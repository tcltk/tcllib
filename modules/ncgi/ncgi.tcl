# ncgi.tcl
#
# Basic support for CGI programs
#
# Copyright (c) 2000 Ajuba Solutions.
# Copyright (c) 2012 Richard Hipp, Andreas Kupries
# Copyright (c) 2013-2014 Andreas Kupries
# Copyright (c) 2018 Poor Yorick 
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.


# Please note that Don Libes' has a "cgi.tcl" that implements version 1.0
# of the cgi package.  That implementation provides a bunch of cgi_ procedures
# (it doesn't use the ::cgi:: namespace) and has a wealth of procedures for
# generating HTML.  In contrast, the package provided here is primarly
# concerned with processing input to CGI programs.  I have tried to mirror his
# API's where possible.  So, ncgi::input is equivalent to cgi_input, and so
# on.  There are also some different APIs for accessing values (ncgi::list,
# and ncgi::get come to mind)

# Note, I use the term "query data" to refer to the data that is passed in
# to a CGI program.  Typically this comes from a Form in an HTML browser.
# The query data is composed of names and values, and the names can be
# repeated.  The names and values are encoded, and this module takes care
# of decoding them.

# We use newer string routines
package require Tcl 8.4
package require fileutil ; # Required by importFile.
package require mime
package require uri

package provide ncgi 1.5.0

namespace eval ::ncgi {

    # "query" holds the raw query (i.e., form) data
    # This is treated as a cache, too, so you can call ncgi::query more than
    # once

    variable query


    if {[info exists env(CONTENT_LENGTH)] && [
	string length $env(CONTENT_LENGTH)] != 0} {
	variable content_length [expr {$env(CONTENT_LENGTH)}]
    }


    # This is the content-type which affects how the query is parsed
    variable contenttype

    if {[info exists ::env(REQUEST_METHOD)]} {
	variable method [string tolower $::env(REQUEST_METHOD)]
    }

    # This holds the URL coresponding to the current request
    # This does not include the server name.

    variable urlStub

    # This flags compatibility with Don Libes cgi.tcl when dealing with
    # form values that appear more than once.  This bit gets flipped when
    # you use the ncgi::input procedure to parse inputs.

    variable listRestrict 0

    # This is the set of cookies that are pending for output

    variable cookieOutput

    # Support for x-www-urlencoded character mapping
    # The spec says: "non-alphanumeric characters are replaced by '%HH'"
 
    variable i
    variable c
    variable map

    for {set i 1} {$i <= 256} {incr i} {
	set c [format %c $i]
	if {![string match \[a-zA-Z0-9\] $c]} {
	    set map($c) %[format %.2X $i]
	}
    }
     
    # These are handled specially
    array set map {
	" " +   \n %0D%0A
    }

    # Map of transient files

    variable  _tmpfiles
    array set _tmpfiles {}

    # I don't like importing, but this makes everything show up in 
    # pkgIndex.tcl

    namespace export all body get merge method reset urlStub query type decode encode
    namespace export input
    namespace export setDefaultValue setDefaultValueList
    namespace export empty import importAll importFile redirect header
    namespace export multipart cookie setCookie

    namespace ensemble create

    namespace ensemble create -command [namespace current]::form -map {
	exists form_exists
	get form_get
    }

    namespace ensemble create -command [namespace current]::query -map {
	parse query_parse
	set query_set
	string query_string
    }

}


# ::ncgi::all
#
#	Return all the values of a named query element as a list, or
#	the empty list if it was not not specified.  This always returns
#	lists - if you do not want the extra level of listification, use
#	ncgi::get instead.
#
# Arguments:
#	key	The name of the query element
#
# Results:
#	The first value of the named element, or ""

proc ::ncgi::all key {
    variable query
    variable form
    query parse
    if {[form exists]} {
	form get
    }
    set result {}
    foreach {qkey val} $query {
	if {$qkey eq $key} {
	    lappend result $val
	}
    }
    if {[form exists]} {
	foreach {fkey val} $form {
	    if {$fkey eq $key} {
		lappend result [lindex $val 0]
	    }
	}
    }
    return $result
}


proc ::ncgi::body {} {
    global env
    variable content_length
    variable method
    variable body
    if {![info exists body]} {
	if {([info exists method] && $method eq {post})
	    && [info exist content_length]
	} {
	    chan configure stdin -translation binary
	    set body [read stdin $env(CONTENT_LENGTH)]
	} else {
	    set body {}
	}
    }
    chan configure stdout -translation binary
    return $body
}


# ::ncgi::cookie
#
#	Return a *list* of cookie values, if present, else ""
#	It is possible for multiple cookies with the same key
#	to be present, so we return a list.
#
# Arguments:
#	cookie	The name of the cookie (the key)
#
# Results:
#	A list of values for the cookie

proc ::ncgi::cookie cookie {
    global env
    set result {} 
    if {[info exists env(HTTP_COOKIE)]} {
	foreach pair [split $env(HTTP_COOKIE) \;] {
	    foreach {key value} [split [string trim $pair] =] { break ;# lassign }
	    if {[string compare $cookie $key] == 0} {
		lappend result $value
	    }
	}
    }
    return $result
}

# ::ncgi::setCookie
#
#	Set a return cookie.  You must call this before you call
#	ncgi::header or ncgi::redirect
#
# Arguments:
#	args	Name value pairs, where the names are:
#		-name	Cookie name
#		-value	Cookie value
#		-path	Path restriction
#		-domain	domain restriction
#		-expires	Time restriction
#
# Side Effects:
#	Formats and stores the Set-Cookie header for the reply.

proc ::ncgi::setCookie {args} {
    variable cookieOutput
    array set opt $args
    set line "$opt(-name)=$opt(-value) ;"
    foreach extra {path domain} {
	if {[info exists opt(-$extra)]} {
	    append line " $extra=$opt(-$extra) ;"
	}
    }
    if {[info exists opt(-expires)]} {
	switch -glob -- $opt(-expires) {
	    *GMT {
		set expires $opt(-expires)
	    }
	    default {
		set expires [clock format [clock scan $opt(-expires)] \
			-format "%A, %d-%b-%Y %H:%M:%S GMT" -gmt 1]
	    }
	}
	append line " expires=$expires ;"
    }
    if {[info exists opt(-secure)]} {
	append line " secure "
    }
    lappend cookieOutput $line
}

# ::ncgi::decode
#
#	This decodes data in www-url-encoded format.
#
# Arguments:
#	An encoded value
#
# Results:
#	The decoded value

if {[package vsatisfies [package present Tcl] 8.6]} {
    # 8.6+, use 'binary decode hex'
    proc ::ncgi::DecodeHex {hex} {
	return [binary decode hex $hex]
    }
} else {
    # 8.4+. More complex way of handling the hex conversion.
    proc ::ncgi::DecodeHex {hex} {
	return [binary format H* $hex]
    }
}

proc ::ncgi::decode {str} {
    # rewrite "+" back to space
    # protect \ from quoting another '\'
    set str [string map [list + { } "\\" "\\\\" \[ \\\[ \] \\\]] $str]

    # prepare to process all %-escapes
    regsub -all -nocase -- {%([E][A-F0-9])%([89AB][A-F0-9])%([89AB][A-F0-9])} \
	$str {[encoding convertfrom utf-8 [DecodeHex \1\2\3]]} str
    regsub -all -nocase -- {%([CDcd][A-F0-9])%([89AB][A-F0-9])} \
	$str {[encoding convertfrom utf-8 [DecodeHex \1\2]]} str
    regsub -all -nocase -- {%([A-F0-9][A-F0-9])} $str {\\u00\1} str

    # process \u unicode mapped chars
    return [subst -novar $str]
}


# ::ncgi::encode
#
#	This encodes data in www-url-encoded format.
#
# Arguments:
#	A string
#
# Results:
#	The encoded value

proc ::ncgi::encode {string} {
    variable map

    # 1 leave alphanumerics characters alone
    # 2 Convert every other character to an array lookup
    # 3 Escape constructs that are "special" to the tcl parser
    # 4 "subst" the result, doing all the array substitutions

    regsub -all -- \[^a-zA-Z0-9\] $string {$map(&)} string
    # This quotes cases like $map([) or $map($) => $map(\[) ...
    regsub -all -- {[][{})\\]\)} $string {\\&} string
    return [subst -nocommand $string]
}


proc ::ncgi::form_get args {
    set type [type]
    variable form
    if {![info exists form]} {
	set form {}
	switch -glob $type {
	    {} -
	    text/xml* -
	    application/x-www-form-urlencoded* -
	    application/x-www-urlencoded* {
		foreach {key val} [urlquery [body]] {
		    lappend form $key [list $val {}]
		}
	    }
	    multipart/* {
		set form [multipart $type [body]]
	    }
	    default {
		return -code error "Unknown Content-Type: $type"
	    }
	}
    }
    if {[llength $args] == 1} {
	lindex [dict get $form {*}$args] 0
    } elseif {[llength $args] == 2} {
	set args [lassign $args[set args {}] key]
	lassign [dict get $form $key] value params
	dict get $params {*}$args
    } elseif {[llength $args]} {
	error [list wrong # args]
    } else {
	return $form
    }
}

proc ::ncgi::form_exists {} {
    variable content_length
    if {[info exists content_length]} {
	switch -glob [type] {
	    {}
	    - text/xml*
	    - application/x-www-form-urlencoded*
	    - application/x-www-urlencoded*
	    - multipart/* {
		return 1
	    }
	}
    }
    return 0
}


# ::ncgi::get
#
#	Return the value of a named query element, or the empty string if
#	it was not not specified.  This only returns the first value of
#	associated with the name.  If you want them all (like all values
#	of a checkbox), use ncgi::all
#
# Arguments:
#	key	The name of the query element
#	default	The value to return if the value is not present
#
# Results:
#	The first value of the named element, or the default

proc ::ncgi::get args {
    variable form
    variable query
    query parse
    if {[form exists]} {
	form get
    }
    if {![llength $args]} {
	return [merge]
    } elseif {[llength $args] <= 2} {
	lassign $args key default
	if {[form exists] && [dict exists $form $key]} {
	    return [lindex [dict get $form $key] 0]
	} elseif {[dict exists $query $key]} {
	    return [dict get $query $key]
	} else {
	    return $default
	}
    } else {
	error [list {wrong # args}]
    }
}


# ncgi:header
#
#	Output the Content-Type header.
#
# Arguments:
#	type	The MIME content type
#	args	Additional name, value pairs to specifiy output headers
#
# Side Effects:
#	Outputs a normal header

proc ::ncgi::header {{type text/html} args} {
    variable cookieOutput
    puts "Content-Type: $type"
    foreach {n v} $args {
	puts "$n: $v"
    }
    if {[info exists cookieOutput]} {
	foreach line $cookieOutput {
	    puts "Set-Cookie: $line"
	}
    }
    puts ""
    flush stdout
}


# ::ncgi::importFile --
#
#   get information about a file upload field
#
# Arguments:
#   cmd         one of '-server' '-client' '-type' '-data'
#   var         cgi variable name for the file field
#   filename    filename to write to for -server
# Results:
#   -server returns the name of the file on the server: side effect
#      is that the file gets stored on the server and the 
#      script is responsible for deleting/moving the file
#   -client returns the name of the file sent from the client 
#   -type   returns the mime type of the file
#   -data   returns the contents of the file 

proc ::ncgi::importFile {cmd var {filename {}}} {
    if {[form exists]} {
	set form [form get]
    }

    lassign [dict get $form $var] content params

    switch -exact -- $cmd {
	-server {
	    ## take care not to write it out more than once
	    variable _tmpfiles
	    if {![info exists _tmpfiles($var)]} {
		if {$filename eq {}} {
		    ## create a tmp file 
		    set _tmpfiles($var) [::fileutil::tempfile ncgi]
		} else {
		    ## use supplied filename 
		    set _tmpfiles($var) $filename
		}

		# write out the data only if it's not been done already
		if {[catch {open $_tmpfiles($var) w} h]} {
		    error "Can't open temporary file in ncgi::importFile ($h)"
		} 

		fconfigure $h -translation binary -encoding binary
		puts -nonewline $h $content 
		close $h
	    }
	    return $_tmpfiles($var)
	}
	-client {
	    if {[dict exists $params filename]} {
		return [dict get $params filename]
	    }
	    return {}
	}
	-type {
	    if {![info exists fileinfo(content-type)]} {return {}}
	    return $fileinfo(content-type)
	}
	-data {
	    return $contents
	}
	default {
	    error "Unknown subcommand to ncgi::import_file: $cmd"
	}
    }
}


proc ::ncgi::merge {} {
    variable form
    variable query
    query parse
    if {[form exists]} {
	list {*}$query {*}[join [lmap {fkey val} $form {
	    list $fkey [lindex $val 0]
	}]]
    } else {
	return $query
    }
}


# ::ncgi::multipart
#
#	Parses $data into a multidict using the boundary provided in $type,
#	which is a complete Content-type value.  Each value in the resulting
#	multi dict is a list where the first item is the value and the the
#	second item is a multidict where each key is the name of a header and
#	each value is a list containing the header value and a dictionary of
#	parameters for that header.

proc ::ncgi::multipart {type data} {
    set token [mime::initialize  -string "Content-Type: $type\n\n$data"]
    set parts [mime::property $token parts]

    set results [list]
    foreach part $parts {
	    set header [::mime::header get $part]
	    set value [::mime::body $part -decode]
	    lassign [::mime::header get $part content-disposition] hvalue params
	    if {$hvalue eq {form-data} && [dict exists $params name]} {
		set name [dict get $params name]
	    } else {
		set name {}
	    }
	    lappend results $name [list $value $header]
    }
    return $results
}


# ::ncgi::parseMimeValue
#
#	Parse a MIME header value, which has the form
#	value; param=value; param2="value2"; param3='value3'
#
# Arguments:
#	value	The mime header value.  This does not include the mime
#		header field name, but everything after it.
#
# Results:
#	A two-element list, the first is the primary value,
#	the second is in turn a name-value list corresponding to the
#	parameters.  Given the above example, the return value is
#	{
#		value
#		{param value param2 value2 param3 value3}
#	}

proc ::ncgi::parseMimeValue {value} {
    set parts [split $value \;]
    set results [list [string trim [lindex $parts 0]]]
    set paramList [list]
    foreach sub [lrange $parts 1 end] {
	if {[regexp -- {([^=]+)=(.+)} $sub match key val]} {
            set key [string trim [string tolower $key]]
            set val [string trim $val]
            # Allow single as well as double quotes
            if {[regexp -- {^(['"])(.*)\1} $val x quote val2]} { ; # need a " for balance
               # Trim quotes and any extra crap after close quote
               # remove quoted quotation marks
               set val [string map {\\" "\"" \\' "\'"} $val2]
            }
            lappend paramList $key $val
	}
    }
    if {[llength $paramList]} {
	lappend results $paramList
    }
    return $results
}

# ::ncgi::query parse
#
#	Parses the query part of the URI
#
proc ::ncgi::query_parse {} {
    variable query
    if {![info exists query]} {
	set query [urlquery [query_string]]
    }
    return $query
}


# ::ncgi::query_set
#
#	set the value of $key in the query dictionary to $value
#
proc ::ncgi::query_set {key value} {
    variable query
    query parse
    set idx [lindex [lmap idx [lsearch -exact -all $key $query] {
	if {[$idx % 2]} continue
	set idx
    }] end]
    if {$idx >= 0} {
	set query [lreplace $query[set query {}] $idx $idx $value]
    } else {
	lappend query $key $value
    }
    return $value
}


# ::ncgi::query_string
#
#	This reads the query data from the appropriate location, which depends
#	on if it is a POST or GET request.
#
# Arguments:
#	none
#
# Results:
#	The raw query data.

proc ::ncgi::query_string {} {
    global env
    variable querystring

    if {[info exists querystring]} {
	# This ensures you can call ncgi::query more than once,
	# and that you can use it with ncgi::reset
	return $querystring
    }

    set querystring {}
    if {[info exists env(QUERY_STRING)]} {
	set querystring $env(QUERY_STRING)
    }
    return $querystring
}


# ::ncgi::redirect
#
#	Generate a redirect by returning a header that has a Location: field.
#	If the URL is not absolute, this automatically qualifies it to
#	the current server
#
# Arguments:
#	url		The url to which to redirect
#
# Side Effects:
#	Outputs a redirect header

proc ::ncgi::redirect {url} {
    global env

    if {![regexp -- {^[^:]+://} $url]} {

	# The url is relative (no protocol/server spec in it), so
	# here we create a canonical URL.

	# request_uri	The current URL used when dealing with relative URLs.  
	# proto		http or https
	# server 	The server, which we are careful to match with the
	#		current one in base Basic Authentication is being used.
	# port		This is set if it is not the default port.

	if {[info exists env(REQUEST_URI)]} {
	    # Not all servers have the leading protocol spec
	    #regsub -- {^https?://[^/]*/} $env(REQUEST_URI) / request_uri
	    array set u [uri::split $env(REQUEST_URI)]
	    set request_uri /$u(path)
	    unset u
	} elseif {[info exists env(SCRIPT_NAME)]} {
	    set request_uri $env(SCRIPT_NAME)
	} else {
	    set request_uri /
	}

	set port ""
	if {[info exists env(HTTPS)] && $env(HTTPS) == "on"} {
	    set proto https
	    if {$env(SERVER_PORT) != 443} {
		set port :$env(SERVER_PORT)
	    }
	} else {
	    set proto http
	    if {$env(SERVER_PORT) != 80} {
		set port :$env(SERVER_PORT)
	    }
	}
	# Pick the server from REQUEST_URI so it matches the current
	# URL.  Otherwise use SERVER_NAME.  These could be different, e.g.,
	# "pop.scriptics.com" vs. "pop"

	if {[info exists env(REQUEST_URI)]} {
	    # Not all servers have the leading protocol spec
	    if {![regexp -- {^https?://([^/:]*)} $env(REQUEST_URI) x server]} {
		set server $env(SERVER_NAME)
	    }
	} else {
	    set server $env(SERVER_NAME)
	}
	if {[string match /* $url]} {
	    set url $proto://$server$port$url
	} else {
	    regexp -- {^(.*/)[^/]*$} $request_uri match dirname
	    set url $proto://$server$port$dirname$url
	}
    }
    ncgi::header text/html Location $url
    puts "Please go to <a href=\"$url\">$url</a>"
}


# ::ncgi::reset
#
#	This resets the state of the CGI input processor.  This is primarily
#	used for tests, although it is also designed so that TclHttpd can
#	call this with the current query data
#	so the ncgi package can be shared among TclHttpd and CGI scripts.
#
# Arguments:
#	newquery	The query data to be used instead of external CGI.
#	newtype		The raw content type.
#
# Side Effects:
#	Resets the cached query data and wipes any environment variables
#	associated with CGI inputs (like QUERY_STRING)

proc ::ncgi::reset args {
    global env
    variable _tmpfiles
    variable body
    variable query
    variable querystring
    variable contenttype
    variable content_length
    variable cookieOutput
    variable form

    # array unset _tmpfiles -- Not a Tcl 8.2 idiom
    unset _tmpfiles ; array set _tmpfiles {}

    set cookieOutput {}
    if {[llength $args] == 0} {
	# We use and test args here so we can detect the
	# difference between empty query data and a full reset.

	foreach name {body contenttype form query querystring} {
	    if {[info exists $name]} {
		unset $name
	    }
	}
    } else {
	set contenttype {}
	if {[info exists body]} {
	    unset body
	    unset content_length
	}
	catch {unset form}
	catch {unset query}

	dict for {opt val} $args {
	    switch $opt {
		body {
		    set $opt $val
		    set content_length [string length $body]
		}
		contenttype - form - querystring {
		    set $opt $val
		}
		default {
		    error [list {unknown reset option} $opt]
		}
	    }
	}
    }
}


# ::ncgi::type
#
#	This returns the content type of the query data.
#
# Arguments:
#	none
#
# Results:
#	The content type of the query data.

proc ::ncgi::type {} {
    global env
    variable contenttype

    if {![info exists contenttype]} {
	if {[info exists env(CONTENT_TYPE)]} {
	    set contenttype $env(CONTENT_TYPE)
	} else {
	    return ""
	}
    }
    return $contenttype
}


# ::ncgi::parsequery
#
#	Parses $data as a url-encoded query and returns a multidict containing
#	the query.
#
proc ::ncgi::urlquery data {
    set result {}

    # Any whitespace at the beginning or end of urlquery data is not
    # considered to be part of that data, so we trim it off.  One special
    # case in which post data is preceded by a \n occurs when posting
    # with HTTPS in Netscape.
    foreach x [split [string trim $data] &] {
	# Turns out you might not get an = sign,
	# especially with <isindex> forms.

	set pos [string first = $x]
	set len [string length $x]

	if {$pos>=0} {
	    if {$pos == 0} { # if the = is at the beginning ...
		if {$len>1} { 
		    # ... and there is something to the right ...
		    set varname [string range $x 1 end]
		    set val {}
		} else { 
		    # ... otherwise, all we have is an =
		    set varname {}
		    set val {} 
		}
	    } elseif {$pos==[expr {$len-1}]} {
		# if the = is at the end ...
		set varname [string range $x 0 [expr {$pos-1}]]
		set val ""
	    } else {
		set varname [string range $x 0 [expr {$pos-1}]]
		set val [string range $x [expr {$pos+1}] end]
	    }
	} else { # no = was found ...
	    set varname $x
	    set val {}
	}		
	lappend result [decode $varname] [decode $val]
    }
    return $result
}


# ::ncgi::urlStub
#
#	Set or return the URL associated with the current page.
#	This is for use by TclHttpd to override the default value
#	that otherwise comes from the CGI environment
#
# Arguments:
#	url	(option) The url of the page, not counting the server name.
#		If not specified, the current urlStub is returned
#
# Side Effects:
#	May affects future calls to ncgi::urlStub
#
proc ::ncgi::urlStub {{url {}}} {
    global   env
    variable urlStub
    if {[string length $url]} {
	set urlStub $url
	return ""
    } elseif {[info exists urlStub]} {
	return $urlStub
    } elseif {[info exists env(SCRIPT_NAME)]} {
	set urlStub $env(SCRIPT_NAME)
	return $urlStub
    } else {
	return ""
    }
}


namespace eval ::ncgi reset
