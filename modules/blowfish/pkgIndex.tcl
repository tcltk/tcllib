# pkgIndex.tcl - 
#
# Blowfish package index file
#
# $Id: pkgIndex.tcl,v 1.1 2004/12/06 16:15:29 patthoyts Exp $

if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded blowfish 1.0.0 [list source [file join $dir blowfish.tcl]]
