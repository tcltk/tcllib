###
# Option handling for TclOO
###
package require Tcl 8.6 ;# due oo::meta
package require oo::meta 0.8

proc ::oo::define::option {field argdict} {
  set class [lindex [::info level -1] 1]
  set field [string trimleft $field -/:]
  set properties {default {}}
  foreach {f v} $argdict {
    dict set properties [string trim $f -/:] $v
  }
  dict for {f v} [$class clay get option $field] {
    if {![dict exists $properties $f]} {
      dict set properties $f $v
    }
  }
  $class clay set option/ $field/ $properties
}

::oo::object clay set const options_strict 0

oo::define oo::object {

  method config {submethod args} {
    switch $submethod {
      get {
        return [my Config_get {*}$args]
      }
      merge {
        return [my Config_merge {*}$args]
      }
      set {
        my Config_set {*}$args
      }
      default {
        error "Invalid method $submethod. Valid: get merge set"
      }
    }
  }

  ###
  # topic: 86a1b968cea8d439df87585afdbdaadb
  ###
  method cget args {
    return [my Config_get {*}$args]
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
    set dat [my Config_merge $dictargs]
    my Config_triggers $dat
  }

  method Config_get {field args} {
    my variable config option_canonical option_getcmd
    set field [string trimleft $field -]
    if {[info exists option_canonical($field)]} {
      set field $option_canonical($field)
    }
    if {[info exists option_getcmd($field)]} {
      return [eval $option_getcmd($field)]
    }
    if {[dict exists $config $field]} {
      return [dict get $config $field]
    }
    if {[llength $args]} {
      return [lindex $args 0]
    }
    return [my meta cget $field]
  }

  ###
  # topic: dc9fba12ec23a3ad000c66aea17135a5
  ###
  method Config_merge dictargs {
    my variable config option_canonical
    set rawlist $dictargs
    set dictargs {}
    set dat [my clay get option/]
    foreach {field val} $rawlist {
      set field [string trimleft $field -]
      set field [string trimright $field :]
      if {[info exists option_canonical($field)]} {
        set field $option_canonical($field)
      }
      dict set dictargs $field $val
    }
    ###
    # Validate all inputs
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field validate-command]
      if {$script ne {}} {
        dict set dictargs $field [eval [string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]]
      }
    }
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field set-command]
      dict set config $field $val
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
    return $dictargs
  }

  method Config_set args {
    set dictargs [::tool::args_to_options {*}$args]
    set dat [my Config_merge $dictargs]
    my Config_triggers $dat
  }

  ###
  # topic: 543c936485189593f0b9ed79b5d5f2c0
  ###
  method Config_triggers dictargs {
    set dat [my clay get option/]
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field post-command]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
  }

  method Option_Default field {
    set info [my clay get option/ $field]
    set getcmd [dict getnull $info default-command]
    if {$getcmd ne {}} {
      return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
    } else {
      return [dict getnull $info default]
    }
  }
}
package provide oo::option 0.4
