# pkgIndex.tcl for the tcllib http module.
#
# $Id: pkgIndex.tcl,v 1.3 2005/02/17 15:14:25 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded autoproxy 1.2.1 [list source [file join $dir autoproxy.tcl]]
