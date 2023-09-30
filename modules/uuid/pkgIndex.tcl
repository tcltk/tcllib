if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded uuid 1.0.8 [list source [file join $dir uuid.tcl]]
