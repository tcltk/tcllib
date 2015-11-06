###
# A utility for defining a domain specific language for TclOO systems
###

namespace eval ::oo::dialect {}

###
# This proc will generate a namespace, a "mother of all classes",
# and a rudimentary set of policies for this dialect
###
proc ::oo::dialect::create {name} {
  set name [string trimleft $name :]
  set NAME ::${name}
  uplevel #0 [string map [list %NAME% $NAME %name% $name] {
namespace eval %NAME% {}
namespace eval %NAME%::define {}

###
# Build the "define" namespace
###
foreach command [info commands ::oo::define::*] {
  set procname [namespace tail $command]
  proc %NAME%::define::$procname args "
oo::define \[%NAME%::peek\] $procname {*}\$args
"
}

###
# topic: 5832132afd4f65a0dd404f834e7fce7f
# title: Specify other names that this class will answer to
###
proc %NAME%::define::aliases args {
  set class [%NAME%::peek]
  set %NAME%::cname($class) $class
  foreach name $args {
    set alias ::[string trimleft $name :]
    set %NAME%::cname($alias) $class
  }
}

###
# Hijack the constructor and superclass keywords at least
# to enforce this framework
###
proc %NAME%::define::constructor {arglist body} {
  set class [%NAME%::peek]
  dict set %NAME%::class_info($class) constructor 1
  set prefix [%NAME%::body_constructor]
  oo::define $class constructor $arglist "$prefix\n$body"
}

proc %NAME%::define::superclass {args} {
  set class [%NAME%::peek]
  dict set %NAME%::class_info($class) superclass 1
  set result {}
  foreach item $args {
    set Item ::[string trimleft $item :]
    if {[info exists %NAME%::cname($Item)]} {
      lappend result $%NAME%::cname($Item)
    } else {
      lappend result $item
    }
  }
  if {$class ne "%NAME%::object" && "%NAME%::object" ni $result} {
    lappend result %NAME%::object
  }
  oo::define [%NAME%::peek] superclass {*}$result
}

proc %NAME%::class {name args} {
  variable class_info
  set new 0
  if {$name eq "new"} {
    set class [uplevel 1 {oo::class new { superclass %NAME%::object }}]
    set new 1
  } else {
    # FIRST, make sure the class is fully qualified
    if {![string match "::*" $name]} {
      set class ::[string trimleft [uplevel 1 {namespace current}]::$name :]
    } else {
      set class $name
    }
    # Create class if it doesn’t exist
    if {[info commands $class] eq {}} {
      if {$class eq "%NAME%::object"} {
        oo::class create %NAME%::object {}
      } else {
        oo::class create $class { superclass %NAME%::object }
      }
      set new 1
    }
  }
  if {!$new} {
    if {![info exists class_info($class)]} {
      error "%NAME%::define on non-%name% class: \"$class\""
    }
  } else {
    set class_info($class) {
      constructor 0
      superclass 0
      dialect %name%
    }
  }

  if {[llength $args] == 1} {
    set script [lindex $args 0]
  } else {
    set script $args
  }
  define $class $script
  return $class
}

proc %NAME%::define {name script} {
  # FIRST, make sure the class is fully qualified
  variable class_info
  if {![string match "::*" $name]} {
    set class ::[string trimleft [uplevel 1 {namespace current}]::$name :]
  } else {
    set class $name
  }
  %NAME%::push $class
  try {
    namespace eval %NAME%::define $script
    if {![dict get $class_info($class) superclass]} {
      # Define an empty superclass to trigger our magic
      %NAME%::define::superclass
    }
    if {![dict get $class_info($class) constructor]} {
      # Define an empty constructor to trigger our magic
      %NAME%::define::constructor {} {}
    }
    %NAME%::dynamic_methods $class
  } finally {
    %NAME%::pop
  }
}

###
# title: Internal function
# description: Returns the current class being processed
###
proc %NAME%::peek {} {
  ::variable classStack
  set class   [lindex $classStack end]
  return ${class}
}

###
# title: Internal function
# description: Removes the current class being processed from the parser stack.
###
proc %NAME%::pop {} {
  ::variable classStack
  set class      [lindex $classStack end]
  set classStack [lrange $classStack 0 end-1]
  return $class
}

###
# description: Push a class onto the stack
###
proc %NAME%::push type {
  ::variable classStack
  lappend classStack $type
}

###
# Template functions to fill out
###

# Return any pre-amble to the constructor
# that this framework expects
proc %NAME%::body_constructor {} {
}
#
proc %NAME%::dynamic_methods {class} {
  # Build dynamically generated classes for this framework
  #oo::define $class [string map [list %class% $class %ns% $ns] {
  #}]
}


###
# Build the mother of all classes
###

%NAME%::class %NAME%::object {
    # Put MOACish stuff in here
}

  }]
}

package provide oo::dialect 0.1