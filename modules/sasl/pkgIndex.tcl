# pkgIndex.tcl                                                -*- tcl -*-
# Copyright (C) 2005 Pat Thoyts <patthoyts@users.sourceforge.net>
# $Id: pkgIndex.tcl,v 1.1 2005/02/01 02:41:00 patthoyts Exp $
package ifneeded sasl 1.0.0 [list source [file join $dir sasl.tcl]]
package ifneeded sasl::ntlm 1.0.0 [list source [file join $dir ntlm.tcl]]