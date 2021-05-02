#! /usr/bin/env tclsh


package ifneeded {chan getslimit} 0.1 [list ::apply {dir {
    namespace eval ::tcllib::chan::getslimit [
		list ::source [file join $dir getslimit.tcl]]
    package provide {chan getslimit} 0.1
    namespace eval ::tcllib::chan {
	namespace export getslimit
    }
}} $dir]


package ifneeded {chan base} 0.1 [list ::apply {dir {
	namespace eval ::tcllib::chan::base [
		list ::source [file join $dir base.tcl]]
    namespace eval ::tcllib::chan {
		namespace export base
    }
    package provide {chan base} 0.1
}} $dir]


package ifneeded {chan coroutine} 0.1 [list ::apply {dir {
    namespace eval ::tcllib::chan::coroutine [
		list ::source [file join $dir coroutine.tcl]]
    package provide {chan coroutine} 0.1
    namespace eval ::tcllib::chan {
	namespace export coroutine
    }
}} $dir]
