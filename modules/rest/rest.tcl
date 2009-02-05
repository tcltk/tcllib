package require Tcl 8.5
package require http
package require json
package require tdom
package require base64

package provide rest 1.0

namespace eval ::rest {
    namespace export create_interface parameters parse_opts save \
    describe substitute
}

# create_interface --
#
# main entry point - construct a new rest API
#
# ARGS:
#       name       name of the array containing command definitions
#
# EFFECTS:
#       creates a new namespace and builds api procedures within it
#
# RETURNS:
#       the name of the new namespace, which is the same as the input name
#
proc ::rest::create_interface {name} {
    upvar $name in
    
    # check if any defined calls have https urls and automatically load and register tls
    #if {[catch {package present tls}]} {
    #    foreach x [array names in] {
    #        if {[dict exists $in($x) url] && [string match https://* [dict get $in($x) url]]} {
    #            package require tls
    #            ::http::register https 443 [list ::tls::socket]
    #            break
    #        }
    #    }
    #}

    namespace eval ::$name {}
    foreach call [array names in] {
        set config $in($call)
        set proc [list]

        if {[dict exists $config copy]} {
            set config [dict merge $in([dict get $config copy]) $config]
        }
        if {[dict exists $config unset]} {
            set config [dict unset $config [dict get $config unset]]
        }
        
        lappend proc "set config \{$config\}"
        lappend proc "set headers \{\}"
        lappend proc "set url [dict get $config url]"

        # invocation option processing
        _addopts [dict get $config url] config
        if {[dict exists $config headers]} {
            dict for {k val} [dict get $config headers] {
                _addopts $val config
            }
        }
        set opts [list]
        lappend proc "set static \{[expr {[dict exists $config static_args] ? [dict get $config static_args] : {}}]\}"
        lappend proc {variable static_args}
        lappend proc {if {[info exists static_args]} { set static_args [dict merge $static $static_args] }}
        lappend opts [expr {[dict exists $config req_args] ? [dict get $config req_args] : ""}]
        lappend opts [expr {[dict exists $config opt_args] ? [dict get $config opt_args] : ""}]
        lappend proc "set parsed \[::rest::parse_opts \$static $opts \$args]"
        lappend proc {set query [lindex $parsed 0]}
        lappend proc {set body [lindex $parsed 1]}
        lappend proc {set url [::rest::substitute $url query]}
        if {[dict exists $config body]} {
            if {[string match req* [dict get $config body]]} {
                lappend proc {if {$body == ""} { return -code error "a request body is required" }}
            } elseif {[string match no* [dict get $config none]]} {
                lappend proc {if {$body != ""} { return -code error "extra arguments after options" }}
            }
        }
        # end option processing

        if {[dict exists $config auth]} {
            set auth [dict get $config auth]
            if {$auth == "basic"} {
                lappend proc "lappend headers Authorization \"Basic \[base64::encode \$\{::${name}::user\}:\$\{::${name}::password\}]\""
                if {[info commands ::${name}::basic_auth] == ""} {
                    proc ::${name}::basic_auth {u p} {
                        variable user $u
                        variable password $p
                    }
                }
            }
        }

        if {[dict exists $config headers]} {
            lappend proc {dict for {key val} [dict get $config headers] { lappend headers $key [::rest::substitute $val query] }}
        }
        if {[dict exists $config cookie]} {
            lappend proc {lappend headers Cookie [join [dict get $config cookie] \;]}
        }

        if {[dict exists $config input_transform]} {
            lappend proc "set query \[::${name}::_input_transform_$call \$query]"
            proc ::${name}::_input_transform_$call query [dict get $config input_transform]
        }

        if {[dict exists $config auth] && [lindex [dict get $config auth] 0] == "sign"} {
            lappend proc "set query \[::${name}::[lindex [dict get $config auth] 1] \$query]"
        }
        
        lappend proc {set query [eval ::http::formatQuery $query]}
        
        # if this is an async call (has defined a callback)
        # then end the main proc here by returning the http token
        # the rest of the normal result processing will be put in a _callback_NAME
        # proc which is called by the generic _callback proc
        if {[dict exists $config callback]} {
            lappend proc "set t \[::rest::_call \{[list ::${name}::_callback_$call [dict get $config callback]]\} \$headers \$url \$query \$body]"
            lappend proc {return $t}
            proc ::${name}::$call args [join $proc \n]
            set proc {}
        } else {
            lappend proc {set result [::rest::_call {} $headers $url $query $body]}
        }
        
        # process results
        if {[dict exists $config pre_transform]} {
            lappend proc "set result \[::${name}::_pre_transform_$call \$result]"
            proc ::${name}::_pre_transform_$call result [dict get $config pre_transform]
        }
        if {[dict exists $config result]} {
            lappend proc "set result \[::rest::_format_[dict get $config result] \$result]"
        } else {
            lappend proc "set result \[::rest::_format_auto \$result]"
        }
        if {[dict exists $config post_transform]} {
            lappend proc "set result \[::${name}::_post_transform_$call \$result]"
            proc ::${name}::_post_transform_$call result [dict get $config post_transform]
        }
        if {[dict exists $config check_result]} {
            lappend proc "::rest::_check_result \$result [dict get $config check_result]"
        }
        # end process results

        # if this is an async call (has a defined callback)
        # create the callback proc which contains only the result processing and
        # a handoff to the user defined callback
        # otherwise create the normal call proc
        if {[dict exists $config callback]} {
            lappend proc "[dict get $config callback] $call OK \$result"
            proc ::${name}::_callback_$call {result} [join $proc \n]
        } else {
            lappend proc {return $result}
            proc ::${name}::$call args [join $proc \n]
        }
    }

    proc ::${name}::set_static_args {args} {
        variable static_args
        set static_args $args
    }
    
    set ::${name}::static_args {}
    
    # print the contents of all the dynamic generated procs
    if {0} {
        foreach x [info commands ::${name}::*] {
            puts "proc $x \{[info args $x]\} \{\n[info body $x]\n\}\n"
        }
    }
    return $name
}

# save --
#
# saves a copy of the dynamically created procs to a file for later loading
#
# ARGS:
#       name       name of the array containing command definitions
#       file       name of file in which to save the generated commands
#
# RETURNS:
#       nothing
#
proc ::rest::save {name file} {
    set fh [open $file w]
    puts $fh {package require http
package require json
package require tdom
package require base64
}

    if {![catch {package present tls}]} {
        puts $fh {
package require tls
::http::register https 443 [list ::tls::socket]
}
    }
    
    puts $fh "namespace eval ::$name \{\}\n"
    foreach x {_call _callback parse_opts _addopts substitute _check_result \
            _format_auto _format_raw _format_xml _format_json _format_discard \
            _format_tdom} {
        puts $fh "proc ::${name}::$x \{[info args $x]\} \{[info body $x]\n\}\n"
    }
    foreach x [info commands ::${name}::*] {
        puts $fh "proc $x \{[info args $x]\} \{\n[info body $x]\n\}\n"
    }
    close $fh
}

# parameters --
#
# parse a url query string into a dict
#
# ARGS:
#       url        a url with a query string seperated by a '?'
#       args       optionally a dict key to return instead of the entire dict
#
# RETURNS:
#       a dict containing the parsed query string
#
proc ::rest::parameters {url args} {
    set dict [list]
    foreach x [split [lindex [split $url ?] 1] &] {
        set x [split $x =]
        if {[llength $x] < 2} { lappend x "" }
        eval lappend dict $x
    }
    if {[llength $args] > 0} {
        return [dict get $dict [lindex $args 0]]
    }
    return $dict
}

# _call --
#
# makes an http request
# expected to be called only by a generated procedure
#
# ARGS:
#       name       name of the array containing command definitions
#       callback   empty string, or a list of 2 callback procs,
#                  generated and user defined. if not empty the call will
#                  be made async (-command argument to geturl)
#       headers    a dict of keys/values for the http request header
#       url        the url to request
#       query
#       body
#
# EFFECTS:
#       creates a new namespace and builds api procedures within it
#
# RETURNS:
#       the data from the http reply, or an http token if the request was async
#
proc ::rest::_call {callback headers url query body} {
    # get the settings from the calling proc
    upvar config config
    
    set method get
    if {[dict exists $config method]} { set method [dict get $config method] }

    # assume the query should really be the body for post or put requests
    # with no other body. doesnt seem technically correct but works for
    # everything I have encountered. there is no way for the call definition to
    # specify the difference between url parameters and request body
    if {($method == "post" || $method == "put") && $query != "" && $body == ""} {
        set body $query
        set query {}
    }
    set url $url?$query

    # configure options to the geturl command
    set opts [list]
    lappend opts -method $method
    if {[dict exists $config content-type]} {
        lappend opts -type [dict get $config content-type]
    }
    if {$body != ""} {
        lappend opts -query $body
    }
    if {$callback != ""} {
        lappend opts -command [list ::rest::_callback {*}$callback]
    }

    #puts "headers $headers"
    #puts "opts $opts"
    #puts "geturl $url"
    #return
    set t [http::geturl $url -headers $headers {*}$opts]

    # if this is an async request return now, otherwise process the result
    if {$callback != ""} { return $t }
    if {![string match 2* [http::ncode $t]]} {
        #parray $t
        if {[http::ncode $t] == "302"} {
            upvar #0 $t a
            return -code error [list HTTP 302 [dict get $a(meta) Location]]
        }
        return -code error [list HTTP [http::ncode $t]]
    }
    set data [http::data $t]
    #parray $t
    #puts "data: $data"
    http::cleanup $t
    return $data
}

# _callback --
#
# callback procedure for async http requests
#
# ARGS:
#       datacb     name of the dynamically generated callback proc created by
#                  create_interface which contains post transforms and content
#                  interpreting
#       usercb     the name of the user supplied callback function.
#                  if there is an error it is called directly from here,
#                  otherwise the datacb calls it
#       t          the http request token
#
# EFFECTS:
#       evaluates http error conditions and calls the user defined callback
#
# RETURNS:
#       nothing
#
proc ::rest::_callback {datacb usercb t} {
    if {![string match 2* [http::ncode $t]]} {
        set data [list HTTP [http::ncode $t]]
        if {[http::ncode $t] == "302"} {
            upvar #0 $t a
            lappend data [dict get $a(meta) Location]
        }
        http::cleanup $t
        $usercb ERROR $data
        return
    }
    set data [http::data $t]
    http::cleanup $t
    eval $datacb [list $data]
}

# parse_opts --
#
# command option parsing
#
# ARGS:
#       static       a dict of options and values that are always present
#       required     a list of options that must be supplied
#       optional     a list of options that may appear but are not required
#                    the format is
#                        name    - an option which is present or not, no default
#                        name:   - an option which requires a value
#                        name:value - an option with a default value
#       options      the string of options supplied by the user at invocation
#
# EFFECTS:
#       none
#
# RETURNS:
#       a 2 item list. the first item is a dict containing the parsed
#       options and their values. the second item is a string of any
#       remaining data
#       ex: [list [dict create opt1 value1 opt2 value2] {some extra text supplied to the command}]
#
proc ::rest::parse_opts {static required optional options} {
    #puts "static $static\nrequired $required\noptional $optional\noptions $options"
    set args $options
    set query {}
    foreach {k v} $static {
        set k [string trimleft $k -]
        lappend query $k $v
    }

    foreach opt $required {
        if {[string index $opt end] == ":"} {
            set opt [string range $opt 0 end-1]
        }
        if {[set i [lsearch -exact $args -$opt]] < 0} {
            return -code error "the -$opt argument is required"
        }
        if {[llength $args] <= $i+1} { return -code error "the -$opt argument requires a value" }
        lappend query $opt [lindex $args [expr {$i+1}]]
        set args [lreplace $args $i [expr {$i+1}]]
    }

    while {[llength $args] > 0} {
        set opt [lindex $args 0]
        if {![string match -* $opt]} break
        set opt [string range $opt 1 end]
        
        if {[set i [lsearch $optional $opt:*]] > -1} {
            lappend query $opt [lindex $args 1]
            set args [lreplace $args 0 1]
            set optional [lreplace $optional $i $i]
        } elseif {[set i [lsearch -exact $optional $opt]] > -1} {
            lappend query $opt ""
            set args [lreplace $args 0 0]
            set optional [lreplace $optional $i $i]
        } else {
            set opts {}
            foreach x [concat $required $optional] { lappend opts -[string trimright $x :] }
            if {[[length $opts] > 0} {
                return -code error "bad option \"$opt\": Must be [join $opts ", "]"
            }
            return -code error "bad option \"$opt\""
        }
    }
    
    foreach opt $optional {
        if {[string match *:?* $opt]} {
            set opt [split $opt :]
            lappend query [lindex $opt 0] [join [lrange $opt 1 end]]
        }
    }
    #puts "optional $optional\nquery $query"
    return [list $query [join $args]]
}

# _addopts --
#
# add inline argument identifiers to the options list
#
# ARGS:
#       str        a string which may contain %word% option identifiers
#       c          name of the config variable
#
# EFFECTS:
#       modifies the option variable to add any identifiers found
#
# RETURNS:
#       nothing
#
proc ::rest::_addopts {str c} {
    upvar $c config
    foreach {junk x} [regexp -all -inline -nocase {%([a-z0-9_:-]+)%} $str] {
        if {[string match *:* $x]} {
            dict lappend config opt_args $x
         } else {
            dict lappend config req_args $x:
         }
    }
}

# substitute --
#
# take a string and substitute real values for any option identifiers
#
# ARGS:
#       input      a string which may contain %word% option identifiers
#       q          name of a variable containing a dict of options and values
#
# EFFECTS:
#       removes any substituted options from the q variable
#
# RETURNS:
#       the input string with option identifiers replaced by real values
#
proc ::rest::substitute {input q} {
    upvar $q query
    foreach {junk name} [regexp -all -inline -nocase {%([a-z0-9_:-]+)%} $input] {
        set opt [lindex [split $name :] 0]
        if {[dict exists $query $opt]} {
            set replace [dict get $query $opt]
            set query [dict remove $query $opt]
        } else {
            set replace {}
        }
        set input [string map [list %$name% $replace] $input]
    }
    return $input
}

# describe --
#
# print a description of defined api calls
#
# ARGS:
#       name       name of an interface previously created with create_interface
#
# RETURNS:
#       nothing
#
proc ::rest::describe {name} {
    # replace [set], then run all the procs to get the value of the config var
    rename ::set ::_set
    proc ::set {var val} {
        if {[lindex [info level 0] 1] != "config"} { continue }
        upvar 2 config c
        ::_set c([info level -1]) $val
        return -code return
    }
    foreach call [lsort -dictionary [info commands ::${name}::*]] {
        if {[string match *::_* $call]} { continue }
        catch {$call}
    }
    rename ::set {}
    rename ::_set ::set

    foreach {name val} [array get config] {
        puts -nonewline "$name"
        if {([dict exists $val req_args] && [dict get $val req_args] != "") \
            || ([dict exists $val opt_args] && [dict get $val opt_args] != "")} {
            puts -nonewline "  <options>"
        }
        if {[dict exists $val body] && [dict get $val body] == "required"} {
            puts -nonewline "  <body>"
        }
        puts ""
        if {[dict exists $val description]} {
            puts "[regsub -all {[\s\n]+} [dict get $val description] { }]"
        }
        if {[dict exists $val callback]} {
            puts "Async callback: [dict get $val callback]"
        }
        puts "  Required arguments:"
        if {[dict exists $val req_args]} {
            foreach x [dict get $val req_args] {
                puts "    -[format %-12s [string trimright $x :]]  <value>"
            }
        } else {
            puts "     none"
        }
        puts "  Optional arguments:"
        if {[dict exists $val opt_args]} {
            foreach x [dict get $val opt_args] {
                if {![string match *:* $x]} {
                    puts "  $x"
                } else {
                    set x [split $x :]
                    if {[lindex $x 1] == ""} {
                        puts "    -[format %-12s [lindex $x 0]]  <value>"
                    } else {
                        puts "    -[format %-12s [lindex $x 0]]  <value>  default \"[lindex $x 1]\""
                    }
                }
            }
        } else {
            puts "     none"
        }
        puts ""
    }
}

# _check_result --
#
# checks http returned data against user supplied conditions
#
# ARGS:
#       result     name of the array containing command definitions
#       ok         an expression which if it returns false causes an error
#       err        an expression which if it returns true causes an error
#
# EFFECTS:
#       throws an error if the expression evaluations indicate an error
#
# RETURNS:
#       nothing
#
proc ::rest::_check_result {result ok err} {
    if {$err != "" && ![catch {expr $err} out] && [expr {$out}]} {
        return -code error [list ERR $result "triggered error condition" $err $out]
    }
    if {$ok == "" || (![catch {expr $ok} out] && [expr {$out}])} {
        return -code ok
    }
    return -code error [list ERR $result "ok expression failed or returned false" $ok $out]
}

# _format_auto --
#
# the default data formatter. tries to detect the data type and dispatch
# to a specific handler
#
# ARGS:
#       data      data returned by an http call
#
# RETURNS:
#       data, possibly transformed in a representation specific manner
#
proc ::rest::_format_auto {data} {
    if {[string match {<*} [string trimleft $data]]} {
        return [_format_xml $data]
    }
    if {[string match \{* $data] || [regexp {":\s*[\{\[]} $data]} {
        return [_format_json $data]
    }
    return $data
}

proc ::rest::_format_raw {data} {
    return $data
}

proc ::rest::_format_discard {data} {
    return -code ok
}

proc ::rest::_format_json {data} {
    #if {[regexp -nocase {^[a-z_.]+ *= *(.*)} $data -> json]} {
    #    set data $json
    #}
    return [json::json2dict $data]
}

proc ::rest::_format_xml {data} {
    set d [[dom parse $data] documentElement]
    set data [$d asList]
    if {[lindex $data 0] == "rss"} {
        set data [_format_rss $data]
    }
    return $data
}

proc ::rest::_format_rss {data} {
    set data [lindex $data 2 0 2]
    set out {}
    set channel {}
    foreach x $data {
        if {[lindex $x 0] != "item"} {
            lappend channel [lindex $x 0] \
            [linsert [lindex $x 1] end content [lindex $x 2 0 1]]
        } else {
            set tmp {}
            foreach item [lindex $x 2] {
                lappend tmp [lindex $item 0] \
                [linsert [lindex $item 1] end content [lindex $item 2 0 1]]
            }
            lappend out item $tmp
        }
    }
    return [linsert $out 0 channel $channel]
}

proc ::rest::_format_tdom {data} {
    return [[dom parse $data] documentElement]
}
