# Tcl package index file, version 1.1

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded ldap 1.2 [list source [file join $dir ldap.tcl]]
