# # ## ### ##### ######## ############# #####################
## Copyright (c) 2013 Andreas Kupries, BSD licensed

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require fileutil ;# cat

# # ## ### ##### ######## ############# #####################
## API setup
#
## NOTE: We are here placing the 'token' ensemble command into the
##       Tcl core's builtin 'string' ensemble.

namespace eval ::string::token {
    namespace export text file
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## API

proc ::string::token::file {map path args} {
    return [text $map [fileutil::cat {*}$args $path]]
}

proc ::string::token::text {map text} {
    # map = dict (regex -> label)
    #   note! order is important, most specific to most general.

    # result = list (token)
    # where
    #   token = list(label start-index end-index)

    set start  0
    set result 0
    while {[Chomp $map start $text result]} continue
    return $result
}

# # ## ### ##### ######## ############# #####################
## Internal, helpers.

proc ::string::token::Chomp {map sv text rv} {
    upvar 1 $sv start $rv result

    foreach {pattern label} $map {
	if {![regexp -start $start -indices -- \\A($pattern) $text -> range]} continue

	lappend result [list $label {*}$range]
	lassign $range a e
	set start $e
	incr start
	return 1
    }
    return 0
}

# # ## ### ##### ######## ############# #####################
## Ready

package provide string::token 1
return
