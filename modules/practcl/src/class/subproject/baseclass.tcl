oo::class create ::practcl::subproject {
  superclass ::practcl::object ::practcl::distribution

  method child which {
    switch $which {
      organs {
	# A library can be a project, it can be a module. Any
	# subordinate modules will indicate their existance
        return [list project [self] module [self]]
      }
    }
  }

  method compile {} {}

  method critcl args {
    if {![info exists critcl]} {
      ::pratcl::LOCAL tool critcl load
      set critcl [file join [::pratcl::LOCAL tool critcl define get srcdir] main.tcl
    }
    set srcdir [my SourceRoot]
    set PWD [pwd]
    cd $srcdir
    ::pratcl::dotclexec $critcl {*}$args
    cd $PWD
  }

  method go {} {
    set name [my define get name]
    set srcdir [my SrcDir]
    my define set localsrcdir $srcdir
    my define add include_dir [file join $srcdir generic]
    my sources
  }

  # Install project into the local build system
  method install args {}

  method linktype {} {
    return {subordinate package}
  }

  method linker-products {configdict} {}

  method linker-external {configdict} {
    if {[dict exists $configdict PRACTCL_PKG_LIBS]} {
      return [dict get $configdict PRACTCL_PKG_LIBS]
    }
  }

  method sources {} {}
}

###
# Trivial implementations
###


###
# A project which the kit compiles and integrates
# the source for itself
###
oo::class create ::practcl::subproject.source {
  superclass ::practcl::subproject ::practcl::library

  method linktype {} {
    return {subordinate package source}
  }

}

# a copy from the teapot
oo::class create ::practcl::subproject.teapot {
  superclass ::practcl::subproject

  method install-local {} {
    my install-vfs
  }

  method install DEST {
    set pkg [my define get pkg_name [my define get name]]
    set download [my <project> define get download]
    my unpack
    set prefix [string trimleft [my <project> define get prefix] /]
    ::practcl::tcllib_require zipfile::decode
    ::zipfile::decode::unzipfile [file join $download $pkg.zip] [file join $DEST $prefix lib $pkg]
  }
}

oo::class create ::practcl::subproject.kettle {
  superclass ::practcl::subproject

  method install-local {} {
    my install-vfs
  }

  method kettle {path args} {
    my variable kettle
    if {![info exists kettle]} {
      ::pratcl::LOCAL tool kettle load
      set kettle [file join [::pratcl::LOCAL tool kettle define get srcdir] kettle]
    }
    set srcdir [my SourceRoot]
    ::pratcl::dotclexec $kettle -f [file join $srcdir build.tcl] {*}$args
  }

  method install DEST {
    my kettle reinstall --prefix $DEST
  }
}

oo::class create ::practcl::subproject.critcl {
  superclass ::practcl::subproject

  method install-local {} {
    my install-vfs
  }

  method install DEST {
    my critcl -pkg [my define get name]
    set srcdir [my SourceRoot]
    ::pratcl::copyDir [file join $srcdir [my define get name]] [file join $DEST lib [my define get name]]
  }
}


oo::class create ::practcl::subproject.sak {
  superclass ::practcl::subproject

  method install-local {} {
    my install-vfs
  }

  method install DEST {
    ###
    # Handle teapot installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    my unpack
    set prefix [string trimleft [my <project> define get prefix] /]
    set srcdir [my define get srcdir]
    ::practcl::dotclexec [file join $srcdir installer.tcl] \
      -pkg-path [file join $DEST $prefix lib $pkg]  \
      -no-examples -no-html -no-nroff \
      -no-wait -no-gui -no-apps
  }
}
