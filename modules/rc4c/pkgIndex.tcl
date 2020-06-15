if {![package vsatisfies [package provide Tcl] 8.4]} return
package ifneeded rc4c 1.1.0 [list source [file join $dir rc4c.tcl]]
