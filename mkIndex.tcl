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
puts $index "if { \[lsearch \$auto_path \[file dirname \[info script\]\]\] == -1 } {"
puts $index "\tlappend auto_path \[file dirname \[info script\]\]"
puts $index "}"
puts $index "package ifneeded $package $version {"
foreach module $modules {
    puts $index "\tpackage require $module"
}
puts $index "\tpackage provide $package $version"
puts $index "}"
close $index
