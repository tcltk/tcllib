#-------------------------------------------------------------------------
# TITLE: 
#    tool.tcl
#
# PROJECT:
#    tool: TclOO Helper Library
#
# DESCRIPTION:
#    tool(n): Implementation File
#
#-------------------------------------------------------------------------

namespace eval ::tool {}
namespace eval ::tool::define {}

proc ::tool::dynamic_methods class {
  set metainfo [::oo::meta::metadata $class]

}

proc ::tool::define::array {name {values {}}} {
  set class [current_class]
  set name [string trimright $name :]:
  if {![::oo::meta::info $class exists $array $name]} {
    ::oo::meta::info $class set array $name {}
  }
  foreach {var val} $values {
    ::oo::meta::info $class set array $name: $var $val
  }
}

###
# Hijack the constructor and superclass keywords at least
# to enforce this framework
###
proc ::tool::define::constructor {arglist body} {
  set class [current_class]
  set prefix {
  my InitializePublic
  }
  oo::define $class constructor $arglist "$prefix\n$body"
  ::tool::dynamic_methods $class
}

proc ::tool::define::option {name branchinfo} {
  set class [current_class]
  # NEXT, save the option data
  ::oo::meta::info $class branchset option $name $branchinfo
}

###
# topic: 8bcae430f1eda4ccdb96daedeeea3bd409c6bb7a
# description: Add properties and option handling
###
proc ::tool::define::property args {
  set class [current_class]
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


proc ::tool::define::variable {name {default {}}} {
  set class [current_class]
  set name [string trimright $name :]
  ::oo::meta::info $class set variable $name: $default
  ::oo::define $class variable $name
}

#-------------------------------------------------------------------------
# Option Handling Mother of all Classes

# tao::object
#
# This class is inherited by all classes that have options.
#

::tool::define ::tool::object {
  # Put MOACish stuff in here
  
  method configure {args} {
    my variable options
    switch [llength $args] {
      0 {
        return [array get options]
      }
      1 {
        set field [lindex $args 0]
        if {![my meta exists option $field]} {
          error "Invalid option $field. Valid: [my meta keys option]"
        }
        return $options($field)
      }
      default {
        my configurelist $args
      }
    }
  }
  method cget {option} {
    my variable options
    if {![my meta exists option $option]} {
      error "Invalid option $option. Valid: [my meta keys option]"
    }
    return $options($option)
  }

  method option_info args {
    set option_info [my meta getnull option]
    switch [llength $args] {
      0 { return $option_info }
      1 {
        set field [lindex $args 0]
        if {$field eq "list" } { 
          return [dict keys $option_info]
        }
        if {![dict exists $option_info $field]} {
          error "Invalid option $field. Valid [dict keys $option_info]"
        }
        return [dict get $option_info $field]
      }
      default {
        return [dict get $option_info {*}$args]
      }
    }
  }

  method configurelist values {
    my variable options
    set option_info [my meta getnull option]
    # Run all validation checks
    foreach {field value} $values {
      if {[dict exists $option_info $field validate-command]} {
        if {[catch [string map [list %self% [self] %field% $field %value% $value] [dict get $option_info $field validate-command]] res opts]} {
          return {*}$opts $res
        }
      }
    }
    # Ensure all options are valid
    foreach {field value} $values {
      if {![dict exists $option_info $field]} {
        error "Bad option $field. Valid: [dict keys $option_info]"
      }
    }
    # Set the values and apply them
    foreach {field value} $values {
      if {[dict exists $option_info $field map-command]} {
        set options($field) [eval [string map [list %self% [self] %field% $field %value% $value] [dict get $option_info $field map-command]]]
      } else {
        set options($field) $value
      }
      if {[dict exists $option_info $field set-command]} {
        eval [string map [list %self% [self] %field% $field %value% $value] [dict get $option_info $field set-command]]
      }
    }
  }
  
  method ancestors {{reverse 0}} {
    set result [::oo::meta::ancestors [info object class [self]]]
    if {$reverse} {
      return [lreverse $result]
    }
    return $result
  }
}


