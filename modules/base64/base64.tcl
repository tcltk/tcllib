# base64.tcl --
#
# Encode/Decode base64 for a string
# Stephen Uhler / Brent Welch (c) 1997 Sun Microsystems
# The decoder was done for exmh by Chris Garrigues
#
# Copyright (c) 1998-2000 by Scriptics Corporation.
# All rights reserved.
# 
# RCS: @(#) $Id: base64.tcl,v 1.3 2000/03/05 03:41:56 ericm Exp $

package provide base64 2.0

# Version 1.0 implemented Base64_Encode, Bae64_Decode

namespace eval base64 {
    variable i 0
    variable char
    variable base64
    variable base64_en
    foreach char {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
	      a b c d e f g h i j k l m n o p q r s t u v w x y z \
	      0 1 2 3 4 5 6 7 8 9 + /} {
	set base64($char) $i
	set base64_en($i) $char
	incr i
    }

    namespace export *
}

proc base64::encode {string} {
    variable base64_en
    set result {}
    set state 0
    set length 0
    foreach {c} [split $string {}] {
	# RFC 2045 says that the output must have no more than 76 chars per
	# line; we wrap at 60 so that our output is identical to that 
	# produced by the GNU uuencode 4.2.  We do the length check before
	# appending so that we don't get an extra newline if the output is
	# a multiple of 60 chars long.
	if {$length >= 60} {
	    append result \n
	    set length 0
	}
	scan $c %c x
	switch [incr state] {
	    1 {	append result $base64_en([expr {($x >>2) & 0x3F}]) }
	    2 { append result \
		$base64_en([expr {(($old << 4) & 0x30) | (($x >> 4) & 0xF)}]) }
	    3 { append result \
		$base64_en([expr {(($old << 2) & 0x3C) | (($x >> 6) & 0x3)}])
		append result $base64_en([expr {($x & 0x3F)}])
		incr length
		set state 0}
	}
	set old $x
	incr length
    }
    set x 0
    switch $state {
	0 { # OK }
	1 { append result $base64_en([expr {(($old << 4) & 0x30)}])== }
	2 { append result $base64_en([expr {(($old << 2) & 0x3C)}])=  }
    }
    return $result
}
proc base64::decode {string} {
    variable base64

    set output {}
    set group 0
    set j 18
    foreach char [split $string {}] {
	if {[string compare $char "="]} {
	    # RFC 2045 says that line breaks and other characters not part
	    # of the Base64 alphabet must be ignored, and that the decoder
	    # can optionally emit a warning or reject the message.  We opt
	    # not to do so, but to just ignore the character.
	    if { ![info exists base64($char)] } {
		continue
	    }
	    set bits $base64($char)
	    set group [expr {$group | ($bits << $j)}]
	    if {[incr j -6] < 0} {
		scan [format %06x $group] %2x%2x%2x a b c
		append output [format %c%c%c $a $b $c]
		set group 0
		set j 18
	    }
	} else {
	    # = indicates end of data.  Output whatever chars are left.
	    # The encoding algorithm dictates that we can only have 1 or 2
	    # padding characters.  If j is 6, we have 12 bits of good input 
	    # (enough for 1 8-bit output).  If j is 6, we have 18 bits of good
	    # input (enough for 2 8-bit outputs).
	    scan [format %04x $group] %2x%2x a b
	    if {$j == 6} {
		append output [format %c $a]
	    } elseif {$j == 0} {
		append output [format %c%c $a $b]
	    }
	    break
	}
    }
    return $output
}


