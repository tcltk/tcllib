# pkgIndex.tcl -
#
# $Id: pkgIndex.tcl,v 1.11 2004/07/23 20:39:17 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded dns    1.2.0 [list source [file join $dir dns.tcl]]
package ifneeded resolv 1.0.3 [list source [file join $dir resolv.tcl]]
package ifneeded ip     1.0.0 [list source [file join $dir ip.tcl]]
package ifneeded spf    1.1.0 [list source [file join $dir spf.tcl]]
