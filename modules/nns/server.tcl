# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Server (Singleton)

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.4
package require comm             ; # Generic message transport
package require interp           ; # Interpreter helpers.
package require logger           ; # Tracing internal activity
package require nameserv::common ; # Common/shared utilities

namespace eval ::nameserv::server {}

# ### ### ### ######### ######### #########
## API: Start, Stop

proc ::nameserv::server::start {} {
    variable comm
    variable port
    variable localonly

    log::debug "start"
    if {$comm ne ""} return

    log::debug "start /granted"

    set     interp [interp::createEmpty]
    foreach msg {
	Bind
	Release
	Search
	ProtocolVersion
	ProtocolFeatures
    } {
	interp alias $interp $msg {} ::nameserv::server::$msg
    }

    set comm [comm::comm new ::nameserv::server::COMM \
		  -interp $interp \
		  -port   $port \
		  -listen 1 \
		  -local  $localonly]

    $comm hook lost ::nameserv::server::LOST

    log::debug "UP @$port local-only $localonly"
    return
}

proc ::nameserv::server::stop {} {
    variable comm
    variable names
    variable data

    log::debug "stop"
    if {$comm eq ""} return

    log::debug "stop /granted"

    # This kills all existing connection and destroys the configured
    # -interp as well.

    $comm destroy
    set comm ""

    array unset names *
    array unset data  *

    log::debug "DOWN"
    return
}

proc ::nameserv::server::active? {} {
    variable comm
    return [expr {$comm ne ""}]
}

# ### ### ### ######### ######### #########
## INT: Protocol operations

proc ::nameserv::server::ProtocolVersion  {} {return 1}
proc ::nameserv::server::ProtocolFeatures {} {return {Core}}

proc ::nameserv::server::Bind {name cdata} {
    variable comm
    variable names
    variable data

    set id [$comm remoteid]

    log::debug "bind [list $name $cdata], for $id"

    if {[info exists data($name)]} {
	return -code error "Name \"$name\" is already bound"
    }

    lappend names($id)  $name
    set     data($name) $cdata
    return
}

proc ::nameserv::server::Release {} {
    variable comm
    ReleaseId [$comm remoteid]
    return
}

proc ::nameserv::server::Search {pattern} {
    variable data
    return [array get data $pattern]
}

proc ::nameserv::server::ReleaseId {id} {
    variable names
    variable data

    log::debug "release id $id"

    if {![info exists names($id)]} return

    foreach n $names($id) {catch {unset data($n)}}
    unset names($id)
    return
}

# ### ### ### ######### ######### #########
## Initialization - In-memory database

namespace eval ::nameserv::server {
    # Database
    # array (id   -> list (name)) : Names under which a connection is known.
    # array (name -> data)        : Data associated with a name.

    variable names ; array set names {}
    variable data  ; array set data  {}
}

# ### ### ### ######### ######### #########
## INT: Connection management

proc ::nameserv::server::LOST {args} {
    # Currently just to see when a client goes away.

    upvar 1 id id chan chan reason reason

    puts LOST/$args/[list $id $chan $reason]

    ReleaseId $id
    return
}

# ### ### ### ######### ######### #########
## Initialization - System state

namespace eval ::nameserv::server {
    # Object command of the communication channel of the server.
    # If present re-configuration is not possible.

    variable comm {}
}

# ### ### ### ######### ######### #########
## API: Configuration management (host, port)

proc ::nameserv::server::cget {option} {
    return [configure $option]
}

proc ::nameserv::server::configure {args} {
    variable localonly
    variable port
    variable comm

    if {![llength $args]} {
	return [list -local $localonly -port $port]
    }
    if {[llength $args] == 1} {
	# cget
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -local { return $localonly }
	    -port  { return $port }
	    default {
		return -code error "bad option \"$opt\", expected -local, or -port"
	    }
	}
    }

    # Note: Should -port be made configurable after communication has
    # started it might be necessary to provide code to re-initialize
    # the connections to all known clients using the new
    # configuration.

    while {[llength $args]} {
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -local {
		if {[llength $args] % 2 == 1} {
		    return -code error "value for \"$opt\" is missing"
		}
		# Todo: Check boolean 
		set new  [lindex $args 1]
		set args [lrange $args 2 end]

		if {$new == $localonly} continue
		set localonly $new
		if {$comm eq ""} continue
		$comm configure -local $localonly
	    }
	    -port {
		if {$comm ne ""} {
		    return -code error "Unable to configure an active server"
		}
		if {[llength $args] % 2 == 1} {
		    return -code error "value for \"$opt\" is missing"
		}
		# Todo: Check non-zero unsigned short integer
		set port [lindex $args 1]
		set args [lrange $args 2 end]
	    }
	    default {
		return -code error "bad option \"$opt\", expected -local, or -port"
	    }
	}
    }
    return
}

# ### ### ### ######### ######### #########
## Initialization - Tracing, Configuration

logger::initNamespace ::nameserv::server
namespace eval        ::nameserv::server {
    # Port the server will listen on, and boolean flag determining
    # acceptance of non-local connections.

    variable port      [nameserv::common::port]
    variable localonly 1
}

# ### ### ### ######### ######### #########
## Ready

package provide nameserv::server 0.1

##
# ### ### ### ######### ######### #########
