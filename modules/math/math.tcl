# math.tcl --
#
#	Collection of math functions.
#
# Copyright (c) 1998-2000 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: math.tcl,v 1.2 2000/03/28 02:28:25 ericm Exp $

package provide math 1.0

namespace eval ::math {
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

# ::math::mean --
#
#	Return the mean of two or more values
#
# Arguments:
#	val	first value
#	args	other values
#
# Results:
#	mean	arithmetic mean value

proc ::math::mean {val args} {
    set sum $val
    set N [ expr { [ llength $args ] + 1 } ]
    foreach val $args {
        set sum [ expr { $sum + $val } ]
    }
    set mean [expr { double($sum) / $N }]
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

# ::math::product --
#
#	Return the product of one or more values
#
# Arguments:
#	val	first value
#	args	other values
#
# Results:
#	prod	 product of multiplying all values in the list

proc ::math::product {val args} {
    set prod $val
    foreach val $args {
        set prod [ expr { $prod*$val } ]
    }
    set prod
}

# ::math::sum --
#
#	Return the sum of one or more values
#
# Arguments:
#	val	first value
#	args	all other values
#
# Results:
#	sum	arithmetic sum of all values in args

proc ::math::sum {val args} {
    set sum $val
    foreach val $args {
        set sum [ expr { $sum+$val } ]
    }
    set sum
}

