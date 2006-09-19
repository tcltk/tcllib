if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded doctools            1.2.1 [list source [file join $dir doctools.tcl]]
package ifneeded doctools::toc       0.2.1 [list source [file join $dir doctoc.tcl]]
package ifneeded doctools::idx       0.2.1 [list source [file join $dir docidx.tcl]]
package ifneeded doctools::cvs       0.1.1 [list source [file join $dir cvs.tcl]]
package ifneeded doctools::changelog 0.1.1 [list source [file join $dir changelog.tcl]]
