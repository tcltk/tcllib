###
# This file implements a process table
# Instead of having individual components try to maintain their own timers
# we centrally manage how often tasks should be kicked off here.
###
#
# Author: Sean Woods (for T&E Solutions)

package provide cron 1.0

::namespace eval ::cron {}

proc ::cron::at {process timecode command} {
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
  ::cron::runTasks
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
  ::cron::runTasks
}

proc ::cron::cancel {process} {
  variable processTable
  unset -nocomplain processTable($process)
}

###
# topic: 97015814408714af539f35856f85bce6
###
proc ::cron::run process {
  variable processTable
  dict set processTable($process) lastrun 0
}

###
# topic: 1f8d4726623321acc311734c1dadcd8e
# description:
#    Run through our process table and
#    kick off overdue tasks
###
proc ::cron::runProcesses {} {
  variable processTable
  set now [clock seconds]
  
  ###
  # Determine what tasks to run this timestep
  ###
  set tasks {}
  set cancellist {}
  foreach {process} [array names processTable] {
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
    dict with processTable($task) {
      set err [catch {uplevel #0 $command} result]
      if $err {
        puts $result
      }
    }
  }

  foreach {task} $cancellist {
    unset -nocomplain processTable($task)
  }
}

###
# topic: 2f5a33d28948c4514764bd2f58b750fc
# description:
#    Called once per second, and timed to ensure
#    we run in roughly realtime
###
proc ::cron::runTasks {} {
  variable lastcall
  after cancel $lastcall
  ###
  # Run the processes before we kick off another task...
  ###
  catch {runProcesses}
  variable processTable
  ###
  # Look at our schedule and book the next timeslot
  # or 15 minutes, whichever is sooner
  ###
  set now [clock seconds]
  set nexttime [expr {$now - ($now % 900) + 900}]
  foreach {process} [array names processTable] {
    dict with processTable($process) {
      if {$scheduled > $now && $scheduled < $nexttime} {
        set nexttime $scheduled
      }
    }
  }
  ###
  # Try to get the event to fire off on the border of the
  # nearest second
  ###
  if { $nexttime > $now } {
    set ctime [clock milliseconds]
    set next [expr {($nexttime-$now)*1000-1000+($ctime % 1000)}]
  } else {
    set next 0
  }
  set lastcall [after $next [namespace current]::runTasks]
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
}

::cron::runTasks

