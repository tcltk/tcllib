if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded uevent 0.1.2 [list source [file join $dir uevent.tcl]]

