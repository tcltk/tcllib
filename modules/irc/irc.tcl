# irc.tcl --
#
#	irc implementation for Tcl.
#
# Copyright (c) 2001 by David N. Welton <davidw@dedasys.com>.
# This code may be distributed under the same terms as Tcl.
#
# $Id: irc.tcl,v 1.1 2001/11/12 23:52:42 andreas_kupries Exp $

package provide irc 0.1

namespace eval irc {
    variable conn

    # configuration information
    set config(debug) 0

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

    set name [format "irc%s::%s" $conn $host]

    namespace eval $name {}

    set ${name}::conn $conn
    set ${name}::port $port

    namespace eval $name {
	set state 0
	set host [namespace tail [namespace current]]
	array set dispatch {}
    
	# ircsend --
	# send text to the IRC server

	proc ircsend { msg } {
	    variable sock
	    puts $sock "$msg"
	    if { $irc::config(debug) > 0 } {
		puts "ircsend: $msg"
	    }
	}

	# implemented user-side commands

	proc User { username hostname userinfo } {
	    ircsend "USER $username $hostname $username :$userinfo"
	}

	proc Nick { nick } {
	    ircsend "NICK $nick"
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

	# DispatchServerEvent --

	# Dispatch event from server

	proc DispatchServerEvent { line } {
	    variable dispatch
	    set splitline [split $line]
	    set who [lindex $splitline 0]
	    set cmd [lindex $splitline 1]
	    set rest [lrange $splitline 2 end]
	    if { [info exists dispatch($cmd)] } {
		$dispatch($cmd) $who $rest
	    } else {
		$dispatch(defaultevent) $cmd $who $rest
	    }
	}

	# DispatchServerCmd --

	# Dispatch command from server

	proc DispatchServerCmd { line } {
	    variable dispatch
	    set splitline [split $line]
	    set action [lindex $splitline 0]
	    set rest [lrange $splitline 1 end]
	    if { [info exists dispatch($action)] } {
		$dispatch($action) $rest
	    } else {
		$dispatch(defaultcmd) $action $who $rest
	    }
	}

	# GetEvent --

	# Get a line from the server and send it on to
	# DispatchServerCmd/Event

	proc GetEvent { } {
	    variable sock
	    if { [eof $sock] } {
		if { [info exists dispatch(EOF)] } {
		    $dispatch(EOF)
		}
	    }
	    gets $sock line
	    if { [string index $line 0] == ":" } {
		DispatchServerEvent [string range $line 0 end]
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
    set returncommand [format "irc::irc%s::%s::network" $conn $host]
    incr conn
    return $returncommand
}
