if {![package vsatisfies [package provide Tcl] 8.3]} return
package ifneeded pregistry 1.0 [list source [file join $dir registry.tcl]]
