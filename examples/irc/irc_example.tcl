#!/bin/sh
# the next line restarts using tclsh \
	exec tclsh "$0" "$@"

# irc example script, by David N. Welton <davidw@dedasys.com>
# $Id: irc_example.tcl,v 1.4 2003/01/31 02:52:49 davidw Exp $

# Pick up a nick from the command line, or default to TclIrc.

if { [lindex $argv 0] != "" } {
    set nick [lindex $argv 0]
} else {
    set nick TclIrc
}

# I include these so that it can find both the irc package and the
# logger package that irc needs.

set auto_path "[file join [file dirname [info script]] .. .. modules irc] $auto_path"
set auto_path "[file join [file dirname [info script]] .. .. modules log] $auto_path"
package require irc 0.3

namespace eval client {
    variable channel \#tcl
}

proc client::connect { nick } {
    variable channel
    set cn [::irc::connection irc.freenode.net 6667]
    set ns [namespace qualifiers $cn]

    # Register an event for the PING command that comes from the
    # server.
    $cn registerevent PING {
	network send "PONG [msg]"
	set ::PING 1
    }


    $cn registerevent 376 {
	set ::PING 1
    }

    # Register a default action for commands from the server.
    $cn registerevent defaultcmd {
	puts "[action] [msg]"
    }

    # Register a default action for numeric events from the server.
    $cn registerevent defaultnumeric {
	puts "[action] XXX [target] XXX [msg]"
    }

    # Register a default action for events.
    $cn registerevent defaultevent {
	puts "[action] XXX [who] XXX [target] XXX [msg]"
    }

    # Register a default action for PRIVMSG (either public or to a
    # channel).
    $cn registerevent PRIVMSG {
	puts "[who] says to [target] [msg]"
    }

    $cn registerevent KICK {
	puts "[who] KICKed [target 1] from [target] : [msg]"
    }

    # Connect to the server.
    $cn connect
    $cn user $nick localhost "www.tcl.tk"
    $cn nick $nick
    $cn join $channel

    vwait ::PING
    $cn join $channel
}

# Start things in motion.
client::connect $nick
vwait forever
