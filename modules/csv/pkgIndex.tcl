if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded csv 0.8 [list source [file join $dir csv.tcl]]
