## -*- tcl -*-
# ### ### ### ######### ######### #########

# @@ Meta Begin
# Package uevent::onidle 1.0
#
# Meta platform    tcl
# Meta description Request actions to be done at the next idle-cycle
# Meta description 
# Meta subject     idle event
# Meta require     {Tcl 8.5}
# Meta require     snit
#
# # --- --- --- --------- --------- ---------
# Meta ak::api::desc  The class in this module provides generic
# Meta ak::api::desc  objects which can merge a series of requests
# Meta ak::api::desc  for an action into a single execution of the
# Meta ak::api::desc  action the next time Tcl's event queue is idle.
#
# # --- --- --- --------- --------- ---------
# @@ Meta End

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4 ; #
package require snit    ; # 

# ### ### ### ######### ######### #########
##

snit::type uevent::onidle {
    # ### ### ### ######### ######### #########
    ## API 

    constructor {cmd} {
	set mycmd $cmd
	return
    }

    method request {} {
	if {$myhasrequest} return
	after idle [mymethod RunAction]
	set myhasrequest 1
	return
    }

    # ### ### ### ######### ######### #########
    ## Internal commands

    method RunAction {} {
	set myhasrequest 0
	uplevel \#0 $mycmd
	return
    }

    # ### ### ### ######### ######### #########
    ## State

    variable mycmd        {} ; # Command prefix of action to perform
    variable myhasrequest 0  ; # Boolean flag, set when the action has been requested

    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide uevent::onidle 0.1
