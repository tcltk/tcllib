
###
# A binary package
###
oo::class create ::practcl::subproject.binary {
  superclass ::practcl::subproject

  method clean {} {
    set builddir [file normalize [my define get builddir]]
    if {![file exists $builddir]} return
    if {[file exists [file join $builddir make.tcl]]} {
      ::practcl::domake.tcl $builddir clean
    } else {
      ::practcl::domake $builddir clean
    }
  }

 method env-install {} {
    ###
    # Handle tea installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    set os [::practcl::local_os]
    my define set os $os
    my unpack
    set prefix [my <project> define get prefix [file normalize [file join ~ tcl]]]
    set srcdir [my define get srcdir]
    lappend options --prefix $prefix --exec-prefix $prefix
    my define set config_opts $options
    my go
    my clean
    my compile
    ::practcl::domake [my define get builddir] install
  }

  method project-compile-products {} {}

  method ComputeInstall {} {
    if {[my define exists install]} {
      switch [my define get install] {
        static {
          my define set static 1
          my define set autoload 0
        }
        static-autoload {
          my define set static 1
          my define set autoload 1
        }
        vfs {
          my define set static 0
          my define set autoload 0
          my define set vfsinstall 1
        }
        null {
          my define set static 0
          my define set autoload 0
          my define set vfsinstall 0
        }
        default {

        }
      }
    }
  }

  method go {} {
    next
    my ComputeInstall
    my define set builddir [my BuildDir [my define get masterpath]]
  }

  method linker-products {configdict} {
    if {![my define get static 0]} {
      return {}
    }
    set srcdir [my define get builddir]
    if {[dict exists $configdict libfile]} {
      return " [file join $srcdir [dict get $configdict libfile]]"
    }
  }

  method project-static-packages {} {
    if {![my define get static 0]} {
      return {}
    }
    set result [my define get static_packages]
    set statpkg  [my define get static_pkg]
    set initfunc [my define get initfunc]
    if {$initfunc ne {}} {
      set pkg_name [my define get pkg_name]
      if {$pkg_name ne {}} {
        dict set result $pkg_name initfunc $initfunc
        set version [my define get version]
        if {$version eq {}} {
          my unpack
          set info [my read_configuration]
          set version [dict get $info version]
          set pl {}
          if {[dict exists $info patch_level]} {
            set pl [dict get $info patch_level]
            append version $pl
          }
          my define set version $version
        }
        dict set result $pkg_name version $version
        dict set result $pkg_name autoload [my define get autoload 0]
      }
    }
    foreach item [my link list subordinate] {
      foreach {pkg info} [$item project-static-packages] {
        dict set result $pkg $info
      }
    }
    return $result
  }

  method BuildDir {PWD} {
    set name [my define get name]
    set debug [my define get debug 0]
    set project [my organ project]
    if {[$project define get LOCAL 0]} {
      return [my define get builddir [file join $PWD local $name]]
    }
    if {$debug} {
      return [my define get builddir [file join $PWD debug $name]]
    } else {
      return [my define get builddir [file join $PWD pkg $name]]
    }
  }

  method compile {} {
    set name [my define get name]
    set PWD $::CWD
    cd $PWD
    my unpack

    set srcdir [file normalize [my SrcDir]]
    my Collate_Source $PWD

    ###
    # Build a starter VFS for both Tcl and wish
    ###
    set srcdir [my define get srcdir]
    if {[my define get static 1]} {
      puts "BUILDING Static $name $srcdir"
    } else {
      puts "BUILDING Dynamic $name $srcdir"
    }
    if {[my define get USEMSVC 0]} {
      cd $srcdir
      if {[file exists [file join $srcdir make.tcl]]} {
        if {[my define get debug 0]} {
          ::practcl::domake.tcl $srcdir debug all
        } else {
          ::practcl::domake.tcl $srcdir all
        }
      } else {
        if {[file exists [file join $srcdir makefile.vc]]} {
          ::practcl::doexec nmake -f makefile.vc INSTALLDIR=[my <project> define get installdir]  {*}[my NmakeOpts] release
        } elseif {[file exists [file join $srcdir win makefile.vc]]} {
          cd [file join $srcdir win]
          ::practcl::doexec nmake -f makefile.vc INSTALLDIR=[my <project> define get installdir]  {*}[my NmakeOpts] release
        } else {
          error "No make.tcl or makefile.vc found for project $name"
        }
      }
    } else {
      cd $::CWD
      set builddir [file normalize [my define get builddir]]
      file mkdir $builddir
      if {![file exists [file join $builddir Makefile]]} {
        my Configure
      }
      if {[file exists [file join $builddir make.tcl]]} {
        if {[my define get debug 0]} {
          ::practcl::domake.tcl $builddir debug all
        } else {
          ::practcl::domake.tcl $builddir all
        }
      } else {
        ::practcl::domake $builddir all
      }
    }
    cd $PWD
  }

  method Configure {} {
    cd $::CWD
    my unpack
    ::practcl::toolset select [self]
    set srcdir [file normalize [my define get srcdir]]
    set builddir [file normalize [my define get builddir]]
    file mkdir $builddir
    if {[my define get USEMSVC 0]} {
      return
    }
    if {[file exists [file join $builddir autoconf.log]]} {
      file delete [file join $builddir autoconf.log]
    }
    if {![file exists [file join $srcdir configure]]} {
      if {[file exists [file join $srcdir autogen.sh]]} {
        cd $srcdir
        catch {exec sh autogen.sh >>& [file join $builddir autoconf.log]}
        cd $::CWD
      }
    }
    if {![file exists [file join $srcdir tclconfig install-sh]]} {
      # ensure we have tclconfig with all of the trimmings
      set teapath {}
      if {[file exists [file join $srcdir .. tclconfig install-sh]]} {
        set teapath [file join $srcdir .. tclconfig]
      } else {
        set tclConfigObj [::practcl::LOCAL tool tclconfig]
        $tclConfigObj load
        set teapath [$tclConfigObj define get srcdir]
      }
      set teapath [file normalize $teapath]
      #file mkdir [file join $srcdir tclconfig]
      if {[catch {file link -symbolic [file join $srcdir tclconfig] $teapath}]} {
        ::practcl::copyDir [file join $teapath] [file join $srcdir tclconfig]
      }
    }

    set opts [my ConfigureOpts]
    ::practcl::debug [list PKG [my define get name] CONFIGURE {*}$opts]
    ::practcl::log   [file join $builddir autoconf.log] [list  CONFIGURE {*}$opts]
    cd $builddir
    if {[my <project> define get CONFIG_SITE] ne {}} {
      set ::env(CONFIG_SITE) [my <project> define get CONFIG_SITE]
    }
    catch {exec sh [file join $srcdir configure] {*}$opts >>& [file join $builddir autoconf.log]}
    cd $::CWD
  }

  method install DEST {
    set PWD [pwd]
    set PREFIX  [my <project> define get prefix]
    ###
    # Handle teapot installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    if {[my <project> define get teapot] ne {}} {
      set TEAPOT [my <project> define get teapot]
      set found 0
      foreach ver [my define get pkg_vers [my define get version]] {
        set teapath [file join $TEAPOT $pkg$ver]
        if {[file exists $teapath]} {
          set dest  [file join $DEST [string trimleft $PREFIX /] lib [file tail $teapath]]
          ::practcl::copyDir $teapath $dest
          return
        }
      }
    }
    my compile
    if {[my define get USEMSVC 0]} {
      set srcdir [my define get srcdir]
      cd $srcdir
      puts "[self] VFS INSTALL $DEST"
      ::practcl::doexec nmake -f makefile.vc INSTALLDIR=$DEST {*}[my NmakeOpts] install
    } else {
      set builddir [my define get builddir]
      if {[file exists [file join $builddir make.tcl]]} {
        # Practcl builds can inject right to where we need them
        puts "[self] VFS INSTALL $DEST (Practcl)"
        ::practcl::domake.tcl $builddir install-package $DEST
      } elseif {[my define get broken_destroot 0] == 0} {
        # Most modern TEA projects understand DESTROOT in the makefile
        puts "[self] VFS INSTALL $DEST (TEA)"
        ::practcl::domake $builddir install DESTDIR=[::practcl::file_relative $builddir $DEST]
      } else {
        # But some require us to do an install into a fictitious filesystem
        # and then extract the gooey parts within.
        # (*cough*) TkImg
        set PREFIX [my <project> define get prefix]
        set BROKENROOT [::practcl::msys_to_tclpath [my <project> define get prefix_broken_destdir]]
        file delete -force $BROKENROOT
        file mkdir $BROKENROOT
        ::practcl::domake $builddir $install
        ::practcl::copyDir $BROKENROOT  [file join $DEST [string trimleft $PREFIX /]]
        file delete -force $BROKENROOT
      }
    }
    cd $PWD
  }

  method Autoconf {} {
    ###
    # Re-run autoconf for this project
    # Not a good idea in practice... but in the right hands it can be useful
    ###
    set pwd [pwd]
    set srcdir [file normalize [my define get srcdir]]
    cd $srcdir
    foreach template {configure.ac configure.in} {
      set input [file join $srcdir $template]
      if {[file exists $input]} {
        puts "autoconf -f $input > [file join $srcdir configure]"
        exec autoconf -f $input > [file join $srcdir configure]
      }
    }
    cd $pwd
  }
}

oo::class create ::practcl::subproject.tea {
  superclass ::practcl::subproject.binary

}

oo::class create ::practcl::subproject.library {
  superclass ::practcl::subproject.binary ::practcl::library
  method install DEST {
    my compile
  }
}

# An external library
oo::class create ::practcl::subproject.external {
  superclass ::practcl::subproject.binary
  method install DEST {
    my compile
  }
}
