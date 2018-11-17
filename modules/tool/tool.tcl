###
# Amalgamated package for tool
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package provide tool 0.7.1
namespace eval ::tool {}

###
# START: dicttool.tcl
###
###
# This package enhances the stock dict implementation with some
# creature comforts
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

if {[::info commands ::tcl::dict::getnull] eq {}} {
  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
}
if {[::info commands ::tcl::dict::print] eq {}} {
  ###
  # Test if element is a dict
  ###
  proc ::tcl::dict::_putb {buffervar indent field value} {
    ::upvar 1 $buffervar buffer
    ::append buffer \n [::string repeat " " $indent] [::list $field] " "
    if {[string index $field end] eq "/"} {
      ::incr indent 2
      ::append buffer "\{"
      foreach item $value {
        if [catch {
        if {![is_dict $item]} {
          ::append buffer \n [::string repeat " " $indent] [list $item]
        } else {
          ::append buffer \n "[::string repeat " " $indent]\{"
          ::incr indent 2
          foreach {sf sv} $item {
            _putb buffer $indent $sf $sv
          }
          ::incr indent -2
          ::append buffer \n "[::string repeat " " $indent]\}"
        }
        } err] {
          puts [list FAILED $indent $field $item]
          puts $err
          puts "$::errorInfo"
        }
      }
      ::incr indent -2
      ::append buffer \n [::string repeat " " $indent] "\}"
    } elseif {[string index $field end] eq ":" || ![is_dict $value]} {
      ::append buffer [::list $value]
    } else {
      ::incr indent 2
      ::append buffer "\{"
      foreach {f v} $value {
        _putb buffer $indent $f $v
      }
      ::incr indent -2
      ::append buffer \n [::string repeat " " $indent] "\}"
    }
  }
  proc ::tcl::dict::print dict {
    ::set buffer {}
    ::foreach {field value} $dict {
      _putb buffer 0 $field $value
    }
    return $buffer
  }

  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] print ::tcl::dict::print]
}
if {[::info commands ::tcl::dict::is_dict] eq {}} {
  ###
  # Test if element is a dict
  ###
  proc ::tcl::dict::is_dict { d } {
    # is it a dict, or can it be treated like one?
    if {[catch {dict size $d} err]} {
      #::set ::errorInfo {}
      return 0
    }
    return 1
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] is_dict ::tcl::dict::is_dict]
}
if {[::info commands ::tcl::dict::rmerge] eq {}} {
  ###
  # title: A recursive form of dict merge
  # description:
  # A routine to recursively dig through dicts and merge
  # adapted from http://stevehavelka.com/tcl-dict-operation-nested-merge/
  ###
  proc ::tcl::dict::rmerge {a args} {
    ::set result $a
    # Merge b into a, and handle nested dicts appropriately
    ::foreach b $args {
      for { k v } $b {
        if {[string index $k end] eq ":"} {
          # Element names that end in ":" are assumed to be literals
          set result $k $v
        } elseif { [dict exists $result $k] } {
          # key exists in a and b?  let's see if both values are dicts
          # both are dicts, so merge the dicts
          if { [is_dict [get $result $k]] && [is_dict $v] } {
            set result $k [rmerge [get $result $k] $v]
          } else {
            set result $k $v
          }
        } else {
          set result $k $v
        }
      }
    }
    return $result
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] rmerge ::tcl::dict::rmerge]
}

if {[::info commands ::tcl::dict::isnull] eq {}} {
  proc ::tcl::dict::isnull {dictionary args} {
    if {![exists $dictionary {*}$args]} {return 1}
    return [expr {[get $dictionary {*}$args] in {{} NULL null}}]
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] isnull ::tcl::dict::isnull]
}

###
# END: dicttool.tcl
###
###
# START: dialect.tcl
###
###
# oodialect.tcl
#
# Copyright (c) 2015-2018 Sean Woods
# Copyright (c) 2015 Donald K Fellows
#
# BSD License
###
# @@ Meta Begin
# Package oo::dialect 0.3.4
# Meta platform     tcl
# Meta summary      A utility for defining a domain specific language for TclOO systems
# Meta description  This package allows developers to generate
# Meta description  domain specific languages to describe TclOO
# Meta description  classes and objects.
# Meta category     TclOO
# Meta subject      oodialect
# Meta require      {Tcl 8.6}
# Meta author       Sean Woods
# Meta author       Donald K. Fellows
# Meta license      BSD
# @@ Meta End
namespace eval ::oo::dialect {
  namespace export create
}

# A stack of class names
proc ::oo::dialect::Push {class} {
  ::variable class_stack
  lappend class_stack $class
}
proc ::oo::dialect::Peek {} {
  ::variable class_stack
  return [lindex $class_stack end]
}
proc ::oo::dialect::Pop {} {
  ::variable class_stack
  set class_stack [lrange $class_stack 0 end-1]
}

###
# This proc will generate a namespace, a "mother of all classes", and a
# rudimentary set of policies for this dialect.
###
proc ::oo::dialect::create {name {parent ""}} {
  set NSPACE [NSNormalize [uplevel 1 {namespace current}] $name]
  ::namespace eval $NSPACE {::namespace eval define {}}
  ###
  # Build the "define" namespace
  ###
  if {$parent eq ""} {
  	###
  	# With no "parent" language, begin with all of the keywords in
  	# oo::define
  	###
  	foreach command [info commands ::oo::define::*] {
	    set procname [namespace tail $command]
	    interp alias {} ${NSPACE}::define::$procname {} \
    		::oo::dialect::DefineThunk $procname
  	}
  	# Create an empty dynamic_methods proc
    proc ${NSPACE}::dynamic_methods {class} {}
    namespace eval $NSPACE {
      ::namespace export dynamic_methods
      ::namespace eval define {::namespace export *}
    }
    set ANCESTORS {}
  } else {
    ###
  	# If we have a parent language, that language already has the
  	# [oo::define] keywords as well as additional keywords and behaviors.
  	# We should begin with that
  	###
  	set pnspace [NSNormalize [uplevel 1 {namespace current}] $parent]
    apply [list parent {
  	  ::namespace export dynamic_methods
  	  ::namespace import -force ${parent}::dynamic_methods
  	} $NSPACE] $pnspace

    apply [list parent {
  	  ::namespace import -force ${parent}::define::*
  	  ::namespace export *
  	} ${NSPACE}::define] $pnspace
      set ANCESTORS [list ${pnspace}::object]
  }
  ###
  # Build our dialect template functions
  ###
  proc ${NSPACE}::define {oclass args} [string map [list %NSPACE% $NSPACE] {
	###
	# To facilitate library reloading, allow
	# a dialect to create a class from DEFINE
	###
  set class [::oo::dialect::NSNormalize [uplevel 1 {namespace current}] $oclass]
    if {[info commands $class] eq {}} {
	    %NSPACE%::class create $class {*}${args}
    } else {
	    ::oo::dialect::Define %NSPACE% $class {*}${args}
    }
}]
  interp alias {} ${NSPACE}::define::current_class {} \
    ::oo::dialect::Peek
  interp alias {} ${NSPACE}::define::aliases {} \
    ::oo::dialect::Aliases $NSPACE
  interp alias {} ${NSPACE}::define::superclass {} \
    ::oo::dialect::SuperClass $NSPACE

  if {[info command ${NSPACE}::class] ne {}} {
    ::rename ${NSPACE}::class {}
  }
  ###
  # Build the metaclass for our language
  ###
  ::oo::class create ${NSPACE}::class {
    superclass ::oo::dialect::MotherOfAllMetaClasses
  }
  # Wire up the create method to add in the extra argument we need; the
  # MotherOfAllMetaClasses will know what to do with it.
  ::oo::objdefine ${NSPACE}::class \
    method create {name {definitionScript ""}} \
      "next \$name [list ${NSPACE}::define] \$definitionScript"

  ###
  # Build the mother of all classes. Note that $ANCESTORS is already
  # guaranteed to be a list in canonical form.
  ###
  uplevel #0 [string map [list %NSPACE% [list $NSPACE] %name% [list $name] %ANCESTORS% $ANCESTORS] {
    %NSPACE%::class create %NSPACE%::object {
     superclass %ANCESTORS%
      # Put MOACish stuff in here
    }
  }]
  if { "${NSPACE}::class" ni $::oo::dialect::core_classes } {
    lappend ::oo::dialect::core_classes "${NSPACE}::class"
  }
  if { "${NSPACE}::object" ni $::oo::dialect::core_classes } {
    lappend ::oo::dialect::core_classes "${NSPACE}::object"
  }
}

# Support commands; not intended to be called directly.
proc ::oo::dialect::NSNormalize {namespace qualname} {
  if {![string match ::* $qualname]} {
    set qualname ${namespace}::$qualname
  }
  regsub -all {::+} $qualname "::"
}

proc ::oo::dialect::DefineThunk {target args} {
  tailcall ::oo::define [Peek] $target {*}$args
}

proc ::oo::dialect::Canonical {namespace NSpace class} {
  namespace upvar $namespace cname cname
  #if {[string match ::* $class]} {
  #  return $class
  #}
  if {[info exists cname($class)]} {
    return $cname($class)
  }
  if {[info exists ::oo::dialect::cname($class)]} {
    return $::oo::dialect::cname($class)
  }
  if {[info exists ::oo::dialect::cname(${NSpace}::${class})]} {
    return $::oo::dialect::cname(${NSpace}::${class})
  }
  foreach item [list "${NSpace}::$class" "::$class"] {
    if {[info commands $item] ne {}} {
      return $item
    }
  }
  return ${NSpace}::$class
}

###
# Implementation of the languages' define command
###
proc ::oo::dialect::Define {namespace class args} {
  Push $class
  try {
  	if {[llength $args]==1} {
      namespace eval ${namespace}::define [lindex $args 0]
    } else {
      ${namespace}::define::[lindex $args 0] {*}[lrange $args 1 end]
    }
  	${namespace}::dynamic_methods $class
  } finally {
    Pop
  }
}

###
# Implementation of how we specify the other names that this class will answer
# to
###

proc ::oo::dialect::Aliases {namespace args} {
  set class [Peek]
  namespace upvar $namespace cname cname
  set NSpace [join [lrange [split $class ::] 1 end-2] ::]
  set cname($class) $class
  foreach name $args {
    set cname($name) $class
    #set alias $name
    set alias [NSNormalize $NSpace $name]
    # Add a local metaclass reference
    if {![info exists ::oo::dialect::cname($alias)]} {
      lappend ::oo::dialect::aliases($class) $alias
      ##
      # Add a global reference, first come, first served
      ##
      set ::oo::dialect::cname($alias) $class
    }
  }
}

###
# Implementation of a superclass keyword which will enforce the inheritance of
# our language's mother of all classes
###

proc ::oo::dialect::SuperClass {namespace args} {
  set class [Peek]
  namespace upvar $namespace class_info class_info
  dict set class_info($class) superclass 1
  set ::oo::dialect::cname($class) $class
  set NSpace [join [lrange [split $class ::] 1 end-2] ::]
  set unique {}
  foreach item $args {
    set Item [Canonical $namespace $NSpace $item]
    dict set unique $Item $item
  }
  set root ${namespace}::object
  if {$class ne $root} {
    dict set unique $root $root
  }
  tailcall ::oo::define $class superclass {*}[dict keys $unique]
}

###
# Implementation of the common portions of the the metaclass for our
# languages.
###

if {[info commands ::oo::dialect::MotherOfAllMetaClasses] eq {}} {
  ::oo::class create ::oo::dialect::MotherOfAllMetaClasses {
    superclass ::oo::class
    constructor {define definitionScript} {
      $define [self] {
        superclass
      }
      $define [self] $definitionScript
    }
    method aliases {} {
      if {[info exists ::oo::dialect::aliases([self])]} {
        return $::oo::dialect::aliases([self])
      }
    }
  }
}

namespace eval ::oo::dialect {
  variable core_classes {::oo::class ::oo::object}
}

###
# END: dialect.tcl
###
###
# START: oometa.tcl
###

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
      set path [lrange $args 0 end-1]
      set field [string trimright [lindex $args end] :]
      foreach mclass [lreverse [::oo::meta::ancestors $class]] {
        if {![::info exists ::oo::meta::local_property($mclass)]} continue
        set class_metadata $::oo::meta::local_property($mclass)
        if {[dict exists $class_metadata const {*}$path $field:]} {
          return [dict get $class_metadata const {*}$path $field:]
        }
        if {[dict exists $class_metadata const {*}$path $field]} {
          return [dict get $class_metadata const {*}$path $field]
        }
        if {[dict exists $class_metadata {*}$path $field:]} {
          return [dict get $class_metadata {*}$path $field:]
        }
        if {[dict exists $class_metadata {*}$path $field]} {
          return [dict get $class_metadata {*}$path $field]
        }
      }
      return {}
    }
    rebuild {
      ::oo::meta::rebuild $class
    }
    is {
      set info [metadata $class]
      return [string is [lindex $args 0] -strict [dict getnull $info {*}[lrange $args 1 end]]]
    }
    for -
    map {
      set info [metadata $class]
      uplevel 1 [list ::dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]
    }
    with {
      upvar 1 TEMPVAR info
      set info [metadata $class]
      return [uplevel 1 [list ::dict with TEMPVAR {*}$args]]
    }
    branchget {
      set info [metadata $class]
      set result {}
      foreach {field value} [dict getnull $info {*}$args] {
        dict set result [string trimright $field :] $value
      }
      return $result
    }
    branchset {
      ::oo::meta::rebuild $class
      foreach {field value} [lindex $args end] {
        ::dict set ::oo::meta::local_property($class) {*}[lrange $args 0 end-1] [string trimright $field :]: $value
      }
    }
    leaf_add {
      if {[::info exists ::oo::meta::local_property($class)]} {
        set result [dict getnull $::oo::meta::local_property($class) {*}[lindex $args 0]]
      }
      ladd result {*}[lrange $args 1 end]
      dict set ::oo::meta::local_property($class) {*}[lindex $args 0] $result
    }
    leaf_remove {
      if {![::info exists ::oo::meta::local_property($class)]} return
      set result {}
      forearch element [dict getnull $::oo::meta::local_property($class) {*}[lindex $args 0]] {
        if { $element in [lrange $args 1 end]} continue
        lappend result $element
      }
      dict set ::oo::meta::local_property($class) {*}[lindex $args 0] $result
    }
    append -
    incr -
    lappend -
    set -
    unset -
    update {
      ::oo::meta::rebuild $class
      ::dict $submethod ::oo::meta::local_property($class) {*}$args
    }
    merge {
      ::oo::meta::rebuild $class
      set ::oo::meta::local_property($class) [dict rmerge $::oo::meta::local_property($class) {*}$args]
    }
    dump {
      set info [metadata $class]
      return $info
    }
    default {
      set info [metadata $class]
      return [::dict $submethod $info {*}$args]
    }
  }
}

proc ::oo::meta::localdata {class args} {
  if {![::info exists ::oo::meta::local_property($class)]} {
    return {}
  }
  if {[::llength $args]==0} {
    return $::oo::meta::local_property($class)
  }
  return [::dict getnull $::oo::meta::local_property($class) {*}$args]
}

proc ::oo::meta::normalize class {
  set class ::[string trimleft $class :]
}

proc ::oo::meta::metadata {class {force 0}} {
  set class [::oo::meta::normalize $class]
  ###
  # Destroy the cache of all derivitive classes
  ###
  if {$force} {
    unset -nocomplain ::oo::meta::cached_property
    unset -nocomplain ::oo::meta::cached_hierarchy
  } else {
    variable dirty_classes
    foreach dclass $dirty_classes {
      foreach {cclass cancestors} [array get ::oo::meta::cached_hierarchy] {
        if {$dclass in $cancestors} {
          unset -nocomplain ::oo::meta::cached_property($cclass)
          unset -nocomplain ::oo::meta::cached_hierarchy($cclass)
        }
      }
      if {![::info exists ::oo::meta::local_property($dclass)]} continue
      if {[dict getnull $::oo::meta::local_property($dclass) classinfo type:] eq "core"} {
        if {$dclass ni $::oo::dialect::core_classes} {
          lappend ::oo::dialect::core_classes $dclass
        }
      }
    }
    set dirty_classes {}
  }

  ###
  # If the cache is available, use it
  ###
  variable cached_property
  if {[::info exists cached_property($class)]} {
    return $cached_property($class)
  }
  ###
  # Build a cache of the hierarchy and the
  # aggregate metadata for this class and store
  # them for future use
  ###
  variable cached_hierarchy
  set metadata {}
  set stack {}
  variable local_property
  set cached_hierarchy($class) [::oo::meta::ancestors $class]
  foreach class $cached_hierarchy($class) {
    if {[::info exists local_property($class)]} {
      lappend metadata $local_property($class)
    }
  }
  #foreach aclass [lreverse [::info class superclasses $class]] {
  #  lappend metadata [::oo::meta::metadata $aclass]
  #}

  lappend metadata {classinfo {type: {}}}
  if {[::info exists local_property($class)]} {
    lappend metadata $local_property($class)
  }
  set metadata [dict rmerge {*}$metadata]
  set cached_property($class) $metadata
  return $metadata
}

proc ::oo::meta::rebuild args {
  foreach class $args {
    if {$class ni $::oo::meta::dirty_classes} {
      lappend ::oo::meta::dirty_classes $class
    }
  }
}

proc ::oo::meta::search args {
  variable local_property

  set path [lrange $args 0 end-1]
  set value [lindex $args end]

  set result {}
  foreach {class info} [array get local_property] {
    if {[dict exists $info {*}$path:]} {
      if {[string match [dict get $info {*}$path:] $value]} {
        lappend result $class
      }
      continue
    }
    if {[dict exists $info {*}$path]} {
      if {[string match [dict get $info {*}$path] $value]} {
        lappend result $class
      }
    }
  }
  return $result
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
    tailcall ::oo::meta::info [self] $submethod {*}$args
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
    my variable meta MetaMixin
    if {![info exists MetaMixin]} {
      set MetaMixin {}
    }
    set class [::info object class [self object]]
    set classlist [list $class {*}$MetaMixin]
    switch $submethod {
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
        set path [lrange $args 0 end-1]
        set field [string trim [lindex $args end] :]
        if {[dict exists $meta {*}$path $field:]} {
          return [dict get $meta {*}$path $field:]
        }
        if {[dict exists $meta {*}$path $field]} {
          return [dict get $meta {*}$path $field]
        }
        foreach mclass [lreverse $classlist] {
          set class_metadata [::oo::meta::metadata $mclass]
          if {[dict exists $class_metadata const {*}$path $field:]} {
            return [dict get $class_metadata const {*}$path $field:]
          }
          if {[dict exists $class_metadata const {*}$path $field]} {
            return [dict get $class_metadata const {*}$path $field]
          }
          if {[dict exists $class_metadata {*}$path $field:]} {
            return [dict get $class_metadata {*}$path $field:]
          }
          if {[dict exists $class_metadata {*}$path $field]} {
            return [dict get $class_metadata {*}$path $field]
          }
        }
        return {}
      }
      is {
        set value [my meta cget {*}[lrange $args 1 end]]
        return [string is [lindex $args 0] -strict $value]
      }
      for -
      map {
        foreach mclass $classlist {
          lappend mdata [::oo::meta::metadata $mclass]
        }
        set info [dict rmerge {*}$mdata $meta]
        uplevel 1 [list ::dict $submethod [lindex $args 0] [dict get $info {*}[lrange $args 1 end-1]] [lindex $args end]]
      }
      with {
        upvar 1 TEMPVAR info
        foreach mclass $classlist {
          lappend mdata [::oo::meta::metadata $mclass]
        }
        set info [dict rmerge {*}$mdata $meta]
        return [uplevel 1 [list dict with TEMPVAR {*}$args]]
      }
      dump {
        foreach mclass $classlist {
          lappend mdata [::oo::meta::metadata $mclass]
        }
        return [dict rmerge {*}$mdata $meta]
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        return [dict $submethod meta {*}$args]
      }
      branchset {
        foreach {field value} [lindex $args end] {
          dict set meta {*}[lrange $args 0 end-1] [string trimright $field :]: $value
        }
      }
      rmerge -
      merge {
        set meta [dict rmerge $meta {*}$args]
        return $meta
      }
      exists {
        foreach mclass $classlist {
          if {[dict exists [::oo::meta::metadata $mclass] {*}$args]} {
            return 1
          }
        }
        if {[dict exists $meta {*}$args]} {
          return 1
        }
        return 0
      }
      get -
      getnull {
        if {[string index [lindex $args end] end]==":"} {
          # Looking for a leaf node
          if {[dict exists $meta {*}$args]} {
            return [dict get $meta {*}$args]
          }
          foreach mclass [lreverse $classlist] {
            set mdata [::oo::meta::metadata $mclass]
            if {[dict exists $mdata {*}$args]} {
              return [dict get $mdata {*}$args]
            }
          }
          if {$submethod == "get"} {
            error "key \"$args\" not known in metadata"
          }
          return {}
        }
        # Looking for a branch node
        # So we need to composite the result
        set found 0
        foreach mclass $classlist {
          set mdata [::oo::meta::metadata $mclass]
          if {[dict exists $mdata {*}$args]} {
            set found 1
            lappend result [dict get $mdata {*}$args]
          }
        }
        if {[dict exists $meta {*}$args]} {
          set found 1
          lappend result [dict get $meta {*}$args]
        }
        if {!$found} {
          if {$submethod == "get"} {
            error "key \"$args\" not known in metadata"
          }
          return {}
        }
        return [dict rmerge {*}$result]
      }
      branchget {
        set result {}
        foreach mclass [lreverse $classlist] {
          foreach {field value} [dict getnull [::oo::meta::metadata $mclass] {*}$args] {
            dict set result [string trimright $field :] $value
          }
        }
        foreach {field value} [dict getnull $meta {*}$args] {
          dict set result [string trimright $field :] $value
        }
        return $result
      }
      mixin {
        foreach mclass $args {
          set mclass [::oo::meta::normalize $mclass]
          if {$mclass ni $MetaMixin} {
            lappend MetaMixin $mclass
          }
        }
      }
      mixout {
        foreach mclass $args {
          set mclass [::oo::meta::normalize $mclass]
          while {[set i [lsearch $MetaMixin $mclass]]>=0} {
            set MetaMixin [lreplace $MetaMixin $i $i]
          }
        }
      }
      default {
        foreach mclass $classlist {
          lappend mdata [::oo::meta::metadata $mclass]
        }
        set info [dict rmerge {*}$mdata $meta]
        return [dict $submethod $info {*}$args]
      }
    }
  }
}

###
# END: oometa.tcl
###
###
# START: cron.tcl
###
###
# This file implements a process table
# Instead of having individual components try to maintain their own timers
# we centrally manage how often tasks should be kicked off here.
###
#
# Author: Sean Woods (for T&E Solutions)

::namespace eval ::cron {}

proc ::cron::task {command args} {
  if {$::cron::trace > 1} {
    puts [list ::cron::task $command $args]
  }
  variable processTable
  switch $command {
    TEMPLATE {
      return [list object {} lastevent 0 lastrun 0 err 0 result {} \
        running 0 coroutine {} scheduled 0 frequency 0 command {}]
    }
    delete {
      unset -nocomplain ::cron::processTable([lindex $args 0])
    }
    exists {
      return [::info exists ::cron::processTable([lindex $args 0])]
    }
    info {
      set process [lindex $args 0]
      if {![::info exists ::cron::processTable($process)]} {
        error "Process $process does not exist"
      }
      return $::cron::processTable($process)
    }
    frequency {
      set process [lindex $args 0]
      set time [lindex $args 1]
      if {![info exists ::cron::processTable($process)]} return
      dict with ::cron::processTable($process) {
        set now [clock_step [current_time]]
        set frequency [expr {0+$time}]
        if {$scheduled>($now+$time)} {
          dict set ::cron::processTable($process) scheduled [expr {$now+$time}]
        }
      }
    }
    sleep {
      set process [lindex $args 0]
      set time [lindex $args 1]
      if {![info exists ::cron::processTable($process)]} return
      dict with ::cron::processTable($process) {
        set now [clock_step [current_time]]
        set frequency 0
        set scheduled [expr {$now+$time}]
      }
    }
    create -
    set {
      set process [lindex $args 0]
      if {![::info exists ::cron::processTable($process)]} {
        set ::cron::processTable($process) [task TEMPLATE]
      }
      if {[llength $args]==2} {
        foreach {field value} [lindex $args 1] {
          dict set ::cron::processTable($process) $field $value
        }
      } else {
        foreach {field value} [lrange $args 1 end] {
          dict set ::cron::processTable($process) $field $value
        }
      }
    }
  }
}

proc ::cron::at args {
  if {$::cron::trace > 1} {
    puts [list ::cron::at $args]
  }
  switch [llength $args] {
    2 {
      variable processuid
      set process event#[incr processuid]
      lassign $args timecode command
    }
    3 {
      lassign $args process timecode command
    }
    default {
      error "Usage: ?process? timecode command"
    }
  }
  variable processTable
  if {[string is integer -strict $timecode]} {
    set scheduled [expr {$timecode*1000}]
  } else {
    set scheduled [expr {[clock scan $timecode]*1000}]
  }
  ::cron::task set $process \
    frequency -1 \
    command $command \
    scheduled $scheduled \
    coroutine {}

  if {$::cron::trace > 1} {
    puts [list ::cron::task info $process - > [::cron::task info $process]]
  }
  ::cron::wake NEW
  return $process
}

proc ::cron::idle args {
  if {$::cron::trace > 1} {
    puts [list ::cron::idle $args]
  }
  switch [llength $args] {
    2 {
      variable processuid
      set process event#[incr processuid]
      lassign $args command
    }
    3 {
      lassign $args process command
    }
    default {
      error "Usage: ?process? timecode command"
    }
  }
  ::cron::task set $process \
    scheduled 0 \
    frequency 0 \
    command $command
  ::cron::wake NEW
  return $process
}

proc ::cron::in args {
  if {$::cron::trace > 1} {
    puts [list ::cron::in $args]
  }
  switch [llength $args] {
    2 {
      variable processuid
      set process event#[incr processuid]
      lassign $args timecode command
    }
    3 {
      lassign $args process timecode command
    }
    default {
      error "Usage: ?process? timecode command"
    }
  }
  set now [clock_step [current_time]]
  set scheduled [expr {$timecode*1000+$now}]
  ::cron::task set $process \
    frequency -1 \
    command $command \
    scheduled $scheduled
  ::cron::wake NEW
  return $process
}

proc ::cron::cancel {process} {
  if {$::cron::trace > 1} {
    puts [list ::cron::cancel $process]
  }
  ::cron::task delete $process
}

###
# topic: 0776dccd7e84530fa6412e507c02487c
###
proc ::cron::every {process frequency command} {
  if {$::cron::trace > 1} {
    puts [list ::cron::every $process $frequency $command]
  }
  variable processTable
  set mnow [clock_step [current_time]]
  set frequency [expr {$frequency*1000}]
  ::cron::task set $process \
    frequency $frequency \
    command $command \
    scheduled [expr {$mnow + $frequency}]
  ::cron::wake NEW
}


proc ::cron::object_coroutine {objname coroutine {info {}}} {
  if {$::cron::trace > 1} {
    puts [list ::cron::object_coroutine $objname $coroutine $info]
  }
  task set $coroutine \
    {*}$info \
    object $objname \
    coroutine $coroutine

  return $coroutine
}

# Notification that an object has been destroyed, and that
# it should give up any toys associated with events
proc ::cron::object_destroy {objname} {
  if {$::cron::trace > 1} {
    puts [list ::cron::object_destroy $objname]
  }
  variable processTable
  set dat [array get processTable]
  foreach {process info} $dat {
    if {[dict exists $info object] && [dict get $info object] eq $objname} {
      unset -nocomplain processTable($process)
    }
  }
}

###
# topic: 97015814408714af539f35856f85bce6
###
proc ::cron::run process {
  variable processTable
  set mnow [clock_step [current_time]]
  if {[dict exists processTable($process) scheduled] && [dict exists processTable($process) scheduled]>0} {
    dict set processTable($process) scheduled [expr {$mnow-1000}]
  } else {
    dict set processTable($process) lastrun 0
  }
  ::cron::wake PROCESS
}

proc ::cron::clock_step timecode {
  return [expr {$timecode-($timecode%1000)}]
}

proc ::cron::clock_delay {delay} {
  set now [current_time]
  set then [clock_step [expr {$delay+$now}]]
  return [expr {$then-$now}]
}

# Sleep for X seconds, wake up at the top
proc ::cron::clock_sleep {{sec 1} {offset 0}} {
  set now [current_time]
  set delay [expr {[clock_delay [expr {$sec*1000}]]+$offset}]
  sleep $delay
}

proc ::cron::current_time {} {
  if {$::cron::time < 0} {
    return [clock milliseconds]
  }
  return $::cron::time
}

proc ::cron::clock_set newtime {
  variable time
  for {} {$time < $newtime} {incr time 100} {
    uplevel #0 {::cron::do_one_event CLOCK_ADVANCE}
  }
  set time $newtime
  uplevel #0 {::cron::do_one_event CLOCK_ADVANCE}
}

proc ::cron::once_in_a_while body {
  set script {set _eventid_ $::cron::current_event}
  append script $body
  # Add a safety to allow this while to only execute once per call
  append script {if {$_eventid_==$::cron::current_event} yield}
  uplevel 1 [list while 1 $script]
}

proc ::cron::sleep ms {
  if {$::cron::trace > 1} {
    puts [list ::cron::sleep $ms [info coroutine]]
  }

  set coro [info coroutine]
  # When the clock is being externally
  # controlled, advance the clock when
  # a sleep is called
  variable time
  if {$time >= 0 && $coro eq {}} {
    ::cron::clock_set [expr {$time+$ms}]
    return
  }
  if {$coro ne {}} {
    set mnow [current_time]
    set start $mnow
    set end [expr {$start+$ms}]
    set eventid $coro
    if {$::cron::trace} {
      puts "::cron::sleep $ms $coro"
    }
    # Mark as running
    task set $eventid scheduled $end coroutine $coro running 1
    ::cron::wake WAKE_IN_CORO
    yield 2
    while {$end >= $mnow} {
      if {$::cron::trace} {
        puts "::cron::sleep $ms $coro (loop)"
      }
      set mnow [current_time]
      yield 2
    }
    # Mark as not running to resume idle computation
    task set $eventid running 0
    if {$::cron::trace} {
      puts "/::cron::sleep $ms $coro"
    }
  } else {
    set eventid [incr ::cron::eventcount]
    set var ::cron::event_#$eventid
    set $var 0
    if {$::cron::trace} {
      puts "::cron::sleep $ms $eventid waiting for $var"
      ::after $ms "set $var 1 ; puts \"::cron::sleep - $eventid - FIRED\""
    } else {
      ::after $ms "set $var 1"
    }
    ::vwait $var
    if {$::cron::trace} {
      puts "/::cron::sleep $ms $eventid"
    }
    unset $var
  }
}

###
# topic: 21de7bb8db019f3a2fd5a6ae9b38fd55
# description:
#    Called once per second, and timed to ensure
#    we run in roughly realtime
###
proc ::cron::runTasksCoro {} {
  ###
  # Do this forever
  ###
  variable processTable
  variable processing
  variable all_coroutines
  variable coroutine_object
  variable coroutine_busy
  variable nextevent
  variable current_event

  while 1 {
    incr current_event
    set lastevent 0
    set now [current_time]
    # Wake me up in 5 minute intervals, just out of principle
    set nextevent [expr {$now-($now % 300000) + 300000}]
    set next_idle_event [expr {$now+250}]
    if {$::cron::trace > 1} {
      puts [list CRON TASK RUNNER nextevent $nextevent]
    }
    ###
    # Determine what tasks to run this timestep
    ###
    set tasks {}
    set cancellist {}
    set nexttask {}

    foreach {process} [lsort -dictionary [array names processTable]] {
      dict with processTable($process) {
        if {$::cron::trace > 1} {
          puts [list CRON TASK RUNNER process $process frequency: $frequency scheduled: $scheduled]
        }
        if {$scheduled==0 && $frequency==0} {
          set lastrun $now
          set lastevent $now
          lappend tasks $process
        } else {
          if { $scheduled <= $now } {
            lappend tasks $process
            if { $frequency < 0 } {
              lappend cancellist $process
            } elseif {$frequency==0} {
              set scheduled 0
              if {$::cron::trace > 1} {
                puts [list CRON TASK RUNNER process $process demoted to idle]
              }
            } else {
              set scheduled [clock_step [expr {$frequency+$lastrun}]]
              if { $scheduled <= $now } {
                set scheduled [clock_step [expr {$frequency+$now}]]
              }
              if {$::cron::trace > 1} {
                puts [list CRON TASK RUNNER process $process rescheduled to $scheduled]
              }
            }
            set lastrun $now
          }
          set lastevent $now
        }
      }
    }
    foreach task $tasks {
      dict set processTable($task) lastrun $now
      if {[dict exists processTable($task) foreground] && [dict set processTable($task) foreground]} continue
      if {[dict exists processTable($task) running] && [dict set processTable($task) running]} continue
      if {$::cron::trace > 2} {
        puts [list RUNNING $task [task info $task]]
      }
      if {[dict exists $processTable($task) coroutine]} {
        set coro [dict get $processTable($task) coroutine]
      } else {
        set coro {}
      }
      dict set processTable($task) running 1
      if {[dict exists $processTable($task) command]} {
        set command [dict get $processTable($task) command]
      } else {
        set command {}
      }
      if {$command eq {} && $coro eq {}} {
        # Task has nothing to do. Slot it for destruction
        lappend cancellist $task
      } elseif {$coro ne {}} {
        if {[info command $coro] eq {}} {
          set object [dict get $processTable($task) object]
          # Trigger coroutine again if a command was given
          # If this coroutine is associated with an object, ensure
          # the object still exists before invoking its method
          if {$command eq {} || ($object ne {} && [info command $object] eq {})} {
            lappend cancellist $task
            dict set processTable($task) running 0
            continue
          }
          if {$::cron::trace} {
            puts [list RESTARTING $task - coroutine $coro - with $command]
          }
          ::coroutine $coro {*}$command
        }
        try $coro on return {} {
          # Terminate the coroutine
          lappend cancellist $task
        } on break {} {
          # Terminate the coroutine
          lappend cancellist $task
        } on error {errtxt errdat} {
          # Coroutine encountered an error
          lappend cancellist $task
          puts "ERROR $coro"
          set errorinfo [dict get $errdat -errorinfo]
          if {[info exists coroutine_object($coro)] && $coroutine_object($coro) ne {}} {
            catch {
            puts "OBJECT: $coroutine_object($coro)"
            puts "CLASS: [info object class $coroutine_object($coro)]"
            }
          }
          puts "$errtxt"
          puts ***
          puts $errorinfo
        } on continue {result opts} {
          # Ignore continue
          if { $result eq "done" } {
            lappend cancellist $task
          }
        } on ok {result opts} {
          if { $result eq "done" } {
            lappend cancellist $task
          }
        }
      } else {
        dict with processTable($task) {
          set err [catch {uplevel #0 $command} result errdat]
          if $err {
            puts "CRON TASK FAILURE:"
            puts "PROCESS: $task"
            puts $result
            puts ***
            puts [dict get $errdat -errorinfo]
          }
        }
        yield 0
      }
      dict set processTable($task) running 0
    }
    foreach {task} $cancellist {
      unset -nocomplain processTable($task)
    }
    foreach {process} [lsort -dictionary [array names processTable]] {
      set scheduled 0
      set frequency 0
      dict with processTable($process) {
        if {$scheduled==0 && $frequency==0} {
          if {$next_idle_event < $nextevent} {
            set nexttask $task
            set nextevent $next_idle_event
          }
        } elseif {$scheduled < $nextevent} {
          set nexttask $process
          set nextevent $scheduled
        }
        set lastevent $now
      }
    }
    foreach {eventid msec} [array get ::cron::coro_sleep] {
      if {$msec < 0} continue
      if {$msec<$nextevent} {
        set nexttask "CORO $eventid"
        set nextevent $scheduled
      }
    }
    set delay [expr {$nextevent-$now}]
    if {$delay <= 0} {
      yield 0
    } else {
      if {$::cron::trace > 1} {
        puts "NEXT EVENT $delay - NEXT TASK $nexttask"
      }
      yield $delay
    }
  }
}

proc ::cron::wake {{who ???}} {
  ##
  # Only triggered by cron jobs kicking off other cron jobs within
  # the script body
  ##
  if {$::cron::trace} {
    puts "::cron::wake $who"
  }
  if {$::cron::busy} {
    return
  }
  after cancel $::cron::next_event
  set ::cron::next_event [after idle [list ::cron::do_one_event $who]]
}

proc ::cron::do_one_event {{who ???}} {
  if {$::cron::trace} {
    puts "::cron::do_one_event $who"
  }
  after cancel $::cron::next_event
  set now [current_time]
  set ::cron::busy 1
  while {$::cron::busy} {
    if {[info command ::cron::COROUTINE] eq {}} {
      ::coroutine ::cron::COROUTINE ::cron::runTasksCoro
    }
    set cron_delay [::cron::COROUTINE]
    if {$cron_delay==0} {
      if {[incr loops]>10} {
        if {$::cron::trace} {
          puts "Breaking out of 10 recursive loops"
        }
        set ::cron::wake_time 1000
        break
      }
      set ::cron::wake_time 0
      incr ::cron::loops(active)
    } else {
      set ::cron::busy 0
      incr ::cron::loops(idle)
    }
  }
  ###
  # Try to get the event to fire off on the border of the
  # nearest second
  ###
  if {$cron_delay < 10} {
    set cron_delay 250
  }
  set ctime [current_time]
  set next [expr {$ctime+$cron_delay}]
  set ::cron::wake_time [expr {$next/1000}]
  if {$::cron::trace} {
    puts [list EVENT LOOP WILL WAKE IN $cron_delay ms next: [clock format $::cron::wake_time -format "%H:%M:%S"] active: $::cron::loops(active) idle: $::cron::loops(idle) woken_by: $who]
  }
  set ::cron::next_event [after $cron_delay {::cron::do_one_event TIMER}]
}


proc ::cron::main {} {
  # Never launch from a coroutine
  if {[info coroutine] ne {}} {
    return
  }
  set ::cron::forever 1
  while {$::cron::forever} {
    ::after 120000 {set ::cron::forever 1}
    # Call an update just to give the rest of the event loop a chance
    incr ::cron::loops(main)
    ::after cancel $::cron::next_event
    set ::cron::next_event [::after idle {::cron::wake MAIN}]
    set ::cron::forever 1
    set ::cron::busy 0
    ::vwait ::cron::forever
    if {$::cron::trace} {
      puts "MAIN LOOP CYCLE $::cron::loops(main)"
    }
  }
}

###
# topic: 4a891d0caabc6e25fbec9514ea8104dd
# description:
#    This file implements a process table
#    Instead of having individual components try to maintain their own timers
#    we centrally manage how often tasks should be kicked off here.
###
namespace eval ::cron {
  variable lastcall 0
  variable processTable
  variable busy 0
  variable next_event {}
  variable trace 0
  variable current_event
  variable time -1
  if {![info exists current_event]} {
    set current_event 0
  }
  if {![info exists ::cron::loops]} {
    array set ::cron::loops {
      active 0
      main 0
      idle 0
      wake 0
    }
  }
}

::cron::wake STARTUP


###
# END: cron.tcl
###
###
# START: core.tcl
###
package require Tcl 8.6 ;# try in pipeline.tcl. Possibly other things.
package require coroutine
package require TclOO
package require sha1
#package require cron 2.0
#package require oo::dialect

::oo::dialect::create ::tool
::namespace eval ::tool {}
set ::tool::trace 0

proc ::tool::script_path {} {
  set path [file dirname [file join [pwd] [info script]]]
  return $path
}

proc ::tool::module {cmd args} {
  ::variable moduleStack
  ::variable module

  switch $cmd {
    push {
      set module [lindex $args 0]
      lappend moduleStack $module
      return $module
    }
    pop {
      set priormodule      [lindex $moduleStack end]
      set moduleStack [lrange $moduleStack 0 end-1]
      set module [lindex $moduleStack end]
      return $priormodule
    }
    peek {
      set module      [lindex $moduleStack end]
      return $module
    }
    default {
      error "Invalid command \"$cmd\". Valid: peek, pop, push"
    }
  }
}
::tool::module push core

proc ::tool::pathload {path {order {}} {skip {}}} {
  ###
  # On windows while running under a VFS, the system sometimes
  # gets confused about the volume we are running under
  ###
  if {$::tcl_platform(platform) eq "windows"} {
    if {[string range $path 1 6] eq ":/zvfs"} {
      set path [string range $path 2 end]
    }
  }
  set loaded {pkgIndex.tcl index.tcl}
  foreach item $skip {
    lappend loaded [file tail $skip]
  }
  if {[file exists [file join $path metaclass.tcl]]} {
    lappend loaded metaclass.tcl
    uplevel #0 [list source [file join $path metaclass.tcl]]
  }
  if {[file exists [file join $path baseclass.tcl]]} {
    lappend loaded baseclass.tcl
    uplevel #0 [list source [file join $path baseclass.tcl]]
  }
  foreach file $order {
    set file [file tail $file]
    if {$file in $loaded} continue
    if {![file exists [file join $path $file]]} {
      puts "WARNING [file join $path $file] does not exist in [info script]"
    } else {
      uplevel #0 [list source [file join $path $file]]
    }
    lappend loaded $file
  }
  foreach file [lsort -dictionary [glob -nocomplain [file join $path *.tcl]]] {
    if {[file tail $file] in $loaded} continue
    uplevel #0 [list source $file]
    lappend loaded [file tail $file]
  }
}

###
# END: core.tcl
###
###
# START: uuid.tcl
###
::namespace eval ::tool {}

proc ::tool::is_null value {
  return [expr {$value in {{} NULL}}]
}


proc ::tool::uuid_seed args {
  if {[llength $args]==0 || ([llength $args]==1 && [is_null [lindex $args 0]])} {
    if {[info exists ::env(USERNAME)]} {
      set user $::env(USERNAME)
    } elseif {[info exists ::env(USER)]} {
      set user $::env(USER)
    } else {
      set user $::env(user)
    }
    incr ::tool::nextuuid $::tool::globaluuid
    set ::tool::UUID_Seed [list user@[info hostname] [clock format [clock seconds]]]
  } else {
    incr ::tool::globaluuid $::tool::nextuuid
    set ::tool::nextuuid 0
    set ::tool::UUID_Seed $args
  }
}

###
# topic: 0a19b0bfb98162a8a37c1d3bbfb8bc3d
# description:
#    Because the tcllib version of uuid generate requires
#    network port access (which can be slow), here's a fast
#    and dirty rendition
###
proc ::tool::uuid_generate args {
  if {![llength $args]} {
    set block [list [incr ::tool::nextuuid] {*}$::tool::UUID_Seed]
  } else {
    set block $args
  }
  return [::sha1::sha1 -hex [join $block ""]]
}

###
# topic: ee3ec43cc2cc2c7d6cf9a4ef1c345c19
###
proc ::tool::uuid_short args {
  if {![llength $args]} {
    set block [list [incr ::tool::nextuuid] {*}$::tool::UUID_Seed]
  } else {
    set block $args
  }
  return [string range [::sha1::sha1 -hex [join $block ""]] 0 16]
}

###
# topic: b14c505537274904578340ec1bc12af1
# description:
#    Implementation the uses a compiled in ::md5 implementation
#    commonly used by embedded application developers
###
namespace eval ::tool {
  namespace export *
}
###
# Cache the bits of the UUID seed that aren't likely to change
# once the software is loaded, but which can be expensive to
# generate
###
set ::tool::nextuuid 0
set ::tool::globaluuid 0
::tool::uuid_seed

###
# END: uuid.tcl
###
###
# START: ensemble.tcl
###
::namespace eval ::tool::define {}

if {![info exists ::tool::dirty_classes]} {
  set ::tool::dirty_classes {}
}

###
# Monkey patch oometa's rebuild function to
# include a notifier to tool
###
proc ::oo::meta::rebuild args {
  foreach class $args {
    if {$class ni $::oo::meta::dirty_classes} {
      lappend ::oo::meta::dirty_classes $class
    }
    if {$class ni $::tool::dirty_classes} {
      lappend ::tool::dirty_classes $class
    }
  }
}

proc ::tool::ensemble_build_map args {
  set emap {}
  foreach thisclass $args {
    foreach {ensemble einfo} [::oo::meta::info $thisclass getnull method_ensemble] {
      foreach {submethod subinfo} $einfo {
        dict set emap $ensemble $submethod $subinfo
      }
    }
  }
  return $emap
}

proc ::tool::ensemble_methods emap {
  set result {}
  foreach {ensemble einfo} $emap {
    #set einfo [dict getnull $einfo method_ensemble $ensemble]
    set eswitch {}
    set default standard
    if {[dict exists $einfo default:]} {
      set emethodinfo [dict get $einfo default:]
      set arglist     [lindex $emethodinfo 0]
      set realbody    [lindex $emethodinfo 1]
      if {[llength $arglist]==1 && [lindex $arglist 0] in {{} args arglist}} {
        set body {}
      } else {
        set body "\n      ::tool::dynamic_arguments $ensemble \$method [list $arglist] {*}\$args"
      }
      append body "\n      " [string trim $realbody] "      \n"
      set default $body
      dict unset einfo default:
    }
    set methodlist {}
    foreach item [dict keys $einfo] {
      lappend methodlist [string trimright $item :]
    }
    set methodlist  [lsort -dictionary -unique $methodlist]
    foreach {submethod esubmethodinfo} [lsort -dictionary -stride 2 $einfo] {
      if {$submethod in {"_preamble:" "default:"}} continue
      set submethod [string trimright $submethod :]
      lassign $esubmethodinfo arglist realbody
      if {[string length [string trim $realbody]] eq {}} {
        dict set eswitch $submethod {}
      } else {
        if {[llength $arglist]==1 && [lindex $arglist 0] in {{} args arglist}} {
          set body {}
        } else {
          set body "\n      ::tool::dynamic_arguments $ensemble \$method [list $arglist] {*}\$args"
        }
        append body "\n      " [string trim $realbody] "      \n"
        dict set eswitch $submethod $body
      }
    }
    if {![dict exists $eswitch <list>]} {
      dict set eswitch <list> {return $methodlist}
    }
    if {$default=="standard"} {
      set default "error \"unknown method $ensemble \$method. Valid: \$methodlist\""
    }
    dict set eswitch default $default
    set mbody {}    
    if {[dict exists $einfo _preamble:]} {
      append mbody [lindex [dict get $einfo _preamble:] 1] \n
    }
    append mbody \n [list set methodlist $methodlist]
    append mbody \n "set code \[catch {switch -- \$method [list $eswitch]} result opts\]"
    append mbody \n {return -options $opts $result}
    append result \n [list method $ensemble {{method default} args} $mbody]    
  }
  return $result
}

###
# topic: fb8d74e9c08db81ee6f1275dad4d7d6f
###
proc ::tool::dynamic_object_ensembles {thisobject thisclass} {
  variable trace
  set ensembledict {}
  foreach dclass $::tool::dirty_classes {
    foreach {cclass cancestors} [array get ::oo::meta::cached_hierarchy] {
      if {$dclass in $cancestors} {
        unset -nocomplain ::tool::obj_ensemble_cache($cclass)
      }
    }
  }
  set ::tool::dirty_classes {}
  ###
  # Only go through the motions for classes that have a locally defined
  # ensemble method implementation
  ###
  foreach aclass [::oo::meta::ancestors $thisclass] {
    if {[info exists ::tool::obj_ensemble_cache($aclass)]} continue
    set emap [::tool::ensemble_build_map $aclass]
    set body [::tool::ensemble_methods $emap]
    oo::define $aclass $body
    # Define a property for this ensemble for introspection
    foreach {ensemble einfo} $emap {
      ::oo::meta::info $aclass set ensemble_methods $ensemble: [lsort -dictionary [dict keys $einfo]]
    }
    set ::tool::obj_ensemble_cache($aclass) 1
  }
}

###
# topic: ec9ca249b75e2667ad5bcb2f7cd8c568
# title: Define an ensemble method for this agent
###
::proc ::tool::define::method {rawmethod args} {
  set class [current_class]
  set mlist [split $rawmethod "::"]
  if {[llength $mlist]==1} {
    ###
    # Simple method, needs no parsing
    ###
    set method $rawmethod
    ::oo::define $class method $rawmethod {*}$args
    return
  }
  set ensemble [lindex $mlist 0]
  set method [join [lrange $mlist 2 end] "::"]
  switch [llength $args] {
    1 {
      ::oo::meta::info $class set method_ensemble $ensemble $method: [list dictargs [lindex $args 0]]
    }
    2 {
      ::oo::meta::info $class set method_ensemble $ensemble $method: $args
    }
    default {
      error "Usage: method NAME ARGLIST BODY"
    }
  }
}

###
# topic: 354490e9e9708425a6662239f2058401946e41a1
# description: Creates a method which exports access to an internal dict
###
proc ::tool::define::dictobj args {
  dict_ensemble {*}$args
}
proc ::tool::define::dict_ensemble {methodname varname {cases {}}} {
  set class [current_class]
  set CASES [string map [list %METHOD% $methodname %VARNAME% $varname] $cases]
  
  set methoddata [::oo::meta::info $class getnull method_ensemble $methodname]
  set initial [dict getnull $cases initialize]
  variable $varname $initial
  foreach {name body} $CASES {
    dict set methoddata $name: [list args $body]
  }
  set template [string map [list %CLASS% $class %INITIAL% $initial %METHOD% $methodname %VARNAME% $varname] {
    _preamble {} {
      my variable %VARNAME%
    }
    add args {
      set field [string trimright [lindex $args 0] :]
      set data [dict getnull $%VARNAME% $field]
      foreach item [lrange $args 1 end] {
        if {$item ni $data} {
          lappend data $item
        }
      }
      dict set %VARNAME% $field $data
    }
    remove args {
      set field [string trimright [lindex $args 0] :]
      set data [dict getnull $%VARNAME% $field]
      set result {}
      foreach item $data {
        if {$item in $args} continue
        lappend result $item
      }
      dict set %VARNAME% $field $result
    }
    initial {} {
      return [dict rmerge [my meta branchget %VARNAME%] {%INITIAL%}]
    }
    reset {} {
      set %VARNAME% [dict rmerge [my meta branchget %VARNAME%] {%INITIAL%}]
      return $%VARNAME%
    }
    dump {} {
      return $%VARNAME%
    }
    append args {
      return [dict $method %VARNAME% {*}$args]
    }
    incr args {
      return [dict $method %VARNAME% {*}$args]
    }
    lappend args {
      return [dict $method %VARNAME% {*}$args]
    }
    set args {
      return [dict $method %VARNAME% {*}$args]
    }
    unset args {
      return [dict $method %VARNAME% {*}$args]
    }
    update args {
      return [dict $method %VARNAME% {*}$args]
    }
    branchset args {
      foreach {field value} [lindex $args end] {
        dict set %VARNAME% {*}[lrange $args 0 end-1] [string trimright $field :]: $value
      }
    }
    rmerge args {
      set %VARNAME% [dict rmerge $%VARNAME% {*}$args]
      return $%VARNAME%  
    }
    merge args {
      set %VARNAME% [dict rmerge $%VARNAME% {*}$args]
      return $%VARNAME%
    }
    replace args {
      set %VARNAME% [dict rmerge $%VARNAME% {%INITIAL%} {*}$args]
    }
    default args {
      return [dict $method $%VARNAME% {*}$args]
    }
  }]
  foreach {name arglist body} $template {
    if {[dict exists $methoddata $name:]} continue
    dict set methoddata $name: [list $arglist $body]
  }
  ::oo::meta::info $class set method_ensemble $methodname $methoddata
}

proc ::tool::define::arrayobj args {
  array_ensemble {*}$args
}

###
# topic: 354490e9e9708425a6662239f2058401946e41a1
# description: Creates a method which exports access to an internal array
###
proc ::tool::define::array_ensemble {methodname varname {cases {}}} {
  set class [current_class]
  set CASES [string map [list %METHOD% $methodname %VARNAME% $varname] $cases]
  set initial [dict getnull $cases initialize]
  array $varname $initial

  set map [list %CLASS% $class %METHOD% $methodname %VARNAME% $varname %CASES% $CASES %INITIAL% $initial]

  ::oo::define $class method _${methodname}Get {field} [string map $map {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return $%VARNAME%($field)
    }
    return [my meta getnull %VARNAME% $field:]
  }]
  ::oo::define $class method _${methodname}Exists {field} [string map $map {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return 1
    }
    return [my meta exists %VARNAME% $field:]
  }]
  set methoddata [::oo::meta::info $class set array_ensemble $methodname: $varname]
  
  set methoddata [::oo::meta::info $class getnull method_ensemble $methodname]
  foreach {name body} $CASES {
    dict set methoddata $name: [list args $body]
  } 
  set template  [string map [list %CLASS% $class %INITIAL% $initial %METHOD% $methodname %VARNAME% $varname] {
    _preamble {} {
      my variable %VARNAME%
    }
    reset {} {
      ::array unset %VARNAME% *
      foreach {field value} [my meta getnull %VARNAME%] {
        set %VARNAME%([string trimright $field :]) $value
      }
      ::array set %VARNAME% {%INITIAL%}
      return [array get %VARNAME%]
    }
    ni value {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      return [expr {$value ni $data}]
    }
    in value {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      return [expr {$value in $data}]
    }
    add args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      foreach item [lrange $args 1 end] {
        if {$item ni $data} {
          lappend data $item
        }
      }
      set %VARNAME%($field) $data
    }
    remove args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      set result {}
      foreach item $data {
        if {$item in $args} continue
        lappend result $item
      }
      set %VARNAME%($field) $result
    }
    dump {} {
      set result {}
      foreach {var val} [my meta getnull %VARNAME%] {
        dict set result [string trimright $var :] $val
      }
      foreach {var val} [lsort -dictionary -stride 2 [array get %VARNAME%]] {
        dict set result [string trimright $var :] $val
      }
      return $result
    }
    exists args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Exists $field]
    }
    getnull args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]      
    }
    get field {
      set field [string trimright $field :]
      set data [my _%METHOD%Get $field]
    }
    set args {
      set field [string trimright [lindex $args 0] :]
      ::set %VARNAME%($field) {*}[lrange $args 1 end]        
    }
    append args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      ::append data {*}[lrange $args 1 end]
      set %VARNAME%($field) $data
    }
    incr args {
      set field [string trimright [lindex $args 0] :]
      ::incr %VARNAME%($field) {*}[lrange $args 1 end]
    }
    lappend args {
      set field [string trimright [lindex $args 0] :]
      set data [my _%METHOD%Get $field]
      $method data {*}[lrange $args 1 end]
      set %VARNAME%($field) $data
    }
    branchset args {
      foreach {field value} [lindex $args end] {
        set %VARNAME%([string trimright $field :]) $value
      }
    }
    rmerge args {
      foreach arg $args {
        my %VARNAME% branchset $arg
      }
    }
    merge args {
      foreach arg $args {
        my %VARNAME% branchset $arg
      }
    }
    default args {
      return [array $method %VARNAME% {*}$args]
    }
  }]
  foreach {name arglist body} $template {
    if {[dict exists $methoddata $name:]} continue
    dict set methoddata $name: [list $arglist $body]
  }
  ::oo::meta::info $class set method_ensemble $methodname $methoddata
}


###
# END: ensemble.tcl
###
###
# START: metaclass.tcl
###
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

###
# New OO Keywords for TOOL
###
namespace eval ::tool::define {}
proc ::tool::define::array {name {values {}}} {
  set class [current_class]
  set name [string trimright $name :]:
  if {![::oo::meta::info $class exists array $name]} {
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
::tool::object_create [self] [info object class [self]]
# Initialize public variables and options
my InitializePublic
  }
  append body $rawbody
  append body {
# Run "initialize"
my initialize
  }
  set class [current_class]
  ::oo::define $class constructor $arglist $body
}

###
# topic: 7a5c7e04989704eef117ff3c9dd88823
# title: Specify the a method for the class object itself, instead of for objects of the class
###
proc ::tool::define::class_method {name arglist body} {
  set class [current_class]
  ::oo::meta::info $class set class_typemethod $name: [list $arglist $body]
}

###
# topic: 4cb3696bf06d1e372107795de7fe1545
# title: Specify the destructor for a class
###
proc ::tool::define::destructor rawbody {
  set body {
# Run the destructor once and only once
set self [self]
my variable DestroyEvent
if {$DestroyEvent} return
set DestroyEvent 1
::tool::object_destroy $self
}
  append body $rawbody
  ::oo::define [current_class] destructor $body
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
    default {
      error "Usage:
property name type valuedict
OR property name value"
    }
  }
  ::oo::meta::info $class set {*}$args
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
  ::oo::define $class variable $name
}

###
# Utility Procedures
###

# topic: 643efabec4303b20b66b760a1ad279bf
###
proc ::tool::args_to_dict args {
  if {[llength $args]==1} {
    return [lindex $args 0]
  }
  return $args
}

###
# topic: b40970b0d9a2525990b9105ec8c96d3d
###
proc ::tool::args_to_options args {
  set result {}
  foreach {var val} [args_to_dict {*}$args] {
    lappend result [string trimright [string trimleft $var -] :] $val
  }
  return $result
}

###
# topic: a92cd258900010f656f4c6e7dbffae57
###
proc ::tool::dynamic_methods class {
  ::oo::meta::rebuild $class
  set metadata [::oo::meta::metadata $class]
  foreach command [info commands [namespace current]::dynamic_methods_*] {
    $command $class $metadata
  }
}

###
# topic: 4969d897a83d91a230a17f166dbcaede
###
proc ::tool::dynamic_arguments {ensemble method arglist args} {
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
      # Perform args processing in the style of tool
      ###
      set dictargs [::tool::args_to_options {*}[lrange $args $idx end]]
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
# topic: b88add196bb63abccc44639db5e5eae1
###
proc ::tool::dynamic_methods_class {thisclass metadata} {
  foreach {method info} [dict getnull $metadata class_typemethod] {
    lassign $info arglist body
    set method [string trimright $method :]
    ::oo::objdefine $thisclass method $method $arglist $body
  }
}

###
# topic: 53ab28ac5c6ee601fe1fe07b073be88e
###
proc ::tool::dynamic_wrongargs_message {arglist} {
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

proc ::tool::object_create {objname {class {}}} {
  foreach varname {
    object_info
    object_signal
    object_subscribe
  } {
    variable $varname
    set ${varname}($objname) {}
  }
  if {$class eq {}} {
    set class [info object class $objname]
  }
   set object_info($objname) [list class $class]
  if {$class ne {}} {
    $objname graft class $class
    foreach command [info commands [namespace current]::dynamic_object_*] {
      $command $objname $class
    }
  }
}


proc ::tool::object_rename {object newname} {
  foreach varname {
    object_info
    object_signal
    object_subscribe
  } {
    variable $varname
    if {[info exists ${varname}($object)]} {
      set ${varname}($newname) [set ${varname}($object)]
      unset ${varname}($object)
    }
  }
  variable coroutine_object
  foreach {coro coro_objname} [array get coroutine_object] {
    if { $object eq $coro_objname } {
      set coroutine_object($coro) $newname
    }
  }
  rename $object ::[string trimleft $newname]
  ::tool::event::generate $object object_rename [list newname $newname]
}

proc ::tool::object_destroy objname {
  ::tool::event::generate $objname object_destroy [list objname $objname]
  ::tool::event::cancel $objname *
  ::cron::object_destroy $objname
  variable coroutine_object
  foreach varname {
    object_info
    object_signal
    object_subscribe
  } {
    variable $varname
    unset -nocomplain ${varname}($objname)
  }
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
  variable organs {}
  variable mixins {}
  variable mixinmap {}
  variable DestroyEvent 0

  constructor args {
    my Config_merge [::tool::args_to_options {*}$args]
  }

  destructor {}

  method ancestors {{reverse 0}} {
    set result [::oo::meta::ancestors [info object class [self]]]
    if {$reverse} {
      return [lreverse $result]
    }
    return $result
  }

  method DestroyEvent {} {
    my variable DestroyEvent
    return $DestroyEvent
  }

  ###
  # title: Forward a method
  ###
  method forward {method args} {
    oo::objdefine [self] forward $method {*}$args
  }

  ###
  # title: Direct a series of sub-functions to a seperate object
  ###
  method graft args {
    my variable organs
    if {[llength $args] == 1} {
      error "Need two arguments"
    }
    set object {}
    foreach {stub object} $args {
      if {$stub eq "class"} {
        # Force class to always track the object's current class
        set obj [info object class [self]]
      }
      dict set organs $stub $object
      oo::objdefine [self] forward <${stub}> $object
      oo::objdefine [self] export <${stub}>
    }
    return $object
  }

  # Called after all options and public variables are initialized
  method initialize {} {}

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
    my variable config meta mixinmap mixins
    if {![info exists mixins]} {
      set mixins {}
    }
    if {![info exists mixinmap]} {
      set mixinmap {}
    }
    if {![info exists meta]} {
      set meta {}
    }
    if {![info exists config]} {
      set config {}
    }
    my ClassPublicApply {}
  }

  class_method info {which} {
    my variable cache
    if {![info exists cache($which)]} {
      set cache($which) {}
      switch $which {
        public {
          dict set cache(public) variable [my meta branchget variable]
          dict set cache(public) array [my meta branchget array]
          set optinfo [my meta getnull option]
          dict set cache(public) option_info $optinfo
          foreach {var info} [dict getnull $cache(public) option_info] {
            if {[dict exists $info aliases:]} {
              foreach alias [dict exists $info aliases:] {
                dict set cache(public) option_canonical $alias $var
              }
            }
            set getcmd [dict getnull $info default-command:]
            if {$getcmd ne {}} {
              dict set cache(public) option_default_command $var $getcmd
            } else {
              dict set cache(public) option_default_value $var [dict getnull $info default:]
            }
            dict set cache(public) option_canonical $var $var
          }
        }
      }
    }
    return $cache($which)
  }

  ###
  # Incorporate the class's variables, arrays, and options
  ###
  method ClassPublicApply class {
    my variable config
    set integrate 0
    if {$class eq {}} {
      set class [info object class [self]]
    } else {
      set integrate 1
    }
    set public [$class info public]
    foreach {var value} [dict getnull $public variable] {
      if { $var in {meta config} } continue
      my variable $var
      if {![info exists $var]} {
        set $var $value
      }
    }
    foreach {var value} [dict getnull $public array] {
      if { $var eq {meta config} } continue
      my variable $var
      foreach {f v} $value {
        if {![array exists ${var}($f)]} {
          set ${var}($f) $v
        }
      }
    }
    set dat [dict getnull $public option_info]
    if {$integrate} {
      my meta rmerge [list option $dat]
    }
    my variable option_canonical
    array set option_canonical [dict getnull $public option_canonical]
    set dictargs {}
    foreach {var getcmd} [dict getnull $public option_default_command] {
      if {[dict getnull $dat $var class:] eq "organ"} {
        if {[my organ $var] ne {}} continue
      }
      if {[dict exists $config $var]} continue
      dict set dictargs $var [{*}[string map [list %field% $var %self% [namespace which my]] $getcmd]]
    }
    foreach {var value} [dict getnull $public option_default_value] {
      if {[dict getnull $dat $var class:] eq "organ"} {
        if {[my organ $var] ne {}} continue
      }
      if {[dict exists $config $var]} continue
      dict set dictargs $var $value
    }
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      if {[dict exists $config $field]} continue
      set script [dict getnull $dat $field set-command:]
      dict set config $field $val
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
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
  method mixin args {
    ###
    # Mix in the class
    ###
    my variable mixins
    set prior $mixins

    set mixins $args
    ::oo::objdefine [self] mixin {*}$args
    ###
    # Build a compsite map of all ensembles defined by the object's current
    # class as well as all of the classes being mixed in
    ###
    set emap [::tool::ensemble_build_map [::info object class [self]] {*}[lreverse $args]]
    set body [::tool::ensemble_methods $emap]
    oo::objdefine [self] $body
    foreach class $args {
      if {$class ni $prior} {
        my meta mixin $class
      }
      my ClassPublicApply $class
    }
    foreach class $prior {
      if {$class ni $mixins } {
        my meta mixout $class
      }
    }
  }

  method mixinmap args {
    my variable mixinmap
    set priorlist {}
    foreach {slot classes} $args {
      if {[dict exists $mixinmap $slot]} {
        lappend priorlist {*}[dict get $mixinmap $slot]
        foreach class [dict get $mixinmap $slot] {
          if {$class ni $classes && [$class meta exists mixin unmap-script:]} {
            if {[catch [$class meta get mixin unmap-script:] err errdat]} {
              puts stderr "[self] MIXIN ERROR POPPING $class:\n[dict get $errdat -errorinfo]"
            }
          }
        }
      }
      dict set mixinmap $slot $classes
    }
    my Recompute_Mixins
    foreach {slot classes} $args {
      foreach class $classes {
        if {$class ni $priorlist && [$class meta exists mixin map-script:]} {
          if {[catch [$class meta get mixin map-script:] err errdat]} {
            puts stderr "[self] MIXIN ERROR PUSHING $class:\n[dict get $errdat -errorinfo]"
          }
        }
      }
    }
    foreach {slot classes} $mixinmap {
      foreach class $classes {
        if {[$class meta exists mixin react-script:]} {
          if {[catch [$class meta get mixin react-script:] err errdat]} {
            puts stderr "[self] MIXIN ERROR REACTING $class:\n[dict get $errdat -errorinfo]"
          }
        }
      }
    }
  }

  method debug_mixinmap {} {
    my variable mixinmap
    return $mixinmap
  }

  method Recompute_Mixins {} {
    my variable mixinmap
    set classlist {}
    foreach {item class} $mixinmap {
      if {$class ne {}} {
        lappend classlist $class
      }
    }
    my mixin {*}$classlist
  }

  method morph newclass {
    if {$newclass eq {}} return
    set class [string trimleft [info object class [self]]]
    set newclass [string trimleft $newclass :]
    if {[info command ::$newclass] eq {}} {
      error "Class $newclass does not exist"
    }
    if { $class ne $newclass } {
      my Morph_leave
      my variable mixins
      oo::objdefine [self] class ::${newclass}
      my graft class ::${newclass}
      # Reapply mixins
      my mixin {*}$mixins
      my InitializePublic
      my Morph_enter
    }
  }

  ###
  # Commands to perform as this object transitions out of the present class
  ###
  method Morph_leave {} {}
  ###
  # Commands to perform as this object transitions into this class as a new class
  ###
  method Morph_enter {} {}

  ###
  # title: List which objects are forwarded as organs
  ###
  method organ {{stub all}} {
    my variable organs
    if {![info exists organs]} {
      return {}
    }
    if { $stub eq "all" } {
      return $organs
    }
    return [dict getnull $organs $stub]
  }
}



###
# END: metaclass.tcl
###
###
# START: option.tcl
###
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
  # Option Class handling
  ###
  set optclass [dict getnull $dictargs class:]
  if {$optclass ne {}} {
    foreach {f v} [::oo::meta::info $class getnull option_class $optclass] {
      if {![dict exists $dictargs $f]} {
        dict set dictargs $f $v
      }
    }
    if {$optclass eq "variable"} {
      variable $name [dict getnull $dictargs default:]
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

::tool::define ::tool::object {
  property options_strict 0
  variable organs {}

  option_class organ {
    widget label
    set-command {my graft %field% %value%}
    get-command {my organ %field%}
  }

  option_class variable {
    widget entry
    set-command {my variable %field% ; set %field% %value%}
    get-command {my variable %field% ; set %field%}
  }
  
  dict_ensemble config config {
    get {
      return [my Config_get {*}$args]
    }
    merge {
      return [my Config_merge {*}$args]
    }
    set {
      my Config_set {*}$args
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
    set dat [my meta getnull option]
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
    set dat [my meta getnull option]
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field post-command:]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
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
}

package provide tool::option 0.1

###
# END: option.tcl
###
###
# START: event.tcl
###
###
# This file implements the Tool event manager
###

::namespace eval ::tool {}

::namespace eval ::tool::event {}

###
# topic: f2853d380a732845610e40375bcdbe0f
# description: Cancel a scheduled event
###
proc ::tool::event::cancel {self {task *}} {
  variable timer_event
  variable timer_script

  foreach {id event} [array get timer_event $self:$task] {
    ::after cancel $event
    set timer_event($id) {}
    set timer_script($id) {}
  }
}

###
# topic: 8ec32f6b6ba78eaf980524f8dec55b49
# description:
#    Generate an event
#    Adds a subscription mechanism for objects
#    to see who has recieved this event and prevent
#    spamming or infinite recursion
###
proc ::tool::event::generate {self event args} {
  set wholist [Notification_list $self $event]
  if {$wholist eq {}} return
  set dictargs [::oo::meta::args_to_options {*}$args]
  set info $dictargs
  set strict 0
  set debug 0
  set sender $self
  dict with dictargs {}
  dict set info id     [::tool::event::nextid]
  dict set info origin $self
  dict set info sender $sender
  dict set info rcpt   {}
  foreach who $wholist {
    catch {::tool::event::notify $who $self $event $info}
  }
}

###
# topic: 891289a24b8cc52b6c228f6edb169959
# title: Return a unique event handle
###
proc ::tool::event::nextid {} {
  return "event#[format %0.8x [incr ::tool::event_count]]"
}

###
# topic: 1e53e8405b4631aec17f98b3e8a5d6a4
# description:
#    Called recursively to produce a list of
#    who recieves notifications
###
proc ::tool::event::Notification_list {self event {stackvar {}}} {
  set notify_list {}
  foreach {obj patternlist} [array get ::tool::object_subscribe] {
    if {$obj eq $self} continue
    if {$obj in $notify_list} continue
    set match 0
    foreach {objpat eventlist} $patternlist {
      if {![string match $objpat $self]} continue
      foreach eventpat $eventlist {
        if {![string match $eventpat $event]} continue
        set match 1
        break
      }
      if {$match} {
        break
      }
    }
    if {$match} {
      lappend notify_list $obj
    }
  }
  return $notify_list
}

###
# topic: b4b12f6aed69f74529be10966afd81da
###
proc ::tool::event::notify {rcpt sender event eventinfo} {
  if {[info commands $rcpt] eq {}} return 
  if {$::tool::trace} {
    puts [list event notify rcpt $rcpt sender $sender event $event info $eventinfo]
  }
  $rcpt notify $event $sender $eventinfo
}

###
# topic: 829c89bda736aed1c16bb0c570037088
###
proc ::tool::event::process {self handle script} {
  variable timer_event
  variable timer_script

  array unset timer_event $self:$handle
  array unset timer_script $self:$handle

  set err [catch {uplevel #0 $script} result errdat]
  if $err {
    puts "BGError: $self $handle $script
ERR: $result
[dict get $errdat -errorinfo]
***"
  }
}

###
# topic: eba686cffe18cd141ac9b4accfc634bb
# description: Schedule an event to occur later
###
proc ::tool::event::schedule {self handle interval script} {
  variable timer_event
  variable timer_script
  if {$::tool::trace} {
    puts [list $self schedule $handle $interval]
  }
  if {[info exists timer_event($self:$handle)]} {
    if {$script eq $timer_script($self:$handle)} {
      return
    }
    ::after cancel $timer_event($self:$handle)
  }
  set timer_script($self:$handle) $script
  set timer_event($self:$handle) [::after $interval [list ::tool::event::process $self $handle $script]]
}

proc ::tool::event::sleep msec {
  ::cron::sleep $msec
}

###
# topic: e64cff024027ee93403edddd5dd9fdde
###
proc ::tool::event::subscribe {self who event} {
  upvar #0 ::tool::object_subscribe($self) subscriptions
  if {![info exists subscriptions]} {
    set subscriptions {}
  }
  set match 0
  foreach {objpat eventlist} $subscriptions {
    if {![string match $objpat $who]} continue      
    foreach eventpat $eventlist {
      if {[string match $eventpat $event]} {
        # This rule already exists
        return
      }
    }
  }
  dict lappend subscriptions $who $event
}

###
# topic: 5f74cfd01735fb1a90705a5f74f6cd8f
###
proc ::tool::event::unsubscribe {self args} {
  upvar #0 ::tool::object_subscribe($self) subscriptions
  if {![info exists subscriptions]} {
    return
  }  
  switch [llength $args] {
    1 {
      set event [lindex $args 0]
      if {$event eq "*"} {
        # Shortcut, if the 
        set subscriptions {}
      } else {
        set newlist {}
        foreach {objpat eventlist} $subscriptions {
          foreach eventpat $eventlist {
            if {[string match $event $eventpat]} continue
            dict lappend newlist $objpat $eventpat
          }
        }
        set subscriptions $newlist
      }
    }
    2 {
      set who [lindex $args 0]
      set event [lindex $args 1]
      if {$who eq "*" && $event eq "*"} {
        set subscriptions {}
      } else {
        set newlist {}
        foreach {objpat eventlist} $subscriptions {
          if {[string match $who $objpat]} {
            foreach eventpat $eventlist {
              if {[string match $event $eventpat]} continue
              dict lappend newlist $objpat $eventpat
            }
          }
        }
        set subscriptions $newlist
      }
    }
  }
}

::tool::define ::tool::object {
  ###
  # topic: 20b4a97617b2b969b96997e7b241a98a
  ###
  method event {submethod args} {
    ::tool::event::$submethod [self] {*}$args
  }
}

###
# topic: 37e7bd0be3ca7297996da2abdf5a85c7
# description: The event manager for Tool
###
namespace eval ::tool::event {
  variable nextevent {}
  variable nexteventtime 0
}


###
# END: event.tcl
###
###
# START: pipeline.tcl
###
::namespace eval ::tool::signal {}
::namespace eval ::tao {}

# Provide a backward compatible hook
proc ::tool::main {} {
  ::cron::main
}

proc ::tool::do_events {} {
  ::cron::do_events
}

proc ::tao::do_events {} {
  ::cron::do_events
}

proc ::tao::main {} {
  ::cron::main
}


package provide tool::pipeline 0.1


###
# END: pipeline.tcl
###
###
# START: coroutine.tcl
###
proc ::tool::define::coroutine {name corobody} {
  set class [current_class]
  ::oo::meta::info $class set method_ensemble ${name} _preamble: [list {} [string map [list %coroname% $name] {
    my variable coro_queue coro_lock
    set coro %coroname%
    set coroname [info object namespace [self]]::%coroname%
  }]]
  ::oo::meta::info $class set method_ensemble ${name} coroutine: {{} {
    return $coroutine
  }}
  ::oo::meta::info $class set method_ensemble ${name} restart: {{} {
    # Don't allow a coroutine to kill itself
    if {[info coroutine] eq $coroname} return
    if {[info commands $coroname] ne {}} {
      rename $coroname {}
    }
    set coro_lock($coroname) 0
    ::coroutine $coroname {*}[namespace code [list my $coro main]]
    ::cron::object_coroutine [self] $coroname
  }}
  ::oo::meta::info $class set method_ensemble ${name} kill: {{} {
    # Don't allow a coroutine to kill itself
    if {[info coroutine] eq $coroname} return
    if {[info commands $coroname] ne {}} {
      rename $coroname {}
    }
  }}

  ::oo::meta::info $class set method_ensemble ${name} main: [list {} $corobody]

  ::oo::meta::info $class set method_ensemble ${name} clear: {{} {
    set coro_queue($coroname) {}
  }}
  ::oo::meta::info $class set method_ensemble ${name} next: {{eventvar} {
    upvar 1 [lindex $args 0] event
    if {![info exists coro_queue($coroname)]} {
      return 1
    }
    if {[llength $coro_queue($coroname)] == 0} {
      return 1
    }
    set event [lindex $coro_queue($coroname) 0]
    set coro_queue($coroname) [lrange $coro_queue($coroname) 1 end]
    return 0
  }}
  
  ::oo::meta::info $class set method_ensemble ${name} peek: {{eventvar} {
    upvar 1 [lindex $args 0] event
    if {![info exists coro_queue($coroname)]} {
      return 1
    }
    if {[llength $coro_queue($coroname)] == 0} {
      return 1
    }
    set event [lindex $coro_queue($coroname) 0]
    return 0
  }}

  ::oo::meta::info $class set method_ensemble ${name} running: {{} {
    if {[info commands $coroname] eq {}} {
      return 0
    }
    if {[::cron::task exists $coroname]} {
      set info [::cron::task info $coroname]
      if {[dict exists $info running]} {
        return [dict get $info running]
      }
    }
    return 0
  }}
  
  ::oo::meta::info $class set method_ensemble ${name} send: {args {
    lappend coro_queue($coroname) $args
    if {[info coroutine] eq $coroname} {
      return
    }
    if {[info commands $coroname] eq {}} {
      ::coroutine $coroname {*}[namespace code [list my $coro main]]
      ::cron::object_coroutine [self] $coroname
    }
    if {[info coroutine] eq {}} {
      ::cron::do_one_event $coroname
    } else {
      yield
    }
  }}
  ::oo::meta::info $class set method_ensemble ${name} default: {args {my [self method] send $method {*}$args}}

}

###
# END: coroutine.tcl
###
###
# START: organ.tcl
###
###
# A special class of objects that
# stores no meta data of its own
# Instead it vampires off of the master object
###
tool::class create ::tool::organelle {
  
  constructor {master} {
    my entangle $master
    set final_class [my select]
    if {[info commands $final_class] ne {}} {
      # Safe to switch class here, we haven't initialized anything
      oo::objdefine [self] class $final_class
    }
    my initialize
  }

  method entangle {master} {
    my graft master $master
    my forward meta $master meta
    foreach {stub organ} [$master organ] {
      my graft $stub $organ
    }
    foreach {methodname variable} [my meta branchget array_ensemble] {
      my forward $methodname $master $methodname
    }
  }
  
  method select {} {
    return {}
  }
}

###
# END: organ.tcl
###
###
# START: script.tcl
###
###
# Add configure by script facilities to TOOL
###
::tool::define ::tool::object {

  ###
  # Allows for a constructor to accept a psuedo-code
  # initialization script which exercise the object's methods
  # sans "my" in front of every command
  ###
  method Eval_Script script {
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
}
###
# END: script.tcl
###

namespace eval ::tool {
  namespace export *
}

