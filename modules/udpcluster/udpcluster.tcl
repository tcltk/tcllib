# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Cluster

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.5
package require comm             ; # Generic message transport
package require interp           ; # Interpreter helpers.
package require logger           ; # Tracing internal activity
package require uuid
package require cron
package require nettool 0.4
package require udp
package require dicttool

namespace eval ::comm {}
::namespace eval ::cluster {}

###
# This package implements an ad/hoc zero configuration
# like network of comm (and other) network connections
###

###
# topic: 5cffdc91e554c923ebe43df13fac77d5
###
proc ::cluster::broadcast {args} {
  if {$::cluster::config(debug)} {
    puts [list $::cluster::local_pid SEND $args]
  }
  variable discovery_port
  listen
  while {[catch {

    foreach net [::nettool::broadcast_list] {
      if {$::cluster::config(debug)} {
        puts [list BROADCAST -> $net $args]
      }
      set s [udp_open]
      udp_conf $s $net $discovery_port
      puts -nonewline $s [list [pid] {*}$args]
      chan flush $s
      chan close $s
    }
    #set sock [listen]
    #puts -nonewline $sock [list [pid] {*}$args]
    #flush $sock
  } error]} {
    set ::cluster::broadcast_sock {}
    if {$::cluster::config(debug)} {
      puts "Broadcast ERR: $error - Reopening Socket"
      ::cluster::sleep 2000
    } else {
      # Double the delay
      ::cluster::sleep 250
    }
  }
}

###
# topic: 963e24601d0dc61580c9727a74cdba67
###
proc ::cluster::cname rawname {
  # Convert rawname to a canonical name
  if {[string first @ $rawname] < 0 } {
    return $rawname
  }
  lassign [split $rawname @] service host
  if {$host eq {}} {
    set host *
  }
  if {$host in {local localhost}} {
    set host [::cluster::self]
  }
  return $service@$host
}

###
# topic: 3f5f9e197cc9666dd7953d97fef34019
###
proc ::cluster::ipaddr macid {
  # Convert rawname to a canonical name
  if {$macid eq [::cluster::self]} {
    return 127.0.0.1
  }
  foreach {servname dat} [search [cname *@$macid]] {
    if {[dict exists $dat ipaddr]} {
      return [dict get $dat ipaddr]
    }
  }
  ###
  # Do a lookup
  ###
  error "Could not locate $macid"
}

###
# topic: e57db306f0e931d7febb5ad1f9cb2247
###
proc ::cluster::listen {} {
  variable broadcast_sock
  if {$broadcast_sock != {}} {
    return $broadcast_sock
  }

  variable discovery_port 
  #foreach net [::nettool::broadcast_list] {
  #  set s [udp_open $discovery_port reuse]
  #
  #    if {$::cluster::config(debug)} {
  #      puts [list BROADCAST -> $net $args]
  #    }
  #    set s [udp_open]
  #    udp_conf $s $net $discovery_port
  #    puts -nonewline $s [list [pid] {*}$args]
  #    chan flush $s
  #    chan close $s
  #  }
  
  # Open a local discovery port to catch non-IP traffic
  variable discovery_group
  set broadcast_sock [udp_open $discovery_port reuse]
  fconfigure $broadcast_sock -buffering none -blocking 0 \
    -broadcast 1 \
    -mcastadd $discovery_group \
    -remote [list $discovery_group $discovery_port]
  fileevent $broadcast_sock readable [list [namespace current]::UDPPacket $broadcast_sock]
  ::cron::every cluster_heartbeat 30 ::cluster::heartbeat
  
  return $broadcast_sock
}

###
# topic: 2a33c825920162b0791e2cdae62e6164
###
proc ::cluster::UDPPacket sock {
  variable ptpdata
  set pid [pid]
  set packet [string trim [read $sock]]
  set peer [fconfigure $sock -peer]

  if {![string is ascii $packet]} return
  if {![::info complete $packet]} return

  set sender  [lindex $packet 0]
  if {$::cluster::config(debug)} {
    puts [list $::cluster::local_pid RECV $peer $packet]
  }
  if { $sender eq [pid] } {
    # Ignore messages from myself
    return
  }
  set ipaddr [lindex $peer 0]
  set messagetype [string toupper [lindex $packet 1]]

  # These two message types are not associated with a service
  switch -- $messagetype {
    DISCOVERY {
      variable config
      ::cluster::heartbeat
      return
    }
    ?WHOIS {
      set wmacid [lindex $messageinfo 0]
      if { $wmacid eq [::cluster::self] } {
        broadcast +WHOIS [::cluster::self]
      }
      return
    }
  }
  
  set now [clock seconds]
  set serviceurl  [lindex $packet 2]
  set serviceinfo [lindex $packet 3]
  set ::cluster::ping_recv($serviceurl) $now

  if {[dict exists $serviceinfo pid] && [dict get $serviceinfo pid] eq [pid] } {
    # Ignore attempts to overwrite locally managed services from the network
    return
  }
  # Always update the IP of the service info
  dict set ptpdata($serviceurl) ipaddr $ipaddr
  dict set ptpdata($serviceurl) updated $now
  dict set serviceinfo ipaddr [lindex $peer 0]
  dict set serviceinfo updated $now
  set messageinfo [lrange $packet 4 end]
  
  switch -- $messagetype {
    -SERVICE {
      if {![::info exists ptpdata($serviceurl)]} {
        set result $serviceinfo
      } else {
        set result [dict merge $ptpdata($serviceurl) $serviceinfo]
      }
      dict set result closed 1
      if {[dict exists $result pid] && [dict get $result pid] eq [pid] } {
        # Ignore attempts to overwrite locally managed services from the network
        return
      }
      set ptpdata($serviceurl) $result
      Service_Remove $serviceurl $result
    }
    PONG -
    ~SERVICE {
      set ::cluster::recv_message 1

      if {[::info exists ptpdata($serviceurl)]} {
        set ptpinfo $ptpdata($serviceurl)
      } else {
        set ptpinfo {}
      }
      set delta {}
      foreach {field value} $serviceinfo {
        if {![dict exists $ptpinfo $field] || [dict get $ptpinfo $field] ne $value} {
          dict set ptpdata($serviceurl) $field $value
          dict set delta $field $value
        }
      }
      dict set ptpdata($serviceurl) closed 0
      Service_Modified $serviceurl $serviceinfo $delta
    }
    +SERVICE {
      set ::cluster::recv_message 1
      # Code to register the presence of a service
      variable ptpdata
      set ptpdata($serviceurl) $serviceinfo
      dict set ptpdata($serviceurl) closed 0
      Service_Add $serviceurl $serviceinfo
    }
    LOG {
      Service_Log $serviceurl $serviceinfo
    }
    PING {
      foreach {url info} [search_local $serviceurl] {
        broadcast PONG $url $info
      }
    }
  }
}

proc ::cluster::ping {rawname} {
  set rcpt [cname $rawname]
  variable ptpdata
  set starttime [clock seconds]

  set ::cluster::ping_recv($rcpt) 0
  broadcast PING $rcpt
  update
  while 1 {
    if {$::cluster::ping_recv($rcpt)} break
    if {([clock seconds] - $starttime) > $::cluster::config(ping_timeout)} {
      error "Could not locate $rcpt on the network"
    }
    broadcast PING $rcpt
    sleep $::cluster::config(ping_sleep)
  }
  if {[::info exists ptpdata($rcpt)]} {
    return [dict getnull $ptpdata($rcpt) ipaddr]
  }
}

proc ::cluster::publish {url infodict} {
  variable local_data
  dict set infodict macid [self]
  dict set infodict pid [pid]
  set local_data($url) [dict merge $infodict {ipaddr 127.0.0.1}]
  broadcast +SERVICE $url $infodict
}

proc ::cluster::heartbeat {} {
  variable ptpdata
  variable config
  
  _Winnow
  ###
  # Broadcast the status of our local services
  ###
  variable local_data
  foreach {url info} [array get local_data] {
    broadcast ~SERVICE $url $info
  }
  ###
  # Trigger any cluster events that haven't fired off
  ###
  foreach {eventid info} [array get ::cluster::events] {
    if {$info eq "-1"} {
      unset ::cluster::events($eventid)
    } else {
      lassign $info seconds ms
      if {$seconds < $now} {
        set ::cluster::events($eventid) -1
      }
    }
  }
}

proc ::cluster::info url {
  variable local_data
  return [array get local_data $url]
}

proc ::cluster::unpublish {url infodict} {
  variable local_data
  foreach {field value} $infodict {
    dict set local_data($url) $field $value
  }
  set info [lindex [array get local_data $url] 1]
  broadcast -SERVICE $url $info
  dict set local_data($url) closed 1
}

proc ::cluster::configure {url infodict {send 1}} {
  variable local_data
  if {![::info exists local_data($url)]} return
  dict set local_data($url) closed 0
  foreach {field value} $infodict {
    dict set local_data($url) $field $value
  }
  if {$send} {
    broadcast ~SERVICE $url $local_data($url)
    update
  }
}

proc ::cluster::get_free_port {{startport 50000}} {
  ::cluster::listen
  ::cluster::broadcast DISCOVERY
  after 10000 {set ::cluster::recv_message 0}
  # Wait for a pingback or timeout
  vwait ::cluster::recv_message
  cluster::sleep 2000
  
  set macid [::cluster::macid]
  set port $startport
  set conflict 1
  while {$conflict} {
    set conflict 0
    set port [::nettool::find_port $port]
    foreach {url info} [search *@[macid]] {
      if {[dict exists $info port] && [dict get $info port] eq $port} {
        incr port
        set conflict 1
        break
      }
    }
    update
  }
  return $port
}

proc ::cluster::log args {
  broadcast LOG {*}$args
}

###
# topic: 2c04e58c7f93798f9a5ed31a7f5779ab
###
proc ::cluster::resolve {rawname} {
  variable ptpdata
  set self [self]
  set rcpt [cname $rawname]
  set ipaddr {}
  if {[::info exists ptpdata($rcpt)] && [dict exists $ptpdata($rcpt) macid] && [dict get $ptpdata($rcpt) macid] eq $self} {
    set ipaddr 127.0.0.1
  } elseif {[::info exists ptpdata($rcpt)] && [dict exists $ptpdata($rcpt) ipaddr] && [dict exists $ptpdata($rcpt) updated]} {
    # Try Pull the info from cache
    set updatetm [dict get $ptpdata($rcpt) updated]
    if {([clock seconds] - $updatetm) < 30} {
      set ipaddr [dict get $ptpdata($rcpt) ipaddr]
    }
  }
  if {$ipaddr eq {}} {
    ping $rcpt
    if {![::info exists ptpdata($rcpt)]} {
      error "Could not locate $rcpt on the network"
    }
    if {[dict exists $ptpdata($rcpt) macid] && [dict get $ptpdata($rcpt) macid] eq $self} {
      set ipaddr 127.0.0.1
    } else {
      if {![dict exists $ptpdata($rcpt) ipaddr]} {
        error "Could not locate $rcpt on the network"
      }
      set ipaddr [dict getnull $ptpdata($rcpt) ipaddr]
      if {$ipaddr eq {}} {
        error "Could not locate $rcpt on the network"
      }
    }
  }
  set port [dict getnull $ptpdata($rcpt) port]
  if {$port eq {}} {
    error "Could not locate $rcpt on the network"
  }
  return [list $port $ipaddr]
}

###
# topic: 6c7a0a3a8cb2a7ae98ff0dba960c37a7
###
proc ::cluster::pid {} {
  variable local_pid
  return $local_pid
}

proc ::cluster::macid {} {
  variable local_macid
  return $local_macid
}

proc ::cluster::self {} {
  variable local_macid
  return $local_macid
}

###
# topic: f1b71ff12a8ac10373c67ac5d973cd81
###
proc ::cluster::send {service command args} {
  set commid [resolve $service]
  return [::comm::comm send $commid $command {*}$args]
}

proc ::cluster::throw {service command args} {
  if {[catch {resolve $service} commid]} {
    return
  }
  if [catch {::comm::comm send -async $commid $command {*}$args} reply] {
    puts $stderr "ERR: SEND $service $reply"
  }
}

proc ::cluster::sleep ms {
  set eventid [incr ::cluster::eventcount]
  set ::cluster::event($eventid) [list [clock seconds] [expr {[clock milliseconds]+$ms}]]
  after $ms set ::cluster::event($eventid) -1
  vwait ::cluster::event($eventid)
}

###
# topic: c8475e832c912e962f238c61580b669e
###
proc ::cluster::search pattern {
  _Winnow
  set result {}  
  variable ptpdata
  foreach {service dat} [array get ptpdata $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
    }
  }

  variable local_data
  foreach {service dat} [array get local_data $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
    }
  }
  return $result
}

proc ::cluster::is_local pattern {
  variable local_data
  if {[array exists local_data $pattern]} {
    return 1
  }
  if {[array exists local_data [cname $pattern]]} {
    return 1
  }
  return 0
}

proc ::cluster::search_local pattern {
  set result {}  
  variable local_data
  foreach {service dat} [array get local_data $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
    }
  }
  return $result
}

proc ::cluster::Service_Add {serviceurl serviceinfo} {
  # Code to register the emergencs of a new service
}

proc ::cluster::Service_Remove {serviceurl serviceinfo} {
  # Code to register the loss of a service
}

proc ::cluster::Service_Modified {serviceurl serviceinfo {delta {}}} {
  # Code to register an update to a service
}

proc ::cluster::Service_Log {service data delta} {
  # Code to register an event
}

###
# Clean out closed and expired entries
# Performed immediately before searches
# and heartbeats
###
proc ::cluster::_Winnow {} {
  variable ptpdata
  variable config
  variable local_data
  
  set now [clock seconds]
  foreach {item info} [array get ptpdata] {
    set remove 0
    if {[dict exists $info closed] && [dict get $info closed]} {
      set remove 1
    }
    if {[dict exists $info updated] && ($now - [dict get $info updated])>$config(discovery_ttl)} {
      set remove 1
    }
    if {$remove} {
      unset ptpdata($item)
    }
  }
  foreach {item info} [array get local_data] {
    set remove 0
    if {[dict exists $info closed] && [dict get $info closed]} {
      set remove 1
    }
    if {$remove} {
      unset local_data($item)
    }
  }
}

###
# topic: d3e48e31cc4baf81395179f4097fee1b
###
namespace eval ::cluster {
  # Number of seconds to "remember" data
  variable config
  array set config {
    debug 0
    discovery_ttl 300
    local_registry 0
    ping_timeout 120
    ping_sleep   250
  }
  variable eventcount 0
  variable cache {}
  variable broadcast_sock {}
  variable cache_maxage 500
  variable discovery_port 38573
  # Currently an unassigned group in the
  # Local Network Control Block (224.0.0/24)
  # See: RFC3692 and http://www.iana.org
  variable discovery_group 224.0.0.200
  variable local_port {}
  variable local_macid [lindex [::nettool::mac_list] 0]
  variable local_pid   [::uuid::uuid generate]
}

package provide udpcluster 0.3
