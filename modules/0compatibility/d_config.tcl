# (c) 2019 Andreas Kupries
# Redirection wrapper for deprecated package
# Deprecated:
# - doctools::config
# Replacement:
# - struct::map

package require Tcl 8.4
package require struct::map

namespace eval ::doctools {}

proc ::doctools::config {args} { uplevel 1 [linsert $args 0 ::struct::map] }

package provide doctools::config 0.1
return
