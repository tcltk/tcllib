# ncgi.tcl
#
# Basic support for CGI programs

# Please note that Don Libe's has a "cgi.tcl" that implements version 1.0
# of the cgi package.  That implementation provides a bunch of cgi_ procedures
# (it doesn't use the ::cgi:: namespace) and has a wealth of procedures for
# generating HTML.  In contract, the package provided here is primarly concerned
# with processing input to CGI programs.  I have tried to mirror his API's
# where possible.  So, ncgi::input is equivalent to cgi_input, and so on.
# There are also some different APIs for accessing values
# (ncgi::list, ncgi::parse and ncgi::value come to mind)

# Note, I use the term "query data" to refer to the data that is passed in
# to a CGI program.  Typically this comes from a Form in an HTML browser.
# The query data is composed of names and values, and the names can be
# repeated.  The names and values are encoded, and this module takes care
# of decoding them.

package provide ncgi 1.0

namespace eval ncgi {

    # "query" holds the raw query (i.e., form) data
    # This is treated as a cache, too, so you can call ncgi::query more than once

    variable query

    # value is an array of parsed query data.  If a value occurs more than
    # one time in the query data then the value is turned into a list.
    # You have to know if your form has repeated values to know whether or
    # not to expect the list structure.

    variable value

    # This lists the names that appear in the query data

    variable varlist

    # This flags compatibility with Don Libes cgi.tcl when dealing with
    # form values that appear more than once.  This bit gets flipped when
    # you use the ncgi::input procedure to parse inputs.

    variable listRestrict 0

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
 
    # I don't like importing, but this makes everything show up in pkgIndex.tcl

    namespace export *
}

# ncgi::reset
#
#	This resets the state of the CGI input processor.  This is primarily
#	used for tests, although it is also designed so that TclHttpd can
#	call this with the current query data
#	so the ncgi package can be shared among TclHttpd and CGI scripts.
#
# Arguments:
#	newquery	(optional) The raw query.  If this is specified it
#			indicates this is either a testing situation or use
#			within a web server context instead of external CGI.
#
# Side Effects:
#	Resets the cached query data and wipes any environment variables
#	associated with CGI inputs (like QUERY_STRING)

proc ncgi::reset {{newquery {}}} {
    global env
    variable query
    if {[string length $newquery] == 0} {
	if {[info exist query]} {
	    unset query
	}
    } else {
	set query $newquery
    }
}

# ncgi::query
#
#	This reads the query data from the appropriate location, which depends
#	on if it is a POST or GET request.
#
# Arguments:
#	fakeinput	The raw query for use in testing.  This is used if
#			the environment suggests the program is being
#			run from outside a web server.
#
# Results:
#	The raw query data.

proc ncgi::query {{fakeinput {}}} {
    global env
    variable query

    if {[info exist query]} {
	# This ensures you can call ncgi::query more than once 
	return $query
    }

    set query ""
    if {![info exist env(REQUEST_METHOD)]} {
	set query $fakeinput
    } elseif {$env(REQUEST_METHOD) == "GET"} {
	if {[info exists env(QUERY_STRING)]} {
	    set query $env(QUERY_STRING)
	}
    } elseif {$env(REQUEST_METHOD) == "POST"} {
	if {[info exists env(CONTENT_LENGTH)] &&
		[string length $env(CONTENT_LENGTH)] != 0} {
	    set query [read stdin $env(CONTENT_LENGTH)]
	}
    }
    return $query
}

# ncgi::decode
#
#	This decodes data in www-url-encoded format.
#
# Arguments:
#	An encoded value
#
# Results:
#	The decoded value

proc ncgi::decode {str} {
    # Protect Tcl special chars
    regsub -all {[][\\\$]} $str {\\&} str
    # Replace %xx sequences with a format command
    regsub -all {%([0-9a-fA-F][0-9a-fA-F])} $str {[format %c 0x\1]} str
    # Replace the format commands with their result
    return [subst $str]
}

# ncgi::encode
#
#	This encodes data in www-url-encoded format.
#
# Arguments:
#	A string
#
# Results:
#	The encoded value

proc ncgi::encode {string} {
    variable map

    # 1 leave alphanumerics characters alone
    # 2 Convert every other character to an array lookup
    # 3 Escape constructs that are "special" to the tcl parser
    # 4 "subst" the result, doing all the array substitutions

    regsub -all \[^a-zA-Z0-9\] $string {$map(&)} string
    if {0} {
	# These lines seem totally bogus - am I missing something?
	regsub -all \n $string {\\n} string
	regsub -all \t $string {\\t} string
    }
    # This quotes cases like $map([) or $map($)
    regsub -all {[][{})\\]\)} $string {\\&} string
    return [subst $string]
}


# ncgi::list
#
#	This parses the query data and returns it as a name, value list
#
# Arguments:
#	fakeinput	See ncgi::query
#
# Results:
#	An alternating list of names and values

proc ncgi::list {{fakeinput {}}} {
    set query [ncgi::query $fakeinput]
    regsub -all {\+} $query { } query
    set result {}
    foreach {x} [split $query &] {
	# Turns out you might not get an = sign, expecially with <isindex> forms.
	if {![regexp (.*)=(.*) $x dummy varname val]} {
	    set varname anonymous
	    set val $x
	}
	lappend result [ncgi::decode $varname] [ncgi::decode $val]
    }
    return $result
}

# ncgi::parse
#
#	The parses the query data and stores it into an array for later retrieval.
#	You should use the ncgi::value or ncgi::valuelist procedures to get those
#	values, or you are allowed to access the ncgi::value array directly.
#
#	Note - all values have a level of list structure associated with them
#	to allow for multiple values for a given form element (e.g., a checkbox)
#
# Arguments:
#	fakeinput	See ncgi::query
#
# Results:
#	A list of names of the query values

proc ncgi::parse {{fakeinput {}}} {
    variable value
    variable listRestrict 0
    variable varlist {}
    if {[info exist value]} {
	unset value
    }
    foreach {name val} [ncgi::list $fakeinput] {
	if {![info exist value($name)]} {
	    lappend varlist $name
	}
	lappend value($name) $val
    }
    return $varlist
} 

# ncgi::input
#
#	Like ncgi::parse, but with Don Libes cgi.tcl semantics.
#	Form elements must have a trailing "List" in their name to be
#	listified, otherwise this raises errors if an element appears twice.
#
# Arguments:
#	fakeinput	See ncgi::query
#	fakecookie	The raw cookie string to use when testing.
#
# Results:
#	The list of element names in the form

proc ncgi::input {{fakeinput {}} {fakecookie {}}} {
    variable value
    variable varlist {}
    variable listRestrict 1
    if {[info exist value]} {
	unset value
    }
    foreach {name val} [ncgi::list $fakeinput] {
	set exists [info exist value($name)]
	if {!$exists} {
	    lappend varlist $name
	}
	if {[regexp List$ $name]} {
	    # Accumulate a list of values for this name
	    lappend value($name) $val
	} elseif {$exists} {
	    error "Multiple definitions of $name encountered in input.\
	    If you're trying to do this intentionally (such as with select),\
	    the variable must have a \"List\" suffix."
	} else {
	    # Capture value with no list structure
	    set value($name) $val
	}
    }
    return $varlist
} 

# ncgi::value
#
#	Return the value of a named query element, or the empty string if
#	it was not not specified.  This only returns the first value of
#	associated with the name.  If you want them all (like all values
#	of a checkbox), use ncgi::valuelist
#
# Arguments:
#	name	The name of the query element
#
# Results:
#	The first value of the named element, or ""

proc ncgi::value {key} {
    variable value
    variable listRestrict
    if {[info exists value($key)]} {
	if {$listRestrict} {
	    
	    # ncgi::input was called, and it already figured out if the
	    # user wants list structure or not.

	    return $value($key)
	} else {

	    # Undo the level of list structure done by ncgi::parse

	    return [lindex $value($key) 0]
	}
    } else {
	return ""
    }
}

# ncgi::valuelist
#
#	Return all the values of a named query element as a list, or
#	the empty list if it was not not specified.  This always returns
#	lists - if you do not want the extra level of listification, use
#	ncgi::value instead.
#
# Arguments:
#	name	The name of the query element
#
# Results:
#	The first value of the named element, or ""

proc ncgi::valuelist {key} {
    variable value
    if {[info exists value($key)]} {
	return $value($key)
    } else {
	return [list]
    }
}

# ncgi::import
#
#	Map a CGI input into a Tcl variable.  This creates a Tcl variable in
#	the callers scope that has the value of the CGI input.  An alternate
#	name for the Tcl variable can be specified.
#
# Arguments:
#	cginame		The name of the form element
#	tclname		If present, an alternate name for the Tcl variable,
#			otherwise it is the same as the form element name

proc ncgi::import {cginame {tclname {}}} {
    if {[string length $tclname]} {
	upvar 1 $tclname var
    } else {
	upvar 1 $cginame var
    }
    set var [ncgi::value $cginame]
}

# Should add some COOKIE support

# ncgi::redirect
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

proc ncgi::redirect {url} {
    global env

    # Create a canonical URL

    if {[info exist env(REQUEST_URI)]} {
	# Not all servers have the leading protocol spec
	regsub {^https?://[^/]*/} $env(REQUEST_URI) / request_uri
    } elseif {[info exist env(SCRIPT_NAME)]} {
	set request_uri $env(SCRIPT_NAME)
    } else {
	set request_uri /
    }

    if {![regexp {^[^:]+://} $url]} {
	set port ""
	if {[info exist env(HTTPS)] && $env(HTTPS) == "on"} {
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
	if {[string match /* $url]} {
	    set url $proto://$env(SERVER_NAME)$port$url
	} else {
	    regexp {^(.*/)[^/]*$} $request_uri match dirname
	    set url $proto://$env(SERVER_NAME)$port$dirname$url
	}
    }
    puts stdout "Content-Type: text/html
Location: $url

Please go to <a href=\"$url\">$url</a>"
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

proc ncgi::header {{type text/html} args} {
    puts "Content-Type: $type"
    foreach {n v} $args {
	puts "$n: $v"
    }
    puts ""
    flush stdout
}
