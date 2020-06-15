# base64c - Copyright (C) 2003 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# This package is a place-holder for the critcl enhanced code present in
# the tcllib base64 module.
#
# Normally this code will become part of the tcllibc library.
#

# @sak notprovided base64c
package require critcl

namespace eval ::base64c {
    critcl::ccode {
        /* no code required in this file */
    }
}

package provide base64c 2.4.2
return
