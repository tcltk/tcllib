#! /usr/bin/tclsh

# # ## ### ##### ######## #############
# copyright
#
#     2018
#
#     Poor Yorick
# # ## ### ##### ######## #############

package require coroutine


proc new chan {
	set chan [uplevel 1 [list ::namespace which $chan[set chan {}]]]
	oo::objdefine $chan [list mixin [namespace which coroutine]]
	return $chan
}

oo::class create coroutine 
oo::objdefine coroutine {
	method gets args {
		my variable chan
		tailcall ::coroutine::util::gets $chan {*}$args
	}


	method read args {
		my variable chan
		tailcall ::coroutine::util::read $chan {*}$args
	}
}

