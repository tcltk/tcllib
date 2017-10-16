
::oo::class create ::practcl::project {
  superclass ::practcl::module ::practcl::autoconf

  constructor args {
    my variable define
    if {[llength $args] == 1} {
      set rawcontents [lindex $args 0]
    } else {
      set rawcontents $args
    }
    if {[catch {uplevel 1 [list subst $rawcontents]} contents]} {
      set contents $rawcontents
    }
    ###
    # The first instance of ::practcl::project (or its descendents)
    # registers itself as the ::practcl::MAIN. If a project other
    # than ::practcl::LOCAL is created, odds are that was the one
    # the developer intended to be the main project
    ###
    if {$::practcl::MAIN eq "::practcl::LOCAL"} {
      set ::practcl::MAIN [self]
    }
    # DEFS fields need to be passed unchanged and unsubstituted
    # as we need to preserve their escape characters
    foreach field {TCL_DEFS DEFS TK_DEFS} {
      if {[dict exists $rawcontents $field]} {
        dict set contents $field [dict get $rawcontents $field]
      }
    }
    array set define $contents
    my select
    my initialize
  }

  method add_project {pkg info {oodefine {}}} {
    set os [my define get TEACUP_OS]
    if {$os eq {}} {
      set os [::practcl::os]
      my define set os $os
    }
    set fossilinfo [list download [my define get download] tag trunk sandbox [my define get sandbox]]
    if {[dict exists $info os] && ($os ni [dict get $info os])} return
    # Select which tag to use here.
    # For production builds: tag-release
    set profile [my define get profile release]:
    if {[dict exists $info profile $profile]} {
      dict set info tag [dict get $info profile $profile]
    }
    dict set info USEMSVC [my define get USEMSVC 0]
    dict set info debug [my define get debug 0]
    set obj [namespace current]::PROJECT.$pkg
    if {[info command $obj] eq {}} {
      set obj [::practcl::subproject create $obj [self] [dict merge $fossilinfo [list name $pkg pkg_name $pkg static 0 class subproject.binary] $info]]
    }
    my link object $obj
    oo::objdefine $obj $oodefine
    $obj define set masterpath $::CWD
    $obj go
    return $obj
  }

  method add_tool {pkg info {oodefine {}}} {
    set info [dict merge [::practcl::local_os] $info]
    set os [dict get $info TEACUP_OS]
    set fossilinfo [list download [my define get download] tag trunk sandbox [my define get sandbox]]
    if {[dict exists $info os] && ($os ni [dict get $info os])} return
    # Select which tag to use here.
    # For production builds: tag-release
    set profile [my define get profile release]:
    if {[dict exists $info profile $profile]} {
      dict set info tag [dict get $info profile $profile]
    }
    set obj [namespace current]::TOOL.$pkg
    if {[info command $obj] eq {}} {
      set obj [::practcl::tool create $obj [self] [dict merge $fossilinfo [list name $pkg pkg_name $pkg static 0] $info]]
    }
    my link object $obj
    oo::objdefine $obj $oodefine
    $obj define set masterpath $::CWD
    $obj go
    return $obj
  }

  method child which {
    switch $which {
      organs {
	# A library can be a project, it can be a module. Any
	# subordinate modules will indicate their existance
        return [list project [self] module [self]]
      }
    }
  }

  method linktype {} {
    return project
  }

  # Exercise the methods of a sub-object
  method project {pkg args} {
    set obj [namespace current]::PROJECT.$pkg
    if {[llength $args]==0} {
      return $obj
    }
    ${obj} {*}$args
  }

  method select {} {
    next
    ###
    # Select the toolset to use for this project
    ###
    my variable define
    set class {}
    if {[info exists define(toolset)]} {
      if {[info command $define(toolset)] ne {}} {
        set class $define(toolset)
      } elseif {[info command ::practcl::$define(toolset)] ne {}} {
        set class ::practcl::$define(toolset)
      } else {
        switch $define(toolset) {
          default {
            set class ::practcl::build.gcc
          }
        }
      }
    } else {
      if {[info exists ::env(VisualStudioVersion)]} {
        set class ::practcl::build.msvc
      } else {
        set class ::practcl::build.gcc
      }
    }
    ::oo::objdefine [self] mixin $class
  }

  method tool {pkg args} {
    set obj [namespace current]::TOOL.$pkg
    if {[llength $args]==0} {
      return $obj
    }
    ${obj} {*}$args
  }
}
