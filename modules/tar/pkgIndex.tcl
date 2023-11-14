if {![package vsatisfies [package provide Tcl] 8.5 9]} {
    # PRAGMA: returnok
    return
}
package ifneeded tar 0.12 [list source [file join $dir tar.tcl]]
