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
set modules [lrange $argv 3 end]
cd $outdir
puts "Making pkgIndex.tcl in [pwd]"

set index [open pkgIndex.tcl w]
puts $index "if { \[lsearch \$auto_path \$dir\] == -1 } {"
puts $index "\tlappend auto_path \$dir"
puts $index "\tif {!\[catch {package vcompare \[info patchlevel\] \[info patchlevel\]}\]} {"
puts $index "\t\tif {!\[package vsatisfies \[info patchlevel\] 8.3.1\]} {"
puts $index "\t\t\tforeach tlf \[glob -nocomplain \[file join \$dir * pkgIndex.tcl\]\] {"
puts $index "\t\t\t\tset dir \[file dirname \$tlf\]"
puts $index "\t\t\t\tsource \$tlf"
puts $index "\t\t\t}"
puts $index "\t\t\tcatch {unset tlf}"
puts $index "\t\t}"
puts $index "\t}"
puts $index "}"
puts $index "package ifneeded $package $version {"
foreach module $modules {
    puts $index "\tcatch {package require $module}"
}
puts $index "\tpackage provide $package $version"
puts $index "}"
close $index
