# profiler.tcl --
#
#	Tcl code profiler.
#
# Copyright (c) 1998-2000 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: profiler.tcl,v 1.3 2000/03/01 23:27:02 ericm Exp $

package provide profiler 0.1

namespace eval ::profiler {
    variable enabled 1
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
    variable firstRuntime
    variable otherRuntime

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

    # Set up accounting for this procedure
    set callCount($name) 0
    set firstRuntime($name) 0
    set otherRuntime($name) 0

    # Add some interesting stuff to the body of the proc
    set profBody "
	if { \$::profiler::enabled } {
	    upvar ::profiler::callCount callCount
	    upvar ::profiler::firstRuntime firstRuntime
	    upvar ::profiler::otherRuntime otherRuntime
	    upvar ::profiler::callers callers
	    incr callCount($name)
	    if { \[info level\] == 1 } {
		set caller GLOBAL
	    } else {
		# Get the name of the calling procedure
		set caller \[lindex \[info level -1\] 0\]
		# Remove the ORIG suffix
		set caller \[string range \$caller 0 end-4\]
	    }
	    if { \[info exists callers($name,\$caller)\] } {
		incr callers($name,\$caller)
	    } else {
		set callers($name,\$caller) 1
	    }
	    set ms \[clock clicks\]
	}
	set CODE \[uplevel ${name}ORIG \$args\]
	if { \$::profiler::enabled } {
	    set t \[expr {\[clock clicks\] - \$ms}\]
	    if { \$callCount($name) == 1 } {
		set firstRuntime($name) \$t
	    } else {
		incr otherRuntime($name) \$t
	    }
	}
	return \$CODE
    "
	uplevel 1 [list ::_oldProc ${name}ORIG $arglist $body]
	uplevel 1 [list ::_oldProc $name args $profBody]
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
#	pattern	pattern of the proc's to get info for.
#
# Results:
#	A human readable printout of info.

proc ::profiler::print {pattern} {
    variable callCount
    variable firstRuntime
    variable otherRuntime
    variable callers
    
    set result ""
    foreach name [lsort [array names callCount $pattern]] {
	append result "Profiling information for $name\n"
	append result "[string repeat = 80]\n"
	append result "total calls:\t$callCount($name)\n"
	append result "dist to callers:\n"
	foreach index [lsort [array names callers $name,*]] {
	    regsub "^$name," $index {} caller
	    append result "$caller:\t$callers($index)\n"
	}
	append result "first runtime:\t$firstRuntime($name)\n"
	append result "other runtime:\t$otherRuntime($name)\n"
	append result "\n"
    }
    return $result
}

# ::profiler::dump --
#
#	Dump out the information for a proc in a big blob.
#
# Arguments:
#	pattern	pattern of the proc's to lookup.
#
# Results:
#	data	data about the proc's.

proc ::profiler::dump {pattern} {
    variable callCount
    variable firstRuntime
    variable otherRuntime
    variable callers

    foreach name [lsort [array names callCount $pattern]] {
	foreach index [lsort [array names callers $name,*]] {
	    regsub "^$name," $index {} caller
	    set thisCallers($caller) $callers($index)
	}
	lappend result $name [list totalCalls $callCount($name) \
		callerDist [array get thisCallers] \
		firstRuntime $firstRuntime($name) \
		otherRuntime $otherRuntime($name)]
    }
    return $result
}

# ::profiler::sortFunctions --
#
#	Return a list of functions sorted by a particular field and the
#	value of that field.
#
# Arguments:
#	field	field to sort by. (totalCalls, firstRuntime or otherRuntime)
#
# Results:
#	slist	sorted list of lists, sorted by the field in question.

proc ::profiler::sortFunctions {field} {
    set var ::profiler::$field
    upvar $var data
    set result [list ]
    foreach fxn [array names data] {
	lappend result [list $fxn $data($fxn)]
    }
    return [lsort -integer -index 1 $result]
}

