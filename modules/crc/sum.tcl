# sum.tcl - Copyright (C) 2002 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Provides a Tcl only implementation of the unix sum(1) command. There are
# a number of these and they use differing algorithms to get a checksum of
# the input data. We provide two: one using the BSD algorithm and the other
# using the SysV algorithm. More consistent results across multiple
# implementations can be obtained by using cksum(1).
#
# These commands have been checked against the GNU sum program from the GNU
# textutils package version 2.0 to ensure the same results.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
# $Id: sum.tcl,v 1.2 2003/01/26 00:16:03 patthoyts Exp $

package require Tcl 8.2;                # tcl minimum version

namespace eval ::crc {
    variable sum_version 1.0.1
    namespace export sum
}

# Description:
#  The SysV algorithm is fairly naive. The byte values are summed and any
#  overflow is discarded. The lowest 16 bits are returned as the checksum.
# Notes:
#  Input with the same content but different ordering will give the same 
#  result.
#  This is pretty dependant on using a 32 bit accumulator.
#
proc ::crc::sum-sysv {s} {
    set t 0
    binary scan $s c* r
    foreach n $r {
        incr t [expr {$n & 0xFF}]
    }
    return [expr {$t % 0xFFFF}]
}

# Description:
#  This algorithm is similar to the SysV version but includes a bit rotation
#  step which provides a dependency on the order of the data values.
# Notes:
#  Once again this depends upon a 32 bit accumulator.
#
proc ::crc::sum-bsd {s} {
    set t 0
    binary scan $s c* r
    foreach n $r {
        set t [expr {($t & 1) ? (($t >> 1) + 0x8000) : ($t >> 1)}]
        set t [expr {($t + ($n & 0xFF)) & 0xFFFF}]
    }
    return $t
}

# Description:
#  Provide a Tcl equivalent of the unix sum(1) command. We default to the
#  BSD algorithm and return a checkum for the input string unless a filename
#  has been provided. Using sum on a file should give the same results as
#  the unix sum command with equivalent algorithm.
# Options:
#  -bsd           - use the BSD algorithm to calculate the checksum (default)
#  -sysv          - use the SysV algorithm to calculate the checksum
#  -filename name - return a checksum for the specified file
#  -format string - return the checksum using this format string
#
proc ::crc::sum {args} {
    set algorithm [namespace current]::sum-bsd
    set filename {}
    set format %u
    while {[string match -* [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -b* {
                set algorithm [namespace current]::sum-bsd
            }
            -s* {
                set algorithm [namespace current]::sum-sysv
            }
            -fi* {
                set filename [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -fo* {
                set format [lindex $args 1]
                set args [lreplace $args 0 0]
            }
            -- {
                set args [lreplace $args 0 0]
                break
            }
            default {
                return -code error "bad option [lindex $args 0]:\
                     must be -bsd, -sysv, -filename or -format"
            }
        }
        set args [lreplace $args 0 0]
    }

    if {$filename != {}} {
        set f [open $filename r]
        fconfigure $f -translation binary
        set data [read $f]
        close $f
        set r [$algorithm $data]
    } else {
        if {[llength $args] != 1} {
            return -code error "wrong # args: should be \
                 \"sum ?-bsd|-sysv? ?-format string? -file name | data\""
        }
        set r [$algorithm [lindex $args 0]]
    }
    return [format $format $r]
}

# -------------------------------------------------------------------------

package provide sum $::crc::sum_version

# -------------------------------------------------------------------------    
# Local Variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:
