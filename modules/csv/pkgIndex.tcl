if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded csv 0.9 [list source [file join $dir csv.tcl]]
