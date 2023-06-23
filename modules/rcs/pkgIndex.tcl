if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded rcs 0.1 [list source [file join $dir rcs.tcl]]
