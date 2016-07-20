###
# This file implements a process table
# Instead of having individual components try to maintain their own timers
# we centrally manage how often tasks should be kicked off here.
###
#
# Author: Sean Woods (for T&E Solutions)
package require coroutine

::namespace eval ::cron {}

proc ::cron::at args {
  switch [llength $args] {
    2 {
      variable processuid
      set process event#[incr processuid]
      lassign $args timecode command
    }
    3 {
      lassign $args process timecode command
    }
    default {
      error "Usage: ?process? timecode command"
    }
  }
  variable processTable
  if {[string is integer -strict $timecode]} {
    set scheduled $timecode
  } else {
    set scheduled [clock scan $timecode]
  }
  set now [clock seconds]
  set info [list process $process frequency 0 command $command scheduled $scheduled lastevent $now]
  if ![info exists processTable($process)] {
    lappend info lastrun 0 err 0 result {}
  }
  foreach {field value} $info {
    dict set processTable($process) $field $value
  }
  ::cron::wake NEW
  return $process
}

proc ::cron::in args {
  switch [llength $args] {
    2 {
      variable processuid
      set process event#[incr processuid]
      lassign $args timecode command
    }
    3 {
      lassign $args process timecode command
    }
    default {
      error "Usage: ?process? timecode command"
    }
  }
  variable processTable
  set now [clock seconds]
  set scheduled [expr {int(ceil($timecode+$now))}]
  set info [list process $process frequency 0 command $command scheduled $scheduled lastevent $now]
  if ![info exists processTable($process)] {
    lappend info lastrun 0 err 0 result {}
  }
  foreach {field value} $info {
    dict set processTable($process) $field $value
  }
  ::cron::wake NEW
  return $process
}

proc ::cron::cancel {process} {
  variable processTable
  unset -nocomplain processTable($process)
}

proc ::cron::coroutine_register {objname coroutine} {
  variable all_coroutines
  variable object_coroutines
  variable coroutine_object
  # Wake a sleeping main loop
  ::cron::wake ::cron::coroutine_register
  if {$coroutine in $all_coroutines} {
    return 1
  }

  lappend all_coroutines $coroutine
  lappend object_coroutines($objname) $coroutine
  set coroutine_object($coroutine) $objname
  return 0
}

proc ::cron::coroutine_unregister {coroutine} {
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

proc ::cron::do_events {} {
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

###
# topic: 0776dccd7e84530fa6412e507c02487c
###
proc ::cron::every {process frequency command} {
  variable processTable
  set now [clock seconds]
  set info [list process $process frequency $frequency command $command scheduled [expr {$now + $frequency}] lastevent $now]
  if ![info exists processTable($process)] {
    lappend info lastrun 0 err 0 result {}
  }
  foreach {field value} $info {
    dict set processTable($process) $field $value
  }
  ::cron::wake NEW
}

###
# topic: 97015814408714af539f35856f85bce6
###
proc ::cron::run process {
  variable processTable
  dict set processTable($process) lastrun 0
  ::cron::wake PROCESS
}


###
# topic: 21de7bb8db019f3a2fd5a6ae9b38fd55
# description:
#    Called once per second, and timed to ensure
#    we run in roughly realtime
###
proc ::cron::runTasksCoro {} {
  ###
  # Do this forever
  ###
  variable processTable
  variable processing
  while 1 {
    set lastevent 0
    set now [clock seconds]
    ###
    # Determine what tasks to run this timestep
    ###
    set tasks {}
    set cancellist {}
    foreach {process} [lsort -dictionary [array names processTable]] {
      dict with processTable($process) {
        if { $scheduled <= $now } {
          lappend tasks $process
          if { $frequency <= 0 } {
            lappend cancellist $process
          } else {
            set scheduled [expr {$frequency + $lastrun}]
            if { $scheduled <= $now } {
              set scheduled [expr {$frequency + $now}]
            }
          }
          set lastrun $now
        }
        set lastevent $now
      }
    }
    foreach task $tasks {
      dict set processTable($task) lastrun $now
      dict with processTable($task) {
        set err [catch {uplevel #0 $command} result]
        if $err {
          puts $result
        }
      }
      yield 0
    }
    foreach {task} $cancellist {
      unset -nocomplain processTable($task)
    }
    
    # Wake me up in 5 minute intervals, just out of principle
    set nextevent [expr {$now-($now % 300) + 300}]
    set nexttask {}
    foreach {process} [lsort -dictionary [array names processTable]] {
      dict with processTable($process) {
        if {$scheduled < $nextevent} {
          set nexttask $process
          set nextevent $scheduled
        }
        set lastevent $now
      }
    }
    set delay [expr {$nextevent-$now}]
    if {$delay < 0} {
      yield 0
    } else {
      if {$delay > 120} {
        set delay [expr {$delay-($delay % 60) + 60}]
      }
      yield $delay      
    }
  }
}

proc ::cron::wake {{who ???}} {
  ##
  # Only triggered by cron jobs kicking off other cron jobs within
  # the script body
  ##
  after cancel $::cron::next_event
  if {$who eq "PANIC"} {
    # Cron is overdue and may be stuck
    set ::cron::busy 0
    set ::cron::panic_event {}
  }
  if {$::cron::busy && $::cron::panic_event eq {}} {
    puts "BUSY..."
    after cancel $::cron::panic_event
    set ::cron::panic_event [after 120000 {::cron::wake PANIC}]
    return
  }
  set now [clock seconds]
  set ::cron::busy 1
  while {$::cron::busy} {
    after cancel $::cron::panic_event
    set ::cron::panic_event [after 120000 {::cron::wake PANIC}]  
    if {[info command ::cron::COROUTINE] eq {}} {
      coroutine ::cron::COROUTINE ::cron::runTasksCoro
    }
    set cron_delay [::cron::COROUTINE]
    set tool_running [::cron::do_events]
    if {$cron_delay==0 || $tool_running>0} {
      set ::cron::wake_time 0
      incr ::cron::loops(active)
    } else {
      set ::cron::busy 0
      incr ::cron::loops(idle)
    }
  }
  ###
  # Try to get the event to fire off on the border of the
  # nearest second
  ###
  set ::cron::wake_time [expr {[clock seconds]+$cron_delay}]
  set ctime [clock milliseconds]
  set next [expr {$cron_delay*1000-1000+($ctime % 1000)}]
  if {$::cron::trace} {
    puts [list EVENT LOOP WILL WAKE IN $cron_delay s next: $next active: $::cron::loops(active) idle: $::cron::loops(idle) woken_by: $who]
  }
  set ::cron::next_event [after $next {::cron::wake IDLE}]
}


proc ::cron::main {} {
  # Never launch from a coroutine
  if {[info coroutine] ne {}} {
    return
  }
  set ::cron::forever 1
  while {$::cron::forever} {
    ::after 120000 {set ::cron::waiting 0}
    # Call an update just to give the rest of the event loop a chance
    incr ::cron::loops(main)
    ::after cancel $::cron::next_event
    set ::cron::next_event [::after idle {::cron::wake MAIN}]
    set ::cron::forever 1
    set ::cron::busy 0
    ::vwait ::cron::forever
    if {$::cron::trace} {
      puts "MAIN LOOP CYCLE $::cron::loops(main)"
    }
  }
}

###
# topic: 4a891d0caabc6e25fbec9514ea8104dd
# description:
#    This file implements a process table
#    Instead of having individual components try to maintain their own timers
#    we centrally manage how often tasks should be kicked off here.
###
namespace eval ::cron {
  variable lastcall 0
  variable processTable
  variable busy 0
  variable next_event {}
  variable trace 0
  variable event_loops
  variable panic_event {}
  if {![info exists event_loops]} {
    set event_loops 0
  }
  if {![info exists ::cron::loops]} {
    array set ::cron::loops {
      active 0
      main 0
      idle 0
      wake 0
    }
  }
  variable all_coroutines
  if {![info exists all_coroutines]} {
    set all_coroutines {}
  }
}

::cron::wake STARTUP
package provide cron 1.3

