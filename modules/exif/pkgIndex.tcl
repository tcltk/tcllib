if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded exif 1.0 [list source [file join $dir exif.tcl]]
