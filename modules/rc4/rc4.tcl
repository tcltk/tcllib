# rc4.tcl - Copyright (C) 2004 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# RC4 is a symmetric stream cipher developed by Ron Rivest of RSA Data
# Security Inc. The algorithm was a trade secret of RSA but was reverse
# engineered and published to the internet in 1994. This pure Tcl
# implementation is based on the description of the algorithm.
#
# The algorithm is a pseudo-random number generator with the output of
# the PRNG being xored with the plaintext stream. Decryption is done
# by feeding the ciphertext as input with the same key.
#
# $Id: rc4.tcl,v 1.1 2004/07/02 00:01:03 patthoyts Exp $

package require Tcl 8.2

namespace eval ::rc4 {
    variable version 1.0.0
    variable rcsid {$Id: rc4.tcl,v 1.1 2004/07/02 00:01:03 patthoyts Exp $}

    namespace export rc4

    variable uid
    if {![info exists uid]} {
        set uid 0
    }
}

# RC4Init - create and initialize the RC4 state.
#
proc ::rc4::RC4Init {keystr} {
    variable uid

    binary scan $keystr c* key
    set keylen [llength $key]

    set Key [namespace current]::key[incr uid]
    # FRINK: nocheck
    variable $Key
    upvar #0 $Key state
    catch {unset state}

    set state(x) 0
    set state(y) 0
    for {set cn 0} {$cn < 256} {incr cn} {
        set state(s,$cn) $cn
    }
    set i 0
    set j 0
    for {set cn 0} {$cn < 256} {incr cn} {
        set j [expr {([lindex $key $i] + $state(s,$cn) + $j) % 256}]
        set t $state(s,$cn)
        set state(s,$cn) $state(s,$j)
        set state(s,$j) $t
        set i [expr {($i + 1) % $keylen}]
    }

    return $Key
}

proc ::rc4::RC4 {Key datastr} {
    # FRINK: nocheck
    variable $Key
    upvar #0 $Key state
    set res {}

    binary scan $datastr c* data
    set datalen [llength $data]
    
    set x $state(x)
    set y $state(y)

    for {set cn 0} {$cn < $datalen} {incr cn} {
        set x [expr {($x + 1) % 256}]
        set y [expr {($state(s,$x) + $y) % 256}]
        set t $state(s,$y)
        set state(s,$y) $state(s,$x)
        set state(s,$x) $t
        set i [expr {($state(s,$x) + $state(s,$y)) % 256}]
        lappend res [expr {([lindex $data $cn] ^ $state(s,$i)) & 0xFF}]
    }
    set state(x) $x
    set state(y) $y
    return [binary format c* $res]
}

proc ::rc4::RC4Final {Key} {
    # FRINK: nocheck
    variable $Key
    upvar #0 $Key state
    catch {unset state}
    return {}
}

# -------------------------------------------------------------------------
# Helper to turn binary data into hex format.
#
if {[package provide Trf] != {}} {
    interp alias {} ::rc4::Hex {} ::hex -mode encode --
} else {
    proc ::rc4::Hex {data} {
        set result {}
        binary scan $data c* r
        foreach c $r {
            append result [format "%02X" [expr {$c & 0xff}]]
        }
        return $result
    }
}

# Demo function for use with Trf transform command to add automatic
# RC4 encryption to a channel. Illustrates use of [transform]
#
# For instance, to create a file with all ondisk data encrypted:
#   set f [open secretfile r+]
#   transform -attach $f -command [list rc4::Transform $f Secret]
#   puts -nonewline $f yourdata   ;# write to encrypt
#   read $f                       ;# read to decrypt
#   close $f
#
proc ::rc4::Transform {channel keystr operation data} {
    set readkey [namespace current]::R$channel
    # FRINK: nocheck
    variable $readkey
    upvar #0 $readkey rk
    set writekey [namespace current]::W$channel
    # FRINK: nocheck
    variable $writekey
    upvar #0 $writekey wk
    set result {}

    #puts stderr "$operation {$data}"
    switch -- $operation {
        create/write {
            if {[info exists wk]} {
                RCFinal $wk
            }
            set wk [RC4Init $keystr] 
        }
        clear/write {}
        delete/write {
            if {[info exists wk]} {
                RC4Final $wk
                unset wk
            }
        }
        write - flush/write {
            if {![info exists wk]} {
                set wk [RC4Init $keystr]
            }
            set result [RC4 $wk $data] 
        }

        create/read {
            if {[info exists rk]} {
                RCFinal $rk
            }
            set rk [RC4Init $keystr] 
        }
        clear/read {}
        delete/read {
            if {[info exists rk]} {
                RC4Final $rk
                unset rk
            }
        }
        read - flush/read {
            if {![info exists rk]} {
                set rk [RC4Init $keystr]
            }
            set result [RC4 $rk $data] 
        }
        
        query/ratio {
            set result {1 1};           # RC4 is a 1:1 stream cipher.
        }
        query/maxRead {
            set result -1;              # Permit read of any amount
        }
        default {
            # ignore unknown operations.
        }
    }
    return $result
}

# -------------------------------------------------------------------------
# Description:
#  Pop the nth element off a list. Used in options processing.
#
proc ::rc4::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# -------------------------------------------------------------------------
# Fileevent handler for chunked file hashing.
#
proc ::rc4::Chunk {Key in {out {}} {chunksize 4096}} {
    # FRINK: nocheck
    variable $Key
    upvar #0 $Key state
    
    if {[eof $in]} {
        fileevent $in readable {}
        set state(reading) 0
    }
    if {$out == {}} {
        append state(output) [RC4 $Key [read $in $chunksize]]
    } else {
        puts -nonewline $out [RC4 $Key [read $in $chunksize]]
    }
}

# -------------------------------------------------------------------------

proc ::rc4::rc4 {args} {
    array set opts {-hex 0 -infile {} -in {} -out {} -chunksize 4096 -key {}}
    while {[string match -* [set option [lindex $args 0]]]} {
        switch -exact -- $option {
            -key        { set opts(-key) [Pop args 1] }
            -hex        { set opts(-hex) 1}
            -infile     { set opts(-infile) [Pop args 1] }
            -in         { set opts(-in) [Pop args 1] }
            -out        { set opts(-out) [Pop args 1] }
            -chunksize  { set opts(-chunksize) [Pop args 1] }
            --          { Pop args; break }
            default {
                set err [join [lsort [array names opts]] ", "]
                return -code error "bad option $option:\
                    must be one of $err"
            }
        }
        Pop args
    }

    if {$opts(-key) == {}} {
        return -code error "wrong # args:\
            should be \"rc4 ?-hex? -key key -in channel | string\""
    }

    if {$opts(-infile) != {}} {
        set opts(-in) [open $opts(-infile) r]
        fconfigure $opts(-in) -translation binary
    }

    set r {}
    if {$opts(-in) == {}} {
        if {[llength $args] != 1} {
            return -code error "wrong # args:\
            should be \"rc4 ?-hex? -key key -in channel | string\""
        }

        set Key [RC4Init $opts(-key)]
        set r [RC4 $Key [lindex $args 0]]
        if {$opts(-out) != {}} {
            puts -nonewline $opts(-out) $r
            set r {}
        }
        RC4Final $Key

    } else {

        set Key [RC4Init $opts(-key)]
        # FRINK: nocheck
        variable $Key
        upvar #0 $Key state
        set state(reading) 1
        set state(output) ""
        fileevent $opts(-in) readable \
            [list [namespace origin Chunk] \
                 $Key $opts(-in) $opts(-out) $opts(-chunksize)]
        vwait [subst $Key](reading)
        if {$opts(-out) == {}} {
            set r $state(output)
        }
        RC4Final $Key

        # If we opened the channel then we should close it too.
        if {$opts(-infile) != {}} {
            close $opts(-in)
        }
    }

    if {$opts(-hex)} {
        set r [Hex $r]
    }
    return $r
}

# -------------------------------------------------------------------------

package provide rc4 $::rc4::version

# -------------------------------------------------------------------------
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End: