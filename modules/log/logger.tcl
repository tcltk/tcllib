# logger.tcl --
#
#	Tcl implementation of a general logging facility.
#
# Copyright (c) 2003 by David N. Welton <davidw@dedasys.com>
# See the file license.terms.

# The logger package provides an 'object oriented' log facility that
# lets you have trees of services, that inherit from one another.
# This is accomplished through the use of Tcl namespaces.

package provide logger 0.2
package require Tcl 8.2

namespace eval ::logger {
    namespace eval tree {}
    namespace export init enable disable services

    # The active services.
    set services {}

    # The log 'levels'.
    set levels [list debug info notice warn error critical]
}

# ::logger::walk --
#
#	Walk namespaces, starting in 'start', and evaluate 'code' in
#	them.
#
# Arguments:
#	start - namespace to start in.
#	code - code to execute in namespaces walked.
#
# Side Effects:
#	Side effects of code executed.
#
# Results:
#	None.

proc ::logger::walk { start code } {
    set children [namespace children $start]
    foreach c $children {
	logger::walk $c $code
	namespace eval $c $code
    }
}

proc ::logger::init {service} {
    variable levels
    variable services
    # We create a 'tree' namespace to house all the services, so
    # they are in a 'safe' namespace sandbox, and won't overwrite
    # any commands.
    namespace eval tree::${service} {}

    lappend services $service

    set tree::${service}::service $service
    set tree::${service}::levels $levels

    namespace eval tree::${service} {
	# Defaults to 'debug' level - show everything.  I don't
	# want people to wonder where there debug messages are
	# going.  They can turn it off themselves.
	variable enabled "debug"

	# Callback to use when the service in question is shut down.
	set delcallback {}

	# We use this to disable a service completely.  In Tcl 8.4
	# or greater, by using this, disabled log calls are a
	# no-op!

	proc no-op args {}


	proc stdoutcmd {level text} {
	    variable service
	    puts "\[[clock format [clock seconds]]\] \[$service\] \[$level\] \'$text\'"
	}

	proc stderrcmd {level text} {
	    variable service
	    puts stderr "\[[clock format [clock seconds]]\] \[$service\] \[$level\] \'$text\'"
	}


	# setlevel --
	#
	#	This command differs from enable and disable in that
	#	it disables all the levels below that selected, and
	#	then enables all levels above it, which enable/disable
	#	do not do.
	#
	# Arguments:
	#	lv - the level, as defined in $levels.
	#
	# Side Effects:
	#	Runs disable for the level, and then enable, in order
	#	to ensure that all levels are set correctly.
	#
	# Results:
	#	None.


	proc setlevel {lv} {
	    disable $lv
	    enable $lv
	}

	# enable --
	#
	#	Enable a particular 'level', and above, for the
	#	service, and its 'children'.
	#
	# Arguments:
	#	lv - the level, as defined in $levels.
	#
	# Side Effects:
	#	Enables logging for the particular level, and all
	#	above it (those more important).  It also walks
	#	through all services that are 'children' and enables
	#	them at the same level or above.
	#
	# Results:
	#	None.

	proc enable {lv} {
	    variable levels
	    set lvnum [lsearch -exact $levels $lv]
	    if { $lvnum == -1 } {
		::error "Invalid level '$lv' - levels are $levels"
	    }

	    variable enabled $lv
	    while { $lvnum <  [llength $levels] } {
		interp alias {} [namespace current]::[lindex $levels $lvnum] \
		    {} [namespace current]::[lindex $levels $lvnum]cmd
		incr lvnum
	    }
	    logger::walk [namespace current] [list enable $lv]
	}

	# disable --
	#
	#	Disable a particular 'level', and below, for the
	#	service, and its 'children'.
	#
	# Arguments:
	#	lv - the level, as defined in $levels.
	#
	# Side Effects:
	#	Disables logging for the particular level, and all
	#	below it (those less important).  It also walks
	#	through all services that are 'children' and disables
	#	them at the same level or below.
	#
	# Results:
	#	None.

	proc disable {lv} {
	    variable levels
	    set lvnum [lsearch -exact $levels $lv]
	    if { $lvnum == -1 } {
		::error "Levels are $levels"
	    }

	    # this is the lowest level possible.
	    variable enabled $lv
	    while { $lvnum >= 0 } {
		interp alias {} [namespace current]::[lindex $levels $lvnum] {} \
		    [namespace current]::no-op
		incr lvnum -1
	    }
	    logger::walk [namespace current] [list disable $lv]
	}


	# logproc --
	#
	#	Command used to create a procedure that is executed to
	#	perform the logging.  This could write to disk, out to
	#	the network, or something else.
	#
	# Arguments:
	#	lv - the level to log, which must be one of $levels.
	#	arg - the arg the procedure takes, usually something
	#	like 'txt'.
	#	body - the body of the procedure.
	#
	# Side Effects:
	#	Creates a logging command to take care of the details
	#	of logging an event.
	#
	# Results:
	#	None.

	proc logproc {lv arg body} {
	    variable levels
	    set lvnum [lsearch -exact $levels $lv]
	    if { $lvnum == -1 } {
		::error "Invalid level '$lv' - levels are $levels"
	    }
	    proc ${lv}cmd $arg $body
	}


	# delproc --
	#
	#	Set a callback for when the logger instance is
	#	deleted.
	#
	# Arguments:
	#	cmd - the Tcl command to call.
	#
	# Side Effects:
	#	None.
	#
	# Results:
	#	None.

	proc delproc {cmd} {
	    variable delcallback
	    set delcallback $cmd
	}


	# delete --
	#
	#	Delete the namespace and its children.

	proc delete {} {
	    variable delcallback

	    logger::walk [namespace current] delete
	    catch { uplevel \#0 $delcallback }
	    namespace delete [namespace current]
	}

	# Walk the parent service namespaces to see first, if they
	# exist, and if any are enabled, and then, as a
	# consequence, enable this one
	# too.

	enable $enabled
	set parent [namespace parent]
	while { $parent != "::logger::tree" } {
	    # If the 'enabled' variable doesn't exist, create the
	    # whole thing.
	    if { ! [::info exists ${parent}::enabled] } {
		logger::init [string map {::logger::tree:: ""} $parent]
	    }
	    set enabled [set ${parent}::enabled]
	    enable $enabled
	    set parent [namespace parent $parent]
	}
    }

    # Now create the commands for different levels.

    namespace eval tree::${service} {
	set parent [namespace parent]

	# We 'inherit' the commands from the parents.  This
	# means that, if you want to share the same methods with
	# children, they should be instantiated after the parent's
	# methods have been defined.
	if { $parent != "::logger::tree" } {
	    interp alias {} [namespace current]::debugcmd {} ${parent}::debugcmd
	    interp alias {} [namespace current]::infocmd {} ${parent}::infocmd
	    interp alias {} [namespace current]::noticecmd {} ${parent}::noticecmd
	    interp alias {} [namespace current]::warncmd {} ${parent}::warncmd
	    interp alias {} [namespace current]::errorcmd {} ${parent}::errorcmd
	    interp alias {} [namespace current]::criticalcmd {} ${parent}::criticalcmd
	} else {
	    proc debugcmd {txt} {
		stdoutcmd debug $txt
	    }
	    proc infocmd {txt} {
		stdoutcmd info $txt
	    }
	    proc noticecmd {txt} {
		stdoutcmd notice $txt
	    }
	    proc warncmd {txt} {
		stderrcmd warn $txt
	    }
	    proc errorcmd {txt} {
		stderrcmd error $txt
	    }
	    proc criticalcmd {txt} {
		stderrcmd critical $txt
	    }
	}
    }
    return ::logger::tree::${service}
}

# ::logger::services --
#
#	Returns a list of all active services.
#
# Arguments:
#	None.
#
# Side Effects:
#	None.
#
# Results:
#	List of active services.

proc ::logger::services {} {
    variable services
    return services
}

# ::logger::enable --
#
#	Global enable for a certain level.  NOTE - this implementation
#	isn't terribly effective at the moment, because it might hit
#	children before their parents, who will then walk down the
#	tree attempting to disable the children again.
#
# Arguments:
#	lv - level above which to enable logging.
#
# Side Effects:
#	Enables logging in a given level, and all higher levels.
#
# Results:
#	None.

proc ::logger::enable {lv} {
    variable services
    foreach sv $services {
	::logger::tree::${sv}::enable $lv
    }
}

proc ::logger::disable {lv} {
    variable services
    foreach sv $services {
	::logger::tree::${sv}::disable $lv
    }
}
