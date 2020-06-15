# Critcl requires Tcl 8.4 or higher.
if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded md4c 1.1.0 [list source [file join $dir md4c.tcl]]
