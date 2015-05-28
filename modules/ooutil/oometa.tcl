package require oo::util

namespace eval ::oo::meta {
  variable dirty_classes {}
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
  set thisresult {}
  set result {}
  set queue $class
  while {[llength $queue]} {
    set tqueue $queue
    set queue {}
    foreach qclass $tqueue {
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

proc ::oo::meta::info {method class args} {
  set info [properties $class]
  switch $method {
    is {
      return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
    }
    dump {
      return $info
    }
    default {
      return [dict $method $info {*}$args] 
    }
  }
}

proc ::oo::meta::properties class {
  ###
  # Destroy the cache of all derivitive classes
  ###
  variable dirty_classes
  foreach dclass $dirty_classes {
    foreach {cclass cancestors} [array get ::oo::meta::cached_hierarchy] {
      if {$dclass in $cancestors} {
        unset -nocomplain ::oo::meta::cached_property($cclass)
        unset -nocomplain ::oo::meta::cached_hierarchy($cclass)
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
  foreach aclass $cached_hierarchy($class) {
    if {[::info exists local_property($aclass)]} {
      lappend stack $local_property($aclass)
    }
  }
  if {[llength $stack]} {
    set properties [dict merge {*}$stack]
  } else {
    set properties {}
  }
  set cached_property($class) $properties
  return $properties
}

###
# Add properties and option handling
###
proc ::oo::define::property {args} {
  set class [lindex [::info level -1] 1]
  dict set ::oo::meta::local_property($class) {*}$args
  lappend ::oo::meta::dirty_classes $class
}

oo::define oo::class {

  method meta {submethod args} {
    set class [self]
    return [::oo::meta::info $submethod $class {*}$args]
  }
  
}

oo::define oo::object {
    
  method meta {submethod args} {
    my variable config
    if {![::info exists config]} {
      set config {}
    }
    set class [::info object class [self object]]
    set info [dict merge [::oo::meta::properties $class] $config]
    switch $submethod {
      is {
        return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
      }
      dump {
        return $info
      }
      default {
        return [dict $submethod $info {*}$args] 
      }
    }
  }
}

package provide oo::meta 0.1