# -*- tcl -*-
# (C) 2008 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

namespace eval ::sak::validate {}

# ###

proc ::sak::validate::usage {args} {
    package require sak::help
    puts stdout [join $args { }]\n[sak::help::on validate]
    exit 1
}

proc ::sak::validate::all {modules raw log stem} {
    package require sak::validate::manpages
    #package require sak::validate::versions
    #package require sak::validate::testsuites
    #package require sak::validate::syntax

    sak::validate::manpages   $modules $raw $log $stem
    #sak::validate::versions   $modules $raw $log $stem
    #sak::validate::testsuites $modules $raw $log $stem
    #sak::validate::syntax     $modules $raw $log $stem
    return
}

##
# ###

package provide sak::validate 1.0
