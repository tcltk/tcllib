# Umbrella, i.e. Bundle, to put all of the critcl modules which are
# found in Tcllib in one shared library.

package require critcl
package provide tcllibc 0.3.1

namespace eval ::tcllib {
    variable tcllibc_rcsid {$Id: tcllibc.tcl,v 1.6 2006/11/04 15:20:36 patthoyts Exp $}
    critcl::ccode {
        /* no code required in this file */
    }
}
