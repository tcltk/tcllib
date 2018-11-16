package require Tcl 8.6 ;# try in pipeline.tcl. Possibly other things.
package require TclOO
package require md5 2

::namespace eval ::clay {}
::namespace eval ::clay::classes {}
::namespace eval ::clay::define {}
::namespace eval ::clay::tree {}
::namespace eval ::clay::dict {}
::namespace eval ::clay::list {}
::namespace eval ::clay::uuid {}

###
# Because many features in this package may be added as
# commands to future tcl cores, or be provided in binary
# form by packages, I need a declaritive way of saying
# [emph {Create this command if there isn't one already}].
# The [emph ninja] argument is a script to execute if the
# command is created by this mechanism.
###
proc ::clay::PROC {name arglist body {ninja {}}} {
  if {[info commands $name] ne {}} return
  proc $name $arglist $body
  eval $ninja
}
if {[info commands ::PROC] eq {}} {
  namespace eval ::clay { namespace export PROC }
  namespace eval :: { namespace import ::clay::PROC }
}

proc ::clay::K {a b} {set a}
if {[info commands ::K] eq {}} {
  namespace eval ::clay { namespace export K }
  namespace eval :: { namespace import ::clay::K }
}

###
# Perform a noop. Useful in prototyping for commenting out blocks
# of code without actually having to comment them out. It also makes
# a handy default for method delegation if a delegate has not been
# assigned yet.
proc ::clay::noop args {}
if {[info commands ::noop] eq {}} {
  namespace eval ::clay { namespace export noop }
  namespace eval :: { namespace import ::clay::noop }
}

###
# Append a line of text to a variable. Optionally apply a string mapping.
# arglist:
#   map {mandatory 0 positional 1}
#   text {mandatory 1 positional 1}
###
proc ::clay::putb {buffername args} {
  upvar 1 $buffername buffer
  switch [llength $args] {
    1 {
      append buffer [lindex $args 0] \n
    }
    2 {
      append buffer [string map {*}$args] \n
    }
    default {
      error "usage: putb buffername ?map? string"
    }
  }
}
if {[info command ::putb] eq {}} {
  namespace eval ::clay { namespace export putb }
  namespace eval :: { namespace import ::clay::putb }
}
