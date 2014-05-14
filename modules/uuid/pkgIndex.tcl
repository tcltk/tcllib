# pkgIndex.tcl - 
#
# uuid package index file
#
# $Id: pkgIndex.tcl,v 1.3 2012/11/19 19:28:24 andreas_kupries Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded uuid 1.0.3 [list source [file join $dir uuid.tcl]]
