# all.tcl --
#
# This file contains a top-level script to run all of the Tcl
# tests.  Execute it by invoking "source all.test" when running tcltest
# in this directory.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
# All rights reserved.
# 
# RCS: @(#) $Id: all.tcl,v 1.7 2002/02/15 05:35:29 andreas_kupries Exp $

set old_auto_path $auto_path

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
set ::tcltest::testsDirectory [file dirname [info script]]
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


set auto_path $old_auto_path
set auto_path [linsert $auto_path 0 [file join $root modules]]
set old_apath $auto_path

foreach module $modules {
    set ::tcltest::testsDirectory [file join $root modules $module]

    if { ![file isdirectory $::tcltest::testsDirectory] } {
	puts stdout "unknown module $module"
    }

    set auto_path $old_apath
    set auto_path [linsert $auto_path 0 $::tcltest::testsDirectory]

    # foreach module, make a slave interp and source that module's tests into
    # the slave.  This isolates the test suites from one another.
    puts stdout "Module:\t[file tail $module]"
    set c [interp create]
    interp alias $c pSet {} set
    # import the auto_path from the parent interp, so "package require" works
    $c eval {
	set ::tcllibModule [pSet module]
	set auto_path [pSet auto_path]
	package require tcltest
	namespace import ::tcltest::*
	set ::tcltest::testSingleFile false
	set ::tcltest::testsDirectory [pSet ::tcltest::testsDirectory]
	#set ::tcltest::verbose ps

	# Add a function to construct a proper error message for
	# 'wrong#args' situations. The format of the messages changed
	# for 8.4

	proc ::tcltest::getErrorMessage {functionName argList missingIndex} {
	    # if oldstyle errors:
	    if { [info tclversion] < 8.4 } {
		set msg "no value given for parameter "
		append msg "\"[lindex $argList $missingIndex]\" to "
		append msg "\"$functionName\""
	    } else {
		set msg "wrong # args: should be \"$functionName $argList\""
	    }
	    return $msg
	}
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
# FRINK: nocheck
return

