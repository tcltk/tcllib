# csv.tcl --
#
#	Tcl implementations of CSV reader and writer
#
# Copyright (c) 2001 by Jeffrey Hobbs
# Copyright (c) 2001 by Andreas Kupries <a.kupries@westend.com>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: csv.tcl,v 1.9 2002/02/01 22:59:08 andreas_kupries Exp $

package require Tcl 8.3
package provide csv 0.3

namespace eval ::csv {
    namespace export join joinlist read2matrix read2queuen report 
    namespace export split split2matrix split2queue writematrix writequeue
}

# ::csv::join --
#
#	Takes a list of values and generates a string in CSV format.
#
# Arguments:
#	values		A list of the values to join
#	sepChar		The separator character, defaults to comma
#
# Results:
#	A string containing the values in CSV format.

proc ::csv::join {values {sepChar ,}} {
    set out ""
    set sep {}
    foreach val $values {
	if {[string match "*\[\"$sepChar\]*" $val]} {
	    append out $sep\"[string map [list \" \"\"] $val]\"
	} else {
	    append out $sep$val
	}
	set sep $sepChar
    }
    return $out
}

# ::csv::joinlist --
#
#	Takes a list of lists of values and generates a string in CSV
#	format. Each item in the list is made into a single CSV
#	formatted record in the final string, the records being
#	separated by newlines.
#
# Arguments:
#	values		A list of the lists of the values to join
#	sepChar		The separator character, defaults to comma
#
# Results:
#	A string containing the values in CSV format, the records
#	separated by newlines.

proc ::csv::joinlist {values {sepChar ,}} {
    set out ""
    foreach record $values {
	# note that this is ::csv::join
	append out "[join $record $sepChar]\n"
    }
    return $out
}

# ::csv::read2matrix --
#
#	A wrapper around "::csv::split2matrix" reading CSV formatted
#	lines from the specified channel and adding it to the given
#	matrix.
#
# Arguments:
#	m		The matrix to add the read data too.
#	chan		The channel to read from.
#	sepChar		The separator character, defaults to comma
#	expand		The expansion mode. The default is none
#
# Results:
#	A list of the values in 'line'.

proc ::csv::read2matrix {chan m {sepChar ,} {expand none}} {
    # FR #481023
    # See 'split2matrix' for the available expansion modes.

    while {![eof $chan]} {
	if {[gets $chan line] < 0} {continue}
	if {$line == {}} {continue}
	split2matrix $m $line $sepChar $expand
    }
    return
}

# ::csv::read2queue --
#
#	A wrapper around "::csv::split2queue" reading CSV formatted
#	lines from the specified channel and adding it to the given
#	queue.
#
# Arguments:
#	q		The queue to add the read data too.
#	chan		The channel to read from.
#	sepChar		The separator character, defaults to comma
#
# Results:
#	A list of the values in 'line'.

proc ::csv::read2queue {chan q {sepChar ,}} {
    while {![eof $chan]} {
	if {[gets $chan line] < 0} {continue}
	if {$line == {}} {continue}
	split2queue $q $line $sepChar
    }
    return
}

# ::csv::report --
#
#	A report command which can be used by the matrix methods
#	"format-via" and "format2chan-via". For the latter this
#	command delegates the work to "::csv::writematrix". "cmd" is
#	expected to be either "printmatrix" or
#	"printmatrix2channel". The channel argument, "chan", has to
#	be present for the latter and must not be present for the first.
#
# Arguments:
#	cmd		Either 'printmatrix' or 'printmatrix2channel'
#	matrix		The matrix to format.
#	args		0 (chan): The channel to write to
#
# Results:
#	None for 'printmatrix2channel', else the CSV formatted string.

proc ::csv::report {cmd matrix args} {
    switch -exact -- $cmd {
	printmatrix {
	    if {[llength $args] > 0} {
		return -code error "wrong # args:\
			::csv::report printmatrix matrix"
	    }
	    return [joinlist [$matrix get rect 0 0 end end]]
	}
	printmatrix2channel {
	    if {[llength $args] != 1} {
		return -code error "wrong # args:\
			::csv::report printmatrix2channel matrix chan"
	    }
	    writematrix $matrix [lindex $args 0]
	    return ""
	}
	default {
	    return -code error "Unknown method $cmd"
	}
    }
}

# ::csv::split --
#
#	Split a string according to the rules for CSV processing.
#	This assumes that the string contains a single line of CSVs
#
# Arguments:
#	line		The string to split
#	sepChar		The separator character, defaults to comma
#
# Results:
#	A list of the values in 'line'.

proc ::csv::split {line {sepChar ,}} {
    regsub -all -- {(^\"|\"$)} $line \0 line
    set line [string map [list \
	    $sepChar\"\"\" $sepChar\0\" \
	    \"\"\"$sepChar \"\0$sepChar \
	    \"\"           \" \
	    \"             \0 \
	    ] $line]
    set end 0
    while {[regexp -indices -start $end -- {(\0)[^\0]*(\0)} $line \
	    -> start end]} {
	set start [lindex $start 0]
	set end   [lindex $end 0]
	set range [string range $line $start $end]
	if {[string first $sepChar $range] >= 0} {
	    set line [string replace $line $start $end \
		    [string map [list $sepChar \1] $range]]
	}
	incr end
    }
    set line [string map [list $sepChar \0 \1 $sepChar \0 {} ] $line]
    return [::split $line \0]
}

# ::csv::split2matrix --
#
#	Split a string according to the rules for CSV processing.
#	This assumes that the string contains a single line of CSVs.
#	The resulting list of values is appended to the specified
#	matrix, as a new row. The code assumes that the matrix provides
#	the same interface as the queue provided by the 'struct'
#	module of tcllib, "add row" in particular.
#
# Arguments:
#	m		The matrix to write the resulting list to.
#	line		The string to split
#	sepChar		The separator character, defaults to comma
#	expand		The expansion mode. The default is none
#
# Results:
#	A list of the values in 'line', written to 'q'.

proc ::csv::split2matrix {m line {sepChar ,} {expand none}} {
    # FR #481023

    set csv [split $line $sepChar]

    # Expansion modes
    # - none  : default, behaviour of original implementation.
    #           no expansion is done, lines are silently truncated
    #           to the number of columns in the matrix.
    #
    # - empty : A matrix without columns is expanded to the number
    #           of columns in the first line added to it. All
    #           following lines are handled as if "mode == none"
    #           was set.
    #
    # - auto  : Full auto-mode. The matrix is expanded as needed to
    #           hold all columns of all lines.

    switch -exact -- $expand {
	none {}
	empty {
	    if {[$m columns] == 0} {
		$m add columns [llength $csv]
	    }
	}
	auto {
	    if {[$m columns] < [llength $csv]} {
		$m add columns [expr {[llength $csv] - [$m columns]}]
	    }
	}
    }
    $m add row $csv
    return
}

# ::csv::split2queue --
#
#	Split a string according to the rules for CSV processing.
#	This assumes that the string contains a single line of CSVs.
#	The resulting list of values is appended to the specified
#	queue, as a single item. IOW each item in the queue represents
#	a single CSV record. The code assumes that the queue provides
#	the same interface as the queue provided by the 'struct'
#	module of tcllib, "put" in particular.
#
# Arguments:
#	q		The queue to write the resulting list to.
#	line		The string to split
#	sepChar		The separator character, defaults to comma
#
# Results:
#	A list of the values in 'line', written to 'q'.

proc ::csv::split2queue {q line {sepChar ,}} {
    $q put [split $line $sepChar]
    return
}

# ::csv::writematrix --
#
#	A wrapper around "::csv::join" taking the rows in a matrix and
#	writing them as CSV formatted lines into the channel.
#
# Arguments:
#	m		The matrix to take the data to write from.
#	chan		The channel to write into.
#	sepChar		The separator character, defaults to comma
#
# Results:
#	None.

proc ::csv::writematrix {m chan {sepChar ,}} {
    set n [$m rows]
    for {set r 0} {$r < $n} {incr r} {
	puts $chan [join [$m get row $r] $sepChar]
    }

    # Memory intensive alternative:
    # puts $chan [joinlist [m get rect 0 0 end end] $sepChar]
    return
}

# ::csv::writequeue --
#
#	A wrapper around "::csv::join" taking the rows in a queue and
#	writing them as CSV formatted lines into the channel.
#
# Arguments:
#	q		The queue to take the data to write from.
#	chan		The channel to write into.
#	sepChar		The separator character, defaults to comma
#
# Results:
#	None.

proc ::csv::writequeue {q chan {sepChar ,}} {
    while {[$q size] > 0} {
	puts $chan [join [$q get] $sepChar]
    }

    # Memory intensive alternative:
    # puts $chan [joinlist [$q get [$q size]] $sepChar]
    return
}

