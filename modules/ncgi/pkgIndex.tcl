if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded ncgi 1.3.3 [list source [file join $dir ncgi.tcl]]
