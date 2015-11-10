proc ::tool::define::array {name {values {}}} {
  set class [current_class]
  set name [string trimright $name :]:
  if {![::oo::meta::info $class exists array $name]} {
    ::oo::meta::info $class set array $name {}
  }
  foreach {var val} $values {
    ::oo::meta::info $class set array $name $var $val
  }
}

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
  
  ###
  # Mirrored Option Handling
  ###
  set mirror [dict getnull $dictargs mirror:]
  if {[llength $mirror]} {
    if {![dict exists $dictargs signal:]} {
      set signal {}
      foreach i $mirror {
        set sname option_mirror_$i
        lappend signal $sname
        if {![::oo::meta::info $class exists signal $sname]} {
          ::tool::define::signal $sname [string map [list %signal% sname %organ% $i] {
            action: {
              if {[my organ %organ%] ne {}} {
                my %organ% configure {*}[my OptionsMirrored %organ%]
              }
            }
          }]
        }
      }
      dict set dictargs signal: $signal
    }
  }
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

###
# topic: 615b7c43b863b0d8d1f9107a8d126b21
# title: Specify a variable which should be initialized in the constructor
# description:
#    This keyword can also be expressed:
#    [example {property variable NAME {default DEFAULT}}]
#    [para]
#    Variables registered in the variable property are also initialized
#    (if missing) when the object changes class via the [emph morph] method.
###
proc ::tool::define::variable {name {default {}}} {
  set class [current_class]
  set name [string trimright $name :]
  ::oo::meta::info $class set variable $name: $default
}



::tool::define ::tool::object {
  property options_strict 0

  ###
  # topic: 86a1b968cea8d439df87585afdbdaadb
  ###
  method cget {field {default {}}} {
    my variable config
    set field [string trimleft $field -]  
    if {[my meta is true options_strict] && ![my meta exists option $field]} {
      error "Invalid option -$field. Valid: [my meta keys option]"
    }
    set info [my meta branchget option $field]
    if {$default eq "default"} {
      return [my Option_Default $field]
    }
    set getcmd [dict getnull $info get-command:]
    if {$getcmd ne {}} {
      return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
    }
    if {[dict exists $config $field]} {
      return [dict get $config $field]
    }
    if {$info ne {}} {
      return [my Option_Default $field]
    }
    return [my meta getnull const ${field}:]
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
    set dat [my meta getnull option]
    if {[my meta is true options_strict]} {
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
      set script [dict getnull $dat $field validate-command:]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
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
        dict set config $field $val
      }
    }
  }

  ###
  # topic: 543c936485189593f0b9ed79b5d5f2c0
  ###
  method configurelist_triggers dictargs {
    #set dat [my meta getnull option]
    # Add a lock to prevent signals from
    # spawning signals
    ###
    # Apply normal inputs
    ###
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
    if {![info exists config]} {
      set config {}
    }
    foreach {var info} [my meta getnull option] {
      if {![dict exists $config $var]} {
        dict set config $var [my Option_Default $var]
      }
    }
    foreach {var value} [my meta branchget variable] {
      if { $var eq "meta" } continue
      if { $var eq "config" } continue
      my variable $var
      if {![info exists $var]} {
        set $var $value
      }
    }
    foreach {var value} [my meta branchget array] {
      if { $var eq "meta" } continue
      if { $var eq "config" } continue
      my variable $var
      foreach {f v} $value {
        if {![array exists ${var}($f)]} {
          set ${var}($f) $v
        }
      }
    }
  }
}