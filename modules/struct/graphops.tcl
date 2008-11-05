# graphops.tcl --
#
#	Operations on and algorithms for graph data structures.
#
# Copyright (c) 2008 Alejandro Paz <vidriloco@gmail.com>, algorithm implementation
# Copyright (c) 2008 Andreas Kupries, integration with Tcllib's struct::graph
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: graphops.tcl,v 1.1 2008/11/05 07:28:52 andreas_kupries Exp $

package require Tcl 8.4

namespace eval ::struct::graph::op {}

# ### ### ### ######### ######### #########
## 

# This method constructs an adjacency matrix representation of this graph

proc ::struct::graph::op::toAdjacencyMatrix {g args} {
    # Unclear ... Apparently not used.
    if {0} {
	set valformat [lsearch $args -entrydata]
	if{$valformat eq weights} {
	    #TODO weights checker
	}
    }

    set nodeList [lsort -dict [$g nodes]]

    # AK: Added 'lsort' to impose some order on the matrix, for easier
    #     comparison of results in tests. Otherwise different versions
    #     of Tcl and struct::graph (critcl) may generate different,
    #     yet equivalent matrices.

    set matrix {}
    lappend matrix [linsert $nodeList 0 {}]

    # Fill an array for index tracking later.
    # AK: Simplified. Also start from 1 to avoid expr+1 later in the
    #     big loop, see (*).
    set i 1
    foreach n  $nodeList {
	set nodeDict($n) $i
	incr i
    }

    # set up a base row with all of it's elements set to zero.
    # AK: Simplified. Renamed nthRow -> baseRow, nthRowf -> currentRow
    set baseRow 0
    foreach n $nodeList {
	lappend baseRow 0
    }  

    foreach node $nodeList {
	# first element on every row is it's corresponding node
	# lreplace creates a clone of the original object so
	# we can always work from the base row
	set currentRow [lreplace $baseRow 0 0 $node]

	# iterate over the neighbours, also known as 'adjacent' rows.

	# AK: Simplifications. (*) Have the proper index in nodeDict,
	# avoid the expr (+1). Compute only once too.
	set inNodes [$g nodes -adj $node]
	foreach pairedNode $inNodes {
	    # set value for pairedNode on this node list
	    set at $nodeDict($pairedNode)
	    set currentRow [lreplace $currentRow $at $at 1]
	}
	lappend matrix $currentRow
    }

    # AK: The matrix is a list of lists, size (n+1)^2 where n = number of nodes
    #     First row and column (index 0) are node names. The other entries are
    #     boolean flags. True when an arc is present, False otherwise. The matrix
    #     represents an un-directional form of the graph with parallel arcs collapsed.

    return $matrix
}

#
## place holder for the operations to come
#

# ### ### ### ######### ######### #########
## Internal helpers

# This method verifies that every arc on the graph has a weight
# assigned to it. This is required for some algorithms.
proc  ::struct::graph::op::VerifyWeightsAreOk {g} {
    if {![llength [$g arc getunweighted]]} return
    return -code error "Operation invalid for graph with unweighted arcs."
}

# ### ### ### ######### ######### #########
## Ready

namespace eval ::struct::graph::op {
    #namespace export ...
}

package provide struct::graph::op 0.1
