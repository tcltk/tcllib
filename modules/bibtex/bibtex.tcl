#####
#
# "BibTeX parser"
# http://wiki.tcl.tk/13719
#
# Tcl code harvested on:   7 Mar 2005, 23:55 GMT
# Wiki page last updated: ???
#
#####

# bibtex.tcl --
#
#      A basic parser for BibTeX bibliography databases.
#
# Copyright (c) 2005 Neil Madden.
# License: Tcl/BSD style.

### NOTES
###
### Need commands to introspect parser state. Especially the string
### map (for testing of 'addStrings', should be useful in general as
### well).

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4

# ### ### ### ######### ######### #########
## Implementation: Public API

namespace eval ::bibtex {}

# bibtex::parse --
#
#	Parse a bibtex file.
#
# parse ?options? ?bibtex?
#
# where options can be:
#	-recordcommand cmd	-- callback for each record
#	-preamblecommand cmd	-- callback for @preamble blocks
#	-stringcommand cmd	-- callback for @string macros
#	-commentcommand cmd	-- callback for @comment blocks
#	-progresscommand cmd	-- callback to indicate progress of parse

proc ::bibtex::parse {args} {
    # A rough BibTeX grammar (case-insensitive):
    #
    # Database      ::= (Junk '@' Entry)*
    # Junk          ::= .*?
    # Entry         ::= Record
    #               |   Comment
    #               |   String
    #               |   Preamble
    # Comment       ::= "comment" [^\n]* \n         -- ignored
    # String        ::= "string" '{' Field* '}'
    # Preamble      ::= "preamble" '{' .* '}'       -- (balanced)
    # Record        ::= Type '{' Key ',' Field* '}'
    #               |   Type '(' Key ',' Field* ')' -- not handled
    # Type          ::= Name
    # Key           ::= Name
    # Field         ::= Name '=' Value
    # Name          ::= [^\s\"#%'(){}]*
    # Value         ::= [0-9]+
    #               |   '"' ([^'"']|\\'"')* '"'
    #               |   '{' .* '}'                  -- (balanced)

    # " - Fixup emacs hilit confusion from the grammar above.
    variable data
    variable id

    # Argument processing
    if {[llength $args] < 1} {
	set err "[lindex [info level 0] 0] ?options? ?bibtex?"
	return -code error "wrong # args: should be \"$err\""
    }
    set token bibtex[incr id]
    array set options {
	-async		0
	-blocksize		1024
    }
    set options(-stringcommand) [list [namespace current]::addStrings]
    if {[llength $args] % 2 == 1} {
	set data($token,buffer) [lindex $args end]
	set data($token,eof) 1
	array set options [lrange $args 0 end-1]
    } else {
	set data($token,buffer) ""
	set data($token,eof) 0
	array set options [lrange $args 0 end]
	if {![info exists options(-channel)]} {
	    destroy $token
	    return -code error "no channel and no data given"
	}
	if {$options(-async)} {
	    fileevent $options(-channel) readable \
		    [list [namespace current]::ReadChan $token]]
	} else {
	    # Snarf it all up in one go for now
	    set data($token,buffer) [read $options(-channel)]
	    set data($token,eof) 1
	}
    }
    foreach {k v} [array get options] { set data($token,$k) $v }
    # String mappings
    set data($token,strings) { }
    if {$options(-async)} {
	destroy $token
	return -code error "not implemented"
    } else {
	ParseRecords $token
    }
    return $token
}

# Cleanup a parser, cancelling any callbacks etc.

proc ::bibtex::destroy {token} {
    variable data

    set keylist [array names data $token,*]
    if {![llength $keylist]} {
	return -code error "Illegal bibtex parser \"$token\""
    }

    if {[info exists data($token,channel)]} {
	fileevent $data($token,channel) readable {}
    }
    foreach key $keylist {
	unset data($key)
    }
    return
}

# bibtex::addStrings --
#
#	Add strings to the map for a particular parser. All strings are
#	expanded at parse time.

proc ::bibtex::addStrings {token strings} {
    variable data
    eval [linsert $strings 0 lappend data($token,strings)]
    return
}

# ### ### ### ######### ######### #########
## Implementation: Private utility routines

proc ::bibtex::Callback {token type args} {
    variable data

    #puts stdout "Callback ($token $type ($args))"

    if {[info exists data($token,-${type}command)]} {
	if {$data($token,-async)} {
	    after 0 $data($token,-${type}command) [linsert $args 0 $token]
	} else {
	    eval $data($token,-${type}command) [linsert $args 0 $token]
	}
    }
    return
}

proc ::bibtex::ReadChan {token} {
    variable data
    set chan $data($token,-channel)
    append data($token,buffer) [read $chan]

    if {[eof $chan]} {
	set data($token,eof) 1
    }
    return
}

proc ::bibtex::Tidy {str} {
    return [string tolower [string trim $str]]
}

proc ::bibtex::ParseRecords {token} {
    variable data
    set bibtex $data($token,buffer)

    # Split at each @ character which is at the beginning of a line,
    # modulo whitespace. This is a heuristic to distinguish the @'s
    # starting a new record from the @'s occuring inside a record, as
    # part of email addresses. Empty pices at beginning or end are
    # stripped before the split.

    regsub -line -all {^[\n\r\f\t ]*@} $bibtex \000 bibtex
    set db [split [string trim $bibtex \000] \000]

    set total [llength $db] ;#[expr {([llength $db]-2)/2}]
    set step  [expr {double($total) / 100.0}]
    set istep [expr {$step > 1 ? int($step) : 1}]
    set count 0
    foreach block $db {
	if {([incr count] % $istep) == 0} {
	    Callback $token progress [expr {int($count / $step)}]
	}
	if {[regexp -nocase {\s*comment([^\n])*\n(.*)} $block \
		-> cmnt rest]} {
	    # Are @comments blocks, or just 1 line?
	    # Does anyone care?
	    Callback $token comment $cmnt

	} elseif {[regexp -nocase {\s*string[^\{]*\{(.*)\}[^\}]*} \
		$block -> rest]} {
	    # string macro defs
	    Callback $token string [ParseBlock $rest]

	} elseif {[regexp -nocase {\s*preamble[^\{]*\{(.*)\}[^\}]*} \
		$block -> rest]} {
	    Callback $token preamble $rest

	} elseif {[regexp {([^\{]+)\{([^,]*),(.*)\}[^\}]*} \
		$block -> type key rest]} {
	    # Do any @string mappings (these are case insensitive)
	    set rest [string map -nocase $data($token,strings) $rest]
	    Callback $token record [Tidy $type] [string trim $key] \
		    [ParseBlock $rest]
	} else {
	    ## FUTURE: Use a logger.
	    puts stderr "Skipping: $block"
	}
    }
}

proc ::bibtex::ParseBlock {block} {
    set ret   [list]
    set index 0
    while {
	[regexp -start $index -indices -- \
		{(\S+)[^=]*=(.*)} $block -> key rest]
    } {
	foreach {ks ke} $key break
	set k [Tidy [string range $block $ks $ke]]
	foreach {rs re} $rest break
	foreach {v index} \
		[ParseBibString $rs [string range $block $rs $re]] \
		break
	lappend ret $k $v
    }
    return $ret
}

proc ::bibtex::ParseBibString {index str} {
    set count 0
    set retstr ""
    set escape 0
    set string 0
    foreach char [split $str ""] {
	incr index
	if {$escape} {
	    set escape 0
	} else {
	    if {$char eq "\{"} {
		incr count
		continue
	    } elseif {$char eq "\}"} {
		incr count -1
		if {$count < 0} {incr index -1; break}
		continue
	    } elseif {$char eq ","} {
		if {$count == 0} break
	    } elseif {$char eq "\\"} {
		set escape 1
		continue
	    } elseif {$char eq "\""} {
		# Managing the count ensures that comma inside of a
		# string is not considered as the end of the field.
		if {!$string} {
		    incr count
		    set string 1
		} else {
		    incr count -1
		    set string 0
		}
		continue
	    }
	    # else: Nothing
	}
	append retstr $char
    }
    regsub -all {\s+} $retstr { } retstr
    return [list [string trim $retstr] $index]
}


# ### ### ### ######### ######### #########
## Internal. Package configuration and state.

namespace eval bibtex {
    # Counter for the generation of parser tokens.
    variable id 0

    # State of all parsers. Keys for each parser are prefixed with the
    # parser token.
    variable  data
    array set data {}

    # Keys and their meaning (listed without token prefix)
    ##
    # buffer
    # eof
    # channel    <-\/- Difference ?
    # strings      |
    # -async       |
    # -blocksize   |
    # -channel   <-/
    # -recordcommand   -- callback for each record
    # -preamblecommand -- callback for @preamble blocks
    # -stringcommand   -- callback for @string macros
    # -commentcommand  -- callback for @comment blocks
    # -progresscommand -- callback to indicate progress of parse
    ##
}

# ### ### ### ######### ######### #########
## Ready to go
package provide bibtex 0.4
# EOF
