#! /usr/bin/env tclsh

# # ## ### ##### ######## #############
# (C) 2018 Poor Yorick

# # ## ### ##### ######## #############

package require {mime qp}
package require tcl::transform::core

namespace eval ::tcl::transform {}

proc ::tcl::transform::qp chan {
    ::chan push $chan [qp::implementation new]
    return

}

oo::class create ::tcl::transform::qp::implementation {
    superclass tcl::transform::core ;# -> initialize, finalize, destructor

    method write {c data} {
	::mime::qp::encode $data
    }

    method read {c data} {
	::mime::qp::decode $data
    }
}

package provide {tcl transform qp} 0.1
