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
}



source [ file join [ file dirname [ info script ] ] adjust.tcl ]
source [ file join [ file dirname [ info script ] ] split.tcl ]
source [ file join [ file dirname [ info script ] ] tabify.tcl ]
source [ file join [ file dirname [ info script ] ] trim.tcl ]

# Do the [package provide] last, in case there is an error in the code above.
package provide textutil 0.5

