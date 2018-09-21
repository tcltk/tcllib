::namespace eval ::tool::define {}

if {![info exists ::tool::dirty_classes]} {
  set ::tool::dirty_classes {}
}

###
# Monkey patch oometa's rebuild function to
# include a notifier to tool
###
proc ::oo::meta::rebuild args {
}

proc ::tool::ensemble_build_map args {
  set emap {}
  foreach thisclass $args {
    foreach {ensemble einfo} [$thisclass clay get method_ensemble] {
      if {$ensemble eq {.}} continue
      foreach {submethod subinfo} $einfo {
        if {$submethod eq {.}} continue
        dict set emap $ensemble $submethod $subinfo
      }
    }
  }
  return $emap
}

###
# topic: ec9ca249b75e2667ad5bcb2f7cd8c568
# title: Define an ensemble method for this agent
###
::proc ::tool::define::method {rawmethod args}  {
  set class [current_class]
  set mlist [split $rawmethod "::"]
  set ensemble [string trim [lindex $mlist 0] :/]
  switch [llength $args] {
    1 {
      set arglist args
      set body [lindex $args 0]
    }
    2 {
      lassign $args arglist body
    }
    default {
      error "Usage: method NAME?::SUBMETHOD? ?arglist? body"
    }
  }
  set mensemble ${ensemble}/
  if {[llength $mlist]==1} {
    ::oo::define $class method $rawmethod $arglist $body
    return
  }
  if {[lindex $mlist 1] in "_body"} {
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
# topic: 354490e9e9708425a6662239f2058401946e41a1
# description: Creates a method which exports access to an internal dict
###
proc ::tool::define::dictobj args {
  dict_ensemble {*}$args
}
proc ::tool::define::dict_ensemble {methodname varname {cases {}}} {
  set class [current_class]
  set CASES [string map [list %METHOD% $methodname %VARNAME% $varname] $cases]
  set methodname [string trim $methodname /:-]
  set methoddata [$class clay get method_ensemble $methodname]
  set initial [dict remove [dict getnull $cases initialize] .]

  ::clay::define::Dict $varname $initial
  variable $varname $initial

  dict for {name body} $CASES {
    if {$name eq {.}} continue
    set name [string trim $name :/-]
    dict set methoddata $name  [dict create arglist args body $body]
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
      set result [my meta branchget %VARNAME%]
      ::dicttool::dictmerge result {%INITIAL%}
      return [dict remove $result .]
    }
    reset {} {
      set %VARNAME% [my meta branchget %VARNAME%]
      return [dict remove [::dicttool::dictmerge %VARNAME% {%INITIAL%}] .]
    }
    dump {} {
      return [dict remove $%VARNAME% .]
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
      ::dicttool::dictmerge %VARNAME% {*}$args
      return $%VARNAME%
    }
    replace args {
      set %VARNAME% {%INITIAL%}
      ::dicttool::dictmerge %VARNAME% {*}$args
      return $%VARNAME%
    }
    default args {
      return [dict $method $%VARNAME% {*}$args]
    }
  }]
  foreach {name arglist body} $template {
    if {$name eq {.}} continue
    set name [string trim $name :/-]
    if {[dict exists $methoddata $name]} continue
    dict set methoddata $name [dict create arglist $arglist body $body]
  }
  $class clay set method_ensemble $methodname $methoddata
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
  set initial [dict remove [dict getnull $cases initialize] .]
  ::clay::define::Array $varname $initial

  set map [list %CLASS% $class %METHOD% $methodname %VARNAME% $varname %CASES% $CASES %INITIAL% $initial]

  ::oo::define $class method _${methodname}Get {field} [string map $map {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return $%VARNAME%($field)
    }
    return [dict remove [my meta getnull %VARNAME% $field:] .]
  }]
  ::oo::define $class method _${methodname}Exists {field} [string map $map {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return 1
    }
    return [my meta exists %VARNAME% $field:]
  }]

  set methodname [string trim $methodname /:-]
  set methoddata [$class clay get method_ensemble/ $methodname/]
  dict for {name body} $CASES {
    if {$name eq {.}} continue
    set name [string trim $name :/-]
    dict set methoddata $name  [dict create arglist args body $body]
  }
  set template  [string map [list %CLASS% $class %INITIAL% $initial %METHOD% $methodname %VARNAME% $varname] {
    _preamble {} {
      my variable %VARNAME%
    }
    reset {} {
      ::array unset %VARNAME% *
      foreach {var value} [my clay get array/ %VARNAME%/] {
        set var [string trim $var :/-]
        if {![array exists %VARNAME%($var)]} {
          if {$::clay::trace>2} {puts [list initialize array %VARNAME%\($var\) $value]}
          set %VARNAME%($var) $value
        }
      }
      foreach {var value} [my clay get %VARNAME%/] {
        set var [string trim $var :/-]
        if {![array exists %VARNAME%($var)]} {
          if {$::clay::trace>2} {puts [list initialize array %VARNAME%\($var\) $value]}
          set %VARNAME%($var) $value
        }
      }
      dict for {field value} [dict remove [my meta getnull %VARNAME%] .] {
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
      dict for {var val} [my meta getnull %VARNAME%] {
        dict set result [string trimright $var :] $val
      }
      foreach {var val} [lsort -dictionary -stride 2 [array get %VARNAME%]] {
        dict set result [string trimright $var :] $val
      }
      return [dict remove $result .]
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
    if {$name eq {.}} continue
    set name [string trim $name :/-]
    if {[dict exists $methoddata $name]} continue
    dict set methoddata $name [dict create arglist $arglist body $body]
  }
  #puts [list $class $methodname/ $methoddata]
  $class clay set method_ensemble/ $methodname/ $methoddata
}

