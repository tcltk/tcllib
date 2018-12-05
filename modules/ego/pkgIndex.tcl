#! /usr/bin/env tclsh

if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded ego 0.1 [list ::apply {dir {
    namespace eval ::tcllib::ego [list ::source $dir/ego.tcl]
    package provide ego 0.1
}} $dir]
