# @mdgen OWNER: available_ports.tcl
package provide nettool::available_ports 0.2

::namespace eval ::nettool {}

###
# topic: 4a6ac5d7529bac9a223872dd7566e0b3
###
proc ::nettool::allocate_port startingport {
  foreach {start end} $::nettool::blocks {
    if { $end <= $startingport } continue
    if { $start > $startingport } {
      set i $start
    } else {
      set i $startingport
    }
    for {} {$i <= $end} {incr i} {
      if {[string is true -strict [get ::nettool::used_ports($i)]]} continue
      if {[catch {socket -server NOOP $i} chan]} continue
      close $chan
      set ::nettool::used_ports($i) 1
      return $i
    }
  }
  error "Could not locate a port"
}

###
# topic: ce8e812f4c4548cdae7b055c36f39b77
###
proc ::nettool::claim_port {port {protocol tcp}} {
  set ::nettool::used_ports($port) 1
}

###
# topic: ebafbb52e53e0600dd30e386de5fa5c9
###
proc ::nettool::find_port startingport {
  foreach {start end} $::nettool::blocks {
    if { $end <= $startingport } continue
    if { $start > $startingport } {
      set i $start
    } else {
      set i $startingport
    }
    for {} {$i <= $end} {incr i} {
      if {[string is true -strict [get ::nettool::used_ports($i)]]} continue
      return $i
    }
  }
  error "Could not locate a port"
}

###
# topic: d01f726e91e49aea83f74d5f602674bb
###
proc ::nettool::port_busy port {
  ###
  # Check our private list of used ports
  ###
  if {[string is true -strict [get ::nettool::used_ports($port)]]} {
    return 1
  }
  foreach {start end} $::nettool::blocks {
    if { $port >= $start && $port <= $end } {
      return 0
    }
  }
  return 1
}

###
# topic: 9356fda270fe7d83373c6ab20cd4b03e
###
proc ::nettool::release_port {port {protocol tcp}} {
  set ::nettool::used_ports($port) 0
}

set here [file dirname [file normalize [info script]]]
if {[file exists [file join $here available_ports.tcl]]} {
  source [file join $here available_ports.tcl]
}

