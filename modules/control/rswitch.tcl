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
#       See TIP 70 for a description.
#
# -------------------------------------------------------------------------
#
# Inserted from a usenet post comp.lang.tcl:156140
#
# Don Porter wrote:
# > Rather than defining two forms of the command, mono-conditional
# > and bi-conditional, why not use the power of Tcl to allow for both
# > and even more possibilities within a single form?
# > 
# > rswitch $formatString {
# >     $sub1 $body1
# >     ...
# >     $subN $bodyN
# > }
#
# Here's an implementation of that alternative.  It's suitable for
# dropping into tcllib's control package, or it can just be 
# [source]d directly.
#
# Apologies about the complexity and lack of comments in the support
# routines.  Comments will be added, but getting the processing of
# ::errorInfo right just requires that much complexity.  It's just
# that big of a mess.
#
# -------------------------------------------------------------------------
#
# RCS: @(#) $Id: rswitch.tcl,v 1.2 2001/11/03 04:10:42 dgp Exp $

namespace eval ::control {

    namespace export rswitch

    proc CommandAsCaller {cmdVar resultVar {where {}} {codeVar code}} {
	set x [expr {[string equal "" $where] 
		? {} : [subst -nobackslashes {\n    ($where)}]}]
	set script [subst -nobackslashes -nocommands {
	    set $codeVar [catch {uplevel 1 $$cmdVar} $resultVar]
	    if {$$codeVar > 1} {
		return -code $$codeVar $$resultVar
	    }
	    if {$$codeVar == 1} {
		if {[string equal {"uplevel 1 $$cmdVar"} \
			[lindex [split [set ::errorInfo] \n] end]]} {
		    set $codeVar [join \
			    [lrange [split [set ::errorInfo] \n] 0 \
			    end-[expr {4+[llength [split $$cmdVar \n]]}]] \n]
		} else {
		    set $codeVar [join \
			    [lrange [split [set ::errorInfo] \n] 0 end-1] \n]
		}
		return -code error -errorcode [set ::errorCode] \
			-errorinfo "$$codeVar$x" $$resultVar
	    }
	}]
	return $script
    }

    proc BodyAsCaller {bodyVar resultVar codeVar {where {}}} {
	set x [expr {[string equal "" $where]
		? {} : [subst -nobackslashes -nocommands \
		{\n    ($where[string map {{    ("uplevel"} {}} \
		[lindex [split [set ::errorInfo] \n] end]]}]}]
	set script [subst -nobackslashes -nocommands {
	    set $codeVar [catch {uplevel 1 $$bodyVar} $resultVar]
	    if {$$codeVar == 1} {
		if {[string equal {"uplevel 1 $$bodyVar"} \
			[lindex [split [set ::errorInfo] \n] end]]} {
		    set ::errorInfo [join \
			    [lrange [split [set ::errorInfo] \n] 0 end-2] \n]
		} 
		set $codeVar [join \
			[lrange [split [set ::errorInfo] \n] 0 end-1] \n]
		return -code error -errorcode [set ::errorCode] \
			-errorinfo "$$codeVar$x" $$resultVar
	    }
	}]
	return $script
    }

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
