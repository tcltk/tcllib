# uuencode - Copyright (C) 2002 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Provide a Tcl only implementation of uuencode and uudecode.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
# @(#)$Id: uuencode.tcl,v 1.3 2002/01/17 23:09:40 patthoyts Exp $

namespace eval uuencode {
    namespace export encode decode uuencode uudecode
}

proc uuencode::Enc {c} {
    return [format %c [expr {($c != 0) ? (($c & 0x3f) + 0x20) : 0x60}]]
}

proc uuencode::Encode {s} {
    set r {}
    binary scan $s c* d
    foreach {c1 c2 c3} $d {
        if {$c1 == {}} {set c1 0}
        if {$c2 == {}} {set c2 0}
        if {$c3 == {}} {set c3 0}
        append r [Enc [expr {$c1 >> 2}]]
        append r [Enc [expr {(($c1 << 4) & 060) | (($c2 >> 4) & 017)}]]
        append r [Enc [expr {(($c2 << 2) & 074) | (($c3 >> 6) & 003)}]]
        append r [Enc [expr {($c3 & 077)}]]
    }
    return $r
}

proc uuencode::Decode {s} {
    set r {}
    binary scan $s c* d
    if {[expr {[llength $d] % 4}] != 0} {
        return -code error "invalid uuencoded string: length must be a\
              multiple of 4"
    }
        
    foreach {c0 c1 c2 c3} $d {
        append r [format %c [expr {((($c0-0x20)&0x3F) << 2) & 0xFF
                                   | ((($c1-0x20)&0x3F) >> 4) & 0xFF}]]
        append r [format %c [expr {((($c1-0x20)&0x3F) << 4) & 0xFF
                                   | ((($c2-0x20)&0x3F) >> 2) & 0xFF}]]
        append r [format %c [expr {((($c2-0x20)&0x3F) << 6) & 0xFF
                                   | (($c3-0x20)&0x3F) & 0xFF}]]
    }
    return $r
}

# -------------------------------------------------------------------------

# If the Trf package is available then we shall use this by default but the
# Tcllib implementations are always visible if needed (ie: for testing)
if {[catch {package require Trf 2.0}]} {
    interp alias {} uuencode::encode {} uuencode::Encode
    interp alias {} uuencode::decode {} uuencode::Decode
} else {
    proc uuencode::encode {s} {
        return [::uuencode -mode encode $s]
    }
    proc uuencode::decode {s} {
        return [::uuencode -mode decode $s]
    }
}

# -------------------------------------------------------------------------

proc uuencode::uuencode {args} {
    array set opts {mode 0644 filename {} name {}}
    while {[string match -* [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -f* {
                set opts(filename) [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -m* {
                set opts(mode) [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -n* {
                set opts(name) [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -- {
                set args [lreplace $args 0 0]
                break
            }
            default {
                return -code error "bad option [lindex $args 0]:\
                      must be -filename or -mode"
            }
        }
        set args [lreplace $args 0 0]
    }

    if {$opts(name) == {}} {
        set opts(name) $opts(filename)
    }
    if {$opts(name) == {}} {
        set opts(name) "data.dat"
    }

    if {$opts(filename) != {}} {
        set f [open $opts(filename) r]
        fconfigure $f -translation binary
        set data [read $f]
        close $f
    } else {
        if {[llength $args] != 1} {
            return -code error "wrong \# args: should be\
                  \"uuencode ?-mode oct? -file name | data\""
        }
        set data [lindex $args 0]
    }

    set r {}
    append r [format "begin %o %s" $opts(mode) $opts(name)] "\n"
    for {set n 0} {$n < [string length $data]} {incr n 45} {
        set s [string range $data $n [expr {$n + 44}]]
        append r [Enc [string length $s]]
        append r [encode $s] "\n"
    }
    append r "`\nend"
    return $r
}

# -------------------------------------------------------------------------
# Description:
#  Perform uudecoding of a file or data. A file may contain more than one
#  encoded data section so the result is a list where each element is a 
#  three element list of the provided filename, the suggested mode and the 
#  data itself.
#
proc uuencode::uudecode {args} {
    array set opts {mode 0644 filename {}}
    while {[string match -* [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -f* {
                set opts(filename) [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -- {
                set args [lreplace $args 0 0]
                break
            }
            default {
                return -code error "bad option [lindex $args 0]:\
                      must be -filename or -mode"
            }
        }
        set args [lreplace $args 0 0]
    }

    if {$opts(filename) != {}} {
        set f [open $opts(filename) r]
        fconfigure $f -translation binary
        set data [read $f]
        close $f
    } else {
        if {[llength $args] != 1} {
            return -code error "wrong \# args: should be\
                  \"uudecode -file name | data\""
        }
        set data [lindex $args 0]
    }

    set state false
    set result {}

    foreach {line} [split $data "\n"] {
        switch -exact -- $state {
            false {
                if {[regexp {^begin ([0-7]+) ([^\s]*)} $line \
                         -> opts(mode) opts(name)]} {
                    set state true
                    set r {}
                }
            }

            true {
                if {[string match "end" $line]} {
                    set state false
                    lappend result [list $opts(name) $opts(mode) $r]
                } else {
                    set n [expr {([scan $line %c] - 0x21)}]
                    append r [string range \
                                  [decode [string range $line 1 end]] 0 $n]
                }
            }
        }
    }

    return $result
}

# -------------------------------------------------------------------------

package provide uuencode 1.0

# -------------------------------------------------------------------------
#
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:

