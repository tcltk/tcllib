###
# Practcl
# An object oriented templating system for stamping out Tcl API calls to C
###
package require TclOO
package require fileutil

if {[::info commands ::tcl::dict::getnull] eq {}} {
  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
}

proc ::CPUTS {varname args} {
  upvar 1 $varname buffer
  if {[llength $args]==1 && [string length [string trim [lindex $args 0]]] == 0} {
    
  }
  if {[info exist buffer]} {
    if {[string index $buffer end] ne "\n"} {
      append buffer \n
    }
  } else {
    set buffer \n
  }
  # Trim leading \n's
  append buffer [string trimleft [lindex $args 0] \n] {*}[lrange $args 1 end]
}

namespace eval ::practcl {}

proc ::practcl::_isdirectory name {
  return [file isdirectory $name]
}
###
# topic: ebd68484cb7f18cad38beaab3cf574e2de5702ea
###
proc ::practcl::_istcl name {
  return [string match *.tcl $name]
}

###
# topic: 2e481bd24d970304a1dd0acad3d75198b56c122e
###
proc ::practcl::_istm name {
  return [string match *.tm $name]
}

proc ::practcl::_pkgindex_special pkgidxfile {
  set fin [open $pkgidxfile r]
  set dat [read $fin]
  close $fin
  set thisline {}
  foreach line [split $dat \n] {
    append thisline $line \n
    if {![info complete $thisline]} continue
    set line [string trim $line]
    if {[string length $line]==0} {
      set thisline {} ; continue
    }
    if {[string index $line 0] eq "#"} {
      set thisline {} ; continue
    }
    if {[lindex $line 0] != "package"} {return 1}
    if {[lindex $line 1] != "ifneeded"} {return 1}
    set thisline {}
  }
  return 0
}

proc ::practcl::pkgindex_path base {
set stack {}
  set buffer {
lappend ::PATHSTACK $dir
  }
  set base [file normalize $base]
  set i    [string length  $base]
  # Build a list of all of the paths
  set paths [fileutil::find $base ::practcl::_isdirectory]
  
  foreach path $paths {
    if {$path eq $base} continue
    set path_indexed($path) 0
    foreach idxname {pkgIndex.tcl} {
      set idxfile [file join $path $idxname]
      if {[file exists $idxfile] && [::practcl::_pkgindex_special $idxfile]} {
        incr path_indexed($path)
        set dir [string trimleft [string range $path $i end] /]
        append buffer "set dir \[file join \[lindex \$::PATHSTACK end\] $dir\] \; source \[file join \[lindex \$::PATHSTACK end\] $dir $idxname\]"
        append buffer \n
      }
    }
  }

  foreach path $paths {
    if {$path_indexed($path)} continue
    foreach file [glob -nocomplain $path/*.tm] {
      set file [file normalize $file]
      set fname [file rootname [file tail $file]]
      ###
      # Assume the package is correct in the filename
      ###
      set package [lindex [split $fname -] 0]
      set version [lindex [split $fname -] 1]
      set path [string trimleft [string range [file dirname $file] $i end] /]
      ###
      # Read the file, and override assumptions as needed
      ###
      set fin [open $file r]
      set dat [read $fin]
      close $fin
      foreach line [split $dat \n] {
        set line [string trim $line]
        if { [string range $line 0 9] != "# Package " } continue
        set package [lindex $line 2]
        set version [lindex $line 3]
        break
      }
      append buffer "package ifneeded $package $version \[list source \[file join \[lindex \$::PATHSTACK end\] $path [file tail $file]\]\]"
      append buffer \n
    }
    foreach file [glob -nocomplain $path/*.tcl] {
      set file [file normalize $file]
      if { $file == [file join $base tcl8.6 package.tcl] } continue
      if { $file == [file join $base packages.tcl] } continue
      if { $file == [file join $base main.tcl] } continue
      if { [file tail $file] == "version_info.tcl" } continue
      set fin [open $file r]
      set dat [read $fin]
      close $fin
      if {![regexp "package provide" $dat]} continue
      set fname [file rootname [file tail $file]]
      set dir [string trimleft [string range [file dirname $file] $i end] /]
      
      foreach line [split $dat \n] {
        set line [string trim $line]              
        if { [string range $line 0 14] != "package provide" } continue
        set package [lindex $line 2]
        set version [lindex $line 3]
        append buffer "package ifneeded $package $version \[list source \[file join \[lindex \$::PATHSTACK end\] $dir [file tail $file]\]\]"
        append buffer \n
        break
      }
    }
  }
  append buffer {
set dir [lindex $::PATHSTACK end]  
set ::PATHSTACK [lrange $::PATHSTACK 0 end-1]
}
  return $buffer
}

::oo::class create ::practcl::object {

  method target {method args} {
    switch $method {
      is_unix { return [expr {$::tcl_platform(platform) eq "unix"}] }
    }
  }
  
  method generate-include-directory {} {
    set result [my define get include_dir]
    foreach obj [my link list product] {
      foreach path [$obj generate-include-directory] {
        lappend result $path
      }
    }
    return $result
  }
  
  method include_dir args {
    my define add include_dir {*}$args
  }
  
  method include_directory args {
    my define add include_dir {*}$args
  }

  method child {method} {
    return {}
  }
  
  constructor {parent args} {
    my variable links define
    my graft {*}[$parent child organs]
    array set define [$parent child organs]
    array set define [$parent child define]
    array set links {}
    if {[llength $args]==1 && [file exists [lindex $args 0]]} {
      my InitializeSourceFile [lindex $args 0]
    } elseif {[llength $args] == 1} {
      array set define [lindex $args 0]
      my select
      my initialize
    } else {
      array set define $args
      my select
      my initialize
    }
  }  

  method select {} {
    my variable define
    set class {}
    if {[info exists define(class)]} {
      if {[info command $define(class)] ne {}} {
        set class $define(class)
      } elseif {[info command ::practcl::$define(class)] ne {}} {
        set class ::practcl::$define(class)
      } else {
        switch $define(class) {
          default {
            set class ::practcl::object
          }
        }
      }
    }
    if {$class ne {}} {
      oo::objdefine [self] class $class
    }
  }
  
  method InitializeSourceFile filename {
    my define set filename $filename
    set class {}
    switch [file extension $filename] {
      .tcl {
        set class ::practcl::submodule
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
        }
      }
    }
    if {$class ne {}} {
      oo::objdefine [self] class $class
      my initialize
    }
  }
  
  method graft args {
    my variable organs
    if {[llength $args] == 1} {
      error "Need two arguments"
    }
    set object {}
    foreach {stub object} $args {
      dict set organs $stub $object
      oo::objdefine [self] forward <${stub}> $object
      oo::objdefine [self] export <${stub}>
    }
    return $object
  }
  
  method organ {{stub all}} {
    my variable organs
    if {![info exists organs]} {
      return {}
    }
    if { $stub eq "all" } {
      return $organs
    }
    return [dict getnull $organs $stub]
  }
  
  method link {command args} {
    my variable links
    switch $command {
      add {
        ###
        # Add a link to an object that was externally created
        ###
        if {[llength $args] ne 2} { error "Usage: link add LINKTYPE OBJECT"}
        lassign $args linktype object
        if {[info exists links($linktype)] && $object in $links($linktype)} {
          return
        }
        lappend links($linktype) $object
      }
      remove {
        set object [lindex $args 0]
        if {[llength $args]==1} {
          set ltype *
        } else {
          set ltype [lindex $args 1]
        }
        foreach {linktype elements} [array get links $ltype] {
          if {$object in $elements} {
            set nlist {}
            foreach e $elements {
              if { $object ne $e } { lappend nlist $e }
            }
            set links($linktype) $nlist
          }
        }
      }
      list {
        if {[llength $args] ne 1} { error "Usage: link list LINKTYPE"}
        lassign $args linktype
        if {![info exists links($linktype)]} {
          return {}
        }
        return $links($linktype)
      }
      dump {
        return [array get links]
      }
    }
  }
  
  method add args {
    my variable links
    set object [::practcl::object new [self] {*}$args]
    set linktype  [$object linktype]
    lappend links($linktype) $object
    return $object
  }
  
  method initialize {} {}
    
  method define {submethod args} {
    my variable define
    switch $submethod {
      add {
        set field [lindex $args 0]
        if {![info exists define($field)]} {
          set define($field) {}
        }
        foreach arg [lrange $args 1 end] {
          if {$arg ni $define($field)} {
            lappend define($field) $arg
          }
        }
        return $define($field)
      }
      remove {
        set field [lindex $args 0]
        if {![info exists define($field)]} {
          return
        }
        set rlist [lrange $args 1 end]
        set olist $define($field)
        set nlist {}
        foreach arg $olist {
          if {$arg in $rlist} continue
          lappend nlist $arg
        }
        set define($field) $nlist
        return $nlist
      }
      exists {
        set field [lindex $args 0]
        return [info exists define($field)]
      }
      getnull -
      get -
      cget {
        set field [lindex $args 0]
        if {[info exists define($field)]} {
          return $define($field)
        }
        return [lindex $args 1]
      }
      set {
        if {[llength $args]==1} {
          array set define [lindex $args 0]
        } else {
          array set define $args
        }
      }
      default {
        array $submethod define {*}$args
      }
    }
  }
  
  method go {} {
    my variable links
    foreach {linktype objs} [array get links] {
      foreach obj $objs {
        $obj go
      }
    }
  }
    
  method code {section body} {
    my variable code
    CPUTS code($section) $body
  }
  method script script {
    eval $script
  }
  
  method source filename {
    source $filename
  }
}

::oo::class create ::practcl::library {
  superclass ::practcl::object
  
  constructor args {
    my variable define
    if {[llength $args]==1} {
      array set define [lindex $args 0]
    } else {
      array set define $args
    }
    my select
    my initialize
  }
  
  method select {} {}
  
  method child which {
    switch $which {
      organs {
        return [list project [self]]
      }
    }
  }
  
  method implement path {
    foreach item [my link list product] {
      $item implement $path
    }
  }
  
  method generate-make {{filename {}}} {
    set result {}
    set products {}
    set name [string toupper [my define get name]]
    set includedir .
    set here [file dirname [file normalize $filename]]
    foreach include [my generate-include-directory] {
      set cpath [fileutil::relative $here [file normalize $include]]
      if {$cpath ni $includedir} {
        lappend includedir $cpath
      }
    }
    CPUTS result "${name}_DEFS = \$\(PKG_DEFS\)"
    CPUTS result "${name}_INCLUDES = \"-I[join $includedir "\" \"-I"]\"\n"
    foreach {ofile info} [my compile-products] {
      dict set products $ofile $info
      set agline {}
      if {[dict exists $info depend]} {
        CPUTS result "${ofile}: [dict get $info depend]"
      } else {
        CPUTS result "${ofile}:"
      }
      CPUTS result "\t\$\(COMPILE\) \$\(${name}_INCLUDES\) [dict get $info extra] \$\(${name}_DEFS\) -c [dict get $info cfile] -o \$@\n\n"
    }

    CPUTS result "
${name}_OBJS = [dict keys $products]
"
  
    CPUTS result [string map [list @NAME@ $name] {
lib@NAME@: $(@NAME@_SHLIB)

@NAME@.a: $(@NAME@_OBJS)
	$(CC) \
	$(CCFLAGS) -static \
	$(SH_CFLAGS) \
	$(CFLAGS_WARN) \
	$(CFLAGS_OPT) \
	$(LDFLAGS) \
	$(SH_LDFLAGS) \
	-o $@ \
	$(${name}_OBJS) \
	$(TH_LIBS) \
	$(LIB_SPEC)

$(@NAME@_SHLIB): $(@NAME@_OBJS)
	$(CC) \
	$(CCFLAGS) \
	$(SH_CFLAGS) \
	$(CFLAGS_WARN) \
	$(CFLAGS_OPT) \
	$(LDFLAGS) \
	$(SH_LDFLAGS) \
	-o $@ \
	$(${name}_OBJS) \
	$(TH_LIBS) \
	$(LIB_SPEC)
}]
    
    if {$filename ne {}} {
      set fout [open $filename w]
      puts $fout $result
      close $fout
    } else {
      return $result
    }
  }
  
  method generate-c {{filename {}}} {
    set result {}
    CPUTS result "#include <tcl.h>"
    foreach item [my link list product] {
      CPUTS result [$item generate-cinit-header]
    }
    
    CPUTS result  "
extern int DLLEXPORT [my define get init_funct]( Tcl_Interp *interp ) \{"
  CPUTS result  {
  /* Initialise the stubs tables. */
  #ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.5", 0)==NULL) {
      return TCL_ERROR;
    }
    if (TclOOInitializeStubs(interp, "1.0") == NULL) {
      return TCL_ERROR;
    }
  #endif
}
    foreach item [my link list product] {
      CPUTS result [$item generate-cinit]
    }
    if {[my define exists pkg_name]} {
      CPUTS result  "    if (Tcl_PkgProvide(interp, \"[my define get pkg_name]\" , \"[my define get pkg_vers]\" )) return TCL_ERROR\;"
    }
    CPUTS result  "  return TCL_OK\;\n\}\n"
    if {$filename ne {}} {
      my define set output_c [file tail $filename]
      set fout [open $filename w]
      puts $fout $result
      close $fout
    } else {
      return $result
    }
  }
  
  method compile-products {} {
    set result {}
    foreach item [my link list product] {
      lappend result {*}[$item compile-products]
    }
    set filename [my define get output_c]
    if {$filename ne {}} {
      set ofile [file rootname [file tail $filename]]_main.o
      lappend result $ofile [list cfile $filename extra [my define get extra]]
    }
    return $result
  }
}

::oo::class create ::practcl::exe {
  superclass ::practcl::library
  
  
}

::oo::class create ::practcl::product {
  superclass ::practcl::object
  
  method linktype {} {
    return product
  }
  
  method compile-products {} {
    set filename [my define get filename]
    set result {}
    if {$filename ne {}} {
      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my <module> define get localpath]_[file rootname [file tail $filename]].o
      }
      lappend result $ofile [list cfile $filename extra [my define get extra]]
    }
    foreach item [my link list product] {
      lappend result {*}[$item compile-products]
    }
    return $result
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
  }
  
 ###
  # This methods generates any Tcl script file
  # which is required to pre-initialize the C library
  ###
  method generate-tcl {} {
    set result {}
    my variable code
    if {[info exists code(tcl)]} {
      CPUTS result $code(tcl)
    }
    foreach mod [my link list product] {
      CPUTS result [$mod generate-tcl]
    }
    return $result
  }
  
  method generate-cheader {} {}
  method generate-cstruct {} {}
  method generate-cfunct {} {}
  method generate-cmethod {} {}

  method generate-public-macro {} {
    my variable code
    set result {}
    if {[info exists code(public-define)]} {
      CPUTS result $code(public-define)
    }
    if {[info exists code(public-macro)]} {
      CPUTS result $code(public-macro)
    }
    return $result
  }
  method generate-public-typedef {} {
    my variable code cstruct
    set result {}
    if {[info exists code(public-typedef)]} {
      CPUTS result $code(public-typedef)
    }
    if {[info exists cstruct]} {
      # Add defintion for native c data structures
      foreach {name info} $cstruct {
        CPUTS result "typedef struct $name ${name}\;"
        if {[dict exists $info aliases]} {
          foreach n [dict get $info aliases] {
            CPUTS result "typedef struct $name ${n}\;"
          }
        }
      }
    }
    return $result
  }
  method generate-public-structure {} {
    my variable code cstruct
    set result {}
    if {[info exists code(public-structure)]} {
      CPUTS result $code(public-structure)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        if {[dict exists $info comment]} {
          CPUTS result [dict get $info comment]
        }
        CPUTS result "struct $name \{[dict get $info body]\}\;"
      }
    }
    return $result
  }
  method generate-public-headers {} {
    my variable code cfunct tcltype
    set result {}
    if {[info exists code(public-header)]} {
      CPUTS result $code(public-header)
    }
    if {[info exists tcltype]} {
      foreach {type info} $tcltype {
        if {![dict exists $info cname]} {
          set cname [string tolower ${type}]_tclobjtype
          dict set tcltype $type cname $cname
        } else {
          set cname [dict get $info cname]
        }
        CPUTS result "extern const Tcl_ObjType $cname\;"
      }
    }
    if {[info exists code(public)]} {
      CPUTS result $code(public)
    }
    if {[my define get initfunc] ne {}} {
      CPUTS result "int [my define get initfunc](Tcl_Interp *interp);"
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {![dict get $info public]} continue
        CPUTS result "[dict get $info header]\;"
      }
    }
    return $result
  }

  method generate-cinit-header {} {
    set result {}
    foreach obj [my link list product] {
      CPUTS result [$obj generate-cinit-header]
    }
    return $result
  }
  
  method generate-cinit {} {
    my variable code
    set result {}
    if {[info exists code(cinit)]} {
      CPUTS result $code(cinit)
    }
    if {[my define get initfunc] ne {}} {
      CPUTS result "    /* [my define get filename] */"
      CPUTS result "  if([my define get initfunc](interp)!=TCL_OK) return TCL_ERROR\;"
    }
    foreach obj [my link list product] {
      CPUTS result [$obj generate-cinit]
    }
    return $result
  }
  
  # Go and implement do nothing for static code
  method implement args {}
  method go args {}
}

::oo::class create ::practcl::cheader {
  superclass ::practcl::product

  method compile-products {} {}
  method generate-cinit {} {}
  method generate-cheader {} {}
}

::oo::class create ::practcl::csource {
  superclass ::practcl::product
}



###
# In the end, all C code must be loaded into a module
# This will either be a dynamically loaded library implementing
# a tcl extension, or a compiled in segment of a custom shell/app
###
::oo::class create ::practcl::module {
  superclass ::practcl::product

  method initialize {} {
    set filename [my define get filename]
    if {$filename eq {}} {
      return
    }
    if {[my define get name] eq {}} {
      my define set name [file tail [file dirname $filename]]
    }
    if {[my define get localpath] eq {}} {
      my define set localpath [my <project> define get name]_[my define get name]
    }
    my source $filename
  }
  
  method implement path {
    set filename [my define get output_c]
    if {$filename eq {}} {
      return
    }
    set tclout [open [file join $path [file rootname $filename].tcl] w]
    puts $tclout "###
# This file is generated by the [info script] script
# any changes will be overwritten the next time it is run
###"
    puts $tclout [my generate-tcl]
    close $tclout
    
    set cout [open [file join $path [file rootname $filename].c] w]
    puts $cout [subst {/*
** This file is generated by the [info script] script
** any changes will be overwritten the next time it is run
*/}]
    puts $cout [my generate-c]
    close $cout
    set macro HAVE_[string toupper [file rootname $filename]]_H
    set hout [open [file join $path [file rootname $filename].h] w]
    puts $hout [subst {/*
** This file is generated by the [info script] script
** any changes will be overwritten the next time it is run
*/}]
    puts $hout "#ifndef ${macro}"
    puts $hout "#define ${macro}"
    puts $hout [my generate-h]
    puts $hout "#endif"
    close $hout
  }
  
  method child which {
    switch $which {
      organs {
        return [list project [my define get project] module [self]]
      }
    }
  }
  
  method compile-products {} {
    set filename [my define get output_c]
    set result {}
    if {$filename ne {}} {
      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my define get localpath]_[file rootname [file tail $filename]].o
      }
      lappend result $ofile [list cfile $filename extra [my define get extra]]
    }
    foreach item [my link list product] {
      lappend result {*}[$item compile-products]
    }
    return $result
  }
  
  method generate-cinit-header {} {
    set result {}
    if {[my define get loader-funct] ne {}} {
      CPUTS result "int [my define get loader-funct](Tcl_Interp *interp)\;"
      return $result
    }
    if {[my define get initfunc] ne {}} {
      CPUTS result "int [my define get initfunc](Tcl_Interp *interp)\;"
    }
    return $result
  }
  
  method generate-cinit {} {
    set result {}
    if {[my define get loader-funct] ne {}} {
      CPUTS result "  /* [my define get filename] */"
      CPUTS result "  if([my define get loader-funct](interp)!=TCL_OK) return TCL_ERROR\;"
      return $result
    }
    if {[my define get initfunc] ne {}} {
      CPUTS result "  /* [my define get filename] */"
      CPUTS result "  if([my define get initfunc](interp)!=TCL_OK) return TCL_ERROR\;"
    }
    foreach {obj} [my link list product] {
      CPUTS result [$obj generate-cinit]
    }
    return $result
  }
  
  ###
  # This methods generates the contents of an amalgamated .c file
  # which implements the loader for a batch of tools
  ###
  method generate-c {} {
    set result {
/* This file was generated by practcl */
    }
    set includes {}
    lappend headers <tcl.h> <tclOO.h> {*}[my define get include]

    foreach mod [my link list product] {
      # Signal modules to formulate final implementation
      $mod go
    }
    foreach mod [my link list product] {
      foreach inc [$mod define get include] {
        if {$inc ni $headers} {
          lappend headers $inc
        }
      }
    }
    foreach inc $headers {
      if {[string index $inc 0] ni {< \"}} {
        CPUTS result "#include \"$inc\""
      } else {
        CPUTS result "#include $inc"        
      }
    }
    foreach mod [my link list product] {
      puts [list CHEADER: $mod [$mod define get filename]]
      CPUTS result [$mod generate-cheader]
    }
    foreach mod [my link list product] {
      CPUTS result [$mod generate-cstruct]
    }
    foreach mod [my link list product] {
      CPUTS result [$mod generate-cfunct]
    }
    foreach mod [my link list product] {
      CPUTS result [$mod generate-cmethod]
    }
    CPUTS result "int [my define get loader-funct](Tcl_Interp *interp)\n\{\n"
    foreach mod [my link list product] {
      CPUTS result [$mod generate-cinit] \n
    }
    CPUTS result "return TCL_OK\;\n\}\n"
    return $result
  }
  
  ###
  # This methods generates the contents of an amalgamated .h file
  # which describes the public API of this module
  ###
  method generate-h {} {
    set result {}
    foreach method {
      generate-public-macro
      generate-public-typedef
      generate-public-structure
      generate-public-headers
    } {
      CPUTS $result [my $method]
      foreach mod [my link list product] {
        CPUTS result [$mod $method]
      }
    }
    return $result
  }
}

::oo::class create ::practcl::submodule {
  superclass ::practcl::module

  method compile-products {} {
    set filename [my define get output_c]
    set result {}
    if {$filename ne {}} {
      set ofile [my define get name]_[file rootname [file tail $filename]].o
      lappend result $ofile [list cfile $filename extra [my define get extra]]
    }
    return $result
  }
  
  
  ###
  # This methods generates the contents of a standalone .c file
  # which implements this tool
  ###
  method generate-c {} {
    set result {
/* This file was generated by practcl */
    }
    set includes {}
    lappend headers <tcl.h>
    # Formulate final implementation
    my go
    foreach inc [my define get include] {
      if {$inc ni $headers} {
        lappend headers $inc
      }
    }
    foreach inc $headers {
      CPUTS result "#include $inc"
    }
    CPUTS result [my generate-cheader]
    CPUTS result [my generate-cstruct]
    CPUTS result [my generate-cfunct]
    CPUTS result [my generate-cmethod]
    
    CPUTS result "int [my define get loader-funct](Tcl_Interp *interp)\n\{\n"
    CPUTS result [my generate-cinit] \n
    CPUTS result "return TCL_OK\;\n\}\n"
    return $result
  }

  ###
  # Generate code that provides forward static
  # declarations for the rest of the code
  ###
  method generate-cheader {} {
    my variable code cfunct cstruct methods tcltype
    set result {}
    if {[info exists code(header)]} {
      CPUTS result $code(header)
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {[dict get $info public]} continue
        CPUTS result "[dict get $info header]\;"
      }
    }
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {[dict exists $info header]} {
          CPUTS result "[dict get $info header]\;"
        }
      }
    }
    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        if {[dict exists $info header]} {
          CPUTS result "[dict get $info header]\;"
        }
      }
      # Add the initializer wrapper for the class
      CPUTS result "static int ${thisclass}_OO_Init(Tcl_Interp *interp)\;"
    }
    return $result
  }
  
  ###
  # Populate const static data structures
  ###
  method generate-cstruct {} {
    my variable code cstruct methods tcltype
    set result {}
    if {[info exists code(struct)]} {
      CPUTS result $code(struct)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        set map {}
        lappend map @NAME@ $name
        lappend map @MACRO@ GET[string toupper $name]

        if {[dict exists $info deleteproc]} {
          lappend map @DELETEPROC@ [dict get $info deleteproc]
        } else {
          lappend map @DELETEPROC@ NULL
        }
        if {[dict exists $info cloneproc]} {
          lappend map @CLONEPROC@ [dict get $info cloneproc]
        } else {
          lappend map @CLONEPROC@ NULL
        }
        CPUTS result [string map $map {
const static Tcl_ObjectMetadataType @NAME@DataType = {
  TCL_OO_METADATA_VERSION_CURRENT,
  "@NAME@",
  @DELETEPROC@,
  @CLONEPROC@
};
#define @MACRO@(OBJCONTEXT) (@NAME@ *) Tcl_ObjectGetMetadata(Tcl_ObjectContextObject(objectContext),&@NAME@DataType)
}]
      }
    }
    if {[info exists tcltype]} {
      foreach {type info} $tcltype {
        dict with info {}
        CPUTS result "const Tcl_ObjType $cname = \{\n  .freeIntRepProc = &${freeproc},\n  .dupIntRepProc = &${dupproc},\n  .updateStringProc = &${updatestringproc},\n  .setFromAnyProc = &${setfromanyproc}\n\}\;"
      }
    }    

    if {[info exists methods]} {
      set mtypes {}
      foreach {name info} $methods {   
        set callproc   [dict get $info callproc]
        set methodtype [dict get $info methodtype]
        if {$methodtype in $mtypes} continue
        lappend mtypes $methodtype
        ###
        # Build the data struct for this method
        ###
        CPUTS result "const static Tcl_MethodType $methodtype = \{"
        CPUTS result "  .version = TCL_OO_METADATA_VERSION_CURRENT,\n  .name = \"$name\",\n  .callProc = $callproc,"
        if {[dict exists $info deleteproc]} {
          set deleteproc [dict get $info deleteproc]
        } else {
          set deleteproc NULL
        }
        if {$deleteproc ni { {} NULL }} {
          CPUTS result "  .deleteProc = $deleteproc,"
        } else {
          CPUTS result "  .deleteProc = NULL,"
        }
        if {[dict exists $info cloneproc]} {
          set cloneproc [dict get $info cloneproc]
        } else {
          set cloneproc NULL
        }
        if {$cloneproc ni { {} NULL }} {
          CPUTS result "  .cloneProc = $cloneproc\n\}\;"
        } else {
          CPUTS result "  .cloneProc = NULL\n\}\;"
        }
        dict set methods $name methodtype $methodtype
      }
    }
      
    return $result
  }
  
  ###
  # Generate code that provides subroutines called by
  # Tcl API methods
  ###
  method generate-cfunct {} {
    my variable code cfunct
    set result {}
    if {[info exists code(funct)]} {
      CPUTS result $code(funct)
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        CPUTS result "[dict get $info header]\{[dict get $info body]\}\;"
      }
    }
    return $result
  }

  ###
  # Generate code that provides implements Tcl API
  # calls
  ###
  method generate-cmethod {} {
    my variable code methods tclprocs
    set result {}
    if {[info exists code(method)]} {
      CPUTS result $code(method)
    }
    
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {![dict exists $info body]} continue
        set callproc [dict get $info callproc]
        set header [dict get $info header]
        set body [dict get $info body]
        CPUTS result "${header} \{${body}\}"
      }
    }

    
    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        if {![dict exists $info body]} continue
        set callproc [dict get $info callproc]
        set header [dict get $info header]
        set body [dict get $info body]
        CPUTS result "${header} \{${body}\}"
      }
      # Build the OO_Init function
      CPUTS result "static int ${thisclass}_OO_Init(Tcl_Interp *interp) \{"
      CPUTS result [string map [list @CCLASS@ $thisclass @TCLCLASS@ [my define get class]] {
  /*
  ** Build the "@TCLCLASS@" class
  */
  Tcl_Obj* nameObj;		/* Name of a class or method being looked up */
  Tcl_Object curClassObject;  /* Tcl_Object representing the current class */
  Tcl_Class curClass;		/* Tcl_Class representing the current class */

  /* 
   * Find the wallset class, and attach an 'init' method to it.
   */

  nameObj = Tcl_NewStringObj("@TCLCLASS@", -1);
  Tcl_IncrRefCount(nameObj);
  if ((curClassObject = Tcl_GetObjectFromObj(interp, nameObj)) == NULL) {
      Tcl_DecrRefCount(nameObj);
      return TCL_ERROR;
  }
  Tcl_DecrRefCount(nameObj);
  curClass = Tcl_GetObjectAsClass(curClassObject);
}]
      if {[dict exists $methods constructor]} {
        set mtype [dict get $methods constructor methodtype]
        CPUTS result [string map [list @MTYPE@ $mtype] {
  /* Attach the constructor to the class */
  Tcl_ClassSetConstructor(interp, curClass, Tcl_NewMethod(interp, curClass, NULL, 1, &@MTYPE@, NULL));
    }]
      }
      foreach {name info} $methods {
        dict with info {}
        if {$name in {constructor destructor}} continue
        CPUTS result [string map [list @NAME@ $name @MTYPE@ $methodtype] {
  nameObj=Tcl_NewStringObj("@NAME@",-1);
  Tcl_NewMethod(interp, curClass, nameObj, 1, &@MTYPE@, (ClientData) NULL);
  Tcl_DecrRefCount(nameObj);
}]
        if {[dict exists $info aliases]} {
          foreach alias [dict get $info aliases] {
            if {[dict exists $methods $alias]} continue
            CPUTS result [string map [list @NAME@ $alias @MTYPE@ $methodtype] {
  nameObj=Tcl_NewStringObj("@NAME@",-1);
  Tcl_NewMethod(interp, curClass, nameObj, 1, &@MTYPE@, (ClientData) NULL);
  Tcl_DecrRefCount(nameObj);
}]
          }
        }
      }
      CPUTS result "  return TCL_OK\;\n\}\n"  
    }
    return $result
  }

  method generate-cinit-header {} {
    set result {}
    CPUTS result "int [my define get loader-funct](Tcl_Interp *interp)\;"
    return $result
  }
  
  ###
  # Generate code that runs when the package/module is
  # initialized into the interpreter
  ###
  method generate-cinit {} {
    set result {}
    my variable code methods tclprocs
    CPUTS result "/* [my define get filename] */"
    if {[info exists code(nspace)]} {
      CPUTS result "  \{\n    Tcl_Namespace *modPtr;"
      foreach nspace $code(nspace) {
        CPUTS result [string map [list @NSPACE@ $nspace] {
    modPtr=Tcl_FindNamespace(interp,"@NSPACE@",NULL,TCL_NAMESPACE_ONLY);
    if(!modPtr) {
      modPtr = Tcl_CreateNamespace(interp, "@NSPACE@", NULL, NULL);
    }
}]
      }
      CPUTS result "  \}"      
    }
    if {[info exists code(init)]} {
      CPUTS result $code(init)
    }
    if {[info exists code(initfuncts)]} {
      foreach func $code(initfuncts) {
        CPUTS result "  if (${func}(interp) != TCL_OK) return TCL_ERROR\;"
      }
    }
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        set map [list @NAME@ $name @CALLPROC@ [dict get $info callproc]]
        CPUTS result [string map $map {  Tcl_CreateObjCommand(interp,"@NAME@",(Tcl_ObjCmdProc *)@CALLPROC@,NULL,NULL);}]
        if {[dict exists $info aliases]} {
          foreach alias [dict get $info aliases] {
            set map [list @NAME@ $alias @CALLPROC@ [dict get $info callproc]]
            CPUTS result [string map $map {  Tcl_CreateObjCommand(interp,"@NAME@",(Tcl_ObjCmdProc *)@CALLPROC@,NULL,NULL);}]
          }
        }
      }
    }
    
    if {[info exists code(nspace)]} {
      CPUTS result "  \{\n    Tcl_Namespace *modPtr;"
      foreach nspace $code(nspace) {
        CPUTS result [string map [list @NSPACE@ $nspace] {
    modPtr=Tcl_FindNamespace(interp,"@NSPACE@",NULL,TCL_NAMESPACE_ONLY);
    Tcl_CreateEnsemble(interp, modPtr->fullName, modPtr, TCL_ENSEMBLE_PREFIX);
    Tcl_Export(interp, modPtr, "[a-z]*", 1);
}]
      }
      CPUTS result "  \}"
    }
    return $result
  }

  method tcltype {name argdat} {
    my variable tcltype
    foreach {f v} $argdat {
      dict set tcltype $name $f $v
    }
    if {![dict exists tcltype $name cname]} {
      dict set tcltype $name cname [string tolower $name]_tclobjtype
    }
    lappend map @NAME@ $name
    set info [dict get $tcltype $name]
    foreach {f v} $info {
      lappend map @[string toupper $f]@ $v
    }
    foreach {func fpat template} {
      freeproc         {@Name@Obj_freeIntRepProc}       {void @FNAME@(Tcl_Obj *objPtr)}
      dupproc          {@Name@Obj_dupIntRepProc}        {void @FNAME@(Tcl_Obj *srcPtr,Tcl_Obj *dupPtr)}
      updatestringproc {@Name@Obj_updateStringRepProc} {void @FNAME@(Tcl_Obj *objPtr)}
      setfromanyproc   {@Name@Obj_setFromAnyProc}       {int @FNAME@(Tcl_Interp *interp,Tcl_Obj *objPtr)}
    } {
      if {![dict exists $info $func]} {
        error "$name does not define $func"
      }
      set body [dict get $info $func]
      # We were given a function name to call
      if {[llength $body] eq 1} continue
      set fname [string map [list @Name@ [string totitle $name]] $fpat]
      my c_function [string map [list @FNAME@ $fname] $template] [string map $map $body]
      dict set tcltype $name $func $fname
    }
  }
  method c_header body {
    my variable code
    ::CPUTS code(header) $body
  }
  method c_code body {
    my variable code
    ::CPUTS code(funct) $body
  }
  method c_function {header body} {
    my variable code cfunct
    foreach regexp {
         {(.*) ([a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}
         {(.*) (\x2a[a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}
    } {
      if {[regexp $regexp $header all keywords funcname arglist]} {
        dict set cfunct $funcname header $header
        dict set cfunct $funcname body $body
        dict set cfunct $funcname keywords $keywords
        dict set cfunct $funcname arglist $arglist
        dict set cfunct $funcname public [expr {"static" ni $keywords}]
        return
      }
    }
    CPUTS code(header) "$header\;"
    # Could not parse that block as a function
    # append it verbatim to our c_implementation
    CPUTS code(funct) "$header [list $body]"
  }

  
  method cmethod {name body {arginfo {}}} {
    my variable methods code
    foreach {f v} $arginfo {
      dict set methods $name $f $v
    }
    dict set methods $name body $body
  }
  
  method c_tclproc_nspace nspace {
    my variable code
    if {![info exists code(nspace)]} {
      set code(nspace) {}
    }
    if {$nspace ni $code(nspace)} {
      lappend code(nspace) $nspace
    }
  }
  
  method c_tclproc_raw {name body {arginfo {}}} {
    my variable tclprocs code

    foreach {f v} $arginfo {
      dict set tclprocs $name $f $v
    }
    dict set tclprocs $name body $body
  }

  
  method go {} {
    my variable methods code cstruct tclprocs
    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {   
        # Provide a callproc
        if {![dict exists $info callproc]} {
          set callproc [string map {____ _ ___ _ __ _} [string map {{ } _ : _} OOMethod_${thisclass}_${name}]]
          dict set methods $name callproc $callproc
        } else {
          set callproc [dict get $info callproc]
        }
        if {[dict exists $info body] && ![dict exists $info header]} {
          dict set methods $name header "static int ${callproc}(ClientData clientData, Tcl_Interp *interp, Tcl_ObjectContext objectContext ,int objc ,Tcl_Obj *const *objv)"
        }
        if {![dict exists $info methodtype]} {
          set methodtype [string map {{ } _ : _} MethodType_${thisclass}_${name}]
          dict set methods $name methodtype $methodtype
        }
      }
      lappend code(initfuncts) "${thisclass}_OO_Init"
    }
    set thisnspace [my define get nspace]

    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {![dict exists $info callproc]} {
          set callproc [string map {____ _ ___ _ __ _} [string map {{ } _ : _} Tclcmd_${thisnspace}_${name}]]
          dict set tclprocs $name callproc $callproc
        } else {
          set callproc [dict get $info callproc]
        }    
        if {[dict exists $info body] && ![dict exists $info header]} {
          dict set tclprocs $name header "static int ${callproc}(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv\[\])"
        }
      }
    }
  }
}
package provide practcl 0.1