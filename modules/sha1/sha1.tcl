# sha1.tcl - 
#
# Copyright (C) 2001 Don Libes <libes@nist.gov>
# Copyright (C) 2003 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# SHA1 defined by FIPS 180-1, "The SHA1 Message-Digest Algorithm"
# HMAC defined by RFC 2104, "Keyed-Hashing for Message Authentication"
#
# This is an implementation of SHA1 based upon the example code given in
# FIPS 180-1 and upon the tcllib MD4 implementation and taking some ideas
# and methods from the earlier tcllib sha1 version by Don Libes.
#
# This implementation permits incremental updating of the hash and 
# provides support for external compiled implementations either using
# critcl (sha1c) or Trf.
#
# ref: http://www.itl.nist.gov/fipspubs/fip180-1.htm
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
#
# $Id: sha1.tcl,v 1.12 2005/02/20 22:05:35 patthoyts Exp $

package require Tcl 8.2;                # tcl minimum version

namespace eval ::sha1 {
    variable version 2.0.0
    variable rcsid {$Id: sha1.tcl,v 1.12 2005/02/20 22:05:35 patthoyts Exp $}
    variable usetrf 0
    variable usesha1c 0

    namespace export sha1 hmac SHA1Init SHA1Update SHA1Final

    if {![catch {package require Trf}]} {
        # We have this check because Trf's sha1 often doesn't work on Win32.
        set usetrf [expr {![catch {::sha1 aa} msg]}]
    }

    variable uid
    if {![info exists uid]} {
        set uid 0
    }
}

# -------------------------------------------------------------------------

# SHA1Init --
#
#   Create and initialize an SHA1 state variable. This will be
#   cleaned up when we call SHA1Final
#
proc ::sha1::SHA1Init {} {
    variable usetrf
    variable uid
    set token [namespace current]::[incr uid]
    upvar #0 $token tok

    # FIPS 180-1: 7 - Initialize the hash state
    array set tok \
        [list \
             A [expr int(0x67452301)] \
             B [expr int(0xEFCDAB89)] \
             C [expr int(0x98BADCFE)] \
             D [expr int(0x10325476)] \
             E [expr int(0xC3D2E1F0)] \
             n 0 i "" ]
    if {$usetrf} {
        set s {}
        switch -exact -- $::tcl_platform(platform) {
            windows { set s [open NUL w] }
            unix    { set s [open /dev/null w] }
        }
        if {$s != {}} {
            fconfigure $s -translation binary -buffering none
            ::sha1 -attach $s -mode write \
                -read-type variable \
                -read-destination [subst $token](trfread) \
                -write-type variable \
                -write-destination [subst $token](trfwrite)
            array set tok [list trfread 0 trfwrite 0 trf $s]
        }
    }
    return $token
}

# SHA1Update --
#
#   This is called to add more data into the hash. You may call this
#   as many times as you require. Note that passing in "ABC" is equivalent
#   to passing these letters in as separate calls -- hence this proc 
#   permits hashing of chunked data
#
#   If we have a C-based implementation available, then we will use
#   it here in preference to the pure-Tcl implementation.
#
proc ::sha1::SHA1Update {token data} {
    variable usesha1c
    variable $token
    upvar #0 $token state

    if {$usesha1c} {
        if {[info exists state(sha1c)]} {
            set state(sha1c) [sha1c $data $state(sha1c)]
        } else {
            set state(sha1c) [sha1c $data]
        }
        return
    } elseif {[info exists state(trf)]} {
        puts -nonewline $state(trf) $data
        return
    }

    # Update the state values
    incr state(n) [string length $data]
    append state(i) $data

    # Calculate the hash for any complete blocks
    set len [string length $state(i)]
    for {set n 0} {($n + 64) <= $len} {} {
        SHA1Transform $token [string range $state(i) $n [incr n 64]]
    }

    # Adjust the state for the blocks completed.
    set state(i) [string range $state(i) $n end]
    return
}

# SHA1Final --
#
#    This procedure is used to close the current hash and returns the
#    hash data. Once this procedure has been called the hash context
#    is freed and cannot be used again.
#
#    Note that the output is 160 bits represented as binary data.
#
proc ::sha1::SHA1Final {token} {
    variable $token
    upvar 0 $token state

    # Check for either of the C-compiled versions.
    if {[info exists state(sha1c)]} {
        set r $state(sha1c)
        unset state
        return $r
    } elseif {[info exists state(trf)]} {
        close $state(trf)
        set r $state(trfwrite)
        unset state
        return $r
    }

    # Padding
    #
    set len [string length $state(i)]
    set pad [expr {56 - ($len % 64)}]
    if {$len % 64 > 56} {
        incr pad 64
    }
    if {$pad == 0} {
        incr pad 64
    }
    append state(i) [binary format a$pad \x80]

    # Append length in bits as big-endian wide int.
    set dlen [expr {8 * $state(n)}]
    append state(i) [binary format II 0 $dlen]

    # Calculate the hash for the remaining block.
    set len [string length $state(i)]
    for {set n 0} {($n + 64) <= $len} {} {
        SHA1Transform $token [string range $state(i) $n [incr n 64]]
    }

    # Output
    set r [binary format I5 [list $state(A) $state(B) $state(C) $state(D) $state(E)]]
    unset state
    return $r
}

# -------------------------------------------------------------------------
# HMAC Hashed Message Authentication (RFC 2104)
#
# hmac = H(K xor opad, H(K xor ipad, text))
#

# HMACInit --
#
#    This is equivalent to the SHA1Init procedure except that a key is
#    added into the algorithm
#
proc ::sha1::HMACInit {K} {

    # Key K is adjusted to be 64 bytes long. If K is larger, then use
    # the SHA1 digest of K and pad this instead.
    set len [string length $K]
    if {$len > 64} {
        set tok [SHA1Init]
        SHA1Update $tok $K
        set K [SHA1Final $tok]
        set len [string length $K]
    }
    set pad [expr {64 - $len}]
    append K [string repeat \0 $pad]

    # Cacluate the padding buffers.
    set Ki {}
    set Ko {}
    binary scan $K i16 Ks
    foreach k $Ks {
        append Ki [binary format i [expr {$k ^ 0x36363636}]]
        append Ko [binary format i [expr {$k ^ 0x5c5c5c5c}]]
    }

    set tok [SHA1Init]
    SHA1Update $tok $Ki;                 # initialize with the inner pad
    
    # preserve the Ko value for the final stage.
    set [subst $tok](Ko) $Ko

    return $tok
}

# HMACUpdate --
#
#    Identical to calling SHA1Update
#
proc ::sha1::HMACUpdate {token data} {
    SHA1Update $token $data
    return
}

# HMACFinal --
#
#    This is equivalent to the SHA1Final procedure. The hash context is
#    closed and the binary representation of the hash result is returned.
#
proc ::sha1::HMACFinal {token} {
    variable $token
    upvar 0 $token state

    set tok [SHA1Init];                 # init the outer hashing function
    SHA1Update $tok $state(Ko);         # prepare with the outer pad.
    SHA1Update $tok [SHA1Final $token]; # hash the inner result
    return [SHA1Final $tok]
}

# -------------------------------------------------------------------------
# Description:
#  This is the core SHA1 algorithm. It is a lot like the MD4 algorithm but
#  includes an extra round and a set of constant modifiers throughout.
#
proc ::sha1::SHA1Transform {token msg} {
    variable $token
    upvar 0 $token state

    # FIPS 180-1: 7a: Process Message in 16-Word Blocks
    binary scan $msg I* blocks
    foreach {W0 W1 W2 W3 W4 W5 W6 W7 W8 W9 W10 W11 W12 W13 W14 W15} $blocks {
        
        # FIPS 180-1: 7b: Expand the input into 80 words
        # For t = 16 to 79 
        #   let Wt = (Wt-3 ^ Wt-8 ^ Wt-14 ^ Wt-16) <<< 1
        set t3  12
        set t8   7
        set t14  1
        set t16 -1
        for {set t 16} {$t < 80} {incr t} {
            set x [expr {[set W[incr t3]] ^ [set W[incr t8]] ^ \
                             [set W[incr t14]] ^ [set W[incr t16]]}]
            set W$t [expr {($x << 1) | (($x >> 31) & 1)}]
        }
        
        # FIPS 180-1: 7c: Copy hash state.
        set A $state(A)
        set B $state(B)
        set C $state(C)
        set D $state(D)
        set E $state(E)

        # FIPS 180-1: 7d: Do permutation rounds
        # For t = 0 to 79 do
        #   TEMP = (A<<<5) + ft(B,C,D) + E + Wt + Kt;
        #   E = D; D = C; C = S30(B); B = A; A = TEMP;

        # Round 1: ft(B,C,D) = (B & C) | (~B & D) ( 0 <= t <= 19)
        for {set t 0} {$t < 20} {incr t} {
            set TEMP [expr {(($A << 5) | (($A >> 27) & 0x1f)) + \
                                (($B & $C) | ((~$B) & $D)) \
                                + $E + [set W$t] + 0x5a827999}]
            set E $D
            set D $C
            set C [expr {($B << 30) | (($B >> 2) & 0x3fffffff)}]
            set B $A
            set A $TEMP
        }

        # Round 2: ft(B,C,D) = (B ^ C ^ D) ( 20 <= t <= 39)
        for {} {$t < 40} {incr t} {
            set TEMP [expr {(($A << 5) | (($A >> 27) & 0x1f)) + \
                                ($B ^ $C ^ $D) \
                                + $E + [set W$t] + 0x6ed9eba1}]
            set E $D
            set D $C
            set C [expr {($B << 30) | (($B >> 2) & 0x3fffffff)}]
            set B $A
            set A $TEMP
        }
        # Round 3: ft(B,C,D) = ((B & C) | (B & D) | (C & D)) ( 40 <= t <= 59)
        for {} {$t < 60} {incr t} {
            set TEMP [expr {((($A << 5) | (($A >> 27) & 0x1f)) + \
                                (($B & $C) | ($B & $D) | ($C & $D)) \
                                + $E + [set W$t] + 0x8f1bbcdc) & 0xffffffff}]
            set E $D
            set D $C
            set C [expr {($B << 30) | (($B >> 2) & 0x3fffffff)}]
            set B $A
            set A $TEMP
         }

        # Round 4: ft(B,C,D) = (B ^ C ^ D) ( 60 <= t <= 79)
        for {} {$t < 80} {incr t} {
            set TEMP [expr {((($A << 5) | (($A >> 27) & 0x1f)) + \
                                ($B ^ $C ^ $D) \
                                + $E + [set W$t] + 0xca62c1d6) & 0xffffffff}]
            set E $D
            set D $C
            set C [expr {($B << 30) | (($B >> 2) & 0x3fffffff)}]
            set B $A
            set A $TEMP
        }

        # Then perform the following additions. (That is, increment each
        # of the four registers by the value it had before this block
        # was started.)
        incr state(A) $A
        incr state(B) $B
        incr state(C) $C
        incr state(D) $D
        incr state(E) $E
    }

    return
}

proc ::sha1::byte {n v} {expr {((0xFF << (8 * $n)) & $v) >> (8 * $n)}}
proc ::sha1::bytes {v} { 
    #format %c%c%c%c [byte 0 $v] [byte 1 $v] [byte 2 $v] [byte 3 $v]
    format %c%c%c%c \
        [expr {0xFF & $v}] \
        [expr {(0xFF00 & $v) >> 8}] \
        [expr {(0xFF0000 & $v) >> 16}] \
        [expr {((0xFF000000 & $v) >> 24) & 0xFF}]
}

# -------------------------------------------------------------------------

proc ::sha1::Hex {data} {
    binary scan $data H* result
    return $result
}

# -------------------------------------------------------------------------

# Description:
#  Pop the nth element off a list. Used in options processing.
#
proc ::sha1::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# -------------------------------------------------------------------------

# fileevent handler for chunked file hashing.
#
proc ::sha1::Chunk {token channel {chunksize 4096}} {
    variable $token
    upvar 0 $token state
    
    if {[eof $channel]} {
        fileevent $channel readable {}
        set state(reading) 0
    }
        
    SHA1Update $token [read $channel $chunksize]
}

# -------------------------------------------------------------------------

proc ::sha1::sha1 {args} {
    array set opts {-hex 0 -filename {} -channel {} -chunksize 4096}
    if {[llength $args] == 1} {
        set opts(-hex) 1
    } else {
        while {[string match -* [set option [lindex $args 0]]]} {
            switch -glob -- $option {
                -hex       { set opts(-hex) 1 }
                -bin       { set opts(-hex) 0 }
                -file*     { set opts(-filename) [Pop args 1] }
                -channel   { set opts(-channel) [Pop args 1] }
                -chunksize { set opts(-chunksize) [Pop args 1] }
                default {
                    if {[llength $args] == 1} { break }
                    if {[string compare $option "--"] == 0} { Pop args; break }
                    set err [join [lsort [concat -bin [array names opts]]] ", "]
                    return -code error "bad option $option:\
                    must be one of $err"
                }
            }
            Pop args
        }
    }

    if {$opts(-filename) != {}} {
        set opts(-channel) [open $opts(-filename) r]
        fconfigure $opts(-channel) -translation binary
    }

    if {$opts(-channel) == {}} {

        if {[llength $args] != 1} {
            return -code error "wrong # args:\
                should be \"sha1 ?-hex? -filename file | string\""
        }
        set tok [SHA1Init]
        SHA1Update $tok [lindex $args 0]
        set r [SHA1Final $tok]

    } else {

        set tok [SHA1Init]
        set [subst $tok](reading) 1
        fileevent $opts(-channel) readable \
            [list [namespace origin Chunk] \
                 $tok $opts(-channel) $opts(-chunksize)]
        vwait [subst $tok](reading)
        set r [SHA1Final $tok]

        # If we opened the channel - we should close it too.
        if {$opts(-filename) != {}} {
            close $opts(-channel)
        }
    }
    
    if {$opts(-hex)} {
        set r [Hex $r]
    }
    return $r
}

# -------------------------------------------------------------------------

proc ::sha1::hmac {args} {
    array set opts {-hex 1 -filename {} -channel {} -chunksize 4096}
    if {[llength $args] != 2} {
        while {[string match -* [set option [lindex $args 0]]]} {
            switch -glob -- $option {
                -key       { set opts(-key) [Pop args 1] }
                -hex       { set opts(-hex) 1 }
                -bin       { set opts(-hex) 0 }
                -file*     { set opts(-filename) [Pop args 1] }
                -channel   { set opts(-channel) [Pop args 1] }
                -chunksize { set opts(-chunksize) [Pop args 1] }
                default {
                    if {[llength $args] == 1} { break }
                    if {[string compare $option "--"] == 0} { Pop args; break }
                    set err [join [lsort [array names opts]] ", "]
                    return -code error "bad option $option:\
                    must be one of $err"
                }
            }
            Pop args
        }
    }

    if {[llength $args] == 2} {
        set opts(-key) [Pop args]
    }

    if {![info exists opts(-key)]} {
        return -code error "wrong # args:\
            should be \"hmac ?-hex? -key key -filename file | string\""
    }

    if {$opts(-filename) != {}} {
        set opts(-channel) [open $opts(-filename) r]
        fconfigure $opts(-channel) -translation binary
    }

    if {$opts(-channel) == {}} {

        if {[llength $args] != 1} {
            return -code error "wrong # args:\
                should be \"hmac ?-hex? -key key -filename file | string\""
        }
        set tok [HMACInit $opts(-key)]
        HMACUpdate $tok [lindex $args 0]
        set r [HMACFinal $tok]

    } else {

        set tok [HMACInit $opts(-key)]
        set [subst $tok](reading) 1
        fileevent $opts(-channel) readable \
            [list [namespace origin Chunk] \
                 $tok $opts(-channel) $opts(-chunksize)]
        vwait [subst $tok](reading)
        set r [HMACFinal $tok]

        # If we opened the channel - we should close it too.
        if {$opts(-filename) != {}} {
            close $opts(-channel)
        }
    }
    
    if {$opts(-hex)} {
        set r [Hex $r]
    }
    return $r
}

# -------------------------------------------------------------------------

package provide sha1 $::sha1::version

# -------------------------------------------------------------------------
# Local Variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:


