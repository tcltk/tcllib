if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded cmdline 1.4 [list source [file join $dir cmdline.tcl]]
