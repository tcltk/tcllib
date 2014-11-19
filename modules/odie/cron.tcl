###
# This file implements a process table
# Instead of having individual components try to maintain their own timers
# we centrally manage how often tasks should be kicked off here.
###
#
# Author: Sean Woods (for T&E Solutions)

package provide odie::cron 0.1

::namespace eval ::cron {}

###
# topic: 0776dccd7e84530fa6412e507c02487c
###
proc ::cron::process {process frequency command} {
  variable processTable
  set info [list process $process frequency $frequency command $command]
  if ![info exists processTable($process)] {
    lappend info lastrun 0 err 0 result {}
  }
  foreach {field value} $info {
    dict set processTable($process) $field $value
  }
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
  foreach {process} [array names processTable] {
    dict with processTable($process) {
      set time [expr $now - $lastrun]
      if { $time > $frequency || $lastrun == 0 } {
        lappend tasks $process
        set lastrun $now
      }
    }
  }
  foreach task $tasks {
    dict with processTable($task) {
      set err [catch $command result]
      if $err {
        puts $result
      }
    }
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
  variable lasttime
  after cancel $lastcall
  set now [clock clicks -milliseconds]
  set diff [expr $now - $lasttime]
  if { $diff > 1000 || $diff < 0 } {
    set next 1000
  } else {
    set next $diff
  }
  ###
  # Run the processes before we kick off another task...
  ###
  catch {runProcesses}
  after $next [namespace current]::runTasks
  set lasttime $now
}

###
# topic: 4a891d0caabc6e25fbec9514ea8104dd
# description:
#    This file implements a process table
#    Instead of having individual components try to maintain their own timers
#    we centrally manage how often tasks should be kicked off here.
###
namespace eval ::cron {
variable lasttime 0
  variable lastcall 0
  variable processTable
}

::cron::runTasks

