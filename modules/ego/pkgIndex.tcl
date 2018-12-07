#! /usr/bin/env tclsh

if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded ego 0.1 [list ::source [file join $dir ego.tcl]]
