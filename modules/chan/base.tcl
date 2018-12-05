#! /usr/bin/env tclsh

# # ## ### ##### ######## #############
# copyright
#
#     2018
#
#     Poor Yorick
# # ## ### ##### ######## #############


proc .init {_ channame args} {
    $_ .vars chan close
    if {$channame ni [::chan names]} {
	error [list {unknown channel} $channame]
    }
    set chan $channame
    $_ .ondelete [list ::apply {{_ channame} {
	$_ .vars close
	if {$close} {
	    ::close $channame
	}
    }} $_ $channame]
    set close 1
    if {[llength $args]} {
	$_ configure {*}$args
    }
    return $_
}
.my .method .init


proc configure {_ args} {
    $_ .vars chan
    if {[llength $args] == 1} {
	lassign $args key
	switch $key {
	    -chan {
		return $chan
	    }
	}
	set res [::chan configure $chan {*}$args]
    } elseif {[llength $args]} {
	dict size $args
	foreach {key val} $args[set args {}] {
	    switch $key {
		-chan {
		    set chan $val
		}
		-close {
		    $_ $ close [expr {!!$val}]
		}
		default {
		    lappend args $key $val
		}
	    }
	}
	if {[llength $args]} {
	    ::chan configure $chan {*}$args
	}
	set res {}
    } else {
	set res [list {*}[::chan configure $chan {*}$args] -chan $chan]
    }
    return $res
}
.my .method configure


proc copy {_ target} {
    ::chan copy [$_ $ chan] $target
}
.my .method copy


proc gets {_ args} {
    uplevel 1 [list ::gets [$_ $ chan] {*}$args]
}
.my .method gets


proc pending {_ args} {
    uplevel 1 [list ::pending {*}$args [$_ $ chan]]
}
.my .method pending


proc puts {_ args} {
    uplevel 1 [list ::puts {*}[lrange $args 0 end-1] [$_ $ chan] {*}[
	lrange $args end end]]
}
.my .method puts


proc read {_ args} {
    uplevel 1 [list ::read {*}[lrange $args 0 end-1] [$_ $ chan] {*}[
	lrange $args end end]]
}
.my .method read


apply [list {} {
    foreach name {
	blocked close eof event flush names pop posteven push seek tell
	truncate
    } {
	proc $name {_ args} [string map [
	    list @name@ [list $name]] {
	    ::chan @name@ [$_ $ chan] {*}$args
	}]
	.my .method $name
    }
} [namespace current]]


