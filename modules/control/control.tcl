# control.tcl --
#
#	This is the main package provide script for the package
#	"control".  It provides commands that govern the flow of
#	control of a program.
#
# RCS: @(#) $Id: control.tcl,v 1.13 2003/05/01 00:17:40 andreas_kupries Exp $

package require Tcl 8.2

namespace eval ::control {
    variable version 0.1.2
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

    package provide [namespace tail [namespace current]] $version
}

