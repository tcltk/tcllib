# Tcl package index file, version 1.1

if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded ldap 1.6.6 [list source [file join $dir ldap.tcl]]

# the OO level wrapper for ldap
package ifneeded ldapx 0.2.2 [list source [file join $dir ldapx.tcl]]
