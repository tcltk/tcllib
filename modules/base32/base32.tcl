# -*- tcl -*-
# This code is hereby put into the public domain.
# ### ### ### ######### ######### #########
## Overview
# Base32 encoding and decoding of small strings.
#
# Management code for switching between Tcl and C accelerated
# implementations.

# @mdgen EXCLUDE: base32_c.tcl

package require Tcl 8.5 9

namespace eval ::base32 {}

# ### ### ### ######### ######### #########
## Management of base32 std implementations.

# ::base32::LoadAccelerator --
#
#	Loads a named implementation, if possible.
#
# Arguments:
#	key	Name of the implementation to load.
#
# Results:
#	A boolean flag. True if the implementation
#	was successfully loaded; and False otherwise.

proc ::base32::LoadAccelerator {key} {
    variable accel
    set isok 0
    switch -exact -- $key {
	critcl {
	    # Critcl implementation of base32 requires Tcl 8.4.
	    if {![package vsatisfies [package provide Tcl] 8.4]} {return 0}
	    if {[catch {package require tcllibc}]} {return 0}
	    set isok [llength [info commands ::base32::critcl_encode]]
	}
	tcl {
	    variable selfdir
	    if {[catch {source [file join $selfdir base32_tcl.tcl]}]} {return 0}
	    set isok [llength [info commands ::base32::tcl_encode]]
	}
        default {
            return -code error "invalid accelerator $key:\
                must be one of [join [KnownImplementations] {, }]"
        }
    }
    set accel($key) $isok
    return $isok
}

# ::base32::SwitchTo --
#
#	Activates a loaded named implementation.
#
# Arguments:
#	key	Name of the implementation to activate.
#
# Results:
#	None.

proc ::base32::SwitchTo {key} {
    variable accel
    variable loaded

    if {[string equal $key $loaded]} {
	# No change, nothing to do.
	return
    } elseif {![string equal $key ""]} {
	# Validate the target implementation of the switch.

	if {![info exists accel($key)]} {
	    return -code error "Unable to activate unknown implementation \"$key\""
	} elseif {![info exists accel($key)] || !$accel($key)} {
	    return -code error "Unable to activate missing implementation \"$key\""
	}
    }

    # Deactivate the previous implementation, if there was any.

    if {![string equal $loaded ""]} {
	foreach c {encode decode} {
	    rename ::base32::$c ::base32::${loaded}_$c
	}
    }

    # Activate the new implementation, if there is any.

    if {![string equal $key ""]} {
	foreach c {encode decode} {
	    rename ::base32::${key}_$c ::base32::$c
	}
    }

    # Remember the active implementation, for deactivation by future
    # switches.

    set loaded $key
    return
}

# ::base32::Implementations --
#
#	Determines which implementations are
#	present, i.e. loaded.
#
# Arguments:
#	None.
#
# Results:
#	A list of implementation keys.

proc ::base32::Implementations {} {
    variable accel
    set res {}
    foreach n [array names accel] {
	if {!$accel($n)} continue
	lappend res $n
    }
    return $res
}

# ::base32::KnownImplementations --
#
#	Determines which implementations are known
#	as possible implementations.
#
# Arguments:
#	None.
#
# Results:
#	A list of implementation keys. In the order
#	of preference, most prefered first.

proc ::base32::KnownImplementations {} {
    return {critcl tcl}
}

proc ::base32::Names {} {
    return {
	critcl {tcllibc based}
	tcl    {pure Tcl}
    }
}

# ### ### ### ######### ######### #########
## Initialization: Data structures.

namespace eval ::base32 {
    variable  selfdir [file dirname [info script]]
    variable  loaded  {}

    variable  accel
    array set accel   {tcl 0 critcl 0}
}

# ### ### ### ######### ######### #########
## Initialization: Choose an implementation,
## most prefered first. Loads only one of the
## possible implementations. And activates it.

namespace eval ::base32 {
    variable e
    foreach e [KnownImplementations] {
	if {[LoadAccelerator $e]} {
	    SwitchTo $e
	    break
	}
    }
    unset e

    namespace export encode decode
}

# ### ### ### ######### ######### #########
## Ready

package provide base32 0.2
