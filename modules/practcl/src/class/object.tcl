::oo::class create ::practcl::object {
  superclass ::practcl::metaclass

  constructor {parent args} {
    my variable links define
    set organs [$parent child organs]
    my graft {*}$organs
    array set define $organs
    array set define [$parent child define]
    array set links {}
    if {[llength $args]==1 && [file exists [lindex $args 0]]} {
      my InitializeSourceFile [lindex $args 0]
    } elseif {[llength $args] == 1} {
      set data  [uplevel 1 [list subst [lindex $args 0]]]
      array set define $data
      my select
      my initialize
    } else {
      array set define [uplevel 1 [list subst $args]]
      my select
      my initialize
    }
  }


  method include_dir args {
    my define add include_dir {*}$args
  }

  method include_directory args {
    my define add include_dir {*}$args
  }

  method Collate_Source CWD {}


  method child {method} {
    return {}
  }

  method InitializeSourceFile filename {
    my define set filename $filename
    set class {}
    switch [file extension $filename] {
      .tcl {
        set class ::practcl::dynamic
      }
      .h {
        set class ::practcl::cheader
      }
      .c {
        set class ::practcl::csource
      }
      .ini {
        switch [file tail $filename] {
          module.ini {
            set class ::practcl::module
          }
          library.ini {
            set class ::practcl::subproject
          }
        }
      }
      .so -
      .dll -
      .dylib -
      .a {
        set class ::practcl::clibrary
      }
    }
    if {$class ne {}} {
      oo::objdefine [self] class $class
      my initialize
    }
  }

  method add args {
    my variable links
    set object [::practcl::object new [self] {*}$args]
    foreach linktype [$object linktype] {
      lappend links($linktype) $object
    }
    return $object
  }

  method go {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable links
    foreach {linktype objs} [array get links] {
      foreach obj $objs {
        $obj go
      }
    }
    ::practcl::debug [list /[self] [self method] [self class]]
  }

  method code {section body} {
    my variable code
    ::practcl::cputs code($section) $body
  }

  method Ofile filename {
    set lpath [my <module> define get localpath]
    if {$lpath eq {}} {
      set lpath [my <module> define get name]
    }
    return ${lpath}_[file rootname [file tail $filename]].o
  }

  method compile-products {} {
    set filename [my define get filename]
    set result {}
    if {$filename ne {}} {
      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my Ofile $filename]
        my define set ofile $ofile
      }
      lappend result $ofile [list cfile $filename extra [my define get extra] external [string is true -strict [my define get external]] object [self]]
    }
    foreach item [my link list subordinate] {
      lappend result {*}[$item compile-products]
    }
    return $result
  }

  method generate-include-directory {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result [my define get include_dir]
    foreach obj [my link list product] {
      foreach path [$obj generate-include-directory] {
        lappend result $path
      }
    }
    return $result
  }

  method generate-debug {{spaces {}}} {
    set result {}
    ::practcl::cputs result "$spaces[list [self] [list class [info object class [self]] filename [my define get filename]] links [my link list]]"
    foreach item [my link list subordinate] {
      practcl::cputs result [$item generate-debug "$spaces  "]
    }
    return $result
  }

  # Empty template methods
  method generate-cheader {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct cstruct methods tcltype tclprocs
    set result {}
    if {[info exists code(header)]} {
      ::practcl::cputs result $code(header)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      set dat [$obj generate-cheader]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN [$obj define get filename] generate-cheader */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END [$obj define get filename] generate-cheader */"
      }
    }
    ::practcl::debug [list cfunct [info exists cfunct]]
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {[dict get $info public]} continue
        ::practcl::cputs result "[dict get $info header]\;"
      }
    }
    ::practcl::debug [list tclprocs [info exists tclprocs]]
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {[dict exists $info header]} {
          ::practcl::cputs result "[dict get $info header]\;"
        }
      }
    }
    ::practcl::debug [list methods [info exists methods] [my define get cclass]]
    if {[info exists code(global)]} {
      ::practcl::cputs result $code(global)
    }
    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        if {[dict exists $info header]} {
          ::practcl::cputs result "[dict get $info header]\;"
        }
      }
      # Add the initializer wrapper for the class
      ::practcl::cputs result "static int ${thisclass}_OO_Init(Tcl_Interp *interp)\;"
    }
    return $result
  }

  method generate-public-define {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(public-define)]} {
      ::practcl::cputs result $code(public-define)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-define]
    }
    return $result
  }

  method generate-public-macro {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(public-macro)]} {
      ::practcl::cputs result $code(public-macro)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-macro]
    }
    return $result
  }

  method generate-public-typedef {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(public-typedef)]} {
      ::practcl::cputs result $code(public-typedef)
    }
    if {[info exists cstruct]} {
      # Add defintion for native c data structures
      foreach {name info} $cstruct {
        if {[dict get $info public]==0} continue
        ::practcl::cputs result "typedef struct $name ${name}\;"
        if {[dict exists $info aliases]} {
          foreach n [dict get $info aliases] {
            ::practcl::cputs result "typedef struct $name ${n}\;"
          }
        }
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-typedef]
    }
    return $result
  }

  method generate-private-typedef {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(private-typedef)]} {
      ::practcl::cputs result $code(private-typedef)
    }
    if {[info exists cstruct]} {
      # Add defintion for native c data structures
      foreach {name info} $cstruct {
        if {[dict get $info public]==1} continue
        ::practcl::cputs result "typedef struct $name ${name}\;"
        if {[dict exists $info aliases]} {
          foreach n [dict get $info aliases] {
            ::practcl::cputs result "typedef struct $name ${n}\;"
          }
        }
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-private-typedef]
    }
    return $result
  }

  method generate-public-structure {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(public-structure)]} {
      ::practcl::cputs result $code(public-structure)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        if {[dict get $info public]==0} continue
        if {[dict exists $info comment]} {
          ::practcl::cputs result [dict get $info comment]
        }
        ::practcl::cputs result "struct $name \{[dict get $info body]\}\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-structure]
    }
    return $result
  }


  method generate-private-structure {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(private-structure)]} {
      ::practcl::cputs result $code(private-structure)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        if {[dict get $info public]==1} continue
        if {[dict exists $info comment]} {
          ::practcl::cputs result [dict get $info comment]
        }
        ::practcl::cputs result "struct $name \{[dict get $info body]\}\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-private-structure]
    }
    return $result
  }

  method generate-public-headers {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code tcltype
    set result {}
    if {[info exists code(public-header)]} {
      ::practcl::cputs result $code(public-header)
    }
    if {[info exists tcltype]} {
      foreach {type info} $tcltype {
        if {![dict exists $info cname]} {
          set cname [string tolower ${type}]_tclobjtype
          dict set tcltype $type cname $cname
        } else {
          set cname [dict get $info cname]
        }
        ::practcl::cputs result "extern const Tcl_ObjType $cname\;"
      }
    }
    if {[info exists code(public)]} {
      ::practcl::cputs result $code(public)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-headers]
    }
    return $result
  }

  method generate-stub-function {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct tcltype
    set result {}
    foreach mod [my link list product] {
      foreach {funct def} [$mod generate-stub-function] {
        dict set result $funct $def
      }
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {![dict get $info export]} continue
        dict set result $funcname [dict get $info header]
      }
    }
    return $result
  }

  method generate-public-function {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct tcltype
    set result {}

    if {[my define get initfunc] ne {}} {
      ::practcl::cputs result "int [my define get initfunc](Tcl_Interp *interp);"
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {![dict get $info public]} continue
        ::practcl::cputs result "[dict get $info header]\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-public-function]
    }
    return $result
  }

  method generate-public-includes {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set includes {}
    foreach item [my define get public-include] {
      if {$item ni $includes} {
        lappend includes $item
      }
    }
    foreach mod [my link list product] {
      foreach item [$mod generate-public-includes] {
        if {$item ni $includes} {
          lappend includes $item
        }
      }
    }
    return $includes
  }
  method generate-public-verbatim {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set includes {}
    foreach item [my define get public-verbatim] {
      if {$item ni $includes} {
        lappend includes $item
      }
    }
    foreach mod [my link list subordinate] {
      foreach item [$mod generate-public-verbatim] {
        if {$item ni $includes} {
          lappend includes $item
        }
      }
    }
    return $includes
  }
  ###
  # This methods generates the contents of an amalgamated .h file
  # which describes the public API of this module
  ###
  method generate-h {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    set includes [my generate-public-includes]
    foreach inc $includes {
      if {[string index $inc 0] ni {< \"}} {
        ::practcl::cputs result "#include \"$inc\""
      } else {
        ::practcl::cputs result "#include $inc"
      }
    }

    foreach method {
      generate-public-define
      generate-public-macro
      generate-public-typedef
      generate-public-structure
    } {
      ::practcl::cputs result "/* BEGIN SECTION $method */"
      ::practcl::cputs result [my $method]
      ::practcl::cputs result "/* END SECTION $method */"
    }

    foreach file [my generate-public-verbatim] {
      ::practcl::cputs result "/* BEGIN $file */"
      ::practcl::cputs result [::practcl::cat $file]
      ::practcl::cputs result "/* END $file */"
    }

    foreach method {
      generate-public-headers
      generate-public-function
    } {
      ::practcl::cputs result "/* BEGIN SECTION $method */"
      ::practcl::cputs result [my $method]
      ::practcl::cputs result "/* END SECTION $method */"
    }
    return $result
  }

  method IncludeAdd {headervar args} {
    upvar 1 $headervar headers
    foreach inc $args {
      if {[string index $inc 0] ni {< \"}} {
        set inc "\"$inc\""
      }
      if {$inc ni $headers} {
        lappend headers $inc
      }
    }
  }

  ###
  # This methods generates the contents of an amalgamated .c file
  # which implements the loader for a batch of tools
  ###
  method generate-c {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {
/* This file was generated by practcl */
    }
    set includes {}

    foreach mod [my link list product] {
      # Signal modules to formulate final implementation
      $mod go
    }
    set headers {}

    my IncludeAdd headers <tcl.h> <tclOO.h>
    if {[my define get tk 0]} {
      my IncludeAdd headers <tk.h>
    }
    if {[my define get output_h] ne {}} {
      my IncludeAdd headers [my define get output_h]
    }
    my IncludeAdd headers {*}[my define get include]

    foreach mod [my link list dynamic] {
      my IncludeAdd headers {*}[$mod define get include]
    }
    foreach inc $headers {
      ::practcl::cputs result "#include $inc"
    }
    foreach {method} {
      generate-cheader
      generate-private-typedef
      generate-private-structure
      generate-cstruct
      generate-constant
      generate-cfunct
      generate-tcl_c_api
    } {
      set dat [my $method]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN $method [my define get filename] */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END $method [my define get filename] */"
      }
    }
    ::practcl::debug [list /[self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    return $result
  }


  method generate-loader {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    if {[my define get initfunc] eq {}} return
    ::practcl::cputs result  "
extern int DLLEXPORT [my define get initfunc]( Tcl_Interp *interp ) \{"
    ::practcl::cputs result  {
  /* Initialise the stubs tables. */
  #ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.6", 0)==NULL) return TCL_ERROR;
    if (TclOOInitializeStubs(interp, "1.0") == NULL) return TCL_ERROR;
}
    if {[my define get tk 0]} {
      ::practcl::cputs result  {    if (Tk_InitStubs(interp, "8.6", 0)==NULL) return TCL_ERROR;}
    }
    ::practcl::cputs result {  #endif}
    set TCLINIT [my generate-tcl-pre]
    if {[string length $TCLINIT]} {
      ::practcl::cputs result "  if(Tcl_Eval(interp,[::practcl::tcl_to_c $TCLINIT])) return TCL_ERROR ;"
    }
    foreach item [my link list product] {
      if {[$item define get output_c] ne {}} {
        ::practcl::cputs result [$item generate-cinit-external]
      } else {
        ::practcl::cputs result [$item generate-cinit]
      }
    }
    set TCLINIT [my generate-tcl-post]
    if {[string length $TCLINIT]} {
      ::practcl::cputs result "  if(Tcl_Eval(interp,[::practcl::tcl_to_c $TCLINIT])) return TCL_ERROR ;"
    }
    if {[my define exists pkg_name]} {
      ::practcl::cputs result  "    if (Tcl_PkgProvide(interp, \"[my define get pkg_name [my define get name]]\" , \"[my define get pkg_vers [my define get version]]\" )) return TCL_ERROR\;"
    }
    ::practcl::cputs result  "  return TCL_OK\;\n\}\n"
    return $result
  }

  ###
  # This methods generates any Tcl script file
  # which is required to pre-initialize the C library
  ###
  method generate-tcl-pre {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code
    if {[info exists code(tcl)]} {
      set result [::practcl::_tagblock $code(tcl) tcl [my define get filename]]
    }
    if {[info exists code(tcl-pre)]} {
      set result [::practcl::_tagblock $code(tcl) tcl [my define get filename]]
    }
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-tcl-pre]
    }
    return $result
  }

  method generate-tcl-post {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code
    if {[info exists code(tcl-post)]} {
      set result [::practcl::_tagblock $code(tcl-post) tcl [my define get filename]]
    }
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-tcl-post]
    }
    return $result
  }

  method static-packages {} {
    set result [my define get static_packages]
    set initfunc [my define get initfunc]
    if {$initfunc ne {}} {
      set pkg_name [my define get pkg_name]
      if {$pkg_name ne {}} {
        dict set result $pkg_name initfunc $initfunc
        dict set result $pkg_name version [my define get version [my define get pkg_vers]]
        dict set result $pkg_name autoload [my define get autoload 0]
      }
    }
    foreach item [my link list subordinate] {
      foreach {pkg info} [$item static-packages] {
        dict set result $pkg $info
      }
    }
    return $result
  }

  method target {method args} {
    switch $method {
      is_unix { return [expr {$::tcl_platform(platform) eq "unix"}] }
    }
  }
}
