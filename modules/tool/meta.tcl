::namespace eval ::oo::define {}

::namespace eval ::tool::meta {}

###
# topic: e22c4059c10f4f02195e15545037b4eb61bc2e05
###
proc ::oo::define::meta args {
  set class [lindex [::info level -1] 1]
  ::tool::meta::info $class {*}$args
}

###
# topic: 8bcae430f1eda4ccdb96daedeeea3bd409c6bb7a
# description: Add properties and option handling
###
proc ::oo::define::property args {
  set class [lindex [::info level -1] 1]
  switch [llength $args] {
    2 {
      set type const
      set property [string trimleft [lindex $args 0] :]
      set value [lindex $args 1]
      ::tool::meta::info $class set $type $property: $value
      return
    }
    3 {
      set type     [lindex $args 0]
      set property [string trimleft [lindex $args 1] :]
      set value    [lindex $args 2]
      ::tool::meta::info $class set $type $property: $value
      return
    }
  }
  ::tool::meta::info $class set {*}$args
}

###
# topic: 265ec26c7ff4e60b1d30a9204f126592fc1a652c
###
proc ::tool::meta::ancestors class {
  set class [::tool::meta::normalize $class]
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

###
# topic: 5865edf09fbbff0783ffea538c0c9518f7a96f65
###
proc ::tool::meta::args_to_dict args {
  if {[llength $args]==1} {
    return [lindex $args 0]
  }
  return $args
}

###
# topic: bef81560a10739a474a6f70856da8c06f0ec1e72
###
proc ::tool::meta::args_to_options  args {
  set result {}
  foreach {var val} [args_to_dict {*}$args] {
    lappend result [string trimleft $var -] $val
  }
  return $result
}

###
# topic: f43c2473eae1e0a34edd272fe82cdd98292aac02
###
proc ::tool::meta::info {class submethod args} {
  set class [::tool::meta::normalize $class]
  switch $submethod {
    rebuild {
      if {$class ni $::tool::meta::dirty_classes} {
        lappend ::tool::meta::dirty_classes $class
      }
    }
    is {
      set info [properties $class]
      return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
    }
    for -
    map {
      set info [properties $class]
      return [uplevel 1 [list ::dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]]
    }
    with {
      upvar 1 TEMPVAR info
      set info [properties $class]
      return [uplevel 1 [list ::dict with TEMPVAR {*}$args]]
    }
    branchset {
      if {$class ni $::tool::meta::dirty_classes} {
        lappend ::tool::meta::dirty_classes $class
      }
      foreach {field value} [lindex $args end] {
        ::dict set ::tool::meta::local_property($class) {*}[lrange $args 0 end-1] [string trimright $field :]: $value
      }
    }
    append -
    incr -
    lappend -
    set -
    unset -
    update {
      if {$class ni $::tool::meta::dirty_classes} {
        lappend ::tool::meta::dirty_classes $class
      }
      ::dict $submethod ::tool::meta::local_property($class) {*}$args
    }
    merge {
      if {$class ni $::tool::meta::dirty_classes} {
        lappend ::tool::meta::dirty_classes $class
      }
      set ::tool::meta::local_property($class) [dict rmerge $::tool::meta::local_property($class) {*}$args]
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

###
# topic: ba5a7ad6ee4565f6200e9c0c82796f2d8700d6fa
###
proc ::tool::meta::normalize class {
  set class ::[string trimleft $class :]
}

###
# topic: cb6b3c29d7b53941128ca6ac80bab5ebd284b70d
###
proc ::tool::meta::properties {class {force 0}} {
  set class [::tool::meta::normalize $class]
  ###
  # Destroy the cache of all derivitive classes
  ###
  if {$force} {
    unset -nocomplain ::tool::meta::cached_property
    unset -nocomplain ::tool::meta::cached_hierarchy
  } else {
    variable dirty_classes
    foreach dclass $dirty_classes {
      foreach {cclass cancestors} [array get ::tool::meta::cached_hierarchy] {
        if {$dclass in $cancestors} {
          unset -nocomplain ::tool::meta::cached_property($cclass)
          unset -nocomplain ::tool::meta::cached_hierarchy($cclass)
        }
      }
      if {[dict getnull $::tool::meta::local_property($dclass) classinfo type:] eq "core"} {
        if {$dclass ni $::tool::meta::core_classes} {
          lappend ::tool::meta::core_classes $dclass
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
  set cached_hierarchy($class) [::tool::meta::ancestors $class]
  foreach aclass [lrange $cached_hierarchy($class) 0 end-1] {
    if {[::info exists local_property($aclass)]} {
      lappend properties $local_property($aclass)
    }
  }
  lappend properties {classinfo {type {}}}
  if {[::info exists local_property($class)]} {
    set properties [dict rmerge {*}$properties $local_property($class)]
  } else {
    set properties [dict rmerge {*}$properties]
  }
  set cached_property($class) $properties
  return $properties
}

###
# topic: 00e53306f4831055dcc3af93d02d18cfe8aa5a9c
###
proc ::tool::meta::search args {
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

###
# topic: 8b5ca02091803106b2623ef4d54514331ad31f3f
###
namespace eval ::tool::meta {
  variable dirty_classes {}
  variable core_classes {::oo::class ::oo::object ::tao::moac}
}

oo::define oo::class {

  method meta {submethod args} {
    return [::tool::meta::info [self] $submethod {*}$args]
  }
  
}

oo::define oo::object {
  
  ###
  # title: Initialize object
  # format: markdown
  # description:
  # Reserved method, defined by TOOL standard.
  # *initialize* is executed by the constructor
  # after local variables have been initialized,
  # options have been applied, and attributes
  # have been loaded.
  ###
  method initialize {} {}
  
  ###
  # title: Provide access to meta data
  # format: markdown
  # description:
  # The *meta* method allows an object access
  # to a combination of its own meta data as
  # well as to that of its class
  ###
  method meta {submethod args} {
    my variable config
    if {![::info exists config]} {
      set config {}
    }
    set class [::info object class [self object]]
    switch $submethod {
      cget {
        ###
        # submethod: cget
        # arguments: ?*path* ...? *field*
        # format: markdown
        # description:
        # Retrieve a value from the local objects **config** dict
        # or from the class' meta data. Values are searched in the
        # following order:
        # 1. From the local dict as **path** **field:**
        # 2. From the local dict as **path** **field**
        # 3. From class meta data as const **path** **field:**
        # 4. From class meta data as const **path** **field**
        # 5. From class meta data as **path** **field:**
        # 6. From class meta data as **path** **field**
        ###
        set path [lrange $args 0 end-1]
        set field [string trim [lindex $args end] :]
        if {[dict exists $config {*}$path $field:]} {
          return [dict get $config {*}$path $field:]
        }
        if {[dict exists $config {*}$path $field]} {
          return [dict get $config {*}$path $field]
        }
        set class_properties [::tool::meta::properties $class]
        if {[dict exists $class_properties const {*}$path $field:]} {
          return [dict get $class_properties const {*}$path $field:]
        }
        if {[dict exists $class_properties const {*}$path $field]} {
          return [dict get $class_properties const {*}$path $field]
        }
        if {[dict exists $class_properties {*}$path $field:]} {
          return [dict get $class_properties {*}$path $field:]
        }
        if {[dict exists $class_properties {*}$path $field]} {
          return [dict get $class_properties {*}$path $field]
        }
        return {}
      }
      is {
        set value [my meta cget {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict $value]
      }
      for -
      map {
        set class_properties [::tool::meta::properties $class]
        set info [dict rmerge $class_properties $config]
        return [uplevel 1 [list dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]]
      }
      with {
        set class_properties [::tool::meta::properties $class]
        upvar 1 TEMPVAR info
        set info [dict rmerge $class_properties $config]
        return [uplevel 1 [list dict with TEMPVAR {*}$args]]
      }
      dump {
        set class_properties [::tool::meta::properties $class]
        return [dict rmerge $class_properties $config]
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        return [dict $submethod config {*}$args]
      }
      branchset {
        foreach {field value} [lindex $args end] {
          dict set config {*}[lrange $args 0 end-1] [string trimright $field :]: $value
        }
      }
      rmerge -
      merge {
        set config [dict rmerge $config {*}$args]
        return $config
      }
      getnull {
        if {[dict exists $config {*}$args]} {
          return [dict get $config {*}$args]
        }
        set class_properties [::tool::meta::properties $class]
        if {[dict exists $class_properties {*}$args]} {
          return [dict get $class_properties {*}$args]
        }
        return {}
      }
      get {
        if {[dict exists $config {*}$args]} {
          return [dict get $config {*}$args]
        }
        set class_properties [::tool::meta::properties $class]
        if {[dict exists $class_properties {*}$args]} {
          return [dict get $class_properties {*}$args]
        }
        error "Key {*}$args does not exist"
      }
      default {
        set class_properties [::tool::meta::properties $class]
        set info [dict rmerge $class_properties $config]
        return [dict $submethod $info {*}$args] 
      }
    }
  }
}

