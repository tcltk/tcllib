package provide codebale 0.2
package require odie
#package require odielib

::namespace eval ::codebale {}

###
# We use the fileutil package from tcllib, extensively
###
package require fileutil
foreach file [lsort -dictionary [glob [file join [file dirname [file normalize [info script]]] *.tcl]]] {
  if {[file tail $file] eq "index.tcl"} continue
  source $file
}

