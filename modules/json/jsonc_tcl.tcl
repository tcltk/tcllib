#
#   JSON parser for Tcl. Tcl parts of the C parser.
#
#   See http://www.json.org/ && http://www.ietf.org/rfc/rfc4627.txt
#
#   Total rework of the code published with version number 1.0 by
#   Thomas Maeder, Glue Software Engineering AG
#
#   $Id: json.tcl,v 1.7 2011/11/10 21:05:58 andreas_kupries Exp $
#

proc ::json::dict2json_critcl {dictVal} {
    # XXX: Currently this API isn't symmetrical, as to create proper
    # XXX: JSON text requires type knowledge of the input data
    set json ""

    foreach {key val} $dictVal {
	# key must always be a string, val may be a number, string or
	# bare word (true|false|null)
	if {0 && ![string is double -strict $val]
	    && ![regexp {^(?:true|false|null)$} $val]} {
	    set val "\"$val\""
	}
    	append json "\"$key\": $val," \n
    }

    return "\{${json}\}"
}

proc ::json::list2json_critcl {listVal} {
    return "\[[join $listVal ,]\]"
}

proc ::json::string2json_critcl {str} {
    return "\"$str\""
}
