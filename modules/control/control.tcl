# control.tcl --
#
#	This is the main package provide script for the package
#	"control".  It provides commands that govern the flow of
#	control of a program.
#
# RCS: @(#) $Id: control.tcl,v 1.12 2003/04/25 00:22:38 andreas_kupries Exp $

package require Tcl 8.2

namespace eval ::control {
    namespace export assert control do no-op rswitch

    proc control {command args} {
	# Need to add error handling here
	namespace eval [list $command] $args
    }

    # Set up for auto-loading the commands
    variable home [file join [pwd] [file dirname [info script]]]
    if {[lsearch -exact $::auto_path $home] == -1} {
	lappend ::auto_path $home
    }

    variable        version 0.1.2
    package provide control 0.1.2
}

