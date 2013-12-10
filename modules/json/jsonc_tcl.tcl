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

if {![package vsatisfies [package provide Tcl] 8.5]} {
    package require dict
}

package provide json 1.2

namespace eval json {
    # Regular expression for tokenizing a JSON text (cf. http://json.org/)

    # tokens consisting of a single character
    variable singleCharTokens { "{" "}" ":" "\\[" "\\]" "," }
    variable singleCharTokenRE "\[[join $singleCharTokens {}]\]"

    # quoted string tokens
    variable escapableREs { "[\\\"\\\\/bfnrt]" "u[[:xdigit:]]{4}" }
    variable escapedCharRE "\\\\(?:[join $escapableREs |])"
    variable unescapedCharRE {[^\\\"]}
    variable stringRE "\"(?:$escapedCharRE|$unescapedCharRE)*\""

    # (unquoted) words
    variable wordTokens { "true" "false" "null" }
    variable wordTokenRE [join $wordTokens "|"]

    # number tokens
    # negative lookahead (?!0)[[:digit:]]+ might be more elegant, but
    # would slow down tokenizing by a factor of up to 3!
    variable positiveRE {[1-9][[:digit:]]*}
    variable cardinalRE "-?(?:$positiveRE|0)"
    variable fractionRE {[.][[:digit:]]+}
    variable exponentialRE {[eE][+-]?[[:digit:]]+}
    variable numberRE "${cardinalRE}(?:$fractionRE)?(?:$exponentialRE)?"

    # JSON token
    variable tokenRE "$singleCharTokenRE|$stringRE|$wordTokenRE|$numberRE"

    # 0..n white space characters
    set whiteSpaceRE {[[:space:]]*}

    # Regular expression for validating a JSON text
    variable validJsonRE "^(?:${whiteSpaceRE}(?:$tokenRE))*${whiteSpaceRE}$"
}


# Validate JSON text
# @param jsonText JSON text
# @return 1 iff $jsonText conforms to the JSON grammar
#           (@see http://json.org/)
proc ::json::validate_critcl {jsonText} {
    variable validJsonRE

    return [regexp -- $validJsonRE $jsonText]
}

# Parse multiple JSON entities in a string into a list of dictionaries
# @param jsonText JSON text to parse
# @param max      Max number of entities to extract.
# @return list of (dict (or list) containing the objects) represented by $jsonText
proc ::json::many-json2dict_critcl {jsonText {max -1}} {
    error not-implemented-yet
}

proc ::json::dict2json_critcl {dictVal} {
    # XXX: Currently this API isn't symmetrical, as to create proper
    # XXX: JSON text requires type knowledge of the input data
    set json ""

    dict for {key val} $dictVal {
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
