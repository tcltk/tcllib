# dns.tcl - Copyright (C) 2002 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Provide a Tcl only Domain Name Service client. See RFC 1034 and RFC 1035
# for information about the DNS protocol. This should insulate Tcl scripts
# from problems with using the system library resolver for slow name servers.
#
# This implementation uses TCP only for DNS queries. The protocol reccommends
# that UDP be used in these cases but Tcl does not include UDP sockets by
# default. The package should be simple to extend to use a TclUDP extension
# in the future.
#
# TODO:
#  - When using tcp we should make better use of the open connection and
#    send multiple queries along the same connection.
#  - Implement a name cache to reduce the number of queries made.
#  - Implement UDP support.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
#
# $Id: dns.tcl,v 1.3 2002/06/07 17:16:50 andreas_kupries Exp $

package require log;                    # tcllib 1.0
package require uri;                    # tcllib 1.1
package require uri::urn;               # tcllib 1.2

namespace eval dns {
    variable version 1.0.1
    variable rcsid {$Id: dns.tcl,v 1.3 2002/06/07 17:16:50 andreas_kupries Exp $}

    namespace export configure resolve name address cname \
        status reset wait cleanup
}

# -------------------------------------------------------------------------

# Description:
#  Configure the DNS package. In particular the local nameserver will need
#  to be set. With no options, returns a list of all current settings.
#
proc dns::configure {args} {
    variable options

    if {[llength $args] < 1} {
        set r {}
        foreach opt [lsort [array names options]] {
            lappend r -$opt $options($opt)
        }
        return $r
    }

    set cget 0
    if {[llength $args] == 1} {
        set cget 1
    }
   
    while {[string match -* [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -n* -
            -ser* {
                if {$cget} {
                    return $options(nameserver) 
                } else {
                    set options(nameserver) [Pop args 1] 
                }
            }
            -po*  { 
                if {$cget} {
                    return $options(port)
                } else {
                    set options(port) [Pop args 1] 
                }
            }
            -ti*  { 
                if {$cget} {
                    return $options(timeout)
                } else {
                    set options(timeout) [Pop args 1]
                }
            }
            -pr*  {
                if {$cget} {
                    return $options(protocol)
                } else {
                    set options(protocol) [Pop args 1] 
                }
            }
            -sea* { 
                if {$cget} {
                    return $options(search)
                } else {
                    set options(search) [Pop args 1] 
                }
            }
            -log* {
                if {$cget} {
                    return $options(loglevel)
                } else {
                    set options(loglevel) [Pop args 1]
                    log::lvSuppressLE emergency 0
                    log::lvSuppressLE $options(loglevel) 1
                    log::lvSuppress $options(loglevel) 0
                }                    
            }
            --    { Pop args ; break }
            default {
                set opts [join [lsort [array names options]] ", -"]
                return -code error "bad option [lindex $args 0]:\
                        must be one of -$opts"
            }
        }
        Pop args
    }

    return
}

# -------------------------------------------------------------------------

# Description:
#  Create a DNS query and send to the specified name server. Returns a token
#  to be used to obtain any further information about this query.
#
proc dns::resolve {query args} {
    variable uid
    variable options
    set id [incr uid]
    set token [namespace current]::$id
    variable $token
    upvar 0 $token state

    # Setup token/state defaults.
    set state(id)          $id
    set state(query)       $query
    set state(opcode)      0;                   # 0 = query, 1 = inverse query.
    set state(-type)       A;                   # DNS record type (A address)
    set state(-class)      IN;                  # IN (internet address space)
    set state(-recurse)    1;                   # Recursion Desired
    set state(-command)    {};                  # asynchronous handler
    set state(-timeout)    $options(timeout);   # connection timeout default.
    set state(-nameserver) $options(nameserver);# default nameserver
    set state(-port)       $options(port);      # default namerservers port
    set state(-search)     $options(search);    # domain search list
    set state(-protocol)   $options(protocol);  # which protocol udp/tcp

    # Handle DNS URL's
    if {[string match "dns:*" $query]} {
        array set URI [uri::split $query]
        foreach {opt value} [uri::split $query] {
            if {$value != {} && [info exists state(-$opt)]} {
                set state(-$opt) $value
            }   
        }
        set state(query) $URI(query)
        log::log debug "parsed query: $query"
    }

    while {[string match -* [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -n* - ns -
            -ser* { set state(-nameserver) [Pop args 1] }
            -po*  { set state(-port) [Pop args 1] }
            -ti*  { set state(-timeout) [Pop args 1] }
            -co*  { set state(-command) [Pop args 1] }
            -cl*  { set state(-class) [Pop args 1] }
            -ty*  { set state(-type) [Pop args 1] }
            -pr*  { set state(-protocol) [Pop args 1] }
            -sea* { set state(-search) [Pop args 1] }
            -re*  { set state(-recurse) [Pop args 1] }
            --    { Pop args ; break }
            default {
                set opts [join [lsort [array names state -*]] ", "]
                return -code error "bad option [lindex $args 0]: \
                        must be $opts"
            }
        }
        Pop args
    }

    if {$state(-nameserver) == {}} {
        return -code error "no nameserver specified"
    }

    if {$state(-protocol) != "tcp"} {
        return -code error "udp support is not yet available"
    }

    BuildMessage $token
    
    if {$state(-protocol) == "tcp"} {
        TcpTransmit $token
        if {$state(-command) == {}} {
            wait $token
        }
    }
    
    return $token
}

# -------------------------------------------------------------------------

# Description:
#  Return a list of domain names returned as results for the last query.
#
proc dns::name {token} {
    set r {}
    array set reply [Decode $token]
    foreach answer $reply(AN) {
        array set AN $answer

        if {[info exist AN(name)]} {
            lappend r $AN(name)
        }
    }
    return $r
}

# Description:
#  Return a list of the IP addresses returned for this query.
#
proc dns::address {token} {
    set r {}
    array set reply [Decode $token]
    foreach answer $reply(AN) {
        array set AN $answer

        if {[info exist AN(type)]} {
            if {$AN(type) == "A"} {
                lappend r $AN(rdata)
            }
        }
    }
    return $r
}

# Description:
#  Return a list of all CNAME results returned for this query.
#
proc dns::cname {token} {
    set r {}
    array set reply [Decode $token]
    foreach answer $reply(AN) {
        array set AN $answer

        if {[info exist AN(type)]} {
            if {$AN(type) == "CNAME"} {
                lappend r $AN(rdata)
            }
        }
    }
    return $r
}
# -------------------------------------------------------------------------

# Description:
#  Get the status of the request.
#
proc dns::status {token} {
    variable $token
    upvar 0 $token state
    return $state(status)
}

# Description:
#  Get the error message. Empty if no error.
#
proc dns::error {token} {
    variable $token
    upvar 0 $token state
    if {[info exists state(error)]} {
	return $state(error)
    }
    return ""
}

# Description:
#  Reset a connection with optional reason.
#
proc dns::reset {token {why reset}} {
    variable $token
    upvar 0 $token state
    set state(status) $why
    catch {fileevent $state(sock) readable {}}
    Finish $token
}

# Description:
#  Wait for a request to complete and return the status.
#
proc dns::wait {token} {
    variable $token
    upvar 0 $token state

    if {$state(status) == "connect"} {
        vwait [subst $token](status)
    }

    return $state(status)
}

# Description:
#  Remove any state associated with this token.
#
proc dns::cleanup {token} {
    variable $token
    upvar 0 $token state
    if {[info exists state]} {
        unset state
    }
}

# -------------------------------------------------------------------------

# Description:
#  Dump the raw data of the request and reply packets.
#
proc dns::dump {args} {
    if {[llength $args] == 1} {
        set type -reply
        set token [lindex $args 0]
    } elseif { [llength $args] == 2 } {
        set type [lindex $args 0]
        set token [lindex $args 1]
    } else {
        error "wrong # args: should be \"dump ?option? methodName\""
    }

    variable $token
    upvar 0 $token state
    
    set result {}
    switch -glob -- $type {
        -qu*    -
        -req*   {
            set result [DumpMessage $state(request)]
        }
        -rep*   {
            set result [DumpMessage $state(reply)]
        }
        default {
            error "unrecognised option: must be one of \
                    \"-query\", \"-request\" or \"-reply\""
        }
    }

    return $result
}

# Description:
#  Perform a hex dump of binary data.
#
proc dns::DumpMessage {data} {
    set result {}
    binary scan $data c* r
    foreach c $r {
        append result [format "%02x " [expr {$c & 0xff}]]
    }
    return $result
}

# -------------------------------------------------------------------------

# Description:
#  Contruct a DNS query packet.
#
proc dns::BuildMessage {token} {
    variable $token
    upvar 0 $token state
    variable types
    variable classes
    variable options

    if {! [info exists types($state(-type))] } {
        return -code error "invalid DNS query type"
    }

    if {! [info exists classes($state(-class))] } {
        return -code error "invalid DNS query class"
    }

    set qdcount 0
    set qsection {}

    # In theory we can send multiple queries. In practice, named doesn't
    # appear to like that much. If it did work we'd do this:
    #  foreach domain [linsert $options(search) 0 {}] ...

    set qname [string trim $state(query) .]
    
    # break up the name into length tagged 'labels'
    foreach part [split $qname .] {
        set label [binary format c [string length $part]]
        append qsection $label $part
    }
    # append the root label and the type flag and query class.
    append qsection [binary format cSS 0 \
            $types($state(-type))\
            $classes($state(-class))]
    incr qdcount

    set state(request) [binary format SSSSSS $state(id) \
            [expr {($state(opcode) << 11) | ($state(-recurse) << 8)}] \
            $qdcount 0 0 0]
    append state(request) $qsection

    return
}

# -------------------------------------------------------------------------

# Description:
#  Transmit a DNS request over a tcp connection.
#
proc dns::TcpTransmit {token} {
    variable $token
    upvar 0 $token state

    # For TCP the message must be prefixed with a 16bit length field.
    set req [binary format S [string length $state(request)]]
    append req $state(request)

    # setup the timeout
    if {$state(-timeout) > 0} {
        set state(after) [after $state(-timeout) \
                              [list [namespace origin reset] $token timeout]]
    }

    set s [socket $state(-nameserver) $state(-port)]
    fconfigure $s -blocking 0 -translation binary -buffering none
    set state(sock) $s
    set state(status) connect

    puts -nonewline $s $req

    fileevent $s readable [list [namespace current]::TcpEvent $token]
    
    return $token
}

# -------------------------------------------------------------------------

# Description:
#  Tidy up after a tcp transaction.
#
proc dns::Finish {token {errormsg ""}} {
    variable $token
    upvar 0 $token state
    global errorInfo errorCode

    if {[string length $errormsg] != 0} {
	set state(error) $errormsg
	set state(status) error
    }
    catch {close $state(sock)}
    catch {after cancel $state(after)}
    if {[info exists state(-command)] && $state(-command) != {}} {
	if {[catch {eval $state(-command) {$token}} err]} {
	    if {[string length $errormsg] == 0} {
		set state(error) [list $err $errorInfo $errorCode]
		set state(status) error
	    }
	}
        if {[info exist state(-command)]} {
            unset state(-command)
        }
    }
}

# -------------------------------------------------------------------------

# Description:
#  Handle end-of-file on a tcp connection.
#
proc dns::Eof {token} {
    variable $token
    upvar 0 $token state
    set state(status) eof
    Finish $token
}

# -------------------------------------------------------------------------

# Description:
#  Process a DNS reply packet (protocol independent)
#
proc dns::Receive {token data} {
    variable $token
    upvar 0 $token state

    binary scan $data SS id flags
    set status [expr {$flags & 0x000F}]

    append state(reply) $data
    switch -- $status {
        0 {
            set state(status) ok
            Finish $token 
        }
        1 { Finish $token "Format error - unable to interpret the query." }
        2 { Finish $token "Server failure - internal server error." }
        3 { Finish $token "Name Error - domain does not exist" }
        4 { Finish $token "Not implemented - the query type is not available." }
        5 { Finish $token "Refused - your request has been refused by the server." }
        default {
            Finish $token "unrecognised error code: $err"
        }
    }
}

# -------------------------------------------------------------------------

# Description:
#  file event handler for tcp socket. Wait for the reply data.
#
proc dns::TcpEvent {token} {
    variable $token
    upvar 0 $token state
    set s $state(sock)

    if {[eof $s]} {
        Eof $token
        return
    }

    set status [catch {read $state(sock)} result]
    if {$status != 0} {
        log::log debug "Event error: $result"
        Finish $tok "error reading data: $result"
    } elseif { [string length $result] >= 0 } {
        # check the length and flags and chop off the tcp length prefix.
        binary scan $result SSS length id flags
        set payload [string range $result 2 end]
        set id [expr {$id & 0xFFFF}]
        set trunc [expr {$flags & 0x0040}]
        log::log debug "Event read: [string length $payload] should be $length"
        # handle the correct request based on the contained ID
        Receive [namespace current]::$id $payload
    } elseif { [eof $state(sock)] } {
        Eof $token
    } elseif { [fblocked $state(sock)] } {
        log::log debug "Event blocked"
    } else {
        log::log critical "Event error: this can't happen!"
        Finish $tok "Event error: this can't happen!"
    }
}

# -------------------------------------------------------------------------

# Description:
#  Decode a DNS packet (either query or response).
#
proc dns::Decode {token args} {
    variable $token
    upvar 0 $token state

    binary scan $state(reply) SSSSSSc* mid hdr nQD nAN nNS nAR data

    set info "Message ID: $mid\
              Flags: [format 0x%02X [expr {$hdr & 0xFFFF}]]\
              NQ: $nQD\
              NA: $nAN\
              NS: $nNS\
              AR: $nAR"
    log::log debug $info

    set ndx 12
    set r {}
    set QD [ReadQuestion $nQD $state(reply) ndx]
    lappend r QD $QD
    set AN [ReadAnswer $nAN $state(reply) ndx]
    lappend r AN $AN
    set NS [ReadAnswer $nNS $state(reply) ndx]
    lappend r NS $NS
    set AR [ReadAnswer $nAR $state(reply) ndx]
    lappend r AR $AR
    return $r
}

# -------------------------------------------------------------------------

proc dns::Expand {data} {
    set r {}
    binary scan $data c* d
    foreach c $d {
        lappend r [expr {$c & 0xFF}]
    }
    return $r
}

# -------------------------------------------------------------------------
# Description:
#  Pop the nth element off a list. Used in options processing.
#
proc dns::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# -------------------------------------------------------------------------

proc dns::KeyOf {arrayname value {default {}}} {
    upvar $arrayname array
    set lst [array get array]
    set ndx [lsearch -exact $lst $value]
    if {$ndx != -1} {
        incr ndx -1
        set r [lindex $lst $ndx]
    } else {
        set r $default
    }
    return $r
}


# -------------------------------------------------------------------------
# Read the question section from a DNS message. This always starts at index
# 12 of a message but may be of variable length.
#
proc dns::ReadQuestion {nitems data indexvar} {
    variable types
    variable classes
    upvar $indexvar index
    set result {}

    for {set cn 0} {$cn < $nitems} {incr cn} {
        set r {}
        lappend r name [ReadName data $index offset]
        incr index $offset
        
        # Read off QTYPE and QCLASS for this query.
        set ndx $index
        incr index 3
        binary scan [string range $data $ndx $index] SS qtype qclass
        set qtype [expr {$qtype & 0xFFFF}]
        set qclass [expr {$qclass & 0xFFFF}]
        incr index
        lappend r type [KeyOf types $qtype $qtype] \
                  class [KeyOf classes $qclass $qclass]
        lappend result $r
    }
    return $result
}
        
# -------------------------------------------------------------------------

# Read an answer section from a DNS message. 
#
proc dns::ReadAnswer {nitems data indexvar} {
    variable types
    variable classes
    upvar $indexvar index
    set result {}

    for {set cn 0} {$cn < $nitems} {incr cn} {
        set r {}
        lappend r name [ReadName data $index offset]
        incr index $offset
        
        # Read off TYPE, CLASS, TTL and RDLENGTH
        binary scan [string range $data $index end] SSIS type class ttl rdlength

        set type [expr {$type & 0xFFFF}]
        set type [KeyOf types $type $type]

        set class [expr {$class & 0xFFFF}]
        set class [KeyOf classes $class $class]

        set ttl [expr {$ttl & 0xFFFFFFFF}]
        set rdlength [expr {$rdlength & 0xFFFF}]
        incr index 10
        set rdata [string range $data $index [expr {$index + $rdlength - 1}]]

        switch -- $type {
            A {
                set rdata [join [Expand $rdata] .] 
            }
            NS - CNAME - PTR {
                set rdata [ReadName data $index off] 
            }
            MX {
                binary scan $rdata S preference
                set exchange [ReadName data [expr {$index + 2}] off]
                set rdata [list $preference $exchange]
            }
        }

        incr index $rdlength
        lappend r type $type class $class ttl $ttl rdlength $rdlength rdata $rdata
        lappend result $r
    }
    return $result
}


# Read off the NAME or QNAME element. This reads off each label in turn, 
# dereferencing pointer labels until we have finished. The length of data
# used is passed back using the usedvar variable.
#
proc dns::ReadName {datavar index usedvar} {
    upvar $datavar data
    upvar $usedvar used
    set startindex $index

    set r {}
    set len 1
    set max [string length $data]
    
    while {$len != 0 && $index < $max} {
        # Read the label length (and preread the pointer offset)
        binary scan [string range $data $index end] cc len lenb
        set len [expr {$len & 0xFF}]
        incr index
        
        if {$len != 0} {
            if {[expr {$len & 0xc0}]} {
                binary scan [binary format cc [expr {$len & 0x3f}] [expr {$lenb & 0xff}]] S offset
                incr index
                lappend r [ReadName data $offset junk]
                set len 0
            } else {
                lappend r [string range $data $index [expr {$index + $len - 1}]]
                incr index $len
            }
        }
    }
    set used [expr {$index - $startindex}]
    return [join $r .]
}

# -------------------------------------------------------------------------
# Possible support for the DNS URL scheme.
# Ref: http://www.ietf.org/internet-drafts/draft-josefsson-dns-url-04.txt
# eg: dns:target?class=IN;type=A
#     dns://nameserver/target?type=A
#
# URI quoting to be accounted for.
#

catch {
    uri::register {dns} {
        set escape     [set [namespace parent [namespace current]]::basic::escape]
        set host       [set [namespace parent [namespace current]]::basic::host]
        set hostOrPort [set [namespace parent [namespace current]]::basic::hostOrPort]
        set classValues [string map "* \\\\*" \
                             [join [array names ::dns::classes] "|"]]
        set typeValues [string map "* \\\\*" \
                            [join [array names ::dns::types] "|"]]
        set class "class=(${classValues})"
        set type "type=(${typeValues})"
        set classOrType "(${class})|(${type})"
        set classOrTypeSpec "\\?${classOrType}(;${classOrType})?"
        
        set query "${host}(${classOrTypeSpec})?"
        variable schemepart "(//${hostOrPort}/)?(${query})"
        variable url "dns:$schemepart"
    }
}

namespace eval uri {} ;# needed for pkg_mkIndex.

proc uri::SplitDns {uri} {
    upvar \#0 [namespace current]::dns::schemepart schemepart
    upvar \#0 [namespace current]::dns::class classRE
    upvar \#0 [namespace current]::dns::type typeRE
    upvar \#0 [namespace current]::dns::classOrTypeSpec classOrTypeSpec

    array set parts {nameserver {} query {} class {} type {} port {}}

    # validate the uri
    if {[regexp $dns::schemepart $uri r] == 1} {

        # deal with the optional class and type specifiers
        if {[regexp -indices -- "${classOrTypeSpec}$" $uri range]} {
            set spec [string range $uri [lindex $range 0] [lindex $range 1]]
            set uri [string range $uri 0 [expr {[lindex $range 0] - 2}]]

            if {[regexp -- "$classRE" $spec -> class]} {
                set parts(class) $class
            }
            if {[regexp -- "$typeRE" $spec -> type]} {
                set parts(type) $type
            }
        }

        # Handle the nameserver specification
        if {[string match "//*" $uri]} {
            set uri [string range $uri 2 end]
            array set tmp [GetHostPort uri]
            set parts(nameserver) $tmp(host)
            set parts(port) $tmp(port)
        }
        
        # what's left is the query domain name.
        set parts(query) [string trimleft $uri /]
    }

    return [array get parts]
}

proc uri::JoinDns {args} {
    array set parts {nameserver {} port {} query {} class {} type {}}
    array set parts $args
    set query [::uri::urn::quote $parts(query)]
    if {$parts(type) != {}} {
        append query "?type=$parts(type)"
    }
    if {$parts(class) != {}} {
        if {$parts(type) == {}} {
            append query "?class=$parts(class)"
        } else {
            append query ";class=$parts(class)"
        }
    }
    if {$parts(nameserver) != {}} {
        set ns "$parts(nameserver)"
        if {$parts(port) != {}} {
            append ns ":$parts(port)"
        }
        set query "//${ns}/${query}"
    }
    return "dns:$query"
}

# -------------------------------------------------------------------------
# Initialize variables, using the procedures defined above.

namespace eval dns {
    variable options
    if {![info exists options]} {
        array set options {
            port       53
            timeout    30000
            protocol   tcp
            search     {}
            nameserver {localhost}
            loglevel   warning
        }
        configure -loglevel $options(loglevel)
    }

    variable types
    array set types { 
        A 1  NS 2  MD 3  MF 4  CNAME 5  SOA 6  MB 7  MG 8  MR 9 
        NULL 10  WKS 11  PTR 12  HINFO 13  MINFO 14  MX 15  TXT 16
        AXFR 252  MAILB 253  MAILA 254  * 255
    } 

    variable classes
    array set classes { IN 1  CS 2  CH  3  HS 4  * 255}

    variable uid
    if {![info exists uid]} {
        set uid 0
    }
}

# -------------------------------------------------------------------------

package provide dns $dns::version

# -------------------------------------------------------------------------
# Local Variables:
#   indent-tabs-mode: nil
# End:
