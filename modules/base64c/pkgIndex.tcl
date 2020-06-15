if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded base64c 2.4.2 [list source [file join $dir base64c.tcl]]
