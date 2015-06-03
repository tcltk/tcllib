## 
 # oa2rest package - framework for making OAuth2+REST calls
 # 
 ##

# We'll use {*}.
package require Tcl 8.5


# The framework is in many ways a wrapper around the http::geturl command.
package require http

# OAuth2 relies on Transport Layer Security, 
# and as of 2014 many servers require that *clients* would not accept 
# a downgrade to any flavour of SSL, so we'd better register https 
# accordingly.
# 
package require tls
http::register https 443 [list ::tls::socket -ssl2 no -ssl3 no -tls1 yes]


# The framework represents services using TclOO objects, though the user 
# probably shouldn't care exact which OOP system is used.
# 
package require TclOO
# 
# (I started out coding using snit, but hit a _very_ corny critical bug in 
# that case. It shouldn't have mattered, but in an important setting it 
# mattered all too much.)


############################
#                          #
#   JSON data formatting   #
#                          #
############################

# Tcllib does have a separate json::write package, but it would be 
# difficult to replace the following with that, because this is *really* 
# about providing a Little Language for constructing data structures that 
# will happen to end up encoded as JSON.

namespace eval ::oa2rest::json {}


## 
 # ::oa2rest::json::Wrapper $level $script
 # 
 # The intuitive model one should have for this procedure is that it is 
 # like an [uplevel], but forces the current namespace to be 
 # ::oa2rest::json instead of whatever it was at the target calling frame. 
 # This means that inside the $script of an
 # 
 #   ::oa2rest::json::Wrapper $level $script
 # 
 # you can refer to variables as you would in the $script of an
 # 
 #   ::uplevel $level $script
 # 
 # but the commands of the ::oa2rest::json namespace will have precedence 
 # over global commands.
 # 
 # Technically, what happens is rather that the Wrapper procedure [upvar]s 
 # all variables from the $level call frame. The procedure makes use of 
 # the precise order in which substitutions are made to ensure that all 
 # local variables in Wrapper are unset before the [upvar] creates new 
 # ones. Also, the [if] should have the effect of having the $script 
 # become bytecompiled.
 # 
 ##

proc ::oa2rest::json::Wrapper {level script} {
    if {[
        set varL [list]
        foreach var [uplevel $level [list ::info vars]] {
            lappend varL $var $var
        }
        upvar $level {*}$varL {*}[unset level script var varL]
        return -level 0 true
    ]} then $script
}


proc ::oa2rest::json::Quotestr {str} {
    string map {
        \" {\"} \\ {\\} 
        \x00 {\u0000} \x01 {\u0001} \x02 {\u0002} \x03 {\u0003} 
        \x04 {\u0004} \x05 {\u0005} \x06 {\u000C} \x07 {\u0007} 
        \x08 {\b}     \x09 {\t}     \x0A {\n}     \x0B {\u000B} 
        \x0C {\f}     \x0D {\r}     \x0E {\u000E} \x0F {\u000F} 
        \x10 {\u0010} \x11 {\u0011} \x12 {\u0012} \x13 {\u0013} 
        \x14 {\u0014} \x15 {\u0015} \x16 {\u001C} \x17 {\u0017} 
        \x18 {\u0018} \x19 {\u0019} \x1A {\u001A} \x1B {\u001B} 
        \x1C {\u001C} \x1D {\u001D} \x1E {\u001E} \x1F {\u001F} 
    } $str
}

    


#   {
#       "Image": {
#           "Width":  800,
#           "Height": 600,
#           "Title":  "View from 15th Floor",
#           "Thumbnail": {
#               "Url":    "http://www.example.com/image/481989943",
#               "Height": 125,
#               "Width":  "100"
#           },
#           "IDs": [116, 943, 234, 38793]
#       }
#   }
#   
# jsonbody {
#     D Image {
#         I Width 800
#         I Height 600
#         S Title "View from 15th Floor"
#         D Thumbnail {
#             S Url http://www.example.com/image/481989943
#             I Height 125
#             S Width 100 ; # Weird. Error in original example?
#         }
#         A IDs {
#             I 116; I 943; I 234; I 38793
#         }
#     }
# }


## 
 # ::oa2rest::json::dictscript   -- evaluate a script that builds 
 # ::oa2rest::json::arrayscript     a JSON dict or array
 # 
 # These two procedures take a script as argument, and return a formatted 
 # JSON value (dict/object or array, respectively). Since most of the work 
 # is carried out by the A, B, D, I, JSON, N, S, and null procedures, 
 # these two mostly serve as home for two variables which the others 
 # access using [upvar]: state and res.
 # 
 # res is where the formatted JSON code is collected. It is simply a 
 # string to which JSON tokens are appended.
 # 
 # state is an integer, which keeps track of the current context at the 
 # end of res:
 #   0 - We're building an array, and it is so far empty.
 #   1 - We're building a dict, and it is so far empty.
 #   2 - We're building an array, and it has at least one member.
 #   3 - We're building a dict, and it has at least one member.
 # Masking with &1 and &2 extracts either boolean flag.
 # 
 ##

proc ::oa2rest::json::dictscript {script} {
    set res \{
    set state 1
    Wrapper 2 $script
    append res \}
}

proc ::oa2rest::json::arrayscript {script} {
    set res \[
    set state 0
    Wrapper 2 $script
    append res \]
}

# A consequence of this design is that the various data-appending 
# procedures contain a significant amount of basic boilerplate code 
# for handling the state; even the required number of arguments of these 
# procedures depends on whether we're in a dict (where a key is required) 
# or in an array (where it is forbidden). An example of this is provided 
# by the B procedure for boolean data.

## 
 # ::oa2rest::json::B $key $boolean   (if $state is odd)
 # ::oa2rest::json::B $boolean        (if $state is even)
 # 
 # Appends a boolean value to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::B {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        # In dict
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "B key boolean"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        # In array
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "B boolean"}
        }
    }
    # End boilerplate, begin data handling.
    if {[lindex $args end]} then {
        append res true
    } else {
        append res false
    }
}

## 
 # ::oa2rest::json::I $key $integer   (if $state is odd)
 # ::oa2rest::json::I $integer        (if $state is even)
 # 
 # Appends an integer value to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::I {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "I key integer"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "I integer"}
        }
    }
    # End boilerplate, begin data handling.
    # 
    # JSON is more restrictive than Tcl when it comes to formats for 
    # integers (base 10 only, no leading zeroes, no plus sign), but a 
    # simple [format] will take care of that.
    append res [format %lld [lindex $args end]]
}

## 
 # ::oa2rest::json::N $key $number   (if $state is odd)
 # ::oa2rest::json::N $number        (if $state is even)
 # 
 # Appends a number (typically a floating-point number, since I can take 
 # care of all integers, but JSON does not enforce a distinction between 
 # integer and floating-point numbers, and neither does this) value to 
 # the composite JSON value being constructed. An error is thrown if the 
 # number cannot be put on a valid JSON form; this happens for Inf and 
 # NaN. A $number that is not on some valid JSON form will be coerced to 
 # a double.
 ##

proc ::oa2rest::json::N {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "N key number"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "N number"}
        }
    }
    # End boilerplate, begin data handling.
    set num [lindex $args end]
    if {![regexp {^-?(0|[1-9][0-9]*)(\.[0-9]+)?([Ee][+-][0-9]+)?$}]} then {
        set num [::tcl::mathfunc::double $num]
    }
    if {![regexp {^-?(0|[1-9][0-9]*)(\.[0-9]+)?([Ee][+-][0-9]+)?$}]} then {
        return -code error -errorcode {JSON DOMAIN}\
          {domain error: argument not in valid range}
    }
    append res $num
}

## 
 # ::oa2rest::json::JSON $key $json   (if $state is odd)
 # ::oa2rest::json::JSON $json        (if $state is even)
 # 
 # Appends a preformatted JSON value to the composite JSON value being 
 # constructed. The value is not validated.
 ##

proc ::oa2rest::json::JSON {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        # Dict
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "JSON key json-value"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        # Array
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "JSON json-value"}
        }
    }
    # End boilerplate, begin data handling.
    append res [lindex $args end]
}

## 
 # ::oa2rest::json::null $key   (if $state is odd)
 # ::oa2rest::json::null        (if $state is even)
 # 
 # Appends a null value item to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::null {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "null key"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "null"}
        }
    }
    # End boilerplate, begin data handling.
    append res null
}

## 
 # ::oa2rest::json::S $key $string    (if $state is odd)
 # ::oa2rest::json::S $string         (if $state is even)
 # 
 # Appends a string value to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::S {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "S key string"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "S string"}
        }
    }
    # End boilerplate, begin data handling.
    append res \" [Quotestr [lindex $args end]] \"
}


## 
 # ::oa2rest::json::A $key $script    (if $state is odd)
 # ::oa2rest::json::A $script         (if $state is even)
 # 
 # Appends an array value, consisting of the elements appended by the 
 # $script, to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::A {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "A key script"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "A script"}
        }
    }
    # End boilerplate, begin data handling.
    set saved_state $state
    set state 0
    append res \[
    uplevel [lindex $args end]
    append res \]
    set state $saved_state
}

## 
 # ::oa2rest::json::D $key $script    (if $state is odd)
 # ::oa2rest::json::D $script         (if $state is even)
 # 
 # Appends a dict value, consisting of the members appended by the 
 # $script, to the composite JSON value being constructed.
 ##

proc ::oa2rest::json::D {args} {
    upvar 2 res res state state
    if {$state & 2} then {
        append res ,
    } else {
        incr state 2
    }
    if {$state & 1} then {
        if {[llength $args] != 2} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "D key script"}
        }
        append res \" [Quotestr [lindex $args 0]] \" : 
    } else {
        if {[llength $args] != 1} then {
            return -code error -errorcode {TCL WRONGARGS}\
              {wrong # args: should be "D script"}
        }
    }
    # End boilerplate, begin data handling.
    set saved_state $state
    set state 1
    append res \{
    uplevel [lindex $args end]
    append res \}
    set state $saved_state
}





#######################
#                     #
#   Service objects   #
#                     #
#######################

oo::class create ::oa2rest::bearerservice {
    
    variable baseurl bearertoken keepalive

    constructor {base bearer args} {
        set baseurl $base
        set bearertoken $bearer
        set keepalive 1
        foreach {key val} $args {
            switch -glob -- $key {
                -keepalive {
                    if {[string is boolean -strict $val]} then {
                        set keepalive $val
                    } else {
                        return -code error\
                          "-keepalive value must be boolean"
                    }
                }
                default {
                    return -code error "Unknown option: $key"
                }
            }
        }
    }
    
    method send {verb path args} {
        set handledopts [dict create -keepalive $keepalive]
        set otheropts {}
        set headers [dict create Authorization "Bearer $bearertoken"]
        
        foreach {clause data} $args {
            switch -glob -- $clause {
                jsonbody {
                    set json [uplevel 1\
                      [list ::oa2rest::json::dictscript $data]]
                    dict set handledopts -query [encoding convertto utf8 $json]
                    dict set headers Content-Type "application/json;charset=UTF-8"
                }
                -headers {
                    set headers [dict merge $headers $data]
                }
                -keepalive - -query {
                    dict set handledopts $clause $data
                }
                -type {
                    dict set headers Content-Type $data
                }
                -method {
                    return -code error "The HTTP method is\
                      specified in the verb argument of send"
                }
                -* {
                    lappend otheropts $clause $data
                }
                default {
                    return -code error "Unknown clause: $clause"
                }
            }
        }
        
        ::http::geturl $baseurl$path -method $verb\
          -headers $headers {*}$handledopts {*}$otheropts
    }
    
    method configure {args} {
        set keyvarD {
            -baseurl baseurl
            -bearer bearertoken
            -keepalive keepalive
        }
        if {[llength $args] == 0} then {
            set res {}
            dict for {key var} $keyvarD {
                dict set res $key [set var]
            }
            return $res
        } elseif {[llength $args] == 1} then {
            if {[dict exists $keyvarD [lindex $args 0]]} then {
                return [set [dict get $keyvarD [lindex $args 0]]]
            } else {
                return -code error "Bad option \"[lindex $args 0]\":\
                  should be one of [join [dict keys $keyvarD] {, }]"
            }
        } elseif {[llength $args] % 2 == 1} then {
            return -code error "Wrong # args: should be\
              -key value ?-key value ...?"
        }
        foreach {key val} $args {
            if {[dict exists $keyvarD $key]} then {
                set [dict get $keyvarD $key] $val
            } else {
                return -code error "Bad option \"[lindex $args 0]\":\
                  should be one of [join [dict keys $keyvarD] {, }]"
            }
        }
    }
}


package provide oa2rest 1.0


