
###
# topic: 8bcae430f1eda4ccdb96daedeeea3bd409c6bb7a
# description: Add properties and option handling
###
proc ::tool::define::property args {
  set class [current_class]
  switch [llength $args] {
    2 {
      set type const
      set property [string trimleft [lindex $args 0] :]
      set value [lindex $args 1]
      ::oo::meta::info $class set $type $property: $value
      return
    }
    3 {
      set type     [lindex $args 0]
      set property [string trimleft [lindex $args 1] :]
      set value    [lindex $args 2]
      ::oo::meta::info $class set $type $property: $value
      return
    }
    default {
      error "Usage:
property name type valuedict
OR property name value"
    }
  }
  ::oo::meta::info $class set {*}$args
}

###
# topic: 83160a2aba9dfa455d82b46cdd2e4127
# title: Define the properties for this class as a key/value list
###
proc ::tool::define::properties args {
  set class [current_class]
  switch [llength $args] {
    1 {
      foreach {var val} [lindex $args 0] {
        ::oo::meta::info $class set const $var: $val
      }
    }
    2 {
      set type [lindex $args 0]
      foreach {var val} [lindex $args 1] {
        ::oo::meta::info $class set $type $var: $val
      }
    }
    default {
      error "Usage: property ?type? infodict"
    }
  }
}

###
# topic: 6b7879602c202398bd25f733c0933cf9
###
proc ::tool::dynamic_methods_property {thisclass ancestors} {
  ###
  # Apply properties
  ###  
  set info {}
  dict set info option {}
  set proplist {}
  foreach ancestor $ancestors {
    if {![info exists ::oo::meta::local_property($ancestor)]} continue
    foreach {type ancinfo} $::oo::meta::local_property($ancestor) {
      foreach {property dict} $ancinfo {
        set pname [string trim $property :]
        if {[dict exists $info $type $pname]} continue
        dict set info $type $pname $dict
        if { $type in {eval const subst variable}} {
          # For these values, we want to exclude equivilent calls
          if {[dict exists $info eval $pname]} continue
          if {[dict exists $info const $pname]} continue
          if {[dict exists $info subst $pname]} continue
          lappend proplist $pname
          set mdef [split $pname _]
          if {[llength $mdef] > 1} {
            set ptype [lindex $mdef 0]
            lappend proptypes($ptype) $pname
          }
        }
      }     
    }
  }
  
  set publicvars {}
  ###
  # Build options
  ###
  set option_classes [dict getnull $info option_class]
  # Build option handlers
  foreach {property pdict} [dict getnull $info option] {
    set contents {
      default: {}
    }
    #append body \n " [list $property "return \[my cget [list $property]\]"]"
    set optionclass [dict getnull $pdict class]
    if {[dict exists $option_classes $optionclass]} {
      foreach {f v} [dict get $option_classes $optionclass] {
        dict set contents [string trim [string trimleft $f -] :] $v
      }
    }
    if {[dict exists $info option $optionclass]} {
      foreach {f v} [dict get $info option $optionclass] {
        dict set contents [string trim [string trimleft $f -] :] $v
      }
    }
    foreach {f v} $pdict {
      dict set contents [string trimleft $f -] $v
    }
    dict set info option $property $contents
  }
  
  dict set info meta class $thisclass
  dict set info meta ancestors $ancestors
  dict set info meta signal_order [::tool::signal::order [dict getnull $info signal]]
  dict set info meta types [lsort -dictionary -unique [array names proptypes]]
  dict set info meta local [get proplist]
  ###
  # Build the body of the property method
  ###
  set commonbody "switch \$field \{"
  append commonbody \n "  [list class [list return $thisclass]]"
  append commonbody \n "  [list ancestors [list return $ancestors]]"
  
  foreach {type typedict} $info {
    set typebody "    switch \[lindex \$args 0\] \{"
    append typebody \n "    [list list [list return [lsort -unique -dictionary [dict keys $typedict]]]]"
    append typebody \n "    [list dict [list return $typedict]]"
    foreach {subprop value} $typedict {
      switch $type {
        variable {
          append typebody \n "    [list $subprop [list return $value]]"          
        }
        default {
          append typebody \n "    [list $subprop [list return $value]]"          
        }
      }
    }
    append typebody "\n    \}" \n
    append commonbody \n "  [list $type $typebody]"
  }
  # Build const property handlers
  foreach {property pdict} [dict getnull $info const] {
    append commonbody \n " [list $property [list return $pdict]]"   
  }
  set body {
my variable meta
if {[info exists meta] && [llength $args]==0} {
  if {[dict exists $meta $field]} {
    return [dict get $meta $field]
  }
}
  }
  append body $commonbody
  append classbody $commonbody

  # Build eval property handlers
  foreach {property pdict} [dict getnull $info eval] {
    if {$property in $proplist} continue
    append body \n " [list $property $pdict]"
  }

  # Build subst property handlers
  foreach {property pdict} [dict getnull $info subst] {
    if {$property in $proplist} continue
    append body \n " [list $property [list return [subst $pdict]]]"
  }
  
  # Build option handlers
  foreach {property pdict} [dict getnull $info option] {
    dict set publicvars $property $pdict
    append body \n " [list $property "return \[my cget [list $property]\]"]"
  }  
  
  # Build public variable handlers
  foreach {property pdict} [dict getnull $info variable] {
    dict set publicvars $property $pdict
    append body \n " [list $property "my variable $property \; return \$property\]"]"
  }

  # End of switch
  append body \n "\}"
  append classbody \n "\}"

  append body \n {return {}}
  
  oo::define $thisclass method property {field args} $body
  oo::objdefine $thisclass method property {field args} $classbody
}
