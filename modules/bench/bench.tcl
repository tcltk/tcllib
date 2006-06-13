# bench.tcl --
#
#	Management of benchmarks.
#
# Copyright (c) 2005 by Andreas Kupries <andreas_kupries@users.sourceforge.net>
# library derived from runbench.tcl application (C) Jeff Hobbs.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: bench.tcl,v 1.6 2006/06/13 23:20:30 andreas_kupries Exp $

# ### ### ### ######### ######### ######### ###########################
## Requisites - Packages and namespace for the commands and data.

package require Tcl 8.2
package require logger
package require csv
package require struct::matrix
package require report

namespace eval ::bench      {}
namespace eval ::bench::out {}

# @mdgen OWNER: libbench.tcl

# ### ### ### ######### ######### ######### ###########################
## Public API - Benchmark execution

# ::bench::run --
#
#	Run a series of benchmarks.
#
# Arguments:
#	...
#
# Results:
#	Dictionary.

proc ::bench::run {args} {
    variable self

    log::debug [linsert $args 0 ::bench::run]

    # -errors  0|1         default 1, propagate errors in benchmarks
    # -threads <num>       default 0, no threads, #threads to use
    # -match  <pattern>    only run tests matching this pattern
    # -rmatch <pattern>    only run tests matching this pattern
    # -iters  <num>        default 1000, max#iterations for any benchmark

    # interps - dict (path -> version)
    # files   - list (of files)

    # Process arguments ......................................
    # Defaults first, then overides by the user

    set errors  1    ; # Propagate errors
    set threads 0    ; # Do not use threads
    set match   {}   ; # Do not exclude benchmarks based on glob pattern
    set rmatch  {}   ; # Do not exclude benchmarks based on regex pattern
    set iters   1000 ; # Limit #iterations for any benchmark

    while {[string match "-*" [set opt [lindex $args 0]]]} {
	set val [lindex $args 1]
	switch -exact -- $opt {
	    -errors {
		if {![string is boolean -strict $val]} {
		    return -code error "Expected boolean, got \"$val\""
		}
		set errors $val
	    }
	    -threads {
		if {![string is int -strict $val] || ($val < 0)} {
		    return -code error "Expected int >= 0, got \"$val\""
		}
		set threads [lindex $args 1]
	    }
	    -match {
		set match [lindex $args 1]
	    }
	    -rmatch {
		set rmatch [lindex $args 1]
	    }
	    -iters {
		if {![string is int -strict $val] || ($val <= 0)} {
		    return -code error "Expected int > 0, got \"$val\""
		}
		set iters   [lindex $args 1]
	    }
	    default {
		return -code error "Unknown option \"$opt\", should -errors, -threads, -match, -rmatch, or -iters"
	    }
	}
	set args [lrange $args 2 end]
    }
    if {[llength $args] != 2} {
	return -code error "wrong\#args, should be: ?options? interp files"
    }
    foreach {interps files} $args break

    # Run the benchmarks .....................................

    array set DATA {}

    foreach {ip ver} $interps {
	log::info "Benchmark $ver $ip"

	set DATA([list interp ${ip}]) $ver

	set cmd [list $ip [file join $self libbench.tcl] \
		-match   $match   \
		-rmatch  $rmatch  \
		-iters   $iters   \
		-interp  $ip      \
		-errors  $errors  \
		-threads $threads \
		]

	# Determine elapsed time per file, logged.
	set start [clock seconds]

	array set tmp {}

	if {$threads} {
	    if {[catch {
		eval exec $cmd $files
	    } output]} {
		if {$errors} {
		    error $::errorInfo
		}
	    } else {
		array set tmp $output
	    }
	} else {
	    foreach file $files {
		log::info [file tail $file]
		if {[catch {
		    eval exec [linsert $cmd end $file]
		} output]} {
		    if {$errors} {
			error $::errorInfo
		    } else {
			continue
		    }
		} else {
		    array set tmp $output
		}
	    }
	}

	catch {unset tmp(Sourcing)}
	catch {unset tmp(__THREADED)}

	foreach desc [array names tmp] {
	    set DATA([list desc $desc]) {}
	    set DATA([list usec $desc $ip]) $tmp($desc)
	}

	unset tmp
	set elapsed [expr {[clock seconds] - $start}]

	set hour [expr {$elapsed / 3600}]
	set min  [expr {$elapsed / 60}]
	set sec  [expr {$elapsed % 60}]
	log::info " [format %.2d:%.2d:%.2d $hour $min $sec] elapsed"
    }

    # Benchmark data ... Structure, dict (key -> value)
    #
    # Key          || Value
    # ============ ++ =========================================
    # interp IP    -> Version. Shell IP was used to run benchmarks. IP is
    #                 the path to the shell.
    #
    # desc DESC    -> "". DESC is description of an executed benchmark.
    #
    # usec DESC IP -> Result. Result of benchmark DESC when run by the
    #                 shell IP. Usually time in microseconds, but can be
    #                 a special code as well (ERR, BAD_RES).
    # ============ ++ =========================================

    return [array get DATA]
}

# ::bench::locate --
#
#	Locate interpreters on the pathlist, based on a pattern.
#
# Arguments:
#	...
#
# Results:
#	List of paths.

proc ::bench::locate {pattern paths} {
    # Cache of executables already found.
    array set var {}
    set res {}

    foreach path $paths {
	foreach ip [glob -nocomplain [file join $path $pattern]] {
	    if {$::tcl_version > 8.4} {
		set ip [file normalize $ip]
	    }

	    # Follow soft-links to the actual executable.
	    while {[string equal link [file type $ip]]} {
		set link [file readlink $ip]
		if {[string match relative [file pathtype $link]]} {
		    set ip [file join [file dirname $ip] $link]
		} else {
		    set ip $link
		}
	    }

	    if {
		[file executable $ip] && ![info exists var($ip)]
	    } {
		if {[catch {exec $ip << "exit"} dummy]} {
		    log::debug "$ip: $dummy"
		    continue
		}
		set var($ip) .
		lappend res $ip
	    }
	}
    }

    return $res
}

# ::bench::versions --
#
#	Take list of interpreters, find their versions.
#	Removes all interps for which it cannot do so.
#
# Arguments:
#	List of interpreters (paths)
#
# Results:
#	dictonary interpreter -> version.

proc ::bench::versions {interps} {
    set res {}
    foreach ip $interps {
	if {[catch {
	    exec $ip << {puts [info patchlevel] ; exit}
	} patchlevel]} {
	    log::debug "$ip: $patchlevel"
	    continue
	}

	lappend res [list $patchlevel $ip]
    }

    set tmp [lsort -uniq -dictionary -decreasing -index 0 $res]
    set res {}
    foreach item $tmp {
	foreach {p ip} $item break
	lappend res $ip $p
    }

    return $res
}

# ::bench::merge --
#
#	Take the data of several benchmark runs and merge them into
#	one data set.
#
# Arguments:
#	One or more data sets to merge
#
# Results:
#	The merged data set.

proc ::bench::merge {args} {
    if {[llength $args] == 1} {
	return [lindex $args 0]
    }

    array set DATA {}
    foreach data $args {
	array set DATA $data
    }
    return [array get DATA]
}

# ::bench::norm --
#
#	Normalize the time data in the dataset, using one of the
#	columns as reference.
#
# Arguments:
#	Data to normalize
#	Index of reference column
#
# Results:
#	The normalized data set.

proc ::bench::norm {data col} {

    if {![string is integer -strict $col]} {
	return -code error "Ref.column: Expected integer, but got \"$col\""
    }
    if {$col < 1} {
	return -code error "Ref.column out of bounds"
    }

    array set DATA $data
    set ipkeys [array names DATA interp*]

    if {$col > [llength $ipkeys]} {
	return -code error "Ref.column out of bounds"
    }
    incr col -1
    set refip [lindex [lindex [lsort -dict $ipkeys] $col] 1]

    foreach key [array names DATA] {
	if {[string match "desc*"   $key]} continue
	if {[string match "interp*" $key]} continue

	foreach {desc ip} [split $key ,] break
	if {[string equal $ip $refip]}                       continue

	set v $DATA($key)
	if {![string is double -strict $v]}                  continue

	if {![info exists DATA([list usec $desc $refip])]} {
	    # We cannot normalize, we do not keep the time value.
	    # The row will be shown, empty.
	    set DATA($key) ""
	    continue
	}
	set vref $DATA([list usec $desc $refip])

	if {![string is double -strict $vref]} continue

	set DATA($key) [expr {$v/double($vref)}]
    }

    foreach key [array names DATA *$refip] {
	if {![string is double -strict $DATA($key)]} continue
	set DATA($key) 1
    }

    return [array get DATA]
}

# ::bench::edit --
#
#	Change the 'path' of an interp to a user-defined value.
#
# Arguments:
#	Data to edit
#	Index of column to change
#	The value replacing the current path
#
# Results:
#	The changed data set.

proc ::bench::edit {data col new} {

    if {![string is integer -strict $col]} {
	return -code error "Ref.column: Expected integer, but got \"$col\""
    }
    if {$col < 1} {
	return -code error "Ref.column out of bounds"
    }

    array set DATA $data
    set ipkeys [array names DATA interp*]

    if {$col > [llength $ipkeys]} {
	return -code error "Ref.column out of bounds"
    }
    incr col -1
    set refip [lindex [lindex [lsort -dict $ipkeys] $col] 1]

    if {[string equal $new $refip]} {
	# No change, quick return
	return $data
    }

    set refkey [list interp $refip]
    set DATA([list interp $new]) $DATA($refkey)
    unset                         DATA($refkey)

    foreach key [array names DATA *$refip] {
	if {[lindex $key 0] ne "usec"} continue
	foreach {__ desc ip} $key break
	set DATA([list usec $desc $new]) $DATA($key)
	unset                             DATA($key)
    }

    return [array get DATA]
}

# ::bench::del --
#
#	Remove the data for an interp.
#
# Arguments:
#	Data to edit
#	Index of column to remove
#
# Results:
#	The changed data set.

proc ::bench::del {data col} {

    if {![string is integer -strict $col]} {
	return -code error "Ref.column: Expected integer, but got \"$col\""
    }
    if {$col < 1} {
	return -code error "Ref.column out of bounds"
    }

    array set DATA $data
    set ipkeys [array names DATA interp*]

    if {$col > [llength $ipkeys]} {
	return -code error "Ref.column out of bounds"
    }
    incr col -1
    set refip [lindex [lindex [lsort -dict $ipkeys] $col] 1]

    unset DATA([list interp $refip])

    # Do not use 'array unset'. Keep 8.2 clean.
    foreach key [array names DATA *$refip] {
	if {[lindex $key 0] ne "usec"} continue
	unset DATA($key)
    }

    return [array get DATA]
}

# ### ### ### ######### ######### ######### ###########################
## Public API - Result formatting.

# ::bench::out::raw --
#
#	Format the result of a benchmark run.
#	Style: Raw data.
#
# Arguments:
#	DATA dict
#
# Results:
#	String containing the formatted DATA.

proc ::bench::out::raw {data} {
    return $data
}

# ### ### ### ######### ######### ######### ###########################
## Internal commands

# ### ### ### ######### ######### ######### ###########################
## Initialize internal data structures.

namespace eval ::bench {
    variable self [file join [pwd] [file dirname [info script]]]

    logger::init bench
    logger::import -force -all -namespace log bench
}

# ### ### ### ######### ######### ######### ###########################
## Ready to run

package provide bench 0.1
