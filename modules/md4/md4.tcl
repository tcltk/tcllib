# md4.tcl - Copyright (C) 2003 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# This is a Tcl-only implementation of the MD4 hash algorithm as described in 
# RFC 1320 ( http://www.ietf.org/rfc/rfc1320.txt )
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
#
# $Id: md4.tcl,v 1.1 2003/04/15 21:25:15 patthoyts Exp $

package require Tcl 8.2;                # tcl minimum version

namespace eval ::md4 {
    variable version 1.0.0
    variable rcsid {$Id: md4.tcl,v 1.1 2003/04/15 21:25:15 patthoyts Exp $}

    namespace export md4
}

set ::md4::MD4_body {
    
    # RFC1320:3.1 - Padding
    #
    set len [string length $msg]
    set pad [expr {56 - ($len % 64)}]
    if {$len % 64 > 56} {
        incr pad 64
    }
    if {$pad == 0} {
        incr pad 64
    }
    append msg [binary format a$pad \x80]

    # RFC1320:3.2 - Append length in bits as little-endian wide int.
    append msg [binary format ii [expr {8 * $len}] 0]

    # RFC1320:3.3 - Initialize MD buffer
    set A [expr 0x67452301]
    set B [expr 0xefcdab89]
    set C [expr 0x98badcfe]
    set D [expr 0x10325476]

    # RFC1320:3.4 - Process Message in 16-Word Blocks
    binary scan $msg i* blocks
    foreach {X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15} $blocks {
        set AA $A
        set BB $B
        set CC $C
        set DD $D

        # Round 1
        # Let [abcd k s] denote the operation
        #   a = (a + F(b,c,d) + X[k]) <<< s.
        # Do the following 16 operations.
        # [ABCD  0  3]  [DABC  1  7]  [CDAB  2 11]  [BCDA  3 19]
        set A [expr {($A + [F $B $C $D] + $X0) <<< 3}]
        set D [expr {($D + [F $A $B $C] + $X1) <<< 7}]
        set C [expr {($C + [F $D $A $B] + $X2) <<< 11}]
        set B [expr {($B + [F $C $D $A] + $X3) <<< 19}]
        # [ABCD  4  3]  [DABC  5  7]  [CDAB  6 11]  [BCDA  7 19]
        set A [expr {($A + [F $B $C $D] + $X4) <<< 3}]
        set D [expr {($D + [F $A $B $C] + $X5) <<< 7}]
        set C [expr {($C + [F $D $A $B] + $X6) <<< 11}]
        set B [expr {($B + [F $C $D $A] + $X7) <<< 19}]
        # [ABCD  8  3]  [DABC  9  7]  [CDAB 10 11]  [BCDA 11 19]
        set A [expr {($A + [F $B $C $D] + $X8) <<< 3}]
        set D [expr {($D + [F $A $B $C] + $X9) <<< 7}]
        set C [expr {($C + [F $D $A $B] + $X10) <<< 11}]
        set B [expr {($B + [F $C $D $A] + $X11) <<< 19}]
        # [ABCD 12  3]  [DABC 13  7]  [CDAB 14 11]  [BCDA 15 19]
        set A [expr {($A + [F $B $C $D] + $X12) <<< 3}]
        set D [expr {($D + [F $A $B $C] + $X13) <<< 7}]
        set C [expr {($C + [F $D $A $B] + $X14) <<< 11}]
        set B [expr {($B + [F $C $D $A] + $X15) <<< 19}]

        # Round 2.
        # Let [abcd k s] denote the operation
        #   a = (a + G(b,c,d) + X[k] + 5A827999) <<< s
        # Do the following 16 operations.
        # [ABCD  0  3]  [DABC  4  5]  [CDAB  8  9]  [BCDA 12 13]
        set A [expr {($A + [G $B $C $D] + $X0  + 0x5a827999) <<< 3}]
        set D [expr {($D + [G $A $B $C] + $X4  + 0x5a827999) <<< 5}]
        set C [expr {($C + [G $D $A $B] + $X8  + 0x5a827999) <<< 9}]
        set B [expr {($B + [G $C $D $A] + $X12 + 0x5a827999) <<< 13}]
        # [ABCD  1  3]  [DABC  5  5]  [CDAB  9  9]  [BCDA 13 13]
        set A [expr {($A + [G $B $C $D] + $X1  + 0x5a827999) <<< 3}]
        set D [expr {($D + [G $A $B $C] + $X5  + 0x5a827999) <<< 5}]
        set C [expr {($C + [G $D $A $B] + $X9  + 0x5a827999) <<< 9}]
        set B [expr {($B + [G $C $D $A] + $X13 + 0x5a827999) <<< 13}]
        # [ABCD  2  3]  [DABC  6  5]  [CDAB 10  9]  [BCDA 14 13]
        set A [expr {($A + [G $B $C $D] + $X2  + 0x5a827999) <<< 3}]
        set D [expr {($D + [G $A $B $C] + $X6  + 0x5a827999) <<< 5}]
        set C [expr {($C + [G $D $A $B] + $X10 + 0x5a827999) <<< 9}]
        set B [expr {($B + [G $C $D $A] + $X14 + 0x5a827999) <<< 13}]
        # [ABCD  3  3]  [DABC  7  5]  [CDAB 11  9]  [BCDA 15 13]
        set A [expr {($A + [G $B $C $D] + $X3  + 0x5a827999) <<< 3}]
        set D [expr {($D + [G $A $B $C] + $X7  + 0x5a827999) <<< 5}]
        set C [expr {($C + [G $D $A $B] + $X11 + 0x5a827999) <<< 9}]
        set B [expr {($B + [G $C $D $A] + $X15 + 0x5a827999) <<< 13}]
        
        # Round 3.
        # Let [abcd k s] denote the operation
        #   a = (a + H(b,c,d) + X[k] + 6ED9EBA1) <<< s.
        # Do the following 16 operations.
        # [ABCD  0  3]  [DABC  8  9]  [CDAB  4 11]  [BCDA 12 15]
        set A [expr {($A + [H $B $C $D] + $X0  + 0x6ed9eba1) <<< 3}]
        set D [expr {($D + [H $A $B $C] + $X8  + 0x6ed9eba1) <<< 9}]
        set C [expr {($C + [H $D $A $B] + $X4  + 0x6ed9eba1) <<< 11}]
        set B [expr {($B + [H $C $D $A] + $X12 + 0x6ed9eba1) <<< 15}]
        # [ABCD  2  3]  [DABC 10  9]  [CDAB  6 11]  [BCDA 14 15]
        set A [expr {($A + [H $B $C $D] + $X2  + 0x6ed9eba1) <<< 3}]
        set D [expr {($D + [H $A $B $C] + $X10 + 0x6ed9eba1) <<< 9}]
        set C [expr {($C + [H $D $A $B] + $X6  + 0x6ed9eba1) <<< 11}]
        set B [expr {($B + [H $C $D $A] + $X14 + 0x6ed9eba1) <<< 15}]
        # [ABCD  1  3]  [DABC  9  9]  [CDAB  5 11]  [BCDA 13 15]
        set A [expr {($A + [H $B $C $D] + $X1  + 0x6ed9eba1) <<< 3}]
        set D [expr {($D + [H $A $B $C] + $X9  + 0x6ed9eba1) <<< 9}]
        set C [expr {($C + [H $D $A $B] + $X5  + 0x6ed9eba1) <<< 11}]
        set B [expr {($B + [H $C $D $A] + $X13 + 0x6ed9eba1) <<< 15}]
        # [ABCD  3  3]  [DABC 11  9]  [CDAB  7 11]  [BCDA 15 15]
        set A [expr {($A + [H $B $C $D] + $X3  + 0x6ed9eba1) <<< 3}]
        set D [expr {($D + [H $A $B $C] + $X11 + 0x6ed9eba1) <<< 9}]
        set C [expr {($C + [H $D $A $B] + $X7  + 0x6ed9eba1) <<< 11}]
        set B [expr {($B + [H $C $D $A] + $X15 + 0x6ed9eba1) <<< 15}]

        # Then perform the following additions. (That is, increment each
        # of the four registers by the value it had before this block
        # was started.)
        set A [expr {($A + $AA) & 0xFFFFFFFF}]
        set B [expr {($B + $BB) & 0xFFFFFFFF}]
        set C [expr {($C + $CC) & 0xFFFFFFFF}]
        set D [expr {($D + $DD) & 0xFFFFFFFF}]
    }

    # RFC1320:3.5 - Output
    set ::md4::result [list $A $B $C $D]
    return [binary format i4 [list $A $B $C $D]]
}

# Convert our <<< pseuodo-operator into a procedure call.
regsub -all -line \
    {\[expr {(.*) <<< (\d+)}\]} \
    $::md4::MD4_body \
    {[<<< [expr {\1}] \2]} \
    ::md4::MD4_body

proc ::md4::MD4 {msg} $::md4::MD4_body

# 32bit rotate-left
proc ::md4::<<< {v n} {
    set v [expr {(($v << $n) | (($v >> (32 - $n)) & (0x7FFFFFFF >> (31 - $n))))}]
    return [expr {$v & 0xFFFFFFFF}]
}

# RFC1320:3.4 - function F
proc ::md4::F {X Y Z} {
    return [expr {($X & $Y) | ((~$X) & $Z)}]
}

# RFC1320:3.4 - function H
proc ::md4::G {X Y Z} {
    return [expr {($X & $Y) | ($X & $Z) | ($Y & $Z)}]
}

# RFC1320:3.4 - function H
proc ::md4::H {X Y Z} {
    return [expr {$X ^ $Y ^ $Z}]
}

# -------------------------------------------------------------------------

if {[package provide Trf] != {}} {
    interp alias {} ::md4::Hex {} ::hex -mode encode
} else {
    proc ::md4::Hex {data} {
        set result {}
        binary scan $data c* r
        foreach c $r {
            append result [format "%02X" [expr {$c & 0xff}]]
        }
        return $result
    }
}

# -------------------------------------------------------------------------

# Description:
#  Pop the nth element off a list. Used in options processing.
#
proc ::md4::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# -------------------------------------------------------------------------

# TODO: implement a init, update, final version so that we can do large files
#  or streams using block chunking.
#

proc ::md4::md4 {args} {
    array set opts {-hex 0}
    while {[string match -* [set option [lindex $args 0]]]} {
        switch -exact -- $option {
            -hex    { set opts(-hex) 1 }
            --      { Pop args ; break }
            default {
            }
        }
        Pop args
    }

    if {[llength $args] != 1} {
        return -code error "wrong # args: should be \"md4 ?-hex? string\""
    }

    set r [MD4 [lindex $args 0]]
    
    if {$opts(-hex)} {
        set r [Hex $r]
    }
    return $r
}

# Can we do an hmac version??
#proc ::md4::hmac {key text} {
#}

# -------------------------------------------------------------------------

package provide md4 $::md4::version

# -------------------------------------------------------------------------
# Local Variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:


