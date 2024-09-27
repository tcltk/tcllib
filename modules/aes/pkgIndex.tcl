if {![package vsatisfies [package provide Tcl] 8.5 9]} {
    # PRAGMA: returnok
    return
}
package ifneeded aes 1.2.3 [list source [file join $dir aes.tcl]]
package ifneeded aesc 0.2.0 [list source [file join $dir aesc.tcl]]
