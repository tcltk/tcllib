###
if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded practcl 0.16.1 [list source [file join $dir practcl.tcl]]

