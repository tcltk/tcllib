# base64url.tcl --
#
#       Provides encode/decode routines for the 'base64url' encoding standard.
#       See: http://tools.ietf.org/html/rfc4648#section-5
#       We implement the version without padding as described here:
#       https://tools.ietf.org/html/draft-ietf-jose-json-web-signature-36#appendix-C
#
# Copyright (c) 2014 Neil Madden.
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require Tcl         8.5
package require base64      2.4

package provide base64url   1.0

namespace eval ::base64url {
    namespace export encode decode
    namespace ensemble create

    # ::base64url encode encoding data --
    #
    #   Base64url encode a given string.
    #
    # Arguments:
    #   encoding    The character encoding to use when converting the string
    #               bytes. Use "binary" if already encoded.
    #   data        The data to encode.
    #
    # Results:
    #   A base6url encoded version of $data in $encoding encoding.
    #
    proc encode {encoding data} {
        if {$encoding ne "binary"} {
            set data [encoding convertto $encoding $data]
        }
        string map {
            +       -
            /       _
            =       ""
        } [base64::encode -wrapchar "" $data]
    }

    # :base64url decode encoding data --
    #
    #   Base64url decode a given string.
    #
    # Arguments:
    #   encoding    The character encoding to apply to the data after
    #               decoding. Use "binary" if data is binary.
    #   data        The data to decode. Should be in base64url format.
    #
    # Results:
    #   The decoded data after conversion to the given character encoding.
    #
    proc decode {encoding data} {
        set data [base64::decode [string map {
            -       +
            _       /
        } [pad-align 4 "=" $data]]]
        if {$encoding ne "binary"} {
            set data [encoding convertfrom $encoding $data]
        }
        return $data
    }

    # pad-align width padChar data --
    #
    #       Right-pads $data with $padChar until it is a multiple of $width
    #       characters in length.
    #
    proc pad-align {width padChar data} {
        append data [string repeat $padChar \
            [expr {$width - ([string length $data] % $width)}]]
    }
}
