#----------------------------------------------------------------------
#
# calendar.tcl --
#
#	This file is the main 'package provide' script for the
#   	'calendar' package.  The package provides various commands for
#	manipulating dates and times.
#
# RCS:$(@) $Id: calendar.tcl,v 1.3 2003/04/25 00:22:37 andreas_kupries Exp $

package require Tcl 8.2

namespace eval ::calendar {

    variable home [file join [pwd] [file dirname [info script]]]
    if { [lsearch -exact $::auto_path $home] == -1 } {
	lappend ::auto_path $home
    }

    variable         version 0.2
    package provide calendar 0.2
}
