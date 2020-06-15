if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded md5c 0.12 [list source [file join $dir md5c.tcl]]
