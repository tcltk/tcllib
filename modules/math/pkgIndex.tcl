if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded math 1.1 [list source [file join $dir math.tcl]]
package ifneeded math::geometry 1.0 [list source [file join $dir geometry.tcl]]
