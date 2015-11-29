namespace eval ::huddle::types {
    namespace export *
    
    namespace eval dict {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {create keys} 
                        tag D 
                        isContainer yes}


        proc Get_subnode {src key} { 
            # get a sub-node specified by "key" from the tagged-content
            return [dict get $src $key]
        }
        
        # strip from the tagged-content
        proc Strip {src} {
            foreach {key subnode} $src {
                lappend result $key [strip_node $subnode]
            }
            return $result
        }
        
        # set a sub-node from the tagged-content
        proc Set {src_var key value} {
            upvar 1 $src_var src

            dict set src $key $value
        }
        
        proc items {src} {
            set result {}
            dict for {key subnode} $src {
                lappend result [list $key $subnode]
            }
            return $result
        }
        
        
        # remove a sub-node from the tagged-content
        proc Remove {src_var key} {
            upvar 1 $src_var src
            dict unset src $key
        }
        
        # check equal for each node
        proc Equal {src1 src2} {
            if {[llength $src1] != [llength $src2]} {return 0}
            foreach {key1 subnode1} $src1 {
                if {![dict exists $src2 $key1]} {return 0}
                if {![are_equal_nodes $subnode1 [dict get $src2 $key1]]} {return 0}
            }
            return 1
        }
        
        proc Combine {list_of_src} {
            set combined_src [dict merge {*}$list_of_src]
            return $combined_src
        }

        proc Update_children {src_var items} {
            upvar 1 $src_var src

            foreach {key value} $items {
                dict set src $key [argument_to_node $value]
            }
        }

        # $args: all arguments after "huddle create"
        proc create {args} {
            if {[llength $args] % 2} {error {wrong # args: should be "huddle create ?key value ...?"}}
            set resultD [dict create]
            
            foreach {key value} $args {
                if {[is_huddle $key]} {
                    lassign [unwrap $key] tag src

                    if {$tag ne "string"} {
                        return -code error "The key '$key' must a string literal or huddle string" 
                    }
                    set key $src    
                }
                dict set resultD $key [argument_to_node $value]
            }
            return [wrap [list D $resultD]]
        }
        
        proc keys {huddle_object} {
            return [dict keys [get_src $huddle_object]]
        }
        
        proc Exists {src key} {
            return [dict exists $src $key]
        }
    }
    
    
    namespace eval list {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {list llength lappend} 
                        tag L 
                        isContainer yes 
                        map {list List llength Llength lappend Lappend} }
        
        proc Get_subnode {src index} {
            return [lindex $src $index]
        }
        
        proc items {src} {
            set result {}
            for {set i 0} {$i < [llength $src]} {incr i} {
                lappend result [list $i [lindex $src $i]]
            }
            return $result
        }
        
        proc Strip {src} {
            set result {}
            foreach {subnode} $src {
                lappend result [strip_node $subnode]
            }
            return $result
        }
        
        if {[package vcompare [package present Tcl] 8.6] > 0} {
            proc Set {src_var index value} {
                upvar 1 $src_var src
                lset src $index $value
            }
        } else {
            proc Set {src_var index value} {
                upvar 1 $src_var src
                # Manual handling of lset at end of list.
                if {$index == [llength $src]} {
                    lappend src $value
                } else {
                    lset src $index $value
                }
            }
        }
        
        proc Remove {src_var index} {
            upvar 1 $src_var src
            set src [lreplace $src $index $index]
        }
        
        proc Equal {src1 src2} {
            if {[llength $src1] != [llength $src2]} {return 0}
            
            for {set i 0} {$i < [llength $src1]} {incr i} {
                if {![are_equal_nodes [lindex $src1 $i] [lindex $src2 $i]]} {
                    return 0
                }
            }

            return 1
        }

        proc Combine {list_of_src} {
            set combined_src [list]
            foreach src $list_of_src {
                lappend combined_src {*}$src
            }
            
            return $combined_src
        }
        
        proc Update_children {src_var items} {
            upvar 1 $src_var src

            foreach {key value} $items {
                if {!([string is digit $key] && [string index $key 0] ne "0")} {
                    return -code error "The key should be a natural number: $key"
                }
                
                if { $key >= [llength $src]} {
                    return -code error "The key is out of range: $key. List type only allow update children that exists in the list."
                }
                
                lset src $key [argument_to_node $value]
            }
        }
        
        proc Lappend {huddle_var args} {
            upvar 1 $huddle_var huddle_object
            
            set src [get_src $huddle_object]
            
            delete_src huddle_object
            
            foreach argument $args {
                set subnode [argument_to_node $argument]
                lappend src $subnode
            }
            return [wrap [list L $src]]
        }
        
        proc List {args} {

            set resultL {}
            foreach {value} $args {
                lappend resultL [argument_to_node $value]
            }
            return [wrap [list L $resultL]]
        }
        
        proc Llength {huddle_object} {
            return [llength [get_src $huddle_object] ]
        }
        
        proc Exists {src key} {
            return [expr {$key >=0 && $key < [llength $src]}]
        }
    }
    
    namespace eval string {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {string}
                        tag s
                        isContainer no
                        map {string String} }
        
        proc String {src} {
            return [wrap [list s $src]]
        }
        
        proc Equal {string1 string2} {
            return [expr {$string1 eq $string2}]
        }
    }
    
    
    namespace eval number {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {number}
                        tag num
                        isContainer no }
            
        proc number {src} {
            if {[string is double -strict $src]} {
                return [wrap [list num $src]]
            } else {
                return -code error "Argument '$src' is not a number"
            }
        }
        
        proc Equal {number1 number2} {
            return [expr {$number1 == $number2}]
        }
    }
    
    namespace eval boolean {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {boolean true false}
                        tag b
                        isContainer no }
        
        proc boolean {boolean_expresion} {
            
            if {$boolean_expresion} {
                return [wrap [list b true]]
            } else {
                return [wrap [list b false]]
            }
        }
        
        proc true {} {
            return [::huddle::wrap [list b true]]
        }
        
        proc false {} {
            return [wrap [list b false]]
        }

        
        proc Equal {bool1 bool2} {
            return [expr {$bool1 eq $bool2}]
        }
    }
    
    namespace eval null {
        variable settings 
        
        # type definition
        set settings {
                        publicMethods {null}
                        tag null
                        isContainer no }
            
        proc null {} {
            return [wrap [list null]]
        }
        
        proc Equal {null1 null2} {
            return 1
        }        
    }
}
