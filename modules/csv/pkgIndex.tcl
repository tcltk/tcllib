if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded csv 0.7 [list source [file join $dir csv.tcl]]
