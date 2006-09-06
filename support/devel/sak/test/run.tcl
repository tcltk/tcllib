# -*- tcl -*-
# (C) 2006 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

package require  sak::test::shell
namespace eval ::sak::test::run {}

# ###

proc ::sak::test::run {argv} {
    variable run::valgrind
    array set config {valgrind 0 shells {}}

    while {[string match -* [set opt [lindex $argv 0]]]} {
	switch -exact -- $opt {
	    -s - --shell {
		set sh [lindex $argv 1]
		if {![fileutil::test $sh efrx msg "Shell"]} {
		    sak::test::usage $msg
		}
		lappend config(shells) $sh
		set argv [lrange $argv 2 end]
	    }
	    -g - --valgrind {
		if {![llength $valgrind]} {
		    sak::test::usage valgrind not found in the PATH
		}
		set config(valgrind) 1
		set argv [lrange $argv 1 end]
	    }
	    default {
		sak::test::usage Unknown option "\"$opt\""
	    }
	}
    }

    if {![sak::util::checkModules argv]} return

    run::Do config $argv
    return
}

# ###

proc ::sak::test::run::Do {cv modules} {
    upvar 1 $cv config
    variable valgrind

    set shells $config(shells)
    if {![llength $shells]} {
	set shells [sak::test::shell::list]
    }
    if {![llength $shells]} {
	set shells [list [info nameofexecutable]]
    }

    foreach sh $shells {
	puts "@@ Shell is \"$sh\""

	set cmd exec
	if 0 {
	    # Bad valgrind, ok no valgrind
	    if {$config(valgrind)} {
		foreach e $valgrind {lappend cmd $e}
		lappend cmd --num-callers=8
		lappend cmd --leak-resolution=high
		lappend cmd -v --leak-check=yes
		lappend cmd --show-reachable=yes
	    }
	    lappend cmd $sh
	    lappend cmd [Driver] -modules $modules
	} else {
	    # Ok valgrind and no valgrind.
	    if {$config(valgrind)} {
		set     script {}
		lappend script [list set argv [list -modules $modules]]
		lappend script {set argc 2}
		lappend script [list source [Driver]]
		lappend script exit
		lappend cmd echo [join $script \n]
		lappend cmd |
		foreach e $valgrind {lappend cmd $e}
		#lappend cmd --num-callers=8
		#lappend cmd --leak-resolution=high
		#lappend cmd -v --leak-check=yes
		#lappend cmd --show-reachable=yes
		lappend cmd $sh
	    } else {
		lappend cmd $sh
		lappend cmd [Driver] -modules $modules
	    }
	}
	lappend cmd >@ stdout 2>@ stderr
	eval $cmd
    }
    return
}

# ###

proc ::sak::test::run::Driver {} {
    variable base
    return [file join $base all.tcl]
}

# ###

namespace eval ::sak::test::run {
    variable base     [file join $::distribution support devel]
    variable valgrind [auto_execok valgrind]
}

##
# ###

package provide sak::test::run 1.0
