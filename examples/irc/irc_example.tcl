#!/bin/sh
# the next line restarts using tclsh \
	exec tclsh "$0" "$@"

# irc example script, by David N. Welton <davidw@dedasys.com>
# $Id: irc_example.tcl,v 1.3 2002/12/16 08:39:32 davidw Exp $

if { [lindex $argv 0] != "" } {
    set nick [lindex $argv 0]
} else {
    set nick TclIrc
}
set channel \#tcl

if { [catch {package require irc}] } {
    source [file join [file dirname [info script]] \
		.. .. modules irc irc.tcl]
}

proc bgerror { args } {
    puts stderr "Error in irc_example.tcl: $args"
    if { [info exists errorInfo] } {
	puts stderr "errorInfo: $errorInfo"
    }
}

namespace eval client { }

proc client::connect { nick } {
    set cn [::irc::connection irc.openprojects.net 6667]
    set ns [namespace qualifiers $cn]

    $cn registerevent PING {
	network send "PONG [msg]"
	set ::PING 1
    }

    $cn registerevent 376 {
	set ::PING 1
    }

    $cn registerevent defaultcmd {
	puts "[action] [msg]"
    }

    $cn registerevent defaultnumeric {
	puts "[action] XXX [target] XXX [msg]"
    }

    $cn registerevent defaultevent {
	puts "[action] XXX [who] XXX [target] XXX [msg]"
    }

    $cn registerevent PRIVMSG {
	puts "[who] says to [target] [msg]"
    }

    $cn registerevent KICK {
	puts "[who] KICKed [target 1] from [target] : [msg]"
    }

    $cn connect

    $cn user $nick localhost "www.tcl.tk"
    $cn nick $nick

    vwait ::PING
    $cn join $::channel
}

client::connect $nick

vwait forever
