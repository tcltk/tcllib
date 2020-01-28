# @mdgen OWNER: generic.tcl
# @mdgen OWNER: available_ports.tcl
# @mdgen OWNER: locateport.tcl
# @mdgen OWNER: platform_unix_linux.tcl
# @mdgen OWNER: platform_unix_macosx.tcl
# @mdgen OWNER: platform_unix.tcl
# @mdgen OWNER: platform_windows.tcl

package require platform
# Uses the "ip" package from tcllib
package require ip

set here [file dirname [file normalize [info script]]]

::namespace eval ::nettool {}

proc ::nettool::cat filename {
  set fin [open $filename r]
  set dat [read $fin]
  close $fin
  return $dat
}

set genus [lindex [split [::platform::generic] -] 0]
dict set ::nettool::platform tcl_os  $::tcl_platform(os)
dict set ::nettool::platform odie_class   $::tcl_platform(platform)
dict set ::nettool::platform odie_genus   $genus
dict set ::nettool::platform odie_target  [::platform::generic]
dict set ::nettool::platform odie_species [::platform::identify]


