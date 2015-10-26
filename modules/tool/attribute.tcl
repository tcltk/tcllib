::namespace eval ::tool::define {}

###
# topic: 81d7c2cf0bf3660fdf9f8d402568af588b80b0ae
# description:
#    Tools for managing externally stored attributes
#    for objects
###
proc ::tool::define::attribute {field argdict} {
  set class [lindex [::info level -1] 1]
  ::oo::meta::info $class branchset attribute $argdict
}

