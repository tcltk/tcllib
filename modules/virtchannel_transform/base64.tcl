# -*- tcl -*-
# # ## ### ##### ######## #############
# (C) 2009 Andreas Kupries

# @@ Meta Begin
# Package tcl::transform::base64 1
# Meta as::author {Andreas Kupries}
# Meta as::copyright 2009
# Meta as::license BSD
# Meta as::notes   Possibilities for extension: Currently
# Meta as::notes   the mapping between read/write and
# Meta as::notes   decode/encode is fixed. Allow it to be
# Meta as::notes   configured at construction time.
# Meta description Implementation of a base64
# Meta description transformation (RFC 4648). Based on Tcl
# Meta description 8.6's transformation reflection support
# Meta description (TIP 230) and binary en/decode (TIP 317).
# Meta description Exports a single command adding a new
# Meta description transformation of this type to a channel.
# Meta description One argument, the channel to extend. No
# Meta description result.
# Meta platform tcl
# Meta require tcl::transform::core
# Meta require {Tcl 8.6}
# @@ Meta End

# # ## ### ##### ######## #############

package require Tcl 8.6
package require tcl::transform::core

# # ## ### ##### ######## #############

namespace eval ::tcl::transform {}

proc ::tcl::transform::base64 {chan} {
    ::chan push $chan [base64::implementation new]
    return
}

oo::class create ::tcl::transform::base64::implementation {
    superclass tcl::transform::core ;# -> initialize, finalize, destructor

    method write {c data} {
	set res [my Code encodebuf encode $data 3]
	incr enccount [string length $data]
	return $res
    }

    method read {c data} {
	set length [string length $data]
	# remove whitespace to make framing calculations in [Code] accurate
	# to do:  Add a -strict configuration to disallow whitespace?
	regsub -all {[[:space:]]} $data[set data {}] {} data
	set res [my Code decodebuf decode $data 4]
	incr deccount $length 
	return $res
    }

    method flush {c} {
	set data [binary encode base64 $encodebuf]
	set encodebuf {}
	return $data
    }

    method drain {c} {
	set length [string length $decodebuf]
	set data [binary decode base64 $decodebuf]
	if {$data eq {} && $length} {
	    error [list {invalid input after } $deccount]
	}
	set decodebuf {}
	return $data
    }

    method clear {c} {
	set decodebuf {}
	return
    }

    # # ## ### ##### ######## #############

    constructor {} {
	set encodebuf {}
	set deccount 0
	set enccount 0
	set decodebuf {}
	return
    }

    # # ## ### ##### ######## #############

    variable enccount encodebuf deccount decodebuf

    # # ## ### ##### ######## #############

    method Code {bufvar op data n} {
	upvar 1 $bufvar buffer

	append buffer $data

	set n [my Complete $buffer $n]
	if {$n < 0} {
	    return {}
	}

	set chunk [string range $buffer 0 $n]
	set result [binary $op base64 $chunk]

	if {$result eq {} && $chunk ne {}} {
	    error [list {invalid input after} [
		expr {$op eq {encode} ? $enccount : $deccount}]]
	}
	incr n
	set buffer [string range $buffer $n end]
	
	return $result
    }

    method Complete {buffer n} {
	set len [string length $buffer]
	return [expr {(($len / $n) * $n)-1}]
    }
}

# # ## ### ##### ######## #############
package provide tcl::transform::base64 1
return
