# @mdgen OWNER: generic.tcl
# @mdgen OWNER: platform_*.tcl
package provide nettool 0.4

package require platform
# Uses the "ip" package from tcllib
package require ip

if {[info command ::ladd] eq {}} {
  proc ::ladd {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        set var {}
    }
    foreach item $args {
      if {$item in $var} continue
      lappend var $item
    }
    return $var
  }
}
if {[info command ::get] eq {}} {
  proc ::get varname {
    upvar 1 $varname var
    if {[info exists var]} {
      return [set var]
    }
    return {}
  }
}
if {[info command ::cat] eq {}} {
  proc ::cat filename {
    set fin [open $filename r]
    set dat [read $fin]
    close $fin
    return $dat
  }
}


set here [file dirname [file normalize [info script]]]

::namespace eval ::nettool {}

set genus [lindex [split [::platform::generic] -] 0]
dict set ::nettool::platform tcl_os  $::tcl_platform(os)
dict set ::nettool::platform odie_class   $::tcl_platform(platform)
dict set ::nettool::platform odie_genus   $genus
dict set ::nettool::platform odie_target  [::platform::generic]
dict set ::nettool::platform odie_species [::platform::identify]

source [file join $here generic.tcl]
source [file join $here available_ports.tcl]
source [file join $here locateport.tcl]

set platfile [file join $here platform_$::tcl_platform(platform).tcl]
if {[file exists $platfile]} {
  source $platfile
}
set genfile [file join $here platform_$::tcl_platform(platform)_$genus.tcl]
if {[file exists $genfile]} {
  source $genfile
}

::nettool::init

