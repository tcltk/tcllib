# comm.tcl --
#
#	socket-based 'send'ing of commands between interpreters.
#
# %%_OSF_FREE_COPYRIGHT_%%
# Copyright (C) 1995-1998 The Open Group.   All Rights Reserved.
# (Please see the file "comm.LICENSE" that accompanied this source,
#  or http://www.opengroup.org/www/dist_client/caubweb/COPYRIGHT.free.html)
#
# This is the 'comm' package written by Jon Robert LoVerso, placed
# into its own namespace during integration into tcllib.
#
# Note that the actual code was changed in several places (Reordered,
# eval speedup)
# 
#	comm works just like Tk's send, except that it uses sockets.
#	These commands work just like "send" and "winfo interps":
#
#		comm send ?-async? <id> <cmd> ?<arg> ...?
#		comm interps
#
#	See the manual page comm.n for further details on this package.
#
# RCS: @(#) $Id: comm.tcl,v 1.8 2003/04/11 19:39:12 andreas_kupries Exp $

package require Tcl 8.2

namespace eval ::comm {
    namespace export comm comm_send

    variable  comm
    array set comm {}

    if {![info exists comm(chans)]} {
	array set comm {
	    debug 0 chans {} localhost 127.0.0.1
	    connecting,hook 1
	    connected,hook 1
	    incoming,hook 1
	    eval,hook 1
	    reply,hook 1
	    lost,hook 1
	    offerVers {3 2}
	    acceptVers {3 2}
	    defVers 2
	}
	set comm(lastport) [expr {[pid] % 32768 + 9999}]
	# fast check for acceptable versions
	foreach comm(_x) $comm(acceptVers) {
	    set comm($comm(_x),vers) 1
	}
	catch {unset comm(_x)}
    }

    # Class variables:
    #	lastport		saves last default listening port allocated 
    #	debug			enable debug output
    #	chans			list of allocated channels
    #	$meth,method		body of method
    #
    # Channel instance variables:
    # comm()
    #	$ch,port		listening port (our id)
    #	$ch,socket		listening socket
    #	$ch,local		boolean to indicate if port is local
    #	$ch,serial		next serial number for commands
    #
    #	$ch,hook,$hook		script for hook $hook
    #
    #	$ch,peers,$id		open connections to peers; ch,id=>fid
    #	$ch,fids,$fid		reverse mapping for peers; ch,fid=>id
    #	$ch,vers,$id		negotiated protocol version for id
    #	$ch,pending,$id		list of outstanding send serial numbers for id
    #
    #	$ch,buf,$fid		buffer to collect incoming data		
    #	$ch,result,$serial	result value set here to wake up sender
    #	$ch,return,$serial	return codes to go along with result

    # Special initialization, defines the method 'method' to be used
    # for the definition of new methods (sic!). The code is executed
    # in the scope of the procedure '::comm::comm''. This means that
    # they have only access to the 'args' argument and the 'chan'
    # variable. This includes 'method' itself.

    # Create the methods on comm
    # Perhaps this shouldn't store them as procs?

    set comm(method,method) {
	# args[0]      = name of method
	# args[1..end] = body of method

	if {[llength $args] == 1} {
	    # No body given, call is query for body.
	    if [info exists comm([lindex $args 0],method)] {
		return $comm([lindex $args 0],method)
	    } else {
		error "No such method"
	    }
	}
	# Define new method.
	eval [linsert [lrange $args 1 end] 0 \
		set [list comm([lindex $args 0],method)]]
	#eval set [list comm([lindex $args 0],method)] [lrange $args 1 end]
    }

    if {0} {
	# Propogate result, code, and errorCode.  Can't just eval
	# otherwise TCL_BREAK gets turrned into TCL_ERROR.
	global errorInfo errorCode
	set code [catch [concat commSend $args] res]
	return -code $code -errorinfo $errorInfo -errorcode $errorCode $res
    }
}

# ::comm::comm_send --
#
#	Convenience command. Replaces Tk 'send' and 'winfo' with
#	versions using the 'comm' variants. Multiple calls are
#	allowed, only the first one will have an effect.
#
# Arguments:
#	None.
#
# Results:
#	None.

proc ::comm::comm_send {} {
    proc send {args} {
	# Use pure lists to speed this up.
	eval [linsert $args 0 ::comm::comm send]
	#eval comm send $args
    }
    rename winfo tk_winfo
    proc winfo {cmd args} {
	if {![string match in* $cmd]} {
	    # Use pure lists to speed this up ...
	    return [eval [linsert $args 0 tk_winfo $cmd]]
	    #return [eval [list tk_winfo $cmd] $args]
	}
	return [::comm::comm interps]
    }
    proc ::comm::comm_send {} {}
}

# ::comm::comm --
#
#	See documentation for public methods of "comm".
#	This procedure is followed by the definition of
#	the public methods themselves.
#
# Arguments:
#	cmd	Invoked method
#	args	Arguments to method.
#
# Results:
#	As of the invoked method.

proc ::comm::comm {cmd args} {
    variable comm
    set chan ::comm::comm ; # chan is used in the code of the declared methods.

    set method [array names comm $cmd*,method]	;# min unique

    if {[llength $method] == 1} {
	return [eval $comm($method)]
    } else {
	foreach c [array names comm *,method] {
	    lappend cmds [lindex [split $c ,] 0]
	}
        error "bad subcommand \"$cmd\": should be [join [lsort $cmds] ", "]"
    }
}

::comm::comm method connect {
    #eval commConnect $args
    eval [linsert $args 0 commConnect]
}
::comm::comm method self {
    set comm($chan,port)
}
::comm::comm method channels {
    set comm(chans)
}
::comm::comm method new	{
    #eval commNew $args
    eval [linsert $args 0 commNew]
}
::comm::comm method configure {
    #eval commConfigure 0 $args
    eval [linsert $args 0 commConfigure 0]
}
::comm::comm method shutdown {
    eval commShutdown $args
    #eval commShutdown $args
}
::comm::comm method abort {
    eval [linsert $args 0 commAbort]
    #eval commAbort $args
}
::comm::comm method destroy {
    eval [linsert $args 0 commDestroy]
    #eval commDestroy $args
}
::comm::comm method hook {
    eval [linsert $args 0 commHook]
    #eval commHook $args
}
::comm::comm method ids {
    set res $comm($chan,port)
    foreach {i id} [array get comm $chan,fids,*] {lappend res $id}
    set res
}
::comm::comm method interps \
	[::comm::comm method ids]
::comm::comm method remoteid {
    if {[info exists comm($chan,remoteid)]} {
	set comm($chan,remoteid)
    } else {
	error "No remote commands processed yet"
    }
}
::comm::comm method debug {
    set comm(debug) \
	    [switch -exact -- $args on - 1 {subst 1} default {subst 0}]
}
::comm::comm method init {
    error "This method is no longer supported"
}
::comm::comm method send {
    set cmd send

    # args = ?-async? id cmd ?arg arg ...?
    set i 0
    if {[string match -async [lindex $args $i]]} {
	set cmd async
	incr i
    }
    # args = id cmd ?arg arg ...?

    set id [lindex $args $i]
    incr i
    set args [lrange $args $i end]

    if {![info complete $args]} {
	return -code error "Incomplete command"
    }
    if {[string match "" $args]} {
	return -code error \
		"wrong # args: should be \"send ?-async? id arg ?arg ...?\""
    }
    if {[catch {commConnect $id} fid]} {
	return -code error "Connect to remote failed: $fid"
    }

    set ser [incr comm($chan,serial)]
    # This is unneeded - wraps from 2147483647 to -2147483648
    ### if {$comm($chan,serial) == 0x7fffffff} {set comm($chan,serial) 0}

    commDebug {puts stderr "send <[list [list $cmd $ser $args]]>"}

    # The double list assures that the command is a single list when read.
    puts  $fid [list [list $cmd $ser $args]]
    flush $fid

    # wait for reply if so requested

    if {[string match send $cmd]} {
	upvar 0 comm($chan,pending,$id) pending	;# shorter variable name

	lappend pending $ser
	set comm($chan,return,$ser) ""		;# we're waiting

	commDebug {puts stderr "--<<waiting $chan $ser>>--"}
	vwait ::comm::comm($chan,result,$ser)

	# if connection was lost, pending is gone
	if {[info exists pending]} {
	    set pos [lsearch -exact $pending $ser]
	    set pending [lreplace $pending $pos $pos]
	}

	commDebug {
	    puts stderr "result\
		    <$comm($chan,return,$ser);$comm($chan,result,$ser)>"
	}
	after idle unset ::comm::comm($chan,result,$ser)

	array set return $comm($chan,return,$ser)
	unset comm($chan,return,$ser)
	switch -- $return(-code) {
	    "" - 0 {return $comm($chan,result,$ser)}
	    1 {
		return  -code $return(-code) \
			-errorinfo $return(-errorinfo) \
			-errorcode $return(-errorcode) \
			$comm($chan,result,$ser)
	    }
	    default {return -code $return(-code) $comm($chan,result,$ser)}
	}
    }
}

###############################################################################

# ::comm::commDebug --
#
#	Internal command. Conditionally executes debugging
#	statements. Currently this are only puts commands logging the
#	various interactions. These could be replaced with calls into
#	the 'log' module.
#
# Arguments:
#	arg	Tcl script to execute.
#
# Results:
#	None.

proc ::comm::commDebug {arg} {
    variable comm
    if {$comm(debug)} {
	uplevel 1 $arg
    }
}

# ::comm::commNew --
#
#	Internal command. Create a new comm channel/instance.
#	Implements the 'comm new' method.
#
# Arguments:
#	ch	Name of the new channel
#	args	Configuration, in the form of -option value pairs.
#
# Results:
#	None.

proc ::comm::commNew {ch args} {
    variable comm

    if {[lsearch -exact $comm(chans) $ch] >= 0} {
	error "Already existing channel: $ch"
    }
    if {([llength $args] % 2) != 0} {
	error "Must have an even number of config arguments"
    }
    if {[string match ::comm::comm $ch]} {
	# allow comm to be recreated after destroy
    } elseif {![string compare $ch [info proc $ch]]} {
	error "Already existing command: $ch"
    } else {
	regsub  "set chan \[^\n\]*\n" [info body ::comm::comm] \
		"set chan $ch\n" nbody
	proc $ch {cmd args} $nbody
    }
    lappend comm(chans) $ch
    set chan $ch
    set comm($chan,serial) 0
    set comm($chan,chan) $chan
    set comm($chan,port) 0
    set comm($chan,listen) 0
    set comm($chan,socket) ""
    set comm($chan,local) 1

    if {[llength $args] > 0} {
	eval [linsert $args 0 commConfigure 1]
	#eval commConfigure 1 $args
    }
    # XXX need to destroy chan if config failed
}

# ::comm::commDestroy --
#
#	Internal command. Destroy the channel invoking it.
#	Implements the 'comm destroy' method.
#
# Arguments:
#	None.
#
# Results:
#	None.

proc ::comm::commDestroy {} {
    upvar chan chan
    variable comm
    catch {close $comm($chan,socket)}
    commAbort
    catch {unset comm($chan,port)}
    catch {unset comm($chan,local)}
    catch {unset comm($chan,socket)}
    unset comm($chan,serial)
    set pos [lsearch -exact $comm(chans) $chan]
    set comm(chans) [lreplace $comm(chans) $pos $pos]
    if {[string compare ::comm::comm $chan]} {
	rename $chan {}
    }
}

# ::comm::commConfVars --
#
#	Internal command. Used to declare configuration options.
#
# Arguments:
#	v	Name of configuration option.
#	t	Default value.
#
# Results:
#	None.

proc ::comm::commConfVars {v t} {
    variable comm
    set comm($v,var) $t
    set comm(vars) {}
    foreach c [array names comm *,var] {
	lappend comm(vars) [lindex [split $c ,] 0]
    }
}
::comm::commConfVars port p
::comm::commConfVars local b
::comm::commConfVars listen b
::comm::commConfVars socket ro
::comm::commConfVars chan ro
::comm::commConfVars serial ro

# ::comm::commConfigure --
#
#	Internal command. Implements 'comm configure'.
#
# Arguments:
#	force	Boolean flag. If set the socket is reinitialized.
#	args	New configuration, as -option value pairs.
#
# Results:
#	None.

proc ::comm::commConfigure {{force 0} args} {
    upvar chan chan
    variable comm

    # query
    switch [llength $args] {
	0 {
	    foreach v $comm(vars) {lappend res -$v $comm($chan,$v)}
	    return $res
	}
	1 {
	    set arg [lindex $args 0]
	    set var [string range $arg 1 end]
	    if {[string match -* $arg] && [info exists comm($var,var)]} {
		return $comm($chan,$var)
	    } else {
		error "Unknown configuration option: $arg"
	    }
	}
    }

    # set
    set opt 0
    foreach arg $args {
	incr opt
	if {[info exists skip]} {unset skip; continue}
	set var [string range $arg 1 end]
	if {![string match -* $arg] || ![info exists comm($var,var)]} {
	    error "Unknown configuration option: $arg"
	}
	set optval [lindex $args $opt]
	switch $comm($var,var) {
	    b {
		# FRINK: nocheck
		set $var [commBool $optval]
		set skip 1
	    }
	    v {
		# FRINK: nocheck
		set $var $optval
		set skip 1
	    }
	    p {
		if {
		    [string compare $optval ""] &&
		    ![string is integer $optval]
		} {
		    error "Non-port to configuration option: -$var"
		}
		# FRINK: nocheck
		set $var $optval
		set skip 1
	    }
	    i {
		if {![string is integer $optval]} {
		    error "Non-integer to configuration option: -$var"
		}
		# FRINK: nocheck
		set $var $optval
		set skip 1
	    }
	    ro { error "Readonly configuration option: -$var" }
	}
    }
    if {[info exists skip]} {
	error "Missing value for option: $arg"
    }

    foreach var {port listen local} {
	# FRINK: nocheck
	if {[info exists $var] && [set $var] != $comm($chan,$var)} {
	    incr force
	    # FRINK: nocheck
	    set comm($chan,$var) [set $var]
	}
    }

    # do not re-init socket
    if {!$force} {return ""}

    # User is recycling object, possibly to change from local to !local
    if {[info exists comm($chan,socket)]} {
	commAbort
	catch {close $comm($chan,socket)}
	unset comm($chan,socket)
    }

    set comm($chan,socket) ""
    if {!$comm($chan,listen)} {
	set comm($chan,port) 0
	return ""
    }

    if {[info exists port] && [string match "" $comm($chan,port)]} {
	set nport [incr comm(lastport)]
    } else {
	set userport 1
	set nport $comm($chan,port)
    } 
    while {1} {
	set cmd [list socket -server [list ::comm::commIncoming $chan]]
	if {$comm($chan,local)} {
	    lappend cmd -myaddr $comm(localhost)
	}
	lappend cmd $nport
	if {![catch $cmd ret]} {
	    break
	}
	if {[info exists userport] || ![string match "*already in use" $ret]} {
	    # don't erradicate the class
	    if {![string match ::comm::comm $chan]} {
		rename $chan {}
	    }
	    error $ret
	}
	set nport [incr comm(lastport)]
    }
    set comm($chan,socket) $ret

    # If port was 0, system allocated it for us
    set comm($chan,port) [lindex [fconfigure $ret -sockname] 2]
    return ""
}

# ::comm::commBool --
#
#	Internal command. Used by commConfigure to process boolean values.
#
# Arguments:
#	b	Value to process.
#
# Results:
#	bool	0 - false, 1 - true

proc ::comm::commBool {b} {
    switch -glob -- $b 0 - {[fF]*} - {[oO][fF]*} {return 0}
    return 1
}

# ::comm::commConnect --
#
#	Internal command. Called to connect to a remote interp
#
# Arguments:
#	id	Specification of the location of the remote interp.
#		A list containing either one or two elements.
#		One element = port, host is localhost.
#		Two elements = port and host, in this order.
#
# Results:
#	fid	channel handle of the socket the connection goes through.

proc ::comm::commConnect {id} {
    upvar chan chan
    variable comm

    commDebug {puts stderr "commConnect $id"}

    # process connecting hook now
    if {[info exists comm($chan,hook,connecting)]} {
    	eval $comm($chan,hook,connecting)
    }

    if {[info exists comm($chan,peers,$id)]} {
	return $comm($chan,peers,$id)
    }
    if {[lindex $id 0] == 0} {
	error "Remote comm is anonymous; cannot connect"
    }

    if {[llength $id] > 1} {
	set host [lindex $id 1]
    } else {
	set host $comm(localhost)
    }
    set port [lindex $id 0]
    set fid [socket $host $port]

    # process connected hook now
    if {[info exists comm($chan,hook,connected)]} {
    	if {[catch $comm($chan,hook,connected) err]} {
	    global errorInfo
	    set ei $errorInfo
	    close $fid
	    error $err $ei
	}
    }

    # commit new connection
    commNewConn $id $fid

    # send offered protocols versions and id to identify ourselves to remote
    puts $fid [list $comm(offerVers) $comm($chan,port)]
    set comm($chan,vers,$id) $comm(defVers)		;# default proto vers
    flush  $fid
    return $fid
}

# ::comm::commIncoming --
#
#	Internal command. Called for an incoming new connection.
#	Handles connection setup and initialization.
#
# Arguments:
#	chan	logical channel handling the connection.
#	fid	channel handle of the socket running the connection.
#	addr	ip address of the socket channel 'fid'
#	remport	remote port for the socket channel 'fid'
#
# Results:
#	None.

proc ::comm::commIncoming {chan fid addr remport} {
    variable comm

    commDebug {puts stderr "commIncoming $chan $fid $addr $remport"}

    # process incoming hook now
    if {[info exists comm($chan,hook,incoming)]} {
    	if {[catch $comm($chan,hook,incoming) err]} {
	    global errorInfo
	    set ei $errorInfo
	    close $fid
	    error $err $ei
	}
    }

    # a list of offered proto versions is the first word of first line
    # remote id is the second word of first line
    # rest of first line is ignored
    set protoline [gets $fid]
    set offeredvers [lindex $protoline 0]
    set remid [lindex $protoline 1]

    # use the first supported version in the offered list
    foreach v $offeredvers {
	if {[info exists comm($v,vers)]} {
	    set vers $v
	    break
	}
    }
    if {![info exists vers]} {
	close $fid
	error "Unknown offered protocols \"$protoline\" from $addr/$remport"
    }

    # If the remote host addr isn't our local host addr,
    # then add it to the remote id.
    if {[string compare [lindex [fconfigure $fid -sockname] 0] $addr]} {
	set id [list $remid $addr]
    } else {
	set id $remid
    }

    # Detect race condition of two comms connecting to each other
    # simultaneously.  It is OK when we are talking to ourselves.

    if {[info exists comm($chan,peers,$id)] && $id != $comm($chan,port)} {

	puts stderr "commIncoming race condition: $id"
	puts stderr "peers=$comm($chan,peers,$id) port=$comm($chan,port)"

	# To avoid the race, we really want to terminate one connection.
	# However, both sides are commited to using it.  commConnect
	# needs to be sychronous and detect the close.
	# close $fid
	# return $comm($chan,peers,$id)
    }

    # Make a protocol response.  Avoid any temptation to use {$vers > 2}
    # - this forces forwards compatibility issues on protocol versions
    # that haven't been invented yet.  DON'T DO IT!  Instead, test for
    # each supported version explicitly.  I.e., {$vers >2 && $vers < 5} is OK.

    switch $vers {
	3 {				
	    # Respond with the selected version number
	    puts  $fid [list [list vers $vers]]
	    flush $fid
	}
    }

    # commit new connection
    commNewConn $id $fid
    set comm($chan,vers,$id) $vers
}

# ::comm::commNewConn --
#
#	Internal command. Common new connection processing
#
# Arguments:
#	id	Reference to the remote interp
#	fid	channel handle of the socket running the connection.
#
# Results:
#	None.

proc ::comm::commNewConn {id fid} {
    upvar chan chan
    variable comm

    commDebug {puts stderr "commNewConn $id $fid"}

    # There can be a race condition two where comms connect to each other
    # simultaneously.  This code favors our outgoing connection.

    if {[info exists comm($chan,peers,$id)]} {
	# abort this connection, use the existing one
	# close $fid
	# return -code return $comm($chan,peers,$id)
    } else {
	set comm($chan,pending,$id) {}
    	set comm($chan,peers,$id) $fid
    }
    set comm($chan,fids,$fid) $id
    fconfigure $fid -trans binary -blocking 0
    fileevent $fid readable [list ::comm::commCollect $chan $fid]
}

# ::comm::commShutdown --
#
#	Internal command. Close down a peer connection.
#	Implements the 'comm shutdown' method.
#
# Arguments:
#	id	Reference to the remote interp
#
# Results:
#	None.

proc ::comm::commShutdown {id} {
    upvar chan chan
    variable comm

    if {[info exists comm($chan,peers,$id)]} {
	commLostConn $comm($chan,peers,$id) "Connection shutdown by request"
    }
}

# ::comm::commAbort --
#
#	Internal command. Close down all peer connections.
#	Implements the 'comm abort' method.
#
# Arguments:
#	None.
#
# Results:
#	None.

proc ::comm::commAbort {} {
    upvar chan chan
    variable comm

    foreach pid [array names comm $chan,peers,*] {
	commLostConn $comm($pid) "Connection aborted by request"
    }
}

# ::comm::commLostConn --
#
#	Internal command. Called to tidy up a lost connection,
#	including aborting ongoing sends. Each send should clean
#	themselves up in pending/result.
#
# Arguments:
#	fid	Channel handle of the socket which got lost.
#	reason	Message describing the reason of the loss.
#
# Results:
#	reason

proc ::comm::commLostConn {
    fid {reason "target application died or connection lost"}
} {
    upvar chan chan
    variable comm

    commDebug {puts stderr "commLostConn $fid $reason"}

    catch {close $fid}

    set id $comm($chan,fids,$fid)

    foreach s $comm($chan,pending,$id) {
	set comm($chan,return,$s) {-code error}
	set comm($chan,result,$s) $reason
    }
    unset comm($chan,pending,$id)
    unset comm($chan,fids,$fid)
    catch {unset comm($chan,peers,$id)}		;# race condition
    catch {unset comm($chan,buf,$fid)}

    # process lost hook now
    catch {catch $comm($chan,hook,lost)}

    return $reason
}

###############################################################################

# ::comm::commHook --
#
#	Internal command. Implements 'comm hook'.
#
# Arguments:
#	hook	hook to modify
#	script	Script to add/remove to/from the hook
#
# Results:
#	None.

proc ::comm::commHook {hook {script +}} {
    upvar chan chan
    variable comm
    if {![info exists comm($hook,hook)]} {
	error "Unknown hook invoked"
    }
    if {!$comm($hook,hook)} {
	error "Unimplemented hook invoked"
    }
    if {[string match + $script]} {
	if {[catch {set comm($chan,hook,$hook)} ret]} {
	    return ""
	}
	return $ret
    }
    if {[string match +* $script]} {
	append comm($chan,hook,$hook) \n [string range $script 1 end]
    } else {
	set comm($chan,hook,$hook) $script
    }
    return ""
}

###############################################################################

# ::comm::commCollect --
#
#	Internal command. Called from the fileevent to read from fid
#	and append to the buffer. This continues until we get a whole
#	command, which we then invoke.
#
# Arguments:
#	chan	logical channel collecting the data
#	fid	channel handle of the socket we collect.
#
# Results:
#	None.

proc ::comm::commCollect {chan fid} {
    variable comm
    upvar #0 comm($chan,buf,$fid) data

    # Tcl8 may return an error on read after a close
    if {[catch {read $fid} nbuf] || [eof $fid]} { 
	fileevent $fid readable {}		;# be safe
	commLostConn $fid
	return
    }
    append data $nbuf

    commDebug {puts stderr "collect <$data>"}

    # If data contains at least one complete command, we will
    # be able to take off the first element, which is a list holding
    # the command.  This is true even if data isn't a well-formed
    # list overall, with unmatched open braces.  This works because
    # each command in the protocol ends with a newline, thus allowing
    # lindex and lreplace to work.
    #
    # This isn't true with Tcl8.0, which will return an error until
    # the whole buffer is a valid list.  This is probably OK, although
    # it could potentially cause a deadlock.

    while {![catch {set cmd [lindex $data 0]}]} {
	commDebug {puts stderr "cmd <$data>"}
	if {[string match "" $cmd]} break
	if {[info complete $cmd]} {
	    set data [lreplace $data 0 0]
	    after idle \
		    [list ::comm::commExec $chan $fid $comm($chan,fids,$fid) $cmd]
	}
    }
}

# ::comm::commExec --
#
#	Internal command. Receives and executes a remote command,
#	returning the result and/or error. Unknown protocol commands
#	are silently discarded
#
# Arguments:
#	chan		logical channel collecting the data
#	fid		channel handle of the socket we collect.
#	remoteid	id of the other side.
#	buf		buffer containing the command to execute.
#
# Results:
#	None.

proc ::comm::commExec {chan fid remoteid buf} {

    # buffer should contain:
    #	send # {cmd}		execute cmd and send reply with serial #
    #	async # {cmd}		execute cmd but send no reply
    #	reply # {cmd}		execute cmd as reply to serial #
    
    variable comm

    # these variables are documented in the hook interface
    set cmd [lindex $buf 0]
    set ser [lindex $buf 1]
    set buf [lrange $buf 2 end]
    set buffer [lindex $buf 0]

    # Save remoteid for "comm remoteid".  This will only be valid
    # if retrieved before any additional events occur # on this channel.   
    # N.B. we could have already lost the connection to remote, making
    # this id be purely informational!
    set comm($chan,remoteid) [set id $remoteid]

    commDebug {puts stderr "exec <$cmd,$ser,$buf>"}

    switch -- $cmd {
	send - async {}
	reply {
	    if {![info exists comm($chan,return,$ser)]} {
	        commDebug {puts stderr "No one waiting for serial \"$ser\""}
		return
	    }

	    # Decompose reply command to assure it only uses "return"
	    # with no side effects.

	    array set return {-code "" -errorinfo "" -errorcode ""}
	    set ret [lindex $buffer end]
	    set len [llength $buffer]
	    incr len -2
	    foreach {sw val} [lrange $buffer 1 $len] {
		if {![info exists return($sw)]} continue
		set return($sw) $val
	    }

	    if {[info exists comm($chan,hook,reply)]} {
		catch $comm($chan,hook,reply)
	    }

	    # this wakes up the sender
	    commDebug {puts stderr "--<<wakeup $chan $ser>>--"}
	    set comm($chan,result,$ser) $ret
	    set comm($chan,return,$ser) [array get return]
	    return
	}
	vers {
	    set ::comm::comm($chan,vers,$id) $ser
	    return
	}
	default {
	    commDebug {puts stderr "unknown command; discard \"$cmd\""}
	    return
	}
    }

    # process eval hook now
    if {[info exists comm($chan,hook,eval)]} {
    	set err [catch $comm($chan,hook,eval) ret]
	commDebug {puts stderr "eval hook res <$err,$ret>"}
	switch $err {
	    1 {				;# error
		set done 1
	    }
	    2 - 3 {			;# return / break
		set err 0
		set done 1
	    }
	}
    }

    # exec command
    if {![info exists done]} {
	# Sadly, the uplevel needs to be in the catch to access the local
	# variables buffer and ret.  These cannot simply be global because
	# commExec is reentrant (i.e., they could be linked to an allocated
	# serial number).
	set err [catch [concat uplevel #0 $buffer] ret]
    }

    commDebug {puts stderr "res <$err,$ret>"}

    # The double list assures that the command is a single list when read.
    if {[string match send $cmd]} {
	# The catch here is just in case we lose the target.  Consider:
	#	comm send $other comm send [comm self] exit
	catch {
	    set return return
	    # send error or result
	    switch $err {
		0 {}
		1 {
		    global errorInfo errorCode
		    lappend return -code $err \
			    -errorinfo $errorInfo \
			    -errorcode $errorCode
		}
		default { lappend return -code $err}
	    }
	    lappend return $ret
	    puts $fid [list [list reply $ser $return]]
	    flush $fid
	}
    }

    if {$err == 1} {
	# SF Tcllib Patch #526499
	# (See http://sourceforge.net/tracker/?func=detail&aid=526499&group_id=12883&atid=312883
	#  for initial request and comments)
	#
	# Error in async call. Look for [bgerror] to report it. Same
	# logic as in Tcl itself. Errors thrown by bgerror itself get
	# reported to stderr.

	if {[catch {
	    bgerror $ret
	} msg]} {
	    puts stderr "bgerror failed to handle background error."
	    puts stderr "    Original error: $ret"
	    puts stderr "    Error in bgerror: $msg"
	    flush stderr
	}
    }
    return
}

###############################################################################
#
# Finish creating "comm" using the default port for this interp.
#

if {![info exists ::comm::comm(comm,port)]} {
    if {[string match macintosh $tcl_platform(platform)]} {
	::comm::comm new ::comm::comm -port 0 -local 0 -listen 1
	set ::comm::comm(localhost) \
		[lindex [fconfigure $::comm::comm(comm,socket) -sockname] 0]
	::comm::comm config -local 1
    } else {
	::comm::comm new ::comm::comm -port 0 -local 1 -listen 1
    }
}

#eof
package provide comm 4.0.1
