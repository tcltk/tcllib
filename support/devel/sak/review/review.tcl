# -*- tcl -*-
# (C) 2013 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

package require sak::color

namespace eval ::sak::review {
    namespace import ::sak::color::*
}

# ###

proc ::sak::review::usage {} {
    package require sak::help
    puts stdout \n[sak::help::on review]
    exit 1
}

proc ::sak::review::run {m p} {
    global package_name package_version distribution
    variable entries
    variable at 0
    variable tags {}
    variable mod $m
    variable pkg $p
    variable stop 0

    package require linenoise

    getpackage fileutil                 fileutil/fileutil.tcl
    getpackage doctools::changelog      doctools/changelog.tcl
    getpackage term::ansi::code::macros term/ansi/code/macros.tcl
    getpackage term::ansi::send         term/ansi/send.tcl

    sak::note::LoadNotes
    set k [list $mod $pkg]
    catch { set tags $sak::note::notes($k) }

    # get changelog. split into entries, trim after last release.
    # ... show current entry, plus tags (LoadNotes), and run command
    # loop to allow paging through the entries and manipulating the
    # set of tags.

    set entries {}
    foreach e [doctools::changelog::scan [fileutil::cat $distribution/modules/$m/ChangeLog]] {
	if {[string match -nocase "*Released and tagged*" $e]} break
	lappend entries $e
    }
    set entries [doctools::changelog::flatten $entries]

    RefreshDisplay

    linenoise::cmdloop \
	-history   0 \
	-exit      ::sak::review::E \
	-continued ::sak::review::C \
	-dispatch  ::sak::review::D \
	-prompt1   ::sak::review::P
   
    # Tags collection done, save result

    if {![llength $tags]} { lappend tags --- }
    sak::note::run $m $p $tags
    return
}

proc ::sak::review::E {} {
    variable stop
    return $stop
}
proc ::sak::review::C {buffer} { return 0 }
proc ::sak::review::D {line} {
    if {$line == ""} { set line n }
    set cmd [lindex $line 0]

    #puts $cmd|[info commands ::sak::review::C$cmd]|
    #puts $cmd|[info commands ::sak::review::C*]|

    if {![llength [info commands ::sak::review::C_$cmd]]} {
	return -code error "Unknown command $cmd, use help or ? to list them"
    }
    eval C_$line
}

proc ::sak::review::P {} {
    variable mod
    variable pkg
    variable at
    variable entries

    set a [expr {1+$at}]
    set n [llength $entries]

    return "$mod/$pkg \[$a/$n\] > "
}

proc ::sak::review::C_exit {} { variable stop 1 }
proc ::sak::review::C_quit {} { variable stop 1 }
proc ::sak::review::C_done {} { variable stop 1 }
proc ::sak::review::C_q    {} { variable stop 1 }

proc ::sak::review::C_? {} { C_help }
proc ::sak::review::C_h {} { C_help }
proc ::sak::review::C_help {} {
    set r {}
    foreach c [info commands ::sak::review::C_*] {
	lappend r [string range [namespace tail $c] 2 end]
    }
    return "Commands: [join $r {, }]"
}

proc ::sak::review::C_next {} { C_n }
proc ::sak::review::C_n {} {
    variable entries
    variable at
    if {$at >= [llength $entries]-1} return
    incr at
    RefreshDisplay
    return
}

proc ::sak::review::C_prev {} { C_p }
proc ::sak::review::C_p {} {
    variable entries
    variable at
    if {$at == 0} return
    incr at -1
    RefreshDisplay
    return
}

# Commands to add/remove tags, clear set, replace set

proc ::sak::review::C_+ef {} { plus EF }
proc ::sak::review::C_+t  {} { plus T }
proc ::sak::review::C_+d  {} { plus D }
proc ::sak::review::C_+b  {} { plus B }
proc ::sak::review::C_+p  {} { plus P }
proc ::sak::review::C_+ex {} { plus EX }
proc ::sak::review::C_+a  {} { plus API }
proc ::sak::review::C_+i  {} { plus I }

proc ::sak::review::C_-ef {} { minus EF }
proc ::sak::review::C_-t  {} { minus T }
proc ::sak::review::C_-d  {} { minus D }
proc ::sak::review::C_-b  {} { minus B }
proc ::sak::review::C_-p  {} { minus P }
proc ::sak::review::C_-ex {} { minus EX }
proc ::sak::review::C_-a  {} { minus API }
proc ::sak::review::C_-i  {} { minus I }

proc ::sak::review::C_=ef {} { replace EF }
proc ::sak::review::C_=t  {} { replace T }
proc ::sak::review::C_=d  {} { replace D }
proc ::sak::review::C_=b  {} { replace B }
proc ::sak::review::C_=p  {} { replace P }
proc ::sak::review::C_=ex {} { replace EX }
proc ::sak::review::C_=a  {} { replace API }
proc ::sak::review::C_=i  {} { replace I }

proc ::sak::review::C_---   {} { variable tags {} ; RefreshDisplay }
proc ::sak::review::C_clear {} { variable tags {} ; RefreshDisplay }
proc ::sak::review::replace {tag} { variable tags $tag ; RefreshDisplay }

proc ::sak::review::plus {tag} {
    variable tags
    if {[lsearch -exact $tag $tags] >= 0} return
    lappend tags $tag
    RefreshDisplay
    return
}

proc ::sak::review::minus {tag} {
    variable tags
    set pos [lsearch -exact $tag $tags]
    if {$pos < 0} return
    set tags [lreplace $tags $pos $pos]
    RefreshDisplay
    return
}

proc ::sak::review::RefreshDisplay {} {
    # Clear screen
    # Show module/package
    # Show current entry of changelog
    # Show current set of tags.

    # XXX should note #entry and #entries, i.e. where in how many
    # XXX entries are we.

    variable mod
    variable pkg
    variable entries
    variable at
    variable tags

    set entry [lindex $entries $at]

    term::ansi::send::clear
    puts "Reviewing [=cya $mod] // [=cya $pkg]"
    puts "\[[expr {1+$at}]/[llength $entries]\]"
    puts [term::ansi::code::macros::frame $entry]
    puts "Tags: [join $tags ,]"
    return
}

##
# ###

namespace eval ::sak::review {}

package provide sak::review 1.0
