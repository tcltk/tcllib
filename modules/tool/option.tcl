###
# topic: 68aa446005235a0632a10e2a441c0777
# title: Define an option for the class
###
proc ::tool::define::option {name args} {
  set class [current_class]
  set dictargs {default: {}}
  foreach {var val} [::oo::meta::args_to_dict {*}$args] {
    dict set dictargs [string trimright [string trimleft $var -] :]: $val
  }
  set name [string trimleft $name -]
  ::oo::meta::info $class branchset option $name $dictargs
}

###
# topic: 827a3a331a2e212a6e301f59c1eead59
# title: Define a class of options
# description:
#    Option classes are a template of properties that other
#    options can inherit.
###
proc ::tool::define::option_class {name args} {
  set class [current_class]
  set dictargs {default {}}
  foreach {var val} [::oo::meta::args_to_dict {*}$args] {
    dict set dictargs [string trimleft $var -] $val
  }
  set name [string trimleft $name -]
  ::oo::meta::info $class branchset option_class $name $dictargs
}

::tool::define ::tool::object {
  property options_strict 0

  ###
  # topic: 86a1b968cea8d439df87585afdbdaadb
  ###
  method cget {field {default {}}} {
    my variable options options_canonical
    set field [string trimleft $field -]
    if {[info exists options_canonical($field)]} {
      set field $options_canonical($field)
    }
    if {[info exists options($field)]} {
      return $options($field)
    }
    if {[my property options_strict]} {
      error "Invalid option -$field. Valid: [my meta keys option]"
    }
    return [my property $field]
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
    my variable options options_canonical
    set rawlist $dictargs
    set dictargs {}
    set dat [my meta getnull option]
    set strict [my meta is true options_strict]
    foreach {field val} $rawlist {
      set field [string trimleft $field -]
      set field [string trimright $field :]
      if {[info exists options_canonical($field)]} {
        set field $options_canonical($field)
      } elseif {$strict && ![dict exists $dat $field]} {
        error "Invalid option $field. Valid: [dict keys $dat]"
      }
      dict set dictargs $field $val
    }
    ###
    # Validate all inputs
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field validate-command:]
      if {$script ne {}} {
        dict set dictargs $field [eval [string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]]
      }
    }
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field set-command:]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      } else {
        set options($field) $val
      }
    }
  }

  ###
  # topic: 543c936485189593f0b9ed79b5d5f2c0
  ###
  method configurelist_triggers dictargs {
    set dat [my meta getnull option]
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field post-command:]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      } else {
        set options($field) $val
      }
    }
  }

  method Option_Default field {
    set info [my meta getnull option $field]
    set getcmd [dict getnull $info default-command:]
    if {$getcmd ne {}} {
      return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
    } else {
      return [dict getnull $info default:]
    }
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
    my variable config meta
    if {![info exists meta]} {
      set meta {}
    }
    foreach {var value} [my meta branchget variable] {
      if { $var in {meta options} } continue
      my variable $var
      if {![info exists $var]} {
        set $var $value
      }
    }
    foreach {var value} [my meta branchget array] {
      if { $var eq {meta options} } continue
      my variable $var
      foreach {f v} $value {
        if {![array exists ${var}($f)]} {
          set ${var}($f) $v
        }
      }
    }
    my variable options options_canonical
    foreach {var info} [my meta getnull option] {
      if {[dict exists $info aliases:]} {
        foreach alias [dict exists $info aliases:] {
          set options_canonical($alias) $var
        }
      }
      if {![info exists options($var)]} {
        set options($var) [my Option_Default $var]
      }
    }
  }
}

package provide tool::option 0.1
