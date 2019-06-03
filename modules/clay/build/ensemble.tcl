::namespace eval ::clay::define {}

proc ::clay::ensemble_methodbody {ensemble einfo} {
  set default standard
  set preamble {}
  set eswitch {}
  if {[dict exists $einfo default]} {
    set emethodinfo [dict get $einfo default]
    set argspec     [dict getnull $emethodinfo argspec]
    set realbody    [dict getnull $emethodinfo body]
    set argstyle    [dict getnull $emethodinfo argstyle]
    if {$argstyle eq "dictargs"} {
      set body "\n      ::dictargs::parse \{$argspec\} \$args"
    } elseif {[llength $argspec]==1 && [lindex $argspec 0] in {{} args arglist}} {
      set body {}
    } else {
      set body "\n      ::clay::dynamic_arguments $ensemble \$method [list $argspec] {*}\$args"
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
    set argspec     [dict getnull $esubmethodinfo argspec]
    set realbody    [dict getnull $esubmethodinfo body]
    set argstyle    [dict getnull $esubmethodinfo argstyle]
    if {[string length [string trim $realbody]] eq {}} {
      dict set eswitch $submethod {}
    } else {
      if {$argstyle eq "dictargs"} {
        set body "\n      ::dictargs::parse \{$argspec\} \$args"
      } elseif {[llength $argspec]==1 && [lindex $argspec 0] in {{} args arglist}} {
        set body {}
      } else {
        set body "\n      ::clay::dynamic_arguments $ensemble \$method [list $argspec] {*}\$args"
      }
      append body "\n      " [string trim $realbody] "      \n"
      if {$submethod eq "default"} {
        set default $body
      } else {
        foreach alias [dict getnull $esubmethodinfo aliases] {
          dict set eswitch $alias -
        }
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

::proc ::clay::define::Ensemble {rawmethod args} {
  if {[llength $args]==2} {
    lassign $args argspec body
    set argstyle tcl
  } elseif {[llength $args]==3} {
    lassign $args argstyle argspec body
  } else {
    error "Usage: Ensemble name ?argstyle? argspec body"
  }
  set class [current_class]
  #if {$::clay::trace>2} {
  #  puts [list $class Ensemble $rawmethod $argspec $body]
  #}
  set mlist [split $rawmethod "::"]
  set ensemble [string trim [lindex $mlist 0] :/]
  set mensemble ${ensemble}/
  if {[llength $mlist]==1 || [lindex $mlist 1] in "_body"} {
    set method _body
    ###
    # Simple method, needs no parsing, but we do need to record we have one
    ###
    if {$argstyle eq "dictargs"} {
      set argspec [list args $argspec]
    }
    $class clay set method_ensemble/ $mensemble _body [dict create argspec $argspec body $body argstyle $argstyle]
    if {$::clay::trace>2} {
      puts [list $class clay set method_ensemble/ $mensemble _body ...]
    }
    set method $rawmethod
    if {$::clay::trace>2} {
      puts [list $class Ensemble $rawmethod $argspec $body]
      set rawbody $body
      set body {puts [list [self] $class [self method]]}
      append body \n $rawbody
    }
    if {$argstyle eq "dictargs"} {
      set rawbody $body
      set body "::dictargs::parse \{$argspec\} \$args\; "
      append body $rawbody
    }
    ::oo::define $class method $rawmethod $argspec $body
    return
  }
  set method [join [lrange $mlist 2 end] "::"]
  $class clay set method_ensemble/ $mensemble [string trim [lindex $method 0] :/] [dict create argspec $argspec body $body argstyle $argstyle]
  if {$::clay::trace>2} {
    puts [list $class clay set method_ensemble/ $mensemble [string trim $method :/]  ...]
  }
}


