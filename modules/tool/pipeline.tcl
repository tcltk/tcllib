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
    } on error {} {
      # Coroutine encountered an error
      coroutine_unregister $coro
      puts "ERROR $coro"
      puts "$::errorInfo"
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

proc ::tool::main {} {
  package require cron 1.2
  ###
  # Have the cron::wake procedure wake up an idle loop instead
  # of it's normal run commands in the background
  ###
  proc ::cron::wake {} {
    set ::tool::wake_up 1
  }

  set ::forever 1
  while {$::forever} {
    incr ::tool::loops(all)
    if {[info command ::CRON] eq {}} {
      coroutine ::CRON ::cron::runTasksCoro
    }
    set cron_delay [::CRON]
    set tool_running [::tool::do_events]
    if {$cron_delay==0 || $tool_running>0} {
      incr ::tool::loops(active)
      update
    } else {
      incr ::tool::loops(idle)
      set ::tool::wake_up 0
      after [expr {$cron_delay*1000}] {set ::tool::wake_up 1}
      vwait ::tool::wake_up
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
    unset ${varname}($objname)
  }
}

###
# topic: 3040c40643cf48aeb6324cf6289875afede57d92
###
proc ::tool::signal::compare {i j sigdat} {
  if {$i == $j} {
    return 0
  }

  set j_preceeds_i [matches $j [dict getnull $sigdat $i preceeds:]]
  set i_preceeds_j [matches $i [dict getnull $sigdat $j preceeds:]]
  set j_follows_i [matches $j [dict getnull $sigdat $i follows:]]
  set i_follows_j [matches $i [dict getnull $sigdat $j follows:]]

  if {$i_preceeds_j && !$j_preceeds_i && !$i_follows_j} {
    return -1
  }
  if {$j_preceeds_i && !$i_preceeds_j && !$j_follows_i} {
    return 1
  }
  if {$j_follows_i && !$i_follows_j} {
    return 1
  }
  if {$i_follows_j && !$j_follows_i} {
    return -1
  }
  set j_triggers_i [matches $j [dict getnull $sigdat $j triggers:]]
  set i_triggers_j [matches $i [dict getnull $sigdat $i triggers:]]
  return 0
}

###
# topic: 1f4128fa725b7af77fc6458fe653a651
###
proc ::tool::signal::expand {rawsignal sigdat {signalvar {}}} {
  if {$signalvar ne {}} {
    upvar 1 $signalvar result
  } else {
    set result {}
  }
  if {$rawsignal in $result} {
    return {}
  }
  if {[dict exists $sigdat $rawsignal]} {
    lappend result $rawsignal
    # Map triggers
    foreach s [dict getnull $sigdat $rawsignal triggers:] {
      expand $s $sigdat result
    }
  } else {
    # Map aliases
    foreach {s info} $sigdat {
      if {$rawsignal in [dict getnull $info aliases:]} {
        expand $s $sigdat result
      }
    }
  }
  return $result
}


###
# topic: 4aa27f5cd1b48bbe1b6b2d937f7e1ba4f879e9fb
###
proc ::tool::signal::matches {signal fieldinfo} {
  foreach value $fieldinfo {
    if {[string match $value $signal]} {
      return 1
    }
  }
  return 0
}

###
# topic: ca5bb3c3d9476b8e8a854f2203111c377c390f0e
###
proc ::tool::signal::order sigdat {
  set allsig [lsort -dictionary [dict keys $sigdat]]
  
  foreach i $allsig {
    set follows($i) {}
    set preceeds($i) {}
  }
  foreach i $allsig {
    foreach j $allsig {
      if { $i eq $j } continue
      set cmp [compare $i $j $sigdat]
      if { $cmp < 0 } {
        ::ladd follows($i) $j
      }
    }
  }
  # Resolve mutual dependencies
  foreach i $allsig {
    foreach j $follows($i) {
      foreach k $follows($j) {
        if {[compare $i $k $sigdat] < 0} {
          ::ladd follows($i) $k
        }
      }
    }
  }
  foreach i $allsig {
    foreach j $follows($i) {
      ::ladd preceeds($j) $i
    }
  }
  # Start with sorted order
  set order $allsig
  set pass 0
  set changed 1
  while {$changed} {
    set changed 0
    foreach i $allsig {
      set iidx [lsearch $order $i]
      set max $iidx
      foreach j $preceeds($i) {
        set jidx [lsearch $order $j]
        if {$jidx > $max } {
          set after $j
          set max $jidx
        }
      }
      if { $max > $iidx } {
        set changed 1
        set order [lreplace $order $iidx $iidx]
        set order [linsert $order [expr {$max + 1}] $i]
      }
    }
    if {[incr pass]>10} break
  }
  return $order
}

tool::define ::tool::object {
  ###
  # topic: 6c9e9e67ccd608d1983bbebcd81f2fd3
  ###
  method lock {method args} {
    my variable ActiveLocks
    if {![info exists ActiveLocks]} {
      set ActiveLocks {}
    }
    switch $method {
      active {
        ###
        # submethod: active
        # title: Return a list of active locks
        ###
        return $ActiveLocks
      }
      create {
        ###
        # submethod: create ?lock...?
        # title: Create a lock
        # returns: True if lock was already present, false otherwise
        ###
        foreach lock $args {
          if { $lock in $ActiveLocks } {
            return 1
          }
        }
        foreach lock $args {
          if { $lock ni $ActiveLocks } {
            lappend ActiveLocks $lock
          }
        }
        return 0
      }
      peek {
        ###
        # submethod: peek ?lock...?
        # title: Check status of a lock
        # returns: True if lock is present, false otherwise
        ###
        foreach lock $args {
          if { $lock in $ActiveLocks } {
            return 1
          }
        }
        return 0
      }
      remove {
        ###
        # submethod: remove ?lock...?
        # title: Remove a lock
        # returns: True if lock was present, false otherwise
        # description:
        # Removes one or more locks. When the last lock
        # is removed, the Signal_Pipeline method is invoked
        ###
        if {![llength $ActiveLocks]} {
          return 0
        }
        set oldlist $ActiveLocks
        set ActiveLocks {}
        foreach item $oldlist {
          if {$item ni $args} { lappend ActiveLocks $item }
        }
        if {![llength $ActiveLocks]} {
          my Signal_schedule
          return 1
        }
        return 0     
      }
      remove_all {
        ###
        # submethod: remove_all
        # title: Remove all locks and invoke Signal_schedule
        ###
        set ActiveLocks {}
        my Signal_schedule
      }
    }
  }

  ###
  # title: Sends a signal to the object
  # description:
  # Signals are ways to tell an object that the world has changed
  # and that it will need to carry out an evolution to realign
  # itself with it.
  #
  # Signals are defined in the signal section of the meta data
  # and contain the following fields:
  # * action: Action to perform
  # * follows: Which signal's behavior should this action follow
  # 
  ###
  method signal args {
    set rawlist [::oo::meta::args_to_dict {*}$args]
    foreach var {signals_pending signals_processed} {
      my variable $var
      if {![info exists $var]} {
        set $var {}
      }
    }
    set sigdat [my meta getnull signal]
    ###
    # Process incoming signals
    ###
    set signalmap $signals_pending
    foreach rawsignal $rawlist {
      ::tool::signal::expand $rawsignal $sigdat signalmap
    }
    set newsignals {}
    foreach signal $signalmap {
      if {$signal in $signals_processed} continue
      if {$signal in $signals_pending} continue
      set action [dict getnull $sigdat $signal action:]
      if {[string length $action]} {
        lappend newsignals $signal
        lappend signals_pending $signal
      }
      set apply_action [dict getnull $sigdat $signal apply_action:]
      if {[string length $apply_action]} {
        eval $apply_action
      }
    }
    if {[llength [my lock active]]} {
      return
    }

    if {("idle" in $rawlist && [llength $signals_pending]) || [llength $newsignals] } {
      set event [my Signal_schedule]
    } else {
      set event {}
    }
    return [list $event $signals_pending]
  }
  
  method Signal_schedule {} {
    set coroname [namespace current]::signal_coro
    if {[::tool::coroutine_register [self] $coroname]} {
      return
    }
    ::coroutine $coroname {*}[namespace code {my Signal_coroutine}]
  }

  ###
  # topic: b9adb42b9e32fca79a9af340144281b6
  ###
  method Signal_coroutine {} {
    # Yield immediately on the first call
    yield
    set trace [my trace]
    set errlist {}
    my Signal_Busy
    set sigdat [my meta getnull signal]
    my variable signals_pending signals_processed
    set order [::tool::signal::order $sigdat]
    set pass 0
    if {$trace} {
      puts [list [self] [self method] $signals_pending]
    }
    while {[llength [set signals $signals_pending]]} {
      ###
      # Copy our pending signals and clear out the list
      ###
      set signals_pending {}
      # Ignore mutually exclusive tasks
      set ignored {}
      foreach signal $order {
        if { $signal in $signals && $signal ni $ignored } {
          foreach item [dict getnull $sigdat $signal excludes:] {
            ::ladd ignored $item
          }
        }
      }      
      ###
      # Fire off signals in the order calculated
      ###
      foreach signal $order {
        if { $signal in $signals && $signal ni $ignored } {
          set action [dict getnull $sigdat $signal action:]
        }
      }
      foreach signal $order {
        if { $signal in $signals && $signal ni $ignored } {
          lappend signals_processed $signal
          if {$trace} {
            puts [list $signal [dict getnull $sigdat $signal action:]]
          }
          eval [dict getnull $sigdat $signal action:]
        }
      }
    }
    my Signal_Idle
    ###
    # If this sequence triggered more sequences
    # schedule our next call
    ###
    set signals_processed {}
  }

  # Actions to perform while entering a busy cycle
  method Signal_Busy {} {
    my variable isbusy 1
  }

  # Actions to perform while exiting a busy cycle
  method Signal_Idle {} {
    my variable isbusy 0
  }
  
  method is_busy {} {
    my variable isbusy
    if {![info exists isbusy]} {
      set isbusy 0
    }
    return $isbusy
  }

  method trace {args} {
    my variable do_trace
    if {![info exists do_trace]} {
      set do_trace 0
    }
    if {[llength $args]} {
      set do_trace [string is true -strict [lindex $args 0]]
    }
    return $do_trace
  }
}

namespace eval ::tool {
  variable trace 0
  variable all_coroutines
  if {![info exists all_coroutines]} {
    set all_coroutines {}
  }
}

package provide tool::pipeline 0.1

