# fakeldap.tcl --
#
#	A minimal fake LDAPv3 server for the ldap/ldapx API tests. It runs
#	inside the test process, listens on 127.0.0.1 (random port), decodes
#	the requests it receives (recorded in fakeldap::requests) and sends
#	canned responses. Requires the asn package.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------

namespace eval ::fakeldap {
    namespace import ::asn::*

    variable server  {}
    variable port    0
    variable clients {}
    variable buf

    # Configuration, reset by start:
    #   requests  - decoded requests, in order received
    #   results   - dict: request application number -> {code matchedDN msg}
    #               (default {0 {} {}})
    #   entries   - search result entries {dn {attr vals ...}} ...
    #   refs      - search result references, each a list of URLs
    #   rootdse   - attributes of the root DSE {attr vals ...}, returned
    #               for base-scope searches of ""
    #   whoami    - authzId returned by the "Who am I?" extended operation
    #   mode      - normal | close (close on the next request) |
    #               silent (never answer) | split (answer in 2 pieces)
    variable requests {}
    variable results  {}
    variable entries  {}
    variable refs     {}
    variable rootdse  {}
    variable whoami   {}
    variable mode     normal
}

proc ::fakeldap::start {} {
    variable server
    variable port
    variable requests {}
    variable results  {}
    variable entries  {}
    variable refs     {}
    variable rootdse  {}
    variable whoami   {}
    variable mode     normal
    set server [socket -server [namespace code Accept] -myaddr 127.0.0.1 0]
    set port [lindex [fconfigure $server -sockname] 2]
    return $port
}

proc ::fakeldap::stop {} {
    variable server
    variable clients
    variable buf
    catch {close $server}
    foreach c $clients {catch {close $c}}
    set clients {}
    set server {}
    array unset buf
    return
}

# Requests whose first element (the operation name) matches pattern.
proc ::fakeldap::requests {{pattern *}} {
    variable requests
    set r {}
    foreach q $requests {
        if {[string match $pattern [lindex $q 0]]} {lappend r $q}
    }
    return $r
}

# Process events until the request count reaches n (bounded).
proc ::fakeldap::waitrequests {n} {
    variable requests
    set limit [expr {[clock milliseconds] + 5000}]
    while {[llength $requests] < $n && [clock milliseconds] < $limit} {
        set ::fakeldap::tick 0
        set id [after 10 {set ::fakeldap::tick 1}]
        vwait ::fakeldap::tick
        after cancel $id
    }
    return [llength $requests]
}

proc ::fakeldap::Accept {chan addr port} {
    variable clients
    variable buf
    lappend clients $chan
    set buf($chan) ""
    fconfigure $chan -translation binary -blocking 0 -buffering none
    fileevent $chan readable [namespace code [list Read $chan]]
}

proc ::fakeldap::Drop {chan} {
    variable clients
    variable buf
    catch {close $chan}
    set i [lsearch -exact $clients $chan]
    if {$i >= 0} {set clients [lreplace $clients $i $i]}
    unset -nocomplain buf($chan)
}

proc ::fakeldap::Read {chan} {
    variable buf
    if {[catch {read $chan} data]} {
        Drop $chan
        return
    }
    append buf($chan) $data
    while {[set pdu [NextPdu buf($chan)]] ne ""} {
        Handle $chan $pdu
        if {![info exists buf($chan)]} return
    }
    if {[eof $chan]} {
        Drop $chan
    }
}

# Remove one complete TLV from the buffer and return its content, or
# return "" if there is no complete TLV yet.
proc ::fakeldap::NextPdu {bufvar} {
    upvar 1 $bufvar data
    if {[string length $data] < 2} {return ""}
    binary scan $data @1cu l
    set hdr 2
    if {$l & 0x80} {
        set n [expr {$l & 0x7F}]
        if {[string length $data] < 2 + $n} {return ""}
        set l 0
        binary scan $data @2cu$n bytes
        foreach b $bytes {set l [expr {($l << 8) | $b}]}
        incr hdr $n
    }
    if {[string length $data] < $hdr + $l} {return ""}
    set pdu  [string range $data $hdr [expr {$hdr + $l - 1}]]
    set data [string range $data [expr {$hdr + $l}] end]
    return $pdu
}

# Get one raw TLV (tag + length + content) from a variable.
proc ::fakeldap::GetTLV {var} {
    upvar 1 $var data
    set orig $data
    ::asn::asnGetByte data tag
    ::asn::asnGetLength data len
    set hdr [expr {[string length $orig] - [string length $data]}]
    set data [string range $data $len end]
    return [string range $orig 0 [expr {$hdr + $len - 1}]]
}

proc ::fakeldap::Result {app} {
    variable results
    if {[dict exists $results $app]} {
        return [dict get $results $app]
    }
    return {0 {} {}}
}

proc ::fakeldap::LdapResult {app} {
    lassign [Result $app] code matched msg
    return [asnEnumeration $code][asnOctetString $matched][asnOctetString $msg]
}

proc ::fakeldap::Send {chan mid data} {
    variable mode
    set msg [asnSequence [asnInteger $mid] $data]
    if {$mode eq "split"} {
        set n [expr {[string length $msg] / 2}]
        puts -nonewline $chan [string range $msg 0 [expr {$n - 1}]]
        flush $chan
        after 20 [list catch [list puts -nonewline $chan \
                                  [string range $msg $n end]]]
    } else {
        catch {puts -nonewline $chan $msg; flush $chan}
    }
}

proc ::fakeldap::Entry {dn attrs} {
    set a ""
    foreach {name vals} $attrs {
        set l {}
        foreach v $vals {lappend l [asnOctetString $v]}
        append a [asnSequence [asnOctetString $name] [asnSetFromList $l]]
    }
    return [asnApplicationConstr 4 [asnOctetString $dn] [asnSequence $a]]
}

proc ::fakeldap::Handle {chan pdu} {
    variable requests
    variable mode
    variable entries
    variable refs
    variable rootdse
    variable whoami

    asnGetInteger pdu mid
    asnGetApplication pdu app body

    switch -- $app {
        0 {
            asnGetInteger body version
            asnGetOctetString body name
            asnGetContext body ctx password
            lappend requests [list bind $version $name $password $ctx]
        }
        2 {
            lappend requests [list unbind]
            return
        }
        3 {
            asnGetOctetString body base
            asnGetEnumeration body scope
            asnGetEnumeration body deref
            asnGetInteger body size
            asnGetInteger body time
            asnGetBoolean body attrsonly
            set filter [GetTLV body]
            binary scan $filter H* filter
            asnGetSequence body attrseq
            set attrs {}
            while {[string length $attrseq]} {
                asnGetOctetString attrseq a
                lappend attrs $a
            }
            lappend requests [list search $base $scope $deref $size $time \
                                  $attrsonly $filter $attrs]
        }
        6 {
            asnGetOctetString body dn
            asnGetSequence body mods
            set l {}
            while {[string length $mods]} {
                asnGetSequence mods m
                asnGetEnumeration m op
                asnGetSequence m av
                asnGetOctetString av attr
                asnGetSet av vs
                set vals {}
                while {[string length $vs]} {
                    asnGetOctetString vs v
                    lappend vals $v
                }
                lappend l [list [lindex {add delete replace} $op] $attr $vals]
            }
            lappend requests [list modify $dn $l]
        }
        8 {
            asnGetOctetString body dn
            asnGetSequence body attrseq
            set l {}
            while {[string length $attrseq]} {
                asnGetSequence attrseq av
                asnGetOctetString av attr
                asnGetSet av vs
                set vals {}
                while {[string length $vs]} {
                    asnGetOctetString vs v
                    lappend vals $v
                }
                lappend l $attr $vals
            }
            lappend requests [list add $dn $l]
        }
        10 {
            lappend requests [list delete $body]
        }
        12 {
            asnGetOctetString body dn
            asnGetOctetString body newrdn
            asnGetBoolean body delold
            set q [list modifyDN $dn $newrdn $delold]
            if {[string length $body]} {
                asnGetContext body ctx sup
                lappend q $sup
            }
            lappend requests $q
        }
        16 {
            set n 0
            binary scan $body cu* bytes
            foreach b $bytes {set n [expr {($n << 8) | $b}]}
            lappend requests [list abandon $n]
            return
        }
        23 {
            asnGetContext body ctx oid
            lappend requests [list extended $oid]
        }
        default {
            lappend requests [list unknown $app]
            return
        }
    }

    switch -- $mode {
        close  { Drop $chan; return }
        silent { return }
    }

    switch -- $app {
        0  { Send $chan $mid [asnApplicationConstr 1 [LdapResult 1]] }
        3  {
            lassign [lindex $requests end] op base scope - - - - - attrs
            if {$base eq "" && $scope == 0} {
                set a {}
                foreach {name vals} $rootdse {
                    if {![llength $attrs] || $name in $attrs} {
                        lappend a $name $vals
                    }
                }
                Send $chan $mid [Entry "" $a]
            } else {
                foreach e $entries {
                    Send $chan $mid [Entry {*}$e]
                }
                foreach r $refs {
                    set l ""
                    foreach u $r {append l [asnOctetString $u]}
                    Send $chan $mid [asnApplicationConstr 19 $l]
                }
            }
            Send $chan $mid [asnApplicationConstr 5 [LdapResult 5]]
        }
        6  { Send $chan $mid [asnApplicationConstr 7 [LdapResult 7]] }
        8  { Send $chan $mid [asnApplicationConstr 9 [LdapResult 9]] }
        10 { Send $chan $mid [asnApplicationConstr 11 [LdapResult 11]] }
        12 { Send $chan $mid [asnApplicationConstr 13 [LdapResult 13]] }
        23 {
            set r [LdapResult 24]
            if {$whoami ne ""} {append r [asnContext 11 $whoami]}
            Send $chan $mid [asnApplicationConstr 24 $r]
        }
    }
}
