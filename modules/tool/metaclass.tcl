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
# topic: 710a93168e4ba7a971d3dbb8a3e7bcbc
###
proc ::tool::define::component {name info} {
  set class [current_class]
  ::oo::meta::info $class branchset component $name $info
}

###
# topic: 2cfc44a49f067124fda228458f77f177
# title: Specify the constructor for a class
###
proc ::tool::define::constructor {arglist rawbody} {
  set body {
::tool::object_create [self]
my InitializePublic
my lock create constructor
  }
  append body $rawbody
  append body {
# Run "initialize"
my initialize
# Remove lock constructor
my lock remove constructor
  }
  set class [current_class]
  ::oo::define $class constructor $arglist $body
}

###
# topic: 4cb3696bf06d1e372107795de7fe1545
# title: Specify the destructor for a class
###
proc ::tool::define::destructor rawbody {
  set body {
::tool::object_destroy [self]
  }
  append body $rawbody
  ::oo::define [current_class] destructor $body
}

proc ::tool::define::option {name branchinfo} {
  set class [current_class]
  # NEXT, save the option data
  ::oo::meta::info $class branchset option $name $branchinfo
}

proc ::tool::define::variable {name {default {}}} {
  set class [current_class]
  set name [string trimright $name :]
  ::oo::meta::info $class set variable $name: $default
  ::oo::define $class variable $name
}

#-------------------------------------------------------------------------
# Option Handling Mother of all Classes

# tool::object
#
# This class is inherited by all classes that have options.
#

::tool::define ::tool::object {
  # Put MOACish stuff in here
  variable signals_pending create
  
  constructor args {
    my configurelist [::tool::args_to_options {*}$args]
    my initialize
  }
  
  destructor {}
  
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

  # Called after all options and public variables are initialized
  method initialize {} {}
  
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


