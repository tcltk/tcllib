#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

set tcllib_version 1.3

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

set installdir [file join [file dirname [info library]] tcllib$tcllib_version]

puts "[info nameofexecutable] ..."
puts "Tcl script library at      [info library]"

file mkdir $installdir

if {[file exists pkgIndex.tcl]} {
    # Source distribution

    puts "Installing Tcllib $tcllib_version (Source distribution) into $installdir"

    file copy pkgIndex.tcl $installdir

    puts "\tCopying HTML documentation ..."

    xcopy [file join doc html] [file join $installdir doc]

    cd modules

    foreach module [glob -nocomplain *] {
	puts "\tCopying module $module ..."
	xcopy $module [file join $installdir $module]
    }
} else {
    # CVS snapshot.

    puts "Installing Tcllib $tcllib_version (CVS Snapshot) into $installdir"
    puts "This is not yet possible"

    exit 1
}

puts Done
exit
