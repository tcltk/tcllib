# pkgIndex.tcl for the tcllib http module.
#
# $Id: pkgIndex.tcl,v 1.2 2004/07/19 13:40:18 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded autoproxy 1.2.0 [list source [file join $dir autoproxy.tcl]]
