# -*- tcl -*-
# (C) 2008 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

package require sak::animate

namespace eval ::sak::feedback {
    namespace import ::sak::animate::next ; rename next aNext
    namespace import ::sak::animate::last ; rename last aLast
}

# ###

proc ::sak::feedback::init {araw alog astem {extlist log}} {
    variable prefix ""
    variable raw    $araw
    variable log    $alog
    variable stem   $astem
    variable logc   ; unset logc ; array set logc {}
    variable dst    ""

    if {$alog} {
	foreach e $extlist { set logc($e) [open ${astem}.$e w] }
    } else {
	foreach e $extlist { set logc($e) stdout }
    }
    return
}

###

proc ::sak::feedback::log {text {ext log}} {
    variable raw
    variable log
    if {!$log && !$raw} return
    variable logc
    puts $logc($ext) $text
    return
}

###

proc ::sak::feedback::! {} {
    variable raw
    if {$raw} return
    variable prefix ""
	sak::animate::init
    return
}

proc ::sak::feedback::+= {string} {
    variable raw
    if {$raw} return
    variable prefix
    append   prefix " " $string
    aNext               $prefix
    return
}

proc ::sak::feedback::= {string} {
    variable raw
    if {$raw} return
    variable prefix
    aNext  "$prefix $string"
    return
}

proc ::sak::feedback::=| {string} {
    variable raw
    if {$raw} return
    variable prefix
    aLast  "$prefix $string"
    variable log
    if {$log} {
	variable dst
	if {[string length $dst]} {
	    log "$prefix $string" $dst
	    set dst ""
	}
    }
    set      prefix ""
    return
}

proc ::sak::feedback::>> {string} {
    variable dst $string
    return
}

# ###

namespace eval ::sak::feedback {
    namespace export >> ! += = =| init log

    variable prefix ""
    variable raw    0
    variable log    0
    variable stem   ""
    variable logc   ; array set logc {}
    variable dst    ""
}

##
# ###

package provide sak::feedback 1.0
