# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Cluster

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.6
package require uuid
package require cron 2.0
package require nettool 0.5.3
package require udp
package provide udpcluster 0.4

###
# This package implements an ad/hoc zero configuration
# like network of comm (and other) network connections
###
::namespace eval ::cluster {}
::namespace eval ::cluster::directory {}

proc ::cluster::directory::alloc_port {{port 50000}} {
  if {$port in {{} 0 -1}} {
    set port 50000
  }
  set conflict 1
  while {$conflict} {
    set conflict 0
    set port [::nettool::find_port $port]
    foreach {url info} [search *@[::cluster::macid]] {
      if {[dict exists $info port] && [dict get $info port] eq $port} {
        incr port
        set conflict 1
        break
      }
    }
    if {$port >= 65336 } {
      error "All ports consumed"
    }
  }
  ::nettool::claim_port $port
  return $port
}

proc ::cluster::directory::broadcast {args} {
  if {$::cluster::config(debug)} {
    puts [list $::cluster::local_pid SEND $args]
  }
  foreach net [broadcast_list]  {
    if {$::cluster::config(debug)} {
      puts [list BROADCAST -> $net $args]
    }
    set s [udp_open]
    udp_conf $s $net $::cluster::discovery_port
    udp_conf $s -broadcast 1
    chan puts -nonewline $s [list $::cluster::local_pid {*}$args]
    chan flush $s
    chan close $s
  }
}

proc ::cluster::directory::broadcast_list {} {
  variable broadcast_timestamp
  variable broadcast_list
  if {([clock seconds]-$broadcast_timestamp) > 900} {
    set broadcast_list [::nettool::broadcast_list]
  }
  return $broadcast_list
}
proc ::cluster::_Cleanup {} {
  ###
  # Clean out closed and expired entries
  # Performed immediately before searches
  # and heartbeats
  ###
  foreach {item info} [array get ::cluster::local_data] {
    set remove 0
    if {[dict exists $info closed] && [dict get $info closed]} {
      set remove 1
    }
    if {$remove} {
      unset ::cluster::local_data($item)
    }
  }
  set ttl $::cluster::config(discovery_ttl)
  set now [clock seconds]
  foreach {item info} [array get ::cluster::directory::ptpdata] {
    set remove 0
    if {[dict exists $info closed] && [dict get $info closed]} {
      set remove 1
    }
    if {[dict exists $info updated] && ($now - [dict get $info updated])>$ttl} {
      set remove 1
    }
    if {$remove} {
      unset ::cluster::directory::ptpdata($item)
    }
  }
  foreach {item info} [array get ::cluster::directory::directory_data] {
    set remove 0
    if {[dict exists $info closed] && [dict get $info closed]} {
      set remove 1
    }
    if {$remove} {
      unset ::cluster::directory::directory_data($item)
    }
  }
}

proc ::cluster::directory::_Heartbeat {} {
  variable directory_data
  foreach {url info} [array get directory_data] {
    broadcast ~SERVICE $url $info
  }
}
proc ::cluster::directory::ipaddr macid {
  if {$macid eq [::cluster::self]} {
    return 127.0.0.1
  }
  foreach {servname dat} [search [::cluster::cname *@$macid]] {
    if {[dict exists $dat ipaddr]} {
      return [dict get $dat ipaddr]
    }
  }
  return [ping *@$macid]
}

proc ::cluster::directory::ping {rawname {timeout -1}} {
  variable ptpdata
  set rcpt [::cluster::cname $rawname]
  set starttime [clock seconds]
  set macid [lindex [split $rcpt @] 1]
  if {$macid eq $::cluster::local_macid} {
    return 127.0.0.1
  }
  set ::cluster::ping_recv($rcpt) 0
  broadcast PING $rcpt
  ::cron::sleep 1
  if {$timeout <= 0} {
    set timeout $::cluster::config(ping_timeout)
  }
  while 1 {
    if {$::cluster::ping_recv($rcpt)} break
    if {([clock seconds] - $starttime) > $timeout} {
      error "Could not locate $rcpt on the network"
    }
    broadcast PING $rcpt
    ::cron::sleep $::cluster::config(ping_sleep)
  }
  if {[::info exists ptpdata($rcpt)]} {
    return [dict getnull $ptpdata($rcpt) ipaddr]
  }
}

proc ::cluster::directory::port_busy port {
  return [::nettool::port_busy $port]
}

proc ::cluster::directory::pid {} {
  return $::cluster::local_pid
}

proc ::cluster::directory::resolve {rawname} {
  variable ptpdata
  variable directory_data
  set self [::cluster::macid]
  set rcpt [::cluster::cname $rawname]
  set ipaddr {}
  if {[::info exists directory_data($rcpt)]} {
    set port [dict getnull $directory_data($rcpt) port]
    return [list $port 127.0.0.1]
  }
  if {[::info exists ptpdata($rcpt)]} {
    # Try Pull the info from cache
    set ipaddr [dict get $ptpdata($rcpt) ipaddr]
    set port [dict get $ptpdata($rcpt) port]
    return [list $port $ipaddr]
  }
  ping $rcpt 1
  if {![::info exists ptpdata($rcpt)]} {
    return {}
  }
  return [list [dict get $ptpdata($rcpt) port] [dict get $ptpdata($rcpt) ipaddr]]
}

proc ::cluster::directory::directory_data {} {
  variable directory_data
  return [array get directory_data]
}

proc ::cluster::directory::ptp_data {} {
  variable ptpdata
  return [array get ptpdata]
}

proc ::cluster::directory::search pattern {
  ::cluster::_Cleanup
  variable directory_data
  variable ptpdata
  set result {}
  foreach {service dat} [array get ptpdata $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
    }
  }
  foreach {service dat} [array get directory_data $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
      dict set result $service ipaddr 127.0.0.1
    }
  }
  return $result
}
proc ::cluster::directory::search_directory pattern {
  ::cluster::_Cleanup
  variable directory_data
  set result {}
  foreach {service dat} [array get directory_data $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
      dict set result $service ipaddr 127.0.0.1
    }
  }
  return $result
}
proc ::cluster::directory::service_publish {url infodict} {
  variable directory_data
  set directory_data($url) [dict merge $infodict {ipaddr 127.0.0.1}]
  broadcast +SERVICE $url $infodict
}
proc ::cluster::directory::service_update {url infodict} {
  variable directory_data
  set directory_data($url) [dict merge $infodict {ipaddr 127.0.0.1}]
  broadcast ~SERVICE $url $infodict
}
proc ::cluster::directory::service_unpublish {url infodict} {
  variable directory_data
  set directory_data($url) [dict merge $infodict {closed 1}]
  broadcast -SERVICE $url $infodict
}
proc ::cluster::directory::TCPAccept {sock host port} {
  chan configure $sock -translation {crlf crlf} -buffering line -blocking 1
  set packet [chan gets $sock]
  if {![string is ascii $packet]} return
  if {![::info complete $packet]} return
  try {
    set result [::cluster::directory::[lindex $packet 0] {*}[lrange $packet 1 end]]
    puts $sock [list $result {}]
  } on error {err errdat} {
    puts $sock [list $err $errdat]
  } finally {
    chan flush $sock
    chan close $sock
  }
}
###
# topic: 2a33c825920162b0791e2cdae62e6164
###
proc ::cluster::directory::UDPPacket sock {
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
  UDPPortInfo $serviceurl $messagetype $serviceinfo

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
    }
    +SERVICE {
      set ::cluster::recv_message 1
      # Code to register the presence of a service
      set ptpdata($serviceurl) $serviceinfo
      dict set ptpdata($serviceurl) closed 0
    }
    LOG {
      #::cluster::Service_Log $serviceurl $serviceinfo
    }
    PING {
      foreach {url info} [search_directory $serviceurl] {
        broadcast PONG $url $info
      }
    }
  }
}

proc ::cluster::directory::UDPPortInfo {serviceurl msgtype newinfo} {
  variable ptpdata
  # We only care about port changes on the local machine
  if {[dict exists $newinfo macid]} {
    set macid [dict get $newinfo macid]
    if {$macid ne [::cluster::self]} {
      return
    }
  } elseif {[::info exists ptpdata($serviceurl)] && [dict exists $ptpdata($serviceurl) macid]} {
    set macid [dict get $ptpdata($serviceurl) macid]
    if {$macid ne [::cluster::self]} {
      return
    }
  } else {
    return
  }
  set newport {}
  set oldport {}
  if {[dict exists $newinfo port]} {
    set newport [dict get $newinfo port]
  }
  if {[::info exists ptpdata($serviceurl)] && [dict exists $ptpdata($serviceurl) port]} {
    set oldport [dict get $ptpdata($serviceurl) port]
  }
  switch -- $msgtype {
    -SERVICE {
      if {$oldport ne {}} {
        ::nettool::release_port $oldport
      }
      if {$newport ne {}} {
        ::nettool::release_port $newport
      }
    }
    default {
      if {$oldport ne {}} {
        ::nettool::release_port $oldport
      }
      if {$newport ne {}} {
        ::nettool::claim_port $newport
      }
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

proc ::cluster::directory {method args} {
  variable directory_pid
  variable local_pid
  if {$directory_pid eq $local_pid} {
    return [::cluster::directory::$method {*}$args]
  }
  variable directory_port
  if {[catch {socket localhost $directory_port} sock]} {
    Promote_To_Directory
    return [::cluster::directory::$method {*}$args]
  }
  # We are not acting as the directory, query who is
  chan flush $sock
  if {[::info coroutine] ne {}} {
    chan configure $sock -translation crlf -buffering line -blocking 0
    chan puts $sock [list $method {*}$args]
    chan event $sock readable [::info coroutine]
    yield
    chan event $sock readable {}
  } else {
    chan configure $sock -translation crlf -buffering line -blocking 1
    chan puts $sock [list $method {*}$args]
    update
  }
  set reply {}
  while {[chan gets $sock line]>0} {
    append reply \n $line
    if {[::info complete $reply]} break
  }
  lassign $reply result errdat
  catch {chan close $sock}
  if {[llength $errdat]==0} {
    return $result
  }
  return $result {*}errdat
}

###
# topic: 3f5f9e197cc9666dd7953d97fef34019
###
proc ::cluster::ipaddr macid {
  # Convert rawname to a canonical name
  if {$macid eq [::cluster::self]} {
    return 127.0.0.1
  }
  return [directory ipaddr $macid]
}

###
# Promote this process to the local directory
###
proc ::cluster::Promote_To_Directory {} {
  set ::cluster::directory_pid $::cluster::local_pid
  if {$::cluster::config(debug)} {
    puts [list $::cluster::local_pid Promote_To_Directory]
  }
  variable broadcast_sock
  variable discovery_group

  variable discovery_port
  # Accept local directory traffic
  set ::cluster::directory_sock [socket -server ::cluster::directory::TCPAccept $::cluster::directory_port]
  # Listen for broadcasts from the subnet
  set broadcast_sock [udp_open $discovery_port reuse]
  fconfigure $broadcast_sock -buffering none -blocking 0
  chan event $broadcast_sock readable [list [namespace current]::directory::UDPPacket $broadcast_sock]
}

proc ::cluster::sleep args {
  ::cron::sleep {*}$args
}

proc ::cluster::ping {rawname {timeout -1}} {
  return [directory ping $rawname $timeout]
}

proc ::cluster::publish {url infodict} {
  variable local_data
  dict set infodict macid [macid]
  dict set infodict pid   [pid]
  set local_data($url) [dict merge $infodict {ipaddr 127.0.0.1}]
  directory service_publish $url $infodict
}

###
# Empty implementation. Replace to have a task run every
# heartbeat
###
proc ::cluster::event_hook {} {}

proc ::cluster::heartbeat {} {
  variable config
  _Cleanup
  ###
  # Broadcast the status of our local services
  ###
  variable local_data
  foreach {url info} [array get local_data] {
    directory service_update $url $info
  }
  if {$::cluster::local_pid eq $::cluster::directory_pid} {
    ::cluster::directory::_Heartbeat
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
  event_hook
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
  directory service_unpublish $url $info
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
    directory service_update $url $local_data($url)
  }
}

proc ::cluster::get_free_port {{startport 50000}} {
  return [directory alloc_port $startport]
}

proc ::cluster::log args {
  broadcast LOG {*}$args
}

###
# topic: 2c04e58c7f93798f9a5ed31a7f5779ab
###
proc ::cluster::resolve {rawname} {
  set uri [cname $rawname]
  set data [search $uri]
  if {[dict size $data]==0} {
    return {}
    #error "Cannot Resolve $rawname"
  }
  return [list [dict get [lindex $data 1] port] [dict get [lindex $data 1] ipaddr]]
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
# topic: c8475e832c912e962f238c61580b669e
###
proc ::cluster::search pattern {
  ::cluster::_Cleanup
  set result [directory search $pattern]
  variable local_data
  foreach {service dat} [array get local_data $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
      dict set result $service ipaddr 127.0.0.1
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
  variable directory_sock {}

  variable cache_maxage 500
  variable discovery_port 38573
  variable directory_port 38574
  variable broadcast_port {}
  variable directory_pid {}

  # Currently an unassigned group in the
  # Local Network Control Block (224.0.0/24)
  # See: RFC3692 and http://www.iana.org
  variable discovery_group 224.0.0.200
  variable local_port {}
  variable local_macid [lindex [lsort [::nettool::mac_list]] 0]
  variable local_pid   [::uuid::uuid generate]
}
namespace eval ::cluster::directory {
  variable broadcast_list     {}
  variable broadcast_timestamp 0
}

::cron::every cluster_heartbeat 30 ::cluster::heartbeat

