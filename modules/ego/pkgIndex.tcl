#! /usr/bin/env tclsh

package ifneeded ego 0.1 [list ::apply {dir {
    namespace eval ::tcllib::ego [list ::source $dir/ego.tcl]
    package provide ego 0.1
}} $dir]
