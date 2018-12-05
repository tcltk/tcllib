#! /usr/bin/env tclsh

# # ## ### ##### ######## #############
# (C) 2018 Poor Yorick
# # ## ### ##### ######## #############

package require Tcl 8.6

package require coroutine

package require tcl::chan::events

oo::class create ::tcl::chan::wrapper {
    superclass ::tcl::chan::events ; # -> initialize, finalize, watch


    constructor args {
	namespace path [list ::coroutine::util {*}[namespace path]]
	dict size $args
	foreach {key val} $args {
	    switch $key {
		chan {
		    set chan $chan
		}
	    }
	}
	next {*}$args
    }

    method blocking {c m} {
	chan blocking $c $m
    }


    method cget {c o} {
	chan configure $chan $o
    }


    method cgetall c {
	chan configure $chan
    }


    method configure {c o v} {
	chan configure $chan $o $v
    }


    method finalize {} {
	close $chan
	next
    }

    method read {c n} {
	read $c $n
    }

    method seek {c o b} {
	seek $c $o $b
    }

    method write {c d} {
	puts -nonwline $chan $d
    }

    variable chan
}

package provide tcl::chan::wrapper 1
