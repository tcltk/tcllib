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
