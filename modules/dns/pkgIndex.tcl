# pkgIndex.tcl -
#
# $Id: pkgIndex.tcl,v 1.12 2004/11/21 01:05:06 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded dns    1.2.1 [list source [file join $dir dns.tcl]]
package ifneeded resolv 1.0.3 [list source [file join $dir resolv.tcl]]
package ifneeded ip     1.0.0 [list source [file join $dir ip.tcl]]
package ifneeded spf    1.1.0 [list source [file join $dir spf.tcl]]
