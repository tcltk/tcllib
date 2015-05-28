package require oo::util

namespace eval ::oo::meta {} {}

if {[info command ::tcl::dict::getnull] eq {}} {
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
      foreach aclass [info class superclasses $qclass] {
        if { $aclass in $result } continue
        if { $aclass in $queue } continue
        lappend queue $aclass
      }
      foreach aclass [info class mixins $qclass] {
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

proc ::oo::meta::decendents class {
  set thisresult {}
  set result {}
  set queue $class
  while {[llength $queue]} {
    set tqueue $queue
    set queue {}
    foreach qclass $tqueue {
      foreach aclass [info class subclasses $qclass] {
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

proc ::oo::meta::property {method class args} {
  set info [properties $class]
  switch $method {
    ancestors {
      return [::oo::meta::ancestors $class]
    }
    true -
    is_true {
      return [string is true -strict [dict getnull $info {*}$args]]
    }
    false - 
    is_false {
      return [string is false -strict [dict getnull $info {*}$args]]
    }
    null -
    is_null {
      if {[dict getnull $info {*}$args] eq {}} {
        return 1
      }
      return 0
    }
    dump {
      return $info
    }
    set {
      variable local_property
      dict set local_property($class) {*}$args
      foreach dclass [::oo::meta::decendents $class] {
        unset -nocomplain ::oo::meta::cached_property($dclass)
      }
    }
    get {
      if {[dict exists $info {*}$args]} {
        return [dict get $info {*}$args]
      }
    }
    default {
      return [dict $method $info {*}$args] 
    }
  }
}

proc ::oo::meta::properties class {
  variable cached_property
  if {[info exists cached_property($class)]} {
    return $cached_property($class)
  }
  set properties {}
  set stack {}
  variable local_property
  foreach aclass [::oo::meta::ancestors $class] {
    if {[info exists local_property($aclass)]} {
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
  set class [lindex [info level -1] 1]
  dict set ::oo::meta::local_property($class) {*}$args
  ###
  # Destroy the cache of all derivitive classes
  ###
  #foreach dclass [::oo::meta::decendents $class] {
  #  unset -nocomplain ::oo::meta::cached_property($dclass)
  #}
}

oo::define oo::class {

  method property {submethod args} {
    set class [self]
    return [::oo::meta::property $submethod $class {*}$args]
  }
}

oo::define oo::object {
    
  method property {submethod args} {
    set class [info object class [self object]]
    return [::oo::meta::property $submethod $class {*}$args]
  }
  

  ###
  # topic: 3c4893b65a1c79b2549b9ee88f23c9e3
  # description:
  #    Provide a default value for all options and
  #    publically declared variables, and locks the
  #    pipeline mutex to prevent signal processing
  #    while the contructor is still running.
  #    Note, by default an odie object will ignore
  #    signals until a later call to <i>my lock remove pipeline</i>
  ###
  method InitializePublic {} {
    my variable config
    if {![info exists config]} {
      set config {}
    }
    set dat [my property get option]
    foreach {var info} $dat {
      if {[dict exists $info set-command]} {
        if {[catch {my cget $var} value]} {
          dict set config $var [my cget $var default]
        } else {
          if { $value eq {} } {
            dict set config $var [my cget $var default]
          }
        }
      }
      if {![dict exists $config $var]} {
        dict set config $var [my cget $var default]
      }
    }
    foreach {var info} [my property get variable] {
      if { $var eq "config" } continue
      my variable $var
      if {![info exists $var]} {
        if {[dict exists $info default]} {
          set $var [dict get $info default]
        } else {
          set $var {}
        }
      }
    }
    foreach {var info} [my property get array] {
      if { $var eq "config" } continue
      my variable $var
      if {![info exists $var]} {
        if {[dict exists $info default]} {
          array set $var [dict get $info default]
        } else {
          array set $var {}
        }
      }
    }
  }

  ###
  # topic: 86a1b968cea8d439df87585afdbdaadb
  ###
  method cget {field {default {}}} {
    my variable config
    set field [string trimleft $field -]
    set dat [my property get option]
  
    if {[my property true options_strict] && ![dict exists $dat $field]} {
      error "Invalid option -$field. Valid: [dict keys $dat]"
    }
    set info [dict getnull $dat $field]    
    if {$default eq "default"} {
      set getcmd [dict getnull $info default-command]
      if {$getcmd ne {}} {
        return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
      } else {
        return [dict getnull $info default]
      }
    }
    if {[dict exists $dat $field]} {
      set getcmd [dict getnull $info get-command]
      if {$getcmd ne {}} {
        return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
      }
      if {![dict exists $config $field]} {
        set getcmd [dict getnull $info default-command]
        if {$getcmd ne {}} {
          dict set config $field [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
        } else {
          dict set config $field [dict getnull $info default]
        }
      }
      if {$default eq "varname"} {
        set varname [my varname visconfig]
        set ${varname}($field) [dict get $config $field]
        return "${varname}($field)"
      }
      return [dict get $config $field]
    }
    if {[dict exists $config $field]} {
      return [dict get $config $field]
    }
    return [my property get $field]
  }
  
  ###
  # topic: 73e2566466b836cc4535f1a437c391b0
  ###
  method configure args {
    # Will be removed at the end of "configurelist_triggers"
    set dictargs [::oo::meta::args_to_options {*}$args]
    if {[llength $dictargs] == 1} {
      return [my cget [lindex $dictargs 0]]
    }
    my configurelist $dictargs
    my configurelist_triggers $dictargs
  }

  ###
  # topic: dc9fba12ec23a3ad000c66aea17135a5
  ###
  method configurelist dictargs {
    my variable config
    set dat [my property get option]
    if {[my property true options_strict]} {
      foreach {field val} $dictargs {
        if {![dict exists $dat $field]} {
          error "Invalid option $field. Valid: [dict keys $dat]"
        }
      }
    }
    ###
    # Validate all inputs
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field validate-command]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      dict set config $field $val
    }
  }

  ###
  # topic: 543c936485189593f0b9ed79b5d5f2c0
  ###
  method configurelist_triggers dictargs {
    set dat [my property get option]
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field set-command]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
  }
}

package provide oo::property 0.1