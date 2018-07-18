
###
# clay.tcl
#
# Copyright (c) 2018 Sean Woods
#
# BSD License
###
# @@ Meta Begin
# Package clay 0.2
# Meta platform     tcl
# Meta summary      A minimalist framework for complex TclOO development
# Meta description  This package introduces the method "clay" to both oo::object
# Meta description  and oo::class which facilitate complex interactions between objects
# Meta description  and their ancestor and mixed in classes.
# Meta category     TclOO
# Meta subject      framework
# Meta require      {Tcl 8.6}
# Meta author       Sean Woods
# Meta license      BSD
# @@ Meta End

###
# Amalgamated package for clay
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package provide clay 0.2
namespace eval ::clay {}

###
# START: core.tcl
###
package require Tcl 8.6 ;# try in pipeline.tcl. Possibly other things.
package require TclOO
package require uuid
package require oo::dialect

::oo::dialect::create ::clay

::namespace eval ::clay {}
::namespace eval ::clay::classes {}
::namespace eval ::clay::define {}

###
# END: core.tcl
###
###
# START: procs.tcl
###
::namespace eval ::clay {}
set ::clay::trace 0

###
# Global utilities
###
if {[info commands ::ladd] eq {}} {
  proc ladd {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        set var {}
    }
    foreach item $args {
      if {$item in $var} continue
      lappend var $item
    }
    return $var
  }
}

if {[info command ::ldelete] eq {}} {
  proc ::ldelete {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        return
    }
    foreach item [lsort -unique $args] {
      while {[set i [lsearch $var $item]]>=0} {
        set var [lreplace $var $i $i]
      }
    }
    return $var
  }
}

if {[info command ::lrandom] eq {}} {
  proc ::lrandom list {
    set len [llength $list]
    set idx [expr int(rand()*$len)]
    return [lindex $list $idx]
  }
}

if {[::info commands ::tcl::dict::getnull] eq {}} {
  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
}

proc ::putb {buffername args} {
  upvar 1 $buffername buffer
  switch [llength $args] {
    1 {
      append buffer [lindex $args 0] \n
    }
    2 {
      append buffer [string map {*}$args] \n
    }
    default {
      error "usage: putb buffername ?map? string"
    }
  }
}
namespace eval ::clay {}

proc ::clay::ancestors args {
  set result {}
  set queue {}
  foreach class [lreverse $args] {
    lappend queue $class
  }

  # Rig things such that that the top superclasses
  # are evaluated first
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
        lappend result $item
      }
    }
  }
  return $result
}

proc ::clay::args_to_dict args {
  if {[llength $args]==1} {
    return [lindex $args 0]
  }
  return $args
}

proc ::clay::args_to_options args {
  set result {}
  foreach {var val} [args_to_dict {*}$args] {
    lappend result [string trim $var -:] $val
  }
  return $result
}

proc ::clay::dictmerge {varname args} {
  upvar 1 $varname result
  if {![info exists result]} {
    set result {}
  }
  switch [llength $args] {
    0 {
      return
    }
    1 {
      set result [_dictmerge $result [lindex $args 0]]
      return $result
    }
    2 {
      lassign $args path value
    }
    default {
      # Merge b into a, and handle nested dicts appropriately
      set value [lindex $args end]
      set path  [lrange $args 0 end-1]
    }
  }
  if {![dict exists $result {*}$path]} {
    dict set result {*}$path $value
    return $result
  }
  if {[string index [lindex $path end] end] ne "/"} {
    dict set result {*}$path $value
    return $result
  }
  ::dict for { k v } $value {
    # Element names that end in "/" are assumed to be branches
    if {[string index $k end] eq "/" && [::dict exists $result {*}$path $k]} {
      # key exists in a and b?  let's see if both values are dicts
      # both are dicts, so merge the dicts
      set dvalue [::dict get $result {*}$path $k]
      if { [is_dict $dvalue] && [is_dict $v] } {
        ::dict set result {*}$path $k [_dictmerge $dvalue $v]
      } else {
        ::dict set result {*}$path $k $v
      }
    } else {
      ::dict set result {*}$path $k $v
    }
  }
  return $result
}

proc ::clay::_dictmerge {a b} {
  ::set result $a
  # Merge b into a, and handle nested dicts appropriately
  ::dict for { k v } $b {
    if {[string index $k end] ne "/"} {
      # Element names that do not end in "/" are assumed to be literals
      # or dict trees we intend to replace wholly
      ::dict set result $k $v
    } elseif { [::dict exists $result $k] } {
      # key exists in a and b?  let's see if both values are dicts
      # both are dicts, so merge the dicts
      if { [is_dict [::dict get $result $k]] && [is_dict $v] } {
        ::dict set result $k [_dictmerge [::dict get $result $k] $v]
      } else {
        ::dict set result $k $v
      }
    } else {
      ::dict set result $k $v
    }
  }
  return $result
}

proc ::clay::dictputb {dict} {
  set result {}
  set level -1
  _dictputb 0 $level result $dict
  return $result
}

proc ::clay::_dictputb {leaf level varname dict} {
  upvar 1 $varname result
  incr level
  foreach {field value} $dict {
    if {[string index $field end] eq "/"} {
      putb result "[string repeat "  " $level]$field \{"
      _dictputb 0 $level result $value
      putb result "[string repeat "  " $level]\}"
    } else {
      putb result "[string repeat "  " $level][list $field $value]"
    }
  }
}

###
# topic: 4969d897a83d91a230a17f166dbcaede
###
proc ::clay::dynamic_arguments {ensemble method arglist args} {
  set idx 0
  set len [llength $args]
  if {$len > [llength $arglist]} {
    ###
    # Catch if the user supplies too many arguments
    ###
    set dargs 0
    if {[lindex $arglist end] ni {args dictargs}} {
      return -code error -level 2 "Usage: $ensemble $method [string trim [dynamic_wrongargs_message $arglist]]"
    }
  }
  foreach argdef $arglist {
    if {$argdef eq "args"} {
      ###
      # Perform args processing in the style of tcl
      ###
      uplevel 1 [list set args [lrange $args $idx end]]
      break
    }
    if {$argdef eq "dictargs"} {
      ###
      # Perform args processing in the style of tcl
      ###
      uplevel 1 [list set args [lrange $args $idx end]]
      ###
      # Perform args processing in the style of clay
      ###
      set dictargs [::clay::args_to_options {*}[lrange $args $idx end]]
      uplevel 1 [list set dictargs $dictargs]
      break
    }
    if {$idx > $len} {
      ###
      # Catch if the user supplies too few arguments
      ###
      if {[llength $argdef]==1} {
        return -code error -level 2 "Usage: $ensemble $method [string trim [dynamic_wrongargs_message $arglist]]"
      } else {
        uplevel 1 [list set [lindex $argdef 0] [lindex $argdef 1]]
      }
    } else {
      uplevel 1 [list set [lindex $argdef 0] [lindex $args $idx]]
    }
    incr idx
  }
}

###
# topic: 53ab28ac5c6ee601fe1fe07b073be88e
###
proc ::clay::dynamic_wrongargs_message {arglist} {
  set result ""
  set dargs 0
  foreach argdef $arglist {
    if {$argdef in {args dictargs}} {
      set dargs 1
      break
    }
    if {[llength $argdef]==1} {
      append result " $argdef"
    } else {
      append result " ?[lindex $argdef 0]?"
    }
  }
  if { $dargs } {
    append result " ?option value?..."
  }
  return $result
}

proc ::clay::is_dict { d } {
  # is it a dict, or can it be treated like one?
  if {[catch {::dict size $d} err]} {
    #::set ::errorInfo {}
    return 0
  }
  return 1
}

proc ::clay::is_null value {
  return [expr {$value in {{} NULL}}]
}

proc ::clay::leaf args {
  set marker [string index [lindex $args end] end]
  set result [path {*}${args}]
  if {$marker eq "/"} {
    return $result
  }
  return [list {*}[lrange $result 0 end-1] [string trim [string trim [lindex $result end]] /]]
}

proc ::clay::path args {
  set result {}
  foreach item $args {
    set item [string trim $item :./]
    foreach subitem [split $item /] {
      lappend result [string trim ${subitem}]/
    }
  }
  return $result
}

proc ::clay::script_path {} {
  set path [file dirname [file join [pwd] [info script]]]
  return $path
}

proc ::clay::NSNormalize qualname {
  if {![string match ::* $qualname]} {
    set qualname ::clay::classes::$qualname
  }
  regsub -all {::+} $qualname "::"
}

proc ::clay::uuid_generate args {
  return [uuid::uuid generate]
}

namespace eval ::clay {
  variable core_classes {::oo::class ::oo::object}
}

###
# END: procs.tcl
###
###
# START: class.tcl
###
oo::define oo::class {
  method clay {submethod args} {
    my variable clay
    if {![info exists clay]} {
      set clay {}
    }
    switch $submethod {
      ancestors {
        tailcall ::clay::ancestors [self]
      }
      exists {
        set path [::clay::leaf {*}$args]
        if {![info exists clay]} {
          return 0
        }
        return [dict exists $clay {*}$path]
      }
      dump {
        return $clay
      }
      getnull -
      get {
        if {[llength $args]==0} {
          return $clay
        }
        if {![dict exists $clay {*}$args]} {
          return {}
        }
        tailcall dict get $clay {*}$args
      }
      merge {
        foreach arg $args {
          ::clay::dictmerge clay {*}$arg
        }
      }
      search {
        foreach aclass [::clay::ancestors [self]] {
          if {[$aclass clay exists {*}$args]} {
            return [$aclass clay get {*}$args]
          }
        }
      }
      set {
        #puts [list [self] clay SET {*}$args]
        set value [lindex $args end]
        set path [::clay::leaf {*}[lrange $args 0 end-1]]
        ::clay::dictmerge clay {*}$path $value
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }
}

###
# END: class.tcl
###
###
# START: object.tcl
###
oo::define oo::object {

  ###
  # title: Provide access to clay data
  # format: markdown
  # description:
  # The *clay* method allows an object access
  # to a combination of its own clay data as
  # well as to that of its class
  ###
  method clay {submethod args} {
    my variable clay claycache clayorder
    if {![info exists clay]} {set clay {}}
    if {![info exists claycache]} {set claycache {}}
    if {![info exists clayorder] || [llength $clayorder]==0} {
      set clayorder [::clay::ancestors [info object class [self]] {*}[info object mixins [self]]]
    }
    switch $submethod {
      ancestors {
        return $clayorder
      }
      cget {
        # Leaf searches return one data field at a time
        # Search in our local dict
        if {[dict exists $clay {*}$args]} {
          return [dict get $clay {*}$args]
        }
        # Search in our local cache
        if {[dict exists $claycache {*}$args]} {
          return [dict get $claycache {*}$args]
        }
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          if {[$class clay exists {*}$args]} {
            set value [$class clay get {*}$args]
            dict set claycache {*}$args $value
            return $value
          }
          if {[$class clay exists const/ {*}$args]} {
            set value [$class clay get const/ {*}$args]
            dict set claycache {*}$args $value
            return $value
          }
          if {[llength $args]==1} {
            set field [lindex $args 0]
            if {[$class clay exists public/ option/ ${field}/ default]} {
              set value [$class clay get public/ option/ ${field}/ default]
              dict set claycache {*}$args $value
              return $value
            }
          }
        }
        return {}
      }
      delegate {
        if {![dict exists $clay delegate/ <class>]} {
          dict set clay delegate/ <class> [info object class [self]]
        }
        if {[llength $args]==0} {
          return [dict get $clay delegate/]
        }
        if {[llength $args]==1} {
          set stub <[string trim [lindex $args 0] <>]>
          if {![dict exists $clay delegate/ $stub]} {
            return {}
          }
          return [dict get $clay delegate/ $stub]
        }
        if {([llength $args] % 2)} {
          error "Usage: delegate
    OR
    delegate stub
    OR
    delegate stub OBJECT ?stub OBJECT? ..."
        }
        foreach {stub object} $args {
          set stub <[string trim $stub <>]>
          dict set clay delegate/ $stub $object
          oo::objdefine [self] forward ${stub} $object
          oo::objdefine [self] export ${stub}
        }
      }
      dump {
        # Do a full dump of clay data
        set result $clay
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          ::clay::dictmerge result [$class clay dump]
        }
        return $result
      }
      ensemble_map {
        set ensemble [lindex $args 0]
        my variable claycache
        set mensemble [string trim $ensemble :/]/
        if {[dict exists $claycache method_ensemble/ $mensemble]} {
          return [dict get $claycache method_ensemble/ $mensemble]
        }
        set emap [my clay get method_ensemble/ $mensemble]
        dict set claycache method_ensemble/ $mensemble $emap
        return $emap
      }
      eval {
        set script [lindex $args 0]
        set buffer {}
        set thisline {}
        foreach line [split $script \n] {
          append thisline $line
          if {![info complete $thisline]} {
            append thisline \n
            continue
          }
          set thisline [string trim $thisline]
          if {[string index $thisline 0] eq "#"} continue
          if {[string length $thisline]==0} continue
          if {[lindex $thisline 0] eq "my"} {
            # Line already calls out "my", accept verbatim
            append buffer $thisline \n
          } elseif {[string range $thisline 0 2] eq "::"} {
            # Fully qualified commands accepted verbatim
            append buffer $thisline \n
          } elseif {
            append buffer "my $thisline" \n
          }
          set thisline {}
        }
        eval $buffer
      }
      evolve {
        my Evolve
      }
      exists {
        # Leaf searches return one data field at a time
        # Search in our local dict
        if {[dict exists $clay {*}$args]} {
          return 1
        }
        # Search in our local cache
        if {[dict exists $claycache {*}$args]} {
          return 2
        }
        set count 2
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          incr count
          if {[$class clay exists {*}$args]} {
            return $count
          }
        }
        return 0
      }
      flush {
        set claycache {}
        set clayorder [::clay::ancestors [info object class [self]] {*}[info object mixins [self]]]
      }
      forward {
        oo::objdefine [self] forward {*}$args
      }
      getnull -
      get {
        set leaf [expr {[string index [lindex $args end] end] ne "/"}]
        #puts [list [self] clay get {*}$args (leaf: $leaf)]
        if {$leaf} {
          #puts [list EXISTS: (clay) [dict exists $clay {*}$args]]
          if {[dict exists $clay {*}$args]} {
            return [dict get $clay {*}$args]
          }
          # Search in our local cache
          #puts [list EXISTS: (claycache) [dict exists $claycache {*}$args]]
          if {[dict exists $claycache {*}$args]} {
            return [dict get $claycache {*}$args]
          }
          # Search in the in our list of classes for an answer
          foreach class $clayorder {
            if {[$class clay exists {*}$args]} {
              set value [$class clay get {*}$args]
              dict set claycache {*}$args $value
              return $value
            }
          }
        } else {
          set result {}
          # Leaf searches return one data field at a time
          # Search in our local dict
          if {[dict exists $clay {*}$args]} {
            set result [dict get $clay {*}$args]
          }
          # Search in the in our list of classes for an answer
          foreach class $clayorder {
            ::clay::dictmerge result [$class clay get {*}$args]
          }
          return $result
        }
      }
      leaf {
        # Leaf searches return one data field at a time
        # Search in our local dict
        if {[dict exists $clay {*}$args]} {
          return [dict get $clay {*}$args]
        }
        # Search in our local cache
        if {[dict exists $claycache {*}$args]} {
          return [dict get $claycache {*}$args]
        }
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          if {[$class clay exists {*}$args]} {
            set value [$class clay get {*}$args]
            dict set claycache {*}$args $value
            return $value
          }
        }
      }
      merge {
        foreach arg $args {
          ::clay::dictmerge clay {*}$arg
        }
      }
      mixin {
        ###
        # Mix in the class
        ###
        set prior  [info object mixins [self]]
        set newmixin {}
        foreach item $args {
          lappend newmixin ::[string trimleft $item :]
        }
        set newmap $args
        foreach class $prior {
          if {$class ni $newmixin} {
            set script [$class clay search mixin/ unmap-script]
            if {[string length $script]} {
              if {[catch $script err errdat]} {
                puts stderr "[self] MIXIN ERROR POPPING $class:\n[dict get $errdat -errorinfo]"
              }
            }
          }
        }
        ::oo::objdefine [self] mixin {*}$args
        ###
        # Build a compsite map of all ensembles defined by the object's current
        # class as well as all of the classes being mixed in
        ###
        my Evolve
        foreach class $newmixin {
          if {$class ni $prior} {
            set script [$class clay search mixin/ map-script]
            if {[string length $script]} {
              if {[catch $script err errdat]} {
                puts stderr "[self] MIXIN ERROR PUSHING $class:\n[dict get $errdat -errorinfo]"
              }
            }
          }
        }
        foreach class $newmixin {
          set script [$class clay search mixin/ react-script]
          if {[string length $script]} {
            if {[catch $script err errdat]} {
              puts stderr "[self] MIXIN ERROR PEEKING $class:\n[dict get $errdat -errorinfo]"
            }
            break
          }
        }
      }
      mixinmap {
        if {[llength $args]==0} {
          return [my clay get mixin/]
        } elseif {[llength $args]==1} {
          return [my clay get mixin/ [lindex $args 0]]
        } else {
          foreach {slot classes} $args {
            dict set clay mixin/ $slot $classes
          }
          set claycache {}
          set classlist {}
          foreach {item class} [my clay get mixin/] {
            if {$class ne {}} {
              lappend classlist $class
            }
          }
          my clay mixin {*}$classlist
        }
      }
      provenance {
        if {[dict exists $clay {*}$args]} {
          return self
        }
        foreach class $clayorder {
          if {[$class clay exists {*}$args]} {
            return $class
          }
        }
        return {}
      }
      replace {
        set clay [lindex $args 0]
      }
      source {
        source [lindex $args 0]
      }
      set {
        #puts [list [self] clay SET {*}$args]
        ::clay::dictmerge clay {*}$args
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }

  ###
  # React to a mixin
  ###
  method Evolve {} {}
}


###
# END: object.tcl
###
###
# START: metaclass.tcl
###
#-------------------------------------------------------------------------
# TITLE:
#    clay.tcl
#
# PROJECT:
#    clay: TclOO Helper Library
#
# DESCRIPTION:
#    clay(n): Implementation File
#
#-------------------------------------------------------------------------


proc ::clay::dynamic_methods class {
  foreach command [info commands [namespace current]::dynamic_methods_*] {
    $command $class
  }
}

proc ::clay::dynamic_methods_class {thisclass} {
  set methods {}
  foreach aclass [::clay::ancestors $thisclass] {
    set mdata  [$aclass clay get class_typemethod/]
    foreach {method info} $mdata {
      set method [string trimright $method :/-]
      if {$method in $methods} continue
      lappend methods $method
      set arglist [dict getnull $info arglist]
      set body    [dict getnull $info body]
      ::oo::objdefine $thisclass method $method $arglist $body
    }
  }
}

###
# New OO Keywords for clay
###
proc ::clay::define::Array {name {values {}}} {
  set class [current_class]
  set name [string trim $name :/]/
  if {![$class clay exists array/ $name]} {
    $class clay set public/ array/ $name {}
  }
  foreach {var val} $values {
    $class clay set public/ array/ $name $var $val
  }
}

###
# topic: 710a93168e4ba7a971d3dbb8a3e7bcbc
###
proc ::clay::define::component {name info} {
  set class [current_class]
  foreach {field value} $info {
    $class clay set component/ [string trim $name :/]/ $field $value
  }
}

###
# topic: 2cfc44a49f067124fda228458f77f177
# title: Specify the constructor for a class
###
proc ::clay::define::constructor {arglist rawbody} {
  set body {
my variable DestroyEvent
set DestroyEvent 0
::clay::object_create [self] [info object class [self]]
# Initialize public variables and options
my Ensembles_Rebuild
  }
  append body $rawbody
  set class [current_class]
  ::oo::define $class constructor $arglist $body
}

###
# topic: 7a5c7e04989704eef117ff3c9dd88823
# title: Specify the a method for the class object itself, instead of for objects of the class
###
proc ::clay::define::class_method {name arglist body} {
  set class [current_class]
  $class clay set class_typemethod/ [string trim $name :/] [dict create arglist $arglist body $body]
}

proc ::clay::define::clay {args} {
  set class [current_class]
  if {[lindex $args 0] in "cget set branchset"} {
    $class clay {*}$args
  } else {
    $class clay set {*}$args
  }
}

###
# topic: 4cb3696bf06d1e372107795de7fe1545
# title: Specify the destructor for a class
###
proc ::clay::define::destructor rawbody {
  set body {
# Run the destructor once and only once
set self [self]
my variable DestroyEvent
if {$DestroyEvent} return
set DestroyEvent 1
::clay::object_destroy $self
}
  append body $rawbody
  ::oo::define [current_class] destructor $body
}

proc ::clay::define::Dict {name {values {}}} {
  set class [current_class]
  set name [string trim $name :/]/
  if {![$class clay exists dict/ $name]} {
    $class clay set public/ dict/ $name {}
  }
  foreach {var val} $values {
    $class clay set public/ dict/ $name $var $val
  }
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
proc ::clay::define::Variable {name {default {}}} {
  set class [current_class]
  set name [string trimright $name :/]
  $class clay set public/ variable/ $name $default
  #::oo::define $class variable $name
}

proc ::clay::object_create {objname {class {}}} {
  if {$::clay::trace>0} {
    puts [list $objname CREATE]
  }
}

proc ::clay::object_rename {object newname} {
  if {$::clay::trace>0} {
    puts [list $object RENAME -> $newname]
  }
}

proc ::clay::object_destroy objname {
  if {$::clay::trace>0} {
    puts [list $objname DESTROY]
  }
  ::cron::object_destroy $objname
}


# clay::object
#
# This class is inherited by all classes that have options.
#
::clay::define ::clay::object {
  Variable clay {}
  Variable claycache {}
  Variable DestroyEvent 0

  method Evolve {} {
    my Ensembles_Rebuild
  }

  method Ensembles_Rebuild {} {
    my variable clayorder clay claycache
    set claycache {}
    set clayorder [::clay::ancestors [info object class [self]] {*}[info object mixins [self]]]
    if {[info exists clay]} {
      set emap [dict getnull $clay method_ensemble/]
    } else {
      set emap {}
    }
    if {$::clay::trace>2} {
      puts "Rebuilding Ensembles"
    }
    foreach class $clayorder {
      foreach {var value} [$class clay get public/ variable/] {
        set var [string trim $var :/]
        if { $var in {clay} } continue
        my variable $var
        if {![info exists $var]} {
          if {$::clay::trace>2} {puts [list initialize variable $var $value]}
          set $var $value
        }
      }
      foreach {var value} [$class clay get public/ dict/] {
        set var [string trim $var :/]
        my variable $var
        if {![info exists $var]} { set $var {} }
        foreach {f v} $value {
          if {![dict exists ${var} $f]} {
            if {$::clay::trace>2} {puts [list initialize dict $var $f $v]}
            dict set ${var} $f $v
          }
        }
      }
      foreach {var value} [$class clay get public/ array/] {
        set var [string trim $var :/]
        if { $var eq {clay} } continue
        my variable $var
        if {![info exists $var]} { array set $var {} }
        foreach {f v} $value {
          if {![array exists ${var}($f)]} {
            if {$::clay::trace>2} {puts [list initialize array $var\($f\) $v]}
            set ${var}($f) $v
          }
        }
      }
      ###
      # Build a compsite map of all ensembles defined by the object's current
      # class as well as all of the classes being mixed in
      ###
      foreach {mensemble einfo} [$class clay get method_ensemble/] {
        set ensemble [string trim $mensemble :/]
        if {$::clay::trace>2} {puts [list Defining $ensemble from $class]}

        foreach {method info} $einfo {
          dict set info source $class
          if {$::clay::trace>2} {puts [list Defining $ensemble -> $method from $class - $info]}
          dict set emap $ensemble $method $info
        }
      }
    }
    foreach {ensemble einfo} $emap {
      #if {[dict exists $einfo _body]} continue
      set body [::clay::ensemble_methodbody $ensemble $einfo]
      if {$::clay::trace>2} {
        set rawbody $body
        set body {puts [list [self] <object> [self method]]}
        append body \n $rawbody
      }
      oo::objdefine [self] method $ensemble {{method default} args} $body
    }
  }
}


###
# END: metaclass.tcl
###
###
# START: ensemble.tcl
###
::namespace eval ::clay::define {}

proc ::clay::ensemble_methodbody {ensemble einfo} {
  set default standard
  set preamble {}
  set eswitch {}
  if {[dict exists $einfo default]} {
    set emethodinfo [dict get $einfo default]
    set arglist     [dict getnull $emethodinfo arglist]
    set realbody    [dict get $emethodinfo body]
    if {[llength $arglist]==1 && [lindex $arglist 0] in {{} args arglist}} {
      set body {}
    } else {
      set body "\n      ::clay::dynamic_arguments $ensemble \$method [list $arglist] {*}\$args"
    }
    append body "\n      " [string trim $realbody] "      \n"
    set default $body
    dict unset einfo default
  }
  foreach {msubmethod esubmethodinfo} [lsort -dictionary -stride 2 $einfo] {
    set submethod [string trim $msubmethod :/-]
    if {$submethod eq "_body"} continue
    if {$submethod eq "_preamble"} {
      set preamble [dict getnull $esubmethodinfo body]
      continue
    }
    set arglist     [dict getnull $esubmethodinfo arglist]
    set realbody    [dict getnull $esubmethodinfo body]
    if {[string length [string trim $realbody]] eq {}} {
      dict set eswitch $submethod {}
    } else {
      if {[llength $arglist]==1 && [lindex $arglist 0] in {{} args arglist}} {
        set body {}
      } else {
        set body "\n      ::clay::dynamic_arguments $ensemble \$method [list $arglist] {*}\$args"
      }
      append body "\n      " [string trim $realbody] "      \n"
      if {$submethod eq "default"} {
        set default $body
      } else {
        dict set eswitch $submethod $body
      }
    }
  }
  set methodlist [lsort -dictionary [dict keys $eswitch]]
  if {![dict exists $eswitch <list>]} {
    dict set eswitch <list> {return $methodlist}
  }
  if {$default eq "standard"} {
    set default "error \"unknown method $ensemble \$method. Valid: \$methodlist\""
  }
  dict set eswitch default $default
  set mbody {}

  append mbody $preamble \n

  append mbody \n [list set methodlist $methodlist]
  append mbody \n "set code \[catch {switch -- \$method [list $eswitch]} result opts\]"
  append mbody \n {return -options $opts $result}
  return $mbody
}

::proc ::clay::define::Ensemble {rawmethod arglist body} {
  set class [current_class]
  if {$::clay::trace>2} {
    puts [list $class Ensemble $rawmethod $arglist $body]
  }
  set mlist [split $rawmethod "::"]
  set ensemble [string trim [lindex $mlist 0] :/]
  set mensemble ${ensemble}/
  if {[llength $mlist]==1 || [lindex $mlist 1] in "_body"} {
    set method _body
    ###
    # Simple method, needs no parsing, but we do need to record we have one
    ###
    $class clay set method_ensemble/ $mensemble _body [dict create arglist $arglist body $body]
    if {$::clay::trace>2} {
      puts [list $class clay set method_ensemble/ $mensemble _body ...]
    }
    set method $rawmethod
    if {$::clay::trace>2} {
      puts [list $class Ensemble $rawmethod $arglist $body]
      set rawbody $body
      set body {puts [list [self] $class [self method]]}
      append body \n $rawbody
    }
    ::oo::define $class method $rawmethod $arglist $body
    return
  }
  set method [join [lrange $mlist 2 end] "::"]
  $class clay set method_ensemble/ $mensemble [string trim $method :/] [dict create arglist $arglist body $body]
  if {$::clay::trace>2} {
    puts [list $class clay set method_ensemble/ $mensemble [string trim $method :/]  ...]
  }
}

###
# END: ensemble.tcl
###

namespace eval ::clay {
  namespace export *
}

