
# tool::object
#
# This class is inherited by all classes that have options.
#

::tool::define ::tool::object {
  # Put MOACish stuff in here
  property options_strict 0
  variable signals_pending create
  Dict clay {}
  Dict claycache {}
  Dict organs {}
  Dict mixins {}
  Dict mixinmap {}
  variable DestroyEvent 0

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

  constructor args {
    my Config_merge [::tool::args_to_options {*}$args]
  }

  destructor {}

  method ancestors {{reverse 0}} {
    set result [::clay::ancestors [info object class [self]]]
    if {$reverse} {
      return [lreverse $result]
    }
    return $result
  }

  method cget args {
    return [my Config_get {*}$args]
  }

  method config {method args} {
    my variable config
    set methodlist {add append branchset dump get incr initial lappend merge remove replace reset rmerge set unset update}
    switch $method {
      add {
        set field [string trimright [lindex $args 0] :/-]
        set data [dict getnull $config $field]
        foreach item [lrange $args 1 end] {
          if {$item ni $data} {
            lappend data $item
          }
        }
        dict set config $field $data
      }
      append {
        return [dict $method config {*}$args]
      }
      branchset {
        foreach {field value} [lindex $args end] {
          dict set config {*}[lrange $args 0 end-1] [string trimright $field :/] $value
        }
      }
      dump {
        return $config
      }
      get {
        return [my Config_get {*}$args]
      }
      incr {
        return [dict incr config {*}$args]
      }
      initial {
        return [my clay get public/ dict/ config/]
      }
      lappend {
        return [dict lappend config {*}$args]
      }
      merge {
        return [my Config_merge {*}$args]
      }
      remove {
        set field [string trimright [lindex $args 0] :/-]
        set data [dict getnull $config $field]
        set result {}
        foreach item $data {
          if {$item in $args} continue
          lappend result $item
        }
        dict set config $field $result
      }
      replace {
        set config [dict rmerge $config [my clay get public/ dict/ config/] {*}$args]
      }
      reset {
        set config [my clay get public/ dict/ config/]
        return $config
      }
      rmerge {
        set config [dict rmerge $config {*}$args]
        return $config
      }
      set {
        my Config_set {*}$args
      }
      unset {
        return [dict $method config {*}$args]
      }
      update {
        return [dict $method config {*}$args]
      }
      <list> {return $methodlist} default {
        return [dict $method $config {*}$args]
      }
    }
  }


  method configure args {
    # Will be removed at the end of "configurelist_triggers"
    set dictargs [::clay::args_to_options {*}$args]
    if {[llength $dictargs] == 1} {
      return [my cget [lindex $dictargs 0]]
    }
    set dat [my Config_merge $dictargs]
    my Config_triggers $dat
  }

  method Config_get {field args} {
    my variable config claycache
    set field [string trim $field -:/]
    if {[dict exists $claycache option_canonical $field]} {
      set field [dict get $claycache option_canonical $field]
    }
    set script [my clay get public/ option/ $field get-command]
    if {$script ne {}} {
        return [{*}[string map [list %field% [list $field] %self% [namespace which my]] $script]]
    }
    if {[dict exists $config $field]} {
      return [dict get $config $field]
    }
    if {[llength $args]} {
      return [lindex $args 0]
    }
    foreach branch {const/ {}} {
      if {[my clay exists {*}$branch $field]} {
        return [my clay get {*}$branch $field]
      }
    }
    return {}
  }

  method Config_merge dictargs {
    my variable config claycache
    set rawlist $dictargs
    set dictargs {}
    set dat [dict getnull $claycache option/]
    foreach {field val} $rawlist {
      set field [string trim $field -:/]
      if {[dict exists $claycache option_canonical $field]} {
        set field [dict get $claycache option_canonical $field]
      }
      dict set dictargs $field $val
    }
    ###
    # Validate all inputs
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field validate-command]
      if {$script ne {}} {
        dict set dictargs $field [eval [string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]]
      }
    }
    ###
    # Apply all inputs with special rules
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field set-command]
      dict set config $field $val
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
    return $dictargs
  }

  method Config_triggers dictargs {
    my variable claycache
    set dat [dict getnull $claycache option/]
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field post-command]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
  }

  method Config_set args {
    set dictargs [::tool::args_to_options {*}$args]
    set dat [my Config_merge $dictargs]
    my Config_triggers $dat
  }

  method DestroyEvent {} {
    my variable DestroyEvent
    return $DestroyEvent
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
    my variable clayorder clay claycache config
    set claycache {}
    set clayorder [::clay::ancestors [info object class [self]] {*}[info object mixins [self]]]
    if {[info exists meta]} {
      set emap [dict getnull $clay method_ensemble/]
    } else {
      set emap {}
    }
    if {![info exists config]} {
      set config {}
    }
    if {$::clay::trace>2} {
      puts "Rebuilding Ensembles"
    }
    ###
    # Dict for new configuration items
    ###
    set newconfig {}
    foreach class $clayorder {
      foreach {var value} [$class clay get public/ variable/] {
        set var [string trim $var :/]
        if { $var in {meta} } continue
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
        if { $var eq {meta} } continue
        my variable $var
        if {![info exists $var]} { array set $var {} }
        foreach {f v} $value {
          if {![array exists ${var}($f)]} {
            if {$::clay::trace>2} {puts [list initialize array $var\($f\) $v]}
            set ${var}($f) $v
          }
        }
      }
      foreach {var info} [$class clay get public/ option/] {
        set var [string trim $var :/-]
        foreach {f v} $info {
          if {![dict exist $claycache option/ $var $f]} {
            dict set $claycache public/ option/ $var $f $v
          }
        }
        dict set claycache option/ $var $info
        foreach alias [dict getnull $info aliases] {
          if {![dict exists $claycache option_canonical $alias]} {
            dict set claycache option_canonical $alias $var
          }
        }
        dict set claycache option_canonical $var $var
        if {[dict exists $newconfig $var]} continue
        if {[dict exists $config $var]} continue
        if {[dict getnull $info class] eq "organ"} {
          if {[my organ $var] ne {}} continue
        }
        set getcmd [dict getnull $info default-command]
        if {$getcmd ne {}} {
          dict set newconfig $var [{*}[string map [list %field% $var %self% [namespace which my]] $getcmd]]
        } else {
          dict set newconfig $var [dict getnull $info default]
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
          set method [string trim $method :./]
          if {[dict exists $emap $ensemble $method]} continue
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
    foreach {f v} $newconfig {
      dict set config $f $v
      set script [dict getnull $claycache option/ $f set-command]
      if {[string length $script]} {
        {*}[string map [list %field% [list $f] %value% [list $v] %self% [namespace which my]] $script]
      }
    }
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
    my variable config meta
    if {![info exists meta]} {
      set clay {}
    }
    if {![info exists config]} {
      set config {}
    }
    my Ensembles_Rebuild
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
    my clay mixin {*}$args
  }

  method mixinmap args {
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
    my Meta_Mixin {*}$classlist

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

  method debug_mixinmap {} {
    my variable mixinmap
    return $mixinmap
  }

  method clay {submethod args} {
    my variable clay claycache clayorder
    if {![info exists meta]} {set clay {}}
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
        }
        return {}
      }
      dump {
        # Do a full dump of clay data
        set result $clay
        # Search in the in our list of classes for an answer
        foreach class $clayorder {
          set result [::clay::dictmerge $result [$class clay dump]]
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
        if {$leaf} {
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
        } else {
          set result {}
          # Leaf searches return one data field at a time
          # Search in our local dict
          if {[dict exists $clay {*}$args]} {
            set result [dict get $clay {*}$args]
          }
          # Search in the in our list of classes for an answer
          foreach class $clayorder {
            set result [::clay::dictmerge $result [$class clay get {*}$args]]
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
        ::clay::dictmerge clay {*}$args
      }
      mixin {
        my Meta_Mixin {*}$args
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
        dict set clay {*}$args
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }


  method Meta_Mixin args {
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
      if {$class in $newmixin} continue
      set script [$class clay search mixin/ unmap-script]
      if {[string length $script]} {
        if {[catch $script err errdat]} {
          puts stderr "[self] MIXIN ERROR POPPING $class:\n[dict get $errdat -errorinfo]"
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
      if {$class in $prior} continue
      set script [$class clay search mixin/ map-script]
      if {[string length $script]} {
        if {[catch $script err errdat]} {
          puts stderr "[self] MIXIN ERROR PUSHING $class:\n[dict get $errdat -errorinfo]"
        }
      }
    }
    foreach class $newmixin {
      set script [$class clay search mixin/ react-script]
      if {[string length $script]} {
        if {[catch $script err errdat]} {
          puts stderr "[self] MIXIN ERROR PEEKING $class:\n[dict get $errdat -errorinfo]"
        }
      }
    }
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
      my Ensembles_Rebuild
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

  method Option_Default field {
    my variable claycache
    set info [dict getnull $claycache option/ $field]
    set getcmd [dict getnull $info default-command]
    if {$getcmd ne {}} {
      return [{*}[string map [list %field% $field %self% [namespace which my]] $getcmd]]
    } else {
      return [dict getnull $info default]
    }
  }

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
