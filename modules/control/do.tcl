# do.tcl --
#
#        Tcl implementation of a "do ... while|until" loop.
#
# Originally written for the "Texas Tcl Shootout" programming contest
# at the 2000 Tcl Conference in Austin/Texas.
#
# Copyright (c) 2001 by Reinhard Max <Reinhard.Max@gmx.de>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: do.tcl,v 1.5.2.2 2005/05/24 19:19:09 dgp Exp $
#
namespace eval ::control {
    variable ReturnOptions [package vsatisfies [package provide Tcl] 8.5]

    proc do {body args} {
	variable ReturnOptions
	variable DoResult
	variable DoOptions

	#
	# Implements a "do body while|until test" loop
	# 
	# It is almost as fast as builtin "while" command for loops with
	# more than just a few iterations.
	#

	set proc [lindex [info level 0] 0]
	set len [llength $args]
	if {$len !=2 && $len != 0} {
	    return -code error "wrong # args: should be \"$proc body\" or \"$proc body \[until|while\] test\""
	}
	set test 0
	foreach {whileOrUntil test} $args {
	    switch -exact -- $whileOrUntil {
		"while" {}
		"until" { set test !($test) }
		default {
		    return -code error \
			"bad option \"$whileOrUntil\": must be until, or while"
		}
	    }
	    break
	}

	# the first invocation of the body
	if {$ReturnOptions} {
	    set code [uplevel 1 [list ::catch $body \
		    [namespace which -variable DoResult] \
		    [namespace which -variable DoOptions]]]
	} else {
	    set code [catch { uplevel 1 $body } DoResult]
	}

	# decide what to do upon the return code:
	#               0 - the body executed successfully
	#               1 - the body raised an error
	#               2 - the body invoked [return]
	#               3 - the body invoked [break]
	#               4 - the body invoked [continue]
	# everything else - return and pass on the results
	#
	switch -exact -- $code {
	    0 {}
	    1 {
		if {$ReturnOptions} {
		    set line [dict get $DoOptions -errorline]
		    dict append DoOptions -errorinfo \
			    "\n    (\"$proc\" body line $line)"
		    dict incr DoOptions -level
		    return -options $DoOptions $DoResult
		} else {
		    return -errorinfo [ErrorInfoAsCaller uplevel do]  \
			    -errorcode $::errorCode -code error $DoResult
		}
	    }
	    2 {
		if {$ReturnOptions} {
		    dict incr DoOptions -level
		    return -options $DoOptions $DoResult
		} else {
		    return -code $code $DoResult
		}
	    }
	    3 {
		# FRINK: nocheck
		return
	    }
	    4 {}
	    default {
		return -code $code $DoResult
	    }
	}
	# the rest of the loop
	if {$ReturnOptions} {
	    set code [uplevel 1 [list ::catch [list ::while $test $body] \
		    [namespace which -variable DoResult] \
		    [namespace which -variable DoOptions]]]
	} else {
	    set code [catch { uplevel 1 [list ::while $test $body] } DoResult]
	}
	if {$code == 1} {
	    if {$ReturnOptions} {
		set line [dict get $DoOptions -errorline]
		dict append DoOptions -errorinfo \
			"\n    (\"$proc\" body line $line)"
		dict incr DoOptions -level
		return -options $DoOptions $DoResult
	    } else {
		return -errorinfo [ErrorInfoAsCaller while do]  \
			-errorcode $::errorCode -code error $DoResult
	    }
	}
	if {$ReturnOptions && $code} {
	    dict incr DoOptions -level
	    return -options $DoOptions $DoResult
	}
	return -code $code $DoResult
	
    }

}
