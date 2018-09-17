oo::define oo::class {

  ###
  # description:
  # The [method clay] method allows a class object access
  # to a combination of its own clay data as
  # well as to that of its ancestors
  # ensemble:
  # ancestors {
  #   arglist {}
  #   description {Return this class and all ancestors in search order.}
  # }
  # dump {
  #   arglist {}
  #   description {Return a complete dump of this object's clay data, but only this object's clay data.}
  # }
  # get {
  #   arglist {path {mandatory 1 positional 1 repeating 1}}
  #   description {
  #     Pull a chunk of data from the clay system. If the last element of [emph path] is a branch (ends in a slash /),
  #     returns a recursive merge of all data from this object and it's constituent classes of the data in that branch.
  #     If the last element is a leaf, search this object for a matching leaf, or search all  constituent classes for a matching
  #     leaf and return the first value found.
  #     If no value is found, returns an empty string.
  #   }
  # }
  # merge {
  #   arglist {dict {mandatory 1 positional 1 repeating 1}}
  #   description {Recursively merge the dictionaries given into the object's local clay storage.}
  # }
  # replace {
  #   arglist {dictionary {mandatory 1 positional 1}}
  #   description {Replace the contents of the internal clay storage with the dictionary given.}
  # }
  # search {
  #   arglist {path {mandatory 1 positional 1 repeating 1}}
  #   description {Return the first matching value for the path in either this class's clay data or one of its ancestors}
  # }
  # set {
  #   arglist {path {mandatory 1 positional 1 repeating 1} value {mandatory 1 postional 1}}
  #   description {Merge the conents of [const value] with the object's clay storage at [const path].}
  # }
  ###
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
