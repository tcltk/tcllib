# mime.tcl - MIME body parts
#
# (c) 1999-2000 Marshall T. Rose
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Influenced by Borenstein's/Rose's safe-tcl (circa 1993) and Darren New's
# unpublished package of 1999.
#


package provide mime 1.2

if {[catch {package require Trf  2.0}]} {

    # Fall-back to tcl-based procedures of base64 and quoted-printable encoders
    # Warning!
    # These are a fragile emulations of the more general calling sequence
    # that appears to work with this code here.

    package require base64 2.0
    proc base64 {-mode what -- chunk} {
	return [base64::$what $chunk]
    }
    proc quoted-printable {-mode what -- chunk} {
	return [mime::qp_$what $chunk]
    }
    proc md5 {-- string} {
	# md5 is just used to uniquify something - bail for the moment
	# 31 is completely random - just want something long for boundaries
	return [string range $string 0 31]
    }
    proc unstack {channel} {
	# do nothing
	return
    }
}

#
# state variables:
#
#     canonicalP: input is in its canonical form
#     content: type/subtype
#     params: seralized array of key/value pairs (keys are lower-case)
#     encoding: transfer encoding
#     version: MIME-version
#     header: serialized array of key/value pairs (keys are lower-case)
#     lowerL: list of header keys, lower-case
#     mixedL: list of header keys, mixed-case
#     value: either "file", "parts", or "string"
#
#     file: input file
#     fd: cached file-descriptor, typically for root
#     root: token for top-level part, for (distant) subordinates
#     offset: number of octets from beginning of file/string
#     count: length in octets of (encoded) content
#
#     parts: list of bodies (tokens)
#
#     string: input string
#
#     cid: last child-id assigned
#


namespace eval mime {
    variable mime
    array set mime { uid 0 cid 0 }

# 822 lexemes
    variable addrtokenL  [list ";"          ","         \
                               "<"          ">"         \
                               ":"          "."         \
                               "("          ")"         \
                               "@"          "\""        \
                               "\["         "\]"        \
                               "\\"]
    variable addrlexemeL [list LX_SEMICOLON LX_COMMA    \
                               LX_LBRACKET  LX_RBRACKET \
                               LX_COLON     LX_DOT      \
                               LX_LPAREN    LX_RPAREN   \
                               LX_ATSIGN    LX_QUOTE    \
                               LX_LSQUARE   LX_RSQUARE   \
                               LX_QUOTE]

# 2045 lexemes
    variable typetokenL  [list ";"          ","         \
                               "<"          ">"         \
                               ":"          "?"         \
                               "("          ")"         \
                               "@"          "\""        \
                               "\["         "\]"        \
                               "="          "/"         \
                               "\\"]
    variable typelexemeL [list LX_SEMICOLON LX_COMMA    \
                               LX_LBRACKET  LX_RBRACKET \
                               LX_COLON     LX_QUESTION \
                               LX_LPAREN    LX_RPAREN   \
                               LX_ATSIGN    LX_QUOTE    \
                               LX_LSQUARE   LX_RSQUARE  \
                               LX_EQUALS    LX_SOLIDUS  \
                               LX_QUOTE]

    namespace export initialize finalize getproperty \
                     getheader setheader \
                     getbody \
                     copymessage \
                     parseaddress \
                     parsedatetime \
                     uniqueID
}


#
# parts is parts
#

proc mime::initialize {args} {
    global errorCode errorInfo

    variable mime

    set token [namespace current]::[incr mime(uid)]

    variable $token
    upvar 0 $token state

    if {[set code [catch { eval [list mime::initializeaux $token] $args } \
                         result]]} {
        set ecode $errorCode
        set einfo $errorInfo

        catch { mime::finalize $token -subordinates dynamic }

        return -code $code -errorinfo $einfo -errorcode $ecode $result
    }

    return $token
}


proc mime::initializeaux {token args} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    array set params [set state(params) ""]
    set state(encoding) ""
    set state(version) "1.0"

    set state(header) ""
    set state(lowerL) ""
    set state(mixedL) ""

    set state(cid) 0

    set argc [llength $args]
    for {set argx 0} {$argx < $argc} {incr argx} {
        set option [lindex $args $argx]
        if {[incr argx] >= $argc} {
            error "missing argument to $option"
        }
        set value [lindex $args $argx]

        switch -- $option {
            -canonical {
                set state(content) [string tolower $value]
            }

            -param {
                if {[llength $value] != 2} {
                    error "-param expects a key and a value, not $value"
                }
                set lower [string tolower [set mixed [lindex $value 0]]]
                if {[info exists params($lower)]} {
                    error "the $mixed parameter may be specified at most once"
                }

                set params($lower) [lindex $value 1]
                set state(params) [array get params]
            }

            -encoding {
                switch -- [set state(encoding) [string tolower $value]] {
                    7bit - 8bit - quoted-printable - base64 {
                    }

                    default {
                        error "unknown value for -encoding $state(encoding)"
                    }
                }
            }

            -header {
                if {[llength $value] != 2} {
                    error "-header expects a key and a value, not $value"
                }
                set lower [string tolower [set mixed [lindex $value 0]]]
                if {![string compare $lower content-type]} {
                    error "use -canonical instead of -header $value"
                }
                if {![string compare $lower content-transfer-encoding]} {
                    error "use -encoding instead of -header $value"
                }
                if {(![string compare $lower content-md5]) \
                        || (![string compare $lower mime-version])} {
                    error "don't go there..."
                }
                if {[lsearch -exact $state(lowerL) $lower] < 0} {
                    lappend state(lowerL) $lower
                    lappend state(mixedL) $mixed
                }               

                array set header $state(header)
                lappend header($lower) [lindex $value 1]
                set state(header) [array get header]
            }

            -file {
                set state(file) $value
            }

            -parts {
                set state(parts) $value
            }

            -string {
                set state(string) $value
            }

# the following are internal options
            -root {
                set state(root) $value
            }

            -offset {
                set state(offset) $value
            }

            -count {
                set state(count) $value
            }

            default {
                error "unknown option $option"
            }
        }
    }

    set valueN 0
    foreach value [list file parts string] {
        if {[info exists state($value)]} {
            set state(value) $value
            incr valueN
        }
    }
    if {$valueN != 1} {
        error "specify exactly one of -file, -parts, or -string"
    }

    if {[set state(canonicalP) [info exists state(content)]]} {
        switch -- $state(value) {
            file {
                set state(offset) 0
            }

            parts {
                switch -glob -- $state(content) {
                    text/*
                        -
                    image/*
                        -
                    audio/*
                        -
                    video/* {
                        error "-canonical $state(content) and -parts do not mix"
                    }
    
                    default {
                        if {[string compare $state(encoding) ""]} {
                            error "-encoding and -parts do not mix"
                        }
                    }
                }
            }
        }

        if {[lsearch -exact $state(lowerL) content-id] < 0} {
            lappend state(lowerL) content-id
            lappend state(mixedL) Content-ID

            array set header $state(header)
            lappend header(content-id) [mime::uniqueID]
            set state(header) [array get header]
        }

        set state(version) 1.0

        return
    }

    if {[string compare $state(params) ""]} {
        error "-param requires -canonical"
    }
    if {[string compare $state(encoding) ""]} {
        error "-encoding requires -canonical"
    }
    if {[string compare $state(header) ""]} {
        error "-header requires -canonical"
    }
    if {[info exists state(parts)]} {
        error "-parts requires -canonical"
    }

    if {[set fileP [info exists state(file)]]} {
        if {[set openP [info exists state(root)]]} {
            variable $state(root)
            upvar 0 $state(root) root

            set state(fd) $root(fd)
        } else {
            set state(root) $token
            set state(fd) [open $state(file) { RDONLY }]
            set state(offset) 0
            seek $state(fd) 0 end
            set state(count) [tell $state(fd)]

            fconfigure $state(fd) -translation binary
        }
    }

    set code [catch { mime::parsepart $token } result]
    set ecode $errorCode
    set einfo $errorInfo

    if {$fileP} {
        if {!$openP} {
            unset state(root)
            catch { close $state(fd) }
        }
        unset state(fd)
    }

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc mime::parsepart {token} {
    variable $token
    upvar 0 $token state

    if {[set fileP [info exists state(file)]]} {
        seek $state(fd) [set pos $state(offset)] start
        set last [expr {$state(offset)+$state(count)-1}]
    } else {
        set string $state(string)
    }

    set vline ""
    while {1} {
        set blankP 0
        if {$fileP} {
            if {($pos > $last) || ([set x [gets $state(fd) line]] <= 0)} {
                set blankP 1
            } else {
                incr pos [expr {$x+1}]
            }
        } else {
            if {[string length $string] == 0} {
                set blankP 1
            } else {
                switch -- [set pos [string first "\n" $string]] {
                    -1 {
                        set line $string
                        set string ""
                    }
    
                    0 {
                        set blankP 1
                        set line ""
                        set string [string range $string 1 end]
                    }
    
                    default {
                        set line [string range $string 0 [expr {$pos-1}]]
                        set string [string range $string [expr {$pos+1}] end]
                    }
                }
                set x [string length $line]
            }
        }

        if {(!$blankP) && ([string last "\r" $line] == [expr {$x-1}])} {
            set line [string range $line 0 [expr {$x-2}]]
            if {$x == 1} {
                set blankP 1
            }
        }

        if {(!$blankP) \
                && (([string first " " $line] == 0) \
                        || ([string first "\t" $line] == 0))} {
            append vline "\n" $line
            continue
        }      

        if {![string compare $vline ""]} {
            if {$blankP} {
                break
            }

            set vline $line
            continue
        }

        if {([set x [string first ":" $vline]] <= 0) \
                || (![string compare \
                             [set mixed \
                                  [string trimright \
                                          [string range \
                                                  $vline 0 [expr {$x-1}]]]] \
                            ""])} {
            error "improper line in header: $vline"
        }
        set value [string trim [string range $vline [expr {$x+1}] end]]
        switch -- [set lower [string tolower $mixed]] {
            content-type {
                if {[info exists state(content)]} {
                    error "multiple Content-Type fields starting with $vline"
                }

                if {![catch { set x [mime::parsetype $token $value] }]} {
                    set state(content) [lindex $x 0]
                    set state(params) [lindex $x 1]
                }
            }

            content-md5 {
            }

            content-transfer-encoding {
                if {([string compare $state(encoding) ""]) \
                        && ([string compare $state(encoding) \
                                    [string tolower $value]])} {
                    error "multiple Content-Transfer-Encoding fields starting with $vline"
                }

                set state(encoding) [string tolower $value]
            }

            mime-version {
                set state(version) $value
            }

            default {
                if {[lsearch -exact $state(lowerL) $lower] < 0} {
                    lappend state(lowerL) $lower
                    lappend state(mixedL) $mixed
                }

                array set header $state(header)
                lappend header($lower) $value
                set state(header) [array get header]
            }
        }

        if {$blankP} {
            break
        }
        set vline $line
    }

    if {![info exists state(content)]} {
        set state(content) text/plain
        set state(params) [list charset us-ascii]
    }

    if {![string match multipart/* $state(content)]} {
        if {$fileP} {
            set x [tell $state(fd)]
            incr state(count) [expr {$state(offset)-$x}]
            set state(offset) $x
        } else {
            set state(string) $string
        }

        if {[string match message/* $state(content)]} {
            variable [set child $token-[incr state(cid)]]

            set state(value) parts
            set state(parts) $child
            if {$fileP} {
                mime::initializeaux $child \
                    -file $state(file) -root $state(root) \
                    -offset $state(offset) -count $state(count)
            } else {
                mime::initializeaux $child -string $state(string)
            }
        }

        return
    }

    set state(value) parts

    set boundary ""
    foreach {k v} $state(params) {
        if {![string compare $k boundary]} {
            set boundary $v
            break
        }
    }
    if {![string compare $boundary ""]} {
        error "boundary parameter is missing in $state(content)"
    }
    if {![string compare [string trim $boundary] ""]} {
        error "boundary parameter is empty in $state(content)"
    }

    if {$fileP} {
        set pos [tell $state(fd)]
    }

    set inP 0
    set moreP 1
    while {$moreP} {
        if {$fileP} {
            if {$pos > $last} {
                error "termination string missing in $state(content)"
            }
            if {[set x [gets $state(fd) line]] < 0} {
                error "end-of-file encountered while parsing $state(content)"
            }
            incr pos [expr {$x+1}]
        } else {
            if {[string length $string] == 0} {
                error "end-of-string encountered while parsing $state(content)"
            }
            switch -- [set pos [string first "\n" $string]] {
                -1 {
                    set line $string
                    set string ""
                }

                0 {
                    set line ""
                    set string [string range $string 1 end]
                }

                default {
                    set line [string range $string 0 [expr {$pos-1}]]
                    set string [string range $string [expr {$pos+1}] end]
                }
            }
            set x [string length $line]
        }
        if {[string last "\r" $line] == [expr {$x-1}]} {
            set line [string range $line 0 [expr {$x-2}]]
        }

        if {[string first "--$boundary" $line] != 0} {
            if {$inP && !$fileP} {
                append start $line "\n"
            }

            continue
        }

        if {!$inP} {
            if {![string compare $line "--$boundary"]} {
                set inP 1
                if {$fileP} {
                    set start $pos
                } else {
                    set start ""
                }
            }

            continue
        }

        if {([set moreP [string compare $line "--$boundary--"]]) \
                && ([string compare $line "--$boundary"])} {
            if {$inP && !$fileP} {
                append start $line "\n"
            }
            continue
        }

        variable [set child $token-[incr state(cid)]]

        lappend state(parts) $child

        if {$fileP} {
            if {[set count [expr {$pos-($start+$x+3)}]] < 0} {
                set count 0
            }

            mime::initializeaux $child \
                -file $state(file) -root $state(root) \
                -offset $start -count $count

            seek $state(fd) [set start $pos] start
        } else {
            mime::initializeaux $child -string \
                    [string range $start 0 [expr {[string length $start]-2}]]

            set start ""
        }
    }
}


proc mime::parsetype {token string} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    variable typetokenL
    variable typelexemeL

    set state(input)   $string
    set state(buffer)  ""
    set state(lastC)   LX_END
    set state(comment) ""
    set state(tokenL)  $typetokenL
    set state(lexemeL) $typelexemeL

    set code [catch { mime::parsetypeaux $token $string } result]    
    set ecode $errorCode
    set einfo $errorInfo

    unset state(input)   \
          state(buffer)  \
          state(lastC)   \
          state(comment) \
          state(tokenL)  \
          state(lexemeL)

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc mime::parsetypeaux {token string} {
    variable $token
    upvar 0 $token state

    if {[string compare [mime::parselexeme $token] LX_ATOM]} {
        error [format "expecting type (found %s)" $state(buffer)]
    }
    set type [string tolower $state(buffer)]

    switch -- [mime::parselexeme $token] {
        LX_SOLIDUS {
        }

        LX_END {
            if {[string compare $type message]} {
                error "expecting type/subtype (found $type)"
            }

            return [list message/rfc822 ""]
        }

        default {
            error [format "expecting \"/\" (found %s)" $state(buffer)]
        }
    }

    if {[string compare [mime::parselexeme $token] LX_ATOM]} {
        error [format "expecting subtype (found %s)" $state(buffer)]
    }
    append type [string tolower /$state(buffer)]

    array set params ""
    while {1} {
        switch -- [mime::parselexeme $token] {
            LX_END {
                return [list $type [array get params]]
            }

            LX_SEMICOLON {
            }

            default {
                error [format "expecting \";\" (found %s)" $state(buffer)]
            }
        }

        if {[string compare [mime::parselexeme $token] LX_ATOM]} {
            error [format "expecting attribute (found %s)" $state(buffer)]
        }
        set attribute [string tolower $state(buffer)]

        if {[string compare [mime::parselexeme $token] LX_EQUALS]} {
            error [format "expecting \"=\" (found %s)" $state(buffer)]
        }

        switch -- [mime::parselexeme $token] {
            LX_ATOM {
            }

            LX_QSTRING {
                set state(buffer) \
                    [string range $state(buffer) 1 \
                            [expr {[string length $state(buffer)]-2}]]
            }

            default {
                error [format "expecting value (found %s)" $state(buffer)]
            }
        }
        set params($attribute) $state(buffer)
    }
}


proc mime::finalize {token args} {
    variable $token
    upvar 0 $token state

    array set options [list -subordinates dynamic]
    array set options $args

    switch -- $options(-subordinates) {
        all {
            if {![string compare $state(value) parts]} {
                foreach part $state(parts) {
                    eval [list mime::finalize $part] $args
                }
            }
        }

        dynamic {
            for {set cid $state(cid)} {$cid > 0} {incr cid -1} {
                eval [list mime::finalize $token-$cid] $args
            }
        }

        none {
        }

        default {
            error "unknown value for -subordinates $options(-subordinates)"
        }
    }

    foreach name [array names state] {
        unset state($name)
    }
    unset $token
}


proc mime::getproperty {token {property ""}} {
    variable $token
    upvar 0 $token state

    switch -- $property {
        "" {
            array set properties [list content  $state(content) \
                                       encoding $state(encoding) \
                                       params   $state(params) \
                                       size     [mime::getsize $token]]
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

            return $names
        }

        content
            -
        encoding
            -
        params {
            return $state($property)
        }

        parts {
            if {![info exists state(parts)]} {
                error "MIME part is a leaf"
            }

            return $state(parts)
        }

        size {
            return [mime::getsize $token]
        }

        default {
            error "unknown property $property"
        }
    }
}

proc mime::getsize {token} {
    variable $token
    upvar 0 $token state

    switch -- $state(value)/$state(canonicalP) {
        file/0 {
            set size $state(count)
        }

        file/1 {
            return [file size $state(file)]
        }

        parts/0
            -
        parts/1 {
            set size 0
            foreach part $state(parts) {
                incr size [mime::getsize $part]
            }

            return $size
        }

        string/0 {
            set size [string length $state(string)]
        }

        string/1 {
            return [string length $state(string)]
        }
    }

    if {![string compare $state(encoding) base64]} {
        set size [expr {($size*3+2)/4}]
    }

    return $size
}


#
# header access
#

proc mime::getheader {token {key ""}} {
    variable $token
    upvar 0 $token state

    array set header $state(header)
    switch -- $key {
        "" {
            set result ""
            foreach lower $state(lowerL) mixed $state(mixedL) {
                lappend result $mixed $header($lower)
            }
            return $result
        }

        -names {
            return $state(mixedL)
        }

        default {
            set lower [string tolower [set mixed $key]]

            if {![info exists header($lower)]} {
                error "key $mixed not in header"
            }
            return $header($lower)
        }
    }
}


proc mime::setheader {token key value args} {
    variable $token
    upvar 0 $token state

    array set options [list -mode write]
    array set options $args

    switch -- [set lower [string tolower $key]] {
        content-md5
            -
        content-type
            -
        content-transfer-encoding
            -
        mime-version {
            error "key $key may not be set"
        }
    }

    array set header $state(header)
    if {[set x [lsearch -exact $state(lowerL) $lower]] < 0} {
        if {![string compare $options(-mode) delete]} {
            error "key $key not in header"
        }

        lappend state(lowerL) $lower
        lappend state(mixedL) $key

        set result ""
    } else {
        set result $header($lower)
    }
    switch -- $options(-mode) {
        append {
            lappend header($lower) $value
        }

        delete {
            unset header($lower)
            set state(lowerL) [lreplace $state(lowerL) $x $x]
            set state(mixedL) [lreplace $state(mixedL) $x $x]
        }

        write {
            set header($lower) [list $value]
        }

        default {
            error "unknown value for -mode $options(-mode)"
        }
    }

    set state(header) [array get header]

    return $result
}


#
# body handling
#

proc mime::getbody {token args} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    array set options [list -command [list mime::getbodyaux $token] \
                            -blocksize 4096]
    array set options $args
    if {$options(-blocksize) < 1} {
        error "-blocksize expects a positive integer, not $options(-blocksize)"
    }

    set code 0
    set ecode ""
    set einfo ""

    switch -- $state(value)/$state(canonicalP) {
        file/0 {
            set fd [open $state(file) { RDONLY }]

            set code [catch {
                fconfigure $fd -translation binary
                seek $fd [set pos $state(offset)] start
                set last [expr {$state(offset)+$state(count)-1}]

                set fragment ""
                while {$pos <= $last} {
                    if {[set cc [expr {($last-$pos)+1}]] \
                            > $options(-blocksize)} {
                        set cc $options(-blocksize)
                    }
                    incr pos [set len \
                                  [string length [set chunk [read $fd $cc]]]]
                    switch -- $state(encoding) {
                        base64
                            -
                        quoted-printable {
                            if {([set x [string last "\n" $chunk]] > 0) \
                                    && ($x+1 != $len)} {
                                set chunk [string range $chunk 0 $x]
                                seek $fd [incr pos [expr {($x+1)-$len}]] start
                            }
                            set chunk [$state(encoding) -mode decode \
                                                        -- $chunk]
                        }
                    }
                    append fragment $chunk

                    set cc [expr {$options(-blocksize)-1}]
                    while {[string length $fragment] > $options(-blocksize)} {
                        uplevel #0 $options(-command) \
                                   [list data \
                                         [string range $fragment 0 $cc]]

                        set fragment [string range \
                                             $fragment $options(-blocksize) \
                                             end]
                    }
                }
                if {[string length $fragment] > 0} {
                    uplevel #0 $options(-command) [list data $fragment]
                }
            } result]
            set ecode $errorCode
            set einfo $errorInfo

            catch { close $fd }
        }

        file/1 {
            set fd [open $state(file) { RDONLY }]

            set code [catch {
                fconfigure $fd -translation binary

                while {[string length \
                               [set fragment \
                                    [read $fd $options(-blocksize)]]] > 0} {
                    uplevel #0 $options(-command) [list data $fragment]
                }
            } result]
            set ecode $errorCode
            set einfo $errorInfo

            catch { close $fd }
        }

        parts/0
            -
        parts/1 {
            error "MIME part isn't a leaf"
        }

        string/0
            -
        string/1 {
            switch -- $state(encoding)/$state(canonicalP) {
                base64/0
                    -
                quoted-printable/0 {
                    set fragment [$state(encoding) -mode decode \
                                                   -- $state(string)]
                }

                default {
                    set fragment $state(string)
                }
            }

            set code [catch {
                set cc [expr {$options(-blocksize)-1}]
                while {[string length $fragment] > $options(-blocksize)} {
                    uplevel #0 $options(-command) \
                            [list data [string range $fragment 0 $cc]]

                    set fragment [string range $fragment \
                                         $options(-blocksize) end]
                }
                if {[string length $fragment] > 0} {
                    uplevel #0 $options(-command) [list data $fragment]
                }
            } result]
            set ecode $errorCode
            set einfo $errorInfo
        }
    }

    set code [catch {
        if {$code} {
            uplevel #0 $options(-command) [list error $result]
        } else {
            uplevel #0 $options(-command) [list end]
        }
    } result]
    set ecode $errorCode
    set einfo $errorInfo    

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc mime::getbodyaux {token reason {fragment ""}} {
    variable $token
    upvar 0 $token state

    switch -- $reason {
        data {
            append state(getbody) $fragment
        }

        end {
            if {[info exists state(getbody)]} {
                set result $state(getbody)
                unset state(getbody)
            } else {
                set result ""
            }

            return $result
        }

        error {
            catch { unset state(getbody) }
            error $reason
        }
    }
}


#
# message handling
#

proc mime::copymessage {token channel} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    set openP [info exists state(fd)]

    set code [catch { mime::copymessageaux $token $channel } result]
    set ecode $errorCode
    set einfo $errorInfo

    if {(!$openP) && ([info exists state(fd)])} {
        if {![info exists state(root)]} {
            catch { close $state(fd) }
        }
        unset state(fd)
    }

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc mime::copymessageaux {token channel} {
    variable $token
    upvar 0 $token state

    array set header $state(header)

    if {[string compare $state(version) ""]} {
        puts $channel "MIME-Version: $state(version)"
    }
    foreach lower $state(lowerL) mixed $state(mixedL) {
        foreach value $header($lower) {
            puts $channel "$mixed: $value"
        }
    }
    if {(!$state(canonicalP)) \
            && ([string compare [set encoding $state(encoding)] ""])} {
        puts $channel "Content-Transfer-Encoding: $encoding"
    }

    puts -nonewline $channel "Content-Type: $state(content)"
    set boundary ""
    foreach {k v} $state(params) {
        if {![string compare $k boundary]} {
            set boundary $v
        }

        puts -nonewline $channel ";\n              $k=\"$v\""
    }

    set converter ""
    set encoding ""
    if {[string compare $state(value) parts]} {
        puts $channel ""

        if {$state(canonicalP)} {
            if {![string compare [set encoding $state(encoding)] ""]} {
                set encoding [mime::encoding $token]
            }
            if {[string compare $encoding ""]} {
                puts $channel "Content-Transfer-Encoding: $encoding"
            }
            switch -- $encoding {
                base64
                    -
                quoted-printable {
                    set converter $encoding
                }
            }
        }
    } elseif {([string match multipart/* $state(content)]) \
                    && (![string compare $boundary ""])} {
# we're doing everything in one pass...
        set key [clock seconds]$token[info hostname][array get state]
        set seqno 8
        while {[incr seqno -1] >= 0} {
            set key [md5 -- $key]
        }
        set boundary "----- =_[string trim [base64 -mode encode -- $key]]"

        puts $channel ";\n              boundary=\"$boundary\""
    } else {
        puts $channel ""
    }

    catch { unset state(error) }
                
    switch -- $state(value) {
        file {
            set closeP 1
            if {[info exists state(root)]} {
                variable $state(root)
                upvar 0 $state(root) root 

                if {[info exists root(fd)]} {
                    set fd $root(fd)
                    set closeP 0
                } else {
                    set fd [set state(fd) \
                                [open $state(file) { RDONLY }]]
                }
                set size $state(count)
            } else {
                set fd [set state(fd) [open $state(file) { RDONLY }]]
		# read until eof
                set size -1
            }
            seek $fd $state(offset) start
            if {$closeP} {
                fconfigure $fd -translation binary
            }

            puts $channel ""

	    while {($size != 0) && (![eof $fd])} {
		if {$size < 0 || $size > 32766} {
		    set X [read $fd 32766]
		} else {
		    set X [read $fd $size]
		}
		if {$size > 0} {
		    set size [expr {$size - [string length $X]}]
		}
		if {[string compare $converter ""]} {
		    puts $channel [$converter -mode encode -- $X]
		} else {
		    puts $channel $X
		}
	    }

            if {$closeP} {
                catch { close $state(fd) }
                unset state(fd)
            }
        }

        parts {
            if {(![info exists state(root)]) \
                    && ([info exists state(file)])} {
                set state(fd) [open $state(file) { RDONLY }]
                fconfigure $state(fd) -translation binary
            }

            switch -glob -- $state(content) {
                message/* {
                    puts $channel ""
                    foreach part $state(parts) {
                        mime::copymessage $part $channel
                        break
                    }
                }

                default {
                    foreach part $state(parts) {
                        puts $channel "\n--$boundary"
                        mime::copymessage $part $channel
                    }
                    puts $channel "\n--$boundary--"
                }
            }

            if {[info exists state(fd)]} {
                catch { close $state(fd) }
                unset state(fd)
            }
        }

        string {
            if {[catch { fconfigure $channel -buffersize } blocksize]} {
                set blocksize 4096
            } elseif {$blocksize < 512} {
                set blocksize 512
            }
            set blocksize [expr {($blocksize/4)*3}]

            puts $channel ""

            if {[string compare $converter ""]} {
                puts $channel [$converter -mode encode -- $state(string)]
            } else {
		puts $channel $state(string)
	    }
        }
    }

    flush $channel

    if {[string compare $converter ""]} {
        unstack $channel
    }
    if {[info exists state(error)]} {
        error $state(error)
    }
}

#
# The following is a clone of the copymessage code to build up the
# result in memory, and, unfortunately, without using a memory channel.
# I considered parameterizing the "puts" calls in copy message, but
# the need for this procedure may go away, so I'm living with it for
# the moment.
#

proc mime::buildmessage {token} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    set openP [info exists state(fd)]

    set code [catch { mime::buildmessageaux $token } result]
    set ecode $errorCode
    set einfo $errorInfo

    if {(!$openP) && ([info exists state(fd)])} {
        if {![info exists state(root)]} {
            catch { close $state(fd) }
        }
        unset state(fd)
    }

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}

proc mime::buildmessageaux {token} {
    variable $token
    upvar 0 $token state

    array set header $state(header)

    set result ""
    if {[string compare $state(version) ""]} {
        append result "MIME-Version: $state(version)\n"
    }
    foreach lower $state(lowerL) mixed $state(mixedL) {
        foreach value $header($lower) {
            append result "$mixed: $value\n"
        }
    }
    if {(!$state(canonicalP)) \
            && ([string compare [set encoding $state(encoding)] ""])} {
        append result "Content-Transfer-Encoding: $encoding\n"
    }

    append result "Content-Type: $state(content)"
    set boundary ""
    foreach {k v} $state(params) {
        if {![string compare $k boundary]} {
            set boundary $v
        }

        append result ";\n              $k=\"$v\""
    }

    set converter ""
    set encoding ""
    if {[string compare $state(value) parts]} {
        append result \n

        if {$state(canonicalP)} {
            if {![string compare [set encoding $state(encoding)] ""]} {
                set encoding [mime::encoding $token]
            }
            if {[string compare $encoding ""]} {
                append result "Content-Transfer-Encoding: $encoding\n"
            }
            switch -- $encoding {
                base64
                    -
                quoted-printable {
                    set converter $encoding
                }
            }
        }
    } elseif {([string match multipart/* $state(content)]) \
                    && (![string compare $boundary ""])} {
# we're doing everything in one pass...
        set key [clock seconds]$token[info hostname][array get state]
        set seqno 8
        while {[incr seqno -1] >= 0} {
            set key [md5 -- $key]
        }
        set boundary "----- =_[string trim [base64 -mode encode -- $key]]"

        append result ";\n              boundary=\"$boundary\"\n"
    } else {
        append result \n
    }

    catch { unset state(error) }
                
    switch -- $state(value) {
        file {
            set closeP 1
            if {[info exists state(root)]} {
                variable $state(root)
                upvar 0 $state(root) root 

                if {[info exists root(fd)]} {
                    set fd $root(fd)
                    set closeP 0
                } else {
                    set fd [set state(fd) \
                                [open $state(file) { RDONLY }]]
                }
                set size $state(count)
            } else {
                set fd [set state(fd) [open $state(file) { RDONLY }]]
                set size -1	;# Read until EOF
            }
            seek $fd $state(offset) start
            if {$closeP} {
                fconfigure $fd -translation binary
            }

            append result \n

	    while {($size != 0) && (![eof $fd])} {
		if {$size < 0 || $size > 32766} {
		    set X [read $fd 32766]
		} else {
		    set X [read $fd $size]
		}
		if {$size > 0} {
		    set size [expr {$size - [string length $X]}]
		}
		if {[string compare $converter ""]} {
		    append result [$converter -mode encode -- $X]
		} else {
		    append result $X
		}
	    }

            if {$closeP} {
                catch { close $state(fd) }
                unset state(fd)
            }
        }

        parts {
            if {(![info exists state(root)]) \
                    && ([info exists state(file)])} {
                set state(fd) [open $state(file) { RDONLY }]
                fconfigure $state(fd) -translation binary
            }

            switch -glob -- $state(content) {
                message/* {
                    append result \n
                    foreach part $state(parts) {
                        append result [mime::buildmessage $part]
                        break
                    }
                }

                default {
                    foreach part $state(parts) {
                        append result "\n--$boundary\n"
                        append result [mime::buildmessage $part]
                    }
                    append result "\n--$boundary--\n"
                }
            }

            if {[info exists state(fd)]} {
                catch { close $state(fd) }
                unset state(fd)
            }
        }

        string {

            append result "\n"

	    if {[string compare $converter ""]} {
		append result [$converter -mode encode -- $state(string)]
	    } else {
		append result $state(string)
	    }
        }
    }

    if {[info exists state(error)]} {
        error $state(error)
    }
    return $result
}


proc mime::encoding {token} {
    variable $token
    upvar 0 $token state

    switch -glob -- $state(content) {
        audio/*
            -
        image/*
            -
        video/* {
            return base64
        }

        message/*
            -
        multipart/* {
            return ""
        }
    }

    set asciiP 1
    set lineP 1
    switch -- $state(value) {
        file {
            set fd [open $state(file) { RDONLY }]
            fconfigure $fd -translation binary

            while {[gets $fd line] >= 0} {
                if {$asciiP} {
                    set asciiP [mime::encodingasciiP $line]
                }
                if {$lineP} {
                    set lineP [mime::encodinglineP $line]
                }
                if {(!$asciiP) && (!$lineP)} {
                    break
                }
            }

            catch { close $fd }
        }

        parts {
            return ""
        }

        string {
            foreach line [split $state(string) "\n"] {
                if {$asciiP} {
                    set asciiP [mime::encodingasciiP $line]
                }
                if {$lineP} {
                    set lineP [mime::encodinglineP $line]
                }
                if {(!$asciiP) && (!$lineP)} {
                    break
                }
            }
        }
    }

    switch -glob -- $state(content) {
        text/* {
            if {!$asciiP} {
                foreach {k v} $state(params) {
                    if {![string compare $k charset]} {
                        set v [string tolower $v]
                        if {([string compare $v us-ascii]) \
                                && (![string match {iso-8859-[1-8]} $v])} {
                            return base64
                        }

                        break
                    }
                }
            }

            if {!$lineP} {
                return quoted-printable
            }
        }

        
        default {
            if {(!$asciiP) || (!$lineP)} {
                return base64
            }
        }
    }

    return ""
}


proc mime::encodingasciiP {line} {
    foreach c [split $line ""] {
        switch -- $c {
            " " - "\t" - "\r" - "\n" {
            }

            default {
                binary scan $c c c
                if {($c < 32) || ($c > 126)} {
                    return 0
                }
            }
        }
    }
    if {([set r [string first "\r" $line]] < 0) \
            || ($r == [expr {[string length $line]-1}])} {
        return 1
    }

    return 0
}


proc mime::encodinglineP {line} {
    if {([string length $line] > 76) \
            || ([string compare $line [string trimright $line]]) \
            || ([string first . $line] == 0) \
            || ([string first "From " $line] == 0)} {
        return 0
    }

    return 1
}


proc mime::fcopy {token count {error ""}} {
    variable $token
    upvar 0 $token state

    if {[string compare $error ""]} {
        set state(error) $error
    }
    set state(doneP) 1
}


proc mime::scopy {token channel offset len blocksize} {
    variable $token
    upvar 0 $token state

    if {$len <= 0} {
        set state(doneP) 1
        fileevent $channel writable ""
        return
    }

    if {[set cc $len] > $blocksize} {
        set cc $blocksize
    }

    if {[catch { puts -nonewline $channel \
                      [string range $state(string) $offset \
                              [expr {$offset+$cc-1}]]
                 fileevent $channel writable \
                           [list mime::scopy $token $channel \
                                             [incr offset $cc] \
                                             [incr len -$cc] \
                                             $blocksize]
               } result]} {
        set state(error) $result
        set state(doneP) 1
        fileevent $channel writable ""
    }
}

# Tcl version of quote-printable encode/decode

proc mime::qp_encode {string} {
    # Replace outlying characters, characters that would normally be munged
    # by EBCDIC gateways, and special Tcl characters with =xx sequence
    regsub -all "\[\x00-\x08\x0B-\x1E\x21-\x24=\x40\\\[\\\\\\\]\x5E\x60\x7B-\xFF\]" \
	    $string {[scan "\\&" %c c; format "=%02X" $c]} string

    # soft/hard newlines
    regsub -all {([ \t])\n} $string \
	    {[scan "\1" %c c; format "=%02X\n" $c]} string

    # Funky cases for SMTP compatibility
    regsub -all "\n\.\n" $string "\n=2E\n" string
    regsub -all "\nFrom " $string "\n=46rom " string

    # Replace the format commands with their result
    set string [subst $string]

    # Break long lines - ugh
    set result ""
    foreach line [split $string \n] {
	while {[string length $line] > 72} {
	    set chunk [string range $line 0 72]
	    if {[regexp (=|=.)$ $chunk dummy end]} {
		# Don't break in the middle of a code
		set len [expr {72 - [string length $end]}]
		set chunk [string range $line 0 $len]
		incr len
		set line [string range $line $len end]
	    } else {
		set line [string range $line 73 end]
	    }
	    append result $chunk=\n
	}
	append result $line\n
    }
    
    # Trim off last \n, since the above code has the side-effect of adding an
    # extra \n to the encoded string and return the result.
    set result [string range $result 0 end-1]

    # If the string ends in space or tab, replace with =xx
    set lastChar [string index $result end]
    if {$lastChar==" "} {
	set result [string replace $result end end "=20"]
    }
    if {$lastChar=="\t"} {
	set result [string replace $result end end "=09"]
    }
	
    return $result
}

proc mime::qp_decode {string} {

    # Protect Tcl special chars
    regsub -all {[][\\\$]} $string {\\&} string

    # smash the white-space at the ends of lines since that must've been
    # generated by an MUA.
    regsub -all {[ \t]+\n} $string "\n" string
    set string [string trimright $string " \t"]

    # smash soft newlines
    regsub -all {=\n} $string {} string

    # Decode specials
    regsub -all =(..) $string {[format %c "0x\1"]} string

    return [subst $string]
}

#
# address handling
#
#    this was originally written circa 1982 in C. we're still using it
#    because it recognizes virtually every buggy address syntax ever
#    generated!
#

proc mime::parseaddress {string} {
    global errorCode errorInfo

    variable mime

    set token [namespace current]::[incr mime(uid)]

    variable $token
    upvar 0 $token state

    set code [catch { mime::parseaddressaux $token $string } result]
    set ecode $errorCode
    set einfo $errorInfo

    foreach name [array names state] {
        unset state($name)
    }
    catch { unset $token }

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc mime::parseaddressaux {token string} {
    variable $token
    upvar 0 $token state

    variable addrtokenL
    variable addrlexemeL

    set state(input)   $string
    set state(glevel)  0
    set state(buffer)  ""
    set state(lastC)   LX_END
    set state(tokenL)  $addrtokenL
    set state(lexemeL) $addrlexemeL

    set result ""
    while {[mime::addr_next $token]} {
        if {[string compare [set tail $state(domain)] ""]} {
            set tail @$state(domain)
        } else {
            set tail @[info hostname]
        }
        if {[string compare [set address $state(local)] ""]} {
            append address $tail
        }

        if {[string compare $state(phrase) ""]} {
            set state(phrase) [string trim $state(phrase) "\""]
            foreach t $state(tokenL) {
                if {[string first $t $state(phrase)] >= 0} {
                    set state(phrase) \"$state(phrase)\"
                    break
                }
            }

            set proper "$state(phrase) <$address>"
        } else {
            set proper $address
        }

        if {![string compare [set friendly $state(phrase)] ""]} {
            if {[string compare [set note $state(comment)] ""]} {
                if {[string first "(" $note] == 0} {
                    set note [string trimleft [string range $note 1 end]]
                }
                if {[string last ")" $note] \
                        == [set len [expr {[string length $note]-1}]]} {
                    set note [string range $note 0 [expr {$len-1}]]
                }
                set friendly $note
            }

            if {(![string compare $friendly ""]) \
                    && ([string compare [set mbox $state(local)] ""])} {
                set mbox [string trim $mbox "\""]

                if {[string first "/" $mbox] != 0} {
                    set friendly $mbox
                } elseif {[string compare \
                                  [set friendly [mime::addr_x400 $mbox PN]] \
                                  ""]} {
                } elseif {([string compare \
                                   [set friendly [mime::addr_x400 $mbox S]] \
                                   ""]) \
                            && ([string compare \
                                        [set g [mime::addr_x400 $mbox G]] \
                                        ""])} {
                    set friendly "$g $friendly"
                }

                if {![string compare $friendly ""]} {
                    set friendly $mbox
                }
            }
        }
        set friendly [string trim $friendly "\""]

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

    unset state(input)   \
          state(glevel)  \
          state(buffer)  \
          state(lastC)   \
          state(tokenL)  \
          state(lexemeL)

    return $result
}


proc mime::addr_next {token} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    foreach prop {comment domain error group local memberP phrase route} {
        catch { unset state($prop) }
    }

    switch -- [set code [catch { mime::addr_specification $token } result]] {
        0 {
            if {!$result} {
                return 0
            }

            switch -- $state(lastC) {
                LX_COMMA
                    -
                LX_END {
                }

# catch trailing comments...
                default {
                    set lookahead $state(input)
                    mime::parselexeme $token
                    set state(input) $lookahead
                }
            }
        }

        7 {
            set state(error) $result

            while {1} {
                switch -- $state(lastC) {
                    LX_COMMA
                        -
                    LX_END {
                        break
                    }

                    default {
                        mime::parselexeme $token
                    }
                }
            }
        }

        default {
            set ecode $errorCode
            set einfo $errorInfo

            return -code $code -errorinfo $einfo -errorcode $ecode $result
        }
    }

    foreach prop {comment domain error group local memberP phrase route} {
        if {![info exists state($prop)]} {
            set state($prop) ""
        }
    }

    return 1
}


proc mime::addr_specification {token} {
    variable $token
    upvar 0 $token state

    set lookahead $state(input)
    switch -- [mime::parselexeme $token] {
        LX_ATOM
            -
        LX_QSTRING {
            set state(phrase) $state(buffer)
        }

        LX_SEMICOLON {
            if {[incr state(glevel) -1] < 0} {
                return -code 7 "extraneous semi-colon"
            }

            catch { unset state(comment) }
            return [mime::addr_specification $token]
        }

        LX_COMMA {
            catch { unset state(comment) }
            return [mime::addr_specification $token]
        }

        LX_END {
            return 0
        }

        LX_LBRACKET {
            return [mime::addr_routeaddr $token]
        }

        LX_ATSIGN {
            set state(input) $lookahead
            return [mime::addr_routeaddr $token 0]
        }

        default {
            return -code 7 \
                   [format "unexpected character at beginning (found %s)" \
                           $state(buffer)]
        }
    }

    switch -- [mime::parselexeme $token] {
        LX_ATOM
            -
        LX_QSTRING {
            append state(phrase) " " $state(buffer)

            return [mime::addr_phrase $token]
        }

        LX_LBRACKET {
            return [mime::addr_routeaddr $token]
        }

        LX_COLON {
            return [mime::addr_group $token]
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
            if {(![string compare $state(lastC) LX_SEMICOLON]) \
                    && ([incr state(glevel) -1] < 0)} {
                return -code 7 "extraneous semi-colon"
            }

            set state(local) $state(phrase)
            unset state(phrase)
        }

        default {
            return -code 7 [format "expecting mailbox (found %s)" \
                                   $state(buffer)]
        }
    }

    return 1
}


proc mime::addr_routeaddr {token {checkP 1}} {
    variable $token
    upvar 0 $token state

    set lookahead $state(input)
    if {![string compare [mime::parselexeme $token] LX_ATSIGN]} {
        mime::addr_route $token
    } else {
        set state(input) $lookahead
    }

    mime::addr_local $token

    switch -- $state(lastC) {
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
            return -code 7 \
                   [format "expecting at-sign after local-part (found %s)" \
                           $state(buffer)]
        }
    }

    if {($checkP) && ([string compare $state(lastC) LX_RBRACKET])} {
        return -code 7 [format "expecting right-bracket (found %s)" \
                               $state(buffer)]
    }

    return 1
}


proc mime::addr_route {token} {
    variable $token
    upvar 0 $token state

    set state(route) @

    while {1} {
        switch -- [mime::parselexeme $token] {
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

        switch -- [mime::parselexeme $token] {
            LX_COMMA {
                append state(route) $state(buffer)
                while {1} {
                    switch -- [mime::parselexeme $token] {
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
                return -code 7 \
                       [format "expecting colon to terminate route (found %s)" \
                               $state(buffer)]
            }
        }
    }
}


proc mime::addr_domain {token} {
    variable $token
    upvar 0 $token state

    while {1} {
        switch -- [mime::parselexeme $token] {
            LX_ATOM
                -
            LX_DLITERAL {
                append state(domain) $state(buffer)
            }

            default {
                return -code 7 \
                       [format "expecting sub-domain in domain-part (found %s)" \
                               $state(buffer)]
            }
        }

        switch -- [mime::parselexeme $token] {
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


proc mime::addr_local {token} {
    variable $token
    upvar 0 $token state

    set state(memberP) $state(glevel)

    while {1} {
        switch -- [mime::parselexeme $token] {
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

        switch -- [mime::parselexeme $token] {
            LX_DOT {
                append state(local) $state(buffer)
            }

            default {
                return
            }
        }
    }
}


proc mime::addr_phrase {token} {
    variable $token
    upvar 0 $token state

    while {1} {
        switch -- [mime::parselexeme $token] {
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

    switch -- $state(lastC) {
        LX_LBRACKET {
            return [mime::addr_routeaddr $token]
        }

        LX_COLON {
            return [mime::addr_group $token]
        }

        LX_DOT {
            append state(phrase) $state(buffer)
            return [mime::addr_phrase $token]   
        }

        default {
            return -code 7 \
                   [format "found phrase instead of mailbox (%s%s)" \
                           $state(phrase) $state(buffer)]
        }
    }
}


proc mime::addr_group {token} {
    variable $token
    upvar 0 $token state

    if {[incr state(glevel)] > 1} {
        return -code 7 [format "nested groups not allowed (found %s)" \
                               $state(phrase)]
    }

    set state(group) $state(phrase)
    unset state(phrase)

    set lookahead $state(input)
    while {1} {
        switch -- [mime::parselexeme $token] {
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
                return [mime::addr_specification $token]
            }
        }
    }
}


proc mime::addr_end {token} {
    variable $token
    upvar 0 $token state

    switch -- $state(lastC) {
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
            return -code 7 [format "junk after local@domain (found %s)" \
                                   $state(buffer)]
        }
    }    
}


proc mime::addr_x400 {mbox key} {
    if {[set x [string first "/$key=" [string toupper $mbox]]] < 0} {
        return
    }
    set mbox [string range $mbox [expr {$x+[string length $key]+2}] end]

    if {[set x [string first "/" $mbox]] > 0} {
        set mbox [string range $mbox 0 [expr {$x-1}]]
    }

    return [string trim $mbox "\""]
}


#
# date handling
#
#    fortunately the clock command in the Tcl 8.x core does all the heavy 
#    lifting for us (except for timezone calculations)
#

proc mime::parsedatetime {value property} {
    if {![string compare $value -now]} {
        set clock [clock seconds]
    } else {
        set clock [clock scan $value]
    }

    switch -- $property {
        hour {
            set value [clock format $clock -format %H]
        }

        lmonth {
            return [clock format $clock -format %B]
        }

        lweekday {
            return [clock format $clock -format %A]
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
            return [clock format $clock -format %b]
        }

        proper {
            set gmt [clock format $clock -format "%d %b %Y %H:%M:%S" \
                           -gmt true]
            if {[set diff [expr {($clock-[clock scan $gmt])/60}]] < 0} {
                set s -
                set diff [expr {-($diff)}]
            } else {
                set s +
            }
            set zone [format %s%02d%02d $s [expr {$diff/60}] [expr {$diff%60}]]

            return [clock format $clock \
                          -format "%a, %d %b %Y %H:%M:%S $zone"]
        }

        rclock {
            if {![string compare $value -now]} {
                return 0
            } else {
                return [expr {[clock seconds]-$clock}]
            }
        }

        sec {
            set value [clock format $clock -format %S]
        }

        wday {
            return [clock format $clock -format %w]
        }

        weekday {
            return [clock format $clock -format %a]
        }

        yday {
            set value [clock format $clock -format %j]
        }

        year {
            set value [clock format $clock -format %Y]
        }

        zone {
            regsub -all "\t" $value " " value
            set value [string trim $value]
            if {[set x [string last " " $value]] < 0} {
                return 0
            }
            set value [string range $value [expr {$x+1}] end]
            switch -- [set s [string index $value 0]] {
                + - - {
                    if {![string compare $s +]} {
                        set s ""
                    }
                    set value [string trim [string range $value 1 end]]
                    if {([string length $value] != 4) \
                            || ([scan $value %2d%2d h m] != 2) \
                            || ($h > 12) \
                            || ($m > 59) \
                            || (($h == 12) && ($m > 0))} {
                        error "malformed timezone-specification: $value"
                    }
                    set value $s[expr {$h*60+$m}]
                }

                default {
                    set value [string toupper $value]
                    set z1 [list  UT GMT EST EDT CST CDT MST MDT PST PDT]
                    set z2 [list   0   0  -5  -4  -6  -5  -7  -6  -8  -7]
                    if {[set x [lsearch -exact $z1 $value]] < 0} {
                        error "unrecognized timezone-mnemonic: $value"
                    }
                    set value [expr {[lindex $z2 $x]*60}]
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

    if {![string compare [set value [string trimleft $value 0]] ""]} {
        set value 0
    }
    return $value
}


#
# unique identifiers
#

proc mime::uniqueID {} {
    variable mime

    return "<[pid].[clock seconds].[incr mime(cid)]@[info hostname]>"
}


#
# helper functions
#

proc mime::parselexeme {token} {
    variable $token
    upvar 0 $token state

    set state(input) [string trimleft $state(input)]

    set state(buffer) ""
    if {![string compare $state(input) ""]} {
        set state(buffer) end-of-input
        return [set state(lastC) LX_END]
    }

    set c [string index $state(input) 0]
    set state(input) [string range $state(input) 1 end]

    if {![string compare $c "("]} {
        set noteP 0
        set quoteP 0

        while {1} {
            append state(buffer) $c

            switch -- $c/$quoteP {
                "(/0" {
                    incr noteP
                }

                "\\/0" {
                    set quoteP 1
                }

                ")/0" {
                    if {[incr noteP -1] < 1} {
                        if {[info exists state(comment)]} {
                            append state(comment) " "
                        }
                        append state(comment) $state(buffer)

                        return [mime::parselexeme $token]
                    }
                }

                default {
                    set quoteP 0
                }
            }

            if {![string compare [set c [string index $state(input) 0]] ""]} {
                set state(buffer) "end-of-input during comment"
                return [set state(lastC) LX_ERR]
            }
            set state(input) [string range $state(input) 1 end]
        }
    }

    if {![string compare $c "\""]} {
        set firstP 1
        set quoteP 0

        while {1} {
            append state(buffer) $c

            switch -- $c/$quoteP {
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

            if {![string compare [set c [string index $state(input) 0]] ""]} {
                set state(buffer) "end-of-input during quoted-string"
                return [set state(lastC) LX_ERR]
            }
            set state(input) [string range $state(input) 1 end]
        }
    }

    if {![string compare $c "\["]} {
        set quoteP 0

        while {1} {
            append state(buffer) $c

            switch -- $c/$quoteP {
                "\\/0" {
                    set quoteP 1
                }

                "\]/0" {
                    return [set state(lastC) LX_DLITERAL]
                }

                default {
                    set quoteP 0
                }
            }

            if {![string compare [set c [string index $state(input) 0]] ""]} {
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

    while {1} {
        append state(buffer) $c

        switch -- [set c [string index $state(input) 0]] {
            "" - " " - "\t" - "\n" {
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
