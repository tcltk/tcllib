if {![package vsatisfies [package provide Tcl] 8.5]} {
    # PRAGMA: returnok
    return
}
package ifneeded aes 1.2.2 [list source [file join $dir aes.tcl]]
package ifneeded aesc 0.0.1 [list source [file join $dir aesc.tcl]]
