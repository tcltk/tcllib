if {![package vsatisfies [package provide Tcl] 8.4]} return
package ifneeded base32c      0.1 [list source [file join $dir base32_c.tcl]]
package ifneeded base32c::hex 0.1 [list source [file join $dir base32hex_c.tcl]]
