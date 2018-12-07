if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded {chan getslimit} 0.1 [list ::source [file join $dir getslimit.tcl]]
package ifneeded {chan base}      0.1 [list ::source [file join $dir base.tcl]]
package ifneeded {chan coroutine} 0.1 [list ::source [file join $dir coroutine.tcl]]
