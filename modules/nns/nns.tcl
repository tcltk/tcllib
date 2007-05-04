# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Client side access

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.4
package require comm             ; # Generic message transport
package require logger           ; # Tracing internal activity
package require nameserv::common ; # Common/shared utilities

namespace eval ::nameserv {}

# ### ### ### ######### ######### #########
## API: Write, Read, Search

proc ::nameserv::bind {name data} {
    # Registers this application at the configured name service under
    # the specified name, and provides a value.
    #
    # Note: The application is allowed register multiple names.
    #
    # Note: A registered name is automatically removed by the server
    #       when the connection to it collapses.

    DO Bind $name $data
    return
}

proc ::nameserv::release {} {
    # Releases all names the application is registered under
    # at the configured name service.

    DO Release
    return
}

proc ::nameserv::search {{pattern *}} {
    # Searches the configured name service for applications whose name
    # matches the given pattern. Returns a dictionary mapping from the
    # names to the data they provided at 'bind' time.

    return [DO Search $pattern]
}

proc ::nameserv::protocol {} {
    return 1
}

proc ::nameserv::server_protocol {} {
    return [DO ProtocolVersion]
}

proc ::nameserv::server_features {} {
    return [DO ProtocolFeatures]
}

# ### ### ### ######### ######### #########
## INT: Communication setup / teardown / use

proc ::nameserv::DO {args} {
    variable sid
    log::debug [linsert $args end @ $sid]

    if {[catch {
	[SERV] send $sid $args
	#eval [linsert $args 0 [SERV] send $sid] ;# $args
    } msg]} {
	if {[string match "*refused*" $msg]} {
	    return -code error "No name server present @ $sid"
	} else {
	    return -code error $msg
	}
    }
    # Result of the call
    return $msg
}

proc ::nameserv::SERV {} {
    variable comm
    variable sid
    variable host
    variable port
    if {$comm ne ""} {return $comm}

    # NOTE
    # -local 1 means that clients can only talk to a local
    #          name service. Might make sense to auto-force
    #          -local 0 for host ne "localhost".

    set sid  [list $port $host]
    set comm [comm::comm new ::nameserv::CSERV \
		  -local  1 \
		  -listen 1]

    $comm hook lost ::nameserv::LOST

    log::debug [list SERV @ $sid : $comm]
    return $comm
}

proc ::nameserv::LOST {args} {
    upvar 1 id id chan chan reason reason

    puts LOST/$args/[list $id $chan $reason]

    variable comm ; $comm destroy ; set comm {}
    log::debug [list LOST @ $sid]
    variable sid  ;		    set sid  {}
    return
}

# ### ### ### ######### ######### #########
## Initialization - System state

namespace eval ::nameserv {
    # Object command of the communication channel to the server.
    # If present re-configuration is not possible. Also the comm
    # id of the server.

    variable comm {}
    variable sid  {}
}

# ### ### ### ######### ######### #########
## API: Configuration management (host, port)

proc ::nameserv::cget {option} {
    return [configure $option]
}

proc ::nameserv::configure {args} {
    variable host
    variable port

    if {![llength $args]} {
	return [list -host $host -port $port]
    }
    if {[llength $args] == 1} {
	# cget
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -host { return $host }
	    -port { return $port }
	    default {
		return -code error "bad option \"$opt\", expected -host, or -port"
	    }
	}
    }

    if {$comm ne ""} {
	return -code error "Unable to configure an active connection"
    }

    # Note: Should -port/-host be made configurable after
    # communication has started it will be necessary to provide code
    # which retracts everything from the old server and re-initializes
    # the new one.

    while {[llength $args]} {
	set opt [lindex $args 0]
	switch -exact -- $opt {
	    -host {
		if {[llength $args] % 2 == 1} {
		    return -code error "value for \"$opt\" is missing"
		}
		set host [lindex $args 1]
		set args [lrange $args 2 end]
	    }
	    -port {
		if {[llength $args] % 2 == 1} {
		    return -code error "value for \"$opt\" is missing"
		}
		set port [lindex $args 1]
		# Todo: Check non-zero unsigned short integer
		set args [lrange $args 2 end]
	    }
	    default {
		return -code error "bad option \"$opt\", expected -host, or -port"
	    }
	}
    }
    return
}

# ### ### ### ######### ######### #########
## Initialization - Tracing, Configuration

logger::initNamespace ::nameserv
namespace eval        ::nameserv {
    # Host and port to connect to, to get access to the nameservice.

    variable host localhost
    variable port [nameserv::common::port]
}

# ### ### ### ######### ######### #########
## Ready

package provide nameserv 0.1

##
# ### ### ### ######### ######### #########
