# pkgIndex.tcl - 
#
# RIPEMD package index file
#
# This package has been tested with tcl 8.2.3 and above.
#
# $Id: pkgIndex.tcl,v 1.2 2004/02/18 14:32:04 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded ripemd128 1.0.0 [list source [file join $dir ripemd128.tcl]]
package ifneeded ripemd160 1.0.0 [list source [file join $dir ripemd160.tcl]]
