# mime.tcl - MIME body parts
#
# (c) 1999-2000 Marshall T. Rose
# (c) 2000      Brent Welch
# (c) 2000      Sandeep Tamhankar
# (c) 2000      Dan Kuchler
# (c) 2000-2001 Eric Melski
# (c) 2001      Jeff Hobbs
# (c) 2001-2008 Andreas Kupries
# (c) 2002-2003 David Welton
# (c) 2003-2008 Pat Thoyts
# (c) 2005      Benjamin Riefenstahl
# (c) 2013-2018 Poor Yorick
#
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Influenced by Borenstein's/Rose's safe-tcl (circa 1993) and Darren New's
# unpublished package of 1999.
#

# new string features and inline scan are used, requiring 8.3.
package require Tcl 8.6.9

package require namespacex
package require tcl::chan::cat
package provide mime 3.0.0 
package require tcl::chan::memchan
package require tcl::chan::string
package require {chan base}
package require {chan getslimit}
package require sha256


if {[catch {package require Trf 2.0}]} {

    # Fall-back to tcl-based procedures of base64 and quoted-printable
    # encoders
    ##
    # Warning!
    ##
    # These are a fragile emulations of the more general calling
    # sequence that appears to work with this code here.
    ##
    # The `__ignored__` arguments are expected to be `--` options on
    # the caller's side. (See the uses in `copymessageaux`,
    # `buildmessageaux`, `parsepart`, and `getbody`).

    package require base64 2.0
    set ::major [lindex [split [package require md5] .] 0]

    # Create these commands in the mime namespace so that they
    # won't collide with things at the global namespace level

    namespace eval ::mime {
        proc base64 {-mode what __ignored__ chunk} {
            return [base64::$what $chunk]
        }
        proc quoted-printable {-mode what __ignored__ chunk} {
            return [mime::qp_$what $chunk]
        }

        if {$::major < 2} {
            # md5 v1, result is hex string ready for use.
            proc md5 {__ignored__ string} {
                return [md5::md5 $string]
            }
        } else {
            # md5 v2, need option to get hex string
            proc md5 {__ignored__ string} {
                return [md5::md5 -hex $string]
            }
        }
    }

    unset ::major
}

#
# state variables:
#
#     canonicalP: input is in its canonical form
#     encoding: transfer encoding
#     version: MIME-version
#     header: dictionary (keys are lower-case)
#     value: either "chan" or  "parts"
#
#     file: input file
#     fd: cached file-descriptor, typically for root
#     root: token for top-level part, for (distant) subordinates
#     count: length in octets of (encoded) content
#
#     parts: list of bodies (tokens)
#
#     cid: last child-id assigned


namespace eval ::mime {

    variable mime
    array set mime {uid 0 cid 0}


    # RFC 822 lexemes
    variable addrtokenL
    lappend addrtokenL \; , < > : . ( ) @ \" \[ ] \\
    variable addrlexemeL {
        LX_SEMICOLON LX_COMMA
        LX_LBRACKET  LX_RBRACKET
        LX_COLON     LX_DOT
        LX_LPAREN    LX_RPAREN
        LX_ATSIGN    LX_QUOTE
        LX_LSQUARE   LX_RSQUARE
        LX_QUOTE
    }

    variable encList {
        ascii US-ASCII
        big5 Big5
        cp1250 Windows-1250
        cp1251 Windows-1251
        cp1252 Windows-1252
        cp1253 Windows-1253
        cp1254 Windows-1254
        cp1255 Windows-1255
        cp1256 Windows-1256
        cp1257 Windows-1257
        cp1258 Windows-1258
        cp437 IBM437
        cp737 {}
        cp775 IBM775
        cp850 IBM850
        cp852 IBM852
        cp855 IBM855
        cp857 IBM857
        cp860 IBM860
        cp861 IBM861
        cp862 IBM862
        cp863 IBM863
        cp864 IBM864
        cp865 IBM865
        cp866 IBM866
        cp869 IBM869
        cp874 {}
        cp932 {}
        cp936 GBK
        cp949 {}
        cp950 {}
        dingbats {}
        ebcdic {}
        euc-cn EUC-CN
        euc-jp EUC-JP
        euc-kr EUC-KR
        gb12345 GB12345
        gb1988 GB1988
        gb2312 GB2312
        iso2022 ISO-2022
        iso2022-jp ISO-2022-JP
        iso2022-kr ISO-2022-KR
        iso8859-1 ISO-8859-1
        iso8859-2 ISO-8859-2
        iso8859-3 ISO-8859-3
        iso8859-4 ISO-8859-4
        iso8859-5 ISO-8859-5
        iso8859-6 ISO-8859-6
        iso8859-7 ISO-8859-7
        iso8859-8 ISO-8859-8
        iso8859-9 ISO-8859-9
        iso8859-10 ISO-8859-10
        iso8859-13 ISO-8859-13
        iso8859-14 ISO-8859-14
        iso8859-15 ISO-8859-15
        iso8859-16 ISO-8859-16
        jis0201 JIS_X0201
        jis0208 JIS_C6226-1983
        jis0212 JIS_X0212-1990
        koi8-r KOI8-R
        koi8-u KOI8-U
        ksc5601 KS_C_5601-1987
        macCentEuro {}
        macCroatian {}
        macCyrillic {}
        macDingbats {}
        macGreek {}
        macIceland {}
        macJapan {}
        macRoman {}
        macRomania {}
        macThai {}
        macTurkish {}
        macUkraine {}
        shiftjis Shift_JIS
        symbol {}
        tis-620 TIS-620
        unicode {}
        utf-8 UTF-8
    }

    variable encodings
    array set encodings $encList
    variable reversemap
    # Initialized at the bottom of the file

    variable encAliasList {
        ascii ANSI_X3.4-1968
        ascii iso-ir-6
        ascii ANSI_X3.4-1986
        ascii ISO_646.irv:1991
        ascii ASCII
        ascii ISO646-US
        ascii us
        ascii IBM367
        ascii cp367
        cp437 cp437
        cp437 437
        cp775 cp775
        cp850 cp850
        cp850 850
        cp852 cp852
        cp852 852
        cp855 cp855
        cp855 855
        cp857 cp857
        cp857 857
        cp860 cp860
        cp860 860
        cp861 cp861
        cp861 861
        cp861 cp-is
        cp862 cp862
        cp862 862
        cp863 cp863
        cp863 863
        cp864 cp864
        cp865 cp865
        cp865 865
        cp866 cp866
        cp866 866
        cp869 cp869
        cp869 869
        cp869 cp-gr
        cp936 CP936
        cp936 MS936
        cp936 Windows-936
        iso8859-1 ISO_8859-1:1987
        iso8859-1 iso-ir-100
        iso8859-1 ISO_8859-1
        iso8859-1 latin1
        iso8859-1 l1
        iso8859-1 IBM819
        iso8859-1 CP819
        iso8859-2 ISO_8859-2:1987
        iso8859-2 iso-ir-101
        iso8859-2 ISO_8859-2
        iso8859-2 latin2
        iso8859-2 l2
        iso8859-3 ISO_8859-3:1988
        iso8859-3 iso-ir-109
        iso8859-3 ISO_8859-3
        iso8859-3 latin3
        iso8859-3 l3
        iso8859-4 ISO_8859-4:1988
        iso8859-4 iso-ir-110
        iso8859-4 ISO_8859-4
        iso8859-4 latin4
        iso8859-4 l4
        iso8859-5 ISO_8859-5:1988
        iso8859-5 iso-ir-144
        iso8859-5 ISO_8859-5
        iso8859-5 cyrillic
        iso8859-6 ISO_8859-6:1987
        iso8859-6 iso-ir-127
        iso8859-6 ISO_8859-6
        iso8859-6 ECMA-114
        iso8859-6 ASMO-708
        iso8859-6 arabic
        iso8859-7 ISO_8859-7:1987
        iso8859-7 iso-ir-126
        iso8859-7 ISO_8859-7
        iso8859-7 ELOT_928
        iso8859-7 ECMA-118
        iso8859-7 greek
        iso8859-7 greek8
        iso8859-8 ISO_8859-8:1988
        iso8859-8 iso-ir-138
        iso8859-8 ISO_8859-8
        iso8859-8 hebrew
        iso8859-9 ISO_8859-9:1989
        iso8859-9 iso-ir-148
        iso8859-9 ISO_8859-9
        iso8859-9 latin5
        iso8859-9 l5
        iso8859-10 iso-ir-157
        iso8859-10 l6
        iso8859-10 ISO_8859-10:1992
        iso8859-10 latin6
        iso8859-14 iso-ir-199
        iso8859-14 ISO_8859-14:1998
        iso8859-14 ISO_8859-14
        iso8859-14 latin8
        iso8859-14 iso-celtic
        iso8859-14 l8
        iso8859-15 ISO_8859-15
        iso8859-15 Latin-9
        iso8859-16 iso-ir-226
        iso8859-16 ISO_8859-16:2001
        iso8859-16 ISO_8859-16
        iso8859-16 latin10
        iso8859-16 l10
        jis0201 X0201
        jis0208 iso-ir-87
        jis0208 x0208
        jis0208 JIS_X0208-1983
        jis0212 x0212
        jis0212 iso-ir-159
        ksc5601 iso-ir-149
        ksc5601 KS_C_5601-1989
        ksc5601 KSC5601
        ksc5601 korean
        shiftjis MS_Kanji
        utf-8 UTF8
    }

    namespace export {*}{
	datetime finalize getbody header initialize mapencoding parseaddress
	property reversemapencoding serialize setheader uniqueID
    }
}


proc ::mime::addchan {token chan} {
    variable channels
    upvar 0 $token state
    upvar 0 state(fd) fd
    if {[info exists fd]} {
	error [list {a channel is already present}]
    }

    if {[$chan configure -encoding] ne {binary}} {
	$chan configure -translation auto
    }
    set fd $chan
    incr channels($fd)
    return
}


# ::mime::addr_next --
#
#       Locate the next address in a mime token.
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns 1 if there is another address, and 0 if there is not.

proc ::mime::addr_next token {
    # FRINK: nocheck
    upvar 0 $token state
    set nocomplain [package vsatisfies [package provide Tcl] 8.4]
    foreach prop {comment domain error group local memberP phrase route} {
        if {$nocomplain} {
            unset -nocomplain state($prop)
        } else {
            catch {unset state($prop)}
        }
    }

    switch [set code [catch {mime::addr_specification $token} result copts]] {
        0 {
            if {!$result} {
                return 0
            }

            switch $state(lastC) {
                LX_COMMA
                    -
                LX_END {
                }
                default {
                    # catch trailing comments...
                    set lookahead $state(input)
                    parselexeme $token
                    set state(input) $lookahead
                }
            }
        }

        7 {
            set state(error) $result

            while 1 {
                switch $state(lastC) {
                    LX_COMMA
                        -
                    LX_END {
                        break
                    }

                    default {
                        parselexeme $token
                    }
                }
            }
        }

        default {
            return -options $copts $result
        }
    }

    foreach prop {comment domain error group local memberP phrase route} {
        if {![info exists state($prop)]} {
            set state($prop) {}
        }
    }

    return 1
}


# ::mime::addr_specification --
#
#   Uses lookahead parsing to determine whether there is another
#   valid e-mail address or not.  Throws errors if unrecognized
#   or invalid e-mail address syntax is used.
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns 1 if there is another address, and 0 if there is not.

proc ::mime::addr_specification {token} {
    # FRINK: nocheck
    upvar 0 $token state

    set lookahead $state(input)
    switch [parselexeme $token] {
        LX_ATOM
            -
        LX_QSTRING {
            set state(phrase) $state(buffer)
        }

        LX_SEMICOLON {
            if {[incr state(glevel) -1] < 0} {
                return -code 7 "extraneous semi-colon"
            }

            catch {unset state(comment)}
            return [addr_specification $token]
        }

        LX_COMMA {
            catch {unset state(comment)}
            return [addr_specification $token]
        }

        LX_END {
            return 0
        }

        LX_LBRACKET {
            return [addr_routeaddr $token]
        }

        LX_ATSIGN {
            set state(input) $lookahead
            return [addr_routeaddr $token 0]
        }

        default {
            return -code 7 [
		format "unexpected character at beginning (found %s)" \
		   $state(buffer)]
        }
    }

    switch [parselexeme $token] {
        LX_ATOM
            -
        LX_QSTRING {
            append state(phrase) " " $state(buffer)

            return [addr_phrase $token]
        }

        LX_LBRACKET {
            return [addr_routeaddr $token]
        }

        LX_COLON {
            return [addr_group $token]
        }

        LX_DOT {
            set state(local) "$state(phrase)$state(buffer)"
            unset state(phrase)
            mime::addr_routeaddr $token 0
            mime::addr_end $token
        }

        LX_ATSIGN {
            set state(memberP) $state(glevel)
            set state(local) $state(phrase)
            unset state(phrase)
            mime::addr_domain $token
            mime::addr_end $token
        }

        LX_SEMICOLON
            -
        LX_COMMA
            -
        LX_END {
            set state(memberP) $state(glevel)
            if {
		$state(lastC) eq "LX_SEMICOLON"
		&&
		([incr state(glevel) -1] < 0)
	    } {
                #TODO: this path is not covered by tests
                return -code 7 "extraneous semi-colon"
            }

            set state(local) $state(phrase)
            unset state(phrase)
        }

        default {
            return -code 7 [
                format "expecting mailbox (found %s)" $state(buffer)]
        }
    }

    return 1
}


# ::mime::addr_routeaddr --
#
#       Parses the domain portion of an e-mail address.  Finds the '@'
#       sign and then calls mime::addr_route to verify the domain.
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns 1 if there is another address, and 0 if there is not.

proc ::mime::addr_routeaddr {token {checkP 1}} {
    # FRINK: nocheck
    upvar 0 $token state

    set lookahead $state(input)
    if {[parselexeme $token] eq "LX_ATSIGN"} {
        #TODO: this path is not covered by tests
        mime::addr_route $token
    } else {
        set state(input) $lookahead
    }

    mime::addr_local $token

    switch $state(lastC) {
        LX_ATSIGN {
            mime::addr_domain $token
        }

        LX_SEMICOLON
            -
        LX_RBRACKET
            -
        LX_COMMA
            -
        LX_END {
        }

        default {
            return -code 7 [
                format "expecting at-sign after local-part (found %s)" \
                $state(buffer)]
        }
    }

    if {($checkP) && ($state(lastC) ne "LX_RBRACKET")} {
        return -code 7 [
            format "expecting right-bracket (found %s)" $state(buffer)]
    }

    return 1
}


# ::mime::addr_route --
#
#    Attempts to parse the portion of the e-mail address after the @.
#    Tries to verify that the domain definition has a valid form.
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_route {token} {
    # FRINK: nocheck
    upvar 0 $token state

    set state(route) @

    while 1 {
        switch [parselexeme $token] {
            LX_ATOM
                -
            LX_DLITERAL {
                append state(route) $state(buffer)
            }

            default {
                return -code 7 \
                       [format "expecting sub-route in route-part (found %s)" \
                               $state(buffer)]
            }
        }

        switch [parselexeme $token] {
            LX_COMMA {
                append state(route) $state(buffer)
                while 1 {
                    switch [parselexeme $token] {
                        LX_COMMA {
                        }

                        LX_ATSIGN {
                            append state(route) $state(buffer)
                            break
                        }

                        default {
                            return -code 7 \
                                   [format "expecting at-sign in route (found %s)" \
                                           $state(buffer)]
                        }
                    }
                }
            }

            LX_ATSIGN
                -
            LX_DOT {
                append state(route) $state(buffer)
            }

            LX_COLON {
                append state(route) $state(buffer)
                return
            }

            default {
                return -code 7 [
		    format "expecting colon to terminate route (found %s)" \
			$state(buffer)]
            }
        }
    }
}


# ::mime::addr_domain --
#
#    Attempts to parse the portion of the e-mail address after the @.
#    Tries to verify that the domain definition has a valid form.
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_domain token {
    # FRINK: nocheck
    upvar 0 $token state

    while 1 {
        switch [parselexeme $token] {
            LX_ATOM
                -
            LX_DLITERAL {
                append state(domain) $state(buffer)
            }

            default {
                return -code 7 [
		    format "expecting sub-domain in domain-part (found %s)" \
			$state(buffer)]
            }
        }

        switch [parselexeme $token] {
            LX_DOT {
                append state(domain) $state(buffer)
            }

            LX_ATSIGN {
                append state(local) % $state(domain)
                unset state(domain)
            }

            default {
                return
            }
        }
    }
}


# ::mime::addr_local --
#
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_local {token} {
    # FRINK: nocheck
    upvar 0 $token state

    set state(memberP) $state(glevel)

    while 1 {
        switch [parselexeme $token] {
            LX_ATOM
                -
            LX_QSTRING {
                append state(local) $state(buffer)
            }

            default {
                return -code 7 \
                       [format "expecting mailbox in local-part (found %s)" \
                               $state(buffer)]
            }
        }

        switch [parselexeme $token] {
            LX_DOT {
                append state(local) $state(buffer)
            }

            default {
                return
            }
        }
    }
}


# ::mime::addr_phrase --
#
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.


proc ::mime::addr_phrase {token} {
    # FRINK: nocheck
    upvar 0 $token state

    while 1 {
        switch [parselexeme $token] {
            LX_ATOM
                -
            LX_QSTRING {
                append state(phrase) " " $state(buffer)
            }

            default {
                break
            }
        }
    }

    switch $state(lastC) {
        LX_LBRACKET {
            return [addr_routeaddr $token]
        }

        LX_COLON {
            return [addr_group $token]
        }

        LX_DOT {
            append state(phrase) $state(buffer)
            return [addr_phrase $token]
        }

        default {
            return -code 7 [
		format "found phrase instead of mailbox (%s%s)" \
		    $state(phrase) $state(buffer)]
        }
    }
}


# ::mime::addr_group --
#
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_group {token} {
    # FRINK: nocheck
    upvar 0 $token state

    if {[incr state(glevel)] > 1} {
        return -code 7 [
	    format "nested groups not allowed (found %s)" $state(phrase)]
    }

    set state(group) $state(phrase)
    unset state(phrase)

    set lookahead $state(input)
    while 1 {
        switch [parselexeme $token] {
            LX_SEMICOLON
                -
            LX_END {
                set state(glevel) 0
                return 1
            }

            LX_COMMA {
            }

            default {
                set state(input) $lookahead
                return [addr_specification $token]
            }
        }
    }
}


# ::mime::addr_end --
#
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_end {token} {
    # FRINK: nocheck
    upvar 0 $token state

    switch $state(lastC) {
        LX_SEMICOLON {
            if {[incr state(glevel) -1] < 0} {
                return -code 7 "extraneous semi-colon"
            }
        }

        LX_COMMA
            -
        LX_END {
        }

        default {
            return -code 7 [
		format "junk after local@domain (found %s)" $state(buffer)]
        }
    }
}


# ::mime::addr_x400 --
#
#
# Arguments:
#       token         The MIME token to work from.
#
# Results:
#    Returns nothing if successful, and throws an error if invalid
#       syntax is found.

proc ::mime::addr_x400 {mbox key} {
    if {[set x [string first /$key= [string toupper $mbox]]] < 0} {
        return {}
    }
    set mbox [string range $mbox [expr {$x + [string length $key] + 2}] end]

    if {[set x [string first / $mbox]] > 0} {
        set mbox [string range $mbox 0 [expr {$x - 1}]]
    }

    return [string trim $mbox \"]
}


proc ::mime::checkinputs {} {
    upvar 1 inputs inputs
    if {[incr inputs] > 1} {
	error [list {more than one input source provided}]
    }
}


proc ::mime::body_decoded token {
    upvar 0 $token state
    upvar 0 state(bodychandecoded) bodychandecoded
    parsepart $token
    if {[info exists state(parts)]} {
	error [list {not a leaf part} $token]
    }
    if {$state(canonicalP)} { 
	$state(fd) seek 0 
	return $state(fd)
    } else {
	if {![info exists bodychandecoded]} {
	    set bodychandecoded [::tcllib::chan::base .new [
		info cmdcount]_bodydecoded [file tempfile]]
	    $bodychandecoded configure -translation binary
	    $state(bodychan) seek 0
	    $state(bodychan) copy [$bodychandecoded $ chan]
	    $bodychandecoded seek 0
	    $state(bodychan) seek 0
	    setencoding $token $bodychandecoded
	    setcharset $token $bodychandecoded
	}
	$bodychandecoded seek 0
	return $bodychandecoded
    }
}

proc ::mime::body_raw token {
    upvar 0 $token state
    parsepart $token
    if {[info exists state(parts)]} {
	error [list {not a leaf part} $token]
    }
    if {$state(canonicalP)} { 
	$state(fd) seek 0
	return $state(fd)
    } else {
	$state(bodychan) seek 0 
	return $state(bodychan)
    }
}


namespace eval ::mime::body {
    namespace ensemble create
    namespace export *
    namespacex import [namespace parent] body_decoded decoded body_raw raw
}


proc ::mime::contenttype token {
    upvar 0 $token state
    try {
	header get $token content-type
    } on error {cres copts} {
	# rfc 2045 5.2
	try {
	    if {header exists $token MIME-Version} {
		    return text/plain
	    } else {
		switch $state(spec) {
		    http {
			return {text/html {charset UTF-8}}
		    }
		    mime {
			# do not specify US-ASCII here as it is the default
			return text/plain
		    }
		    
		}
	    }
	} on error {} {
	    return application/octet-stream
	}
    }
}


# ::mime::datetime --
#
#    Fortunately the clock command in the Tcl 8.x core does all the heavy
#    lifting for us (except for timezone calculations).
#
#    mime::datetime takes a string containing an 822-style date-time
#    specification and returns the specified property.
#
#    The list of properties and their ranges are:
#
#       property     range
#       ========     =====
#       clock        raw result of "clock scan"
#       hour         0 .. 23
#       lmonth       January, February, ..., December
#       lweekday     Sunday, Monday, ... Saturday
#       mday         1 .. 31
#       min          0 .. 59
#       mon          1 .. 12
#       month        Jan, Feb, ..., Dec
#       proper       822-style date-time specification
#       rclock       elapsed seconds between then and now
#       sec          0 .. 59
#       wday         0 .. 6 (Sun .. Mon)
#       weekday      Sun, Mon, ..., Sat
#       yday         1 .. 366
#       year         1900 ...
#       zone         -720 .. 720 (minutes east of GMT)
#
# Arguments:
#       value       Either a 822-style date-time specification or '-now'
#                   if the current date/time should be used.
#       property    The property (from the list above) to return
#
# Results:
#    Returns the string value of the 'property' for the date/time that was
#       specified in 'value'.

namespace eval ::mime {
        variable WDAYS_SHORT  [list Sun Mon Tue Wed Thu Fri Sat]
        variable WDAYS_LONG   [list Sunday Monday Tuesday Wednesday Thursday \
                                    Friday Saturday]

        # Counting months starts at 1, so just insert a dummy element
        # at index 0.
        variable MONTHS_SHORT [list {} \
                                    Jan Feb Mar Apr May Jun \
                                    Jul Aug Sep Oct Nov Dec]
        variable MONTHS_LONG  [list {} \
                                    January February March April May June July \
                                    August Sepember October November December]
}
proc ::mime::datetime {value property} {
    if {$value eq "-now"} {
        set clock [clock seconds]
    } elseif {[regexp {^(.*) ([+-])([0-9][0-9])([0-9][0-9])$} $value \
	-> value zone_sign zone_hour zone_min]
    } {
        set clock [clock scan $value -gmt 1]
        if {[info exists zone_min]} {
            set zone_min [scan $zone_min %d]
            set zone_hour [scan $zone_hour %d]
            set zone [expr {60 * ($zone_min + 60 * $zone_hour)}]
            if {$zone_sign eq "+"} {
                set zone -$zone
            }
            incr clock $zone
        }
    } else {
        set clock [clock scan $value]
    }

    switch $property {
        clock {
            return $clock
        }

        hour {
            set value [clock format $clock -format %H]
        }

        lmonth {
            variable MONTHS_LONG
            return [lindex $MONTHS_LONG \
                            [scan [clock format $clock -format %m] %d]]
        }

        lweekday {
            variable WDAYS_LONG
            return [lindex $WDAYS_LONG [clock format $clock -format %w]]
        }

        mday {
            set value [clock format $clock -format %d]
        }

        min {
            set value [clock format $clock -format %M]
        }

        mon {
            set value [clock format $clock -format %m]
        }

        month {
            variable MONTHS_SHORT
            return [lindex $MONTHS_SHORT [
		scan [clock format $clock -format %m] %d]]
        }

        proper {
            set gmt [clock format $clock -format "%Y-%m-%d %H:%M:%S" -gmt true]
            if {[set diff [expr {($clock-[clock scan $gmt]) / 60}]] < 0} {
                set s -
                set diff [expr {-($diff)}]
            } else {
                set s +
            }
            set zone [format %s%02d%02d $s [
                expr {$diff / 60}] [expr {$diff % 60}]]

            variable WDAYS_SHORT
            set wday [lindex $WDAYS_SHORT [clock format $clock -format %w]]
            variable MONTHS_SHORT
            set mon [lindex $MONTHS_SHORT [
		scan [clock format $clock -format %m] %d]]

            return [
		clock format $clock -format "$wday, %d $mon %Y %H:%M:%S $zone"]
        }

        rclock {
            #TODO: these paths are not covered by tests
            if {$value eq "-now"} {
                return 0
            } else {
                return [expr {[clock seconds] - $clock}]
            }
        }

        sec {
            set value [clock format $clock -format %S]
        }

        wday {
            return [clock format $clock -format %w]
        }

        weekday {
            variable WDAYS_SHORT
            return [lindex $WDAYS_SHORT [clock format $clock -format %w]]
        }

        yday {
            set value [clock format $clock -format %j]
        }

        year {
            set value [clock format $clock -format %Y]
        }

        zone {
            set value [string trim [string map [list \t { }] $value]]
            if {[set x [string last { } $value]] < 0} {
                return 0
            }
            set value [string range $value [expr {$x + 1}] end]
            switch [set s [string index $value 0]] {
                + - - {
                    if {$s eq "+"} {
                        #TODO: This path is not covered by tests
                        set s {}
                    }
                    set value [string trim [string range $value 1 end]]
                    if {(
			    [string length $value] != 4)
			||
			    [scan $value %2d%2d h m] != 2
			||
			    $h > 12
			||
			    $m > 59
			||
			    ($h == 12 && $m > 0)
		    } {
                        error "malformed timezone-specification: $value"
                    }
                    set value $s[expr {$h * 60 + $m}]
                }

                default {
                    set value [string toupper $value]
                    set z1 [list  UT GMT EST EDT CST CDT MST MDT PST PDT]
                    set z2 [list   0   0  -5  -4  -6  -5  -7  -6  -8  -7]
                    if {[set x [lsearch -exact $z1 $value]] < 0} {
                        error "unrecognized timezone-mnemonic: $value"
                    }
                    set value [expr {[lindex $z2 $x] * 60}]
                }
            }
        }

        date2gmt
            -
        date2local
            -
        dst
            -
        sday
            -
        szone
            -
        tzone
            -
        default {
            error "unknown property $property"
        }
    }

    if {[set value [string trimleft $value 0]] eq {}} {
        #TODO: this path is not covered by tests
        set value 0
    }
    return $value
}


# ::mime::encoding --
#
#     Determines how a token is encoded.
#
# Arguments:
#       token
#            The MIME token to parse.
#
# Results:
#       Returns the encoding of the message (the null string, base64,
#       or quoted-printable).

proc ::mime::encoding token {
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(fd) chan state(params) params

    if {[info exists state(encoding)]} {
	return $state(encoding)
    }
    lassign [contenttype $token] content

    switch -glob $content {
        audio/*
            -
        image/*
            -
        video/* {
            return [set state(encoding) base64]
        }

        message/*
            -
        multipart/* {
            return [set state(encoding) {}]
        }
        default {# Skip}
    }

    set asciiP 1
    set lineP 1
    if {[info exists state(parts)]} {
	return [set state(encoding) {}]
    }

    if {[set current [$chan tell]] < 0} {
	makeseekable $token
	set current [$chan tell]
    }
    set chanconfig [$chan configure]
    try {
	set buf {}
	set dataend 0
	while {[set data [$chan read 8192]] ne {} || $buf ne {}} {
	    if {$data eq {}} {
		set dataend 1
	    }
	    set data $buf[set buf {}]$data[set data{}]
	    set lines [split $data \n]
	    if {!$dataend} {
		set buf [lindex $lines end]
		set lines [lrange $lines[set lines {}] 0 end-1]
	    }
	    if {[llength $lines]} {
		if {$asciiP} {
		    set asciiP [encodingasciiP $lines]
		}
		if {$lineP} {
		    set lineP [encodinglineP $lines]
		}
		if {(!$asciiP) && (!$lineP)} {
		    break
		}
	    }
	}
    } finally {
	$chan configure {*}$chanconfig
	$chan seek 0
    }

    switch -glob $content {
        text/* {
            if {!$asciiP} {
                #TODO: this path is not covered by tests
		if {[dict exists $params charset]} {
		    set v [string tolower [dict get $params $charset]]
		    if {($v ne {us-ascii}) \
			    && (![string match {iso-8859-[1-8]} $v])} {
			return [set state(encoding) base64]
		    }
		}
            }

            if {!$lineP} {
                return [set state(encoding) quoted-printable]
            }
        }


        default {
            if {(!$asciiP) || (!$lineP)} {
                return [set state(encoding) base64]
            }
        }
    }
    return [set state(encoding) {}]
}

# ::mime::encodingasciiP --
#
#     Checks if a string is a pure ascii string, or if it has a non-standard
#     form.
#
# Arguments:
#       line    The line to check.
#
# Results:
#       Returns 1 if \r only occurs at the end of lines, and if all
#       characters in the line are between the ASCII codes of 32 and 126.

proc ::mime::encodingasciiP lines {
    foreach line $lines {
	set firstr [string first \r $line]]
	if {
	    $firstr > 0 && $first != [string length $line]
	} {
	    return 0
	}
	foreach c [split $line {}] {
	    switch $c {
		{ } - \t - \r - \n {
		}

		default {
		    binary scan $c c c
		    if {($c < 32) || ($c > 126)} {
			return 0
		    }
		}
	    }
	}
    }
    return 1
}

# ::mime::encodinglineP --
#
#     Checks if a string is a line is valid to be processed.
#
# Arguments:
#       line    The line to check.
#
# Results:
#       Returns 1 the line is less than 76 characters long, the line
#       contains more characters than just whitespace, the line does
#       not start with a '.', and the line does not start with 'From '.

proc ::mime::encodinglineP lines {
    foreach line $line {
	if {([string length $line] > 76) \
		|| ($line ne [string trimright $line]) \
		|| ([string first . $line] == 0) \
		|| ([string first {From } $line] == 0)} {
	    return 0
	}
    }
    return 1
}


proc ::mime::contentid token {
    upvar 0 $token state
    upvar 0 state(parts) parts
    parsepart $token
    if {[info exists parts]} {
	foreach part $parts {
	    # use message-id here, not content-id, to account for header info
	    # in the parts
	    append ids [header get $part message-id] 
	}
	set id [::sha2::sha256 -hex $ids]
    } else {
	set chan [body decoded $token]
	set config [$chan configure]
	if {[dict exists $config -chan]} {
	    dict unset config -chan
	}
	try {
	    $chan seek 0
	    set id [::sha2::sha256 -hex -channel [$chan configure -chan]]
	    $chan seek 0
	} finally {
	    $chan configure {*}$config
	}
    }
    return $id@|
}


proc ::mime::dropchan token {
    variable channels
    upvar 0 $token state
    upvar 0 state(fd) fd

    if {[info exists fd]} {
	if {[incr channels($fd) -1] == 0} {
	    unset channels($fd)
	    if {$state(closechan)} {
		$fd close
	    }
	}
	unset state(fd)
    }
}


# ::mime::finalize --
#
#   mime::finalize destroys a MIME part.
#
#   If the -subordinates option is present, it specifies which
#   subordinates should also be destroyed. The default value is
#   "dynamic".
#
# Arguments:
#       token  The MIME token to parse.
#       args   Args can be optionally be of the following form:
#              ?-subordinates "all" | "dynamic" | "none"?
#
# Results:
#       Returns an empty string.

proc ::mime::finalize {token args} {
    # FRINK: nocheck
    upvar 0 $token state
    array set options [list -subordinates dynamic]
    array set options $args

    switch $options(-subordinates) {
        all {
            #TODO: this code path is untested
            if {[info exists state(parts)]} {
                foreach part $state(parts) {
                    eval [linsert $args 0 mime::finalize $part]
                }
            }
        }

        dynamic {
            for {set cid $state(cid)} {$cid > 0} {incr cid -1} {
                eval [linsert $args 0 mime::finalize $token-$cid]
            }
        }

        none {
        }

        default {
            error "unknown value for -subordinates $options(-subordinates)"
        }
    }

    dropchan $token

    if {$state(bodychan) ne {}} {
	if {[$state(bodychan) configure -chan] in [chan names]} {
	    rename $state(bodychan) {}
	}
    }

    if {[info exists state(bodychandecoded)]} {
	rename $state(bodychandecoded) {}
    }

    foreach name [array names state] {
        unset state($name)
    }
    # FRINK: nocheck
    unset $token
}


proc ::mime::messageid token {
    upvar 0 $token state
    #set unique [uniqueID]
    if {![header exists $token content-id] && $state(addcontentid)} {
	header::setinternal $token Content-ID [contentid $token]
    }
    set sha [::sha2::SHA256Init]
    foreach {key val} [lsort -stride 2 [header::get $token]] {
	lassign $val value params
	::sha2::SHA256Update $sha $key$value
	foreach {pkey pval} $params {
	    ::sha2::SHA256Update $sha $pkey$pval
	}
    }
    set hash [::sha2::SHA256Final $sha]
    binary scan $hash H* hex
    return $hex@|
}

# ::mime::mimegets --
#
#    like [gets] but does not run over multipart boundaries
#
#    only needed during the parsing stage, since after that the content of each
#    part is in a separate file
#
# Arguments:
#       token      The MIME token to parse.
#
# Results:
#       Returns the size in bytes of the MIME token.
proc ::mime::mimegets {token varname} {
    upvar 0 $token state
    upvar 0 state(boundary) boundary state(eof) eof
    upvar 1 $varname line
    if {$eof} {
	set line {}
	return -1
    }
    set res [$state(fd) gets line]
    if {$res == -1} {
	set eof 1
	set line {}
	return -1
    } else {
	set found [string first --$boundary $line]
	if {$found == 0} {
	    if {[string first --$boundary-- $line] >= 0} {
		set state(sawclosing) 1
		set eof 1
	    }
	    set line {}
	    return -1 
	}
	return $res
    }
}

# ::mime::getsize --
#
#    Determine the size (in bytes) of a MIME part/token
#
# Arguments:
#       token      The MIME token to parse.
#
# Results:
#       Returns the size in bytes of the MIME token.

proc ::mime::getsize token {
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(bodychan) bodychan state(fd) inputchan 

    parsepart $token

    if {[info exists state(parts)]} {
	set size 0
	foreach part $state(parts) {
	    incr size [getsize $part]
	}
    } else {
	set size 0
	if {$state(canonicalP)} {
	    if {[set current [$inputchan tell]] < 0} {
		makeseekable $token
	    }
	    set current [$inputchan tell]
	    $inputchan seek 0 end
	    set size [$inputchan tell]
	    $inputchan seek $current
	} else {
	    set size $state(size)
	}
    }
    # no longer needed since size is calculated during parsing
    #if {$state(encoding) eq {base64}} {
    #    set size [expr {($size * 3 + 2) / 4}]
    #}
    return $size
}


proc ::mime::getTransferEncoding token {
    upvar 0 $token state
    set encoding [encoding $token]
    # See also issues [#477088] and [#539952]
    switch $encoding {
	base64 - quoted-printable  - 7bit - 8bit - binary - {} {
	}
	default {
	    error [list {Can't handle content encoding} $encoding]
	}
    }
    return $encoding
}


namespace eval ::mime::header {
    namespace ensemble create -map {
	get get
	exists exists
	parse parse
	set set_
	serialize serialize
	setinternal setinternal
    }

    variable tchar
    # hypen is first for inclusion in brackets
    variable tchar_re {-!#$%&'*+.^`|~0-9A-Za-z}
    variable token_re "^(\[$tchar_re]*)\\s*(?:;|$)?"
    variable notattchar_re "\[^[string map {* {} ' {} % {}} $tchar_re]]"

    # RFC 2045 lexemes
    variable typetokenL
    lappend typetokenL \; , < > : ? ( ) @ \" \[ ] = / \\
    variable typelexemeL {
        LX_SEMICOLON LX_COMMA
        LX_LBRACKET  LX_RBRACKET
        LX_COLON     LX_QUESTION
        LX_LPAREN    LX_RPAREN
        LX_ATSIGN    LX_QUOTE
        LX_LSQUARE   LX_RSQUARE
        LX_EQUALS    LX_SOLIDUS
        LX_QUOTE
    }

    variable internal 0
}


proc ::mime::header::boundary {} {
    return [uniqueID]
}


# ::mime::dunset --
#
#   Unset all values for $key, without "normalizing" other redundant keys
proc ::mime::header::dunset {dictname key} {
    upvar 1 $dictname dict
    set dict [join [lmap {key1 val} $dict[set dict {}] {
	if {$key1 eq $key} continue
	list $key1 $val
    }]]
}


proc ::mime::header::exists {token name} {
    upvar 0 $token state
    set lname [string tolower $name]
    expr {[dict exists $state(headerlower) $lname]
		|| [dict exists $state(headerinternallower) $lname]
		|| [dict exists $state(contentidlower) $lname]
		|| [dict exists $state(messageidlower) $lname]
    }
}


# ::mime::header get --
#
#    Returns the header of a message as a multidict where each value is a list
#    containing the header value and a dictionary parameters for that header.

#    If $key is provided, returns only the value and paramemters of the last
#    maching header, without regard for case. 
#
#    If -names is specified, a list of all header names is returned.
#

proc ::mime::header::get {token {key {}}} {
    # FRINK: nocheck
    upvar 0 $token state
    parse $token

    set contentid $state(contentid)
    set contentidlower $state(contentidlower)
    set header $state(header)
    set headerlower $state(headerlower)
    set headerinternal $state(headerinternal)
    set headerinternallower $state(headerinternallower)
    set messageid $state(messageid) 
    set messageidlower $state(messageidlower)
    switch $key {
	{} {
	    set result [list {*}$messageid {*}$contentid {*}$headerinternal \
		{*}$header]
	    if {![dict exists $headerlower content-transfer-encoding]
		&& !$state(canonicalP)} {
		set tencoding [getTransferEncoding $token]
		if {$tencoding ne {}} {
		    lappend result Content-Transfer-Encoding [list $tencoding {}]
		}
	    }
	    return $result
	}

	-names {
	    return [dict keys $header]
	}

	default {
	    set lower [string tolower $key]

	    switch $lower {
		content-id {
		    if {![dict size $contentidlower]} {
			contentid $token
		    }
		    return [dict get $contentidlower content-id]
		}
		content-transfer-encoding {
		    if {[dict exists $headerinternallower $lower]} {
			return [dict get $headerinternallower $lower]
		    } elseif {!$state(canonicalP)} {
			return [list [getTransferEncoding $token] {}]
		    } else {
			error [list {no such header} $key]
		    }
		}
		message-id {
		    if {![dict size $messageidlower]} {
			setinternal $token Message-ID [
			    [namespace parent]::messageid $token]
		    }
		    return [dict get $messageidlower message-id]
		}
		mime-version {
		    return [list $state(version) {}]
		}
		default {
		    set res {}
		    if {[dict exists $headerinternallower $lower]} {
			return [dict get $headerinternallower $lower]
		    } elseif {[dict exists $headerlower $lower]} {
			return [dict get $headerlower $lower]
		    } else {
			error [list {no such header} $key]
		    }
		}
	    }
	}
    }
}


proc ::mime::header::parse token {
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(fd) fd state(boundary) boundary
    if {$state(canonicalP) || $state(headerparsed)} {
	return
    }
    set state(headerparsed) 1

    if {[info exists boundary]} {
	set gets [list [namespace parent]::mimegets $token line]
    } else {
	set gets [list $fd gets line]
    }

    set vline {}
    while 1 {
	set blankP 0
	set x [{*}$gets]
	if {$x <= 0} {
	    set blankP 1
	}

	# to do 2018-11-13: probably remove this now that line translation
	# happens automatically,
	if {!$blankP && [string match *\r $line]} {
	    set line [string range $line 0 $x-2]
	    if {$x == 1} {
		set blankP 1
	    }
	}

	# there is a space and a tab between the brackets in next line
        if {!$blankP && [string match {[ 	]*} $line]} {
            append vline { } [string trimleft $line " \t"]
            continue
        }

        if {$vline eq {}} {
            if {$blankP} {
                break
            }

            set vline $line
            continue
        }

        if {
	    [set x [string first : $vline]] <= 0
	    ||
	    [set mixed [string trimright [
		string range $vline 0 [expr {$x - 1}]]]] eq {}
	} {
            error [list {improper line in header} $vline]
        }
        set value [string trim [string range $vline [expr {$x + 1}] end]]

        switch [set lower [string tolower $mixed]] {
	    content-disposition {
		set_ $token $mixed {*}[parseparts $token $value]
	    }

	    content-id {
		setinternal $token $mixed $value
	    }

            content-type {
                if {[exists $token content-type]} {
                    error [list {multiple Content-Type fields starting with} \
			$vline]
                }

                set x [parsetype $token $value]
		setinternal $token Content-Type {*}$x
            }

            content-md5 {
            }

            content-transfer-encoding {
                if {
		    $state(encoding) ne {}
		    &&
		    $state(encoding) ne [string tolower $value]
		} {
                    error [list [list multiple Content-Transfer-Encoding \
			fields starting with] $vline]
                }

                set state(encoding) [string tolower $value]
            }

            mime-version {
                set state(version) $value
            }

            default {
		set_ $token $mixed $value -mode append
            }
        }

        if {$blankP} {
            break
        }
        set vline $line
    }
}


proc ::mime::header::parseparams token {
    # FRINK: nocheck
    upvar 0 $token state
    set params {}

    while 1 {
        switch [parselexeme $token] {
            LX_END {
		return [processparams $params[set params {}]]
            }

	    LX_SEMICOLON {
		if {[dict size $params]} {
		    continue
		} else {
		    error [list {expecting attribute} not $state(buffer)]
		}
	    }

            LX_ATOM {
            }

            default {
                error [list {expecting attribute} not $state(buffer)]
            }
        }

        set attribute [string tolower $state(buffer)]

        if {[parselexeme $token] ne {LX_EQUALS}} {
            error [list expecting = found  $state(buffer)]
        }

        switch [parselexeme $token] {
            LX_ATOM {
            }

            LX_QSTRING {
                set state(buffer) [
                    string range $state(buffer) 1 [
                        expr {[string length $state(buffer)] - 2}]]
		set state(buffer) [unquote $state(buffer)]
            }

            default {
                error [list expecting value found $state(buffer)]
            }
        }
        dict set params $attribute $state(buffer)
    }
}


proc ::mime::header::parseparts {token value} {
    variable token_re
    upvar 0 $token state

    if {![regexp $token_re $value match type]} {
	error [list {expected disposition-type}]
    }

    variable typetokenL
    variable typelexemeL

    set value [string range $value[set value {}] [string length $match] end]

    set state(input)   $value
    set state(buffer)  {}
    set state(lastC)   LX_END
    set state(comment) {}
    set state(tokenL)  $typetokenL
    set state(lexemeL) $typelexemeL

    set code [catch {parseparams $token} result copts]

    unset {*}{
	state(input)
	state(buffer)
	state(lastC)
	state(comment)
	state(tokenL)
	state(lexemeL)
    }

    return -options $copts [list $type $result]
}


# ::mime::header::parsetype --
#
#       Parses the string passed in and identifies the content-type and
#       params strings.
#
# Arguments:
#       token  The MIME token to parse.
#       string The content-type string that should be parsed.
#
# Results:
#       Returns the content and params for the string as a two element
#       tcl list.

proc ::mime::header::parsetype {token string} {
    # FRINK: nocheck
    upvar 0 $token state

    variable typetokenL
    variable typelexemeL

    set state(input)   $string
    set state(buffer)  {}
    set state(lastC)   LX_END
    set state(comment) {}
    set state(tokenL)  $typetokenL
    set state(lexemeL) $typelexemeL

    catch {parsetypeaux $token} result copts

    unset {*}{
	state(input)
	state(buffer)
	state(lastC)
	state(comment)
	state(tokenL)
	state(lexemeL)
    }

    return -options $copts $result
}


# ::mime::header::parsetypeaux --
#
#       A helper function for mime::parsetype.  Parses the specified
#       string looking for the content type and params.
#
# Arguments:
#       token  The MIME token to parse.
#       string The content-type string that should be parsed.
#
# Results:
#       Returns the content and params for the string as a two element
#       tcl list.

proc ::mime::header::parsetypeaux token {
    # FRINK: nocheck
    upvar 0 $token state
    set params {}

    if {[parselexeme $token] ne {LX_ATOM}} {
        error [list expecting type found $state(buffer)]
    }
    set type [string tolower $state(buffer)]

    switch [parselexeme $token] {
        LX_SOLIDUS {
        }

        LX_END {
            if {$type ne {message}} {
                error [list expecting type/subtype found $type]
            }

            return [list message/rfc822 {}]
        }

        default {
            error [list expecting / found  $state(buffer)]
        }
    }

    if {[parselexeme $token] ne {LX_ATOM}} {
        error [list expecting subtype found $state(buffer)]
    }
    append type [string tolower /$state(buffer)]

    switch [parselexeme $token] {
	LX_END {
	}

	LX_SEMICOLON {
	    set params [parseparams $token]
	}

	default {
	    error [list expecting  {;  or end} found $state(buffer)]
	}
    }

    list $type $params
}


proc ::mime::header::processparams params {
    set info {}
    foreach key [lsort -dictionary [dict keys $params]] {
	set pvalue [dict get $params $key]
	# a trailing asterisk is ignored if this is not the first field in an
	# identically-named series

	# this expression can't fail
	regexp {^([^*]+?)(?:([*])([0-9]+))?([*])?$} $key -> name star1 counter star2
	dict update info $name dict1 {
	    if {![info exists dict1]} {
		set dict1 {}
	    }
	    dict update dict1 encoding encoding value value {
		if {$star1 ne {}} {
		    if {$star2 ne {} || $counter eq {}} {
			if {![regexp {^([^']*)'([^']*)'(.*)$} $pvalue \
			    -> charset lang pvalue]} {

			    error [list [list malformed language information in \
				extended parameter name]]
			}
			if {$charset ne {}} {
			    set encoding [reversemapencoding $charset]
			}
		    }
		}
		append value $pvalue
	    }
	}
    }

    set params {}
    dict for {key pinfo} $info[set info {}] {
	dict update pinfo encoding encoding value value {}
	if {[info exists encoding]} {
	    set value [string map {% {\x}} $value[set value {}]]
	    set value [subst -novariables -nocommands $value[set value {}]]
	    set value [::encoding convertfrom $encoding $value]
	}
	dict set params $key $value
    }
    return $params
}


proc ::mime::header::serialize {token name value params} {
    variable notattchar_re
    set lname [string tolower $name]

    # to do: check key for conformance
    # to do: properly quote/process $value for interpolation
    if {[regexp {[^\x21-\x39\x3b-\x7e]} $name]} {
	error [
	    list {non-printing character or colon character in header name} $name]
    }
    if {[regexp {[^\t\x20-\x7e]} $value]} {
	error [
	    list {non-printing character in header value}]
    }

    switch $lname {
	content-id - message-id {
	    set value <$value>
	}
    }

    set res "$name: $value"

    dict for {key value} $params {
	if {[regexp $notattchar_re $key]} {
	    error [list {illegal character found in attribute name}]
	}
	set len [expr {[string length $key]} + 1 + [string length $value]]
	# save one byte for the folding white space continuation space
	# and two bytes for "; "
	if {$len > 73 || ![regexp {[^-!#$%&'*+,.\w`~^@{}|]+$} $value]} {
	    # save two bytes for the quotes
	    if {$len <= 71 && ![regexp {[^\x20-\x7e]} $value]} {
		set value "[string map [list \\ \\\\ \" \\\"] $value[set value {}]]"
		append res "\n\t; $key=$value"
	    } else {
		set value [::encoding convertto utf-8 $value]

		regsub -all -- $notattchar_re $value {[format %%%02X [scan "\\&" %c]]} value
		set value [subst -novariables $value]

		set partnum 0
		set start 0
		set param $key*$partnum*=utf-8''
		while {$start < [string length $value]} {
		    # subtract one from the limit to ensure that at least one byte
		    # is included in the part value
		    if {[string length $param] > 72} {
			error [list {parameter name is too long}]
		    }
		    set end [expr {$start + 72 - [string length $param]}]
		    set part [string range $value $start $end]
		    incr start [string length $part]
		    append res "\n\t; $param$part"
		    set param $key*$partnum=
		    incr partnum
		}
	    }
	} else {
	    append res "\n\t; $key=$value"
	}
    }
    return $res
}


# ::mime::header::set --
#
#    mime::header::set writes, appends to, or deletes the value associated
#    with a key in the header.
#
#    The value for -mode is one of:
#
#       write: the key/value is either created or overwritten (the
#       default);
#
#       append: a new value is appended for the key (creating it as
#       necessary); or,
#
#       delete: all values associated with the key are removed (the
#       "value" parameter is ignored).
#
#    Regardless, mime::setheader returns the previous value associated
#    with the key.
#
# Arguments:
#       token      The MIME token to parse.
#       key        The name of the key whose value should be set.
#       value      The value for the header key to be set to.
#       args       An optional argument of the form:
#                  ?-mode "write" | "append" | "delete"?
#
# Results:
#       Returns previous value associated with the specified key.

proc ::mime::header::set_ {token key value args} {
    variable internal
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 \
	state(contentid) contentid \
	state(contentidlower) contentidlower \
	state(header) header \
	state(headerinternal) headerinternal \
	state(headerinternallower) headerinternallower \
	state(headerlower) headerlower \
	state(messageid) messageid \
	state(messageidlower) messageidlower
    parse $token

    set params {}
    switch [llength $args] {
	1 - 3 {
	    set args [lassign $args[set args {}] params]
	}
	0 - 2 {
	    # carry on
	}
	default {
	    error [list {wrong # args}]
	}
    }
    array set options [list -mode write]
    array set options {}
    dict for {opt val} $args {
	switch $opt {
	    -mode {
		set options($opt) $val
	    }
	    default {
		error [list {unknon option} $opt]
	    }
	}
    }

    set lower [string tolower $key]
    set result {}
    switch $options(-mode) {
	append - write {
	    switch $lower {
		content-md5
		    -
		content-transfer-encoding
		    -
		mime-version
		    -
		content-type {
		    if {!$internal} {
			switch $lower {
			    default {
				if {[exists $token $lower]} {
				    lassign [get $token $lower] values params1
				    if {$value ni $values} {
					error "key $key may not be set"
				    }
				}
			    }
			}
		    }
		    switch $lower {
			content-type {
			    if {[string match multipart/* $value]
				&&
				![dict exists $params boundary]
			    } {
				dict set params boundary [boundary]
			    }
			}
			default {
			    #carry on
			}
		    }
		}
	    }
	    if {$options(-mode) eq {write}} {
		if {[dict exists $header $key]} {
		    dunset header $key
		}
		if {[dict exists $headerlower $lower]} {
		    dunset headerlower $lower
		}

		if {[dict exists headerinternal $key]} {
		    dunset headerinternal $key
		}
		if {[dict exists $headerinternallower $lower]} {
		    dunset headerinternallower $lower
		}

	    }
	    set newval [list $value $params]
	    if {$internal} {
		switch $lower {
		    content-id {
			lappend contentid $key $newval 
			lappend contentidlower $lower $newval 
		    }
		    message-id {
			lappend messageid $key $newval 
			lappend messageidlower $lower $newval 
		    }
		    default {
			lappend headerinternal $key $newval 
			lappend headerinternallower $lower $newval 
		    }
		}
	    } else {
		lappend header $key $newval 
		lappend headerlower $lower $newval 
	    }
	}
        delete {
            dunset headerlower $lower
	    dunset headerinternallower $lower
	    dunset header $key
	    dunset headerinternal $key
        }

        default {
            error "unknown value for -mode $options(-mode)"
        }
    }

    return $result
}


proc ::mime::header::setinternal args {
    variable internal 1
    try {
	set_ {*}$args
    } finally {
	set internal 0
    }
}

proc ::mime::header::dset {name key val} {
    if {[dict exists $name]} {
	set name [lsearch
    }
}


# ::mime::initialize --
#
#    the public interface for initializeaux

proc ::mime::initialize args {
    variable mime

    set token [namespace current]::[incr mime(uid)]
    # FRINK: nocheck
    upvar 0 $token state

    if {[catch {uplevel 1 [
	list mime::initializeaux $token {*}$args]} result eopts]} {
        catch {mime::finalize $token -subordinates dynamic}
        return -options $eopts $result
    }
    return $token
}

# ::mime::initializeaux --
#
#    Creates a MIME part, and returnes the MIME token for that part.
#
# Arguments:
#    args   Args can be any one of the following:
#                  ?-canonical type/subtype
#                  ?-params    {?key value? ...}
#                  ?-encoding value?
#                  ?-headers   {?key value? ...}
#                  ?-spec   ?mime | http? 
#                  (-chan value | -parts {token1 ... tokenN})
#
#       If the -canonical option is present, then the body is in
#       canonical (raw) form and is found by consulting either the,
#       -chan, or -parts option.
#
#       -header
#           a dictionary of headers
#               with possibliy-redundant keys
#
#       -params
#           a dictionary of parameters
#           with possibly-redundant keys
#
#
#       Also, -encoding, if present, specifies the
#       "Content-Transfer-Encoding" when copying the body.
#
#       If the -canonical option is not present, then the MIME part
#       contained in -chan option is parsed,
#       dynamically generating subordinates as appropriate.
#
# Results:
#    An initialized mime token.


proc ::mime::initializeaux {token args} {
    variable channels
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(canonicalP) canonicalP state(params) params \
	state(relax) relax

    set ipnuts 0

    set params {}

    set state(addcontentid) 1
    set state(addmessageid) 1
    set state(addmimeversion) 1

    # contains the decoded message body 
    set state(bodychan) {}
    set state(bodydecoded) 0
    set state(bodyparsed) 0
    set canonicalP 0
    set state(cid) 0
    set state(closechan) 1
    set state(contentid) {}
    set state(contentidlower) {}
    set state(encoding) {}
    set state(encodingdone) 0
    set state(eof) 0
    set state(header) {}
    set state(headerinternal) {}
    set state(headerinternallower) {}
    set state(headerlower) {}
    set state(headerparsed) 0
    set state(isstring) 0 
    set relax [dict create finalboundary 0]
    set state(messageid) {}
    set state(messageidlower) {}
    set state(root) $token
    set state(sawclosing) 0
    set state(spec) mime
    set state(size) 0
    set state(usemem) 0 
    set state(version) 1.0

    set userparams 0

    set argc [llength $args]
    for {set argx 0} {$argx < $argc} {incr argx} {
        set option [lindex $args $argx]
        if {[incr argx] >= $argc} {
            error "missing argument to $option"
        }
        set value [lindex $args $argx]

        switch $option {
	    -addcontentid {
		set state(addcontentid) [expr {!!$value}]
	    }
	    -addmessageid {
		set state(addmessageid) [expr {!!$value}]
	    }
	    -addmimeversion {
		set state(addmimeversion) [expr {!!$value}]
	    }
	    -boundary {
		set state(boundary) $value
	    }
            -canonical {
		set canonicalP 1
		set type [string tolower $value]
            }
	    -chan {
		checkinputs
		addchan $token [uplevel 1 [list namespace which $value]]
	    }

	    -close {
		set state(closechan) [expr {!!$value}]
	    }

            -encoding {
		set value [string tolower $value[set value {}]]

                switch $value {
                    7bit - 8bit - binary - quoted-printable - base64 {
                    }

                    default {
                        error "unknown value for -encoding $state(encoding)"
                    }
                }
                set state(encoding) [string tolower $value]
            }

	    -file {
		checkinputs
		addchan $token [tcllib::chan::base .new [
		    info cmdcount]_chan [open $value]]
	    }

            -headers {
		# process headers later in order to assure that content-id and
		# content-type occur first
		if {[info exists headers]} {
		    error [list {-headers option occurred more than once}]
		}
                if {[llength $value] % 2} {
                    error [list -headers expects a dictionary]
                }
		set headers $value
            }

            -params {
		if {$userparams} {
		    error [list {-params can only be provided once}]
		}
		set userparams 1
                if {[llength $value] % 2} {
		    error [list -params expects a dictionary]
                }
		foreach {mixed pvalue} $value {
		    set lower [string tolower $mixed]
		    if {[dict exists params $lower]} {
			error "the $mixed parameter may be specified at most once"
		    }

		    dict set params $lower $pvalue
		}
            }

            -parts {
		checkinputs
		set canonicalP 1
                set state(parts) $value
            }

	    -relax {
		relax $token $value 1 
	    }

            -root {
                # the following are internal options
                set state(root) $value
            }

	    -spec {
		switch $value {
		    http {
			set state(addcontentid) 0
			set state(addmimeversion) 0
			set state(addmessageid) 0
			set state(spec) http
		    }
		    mime {
			set state(addcontentid) 1
			set state(addmimeversion) 1
			set state(spec) mime
		    }
		    default {
			error [list {unknown protocol}]
		    }
		}
	    }

	    -strict {
		relax $token $value [expr {!$value}]
	    }

	    -string {
		checkinputs
		addchan $token [tcllib::chan::base .new [
		    info cmdcount]_chan [::tcl::chan::string $value]]
	    }

	    -usemem {
		set state(usemem) [expr {!!$value}] 
	    }

            default {
                error [list {unknown option} $option]
            }
        }
    }

    if {![info exists inputs]} {
	error [list {specify exactly one of} {-chan -file -parts -string}]
    }

    if {$canonicalP} {
        if {![header exists $token content-id] && $state(addcontentid)} {
	    header::setinternal $token Content-ID [contentid $token]
        }

	if {![info exists type]} {
	    set type multipart/mixed
	}

	header setinternal $token Content-Type $type $params

	if {[info exists headers]} {
	    foreach {name hvalue} $headers {
		set lname [string tolower $name]
		if {$lname eq {content-type}} {
		    error [list {use -canonical instead of -headers} $hkey $name]
		}
		if {$lname eq {content-transfer-encoding}} {
		    error [list {use -encoding instead of -headers} $hkey $name]
		}
		if {$lname in {content-md5 mime-version}} {
		    error [list {don't go there...}]
		}
		header::setinternal $token $name $hvalue
	    }
	}

	lassign [header get $token content-type] content dummy

	if {[info exists state(parts)]} {
	    switch -glob $content {
		text/*
		    -
		image/*
		    -
		audio/*
		    -
		video/* {
		    error "-canonical $content and -parts do not mix"
		}

		default {
		    if {$state(encoding) ne {}} {
			error "-encoding and -parts do not mix"
		    }
		}
	    }
	}

        set state(version) 1.0
        return
    }

    if {[dict size $params]} {
        error "-param requires -canonical"
    }
    if {$state(encoding) ne {}} {
        error "-encoding requires -canonical"
    }
    if {[info exists headers]} {
        error "-header requires -canonical"
    }

}


proc mime::makeseekable token {
    upvar 0 $token state
    upvar 0 state(bodychan) bodychan state(fd) inputchan 
    set chan2 [::tcllib::chan::base [info cmdcount]_chan [file tempfile]]
    chan configure $chan2 -translation binary
    chan copy $inputchan $chan2
    incr size [tell $chan2]
    seek $chan2 0
    close $inputchan
    set inputchan [::tcllib::chan::base [info cmdcount]_chan $chan2]
    return
}


# ::mime::mapencoding --
#
#    mime::mapencodings maps tcl encodings onto the proper names for their
#    MIME charset type.  This is only done for encodings whose charset types
#    were known.  The remaining encodings return {} for now.
#
# Arguments:
#       enc      The tcl encoding to map.
#
# Results:
#    Returns the MIME charset type for the specified tcl encoding, or {}
#       if none is known.

proc ::mime::mapencoding {enc} {

    variable encodings

    if {[info exists encodings($enc)]} {
        return $encodings($enc)
    }
    return {}
}

# ::mime::parsepart --
#
#       Parses the MIME headers and attempts to break up the message
#       into its various parts, creating a MIME token for each part.
#
# Arguments:
#       token  The MIME token to parse.
#
# Results:
#       Throws an error if it has problems parsing the MIME token,
#       otherwise it just sets up the appropriate variables.

proc ::mime::parsepart token {
    upvar 0 $token state
    if {$state(canonicalP) || $state(bodyparsed)} {
	return
    }
    set state(bodyparsed) 1
    parsepartaux $token
}


proc ::mime::parsepartaux token {
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(bodychan) bodychan state(eof) eof \
	state(fd) fd state(size) size state(usemem) usemem state(relax) relax

    header parse $token

    # although rfc 2045 5.2 defines a default treatment for content without a
    # type, don't automatically add an explicit content-type field

    #if {![header exists $token content-type]} {
    #    # rfc 2045 5.2
    #    header setinternal $token Content-Type text/plain [
    #        dict create charset us-ascii]
    #}

    lassign [contenttype $token] content params

    if {$usemem} {
	set bodychan [tcllib::chan::base .new [info cmdcount]_bodychan [
	    ::tcl::chan::memchan]]
    } else {
	set bodychan [tcllib::chan::getslimit .new [info cmdcount]_bodychan [
	    file tempfile]]
    }
    if {[dict exists $params charset]} {
	set charset [reversemapencoding [dict get $params charset]]
	if {$charset eq {}} {
	    puts stderr [list {unknown charset} [
		dict get $params charset] {using binary translation instead}]
	    # but still do line automatic translation
	    $fd configure -encoding binary -translation auto
	} else {
	    $fd configure -encoding [reversemapencoding [dict get $params charset]]
	}
    }
    $bodychan configure -translation binary

    if {[info exists state(boundary)]} {
	set gets [list mimegets $token line]
	set iseof {$eof}
    } else {
	set gets [list $fd gets line]
	set iseof {[$fd eof] || $eof}
    }

    if {[string match multipart/* $content]} {
	set state(parts) {}

	dict update params boundary boundary {}
	if {![info exists state(boundary)]} {
	    if {![info exists boundary]} {
		error "boundary parameter is missing in $content"
	    }

	    if {[string trim $boundary] eq {}} {
		error "boundary parameter is empty in $content"
	    }
	}

	while 1 {
	    if $iseof {
		break
	    }
	    if {![llength $state(parts)]} {
		set x [{*}$gets]
		if {$x == -1} {
		    break
		}
	    }
	    if {[string first --$boundary-- $line] >= 0} {
		    # No starting boundary was seen prior to the terminating boundary.
		    # Interpret this to mean there are no more parts, and also attempt
		    # to make a part from data already seen.

		    # Covered by by test case mime-3.7, using  "badmail1.txt".

		    set state(sawclosing) 1

		    $bodychan puts $line
		    $bodychan seek 0

		    # FRINK: nocheck
		    variable [set child $token-[incr state(cid)]]

		    mime::initializeaux $child -chan $bodychan \
			-root $state(root) -boundary $boundary -usemem $usemem
		    parsepart $child
		    
		    lappend state(parts) $child
		    header setinternal $child Content-Type application/octet-stream
		    break
	    } elseif {[llength $state(parts)] || [string first --$boundary $line] == 0} {
		    # either just saw the first boundary or saw a boundary between parts

		    # do not brace this expression 
		    if $iseof {
			# either saw the closing boundary or reached the end of the file
			break
		    } elseif {[string first --$boundary-- $line] >= 0} {
			set state(sawclosing) 1
			break
		    } else {
			#mimegets returned 0 because it found a border

			# FRINK: nocheck
			variable [set child $token-[incr state(cid)]]


			mime::initializeaux $child -chan $fd \
			    -root $state(root) -boundary $boundary -usemem $usemem
			parsepart $child
			lappend state(parts) $child
			upvar 0 $child childstate
			set state(sawclosing) $childstate(sawclosing)
			if {$childstate(eof)} break
		    }
	    } else {
		# Accumulate data in case the terminating boundary occurs starting
		# boundary was found, so that a part can be generated from data
		# seen so far.
		if $iseof {
		    $bodychan puts -nonewline $line
		} else {
		    $bodychan puts $line
		}
		set size [expr {$size + [
		    string length $line] + 1}]
	    }
	}
	if {!$state(sawclosing) && ![dict get $relax finalboundary]} {
	    error {end-of-string encountered while parsing multipart/form-data}
	}
    } else {
	if {[info exists state(boundary)]} {
	    while 1 {
		set x [{*}$gets]
		if {$x == -1} {
		    break
		} else {
		    if {[incr linesout] > 1} {
			$bodychan puts -nonewline \n$line
		    } else {
			$bodychan puts -nonewline $line
		    }
		    set size [expr {$size + [
			string length $line] + 1}]
		}
	    }
	} else {
	    $fd copy [$bodychan configure -chan]
	    set size [$bodychan tell]
	}
	$bodychan seek 0

        if {[string match message/* $content]} {
            # FRINK: nocheck
	    setencoding $token $bodychan
	    setcharset $token $bodychan
            variable [set child $token-[incr state(cid)]]

	    mime::initializeaux $child -chan $bodychan -usemem $usemem

            set state(parts) $child
	    parsepart $child
        } else {
	    # this is undtrusted data, so keep the getslimit enabled on the
	    # assumption that no one else wants to get hit by a long-line
	    # attack either.
	    #$bodychan configure -getslimit -1
	}
    }
    return
}


# ::mime::property --
#
#   mime::property returns the properties of a MIME part.
#
#   The properties are:
#
#       property    value
#       ========    =====
#       content     the type/subtype describing the content
#       encoding    the "Content-Transfer-Encoding"
#       params      a list of "Content-Type" parameters
#       parts       a list of tokens for the part's subordinates
#       size        the approximate size of the content {before decoding} 
#
#   The "parts" property is present only if the MIME part has
#   subordinates.
#
#   If mime::property is invoked with the name of a specific
#   property, then the corresponding value is returned; instead, if
#   -names is specified, a list of all properties is returned;
#   otherwise, a dictionary of properties is returned.
#
# Arguments:
#       token      The MIME token to parse.
#       property   One of 'content', 'encoding', 'params', 'parts', and
#                  'size'. Defaults to returning a dictionary of
#                  properties.
#
# Results:
#       Returns the properties of a MIME part

proc ::mime::property {token {property {}}} {
    # FRINK: nocheck
    upvar 0 $token state
    parsepart $token

    lassign [contenttype $token] content params

    switch $property {
        {} {
            array set properties [list content  $content \
                                       encoding $state(encoding) \
                                       params   $params \
                                       size     [getsize $token]]
            if {[info exists state(parts)]} {
                set properties(parts) $state(parts)
            }

            return [array get properties]
        }

        -names {
            set names [list content encoding params]
            if {[info exists state(parts)]} {
                lappend names parts
            }
	    lappend nams size

            return $names
        }

        content
            -
        params {
	    return [set $property]
        }

        encoding {
            return $state($property)
	}
        parts {
            if {![info exists state(parts)]} {
                error [list not a multipart message]
            }

            return $state(parts)
        }

        size {
            return [getsize $token]
        }

        default {
            error [list {unknown property} $property]
        }
    }
}


# ::mime::parseaddress --
#
#       This was originally written circa 1982 in C. we're still using it
#       because it recognizes virtually every buggy address syntax ever
#       generated!
#
#       mime::parseaddress takes a string containing one or more 822-style
#       address specifications and returns a list of dictionaries, for each
#       address specified in the argument.
#
#    Each dictionary contains these properties:
#
#       property    value
#       ========    =====
#       address     local@domain
#       comment     822-style comment
#       domain      the domain part (rhs)
#       error       non-empty on a parse error
#       group       this address begins a group
#       friendly    user-friendly rendering
#       local       the local part (lhs)
#       memberP     this address belongs to a group
#       phrase      the phrase part
#       proper      822-style address specification
#       route       822-style route specification (obsolete)
#
#    Note that one or more of these properties may be empty.
#
# Arguments:
#    string        The address string to parse
#
# Results:
#    Returns a list of dictionaries, one element for each address
#       specified in the argument.

proc ::mime::parseaddress {string args} {
    variable mime
    set token [namespace current]::[incr mime(uid)]
    # FRINK: nocheck
    upvar 0 $token state

    if {[llength $args]} {
	set string2 [lindex $args end]
	set args [list $string {*}[lrange $args 0 end-1]]
	set string $string2
    }
    dict for {opt val} $args {
	switch $opt {
	    hostname {
		set state(default_host) $val
	    }
	}
    }

    catch {mime::parseaddressaux $token $string} result copts

    foreach name [array names state] {
        unset state($name)
    }
    # FRINK: nocheck
    catch {unset $token}

    return -options $copts $result
}


# ::mime::parseaddressaux --
#
#       This was originally written circa 1982 in C. we're still using it
#       because it recognizes virtually every buggy address syntax ever
#       generated!
#
#       mime::parseaddressaux does the actually parsing for mime::parseaddress
#
#    Each dictionary contains these properties:
#
#       property    value
#       ========    =====
#       address     local@domain
#       comment     822-style comment
#       domain      the domain part (rhs)
#       error       non-empty on a parse error
#       group       this address begins a group
#       friendly    user-friendly rendering
#       local       the local part (lhs)
#       memberP     this address belongs to a group
#       phrase      the phrase part
#       proper      822-style address specification
#       route       822-style route specification (obsolete)
#
#    Note that one or more of these properties may be empty.
#
# Arguments:
#    token         The MIME token to work from.
#    string        The address string to parse
#
# Results:
#    Returns a list of dictionaries, one for each address specified in the
#    argument.

proc ::mime::parseaddressaux {token string} {
    # FRINK: nocheck
    upvar 0 $token state

    variable addrtokenL
    variable addrlexemeL

    set state(input)   $string
    set state(glevel)  0
    set state(buffer)  {}
    set state(lastC)   LX_END
    set state(tokenL)  $addrtokenL
    set state(lexemeL) $addrlexemeL

    set result {}
    while {[addr_next $token]} {
        if {[set tail $state(domain)] ne {}} {
            set tail @$state(domain)
        } else {
			if {![info exists state(default_host)]} {
				set state(default_host) [info hostname]
			}
            set tail @$state(default_host)
        }
        if {[set address $state(local)] ne {}} {
            #TODO: this path is not covered by tests
            append address $tail
        }

        if {$state(phrase) ne {}} {
            #TODO: this path is not covered by tests
            set state(phrase) [string trim $state(phrase) \"]
            foreach t $state(tokenL) {
                if {[string first $t $state(phrase)] >= 0} {
                    #TODO:  is this quoting robust enough?
                    set state(phrase) \"$state(phrase)\"
                    break
                }
            }

            set proper "$state(phrase) <$address>"
        } else {
            set proper $address
        }

        if {[set friendly $state(phrase)] eq {}} {
            #TODO: this path is not covered by tests
            if {[set note $state(comment)] ne {}} {
                if {[string first ( $note] == 0} {
                    set note [string trimleft [string range $note 1 end]]
                }
                if {
		    [string last ) $note]
                        == [set len [expr {[string length $note] - 1}]]
		} {
                    set note [string range $note 0 [expr {$len - 1}]]
                }
                set friendly $note
            }

            if {
		$friendly eq {}
		&&
		[set mbox $state(local)] ne {}
	    } {
                #TODO: this path is not covered by tests
                set mbox [string trim $mbox \"]

                if {[string first / $mbox] != 0} {
                    set friendly $mbox
                } elseif {[set friendly [addr_x400 $mbox PN]] ne {}} {
                } elseif {
		    [set friendly [addr_x400 $mbox S]] ne {}
                    &&
		    [set g [addr_x400 $mbox G]] ne {}
		} {
                    set friendly "$g $friendly"
                }

                if {$friendly eq {}} {
                    set friendly $mbox
                }
            }
        }
        set friendly [string trim $friendly \"]

        lappend result [list address  $address        \
                             comment  $state(comment) \
                             domain   $state(domain)  \
                             error    $state(error)   \
                             friendly $friendly       \
                             group    $state(group)   \
                             local    $state(local)   \
                             memberP  $state(memberP) \
                             phrase   $state(phrase)  \
                             proper   $proper         \
                             route    $state(route)]

    }

    unset {*}{
	state(input)
	state(glevel)
	state(buffer)
	state(lastC)
	state(tokenL)
	state(lexemeL)
    }

    return $result
}


# ::mime::parselexeme --
#
#    Used to implement a lookahead parser.
#
# Arguments:
#       token    The MIME token to operate on.
#
# Results:
#    Returns the next token found by the parser.

proc ::mime::parselexeme token {
    # FRINK: nocheck
    upvar 0 $token state

    set state(input) [string trimleft $state(input)]

    set state(buffer) {}
    if {$state(input) eq {}} {
        set state(buffer) end-of-input
        return [set state(lastC) LX_END]
    }

    set c [string index $state(input) 0]
    set state(input) [string range $state(input) 1 end]

    if {$c eq {(}} {
        set noteP 0
        set quoteP 0

        while 1 {
            append state(buffer) $c

            #TODO: some of these paths are not covered by tests
            switch $c/$quoteP {
                (/0 {
                    incr noteP
                }

                \\/0 {
                    set quoteP 1
                }

                )/0 {
                    if {[incr noteP -1] < 1} {
                        if {[info exists state(comment)]} {
                            append state(comment) { }
                        }
                        append state(comment) $state(buffer)

                        return [parselexeme $token]
                    }
                }

                default {
                    set quoteP 0
                }
            }

            if {[set c [string index $state(input) 0]] eq {}} {
                set state(buffer) "end-of-input during comment"
                return [set state(lastC) LX_ERR]
            }
            set state(input) [string range $state(input) 1 end]
        }
    }

    if {$c eq "\""} {
        set firstP 1
        set quoteP 0

        while 1 {
            append state(buffer) $c

            switch $c/$quoteP {
                "\\/0" {
                    set quoteP 1
                }

                "\"/0" {
                    if {!$firstP} {
                        return [set state(lastC) LX_QSTRING]
                    }
                    set firstP 0
                }

                default {
                    set quoteP 0
                }
            }

            if {[set c [string index $state(input) 0]] eq {}} {
                set state(buffer) "end-of-input during quoted-string"
                return [set state(lastC) LX_ERR]
            }
            set state(input) [string range $state(input) 1 end]
        }
    }

    if {$c eq {[}} {
        set quoteP 0

        while 1 {
            append state(buffer) $c

            switch $c/$quoteP {
                \\/0 {
                    set quoteP 1
                }

                ]/0 {
                    return [set state(lastC) LX_DLITERAL]
                }

                default {
                    set quoteP 0
                }
            }

            if {[set c [string index $state(input) 0]] eq {}} {
                set state(buffer) "end-of-input during domain-literal"
                return [set state(lastC) LX_ERR]
            }
            set state(input) [string range $state(input) 1 end]
        }
    }

    if {[set x [lsearch -exact $state(tokenL) $c]] >= 0} {
        append state(buffer) $c
        return [set state(lastC) [lindex $state(lexemeL) $x]]
    }

    while 1 {
        append state(buffer) $c

        switch [set c [string index $state(input) 0]] {
            {} - " " - "\t" - "\n" {
                break
            }

            default {
                if {[lsearch -exact $state(tokenL) $c] >= 0} {
                    break
                }
            }
        }

        set state(input) [string range $state(input) 1 end]
    }

    return [set state(lastC) LX_ATOM]
}


# ::mime::reversemapencoding --
#
#    mime::reversemapencodings maps MIME charset types onto tcl encoding names.
#    Those that are unknown return {}.
#
# Arguments:
#       mimeType  The MIME charset to convert into a tcl encoding type.
#
# Results:
#    Returns the tcl encoding name for the specified mime charset, or {}
#       if none is known.

proc ::mime::reversemapencoding mimeType {
    variable reversemap

    set lmimeType [string tolower $mimeType]
    if {[info exists reversemap($lmimeType)]} {
        return $reversemap($lmimeType)
    }
    return {}
}


proc ::mime::relax {token args} {
    upvar 0 $token state
    upvar 0 state(relax) relax
    foreach {key val} $args {
	switch $key {
	    all {
		dict set relax finalboundary 1
	    }
	    finalboundary {
		dict set relax $key [expr {!!$val}]
	    }
	    default {
		error [list {unknown value for -relax} $key {should be one of} {
		    all finalboundary
		}]
	    }
	}
    }
}


# ::mime::serialize --
#
#    Serializes a message to a value or a channel.
#
# Arguments:
#       token      The MIME token to parse.
#       channel    The channel to copy the message to.
#
# Results:
#       Returns nothing unless an error is thrown while the message
#       is being written to the channel.


proc ::mime::serialize {token args} {
    set level 0
    set chan {} 
    dict for {arg val} $args {
	switch $arg {
	    -chan {
		if {$val eq {}} {
		    error [list {chan must not be the empty string}]
		}
		set chan [uplevel 1 [list ::namespace which $val]]
	    }
	    -level {
		set level [expr {$val + 0}]
	    }
	    default {
		error [list {unknown option} $arg]
	    }
	}
    }

    if {$chan eq {}} {
	# FRINK: nocheck
	upvar 0 $token state
	set code [catch {mime::serialize_value $token $level} result copts]
	return -options $copts $result
    } else {
	return [serialize_chan $token $chan $level]
    }
}


proc ::mime::serialize_chan {token channel level} {
    # FRINK: nocheck
    upvar 0 $token state
    upvar 0 state(bodychan) bodychan
    parsepart $token

    set result {}
    if {!$level} {
	$channel puts [header serialize $token MIME-Version $state(version) {}]
    }
    contentid $token
    if {![header exists $token content-id] && $state(addcontentid)} {
	header::setinternal $token Content-ID [contentid $token]
    }
    if {![header exists $token message-id] && $state(addmessageid)} {
	header::setinternal $token Message-ID [messageid $token]
    }

    foreach {name value} [header get $token] {
	$channel puts [header serialize $token $name {*}$value]
    }

    set converter {}
    set encoding {}
    if {![info exists state(parts)]} {
        if {$state(canonicalP)} {
	    set encoding [getTransferEncoding $token]
            if {$encoding ne {}} {
                $channel puts "Content-Transfer-Encoding: $encoding"
            }
        }
    }

    if {[info exists state(error)]} {
        unset state(error)
    }

    if {[info exists state(parts)]} {
	lassign [contenttype $token] content params
	set boundary [dict get $params boundary]

	switch -glob $content {
	    message/* {
		$channel puts {}
		foreach part $state(parts) {
		    mime::serialize_chan $part $channel 1
		    break
		}
	    }

	    default {
		# Note RFC 2046: See serialize_value for details.
		#
		# The boundary delimiter MUST occur at the
		# beginning of a line, i.e., following a CRLF, and
		# the initial CRLF is considered to be attached to
		# the boundary delimiter line rather than part of
		# the preceding part.
		#
		# - The above means that the CRLF before $boundary
		#   is needed per the RFC, and the parts must not
		#   have a closing CRLF of their own. See Tcllib bug
		#   1213527, and patch 1254934 for the problems when
		#   both file/string branches added CRLF after the
		#   body parts.


		foreach part $state(parts) {
		    $channel puts \n--$boundary
		    mime::serialize_chan $part $channel 1
		}
		$channel puts \n--$boundary--
	    }
	}
    } else {
	$channel puts {}
	if {$state(canonicalP)} {
	    set transforms [setencoding $token $channel]
	    $state(fd) seek 0
	    $state(fd) copy [$channel $ chan]
	    while {[incr transforms -1] >= 0} {
		$channel $channel
	    }
	} else {
	    $state(bodychan) seek 0
	    $state(bodychan) copy [$channel $ chan]
	}
    }

    $channel flush

    if {[info exists state(error)]} {
        error $state(error)
    }
}


proc ::mime::serialize_value {token level} {
    set chan [::tcllib::chan::base .new [info cmdcount]_serialize_value [
	tcl::chan::memchan]]
    $chan configure -translation crlf
    serialize_chan $token $chan $level
    $chan seek 0
    $chan configure -translation binary
    set res [$chan read]
    $chan close
    return $res
}


proc ::mime::setencoding {token chan} {
    upvar 0 $token state

    set transforms 0

    if {[info exists state(encoding)]} {
	switch $state(encoding) {
	    base64 {
		package require tcl::transform::base64
		::tcl::transform::base64 [$chan configure -chan]
		incr transforms
	    }
	    quoted-printable {
		package require {tcl transform qp}
		::tcl::transform::qp [$chan configure -chan]
		incr transforms
	    }
	    7bit - 8bit - binary - {} {
		# Bugfix for [#477088]
		# Go ahead, leave chunk alone
	    }
	    default {
		error [list {Can't handle content encoding} $state(encoding)]
	    }
	}
    }
    return $transforms
}

proc ::mime::setcharset {token chan} {
    upvar 0 $token state
    lassign [contenttype $token] content params
    if {[dict exists $params charset]} {
	set mcharset [dict get $params charset]
    } else {
	switch $state(spec) {
	    http {
		set mcharset UTF-8
	    }
	    mime - default {
		# mime
		set mcharset US-ASCII
	    }
	}
    }
    set encoding [reversemapencoding $mcharset]
    if {$encoding eq {}} {
	$chan configure -translation binary
    } else {
	$chan configure -encoding $encoding 
    }
    return
}


# ::mime::uniqueID --
#
#    Used to generate a 'globally unique identifier' for the content-id.
#    The id is built from the pid, the current time, the hostname, and
#    a counter that is incremented each time a message is sent.
#
# Arguments:
#
# Results:
#    Returns the a string that contains the globally unique identifier
#       that should be used for the Content-ID of an e-mail message.

proc ::mime::uniqueID {} {
    set id [base64 -mode encode -- [
	sha2::sha256 -bin [expr {rand()}][pid][clock clicks][array get state]]]
    return $id
}


# ::mime::unquote
#
#    Removes any enclosing quotes and unquotes quoted pairs in a string.
proc ::mime::unquote string {
    set qstring [string match "\"*" $string]
    regsub -all {\\(.)} $string[set string {}] {\1} string 

    # this isn't exactly right because it doesn't validate that a quote at the
    # end of the string wsan't just replaced as part of a quoted pair.
    if {$qstring} {
	regexp {^["]?(.*?)["]?$} $string[set string {}] -> string
	# a quote for vim syntax coloring: "
    }
    return $string
}


# ::mime::word_encode --
#
#    Word encodes strings as per RFC 2047.
#
# Arguments:
#       charset   The character set to encode the message to.
#       method    The encoding method (base64 or quoted-printable).
#       string    The string to encode.
#       ?-charset_encoded   0 or 1      Whether the data is already encoded
#                                       in the specified charset (default 1)
#       ?-maxlength         maxlength   The maximum length of each encoded
#                                       word to return (default 66)
#
# Results:
#    Returns a word encoded string.

proc ::mime::word_encode {charset method string {args}} {

    variable encodings

    if {![info exists encodings($charset)]} {
        error [list {unknown charset} $charset]
    }

    if {$encodings($charset) eq {}} {
        error [list {invalid charset} $charset]
    }

    if {$method ne {base64} && $method ne {quoted-printable}} {
        error [list {unknown method} $method {must be one of} \
	    {base64 quoted-printable}]
    }

    # default to encoded and a length that won't make the Subject header to long
    array set options [list -charset_encoded 1 -maxlength 66]
    array set options $args

    if {$options(-charset_encoded)} {
        set unencoded_string [::encoding convertfrom $charset $string]
    } else {
        set unencoded_string $string
    }

    set string_length [string length $unencoded_string]

    if {!$string_length} {
        return {}
    }

    set string_bytelength [string bytelength $unencoded_string]

    # the 7 is for =?, ?Q?, ?= delimiters of the encoded word
    set maxlength [expr {$options(-maxlength) - [string length $encodings($charset)] - 7}]
    switch -exact $method {
        base64 {
            if {$maxlength < 4} {
                error [list maxlength $options(-maxlength) \
		    {too short for chosen charset and encoding}]
            }
            set count 0
            set maxlength [expr {($maxlength / 4) * 3}]
            while {$count < $string_length} {
                set length 0
                set enc_string {}
                while {$length < $maxlength && $count < $string_length} {
                    set char [string range $unencoded_string $count $count]
                    set enc_char [::encoding convertto $charset $char]
                    if {$length + [string length $enc_char] > $maxlength} {
                        set length $maxlength
                    } else {
                        append enc_string $enc_char
                        incr count
                        incr length [string length $enc_char]
                    }
                }
                set encoded_word [string map [
                    list \n {}] [base64 -mode encode -- $enc_string]]
                append result "=?$encodings($charset)?B?$encoded_word?=\n "
            }
            # Trim off last "\n ", since the above code has the side-effect
            # of adding an extra "\n " to the encoded string.

            set result [string range $result 0 end-2]
        }
        quoted-printable {
            if {$maxlength < 1} {
                error [list maxlength $options(-maxlength) \
		    {too short for chosen charset and encoding}]
            }
            set count 0
            while {$count < $string_length} {
                set length 0
                set encoded_word {}
                while {$length < $maxlength && $count < $string_length} {
                    set char [string range $unencoded_string $count $count]
                    set enc_char [::encoding convertto $charset $char]
                    set qp_enc_char [qp::encode $enc_char 1]
                    set qp_enc_char_length [string length $qp_enc_char]
                    if {$qp_enc_char_length > $maxlength} {
                        error [list maxlength $options(-maxlength) \
			    {too short for chosen charset and encoding}]
                    }
                    if {
			$length + [string length $qp_enc_char] > $maxlength
		    } {
                        set length $maxlength
                    } else {
                        append encoded_word $qp_enc_char
                        incr count
                        incr length [string length $qp_enc_char]
                    }
                }
                append result "=?$encodings($charset)?Q?$encoded_word?=\n "
            }
            # Trim off last "\n ", since the above code has the side-effect
            # of adding an extra "\n " to the encoded string.

            set result [string range $result 0 end-2]
        }
        {} {
            # Go ahead
        }
        default {
            error "Can't handle content encoding \"$method\""
        }
    }
    return $result
}


# ::mime::word_decode --
#
#    Word decodes strings that have been word encoded as per RFC 2047.
#
# Arguments:
#       encoded   The word encoded string to decode.
#
# Results:
#    Returns the string that has been decoded from the encoded message.

proc ::mime::word_decode {encoded} {

    variable reversemap

    if {[regexp -- {=\?([^?]+)\?(.)\?([^?]*)\?=} $encoded \
	- charset method string] != 1
    } {
        error "malformed word-encoded expression '$encoded'"
    }

    set enc [reversemapencoding $charset]
    if {$enc eq {}} {
        error "unknown charset '$charset'"
    }

    switch -exact $method {
        b -
        B {
            set method base64
        }
        q -
        Q {
            set method quoted-printable
        }
        default {
            error "unknown method '$method', must be B or Q"
        }
    }

    switch -exact $method {
        base64 {
            set result [base64 -mode decode -- $string]
        }
        quoted-printable {
            set result [qp::decode $string 1]
        }
        {} {
            # Go ahead
        }
        default {
            error "Can't handle content encoding \"$method\""
        }
    }

    return [list $enc $method $result]
}


# ::mime::field_decode --
#
#    Word decodes strings that have been word encoded as per RFC 2047
#    and converts the string from the original encoding/charset to UTF.
#
# Arguments:
#       field     The string to decode
#
# Results:
#    Returns the decoded string in UTF.

proc ::mime::field_decode {field} {
    # ::mime::field_decode is broken.  Here's a new version.
    # This code is in the public domain.  Don Libes <don@libes.com>

    # Step through a field for mime-encoded words, building a new
    # version with unencoded equivalents.

    # Sorry about the grotesque regexp.  Most of it is sensible.  One
    # notable fudge: the final $ is needed because of an apparent bug
    # in the regexp engine where the preceding .* otherwise becomes
    # non-greedy - perhaps because of the earlier ".*?", sigh.

    while {[regexp {(.*?)(=\?(?:[^?]+)\?(?:.)\?(?:[^?]*)\?=)(.*)$} $field \
	ignore prefix encoded field]
    } {
        # don't allow whitespace between encoded words per RFC 2047
        if {{} ne $prefix} {
            if {![string is space $prefix]} {
                append result $prefix
            }
        }

        set decoded [word_decode $encoded]
        foreach {charset - string} $decoded break

        append result [::encoding convertfrom $charset $string]
    }

    append result $field
    return $result
}

namespace eval ::mime::header {
    ::apply [list {} {
	set saved [namespace eval [namespace parent] {
	    namespace export
	}]
	namespace eval [namespace parent] {
	    namespace export *
	}
	namespace import [namespace parent]::getTransferEncoding
	namespace import [namespace parent]::parselexeme
	namespace import [namespace parent]::reversemapencoding
	namespace import [namespace parent]::uniqueID
	namespace import [namespace parent]::unquote
	namespace eval [namespace parent] [
	    list namespace export -clear {*}$saved
	]
    } [namespace current]]
}


## One-Shot Initialization

::apply {{} {
    variable encList
    variable encAliasList
    variable reversemap

    foreach {enc mimeType} $encList {
        if {$mimeType eq {}} continue
	set reversemap([string tolower $mimeType]) $enc
    }

    foreach {enc mimeType} $encAliasList {
        set reversemap([string tolower $mimeType]) $enc
    }

    # Drop the helper variables
    unset encList encAliasList

} ::mime}
