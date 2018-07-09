###
# Global utilities
###
if {[info commands ::ladd] eq {}} {
  proc ladd {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        set var {}
    }
    foreach item $args {
      if {$item in $var} continue
      lappend var $item
    }
    return $var
  }
}

if {[info command ::ldelete] eq {}} {
  proc ::ldelete {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        return
    }
    foreach item [lsort -unique $args] {
      while {[set i [lsearch $var $item]]>=0} {
        set var [lreplace $var $i $i]
      }
    }
    return $var
  }
}

if {[info command ::lrandom] eq {}} {
  proc ::lrandom list {
    set len [llength $list]
    set idx [expr int(rand()*$len)]
    return [lindex $list $idx]
  }
}

if {[::info commands ::tcl::dict::getnull] eq {}} {
  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
}

proc ::putb {buffername args} {
  upvar 1 $buffername buffer
  switch [llength $args] {
    1 {
      append buffer [lindex $args 0] \n
    }
    2 {
      append buffer [string map {*}$args] \n
    }
    default {
      error "usage: putb buffername ?map? string"
    }
  }
}
namespace eval ::clay {}

proc ::clay::ancestors args {
  set result {}
  set queue {}
  foreach class [lreverse $args] {
    lappend queue $class
  }

  # Rig things such that that the top superclasses
  # are evaluated first
  while {[llength $queue]} {
    set tqueue $queue
    set queue {}
    foreach qclass $tqueue {
      foreach aclass [::info class superclasses $qclass] {
        if { $aclass in $result } continue
        if { $aclass in $queue } continue
        lappend queue $aclass
      }
    }
    foreach item $tqueue {
      if { $item ni $result } {
        lappend result $item
      }
    }
  }
  return $result
}

proc ::clay::args_to_dict args {
  if {[llength $args]==1} {
    return [lindex $args 0]
  }
  return $args
}

proc ::clay::args_to_options args {
  set result {}
  foreach {var val} [args_to_dict {*}$args] {
    lappend result [string trimright [string trimleft $var -] :] $val
  }
  return $result
}

proc ::clay::dictmerge {varname args} {
  upvar 1 $varname result
  if {![info exists result]} {
    set result {}
  }
  switch [llength $args] {
    0 {
      return
    }
    1 {
      set result [_dictmerge $result [lindex $args 0]]
      return $result
    }
    2 {
      lassign $args path value
    }
    default {
      # Merge b into a, and handle nested dicts appropriately
      set value [lindex $args end]
      set path  [lrange $args 0 end-1]
    }
  }
  if {![dict exists $result {*}$path]} {
    dict set result {*}$path $value
    return $result
  }
  if {[string index [lindex $path end] end] ne "/"} {
    dict set result {*}$path $value
    return $result
  }
  ::dict for { k v } $value {
    # Element names that end in "/" are assumed to be branches
    if {[string index $k end] eq "/" && [::dict exists $result {*}$path $k]} {
      # key exists in a and b?  let's see if both values are dicts
      # both are dicts, so merge the dicts
      set dvalue [::dict get $result {*}$path $k]
      if { [is_dict $dvalue] && [is_dict $v] } {
        ::dict set result {*}$path $k [_dictmerge $dvalue $v]
      } else {
        ::dict set result {*}$path $k $v
      }
    } else {
      ::dict set result {*}$path $k $v
    }
  }
  return $result
}

proc ::clay::_dictmerge {a b} {
  ::set result $a
  # Merge b into a, and handle nested dicts appropriately
  ::dict for { k v } $b {
    if {[string index $k end] ne "/"} {
      # Element names that do not end in "/" are assumed to be literals
      # or dict trees we intend to replace wholly
      ::dict set result $k $v
    } elseif { [::dict exists $result $k] } {
      # key exists in a and b?  let's see if both values are dicts
      # both are dicts, so merge the dicts
      if { [is_dict [::dict get $result $k]] && [is_dict $v] } {
        ::dict set result $k [_dictmerge [::dict get $result $k] $v]
      } else {
        ::dict set result $k $v
      }
    } else {
      ::dict set result $k $v
    }
  }
  return $result
}

proc ::clay::dictputb {dict} {
  set result {}
  set level -1
  _dictputb 0 $level result $dict
  return $result
}

proc ::clay::_dictputb {leaf level varname dict} {
  upvar 1 $varname result
  incr level
  foreach {field value} $dict {
    if {[string index $field end] eq "/"} {
      putb result "[string repeat "  " $level]$field \{"
      _dictputb 0 $level result $value
      putb result "[string repeat "  " $level]\}"
    } else {
      putb result "[string repeat "  " $level][list $field $value]"
    }
  }
}

###
# topic: 4969d897a83d91a230a17f166dbcaede
###
proc ::clay::dynamic_arguments {ensemble method arglist args} {
  set idx 0
  set len [llength $args]
  if {$len > [llength $arglist]} {
    ###
    # Catch if the user supplies too many arguments
    ###
    set dargs 0
    if {[lindex $arglist end] ni {args dictargs}} {
      return -code error -level 2 "Usage: $ensemble $method [string trim [dynamic_wrongargs_message $arglist]]"
    }
  }
  foreach argdef $arglist {
    if {$argdef eq "args"} {
      ###
      # Perform args processing in the style of tcl
      ###
      uplevel 1 [list set args [lrange $args $idx end]]
      break
    }
    if {$argdef eq "dictargs"} {
      ###
      # Perform args processing in the style of tcl
      ###
      uplevel 1 [list set args [lrange $args $idx end]]
      ###
      # Perform args processing in the style of clay
      ###
      set dictargs [::clay::args_to_options {*}[lrange $args $idx end]]
      uplevel 1 [list set dictargs $dictargs]
      break
    }
    if {$idx > $len} {
      ###
      # Catch if the user supplies too few arguments
      ###
      if {[llength $argdef]==1} {
        return -code error -level 2 "Usage: $ensemble $method [string trim [dynamic_wrongargs_message $arglist]]"
      } else {
        uplevel 1 [list set [lindex $argdef 0] [lindex $argdef 1]]
      }
    } else {
      uplevel 1 [list set [lindex $argdef 0] [lindex $args $idx]]
    }
    incr idx
  }
}

###
# topic: 53ab28ac5c6ee601fe1fe07b073be88e
###
proc ::clay::dynamic_wrongargs_message {arglist} {
  set result ""
  set dargs 0
  foreach argdef $arglist {
    if {$argdef in {args dictargs}} {
      set dargs 1
      break
    }
    if {[llength $argdef]==1} {
      append result " $argdef"
    } else {
      append result " ?[lindex $argdef 0]?"
    }
  }
  if { $dargs } {
    append result " ?option value?..."
  }
  return $result
}

proc ::clay::is_dict { d } {
  # is it a dict, or can it be treated like one?
  if {[catch {::dict size $d} err]} {
    #::set ::errorInfo {}
    return 0
  }
  return 1
}

proc ::clay::is_null value {
  return [expr {$value in {{} NULL}}]
}

proc ::clay::leaf args {
  set marker [string index [lindex $args end] end]
  set result [path {*}${args}]
  if {$marker eq "/"} {
    return $result
  }
  return [list {*}[lrange $result 0 end-1] [string trim [string trim [lindex $result end]] /]]
}

proc ::clay::path args {
  set result {}
  foreach item $args {
    set item [string trim $item :./]
    foreach subitem [split $item /] {
      lappend result [string trim ${subitem}]/
    }
  }
  return $result
}

proc ::clay::script_path {} {
  set path [file dirname [file join [pwd] [info script]]]
  return $path
}

proc ::clay::NSNormalize qualname {
  if {![string match ::* $qualname]} {
    set qualname ::clay::classes::$qualname
  }
  regsub -all {::+} $qualname "::"
}

proc ::clay::uuid_generate args {
  return [uuid::uuid generate]
}

namespace eval ::clay {
  variable core_classes {::oo::class ::oo::object}
}
