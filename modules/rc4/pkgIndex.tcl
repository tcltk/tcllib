# pkgIndex.tcl - 
#
# RC4 package index file
#
# This package has been tested with tcl 8.2.3 and above.
#
# $Id: pkgIndex.tcl,v 1.3 2005/09/04 17:19:59 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {
    # PRAGMA: returnok
    return
}
package ifneeded rc4 1.0.1 [list source [file join $dir rc4.tcl]]
