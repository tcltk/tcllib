
::oo::class create ::practcl::target_obj {
  superclass ::practcl::metaclass

  constructor {module_object name info {action_body {}}} {
    my variable define triggered domake
    set triggered 0
    set domake 0
    set define(name) $name
    set define(action) {}
    array set define $info
    my select
    my initialize
    foreach {stub obj} [$module_object child organs] {
      my graft $stub $obj
    }
    if {$action_body ne {}} {
      set define(action) $action_body
    }
  }

  method do {} {
    my variable domake
    return $domake
  }

  method check {} {
    my variable needs_make domake
    if {$domake} {
      return 1
    }
    if {[info exists needs_make]} {
      return $needs_make
    }
    set make_objects [my <module> target objects]
    set needs_make 0
    foreach item [my define get depends] {
      if {![dict exists $make_objects $item]} continue
      set depobj [dict get $make_objects $item]
      if {$depobj eq [self]} {
        puts "WARNING [self] depends on itself"
        continue
      }
      if {[$depobj check]} {
        set needs_make 1
      }
    }
    if {!$needs_make} {
      set filename [my define get filename]
      if {$filename ne {} && ![file exists $filename]} {
        set needs_make 1
      }
    }
    return $needs_make
  }

  method triggers {} {
    my variable triggered domake define
    if {$triggered} {
      return $domake
    }
    set triggered 1
    set make_objects [my <module> target objects]

    foreach item [my define get depends] {
      if {![dict exists $make_objects $item]} continue
      set depobj [dict get $make_objects $item]
      if {$depobj eq [self]} {
        puts "WARNING [self] triggers itself"
        continue
      } else {
        set r [$depobj check]
        if {$r} {
          $depobj triggers
        }
      }
    }
    set domake 1
    my <module> target trigger {*}[my define get triggers]
  }
}
