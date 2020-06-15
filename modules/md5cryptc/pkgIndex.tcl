if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded md5cryptc 1.0 [list source [file join $dir md5cryptc.tcl]]
