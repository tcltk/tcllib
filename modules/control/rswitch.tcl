# rswitch.tcl - 
#	Originally written: 	2001 Nov 2
#	Original author:	Don Porter <dgp@users.sourceforge.net>
#
#	This software was developed at the National Institute of Standards
#	and Technology by employees of the Federal Government in the course
#	of their official duties. Pursuant to title 17 Section 105 of the
#	United States Code this software is not subject to copyright
#	protection and is in the public domain. 
#
#       The [rswitch] command of the package "control".
#	Inspired by TIP 70.  Amended to the syntax:
#
# 		rswitch $formatString {
#		    $sub1 $body1
#		    ...
#		    $subN $bodyN
#		}
#
#	See documentation in control.n
# -------------------------------------------------------------------------
#
# RCS: @(#) $Id: rswitch.tcl,v 1.3 2001/11/07 21:59:24 dgp Exp $

namespace eval ::control {

    namespace export rswitch

    proc rswitch {formatString actionList} {
	if {[catch {llength $actionList} actionListLength]} {
	    return -code error $actionListLength
	}
	if {$actionListLength % 2} {
	    return -code error "extra substitution with no body"
	}
	# Check for final "default" arm
	set hasDefault [string equal default [lindex $actionList end-1]]
	if {$hasDefault} {
	    set defaultBody [lindex $actionList end]
	    set actionList [lrange $actionList 0 end-2]
	}
	set evalBody 0
	foreach {sub body} $actionList {
	    if {!$evalBody} {
		if {[catch {linsert $sub 0 ::format $formatString} cmd]} {
		    return -code error -errorinfo "$cmd\n    (\"$sub\"\
		        arm substitution)" -errorcode $::errorCode $cmd
		}
		if {[catch {eval $cmd} expression]} {
		    return -code error -errorcode $::errorCode -errorinfo \
			    "$expression\n    (\"$sub\" arm substitution)" \
			    $expression
		}
		set cmd [list ::expr $expression]
		eval [CommandAsCaller cmd evalBody [format "%s\n%s" \
			{\"$sub\" arm expression)} \
			{    (expression: \"$expression\"}]]
		if {![string is boolean -strict $evalBody]} {
		    set msg "non-boolean expression"
		    return -code error -errorcode $::errorCode -errorinfo \
			    [format "%s\n%s\n%s" $msg \
			    "    (\"$sub\" arm expression)" \
			    "    (expression: \"$expression\")"] $msg
		}
		if {!$evalBody} {
		    continue
		}
		set match $sub
	    }
	    # We've found a successful expression.
	    # Evaluate the corresponding body.
	    if {[string equal - $body]} {
		continue
	    }
	    eval [BodyAsCaller body result code {\"$match\" arm}]
	    return -code $code $result
	}
	if {!$hasDefault && !$evalBody} {
	    return
	}
	if {!$evalBody} {
	    set match default
	}
	if {!$hasDefault || [string equal - $defaultBody]} {
	    return -code error \
		"no body specified for substitution \"$match\""
	}
	eval [BodyAsCaller defaultBody result code {\"$match\" arm}]
	return -code $code $result
    }

}
