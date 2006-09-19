if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded fileutil 1.9 [list source [file join $dir fileutil.tcl]]

if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded fileutil::traverse 0.1 [list source [file join $dir traverse.tcl]]
