# math.tcl --
#
#	Collection of math functions.
#
# Copyright (c) 1998-2000 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: math.tcl,v 1.1 2000/03/07 23:00:34 ericm Exp $

package provide math 1.0

namespace eval ::math {
}

# ::math::min --
#
#	Return the minimum of two or more values
#
# Arguments:
#	val	first value
#	args	other values
#
# Results:
#	min	minimum value

proc ::math::min {val args} {
    set min $val
    foreach val $args {
	if { $val < $min } {
	    set min $val
	}
    }
    set min
}

# ::math::max --
#
#	Return the maximum of two or more values
#
# Arguments:
#	val	first value
#	args	other values
#
# Results:
#	max	maximum value

proc ::math::max {val args} {
    set max $val
    foreach val $args {
	if { $val > $max } {
	    set max $val
	}
    }
    set max
}

