# saslclient.tcl - Copyright (C) 2005 Pat Thoyts <patthoyts@users.sf.net>
#
# This is a SMTP SASL test client. It connects to a SMTP server and uses 
# the STARTTLS feature if available to switch to a secure link before 
# negotiating authentication using SASL.
#
# $Id: saslclient.tcl,v 1.1 2005/02/01 02:41:00 patthoyts Exp $

source [file join [file dirname [info script]] sasl.tcl]

package require sasl
package require base64
catch {package require sasl::ntlm}

proc ::Write {chan what} {
    puts "< $what"
    puts $chan $what
    return
}

proc ::Read {chan callback} {
    if {[eof $chan]} {
        fileevent $chan readable {}
        puts stderr "eof"
        eval $callback [list $chan 1 {}]
        return
    }
    if {[gets $chan line] != -1} {
        eval $callback [list $chan 0 $line]
    }
    return
}

proc ::Callback {chan eof line} {
    variable mechs
    variable tls
    variable ctx
    if {![info exists mechs]} {set mechs {}}
    if {$eof} { set ::forever 1; return }
    puts "> $line"
    switch -glob -- $line {
        "220 *" { 
            if {$tls} {
                set tls 0
                puts "| switching to SSL"
                fileevent $chan readable {}
                tls::import $chan
                catch {tls::handshake $chan} msg
                set mechs {}
                fileevent $chan readable [list Read $chan ::Callback]
            }
            Write $chan "EHLO [info host]" 
        }
        "250 *" {
            if {$tls} {
                Write $chan STARTTLS
            } else {
                set supported [sasl::mechanisms]
                puts "SASL mechanisms: $mechs\ncan do $supported"
                foreach mech $mechs {
                    if {[lsearch -exact $supported $mech] != -1} {
                        
                        set ctx [sasl::new -mechanism $mech \
                                     -callback [list \
                                                    [namespace origin saslcb]\
                                                    "a blob"]]
                        Write $chan "AUTH $mech"
                        return
                    }
                }
                puts "! No matching SASL mechanism found"
            }
        }
        "250-AUTH*" {
            set line [string trim [string range $line 9 end]]
            set mechs [concat $mechs [split $line]]
        }
        "250-STARTTLS*" {
            if {![catch {package require tls}]} {
                set tls 1
            }
        }
        "235 *" {
            Write $chan "QUIT" 
        }
        "334 *" {
            set challenge [string range $line 4 end]
            if {![catch {set dec [base64::decode $challenge]}]} {
                set challenge $dec
            }
            puts "> $challenge"
            set code [catch {sasl::step $ctx $challenge} err]
            if {! $code} {
                set rsp [sasl::response $ctx]
                puts "< $rsp"
                Write $chan [join [base64::encode $rsp] {}]
            } else {
                puts stderr "sasl error: $err"
                Write $chan "QUIT"
            }
        }
        "535*" {
            Write $chan QUIT
        }
        default {
        }
    }
}

proc ::saslcb {clientblob context command args} {
    global env
    upvar #0 $context ctx
    switch -exact -- $command {
        username {
            if {[info exists env(USERDOMAIN)] \
                    && $env(USERDOMAIN) eq "RENISHAW" \
                    && $ctx(mech) ne "NTLM" } {
                return "$env(USERDOMAIN)\\$env(USERNAME)"
            } else {
                return "$env(USERNAME)"
            }
        }
        password { 
            if {[info exists env(http_proxy_pass)]} {
                return "$env(http_proxy_pass)"
            } else {
                return "$env(PASSWORD)"
            }
        }
        realm {
            if {$ctx(mech) eq "NTLM"} {
                return "$env(USERDOMAIN)"
            } else {
                return "patthoyts.tk"
            }
        }
        hostname {
            return [info host]
        }
        default {
            return -code error "oops: client needs to write $command"
        }
    }
}

proc ::connect { server port } {
    variable mechs ; set mechs {}
    variable tls  ; set tls 0
    puts "Connect to $server:$port"
    set sock [socket $server $port]
    fconfigure $sock -buffering line -blocking 1 -translation {auto crlf}
    fileevent $sock readable [list Read $sock ::Callback]
    after 6000 {puts timeout ; set ::forever 1}
    vwait ::forever
    catch {close $sock}
    return
}

if {!$tcl_interactive} {
    catch {eval ::connect $argv} res
    puts $res
}
