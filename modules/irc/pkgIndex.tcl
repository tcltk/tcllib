# pkgIndex.tcl -*- tcl -*-
if { ![package vsatisfies [package provide Tcl] 8.6 9] } {
    # PRAGMA: returnok
    return
}
package ifneeded irc     0.8.1 [list source [file join $dir irc.tcl]]
package ifneeded picoirc 0.14.1 [list source [file join $dir picoirc.tcl]]
