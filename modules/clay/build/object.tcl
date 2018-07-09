oo::define oo::object {

  method Clay_Mixin args {
    ::oo::objdefine [self] mixin {*}$args
  }

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
      dump {
        # Do a full dump of clay data
        set result $clay
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          ::clay::dictmerge result [$class clay dump]
        }
        return $result
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
        my Clay_Mixin {*}$args
      }
      replace {
        set clay [lindex $args 0]
      }
      source {
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
      set {
        #puts [list [self] clay SET {*}$args]
        ::clay::dictmerge clay {*}$args
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }
}

# clay::object
#
# This class is inherited by all classes that have options.
#
::clay::define ::clay::object {
  Variable organs {}
  Variable clay {}
  Variable mixinmap {}
  Variable claycache {}
  Variable DestroyEvent 0

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

  method delegate args {
    my variable delegate
    if {![info exists delegate]} {
      set delegate {}
    }
    if {![dict exists delegate <class>]} {
      dict set delegate <class> [info object class [self]]
    }
    if {[llength $args]==0} {
      return $delegate
    }
    if {[llength $args]==1} {
      set stub <[string trim [lindex $args 0] <>]>
      if {![dict exists $delegate $stub]} {
        return {}
      }
      return [dict get $delegate $stub]
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
      dict set delegate $stub $object
      oo::objdefine [self] forward ${stub} $object
      oo::objdefine [self] export ${stub}
    }
  }

  method Ensemble_Map ensemble {
    my variable claycache
    set mensemble [string trim $ensemble :/]/
    if {[dict exists $claycache method_ensemble/ $mensemble]} {
      return [dict get $claycache method_ensemble/ $mensemble]
    }
    set emap [my clay get method_ensemble/ $mensemble]
    dict set claycache method_ensemble/ $mensemble $emap
    return $emap
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

  method forward args {
    oo::objdefine [self] forward {*}$args
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
    my variable mixinmap
    set priorlist {}
    foreach {slot classes} $args {
      if {[dict exists $mixinmap $slot]} {
        lappend priorlist {*}[dict get $mixinmap $slot]
        foreach class [dict get $mixinmap $slot] {
          if {$class ni $classes && [$class clay exists mixin/ unmap-script]} {
            if {[catch [$class clay get mixin/ unmap-script] err errdat]} {
              puts stderr "[self] MIXIN ERROR POPPING $class:\n[dict get $errdat -errorinfo]"
            }
          }
        }
      }
      dict set mixinmap $slot $classes
    }

    set classlist {}
    foreach {item class} $mixinmap {
      if {$class ne {}} {
        lappend classlist $class
      }
    }
    my clay mixin {*}$classlist

    foreach {slot classes} $args {
      foreach class $classes {
        if {$class ni $priorlist && [$class clay exists mixin/ map-script]} {
          if {[catch [$class clay get mixin/ map-script] err errdat]} {
            puts stderr "[self] MIXIN ERROR PUSHING $class:\n[dict get $errdat -errorinfo]"
          }
        }
      }
    }
    foreach {slot classes} $mixinmap {
      foreach class $classes {
        if {[$class clay exists mixin/ react-script]} {
          if {[catch [$class clay get mixin/ react-script] err errdat]} {
            puts stderr "[self] MIXIN ERROR REACTING $class:\n[dict get $errdat -errorinfo]"
          }
        }
      }
    }
  }

  method Clay_Mixin args {
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
    my Ensembles_Rebuild
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

  # Invoke a script in this object's namespace
  method source filename {
    source $filename
  }
}
