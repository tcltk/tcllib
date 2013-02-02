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

    #package require linenoise

    getpackage fileutil                 fileutil/fileutil.tcl
    getpackage doctools::changelog      doctools/changelog.tcl
    getpackage term::ansi::code::macros term/ansi/code/macros.tcl
    getpackage term::ansi::send         term/ansi/send.tcl

    # get changelog. split into entries, trim after last release.
    # ... show current entry, plus tags (LoadNotes), and run command
    # loop to allow paging through the entries and manipulating the
    # set of tags.

    # doctools::changelog::scan

    set entries {}
    foreach e [doctools::changelog::scan [fileutil::cat $distribution/modules/$m/ChangeLog]] {
	if {[string match -nocase "*Released and tagged*" $e]} break
	lappend entries $e
    }

    RefreshDisplay
return
    if 0 {linenoise::cmdloop -history 0 \
	-continued ::sake::review::C
	-dispatch  ::sake::review::Do
    }
    # Tags collection done, save result
    sak::note::run $m $p $tags
    return
}

proc ::sak::review::C {} { return 0 }
proc ::sak::review::D {line} {
    # TODO: proper check for commands
    namespace eval sak::review C$line
}

proc ::sak::review::Cn {} {
    variable entries
    variable at
    if {[llength $entries] == $at} return
    incr at
    RefreshDisplay
    return
}

proc ::sak::review::Cp {} {
    variable entries
    variable at
    if {$at == 0} return
    incr at -1
    RefreshDisplay
    return
}

# Commands to add/remove tags, clear set, replace set

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
    foreach {d u sections} $entry break

    set entry $d\n\t$u\n
    foreach s $sections {
	foreach {files text} $s break
	append entry \t$files:\n$text\n
    }

    term::ansi::send::clear
    puts "Reviewing [=cya $mod] // [=cya $pkg]"
    puts [term::ansi::code::macros::frame $entry]
    puts "Tags: [join $tags ,]"
    return
}

##
# ###

namespace eval ::sak::review {}

package provide sak::review 1.0
