if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded sha1c 2.0.4 [list source [file join $dir sha1c.tcl]]
