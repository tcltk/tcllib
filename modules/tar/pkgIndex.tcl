if {![package vsatisfies [package provide Tcl] 8.5 9]} { return }
package ifneeded tar 0.15 [list source [file join $dir tar.tcl]]
