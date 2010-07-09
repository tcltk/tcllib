if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded report 0.2 [list source [file join $dir imap4.tcl]]
