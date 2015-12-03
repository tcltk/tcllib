###
# Support for method ensembles
###

###
# topic: 7a5c7e04989704eef117ff3c9dd88823
# title: Specify the a method for the class object itself, instead of for objects of the class
###
proc ::tool::define::class_method {name arglist body} {
  set class [current_class]
  ::oo::meta::info $class set class_typemethod $name: [list $arglist $body]
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
# topic: 4969d897a83d91a230a17f166dbcaede
###
proc ::tool::dynamic_arguments {arglist args} {
  set idx 0
  set len [llength $args]
  if {$len > [llength $arglist]} {
    ###
    # Catch if the user supplies too many arguments
    ###
    set dargs 0
    if {[lindex $arglist end] ni {args dictargs}} {
      set string [dynamic_wrongargs_message $arglist]
      error $string
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
        set string [dynamic_wrongargs_message $arglist]
        error $string
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
# topic: fb8d74e9c08db81ee6f1275dad4d7d6f
###
proc ::tool::dynamic_methods_ensembles {thisclass metadata} {
  variable trace
  set ensembledict {}
  if {$trace} { puts "dynamic_methods_ensembles $thisclass"}
  foreach {ensemble einfo} [dict getnull $metadata method_ensemble] {
    set eswitch {}
    set default standard
    if {[dict exists $einfo default:]} {
      set emethodinfo [dict get $einfo default:]
      set arglist     [lindex $emethodinfo 0]
      set realbody    [lindex $emethodinfo 1]
      set body "\n      ::tool::dynamic_arguments [list $arglist] {*}\$args"
      append body "\n      " [string trim $realbody] "      \n"
      set default $body
      dict unset einfo default:
    }
    set eswitch \n
    append eswitch "\n    [list <list> [list return [lsort -dictionary [dict keys $einfo]]]]" \n
    foreach {submethod esubmethodinfo} [lsort -dictionary -stride 2 $einfo] {
      set submethod [string trimright $submethod :]
      lassign $esubmethodinfo arglist realbody
      if {[string length [string trim $realbody]] eq {}} {
        append eswitch "    [list $submethod {}]" \n
      } else {
        set body "\n      ::tool::dynamic_arguments [list $arglist] {*}\$args"
        append body "\n      " [string trim $realbody] "      \n"
        append eswitch "    [list $submethod $body]" \n
      }
    }
    if {$default=="standard"} {
      set default "error \"unknown method $ensemble \$method. Valid: [lsort -dictionary [dict keys $eswitch]]\""
    }
    append eswitch [list default $default] \n
    set body {}
    append body \n "set code \[catch {switch -- \$method [list $eswitch]} result opts\]"

    #if { $ensemble == "action" } {
    #  append body \n {  if {$code == 0} { my event generate event $method {*}$dictargs}}
    #}
    append body \n {return -options $opts $result}
    oo::define $thisclass method $ensemble {{method default} args} $body
    # Define a property for this ensemble for introspection
    ::oo::meta::info $thisclass set ensemble_methods $ensemble: [lsort -dictionary [dict keys $einfo]]
  }
  if {$trace} { puts "/dynamic_methods_ensembles $thisclass"}
}

###
# topic: 53ab28ac5c6ee601fe1fe07b073be88e
###
proc ::tool::dynamic_wrongargs_message arglist {
  set result "Wrong # args: should be:"
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
