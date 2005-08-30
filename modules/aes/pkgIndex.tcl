if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded report 0.3 [list source [file join $dir aes.tcl]]
