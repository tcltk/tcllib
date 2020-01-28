if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded uuid 1.0.6 [list source [file join $dir uuid.tcl]]
