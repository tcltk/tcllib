# -*- tcl -*-
# (C) 2006 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

package require Tcl 8.3
package require snit
package require tie

# ###

snit::type pregistry {

    # API
    # delete key ?attribute?
    # mtime  key ?attribute?
    # get    key attribute
    # keys   key ?pattern?/*
    # set    key ?attribute value?
    # attrs  key ?pattern?

    option -tie -default {} -configuremethod TIE ; # Persistence

    constructor {args} {
	$self configurelist $args
	$self INIT
	return
    }

    # ###

    method delete {key args} {
	if {[llength $args] > 1} {return -code error "wrong\#args"}
	if {![info exists data([list C $key])]} return

	if {[llength $args]} {
	    set attr [lindex $args 0]
	    unset -nocomplain data([list A  $key $attr])
	    unset -nocomplain data([list Ma $key $attr])
	    set data([list Mk $key]) [clock seconds]
	} else {
	    if {$key == ""} {
		return -code error "cannot delete root"
	    }
	    set parent [lrange  $key 0 end-1]
	    set id     [lindex  $key end]
	    set chglob [linsert $key end *]

	    unset data([list C  $key])
	    unset data([list Mk $key])
	    array unset data [list A $key *]
	    array unset data [list C $chglob]
	    array unset data [list A $chglob *]

	    set pos [lsearch -exact $data([list C $parent]) $id]
	    # assert (pos >= 0)
	    set data([list C  $parent]) [lreplace $data([list C $parent]) $pos $pos]
	    set data([list Mk $parent]) [clock seconds]
	}
	return
    }

    method mtime {key args} {
	if {[llength $args] > 1} {return -code error "wrong\#args"}
	if {![info exists data([list C $key])]} {
	    return -code error "Unknown key \"$key\""
	}
	if {[llength $args]} {
	    set attr  [lindex $args 0]
	    set index [list Ma $key $attr]
	    if {![info exists data($index)]} {
		return -code error "Unknown attribute \"$attr\" in key \"$key\""
	    }
	} else {
	    set index [list Mk $key]
	}
	return $data($index)
    }

    method exists {key args} {
	if {[llength $args] > 1} {return -code error "wrong\#args"}
	if {[llength $args]} {
	    set attr  [lindex $args 0]
	    set index [list Ma $key $attr]
	} else {
	    set index [list Mk $key]
	}
	return [info exist data($index)]
    }

    method get {key attr} {
	if {![info exists data([list C $key])]} {
	    return -code error "Unknown key \"$key\""
	}
	if {![info exists data([list A $key $attr])]} {
	    return -code error "Unknown attribute \"$attr\" in key \"$key\""
	}
	return $data([list A $key $attr])
    }

    method get||default {key attr default} {
	if {[catch {
	    set res $data([list A $key $attr])
	}]} {set res $default}
	return $res
    }

    method keys {key {pattern *}} {
	set res {}
	foreach c $data([list C $key]) {
	    if {![string match $pattern $c]} continue
	    lappend res [linsert $key end $c]
	}
	return $res
    }

    method attrs {key {pattern *}} {
	set res {}
	foreach c [array names data [list A $key $pattern]] {
	    lappend res [lindex $c end]
	}
	return $res
    }

    method set {key args} {
	if {$key != {}} {
	    set parent [lrange $key 0 end-1]
	    if {![info exists data([list C $parent])]} {
		$self set $parent
	    }
	}
	if {![info exist data([list C $key])]} {
	    lappend data([list C $parent]) [lindex $key end]
	    set     data([list C $key]) {}
	    set     data([list Mk $key]) [clock seconds]
	}

	if {![llength $args]} return
	if {[llength $args] != 2} {return -code error "wrong\#args"}
	foreach {attr value} $args break

	set data([list A $key $attr]) $value
	set data([list Ma $key $attr]) [clock seconds]
	return
    }

    # ### state

    variable data -array {}

    # Tree of keys. Each keys can have multiple attributes.
    # Each key, and attribute, have a modification timestamp.

    # (C  key)      -> children (only the tail elements)
    # (Mk key)      -> timestamp

    # (A  key attr) -> value
    # (Ma key attr) -> timestamp

    # ### configure -tie (persistence)

    method TIE {option value} {
	if {[string equal $options(-tie) $value]} return
	tie::untie [myvar data]
	# 8.5 - tie::tie [myvar data] {expand}$value
	eval [linsert $value 0 tie::tie [myvar data]]
	set options(-tie) $value
	return
    }

    method INIT {} {
	set root {C {}}
	set room {Mk {}}
	if {![info exists data($root)]} {
	    set data($root) {}
	    set data($room) [clock seconds]
	}
	return
    }

    # ###
}

##
# ###

package provide pregistry 0.1
