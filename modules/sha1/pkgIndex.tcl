if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded sha256 1.0.4 [list source [file join $dir sha256.tcl]]
package ifneeded sha1   2.0.4 [list source [file join $dir sha1.tcl]]
package ifneeded sha1   1.1.1 [list source [file join $dir sha1v1.tcl]]
