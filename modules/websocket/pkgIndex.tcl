if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded websocket 1.5 [list source [file join $dir websocket.tcl]]
