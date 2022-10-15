## -*- tcl -*-
# ### ### ### ######### ######### #########
##
## Common information for slippy based maps. I.e. tile size, relationship between zoom level and map
## size, etc.
##
## See
##	http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Pseudo-Code
##
## for the coordinate conversions and other information.

#
# Management code for switching between Tcl and C accelerated implementations.
#
# @mdgen EXCLUDE: map_slippy_c.tcl
#

package require Tcl 8.6
namespace eval ::map::slippy {}

# ### ### ### ######### ######### #########
## Management of map::slippy std implementations.

# ::map::slippy::LoadAccelerator --
#
#	Loads a named implementation, if possible.
#
# Arguments:
#	key	Name of the implementation to load.
#
# Results:
#	A boolean flag. True if the implementation was successfully loaded; and False otherwise.

proc ::map::slippy::LoadAccelerator {key} {
    variable accel
    set isok 0
    switch -exact -- $key {
	critcl {
	    # Critcl implementation of map::slippy requires Tcl 8.6.
	    if {![package vsatisfies [package provide Tcl] 8.6]} {return 0}
	    if {[catch {package require tcllibc}]} { return 0 }
	    set isok [llength [info commands ::map::slippy::critcl_tiles]]
	}
	tcl {
	    variable selfdir
	    if {[catch {source [file join $selfdir map_slippy_tcl.tcl]}]} {return 0}
	    set isok [llength [info commands ::map::slippy::tcl_tiles]]
	}
        default {
            return -code error "invalid accelerator $key:\
                must be one of [join [KnownImplementations] {, }]"
        }
    }
    set accel($key) $isok
    return $isok
}

# ::map::slippy::SwitchTo --
#
#	Activates a loaded named implementation.
#
# Arguments:
#	key	Name of the implementation to activate.
#
# Results:
#	None.

proc ::map::slippy::SwitchTo {key} {
    variable accel
    variable loaded

    if {$key eq $loaded} {
	# No change, nothing to do.
	return
    } elseif {$key ne {}} {
	# Validate the target implementation of the switch.

	if {![info exists accel($key)]} {
	    return -code error "Unable to activate unknown implementation \"$key\""
	} elseif {![info exists accel($key)] || !$accel($key)} {
	    return -code error "Unable to activate missing implementation \"$key\""
	}
    }

    set cmdmap {
        fit_geobox   fit::geobox
	geo_distance geo::distance
        geo_2point   geo::2point
        geo_2points  geo::2points
        geo_2tile    geo::2tile
        geo_2tilef   geo::2tile.float
        length       length
        point_2geo   point::2geo
        point_2tile  point::2tile
        tile_2geo    tile::2geo
        tile_2point  tile::2point
        tile_size    tile::size
        tile_valid   tile::valid
        tiles        tiles
    }

    # Deactivate the previous implementation, if there was any.

    if {$loaded ne {}} {
	foreach {origin c} $cmdmap {
	    rename ::map::slippy::$c ::map::slippy::${loaded}_$origin
	}
    }

    # Activate the new implementation, if there is any.

    if {$key ne {}} {
	foreach {origin c} $cmdmap {
	    rename ::map::slippy::${key}_$origin ::map::slippy::$c
	}
    }

    # Remember the active implementation, for deactivation by future switches.

    set loaded $key
    return
}

# ::map::slippy::Implementations --
#
#	Determines which implementations are present, i.e. loaded.
#
# Arguments:
#	None.
#
# Results:
#	A list of implementation keys.

proc ::map::slippy::Implementations {} {
    variable accel
    set res {}
    foreach n [array names accel] {
	if {!$accel($n)} continue
	lappend res $n
    }
    return $res
}

# ::map::slippy::KnownImplementations --
#
#	Determines which implementations are known as possible implementations.
#
# Arguments:
#	None.
#
# Results:
#	A list of implementation keys. In the order of preference, most prefered first.

proc ::map::slippy::KnownImplementations {} {
    return {critcl tcl}
}

proc ::map::slippy::Names {} {
    return {
	critcl {tcllibc based}
	tcl    {pure Tcl}
    }
}

# ### ### ### ######### ######### #########
## Initialization: Data structures.

namespace eval ::map::slippy {
    variable  selfdir [file dirname [info script]]
    variable  loaded  {}

    variable  accel
    array set accel {tcl 0 critcl 0}
}

# ### ### ### ######### ######### #########
## Initialization. Ensemble

namespace eval ::map {
    namespace export slippy
    namespace ensemble create
}
namespace eval ::map::slippy {
    namespace export fit geo length point tile tiles
    namespace ensemble create
}
namespace eval ::map::slippy::tile {
    namespace export 2geo 2point size valid
    namespace ensemble create
}
namespace eval ::map::slippy::geo {
    namespace export distance 2point 2points 2tile 2tile.float
    namespace ensemble create
}
namespace eval ::map::slippy::point {
    namespace export 2geo 2tile
    namespace ensemble create
}
namespace eval ::map::slippy::fit {
    namespace export geobox
    namespace ensemble create
}

# ### ### ### ######### ######### #########
## Initialization: Choose an implementation, most prefered first.
## Loads only one of the possible implementations and activates it.

apply {{} {
    foreach e [KnownImplementations] {
	if {[LoadAccelerator $e]} {
	    SwitchTo $e
	    break
	}
    }
} ::map::slippy}

# ### ### ### ######### ######### #########
## Ready

package provide map::slippy 0.7
