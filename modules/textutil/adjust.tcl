namespace eval ::textutil {

    namespace eval adjust {

	variable StrRepeat [ namespace parent ]::strRepeat
	variable Justify  left
	variable Length   72
	variable FullLine 0
	variable StrictLength 0
	
	namespace export adjust

	# This will be redefined later. We need it just to let
	# a chance for the next import subcommand to work
	#
	proc adjust { text args } { }	

    }

    namespace import -force adjust::adjust
    namespace export adjust

}

#########################################################################

proc ::textutil::adjust::adjust { text args } {
	    
    if { [ string length [ string trim $text ] ] == 0 } then { 
	return ""
    }
    
    Configure $args
    Adjust text newtext
    
    return $newtext
}

proc ::textutil::adjust::Configure { args } {
    variable Justify   left
    variable Length    72
    variable FullLine  0
    variable StrictLength 0

    set args [ lindex $args 0 ]
    foreach { option value } $args {
	switch -exact -- $option {
	    -full {
		if { ![ string is boolean -strict $value ] } then {
		    error "expected boolean but got \"$value\""
		}
		set FullLine [ string is true $value ]
	    }
	    -justify {
		set lovalue [ string tolower $value ]
		switch -exact -- $lovalue {
		    left -
		    right -
		    center -
		    plain {
			set Justify $lovalue
		    }
		    default {
			error "bad value \"$value\": should be center, left, plain or right"
		    }
		}   
	    }
	    -length {
		if { ![ string is integer $value ] } then {
		    error "expected positive integer but got \"$value\""
		}
		if { $value < 1 } then {
		    error "expected positive integer but got \"$value\""
		}
		set Length $value
	    }
	    -strictlength {
		if { ![ string is boolean -strict $value ] } then {
		    error "expected boolean but got \"$value\""
		}
		set StrictLength [ string is true $value ]
            }
	    default {
		error "bad option \"$option\": must be -full, -justify, -length, or -strictlength"
	    }
	}
    }

    return ""
}

proc ::textutil::adjust::Adjust { varOrigName varNewName } {
    variable Length
    variable StrictLength

    upvar $varOrigName orig
    upvar $varNewName  text

    regsub -all -- "(\n)|(\t)"     $orig  " "  text
    regsub -all -- " +"            $text  " "  text
    regsub -all -- "(^ *)|( *\$)"  $text  ""   text

    set ltext [ split $text ]

    if { $StrictLength } then {

        # Limit the length of a line to $Length. If any single
        # word is long than $Length, then split the word into multiple
        # words.
 
        set i 0
        foreach tmpWord $ltext {
            if { [ string length $tmpWord ] > $Length } then {
 
                # Since the word is longer than the line length,
                # remove the word from the list of words.  Then
                # we will insert several words that are less than
                # or equal to the line length in place of this word.
 
                set ltext [ lreplace $ltext $i $i ]
                incr i -1
                set j 0
 
                # Insert a series of shorter words in place of the
                # one word that was too long.
 
                while { $j < [ string length $tmpWord ] } {
 
                    # Calculate the end of the string range for this word.
 
                    if { [ expr { [string length $tmpWord ] - $j } ] > $Length } then {
                        set end [ expr { $j + $Length - 1} ]
                    } else {
                        set end [ string length $tmpWord ]
                    }
 
                    set ltext [ linsert $ltext [ expr {$i + 1} ] [ string range $tmpWord $j $end ] ]
                    incr i
                    incr j [ expr { $end - $j + 1 } ]
                }
            }
            incr i
        }
    }

    set line [ lindex $ltext 0 ]
    set pos [ string length $line ]
    set text ""
    set numline 0
    set numword 1
    set words(0) 1
    set words(1) [ list $pos $line ]

    foreach word [ lrange $ltext 1 end ] {
        set size [ string length $word ]
        if { ( $pos + $size ) < $Length } then {
            append line " $word"
	    incr numword
	    incr words(0)
	    set words($numword) [ list $size $word ]
            incr pos
            incr pos $size
        } else {
            if { [ string length $text ] != 0 } then {
                append text "\n"
            }
            append text [ Justification $line [ incr numline ] words ]
            set line "$word"
            set pos $size
	    catch { unset words }
	    set numword 1
	    set words(0) 1
	    set words(1) [ list $size $word ]
        }
    }
    if { [ string length $text ] != 0 } then {
	append text "\n"
    }
    append text [ Justification $line end words ]
    
    return $text
}

proc ::textutil::adjust::Justification { line index arrayName } {
    variable Justify
    variable Length
    variable FullLine
    variable StrRepeat

    upvar $arrayName words

    set len [ string length $line ]
    if { $Length == $len } then {
        return $line
    }

    # Special case:
    # for the last line, and if the justification is set to 'plain'
    # the real justification is 'left' if the length of the line
    # is less than 90% (rounded) of the max length allowed. This is
    # to avoid expansion of this line when it is too small: without
    # it, the added spaces will 'unbeautify' the result.
    #

    set justify $Justify
    if { ( "$index" == "end" ) && \
	     ( "$Justify" == "plain" ) && \
	     ( $len < round($Length * 0.90) ) } then {
	set justify left
    }

    # For a left justification, nothing to do, but to
    # add some spaces at the end of the line if requested
    #
	
    if { "$justify" == "left" } then {
	set jus ""
	if { $FullLine } then {
	    set jus [ $StrRepeat " " [ expr { $Length - $len } ] ]
	}
        return "${line}${jus}"
    }

    # For a right justification, just add enough spaces
    # at the beginning of the line
    #

    if { "$justify" == "right" } then {
	set jus [ $StrRepeat " " [ expr { $Length - $len } ] ]
        return "${jus}${line}"
    }

    # For a center justification, add half of the needed spaces
    # at the beginning of the line, and the rest at the end
    # only if needed.

    if { "$justify" == "center" } then {
        set mr [ expr { ( $Length - $len ) / 2 } ]
        set ml [ expr { $Length - $len - $mr } ]
	set jusl [ $StrRepeat " " $ml ]
	set jusr [ $StrRepeat " " $mr ]
	if { $FullLine } then {
	    return "${jusl}${line}${jusr}"
	} else {
	    return "${jusl}${line}"
	}
    }

    # For a plain justiciation, it's a little bit complex:
    # if some spaces are missing, then
    # sort the list of words in the current line by
    # decreasing size
    # foreach word, add one space before it, except if
    # it's the first word, until enough spaces are added
    # then rebuild the line
    #

    if { "$justify" == "plain" } then {
	set miss [ expr { $Length - [ string length $line ] } ]
	if { $miss == 0 } then {
	    return "${line}"
	}

	for { set i 1 } { $i < $words(0) } { incr i } {
	    lappend list [ eval list $i $words($i) 1 ]
	}
	lappend list [ eval list $i $words($words(0)) 0 ]
	set list [ SortList $list decreasing 1 ]

	set i 0
	while { $miss > 0 } {
	    set elem [ lindex $list $i ]
	    set nb [ lindex $elem 3 ]
	    incr nb
	    set elem [ lreplace $elem 3 3 $nb ]
	    set list [ lreplace $list $i $i $elem ]
	    incr miss -1
	    incr i
	    if { $i == $words(0) } then {
		set i 0
	    }
	}
	set list [ SortList $list increasing 0 ]
	set line ""
	foreach elem $list {
	    set jus [ $StrRepeat " " [ lindex $elem 3 ] ]
	    set word [ lindex $elem 2 ]
	    if { [ lindex $elem 0 ] == $words(0) } then {
		append line "${jus}${word}"
	    } else {
		append line "${word}${jus}"
	    }
	}

	return "${line}"
    }

    error "Illegal justification key \"$justify\""
}

proc ::textutil::adjust::SortList { list dir index } {

    if { [ catch { lsort -integer -$dir -index $index $list } sl ] != 0 } then {
	error "$sl"
    }

    return $sl
}
