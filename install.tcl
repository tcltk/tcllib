#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

# Install tcllib in the lib directory of the tclsh used to execute
# this script.

proc xcopy {src dest} {
    file mkdir $dest
    foreach file [glob [file join $src *]] {
        set base [file tail $file]
	set sub  [file join $dest $base]

        if {[file isdirectory $file]} then {
            file mkdir  $sub
            xcopy $file $sub
        } else {
            file copy $file $sub
        }
    }
}

set installdir [file join [file dirname [info library]] tcllib1.3]

puts "[info nameofexecutable] ..."
puts "Tcl script library at      [info library]"
puts "Installing Tcllib 1.3 into $installdir"

file mkdir $installdir
file copy pkgIndex.tcl $installdir

puts "\tCopying HTML documentation ..."

xcopy [file join doc html] [file join $installdir doc]

cd modules

foreach module [glob -nocomplain *] {
    puts "\tCopying module $module ..."

    xcopy $module [file join $installdir $module]
}

puts Done
exit
