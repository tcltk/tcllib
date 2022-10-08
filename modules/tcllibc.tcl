# Umbrella, i.e. Bundle, to put all of the critcl modules which are found in Tcllib in one shared
# library.

package require critcl
package provide tcllibc 0.4

namespace eval ::tcllib {
    critcl::ccode {
        /* no code required in this file */
    }
}
