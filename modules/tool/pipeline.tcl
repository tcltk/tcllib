::namespace eval ::tool::signal {}

# Provide a backward compadible hook
proc ::tool::main {} {
  ::cron::main
}

package provide tool::pipeline 0.1

