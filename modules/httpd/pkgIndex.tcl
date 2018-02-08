
if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded httpd 4.1.0 [list source [file join $dir httpd.tcl]]

