::namespace eval ::tool::signal {}

proc ::tool::coroutine_register {objname coroutine} {
  variable all_coroutines
  variable object_coroutines
  variable coroutine_object
  # Wake a sleeping main loop
  set ::tool::wake_up 2
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
  variable last_event
  set last_event [clock seconds]
  set count 0
  foreach coro $all_coroutines {
    if {[info command $coro] eq {}} {
      #puts "$coro quit"
      coroutine_unregister $coro
      continue
    }
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
      }
    } on ok {result opts} {
      if { $result eq "done" } {
        coroutine_unregister $coro
      } else {
        incr count
      }
    }
  }
  return $count
}

proc ::tool::Main_Service {} {
  # Cap cron delays at 1 minute
  if {[info command ::CRON] eq {}} {
    coroutine ::CRON ::cron::runTasksCoro
  }
  set cron_delay [::CRON]
  set tool_running [::tool::do_events]
  if {$cron_delay==0 || $tool_running>0} {
    incr ::tool::loops(active)
    update
    set ::tool::wake_up 1
  } else {
    incr ::tool::loops(idle)
  }
}


proc ::tool::main {} {
  package require cron 1.2
  variable event_loops
  variable last_event
  if {[info exists ::tool::main($event_loops)]} {
    if {$::tool::main($event_loops)} {
      set last_event -1
      set ::tool::wake_up 1
      update
      if {$last_event>0} {
        puts "Avoiding re-entrance into ::tool::main"
        return
      }
    }
  }
  ###
  # Have the cron::wake procedure wake up an idle loop instead
  # of it's normal run commands in the background
  ###
  proc ::cron::wake {} {
    set ::tool::wake_up 1
  }
  # Signal for all other MAIN loops to terminate
  for {set x 0} {$x < $event_loops} {incr x} {
    set ::tool::main($x) 0
  }
  set ::tool::wake_up -1
  update
  set this [incr event_loops]
  set ::tool::main($this) 1
  set ::tool::wake_up 0

  while {$::tool::main($this)} {
    set panic [after 120000 {puts "Warning: Tool event loop has not responded in 2 minutes"}]
    incr ::tool::loops(all)
    after idle ::tool::Main_Service
    set next [after [expr {60000}] {set ::tool::wake_up 1}]
    vwait ::tool::wake_up
    after cancel $panic
    after cancel $next
    if {$::tool::wake_up < 0} {
      break
    }
  }
}

proc ::tool::object_create objname {
  foreach varname {
    object_info
    object_signal
    object_subscribe
    object_coroutine
  } {
    variable $varname
    set ${varname}($objname) {}
  }
  set object_info($objname) [list class [info object class $objname]]
}

proc ::tool::object_rename {object newname} {
  foreach varname {
    object_info
    object_signal
    object_subscribe
    object_coroutine
  } {
    variable $varname
    if {[info exists ${varname}($object)]} {
      set ${varname}($newname) [set ${varname}($object)]
      unset ${varname}($object)
    }
  }
  variable coroutine_object
  foreach {coro coro_objname} [array get coroutine_object] {
    if { $object eq $coro_objname } {
      set coroutine_object($coro) $newname
    }
  }
  rename $object ::[string trimleft $newname]
  ::tool::event::generate $object object_rename [list newname $newname]
}

proc ::tool::object_destroy objname {
  ::tool::event::generate $objname object_destroy [list objname $objname]

  variable coroutine_object
  foreach {coro coro_objname} [array get coroutine_object] {
    if { $objname eq $coro_objname } {
      coroutine_unregister $coro
    }
  }
  foreach varname {
    object_info
    object_signal
    object_subscribe
    object_coroutine
  } {
    variable $varname
    unset -nocomplain ${varname}($objname)
  }
}

namespace eval ::tool {
  variable trace 0
  variable event_loops
  if {![info exists event_loops]} {
    set event_loops 0
  }
  variable all_coroutines
  if {![info exists all_coroutines]} {
    set all_coroutines {}
  }
}

package provide tool::pipeline 0.1

