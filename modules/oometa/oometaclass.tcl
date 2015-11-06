###
# Instant Metaclass, just add Water
# "name" is the name of a new namespace
# where a "class" proc will be created
# and a new deriviative of oo::class and oo::object
# will be sprung
###
proc ::oo::metaclass {name} {
  set name ::[string trimleft $name :]
  uplevel #0 [string map [list %NAME% $name] {
  namespace eval %NAME% {}
  namespace eval %NAME%::define {} {
    namespace import ::oo::define::*
  }
  proc %NAME%::define {class body} {
    
    namespace eval %NAME%::define $name $body
  }
  
  proc %NAME%::class {name body} {
    set name ::[string trimleft $name :]
    if {[info command $name] eq {}} {
      %NAME%::the_Class create $name {}
    }
    namespace eval %NAME%::define $name $body
    #::oo::define $name $body
  }

  ::oo::class create %NAME%::object {
    superclass oo::object
  }
  ::oo::class create %NAME%::the_Class {
    superclass oo::class
    
    method constructor {argList body} {
      ::oo::define [self] constructor $argList $body
    }
    method destructor {body} {
      ::oo::define [self] destructor $body
    }
    method filter {args} {
      ::oo::define [self] filter {*}$args
    }
    method forward {name cmdName args} {
      ::oo::define [self] forward $name $cmdName {*}$args
    }
    method method {name argList body} {
      ::oo::define [self] method $name $argList $body
    }
    method mixin {args} {
      ::oo::define [self] mixin {*}$args
    }
    method superclass {args} {
      if {"%NAME%::object" ni $args} {
        lappend args %NAME%::object
      }
      ::oo::define [self] superclass {*}$args
    }
    method variable {args} {
      ::oo::define [self] variable {*}$args
    }
  }
  }]
}

package provide oo::metaclass 0.1