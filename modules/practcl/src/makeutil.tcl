###
# Make facilities
###

proc ::practcl::trigger {args} {
  foreach name $args {
    if {[dict exists $::make_objects $name]} {
      [dict get $::make_objects $name] triggers
    }
  }
}

proc ::practcl::depends {args} {
  foreach name $args {
    if {[dict exists $::make_objects $name]} {
      [dict get $::make_objects $name] check
    }
  }
}

proc ::practcl::target {name info} {
  set obj [::practcl::target_obj new $name $info]
  dict set ::make_objects $name $obj
  if {[dict exists $info aliases]} {
    foreach item [dict get $info aliases] {
      if {![dict exists $::make_objects $item]} {
        dict set ::make_objects $item $obj
      }
    }
  }
  set ::make($name) 0
  set ::trigger($name) 0
  set filename [$obj define get filename]
  if {$filename ne {}} {
    set ::target($name) $filename
  }
}
