proc ::tool::define::coroutine {name corobody} {
  set class [current_class]
  set methodname $name
  set methodname [string trim $methodname /:-]

  $class clay set method_ensemble/ $methodname/ _preamble [list arglist {} body [string map [list %coroname% $name] {
    my variable coro_queue coro_lock
    set coro %coroname%
    set coroname [info object namespace [self]]::%coroname%
  }]]
  $class clay set method_ensemble/ $methodname/ coroutine {arglist {} body {
    return $coroutine
  }}
  $class clay set method_ensemble/ $methodname/ restart {arglist {} body {
    # Don't allow a coroutine to kill itself
    if {[info coroutine] eq $coroname} return
    if {[info commands $coroname] ne {}} {
      rename $coroname {}
    }
    set coro_lock($coroname) 0
    ::coroutine $coroname {*}[namespace code [list my $coro main]]
    ::cron::object_coroutine [self] $coroname
  }}
  $class clay set method_ensemble/ $methodname/ kill {arglist {} body {
    # Don't allow a coroutine to kill itself
    if {[info coroutine] eq $coroname} return
    if {[info commands $coroname] ne {}} {
      rename $coroname {}
    }
  }}

  $class clay set method_ensemble/ $methodname/ main [list arglist {} body $corobody]

  $class clay set method_ensemble/ $methodname/ clear {arglist {} body {
    set coro_queue($coroname) {}
  }}
  $class clay set method_ensemble/ $methodname/ next {arglist {eventvar} body {
    upvar 1 [lindex $args 0] event
    if {![info exists coro_queue($coroname)]} {
      return 1
    }
    if {[llength $coro_queue($coroname)] == 0} {
      return 1
    }
    set event [lindex $coro_queue($coroname) 0]
    set coro_queue($coroname) [lrange $coro_queue($coroname) 1 end]
    return 0
  }}

  $class clay set method_ensemble/ $methodname/ peek {arglist {eventvar} body {
    upvar 1 [lindex $args 0] event
    if {![info exists coro_queue($coroname)]} {
      return 1
    }
    if {[llength $coro_queue($coroname)] == 0} {
      return 1
    }
    set event [lindex $coro_queue($coroname) 0]
    return 0
  }}

  $class clay set method_ensemble/ $methodname/ running {arglist {} body {
    if {[info commands $coroname] eq {}} {
      return 0
    }
    if {[::cron::task exists $coroname]} {
      set info [::cron::task info $coroname]
      if {[dict exists $info running]} {
        return [dict get $info running]
      }
    }
    return 0
  }}

  $class clay set method_ensemble/ $methodname/ send {arglist args body {
    lappend coro_queue($coroname) $args
    if {[info coroutine] eq $coroname} {
      return
    }
    if {[info commands $coroname] eq {}} {
      ::coroutine $coroname {*}[namespace code [list my $coro main]]
      ::cron::object_coroutine [self] $coroname
    }
    if {[info coroutine] eq {}} {
      ::cron::do_one_event $coroname
    } else {
      yield
    }
  }}
  $class clay set method_ensemble/ $methodname/ default {arglist args body {my [self method] send $method {*}$args}}

}
