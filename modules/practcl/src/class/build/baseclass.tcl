

###
# Ancestor-less class intended to be a mixin
# which defines a family of build related behaviors
# that are modified when targetting either gcc or msvc
###
::oo::class create ::practcl::build {
  ## method DEFS
  # This method populates 4 variables:
  # name - The name of the package
  # version - The version of the package
  # defs - C flags passed to the compiler
  # includedir - A list of paths to feed to the compiler for finding headers
  #
  method build-cflags {PROJECT DEFS namevar versionvar defsvar} {
    upvar 1 $namevar name $versionvar version NAME NAME $defsvar defs
    set name [string tolower [${PROJECT} define get name [${PROJECT} define get pkg_name]]]
    set NAME [string toupper $name]
    set version [${PROJECT} define get version [${PROJECT} define get pkg_vers]]
    if {$version eq {}} {
      set version 0.1a
    }
    set defs $DEFS
    foreach flag {
      -DPACKAGE_NAME
      -DPACKAGE_VERSION
      -DPACKAGE_TARNAME
      -DPACKAGE_STRING
    } {
      if {[set i [string first $flag $defs]] >= 0} {
        set j [string first -D $flag [expr {$i+[string length $flag]}]]
        set predef [string range $defs 0 [expr {$i-1}]]
        set postdef [string range $defs $j end]
        set defs "$predef $postdef"
      }
    }
    append defs " -DPACKAGE_NAME=\"${name}\" -DPACKAGE_VERSION=\"${version}\""
    append defs " -DPACKAGE_TARNAME=\"${name}\" -DPACKAGE_STRING=\"${name}\x5c\x20${version}\""
    return $defs
  }

  method build-tclkit_main {PROJECT PKG_OBJS} {
  ###
  # Build static package list
  ###
  set statpkglist {}
  foreach cobj [list {*}${PKG_OBJS} $PROJECT] {
    foreach {pkg info} [$cobj static-packages] {
      dict set statpkglist $pkg $info
    }
  }
  foreach {ofile info} [${PROJECT} compile-products] {
    if {![dict exists $info object]} continue
    set cobj [dict get $info object]
    foreach {pkg info} [$cobj static-packages] {
      dict set statpkglist $pkg $info
    }
  }

  set result {}
  $PROJECT include {<tcl.h>}
  $PROJECT include {"tclInt.h"}
  $PROJECT include {"tclFileSystem.h"}
  $PROJECT include {<assert.h>}
  $PROJECT include {<stdio.h>}
  $PROJECT include {<stdlib.h>}
  $PROJECT include {<string.h>}
  $PROJECT include {<math.h>}

  $PROJECT code header {
#ifndef MODULE_SCOPE
#   define MODULE_SCOPE extern
#endif

/*
** Provide a dummy Tcl_InitStubs if we are using this as a static
** library.
*/
#ifndef USE_TCL_STUBS
# undef  Tcl_InitStubs
# define Tcl_InitStubs(a,b,c) TCL_VERSION
#endif
#define STATIC_BUILD 1
#undef USE_TCL_STUBS

/* Make sure the stubbed variants of those are never used. */
#undef Tcl_ObjSetVar2
#undef Tcl_NewStringObj
#undef Tk_Init
#undef Tk_MainEx
#undef Tk_SafeInit
}

  # Build an area of the file for #define directives and
  # function declarations
  set define {}
  set mainhook   [$PROJECT define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook]
  set mainfunc   [$PROJECT define get TCL_LOCAL_APPINIT Tclkit_AppInit]
  set mainscript [$PROJECT define get main.tcl main.tcl]
  set vfsroot    [$PROJECT define get vfsroot "[$PROJECT define get ZIPFS_VOLUME]app"]
  set vfs_main "${vfsroot}/${mainscript}"
  set vfs_tcl_library "${vfsroot}/boot/tcl"
  set vfs_tk_library "${vfsroot}/boot/tk"

  set map {}
  foreach var {
    vfsroot mainhook mainfunc vfs_main vfs_tcl_library vfs_tk_library
  } {
    dict set map %${var}% [set $var]
  }
  set preinitscript {
set ::odie(boot_vfs) {%vfsroot%}
set ::SRCDIR {%vfsroot%}
if {[file exists {%vfs_tcl_library%}]} {
  set ::tcl_library {%vfs_tcl_library%}
  set ::auto_path {}
}
if {[file exists {%vfs_tk_library%}]} {
  set ::tk_library {%vfs_tk_library%}
}
} ; # Preinitscript

  set zvfsboot {
/*
 * %mainhook% --
 * Performs the argument munging for the shell
 */
  }
  ::practcl::cputs zvfsboot {
  CONST char *archive;
  Tcl_FindExecutable(*argv[0]);
  archive=Tcl_GetNameOfExecutable();
  }
  # We have to initialize the virtual filesystem before calling
  # Tcl_Init().  Otherwise, Tcl_Init() will not be able to find
  # its startup script files.
  if {[$PROJECT define get tip_430 0]} {
    ::practcl::cputs zvfsboot "  if(!TclZipfs_Mount(NULL, archive, \"%vfsroot%\", NULL)) \x7B "
  } else {
    ::practcl::cputs zvfsboot {  Odie_Zipfs_Init(NULL);}
    ::practcl::cputs zvfsboot "  if(!Odie_Zipfs_Mount(NULL, archive, \"%vfsroot%\", NULL)) \x7B "
  }
  ::practcl::cputs zvfsboot {
    Tcl_Obj *vfsinitscript;
    vfsinitscript=Tcl_NewStringObj("%vfs_main%",-1);
    Tcl_IncrRefCount(vfsinitscript);
    if(Tcl_FSAccess(vfsinitscript,F_OK)==0) {
      /* Startup script should be set before calling Tcl_AppInit */
      Tcl_SetStartupScript(vfsinitscript,NULL);
    }
  }
  ::practcl::cputs zvfsboot "    TclSetPreInitScript([::practcl::tcl_to_c $preinitscript])\;"
  ::practcl::cputs zvfsboot "  \x7D else \x7B"
  ::practcl::cputs zvfsboot "    TclSetPreInitScript([::practcl::tcl_to_c {
foreach path {
  ../tcl
} {
  set p  [file join $path library init.tcl]
  if {[file exists [file join $path library init.tcl]]} {
    set ::tcl_library [file normalize [file join $path library]]
    break
  }
}
foreach path {
  ../tk
} {
  if {[file exists [file join $path library tk.tcl]]} {
    set ::tk_library [file normalize [file join $path library]]
    break
  }
}
}])\;"

  ::practcl::cputs zvfsboot "  \x7D"
  ::practcl::cputs zvfsboot "  return TCL_OK;"

  if {[$PROJECT define get TEACUP_OS] eq "windows"} {
    set header {int %mainhook%(int *argc, TCHAR ***argv)}
  } else {
    set header {int %mainhook%(int *argc, char ***argv)}
  }
  $PROJECT c_function  [string map $map $header] [string map $map $zvfsboot]

  practcl::cputs appinit "int %mainfunc%(Tcl_Interp *interp) \x7B"

  # Build AppInit()
  set appinit {}
  practcl::cputs appinit {
  if ((Tcl_Init)(interp) == TCL_ERROR) {
      return TCL_ERROR;
  }
}
  set main_init_script {}

  foreach {statpkg info} $statpkglist {
    set initfunc {}
    if {[dict exists $info initfunc]} {
      set initfunc [dict get $info initfunc]
    }
    if {$initfunc eq {}} {
      set initfunc [string totitle ${statpkg}]_Init
    }
    if {![dict exists $info version]} {
      error "$statpkg HAS NO VERSION"
    }
    # We employ a NULL to prevent the package system from thinking the
    # package is actually loaded into the interpreter
    $PROJECT code header "extern Tcl_PackageInitProc $initfunc\;\n"
    set script [list package ifneeded $statpkg [dict get $info version] [list ::load {} $statpkg]]
    append main_init_script \n [list set ::kitpkg(${statpkg}) $script]
    if {[dict get $info autoload]} {
      ::practcl::cputs appinit "  if(${initfunc}(interp)) return TCL_ERROR\;"
      ::practcl::cputs appinit "  Tcl_StaticPackage(interp,\"$statpkg\",$initfunc,NULL)\;"
    } else {
      ::practcl::cputs appinit "\n  Tcl_StaticPackage(NULL,\"$statpkg\",$initfunc,NULL)\;"
      append main_init_script \n $script
    }
  }
  append main_init_script \n {
if {[file exists [file join $::SRCDIR packages.tcl]]} {
  #In a wrapped exe, we don't go out to the environment
  set dir $::SRCDIR
  source [file join $::SRCDIR packages.tcl]
}
# Specify a user-specific startup file to invoke if the application
# is run interactively.  Typically the startup file is "~/.apprc"
# where "app" is the name of the application.  If this line is deleted
# then no user-specific startup file will be run under any conditions.
  }
  append main_init_script \n [list set tcl_rcFileName [$PROJECT define get tcl_rcFileName ~/.tclshrc]]
  practcl::cputs appinit "  Tcl_Eval(interp,[::practcl::tcl_to_c  $main_init_script]);"
  practcl::cputs appinit {  return TCL_OK;}
  $PROJECT c_function [string map $map "int %mainfunc%(Tcl_Interp *interp)"] [string map $map $appinit]
}

}
