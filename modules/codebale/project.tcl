::namespace eval ::codebale {}

###
# topic: 297048c11cac778e1b5b7d3dcb41b546
###
proc ::codebale::_project_detect_root path {
  set here [file normalize $path]
  while 1 {
    if {[file dirname $here] eq $::odie(sandbox)} {
      return $here
    }
    if {[file dirname $here] eq $::odie(local_repo)} {
      error "Could not detect project root"
    }
    if {[file dirname $here] eq "/"} {
      error "Could not detect project"
    }
    if {[file dirname $here] eq ""} {
      error "Could not detect project"
    }
    if {[file exists [file join $here sherpa.txt]]} {
      return $here
    }
    if {[file exists [file join $here .fslckout]]} {
      return $here
    }
    if {[file exists [file join $here _FOSSIL_]]} {
      return $here
    }
    if {[file exists [file join $here .git]]} {
      return $here
    }
    set here [file dirname $here]
  }
  error "Could not detect project"
}

###
# topic: 7bb613fd690a29ecf89e8923c152c166
###
proc ::codebale::_project_fossil_info {} {
  set dat [exec $::odie(fossil) info]
  set result {}
  foreach line [split $dat \n] {
    set n [string first ":" $line]
    if { $n < 0 } break
    set keyword [string range $line 0 $n]
    switch $keyword {
      parent: {
        dict lappend result parent:  [lindex $line end-3]
      }
      checkout: {
        dict set result checkout:  [lindex $line end-3]
        dict set result timestamp: [lrange $line end-2 end]
      }
      comment: {
        break
      }
      default {
        dict set result $keyword [string trim [string range $line $n+1 end]]
      }
    }
  }
  return $result
}

###
# topic: f154056d71dcbbd481fac3c0ed71c8b4
###
proc ::codebale::_project_teapot_info teapotfile {
  set fin [open $teapotfile]
  set fd [open $teapot r]
  set result {}
  set package_requires {}
  set description {}
  for {gets $fd line} {![eof $fd]} {gets $fd line} {
    if {[string match "Package *" $line]} {
      dict set info package-name: [lindex $line 1]
      dict set info package-version: [lindex $line 2]
    } elseif {[string match "Meta description *" $line]} {
      append description \n [string range $line 16 end]
    } elseif {[string match "Meta *" $line]} {
      if {![info complete $line]} continue
      set field [lindex $line 1]
      switch $field {
        as::author {
          dict set result author: [lrange $line 2 end]
        }
        as::origin {
          dict set result url: [lrange $line 2 end]
        }
        require {
          lappend package_requires {*}[lrange $line 2 end]
        }
        default {
          dict set result [lindex $line 1] [lrange $line 2 end]
        }
      }

    } elseif {[string match "Meta plaform *"]}
  }
  dict set result package-requires: ${package_requires}
  dict set result description: ${description}

}

###
# topic: 55101762c3907b5b5f9acbe761dba7d6
# description: Codebale project management tools
###
proc ::codebale::project_detect path {
  set root [_project_detect_root $path]
  dict set result local-root: $root
  cd $root
  dict set result package-name: [file tail $root]
  # Detect info from Fossil
  if {[file exists [file join $root $::odie(fskckout)]]} {
    foreach {field val} [_project_fossil_info] {
      dict set result $field $val
    }
  }
  # Detect info from teapot
  if {[file exists [file join $root teapot.txt]]} {
    foreach {field val} [_project_teapot_info [file join $root teapot.txt]] {
      dict set result $field $val
    }
  }
  # Detect Modules
  set modules {}
  foreach item [lsort -dictionary [glob -nocomplain [file join $root modules *]]] {
    if {[file isdirectory $item]} {
      lappend modules [file tail $item]
    }
  }
  dict set result modules: $modules
  return $result
}

