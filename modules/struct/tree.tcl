# tree.tcl --
#
#	Implementation of a tree data structure for Tcl.
#
# Copyright (c) 1998-2000 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: tree.tcl,v 1.1.1.1 2000/02/24 17:44:43 ericm Exp $

namespace eval ::struct {}

namespace eval ::struct::tree {
    # Data storage in the tree module
    # -------------------------------
    #
    # There's a lot of bits to keep track of for each tree:
    #	nodes
    #	node values
    #	node relationships
    #
    # It would quickly become unwieldy to try to keep these in arrays or lists
    # within the tree namespace itself.  Instead, each tree structure will get
    # its own namespace.  Each namespace contains:
    #	children	array mapping nodes to their children list
    #	parent		array mapping nodes to their parent node
    #	node:$node	array mapping keys to values for the node $node
    
    # counter is used to give a unique name for unnamed trees
    variable counter 0

    # commands is the list of subcommands recognized by the tree
    variable commands [list \
	    "children"	\
	    "destroy"	\
	    "delete"	\
	    "depth"	\
	    "exists"	\
	    "get"	\
	    "insert"	\
	    "move"	\
	    "parent"	\
	    "set"	\
	    "size"	\
	    "swap"	\
	    "unset"	\
	    "walk"	\
	    ]

    # Only export one command, the one used to instantiate a new tree
    namespace export tree
}

# ::struct::tree::tree --
#
#	Create a new tree with a given name; if no name is given, use
#	treeX, where X is a number.
#
# Arguments:
#	name	name of the tree; if null, generate one.
#
# Results:
#	name	name of the tree created

proc ::struct::tree::tree {{name ""}} {
    variable counter
    
    if { [llength [info level 0]] == 1 } {
	incr counter
	set name "tree${counter}"
    }

    if { ![string equal [info commands ::$name] ""] } {
	error "command \"$name\" already exists, unable to create tree"
    }

    # Set up the namespace
    namespace eval ::struct::tree::tree$name {
	variable children
	set children(root) [list ]

	variable parent
	set parent(root) [list ]

	# Set up the root node's data
	variable noderoot
	set noderoot(data) ""
    }

    # Create the command to manipulate the tree
    interp alias {} ::$name {} ::struct::tree::TreeProc $name

    return $name
}

##########################
# Private functions follow

# ::struct::tree::TreeProc --
#
#	Command that processes all tree object commands.
#
# Arguments:
#	name	name of the tree object to manipulate.
#	args	command name and args for the command
#
# Results:
#	Varies based on command to perform

proc ::struct::tree::TreeProc {name {cmd ""} args} {
    # Do minimal args checks here
    if { [llength [info level 0]] == 2 } {
	error "wrong # args: should be \"$name option ?arg arg ...?\""
    }
    
    # Split the args into command and args components
    if { [llength [info commands ::struct::tree::_$cmd]] == 0 } {
	variable commands
	set optlist [join $commands ", "]
	set optlist [linsert $optlist "end-1" "or"]
	error "bad option \"$cmd\": must be $optlist"
    }
    eval [list ::struct::tree::_$cmd $name] $args
}

# ::struct::tree::_children --
#
#	Return the child list for a given node of a tree.
#
# Arguments:
#	name	name of the tree object.
#	node	node to look up.
#
# Results:
#	children	list of children for the node.

proc ::struct::tree::_children {name node} {
    upvar ::struct::tree::tree${name}::children children
    return $children($node)
}

# ::struct::tree::_destroy --
#
#	Destroy a tree, including its associated command and data storage.
#
# Arguments:
#	name	name of the tree.
#
# Results:
#	None.

proc ::struct::tree::_destroy {name} {
    namespace delete ::struct::tree::tree$name
    interp alias {} ::$name {}
}

# ::struct::tree::_delete --
#
#	Remove a node from a tree, including all of its values.  Recursively
#	removes the node's children.
#
# Arguments:
#	name	name of the tree.
#	node	node to delete.
#
# Results:
#	None.

proc ::struct::tree::_delete {name node} {
    if { [string equal $node "root"] } {
	# Can't delete the special root node
	error "cannot delete root node"
    }
    
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }

    upvar ::struct::tree::tree${name}::children children
    upvar ::struct::tree::tree${name}::parent parent

    # Remove this node from its parent's children list
    set parentNode $parent($node)
    set index [lsearch -exact $children($parentNode) $node]
    set children($parentNode) [lreplace $children($parentNode) $index $index]

    # Yes, we could use the stack structure implemented in ::struct::stack,
    # but it's slower than inlining it.  Since we don't need a sophisticated
    # stack, don't bother.
    set st [list ]
    foreach child $children($node) {
	lappend st $child
    }

    unset children($node)
    unset parent($node)
    unset ::struct::tree::tree${name}::node$node

    while { [llength $st] > 0 } {
	set node [lindex $st end]
	set st [lreplace $st end end]
	foreach child $children($node) {
	    lappend st $child
	}
	unset children($node)
	unset parent($node)
	unset ::struct::tree::tree${name}::node$node
    }
    return
}

# ::struct::tree::_depth --
#
#	Return the depth (distance from the root node) of a given node.
#
# Arguments:
#	name	name of the tree.
#	node	node to find.
#
# Results:
#	depth	number of steps from node to the root node.

proc ::struct::tree::_depth {name node} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    upvar ::struct::tree::tree${name}::parent parent
    set depth 0
    while { ![string equal $node "root"] } {
	incr depth
	set node $parent($node)
    }
    return $depth
}

# ::struct::tree::_exists --
#
#	Test for existance of a given node in a tree.
#
# Arguments:
#	name	name of the tree.
#	node	node to look for.
#
# Results:
#	1 if the node exists, 0 else.

proc ::struct::tree::_exists {name node} {
    return [info exists ::struct::tree::tree${name}::parent($node)]
}

# ::struct::tree::_get --
#
#	Get a keyed value from a node in a tree.
#
# Arguments:
#	name	name of the tree.
#	node	node to query.
#	flag	-key; anything else is an error
#	key	key to lookup; defaults to data
#
# Results:
#	value	value associated with the key given.

proc ::struct::tree::_get {name node {flag -key} {key data}} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    
    upvar ::struct::tree::tree${name}::node${node} data
    if { ![info exists data($key)] } {
	error "invalid key \"$key\" for node \"$node\""
    }
    return $data($key)
}

# ::struct::tree::_insert --
#
#	Add a node to a tree.
#
# Arguments:
#	name		name of the tree.
#	parentNode	parent to add the node to.
#	index		index at which to insert.
#	node		node to insert; must be unique.
#
# Results:
#	None.

proc ::struct::tree::_insert {name parentNode index node} {
    if { [_exists $name $node] } {
	error "node \"$node\" already exists in tree \"$name\""
    }
    
    if { ![_exists $name $parentNode] } {
	error "parent node \"$parentNode\" does not exist in tree \"$name\""
    }

    upvar ::struct::tree::tree${name}::parent parent
    upvar ::struct::tree::tree${name}::children children
    upvar ::struct::tree::tree${name}::node${node} data
    
    # Set up the new node
    set parent($node) $parentNode
    set children($node) [list ]
    set data(data) ""

    # Add this node to its parent's children list
    set children($parentNode) [linsert $children($parentNode) $index $node]

    return
}

# ::struct::tree::_move --
#
#	Move a node (and all its subnodes) from where ever it is to a new
#	location in the tree.
#
# Arguments:
#	name		name of the tree
#	parentNode	parent to add the node to.
#	index		index at which to insert.
#	node		node to insert; must be unique.
#
# Results:
#	None.

proc ::struct::tree::_move {name parentNode index node} {
    if { [string equal $node "root"] } {
	error "cannot move root node"
    }

    # Can only move a node to a real location in the tree
    if { ![_exists $name $parentNode] } {
	error "parent node \"$parentNode\" does not exist in tree \"$name\""
    }

    # Can only move real nodes
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }

    # Cannot move a node to be a descendant
    upvar ::struct::tree::tree${name}::parent parent
    set ancestor $parentNode
    while { ![string equal $ancestor "root"] } {
	if { [string equal $ancestor $node] } {
	    error "node \"$node\" cannot be its own descendant"
	}
	set ancestor $parent($ancestor)
    }
    
    upvar ::struct::tree::tree${name}::children children
    
    # Remove this node from its parent's children list
    set oldParent $parent($node)
    set oldInd [lsearch -exact $children($oldParent) $node]
    set children($oldParent) [lreplace $children($oldParent) $oldInd $oldInd]

    # Update the nodes parent value
    set parent($node) $parentNode

    # Add this node to its parent's children list
    set children($parentNode) [linsert $children($parentNode) $index $node]

    return
}

# ::struct::tree::_parent --
#
#	Return the name of the parent node of a node in a tree.
#
# Arguments:
#	name	name of the tree.
#	node	node to look up.
#
# Results:
#	parent	parent of node $node

proc ::struct::tree::_parent {name node} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    return [set ::struct::tree::tree${name}::parent($node)]
}

# ::struct::tree::_set --
#
#	Set or get a value for a node in a tree.
#
# Arguments:
#	name	name of the tree.
#	node	node to modify or query.
#	args	?-key key? ?value?
#
# Results:
#	val	value associated with the given key of the given node

proc ::struct::tree::_set {name node args} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    upvar ::struct::tree::tree${name}::node$node data

    if { [llength $args] > 3 } {
	error "wrong # args: should be \"$name set $node ?-key key?\
		?value?\""
    }
    
    set key "data"
    set haveValue 0
    if { [llength $args] > 1 } {
	foreach {flag key} $args break
	if { ![string match "${flag}*" "-key"] } {
	    error "invalid option \"$flag\": should be key"
	}
	if { [llength $args] == 3 } {
	    set haveValue 1
	    set value [lindex $args end]
	}
    } elseif { [llength $args] == 1 } {
	set haveValue 1
	set value [lindex $args end]
    }

    if { $haveValue } {
	# Setting a value
	return [set data($key) $value]
    } else {
	# Getting a value
	if { ![info exists data($key)] } {
	    error "invalid key \"$key\" for node \"$node\""
	}
	return $data($key)
    }
}

# ::struct::tree::_size --
#
#	Return the number of descendants of a given node.  The default node
#	is the special root node.
#
# Arguments:
#	name	name of the tree.
#	node	node to start counting from (default is root).
#
# Results:
#	size	number of descendants of the node.

proc ::struct::tree::_size {name {node root}} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    
    # If the node is the root, we can do the cheap thing and just count the
    # number of nodes (excluding the root node) that we have in the tree with
    # array names
    if { [string equal $node "root"] } {
	set size [llength [array names ::struct::tree::tree${name}::parent]]
	return [expr {$size - 1}]
    }

    # Otherwise we have to do it the hard way and do a full tree search
    upvar ::struct::tree::tree${name}::children children
    set size 0
    set st [list ]
    foreach child $children($node) {
	lappend st $child
    }
    while { [llength $st] > 0 } {
	set node [lindex $st end]
	set st [lreplace $st end end]
	incr size
	foreach child $children($node) {
	    lappend st $child
	}
    }
    return $size
}

# ::struct::tree::_swap --
#
#	Swap two nodes in a tree.
#
# Arguments:
#	name	name of the tree.
#	node1	first node to swap.
#	node2	second node to swap.
#
# Results:
#	None.

proc ::struct::tree::_swap {name node1 node2} {
    # Can't swap the magic root node
    if { [string equal $node1 "root"] || [string equal $node2 "root"] } {
	error "cannot swap root node"
    }
    
    # Can only swap two real nodes
    if { ![_exists $name $node1] } {
	error "node \"$node1\" does not exist in tree \"$name\""
    }
    if { ![_exists $name $node2] } {
	error "node \"$node2\" does not exist in tree \"$name\""
    }

    # Can't swap a node with itself
    if { [string equal $node1 $node2] } {
	error "cannot swap node \"$node1\" with itself"
    }

    # Swapping nodes means swapping their labels and values
    upvar ::struct::tree::tree${name}::children children
    upvar ::struct::tree::tree${name}::parent parent
    upvar ::struct::tree::tree${name}::node${node1} node1Vals
    upvar ::struct::tree::tree${name}::node${node2} node2Vals

    set parent1 $parent($node1)
    set parent2 $parent($node2)

    # Replace node1 with node2 in node1's parent's children list, and
    # node2 with node1 in node2's parent's children list
    set i1 [lsearch -exact $children($parent1) $node1]
    set i2 [lsearch -exact $children($parent2) $node2]

    set children($parent1) [lreplace $children($parent1) $i1 $i1 $node2]
    set children($parent2) [lreplace $children($parent2) $i2 $i2 $node1]
    
    # Make node1 the parent of node2's children, and vis versa
    foreach child $children($node2) {
	set parent($child) $node1
    }
    foreach child $children($node1) {
	set parent($child) $node2
    }
    
    # Swap the children lists
    set children1 $children($node1)
    set children($node1) $children($node2)
    set children($node2) $children1

    if { [string equal $node1 $parent2] } {
	set parent($node1) $node2
	set parent($node2) $parent1
    } elseif { [string equal $node2 $parent1] } {
	set parent($node1) $parent2
	set parent($node2) $node1
    } else {
	set parent($node1) $parent2
	set parent($node2) $parent1
    }

    # Swap the values
    set value1 [array get node1Vals]
    unset node1Vals
    array set node1Vals [array get node2Vals]
    unset node2Vals
    array set node2Vals $value1

    return
}

# ::struct::tree::_unset --
#
#	Remove a keyed value from a node.
#
# Arguments:
#	name	name of the tree.
#	node	node to modify.
#	args	additional args: ?-key key?
#
# Results:
#	None.

proc ::struct::tree::_unset {name node {flag -key} {key data}} {
    if { ![_exists $name $node] } {
	error "node \"$node\" does not exist in tree \"$name\""
    }
    
    if { ![string match "${flag}*" "-key"] } {
	error "invalid option \"$flag\": should be \"$name unset\
		$node ?-key key?\""
    }

    upvar ::struct::tree::tree${name}::node${node} data
    if { [info exists data($key)] } {
	unset data($key)
    }
    return
}

# ::struct::tree::_walk --
#
#	Walk a tree using a pre-, post-, or in-order depth or breadth first
#	search. Pre-order DFS is the default.  At each node that is visited,
#	a command will be called with the name of the tree and the node.
#
# Arguments:
#	name	name of the tree.
#	node	node at which to start.
#	args	additional args: ?-type {bfs|dfs}? ?-order {pre|post|in}?
#		-command cmd
#
# Results:
#	None.

proc ::struct::tree::_walk {name node args} {
    set usage "$name walk $node ?-type {bfs|dfs}?\
		?-order {pre|post|in}? -command cmd\""

    if {[llength $args] > 6 || [llength $args] < 2} {
	error "wrong # args: should be \"$usage\""
    }

    # Set defaults
    set type dfs
    set order pre
    set cmd ""

    for {set i 0} {$i < [llength $args]} {incr i} {
	set flag [lindex $args $i]
	incr i
	if { $i >= [llength $args] } {
	    error "value for \"$flag\" missing: should be \"$usage\""
	}
	switch -glob -- $flag {
	    "-type" {
		set type [string tolower [lindex $args $i]]
	    }
	    "-order" {
		# TODO -- it's a large hassle to support all three kinds 
		# of traversal here, so for now order is always pre-order.
		# To re-enable it, uncomment the next line and add support.
		#set order [string tolower [lindex $args $i]]
	    }
	    "-command" {
		set cmd [lindex $args $i]
	    }
	    default {
		error "unknown option \"$flag\": should be \"$usage\""
	    }
	}
    }
    
    # Make sure we have a command to run, otherwise what's the point?
    if { [string equal $cmd ""] } {
	error "no command specified: should be \"$usage\""
    }

    # Validate that the given type is good
    switch -glob -- $type {
	"dfs" {
	    set type "dfs"
	}
	"bfs" {
	    set type "bfs"
	}
	default {
	    error "invalid search type \"$type\": should be dfs, or bfs"
	}
    }
    
    # Validate that the given order is good
    switch -glob -- $order {
	"pre" {
	    set order pre
	}
	"post" {
	    set order post
	}
	"in" {
	    set order in
	}
	default {
	    error "invalid search order \"$order\": should be pre, post, or in"
	}
    }

    # Do the walk
    upvar ::struct::tree::tree${name}::children children
    set st [list ]
    lappend st $node
    if { [string equal $type "dfs"] } {
	# Depth-first search
	while { [llength $st] > 0 } {
	    set node [lindex $st end]
	    set st [lreplace $st end end]
	    # Evaluate the command at this node
	    set cmdcpy $cmd
	    lappend cmdcpy $name $node
	    uplevel 2 $cmdcpy
	    
	    # Add this node's children.  Have to add them in reverse order
	    # so that they will be popped left-to-right
	    set len [llength $children($node)]
	    for {set i [expr {$len - 1}]} {$i >= 0} {incr i -1} {
		lappend st [lindex $children($node) $i]
	    }
	}
    } else {
	# Breadth first search
	while { [llength $st] > 0 } {
	    set node [lindex $st 0]
	    set st [lreplace $st 0 0]
	    # Evaluate the command at this node
	    set cmdcpy $cmd
	    lappend cmdcpy $name $node
	    uplevel 2 $cmdcpy
	    
	    # Add this node's children
	    foreach child $children($node) {
		lappend st $child
	    }
	}
    }
    return
}

