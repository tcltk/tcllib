# -*- tcl -*-
# Implementation of 'note'.

# Available variables
# * argv  - Cmdline arguments
# * base  - Location of sak.tcl = Top directory of Tcllib distribution
# * cbase - Location of all files relevant to this command.
# * sbase - Location of all files supporting the SAK.

package require sak::util
package require sak::note

set raw  0
set log  0
set stem {}
set tclv {}

if {![llength $argv]} {
    sak::note::show
    return
}
if {[llength $argv] == 1} {
    set f [lindex $argv 0]
    if {![file exists $f] ||
	![file isfile $f] ||
	![file readable $f]
    } {
	sak::note::usage
    }
    set c [open $f]
    set d [string trimright [read $c]]
    close $c

    foreach line [split $d \n] {
	if {[llength $line] < 3} {
	    puts stdout "\tBad line: '$line'"
	    exit 1
	}
	foreach {m p} $line break
	set notes [lrange $line 2 end]
	sak::note::run $m $p $notes
    }
    return
} elseif {[llength $argv] < 3} {
    sak::note::usage
}
foreach {m p} $argv break
set notes [lrange $argv 2 end]

sak::note::run $m $p $notes

##
# ###
