# base64c - Copyright (C) 2003 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# This file implements the base64c package which provides compiled speedups
# for the tcllib base64 module.
#
# The actual C code is embedded in each of the modules package files.
# To build this compiled package:
#  critcl -libdir .. -pkg base64c base64c.tcl uuencode.tcl ...
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
# @(#)$Id: base64c.tcl,v 1.1.2.1 2003/04/22 00:01:03 patthoyts Exp $

package require critcl
critcl::ccode {
    /* dummy - required to make critcl accept this file*/
}
package provide base64c 1.0.0

# -------------------------------------------------------------------------
#
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:

