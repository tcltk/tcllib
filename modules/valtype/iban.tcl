# # ## ### ##### ######## ############# ######################
## Validation of IBAN numbers.
#
# # ## ### ##### ######## ############# ######################

# The code below implements the interface of a snit validation type,
# making it directly usable with snit's -type option in option
# specifications.

# # ## ### ##### ######## ############# ######################
## Requisites

package require Tcl 8.5
package require snit
package require valtype::common

# # ## ### ##### ######## ############# ######################
## Implementation

namespace eval ::valtype::iban {
    namespace import ::valtype::common::*
}

snit::type ::valtype::iban {
    #-------------------------------------------------------------------
    # Type Methods

    typemethod validate {value} {

	if {![regexp {^[A-Z]{2}[0-9]{26}$} $value]} {
	    badchar IBAN "IBAN number, expected only country code with 26 digits"
	}

	scan $value "%2s%2s%24s" country_symbol ctrl number

	set country_code [string map {
	    A 10 B 11 C 12 D 13 E 14 F 15 G 16 H 17 I 18 J 19 K 20 L 21 M 22
	    N 23 O 24 P 25 Q 26 R 27 S 28 T 29 U 30 V 31 W 32 X 33 Y 34 Z 35
	} $country_symbol]

	set pe [split ${number}${country_code}${ctrl} {}]
	set wa [list 57 93 19 31 71 75 56 25 51 73 17 89 38 62 45 53 15 50 5 49 34 81 76 27 90 9 30 3 10 1]

	set sum 0
	foreach d $pe w $wa {incr sum [expr {$d * $w}]}

	if {($sum % 97) != 1} {
	    badcheck IBAN "IBAN number"
	}

	return $value

    }

    #-------------------------------------------------------------------
    # Constructor

    # None needed; no options

    #-------------------------------------------------------------------
    # Public Methods

    method validate {value} {
        $type validate $value
    }
}

# # ## ### ##### ######## ############# ######################
## Ready

package provide valtype::iban 1
