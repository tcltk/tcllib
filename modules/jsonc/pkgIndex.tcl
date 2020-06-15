# Tcl package index file, version 1.1

if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded jsonc 1.1.2 [list source [file join $dir jsonc.tcl]]
