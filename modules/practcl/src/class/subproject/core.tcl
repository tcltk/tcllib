
oo::class create ::practcl::subproject.core {
  superclass ::practcl::subproject.binary

  # On the windows platform MinGW must build
  # from the platform directory in the source repo
  method BuildDir {PWD} {
    return [my define get localsrcdir]
  }

  method Configure {} {
    if {[my define get USEMSVC 0]} {
      return
    }
    set opts [my ConfigureOpts]
    set builddir [file normalize [my define get builddir]]
    set localsrcdir [file normalize [my define get localsrcdir]]
    puts [list PKG [my define get name] CONFIGURE {*}$opts]
    cd $localsrcdir
    if {[my <project> define get CONFIG_SITE] ne {}} {
      set ::env(CONFIG_SITE) [my <project> define get CONFIG_SITE]
    }
    catch {exec sh [file join $localsrcdir configure] {*}$opts >& [file join $builddir practcl.log]}
  }

  method ConfigureOpts {} {
    set opts {}
    set builddir [file normalize [my define get builddir]]
    set PREFIX [my <project> define get prefix]
    if {[my <project> define get CONFIG_SITE] != {}} {
      lappend opts --host=[my <project> define get HOST]
      lappend opts --with-tclsh=[info nameofexecutable]
    }
    lappend opts {*}[my define get config_opts]
    if {![regexp -- "--prefix" $opts]} {
      lappend opts --prefix=$PREFIX
    }
    #--exec_prefix=$PREFIX
    lappend opts --disable-shared
    return $opts
  }

  method go {} {
    set name [my define get name]
    set os [my <project> define get TEACUP_OS]
    my ComputeInstall
    set srcdir [my SrcDir]
    my define add include_dir [file join $srcdir generic]
    switch $os {
      windows {
        my define set localsrcdir [file join $srcdir win]
        my define add include_dir [file join $srcdir win]
      }
      default {
        my define set localsrcdir [file join $srcdir unix]
        my define add include_dir [file join $srcdir $name unix]
      }
    }
    my define set builddir [my BuildDir [my define get masterpath]]
  }

  method linktype {} {
    return {subordinate core.library}
  }

  method SrcDir {} {
    set pkg [my define get name]
    if {[my define exists srcdir]} {
      return [my define get srcdir]
    }
    set sandbox [my Sandbox]
    set debug [my define get debug 0]
    puts [list [self] NAME $pkg debug $debug]
    if {$debug} {
      set srcdir [file join [my Sandbox] $pkg.debug]
    } else {
      set srcdir [file join [my Sandbox] $pkg]
    }
    my define set srcdir $srcdir
    return $srcdir
  }
}
