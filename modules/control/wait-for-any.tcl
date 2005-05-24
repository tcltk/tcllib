# control.tcl --
#
#       The control package, providing a vwait that takes multiple
#       variables.
#
# Taken from the tcler's wiki (http://mini.net/tcl/1302.html) by kenstir
# and enhanced.  Submitted as a proposed new package to
# tcllib.sourceforge.net on 7/30/01.
#
# Original author: Donald Porter.  BBH added the timeout option.  Kenstir
# added the return value to detect what variables changed, the packaging,
# standard formatting, and the help text.
#
# TODO
#       * Write control::unwindProtect.  I've always wanted one.
#         --7/30/01 kenstir
#
# $Id: wait-for-any.tcl,v 1.1.2.1 2005/05/24 15:08:51 dgp Exp $

namespace eval control {
    variable WaitForAnyKey 0
}

# control::waitForAny --
#
#       Like [vwait], but takes multiple variables and/or optional
#       timeout.  Allows you to detect which variable or variables got set
#       during the vwait.
#
# Usage:
#       waitForAny ?timeout? variable ?variable ...?
#
# Arguments:
#       timeout  - If the first argument is an integer, it specifies a
#                  timeout.  If the timeout expires, waitForAny returns
#                  "timeout".
#       variable - One or more fully scoped variable names.  A change to
#                  any of these variables will cause waitForAny to
#                  return.
#
# Returns:
#       A list of the variables that got set, or the string "timeout" to
#       indicate that the timeout expired without any variables being
#       set.
#
proc control::waitForAny {args} {
    variable WaitForAnyArray
    variable WaitForAnyKey

    # If first arg is a number, it specifies the timeout.
    if {[string is integer [lindex $args 0]]} {
        set timeout [lindex $args 0]
        set args [lrange $args 1 end]
    }

    # Create a trigger script that will be cause vwait to return.  The
    # [lappend] command is used here to capture all args appended by
    # [trace].
    set index Key[incr WaitForAnyKey]
    set trigger [namespace code [list lappend WaitForAnyArray($index)]]

    # Create the traces.
    # Note that we use [concat $trigger $var] to make sure the trace gets
    # called with the original name of the variable.  Otherwise, the use
    # of an upvar'd alias could prevent us from knowing which variable got
    # set.
    foreach var $args {
        uplevel \#0 [list trace variable $var w [concat $trigger $var]]
    }

    # Set timer if user requested a timeout.
    if {[info exists timeout]} {
        set timerId [after $timeout $trigger]
    }
    vwait [namespace which -variable WaitForAnyArray]($index)

    # Figure out which triggers fired during the vwait.
    set ret {}
    if {[info exists WaitForAnyArray($index)]} {
        # Looks like a variable or variables got set.  But, we aren't
        # sure yet; the list can be empty.  The format of this list is
        # determined by the trace command.
        foreach {vwaitName name1 name2 op} $WaitForAnyArray($index) {
            # Avoid duplicates.  Sometimes the trace gets invoked
            # multiple times.  I would use [lsort -unique], but I have to
            # support tcl8.2.3 for now.
            if {[lsearch -exact $ret $vwaitName] == -1} {
                lappend ret $vwaitName
            }
        }
    }
    if {[llength $ret] == 0} {
        # No variables got set.  We timed out.
        set ret timeout
    }

    # Remove all traces.
    foreach var $args {
        uplevel \#0 [list trace vdelete $var w [concat $trigger $var]]
    }

    # Cancel the timer.
    if {[info exists timerId]} {
        after cancel $timerId
    }

    # Cleanup.
    unset WaitForAnyArray($index)

    return $ret
}

# Local Variables:
# tcl-indent-level:4
# End:
