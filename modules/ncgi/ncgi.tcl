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
# concerned with processing input to CGI programs.

# Note, I use the term "query data" to refer to the data that is passed in
# to a CGI program.  Typically this comes from a Form in an HTML browser.
# The query data is composed of names and values, and the names can be
# repeated.  The names and values are encoded, and this module takes care
# of decoding them.

# We use newer string routines
package require Tcl 8.6
package require {chan base}
package require fileutil ; # Required by importFile.
package require mime 3.0-
package require uri

package provide ncgi 1.5.0

namespace eval ::ncgi {

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
	{ } + \n %0D%0A
    }

}

proc ::ncgi::.namespace token {
    namespace ensemble configure $token -namespace
}


# ::ncgi::all
#
#	Returns all the values of a named query element as a list, or
#	the empty list if $name was not not specified.  Always returns
#	lists.  Consider using ncgi::get instead.
#
# Arguments:
#	key	The name of the query element
#
# Results:
#	The first value of the named element, or ""

proc ::ncgi::all {token name} {
    namespace upvar $token query query form form
    query $token parse
    if {[form $token exists]} {
	form $token get 
    }
    set result {}
    foreach {qname val} $query {
	if {$qname eq $name} {
	    lappend result $val
	}
    }
    if {[form $token exists]} {
	foreach {fname val} $form {
	    if {$fname eq $name} {
		lappend result [lindex $val 0]
	    }
	}
    }
    return $result
}


proc ::ncgi::body token {
    global env
    namespace upvar $token {*}{
	body body content_length content_length method method
    }
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
#	Returns a multidict of incoming cookies.

namespace eval ::ncgi::cookies {
    namespace ensemble create -parameters token
    namespace export all get

    proc all {token name} {
	namespace upvar $token cookies cookies
	init $token
	lmap {name1 val} $cookies {
	    if {$name1 ne $name} continue
	    lindex $val
	}
    }

    proc init token {
	global env
	namespace upvar $token cookies cookies
	if {![info exists cookies]} {
	    if {[info exists env(HTTP_COOKIE)]} {
		set cookies [join [lmap pair [split $env(HTTP_COOKIE) \;] {
		    split [string trim $pair] =
		}]]
	    } else {
		set cookies {}
	    }
	}
	return 
    }

    proc get {token args} {
	init $token
	namespace upvar $token cookies cookies
	switch [llength $args] {
	    1 {
		return [dict get $cookies [lindex $args 0]]
	    }
	    0 {
		return $cookies
	    }
	    default {
		error [list {wrong # args}]
	    }
	}
    }
}

proc ::ncgi::delete token {
    namespace delete [namespace ensemble configure $token -namespace]
}


# ::ncgi::decode
#
#	Decodes data in www-url-encoded format.
#
# Arguments:
#	An encoded value.
#
# Results:
#	The decoded value.
proc ::ncgi::DecodeHex {hex} {
    return [binary decode hex $hex]
}

proc ::ncgi::decode str {
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
#	Encodes data in www-url-encoded format.
#
# Arguments:
#	A string
#
# Results:
#	The encoded value

proc ::ncgi::encode string {
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


proc ::ncgi::form_get {token args} {
    namespace upvar $token form form
    set type [type $token]
    if {![info exists form]} {
	set form {}
	switch -glob $type {
	    {} -
	    text/xml* -
	    application/x-www-form-urlencoded* -
	    application/x-www-urlencoded* {
		foreach {key val} [urlquery [body $token]] {
		    lappend form $key [list $val {}]
		}
	    }
	    multipart/* {
		multipart $token
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


proc ::ncgi::form_exists token {
    namespace upvar $token content_length content_length
    if {[info exists content_length]} {
	switch -glob [type $token] {
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

proc ::ncgi::headerfilter headers {
    join [lmap {key val} $headers[set headers {}] {
	if {[string tolower $key] in {content-type}} continue
	list $key $val
    }]
}


proc ::ncgi::header_send {token type args} {
    namespace upvar $token respons response 
    set mimeout [mime::.new {} -canonical $type -params $args \
	-addcontentid 0 -addmimeversion 0 -addmessageid 0 -string {}
    ]
    foreach {n v} [headerfilter [$token response header get]] {
	$mimeout header set $n {*}$v
    }
    $token response .destroy
    $mimeout serialize -chan ${token}::stdout
    ${token}::stdout flush
    $mimeout .destroy
}


# ::ncgi::get
#
#	Returns the value of a named query element, or the empty string if
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

proc ::ncgi::get {token args} {
    namespace upvar $token form form query query
    query $token parse
    if {[form $token exists]} {
	form $token get
    }
    set merged [merge $token]
    if {![llength $args]} {
	return $merged
    } elseif {[llength $args] <= 2} {
	lassign $args key default
	try {
	    return [lindex [dict get $merged $key] 0]
	} on error {} {
	    return $default
	}
    } else {
	error [list {wrong # args}]
    }
}


# ::ncgi::importFile --
#
#   get information about a file upload field
#
# Arguments:
#   cmd         one of '-server' '-client' '-type' '-data'
#   var         cgi variable name for the file field
# Results:
#   -server returns the name of the file on the server: side effect
#      is that the file gets stored on the server and the 
#      script is responsible for deleting/moving the file
#   -client returns the name of the file sent from the client 
#   -type   returns the mime type of the file
#   -data   returns a channel command for the contents of the file 

proc ::ncgi::importFile {token cmd var {filename {}}} {
    namespace upvar $token mimeparts mimeparts
    if {[form $token exists]} {
	set form [form $token get]
    }

    lassign [dict get $mimeparts $var] mime 

    lassign [$mime header get content-disposition] cdisp dispparams

    switch -exact -- $cmd {
	-server {
	    return [$mime body decode]
	}
	-client {
	    if {[dict exists $dispparams filename]} {
		return [dict get $dispparams filename]
	    }
	    return {}
	}
	-type {
	    lassign [$mime header get content-type] ctype params
	    return $ctype
	}
	-data {
	    return [$mime body decoded]
	}
	default {
	    error "Unknown subcommand to ncgi::import_file: $cmd"
	}
    }
}


proc ::ncgi::merge token {
    namespace upvar $token form form query query
    query $token parse
    set query2 [join [lmap {key val} $query {
	list $key [list $val {}]
    }]]
    if {[form $token exists]} {
	# form overrides query in a multidict
	list {*}$query2 {*}[join [lmap {key val} $form {
	    list $key $val 
	}]]
    } else {
	return $query2
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

proc ::ncgi::multipart token {
    namespace upvar $token form form mime mime mimeparts mimeparts
    set type [type $token]
    set data [body $token]
    set mime [mime::.new {}  -string "Content-Type: $type\n\n$data"]
    set parts [$mime property parts]
    trace add variable mime unset [list apply [list {mime args} {
	if {[namespace which $mime] ne {}} {
	    $mime .destroy
	}
    } $mime]]

    set results [list]
    foreach part $parts {
	set value [[$part body decoded] read]
	lassign [$part header get content-disposition] hvalue params
	if {$hvalue eq {form-data} && [dict exists $params name]} {
	    set name [dict get $params name]
	    dict unset params name
	} else {
	    set name {}
	}
	lappend mimeparts $name $part 
	lappend form $name [list $value $params]
    }
    return $form
}


# ::ncgi::.new
#	Create a new cgi session and return a token for that session
# Arguments:
#	newquery	The query data to be used instead of external CGI.
#	newtype		The raw content type.
#
# Side Effects:
#	Resets the cached query data and wipes any environment variables
#	associated with CGI inputs (like QUERY_STRING)

proc ::ncgi::.new {token name args} {
    if {$name eq {}} {
	set name [namespace current]::[info cmdcount]
    } elseif {![string match ::* $name]} {
	set name [uplevel 1 {namespace current}]::$name
    }
    set ns [namespace eval $name {
	namespace ensemble create
	namespace current
    }]
    # normalize $name
    set name [namespace which $name]

    [::tcllib::chan::base new ${ns}::stdout] .init stdout -close 0

    namespace ensemble create -command ${ns}::header -map [list \
	send [list header_send $name]
    ]

    mime::.new ${ns}::response -canonical text/html -spec cgi -string {}

    set map [dict merge [list decode decode encode encode {*}[join [lmap cmdname {
	.namespace .new all importFile input body cookies delete form get
	merge method query redirect type urlStub
    } {
	list $cmdname [list $cmdname $name]
    }]]] [list \
	header [list ${ns}::header] \
	response [list ${ns}::response] \
	stdout [list ${ns}::stdout]
    ]]
    namespace ensemble configure $name -map $map
    
    trace add command $name delete [list apply [list {
	token headercmd old new op} {
	$old .destroy
    }]]

    # $query holds the raw query (i.e., form) data
    # This is treated as a cache, too, so you can call ncgi::query more than
    # once

    # $contenttype is the content-type, which affects how the query is parsed

    # $urlStub holds the URL corresponding to the current request
    # This does not include the server name.

    namespace upvar $ns \
	_tmpfiles _tmpfiles \
	body body \
	content_length content_length \
	contenttype contenttype \
	env env \
	form form \
	listRestrict listRestrict \
	method method \
	query query \
	querystring querystring \
	urlStub urlStub \


    # Map of transient files
    array set _tmpfiles {}

    # $listRestrict flags compatibility with Don Libes cgi.tcl when dealing
    # with form values that appear more than once.  This bit gets flipped when
    # you use the ncgi::input procedure to parse inputs.
    set listRestrict 0

    dict for {opt val} $args {
	switch $opt {
	    body {
		set $opt $val
		set content_length [string length $body]
	    }
	    contenttype - env - form - querystring {
		set $opt $val
	    }
	    default {
		error [list {unknown reset option} $opt]
	    }
	}
    }

    if {![info exists env]} {
	array set env [array get ::env]
    }

    if {[info exists env(CONTENT_LENGTH)] && [
	string length $env(CONTENT_LENGTH)] != 0} {
	set content_length [expr {$env(CONTENT_LENGTH)}]
    }

    if {[info exists env(REQUEST_METHOD)]} {
	set method [string tolower $env(REQUEST_METHOD)]
    }

    return $name
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

proc ::ncgi::parseMimeValue value {
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
proc ::ncgi::query_parse token {
    namespace upvar $token query query
    if {![info exists query]} {
	set query [urlquery [query_string $token]]
    }
    return $query
}


# ::ncgi::query_set
#
#	set the value of $key in the query dictionary to $value
#
proc ::ncgi::query_set {token key value} {
    namespace upvar $token query query
    query $token parse
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
#	Reads the query data from the QUERY_STRING environment variable if
#	needed.
#
# Arguments:
#	none
#
# Results:
#	The raw query data.

proc ::ncgi::query_string token {
    namespace upvar $token env env querystring querystring

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

proc ::ncgi::redirect {token url} {
    namespace upvar $token env env
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

    set mimeout [mime::.new {} -canonical text/html -addcontentid 0 \
	-addmimeversion 0 -addmessageid 0 \
	-string "Please go to <a href=\"$url\">$url</a>\n"
    ]

    foreach {n v} [headerfilter [$token response header get]] {
	$mimeout header set $n {*}$v
    }
    $token response .destroy

    $mimeout header set Location $url
    $mimeout serialize -chan ${token}::stdout
    ${token}::stdout flush
    $mimeout .destroy
    return
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
proc ::ncgi::type token {
    namespace upvar $token contenttype contenttype env env

    if {![info exists contenttype]} {
	if {[info exists env(CONTENT_TYPE)]} {
	    set contenttype $env(CONTENT_TYPE)
	} else {
	    return {} 
	}
    }
    return $contenttype
}


# ::ncgi::urlquery
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
proc ::ncgi::urlStub {token {url {}}} {
    global  env
    namespace upvar $token urlStub urlStub
    if {[string length $url]} {
	set urlStub $url
	return {} 
    } elseif {[info exists urlStub]} {
	return $urlStub
    } else {
	if {[info exists env(SCRIPT_NAME)]} {
	    set urlStub $env(SCRIPT_NAME)
	} else {
	    set urlStub {}
	}
	return $urlStub
    }
}

namespace eval ::ncgi {
    namespace ensemble create -command [namespace current]::form \
	-parameters token -map {
	exists form_exists
	get form_get
    }

    namespace ensemble create -command [namespace current]::query \
	-parameters token -map {

	parse query_parse
	set query_set
	string query_string
    }

    .new dummy [namespace current]
}

