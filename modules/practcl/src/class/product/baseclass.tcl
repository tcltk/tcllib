
::oo::class create ::practcl::product {
  superclass ::practcl::object

  method linktype {} {
    return {subordinate product}
  }

  method include header {
    my define add include $header
  }

  method cstructure {name definition {argdat {}}} {
    my variable cstruct
    dict set cstruct $name body $definition
    foreach {f v} $argdat {
      dict set cstruct $name $f $v
    }
    if {![dict exists $cstruct $name public]} {
      dict set cstruct $name public 1
    }
  }

  method generate-cinit {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(cinit)]} {
      ::practcl::cputs result $code(cinit)
    }
    if {[my define get initfunc] ne {}} {
      ::practcl::cputs result "  if([my define get initfunc](interp)!=TCL_OK) return TCL_ERROR\;"
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach obj [my link list product] {
      ::practcl::cputs result [$obj generate-cinit]
    }
    return $result
  }
}

###
# Flesh out several trivial varieties of product
###
::oo::class create ::practcl::cheader {
  superclass ::practcl::product

  method compile-products {} {}
  method generate-cinit {} {}
}

::oo::class create ::practcl::csource {
  superclass ::practcl::product
}

::oo::class create ::practcl::clibrary {
  superclass ::practcl::product

  method linker-products {configdict} {
    return [my define get filename]
  }

}
