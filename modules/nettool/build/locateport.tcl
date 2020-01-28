::namespace eval ::nettool {}

###
# topic: fc6f8b9587dd5524f143f9df4be4755b63eb6cd5
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
      if {[port_busy $i]} continue
      if {[catch {socket -server NOOP $i} chan]} {
        dict set ::nettool::used_ports $port mtime [clock seconds]
        dict set ::nettool::used_ports $port pid   1
        continue
      }
      close $chan
      claim_port $i
      return $i
    }
  }
  error "Could not locate a port"
}

###
# topic: 3286fdbd0a3fdebbb26414475754bcf3dea67b0f
###
proc ::nettool::claim_port {port {protocol tcp}} {
  dict set ::nettool::used_ports $port mtime [clock seconds]
  dict set ::nettool::used_ports $port pid   [pid]
  if {[info exists ::nettool::syncfile]} {
    ::nettool::_sync_db $::nettool::syncfile
  }
}

###
# topic: 1d1f8a65a9aef8765c9b4f2b0ee0ebaf42e99d46
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
      if {[port_busy $i]} continue
      return $i
    }
  }
  error "Could not locate a port"
}

proc ::nettool::_die {filename} {
}


proc ::nettool::_sync_db {filename} {
  set mypid [pid]
  if {[file exists $filename]} {
    for {set x 0} {$x < 30} {incr x} {
      if {![file exists $filename.lock]} break
      set pid [string trim [cat $filename.lock]]
      if {$pid==$mypid} break
      after 250
    }
    set fout [open $filename.lock w]
    puts $fout $mypid
    close $fout
    set now [clock seconds]
    set fin [open $filename r]
    while {[gets $fin line]>=0} {
      lassign $line port info
      # Ignore file entries attributed to my process id
      if {[dict exists $info pid] && [dict get $info pid] == $mypid} continue
      # Ignore attempts to update usage on ports I have allocated
      if {[dict exists $::nettool::used_ports $port pid] && [dict get $::nettool::used_ports $port pid] == $mypid} continue
      # Ignore entries more than a week old
      if {[dict exists $info mtime] && ($now-[dict get $info mtime]) > 604800} continue
      dict set ::nettool::used_ports $port $info
    }
    close $fin
  }
  set fout [open $filename w]
  set ports [lsort -integer [dict keys $::nettool::used_ports]]
  foreach port $ports {
    if {[dict get $::nettool::used_ports $port pid]==$mypid} {
      dict set ::nettool::used_ports $port mtime $now
    }
    puts $fout [list $port [dict get $::nettool::used_ports $port]]
  }
  close $fout
  catch {file delete $filename.lock}
}

###
# topic: ded1c51260e009effb1f77044f8d0dec3d030b91
###
proc ::nettool::port_busy port {
  if {[info exists ::nettool::syncfile] && [file exists $::nettool::syncfile]} {
    ::nettool::_sync_db $::nettool::syncfile
  }
  ###
  # Check our private list of used ports
  ###
  if {[dict exists $::nettool::used_ports $port pid] && [dict get $::nettool::used_ports $port pid] > 0} {
    return 1
  }
  foreach {start end} $::nettool::blocks {
    if { $port >= $start && $port <= $end } {
      return 0
    }
  }
  return 1
}

# Called when a process is closing
proc ::nettool::release_all {} {
  set mypid [pid]
  set now [clock seconds]
  dict for {port info} $::nettool::used_ports {
    if {[dict exists $info pid] && [dict get $info pid]==$mypid} {
      dict set ::nettool::used_ports $port pid 0
      dict set ::nettool::used_ports $port mtime $now
    }
  }
  if {[info exists ::nettool::syncfile]} {
    ::nettool::_sync_db $::nettool::syncfile
  }
}

###
# topic: b5407b084aa09f9efa4f58a337af6186418fddf2
###
proc ::nettool::release_port {port {protocol tcp}} {
  dict set ::nettool::used_ports $port mtime [clock seconds]
  dict set ::nettool::used_ports $port pid   0
  if {[info exists ::nettool::syncfile]} {
    ::nettool::_sync_db $::nettool::syncfile
  }
}

if {![info exists ::nettool::used_ports]} {
  set ::nettool::used_ports {}
}
