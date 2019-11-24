# (c) 2019 Andreas Kupries
# Redirection wrapper for deprecated package
# Deprecated:
# - configuration
# Replacement:
# - struct::map

package require Tcl 8.4
package require struct::map

proc ::configuration {args} { uplevel 1 [linsert $args 0 ::struct::map] }

package provide configuration 1
return
