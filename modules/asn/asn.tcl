#-----------------------------------------------------------------------------
#   Copyright (C) 1999-2004 Jochen C. Loewer (loewerj@web.de)
#-----------------------------------------------------------------------------
#   
#   A partial ASN decoder/encoder implementation in plain Tcl. 
#
#   See ASN.1 (X.680) and BER (X.690).
#   See 'asn_ber_intro.txt' in this directory.
#
#   This software is copyrighted by Jochen C. Loewer (loewerj@web.de). The 
#   following terms apply to all files associated with the software unless 
#   explicitly disclaimed in individual files.
#
#   The authors hereby grant permission to use, copy, modify, distribute,
#   and license this software and its documentation for any purpose, provided
#   that existing copyright notices are retained in all copies and that this
#   notice is included verbatim in any distributions. No written agreement,
#   license, or royalty fee is required for any of the authorized uses.
#   Modifications to this software may be copyrighted by their authors
#   and need not follow the licensing terms described here, provided that
#   the new terms are clearly indicated on the first page of each file where
#   they apply.
#  
#   IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#   FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#   ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
#   DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.
#
#   THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#   INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#   IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#   NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#   MODIFICATIONS.
#
#   written by Jochen Loewer
#   3 June, 1999
#
#-----------------------------------------------------------------------------

package require log

namespace eval asn {
    # Encoder commands
    namespace export \
	    asnSequence \
	    asnSet \
	    asnApplicationConstr \
	    asnApplication \
	    asnChoice \
	    asnChoiceConstr \
	    asnInteger \
	    asnEnumeration \
	    asnBoolean \
	    asnOctetString

    # Decoder commands. They read from a channel.
    namespace export \
	    asnGetResponse \
	    asnGetInteger \
	    asnGetEnumeration \
	    asnGetOctetString \
	    asnGetSequence \
	    asnGetSet \
	    asnGetApplication    
}

#-----------------------------------------------------------------------------
# Implementation notes:
#
# See the 'asn_ber_intro.txt' in this directory for an introduction
# into BER/DER encoding of ASN.1 information. Bibliography information
#
#	A Layman's Guide to a Subset of ASN.1, BER, and DER
#
#	An RSA Laboratories Technical Note
#	Burton S. Kaliski Jr.
#	Revised November 1, 1993
#
#	Supersedes June 3, 1991 version, which was also published as
#	NIST/OSI Implementors' Workshop document SEC-SIG-91-17.
#	PKCS documents are available by electronic mail to
#	<pkcs@rsa.com>.
#
#	Copyright (C) 1991-1993 RSA Laboratories, a division of RSA
#	Data Security, Inc. License to copy this document is granted
#	provided that it is identified as "RSA Data Security, Inc.
#	Public-Key Cryptography Standards (PKCS)" in all material
#	mentioning or referencing this document.
#	003-903015-110-000-000
#
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# asnLength : Encode some length data. Helper command.
#-----------------------------------------------------------------------------

proc ::asn::asnLength {len} {
    if {$len < 128} {
        return [binary format c $len]
    }
    if {$len < 65536} {
        return [binary format H2S 82 $len]
    }
    return [binary format H2I 84 $len]
}


#-----------------------------------------------------------------------------
# asnSequence : Assumes that the arguments are already ASN encoded.
#-----------------------------------------------------------------------------

proc ::asn::asnSequence {args} {
    # The sequence tag is 0x30. The length is arbitrary and thus full
    # length coding is required. The arguments have to be BER encoded
    # already. Constructed value, definite-length encoding.

    set out ""
    foreach part $args {
        append out $part
    }
    set len [string length $out]
    return [binary format H2a*a$len 30 [asnLength $len] $out]
}


#-----------------------------------------------------------------------------
# asnSet : Assumes that the arguments are already ASN encoded.
#-----------------------------------------------------------------------------

proc ::asn::asnSet {args} {
    # The set tag is 0x31. The length is arbitrary and thus full
    # length coding is required. The arguments have to be BER encoded
    # already.

    set out ""
    foreach part $args {
        append out $part
    }
    set len [string length $out]
    return [binary format H2a*a$len 31 [asnLength $len] $out]
}


#-----------------------------------------------------------------------------
# asnApplicationConstr
#-----------------------------------------------------------------------------

proc ::asn::asnApplicationConstr {appNumber args} {
    # Packs the arguments into a constructed value with application tag.

    set out ""
    foreach part $args {
        append out $part
    }
    set code [expr {0x060 + $appNumber}]
    set len  [string length $out]
    return [binary format ca*a$len $code [asnLength $len] $out]
}

#-----------------------------------------------------------------------------
# asnApplication
#-----------------------------------------------------------------------------

proc ::asn::asnApplication {appNumber data} {
    # Packs the arguments into a constructed value with application tag.

    set code [expr {0x040 + $appNumber}]
    set len  [string length $data]
    return [binary format ca*a$len $code [asnLength $len] $data]
}

#-----------------------------------------------------------------------------
# asnChoice
#-----------------------------------------------------------------------------

proc ::asn::asnChoice {appNumber args} {
    # Packs the arguments into a choice construction.

    set out ""
    foreach part $args {
        append out $part
    }
    set code [expr {0x080 + $appNumber}]
    set len  [string length $out]
    return [binary format ca*a$len $code [asnLength $len] $out]
}

#-----------------------------------------------------------------------------
# asnChoiceConstr
#-----------------------------------------------------------------------------

proc ::asn::asnChoiceConstr {appNumber args} {
    # Packs the arguments into a choice construction.

    set out ""
    foreach part $args {
        append out $part
    }
    set code [expr {0x0A0 + $appNumber}]
    set len  [string length $out]
    return [binary format ca*a$len $code [asnLength $len] $out]
}

#-----------------------------------------------------------------------------
# asnInteger : Encode integer value.
#-----------------------------------------------------------------------------

proc ::asn::asnInteger {number} {
    # The integer tag is 0x02. The length is 1, 2, 3, or 4, coded in a
    # single byte. This can be done directly, no need to go through
    # asnLength. The value itself is written in big-endian.

    # Known bug/issue: The command cannot handle wide integers, i.e.
    # anything between 5 to 8 bytes length.

    if {($number >= -128) && ($number < 128)} {
        return [binary format H2H2c 02 01 $number]
    }
    if {($number >= -32768) && ($number < 32768)} {
        return [binary format H2H2S 02 02 $number]
    }
    if {($number >= -8388608) && ($number < 8388608)} {
	set numberb [expr {$number & 0xFFFF}]
	set numbera [expr {($number >> 16) & 0xFF}]
	return [binary format H2H2cS 02 03 $numbera $numberb]
    }
    return [binary format H2H2I 02 04 $number]
}

#-----------------------------------------------------------------------------
# asnEnumeration : Encode enumeration value.
#-----------------------------------------------------------------------------

proc ::asn::asnEnumeration {number} {
    # The enumeration tag is 0x0A. The length is 1, 2, or 4, coded in
    # a single byte. This can be done directly, no need to go through
    # asnLength. The value itself is written in big-endian.

    # Known bug/issue: The command cannot handle wide integers, i.e.
    # anything between 5 to 8 bytes length.

    if {($number >= -128) && ($number < 128)} {
        return [binary format H2H2c 0a 01 $number]
    }
    if {($number >= -32768) && ($number < 32768)} {
        return [binary format H2H2S 0a 02 $number]
    }
    if {($number >= -8388608) && ($number < 8388608)} {
	set numberb [expr {$number & 0xFFFF}]
	set numbera [expr {($number >> 16) & 0xFF}]
	return [binary format H2H2cS 0a 03 $numbera $numberb]
    }
    return [binary format H2H2I 0a 04 $number]
}

#-----------------------------------------------------------------------------
# asnBoolean : Encode a boolean value.
#-----------------------------------------------------------------------------

proc ::asn::asnBoolean {bool} {
    # The boolean tag is 0x01. The length is always 1, coded in
    # a single byte. This can be done directly, no need to go through
    # asnLength. The value itself is written in big-endian.

    return [binary format H2H2c 01 01 [expr {$bool ? 0x0FF : 0x0}]]
}

#-----------------------------------------------------------------------------
# asnOctetString : Encode a string of arbitrary bytes
#-----------------------------------------------------------------------------

proc ::asn::asnOctetString {string} {
    # The octet tag is 0x04. The length is arbitrary, so we need
    # 'asnLength' for full coding of the length.

    set len [string length $string]
    return [binary format H2a*a$len 04 [asnLength $len] $string]
}

#-----------------------------------------------------------------------------
# asnGetResponse : Read a ASN response from a channel.
#-----------------------------------------------------------------------------

proc ::asn::asnGetResponse {sock data_var} {
    upvar $data_var data

    # We expect a sequence here (tag 0x30). The code below is an
    # inlined replica of 'asnGetSequence', modified for reading from a
    # channel instead of a string.

    set tag [read $sock 1]

    if {$tag == "\x30"} {
	# The following code is a replica of 'asnGetLength', modified
	# for reading the bytes from the channel instead of a string.

        set len1 [read $sock 1]
        binary scan $len1 c num
        set length [expr {($num + 0x100) % 0x100}]

        ::log::log debug "asnGetResponse length=$length"

        if {$length  >= 0x080} {
	    # The byte the read is not the length, but a prefix, and
	    # the lower nibble tells us how many bytes follow.

            set len_length  [expr {$length & 0x7f}]

	    # BUG: We should not perform the value extraction for an
	    # BUG: improper length. It wastes cycles, and here it can
	    # BUG: cause us trouble, reading more data than there is
	    # BUG: on the channel. Depending on the channel
	    # BUG: configuration an attacker can induce us to block,
	    # BUG: causing a denial of service.
            set lengthBytes [read $sock $len_length]

            switch $len_length {
                1 {
		    binary scan $lengthBytes     c length 
		    set length [expr {($length + 0x100) % 0x100}]
                }
                2 { binary scan $lengthBytes     S length }
                3 { binary scan \x00$lengthBytes I length }
                4 { binary scan $lengthBytes     I length }
                default {
                    return -code error "length information too long ($len_length)"
                }
            }
        }

	# Now that the length is known we get the remainder,
	# i.e. payload, and construct proper in-memory BER encoded
	# sequence.

        set rest [read $sock $length]
        set data [binary format aa*a$length $tag [asnLength $length] $rest]
    }  else {
	# Generate an error message if the data is not a sequence as
	# we expected.

        set tag_hex ""
        binary scan $tag H2 tag_hex
        return -code error "unknown start tag [string length $tag] $tag_hex"
    }
}

#-----------------------------------------------------------------------------
# asnGetByte : Retrieve a single byte from the data (unsigned)
#-----------------------------------------------------------------------------

proc ::asn::asnGetByte {data_var byte_var} {
    upvar $data_var data $byte_var byte

    binary scan [string index $data 0] c byte
    set byte [expr {($byte + 0x100) % 0x100}]  
    set data [string range $data 1 end]

    ::log::log debug "asnGetByte $byte"
    return
}


#-----------------------------------------------------------------------------
# asnGetBytes : Retrieve a block of 'length' bytes from the data.
#-----------------------------------------------------------------------------

proc ::asn::asnGetBytes {data_var length bytes_var} {
    upvar $data_var data  $bytes_var bytes

    incr length -1
    set bytes [string range $data 0 $length]
    incr length
    set data [string range $data $length end]

    ::log::loghex debug asnGetBytes $bytes
    return
}


#-----------------------------------------------------------------------------
# asnGetLength : Retrieve an ASN length value (What comes after the tag (See notes))
#-----------------------------------------------------------------------------

proc ::asn::asnGetLength {data_var length_var} {
    upvar $data_var data  $length_var length

    asnGetByte data length
    if {$length >= 0x080} {
	# The retrieved byte is a prefix value, and the integer in the
	# lower nibble tells us how many bytes were used to encode the
	# length data following immediately after this prefix.

        set len_length [expr {$length & 0x7f}]

	# BUG: We should not perform the value extraction for an
	# BUG: improper length. It cannot cause us trouble [1], even
	# BUG: if we try to read much more data then we have bytes,
	# BUG: but it does waste cycles.
	#
	# [1] In contrast to reading from a channel (See asnGetResponse).

        asnGetBytes data $len_length lengthBytes

        switch $len_length {
            1 {
		# Efficiently coded data will not go through this
		# path, as small length values can be coded directly,
		# without a prefix.

		binary scan $lengthBytes     c length 
	        set length [expr {($length + 0x100) % 0x100}]
            }
            2 { binary scan $lengthBytes     S length }
            3 { binary scan \x00$lengthBytes I length }
            4 { binary scan $lengthBytes     I length }
            default {
                return -code error "length information too long"
            }
        }
    }
    ::log::log debug "asnGetLength -> length = $length"
    return
}

#-----------------------------------------------------------------------------
# asnGetInteger : Retrieve integer.
#-----------------------------------------------------------------------------

proc ::asn::asnGetInteger {data_var int_var} {
    # Tag is 0x02. We expect that the length of the integer is coded with
    # maximal efficiency, i.e. without a prefix 0x81 prefix. If a prefix
    # is used this decoder will fail.

    # BUG: Extracting length, and later payload before the validation
    # BUG: is wasting cycles.

    upvar $data_var data $int_var int

    asnGetByte   data tag
    asnGetLength data len
    asnGetBytes  data $len integerBytes

    if {$tag != 0x02} {
        binary scan $tag H2 tag_hex
        return -code error "Expected Integer (0x02), but got $tag_hex"
    }
    set int ?

    ::log::log debug "asnGetInteger len=$len"
    switch $len {
        1 { binary scan $integerBytes     c int }
        2 { binary scan $integerBytes     S int }
        3 { binary scan \x00$integerBytes I int }
        4 { binary scan $integerBytes     I int }
        default {
	    # Too long, or prefix coding was used.
            return -code error "length information too long"
        }
    }
    ::log::log debug "asnGetInteger int=$int"
    return
}

#-----------------------------------------------------------------------------
# asnGetEnumeration : Retrieve an enumeration id
#-----------------------------------------------------------------------------

proc ::asn::asnGetEnumeration {data_var enum_var} {
    # This is like 'asnGetInteger', except for a different tag.

    # BUG: Extracting length, and later payload before the validation
    # BUG: is wasting cycles.

    upvar $data_var data $enum_var enum

    asnGetByte   data tag
    asnGetLength data len
    asnGetBytes  data $len integerBytes

    if {$tag != 0x0a} {
        binary scan $tag H2 tag_hex
        return -code error "Expected Enumeration (0x0a), but got $tag_hex"
    }
    set enum ?

    ::log::log debug "asnGetEnumeration  len=$len"
    switch $len {
        1 { binary scan $integerBytes     c enum }
        2 { binary scan $integerBytes     S enum }
        3 { binary scan \x00$integerBytes I enum }
        4 { binary scan $integerBytes     I enum }
        default {
            return -code error "length information too long"
        }
    }
    ::log::log debug "asnGetEnumeration enum=$enum"
    return
}

#-----------------------------------------------------------------------------
# asnGetOctetString : Retrieve arbitrary string.
#-----------------------------------------------------------------------------

proc ::asn::asnGetOctetString {data_var string_var} {
    # Here we need the full decoder for length data.

    upvar $data_var data $string_var string
    
    asnGetByte data tag
    if {$tag != 0x04} { 
        binary scan $tag H2 tag_hex
        return -code error "Expected Octet String (0x04), but got $tag_hex"
    }
    asnGetLength data length
    asnGetBytes  data $length temp
    set string $temp
    return
}

#-----------------------------------------------------------------------------
# asnGetSequence : Retrieve Sequence data for further decoding.
#-----------------------------------------------------------------------------

proc ::asn::asnGetSequence {data_var sequence_var} {
    # Here we need the full decoder for length data.

    upvar $data_var data $sequence_var sequence

    asnGetByte data tag
    if {$tag != 0x030} { 
        binary scan $tag H2 tag_hex
        return -code error "Expected Sequence (0x30), but got $tag_hex"
    }    
    asnGetLength data length
    asnGetBytes  data $length temp
    set sequence $temp
    return
}

#-----------------------------------------------------------------------------
# asnGetSet : Retrieve Set data for further decoding.
#-----------------------------------------------------------------------------

proc ::asn::asnGetSet {data_var set_var} {
    # Here we need the full decoder for length data.

    upvar $data_var data $set_var set

    asnGetByte data tag
    if {$tag != 0x031} { 
        binary scan $tag H2 tag_hex
        return -code error "Expected Set (0x31), but got $tag_hex"
    }    
    asnGetLength data length
    asnGetBytes  data $length temp
    set set $temp
    return
}

#-----------------------------------------------------------------------------
# asnGetApplication
#-----------------------------------------------------------------------------

proc ::asn::asnGetApplication {data_var appNumber_var} {
    upvar $data_var data $appNumber_var appNumber

    asnGetByte   data tag
    asnGetLength data length

    if {($tag & 0xE0) != 0x060} {
        binary scan $tag H2 tag_hex
        return -code error "Expected Application (0x60), but got $tag_hex"
    }    
    set appNumber [expr {$tag & 0x1F}]
    return
}

#-----------------------------------------------------------------------------
package provide asn 0.1
