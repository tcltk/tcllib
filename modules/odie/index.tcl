###
# index.tcl
#
# This file loads the rest of the odie package
#
# Copyright (c) 2012 Sean Woods
#
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.
###

###
# This version is always higher than the one embedded with
# the odie core to better exploit the C accellerated tools
###

package provide odie 0.2

###
# topic: 8b8d3c47197b0abe5005b2a644ebcb7d
###
proc ::load_path {path {ordered_files {}}} {
  lappend loaded index.tcl pkgIndex.tcl
  if {[file exists [file join $path baseclass.tcl]]} {
    lappend loaded baseclass.tcl
    uplevel #0 [list source [file join $path baseclass.tcl]]
  }
  foreach file $ordered_files {
    lappend loaded $file
    uplevel #0 [list source [file join $path $file]]
  }
  foreach file [glob -nocomplain [file join $path *.tcl]] {
    if {[file tail $file] in $loaded} continue
    lappend loaded [file tail $file]
    uplevel #0 [list source $file]
  }
}

set loaded {pkgIndex.tcl index.tcl}

set odie_path [file dirname [info script]]

load_path $odie_path {
  global.tcl
  stack.tcl
}
###
# Load the C accellerated modules
###
catch {package require odielib}

