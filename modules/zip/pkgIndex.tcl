if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded zipfile::encode 0.1 [list source [file join $dir encode.tcl]]
package ifneeded zipfile::decode 0.2 [list source [file join $dir decode.tcl]]
