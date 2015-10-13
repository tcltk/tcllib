::namespace eval ::oo::define {}
###
# topic: 354490e9e9708425a6662239f2058401946e41a1
# description: Creates a method which exports access to an internal dict
###
proc ::oo::define::dictobj {methodname varname {cases {}}} {
  set class [lindex [::info level -1] 1]
  set CASES [string map [list %METHOD% $methodname %VARNAME% $varname] $cases]
  set def [string map [list %METHOD% $methodname %VARNAME% $varname %CASES% $CASES] {
  method %METHOD% {subcommand args} {
    my variable %VARNAME%
    switch $subcommand {
      %CASES%
      add {
        set value [dict getnull $%VARNAME% {*}[lindex $args 0]]
        ladd value {*}[lrange $args 1 end]
        dict set %VARNAME% {*}[lindex $args 0] $value
      }
      dump {
        return $%VARNAME%
      }
      append -
      incr -
      lappend -
      set -
      unset -
      update {
        return [dict $subcommand %VARNAME% {*}$args]
      }
      branchset {
        foreach {field value} [lindex $args end] {
          dict set %VARNAME% {*}[lrange $args 0 end-1] [string trimright $field :]: $value
        }
      }
      rmerge -
      merge {
        set %VARNAME% [dict rmerge $%VARNAME% {*}$args]
        return $%VARNAME%
      }
      default {
        return [dict $subcommand $%VARNAME% {*}$args]
      }
    }
  }
}]
  oo::define $class $def
}

###
# topic: 354490e9e9708425a6662239f2058401946e41a1
# description: Creates a method which exports access to an internal array
###
proc ::oo::define::arrayobj {methodname varname {cases {}}} {
  set class [lindex [::info level -1] 1]
  set CASES [string map [list %METHOD% $methodname %VARNAME% $varname] $cases]
  set def [string map [list %METHOD% $methodname %VARNAME% $varname %CASES% $CASES] {
    
  method _%METHOD%Get {field} {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return $%VARNAME%($field)
    }
    return [my meta getnull %VARNAME% $field:]
  }
  method _%METHOD%Exists {field} {
    my variable %VARNAME%
    if {[info exists %VARNAME%($field)]} {
      return 1
    }
    return [my meta exists %VARNAME% $field:]
  }
  method %METHOD% {subcommand args} {
    my variable %VARNAME%
    switch $subcommand {
      %CASES%
      add {
        set field [string trimright [lindex $args 0] :]
        set data [my _%METHOD%Get $field]
        ladd data {*}[lrange $args 1 end]
        set %VARNAME%($field) data
      }
      default {
        set field [string trimright [lindex $args 0] :]
        # Set a value if it doesn't already exist
        if {[my ]}
      }
      dump {
        foreach {var val} [my meta getnull %VARNAME%] {
          dict set result [string trimright $var :] $val
        }
        foreach {var val} [lsort -dictionary -stride 2 [array get %VARNAME%]] {
          dict set result [string trimright $var :] $val
        }
        return $result
      }
      exists {
        set field [string trimright [lindex $args 0] :]
        set data [my _%METHOD%Exists $field]
      }
      getnull -
      get {
        set field [string trimright [lindex $args 0] :]
        set data [my _%METHOD%Get $field]
      }
      set {
        set field [string trimright [lindex $args 0] :]
        $subcommand %VARNAME%($field) {*}[lrange $args 1 end]        
      }
      append -
      incr -
      lappend {
        set field [string trimright [lindex $args 0] :]
        set data [my _%METHOD%Get $field]
        $subcommand data {*}[lrange $args 1 end]
        set %VARNAME%($field) $data
      }
      branchset {
        foreach {field value} [lindex $args end] {
          set %VARNAME%([string trimright $field :]) $value
        }
      }
      rmerge -
      merge {
        foreach arg $args {
          my %VARNAME% branchset $arg
        }
      }
      default {
        return [array $subcommand %VARNAME% {*}$args]
      }
    }
  }
}]
  oo::define $class $def
}

