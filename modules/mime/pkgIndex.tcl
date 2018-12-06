if {![package vsatisfies [package provide Tcl] 8.6.9]} {return}
package ifneeded smtp 1.5 [list source [file join $dir smtp.tcl]]
package ifneeded mime 1.7 [list source [file join $dir mime.tcl]]
package ifneeded {mime qp} 1.7 [list source [file join $dir qp.tcl]]
