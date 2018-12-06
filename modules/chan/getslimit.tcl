# # ## ### ##### ######## #############
# copyright
#
#     2018
#
#     Poor Yorick
# # ## ### ##### ######## #############
package require ego
namespace eval ::tcllib::chan::getslimit {
variable buf bufcount eof getslimit

proc [namespace current] chan {
	if {![string match ::* $chan]} {
		set chan [uplevel 1 [list ::namespace which $chan]]
	}
	$chan .specialize
	foreach name {
		.init configure eof gets read
	} {
		$chan .method $name getslimit::$name
	}
	return $chan
}


proc .init {_ args} {
    $_ .vars eof buf bufcount getslimit
    set eof 0
    set buf {}
    set bufcount 0
    set getslimit -1
    uplevel 1 [list $_ .prototype .init {*}$args]
}


proc configure {_ args} {
    $_ .vars getslimit
    if {[llength $args] == 1} {
	switch [lindex $args 0] {
	    -getslimit {
		set res $getslimit
	    } default {
		set res [uplevel 1 [list $_ .prototype configure {*}$args]]
	    }
	}
    } elseif {[llength $args]} {
	dict size $args
	foreach {key val} $args[set args {}] {
	    if {$key eq {-getslimit}} {
		set getslimit $val
	    } else {
		lappend args $key $val
	    }
	}
	if {[llength $args]} {
	    uplevel 1 [list $_ .prototype configure {*}$args]
	}
	set res {}
    } else {
	set res [list {*}[uplevel 1 [
	    list $_ .prototype configure {*}$args]] -getslimit $getslimit]
    }
    return $res
}


proc  eof _ {
    $_ .vars bufcount eof
    return [expr {$eof || ( [$_ .prototype eof] && $bufcount == 0 )}]
}


proc gets {_ args} {
    $_ .vars buf bufcount chan eof getslimit
    switch [llength $args] {
	1 {
	    lassign $args varname
	    upvar 1 $varname resvar
	}
	0 {}
	default {
	    #this is just to generate the error message
	    ::gets [$_ $ chan] {*}$args
	}
    }

    if {$eof} {
	if {[info exists varname]} {
	    set resvar {}
	    return -1
	}
	return {}
    }

    if {[string first \n $buf] < 0 && ![::eof $chan]} {
	if {$getslimit >= 0} {
	    append buf [$_ read $getslimit]
	} else {
	    append buf [$_ read]
	}
    }

    if {[regexp {^(.*?)\n(.*)$} $buf -> res remainder]} {
	set buf $remainder
	set bufcount [expr {$bufcount - [string length $res] - 1}]
    } else {
	# must be at eof
	set res $buf
	set buf {}
	set bufcount 0
	if {[::eof $chan]} {
	    set eof 1
	}
    }

    if {[llength $args]} {
	set args [lassign $args[set args {}] varname]
	set resvar $res

	if {$res eq {} && $eof} {
	    return -1
	} else {
	    return [string length $res]
	}
    } else {
	return $res
    }
}


proc read {_ args} {
    $_ .vars buf eof bufcount
    if {$eof} {
	return {}
    }
    if {$bufcount} {
	if {[llength $args]} {
	    lassign $args size
	    if {$size <= $bufcount} {
		set res [string range $buf 0 [expr {$size - 1}]]
		set buf [string range $buf $size end]
		incr bufcount -[string length $res]
	    } else {
		set readsize [expr {$size - $bufcount}]
		set res $buf[set buf {}][$_ .prototype read $readsize]
		set bufcount 0
	    }
	} else {
	    set bufcount 0
	    set res $buf[set buf {}][$_ .prototype read {*}$args]
	}
    } else {
	set res [$_ .prototype read {*}$args]
    }
    return $res
}
}

package provide tcllib::chan::getslimit 1
package provide {chan getslimit} 0.1
namespace eval ::tcllib::chan {
	namespace export getslimit
}
