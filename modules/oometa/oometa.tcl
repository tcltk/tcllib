###
# Author: Sean Woods, yoda@etoyoc.com
##
# TclOO routines to implement property tracking by class and object
###
package require Tcl 8.6 ;# tailcall
package require dicttool 1.2
package require clay 0.4
package require oo::dialect
package provide oo::meta 0.8

namespace eval ::oo::meta {
  set dirty_classes {}
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
  set core_result {}
  set queue $class
  set result {}
  # Rig things such that that the top superclasses
  # are evaluated first
  while {[llength $queue]} {
    set tqueue $queue
    set queue {}
    foreach qclass $tqueue {
      if {$qclass in $::oo::dialect::core_classes} {
        if {$qclass ni $core_result} {
          lappend core_result $qclass
        }
        continue
      }
      foreach aclass [::info class superclasses $qclass] {
        if { $aclass in $result } continue
        if { $aclass in $core_result } continue
        if { $aclass in $queue } continue
        lappend queue $aclass
      }
    }
    foreach item $tqueue {
      if {$item in $core_result} continue
      if { $item ni $result } {
        set result [linsert $result 0 $item]
      }
    }
  }
  # Handle core classes last
  set queue $core_result
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
        set result [linsert $result 0 $item]
      }
    }
  }
  return $result
}

###
# Output a dictionary removing any . entries added by [fun {dicttool::merge}]
###
proc oo::meta::to_dicttool {dict} {
  ::set result {}
  ::set level -1
  if {![dict is_dict $dict]} {
    return $dict
  }
  _to_dicttool {} result $dict
  return $result
}

###
# Helper function for ::dicttool::sanitize
# Formats the string representation for a dictionary element within
# a human readable stream of lines, and determines if it needs to call itself
# with further indentation to express a sub-branch
###
proc oo::meta::_to_dicttool {path varname dict} {
  upvar 1 $varname result
  dict for {field value} $dict {
    if {$field eq "."} continue
    if {[dicttool::is_branch $dict $field]} {
      dict set result {*}$path $field . {}
      _to_dicttool [list {*}$path $field] result $value
    } else {
      dict set result {*}$path [string trim $field :] $value
    }
  }
}

proc oo::meta::clay_branch args {
  foreach item $args {
    lappend result [string trim $item /:]/
  }
  return $result
}

proc oo::meta::clay_leaf args {
  set tfx [string index [lindex $args end] end]
  if {$tfx eq "/"} {
    return {*}$args
  }
  set result {}
  foreach item [lrange $args 0 end-1] {
    lappend result [string trim $item /:]/
  }
  lappend result [string trim [lindex $args end] :]
  return $result
}

proc oo::meta::claypath args {
  set tfx [string index [lindex $args end] end]
  if {$tfx eq "/"} {
    return $args
  }
  set result {}
  set root [lindex $args 0]
  if {$root in {option method_ensemble}} {
    lappend result $root/
    if {[llength $args]>1} {
      lappend result [string trim [lindex $args 1] /:]
    }
    foreach item [lrange $args 2 end-1] {
      lappend result [string trim $item /:]
    }
    if {[llength $args]>2} {
      lappend result [string trim [lindex $args end] :]
    }
  } elseif {$root in {variable dict array}} {
    lappend result $root/
    if {[llength $args]>1} {
      lappend result [string trim [lindex $args 1] /:]/
    }
    foreach item [lrange $args 2 end-1] {
      lappend result [string trim $item /:]/
    }
    if {[llength $args]>2} {
      lappend result [lindex $args end]
    }
  } else {
    foreach item [lrange $args 0 end-1] {
      lappend result [string trim $item /:]/
    }
    lappend result [string trim [lindex $args end] :]
  }
  return $result
}

proc oo::meta::info {class args} {
  set class [::oo::meta::normalize $class]
  tailcall $class meta {*}$args
}
noop {
  switch $submethod {
    cget {
      ###
      # submethod: cget
      # arguments: ?*path* ...? *field*
      # format: markdown
      # description:
      # Retrieve a value from the class' meta data. Values are searched in the
      # following order:
      # 1. From class meta data as const **path** **field:**
      # 2. From class meta data as const **path** **field**
      # 3. From class meta data as **path** **field:**
      # 4. From class meta data as **path** **field**
      ###
      set path [::oo::meta::clay_leaf {*}$args]
      if {[$class clay exists const/ {*}$path]} {
        return [$class clay get const/ {*}$path]
      }
      if {[$class clay exists {*}$path]} {
        return [$class clay get {*}$path]
      }
      return {}
    }
    exists {
      set path [oo::meta::claypath {*}$args]
      return [$class clay exists $path]
    }
    rebuild {
      ::oo::meta::rebuild $class
    }
    is {
      set path [::oo::meta::clay_leaf is {*}[lrange $args 1 end]]
      return [string is [lindex $args 0] -strict [$class clay get {*}$path]]
    }
    for -
    map {
      set info [$class clay find {*}[lrange $args 1 end-1]]
      tailcall ::dict $submethod [lindex $args 0] $info [lindex $args end]
    }
    with {
      upvar 1 TEMPVAR info
      set info [$class clay find {*}[lrange $args 1 end-1]]
      tailcall ::dict with TEMPVAR [lindex $args end]
    }
    branchget {
      return [dicttool::sanitize [$class clay get $args]]
    }
    branchset {
      set path [::dicttool::storage [lrange $args 0 end-1]]
      foreach {field value} [lindex $args end] {
        $class clay set {*}$path [string trim $field /:] [::oo::meta::to_dicttool $value]
      }
    }
    leaf_add {
      error "Unsupported"
    }
    leaf_remove {
      error "Unsupported"
    }
    set -
    update {
      ::oo::meta::rebuild $class
      set value [::oo::meta::to_dicttool [lindex $args end]]
      $class clay set {*}$path $field: $value

      set field [lindex $args end-1]
      set path  [lrange $args 0 end-2]
      puts [list META SET $class -> $path $field $value]
      if {![dict is_dict $value] || [string index $field end] eq ":"} {
        $class clay set {*}$path $field: $value
      } else {
        $class clay merge {*}$path $field $value
      }
    }
    unset {
      ::oo::meta::rebuild $class
      $class clay unset {*}$args
    }
    append -
    incr -
    lappend {
      error "Operation not supported"
      ::oo::meta::rebuild $class
      $class clay $submethod {*}$args
    }
    merge {
      ::oo::meta::rebuild $class
      $class clay merge {*}$args
    }
    dump {
      set info [metadata $class]
      return $info
    }
    get -
    getnull {
      if {![$class clay exists {*}$args]} {
        return [$class clay find {*}[lrange $args 0 end-1] [lindex $args end]:]
      } else {
        return [$class clay find {*}$args]
      }
    }
    default {
      set info [metadata $class]
      return [::dict $submethod $info {*}$args]
    }
  }
}

proc ::oo::meta::localdata {class args} {
  if {[llength $args]==0} {
    return [::dicttool::sanitize [$class clay dump]]
  } else {
    return [::dicttool::sanitize [$class clay get {*}$args]]
  }
}

proc ::oo::meta::normalize class {
  set class ::[string trimleft $class :]
}

proc ::oo::meta::metadata {class {force 0}} {
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
      if {[$dclass clay get classinfo type:] eq "core"} {
        if {$dclass ni $::oo::dialect::core_classes} {
          lappend ::oo::dialect::core_classes $dclass
        }
      }
    }
    set dirty_classes {}
  }

  ###
  # If the cache is available, use it
  ###
  variable cached_property
  if {[::info exists cached_property($class)]} {
    return [dicttool::sanitize $cached_property($class)]
  }
  ###
  # Build a cache of the hierarchy and the
  # aggregate metadata for this class and store
  # them for future use
  ###
  variable cached_hierarchy
  set metadata {}
  set stack {}
  set cached_hierarchy($class) [::oo::meta::ancestors $class]
  foreach aclass $cached_hierarchy($class) {
    ::dicttool::dictmerge metadata [$aclass clay dump]
  }
  ::dicttool::dictmerge metadata {. {} classinfo {type {}}}
  ::dicttool::dictmerge metadata [$class clay dump]
  set cached_property($class) $metadata
  return [::dicttool::sanitize $metadata]
}

proc ::oo::meta::rebuild args {
  foreach class $args {
    if {$class ni $::oo::meta::dirty_classes} {
      lappend ::oo::meta::dirty_classes $class
    }
  }
}

proc ::oo::meta::search args {
  error "Feature Removed"
}

proc ::oo::define::meta {args} {
  set class [lindex [::info level -1] 1]
  if {[lindex $args 0] in "cget set branchset"} {
    ::oo::meta::info $class {*}$args
  } else {
    ::oo::meta::info $class set {*}$args
  }
}

oo::define oo::class {
 method meta {submethod args} {
    switch $submethod {
      branchget {
        set path [oo::meta::clay_branch {*}$args]
        return [dicttool::sanitize [my clay get $path]]
      }
      branchset {
        set path [oo::meta::clay_branch {*}[lrange $args 0 end-1]]
        foreach {field value} [lindex $args end] {
          my clay set {*}$path [string trim $field /:] [::oo::meta::to_dicttool $value]
        }
      }
      cget {
        ###
        # submethod: cget
        # arguments: ?*path* ...? *field*
        # format: markdown
        # description:
        # Retrieve a value from the local objects **meta** dict
        # or from the class' meta data. Values are searched in the
        # following order:
        # 0. (If path length==1) From the _config array
        # 1. From the local dict as **path** **field:**
        # 2. From the local dict as **path** **field**
        # 3. From class meta data as const **path** **field:**
        # 4. From class meta data as const **path** **field**
        # 5. From class meta data as **path** **field:**
        # 6. From class meta data as **path** **field**
        ###
        set path [::dicttool::storage {*}$args]
        if {[my clay exists {*}$path]} {
          return [my clay get {*}$path]
        }
        if {[my clay exists const/ {*}$path]} {
          return [my clay get const/ {*}$path]
        }
        if {[llength $path]==1} {
          set field [string trim [lindex $path end] -:/]
          if {[my clay exists option $field default]} {
            return [my clay get option $field default]
          }
        }
        return {}
      }
      dump {
        return [my clay dump]
      }
      exists {
        set path [oo::meta::claypath {*}$args]
        return [my clay exists $path]
      }
      for -
      map {
        set path [::dicttool::storage [lrange $args 1 end-1]]
        set info  [dicttool::sanitize [my clay find {*}$path]]
        tailcall ::dict $submethod [lindex $args 0] $info [lindex $args end]
      }
      is {
        set path [::oo::meta::clay_leaf is {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict [my clay get {*}$path]]
      }
      getnull -
      get {
        set rawpath [::dicttool::storage $args]
        if {[my clay is_branch $rawpath]} {
          set result [my clay find {*}$rawpath]
          return [dicttool::sanitize $result]
        }
        set field [string trim [lindex $rawpath end] :/]
        set path [lrange $rawpath 0 end-1]
        if {[llength $path]==0 || [string index [lindex $args end] end] eq "/"} {
          set result [my clay find {*}$path $field]
          return [dicttool::sanitize $result]
        }
        if {[my clay exists {*}$path $field:]} {
          return [my clay find {*}$path $field:]
        }
        set result [my clay find {*}$path $field]
        if {[dict is_dict $result] && [dict exists $result .]} {
          return [dicttool::sanitize $result]
        }
        return $result
      }
      merge {
        my clay merge {*}${args}
      }
      set {
        set field [lindex $args end-1]
        set path  [::dicttool::storage [lrange $args 0 end-2]]
        set value [lindex $args end]
        if {![dict is_dict $value] || [string index $field end] eq ":"} {
          my clay set {*}$path [string trim $field :/] $value
          return
        }
        if {[llength [dict keys $value *:]]} {
          dict for {f v} $value {
            my clay set {*}$path [string trim $field :/] [string trim $f :] $value
          }
          return
        }
        my clay set {*}$path [string trim $field :/] [::oo::meta::to_dicttool $value]
      }
      with {
        set path [::dicttool::storage [lrange $args 0 end-1]]
        upvar 1 TEMPVAR info
        set info  [dicttool::sanitize [my clay find {*}$path]]
        uplevel 1 [list ::dict with TEMPVAR [lindex $args end]]
      }
      default {
        error "Unknown method $submethod. Valid: branchget branchset cget for is with"
      }
    }
  }
}

oo::define oo::object {
  ###
  # title: Provide access to meta data
  # format: markdown
  # description:
  # The *meta* method allows an object access
  # to a combination of its own meta data as
  # well as to that of its class
  ###
  method meta {submethod args} {
    my variable meta MetaMixin
    if {![info exists MetaMixin]} {
      set MetaMixin {}
    }
    set class [::info object class [self object]]
    set classlist [my clay ancestors]
    switch $submethod {
      cget {
        ###
        # submethod: cget
        # arguments: ?*path* ...? *field*
        # format: markdown
        # description:
        # Retrieve a value from the local objects **meta** dict
        # or from the class' meta data. Values are searched in the
        # following order:
        # 1. From the local dict as **path** **field:**
        # 2. From the local dict as **path** **field**
        # 3. From class meta data as const **path** **field:**
        # 4. From class meta data as const **path** **field**
        # 5. From class meta data as **path** **field:**
        # 6. From class meta data as **path** **field**
        ###
        set path [::oo::meta::clay_leaf {*}$args]

        set field [lindex $path end]
        set path [lrange $path 0 end-1]
        if {[dict exists $meta {*}$path $field]} {
          return [dict get $meta {*}$path $field]
        }
        my variable config clay
        if {[my clay exists const {*}$path $field]} {
          return [my clay get const {*}$path $field]
        }
        if {[my clay exists {*}$path $field]} {
          return [my clay get {*}$path $field]
        }
        return {}
      }
      is {
        set value [my meta cget {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict $value]
      }
      for -
      map {
        set path [::dicttool::storage [lrange $args 1 end-1]]
        set info [dicttool::sanitize [my clay get {*}$path]]
        tailcall ::dict $submethod [lindex $args 0] $info [lindex $args end]
      }
      with {
        set path [::dicttool::storage [lrange $args 0 end-1]]
        upvar 1 TEMPVAR info
        set info  [dicttool::sanitize [my clay get {*}$path]]
        uplevel 1 [list ::dict with TEMPVAR [lindex $args end]]
      }
      dump {
        set result {. {}}
        foreach mclass $classlist {
          ::dicttool::dictmerge result [$mclass clay dump]
        }
        return [::dicttool::sanitize $result]
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        return [dict $submethod meta {*}$args]
      }
      branchset {
        foreach {field value} [lindex $args end] {
          dict set meta {*}[lrange $args 0 end-1] [string trimright $field :]: $value
        }
      }
      rmerge -
      merge {
        set meta [dict rmerge $meta {*}$args]
        return $meta
      }
      exists {
        set path [::oo::meta::clay_leaf {*}$args]
        foreach mclass $classlist {
          if {[$mclass clay exists {*}$path]} {
            return 1
          }
        }
        if {[dict exists $meta {*}$path]} {
          return 1
        }
        if {[dict exists $meta {*}$args]} {
          return 1
        }
        return 0
      }
      get {
        set path [::dicttool::storage $args]
        if {[dict exists $meta {*}$args]} {
          return [dict get $meta {*}$args]
        }
        set dpath [lrange $path 0 end-1]
        set field [string trim [lindex $path end] :]
        if {![my clay exists {*}$dpath $field]} {
          puts [list [self] META [::dicttool::print  [my clay dump]]]
          puts [list [self] meta get $path]
          #puts [[self] meta get $path]
          puts [list [self] meta get $args]
          #puts [[self] meta get $args]
          error "key \"$args\" not known in metadata"
        }
        return [my clay get {*}$dpath $field]
      }
      getnull {
        if {[dict exists $meta {*}$args]} {
          return [dict get $meta {*}$args]
        }
        set path [::dicttool::storage $args]
        set dpath [lrange $path 0 end-1]
        set field [string trim [lindex $path end] :]
        return [my clay get {*}$dpath $field]
      }
      branchget {
        set result {}
        foreach {field value} [my clay get {*}$args] {
          dict set result [string trim $field :] $value
        }
        foreach {field value} [dict getnull $meta {*}$args] {
          dict set result [string trimright $field :] $value
        }
        return $result
      }
      mixin {
        foreach mclass $args {
          set mclass [::oo::meta::normalize $mclass]
          if {$mclass ni $MetaMixin} {
            lappend MetaMixin $mclass
          }
        }
        my clay mixin {*}$MetaMixin
      }
      mixout {
        foreach mclass $args {
          set mclass [::oo::meta::normalize $mclass]
          while {[set i [lsearch $MetaMixin $mclass]]>=0} {
            set MetaMixin [lreplace $MetaMixin $i $i]
          }
        }
        my clay mixin {*}$MetaMixin
      }
      default {
        foreach mclass $classlist {
          lappend mdata [::oo::meta::metadata $mclass]
        }
        set info [dict rmerge {*}$mdata $meta]
        return [dict $submethod $info {*}$args]
      }
    }
  }
}
