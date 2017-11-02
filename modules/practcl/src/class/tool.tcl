###
# Classes to manage tools that needed in the local environment
# to compile and/or installed other packages
###
oo::class create ::practcl::tool {
  superclass ::practcl::object

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
    my morph $class
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

  method unpack {} {
    ::practcl::distribution select [self]
    my Unpack
  }
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

oo::class create ::practcl::tool.tea {
  superclass ::practcl::tool ::practcl::subproject.binary

  method present {} {
    return [expr {![catch {package require [my define get pkg_name [my define get name]]}]}]
  }

}

oo::class create ::practcl::tool.core {
  superclass ::practcl::tool ::practcl::subproject.core

  method present {} {
    return [expr {![catch {package require [my define get pkg_name [my define get name]]}]}]
  }

}

###
# Create an object to represent the local environment
###
set ::practcl::MAIN ::practcl::LOCAL
# Defer the creation of the ::pratcl::LOCAL object until it is called
# in order to allow packages to
set ::auto_index(::practcl::LOCAL) {
  ::practcl::project create ::practcl::LOCAL
  ::practcl::LOCAL define set [::practcl::local_os]
  ::practcl::LOCAL define set prefix [file normalize [file join ~ tcl]]
  ::practcl::LOCAL define set LOCAL 1

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
  ::practcl::LOCAL add_tool tclvfs {
    tag trunk class tool.tea
    fossil_url http://fossil.etoyoc.com/fossil/tclvfs
  }
  ::practcl::LOCAL add_tool critcl {
    tag master class tool.source
    git_url http://github.com/andreas-kupries/critcl
    modules lib
  }
  ::practcl::LOCAL add_tool odie {
    tag trunk class tool.source
    fossil_url http://fossil.etoyoc.com/fossil/odie
  }
  ::practcl::LOCAL add_tool tcl {
    tag release class tool.core
    fossil_url http://core.tcl.tk/tcl
  }
  ::practcl::LOCAL add_tool tk {
    tag release class tool.core
    fossil_url http://core.tcl.tk/tcl
  }
}
