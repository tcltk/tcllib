if {![package vsatisfies [package provide Tcl] 8]} {return}
package ifneeded nameserv::common 0.1 [list source [file join $dir common.tcl]]

if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded nameserv         0.1 [list source [file join $dir nns.tcl]]
package ifneeded nameserv::server 0.2 [list source [file join $dir server.tcl]]
