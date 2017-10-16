
::oo::class create ::practcl::target_obj {
  superclass ::practcl::metaclass

  constructor {name info} {
    my variable define triggered domake
    set triggered 0
    set domake 0
    set define(name) $name
    set data  [uplevel 2 [list subst $info]]
    array set define $data
    my select
    my initialize
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
    set needs_make 0
    foreach item [my define get depends] {
      if {![dict exists $::make_objects $item]} continue
      set depobj [dict get $::make_objects $item]
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
    foreach item [my define get depends] {
      if {![dict exists $::make_objects $item]} continue
      set depobj [dict get $::make_objects $item]
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
    if {[info exists ::make($define(name))] && $::make($define(name))} {
      return
    }
    set ::make($define(name)) 1
    ::practcl::trigger {*}[my define get triggers]
  }
}
