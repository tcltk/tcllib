# irc.tcl --
#
#	irc implementation for Tcl.
#
# Copyright (c) 2001 by David N. Welton <davidw@dedasys.com>.
# This code may be distributed under the same terms as Tcl.
#
# $Id: irc.tcl,v 1.11 2003/05/16 22:01:13 davidw Exp $

package provide irc 0.4
package require Tcl 8.3

package require logger

namespace eval ::irc {
    variable conn

    # configuration information
    set config(debug) 0
    set log [logger::init irc]

    # counter used to differentiate connections
    set conn 0
}

# ::irc::config --
#
# Set configuration options.
#
# Arguments:
#
# key	name of the configuration option to change.
#
# value	value of the configuration option.

proc ::irc::config { key value } {
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

# ::irc::connection --

# Create an IRC connection namespace and associated commands.  Do not
# actually make the socket.

# Arguments:

# host	hostname to connect to

# port	port to use - usually 6667

proc ::irc::connection { host {port 6667} } {
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
	    variable dispatch
	    variable state
	    ${irc::log}::debug "ircsend: '$msg'"
	    if { [catch {puts $sock "$msg"} err] } {
	        close $sock
	        set state 0
		if { [info exists dispatch(EOF)] } {
		    eval $dispatch(EOF)
		}
		${irc::log}::error "Error in ircsend: $err"
	    }
	}

	# Implemented user-side commands, meaning that these commands
	# cause the calling user to perform the given action.

	proc cmd-user { username hostname servername userinfo } {
	    ircsend "USER $username $hostname $servername :$userinfo"
	}

	proc cmd-nick { nk } {
	    variable nick
	    set nick $nk
	    ircsend "NICK $nk"
	}

	proc cmd-ping { target } {
	    ircsend "PRIVMSG $target :\001PING [clock seconds]\001"
	}

	proc cmd-serverping { } {
	    ircsend "PING [clock seconds]"
	}

	proc cmd-ctcp { target line } {
	    ircsend "PRIVMSG $target :\001$line\001"
	}

	proc cmd-join { chan {key {}} } {
	    ircsend "JOIN $chan $key"
	}

	proc cmd-part { chan {msg "tcllib irc library"} } {
	    ircsend "PART $chan :$msg"
	}

	proc cmd-quit { {msg {}} } {
	    ircsend "QUIT :$msg"
	}

	proc cmd-privmsg { target msg } {
	    ircsend "PRIVMSG $target :$msg"
	}

	proc cmd-notice { target msg } {
	    ircsend "NOTICE $target :$msg"
	}

	proc cmd-kick { chan target {msg {}} } {
	    ircsend "KICK $chan $target :$msg"
	}

	proc cmd-mode { target args } {
	    ircsend "MODE $target [join $args]"
	}

	proc cmd-topic { chan msg } {
	    ircsend "TOPIC $chan :$msg"
	}

	proc cmd-invite { chan target } {
	    ircsend "INVITE $target $chan"
	}

	proc cmd-send { line } {
	    ircsend $line
	}

	# Connect --
	# Create the actual connection.

	proc cmd-connect { } {
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
		fileevent $sock readable\
		    [format "::irc::irc%s::%s::GetEvent" $conn $host ]
	    }
	    return 0
	}

	# Callback API:

	# These are all available from within callbacks, so as to
	# provide an interface to provide some information on what is
	# coming out of the server.

	# action --

	# Action returns the action performed, such as KICK, PRIVMSG,
	# MODE etc, including numeric actions such as 001, 252, 353,
	# and so forth.

	proc action { } {
	    variable linedata
	    return $linedata(action)
	}

	# msg --

	# The last argument of the line, after the last ':'.

	proc msg { } {
	    variable linedata
	    return $linedata(msg)
	}

	# who --

	# Who performed the action.  If the command is called as [who address],
	# it returns the information in the form
	# nick!ident@host.domain.net

	proc who { {address 0} } {
	    variable linedata
	    if { $address == 0 } {
		return [lindex [split $linedata(who) !] 0]
	    } else {
		return $linedata(who)
	    }
	}

	# target --

	# To whom was this action done.

	proc target { } {
	    variable linedata
	    return $linedata(target)
	}

	# additional --

	# Returns any additional header elements beyond the target.

	proc additional { } {
	    variable linedata
	    return $linedata(additional)
	}

	# header --

	# Returns the entire header in list format.

	proc header { } {
	    variable linedata
	    return [concat [list $linedata(who) $linedata(action) $linedata(target)] \
			$linedata(additional)]
	}

	# GetEvent --

	# Get a line from the server and dispatch it.

	proc GetEvent { } {
	    variable linedata
	    variable sock
	    variable dispatch
	    variable state
	    array set linedata {}
	    set line "eof"
	    if { [eof $sock] || [catch {gets $sock} line] } {
		close $sock
		set state 0
		${irc::log}::error "Error receiving from network: $line"
		if { [info exists dispatch(EOF)] } {
		    eval $dispatch(EOF)
		}
		return
	    }
	    if { [set pos [string first " :" $line]] > -1 } {
		set header [string range $line 0 [expr $pos - 1]]
		set linedata(msg) [string range $line [expr $pos + 2] end]
	    } else {
		set line [string trim $line]
		set pos [string last " " $line]
		set header [string range $line 0 [expr $pos - 1]]
		set linedata(msg) [string range $line [expr $pos + 1] end]
	    }
	    if { [string match :* $header] } {
		set header [split [string trimleft $header :]]
	    } else {
		set header [linsert [split $header] 0 {}]
	    }
	    set linedata(who) [lindex $header 0]
	    set linedata(action) [lindex $header 1]
	    set linedata(target) [lindex $header 2]
	    set linedata(additional) [lrange $header 3 end]
	    if { [info exists dispatch($linedata(action))] } {
		eval $dispatch($linedata(action))
	    } elseif { [string match {[0-9]??} $linedata(action)] } {
		eval $dispatch(defaultnumeric)
	    } elseif { $linedata(who) == "" } {
		eval $dispatch(defaultcmd)
	    } else {
		eval $dispatch(defaultevent)
	    }
	}

	# registerevent --

	# Register an event in the dispatch table.

	# Arguments:
	# evnt: name of event as sent by IRC server.
	# cmd: proc to register as the event handler

	proc cmd-registerevent { evnt cmd } {
	    variable dispatch
	    set dispatch($evnt) $cmd
	    if { $cmd == "" } {
		unset dispatch($evnt)
	    }
	}

	# getevent --

	# Return the currently registered handler for the event.

	# Arguments:
	# evnt: name of event as sent by IRC server.

	proc cmd-getevent { evnt } {
	    variable dispatch
	    if { [info exists exists dispatch($evnt)] } {
		return $dispatch($evnt)
	    }
	    return {}
	}

	# eventexists --

	# Return a boolean value indicating if there is a handler
	# registered for the event.

	# Arguments:
	# evnt: name of event as sent by IRC server.

	proc cmd-eventexists { evnt } {
	    variable dispatch
	    return [info exists dispatch($evnt)]
	}

	# network --

	# Accepts user commands and dispatches them.

	# Arguments:
	# cmd: command to invoke
	# args: arguments to the command

	proc network { cmd args } {
	    eval [namespace current]::cmd-$cmd $args
	}

	# Create default handlers.

	set dispatch(PING) {network send "PONG :[msg]"}
    }
    set returncommand [format "%s::irc%s::%s::network" [namespace current] \
			   $conn $host]
    incr conn
    return $returncommand
}
