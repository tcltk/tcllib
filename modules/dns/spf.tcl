# spf.tcl - Copyright (C) 2004 Pat Thoyts <patthoyts@users.sourceforge.net>
#
#                         Sender Policy Framework
#
#    http://spf.pobox.com/
#    http://www.ietf.org/internet-drafts/draft-mengwong-spf-01.txt
#
# Domains using SPF:
#   pobox.org      - mx, a, ptr
#   oxford.ac.uk   - include
#   gnu.org        - ip4
#   aol.com        - ip4, ptr
#   altavista.com  - exists,  multiple TXT replies.
#   oreilly.com    - mx, ptr, include (invalid domain)
#   motleyfool.com - include (looping includes)
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
#
# $Id: spf.tcl,v 1.1 2004/07/01 12:25:14 patthoyts Exp $

package require Tcl 8.2;                # tcl minimum version
package require dns;                    # tcllib 1.3
package require logger;                 # tcllib 1.3

namespace eval spf {
    variable version 1.0.0
    variable rcsid {$Id: spf.tcl,v 1.1 2004/07/01 12:25:14 patthoyts Exp $}

    namespace export spf

    variable log
    if {![info exists log]} { 
        set log [logger::init spf]
        ${log}::setlevel warn
        proc ${log}::stdoutcmd {level text} {
            variable service
            puts "\[[clock format [clock seconds] -format {%H:%M:%S}]\
                $service $level\] $text"
        }
    }
}

# -------------------------------------------------------------------------
# sender : ip address of sender
# target : domain name to test against.
#
proc ::spf::spf {sender target} {
    variable log

    if {[catch {SPF $target} spf]} {
        ${log}::debug "error fetching SPF record: $spf"
        return none
    }
    
    return [Spf $sender $target $spf]
}

proc ::spf::Spf {sender target spf} {
    variable log
    if {![regexp {^v=spf(\d)\s+} $spf -> version]} {
        return none
    }

    ${log}::debug "$spf"

    if {$version != 1} {
        return -code error "version mismatch: we only understand SPF 1\
            this domain has provided version \"$version\""
    }

    if {![is_ip4_addr $sender]} {
        set ips [A $sender]
        set sender [lindex $ips 0]
    }
    
    set result ?
    set seen_domains $target
    set explanation {denied}

    set directives [lrange [split $spf { }] 1 end]
    foreach directive $directives {
        set prefix [string range $directive 0 0]
        if {$prefix eq "+" || $prefix eq "-" 
            || $prefix eq "?" || $prefix eq "~"} {
            set directive [string range $directive 1 end]
        } else {
            set prefix "+"
        }

        set cmd [string tolower [lindex [split $directive {:/=}] 0]]
        set param [string range $directive [string length $cmd] end]

        if {[info command ::spf::_$cmd] == {}} {
            # 6.1 Unrecognised directives terminate processing
            #     but unknown modifiers are ignored.
            if {[string match "=*" $param]} {
                continue
            } else {
                set result unknown
                break
            }
        } else {
            if {[catch {::spf::_$cmd $sender $target $param} res]} {
                if {$res eq "none" || $res eq "error" || $res eq "unknown"} {
                    return $res
                }
                return -code error "error in \"$cmd\": $res"
            }
            if {$res} { set result $prefix }
        }
        
        ${log}::debug "$prefix $cmd\($param) -> $result"
        if {$result eq "+"} break
    }
    
    return $result
}

proc ::spf::loglevel {level} {
    variable log
    ${log}::setlevel $level
}

# get a guaranteed unique and non-present token id.
proc ::spf::create_token {} {
    variable uid
    set id [incr uid]
    while {[info exists [set token [namespace current]::$id]]} {
        set id [incr uid]
    }
    return $token
}

# -------------------------------------------------------------------------
#
#                      SPF MECHANISM HANDLERS
#
# -------------------------------------------------------------------------

# 4.1: The "all" mechanism is a test that always matches.  It is used as the
#      rightmost mechanism in an SPF record to provide an explicit default
#
proc ::spf::_all {sender target param} {
    return 1
}

# 4.2: The "include" mechanism triggers a recursive SPF query.
#
proc ::spf::_include {sender target param} {
    variable log
    upvar seen_domains Seen

    if {[string range $param 0 0] ne ":"} {
        return -code error "dubious parameters for \"include\""
    }
    set r ?
    set domain [string range $param 1 end]
    if {[lsearch $Seen $domain] == -1} {
        lappend Seen $domain
        if {[catch {set r [spf $sender $domain]}]} {
            return -code error error
        }
        if {$r eq "none" || $r eq "unknown"} {
            return -code error $r
        }
    }
    return [expr {$r eq "+"}]
}

# 4.4: This mechanism matches if the <sending-host> is one of the
#      <target-name>'s IP addresses.
#
proc ::spf::_a {sender target param} {
    variable log
    foreach {domain bits} [splitspec [string trimleft $param :]] {}
    if {$domain == {}} {
        set domain $target
    }
    set dips [A $domain]
    set ip [ipmask $sender $bits]
    foreach dip $dips {
        ${log}::debug "  compare: ${sender}/${bits} with ${dip}/${bits}"
        set dp [ipmask $dip $bits]
        if {$ip == $dp} {
            return 1
        }
    }
    return 0
}

# 4.5: This mechanism matches if the <sending-host> is one of the MX hosts
#      for a domain name.
#
proc ::spf::_mx {sender target param} {
    variable log
    foreach {domain bits} [splitspec [string trimleft $param :]] {}
    if {$domain eq ""} {
        set domain $target
    }
    ${log}::debug "  fetching MX for $domain"
    set mxs [MX $domain]

    set ip [ipmask $sender $bits]
    foreach mx $mxs {
        set mx [lindex $mx 1]
        set mxips [A $mx]
        foreach mxip $mxips {
            ${log}::debug "  compare: ${sender}/${bits} with ${mxip}/${bits}"
            set mp [ipmask $mxip $bits]
            if {$ip == $mp} {
                return 1
            }
        }
    }
    return 0
}

# 4.6: This mechanism tests if the <sending-host>'s name is within a
#      particular domain.
#
proc ::spf::_ptr {sender target param} {
    variable log
    set validnames {}
    if {[catch { set names [PTR $sender] } msg]} {
        ${log}::debug "  \"$sender\" $msg"
        return 0
    }
    foreach name $names {
        set ips [A $name]
        foreach ip $ips {
            if {$ip eq $sender} {
                lappend validnames $name
                continue
            }
        }
    }

    ${log}::debug "  validnames: $validnames"
    set domain [string trimleft $param :]
    if {$domain == {}} {
        set domain $target
    }
    foreach name $validnames {
        if {[string match "*$domain" $name]} {
            return 1
        }
    }

    return 0
}

# 4.7: These mechanisms test if the <sending-host> falls into a given IP
#      network.
#
proc ::spf::_ip4 {sender target param} {
    variable log
    foreach {network bits} [splitspec [string range $param 1 end]] {}
    set net [ipmask $network $bits]
    set ipx [ipmask $sender $bits]
    ${log}::debug "  compare ${sender}/${bits} to ${network}/${bits}"
    if {$ipx == $net} {
        return 1
    }
    return 0
}

# 4.7: These mechanisms test if the <sending-host> falls into a given IP
#      network.
#
proc ::spf::_ip6 {sender target param} {
    variable log
    ${log}::warn "ip6 address handling not implemented."
    return 0
}

# 4.8: This mechanism is used to construct an arbitrary host name that is
#      used for a DNS A record query.  It allows for complicated schemes
#      involving arbitrary parts of the mail envelope to determine what is
#      legal.
#
proc ::spf::_exists {sender target param} {
    variable log
    set param [string range $param 1 end]
    ${log}::warn "exists mechanism handling not implemented."
    return 0
}

# 5.1: Redirected query
#
proc ::spf::_redirect {sender target param} {
    variable log
    set domain [string range $param 1 end]
    ${log}::debug ">> redirect to $domain"
    set r [spf $sender $target $domain]
    return -code return $r
}

# 5.2: Explanation
#
proc ::spf::_exp {sender target param} {
    variable log
    set domain [string range $param 1 end]
    set exp [TXT $domain]
    set exp [Expand $exp]
}

# 5.3: Sender accreditation
#
proc ::spf::_accredit {sender target param} {
    variable log
    ${log}::debug "  accredit modifier ignored"
    return 0
}


# 7: Macro expansion
#
proc ::spf::Expand {txt} {
    variable log
    ${log}::warn "macro expansion not implemented"
    return 0
}

# -------------------------------------------------------------------------
#
# DNS helper procedures.
#
# -------------------------------------------------------------------------

proc ::spf::Resolve {domain type resultproc} {
    if {[info command $resultproc] == {}} {
        return -code error "invalid arg: \"$resultproc\" must be a command"
    }
    set tok [dns::resolve $domain -type $type]
    dns::wait $tok
    if {[dns::status $tok] eq "ok"} {
        set result [$resultproc $tok]
        set code   ok
    } else {
        set result [dns::error $tok]
        set code   error
    }
    dns::cleanup $tok
    return -code $code $result
}

proc ::spf::SPF {domain} {
    set r [Resolve $domain SPF ::dns::result]
    set txt ""
    foreach res $r {
        set ndx [lsearch $res rdata]
        incr ndx
        if {$ndx != 0} {
            append txt [string range [lindex $res $ndx] 1 end]
        }
    }
    return $txt
}

proc ::spf::TXT {domain} {
    set r [Resolve $domain TXT ::dns::result]
    set txt ""
    foreach res $r {
        set ndx [lsearch $res rdata]
        incr ndx
        if {$ndx != 0} {
            append txt [string range [lindex $res $ndx] 1 end]
        }
    }
    return $txt
}

proc ::spf::A {name} {
    return [Resolve $name A ::dns::address]
}

proc ::spf::PTR {addr} {
    return [Resolve $addr A ::dns::name]
}

proc ::spf::MX {domain} {
    set r [Resolve $domain MX ::dns::name]
    return [lsort -index 0 $r]
}

# -------------------------------------------------------------------------

# FIX ME - Factor these helpers out into an IPv4 address module or something.

proc ::spf::ip2x {ip {validate 0}} {
    set octets [split $ip .]
    if {[llength $octets] != 4} {
        set octets [lrange [concat $octets 0 0 0] 0 3]
    }
    if {$validate} {
        foreach oct $octets {
            if {$oct < 0 || $oct > 255} {
                return -code error "invalid ip address"
            }
        }
    }
    binary scan [binary format c4 $octets] H8 x
    return 0x$x
}

proc ::spf::ipmask {ip {bits {}}} {
    if {[string length $bits] < 1} { set bits 32 }
    set ipx [ip2x $ip]
    if {[string is integer $bits]} {
        set mask [expr {(0xFFFFFFFF << (32 - $bits)) & 0xFFFFFFFF}]
    } else {
        set mask [ip2x $bits]
    }
    return [format 0x%08x [expr {$ipx & $mask}]]
}
    
proc ::spf::is_ip4_addr {ip} {
    if {[catch {ip2x $ip true}]} {
        return 0
    }
    return 1
}

proc ::spf::splitspec {spec} {
    set bits 32
    set domain $spec
    set slash [string last / $spec]
    if {$slash != -1} {
        incr slash -1
        set domain [string range $spec 0 $slash]
        incr slash 2
        set bits [string range $spec $slash end]
    }
    return [list $domain $bits]
}
    
# -------------------------------------------------------------------------

package provide spf $::spf::version

# -------------------------------------------------------------------------
# Local Variables:
#   indent-tabs-mode: nil
# End:
