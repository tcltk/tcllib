if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded fileutil 1.16.1 [list source [file join $dir fileutil.tcl]]
package ifneeded fileutil::traverse 0.6 [list source [file join $dir traverse.tcl]]
package ifneeded fileutil::multi     0.1   [list source [file join $dir multi.tcl]]
package ifneeded fileutil::multi::op 0.5.3 [list source [file join $dir multiop.tcl]]
package ifneeded fileutil::decode    0.2.1 [list source [file join $dir decode.tcl]]
package ifneeded fileutil::paths     1     [list source [file join $dir paths.tcl]]
