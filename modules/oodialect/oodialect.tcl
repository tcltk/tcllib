###
# A utility for defining a domain specific language for TclOO systems
###

namespace eval ::oo::dialect {}

proc ::oo::dialect::push class {
  ::variable class_stack
  lappend class_stack $class
}
proc ::oo::dialect::peek {} {
  ::variable class_stack
  return [lindex $class_stack end]
}
proc ::oo::dialect::pop {} {
  ::variable class_stack
  set class_stack [lrange $class_stack 0 end-1]
}

###
# This proc will generate a namespace, a "mother of all classes",
# and a rudimentary set of policies for this dialect
###
proc ::oo::dialect::create {name {parent {}}} {
  if {[string index $name 0] eq ":"} {
    set name [string trimleft $name :]
    set NSPACE ::${name}
  } else {
    set NSPACE [uplevel 1 [namespace current]]::$name
  }
  ::namespace eval $NSPACE {}
  ::namespace eval ${NSPACE}::define {}
  ###
  # Build the "define" namespace
  ###
  if {$parent eq {}} {
    ###
    # With no "parent" language, begin with all of the keywords in oo::define
    ###
    foreach command [info commands ::oo::define::*] {
      set procname [namespace tail $command]
      proc ${NSPACE}::define::$procname args "oo::define \[::oo::dialect::peek\] $procname {*}\$args"
    }
    # Create an empty dynamic_methods proc
    proc ${NSPACE}::dynamic_methods class {}
    set ANCESTORS {}
  } else {
    ###
    # If we have a parent language, that language already has the oo::define keywords
    # as well as additional keywords and behaviors. We should begin with that
    ###
    if {[string index $parent 0] eq ":"} {
      set parent [string trimleft $parent :]
      set pnspace ::${parent}
    } else {
      set pnspace [uplevel 1 [namespace current]]::$parent
      if {![namespace exists $pnspace]} {
        set parent [string trimleft $parent :]
        set pnspace ::${parent}
      }
    }
    ::namespace eval ${pnspace} [list ::namespace export dynamic_methods]
    ::namespace eval ${pnspace}::define [list ::namespace export *]
    ::namespace eval ${NSPACE} [list ::namespace import ${pnspace}::dynamic_methods]    
    ::namespace eval ${NSPACE}::define [list ::namespace import ${pnspace}::define::*]
    set ANCESTORS ${pnspace}::object
  }
  ###
  # Build our dialect template functions
  ###
  uplevel #0 [string map [list %NSPACE% $NSPACE %name% $name %ANCESTORS% $ANCESTORS] {
###
# create the %NSPACE%::define command
###
proc %NSPACE%::define {class args} {
  ::oo::dialect::push $class
  if {[llength $args]==1} {
    namespace eval %NSPACE%::define [lindex $args 0]
  } else {
    %NSPACE%::define::[lindex $args 0] {*}[lrange $args 1 end]
  }
  %NSPACE%::dynamic_methods $class
  ::oo::dialect::pop
}

###
# title: Specify other names that this class will answer to
###
proc %NSPACE%::define::current_class args {
  return [::oo::dialect::peek]
}
    
###
# title: Specify other names that this class will answer to
###
proc %NSPACE%::define::aliases args {
  set class [::oo::dialect::peek]
  set %NSPACE%::cname($class) $class
  foreach name $args {
    set alias ::[string trimleft $name :]
    set %NSPACE%::cname($alias) $class
  }
}

###
# Create a superclass keyword which will enforce the inheritance
# of our language's mother of all classes
###
proc %NSPACE%::define::superclass {args} {
  set class [::oo::dialect::peek]
  dict set %NSPACE%::class_info($class) superclass 1
  set result {}
  foreach item $args {
    set Item ::[string trimleft $item :]
    if {[info exists %NSPACE%::cname($Item)]} {
      if {$%NSPACE%::cname($Item) ni $result} {
        lappend result $%NSPACE%::cname($Item)
      }
    } else {
      if {[info commands $Item] ne {}} {
        if {$Item ni $result} {
          lappend result $Item
        }
      } else {
        if {$item ni $result} {
          lappend result $item
        }
      }
    }
  }
  if {$class ne "%NSPACE%::object" && "%NSPACE%::object" ni $result} {
    lappend result %NSPACE%::object
  }
  oo::define [::oo::dialect::peek] superclass {*}$result
}

###
# Build the metaclass for our language
###
oo::class create %NSPACE%::class {
  superclass oo::class
  constructor {definitionScript} {
    %NSPACE%::define [self] {
      superclass
      constructor {} {}
    }
    %NSPACE%::define [self] $definitionScript
  }
}
###
# Build the mother of all classes
###
%NSPACE%::class create %NSPACE%::object {
  superclass %ANCESTORS%
    # Put MOACish stuff in here
}
  }]
  
  
}
package provide oo::dialect 0.1