# all.tcl --
#
# This file contains a top-level script to run all of the Tcl
# tests.  Execute it by invoking "source all.test" when running tcltest
# in this directory.
#
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: all.tcl,v 1.1 2000/03/09 19:44:31 ericm Exp $

if {[lsearch [namespace children] ::tcltest] == -1} {
    namespace eval ::tcltest {}
    proc ::tcltest::processCmdLineArgsFlagsHook {} {
	return [list -modules]
    }
    proc ::tcltest::processCmdLineArgsHook {argv} {
	array set foo $argv
	set ::modules $foo(-modules)
    }
    proc ::tcltest::cleanupTestsHook {{c {}}} {
	if { [string equal $c ""] } {
	    return
	}
	# Get total/pass/skip/fail counts
	array set foo [$c eval {array get ::tcltest::numTests}]
	foreach index [list "Total" "Passed" "Skipped" "Failed"] {
	    incr ::tcltest::numTests($index) $foo($index)
	}
	incr ::tcltest::numTestFiles

	# Append the list of failFiles if necessary
	set f [$c eval {
	    set ff $::tcltest::failFiles
	    if {($::tcltest::currentFailure) && \
		    ([lsearch -exact $ff $testFileName] == -1)} {
		set res [file join $::tcllibModule $testFileName]
	    } else {
		set res ""
	    }
	    set res
	}]
	if { ![string equal $f ""] } {
	    lappend ::tcltest::failFiles $f
	}

	# Get the "skipped because" information
	unset foo
	array set foo [$c eval {array get ::tcltest::skippedBecause}]
	foreach constraint [array names foo] {
	    if { ![info exists ::tcltest::skippedBecause($constraint)] } {
		set ::tcltest::skippedBecause($constraint) $foo($constraint)
	    } else {
		incr ::tcltest::skippedBecause($constraint) $foo($constraint)
	    }
	}

	# Clean out the state in the slave
	$c eval {
	    foreach index [list "Total" "Passed" "Skipped" "Failed"] {
		set ::tcltest::numTests($index) 0
	    }
	    set ::tcltest::failFiles {}
	    foreach constraint [array names ::tcltest::skippedBecause] {
		unset ::tcltest::skippedBecause($constraint)
	    }
	}
    }

    package require tcltest
    namespace import ::tcltest::*
}

set ::tcltest::testSingleFile false
set ::tcltest::testsDirectory [file dir [info script]]
set root $::tcltest::testsDirectory

# We need to ensure that the testsDirectory is absolute
::tcltest::normalizePath ::tcltest::testsDirectory

puts stdout "tcllib tests"
puts stdout "Tests running in working dir:  $::tcltest::testsDirectory"
if {[llength $::tcltest::skip] > 0} {
    puts stdout "Skipping tests that match:  $::tcltest::skip"
}
if {[llength $::tcltest::match] > 0} {
    puts stdout "Only running tests that match:  $::tcltest::match"
}

if {[llength $::tcltest::skipFiles] > 0} {
    puts stdout "Skipping test files that match:  $::tcltest::skipFiles"
}
if {[llength $::tcltest::matchFiles] > 0} {
    puts stdout "Only sourcing test files that match:  $::tcltest::matchFiles"
}

set timeCmd {clock format [clock seconds]}
puts stdout "Tests began at [eval $timeCmd]"

set auto_path [linsert $auto_path 0 [file join $root modules]]

foreach module $modules {
    set ::tcltest::testsDirectory [file join $root modules $module]
    if { ![file isdirectory $::tcltest::testsDirectory] } {
	puts stdout "unknown module $module"
    }

    # foreach module, make a slave interp and source that module's tests into
    # the slave.  This isolates the test suites from one another.
    puts stdout "Module:\t[file tail $module]"
    set c [interp create]
    interp alias $c pSet {} set
    # import the auto_path from the parent interp, so "package require" works
    $c eval {
	set ::tcllibModule [pSet module]
	package require tcltest
	namespace import ::tcltest::*
	set ::tcltest::testSingleFile false
	set auto_path [pSet auto_path]
    }
    interp alias $c ::tcltest::cleanupTestsHook {} \
	    ::tcltest::cleanupTestsHook $c
    # source each of the specified tests
    foreach file [lsort [::tcltest::getMatchingFiles]] {
	set tail [file tail $file]
	puts stdout [string map [list "$root/" ""] $file]
	$c eval {
	    if {[catch {source [pSet file]} msg]} {
		puts stdout $msg
	    }
	}
    }
    interp delete $c
    puts stdout ""
}

# cleanup
puts stdout "\nTests ended at [eval $timeCmd]"
::tcltest::cleanupTests 1
return

