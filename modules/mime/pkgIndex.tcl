if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded mime 1.5.2 [list source [file join $dir mime.tcl]]
package ifneeded smtp 1.4.3 [list source [file join $dir smtp.tcl]]
