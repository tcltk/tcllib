# pkgIndex.tcl                                                -*- tcl -*-
# Copyright (C) 2005 Pat Thoyts <patthoyts@users.sourceforge.net>
# $Id: pkgIndex.tcl,v 1.10 2007/08/26 00:36:45 patthoyts Exp $
if {![package vsatisfies [package provide Tcl] 8.2]} {
    # PRAGMA: returnok
    return
}
package ifneeded SASL 1.3.1 [list source [file join $dir sasl.tcl]]
package ifneeded SASL::NTLM 1.1.1 [list source [file join $dir ntlm.tcl]]
package ifneeded SASL::XGoogleToken 1.0.1 [list source [file join $dir gtoken.tcl]]
