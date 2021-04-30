# (c) 2019 Andreas Kupries
# Redirection wrapper for deprecated package
# Deprecated:
# - doctools::paths
# Replacement:
# - fileutil::paths

package require Tcl 8.4
package require fileutil::paths

namespace eval ::doctools {}

proc ::doctools::paths {args} { uplevel 1 [linsert $args 0 ::fileutil::paths] }

package provide doctools::paths 0.1
return
