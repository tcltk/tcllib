if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded tie              1.0 [list source [file join $dir tie.tcl]]
package ifneeded tie::file        1.0 [list source [file join $dir tie_file.tcl]]
package ifneeded tie::log         1.0 [list source [file join $dir tie_log.tcl]]
package ifneeded tie::array       1.0 [list source [file join $dir tie_array.tcl]]
package ifneeded tie::remotearray 1.0 [list source [file join $dir tie_rarray.tcl]]
package ifneeded tie::dsource     1.0 [list source [file join $dir tie_dsource.tcl]]

