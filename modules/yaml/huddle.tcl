# huddle.tcl
#
#   It is published with the terms of tcllib's BSD-style license.
#   See the file named license.terms.
#
# This library provide functions to differentinate string/list/dict in multi-ranks.
#
# Copyright (c) 2008-2011 KATO Kanryu <kanryu6@users.sourceforge.net>
# Copyright (c) 2015 Miguel Martínez López

package require Tcl 8.5
package provide huddle 0.1.7

namespace eval ::huddle {
    namespace export huddle wrap unwrap is_huddle strip_node are_equal_nodes argument_to_node get_src

    variable types

    namespace ensemble create -map {
        set              ::huddle::set_huddle
        append           ::huddle::append_huddle
        get              ::huddle::get
        getStripped      ::huddle::get_stripped
        removed          ::huddle::removed
        remove           ::huddle::remove
        combine          ::huddle::combine
        type             ::huddle::type
        equal            ::huddle::equal
        exists           ::huddle::exists
        clone            ::huddle::clone
        isHuddle         ::huddle::is_huddle
        wrap             ::huddle::wrap
        unwrap           ::huddle::unwrap
        addType          ::huddle::add_type
        jsondump         ::huddle::json_dump
        compile          ::huddle::compile
    }
}

proc ::huddle::add_type {typeNamespace} {
    variable types

    set typeName [namespace tail $typeNamespace]
    set typeCommand ::huddle::Type_of_$typeName

    namespace upvar $typeNamespace settings settings

    if {[dict exists $settings map]} {
        set ensemble_map_of_type [dict get $settings map]
        set renamed_subcommands [dict values $ensemble_map_of_type]
    } else {
        set renamed_subcommands [list]
    }

    dict set ensemble_map_of_type settings ${typeNamespace}::settings

    foreach path_to_subcommand [info procs ${typeNamespace}::*] {
        set subcommand [namespace tail $path_to_subcommand]

        if {$subcommand ni $renamed_subcommands} {
            dict set ensemble_map_of_type $subcommand ${typeNamespace}::$subcommand
        }
    }

    namespace eval $typeNamespace "
        namespace import ::huddle::wrap ::huddle::unwrap ::huddle::is_huddle ::huddle::strip_node ::huddle::are_equal_nodes ::huddle::argument_to_node ::huddle::get_src

        namespace ensemble create -unknown ::huddle::unknown_subcommand -command $typeCommand -prefixes false -map {$ensemble_map_of_type}

        proc settings {} {
            variable settings
            return \$settings
        }
    "

    set huddle_map [namespace ensemble configure ::huddle -map]

    dict with settings {
        foreach subcommand $publicMethods {
            dict set huddle_map $subcommand [list $typeCommand $subcommand]
        }

        if {[info exists superclass]} {
            set types(superclass:$tag) $superclass
        }

        set types(type:$tag) $typeName
        set types(callback:$tag) $typeCommand
        set types(isContainer:$tag) $isContainer
        set types(tagOfType:$typeName) $tag
    }

    namespace ensemble configure ::huddle -map $huddle_map
    return
}

proc ::huddle::is_superclass_of {tag1 tag2} {
    variable types

    if {![info exists types(list_of_superclasses:$tag1)]} {
        set types(list_of_superclasses:$tag1) [list]

        set superclass_tag $tag1

        while {true} {
            if {[info exists types(superclass:$superclass_tag)]} {
                set superclass $types(superclass:$superclass_tag)
                set superclass_tag $types(tagOfType:$superclass)

                lappend types(list_of_superclasses:$tag1) $superclass_tag
            } else {
                break
            }
        }
    }

    if {$tag2 in $types(list_of_superclasses:$tag1) } {
        return 1
    } else {
        return 0
    }
}

proc ::huddle::unknown_subcommand {ensembleCmd subcommand args} {
    variable types
    
    set settings [$ensembleCmd settings]

    if {[dict exists $settings superclass]} {
        set superclass [dict get $settings superclass]

        set map [namespace ensemble configure $ensembleCmd -map]

        set superclass_tag $types(tagOfType:$superclass)
        dict set map $subcommand [list $types(callback:$superclass_tag) $subcommand]

        namespace ensemble configure $ensembleCmd -map $map
        return ""
    } else {
        error "Invalid subcommand '$subcommand' for type '$ensembleCmd'"
    }
}

proc ::huddle::is_huddle {obj} {
    if {[lindex $obj 0] ne "HUDDLE" || [llength $obj] != 2} {
        return 0
    }
    
    variable types
    set node [lindex $obj 1]
    set tag [lindex $node 0]

    if { [array get types "type:$tag"] == ""} {
        return 0
    }

    return 1
}

proc ::huddle::strip_node {node} {
    variable types
    lassign $node head src
    
    if {[info exists types(type:$head)]} {
        if {$types(isContainer:$head)} {
            return [$types(callback:$head) Strip $src]
        } else {
            return $src
        }
    } else {
        error "This head '$head' doesn't exists."
    }
}

proc ::huddle::call {tag cmd arguments} {
    variable types
    return [$types(callback:$tag) $cmd {*}$arguments]
}

proc ::huddle::combine {args} {
    variable types

    foreach {obj} $args {
        check_huddle $obj
    }

    set first_object [lindex $args 0]
    set tag_of_group [lindex [unwrap $first_object] 0]

    foreach {obj} $args {
        set node [unwrap  $obj]
    
        lassign $node tag src

        if {$tag_of_group ne $tag} {
            error "unmatched types are given in 'combine' subcommand."
        }
        
        
        lappend result {*}$src
    }

    set src [$types(callback:$tag_of_group) Append_subnodes "" {} $result]
    return [wrap [list $tag $src]]
}

proc ::huddle::check_huddle {huddle_object} {
    if {![is_huddle $huddle_object]} {
        error "\{$huddle_object\} is not a huddle."
    }
}

proc ::huddle::argument_to_node {src {default_tag s}} {
    if {[is_huddle $src]} {
        return [unwrap $src]
    } else {
        return [list $default_tag $src]
    }
}

proc ::huddle::wrap { node } {
    return [list HUDDLE $node]
}

proc ::huddle::unwrap { huddle_object } {
    return [lindex $huddle_object 1]
}

proc ::huddle::get_src { huddle_object } {
    return [lindex [unwrap $huddle_object] 1]
}

proc ::huddle::get {huddle_object args} {
    return [retrieve_huddle $huddle_object $args 0]
}

proc ::huddle::get_stripped {huddle_object args} {
    return [retrieve_huddle $huddle_object $args 1]
}

proc ::huddle::retrieve_huddle {huddle_object path striped} {
    check_huddle $huddle_object

    set target_node [Find_node [unwrap $huddle_object] $path]

    if {$striped} {
        return [strip_node $target_node]
    } else {
        return [wrap $target_node]
    }
}

proc ::huddle::type {huddle_object args} {
    variable types

    check_huddle $huddle_object

    set target_node [Find_node [unwrap $huddle_object] $args]

    lassign $target_node tag src

    return $types(type:$tag)
}

proc ::huddle::Find_node {node path} {
    variable types

    set subnode $node

    foreach subpath $path {
        lassign $subnode tag src
        set subnode [$types(callback:$tag) Get_subnode $src $subpath]
    }

    return $subnode
}

proc ::huddle::exists {huddle_object args} {
    variable types

    check_huddle $huddle_object

    set subnode [unwrap $huddle_object]

    foreach key $args {
        lassign $subnode tag src

        if {$types(isContainer:$tag) && [$types(callback:$tag) exists $src $key] } {
            set subnode [$types(callback:$tag) Get_subnode $src $key]
        } else {
            return 0
        }
    }

    return 1
}

proc ::huddle::equal {obj1 obj2} {
    check_huddle $obj1
    check_huddle $obj2
    return [are_equal_nodes [unwrap $obj1] [unwrap $obj2]]
}

proc ::huddle::are_equal_nodes {node1 node2} {
    variable types

    lassign $node1 tag1 src1
    lassign $node2 tag2 src2
    
    if {$tag1 ne $tag2} {return 0}
    return [$types(callback:$tag1) Equal $src1 $src2]
}

proc ::huddle::append_huddle {objvar args} {
    variable types

    upvar 1 $objvar obj
    check_huddle $obj
    
    lassign [unwrap $obj] tag src
    
    set src [$types(callback:$tag) Append_subnodes $tag $src $args]
    set obj [wrap [list $tag $src]]
    return $obj
}

proc ::huddle::set_huddle {objvar args} {
    upvar 1 $objvar obj

    check_huddle $obj
    set path [lrange $args 0 end-1]

    set new_subnode [argument_to_node [lindex $args end]]

    set root_node [unwrap $obj]

    # We delete the internal reference of $obj to $root_node
    # Now refcount of $root_node is 1
    unset obj

    apply_to_subnode Set root_node [llength $path] $path [list $new_subnode]
    set obj [wrap $root_node]
}

proc ::huddle::remove {objvar args} {
    upvar 1 $objvar obj
    check_huddle $obj

    set root_node [unwrap $obj]

    # We delete the internal reference of $obj to $root_node
    # Now refcount of $root_node is 1
    unset obj

    apply_to_subnode Remove root_node [llength $args] $args

    set obj [wrap $root_node]
}

proc ::huddle::apply_to_subnode {subcommand node_var len path {subcommand_arguments ""}} {
    # This proc is optimized for performance.
    # We make all the surgery for keeping a reference count of 1 for all the variables that we 
    # want to change in place.
    # It's necessary that the user that wants to apply this optimization keeps a reference count
    # of 1 for his huddle object before calling "huddle set" or "huddle remove".
    
    variable types

    upvar 1 $node_var node

    lassign $node tag src

    # We delete $src from $node.
    # In that position there is only an empty string.
    # This way, the refcount of $src is 1
    lset node 1 ""

    # We get the fist key. This information is used in the recursive case ($len>1) and in the base case ($len==1).
    set key [lindex $path 0]

    if {$len > 1} {

        set subpath [lrange $path 1 end]

        incr len -1

        if { $types(isContainer:$tag) } {

            set subnode [$types(callback:$tag) Get_subnode $src $key]

            # We delete the internal reference of $src to $subnode.
            # Now refcount of $subnode is 1
            # We don't want to delete the key, because we will use again later.
            # We only delete delete its subnode associated.
            $types(callback:$tag) Delete_subnode_but_not_key src $key

            ::huddle::apply_to_subnode $subcommand subnode $len $subpath $subcommand_arguments

            # We add again the new $subnode to the original $src
            $types(callback:$tag) Set src $key $subnode

            # We add again the new $src to the parent node
            lset node 1 $src

        } else {
            error "\{$src\} don't have any child node."
        }
    } else {
        if {![info exists types(type:$tag)]} {error "\{$src\} is not a huddle node."}

        $types(callback:$tag) $subcommand src $key {*}$subcommand_arguments
        lset node 1 $src
    }
}

proc ::huddle::removed {obj args} {
    # The procedure returns a cloned huddle object with the requested subnode removed.

    check_huddle $obj

    set modified_node [Remove_node_and_clone [unwrap $obj] [llength $args] $args]

    set obj [wrap $modified_node]
}

proc ::huddle::Remove_node_and_clone {node len path} {
    variable types

    lassign $node tag src

    set key_containing_removed_subnode [lindex $path 0]

    if {$len > 1} {
        if { $types(isContainer:$tag) } {

            set subpath_to_removed_subnode [lrange $path 1 end]

            incr len -1

            set new_src ""

            foreach item [$types(callback:$tag) items $src] {
                lassign $item key subnode

                if {$key eq $key_containing_removed_subnode} {
                    set modified_subnode [Remove_node_and_clone $subnode $len $subpath_to_removed_subnode]
                    $types(callback:$tag) Set new_src $key $modified_subnode
                } else {
                    set cloned_subnode [Clone_node $subnode]
                    $types(callback:$tag) Set new_src $key $cloned_subnode
                }
            }
        
            return [list $tag $new_src]
        } else {
            error "\{$src\} don't have any child node."
        }
    } else {
        $types(callback:$tag) Remove src $key_containing_removed_subnode
        return [list $tag $src]
    }
}

proc ::huddle::clone {obj} {
    set cloned_node [Clone_node [unwrap $obj]]

    return [wrap $cloned_node]
}

proc ::huddle::Clone_node {node} {
    variable types

    lassign $node tag src


    if { $types(isContainer:$tag) } {
        set cloned_src ""

        foreach item [$types(callback:$tag) items $src] {
            lassign $item key subnode

            set cloned_subnode [Clone_node $subnode]
            $types(callback:$tag) Set cloned_src $key $cloned_subnode
        }
        return [list $tag $cloned_src]
    } else {
        return $node
    }
}


proc ::huddle::json_dump {huddle_object {offset "  "} {newline "\n"} {begin ""}} {
    variable types
    set nextoff "$begin$offset"
    set nlof "$newline$nextoff"
    set sp " "
    if {[string equal $offset ""]} {set sp ""}

    set type [type $huddle_object]

    switch -- $type {
        boolean -
        number -
        null {
            return [get_stripped $huddle_object]
        }

        string {
            set data [get_stripped $huddle_object]

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
        
        list {
            set inner {}
            set len [huddle llength $huddle_object]
            for {set i 0} {$i < $len} {incr i} {
                set subobject [get $huddle_object $i]
                lappend inner [json_dump $subobject $offset $newline $nextoff]
            }
            if {[llength $inner] == 1} {
                return "\[[lindex $inner 0]\]"
            }
            
            return "\[$nlof[join $inner ,$nlof]$newline$begin\]"
        }
        
        dict {
            set inner {}
            foreach {key} [huddle keys $huddle_object] {
                lappend inner [subst {"$key":$sp[json_dump [huddle get $huddle_object $key] $offset $newline $nextoff]}]
            }
            if {[llength $inner] == 1} {
                return $inner
            }
            return "\{$nlof[join $inner ,$nlof]$newline$begin\}"
        }
        
        default {
            return [$types(callback:$type) json_dump $data $offset $newline $nextoff]
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
    while {[llength $spec]} {
        set type [lindex $spec 0]
        set spec [lrange $spec 1 end]

        switch -- $type {
            dict {
                if {![llength $spec]} {
                    lappend spec * string
                }

                set result [huddle create]
                foreach {key value} $data {
                    foreach {matching_key subspec} $spec {
                        if {[string match $matching_key $key]} {
                            append_huddle result $key [compile $subspec $value]
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
                foreach list_item $data {
                    append_huddle result [compile $spec $list_item]
                }
            
                return $result
            }
        
            string {
                set data [string map {\"  \\\"} $data]
                set data [string map {\n \\n} $data]
                
                return [huddle string $data]
            }
        
            number {
                return [huddle number $data]
            }
        
            bool {
                return [huddle boolean $data]
            }
        
            null {
                if {$data eq ""} {
                    return [huddle null]
                } else {
                    error "Data must be an empty string: '$data'"
                }
            }
        
            huddle {
                if {[is_huddle $data]} {
                    return $data
                } else {
                    error "Data is not a huddle object: $data"
                }
            }
        
            default {error "Invalid type: '$type'"}
        }
    }
}

apply {{selfdir} {
    source [file join $selfdir huddle_types.tcl]

    foreach typeNamespace [namespace children ::huddle::types] {
        add_type $typeNamespace
    }

    return
} ::huddle} [file dirname [file normalize [info script]]]

return
