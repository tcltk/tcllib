# uuid.tcl - Copyright (C) 2004 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# UUIDs are 128 bit values that attempt to be unique in time and space.
#
# Reference:
#   http://www.opengroup.org/dce/info/draft-leach-uuids-guids-01.txt
#
# uuid: scheme:
# http://www.globecom.net/ietf/draft/draft-kindel-uuid-uri-00.html
#
# Usage: uuid::uuid generate
#        uuid::uuid equal $idA $idB

namespace eval uuid {
    variable version 1.0.0

    namespace export uuid

    variable uid
    if {![info exists uid]} {
        set uid 1
    }

    if {[package vcompare [package provide Tcl] 8.4] < 0} {
        package require struct::list
        interp alias {} ::uuid::lset {} ::struct::list::lset
    }

    proc K {a b} {set a}
}

# Generates a binary UUID as per the draft spec. We generate a pseudo-random
# type uuid (type 4). See section 3.4
#
proc ::uuid::generate {} {
    package require md5 2
    variable uid

    set tok [md5::MD5Init]
    md5::MD5Update $tok [clock seconds]; # timestamp
    md5::MD5Update $tok [clock clicks];  # system incrementing counter
    md5::MD5Update $tok [incr uid];      # package incrementing counter 
    md5::MD5Update $tok [info hostname]; # spatial unique id (poor)
    md5::MD5Update $tok [pid];           # additional entropy
    md5::MD5Update $tok [array get ::tcl_platform]
    
    # More spatial information -- better than hostname.
    catch {
        set s [socket -server void -myaddr [info hostname] 0]
        K [fconfigure $s -sockname] [close $s]
    } r
    md5::MD5Update $tok $r

    if {[package provide Tk] != {}} {
        md5::MD5Update $tok [winfo pointerxy .]
        md5::MD5Update $tok [winfo id .]
    }

    set r [md5::MD5Final $tok]
    binary scan $r c* r
    
    # 3.4: set uuid versioning fields
    lset r 8 [expr {([lindex $r 8] & 0x7F) | 0x40}]
    lset r 6 [expr {([lindex $r 6] & 0x0F) | 0x40}]
    
    return [binary format c* $r]
}

# Convert a binary uuid into its string representation.
#
proc ::uuid::tostring {uuid} {
    set s [md5::Hex $uuid]
    foreach {a b} {0 7 8 11 12 15 16 19 20 end} {
        append r [string range $s $a $b] -
    }
    return [string tolower [string trimright $r -]]
}

# Convert a string representation of a uuid into its binary format.
#
proc ::uuid::fromstring {uuid} {
    return [binary format H* [string map {- {}} $uuid]]
}

# Compare two uuids for equality.
#
proc ::uuid::equal {left right} {
    set l [fromstring $left]
    set r [fromstring $right]
    return [string equal $l $r]
}

# uuid generate -> string rep of a new uuid
# uuid equal uuid1 uuid2
#
proc uuid::uuid {cmd args} {
    switch -exact -- $cmd {
        generate {
            if {[llength $args] != 0} {
                return -code error "wrong # args:\
                    should be \"uuid generate\""
            }
            return [tostring [generate]]
        }
        equal {
            if {[llength $args] != 2} {
                return -code error "wrong \# args:\
                    should be \"uuid equal uuid1 uuid2\""
            }
            return [eval [linsert $args 0 equal]]
        }
        default {
            return -code error "bad option \"$cmd\":\
                must be generate or equal"
        }
    }
}

# -------------------------------------------------------------------------

package provide uuid $::uuid::version

# -------------------------------------------------------------------------
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End: