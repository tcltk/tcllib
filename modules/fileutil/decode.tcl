# -*- tcl -*-
# ### ### ### ######### ######### #########
## Copyright (c) 2008-2009 ActiveState Software Inc.
##                         Andreas Kupries
## BSD License
##
# Package to help the writing of file decoders. Provides generic
# low-level support commands.

package require Tcl 8.5
package require debug
package require debug::caller

namespace eval ::fileutil::decode {
    namespace export mark go rewind at
    namespace export byte short-le long-le nbytes skip
    namespace export unsigned match recode getval
    namespace export clear get put putloc setbuf
}

debug level  fileutil/decode 
debug prefix fileutil/decode {[debug caller] | }

# ### ### ### ######### ######### #########
##

proc ::fileutil::decode::open {fname} {
    debug.fileutil/decode {}
    variable chan
    set chan [::open $fname r]
    fconfigure $chan \
	-translation binary \
	-encoding    binary \
	-eofchar     {}

    debug.fileutil/decode {/done = $chan}
    return
}

proc ::fileutil::decode::close {} {
    variable chan
    debug.fileutil/decode { closing $chan }
    ::close $chan
    return
}

# ### ### ### ######### ######### #########
##

proc ::fileutil::decode::mark {} {
    variable chan
    variable mark
    set mark [tell $chan]
    debug.fileutil/decode { @ $mark }
    return
}

proc ::fileutil::decode::go {to} {
    debug.fileutil/decode {}
    variable chan
    seek $chan $to start
    return
}

proc ::fileutil::decode::rewind {} {
    variable chan
    variable mark
    if {$mark == {}} {
	debug.fileutil/decode {}
	return -code error "No mark to rewind to"
    }
    seek $chan $mark start
    debug.fileutil/decode { @ $mark}

    set mark {}
    return
}

proc ::fileutil::decode::at {} {
    debug.fileutil/decode {}
    variable chan
    return [tell $chan]
}

# ### ### ### ######### ######### #########
##

proc ::fileutil::decode::byte {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 1]
    binary scan $val c val
    return
}

proc ::fileutil::decode::short-le {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 2]
    binary scan $val s val
    return
}

proc ::fileutil::decode::short-be {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 2]
    binary scan $val S val
    return
}

proc ::fileutil::decode::long-le {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 4]
    binary scan $val i val
    return
}

proc ::fileutil::decode::long-be {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 4]
    binary scan $val I val
    return
}

proc ::fileutil::decode::longlong-le {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 8]
    binary scan $val ii lo hi
    set val [expr {($hi << 32) | $lo}]
    return
}

proc ::fileutil::decode::longlong-be {} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan 8]
    binary scan $val II hi lo
    set val [expr {($hi << 32) | $lo}]
    return
}

proc ::fileutil::decode::nbytes {n} {
    debug.fileutil/decode {}
    variable chan
    variable val [read $chan $n]
    return
}

proc ::fileutil::decode::skip {n} {
    debug.fileutil/decode {}
    variable chan
    #read $chan $n
    seek $chan $n current
    return
}

# ### ### ### ######### ######### #########
##

proc ::fileutil::decode::unsigned {} {
    debug.fileutil/decode {}
    variable val
    if {$val >= 0} return
    set val [format %u [expr {$val & 0xffffffff}]]
    return
}

proc ::fileutil::decode::match {eval} {
    debug.fileutil/decode {}
    variable val

    #puts "Match: Expected $eval, Got: [format 0x%08x $val]"

    if {$val == $eval} {
	debug.fileutil/decode {OK}
	return 1
    }
    rewind

    debug.fileutil/decode {FAIL $val}
    return 0
}

proc ::fileutil::decode::recode {cmdpfx} {
    debug.fileutil/decode {}
    variable val
    lappend cmdpfx $val
    set val [uplevel 1 $cmdpfx]
    return
}

proc ::fileutil::decode::getval {} {
    debug.fileutil/decode {}
    variable val
    return $val
}

# ### ### ### ######### ######### #########
##

proc ::fileutil::decode::clear {} {
    debug.fileutil/decode {}
    variable buf {}
    return
}

proc ::fileutil::decode::get {} {
    debug.fileutil/decode {}
    variable buf
    return $buf
}

proc ::fileutil::decode::setbuf {list} {
    debug.fileutil/decode {}
    variable buf $list
    return
}

proc ::fileutil::decode::put {name} {
    debug.fileutil/decode {}
    variable buf
    variable val
    lappend buf $name $val
    return
}

proc ::fileutil::decode::putloc {name} {
    debug.fileutil/decode {}
    variable buf
    variable chan
    lappend buf $name [tell $chan]
    return
}

# ### ### ### ######### ######### #########
##

namespace eval ::fileutil::decode {
    # Stream to read from
    variable chan {}

    # Last value read from the stream, or modified through decoder
    # operations.
    variable val  {}

    # Remembered location in the stream
    variable mark {}

    # Buffer for accumulating structured results
    variable buf  {}
}

# ### ### ### ######### ######### #########
## Ready
package provide fileutil::decode 0.3
return
