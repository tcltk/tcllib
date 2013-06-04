##################
## Module Name     --  websocket
## Original Author --  Emmanuel Frecon - emmanuel@sics.se
## Description:
##
##    This library implements a WebSocket client library on top of the
##    existing http package.  The library implements the HTTP-like
##    handshake and the necessary framing of messages on sending and
##    reception.  The library is also server-aware, i.e. implementing
##    the slightly different framing when communicating from a server
##    to a client.  Part of the code comes (with modifications) from
##    the following Wiki page: http://wiki.tcl.tk/26556
##
##################

package require Tcl 8.4

package require http 2.7;  # Need keepalive!
package require logger
package require sha1
package require base64


# IMPLEMENTATION NOTES:
#
# The rough idea behind this library is to misuse the standard HTTP
# package so as to benefit from all its handshaking and the solid
# implementation of the HTTP protocol that it provides.  "Misusing"
# means requiring the HTTP package to keep the socket alive, which
# giving away the opened socket to the library once all initial HTTP
# handshaking has been performed.  From that point and onwards, the
# library is responsible for the framing of fragments of messages on
# the socket according to the RFC.
#
# The library almost solely uses the standard API of the HTTP package,
# thus being future-proof as much as possible as long as the HTTP
# package is kept backwards compatible. HOWEVER, it requires to
# extract the identifier of the socket towards the server from the
# state array. This extraction is not officially specified in the man
# page of the library and could therefor be subject to change in the
# future.

namespace eval ::websocket {
    variable WS
    if { ! [info exists WS] } {
	array set WS {
	    loglevel       "warn"
	    maxlength      16777216
	    ws_magic       "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	    ws_version     13
	    id_gene        0
	    -keepalive     30
	    -ping          ""
	}
	variable log [::logger::init [string trimleft [namespace current] ::]]
	variable libdir [file dirname [file normalize [info script]]]
	${log}::setlevel $WS(loglevel)
    }
}

# ::websocket::loglevel -- Set or query loglevel
#
#       Set or query the log level of the library, which defaults to
#       warn.  The library provides much more debugging help when set
#       to debug.
#
# Arguments:
#	loglvl	New loglevel, empty for no change
#
# Results:
#       Return the (changed?) log level of the library
#
# Side Effects:
#       Increasing the loglevel of the library will output an
#       increased number of messages via the logger package.
proc ::websocket::loglevel { { loglvl "" } } {
    variable WS
    variable log

    if { $loglvl != "" } {
	if { [catch "${log}::setlevel $loglvl"] == 0 } {
	    set WS(loglevel) $loglvl
	}
    }

    return $WS(loglevel)
}


# ::websocket::Disconnect -- Disconnect from remote end
#
#       Disconnects entirely from remote end, providing an event in
#       the handler associated to the socket.  This event is of type
#       "disconnect".  Upon disconnection, the socket is closed and
#       all state concerning that WebSocket is forgotten.
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::Disconnect { sock } {
    variable WS

    set varname [namespace current]::Connection_$sock
    upvar \#0 $varname Connection

    if { $Connection(liveness) ne "" } {
	after cancel $Connection(liveness)
    }
    Push $sock disconnect "Disconnected from remote end"
    catch {::close $sock}
    unset $varname
}


# ::websocket::close -- Close a WebSocket
#
#       Close a WebSocket, while sending the remote end a close frame
#       to describe the reason for the closure.
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#	code	Reason code, as suggested by the RFC
#	reason	Descriptive message, empty to rely on builtin messages.
#
# Results:
#       None.
#
# Side Effects:
#       Will eventually disconnect the socket and loose connection to
#       the remote end.
proc ::websocket::close { sock { code 1000 } { reason "" } } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [info exists $varname] } {
	${log}::warn "$sock is not a WebSocket connection anymore"
	return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection

    if { $Connection(closed) } {
	${log}::notice "Connection already closed"
	return
    }
    set Connection(closed) 1

    if { $code == "" || ![string is integer $code] } {
	send $sock 8
	${log}::info "Closing web socket"
	Push $sock close {}
    } else {
	if { $reason eq "" } {
	    set reason [string map \
			    { 1000 "Normal closure" \
			      1001 "Endpoint going away" \
			      1002 "Protocol error" \
			      1003 "Received incompatible data type" \
			      1006 "Abnormal closure" \
			      1007 "Received data not consistent with type" \
			      1008 "Policy violation" \
			      1009 "Received message too big" \
			      1010 "Missing extension" \
			      1011 "Unexpected condition" \
			      1015 "TLS handshake error" } $code]
	}
	set msg [binary format Su $code]
	append msg [encoding convertto utf-8 $reason]
	set msg [string range $msg 0 124];  # Cut answer to make sure it fits!
	send $sock 8 $msg
	${log}::info "Closing web socket: $code ($reason)"
	Push $sock close [list $code $reason]
    }
    
    Disconnect $sock
}


# ::websocket::Push -- Push event or data to handler
#
#       Every WebSocket is associated to a handler that will be
#       notified upon reception of data, but also upon important
#       events within the library or events resulting from control
#       messages sent by the remote end.  This procedure calls this
#       handler, catching all errors that might occur within the
#       handler.  The types that the library pushes out via this
#       callback are:
#       text       Text complete message
#       binary     Binary complete message
#       connect    Notification of successful connection to server
#       disconnect Disconnection from remote end.
#       close      Pending closure of connection
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#	type	Type of the event
#	msg	Data of the event.
#       handler Use this command to push back instead of handler at WebSocket
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::Push { sock type msg { handler "" } } {
    variable WS
    variable log

    # If we have not specified a handler, which is in most cases, pick
    # up the handler from the array that contains all WS-relevant
    # information.
    if { $handler eq "" } {
	set varname [namespace current]::Connection_$sock
	if { ! [info exists $varname] } {
	    ${log}::warn "$sock is not a WebSocket connection anymore"
	    return -code error "$sock is not a WebSocket"
	}
	upvar \#0 $varname Connection
	set handler $Connection(handler)
    }

    # Ugly but working eval...
    if { [catch {eval [concat $handler [list $sock $type $msg]]} res] } {
	${log}::error "Error when executing WebSocket reception handler: $res"
    }
}


# ::websocket::Ping -- Send a ping
#
#       Sends a ping at regular intervals to keep the connection alive
#       and prevent equipment to close it due to inactivity.
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::Ping { sock } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [info exists $varname] } {
	${log}::warn "$sock is not a WebSocket connection anymore"
	return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection

    # Reschedule at once to get around any possible problem with ping
    # sending.
    Liveness $sock

    # Now send a ping, which will trigger a pong from the
    # (well-behaved) client.
    ${log}::debug "Sending ping to keep connection alive"
    send $sock ping $Connection(-ping)
}


# ::websocket::Liveness -- Keep connections alive
#
#       Keep connections alive (from the server side by construction),
#       as suggested by the specification.  This procedure arranges to
#       send pings after a given period of inactivity within the
#       socket.  This ties to ensure that all equipment keep the
#       connection open.
#
# Arguments:
#	sock	Existing Web socket
#
# Results:
#       Return the time to next ping, negative or zero if not relevant.
#
# Side Effects:
#       None.
proc ::websocket::Liveness { sock } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    upvar \#0 $varname Connection

    # Keep connection alive by issuing pings.
    if { $Connection(liveness) ne "" } {
	after cancel $Connection(liveness)
    }
    set when [expr {$Connection(-keepalive)*1000}]
    if { $when > 0 } {
	set Connection(liveness) [after $when [namespace current]::Ping $sock]
    } else {
	set Connection(liveness) ""
    }
    return $when
}


proc ::websocket::Type { opcode } {
    variable WS
    variable log

    array set TYPES {1 text 2 binary 8 close 9 ping 10 pong}
    if { [array names TYPES $opcode] } {
	set type $TYPES($opcode)
    } else {
	set type <opcode-$opcode>
    }

    return $type
}


# ::websocket::send -- Send message or fragment to remote end.
#
#       Sends a fragment or a control message to the remote end of the
#       WebSocket. The type of the message is passed as a parameter
#       and can either be an integer according to the specification or
#       one of the following strings: text, binary, ping.  When
#       fragmenting, it is not allowed to change the type of the
#       message between fragments.
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#	type	Type of the message (see above)
#	msg	Data of the fragment.
#	final	True if final fragment
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::send { sock type {msg ""} {final 1}} {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [info exists $varname] } {
	${log}::warn "$sock is not a WebSocket connection anymore"
	return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection

    # Determine opcode from type, i.e. text, binary or ping. Accept
    # integer opcodes for internal use or for future extensions of the
    # protocol.
    set opcode -1;
    if { [string is integer $type] } {
	set opcode $type
    } else {
	switch -glob -nocase -- $type {
	    t* {
		# text
		set opcode 1
	    }
	    b* {
		# binary
		set opcode 2
	    }
	    p* {
		# ping
		set opcode 9
	    }
	}
    }

    if { $opcode < 0 } {
	return -code error \
	    "Unrecognised type, should be one of text, binary, ping or\
             a protocol valid integer"
    }

    # Refuse to continue if different from last type of message.
    if { $Connection(write:opcode) > 0 } {
	if { $opcode != $Connection(write:opcode) } {
	    return -code error \
		"Cannot change type of message under continuation!"
	}
	set opcode 0;    # Continuation
    } else {
	set Connection(write:opcode) $opcode
    }

    # Encode text
    set type [Type $Connection(write:opcode)]
    if { $Connection(write:opcode) == 1 } {
	set msg [encoding convertto utf-8 $msg]
    }

    # Reset continuation state once sending last fragment of message.
    if { $final } {
	set Connection(write:opcode) -1
    }

    # Start assembling the header.
    set header [binary format c [expr {!!$final << 7 | $opcode}]]

    # Append the length of the message to the header. Small lengths
    # fit directly, larger ones use the markers 126 or 127.  We need
    # also to take into account the direction of the socket, since
    # clients shall randomly mask data.
    set mlen [string length $msg]
    if { $mlen < 126 } {
	set plen [string length $msg]
    } elseif { $mlen < 65536 } {
	set plen 126
    } else {
	set plen 127
    }

    # Set mask bit and push regular length into header.
    if { [string is true $Connection(server)] } {
	append header [binary format c $plen]
	set dst "client"
    } else {
	append header [binary format c [expr {1 << 7 | $plen}]]
	set dst "server"
    }

    # Appends "longer" length when the message is longer than 125 bytes
    if { $mlen > 125 } {
	if { $mlen < 65536 } {
	    append header [binary format Su $mlen]
	} else {
	    append header [binary format Wu $mlen]
	}
    }

    # Add the masking key and perform client masking whenever relevant
    if { [string is false $Connection(server)] } {
	set mask [expr {int(rand()*4294967296)}]
	append header [binary format Iu $mask]
	set msg [Mask $mask $msg]
    }
    
    # Send the (masked) frame
    if { [catch {
	puts -nonewline $sock $header$msg
	flush $sock}] } {
	${log}::error "Could not send to remote end, closed socket?"
	close $sock 1001
	return -1
    }

    # Keep socket alive at all times.
    Liveness $sock

    if { [string is true $final] } {
	${log}::debug "Sent $mlen bytes long $type final fragment to $dst"
    } else {
	${log}::debug "Sent $mlen bytes long $type fragment to $dst"
    }
    return [string length $header$msg]
}


# ::websocket::Mask -- Mask data according to RFC
#
#       XOR mask data with the provided mask as described in the RFC.
#
# Arguments:
#	mask	Mask to use to mask the data
#	dta	Bytes to mask
#
# Results:
#       Return the mask bytes, i.e. as many bytes as the data that was
#       given to this procedure, though XOR masked.
#
# Side Effects:
#       None.
proc ::websocket::Mask { mask dta } {
    variable WS
    variable log

    # Format data as a list of 32-bit integer
    # words and list of 8-bit integer byte leftovers.  Then unmask
    # data, recombine the words and bytes, and return
    binary scan $dta I*c* words bytes

    set masked_words {}
    set masked_bytes {}
    for {set i 0} {$i < [llength $words]} {incr i} {
	lappend masked_words [expr {[lindex $words $i] ^ $mask}]
    }
    for {set i 0} {$i < [llength $bytes]} {incr i} {
	lappend masked_bytes [expr {[lindex $bytes $i] ^
				    ($mask >> (24 - 8 * $i))}]
    }

    return [binary format I*c* $masked_words $masked_bytes]
}


# ::websocket::Receiver -- Receive (framed) data from WebSocket
#
#       Received framed data from a WebSocket, recontruct all
#       fragments to a complete message whenever the final fragment is
#       received and calls the handler associated to the WebSocket
#       with the content of the message once it has been
#       reconstructed.  Interleaved control frames are also passed
#       further to the handler.  This procedure also automatically
#       responds to ping by pongs.
#
# Arguments:
#	sock	WebSocket that was taken over or created by this library
#
# Results:
#       None.
#
# Side Effects:
#       Read a frame from the socket, possibly blocking while reading.
proc ::websocket::Receiver { sock } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [info exists $varname] } {
	${log}::warn "$sock is not a WebSocket connection anymore"
	return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection

    # Keep connection alive by issuing pings.
    Liveness $sock

    # Get basic header.  Abort if reserved bits are set, unexpected
    # continuation frame, fragmented or oversized control frame, or
    # the opcode is unrecognised.
    if { [catch {read $sock 2} dta] || [string length $dta] != 2 } {
	${log}::error "Cannot read header from socket: $dta"
	close $sock 1001
	return
    }
    binary scan $dta Su header
    set opcode [expr {$header >> 8 & 0xf}]
    set mask [expr {$header >> 7 & 0x1}]
    set len [expr {$header & 0x7f}]
    set reserved [expr {$header >> 12 & 0x7}]
    if { $reserved \
	     || ($opcode == 0 && $Connection(read:mode) eq "") \
	     || ($opcode > 7 && (!($header & 0x8000) || $len > 125)) \
	     || [lsearch {0 1 2 8 9 10} $opcode] < 0 } {
	# Send close frame, reason 1002: protocol error
	close $sock 1002
	return
    }

    # Determine the opcode for this frame, i.e. handle continuation of
    # frames.
    if { $Connection(read:mode) eq "" } {
	set Connection(read:mode) $opcode
    } elseif { $opcode == 0 } {
	set opcode $Connection(read:mode)
    }


    # Get the extended length, if present
    if { $len == 126 } {
	if { [catch {read $sock 2} dta] || [string length $dta] != 2 } {
	    ${log}::error "Cannot read length from socket: $dta"
	    close $sock 1001
	    return
	}
	binary scan $dta Su len
    } elseif { $len == 127 } {
	if { [catch {read $sock 8} dta] || [string length $dta] != 2 } {
	    ${log}::error "Cannot read length from socket: $dta"
	    close $sock 1001
	    return
	}
	binary scan $dta Wu len
    }


    # Control frames use a separate buffer, since they can be
    # interleaved in fragmented messages.
    if { $opcode > 7 } {
	# Control frames should be shorter than 125 bytes
	if { $len > 125 } {
	    close $sock 1009
	    return
	}
	set oldmsg $Connection(read:msg)
	set Connection(read:msg) ""
    } else {
	# Limit the maximum message length
	if { [string length $Connection(read:msg)] + $len > $WS(maxlength) } {
	    # Send close frame, reason 1009: frame too big
	    close $sock 1009 "Limit $WS(maxlength) exceeded"
	    return
	}
    }

    if { $mask } {
	# Get mask and data.  Format data as a list of 32-bit integer
        # words and list of 8-bit integer byte leftovers.  Then unmask
	# data, recombine the words and bytes, and append to the buffer.
	if { [catch {read $sock 4} dta] || [string length $dta] != 4 } {
	    ${log}::error "Cannot read mask from socket: $dta"
	    close $sock 1001
	    return
	}
	binary scan $dta Iu mask
	if { [catch {read $sock $len} bytes] } {
	    ${log}::error "Cannot read fragment content from socket: $bytes"
	    close $sock 1001
	    return
	}
	append Connection(read:msg) [Mask $mask $bytes]
    } else {
	if { [catch {read $sock $len} bytes] \
		 || [string length $bytes] != $len } {
	    ${log}::error "Cannot read fragment content from socket: $bytes"
	    close $sock 1001
	    return
	}
	append Connection(read:msg) $bytes
    }

    if { [string is true $Connection(server)] } {
	set dst "client"
    } else {
	set dst "server"
    }
    set type [Type $Connection(read:mode)]

    # If the FIN bit is set, process the frame.
    if { $header & 0x8000 } {
	${log}::debug "Received $len long $type final fragment from $dst"
	switch $opcode {
	    1 {
		# Text: decode and notify handler
		Push $sock text \
		    [encoding convertfrom utf-8 $Connection(read:msg)]
	    }
	    2 {
		# Binary: notify handler, no decoding
		Push $sock binary $Connection(read:msg)
	    }
	    8 {
		# Close: decode, notify handler and close frame.
		if { [string length $Connection(read:msg)] >= 2 } {
		    binary scan [string range $Connection(read:msg) 0 1] Su \
			reason
		    set msg [encoding convertfrom utf-8 \
				 [string range $Connection(read:msg) 2 end]]
		    close $sock $reason $msg
		} else {
		    close $sock 
		}
		return
	    }
	    9 {
		# Ping: send pong back and notify handler since this
		# might contain some data.
		send $sock 10 $Connection(read:msg)
		Push $sock ping $Connection(read:msg)
	    }
	}

	# Prepare for next frame.
	if { $opcode < 8 } {
	    # Reinitialise
	    set Connection(read:msg) ""
	    set Connection(read:mode) ""
	} else {
	    set Connection(read:msg) $oldmsg
	}
    } else {
	${log}::debug "Received $len long $type fragment from $dst"
    }
}


# ::websocket::takeover -- Take over an existing socket.
#
#       Take over an existing opened socket to implement sending and
#       receiving WebSocket framing on top of the socket.  The
#       procedure takes a handler, i.e. a command that will be called
#       whenever messages, control messages or other important
#       internal events are received or occur.
#
# Arguments:
#	sock	Existing opened socket.
#	handler	Command to call on events and incoming messages.
#	server	Is this a socket within a server, i.e. towards a client.
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::takeover { sock handler { server 0 } } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    upvar \#0 $varname Connection
    
    set Connection(sock) $sock
    set Connection(handler) $handler
    set Connection(server) $server

    set Connection(read:mode) ""
    set Connection(read:msg) ""
    set Connection(write:opcode) -1
    set Connection(closed) 0
    set Connection(liveness) ""
    
    # Arrange for keepalive to be zero, i.e. no pings, when we are
    # within a client.  When in servers, take the default from the
    # library.  In any case, this can be configured, which means that
    # even clients can start sending pings when nothing has happened
    # on the line if necessary.
    if { [string is true $server] } {
	set Connection(-keepalive) $WS(-keepalive)
    } else {
	set Connection(-keepalive) 0
    }
    set Connection(-ping) $WS(-ping)

    fconfigure $sock -translation binary -blocking on
    fileevent $sock readable [list [namespace current]::Receiver $sock]
    Liveness $sock
    
    ${log}::debug "$sock has been registered as a\
                   [expr $server?\"server\":\"client\"] WebSocket"
}


# ::websocket::Connected -- Handshake and framing initialisation
#
#       Performs the security handshake once connection to a remote
#       WebSocket server has been established and handshake properly.
#       On success, start listening to framed data on the socket, and
#       mediate the callers about the connection and the application
#       protocol that was chosen by the server.
#
# Arguments:
#	opener	Temporary HTTP connection opening object.
#	sock	Socket connection to server, empty to pick from HTTP state array
#	token	HTTP state array.
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::Connected { opener sock token } {
    variable WS
    variable log

    upvar \#0 $opener OPEN
    upvar \#0 $token STATE

    # Dig into the internals of the HTTP library for the socket if
    # none present as part of the arguments (ugly...)
    if { $sock eq "" } {
	set sock $STATE(sock)
    }

    if { [::http::ncode $token] == 101 } {
	array set HDR $STATE(meta)

	# Extact security handshake, check against what was expected
	# and abort in case of mismatch.
	if { [array names HDR Sec-WebSocket-Accept] ne "" } {
	    # Compute security handshake
	    set sec $OPEN(nonce)$WS(ws_magic)
	    set accept [base64::encode [sha1::sha1 -bin $sec]]
	    if { $accept ne $HDR(Sec-WebSocket-Accept) } {
		${log}::error "Security handshake failed"
		::http::reset $token error
		unset $opener
		return 0
	    }
	}

	# Extract application protocol information to pass further to
	# handler.
	set proto ""
	if { [array names HDR Sec-WebSocket-Protocol] ne "" } {
	    set proto $HDR(Sec-WebSocket-Protocol)
	}

	# Remove the socket from the socketmap inside the http
	# library.  THIS IS UGLY, but the only way to make sure we
	# really can take over the socket and make sure the library
	# will open A NEW socket, even towards the same host, at a
	# later time.
	if { [info vars ::http::socketmap] ne "" } {
	    foreach k [array names ::http::socketmap] {
		if { $::http::socketmap($k) eq $sock } {
		    ${log}::debug "Removed socket $sock from internal state\
                                   of http library"
		    unset ::http::socketmap($k)
		}
	    }
	} else {
	    ${log}::warn "Could not remove socket $sock from socket map, future\
                          connections to same host and port are likely not to\
                          work"
	}

	# Takeover the socket to create a connection and mediate about
	# connection via the handler.
	takeover $sock $OPEN(handler)
	Push $sock connect $proto;  # Tell the handler which
				      # protocol was chosen.
    } else {
	Push \
	    "" \
	    error \
	    "Protocol error during WebSocket connection with $OPEN(url)" \
	    $OPEN(handler)
    }

    ::http::cleanup $token
    unset $opener;   # Always unset the temporary connection opening
		     # array
}


# ::websocket::Finished -- Pass further on HTTP connection finalisation
#
#       Pass further to Connected whenever the HTTP operation has
#       been finished as implemented by the HTTP package.
#
# Arguments:
#	opener	Temporary HTTP connection opening object.
#	sock	Socket connection to server, empty to pick from HTTP state array
#	token	HTTP state array.
#
# Results:
#       None.
#
# Side Effects:
#       None.
proc ::websocket::Finished { opener token } {
    Connected $opener "" $token
}


# ::websocket::Timeout -- Timeout an HTTP connection
#
#       Reimplementation of the timeout facility from the HTTP package
#       to be able to cleanup internal state properly and mediate to
#       the handler.
#
# Arguments:
#	opener	Temporary HTTP connection opening object.
#
# Results:
#       None.
#
# Side Effects:
#       Reset the HTTP connection, which will (probably) close the
#       socket.
proc ::websocket::Timeout { opener } {
    variable WS
    variable log

    if { [info exists $opener] } {
	upvar \#0 $opener OPEN
	
	::http::reset $OPEN(token) "timeout"
	Push "" timeout "Timeout when connecting to $OPEN(url)" $OPEN(handler)
	::http::cleanup $OPEN(token)
	unset $opener
    }
}


# ::websocket::open -- Open connection to remote WebSocket server
#
#       Open a WebSocket connection to a remote server.  This
#       procedure takes a number of options, which mostly are the
#       options that are supported by the http::geturl procedure.
#       However, there are a few differences described below:
#       -headers  Is supported, but additional headers will be added internally
#       -validate Is not supported, it has no point.
#       -handler  Is used internally, so cannot be specified.
#       -command  Is used internally, so cannot be specified.
#       -protocol Contains a list of app. protocols to handshake with server
#
# Arguments:
#	url	WebSocket URL, i.e. led by ws: or wss:
#	handler	Command to callback on data reception or event occurence
#	args	List of dashled options with their values, as explained above.
#
# Results:
#       Return the token of the HTTP library. You should only cleanup
#       that token once the library has been disconnected from the server.
#
# Side Effects:
#       None.
proc ::websocket::open { url handler args } {
    variable WS
    variable log

    # Fool the http library by replacing the ws: (websocket) scheme
    # with the http, so we can use the http library to handle all the
    # initial handshake.
    set hturl [string map -nocase {ws: http: wss: https:} $url]

    # Start creating a command to call the http library.
    set cmd [list ::http::geturl $hturl]

    # Control the geturl options that we can blindly pass to the
    # http::geturl call. We basically remove -validate, which has no
    # point and stop -handler which we will be using internally.  We
    # restrain the use of -timeout, implementing the timeout ourselves
    # to avoid the library to close the socket to the server.  We also
    # intercept the headers since we will be adding WebSocket protocol
    # information as part of the headers.
    set protos {}
    set timeout -1
    array set HDR {}
    foreach { k v } $args {
	set allowed 0
	foreach opt {bi* bl* ch* he* k* m* prog* prot* qu* s* ti* ty*} {
	    if { [string match -nocase $opt [string trimleft $k -]] } {
		set allowed 1
	    }
	}
	if { ! $allowed } {
	    return -code error "$k is not a recognised option"
	}
	switch -nocase -glob -- [string trimleft $k -] {
	    he* {
		# Catch the headers, since we will be adding a few
		# ones by hand.
		array set HDR $v
	    }
	    prot* {
		# New option -protocol to support the list of
		# application protocols that the client accepts.
		# -protocol should be a list.
		set protos $v
	    }
	    ti* {
		# We implement the timeout ourselves to be able to
		# properly cleanup.
		if { [string is integer $v] && $v > 0 } {
		    set timeout $v
		}
	    }
	    default {
		# Any other allowed option will simply be passed
		# further to the http::geturl call, to benefit from
		# all its facilities.
		lappend cmd $k $v
	    }
	}
    }

    # Create an HTTP connection object that will contain all necessary
    # internal data until the connection has been a success or until
    # it failed.
    set varname [namespace current]::opener_[incr WS(id_gene)]
    upvar \#0 $varname OPEN
    set OPEN(url) $url
    set OPEN(handler) $handler
    set OPEN(nonce) ""

    # Construct the WebSocket part of the header according to RFC6455.
    # The NONCE should be randomly chosen for each new connection
    # established
    set HDR(Connection) "Upgrade"
    set HDR(Upgrade) "websocket"
    for { set i 0 } { $i < 4 } { incr i } {
	append OPEN(nonce) [binary format Iu [expr {int(rand()*4294967296)}]]
    }
    set OPEN(nonce) [::base64::encode $OPEN(nonce)]
    set HDR(Sec-WebSocket-Key) $OPEN(nonce)
    set HDR(Sec-WebSocket-Protocol) [join $protos ", "]
    set HDR(Sec-WebSocket-Version) $WS(ws_version)
    lappend cmd -headers [array get HDR]

    # Add our own handler to intercept the socket once connection has
    # been opened and established properly and make sure we keep alive
    # the socket so we can continue using it. In practice, what gets
    # called is the command that is specified by -command, even though
    # we would like to intercept this earlier on.  This has to do with
    # the internals of the HTTP package.
    lappend cmd \
	-handler [list [namespace current]::Connected $varname] \
	-command [list [namespace current]::Finished $varname] \
	-keepalive 1

    # Now open the connection to the remote server using the HTTP
    # package...
    if { [catch {eval $cmd} token] } {
	${log}::error "Error while opening WebSocket connection to $url: $token"
	set token ""
    } else {
	set OPEN(token) $token
	if { $timeout > 0 } {
	    set OPEN(timeout) \
		[after $timeout [namespace current]::Timeout $varname]
	}
    }

    return $token
}


proc ::websocket::conninfo { sock what } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [::info exists $varname] } {
        ${log}::warn "$sock is not a WebSocket connection anymore"
        return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection
    
    switch -glob -nocase -- $what {
        "peer*" {
            return $Connection(peername)
        }
        "sockname" -
        "name" {
            return $Connection(sockname)
        }
        "close*" {
            return $Connection(closed)
        }
        "client" {
            return [string is false $Connection(server)]
        }
        "server" {
            return [string is true $Connection(server)]
        }
        "type" {
            return [string is true $Connection(server)]?"server":"client"
        }
        "handlers" {
            return $Connection(handlers)
        }
        default {
            return -code error "$what is not a known information piece for\
                                a websocket"
        }
    }
    return "";  # Never reached
}


proc ::websocket::find { { host * } { port * } } {
    variable WS
    variable log

    set socks [list]
    foreach varname [::info vars [namespace current]::Connection_*] {
        upvar \#0 $varname Connection
        foreach {ip hst prt} $Connection(peername) break
        if { ([string match $host $ip] || [string match $host $hst]) \
                 && [string match $port $prt] } {
            lappend socks $Connection(sock)
        }
    }

    return $socks
}


proc ::websocket::configure { sock args } {
    variable WS
    variable log

    set varname [namespace current]::Connection_$sock
    if { ! [info exists $varname] } {
	${log}::warn "$sock is not a WebSocket connection anymore"
	return -code error "$sock is not a WebSocket"
    }
    upvar \#0 $varname Connection

    foreach { k v } $args {
	set allowed 0
	foreach opt {k* p*} {
	    if { [string match -nocase $opt [string trimleft $k -]] } {
		set allowed 1
	    }
	}
	if { ! $allowed } {
	    return -code error "$k is not a recognised option"
	}
	switch -nocase -glob -- [string trimleft $k -] {
	    k* {
		# Change keepalive
		set Connection(-keepalive) $v
		Liveness $sock;  # Change at once.
	    }
	    p* {
		# Change ping, i.e. text used during the automated pings.
		set Connection(-ping) $v
	    }
	}
    }
}


package provide websocket 1.0
