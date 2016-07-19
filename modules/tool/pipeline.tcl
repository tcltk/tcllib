::namespace eval ::tool::signal {}
package require coroutine::auto

proc ::tool::coroutine_register {objname coroutine} {
  variable all_coroutines
  variable object_coroutines
  variable coroutine_object
  # Wake a sleeping main loop
  set ::tool::wake_up 0
  set ::tool::rouser ::tool::coroutine_register
  if {$coroutine in $all_coroutines} {
    return 1
  }

  lappend all_coroutines $coroutine
  lappend object_coroutines($objname) $coroutine
  set coroutine_object($coroutine) $objname
  return 0
}

proc ::tool::coroutine_unregister {coroutine} {
  variable all_coroutines
  variable object_coroutines
  variable coroutine_object
  ldelete all_coroutines $coroutine
  if {[info exists coroutine_object($coroutine)]} {
    set objname $coroutine_object($coroutine)
    ldelete object_coroutines($objname) $coroutine
    unset coroutine_object($coroutine)
  }
}


proc ::tool::do_events {} {
  # Process coroutines
  variable all_coroutines
  variable coroutine_object
  variable coroutine_busy
  variable last_event
  set last_event [clock seconds]
  set count 0
  foreach coro $all_coroutines {
    if {![info exists coroutine_busy($coro)]} {
      set coroutine_busy($coro) 0
    }
    # Prevent a stuck coroutine from logjamming the entire event loop
    if {$coroutine_busy($coro)} continue
    set coroutine_busy($coro) 1
    if {[info command $coro] eq {}} {
      #puts "$coro quit"
      coroutine_unregister $coro
      continue
    }
    set deleted 0
    #puts [list RUN $coro]
    try $coro on return {} {
      # Terminate the coroutine
      coroutine_unregister $coro
    } on break {} {
      # Terminate the coroutine
      coroutine_unregister $coro
    } on error {errtxt errdat} {
      # Coroutine encountered an error
      coroutine_unregister $coro
      puts "ERROR $coro"
      set errorinfo $::errorInfo
      catch {
      puts "OBJECT: $coroutine_object($coro)"
      puts "CLASS: [info object class $coroutine_object($coro)]"
      }
      puts "$errtxt"
      puts ***
      puts $errorinfo
    } on continue {result opts} {
      # Ignore continue
      if { $result eq "done" } {
        incr count
        coroutine_unregister $coro
        set deleted 1

      }
    } on ok {result opts} {
      if { $result eq "done" } {
        coroutine_unregister $coro
        set deleted 1
      } else {
        incr count
      }
    }
    if {$deleted} {
      unset -nocomplain coroutine_busy($coro)
    } else {
      set coroutine_busy($coro) 0
    }
  }
  return $count
}

proc ::tool::Main_Service {} {
  if {[info command ::CRON] eq {}} {
    coroutine ::CRON ::cron::runTasksCoro
  }
  set now [clock seconds]
  set cron_delay [::CRON]
  set ::tool::busy 1
  set tool_running [::tool::do_events]
  set ::tool::busy 0
  if {$cron_delay==0 || $tool_running>0} {
    set ::tool::wake_up 0
    set ::tool::rouser {Main_Service active}
    incr ::tool::loops(active)
  } else {
    set ::tool::rouser [list Main_Service idle $cron_delay]
    set ::tool::wake_up [expr {$cron_delay+$now}]
    incr ::tool::loops(idle)
  }
}


proc ::tool::main {} {
  set ::tool::rouser STARTUP
  package require cron 1.2
  variable event_loops
  variable last_event
  variable trace
  if {[info exists ::tool::main($event_loops)]} {
    if {$::tool::main($event_loops)} {
      set last_event -1
      set ::tool::wake_up 0
      set ::tool::rouser RESTART_EVENT_LOOP
      update
      if {$last_event>0} {
        return
      }
    }
  }
  ###
  # Have the cron::wake procedure wake up an idle loop instead
  # of it's normal run commands in the background
  ###
  proc ::cron::wake {} {
    set ::tool::wake_up 0
  set ::tool::rouser ::cron::wake

  }
  # Signal for all other MAIN loops to terminate
  for {set x 0} {$x < $event_loops} {incr x} {
    set ::tool::main($x) 0
  }
  set ::tool::wake_up 0
  update
  set this [incr event_loops]
  set ::tool::main($this) 1
  set ::tool::wake_up 0
  set ::tool::busy 0
  while {$::tool::main($this)} {
    # Call an update just to give the rest of the event loop a chance
    update
    incr ::tool::loops(all)
    if {$::tool::busy==0} {
      # Kick off a new round of event processing 
      # only if the current round
      # has completed
      set panic [after 120000 {puts "Warning: Tool event loop has not responded in 2 minutes" ; set ::tool::rouser PANIC ; set ::tool::busy 0}]
      after idle ::tool::Main_Service
      update
    }
    if {$::tool::wake_up > 0} {
      set delay [expr {(${::tool::wake_up}-[clock seconds])*1000}]
      if {$trace} {
        puts [list EVENT LOOP WILL WAKE IN [expr {$delay/1000}]s active: $::tool::loops(active) idle: $::tool::loops(idle) busy: $::tool::busy rouser: $::tool::rouser]
      }
      set next [after $delay {set ::tool::wake_up 0}]
      set ::tool::rouser IDLELOOP
      set ::tool::wake_up 0
      vwait ::tool::wake_up
      after cancel $next
    }
    if {${::tool::busy} == 0} {
      after cancel $panic
    }
  }
}

namespace eval ::tool {
  variable trace 0
  variable event_loops
  if {![info exists event_loops]} {
    set event_loops 0
  }
  if {![info exists ::tool::loops]} {
    array set ::tool::loops {
      active 0
      all 0
      idle 0
    }
  }
  variable all_coroutines
  if {![info exists all_coroutines]} {
    set all_coroutines {}
  }
}

package provide tool::pipeline 0.1

