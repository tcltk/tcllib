# smtp.tcl - SMTP client
#
# (c) 1999-2000 Marshall T. Rose
# Hold harmless the author, and any lawful use is allowed.
#


package provide smtp 1.2

package require mime 1.0

if {[catch {package require Trf  2.0}]} {
    # Trf is not available, but we can live without it as long as the
    # transform proc is defined.

    # Warning!
    # This is a fragile emulation of the more general calling sequence
    # that appears to work with this code here.

    proc transform {args} {
	upvar state mystate
	set mystate(size) 1
    }
}

#
# state variables:
#
#    sd: socket to server
#    afterID: afterID associated with smtp::timer
#    options: array of user-supplied options
#    readable: semaphore for vwait
#    addrs: number of recipients negotiated
#    error: error during read
#    line: response read from server
#    crP: just put a \r in the data
#    nlP: just put a \n in the data
#    size: number of octets sent in DATA
#


namespace eval smtp {
    variable smtp
    array set smtp { uid 0 }

    namespace export sendmessage
}


proc smtp::sendmessage {part args} {
    global errorCode errorInfo

    set aloP 0
    set debugP 0
    set origP 0
    set queueP 0
    set originator ""
    set recipients ""
    set servers [list localhost]

    array set header ""
    set lowerL ""
    set mixedL ""

    set argc [llength $args]
    for {set argx 0} {$argx < $argc} {incr argx} {
        set option [lindex $args $argx]
        if {[incr argx] >= $argc} {
            error "missing argument to $option"
        }
        set value [lindex $args $argx]

        switch -- $option {
            -atleastone {
                set aloP [smtp::boolean $value]
            }

            -debug {
                set debugP [smtp::boolean $value]
            }

            -queue {
                set queueP [smtp::boolean $value]
            }

            -header {
                if {[llength $value] != 2} {
                    error "-header expects a key and a value, not $value"
                }
                set lower [string tolower [set mixed [lindex $value 0]]]
                if {(![string compare $lower content-type]) \
                        || (![string compare $lower \
                                     content-transfer-encoding]) \
                        || (![string compare $lower content-md5]) \
                        || (![string compare $lower mime-version])} {
                    error "don't go there..."
                }
                if {[lsearch -exact $lowerL $lower] < 0} {
                    lappend lowerL $lower
                    lappend mixedL $mixed
                }               

                lappend header($lower) [lindex $value 1]
            }

            -originator {
                if {![string compare [set originator $value] ""]} {
                    set origP 1
                }
            }

            -recipients {
                set recipients $value
            }

            -servers {
                set servers $value
            }

            default {
                error "unknown option $option"
            }
        }
    }

    if {[lsearch -glob $lowerL resent-*] >= 0} {
        set prefixL resent-
        set prefixM Resent-
    } else {
        set prefixL ""
        set prefixM ""
    }
    foreach mixed {From Sender To cc Dcc Bcc Date Message-ID} {
        set lower [string tolower $mixed]
        set ${lower}L $prefixL$lower
        set ${lower}M $prefixM$mixed
    }

    if {$origP} {
        set sender ""
    } else {
        if {(![string compare $originator ""]) \
                && (![info exists header($fromL)])} {
            catch { set originator [id user] }
        }
        if {[string compare $originator ""]} {
            set who -originator
    
            if {[lsearch -exact $lowerL $fromL] < 0} {
                lappend lowerL $fromL
                lappend mixedL $fromM
                lappend header($fromL) $originator
            }
        } elseif {[catch { set originator [smtp::merge $header($fromL)] }]} {
            error "need -header \"$fromM ...\""
        } else {
            set who $fromM
        }
        if {[llength [set addrs [mime::parseaddress $originator]]] > 1} {
            error "too many mailboxes in $who: $originator"
        }
        array set aprops [lindex $addrs 0]
        if {[string compare $aprops(error) ""]} {
            error "error in $who: $aprops(error)"
        }
        set sender $aprops(address)
    
        if {([lsearch -exact $lowerL $senderL] < 0) \
                && ([string compare $originator \
                            [set from [smtp::merge $header($fromL)]]])} {
            catch { unset aprops }
            array set aprops [lindex [mime::parseaddress $from] 0]
            if {[string compare $aprops(error) ""]} {
                error "error in $fromM: $aprops(error)"
            }
            if {[string compare $aprops(address) $sender]} {
                lappend lowerL $senderL
                lappend mixedL $senderM
                lappend header($senderL) $aprops(address)
            }
        }
    }

    if {[string compare $recipients ""]} {
        set who -recipients
    } elseif {[catch { set recipients [smtp::merge $header($toL)] }]} {
        error "need -header \"$toM ...\""
    } else {
        set who $toM
        if {![catch { append recipients ,[smtp::merge $header($ccL)] }]} {
            append who /$ccM
        }

        if {[set x [lsearch -exact $lowerL $dccL]] >= 0} {
            append recipients ,[smtp::merge $header($dccL)]
            append who /$dccM

            unset header($dccL)
            set lowerL [lreplace $lowerL $x $x]
            set mixedL [lreplace $mixedL $x $x]
        }
    }

    set brecipients ""
    if {[set x [lsearch -exact $lowerL $bccL]] >= 0} {
        set bccP 1

        foreach addr [mime::parseaddress [smtp::merge $header($bccL)]] {
            catch { unset aprops }
            array set aprops $addr
            if {[string compare $aprops(error) ""]} {
                error "error in $bccM: $aprops(error)"
            }
            lappend brecipients $aprops(address)
        }

        unset header($bccL)
        set lowerL [lreplace $lowerL $x $x]
        set mixedL [lreplace $mixedL $x $x]
    } else {
        set bccP 0
    }
    if {[lsearch -exact $lowerL $toL] < 0} {
        lappend lowerL $bccL
        lappend mixedL $bccM
        lappend header($bccL) ""
    }

    set vrecipients ""
    foreach addr [mime::parseaddress $recipients] {
        catch { unset aprops }
        array set aprops $addr
        if {[string compare $aprops(error) ""]} {
            error "error in $who: $aprops(error)"
        }
        lappend vrecipients $aprops(address)
    }

    if {([lsearch -exact $lowerL $dateL] < 0) \
            && ([catch { mime::getheader $part $dateL }])} {
        lappend lowerL $dateL
        lappend mixedL $dateM
        lappend header($dateL) [mime::parsedatetime -now proper]
    }

    if {([lsearch -exact $lowerL ${message-idL}] < 0) \
            && ([catch { mime::getheader $part ${message-idL} }])} {
        lappend lowerL ${message-idL}
        lappend mixedL ${message-idM}
        lappend header(${message-idL}) [mime::uniqueID]

    }

    set savedH [mime::getheader $part]
    foreach lower $lowerL mixed $mixedL {
        foreach value $header($lower) {
            mime::setheader $part $mixed $value -mode append
        }
    }

    if {![string compare $servers localhost]} {
        set client localhost
    } else {
        set client [info hostname]
    }

    set token [smtp::initialize -debug $debugP -client $client \
                                -multiple $bccP -queue $queueP \
                                -servers $servers]

    set code [catch { smtp::sendmessageaux $token $part \
                                           $sender $vrecipients $aloP } \
                    result]
    set ecode $errorCode
    set einfo $errorInfo

    if {($code == 0) && ($bccP)} {
        set inner [mime::initialize -canonical message/rfc822 \
                                    -header [list Content-Description \
                                                  "Original Message"] \
                                    -parts [list $part]]

        set subject "\[$bccM\]"
        catch { append subject " " [lindex $header(subject) 0] }

        set outer [mime::initialize \
                         -canonical multipart/digest \
                         -header [list From $originator] \
                         -header [list Bcc ""] \
                         -header [list Date \
                                       [mime::parsedatetime -now proper]] \
                         -header [list Subject $subject] \
                         -header [list Message-ID [mime::uniqueID]] \
                         -header [list Content-Description \
                                       "Blind Carbon Copy"] \
                         -parts [list $inner]]


        set code [catch { smtp::sendmessageaux $token $outer \
                                               $sender $brecipients \
                                               $aloP } result2]
        set ecode $errorCode
        set einfo $errorInfo

        if {$code == 0} {
            set result [concat result $result2]
        } else {
            set result $result2
        }

        catch { mime::finalize $inner -subordinates none }
        catch { mime::finalize $outer -subordinates none }
    }

    switch -- $code {
        0 {
            set status orderly
        }

        7 {
            set code 1
            array set response $result
            set result "$response(code): $response(diagnostic)"
            set status abort
        }

        default {
            set status abort
        }
    }

    catch { smtp::finalize $token -close $status }

    foreach key [mime::getheader $part -names] {
        mime::setheader $part $key "" -mode delete
    }
    foreach {key values} $savedH {
        foreach value $values {
            mime::setheader $part $key $value -mode append
        }
    }

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc smtp::sendmessageaux {token part originator recipients aloP} {
    global errorCode errorInfo

    smtp::winit $token $originator

    set goodP 0
    set badP 0
    set oops ""
    foreach recipient $recipients {
        set code [catch { smtp::waddr $token $recipient } result]
        set ecode $errorCode
        set einfo $errorInfo

        switch -- $code {
            0 {
                incr goodP
            }

            7 {
                incr badP

                array set response $result
                lappend oops [list $recipient $response(code) \
                                   $response(diagnostic)]
            }

            default {
                return -code $code -errorinfo $einfo -errorcode $ecode $result
            }
        }
    }

    if {($goodP) && ((!$badP) || ($aloP))} {
        smtp::wtext $token $part
    } else {
        catch { smtp::talk $token 300 RSET }
    }

    return $oops
}

proc smtp::initialize {args} {
    global errorCode errorInfo

    variable smtp

    set token [namespace current]::[incr smtp(uid)]

    variable $token
    upvar 0 $token state

    array set state [list afterID "" options "" readable 0]
    array set options [list -debug 0 -client localhost -multiple 1 \
                            -queue 0 -servers localhost]
    array set options $args
    set state(options) [array get options]

    foreach server $options(-servers) {
        if {$options(-debug)} {
            puts stderr "Trying $server..."
            flush stderr
        }

        catch { unset state(sd) }
        if {[set code [catch {
            set state(sd) [socket -async $server 25]
            fconfigure $state(sd) -blocking off -translation binary
            fileevent $state(sd) readable [list smtp::readable $token]
        } result]]} {
            set ecode $errorCode
            set einfo $errorInfo

            catch { close $state(sd) }
            continue
        }

        if {[set code [catch { smtp::hear $token 600 } result]]} {
            array set response [list code 400 diagnostic $result]
        } else {
            array set response $result
        }
        set ecode $errorCode
        set einfo $errorInfo
        switch -- $response(code) {
            220 {
            }

            421 - default {
                catch { close $state(sd) }

                continue
            }
        }
        
        if {[set code [catch { smtp::talk $token 300 \
                                          "EHLO $options(-client)" } \
                   result]]} {
            array set response [list code 400 diagnostic $result args ""]
        } else {
            array set response $result
        }
        set ecode $errorCode
        set einfo $errorInfo
        if {(500 <= $response(code)) && ($response(code) <= 599)} {
            if {[set code [catch { smtp::talk $token 300 \
                                              "HELO $options(-client)" } \
                       result]]} {
                array set response [list code 400 diagnostic $result \
                                    args ""]
            } else {
                array set response $result
            }
            set ecode $errorCode
            set einfo $errorInfo
        }
        switch -- $response(code) {
            250 {
                if {(!$options(-multiple)) \
                        && ([lsearch $response(args) ONEX] >= 0)} {
                    catch { smtp::talk $token 300 ONEX }
                }
                if {($options(-queue)) \
                        && ([lsearch $response(args) XQUE] >= 0)} {
                    catch { smtp::talk $token 300 QUED }
                }

                return $token
            }

            default {
                catch { close $state(sd) }
            }
        }
    }

    smtp::finalize $token -close drop

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc smtp::finalize {token args} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    array set options [list -close orderly]
    array set options $args

    switch -- $options(-close) {
        orderly {
            set code [catch { smtp::talk $token 120 QUIT } result]
        }

        abort {
            set code [catch {
                smtp::talk $token 0 RSET
                smtp::talk $token 0 QUIT
            } result]
        }

        drop {
            set code 0
            set result ""
        }

        default {
            error "unknown value for -close $options(-close)"
        }
    }
    set ecode $errorCode
    set einfo $errorInfo

    catch { close $state(sd) }

    if {[string compare $state(afterID) ""]} {
        catch { after cancel $state(afterID) }
    }

    foreach name [array names state] {
        unset state($name)
    }
    unset $token

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc smtp::winit {token originator {mode MAIL}} {
    variable $token
    upvar 0 $token state

    switch -- $mode {
        MAIL - SEND - SOML - SAML {
        }

        default {
            error "unknown origination mode $mode"
        }
    }

    array set response \
          [set result [smtp::talk $token 600 \
                                  "$mode FROM:<$originator>"]]
    switch -- $response(code) {
        250 {
            set state(addrs) 0
            return $result
        }

        default {
            return -code 7 $result
        }
    }
}


proc smtp::waddr {token recipient} {
    variable $token
    upvar 0 $token state

    array set response \
          [set result [smtp::talk $token 3600 "RCPT TO:<$recipient>"]]
    switch -- $response(code) {
        250 - 251 {
            incr state(addrs)
            return $result
        }

        default {
            return -code 7 $result
        }
    }
}


proc smtp::wtext {token part} {
    variable $token
    upvar 0 $token state

    array set response [set result [smtp::talk $token 300 DATA]]
    switch -- $response(code) {
        354 {
        }

        default {
            return -code 7 $result
        }
    }

    if {[catch { smtp::wtextaux $token $part } result]} {
        catch { puts -nonewline $state(sd) "\r\n.\r\n" ; flush $state(sd) }
        return -code 7 [list code 400 diagnostic $result]
    }

    set secs [expr {(($state(size)>>10)+1)*3600}]

    array set response [set result [smtp::talk $token $secs .]]
    switch -- $response(code) {
        250 - 251 {
            return $result
        }

        default {
            return -code 7 $result
        }
    }
}


proc smtp::wtextaux {token part} {
    global errorCode errorInfo

    variable $token
    upvar 0 $token state

    flush $state(sd)
    fileevent $state(sd) readable ""
    transform -attach $state(sd) -command [list smtp::wdata $token]
    fileevent $state(sd) readable [list smtp::readable $token]

    set code [catch { mime::copymessage $part $state(sd) } result]
    set ecode $errorCode
    set einfo $errorInfo

    flush $state(sd)
    fileevent $state(sd) readable ""
    unstack $state(sd)
    fileevent $state(sd) readable [list smtp::readable $token]

    return -code $code -errorinfo $einfo -errorcode $ecode $result
}


proc smtp::wdata {token command buffer} {
    variable $token
    upvar 0 $token state

    switch -- $command {
        create/write
            -
        clear/write
            -
        delete/write {
            set state(crP) 0
            set state(nlP) 1
            set state(size) 0
        }

        write {
            set result ""

            foreach c [split $buffer ""] {
                switch -- $c {
                    "." {
                        if {$state(nlP)} {
                            append result .
                        }
                        set state(crP) 0
                        set state(nlP) 0
                    }

                    "\r" {
                        set state(crP) 1
                        set state(nlP) 0
                    }

                    "\n" {
                        if {!$state(crP)} {
                            append result "\r"
                        }
                        set state(crP) 0
                        set state(nlP) 1
                    }

                    default {
                        set state(crP) 0
                        set state(nlP) 0
                    }
                }

                append result $c
            }

            incr state(size) [string length $result]
            return $result
        }

        flush/write {
            set result ""

            if {!$state(nlP)} {
                if {!$state(crP)} {
                    append result "\r"
                }
                append result "\n"
            }

            incr state(size) [string length $result]
            return $result
        }
    }
}


proc smtp::talk {token secs command} {
    variable $token
    upvar 0 $token state

    array set options $state(options)

    if {$options(-debug)} {
        puts stderr "--> $command (wait upto $secs seconds)"
        flush stderr
    }

    if {[catch { puts -nonewline $state(sd) "$command\r\n"
                 flush $state(sd) } result]} {
        return [list code 400 diagnostic $result]
    }

    if {$secs == 0} {
        return
    }

    return [smtp::hear $token $secs]
}


proc smtp::hear {token secs} {
    variable $token
    upvar 0 $token state

    array set options $state(options)

    array set response [list args ""]

    set firstP 1
    while {1} {
        if {$secs >= 0} {
            set state(afterID) [after [expr {$secs*1000}] \
                                      [list smtp::timer $token]]
        }

        if {!$state(readable)} {
            vwait $token
        }

        if {$state(readable) !=  -1} {
            catch { after cancel $state(afterID) }
            set state(afterID) ""
        }

        if {$state(readable) < 0} {
            array set response [list code 400 diagnostic $state(error)]
            break
        }
        set state(readable) 0

        if {$options(-debug)} {
            puts stderr "<-- $state(line)"
            flush stderr
        }

        if {[string length $state(line)] < 3} {
            array set response \
                  [list code 500 \
                        diagnostic "response too short: $state(line)"]
            break
        }

        if {$firstP} {
            set firstP 0

            if {[scan [string range $state(line) 0 2] %d response(code)] \
                    != 1} {
                array set response \
                      [list code 500 \
                            diagnostic "unrecognizable code: $state(line)"]
                break
            }

            set response(diagnostic) \
                [string trim [string range $state(line) 4 end]]
        } else {
            lappend response(args) \
                    [string trim [string range $state(line) 4 end]]
        }

        if {[string compare [string index $state(line) 3] -]} {
            break
        }
    }

    return [array get response]
}


proc smtp::readable {token} {
    variable $token
    upvar 0 $token state

    if {[catch { array set options $state(options) }]} {
        return
    }

    set state(line) ""
    if {[eof $state(sd)]} {
        set state(readable) -3
        set state(error) "premature end-of-file from server"
    } elseif {[catch { gets $state(sd) state(line) } result]} {
        set state(readable) -2
        set state(error) $result
    } else {
        if {[string last "\r" $state(line)] \
                == [set x [expr {[string length $state(line)]-1}]]} {
            set state(line) [string range $state(line) 0 [expr {$x-1}]]
        }
        set state(readable) 1
    }

    if {$state(readable) != 1} {
        if {$options(-debug)} {
            puts stderr "    ... $state(error) ..."
            flush stderr
        }

        catch { fileevent $state(sd) readable "" }
    }
}


proc smtp::timer {token} {
    variable $token
    upvar 0 $token state

    array set options $state(options)

    set state(afterID) ""
    set state(readable) -1
    set state(error) "read from server timed out"

    if {$options(-debug)} {
        puts stderr "    ... $state(error) ..."
        flush stderr
    }
}


proc smtp::boolean {value} {
    switch -- [string tolower $value] {
        0 - false - no - off {
            return 0
        }

        1 - true - yes - on {
            return 1
        }

        default {
            error "unknown boolean value: $value"
        }
    }
}

proc smtp::merge {values} {
    set result ""
    set s ""

    foreach value $values {
        append result $s $value
        set s ,
    }

    return $result
}
