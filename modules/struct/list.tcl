#----------------------------------------------------------------------
#
# list.tcl --
#
#	Definitions for extended processing of Tcl lists.
#
# Copyright (c) 2003 by Kevin B. Kenny.  All rights reserved.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: list.tcl,v 1.5 2003/04/09 18:25:31 andreas_kupries Exp $
#
#----------------------------------------------------------------------

package require Tcl 8.0

namespace eval ::struct { namespace eval list {} }

namespace eval ::struct::list {
    namespace export list

    if 0 {
	# Possibly in the future.
	namespace export LongestCommonSubsequence
	namespace export LongestCommonSubsequence2
	namespace export LcsInvert
	namespace export LcsInvert2
	namespace export LcsInvertMerge
	namespace export LcsInvertMerge2
	namespace export Reverse
	namespace export Assign
	namespace export Flatten
	namespace export Map
	namespace export Fold
	namespace export Iota
	namespace export Equal
	namespace export Repeat
    }
}

##########################
# Public functions

# ::struct::list::list --
#
#	Command that access all list commands.
#
# Arguments:
#	cmd	Name of the subcommand to dispatch to.
#	args	Arguments for the subcommand.
#
# Results:
#	Whatever the result of the subcommand is.

proc ::struct::list::list {cmd args} {
    # Do minimal args checks here
    if { [llength [info level 0]] == 1 } {
	return -code error "wrong # args: should be \"$cmd ?arg arg ...?\""
    }
    set sub [string toupper [string index $cmd 0]][string range $cmd 1 end]

    if { [llength [info commands ::struct::list::$sub]] == 0 } {
	set optlist [info commands ::struct::list::L*]
	set xlist {}
	foreach p $optlist {
	    lappend xlist [string tolower [string index $p 0]][string range $p 1 end]
	}
	return -code error \
		"bad option \"$cmd\": must be [linsert [join $xlist ", "] "end-1" "or"]"
    }
    return [eval [linsert $args 0 ::struct::list::$sub]]
}

##########################
# Private functions follow
#
# Do a compatibility version of [lset] for pre-8.4 versions of Tcl.
# This version does not do multi-arg [lset]!

if { [package vcompare [package provide Tcl] 8.4] < 0 } {
    proc ::struct::list::K { x y } { set x }
    proc ::struct::list::lset { var index arg } {
	upvar 1 $var list
	set list [::lreplace [K $list [set list {}]] $index $index $arg]
    }
}

##########################
# Implementations of the functionality.
#

# ::struct::list::LongestCommonSubsequence --
#
#       Computes the longest common subsequence of two lists.
#
# Parameters:
#       sequence1, sequence2 -- Two lists to compare.
#	maxOccurs -- If provided, causes the procedure to ignore
#		     lines that appear more than $maxOccurs times
#		     in the second sequence.  See below for a discussion.
# Results:
#       Returns a list of two lists of equal length.
#       The first sublist is of indices into sequence1, and the
#       second sublist is of indices into sequence2.  Each corresponding
#       pair of indices corresponds to equal elements in the sequences;
#       the sequence returned is the longest possible.
#
# Side effects:
#       None.
#
# Notes:
#
#	While this procedure is quite rapid for many tasks of file
# comparison, its performance degrades severely if the second list
# contains many equal elements (as, for instance, when using this
# procedure to compare two files, a quarter of whose lines are blank.
# This drawback is intrinsic to the algorithm used (see the References
# for details).  One approach to dealing with this problem that is
# sometimes effective in practice is arbitrarily to exclude elements
# that appear more than a certain number of times.  This number is
# provided as the 'maxOccurs' parameter.  If frequent lines are
# excluded in this manner, they will not appear in the common subsequence
# that is computed; the result will be the longest common subsequence
# of infrequent elements.
#
#	The procedure struct::list::LongestCommonSubsequence2
# functions as a wrapper around this procedure; it computes the longest
# common subsequence of infrequent elements, and then subdivides the
# subsequences that lie between the matches to approximate the true
# longest common subsequence.
#
# References:
#	J. W. Hunt and M. D. McIlroy, "An algorithm for differential
#	file comparison," Comp. Sci. Tech. Rep. #41, Bell Telephone
#	Laboratories (1976). Available on the Web at the second
#	author's personal site: http://www.cs.dartmouth.edu/~doug/

proc ::struct::list::LongestCommonSubsequence {
    sequence1
    sequence2
    {maxOccurs 0x7fffffff}
} {
    # Construct a set of equivalence classes of lines in file 2

    set index 0
    foreach string $sequence2 {
	lappend eqv($string) $index
	incr index
    }

    # K holds descriptions of the common subsequences.
    # Initially, there is one common subsequence of length 0,
    # with a fence saying that it includes line -1 of both files.
    # The maximum subsequence length is 0; position 0 of
    # K holds a fence carrying the line following the end
    # of both files.

    lappend K [::list -1 -1 {}]
    lappend K [::list [llength $sequence1] [llength $sequence2] {}]
    set k 0

    # Walk through the first file, letting i be the index of the line and
    # string be the line itself.

    set i 0
    foreach string $sequence1 {
	# Consider each possible corresponding index j in the second file.

	if { [info exists eqv($string)]
	     && [llength $eqv($string)] <= $maxOccurs } {

	    # c is the candidate match most recently found, and r is the
	    # length of the corresponding subsequence.

	    set r 0
	    set c [lindex $K 0]

	    foreach j $eqv($string) {
		# Perform a binary search to find a candidate common
		# subsequence to which may be appended this match.

		set max $k
		set min $r
		set s [expr { $k + 1 }]
		while { $max >= $min } {
		    set mid [expr { ( $max + $min ) / 2 }]
		    set bmid [lindex [lindex $K $mid] 1]
		    if { $j == $bmid } {
			break
		    } elseif { $j < $bmid } {
			set max [expr {$mid - 1}]
		    } else {
			set s $mid
			set min [expr { $mid + 1 }]
		    }
		}

		# Go to the next match point if there is no suitable
		# candidate.

		if { $j == [lindex [lindex $K $mid] 1] || $s > $k} {
		    continue
		}

		# s is the sequence length of the longest sequence
		# to which this match point may be appended. Make
		# a new candidate match and store the old one in K
		# Set r to the length of the new candidate match.

		set newc [::list $i $j [lindex $K $s]]
		if { $r >= 0 } {
		    lset K $r $c
		}
		set c $newc
		set r [expr { $s + 1 }]

		# If we've extended the length of the longest match,
		# we're done; move the fence.

		if { $s >= $k } {
		    lappend K [lindex $K end]
		    incr k
		    break
		}
	    }

	    # Put the last candidate into the array

	    lset K $r $c
	}

	incr i
    }

    # Package the common subsequence in a convenient form

    set seta {}
    set setb {}
    set q [lindex $K $k]

    for { set i 0 } { $i < $k } {incr i } {
	lappend seta {}
	lappend setb {}
    }
    while { [lindex $q 0] >= 0 } {
	incr k -1
	lset seta $k [lindex $q 0]
	lset setb $k [lindex $q 1]
	set q [lindex $q 2]
    }

    return [::list $seta $setb]
}

# ::struct::list::LongestCommonSubsequence2 --
#
#	Derives an approximation to the longest common subsequence
#	of two lists.
#
# Parameters:
#	sequence1, sequence2 - Lists to be compared
#	maxOccurs - Parameter for imprecise matching - see below.
#
# Results:
#       Returns a list of two lists of equal length.
#       The first sublist is of indices into sequence1, and the
#       second sublist is of indices into sequence2.  Each corresponding
#       pair of indices corresponds to equal elements in the sequences;
#       the sequence returned is an approximation to the longest possible.
#
# Side effects:
#       None.
#
# Notes:
#	This procedure acts as a wrapper around the companion procedure
#	struct::list::LongestCommonSubsequence and accepts the same
#	parameters.  It first computes the longest common subsequence of
#	elements that occur no more than $maxOccurs times in the
#	second list.  Using that subsequence to align the two lists,
#	it then tries to augment the subsequence by computing the true
#	longest common subsequences of the sublists between matched pairs.

proc ::struct::list::LongestCommonSubsequence2 {
    sequence1
    sequence2
    {maxOccurs 0x7fffffff}
} {
    # Derive the longest common subsequence of elements that occur at
    # most $maxOccurs times

    foreach { l1 l2 } \
	[LongestCommonSubsequence $sequence1 $sequence2 $maxOccurs] {
	    break
	}

    # Walk through the match points in the sequence just derived.

    set result1 {}
    set result2 {}
    set n1 0
    set n2 0
    foreach i1 $l1 i2 $l2 {
	if { $i1 != $n1 && $i2 != $n2 } {
	    # The match points indicate that there are unmatched
	    # elements lying between them in both input sequences.
	    # Extract the unmatched elements and perform precise
	    # longest-common-subsequence analysis on them.

	    set subl1 [lrange $sequence1 $n1 [expr { $i1 - 1 }]]
	    set subl2 [lrange $sequence2 $n2 [expr { $i2 - 1 }]]
	    foreach { m1 m2 } [LongestCommonSubsequence $subl1 $subl2] break
	    foreach j1 $m1 j2 $m2 {
		lappend result1 [expr { $j1 + $n1 }]
		lappend result2 [expr { $j2 + $n2 }]
	    }
	}

	# Add the current match point to the result

	lappend result1 $i1
	lappend result2 $i2
	set n1 [expr { $i1 + 1 }]
	set n2 [expr { $i2 + 1 }]
    }

    # If there are unmatched elements after the last match in both files,
    # perform precise longest-common-subsequence matching on them and
    # add the result to our return.

    if { $n1 < [llength $sequence1] && $n2 < [llength $sequence2] } {
	set subl1 [lrange $sequence1 $n1 end]
	set subl2 [lrange $sequence2 $n2 end]
	foreach { m1 m2 } [LongestCommonSubsequence $subl1 $subl2] break
	foreach j1 $m1 j2 $m2 {
	    lappend result1 [expr { $j1 + $n1 }]
	    lappend result2 [expr { $j2 + $n2 }]
	}
    }

    return [::list $result1 $result2]
}

# ::struct::list::LcsInvert --
#
#	Takes the data describing a longest common subsequence of two
#	lists and inverts the information in the sense that the result
#	of this command will describe the differences between the two
#	sequences instead of the identical parts.
#
# Parameters:
#	lcsData		longest common subsequence of two lists as
#			returned by longestCommonSubsequence(2).
# Results:
#	Returns a single list whose elements describe the differences
#	between the original two sequences. Each element describes
#	one difference through three pieces, the type of the change,
#	a pair of indices in the first sequence and a pair of indices
#	into the second sequence, in this order.
#
# Side effects:
#       None.

proc ::struct::list::LcsInvert {lcsData len1 len2} {
    return [LcsInvert2 [::lindex $lcsData 0] [::lindex $lcsData 1] $len1 $len2]
}

proc ::struct::list::LcsInvert2 {idx1 idx2 len1 len2} {
    set result {}
    set last1 -1
    set last2 -1

    foreach a $idx1 b $idx2 {
	# Four possible cases.
	# a) last1 ... a and last2 ... b are not empty.
	#    This is a 'change'.
	# b) last1 ... a is empty, last2 ... b is not.
	#    This is an 'addition'.
	# c) last1 ... a is not empty, last2 ... b is empty.
	#    This is a deletion.
	# d) If both ranges are empty we can ignore the
	#    two current indices.

	set empty1 [expr {($a - $last1) <= 1}]
	set empty2 [expr {($b - $last2) <= 1}]

	if {$empty1 && $empty2} {
	    # Case (d), ignore the indices
	} elseif {$empty1} {
	    # Case (b), 'addition'.
	    incr last2 ; incr b -1
	    lappend result [::list added [::list $last1 $a] [::list $last2 $b]]
	    incr b
	} elseif {$empty2} {
	    # Case (c), 'deletion'
	    incr last1 ; incr a -1
	    lappend result [::list deleted [::list $last1 $a] [::list $last2 $b]]
	    incr a
	} else {
	    # Case (q), 'change'.
	    incr last1 ; incr a -1
	    incr last2 ; incr b -1
	    lappend result [::list changed [::list $last1 $a] [::list $last2 $b]]
	    incr a
	    incr b
	}

	set last1 $a
	set last2 $b
    }

    # Handle the last chunk, using the information about the length of
    # the original sequences.

    set empty1 [expr {($len1 - $last1) <= 1}]
    set empty2 [expr {($len2 - $last2) <= 1}]

    if {$empty1 && $empty2} {
	# Case (d), ignore the indices
    } elseif {$empty1} {
	# Case (b), 'addition'.
	incr last2 ; incr len2 -1
	lappend result [::list added [::list $last1 $len1] [::list $last2 $len2]]
    } elseif {$empty2} {
	# Case (c), 'deletion'
	incr last1 ; incr len1 -1
	lappend result [::list deleted [::list $last1 $len1] [::list $last2 $len2]]
    } else {
	# Case (q), 'change'.
	incr last1 ; incr len1 -1
	incr last2 ; incr len2 -1
	lappend result [::list changed [::list $last1 $len1] [::list $last2 $len2]]
    }

    return $result
}

proc ::struct::list::LcsInvertMerge {lcsData len1 len2} {
    return [LcsInvertMerge2 [::lindex $lcsData 0] [::lindex $lcsData 1] $len1 $len2]
}

proc ::struct::list::LcsInvertMerge2 {idx1 idx2 len1 len2} {
    set result {}
    set last1 -1
    set last2 -1

    foreach a $idx1 b $idx2 {
	# Four possible cases.
	# a) last1 ... a and last2 ... b are not empty.
	#    This is a 'change'.
	# b) last1 ... a is empty, last2 ... b is not.
	#    This is an 'addition'.
	# c) last1 ... a is not empty, last2 ... b is empty.
	#    This is a deletion.
	# d) If both ranges are empty we can ignore the
	#    two current indices. For merging we simply
	#    take the information from the input.

	set empty1 [expr {($a - $last1) <= 1}]
	set empty2 [expr {($b - $last2) <= 1}]

	if {$empty1 && $empty2} {
	    # Case (d), add 'unchanged' chunk.
	    foreach {type left right} [lindex $result end] break
	    if {[string equal $type unchanged]} {
		# We extend the 'unchanged' chunk found at the end.
		lset result end [::list unchanged [::list [lindex $left 0] $a] [::list [lindex $right 0] $b]]
	    } else {
		lappend result [::list unchanged [::list $last1 $a] [::list $last2 $b]]
	    }

	} elseif {$empty1} {
	    # Case (b), 'addition'.
	    incr last2 ; incr b -1
	    lappend result [::list added [::list $last1 $a] [::list $last2 $b]]
	    incr b
	} elseif {$empty2} {
	    # Case (c), 'deletion'
	    incr last1 ; incr a -1
	    lappend result [::list deleted [::list $last1 $a] [::list $last2 $b]]
	    incr a
	} else {
	    # Case (q), 'change'.
	    incr last1 ; incr a -1
	    incr last2 ; incr b -1
	    lappend result [::list changed [::list $last1 $a] [::list $last2 $b]]
	    incr a
	    incr b
	}

	set last1 $a
	set last2 $b
    }

    # Handle the last chunk, using the information about the length of
    # the original sequences.

    set empty1 [expr {($len1 - $last1) <= 1}]
    set empty2 [expr {($len2 - $last2) <= 1}]

    if {$empty1 && $empty2} {
	# Case (d), ignore the indices
    } elseif {$empty1} {
	# Case (b), 'addition'.
	incr last2 ; incr len2 -1
	lappend result [::list added [::list $last1 $len1] [::list $last2 $len2]]
    } elseif {$empty2} {
	# Case (c), 'deletion'
	incr last1 ; incr len1 -1
	lappend result [::list deleted [::list $last1 $len1] [::list $last2 $len2]]
    } else {
	# Case (q), 'change'.
	incr last1 ; incr len1 -1
	incr last2 ; incr len2 -1
	lappend result [::list changed [::list $last1 $len1] [::list $last2 $len2]]
    }

    return $result
}

# ::struct::list::Reverse --
#
#	Reverses the contents of the list and returns the reversed
#	list as the result of the command.
#
# Parameters:
#	sequence	List to be reversed.
#
# Results:
#	The sequence in reverse.
#
# Side effects:
#       None.

proc ::struct::list::Reverse {sequence} {
    set l [::llength $sequence]

    # Shortcut for lists where reversing yields the list itself
    if {$l < 2} {return $sequence}

    # Perform true reversal
    set res [::list]
    while {$l} {
	::lappend res [::lindex $sequence [incr l -1]]
    }
    return $res
}


# ::struct::list::Assign --
#
#	Assign list elements to variables.
#
# Parameters:
#	sequence	List to assign
#	args		Names of the variables to assign to.
#
# Results:
#	The unassigned part of the sequence. Can be empty.
#
# Side effects:
#       None.

proc ::struct::list::Assign {sequence args} {
    set l [::llength $sequence]
    set a [::llength $args]

    # Nothing to assign.
    if {$a == 0} {return $sequence}

    # Perform assignments
    set i 0
    foreach v $args {
	upvar 2 $v var
	set      var [::lindex $sequence $i]
	incr i
    }

    # Return remainder, if there is any.
    return [::lrange $sequence $a end]
}


# ::struct::list::Flatten --
#
#	Remove nesting from the input
#
# Parameters:
#	sequence	List to flatten
#
# Results:
#	The input list with one or all levels of nesting removed.
#
# Side effects:
#       None.

proc ::struct::list::Flatten {args} {
    if {[::llength $args] < 1} {
	return -code error \
		"wrong#args: should be \"::struct::list::Assign ?-full? ?--? sequence\""
    }

    set full 0
    while {[string match -* [set opt [::lindex $args 0]]]} {
	switch -glob -- $opt {
	    -full   {set full 1}
	    --      {break}
	    default {return -code error ""}
	}
	set args [::lrange $args 1 end]
    }

    if {[::llength $args] != 1} {
	return -code error \
		"wrong#args: should be \"::struct::list::Assign ?-full? ?--? sequence\""
    }

    set sequence [::lindex $args 0]
    set cont 1
    while {$cont} {
	set cont 0
	set result [::list]
	foreach item $sequence {
	    eval [::list ::lappend result] $item
	}
	if {$full && [string compare $sequence $result]} {set cont 1}
	set sequence $result
    }
    return $result
}


# ::struct::list::Map --
#
#	Apply command to each element of a list and return concatenated results.
#
# Parameters:
#	sequence	List to operate on
#	cmdprefix	Operation to perform on the elements.
#
# Results:
#	List containing the result of applying cmdprefix to the elements of the
#	sequence.
#
# Side effects:
#       None of its own, but the command prefix can perform arbitry actions.

proc ::struct::list::Map {sequence cmdprefix} {
    # Shortcut when nothing is to be done.
    if {[::llength $sequence] == 0} {return $sequence}

    set res [::list]
    foreach item $sequence {
	lappend res [uplevel 2 [linsert $cmdprefix end $item]]
    }
    return $res
}

# ::struct::list::Fold --
#
#	Fold list into one value.
#
# Parameters:
#	sequence	List to operate on
#	cmdprefix	Operation to perform on the elements.
#
# Results:
#	Result of applying cmdprefix to the elements of the
#	sequence.
#
# Side effects:
#       None of its own, but the command prefix can perform arbitry actions.

proc ::struct::list::Fold {sequence initialvalue cmdprefix} {
    # Shortcut when nothing is to be done.
    if {[::llength $sequence] == 0} {return $initialvalue}

    set res $initialvalue
    foreach item $sequence {
	set res [uplevel 2 [linsert $cmdprefix end $res $item]]
    }
    return $res
}

# ::struct::list::Iota --
#
#	Return a list containing the integer numbers 0 ... n-1
#
# Parameters:
#	n	First number not in the generated list.
#
# Results:
#	A list containing integer numbers.
#
# Side effects:
#       None

proc ::struct::list::Iota {n} {
    set retval [::list]
    for {set i 0} {$i < $n} {incr i} {
	::lappend retval $i
    }
    return $retval
}

# ::struct::list::Equal --
#
#	Compares two lists for equality
#	(Same length, Same elements in same order).
#
# Parameters:
#	a	First list to compare.
#	b	Second list to compare.
#
# Results:
#	A boolean. True if the lists are equal.
#
# Side effects:
#       None

proc ::struct::list::Equal {a b} {
    # Author of this command is "Richard Suchenwirth"

    if {[::llength $a] != [::llength $b]} {return 0}
    if {[::lindex $a 0] == $a} {return [string equal $a $b]}
    foreach i $a j $b {if {![Equal $i $j]} {return 0}}
    return 1
}

# ::struct::list::Repeat --
#
#	Create a list repeating the same value over again.
#
# Parameters:
#	value	value to use in the created list.
#	args	Dimension(s) of the (nested) list to create.
#
# Results:
#	A list
#
# Side effects:
#       None

proc ::struct::list::Repeat {value args} {
    if {[::llength $args] == 1} {set args [::lindex $args 0]}
    set buf {}
    foreach number $args {
	incr number 0 ;# force integer (1)
	set buf {}
	for {set i 0} {$i<$number} {incr i} {
	    ::lappend buf $value
	}
	set value $buf
    }
    return $buf
    # (1): See 'Stress testing' (wiki) for why this makes the code safer.
}
