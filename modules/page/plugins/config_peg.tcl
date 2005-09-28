# -*- tcl -*- $Id: config_peg.tcl,v 1.1 2005/09/28 04:51:22 andreas_kupries Exp $

package provide page::config::peg 1.0

proc page_cdefinition {} {
    return {
	--reset
	--append
	--reader    peg
	--transform reachable
	--transform realizable
	--writer    me
    }
}
