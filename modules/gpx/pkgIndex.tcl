if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded gpx 1.1 [list source [file join $dir gpx.tcl]]
