# (c) 2019 Andreas Kupries
# Redirection wrapper for deprecated package
# Deprecated:
# - paths
# Replacement:
# - fileutil::paths

package require Tcl 8.4
package require fileutil::paths

proc ::paths {args} { uplevel 1 [linsert $args 0 ::fileutil::paths] }

package provide paths 1
return
