#checker -scope global exclude warnUndefinedVar
# var in question is 'dir'.
if {![package vsatisfies [package provide Tcl] 8.5]} {
    # PRAGMA: returnok
    return
}
package ifneeded oo::util 1.2.2 [list source [file join $dir ooutil.tcl]]
package ifneeded oo::meta 0.1 [list source [file join $dir oometa.tcl]]
package ifneeded oo::option 0.1 [list source [file join $dir oooption.tcl]]
