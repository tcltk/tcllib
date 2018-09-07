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
    my variable clay claycache clayorder config option_canonical
    if {![info exists clay]} {set clay {}}
    if {![info exists claycache]} {set claycache {}}
    if {![info exists config]} {set config {}}
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
        if {[llength $args]==1} {
          set field [string trim [lindex $args 0] -:/]
          if {[info exists option_canonical($field)]} {
            set field $option_canonical($field)
          }
          if {[dict exists $config $field]} {
            return [dict get $config $field]
          }
        }
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
        ::clay::dictmerge result $clay
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
      evolve -
      initialize {
        my InitializePublic
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

          # Search in the in our list of classes for an answer
          foreach class [lreverse $clayorder] {
            ::clay::dictmerge result [$class clay get {*}$args]
          }
          if {[dict exists $clay {*}$args]} {
            ::clay::dictmerge result [dict get $clay {*}$args]
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
            set script [$class clay get mixin/ unmap-script]
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
        my InitializePublic
        foreach class $newmixin {
          if {$class ni $prior} {
            set script [$class clay get mixin/ map-script]
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
        my variable clay
        if {![dict exists $clay mixin]} {
          dict set clay mixin {}
        }
        if {[llength $args]==0} {
          return [dict get $clay mixin]
        } elseif {[llength $args]==1} {
          return [dict getnull $clay mixin [lindex $args 0]]
        } else {
          foreach {slot classes} $args {
            dict set clay mixin $slot $classes
          }
          set claycache {}
          set classlist {}
          foreach {item class} [dict get $clay mixin] {
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
        set claycache {}
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
  method InitializePublic {} {
    my variable clayorder clay claycache config option_canonical
    set claycache {}
    set clayorder [::clay::ancestors [info object class [self]] {*}[info object mixins [self]]]
    if {![info exists config]} {
      set config {}
    }
    foreach {var value} [my clay get variable/] {
      set var [string trim $var :/]
      if { $var in {clay} } continue
      my variable $var
      if {![info exists $var]} {
        if {$::clay::trace>2} {puts [list initialize variable $var $value]}
        set $var $value
      }
    }
    foreach {var value} [my clay get dict/] {
      set var [string trim $var :/]
      my variable $var
      if {![info exists $var]} {
        set $var {}
      }
      foreach {f v} $value {
        if {![dict exists ${var} $f]} {
          if {$::clay::trace>2} {puts [list initialize dict $var $f $v]}
          dict set ${var} $f $v
        }
      }
    }
    foreach {var value} [my clay get dict/] {
      set var [string trim $var :/]
      foreach {f v} [my clay get $var/] {
        if {![dict exists ${var} $f]} {
          if {$::clay::trace>2} {puts [list initialize dict (from const) $var $f $v]}
          dict set ${var} $f $v
        }
      }
    }
    foreach {var value} [my clay get array/] {
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
    foreach {var value} [my clay get array/] {
      set var [string trim $var :/]
      foreach {f v} [my clay get $var/] {
        if {![array exists ${var}($f)]} {
          if {$::clay::trace>2} {puts [list initialize array (from const) $var\($f\) $v]}
          set ${var}($f) $v
        }
      }
    }
    foreach {field info} [my clay get option/] {
      set field [string trim $field -/:]
      foreach alias [dict getnull $info aliases] {
        set option_canonical($alias) $field
      }
      if {[dict exists $config $field]} continue
      set getcmd [dict getnull $info default-command]
      if {$getcmd ne {}} {
        set value [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
      } else {
        set value [dict getnull $info default]
      }
      dict set config $field $value
      set setcmd [dict getnull $info set-command]
      if {$setcmd ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $value] %self% [namespace which my]] $setcmd]
      }
    }
  }
}

