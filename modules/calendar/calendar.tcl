#----------------------------------------------------------------------
#
# calendar.tcl --
#
#	This file is the main 'package provide' script for the
#   	'calendar' package.  The package provides various commands for
#	manipulating dates and times.
#
# RCS:$(@) $Id: calendar.tcl,v 1.2 2003/04/11 19:10:42 andreas_kupries Exp $

package require Tcl 8.2

namespace eval ::calendar {

    variable version 0.2

    variable home [file join [pwd] [file dirname [info script]]]
    if { [lsearch -exact $::auto_path $home] == -1 } {
	lappend ::auto_path $home
    }

    package provide [namespace tail [namespace current]] $version
}
