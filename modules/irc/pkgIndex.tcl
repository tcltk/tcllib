# pkgIndex.tcl                                                    -*- tcl -*-
# $Id: pkgIndex.tcl,v 1.9 2008/06/24 22:06:56 patthoyts Exp $
if { ![package vsatisfies [package provide Tcl] 8.3] } {
    # PRAGMA: returnok
    return 
}
package ifneeded irc 0.6 [list source [file join $dir irc.tcl]]
package ifneeded picoirc 0.5.1 [list source [file join $dir picoirc.tcl]]
