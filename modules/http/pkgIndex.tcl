# pkgIndex.tcl for the tcllib http module.
#
# $Id: pkgIndex.tcl,v 1.1 2004/07/17 21:36:05 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded autoproxy 1.1.0 [list source [file join $dir autoproxy.tcl]]
