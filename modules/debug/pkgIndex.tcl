if {![package vsatisfies [package require Tcl] 8.5]} return
package ifneeded debug            1.0.4 [list source [file join $dir debug.tcl]]
package ifneeded debug::heartbeat 1     [list source [file join $dir heartbeat.tcl]]
package ifneeded debug::timestamp 1     [list source [file join $dir timestamp.tcl]]
package ifneeded debug::caller    1     [list source [file join $dir caller.tcl]]
