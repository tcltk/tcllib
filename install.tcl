# -*- tcl -*-
#
# Install tcllib in the lib directory of the tclsh used to execute
# this script.

proc xcopy {src dest} {
    file mkdir $dest
    foreach file [glob [file join $src *]] {
        set base [file tail $file]
	set sub  [file join $dest $base]

        if {[file isdirectory $file]} then {
            file mkdir  $sub
            xcopy $file $sub
        } else {
            file copy $file $sub
        }
    }
}

set installdir [file join [file dirname [info library]] tcllib1.3]

#puts $installdir
#exit

file mkdir $installdir
file copy pkgIndex.tcl $installdir

xcopy [file join doc html] [file join $installdir doc]

cd modules

foreach module [glob -nocomplain *] {
    xcopy $module [file join $installdir $module]
}
