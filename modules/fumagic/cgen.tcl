# cgen.tcl --
#
#	Generator core for compiler of magic(5) files into recognizers
#	based on the 'rtcore'.
#
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005      Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: cgen.tcl,v 1.1 2005/02/10 17:34:16 andreas_kupries Exp $

#####
#
# "mime type recognition in pure tcl"
# http://wiki.tcl.tk/12526
#
# Tcl code harvested on:  10 Feb 2005, 04:06 GMT
# Wiki page last updated: ???
#
#####

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.4
package require fileutil::magic::rt ; # Runtime core, for Access to the typemap
package require struct::list        ; # Our data structures.
package require struct::tree        ; #

# ### ### ### ######### ######### #########
## Implementation

namespace eval ::fileutil::magic::cgen {
    # Import the runtime typemap into our scope.
    variable ::fileutil::rt::typemap

    # The tree most operations use for their work.
    variable tree {}

    # Generator data structure.
    variable regions

    namespace export 2tree treedump treegen

}


# Optimisations:

# reorder tests according to expected or observed frequency this
# conflicts with reduction in strength optimisations.

# Rewriting within a level will require pulling apart the list of
# tests at that level and reordering them.  There is an inconsistency
# between handling at 0-level and deeper level - this has to be
# removed or justified.

# Hypothetically, every test at the same level should be mutually
# exclusive, but this is not given, and should be detected.  If true,
# this allows reduction in strength to switch on Numeric tests

# reduce Numeric tests at the same level to switches
#
# - first pass through clauses at same level to categorise as
#   variant values over same test (type and offset).

# work out some way to cache String comparisons

# Reduce seek/reads for String comparisons at same level:
#
# - first pass through clauses at same level to determine string ranges.
#
# - String tests at same level over overlapping ranges can be
#   written as sub-string comparisons over the maximum range
#   this saves re-reading the same string from file.
#
# - common prefix strings will have to be guarded against, by
#   sorting string values, then sorting the tests in reverse length order.


proc ::fileutil::magic::cgen::path {tree} {
    # Annotates the tree. In each node we store the path from the root
    # to this node, as list of nodes, with the current node the last
    # element. The root node is never stored in the path.

    $tree set root path {}
    foreach child [$tree children root] {
   	$tree walk $child -type dfs node {
   	    set path [$tree get [$tree parent $node] path]
   	    lappend path [$tree index $node]
   	    $tree set $node path $path
   	}
    }
    return
}

proc ::fileutil::magic::cgen::tree_el {tree parent file line type qual comp offset val message args} {

    # Recursively creates and annotates a node for the specified
    # tests, and its sub-tests (args).

    set     node [$tree insert $parent end]
    set     path [$tree get    $parent path]
    lappend path [$tree index  $node]
    $tree set $node path $path

    # generate a proc call type for the type, Numeric or String
    variable typemap
    switch -glob -- $type {
   	*byte* -
   	*short* -
   	*long* -
   	*date* {
   	    set otype N
   	    set type [lindex $typemap($type) 1]
   	}
   	*string {
   	    set otype S
   	}
   	default {
   	    puts stderr "Unknown type: '$type'"
   	}
    }

    # Stores the type determined above, and the arguments into
    # attributes of the new node.

    foreach key {line type qual comp offset val message file otype} {
   	if {[catch {
   	    $tree set $node $key [set $key]
   	} result eo]} {
   	    puts "Tree: $eo - $file $line $type"
   	}
    }

    # now add children
    foreach el $args {
	eval [linsert $el 0 tree_el $tree $node $file]
   	# 8.5 # tree_el $tree $node $file {expand}$el
    }
    return $node
}

proc ::fileutil::magic::cgen::2tree {script} {

    # Converts a recognizer which is in a simple script form into a
    # tree.

    variable tree
    set tree [::struct::tree]

    $tree set root path ""
    $tree set root otype Root
    $tree set root type root
    $tree set root message "unknown"

    # generate a test for each match
    set file "unknown"
    foreach el $script {
   	#puts "EL: $el"
   	if {[lindex $el 0] eq "file"} {
   	    set file [lindex $el 1]
   	} else {
	    set node [eval [linsert $el 0 tree_el $tree root $file]]
	    # 8.5 # set more [tree_el $tree root $file {expand}$el]
   	    append result $node
   	}
    }
    optNum $tree root
    #optStr $tree root
    puts stderr "Script contains [llength [$tree children root]] discriminators"
    path $tree
    return $tree
}

proc ::fileutil::magic::cgen::isStr {tree node} {
    return [expr {"S" eq [$tree get $node otype]}]
}

proc ::fileutil::magic::cgen::sortRegion {r1 r2} {
    set cmp 0
    if {[catch {
   	if {[string match (*) $r1] || [string match (*) $r2]} {
   	    set cmp [string compare $r1 $r2]
   	} else {
   	    set cmp [expr {[lindex $r1 0] - [lindex $r2 0]}]
   	    if {!$cmp} {
   		set cmp 0
   		set cmp [expr {[lindex $r1 1] - [lindex $r2 1]}]
   	    }
   	}
    } result eo]} {
   	set cmp [string compare $r1 $r2]
    }
    return $cmp
}

proc ::fileutil::magic::cgen::optStr {tree node} {
    variable regions
    catch {unset regions}
    array set regions {}

    optStr1 $tree $node

    puts stderr "Regions [array statistics regions]"
    foreach region [lsort \
	    -index   0 \
	    -command ::fileutil::magic::cgen::sortRegion \
	    [array name regions]] {
   	puts "$region - $regions($region)"
    }
}

proc ::fileutil::magic::cgen::optStr1 {tree node} {
    variable regions

    # traverse each numeric element of this node's children,
    # categorising them

    set kids [$tree children $node]
    foreach child $kids {
   	optStr1 $tree $child
    }

    set strings [$tree children $node filter ::fileutil::magic::cgen::isStr]
    #puts stderr "optstr: $node: $strings"

    foreach el $strings {
   	#if {[$tree get $el otype] eq "String"} {puts "[$tree getall $el] - [string length [$tree get $el val]]"}
	if {[$tree get $el comp] eq "x"} {
	    continue
	}

	set offset [$tree get $el offset]
	set len    [string length [$tree get $el val]]
	lappend regions([list $offset $len]) $el
    }
}

proc ::fileutil::magic::cgen::isNum {tree node} {
    return [expr {"N" eq [$tree get $node otype]}]
}

proc ::fileutil::magic::cgen::switchNSort {tree n1 n2} {
    return [expr {[$tree get $n1 val] - [$tree get $n1 val]}]
}

proc ::fileutil::magic::cgen::optNum {tree node} {
    array set offsets {}

    # traverse each numeric element of this node's children,
    # categorising them

    set kids [$tree children $node]
    foreach child $kids {
	optNum $tree $child
    }

    set numerics [$tree children $node filter ::fileutil::magic::cgen::isNum]
    #puts stderr "optNum: $node: $numerics"
    if {[llength $numerics] < 2} {
	return
    }

    foreach el $numerics {
	if {[$tree get $el comp] ne "=="} {
	    continue
	}
	lappend offsets([$tree get $el type],[$tree get $el offset],[$tree get $el qual]) $el
    }

    #puts "Offset: stderr [array get offsets]"
    foreach {match nodes} [array get offsets] {
	if {[llength $nodes] < 2} {
	    continue
	}

	catch {unset matcher}
	foreach n $nodes {
	    set nv [expr [$tree get $n val]]
	    if {[info exists matcher($nv)]} {
		puts stderr "Node <[$tree getall $n]> clashes with <[$tree getall $matcher($nv)]>"
	    } else {
		set matcher($nv) $n
	    }
	}

	foreach {type offset qual} [split $match ,] break
	set switch [$tree insert $node [$tree index [lindex $nodes 0]]]
	$tree set $switch otype   Switch
	$tree set $switch message $match
	$tree set $switch offset  $offset
	$tree set $switch type    $type
	$tree set $switch qual    $qual

	set nodes [lsort -command [list ::fileutil::magic::cgen::switchNSort $tree] $nodes]

	eval [linsert $nodes 0 $tree move $switch end]
	# 8.5 # $tree move $switch end {expand}$nodes
	set     path [$tree get [$tree parent $switch] path]
	lappend path [$tree index $switch]
	$tree set $switch path $path
    }
}

proc ::fileutil::magic::cgen::treedump {tree} {
    set result ""
    $tree walk root -type dfs node {
	set path  [$tree get $node path]
	set depth [llength $path]

	append result [string repeat "  " $depth] [list $path] ": " [$tree get $node type]

	if {[$tree keyexists $node offset]} {
	    append result ,[$tree get $node offset]
	}
	if {[$tree keyexists $node qual]} {
	    set q [$tree get $node qual]
	    if {$q ne ""} {
		append result ,$q
	    }
	}

	if {[$tree keyexists $node comp]} {
	    append result [$tree get $node comp]
	}
	if {[$tree keyexists $node val]} {
	    append result [$tree get $node val]
	}

	if {$depth == 1} {
	    set msg [$tree get $node message]
	    set n $node
	    while {($n != {}) && ($msg == "")} {
		set n [lindex [$tree children $n] 0]
		if {$n != {}} {
		    set msg [$tree get $n message]
		}
	    }
	    append result " " ( $msg )
	    if {[$tree keyexists $node file]} {
		append result " - " [$tree get $node file]
	    }
	}

	#append result " <" [$tree getall $node] >
	append result \n
    }
    return $result
}

proc ::fileutil::magic::cgen::treegen {tree node} {
    return "[treegen1 $tree $node]\nresult\n"
}

proc ::fileutil::magic::cgen::treegen1 {tree node} {
    variable typemap

    set result ""
    foreach k {otype type offset comp val qual message} {
	if {[$tree keyexists $node $k]} {
	    set $k [$tree get $node $k]
	}
    }

    if {$otype eq "N"} {
	set type [list N $type]
    } elseif {$otype eq "S"} {
	set type S
    }

    # Generate code for each node per its type.

    switch $otype {
	N -
	S {
	    # this is a complex offset - call the offset interpreter
	    # NOTE: The offset interpreter is currently not implemented.

	    if {[string match "(*)" $offset]} {
		set offset "\[offset $offset\]"
		puts "WARNING: This magic makes use of the complex offset interpreter."
		puts "WARNING: A feature not implemented by the runtime core."
		puts "WARNING: Recognition results may be incorrect."
	    }

	    if {$qual eq ""} {
		append result "if \{\[$type $offset $comp [list $val]\]\} \{"
	    } else {
		append result "if \{\[$type $offset $comp [list $val] $qual\]\} \{"
	    }

	    if {[$tree isleaf $node]} {
		if {$message ne ""} {
		    append result "emit [list $message]"
		} else {
		    append result "emit [$tree get $node path]"
		}
	    } else {
		if {$message ne ""} {
		    append result "emit [list $message]\n"
		}
		foreach child [$tree children $node] {
		    append result [treegen1 $tree $child]
		}
		#append result "\nreturn \$result"
	    }

	    append result "\}\n"
	}
	Root {
	    foreach child [$tree children $node] {
		append result [treegen1 $tree $child]
	    }
	}
	Switch {
	    # this is a complex offset - call the offset interpreter
	    if {[string match "(*)" $offset]} {
		set offset "\[offset $offset\]"
		puts "WARNING: This magic makes use of the complex offset interpreter."
		puts "WARNING: A feature not implemented by the runtime core."
		puts "WARNING: Recognition results may be incorrect."
	    }

	    if {$qual eq ""} {
		append result "switch -- \[Nv $type $offset\] "
	    } else {
		append result "switch -- \[Nv $type $offset $qual\] "
	    }

	    set scan [lindex $typemap($type) 1]

	    foreach child [$tree children $node] {
		binary scan [binary format $scan [$tree get $child val]] $scan val
		append result "$val \{"

		if {[$tree isleaf $child]} {
		    append result "emit [list [$tree get $child message]]"
		} else {
		    append result "emit [list [$tree get $child message]]\n"
		    foreach grandchild [$tree children $child] {
			append result [treegen1 $tree $grandchild]
		    }
		}
		append result "\} "
	    }
	    append result "\n"
	}
    }
    return $result
}

# ### ### ### ######### ######### #########
## Ready for use.

package provide fileutil::magic::cgen 1.0
# EOF
