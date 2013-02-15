# # ## ### ##### ######## ############# #####################
## Copyright (c) 2013 Andreas Kupries, BSD licensed

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require string::token

# # ## ### ##### ######## ############# #####################
## API setup

namespace eval ::string::token {
    # Note: string::token claims the "text" and "file" commands.
    namespace export shell
    namespace ensemble create
}

proc ::string::token::shell {text} {
    # result = list (word)

    set     lexer {}
    lappend lexer {[ \t\n\f\v]+}        WSPACE
    lappend lexer {'[^']*'}             QUOTED
    lappend lexer "\"(\[^\"\]|\\\")*\"" QUOTED
    lappend lexer "\[^ \t\n\f\v'\"\]+"  PLAIN
    lappend lexer {.*}                  ERROR

    set result {}

    # States:
    # - WS-WORD : Expected whitespace or word.
    # - WS      : Expected whitespace
    # - WORD    : Expected word.

    # We may have leading whitespace.
    set state WS-WORD

    foreach token [text $lexer $text] {
	#puts "$state + $token"

	lassign $token type start end

	switch -glob -- ${type}/$state {
	    ERROR/* {
		return -code error "Unexpected character '[string index $text $start' at $start"
	    }
	    WSPACE/WORD {
		return -code error "Expected start of word, got whitespace at $start."
	    }
	    WORD*/WS {
		return -code error "Expected whitespace, got start of word at $start"
	    }
            WSPACE/WS* {
		# ignore leading, inter-word and trailing whitespace
		# must be followed by a word
		set state WORD
	    }
	    QUOTED/*WORD {
		# quoted word, extract it, ignore delimiters.
		# must be followed by whitespace.
		incr start
		incr end -1
		lappend result [string range $text $start $end]
		set state WS
	    }
	    PLAIN/*WORD {
		# unquoted word. extract.
		# must be followed by whitespace.
		lappend result [string range $text $start $end]
		set state WS
	    }
	    * {
		return -code error "Illegal token/state combination $type/$state"
	    }
        }
    }
    return $result
}

# # ## ### ##### ######## ############# #####################
## Ready

package provide string::token::shell 1
return
