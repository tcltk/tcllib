# control.tcl --
#
#	This is the main package provide script for the package
#	"control".  It provides commands that govern the flow of
#	control of a program.
#
# RCS: @(#) $Id: control.tcl,v 1.1 2001/08/21 22:54:15 dgp Exp $

package require Tcl 8

namespace eval ::control {
    variable version 0
    namespace export no-op

    variable home [file join [pwd] [file dirname [info script]]]

    # Set up for auto-loading the commands
    if {[lsearch -exact $::auto_path $home] == -1} {
	lappend ::auto_path $home
    }

    package provide [namespace tail [namespace current]] $version
}

