# pkgIndex.tcl                                                    -*- tcl -*-
# $Id: pkgIndex.tcl,v 1.8 2007/10/19 21:17:13 patthoyts Exp $
if { ![package vsatisfies [package provide Tcl] 8.3] } {
    # PRAGMA: returnok
    return 
}
package ifneeded irc 0.6 [list source [file join $dir irc.tcl]]
package ifneeded picoirc 0.5 [list source [file join $dir picoirc.tcl]]
