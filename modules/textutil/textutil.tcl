namespace eval textutil {
    
    variable HaveStrRepeat [ expr {![ catch { string repeat a 1 } ]} ]

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

source [ file join [ file dirname [ info script ] ] adjust.tcl ]
source [ file join [ file dirname [ info script ] ] split.tcl ]
source [ file join [ file dirname [ info script ] ] tabify.tcl ]
source [ file join [ file dirname [ info script ] ] trim.tcl ]

# Do the [package provide] last, in case there is an error in the code above.
package provide textutil 0.1

