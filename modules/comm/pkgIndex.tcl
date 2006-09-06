if {![package vsatisfies [package provide Tcl] 8]} {return}
package ifneeded comm 4.3.2 [list source [file join $dir comm.tcl]]
