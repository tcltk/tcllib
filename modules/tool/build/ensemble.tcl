::namespace eval ::tool::define {}

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
  set method [string trim [join [lrange $mlist 2 end] "::"] :/]
  switch [llength $args] {
    1 {
      $class clay set method_ensemble/ $ensemble/ $method [list arglist dictargs body [lindex $args 0]]
    }
    2 {
      $class clay set method_ensemble/ $ensemble/ $method [list arglist [lindex $args 0] body [lindex $args 1]]
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

  if {![$class clay exists public/ dict/ $varname/]} {
    $class clay set  public/ dict/ $varname/ {}
  }
  set methoddata {}
  foreach {name body} $CASES {
    if {$name eq "initialize"} {
      foreach {f v} $body {
        $class clay set public/ dict/ ${varname}/ $f $v
      }
    } else {
      dict set methoddata $name [list arglist args body $body]
      $class clay set method_ensemble/ $methodname/ $name [list arglist args body $body]
    }
  }

  foreach aclass [::clay::ancestors $class] {
    foreach {smethod info} [$class clay get method_ensemble/ $methodname/] {
      if {![dict exists $methoddata $smethod]} {
        dict set $methoddata $smethod $info
      }
    }
  }
  set template [string map [list %CLASS% $class %METHOD% $methodname %VARNAME% $varname] {
    _preamble {} {
      my variable %VARNAME%
    }
    add args {
      set field [string trimright [lindex $args 0] :/-]
      set data [dict getnull $%VARNAME% $field]
      foreach item [lrange $args 1 end] {
        if {$item ni $data} {
          lappend data $item
        }
      }
      dict set %VARNAME% $field $data
    }
    remove args {
      set field [string trimright [lindex $args 0] :/-]
      set data [dict getnull $%VARNAME% $field]
      set result {}
      foreach item $data {
        if {$item in $args} continue
        lappend result $item
      }
      dict set %VARNAME% $field $result
    }
    initial {} {
      return [my clay get public/ dict/ %VARNAME%/]
    }
    reset {} {
      set %VARNAME% [my clay get public/ dict/ %VARNAME%/]
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
        dict set %VARNAME% {*}[lrange $args 0 end-1] [string trimright $field :/] $value
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
      set %VARNAME% [dict rmerge $%VARNAME% [my clay get public/ dict/ %VARNAME%/] {*}$args]
    }
    default args {
      return [dict $method $%VARNAME% {*}$args]
    }
  }]
  foreach {name arglist body} $template {
    if {[dict exists $methoddata $name]} continue
    $class clay set method_ensemble/ $methodname/ $name [list arglist $arglist body $body]
  }
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


  if {![$class clay exists public/ array/ $varname/]} {
    $class clay set  public/ array/ $varname/ {}
  }

  foreach {name body} $CASES {
    if {$name eq "initialize"} {
      foreach {f v} $body {
        $class clay set public/ array/ ${varname}/ $f $v
      }
    } else {
      dict set methoddata $name [list arglist args body $body]
      $class clay set method_ensemble/ $methodname/ $name [list arglist args body $body]
    }
  }

  foreach aclass [::clay::ancestors $class] {
    foreach {smethod info} [$class clay get method_ensemble/ $methodname/] {
      if {![dict exists $methoddata $smethod]} {
        dict set $methoddata $smethod $info
      }
    }
  }
  set map [list %CLASS% $class %METHOD% $methodname %VARNAME% $varname %CASES% $CASES]

  set template  [string map [list %CLASS% $class %METHOD% $methodname %VARNAME% $varname] {
    _preamble {} {
      my variable %VARNAME%
    }
    reset {} {
      ::array unset %VARNAME% *
      foreach {field value} [my clay get public/ array/ %VARNAME%/] {
        set %VARNAME%([string trimright $field :]) $value
      }
      return [array get %VARNAME%]
    }
    ni value {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        return 0
      }
      return [expr {$value ni $%VARNAME%($field)}]
    }
    in value {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        return 0
      }
      return [expr {$value in $%VARNAME%($field)}]
    }
    add args {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        set %VARNAME%($field) {}
      }
      foreach item [lrange $args 1 end] {
        if {$item ni $%VARNAME%($field)} {
          lappend %VARNAME%($field) $item
        }
      }
    }
    remove args {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        return
      }
      set result {}
      set mods 0
      foreach item $%VARNAME%($field) {
        if {$item in $args} {
          incr mods
        } else {
          lappend result $item
        }
      }
      if {$mods} {
        set %VARNAME%($field) $result
      }
    }
    dump {} {
      return [array get %VARNAME%]
    }
    exists args {
      set field [string trimright [lindex $args 0] :-]
      return [info exists %VARNAME%($field)]
    }
    getnull args {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        return
      }
      return $%VARNAME%($field)
    }
    get field {
      set field [string trimright [lindex $args 0] :-]
      if {![info exists %VARNAME%($field)]} {
        return
      }
      return $%VARNAME%($field)
    }
    set args {
      set field [string trimright [lindex $args 0] :-]
      ::set %VARNAME%($field) {*}[lrange $args 1 end]
    }
    append args {
      set field [string trimright [lindex $args 0] :-]
      ::append %VARNAME%($field) {*}[lrange $args 1 end]
    }
    incr args {
      set field [string trimright [lindex $args 0] :-]
      ::incr %VARNAME%($field) {*}[lrange $args 1 end]
    }
    lappend args {
      set field [string trimright [lindex $args 0] :-]
      lappend %VARNAME%($field) {*}[lrange $args 1 end]
    }
    branchset args {
      foreach {field value} [lindex $args end] {
        set %VARNAME%([string trimright $field :-]) $value
      }
    }
    rmerge args {
      foreach {field value} [lindex $args end] {
        set %VARNAME%([string trimright $field :-]) $value
      }
    }
    merge args {
      foreach {field value} [lindex $args end] {
        set %VARNAME%([string trimright $field :-]) $value
      }
    }
    default args {
      return [array $method %VARNAME% {*}$args]
    }
  }]
  foreach {name arglist body} $template {
    if {[dict exists $methoddata $name]} continue
    $class clay set method_ensemble/ $methodname/ $name [list arglist $arglist body $body]
  }
}

