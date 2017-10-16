###
# Classes to manage tools that needed in the local environment
# to compile and/or installed other packages
###
oo::class create ::practcl::tool {
  superclass ::practcl::object ::practcl::distribution

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

  method SourceRoot {} {
    set info [my define dump]
    set result $info
    if {![my define exists srcdir]} {
      if {[dict exists $info srcdir]} {
        set srcdir [dict get $info srcdir]
      } elseif {[dict exists $info sandbox]} {
        set srcdir [file join [dict get $info sandbox] $pkg]
      } else {
        set srcdir [file join $::CWD .. $pkg]
      }
      dict set result srcdir $srcdir
      my define set srcdir $srcdir
    }
    return [my define get srcdir]
  }

  method linktype {} {
    return tool
  }

  # Return boolean if present
  method present {} {
    return 1
  }

  # Procedure to install in the local environment
  method install {} {
    my unpack
  }

  # Procedure to load into the local interpreter
  method load {} {
    my variable loaded
    if {[info exists loaded]} {
      return 0
    }
    if {![my present]} {
      my install
    }
    my LocalLoad
    set loaded 1
  }

  method LocalLoad {} {}
}

oo::class create ::practcl::tool.source {
  superclass ::practcl::tool

  method present {} {
    return [file exists [my define get srcdir]]
  }

  method toplevel_script {} {
    my load
    return [file join [my SourceRoot] [my define get toplevel_script]]
  }

  method LocalLoad {} {
    set LibraryRoot [file join [my define get srcdir] [my define get module_root modules]]
    if {[file exists $LibraryRoot] && $LibraryRoot ni $::auto_path} {
      set ::auto_path [linsert $::auto_path 0 $LibraryRoot]
    }
  }
}

###
# Create an object to represent the local environment
###
set ::practcl::MAIN ::practcl::LOCAL
# Defer the creation of the ::pratcl::LOCAL object until it is called
# in order to allow packages to
set ::auto_index(::practcl::LOCAL) {
  puts "Building LOCAL"
  ::practcl::project create ::practcl::LOCAL
  ::practcl::LOCAL define set [::practcl::local_os]
  # Until something better comes along, use ::practcl::LOCAL
  # as our main project
  # Add tclconfig as a project of record
  ::practcl::LOCAL add_tool tclconfig {
    name tclconfig tag practcl class tool.source fossil_url http://core.tcl.tk/tclconfig
  }
  # Add tcllib as a project of record
  ::practcl::LOCAL add_tool tcllib {
    tag trunk class tool.source fossil_url http://core.tcl.tk/tcllib
  }
  ::practcl::LOCAL add_tool kettle {
    tag trunk class tool.source fossil_url http://fossil.etoyoc.com/fossil/kettle
  }
  ::practcl::LOCAL add_tool critcl {
    tag trunk class tool.source
    git_url http://github.com/andreas-kupries/critcl
  }
  ::practcl::LOCAL add_tool odie {
    tag trunk class tool.source
    fossil_url http://fossil.etoyoc.com/fossil/odie
  }
}
