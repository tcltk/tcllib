# example.tcl - Copyright (C) 2001 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# Simple test of the mail server. All incoming messages are displayed in a 
# dialog box.
#
# -------------------------------------------------------------------------
# This software is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the file 'license.terms' for
# more details.
# -------------------------------------------------------------------------

package require smtpd
package require Tk

proc deliver {sender recipients data} {
    if {[catch {eval array set saddr [mime::parseaddress $sender]}]} {
        error "invalid sender address \"$sender\""
    }
    set mail "From $saddr(address) [clock format [clock seconds]]"
    append mail "\n" [join $data "\n"]

    foreach rcpt $recipients {
        if {! [catch {eval array set addr [mime::parseaddress $rcpt]}]} {
            tk_messageBox -title "To: $addr(address)" -message $mail
        }
    }
}

proc validate_host {ipnum} {
    if {[string match "192.168.1.*" $ipnum]} {
        error "your domain is not allowed to post, Spammers!"
    }
}

proc validate_sender {address} {
    eval array set addr [mime::parseaddress $address]
    if {[string match "denied" $addr(local)]} {
        error "mailbox $addr(local) denied"
    }
    return    
}

proc validate_recipient {address} {
    eval array set addr [mime::parseaddress $address]
    if {! [string match "soap*" $addr(local)]} {
        error "mailbox $addr(local) denied"
    }
    return
}

smtpd::configure \
    -deliver            ::deliver \
    -validate_host      ::validate_host \
    -validate_recipient ::validate_recipient \
    -validate_sender    ::validate_sender

smtpd::start
