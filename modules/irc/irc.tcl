# irc.tcl --
#
#	irc implementation for Tcl.
#
# Copyright (c) 2001 by David N. Welton <davidw@dedasys.com>.
# This code may be distributed under the same terms as Tcl.
#
# $Id: irc.tcl,v 1.5 2003/01/03 02:52:16 davidw Exp $

package provide irc 0.3

package require logger

namespace eval irc {
    variable conn

    # configuration information
    set config(debug) 0
    set log [logger::init irc]

    # counter used to differentiate connections
    set conn 0
}

# irc::config --
#
# Set configuration options
#
# Arguments:
#
# key	name of the configuration option to change.
#
# value	value of the configuration option.

proc irc::config { key value } {
    variable config
    if { $key == "debug" } {
	if { $value > 0 } {
	    ${irc::log}::enable debug
	} else {
	    ${irc::log}::disable notice
	}
    }
    set config($key) $value
}

# irc::connection --

# Create an IRC connection namespace and associated commands.  Do not
# actually make the socket.

# Arguments:

# host	hostname to connect to

# port	port to use - usually 6667

proc irc::connection { host {port 6667} } {
    variable conn
    variable config

    # Create a unique namespace of the form irc$conn::$host

    set name [format "%s::irc%s::%s" [namespace current] $conn $host]

    namespace eval $name {}

    # FRINK: nocheck
    set ${name}::conn $conn
    # FRINK: nocheck
    set ${name}::port $port
    # FRINK: nocheck
    set ${name}::host $host

    namespace eval $name {
	set nick ""
	set state 0
	array set dispatch {}
	set sock {}
	array set linedata {}
	# ircsend --
	# send text to the IRC server

	proc ircsend { msg } {
	    variable sock
	    ${irc::log}::debug "ircsend: '$msg'"
	    if { [catch {puts $sock "$msg"} err] } {
		${irc::log}::error "Error in ircsend: $err"
	    }
	}

	# implemented user-side commands, meaning that these commands
	# cause the calling user to perform the given action.

	proc User { username hostname userinfo } {
	    ircsend "USER $username $hostname $username :$userinfo"
	}

	proc Nick { nk } {
	    variable nick
	    set nick $nk
	    ircsend "NICK $nk"
	}

	proc Ping { } {
	    ircsend "PING: [clock seconds]"
	}

	proc Join { chan } {
	    ircsend "JOIN $chan "
	}

	proc Part { chan } {
	    ircsend "PART $chan"
	}

	proc Privmsg { target msg } {
	    ircsend "PRIVMSG $target :$msg"
	}

	# Connect --
	# Create the actual connection.

	proc Connect { } {
	    variable state
	    variable sock
	    variable host
	    variable conn
	    variable port
	    if { $state == 0 } {
		catch {
		    set sock [socket $host $port]
		}
		if { ! [info exists sock] } {
		    return -1
		}
		set state 1
		fconfigure $sock -translation crlf
		fconfigure $sock -buffering line
		fileevent $sock readable [format "::irc::irc%s::%s::GetEvent" $conn $host ]
	    }
	    return 0
	}

	# Callback API:

	# These are all available from within callbacks, so as to
	# provide an interface to provide some information on what is
	# coming out of the server.

	# action --

	# action returns the action performed, such as KICK, PRIVMSG,
	# MODE etc...

	proc action { } {
	    variable linedata
	    return $linedata(action)
	}

	# msg --

	# the rest of the line, even if there is more than one target.

	proc msg { } {
	    variable linedata
	    return $linedata(msg)
	}

	# who --

	# who performed the action.  If the command is called as [who
	# address], it returns the information in the form
	# username@ip.address.net

	proc who { {address 0} } {
	    variable linedata
	    set who $linedata(who)
	    if { $address == 0 } {
		return [string range $who 0 [expr {[string first ! $who] - 1}]]
	    } else {
		return [string range $who [expr {[string last ! $who] + 1}] end]
	    }
	}

	# target --

	# to whom was this action done.

	# index specifies which target number it is, if there are more
	# than one (MODE and KICK commands, for instance).

	proc target { {index 0} } {
	    variable linedata
	    return [lindex $linedata(target) $index]
	}

	# DispatchNumeric --
	# Dispatch a numeric event that arrives from the server

	proc DispatchNumeric { } {
	    variable dispatch
	    variable linedata
	    if { [info exists dispatch($linedata(action))] } {
		eval $dispatch($linedata(action))
	    } else {
		eval $dispatch(defaultnumeric)
	    }
	}

	# DispatchServerEvent --
	# Dispatch event from server

	proc DispatchServerEvent { line } {
	    variable dispatch
	    variable linedata
	    set splitline [split $line]
	    set linedata(who) [lindex $splitline 0]
	    set linedata(action) [lindex $splitline 1]
	    set linedata(target) {}
	    set linedata(msg) {}

	    set i 2
	    while { $i <= [llength $splitline] } {
		set tg [lindex $splitline $i]
		if { [string index $tg 0] == ":" } {
		    set linedata(msg) [string range [lrange $splitline $i end] 1 end]
		    break
		}
		lappend linedata(target) $tg
		incr i
	    }

	    if { [string is integer $linedata(action)] } {
		return [DispatchNumeric]
	    }

	    if { [info exists dispatch($linedata(action))] } {
		return [eval $dispatch($linedata(action))]
	    } else {
		return [eval $dispatch(defaultevent)]
	    }
	}

	# DispatchServerCmd --

	# Dispatch command from server

	proc DispatchServerCmd { line } {
	    variable dispatch
	    variable linedata
	    set splt [string first : $line]
	    set linedata(action) [string range $line 0 [expr {$splt - 2}]]
	    set linedata(msg) [string range $line $splt end]
	    set linedata(target) ""
	    set linedata(who) ""

	    if { [info exists dispatch($linedata(action))] } {
		eval $dispatch($linedata(action))
	    } else {
		eval $dispatch(defaultcmd)
	    }
	}

	# GetEvent --

	# Get a line from the server and send it on to
	# DispatchServerCmd/Event

	proc GetEvent { } {
	    variable linedata
	    variable sock
	    array set linedata {}
	    if { [eof $sock] } {
		if { [info exists dispatch(EOF)] } {
		    $dispatch(EOF)
		}
	    }
	    if { [catch {
		gets $sock line
	    } err] } {
		close $sk
		${irc::log}::error "Error receiving from network: $err"
	    }
	    if { [string index $line 0] == ":" } {
		DispatchServerEvent [string range $line 1 end]
	    } else {
		DispatchServerCmd $line
	    }
	}

	# RegisterEvent --

	# Register an event in the dispatch table.

	# Arguments:

	# evnt: name of event as sent by IRC server.

	# cmd: proc to register as the event handler

	proc RegisterEvent { evnt cmd } {
	    variable dispatch
	    set dispatch($evnt) $cmd
	}

	# network --

	# Accepts user commands and dispatches them

	# Arguments:

	# cmd: command to invoke

	# args: arguments to the command

	proc network { cmd args } {
	    switch $cmd {
		connect { Connect }
		user { User [lindex $args 0] [lindex $args 1] [lindex $args 2] }
		nick { Nick [lindex $args 0] }
		join { Join [lindex $args 0] }
		privmsg { Privmsg [lindex $args 0] [lindex $args 1] }
		send { ircsend [lindex $args 0] }
		registerevent { RegisterEvent [lindex $args 0] [lindex $args 1] }
		default { }
	    }
	}
    }
    set returncommand [format "%s::irc%s::%s::network" [namespace current] $conn $host]
    incr conn
    return $returncommand
}
