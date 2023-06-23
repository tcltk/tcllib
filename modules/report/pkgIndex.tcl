if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded report 0.4 [list source [file join $dir report.tcl]]
