if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded smtp 1.5.1 [list source [file join $dir smtp.tcl]]
package ifneeded mime 1.7.1 [list source [file join $dir mime.tcl]]
