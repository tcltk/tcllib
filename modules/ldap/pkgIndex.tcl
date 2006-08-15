# Tcl package index file, version 1.1

if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded ldap 1.5 [list source [file join $dir ldap.tcl]]
