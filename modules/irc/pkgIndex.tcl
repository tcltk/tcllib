# pkgIndex.tcl                                                    -*- tcl -*-
# $Id: pkgIndex.tcl,v 1.7 2006/04/23 22:35:57 patthoyts Exp $
if { ![package vsatisfies [package provide Tcl] 8.3] } {
    # PRAGMA: returnok
    return 
}
package ifneeded irc 0.6 [list source [file join $dir irc.tcl]]
