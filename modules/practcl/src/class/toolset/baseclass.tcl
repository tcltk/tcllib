###
# Ancestor-less class intended to be a mixin
# which defines a family of build related behaviors
# that are modified when targetting either gcc or msvc
###
oo::class create ::practcl::toolset {
  ###
  # find or fake a key/value list describing this project
  ###
  method config.sh {} {
    return [my read_configuration]
  }

  method read_configuration {} {
    my variable conf_result
    if {[info exists conf_result]} {
      return $conf_result
    }
    set result {}
    set name [my define get name]
    set PWD $::CWD
    set builddir [my define get builddir]
    my unpack
    set srcdir [my define get srcdir]
    if {![file exists $builddir]} {
      my Configure
    }
    set filename [file join $builddir config.tcl]
    # Project uses the practcl template. Use the leavings from autoconf
    if {[file exists $filename]} {
      set dat [::practcl::read_configuration $builddir]
      foreach {item value} [::practcl::sort_dict $dat] {
        dict set result $item $value
      }
      set conf_result $result
      return $result
    }
    set filename [file join $builddir ${name}Config.sh]
    if {[file exists $filename]} {
      set l [expr {[string length $name]+1}]
      foreach {field dat} [::practcl::read_Config.sh $filename] {
        set field [string tolower $field]
        if {[string match ${name}_* $field]} {
          set field [string range $field $l end]
        }
        dict set result $field $dat
      }
      set conf_result $result
      return $result
    }
    ###
    # Oh man... we have to guess
    ###
    set filename [file join $builddir Makefile]
    if {![file exists $filename]} {
      error "Could not locate any configuration data in $srcdir"
    }
    foreach {field dat} [::practcl::read_Makefile $filename] {
      dict set result $field $dat
    }
    set conf_result $result
    cd $PWD
    return $result
  }

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

  method critcl args {
    if {![info exists critcl]} {
      ::practcl::LOCAL tool critcl env-load
      set critcl [file join [::practcl::LOCAL tool critcl define get srcdir] main.tcl
    }
    set srcdir [my SourceRoot]
    set PWD [pwd]
    cd $srcdir
    ::practcl::dotclexec $critcl {*}$args
    cd $PWD
  }

  method NmakeOpts {} {
    set opts {}
    set builddir [file normalize [my define get builddir]]

    if {[my <project> define exists tclsrcdir]} {
      ###
      # On Windows we are probably running under MSYS, which doesn't deal with
      # spaces in filename well
      ###
      set TCLSRCDIR  [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tclsrcdir] ..]]]
      set TCLGENERIC [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tclsrcdir] .. generic]]]
      lappend opts TCLDIR=[file normalize $TCLSRCDIR]
      #--with-tclinclude=$TCLGENERIC
    }
    if {[my <project> define exists tksrcdir]} {
      set TKSRCDIR  [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tksrcdir] ..]]]
      set TKGENERIC [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tksrcdir] .. generic]]]
      #lappend opts --with-tk=$TKSRCDIR --with-tkinclude=$TKGENERIC
      lappend opts TKDIR=[file normalize $TKSRCDIR]
    }
    return $opts
  }

  method ConfigureOpts {} {
    set opts {}
    set builddir [my define get builddir]
    if {[my define get broken_destroot 0]} {
      set PREFIX [my <project> define get prefix_broken_destdir]
    } else {
      set PREFIX [my <project> define get prefix]
    }
    if {[my <project> define get CONFIG_SITE] != {}} {
      lappend opts --host=[my <project> define get HOST]
    }
    set inside_msys [string is true -strict [my <project> define get MSYS_ENV 0]]
    lappend opts --with-tclsh=[info nameofexecutable]
    if {![my <project> define get LOCAL 0]} {
      set obj [my <project> tclcore]
      if {$obj ne {}} {
        if {$inside_msys} {
          lappend opts --with-tcl=[::practcl::file_relative [file normalize $builddir] [$obj define get builddir]]
        } else {
          lappend opts --with-tcl=[file normalize [$obj define get builddir]]
        }
      }
      if {[my define get tk 0]} {
        set obj [my <project> tkcore]
        if {$obj ne {}} {
          if {$inside_msys} {
            lappend opts --with-tk=[::practcl::file_relative [file normalize $builddir] [$obj define get builddir]]
          } else {
            lappend opts --with-tk=[file normalize [$obj define get builddir]]
          }
        }
      }
    } else {
      lappend opts --with-tcl=[file join $PREFIX lib]
      if {[my define get tk 0]} {
        lappend opts --with-tk=[file join $PREFIX lib]
      }
    }
    lappend opts {*}[my define get config_opts]
    if {![regexp -- "--prefix" $opts]} {
      lappend opts --prefix=$PREFIX --exec-prefix=$PREFIX
    }
    if {[my define get debug 0]} {
      lappend opts --enable-symbols=true
    }
    #--exec_prefix=$PREFIX
    #if {$::tcl_platform(platform) eq "windows"} {
    #  lappend opts --disable-64bit
    #}
    if {[my define get static 1]} {
      lappend opts --disable-shared
      #--disable-stubs
      #
    } else {
      lappend opts --enable-shared
    }
    return $opts
  }

  #method unpack {} {
  #  ::practcl::distribution select [self]
  #  my Unpack
  #}
}


oo::objdefine ::practcl::toolset {


  method select object {
    ###
    # Select the toolset to use for this project
    ###
    if {[$object define exists toolset]} {
      return [$object define get toolset]
    }
    set class [$object define get toolset]
    if {$class ne {}} {
      $object mixin toolset $class
    } else {
      if {[info exists ::env(VisualStudioVersion)]} {
        $object mixin toolset ::practcl::toolset.msvc
      } else {
        $object mixin toolset ::practcl::toolset.gcc
      }
    }
  }
}
