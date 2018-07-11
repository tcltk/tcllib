::clay::define ::tool::class {
  method clay {submethod args} {
    my variable clay
    if {![info exists clay]} {
      set clay {}
    }
    switch $submethod {
      ancestors {
        tailcall ::clay::ancestors [self]
      }
      branchset {
        set value [lindex $args end]
        set path [::clay::path {*}[lrange $args 0 end-1]]
        ::clay::dictmerge clay {*}$path $value
      }
      exists {
        set path [::clay::leaf {*}$args]
        if {![info exists clay]} {
          return 0
        }
        return [dict exists $clay {*}$path]
      }
      dump {
        return $clay
      }
      getnull -
      get {
        if {[llength $args]==0} {
          return $clay
        }
        if {![dict exists $clay {*}$args]} {
          return {}
        }
        tailcall dict get $clay {*}$args
      }
      merge {
        foreach arg $args {
          ::clay::dictmerge clay {*}$arg
        }
      }
      search {
        foreach aclass [::clay::ancestors [self]] {
          if {[$aclass clay exists {*}$args]} {
            return [$aclass clay get {*}$args]
          }
        }
      }
      set {
        #puts [list [self] clay SET {*}$args]
        set value [lindex $args end]
        set path [::clay::leaf {*}[lrange $args 0 end-1]]
        ::clay::dictmerge clay {*}$path $value
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }
}
