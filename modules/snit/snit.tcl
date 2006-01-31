# snit.tcl
# Snit's Not Incr Tcl, a simple object system in Pure Tcl.
#
# Copyright (C) 2003-2005 by William H. Duquette
# This code is licensed as described in license.txt.

package require Tcl 8.3

# Select the implementation based on the version of the Tcl core
# executing this code. For 8.3 we use a backport emulating various
# 8.4 features

if {[package vsatisfies [package provide Tcl] 8.4]} {
    source [file join [file dirname [info script]] snit84.tcl]
} else {
    source [file join [file dirname [info script]] snit83.tcl]
}

package provide snit 1.1

