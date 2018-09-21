###
# Author: Sean Woods, yoda@etoyoc.com
##
# TclOO routines to implement property tracking by class and object
###
package require Tcl 8.6 ;# tailcall
package require dicttool
package require clay
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

proc oo::meta::clay_branch args {
  foreach item $args {
    lappend result [string trim $item /:]/
  }
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
      lappend result [string trim [lindex $args end] :]
    }
  } else {
    foreach item [lrange $args 0 end-1] {
      lappend result [string trim $item /:]/
    }
    lappend result [string trim [lindex $args end] :]
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

proc oo::meta::info {class submethod args} {
  set class [::oo::meta::normalize $class]
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
      #::oo::meta::rebuild $class
    }
    is {
      set path [::oo::meta::clay_leaf is {*}[lrange $args 1 end]]
      return [string is [lindex $args 0] -strict [$class clay get {*}$path]]
    }
    for -
    map {
      set info [dict sanitize [$class clay find {*}[lrange $args 1 end-1]]]
      uplevel 1 [list ::dict $submethod [lindex $args 0] $info [lindex $args end]]
    }
    with {
      upvar 1 TEMPVAR info
      set info [dict sanitize [$class clay dump]]
      return [uplevel 1 [list ::dict with TEMPVAR {*}$args]]
    }
    branchget {
      return [dict sanitize [$class clay get $args]]
    }
    branchset {
      #$class clay set {*}$args
      #set path [oo::meta::clay_branch {*}[lrange $args 0 end-1]]
      set path [::dicttool::storage [lrange $args 0 end-1]]
      foreach {field value} [lindex $args end] {
        $class clay set {*}$path [string trim $field /:] $value
      }
    }
    get -
    getnull {
      set result [$class clay get {*}${args}]
      if {[llength $args]==1} {
        return [dict sanitize $result]
      }
      return $result
    }
    set {
      $class clay set {*}$args
    }
    merge {
      $class clay merge {*}${args}
    }
    dump {
      return [dict sanitize [$class clay dump]]
    }
    default {
      error "Unknown method $submethod. Valid: branchget branchset cget for is with"
    }
  }
}

proc ::oo::meta::localdata {class args} {
  return [$class clay dump]
}

proc ::oo::meta::normalize class {
  set class ::[string trimleft $class :]
}

proc ::oo::meta::metadata {class {force 0}} {
  return [$class clay dump]
}

proc ::oo::meta::rebuild args {
  # GNDN
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
        return [dict sanitize [my clay get $path]]
      }
      branchset {
        set path [oo::meta::clay_branch {*}[lrange $args 0 end-1]]
        foreach {field value} [lindex $args end] {
          my clay set {*}$path [string trim $field /:] $value
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
        set path [::oo::meta::clay_leaf {*}$args]
        if {[my clay exists {*}$path]} {
          return [my clay get {*}$path]
        }
        if {[my clay exists const/ {*}$path]} {
          return [my clay get const/ {*}$path]
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
        set info  [dict sanitize [my clay find {*}$path]]
        tailcall ::dict $submethod [lindex $args 0] $info [lindex $args end]
      }
      is {
        set path [::oo::meta::clay_leaf is {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict [my clay get {*}$path]]
      }
      getnull -
      get {
        set result [my clay find {*}$args]
        if {[llength $args]==1} {
          return [dict sanitize $result]
        }
        return $result
      }
      merge {
        my clay merge {*}${args}
      }
      set {
        my clay set {*}$args
      }
      with {
        upvar 1 TEMPVAR info
        set info [dict sanitize [my clay find {*}[lrange $args 0 end-1]]]
        tailcall ::dict with TEMPVAR [lindex $args end]
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
    set class [::info object class [self object]]
    switch $submethod {
      branchget {
        return [dict sanitize [my clay get {*}$args]]
      }
      branchset {
        #my clay set {*}$args
        set path [::dicttool::storage [lrange $args 0 end-1]]
        foreach {field value} [lindex $args end] {
          my clay set {*}$path [string trim $field /:] $value
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
        set path [::dicttool::storage $args]
        if {[my clay exists const {*}$path]} {
          return [my clay get const {*}$path]
        }
        my variable config clay
        if {[info exists config]} {
          if {[dict exists $config {*}$path]} {
            return [dict get $config {*}$path]
          }
        }
        if {[my clay exists {*}$path]} {
          return [dict remove [my clay get {*}$path] .]
        }
        return {}
      }
      dump {
        return [dict sanitize [my clay dump]]
      }
      exists {
        return [my clay exists {*}$args]
      }
      for -
      map {
        set path [::dicttool::storage [lrange $args 1 end-1]]
        set info  [dict sanitize [my clay get {*}$path]]
        tailcall ::dict $submethod [lindex $args 0] $info [lindex $args end]
      }
      get - getnull {
        return [my clay get {*}$args]
      }
      is {
        set path [::dicttool::storage [lrange $args 1 end]]
        return [string is [lindex $args 0] -strict [my clay get {*}$path]]
      }
      merge {
        my clay merge {*}${args}
      }
      mixin {
        my clay mixin {*}$args
      }
      set {
        my clay set {*}$args
      }
      with {
        upvar 1 TEMPVAR info
        set info [dict sanitize [my clay get {*}[lrange $args 0 end-1]]]
        tailcall ::dict with TEMPVAR [lindex $args end]
      }
      default {
        error "Unknown method $submethod. Valid: branchget branchset cget for is with"
      }
    }
  }
}
