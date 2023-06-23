if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded cmdline 1.5.2 [list source [file join $dir cmdline.tcl]]
