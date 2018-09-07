oo::define oo::class {
  method clay {submethod args} {
    my variable clay
    if {![info exists clay]} {
      set clay {}
    }
    switch $submethod {
      ancestors {
        tailcall ::clay::ancestors [self]
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
        set path $args
        set leaf [expr {[string index [lindex $path end] end] ne "/"}]
        set clayorder [::clay::ancestors [self]]
        #puts [list [self] clay get {*}$path (leaf: $leaf)]
        if {$leaf} {
          #puts [list EXISTS: (clay) [dict exists $clay {*}$path]]
          if {[dict exists $clay {*}$path]} {
            return [dict get $clay {*}$path]
          }
          #puts [list Search in the in our list of classes for an answer]
          foreach class $clayorder {
            if {$class eq [self]} continue
            if {[$class clay exists {*}$path]} {
              set value [$class clay get {*}$path]
              return $value
            }
          }
        } else {
          set result {}
          # Leaf searches return one data field at a time
          # Search in our local dict
          # Search in the in our list of classes for an answer
          foreach class [lreverse $clayorder] {
            if {$class eq [self]} continue
            ::clay::dictmerge result [$class clay get {*}$path]
          }
          if {[dict exists $clay {*}$path]} {
            ::clay::dictmerge result [dict get $clay {*}$path]
          }
          return $result
        }
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
