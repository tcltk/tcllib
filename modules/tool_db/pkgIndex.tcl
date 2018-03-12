
if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded tool::db 0.1 [list source [file join $dir tool_db.tcl]]

