# mkIndex.tcl --
#
#	This script generates a pkgIndex.tcl file for tcllib.  It expects 
#	several arguments:
#		outdir		directory in which to create pkgIndex.tcl
#		package		package name (tcllib)
#		version 	package version
#		modules		list of modules to include
#
# Copyright (c) 1999-2000 Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

foreach {outdir package version} $argv {
    break
}
## set modules [lrange $argv 3 end]
cd $outdir
puts "Making pkgIndex.tcl in [pwd]"

## First run the standard package indexer. This creates a pkgIndex.tcl
## file in the directory modules. Read an transform this file into the
## final form.

# Add -verbose in case of trouble
pkg_mkIndex modules */*.tcl

set base  [open [file join modules pkgIndex.tcl] r]
set index [open pkgIndex.tcl w]

set trailer [list]

while {![eof $base]} {
    if {[gets $base line] < 0} {continue}
    puts $index $line
    if {[regexp {^package ifneeded} $line]} {
	foreach {_ _ pkg ver} [split $line] break
	lappend trailer "\tcatch \{package require $pkg $ver\}"
    }
}
close $base

puts  $index ""
puts  $index "package ifneeded $package $version \{"
puts  $index [join $trailer \n]
puts  $index "\tpackage provide $package $version"
puts  $index "\ttclLog \"Don't do \\\"package require $package\\\", ask for individual modules.\""
puts  $index "\}"
close $index

file delete [file join modules pkgIndex.tcl]
exit
