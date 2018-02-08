###
if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded practcl 0.11 [list source [file join $dir practcl.tcl]]

