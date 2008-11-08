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
# RCS: @(#) $Id: graphops.tcl,v 1.3 2008/11/08 06:43:18 andreas_kupries Exp $

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4

package require struct::disjointset ; # Used by kruskal
package require struct::prioqueue   ; # Used by kruskal, prim

# ### ### ### ######### ######### #########
##

namespace eval ::struct::graph::op {}

# ### ### ### ######### ######### #########
##

# This command constructs an adjacency matrix representation of the
# graph argument.

# Reference: http://en.wikipedia.org/wiki/Adjacency_matrix
#
# Note: The reference defines the matrix in such a way that some of
#       the limitations of the code here are not present. I.e. the
#       definition at wikipedia deals properly with arc directionality
#       and parallelism.
#
# TODO: Rework the code so that the result is in line with the reference.
#       Add features to handle weights as well.

proc ::struct::graph::op::toAdjacencyMatrix {g} {
    set nodeList [lsort -dict [$g nodes]]
    # Note the lsort. This is used to impose some order on the matrix,
    # for comparability of results. Otherwise different versions of
    # Tcl and struct::graph (critcl) may generate different, yet
    # equivalent matrices, dependent on things like the order a hash
    # search is done, or nodes have been added to the graph, or ...

    # Fill an array for index tracking later. Note how we start from
    # index 1. This allows us avoid multiple expr+1 later on when
    # iterating over the nodes and converting the names to matrix
    # indices. See (*).

    set i 1
    foreach n  $nodeList {
	set nodeDict($n) $i
	incr i
    }

    set matrix {}
    lappend matrix [linsert $nodeList 0 {}]

    # Setting up a template row with all of it's elements set to zero.

    set baseRow 0
    foreach n $nodeList {
	lappend baseRow 0
    }

    foreach node $nodeList {

	# The first element in every row is the name of its
	# corresponding node. Using lreplace to overwrite the initial
	# data in the template we get a copy apart from the template,
	# which we can then modify further.

	set currentRow [lreplace $baseRow 0 0 $node]

	# Iterate over the neighbours, also known as 'adjacent'
	# rows. The exact set of neighbours depends on the mode.

	foreach neighbour [$g nodes -adj $node] {
	    # Set value for neighbour on this node list
	    set at $nodeDict($neighbour)

	    # (*) Here we avoid +1 due to starting from index 1 in the
	    #     initialization of nodeDict.
	    set currentRow [lreplace $currentRow $at $at 1]
	}
	lappend matrix $currentRow
    }

    # The resulting matrix is a list of lists, size (n+1)^2 where n =
    # number of nodes. First row and column (index 0) are node
    # names. The other entries are boolean flags. True when an arc is
    # present, False otherwise. The matrix represents an
    # un-directional form of the graph with parallel arcs collapsed.

    return $matrix
}

# ### ### ### ######### ######### #########
##

# This command finds a minimum spanning tree/forest (MST) of the graph
# argument, using the algorithm developed by Joseph Kruskal. The
# result is a set (as list) containing the names of the arcs in the
# MST. The set of nodes of the MST is implied by set of arcs, and thus
# not given explicitly. The algorithm does not consider arc
# directions. Note that unconnected nodes are left out of the result.

# Reference: http://en.wikipedia.org/wiki/Kruskal%27s_algorithm

proc ::struct::graph::op::kruskal {g} {
    # Check graph argument for proper configuration.

    VerifyWeightsAreOk $g

    # Transient helper data structures. A priority queue for the arcs
    # under consideration, using their weights as priority, and a
    # disjoint-set to keep track of the forest of partial minimum
    # spanning trees we are working with.

    set consider [::struct::prioqueue -dictionary consider]
    set forest   [::struct::disjointset forest]

    # Start with all nodes in the graph each in their partition.

    foreach n [$g nodes] {
	$forest add-partition $n
    }

    # Then fill the queue with all arcs, using their weight to
    # prioritize. The weight is the cost of the arc. The lesser the
    # better.

    foreach {arc weight} [$g arc weights] {
	$consider put $arc $weight
    }

    # And now we can construct the tree. This is done greedily. In
    # each round we add the arc with the smallest weight to the
    # minimum spanning tree, except if doing so would violate the tree
    # condition.

    set result {}

    while {[$consider size]} {
	set minarc [$consider get]
	set origin [$g arc source $minarc]
	set destin [$g arc target $minarc]

	# Ignore the arc if both ends are in the same partition. Using
	# it would add a cycle to the result, i.e. it would not be a
	# tree anymore.

	if {[$forest equal $origin $destin]} continue

	# Take the arc for the result, and merge the trees both ends
	# are in into a single tree.

	lappend result $minarc
	$forest merge $origin $destin
    }

    # We are done. Get rid of the transient helper structures and
    # return our result.

    $forest   destroy
    $consider destroy

    return $result
}

# ### ### ### ######### ######### #########
##

# This command finds a minimum spanning tree/forest (MST) of the graph
# argument, using the algorithm developed by Prim. The result is a
# set (as list) containing the names of the arcs in the MST. The set
# of nodes of the MST is implied by set of arcs, and thus not given
# explicitly. The algorithm does not consider arc directions.

# Reference: http://en.wikipedia.org/wiki/Prim%27s_algorithm

proc ::struct::graph::op::prim {g} {
    VerifyWeightsAreOk $g

    # Fill an array with all nodes, to track which nodes have been
    # visited at least once. When the inner loop runs out of nodes and
    # we still have some left over we restart using one of the
    # leftover as new starting point. In this manner we get the MST of
    # the whole graph minus unconnected nodes, instead of only the MST
    # for the component the initial starting node is in.

    array set unvisited {}
    foreach n [$g nodes] { set unvisited($n) . }

    # Transient helper data structure. A priority queue for the nodes
    # and arcs under consideration for inclusion into the MST. Each
    # element of the queue is a list containing node name, a flag bit,
    # and arc name, in this order. The associated priority is the
    # weight of the arc. The flag bit is set for the initial queue
    # entry only, containing a fake (empty) arc, to trigger special
    # handling.

    set consider [::struct::prioqueue -dictionary consider]

    # More data structures, the result arrays.
    array set weightmap {} ; # maps nodes to min arc weight seen so
			     # far. This is the threshold other arcs
			     # on this node will have to beat to be
			     # added to the MST.
    array set arcmap    {} ; # maps arcs to nothing, these are the
			     # arcs in the MST.

    while {[array size unvisited]} {
	# Choose a 'random' node as the starting point for the inner
	# loop, prim's algorithm, and put it on the queue for
	# consideration. Then we iterate until we have considered all
	# nodes in the its component.

	set startnode [lindex [array names unvisited] 0]
	$consider put [list $startnode 1 {}] 0

	while {[$consider size] > 0} {
	    # Pull the next minimum weight to look for. This is the
	    # priority of the next item we can get from the queue. And the
	    # associated node/decision/arc data.

	    set arcweight [$consider peekpriority 1]

	    foreach {v arcundefined arc} [$consider get] break
	    #8.5: lassign [$consider get] v arcundefined arc

	    # Two cases to consider: The node v is already part of the
	    # MST, or not. If yes we check if the new arcweight is better
	    # than what we have stored already, and update accordingly.

	    if {[info exists weightmap($v)]} {
		set currentweight $weightmap($v)
		if {$arcweight < $currentweight} {
		    # The new weight is better, update to use it as
		    # the new threshold. Note that this fill not touch
		    # any other arcs found for this node, as these are
		    # still minimal.

		    set weightmap($v) $arcweight
		    set arcmap($arc)  .
		}
	    } else {
		# Node not yet present. Save weight and arc. The
		# latter if and only the arc is actually defined. For
		# the first, initial queue entry, it is not.  Then we
		# add all the arcs adjacent to the current node to the
		# queue to consider them in the next rounds.

		set weightmap($v) $arcweight
		if {!$arcundefined} {
		    set arcmap($arc) .
		}
		foreach adjacentarc [$g arcs -adj $v] {
		    set weight    [$g arc  getweight   $adjacentarc]
		    set neighbour [$g node opposite $v $adjacentarc]
		    $consider put [list $neighbour 0 $adjacentarc] $weight
		}
	    }

	    # Mark the node as visited, belonging to the current
	    # component. Future iterations will ignore it.
	    unset -nocomplain unvisited($v)
	}
    }

    # We are done. Get rid of the transient helper structure and
    # return our result.

    $consider destroy

    return [array names arcmap]
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

package provide struct::graph::op 0.2
