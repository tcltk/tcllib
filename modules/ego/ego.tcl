# # ## ### ##### ######## #############
# copyright
#
#     2018
#
#     Poor Yorick
# # ## ### ##### ######## #############

namespace eval ::tcllib::ego {
namespace ensemble create
namespace export *

proc .method {_ name args} {
	if {![llength $args]} {
		lappend args $name
	}
	set args [linsert $args[set args {}] 1 $_]
	set map [namespace ensemble configure $_ -map]
	dict set map $name $args
	uplevel 1 [list ::namespace ensemble configure $_ -map $map]
	return
}
.method [namespace current] .method


proc $ {_ name args} {
	namespace upvar [$_ .namespace] $name var
	if {[llength $args]} {
		if {[llength $args] > 1} {
			error [list {wrong # args}]
		}
		set var [lindex $args 0]
	}
	return $var
}
.method [namespace current] $


proc .as {_ other name args} {
	set map [namespace ensemble configure $_ -map]
	set cmd [dict get $map $name]
	if {[lindex $name 1] ne $_} {
		error [list {not a method} $name]
	}
	set cmd [lreplace $cmd 1 1 $other]
	::tailcall {*}$cmd
}
.method [namespace current] .as


proc .eval {_ args} {
	::tailcall ::namespace eval [$_ .namespace] {*}$args
}
.method [namespace current] .eval


proc .insert {_ name} {
	set unknown1 [namespace ensemble configure $_ -unknown]
	set prototype1 [namespace ensemble configure $_ -prototype]

	if {[llength $unknown1]} {
		namespace ensemble configure $name -prototype $prototype1 \
			-unknown $unknown1
	}

	namespace enemble configure $_ -prototype [list ::lindex $name] -unknown $unknown1
	return
}


proc .name _ {
	return $_
}
.method [namespace current] .name


proc .namespace _ {
	namespace ensemble configure $_ -namespace
}
.method [namespace current] .namespace


proc .new {_ name args} {
	global env
	set ns [uplevel 1 [list ::namespace eval $name {
		::namespace ensemble create
		::variable configured 0
		::namespace current
	}]]
	::trace add command $ns delete [list ::apply {{ns oldname newname op} {
		if {[namespace exists $ns]} {
			namespace delete $ns
		}
	}} $ns]

	set prototype $_
	set map [namespace ensemble configure $_ -map]

	set prototypes {}
	while {[dict exists $map .prototype]} {
		set prototypes [list $map {*}$prototypes[set prototypes {}]]
		lassign [dict get $map .prototype] prototype
		set map [namespace ensemble configure $prototype -map]
	}

	set map {}
	foreach {key val} [namespace ensemble configure $prototype -map] {
		if {$key ne {.prototype}} {
			if {[lindex $val 1] eq $_} {
				set val [lreplace $val[set val {}] 1 1 $ns]
			}
		} else {
			error [list {how did we get to here?}]
		}
		lappend map $key $val
	}

	namespace ensemble configure $ns -map $map

	set prototype $ns
	foreach map $prototypes {
		$ns .specialize
		dict unset map .prototype
		dict for {name cmd} $map {
			if {[lindex $cmd 1] eq $_} {
				# remove the original name from index 1 because .method is
				# going to add it back
				$ns .method $name {*}[lreplace $cmd[set cmd {}] 1 1]
			} else {
				$ns .routine $name {*}$cmd
			}
		}
	}

	interp alias {} ${ns}::.my {} $ns

	if {[llength $args]} {
		tailcall $ns .init {*}$args
	} else {
		return $ns
	}
}
.method [namespace current] .new


proc .ondelete {_ trace args} {
    if {[llength $args] == 1} {
	lassign $args script
	trace remove command $_ delete $trace
	set trace {}
	if {$script ne {}} {
	    set trace [list apply {{script args} {
		try $script
	    }} $script]
	    trace add command $_ delete $trace
	}
	$_ .method .ondelete .ondelete $trace
    } elseif {[llength $args]} {
	error [list {wrong # args}]
    }
    return $trace
}
.method [namespace current] .ondelete .ondelete {}


proc .routine {_ name args} {
	if {![llength $args]} {
		lappend args $name
	}
	set map [namespace ensemble configure $_ -map]
	dict set map $name $args
	uplevel 1 [list ::namespace ensemble configure $_ -map $map]
	return
}
.method [namespace current] .routine


proc .specialize {_ args} {
	set ns [$_ .namespace]
	while {[namespace which [set name ${ns}::[
		info cmdcount]_prototype]] ne {}} {}
	rename $_ $name

	set new [namespace eval ${ns} [
		list namespace ensemble create -command $_ -map [list \
			.prototype [list $name]
		] -unknown [
			list ::apply {{_ name args} {

			set prototype [lindex [dict get [namespace ensemble configure $_ -map] .prototype] 0]
			list $prototype $name
		}}]]]

	::trace add command $new delete [list ::apply {{ns oldname newname op} {
		if {[namespace exists $ns]} {
			namespace delete $ns
		}
	}} $ns]
	return
}
.method [namespace current] .specialize


proc .vars {_ args} {
	set vars {}
	foreach arg $args {
		lassign $arg source target
		if {[llength $arg] == 1} {
			set target $source
		}
		lappend vars $source $target
	}
	uplevel 1 [list ::namespace upvar $_ {*}$vars]
}
.method [namespace current] .vars


proc = {_ name val} {
	set [$_ .namespace]::$name $val
}
.method [namespace current] =
}
package provide ego 0.1



