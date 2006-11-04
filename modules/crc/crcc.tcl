# crcc.tcl - Copyright (C) 2002 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Place holder for building a critcl C module for this tcllib module.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
# $Id: crcc.tcl,v 1.3 2006/11/04 15:20:36 patthoyts Exp $

package require critcl 

namespace eval ::crc {
    variable rcsid {$Id: crcc.tcl,v 1.3 2006/11/04 15:20:36 patthoyts Exp $}

    critcl::ccode {
        /* no code required in this file */
    }
}

package provide crcc 1.0.0