# Umbrella, i.e. Bundle, to put all of the critcl modules which are
# found in Tcllib in one shared library.

package require critcl 3.1
package provide tcllibc 0.3.13

if {![critcl::compiling]} {
    error "Unable to build tcllibc, no proper compiler found."
}

namespace eval ::tcllib {
    variable tcllibc_rcsid {$Id: tcllibc.tcl,v 1.13 2010/05/25 19:26:17 andreas_kupries Exp $}
    critcl::ccode {
        /* no code required in this file */
    }
}
