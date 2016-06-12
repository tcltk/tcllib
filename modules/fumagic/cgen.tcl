# cgen.tcl --
#
#	Generator core for compiler of magic(5) files into recognizers
#	based on the 'rtcore'.
#
# Copyright (c) 2016      Poor Yorick     <tk.tcl.core.tcllib@pooryorick.com>
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005      Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: cgen.tcl,v 1.7 2007/06/23 03:39:34 andreas_kupries Exp $

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

package require Tcl 8.6
package require fileutil::magic::rt ; # Runtime core, for Access to the typemap
package require struct::list        ; # Our data structures.

package provide fileutil::magic::cgen 1.2

# ### ### ### ######### ######### #########
## Implementation

namespace eval ::fileutil::magic {
    namespace export *
}
namespace eval ::fileutil::magic::cgen {
    namespace ensemble create
    namespace export *
    # Import the runtime typemap into our scope.
    variable ::fileutil::magic::rt::typemap

    # The tree most operations use for their work.
    variable tree {}

    # Generator data structure.
    variable regions

    # Export the API
    namespace export 2tree treedump treegen

   # Assumption : the parser folds the test inversion operator into equality and
   # inequality operators .
    variable offsetskey {
	type o rel ind ir it ioi ioo iir io compinvert mod mand
    }
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

proc ::fileutil::magic::cgen::tree_el {tree node} {
    set parent [$tree parent $node]
    if {[$tree keyexists $parent path]} {
	set path [$tree get $parent path]
    } else {
	set path {} 
    }
    lappend path [$tree index $node]
    $tree set $node path $path

    foreach name {type} {
	set $name [$tree get $node $name]
    }

    # Recursively creates and annotates a node for the specified
    # tests, and its sub-tests (args).


    # generate a proc call type for the type, Numeric or String
    variable ::fileutil::magic::rt::typemap

    switch -glob -- $type {
   	*byte* -
	*double* -
   	*short* -
   	*long* -
	*quad* -
   	*date* {
   	    $tree set $node otype N
   	}
   	clear - default - search - regex - *string* {
   	    $tree set $node otype S
   	}
	name {
	    $tree set $node otype A
	}
	use {
	    $tree set $node otype U
	}
   	default {
   	    puts stderr "Unknown type: '$type'"
	    $tree set $node otype Unknown
   	}
    }

    # Stores the type determined above, and the arguments into
    # attributes of the new node.

    # now add children
    foreach el [$tree children $node] {
	tree_el $tree $el
    }
    return
}

proc ::fileutil::magic::cgen::2tree {tree} {

    foreach child [$tree children root] {
	tree_el $tree $child
    }
    optNum $tree root
    #optStr $tree root
    puts stderr "Script contains [llength [$tree children root]] discriminators"
    path $tree

    # Decoding the offsets, determination if we have to handle
    # relative offsets, and where. The less, the better.
    Offsets $tree

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
    } result]} {
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

	set o [$tree get $el o]
	set len    [string length [$tree get $el val]]
	lappend regions([list $o $len]) $el
    }
}

proc ::fileutil::magic::cgen::isNum {tree node} {
    return [expr {"N" eq [$tree get $node otype]}]
}

proc ::fileutil::magic::cgen::switchNSort {tree n1 n2} {
    return [expr {[$tree get $n1 val] - [$tree get $n1 val]}]
}

proc ::fileutil::magic::cgen::optNum {tree node} {
    variable offsetskey
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
	if {[$tree get $el comp] ne {==}} {
	    continue
	}
	set key {}
	foreach name $offsetskey {
	    lappend key [$tree get $el $name]
	}
	lappend offsets([join $key ,]) $el
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
		puts stderr "*====================================="
		puts stderr "* Node         <[$tree getall $n]>"
		puts stderr "* clashes with <[$tree getall $matcher($nv)]>"
		puts stderr "*====================================="
	    } else {
		set matcher($nv) $n
	    }
	}

	foreach $offsetskey [split $match ,] break
	set switch [$tree insert $node [$tree index [lindex $nodes 0]]]
	$tree set $switch otype   Switch
	$tree set $switch desc $match
	foreach name $offsetskey {
	    $tree set $switch $name [set $name]
	}

	set nodes [lsort -command [list ::fileutil::magic::cgen::switchNSort $tree] $nodes]

	eval [linsert $nodes 0 $tree move $switch end]
	# 8.5 # $tree move $switch end {*}$nodes
	set     path [$tree get [$tree parent $switch] path]
	lappend path [$tree index $switch]
	$tree set $switch path $path

	set level [$tree get [$tree parent $switch] level]
	$tree set $switch level [expr {$level+1}]
    }
}

proc ::fileutil::magic::cgen::Offsets {tree} {

    # Indicator if a node has to save field location information for
    # relative addressing. The 'kill' attribute is an accumulated
    # 'save' over the whole subtree. It will be used to determine when
    # level information was destroyed by subnodes and has to be
    # regenerated at the current level.

    $tree walk root -type dfs node {
	$tree set $node kill 0
	if {[$tree get $node otype] ne {Root} &&
	    ([$tree get $node rel] || [$tree get $node ir])} {
	    $tree set $node save 1
	} else {
	    $tree set $node save 0
	}
    }

    # We walk from the leafs up to the root, synthesizing the data
    # needed, as we go.
    $tree walk root -type dfs -order post node {
	if {$node eq {root}} continue

	# If the current node's parent is a switch, and the node has
	# to save, then the switch has to save. Because the current
	# node is not relevant during code generation anymore, the
	# switch is.

	if {[$tree get $node save]} {
	    # We save, therefore we kill.
	    $tree set $node kill 1
	    if {[$tree get [$tree parent $node] otype] eq {Switch}} {
		$tree set [$tree parent $node] save 1
	    }
	} else {
	    # We don't save i.e. kill, but we may inherit it from
	    # children which kill.

	    foreach c [$tree children $node] {
		if {[$tree get $c kill]} {
		    $tree set $node kill 1
		    break
		}
	    }
	}
    }
}


# Useful when debugging
proc ::fileutil::magic::cgen::stack {tree node} {
    set res {}
    set files [$tree get root files]
    while 1 {
	set s [dict create \
	    file [lindex $files [$tree get $node file]] \
	    linenum [$tree get $node linenum]]
	if {[$tree keyexists $node origin]} {
	    set origin [$tree get $node origin]
	    dict set s origin [dict create \
		name [$tree get $origin val] \
		file [lindex $files [$tree get $origin file]] \
		linenum [$tree get $origin linenum]]
	}
	set res [linsert $res 0 $s]
	set node [$tree parent $node]
	if {$node eq {root}} {
	    break
	}
    }
    return $res
}

proc ::fileutil::magic::cgen::treedump {tree} {
    set result ""
    $tree walk root -type dfs node {
	set path  [$tree get $node path]
	set depth [llength $path]

	append result [string repeat "  " $depth] [list $path] ": " [$tree get $node type]:

	if {[$tree keyexists $node o]} {
	    append result " ,O|[$tree get $node o]|"

	    set x {}
	    foreach v {ind rel base itype iop ioperand idelta} {lappend x [$tree get $node $v]}
	    append result "=<[join $x !]>"
	}
	if {[$tree keyexists $node qual]} {
	    set q [$tree get $node qual]
	    if {$q ne ""} {
		append result " ,q/$q/"
	    }
	}

	if {[$tree keyexists $node comp]} {
	    append result " " C([$tree get $node comp])
	}
	if {[$tree keyexists $node val]} {
	    append result " " V([$tree get $node val])
	}

	if {[$tree keyexists $node otype]} {
	    append result " " [$tree get $node otype]/[$tree get $node save]
	}

	if {$depth == 1} {
	    set msg [$tree get $node desc]
	    set n $node
	    while {($n != {}) && ($msg == "")} {
		set n [lindex [$tree children $n] 0]
		if {$n != {}} {
		    set msg [$tree get $n desc]
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
    variable ::fileutil::magic::rt::typemap

    set result {} 
    set named [$tree get root named]
    set otype [$tree get $node otype]
    set level [$tree get $node level]

    set indent \n[string repeat \t [expr {$level > 0 ? $level-1 : 0}]]

    # Generate code for each node per its type.

    switch $otype {
	A {
	    set file [$tree get $node file]
	    set val [$tree get $node val]
	    if {[dict exists named $file$val]} {
		return -code error [list {name already exists} $file $val]
	    }
	    set aresult {}
	    foreach child [$tree children $node] {
		lappend aresult [treegen $tree $child]
	    }
	    dict set named $file $val [join $aresult \n]
	    $tree set root named $named
	    return
	}
	U {
	    set file [$tree get $node file]
	    set val [$tree get $node val]
	    append result "U [list $file] [list $val]\n" 
	}
	N -
	S {
	    set names {type mod mand testinvert compinvert comp val desc kill save path}
	    foreach name $names {
		set $name [$tree get $node $name]
	    }

	    set o [GenerateOffset $tree $node]

	    if {$val eq {}} {
		# If the value is the empty string, armor it.  Otherwise, it's
		# already been armored.
		set val [list $val]
	    }

	    if {$otype eq {N}} {
		if {$kill} {
		    # We have to save field data for relative adressing under this
		    # leaf.
		    set type [list Nx $type]
		} else {
		    # Regular fetching of information.
		    set type [list N $type]
		}
		# $type and $o are expanded via substitution 
		append result "${indent}if \{\[$type $o [list $testinvert] [
		    list $compinvert] [list $mod] [list $mand] [
		    list $comp] $val\]\} \{>\n"
	    } elseif {$otype eq {S}} {
		switch $comp {
		    == {set comp eq}
		    != {set comp ne}
		}
		if {$kill} {
		    set type [list Sx $type]
		} else {
		    set type [list S $type]
		}
		append result "${indent}if \{\[$type $o [list $testinvert] [
		    list $mod] [list $mand] [list $comp] $val\]\} \{>\n"
	    }

	    if {[$tree isleaf $node] && $desc ne {}} {
		append result "${indent}emit [list $desc]"
	    } else {
		if {$desc ne {}} {
		    append result "${indent}emit [list $desc]\n"
		}
		foreach child [$tree children $node] {
		    append result [treegen $tree $child]
		}
		#append result "\nreturn \$result"
	    }

	    if {[$tree keyexists $node ext_mime]} {
		append result "${indent}mime [$tree get $node ext_mime]\n"
	    }

	    if {[$tree keyexists $node ext_ext]} {
		append result "${indent}ext [$tree get $node ext_ext]\n"
	    }

	    append result "\n<\}\n"
	}
	Root {
	    foreach child [$tree children $node] {
		lappend result [treegen $tree $child]
		if {[lindex $result end] eq {}} {
		    set result [lreplace $result[set result {}] end end]
		}
	    }
	}
	Switch {
	    set names {o type compinvert mod mand kill save}
	    foreach name $names {
		set $name [$tree get $node $name]
	    }
	    set o [GenerateOffset $tree $node]

	    if {$kill} {
		set fetch Nvx
	    } else {
		set fetch Nv
	    }

	    append fetch " $type $o [list $compinvert] [list $mod] [list $mand]"
	    append result "${indent}switch -- \[$fetch\] "

	    set scan [lindex $typemap($type) 1]

	    set ckilled 0
	    foreach child [$tree children $node] {
		# See ::fileutil::magic::rt::rtscan
		if {$scan eq {me}} {
		    set scan I
		}

		# get value in binary form, then back to numeric
		# this avoids problems with sign, as both values are
		# [binary scan]-converted identically
		binary scan [binary format $scan [$tree get $child val]] $scan val

		append result "$val \{>;"

		set desc [$tree get $child desc]
		if {[$tree isleaf $child] && $desc ne {}} {
		    append result "emit [list [$tree get $child desc]]"
		} else {
		    if {$desc ne {}} {
			append result "emit [list [$tree get $child desc]]\n"
		    }
		    foreach grandchild [$tree children $child] {
			append result [treegen $tree $grandchild]
		    }
		}
		if {[$tree keyexists $child ext_mime]} {
		    append result "${indent}mime [$tree get $child ext_mime]\n"
		}

		if {[$tree keyexists $child ext_ext]} {
		    append result "${indent}ext [$tree get $child ext_ext]\n"
		}

		append result ";<\} "
	    }
	    append result "\n<\n"
	}
    }
    return $result
}

proc ::fileutil::magic::cgen::GenerateOffset {tree node} {
    # Examples:
    # direct absolute:     45      -> 45
    # direct relative:    &45      -> [R 45]
    # indirect absolute:  (45.s+1) -> [I 45 s + 0 1]
    # indirect absolute (indirect offset):  (45.s+(1)) -> [I 45 s + 1 1]
    # relative indirect absolute:  &(45.s+1) -> [R [I 45 s + 0 1]]
    # relative indirect absolute (indirect offset):  &(45.s+(1)) -> [R [I 45 s + 1 1]]
    # indirect relative: (&45.s+1) -> [I [R 45] s op 0 1]
    # relative indirect relative: &(&45.s+1) -> [R [I [R 45] s + 0 1]]
    # relative indirect relative: &(&45.s+(1)) -> [R [I [R 45] s + 1 1]]

    foreach v {o rel ind ir it ioi iir ioo io} {
	set $v [$tree get $node $v]
    }

    #foreach v {ind rel base itype iop ioperand iindir idelta} {
    #    set $v [$tree get $node $v]
    #}

    if {$ind} {
	if {$ir} {set o "\[R $o]"}
	set o "\[I $o [list $it] [list $ioi] [list $ioo] [list $iir] [list $io]\]"
    }
    if {$rel} {
	set o "\[R $o\]"
    }
    
    return $o
}

# ### ### ### ######### ######### #########
## Ready for use.
# EOF
