namespace eval ::dicttool {}

###
# Because many features in this package may be added as
# commands to future tcl cores, or be provided in binary
# form by packages, I need a declaritive way of saying
# [emph {Create this command if there isn't one already}].
# The [emph ninja] argument is a script to execute if the
# command is created by this mechanism.
###
proc ::PROC {name arglist body {ninja {}}} {
  if {[info commands $name] ne {}} return
  proc $name $arglist $body
  eval $ninja
}

###
# Perform a noop. Useful in prototyping for commenting out blocks
# of code without actually having to comment them out. It also makes
# a handy default for method delegation if a delegate has not been
# assigned yet.
PROC ::noop args {}

###
# Append a line of text to a variable. Optionally apply a string mapping.
# arglist:
#   map {mandatory 0 positional 1}
#   text {mandatory 1 positional 1}
###
PROC ::putb {buffername args} {
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
