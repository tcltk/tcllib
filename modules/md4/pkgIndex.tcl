# pkgIndex.tcl - 
#
# md4 package index file
#
# This package has been tested with tcl 8.2.3 and above.
#
# $Id: pkgIndex.tcl,v 1.2 2003/05/07 22:30:51 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded md4 1.0.1 [list source [file join $dir md4.tcl]]
