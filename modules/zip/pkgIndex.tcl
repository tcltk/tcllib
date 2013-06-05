if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded zipfile::encode 0.3 [list source [file join $dir encode.tcl]]
package ifneeded zipfile::decode 0.4 [list source [file join $dir decode.tcl]]
