# profiler.tcl --
#
#	Tcl code profiler.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: profiler.tcl,v 1.10 2000/06/02 18:43:56 ericm Exp $

package provide profiler 0.1

namespace eval ::profiler {
    variable enabled 1
}

# ::profiler::Handler --
#
#	Profile a function.  This function works together with profProc, which
#	replaces the proc command.  When a new procedure is defined, it creates
#	and alias to this function; when that procedure is called, it calls
#	this handler first, which gathers profiling information from the call.
#
# Arguments:
#	name	name of the function to profile.
#	args	arguments to pass to the original function.
#
# Results:
#	res	result from the original function.

proc ::profiler::Handler {name args} {
    variable enabled
    if { $enabled } {
	if { [info level] == 1 } {
	    set caller GLOBAL
	} else {
	    # Get the name of the calling procedure
	    set caller [lindex [info level -1] 0]
	    # Remove the ORIG suffix
	    set caller [string range $caller 0 end-4]
	}
	if { [catch {incr ::profiler::callers($name,$caller)}] } {
	    set ::profiler::callers($name,$caller) 1
	}
	set mark [clock clicks]
    }

    set CODE [uplevel ${name}ORIG $args]
    if { $enabled } {
	set t [expr {[clock clicks] - $mark}]

	# Check for [clock clicks] wrapping
	if { $t < 0 } {
	    set t [expr {$t * -1}]
	}

	if { [incr ::profiler::callCount($name)] == 1 } {
	    set ::profiler::compileTime($name) $t
	}
	incr ::profiler::totalRuntime($name) $t
	if { [catch {incr ::profiler::descendantTime($caller) $t}] } {
	    set ::profiler::descendantTime($caller) $t
	}
	if { [catch {incr ::profiler::descendants($caller,$name)}] } {
	    set ::profiler::descendants($caller,$name) 1
	}
    }
    return $CODE
}

# ::profiler::profProc --
#
#	Replacement for the proc command that adds rudimentary profiling
#	capabilities to Tcl.
#
# Arguments:
#	name		name of the procedure
#	arglist		list of arguments
#	body		body of the procedure
#
# Results:
#	None.

proc ::profiler::profProc {name arglist body} {
    variable callCount
    variable compileTime
    variable totalRuntime
    variable descendantTime
    
    # Get the fully qualified name of the proc
    set ns [uplevel [list namespace current]]
    # If the proc call did not happen at the global context and it did not
    # have an absolute namespace qualifier, we have to prepend the current
    # namespace to the command name
    if { ![string equal $ns "::"] } {
	if { ![regexp "^::" $name] } {
	    set name "${ns}::${name}"
	}
    }
    if { ![regexp "^::" $name] } {
	set name "::$name"
    }

    # Set up accounting for this procedure
    set callCount($name) 0
    set compileTime($name) 0
    set totalRuntime($name) 0
    set descendantTime($name) 0

    uplevel 1 [list ::_oldProc ${name}ORIG $arglist $body]
    uplevel 1 [list interp alias {} $name {} ::profiler::Handler $name]
    return
}

# ::profiler::init --
#
#	Initialize the profiler.
#
# Arguments:
#	None.
#
# Results:
#	None.  Renames proc to _oldProc and sets an alias for proc to 
#		profiler::profProc

proc ::profiler::init {} {
    rename ::proc ::_oldProc
    interp alias {} proc {} ::profiler::profProc

    return
}

# ::profiler::print --
#
#	Print information about a proc.
#
# Arguments:
#	pattern	pattern of the proc's to get info for; default is *.
#
# Results:
#	A human readable printout of info.

proc ::profiler::print {{pattern *}} {
    variable callCount
    variable compileTime
    variable totalRuntime
    variable descendantTime
    variable descendants
    variable callers
    
    set result ""
    foreach name [lsort [array names callCount $pattern]] {
	set avgRuntime 0
	set avgDesTime 0
	if { $callCount($name) > 0 } {
	    set avgRuntime \
		    [expr {$totalRuntime($name)/($callCount($name))}]
	    set avgDesTime \
		    [expr {$descendantTime($name)/($callCount($name))}]
	}

	append result "Profiling information for $name\n"
	append result "[string repeat = 80]\n"
	append result "Total calls:             \t$callCount($name)\n"
	append result "Caller distribution:\n"
	set i [expr {[string length $name] + 1}]
	foreach index [lsort [array names callers $name,*]] {
	    append result "\t[string range \
		    $index $i end]:\t\t$callers($index)\n"
	}
	append result "Compile time:            \t$compileTime($name)\n"
	append result "Total runtime:           \t$totalRuntime($name)\n"
	append result "Average runtime:         \t$avgRuntime\n"
	append result "Total descendant time:   \t$descendantTime($name)\n"
	append result "Average descendant time: \t$avgDesTime\n"
	append result "Descendants:\n"
	foreach index [lsort [array names descendants $name,*]] {
	    append result "\t[string range \
		    $index $i end]:\t\t$descendants($index)\n"
	}
	append result "\n"
    }
    return $result
}

# ::profiler::dump --
#
#	Dump out the information for a proc in a big blob.
#
# Arguments:
#	pattern	pattern of the proc's to lookup; default is *.
#
# Results:
#	data	data about the proc's.

proc ::profiler::dump {{pattern *}} {
    variable callCount
    variable compileTime
    variable totalRuntime
    variable callers
    variable descendantTime
    variable descendants

    foreach name [lsort [array names callCount $pattern]] {
	set i [expr {[string length $name] + 1}]
	catch {unset thisCallers}
	foreach index [lsort [array names callers $name,*]] {
	    set thisCallers([string range $index $i end]) $callers($index)
	}
	set avgRuntime 0
	set avgDesTime 0
	if { $callCount($name) > 0 } {
	    set avgRuntime \
		    [expr {$totalRuntime($name)/$callCount($name)}]
	    set avgDesTime \
		    [expr {$descendantTime($name)/$callCount($name)}]
	}
	set descendantList [list ]
	foreach index [lsort [array names descendants $name,*]] {
	    lappend descendantList [string range $index $i end]
	}
	lappend result $name [list callCount $callCount($name) \
		callerDist [array get thisCallers] \
		compileTime $compileTime($name) \
		totalRuntime $totalRuntime($name) \
		averageRuntime $avgRuntime \
		descendantTime $descendantTime($name) \
		averageDescendantTime $avgDesTime \
		descendants $descendantList]
    }
    return $result
}

# ::profiler::sortFunctions --
#
#	Return a list of functions sorted by a particular field and the
#	value of that field.
#
# Arguments:
#	field	field to sort by
#
# Results:
#	slist	sorted list of lists, sorted by the field in question.

proc ::profiler::sortFunctions {{field ""}} {
    switch -glob -- $field {
	"calls" {
	    upvar ::profiler::callCount data
	}
	"compileTime" {
	    upvar ::profiler::compileTime data
	}
	"totalRuntime" {
	    upvar ::profiler::totalRuntime data
	}
	"avgRuntime" -
	"averageRuntime" {
	    variable callCount
	    variable totalRuntime
	    foreach fxn [array names callCount] {
		if { $callCount($fxn) > 1 } {
		    set data($fxn) \
			    [expr {$totalRuntime($fxn)/($callCount($fxn) - 1)}]
		}
	    }
	}
	"exclusiveRuntime" {
	    variable totalRuntime
	    variable descendantTime
	    foreach fxn [array names totalRuntime] {
		set data($fxn) \
			[expr {$totalRuntime($fxn) - $descendantTime($fxn)}]
	    }
	}
	"avgExclusiveRuntime" {
	    variable totalRuntime
	    variable callCount
	    variable descendantTime
	    foreach fxn [array names totalRuntime] {
		if { $callCount($fxn) } {
		    set data($fxn) \
			    [expr {($totalRuntime($fxn) - \
				$descendantTime($fxn)) / $callCount($fxn)}]
		}
	    }
	}
	"nonCompileTime" {
	    variable compileTime
	    variable totalRuntime
	    foreach fxn [array names totalRuntime] {
		set data($fxn) [expr {$totalRuntime($fxn)-$compileTime($fxn)}]
	    }
	}
	default {
	    error "unknown statistic \"$field\": should be calls,\
		    compileTime, exclusiveRuntime, nonCompileTime,\
		    totalRuntime, avgExclusiveRuntime, or avgRuntime"
	}
    }
	    
    set result [list ]
    foreach fxn [array names data] {
	lappend result [list $fxn $data($fxn)]
    }
    return [lsort -integer -index 1 $result]
}

# ::profiler::reset --
#
#	Reset collected data for functions matching a given pattern.
#
# Arguments:
#	pattern		pattern of functions to reset; default is *.
#
# Results:
#	None.

proc ::profiler::reset {{pattern *}} {
    variable callCount
    variable compileTime
    variable totalRuntime
    variable callers

    foreach name [array names callCount $pattern] {
	set callCount($name) 0
	set compileTime($name) 0
	set totalRuntime($name) 0
	foreach caller [array names callers $name,*] {
	    unset callers($caller)
	}
    }
    return
}

