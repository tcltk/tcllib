if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded report 0.4 [list source [file join $dir report.tcl]]
