package provide nettool 0.3

package require odie
package require platform
# Uses the "ip" package from tcllib
package require ip

set here [file dirname [file normalize [info script]]]

::namespace eval ::nettool {}

set genus [lindex [split [::platform::generic] -] 0]
dict set ::nettool::platform tcl_os  $::tcl_platform(os)
dict set ::nettool::platform odie_class   $::tcl_platform(platform)
dict set ::nettool::platform odie_genus   $genus
dict set ::nettool::platform odie_target  [::platform::generic]
dict set ::nettool::platform odie_species [::platform::identify]

::load_path [file join $here] {}

if {[file exists [file join $here platform $::tcl_platform(platform) generic.tcl]]} {
  source [file join $here platform $::tcl_platform(platform) generic.tcl]
}

if {[file exists [file join $here platform $::tcl_platform(platform) $genus.tcl]]} {
  source [file join $here platform $::tcl_platform(platform) $genus.tcl]
}

::nettool::init

