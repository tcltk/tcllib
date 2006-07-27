# -*- tcl -*-
# Implementation of 'doc'.

# Available variables
# * argv  - Cmdline arguments
# * base  - Location of sak.tcl = Topd directory of Tcllib distribution
# * cbase - Location of all files relevant to this command.
# * sbase - Location of all files supporting the SAK.

package require sak::util
if {![sak::util::checkModules argv]} return

puts "@@ Shell is \"[info nameofexecutable]\""

exec [info nameofexecutable] \
    [file join $distribution support devel all.tcl] \
    -modules $argv \
    >@ stdout 2>@ stderr

##
# ###
