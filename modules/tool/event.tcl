###
# This file implements the Tao event manager
###

::namespace eval ::tao {}

::namespace eval ::tool::event {}

###
# topic: f2853d380a732845610e40375bcdbe0f
# description: Cancel a scheduled event
###
proc ::tool::event::cancel {self {task *}} {
  variable timer_event
  foreach {id event} [array get timer_event $self:$task] {
    ::after cancel $event
    set timer_event($id) {}
  }
}

###
# topic: 8ec32f6b6ba78eaf980524f8dec55b49
# description:
#    Generate an event
#    Adds a subscription mechanism for objects
#    to see who has recieved this event and prevent
#    spamming or infinite recursion
###
proc ::tool::event::generate {self event args} {
  set dictargs [::oo::meta::args_to_options {*}$args]

  set info $dictargs
  set strict 0
  set debug 0
  set sender $self
  dict with dictargs {}
  dict set info id     [::tool::event::nextid]
  dict set info origin $self
  dict set info sender $sender
  dict set info rcpt   {}
  
  
  foreach who [Notification_list $self $event] {
    catch {::tool::event::notify $who $self $event $info}
  }
}

###
# topic: 891289a24b8cc52b6c228f6edb169959
# title: Return a unique event handle
###
proc ::tool::event::nextid {} {
  return "event#[format %0.8x [incr ::tool::event_count]]"
}

###
# topic: 1e53e8405b4631aec17f98b3e8a5d6a4
# description:
#    Called recursively to produce a list of
#    who recieves notifications
###
proc ::tool::event::Notification_list {self event {stackvar {}}} {
  if { $stackvar ne {} } {
    upvar 1 $stackvar stack
  } else {
    set stack {}
  }
  if {$self in $stack} {
    return {}
  }
  lappend stack $self

  ::tool::db eval {select receiver from object_subscribers where string_match(sender,:self) and string_match(event,:event)} {
    ::tool::db eval {select name as rcpt from object where string_match(name,:receiver)} {
      Notification_list $rcpt $event stack
    }
  }
  return $stack
}

###
# topic: b4b12f6aed69f74529be10966afd81da
###
proc ::tool::event::notify {rcpt sender event eventinfo} {
  if {[info commands $rcpt] eq {}} return 
  if {$::tool::trace} {
    puts [list event notify rcpt $rcpt sender $sender event $event info $eventinfo]
  }
  $rcpt notify $event $sender $eventinfo
}

###
# topic: 829c89bda736aed1c16bb0c570037088
###
proc ::tool::event::process {self handle script} {
  variable timer_event
  array unset timer_event $self:$handle
  set err [catch {uplevel #0 $script} result]
  if $err {
    puts "BGError: $self $handle $script
ERR: $result"
  }
}

###
# topic: eba686cffe18cd141ac9b4accfc634bb
# description: Schedule an event to occur later
###
proc ::tool::event::schedule {self handle interval script} {
  variable timer_event

  if {$::tool::trace} {
    puts [list $self schedule $handle $interval]
  }
  if {[info exists timer_event($self:$handle)]} {
    ::after cancel $timer_event($self:$handle)
  }
  set timer_event($self:$handle) [::after $interval [list ::tool::event::process $self $handle $script]]
}

###
# topic: e64cff024027ee93403edddd5dd9fdde
###
proc ::tool::event::subscribe {self who event} {
  ::tool::db eval {
insert or ignore into object(name) VALUES (:self);
insert or replace into object_subscribers (receiver,sender,event) VALUES (:self,:who,:event);
}
}

###
# topic: 5f74cfd01735fb1a90705a5f74f6cd8f
###
proc ::tool::event::unsubscribe {self args} {
  switch {[llength $args]} {
    0 {
      ::tool::db eval {delete from object_subscribers where receiver=:self}
    }
    1 {
      set event [lindex $args 0]
      ::tool::db eval {delete from object_subscribers where receiver=:self and string_match(event,:event)=1}
    }
  }
}

tool::define tool::object {
  ###
  # topic: 20b4a97617b2b969b96997e7b241a98a
  ###
  method event {submethod args} {
    ::tool::event::$submethod [self] {*}$args
  }
}

###
# topic: 37e7bd0be3ca7297996da2abdf5a85c7
# description: The event manager for Tao
###
namespace eval ::tool::event {
  variable nextevent {}
  variable nexteventtime 0
}

