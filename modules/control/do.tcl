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
# RCS: @(#) $Id: do.tcl,v 1.1 2001/11/07 10:40:01 rmax Exp $
#
namespace eval ::control {

    proc do {body whileOrUntil test} {

	#
	# Implements a "do body while|until test" loop
	# 
	# It is almost as fast as builtin "while" command for loops with
	# more than just a few iterations.
	#
	
	switch -exact -- $whileOrUntil {

	    "while" {}
	    "until" { set test !($test) }
	    default {
		return -code error \
		    "bad option \"$whileOrUntil\": must be until, or while"
	    }
	}
	# the first invocation of the body
	set code [catch { uplevel $body } result]

	# decide what to do uppon the return code:
	#
	#               0 - the body executed successfully
	#               3 - the body invoked [return]
	#               4 - the body invoked [continue]
	# everything else - return and pass on the results
	switch $code {
	    0 {}
	    3 return
	    4 {}
	    default { return -code $code $result }
	}
	# the rest of the loop
	set code [catch {uplevel 1 [list while $test $body] } result]
	return -code $code $result
    }
}