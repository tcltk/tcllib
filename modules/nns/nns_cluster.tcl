# -*- tcl -*-
# ### ### ### ######### ######### #########
## Name Service - Cluster

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.5
package require comm             ; # Generic message transport
package require interp           ; # Interpreter helpers.
package require logger           ; # Tracing internal activity
package require nameserv         ; # Singleton utilities
package require nameserv::common ; # Common/shared utilities
package require nameserv::server ; # Singleton utilities
package require cron
package require nettool 0.4
package require udp

namespace eval ::comm {}
namespace eval ::nameserv::server {}
namespace eval ::nameserv::cluster {}
::namespace eval ::cluster {}

###
# topic: 5cffdc91e554c923ebe43df13fac77d5
###
proc ::cluster::broadcast args {
  if {[llength $args]==1} {
    set msg [lindex $args 0]
    variable discovery_port
    set port $discovery_port
  } else {
    set msg  [lindex $args 1]
    set port [lindex $args 0]
  }
  foreach net [::nettool::broadcast_list] {
    set sock [udp_open]
    fconfigure $sock -broadcast 1 -remote [list $net $port] -ttl 31
    puts -nonewline $sock $msg
    flush $sock
    close $sock
  }
}

###
# topic: 963e24601d0dc61580c9727a74cdba67
###
proc ::cluster::cname rawname {
  # Convert rawname to a canonical name
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
  nameserv_connect
  foreach {servname dat} [nameserv::search [cname *@$macid]] {
    if {[dict exists $dat ipaddr]} {
      return [dict get $dat ipaddr]
    }
  }
  error "Could not locate $macid"
}

###
# topic: e57db306f0e931d7febb5ad1f9cb2247
###
proc ::cluster::nameserv_connect {} {
  variable nameserv_ip
  variable nameserv_mac
  if {$nameserv_ip ne {}} {
    return
  }
  if { [::cluster::self] eq [get nameserv_mac]} {
    ###
    # On windows, local IP lookups don't work reliably
    # However, most applications that rely on a central name server
    # also have a pretty good guess about which node IS the central
    # name server ahead of time
    ####
    set nameserv_ip 127.0.0.1
    ::comm::commDebug {puts stderr "<cluster> NAMESERV AT <$nameserv_ip>"}
    if {![catch {::nameserv::configure -host $nameserv_ip} err]} {
      return
    }
  }
  set replyvar ::cluster::nameserv_reply
  set $replyvar {}
  while 1 {
    set myport [::nettool::allocate_port 49002]
    #if {![catch {udp_open $myport} udp_sock]} break
    if {![catch {socket -server [namespace current]::NameServConnect $myport} tcp_sock]} break
  }
  ::comm::commDebug {puts stderr "<cluster> Listening for namserver reply on port <$myport>"}
  set timeoutevent [after 120000 [list set $replyvar timeout]]
  for {set x 1} {$x < 120} {incr x} {
    ::cluster::broadcast [list ?NAMESERV $myport]
    after 250 {set NEXTBCAST 1}
    vwait NEXTBCAST
    if {[set $replyvar] ni {{} timeout}} break
  }
  close $tcp_sock
  ::nettool::release_port $myport
  if {[set $replyvar] in {{} timeout}} {
    error "Could not locate a local dispatch service"
  }
  set nameserv_ip [set $replyvar]
  ::comm::commDebug {puts stderr "<cluster> NAMESERV AT <$nameserv_ip>"}
  ::nameserv::configure -host $nameserv_ip
  # Rediscover the nameserver in 5 minutes
  after [expr {60*5*1000}] [list set [namespace current]::nameserv_ip {}]
}

###
# topic: 2a33c825920162b0791e2cdae62e6164
###
proc ::cluster::NameServConnect {channel peer clientport} {
  fconfigure $channel -buffering none -translation binary -blocking 1
  set packet [read $channel]
  close $channel
  if {![string is ascii $packet]} return
  if {![::info complete $packet]} return
  set msgtype [lindex $packet 0]
  if { $msgtype eq "+NAMESERV" } {
    set ::cluster::nameserv_reply $peer
  }
}

###
# topic: c6a0630b1539278f070294028064e4b3
###
proc ::cluster::NameServReply {sock replyvar} {
  set packet [read $sock]
  set peer [fconfigure $sock -peer]
  if {![string is ascii $packet]} return
  if {![::info complete $packet]} return
  set msgtype [lindex $packet 0]
  if { $msgtype eq "+NAMESERV" } {
    set $replyvar [lindex $peer 0]
  }
}

proc ::cluster::publish {url infodict} {
  nameserv_connect
  variable url_info
  dict set infodict macid [self]
  dict set infodict pid [pid]
  set url_info($url) $infodict
  broadcast [list +SERVICE $url $infodict]
  ::cron::every cluster_heartbeat 30 ::cluster::heartbeat
}

proc ::cluster::heartbeat {} {
  variable url_info
  foreach {url info} [array get url_info] {
    broadcast [list ~SERVICE $url $info]
  }
}

proc ::cluster::info url {
  variable url_info
  return [array get url_info $url]
}

proc ::cluster::unpublish {url infodict} {
  variable url_info
  foreach {field value} $infodict {
    dict set url_info($url) $field $value
  }
  set info [lindex [array get url_info $url] 1]
  broadcast [list -SERVICE $url $info]
  unset -nocomplain url_info($url)
}

proc ::cluster::configure {url infodict {send 1}} {
  variable url_info
  if {![::info exists url_info($url)]} return
  foreach {field value} $infodict {
    dict set url_info($url) $field $value
  }
  if {$send} {
    broadcast [list ~SERVICE $url $url_info($url)]
  }
}

proc ::cluster::log {url info} {
  broadcast [list LOG $url $info]
}

###
# topic: 2c04e58c7f93798f9a5ed31a7f5779ab
###
proc ::cluster::resolve rawname {
  set found 0
  nameserv_connect
  set self [self]
  foreach {servname dat} [nameserv::search [cname $rawname]] {
    # Ignore services in the process of closing
    if {[dict exists $dat closed] && [dict get $dat closed]} continue
    if {[dict getnull $dat macid] eq $self} {
      set ipaddr 127.0.0.1
    } elseif {![dict exists $dat ipaddr]} {
      set ipaddr [ipaddr [lindex [split $servname @] 1]]
    } else {
      set ipaddr [dict get $dat ipaddr]
    }
    if {![dict exists $dat port]} continue
    if {[llength $ipaddr] > 1} {
      ## Sort out which ipaddr is proper later
      # for now take the last one
      set ipaddr [lindex [dict get $dat ipaddr] end]
    }
    set port [dict get $dat port]
    set found 1
    break    
  }
  if {!$found} {
    error "Could not located $rawname"
  }
  return [list $port $ipaddr]
}

###
# topic: 6c7a0a3a8cb2a7ae98ff0dba960c37a7
###
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
  set commid [resolve $service]
  if [catch {::comm::comm send -async $commid $command {*}$args} reply] {
    puts $stderr "ERR: SEND $service $reply"
  }
}

###
# This file contains an implementation of NNS that
# replies to UDP broadcasts
###
###
# topic: e8d916287e9e4b3433ae8f2071efed9f
###
proc ::nameserv::server::ProtocolFeatures {} {
  return {Core Search/Continuous UDPRelay}
}

###
# topic: c8475e832c912e962f238c61580b669e
###
proc ::nameserv::server::Search pattern {
  set result {}
  foreach {service dat} [array get ::nameserv::cluster::ptpdata $pattern] {
    foreach {field value} $dat {
      dict set result $service $field $value
    }
  }
  return $result
}

proc ::nameserv::cluster::CleanupExpired {} {
  variable ptpdata
  foreach {item info} [array get ptpdata] {
    if {[dict exists $info closed] && [dict get $info closed]} {
      unset ptpdata($item)
    }
  }
}
###
# topic: 0e266ce779660e4751f990dbdda07ca4
###
proc ::nameserv::cluster::UDPPacket sock {
  variable ptpdata
  set packet [read $sock]
  set peer [fconfigure $sock -peer]
  if {![string is ascii $packet]} return
  if {![::info complete $packet]} return
  switch -- [string toupper [lindex $packet 0]] {
    -SERVICE {
      foreach {field value} [lindex $packet 2] {
        dict set ptpdata([lindex $packet 1]) $field $value
      }
      dict set ptpdata([lindex $packet 1]) ipaddr [lindex $peer 0]
      dict set ptpdata([lindex $packet 1]) updated [clock seconds]
      dict set ptpdata([lindex $packet 1]) closed 1
      Service_Remove {*}[lrange $packet 1 2]
    }
    ~SERVICE {
      foreach {field value} [lindex $packet 2] {
        dict set ptpdata([lindex $packet 1]) $field $value
      }
      dict set ptpdata([lindex $packet 1]) ipaddr [lindex $peer 0]
      dict set ptpdata([lindex $packet 1]) updated [clock seconds]
      Service_Modified [lindex $packet 1] $ptpdata([lindex $packet 1])      
    }
    +SERVICE {
      set ptpdata([lindex $packet 1]) [lindex $packet 2]
      dict set ptpdata([lindex $packet 1]) ipaddr [lindex $peer 0]
      dict set ptpdata([lindex $packet 1]) updated [clock seconds]
      Service_Add [lindex $packet 1] $ptpdata([lindex $packet 1])
    }
    DISCOVERY {
      variable data
      foreach {name dat} [array get data] {
        ::cluster::broadcast [list +SERVICE $name $dat]
      }
    }
    LOG {
      Service_Log [lindex $packet 1] [lindex $packet 2]
    }
    ?NAMESERV {
      after idle [list ::nameserv::cluster::NAMESERV_REPLY [lindex $peer 0] [lindex $packet 1]]
    }
  }
}

proc ::nameserv::cluster::NAMESERV_REPLY {ipaddr port} {
  set sout [socket $ipaddr $port]
  fconfigure $sout -buffering none -translation binary -blocking 0
  puts $sout [list +NAMESERV [::cluster::self]]
  flush $sout
  close $sout
}

proc ::nameserv::cluster::Service_Add {service data} {
  # Code to register the presence of a service
}

proc ::nameserv::cluster::Service_Remove {service data} {
  # Code to register the loss of a service
}

proc ::nameserv::cluster::Service_Modified {service data} {
  # Code to register the loss of a service
}

proc ::nameserv::cluster::Service_Log {service data} {
  # Code to register an event
}

proc ::nameserv::cluster::start {} {
  variable udp_sock
  package require nameserv::common
  package require nameserv::server
  set macid [::cluster::self]
  set ::cluster::nameserv_mac $macid
  ###
  # Open up a UDP Socket listener on the discovery port
  ###
  catch {close $udp_sock}
  set udp_sock [udp_open $::cluster::discovery_port]
  fconfigure $udp_sock -buffering none -translation binary -blocking 0
  fileevent $udp_sock readable [list ::nameserv::cluster::UDPPacket $udp_sock]
  
  ::nameserv::server::configure -port $::cluster::discovery_port -localonly 0
  ::nameserv::server::start    
  set ::cluster::nameserve(local) 1
  ::comm::commDebug {puts stderr "<cluster> <$macid> ACTING AS LOCAL NETWORK NAME SERVER"}
  ::nameserv::configure -host 127.0.0.1
  ::cluster::publish nns@${macid} [list port $::cluster::discovery_port class nns protocol comm]
  ::cron::every nnsd_cleanup 300 ::nameserv::cluster::CleanupExpired
}

proc ::nameserv::cluster::stop {} {
  variable udp_sock
  package require nameserv::server
  catch {::nameserv::server::stop}
  set macid [::cluster::self]
  ::cluster::unpublish nns@$macid
  catch {flush $udp_sock}
  catch {close $udp_sock}
  catch {::nameserv::server::stop}
  catch {::nameserv::release}
  ::cron::cancel nnsd_cleanup
}

###
# topic: d3e48e31cc4baf81395179f4097fee1b
###
namespace eval ::cluster {
  # Number of seconds to "remember" data
  variable cache {}
  variable cache_maxage 500
  variable discovery_port 38573
  variable nameserv_ip {}
  variable local_macid [lindex [::nettool::mac_list] 0]
}

package provide nameserv::cluster 0.1