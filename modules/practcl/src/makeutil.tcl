###
# Backward compatible Make facilities
# These were used early in development and are consdiered deprecated
###

proc ::practcl::trigger {args} {
  ::practcl::LOCAL target trigger {*}$args
  foreach {name obj} [::practcl::LOCAL target objects] {
    set ::make($name) [$obj do]
  }
}

proc ::practcl::depends {args} {
  ::practcl::LOCAL target depends {*}$args
}

proc ::practcl::target {name info {action {}}} {
  set obj [::practcl::LOCAL target add $name $info $action]
  set ::make($name) 0
  set filename [$obj define get filename]
  if {$filename ne {}} {
    set ::target($name) $filename
  }
}
