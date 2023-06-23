if {![package vsatisfies [package provide Tcl] 8.5 9]} {
    # PRAGMA: returnok
    return
}
package ifneeded treeql 1.3.1 [list source [file join $dir treeql.tcl]]
