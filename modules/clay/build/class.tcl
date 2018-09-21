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
  # find {
  #   arglist {path {mandatory 1 positional 1 repeating 1}}
  #   description {
  #     Pull a chunk of data from the clay system. If the last element of [emph path] is a branch,
  #     returns a recursive merge of all data from this object and it's constituent classes of the data in that branch.
  #     If the last element is a leaf, search this object for a matching leaf, or search all  constituent classes for a matching
  #     leaf and return the first value found.
  #     If no value is found, returns an empty string.
  #     If a branch is returned the topmost . entry is omitted.
  #   }
  # }
  # get {
  #   arglist {path {mandatory 1 positional 1 repeating 1}}
  #   description {
  #     Pull a chunk of data from the class's clay system.
  #     If no value is found, returns an empty string.
  #     If a branch is returned the topmost . entry is omitted.
  #   }
  # }
  # GET {
  #   arglist {path {mandatory 1 positional 1 repeating 1}}
  #   description {
  #     Pull a chunk of data from the class's clay system.
  #     If no value is found, returns an empty string.
  #   }
  #}
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
        if {![info exists clay]} {
          return 0
        }
        return [dict exists $clay {*}[::dicttool::storage $args]]
      }
      dump {
        return $clay
      }
      dget {
         if {![info exists clay]} {
          return {}
        }
        set path [::dicttool::storage $args]
        if {![dict exists $clay {*}$path]} {
          return {}
        }
        return [dict get $clay {*}$path]
      }
      getnull -
      get {
        if {![info exists clay]} {
          return {}
        }
        set path [::dicttool::storage $args]
        if {[dict exists $clay {*}$path .]} {
          return [::dicttool::sanitize [dict get $clay {*}$path]]
        }
        if {[dict exists $clay {*}$path]} {
          return [dict get $clay {*}$path]
        }
        return {}
      }
      find {
        set path [::dicttool::storage $args]
        if {![info exists clay]} {
          set clay {}
        }
        set clayorder [::clay::ancestors [self]]
        set found 0
        foreach class $clayorder {
          if {[$class clay exists {*}$path .]} {
            # Found a branch break
            set found 1
            break
          }
          if {[$class clay exists {*}$path]} {
            # Found a leaf. Return that value immediately
            return [$class clay get {*}$path]
          }
        }
        if {!$found} {
          return {}
        }
        set result {}
        # Leaf searches return one data field at a time
        # Search in our local dict
        # Search in the in our list of classes for an answer
        foreach class [lreverse $clayorder] {
          ::dicttool::dictmerge result [$class clay dget {*}$path]
        }
        return [::dicttool::sanitize $result]
      }
      merge {
        foreach arg $args {
          ::dicttool::dictmerge clay {*}$arg
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
        ::dicttool::dictset clay {*}$args
      }
      default {
        dict $submethod clay {*}$args
      }
    }
  }
}
