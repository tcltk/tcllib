# pop3.tcl --
#
#	POP3 mail client package, written in pure Tcl.
#	Some concepts borrowed from "frenchie", a POP3
#	mail client utility written by Scott Beasley.
#
# Copyright (c) 2000 by Scriptics Corporation.
# portions Copyright (c) 2000 by Scott Beasley
#
# All rights reserved.
# 
# RCS: @(#) $Id: pop3.tcl,v 1.2 2000/03/22 03:40:32 redman Exp $

package provide pop3 1.0

namespace eval ::pop3 {
}

# pop3::open --
#
#	Opens a connection to a POP3 mail server.
#
# Arguments:
#	host     The name or IP address of the POP3 server host.
#       user     The username to use when logging into the server.
#       passwd   The password to use when logging into the server.
#       port     (optional) The socket port to connect to, defaults
#                to port 110, the POP standard port address.
#
# Results:
#	The connection channel (a socket).
#       May throw errors from the server.

proc ::pop3::open {host user password {port 110}} {

    set chan [socket $host $port]
    fconfigure $chan -buffering none
    
    if {[catch {::pop3::send $chan {}} errorStr]} {
	error "POP3 CONNECT ERROR: $errorStr"
    }

    if {[catch {
	    ::pop3::send $chan "user $user"
	    ::pop3::send $chan "pass $password"
        } errorStr]} {
	error "POP3 LOGIN ERROR: $errorStr"
    }

    return $chan
}

# ::pop3::status --
#
#	Get the status of the mail spool on the POP3 server.
#
# Arguments:
#	chan      The channel, returned by ::pop3::open
#
# Results:
#	A list containing two elements, {msgCount octetSize},
#       where msgCount is the number of messages in the spool
#       and octetSize is the size (in octets, or 8 bytes) of
#       the entire spool.

proc ::pop3::status {chan} {

    if {[catch {set statusStr [::pop3::send $chan "STAT"]} errorStr]} {
	error "POP3 STAT ERROR: $errorStr"
    }

    # Dig the sent size and count info out.
    set rawStatus [split [string trim $statusStr]]
    
    return [list [lindex $rawStatus 0] [lindex $rawStatus 1]]
}

# ::pop3::last --
#
#	Gets the index of the last email read from the server.
#       Note, some POP3 servers do not support this feature,
#       in which case the value returned may always be zero,
#       or an error may be thrown.
#
# Arguments:
#	chan      The channel, returned by ::pop3::open
#
# Results:
#	The index of the last email message read, which may
#       be zero if none have been read or if the server does
#       not support this feature.
#       Server errors may be thrown, including some cases
#       when the LAST command is not supported.

proc ::pop3::last {chan} {

    if {[catch {
	    set resultStr [::pop3::send $chan "LAST"]
        } errorStr]} {
	error "POP3 LAST ERROR: $errorStr"
    }
    
    return [string trim $resultStr]
}

# ::pop3::retrieve --
#
#	Retrieve email message(s) from the server.
#
# Arguments:
#	chan      The channel, returned by ::pop3::open
#       start     The first message to retrieve in the range.
#                 May be "next" (the next message after the last
#                 one seen, see ::pop3::last), "start" (aka 1),
#                 "end" (the last message in the spool, for 
#                 retriving only the last message).
#       end       (optional, defaults to -1) The last message
#                 to retrieve in the range. May be "last"
#                 (the last message viewed), "end" (the last
#                 message in the spool), or "-1" (the default,
#                 any negative number means retrieve only
#                 one message).
#
# Results:
#	A list containing all of the messages retrieved.
#       May throw errors from the server.

proc ::pop3::retrieve {chan start {end -1}} {
    
    set count [lindex [::pop3::status $chan] 0]
    set last 0
    catch {set last [::pop3::last $chan]}

    if {![string is integer $start]} {
	if {[string match $start "next"]} {
	    set start $last
	    incr start
	} elseif {$start == "start"} {
	    set start 1
	} elseif {$start == "end"} {
	    set start $count
	} else {
	    error "POP3 Retrieval error: Bad start index $start"
	}
    } 
    if {$start == 0} {
	set start 1
    }
	
    
    if {![string is integer $end]} {
	if {$end == "end"} {
	    set end $count
	} elseif {$end == "last"} {
	    set end $last
	} else {
	    error "POP3 Retrieval error: Bad end index $end"
	}
    } elseif {$end < 0} {
	set end $start
    }

    if {$end > $count} {
	set end $count
    }
    
    set result {}

    for {set index $start} {$index <= $end} {incr index} {
	if {[catch {::pop3::send $chan "RETR $index"} errorStr]} {
	    error "POP3 RETRIEVE ERROR: $errorStr"
	}
	
	set msgBuffer ""
	
	while {1} {
	    set line [gets $chan]
	    
	    # End of the message is a line with just "."
	    if {$line == "."} {
		break
	    }
	    append msgBuffer $line "\n"
	}
	lappend result $msgBuffer
    }
    return $result
}

# ::pop3::delete --
#
#	Delete messages on the POP3 server.
#
# Arguments:
#	chan      The channel, returned by ::pop3::open
#       start     The first message to delete in the range.
#                 May be "next" (the next message after the last
#                 one seen, see ::pop3::last), "start" (aka 1),
#                 "end" (the last message in the spool, for 
#                 deleting only the last message).
#       end       (optional, defaults to -1) The last message
#                 to delete in the range. May be "last"
#                 (the last message viewed), "end" (the last
#                 message in the spool), or "-1" (the default,
#                 any negative number means delete only
#                 one message).
#
# Results:
#	None.
#       May throw errors from the server.

proc ::pop3::delete {chan start {end -1}} {
    
    set count [lindex [::pop3::status $chan] 0]
    set last 0
    catch {set last [::pop3::last $chan]}

    if {![string is integer $start]} {
	if {[string match $start "next"]} {
	    set start $last
	    incr start
	} elseif {$start == "start"} {
	    set start 1
	} elseif {$start == "end"} {
	    set start $count
	} else {
	    error "POP3 Deletion error: Bad start index $start"
	}
    } 
    if {$start == 0} {
	set start 1
    }
	
    
    if {![string is integer $end]} {
	if {$end == "end"} {
	    set end $count
	} elseif {$end == "last"} {
	    set end $last
	} else {
	    error "POP3 Deletion error: Bad end index $end"
	}
    } elseif {$end < 0} {
	set end $start
    }

    if {$end > $count} {
	set end $count
    }
    
    for {set index $start} {$index <= $end} {incr index} {
	if {[catch {::pop3::send $chan "DELE $index"} errorStr]} {
	    error "POP3 DELETE ERROR: $errorStr"
	}
    }
    return {}
}

# ::pop3::close --
#
#	Close the connection to the POP3 server.
#
# Arguments:
#	chan      The channel, returned by ::pop3::open
#
# Results:
#	None.

proc ::pop3::close {chan} {
    catch {::pop3::send $chan "QUIT"}
    ::close $chan
}

		

# ::pop3::send --
#
#	Send a command string to the POP3 server.  This is an
#       internal function, but may be used in rare cases.
#
# Arguments:
#	chan        The channel open to the POP3 server.
#       cmdstring   POP3 command string
#
# Results:
#	Result string from the POP3 server, except for the +OK tag.
#       Errors from the POP3 server are thrown.

proc ::pop3::send {chan cmdstring} {
   global PopErrorNm PopErrorStr debug

   if {$cmdstring != {}} {
      puts $chan $cmdstring
   }
   
   set popRet [string trim [gets $chan]]
   
   if {[string first "+OK" $popRet] == -1} {
       error [string range $popRet [expr 3 + 1] end]
   }

   return [string range $popRet 3 end]
}

