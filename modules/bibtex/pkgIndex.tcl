if {![package vsatisfies [package provide Tcl] 8.5 9]} {return}
package ifneeded bibtex 0.7 [list source [file join $dir bibtex.tcl]]
