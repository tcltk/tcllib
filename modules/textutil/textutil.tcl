package require Tcl 8.2
namespace eval textutil {
    namespace export strRepeat
    
    variable HaveStrRepeat [ expr {![ catch { string repeat a 1 } ]} ]

    if {0} {
	# Problems with the deactivated code:
	# - Linear in 'num'.
	# - Tests for 'string repeat' in every call!
	#   (Ok, just the variable, still a test every call)
	# - Fails for 'num == 0' because of undefined 'str'.

	proc StrRepeat { char num } {
	    variable HaveStrRepeat
	    if { $HaveStrRepeat == 0 } then {
		for { set i 0 } { $i < $num } { incr i } {
		    append str $char
		}
	    } else {
		set str [ string repeat $char $num ]
	    }
	    return $str
	}
    }

}

if {$::textutil::HaveStrRepeat} {
    proc ::textutil::strRepeat {char num} {
	return [string repeat $char $num]
    }

    proc ::textutil::blank {n} {
	return [string repeat " " $num]
    }

} else {
    proc ::textutil::strRepeat {char num} {
	if {$num <= 0} {
	    # No replication required
	    return ""
	} elseif {$num == 1} {
	    # Quick exit for recursion
	    return $char
	} elseif {$num == 2} {
	    # Another quick exit for recursion
	    return $char$char
	} elseif {0 == ($num % 2)} {
	    # Halving the problem results in O (log n) complexity.
	    set result [strRepeat $char [expr {$num / 2}]]
	    return "$result$result"
	} else {
	    # Uneven length, reduce problem by one
	    return "$char[strRepeat $char [incr num -1]]"
	}
    }

    proc ::textutil::blank {n} {
	return [strRepeat " " $n]
    }
}


# @c Removes the last character from the given <a string>.
#
# @a string: The string to manipulate.
#
# @r The <a string> without its last character.
#
# @i chopping

proc ::textutil::chop {string} {
    return [string range $string 0 [expr {[string length $string]-2}]]
}



# @c Removes the first character from the given <a string>.
# @c Convenience procedure.
#
# @a string: string to manipulate.
#
# @r The <a string> without its first character.
#
# @i tail

proc ::textutil::tail {string} {
    return [string range $string 1 end]
}



# @c Capitalizes first character of the given <a string>.
# @c Complementary procedure to <p ::textutil::uncap>.
#
# @a string: string to manipulate.
#
# @r The <a string> with its first character capitalized.
#
# @i capitalize

proc ::textutil::cap {string} {
    return [string toupper [string index $string 0]][string range $string 1 end]
}

# @c unCapitalizes first character of the given <a string>.
# @c Complementary procedure to <p ::textutil::cap>.
#
# @a string: string to manipulate.
#
# @r The <a string> with its first character uncapitalized.
#
# @i uncapitalize

proc ::textutil::uncap {string} {
    return [string tolower [string index $string 0]][string range $string 1 end]
}


source [ file join [ file dirname [ info script ] ] adjust.tcl ]
source [ file join [ file dirname [ info script ] ] split.tcl ]
source [ file join [ file dirname [ info script ] ] tabify.tcl ]
source [ file join [ file dirname [ info script ] ] trim.tcl ]

# Do the [package provide] last, in case there is an error in the code above.
package provide textutil 0.5

