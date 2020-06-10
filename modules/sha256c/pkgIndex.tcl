if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded sha256c 1.0.4 [list source [file join $dir sha256c.tcl]]
