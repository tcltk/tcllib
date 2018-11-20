#! /usr/bin/env tclsh


package ifneeded {chan getslimit} 0.1 [list ::apply {dir {
    package require {chan base}
    ::tcllib::chan::base .new ::tcllib::chan::getslimit
    ::tcllib::chan::getslimit .specialize
    ::tcllib::chan::getslimit .eval [list ::source $dir/getslimit.tcl]
    namespace eval ::tcllib::chan {
	namespace export getslimit
    }
    package provide {chan getslimit} 0.1
}} $dir]


package ifneeded {chan base} 0.1 [list ::apply {dir {
    package require ego
    tcllib::ego .new ::tcllib::chan::base 
    ::tcllib::chan::base .eval [list ::source  $dir/base.tcl]
    namespace eval ::tcllib::chan {
	namespace export base
    }
    package provide {chan base} 0.1
}} $dir]
