# pkgIndex.tcl - 
#
# md4 package index file
#
# This package has been tested with tcl 8.2.3 and above.
#
# $Id: pkgIndex.tcl,v 1.3.2.1 2004/05/24 03:13:33 andreas_kupries Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded md4 1.0.1 [list source [file join $dir md4.tcl]]
