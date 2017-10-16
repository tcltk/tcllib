

::oo::class create ::practcl::tclkit {
  superclass ::practcl::library

  method Collate_Source CWD {
    set name [my define get name]
    # Assume a static shell
    if {[my define exists SHARED_BUILD]} {
      my define set SHARED_BUILD 0
    }
    if {![my define exists TCL_LOCAL_APPINIT]} {
      my define set TCL_LOCAL_APPINIT Tclkit_AppInit
    }
    if {![my define exists TCL_LOCAL_MAIN_HOOK]} {
      my define set TCL_LOCAL_MAIN_HOOK Tclkit_MainHook
    }
    set PROJECT [self]
    set os [$PROJECT define get TEACUP_OS]
    if {[my define get SHARED_BUILD]} {
      puts [list BUILDING TCLSH FOR OS $os]
    } else {
      puts [list BUILDING KIT FOR OS $os]
    }
    set TCLOBJ [$PROJECT project TCLCORE]
    set TCLSRCDIR [$TCLOBJ define get srcdir]
    set PKG_OBJS {}
    foreach item [$PROJECT link list core.library] {
      if {[string is true [$item define get static]]} {
        lappend PKG_OBJS $item
      }
    }
    foreach item [$PROJECT link list package] {
      if {[string is true [$item define get static]]} {
        lappend PKG_OBJS $item
      }
    }
    # Arrange to build an main.c that utilizes TCL_LOCAL_APPINIT and TCL_LOCAL_MAIN_HOOK
    if {$os eq "windows"} {
      set PLATFORM_SRC_DIR win
      if {[my define get SHARED_BUILD]} {
        my add class csource filename [file join $TCLSRCDIR win tclWinReg.c] initfunc Registry_Init pkg_name registry pkg_vers 1.3.1 autoload 1
        my add class csource filename [file join $TCLSRCDIR win tclWinDde.c] initfunc Dde_Init pkg_name dde pkg_vers 1.4.0 autoload 1
      }
      my add class csource ofile [my define get name]_appinit.o filename [file join $TCLSRCDIR win tclAppInit.c] extra [list -DTCL_LOCAL_MAIN_HOOK=[my define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook] -DTCL_LOCAL_APPINIT=[my define get TCL_LOCAL_APPINIT Tclkit_AppInit]]
    } else {
      set PLATFORM_SRC_DIR unix
      my add class csource ofile [my define get name]_appinit.o filename [file join $TCLSRCDIR unix tclAppInit.c] extra [list -DTCL_LOCAL_MAIN_HOOK=[my define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook] -DTCL_LOCAL_APPINIT=[my define get TCL_LOCAL_APPINIT Tclkit_AppInit]]
    }

    if {[my define get SHARED_BUILD]} {
      ###
      # Add local static Zlib implementation
      ###
      set cdir [file join $TCLSRCDIR compat zlib]
      foreach file {
        adler32.c compress.c crc32.c
        deflate.c infback.c inffast.c
        inflate.c inftrees.c trees.c
        uncompr.c zutil.c
      } {
        my add [file join $cdir $file]
      }
    }
    ###
    # Pre 8.7, Tcl doesn't include a Zipfs implementation
    # in the core. Grab the one from odielib
    ###
    set zipfs [file join $TCLSRCDIR generic tclZipfs.c]
    if {![$PROJECT define exists ZIPFS_VOLUME]} {
      $PROJECT define set ZIPFS_VOLUME "zipfs:/"
    }
    $PROJECT code header "#define ZIPFS_VOLUME \"[$PROJECT define get ZIPFS_VOLUME]\""
    if {[file exists $zipfs]} {
      $TCLOBJ define set tip_430 1
      my define set tip_430 1
    } else {
      # The Tclconfig project maintains a mirror of the version
      # released with the Tcl core
      my define set tip_430 0
      ::practcl::LOCAL tool odie load
      set COMPATSRCROOT [::practcl::LOCAL tool odie define get srcdir]
      my add [file join $COMPATSRCROOT compat zipfs zipfs.tcl]
    }

    my define add include_dir [file join $TCLSRCDIR generic]
    my define add include_dir [file join $TCLSRCDIR $PLATFORM_SRC_DIR]
    # This file will implement TCL_LOCAL_APPINIT and TCL_LOCAL_MAIN_HOOK
    my build-tclkit_main $PROJECT $PKG_OBJS
  }

  ## Wrap an executable
  #
  method wrap {PWD exename vfspath args} {
    cd $PWD
    if {![file exists $vfspath]} {
      file mkdir $vfspath
    }
    foreach item [my link list core.library] {
      set name  [$item define get name]
      set libsrcdir [$item define get srcdir]
      if {[file exists [file join $libsrcdir library]]} {
        ::practcl::copyDir [file join $libsrcdir library] [file join $vfspath boot $name]
      }
    }
    # Assume the user will populate the VFS path
    #if {[my define get installdir] ne {}} {
    #  ::practcl::copyDir [file join [my define get installdir] [string trimleft [my define get prefix] /] lib] [file join $vfspath lib]
    #}
    foreach arg $args {
       ::practcl::copyDir $arg $vfspath
    }

    set fout [open [file join $vfspath packages.tcl] w]
    puts $fout {
set ::PKGIDXFILE [info script]
set dir [file dirname $::PKGIDXFILE]
if {$::tcl_platform(platform) eq "windows"} {
  set ::g(HOME) [file join [file normalize $::env(LOCALAPPDATA)] tcl]
} else {
  set ::g(HOME) [file normalize ~/tcl]
}
lappend ::auto_path [file join $::g(HOME) teapot]
}
    puts $fout [list proc installDir [info args ::practcl::installDir] [info body ::practcl::installDir]]
    set EXEEXT [my define get EXEEXT]
    set tclkit_bare [my define get tclkit_bare]
    set buffer [::practcl::pkgindex_path $vfspath]
    puts $fout $buffer
    puts $fout {
# Advertise statically linked packages
foreach {pkg script} [array get ::kitpkg] {
  eval $script
}
}
    close $fout
    ::practcl::mkzip ${exename}${EXEEXT} $tclkit_bare $vfspath
    if { [my define get TEACUP_OS] ne "windows" } {
      file attributes ${exename}${EXEEXT} -permissions a+x
    }
  }
}
