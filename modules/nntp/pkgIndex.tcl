if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded nntp 0.2.2 [list source [file join $dir nntp.tcl]]
