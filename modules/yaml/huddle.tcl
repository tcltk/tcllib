# huddle.tcl (working title)
#
# huddle.tcl 0.1.5 2011-08-23 14:46:47 KATO Kanryu(kanryu6@users.sourceforge.net)
#            0.1.6 2015-04-23          aplicacionamedida@gmail.com
#                                      Ticket [a753cade83]
#
#   It is published with the terms of tcllib's BSD-style license.
#   See the file named license.terms.
#
# This library provides functions to differentiate string/list/dict in multi-ranks.
#

if { [package vcompare [package provide Tcl] 8.5] < 0 } {
    package require dict
}

package provide huddle 0.1.6

namespace eval ::huddle {
    namespace export huddle
    # common subcommands:
    #   get gets strip jsondump set remove
    # type specified subcommands:
    #   create list llength keys

    variable methods
    variable types
}

if {$::tcl_version < 8.5} {
    proc huddle {command args} {
        variable huddle::methods
        if {[info exists huddle::methods($command)]} {
            return [eval $huddle::methods($command) $command $args]
        }
        return [eval ::huddle::$command $args]
    }
    # some subcommands conflict reserved words. so, add prefix "_" (e.g. from "set" to "_set")
    proc ::huddle::proc_add_ub {command args} {
        return [eval ::huddle::_$command $args]
    }
} else {
    proc huddle {command args} {
        variable huddle::methods
        if {[info exists huddle::methods($command)]} {
			return [$huddle::methods($command) $command {*}$args]
        }

	return [::huddle::$command {*}$args]
    }

    proc ::huddle::proc_add_ub {command args} {
	return [::huddle::_$command {*}$args]
    }
}

proc ::huddle::addType {procedure} {
    variable methods
    variable types

    set settings [$procedure settings]
    dict with settings {
        foreach {m} $method {
            set methods($m) $procedure
        }

        set types(type:$tag) $type
        set types(callback:$tag) $procedure
        set types(constructor:$tag) $constructor
        set types(isContainer:$tag) $isContainer
    }
}

proc ::huddle::isHuddle {arg} {
    if {[lindex $arg 0] ne "HUDDLE" || [llength $arg] != 2} {
        return 0
    }
    variable types
    set sub [lindex $arg 1]
    if {[llength $sub] != 2 && [array get types "type:[lindex $sub 1]"] == ""} {
        return 0
    }
    return 1
}

proc ::huddle::strip {node} {
    variable types
    foreach {head value} $node break
    if {[info exists types(type:$head)]} {
	if $types(isContainer:$head) {
	    return [$types(callback:$head) strip_subtags $value]
	} else {
	    return $value
	}
    } elseif {$head eq "HUDDLE"} {
        return [strip $value]
    } else {
	error "\{$src\} is not a huddle."
    }
}

proc ::huddle::call {tag cmd arg} {
    variable types
    return [eval $types(callback:$tag) $cmd $arg]
}

proc ::huddle::combine {args} {
    variable types

    foreach {obj} $args {
        checkHuddle $obj
    }
    set tag ""
    foreach {obj} $args {
        foreach {nop node} $obj break
        foreach {t src} $node break
        if {$tag eq ""} {
            set tag $t
        } else {
            if {$tag ne $t} {error "unmatched huddles are given."}
        }
        eval lappend result $src
    }
    set src [$types(callback:$tag) append "" {} $result]
    return [wrap $tag $src]

}

proc ::huddle::checkHuddle {huddle_object} {
    if {![isHuddle $huddle_object]} {
        error "\{$huddle_object\} is not a huddle."
    }
}

proc ::huddle::to_node {src {tag s}} {
    if {[isHuddle $src]} {
        return [unwrap $src]
    } else {
        return [list $tag $src]
    }
}

proc ::huddle::wrap {head src} {
    if {$head ne ""} {
        return [list HUDDLE [list $head $src]]
    } else {
        return [list HUDDLE $src]
    }
}


proc ::huddle::unwrap { huddle_object } {
    return [lindex $huddle_object 1]
}

proc ::huddle::_get {huddle_object args} {
    retrieve_huddle $huddle_object $args 0
}

proc ::huddle::_gets {huddle_object args} {
    retrieve_huddle $huddle_object $args 1
}

proc ::huddle::retrieve_huddle {huddle_object path striped} {
    checkHuddle $huddle_object

    set current_node [unwrap $huddle_object]

    set target_node [_find_node $current_node $path]
    if $striped {
	return [strip $target_node]
    } else {
	return [wrap "" $target_node]
    }
}

proc ::huddle::type {huddle_object args} {
    checkHuddle $huddle_object
    variable types

    set target_node [_find_node [unwrap $huddle_object] $args]

    foreach {tag src} $target_node break

    return $types(type:$tag)
}

proc ::huddle::_find_node {node path} {
    set len [llength $path]

    if {$len == 0} {
	return $node
    } else {
	variable types

	foreach {tag src} $node break

	if {$len == 1} {
	    if {![info exists types(type:$tag)]} {error "\{$src\} is not a huddle node."}

	    return [$types(callback:$tag) get_subnode $src $path]
	} else {
	    # length > 1
	    set key [lindex $path 0]
	    set subpath [lrange $path 1 end]
	    if {![info exists types(type:$tag)]} {error "\{$src\} don't have any child node."}
	    set subnode [$types(callback:$tag) get_subnode $src $key]
	    return [_find_node $subnode $subpath]
	}
    }
}

proc ::huddle::equal {obj1 obj2} {
    checkHuddle $obj1
    checkHuddle $obj2
    return [_equal_subnodes [lindex $obj1 1] [lindex $obj2 1]]
}

proc ::huddle::_equal_subnodes {obj1 obj2} {
    variable types

    foreach {tag1 src1} $obj1 break
    foreach {tag2 src2} $obj2 break
    if {$tag1 ne $tag2} {return 0}
    return [$types(callback:$tag1) equal $src1 $src2]
}

proc ::huddle::_append {objvar args} {
    variable types

    upvar 3 $objvar obj
    checkHuddle $obj
    foreach {tag src} [unwrap $obj] break
    set src [$types(callback:$tag) append $tag $src $args]
    set obj [wrap $tag $src]
    return $obj
}

proc ::huddle::_set {objvar args} {
    upvar 3 $objvar obj
    checkHuddle $obj
    set path [lrange $args 0 end-1]
    set value [lindex $args end]
    set value [to_node $value]

    set node [_change_subnode set [unwrap $obj] [llength $path] $path $value]
    set obj [wrap "" $node]
}

proc ::huddle::remove {src args} {
    checkHuddle $src
    foreach {nop src} $src break
    set src [_change_subnode remove $src [llength $args] $args ""]
    set obj [wrap "" $src]
}

proc ::huddle::_change_subnode {command node len path value} {
    variable types
    foreach {tag src} $node break
    if {$len > 1} {
        set key [lindex $path 0]
        set subpath [lrange $path 1 end]
        incr len -1
        if {![info exists types(type:$tag)]} {error "\{$src\} don't have any child node."}
        set subnode [$types(callback:$tag) get_subnode $src $key]
        set modified_subnode [_change_subnode $command $subnode $len $subpath $value]
        set src [$types(callback:$tag) set $src $key $modified_subnode]
        return [list $tag $src]
    }
    if {![info exists types(type:$tag)]} {error "\{$src\} is not a huddle node."}
    set src [$types(callback:$tag) $command $src $path $value]
    return [list $tag $src]
}

proc ::huddle::_dict_type {command args} {
# __TRANSCRIBE_BEGIN__
    switch -- $command {
        settings { ; # type definition
            return {
                type dict
                method {create keys}
                tag D
                isContainer yes
                constructor create
            }
            # type:   the type-name
            # method: add methods to huddle's subcommand.
            #          "get_subnode/strip/set/remove/equal/append" called by huddle module.
            #          "strip" must be defined at all types.
            #          "get_subnode" must be defined at isContainer types.
            #          "set/remove/equal/append" shuould be defined, if you call them.
            # tag:    tag definition("child/parent" word is maybe obsoleted)
        }
        get_subnode { ; # get a sub-node specified by "key" from the tagged-content
            foreach {src key} $args break
            return [dict get $src $key]
        }
        strip_subtags { ; # strip from the tagged-content
            set src [lindex $args 0]

            foreach {key val} $src {
                lappend result $key [huddle strip $val]
            }
            return $result
        }
        set { ; # set a sub-node from the tagged-content
            foreach {src key value} $args break
            dict set src $key $value
            return $src
        }
        remove { ; # remove a sub-node from the tagged-content
            foreach {src key value} $args break
            return [dict remove $src $key]
        }
        equal { ; # check equal for each node
            foreach {src1 src2} $args break
            if {[llength $src1] != [llength $src2]} {return 0}
            foreach {key1 val1} $src1 {
                if {![dict exists $src2 $key1]} {return 0}
                if {![huddle _equal_subnodes $val1 [dict get $src2 $key1]]} {return 0}
            }
            return 1
        }
        append { ; # append nodes
            foreach {str src list} $args break
            if {[llength $list] % 2} {error {wrong # args: should be "huddle append objvar ?key value ...?"}}
            set resultL $src
            foreach {key value} $list {
                if {$str ne ""} {
                    lappend resultL $key [huddle to_node $value $str]
                } else {
                    lappend resultL $key $value
                }
            }
            return [eval dict create $resultL]
        }
        create { ; # $args: all arguments after "huddle create"
            if {[llength $args] % 2} {error {wrong # args: should be "huddle create ?key value ...?"}}
            set resultL {}
            foreach {key value} $args {
                dict set resultL $key [huddle to_node $value]
            }
            return [huddle wrap D $resultL]
        }
        keys {
            foreach {src nop} $args break
            return [dict keys [lindex [lindex $src 1] 1]]
        }
        default {
            error "$command is not callback for dict"
        }
    }
# __TRANSCRIBE_END__
}

proc ::huddle::_list_type {command args} {
    switch -- $command {
        settings {
            return {
                type list
                method {list llength}
                tag L
                isContainer yes
                constructor list
            }
        }
        get_subnode {
            foreach {src index} $args break
            return [lindex $src $index]
        }
        strip_subtags {
            set src [lindex $args 0]
            set result {}
            foreach {val} $src {
                lappend result [strip $val]
            }
            return $result
        }
        set {
            foreach {src index value} $args break
            lset src $index $value
            return $src
        }
        remove {
            foreach {src index value} $args break
            return [lreplace $src $index $index]
        }
        equal {
            foreach {src1 src2} $args break
            if {[llength $src1] != [llength $src2]} {return 0}
            set i 0
            foreach {val1} $src1 {
                if {![huddle _equal_subnodes $val1 [lindex $src2 $i]]} {return 0}
                incr i
            }
            return 1
        }
        append { ; # append nodes
            foreach {str src list} $args break
            set resultL $src
            foreach {value} $list {
                if {$str ne ""} {
                    lappend resultL [huddle to_node $value $str]
                } else {
                    lappend resultL $value
                }
            }
            return $resultL
        }
        list {
            set resultL {}
            foreach {value} $args {
                lappend resultL [huddle to_node $value]
            }
            return [huddle wrap L $resultL]
        }
        llength {
            foreach {src nop} $args break
            return [llength [lindex [lindex $src 1] 1]]
        }
        default {
            error "$command is not callback for list"
        }
    }
}

proc ::huddle::_string_type {command args} {
    switch -- $command {
        settings {
            return {
                type string
                method {string}
                tag s
                isContainer no
                constructor string
            }
        }
        string {
            return [huddle wrap s $args]
        }
        equal {
            foreach {src1 src2} $args break
            return [expr {$src1 eq $src2}]
        }
        default {
            error "$command is not callback for string"
        }
    }
}

proc ::huddle::jsondump {data {offset "  "} {newline "\n"} {begin ""}} {
    variable types
    set nextoff "$begin$offset"
    set nlof "$newline$nextoff"
    set sp " "
    if {[string equal $offset ""]} {set sp ""}

    set type [huddle type $data]

    switch -- $type {
        "string" {
            set data [huddle strip $data]
            if {[string is double -strict $data]} {return $data}
            if {[regexp {^true$|^false$|^null$} $data]} {return $data}
            # JSON permits only oneline string
            set data [string map {
                    \n \\n
                    \t \\t
                    \r \\r
                    \b \\b
                    \f \\f
                    \\ \\\\
                    \" \\\"
                    / \\/
                } $data
            ]
            return "\"$data\""
        }
        "list" {
            set inner {}
            set len [huddle llength $data]
            for {set i 0} {$i < $len} {incr i} {
                set sub [huddle get $data $i]
                lappend inner [jsondump $sub $offset $newline $nextoff]
            }
            if {[llength $inner] == 1} {
                return "\[[lindex $inner 0]\]"
            }
            return "\[$nlof[join $inner ,$nlof]$newline$begin\]"
        }
        "dict" {
            set inner {}
            foreach {key} [huddle keys $data] {
                lappend inner [subst {"$key":$sp[jsondump [huddle get $data $key] $offset $newline $nextoff]}]
            }
            if {[llength $inner] == 1} {
                return $inner
            }
            return "\{$nlof[join $inner ,$nlof]$newline$begin\}"
        }
        default {
            return [$types(callback:$type) jsondump $data $offset $newline $nextoff]
        }
    }
}

# data is plain old tcl values
# spec is defined as follows:
# {string} - data is simply a string, "quote" it if it's not a number
# {list} - data is a tcl list of strings, convert to JSON arrays
# {list list} - data is a tcl list of lists
# {list dict} - data is a tcl list of dicts
# {dict} - data is a tcl dict of strings
# {dict xx list} - data is a tcl dict where the value of key xx is a tcl list
# {dict * list} - data is a tcl dict of lists
# etc..
proc ::huddle::compile {spec data} {
    while [llength $spec] {
        set type [lindex $spec 0]
        set spec [lrange $spec 1 end]

        switch -- $type {
            dict {
                lappend spec * string

                set result [huddle create]
                foreach {key val} $data {
                    foreach {keymatch valtype} $spec {
                        if {[string match $keymatch $key]} {
                            huddle append result $key [compile $valtype $val]
                            break
                        }
                    }
                }
                return $result
            }
            list {
                if {![llength $spec]} {
                    set spec string
                } else {
                    set spec [lindex $spec 0]
                }
                set result [huddle list]
                foreach {val} $data {
                    huddle append result [compile $spec $val]
                }
                return $result
            }
            string {
#                 if {[string is double -strict $data]} {
#                     return $data
#                 } else {
                    return [huddle wrap s $data]
#                 }
            }
            default {error "Invalid type"}
        }
    }
}

namespace eval ::huddle {
    array set methods {}
    array set types {}
    array set callbacks {}

    ::huddle::addType ::huddle::_dict_type
    ::huddle::addType ::huddle::_list_type
    ::huddle::addType ::huddle::_string_type

    set methods(set)    ::huddle::proc_add_ub
    set methods(append) ::huddle::proc_add_ub
    set methods(get)    ::huddle::proc_add_ub
    set methods(gets)   ::huddle::proc_add_ub
}

return
