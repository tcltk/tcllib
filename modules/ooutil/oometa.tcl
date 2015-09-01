###
# Author: Sean Woods, yoda@etoyoc.com
##
# TclOO routines to implement property tracking by class and object
###

namespace eval ::oo::meta {
  variable dirty_classes {}
  variable core_classes {::oo::class ::oo::object ::tao::moac}
}

if {[::info command ::tcl::dict::getnull] eq {}} {
  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }
  
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
}

proc ::oo::meta::args_to_dict args {
  if {[llength $args]==1} {
    return [lindex $args 0]
  }
  return $args
}

proc ::oo::meta::args_to_options args {
  set result {}
  foreach {var val} [args_to_dict {*}$args] {
    lappend result [string trimleft $var -] $val
  }
  return $result
}

proc ::oo::meta::ancestors class {
  set class [::oo::meta::normalize $class]
  set thisresult {}
  set result {}
  set queue $class
  variable core_classes
  
  while {[llength $queue]} {
    set tqueue $queue
    set queue {}
    foreach qclass $tqueue {
      if {$qclass in $core_classes} continue
      foreach aclass [::info class superclasses $qclass] {
        if { $aclass in $result } continue
        if { $aclass in $queue } continue
        lappend queue $aclass
      }
      foreach aclass [::info class mixins $qclass] {
        if { $aclass in $result } continue
        if { $aclass in $queue } continue
        lappend queue $aclass
      }
    }
    foreach item $tqueue {
      if { $item ni $result } {
        set result [linsert $result 0 $item]
      }
    }
  }
  return $result
}

proc ::oo::meta::info {class submethod args} {
  set class [::oo::meta::normalize $class]
  switch $submethod {
    rebuild {
      if {$class ni $::oo::meta::dirty_classes} {
        lappend ::oo::meta::dirty_classes $class
      }
    }
    is {
      set info [properties $class]
      return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
    }
    for -
    map {
      set info [properties $class]
      puts [list [dict get $info {*}[lrange $args 1 end-1]]]
      return [uplevel 1 [list ::dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]]
    }
    with {
      upvar 1 TEMPVAR info
      set info [properties $class]
      return [uplevel 1 [list ::dict with TEMPVAR {*}$args]]
    }
    append -
    incr -
    lappend -
    set -
    unset -
    update {
      if {$class ni $::oo::meta::dirty_classes} {
        lappend ::oo::meta::dirty_classes $class
      }
      ::dict $submethod ::oo::meta::local_property($class) {*}$args
    }
    dump {
      set info [properties $class]
      return $info
    }
    default {
      set info [properties $class]
      return [::dict $submethod $info {*}$args] 
    }
  }
}

proc ::oo::meta::normalize class {
  set class ::[string trimleft $class :]
}

proc ::oo::meta::properties {class {force 0}} {
  set class [::oo::meta::normalize $class]
  ###
  # Destroy the cache of all derivitive classes
  ###
  if {$force} {
    unset -nocomplain ::oo::meta::cached_property
    unset -nocomplain ::oo::meta::cached_hierarchy
  } else {
    variable dirty_classes
    foreach dclass $dirty_classes {
      foreach {cclass cancestors} [array get ::oo::meta::cached_hierarchy] {
        if {$dclass in $cancestors} {
          unset -nocomplain ::oo::meta::cached_property($cclass)
          unset -nocomplain ::oo::meta::cached_hierarchy($cclass)
        }
      }
      if {[dict getnull $::oo::meta::local_property($dclass) classinfo type:] eq "core"} {
        if {$dclass ni $::oo::meta::core_classes} {
          lappend ::oo::meta::core_classes $dclass
        }
      }
    }
  }

  ###
  # If the cache is available, use it
  ###
  variable cached_property
  if {[::info exists cached_property($class)]} {
    return $cached_property($class)
  }
  ###
  # Build a cache of the hierarchy and the
  # aggregate properties for this class and store
  # them for future use
  ###
  variable cached_hierarchy
  set properties {}
  set stack {}
  variable local_property
  set cached_hierarchy($class) [::oo::meta::ancestors $class]
  foreach aclass [lrange $cached_hierarchy($class) 0 end-1] {
    if {[::info exists local_property($aclass)]} {
      foreach {lsec ldata} $local_property($aclass) {
        if {$lsec in {meta classinfo}} continue
        if {[string index $lsec end] eq ":"} {
          set section($lsec) $ldata
        } elseif {![::info exists section($lsec)]} {
          set section($lsec) $ldata
        } else {
          if {[catch {dict size $ldata} err]} {
            set section($lsec) $ldata
          } else {
            set section($lsec) [dict merge $section($lsec) $ldata]
          }
        }
      }
    }
  }
  if {[::info exists local_property($class)]} {
    foreach {lsec ldata} $local_property($class) {
      if {$lsec in {meta classinfo}} continue
      if {![::info exists section($lsec)]} {
        set section($lsec) $ldata
      } else {
        set section($lsec) [dict merge $section($lsec) $ldata]
      }
    }
  }
  foreach {sec data} [lsort -stride 2 [array get section]] {
    dict set properties $sec $data
  }
  set cached_property($class) $properties
  return $properties
}


proc ::oo::meta::search args {
  variable local_property

  set path [lrange $args 0 end-1]
  set value [lindex $args end]

  set result {}
  foreach {class info} [array get local_property] {
    if {[dict exists $info {*}$path:]} {
      if {[string match [dict get $info {*}$path:] $value]} {
        lappend result $class
      }
      continue
    }
    if {[dict exists $info {*}$path]} {
      if {[string match [dict get $info {*}$path] $value]} {
        lappend result $class
      }
    }
  }
  return $result
}

proc ::oo::define::meta {args} {
  set class [lindex [::info level -1] 1]
  ::oo::meta::info $class {*}$args
}

###
# Add properties and option handling
###
proc ::oo::define::property args {
  set class [lindex [::info level -1] 1]
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
  }
  ::oo::meta::info $class set {*}$args
}

proc ::oo::define::option {field argdict} {
  set class [lindex [::info level -1] 1]
  foreach {prop value} $argdict {
    ::oo::meta::info $class set option $field [string trim $prop :]: $value
  }
}

oo::define oo::class {

  method meta {submethod args} {
    set class [self]
    switch $submethod {
      is {
        set info [::oo::meta::properties $class]
        return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
      }
      for -
      map {
        set info [::oo::meta::properties $class]
        return [uplevel 1 [list dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]]
      }
      with {
        upvar 1 TEMPVAR info
        set info [::oo::meta::properties $class]
        return [uplevel 1 [list dict with TEMPVAR {*}$args]]
      }
      dump {
        return [::oo::meta::properties $class]
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        ::oo::meta::info $class rebuild
        return [dict $submethod config {*}$args]
      }
      default {
        set info [::oo::meta::properties $class]
        return [dict $submethod $info {*}$args] 
      }
    }
  }
  
}

oo::define oo::object {
    
  method meta {submethod args} {
    my variable config
    if {![::info exists config]} {
      set config {}
    }
    set class [::info object class [self object]]
    
    switch $submethod {
      cget {
        # Get a constant from the local dict, a field in the const section of meta data, or under the root
        set path [lrange $args 0 end-1]
        set field [string trim [lindex $args end] :]
        if {[dict exists $config {*}$path $field:]} {
          return [dict get $config {*}$path $field:]
        }
        if {[dict exists $config {*}$path $field]} {
          return [dict get $config {*}$path $field]
        }
        set info [dict merge [::oo::meta::properties $class] $config]
        if {[dict exists $info const {*}$path $field:]} {
          return [dict get $info const {*}$path $field:]
        }
        if {[dict exists $info const {*}$path $field]} {
          return [dict get $info const {*}$path $field]
        }
        if {[dict exists $info {*}$path $field:]} {
          return [dict get $info {*}$path $field:]
        }
        if {[dict exists $info {*}$path $field]} {
          return [dict get $info {*}$path $field]
        }
        return {}
      }
      is {
        set value [my meta cget {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict $value]
      }
      for -
      map {
        set info [dict merge [::oo::meta::properties $class] $config]
        return [uplevel 1 [list dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]]
      }
      with {
        upvar 1 TEMPVAR info
        set info [dict merge [::oo::meta::properties $class] $config]
        return [uplevel 1 [list dict with TEMPVAR {*}$args]]
      }
      dump {
        return [dict merge [::oo::meta::properties $class] $config]
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        return [dict $submethod config {*}$args]
      }
      default {
        set info [dict merge [::oo::meta::properties $class] $config]
        return [dict $submethod $info {*}$args] 
      }
    }
  }
}

package provide oo::meta 0.2