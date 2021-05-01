if {![package vsatisfies [package provide Tcl] 8.4]} return
package ifneeded ncgi 1.5.0 [list source $dir/ncgi.tcl]
