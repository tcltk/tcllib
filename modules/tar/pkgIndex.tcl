if {![package vsatisfies [package provide Tcl] 8.5 9]} { return }
package ifneeded tar 0.12.1 [list source [file join $dir tar.tcl]]
