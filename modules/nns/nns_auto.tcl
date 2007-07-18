# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Client side connection monitor

# ### ### ### ######### ######### #########
## Requirements

package require nameserv ; # Name service client-side core
package require uevent   ; # Watch for connection-loss

namespace eval ::nameserv::auto {}

# ### ### ### ######### ######### #########
## API: Write, Read, Search

## TODO - Keep after handle, ensure that only one poll is running.
## Factor into smaller commands with descriptive names ... We have
## several near-replicated pieces of code (error handling).

proc ::nameserv::auto::bind {name data} {
    # See nameserv::bind. Remembers the information, for re-binding
    # when the connection was lost, and later restored.

    variable bindings
    variable delay

    # Watch base client for loss of connection.
    uevent::bind nameserv lost-connection ::nameserv::auto::Reconnect

    if {[catch {
	nameserv::bind $name $data
    } msg]} {
	if {[string match *No name server*]} {
	    # No nameserver. Remember, and start reconnect polling.
	    set bindings($name) $data
	    after $delay ::nameserv::auto::Reconnect
	    return
	}
	# Name is bound already, lost immediately, generate
	# standard event.

	uevent::generate nameserv lost-name [list name $name data $data]
	return
    }

    # Success. Remember for possible loss of connection.
    set bindings($name) $data
    return
}

proc ::nameserv::auto::Reconnect {args} {
    # args = <>|<tags event details>
    # <tag,event> = <'nameserv','lost'>
    #     details = dict ('reason' -> string)

    if {![catch {
	::nameserv::server_features
    }]} {Rebind ; return}

    variable delay
    after   $delay ::nameserv::auto::Reconnect
    return
}

proc ::nameserv::auto::Rebind {} {
    variable bindings

    foreach {name data} [array get bindings] {
	if {[catch {
	    nameserv::bind $name $data
	} msg]} {
	    # Lost server while rebinding names. Abort and wait for
	    # the reconnect to try again.
	    if {[string match *No name server*]} break

	    # Other error => (name already bound) That means someone
	    # else took the name while we were not connected to the
	    # service. Best effort we can do: Deliver total loss of
	    # this binding to observers via event.

	    uevent::generate nameserv lost-name [list name $name data $data]
	}
    }
    return
}

# ### ### ### ######### ######### #########
## Initialization - System state

namespace eval ::nameserv::auto {
    # In-memory database of bindings to restore after connection was
    # lost and restored.

    variable bindings ; array set bindings {}
}

# ### ### ### ######### ######### #########
## API: Configuration management (host, port)

proc ::nameserv::auto::cget {option} {
    return [configure $option]
}

proc ::nameserv::auto::configure {args} {
    variable delay

    if {![llength $args]} {
	return [list -delay $delay]
    }
    if {[llength $args] == 1} {
	# cget
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -delay { return $delay }
	    default {
		return -code error "bad option \"$opt\", expected -delay"
	    }
	}
    }

    while {[llength $args]} {
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -delay {
		if {[llength $args] % 2 == 1} {
		    return -code error "value for \"$opt\" is missing"
		}
		# TODO: check integer > 0
		set delay [lindex $args 1]
		set args  [lrange $args 2 end]
	    }
	    default {
		return -code error "bad option \"$opt\", expected -delay"
	    }
	}
    }
    return
}

# ### ### ### ######### ######### #########
## Initialization - Tracing, Configuration

logger::initNamespace ::nameserv::auto
namespace eval        ::nameserv::auto {
    # Interval between reconnection attempts when connection was lost.

    variable delay 1000 ; # One second
}

# ### ### ### ######### ######### #########
## Ready

package provide nameserv::auto 0.1

##
# ### ### ### ######### ######### #########
