# autoproxy.tcl - Copyright (C) 2002 Pat Thoyts <patthoyts@users.sf.net>
#
# On Unix the standard for identifying the local HTTP proxy server
# seems to be to use the environment variable http_proxy or ftp_proxy and
# no_proxy to list those domains to be excluded from proxying.
#
# On Windows we can retrieve the Internet Settings values from the registry
# to obtain pretty much the same information.
#
# With this information we can setup a suitable filter procedure for the 
# Tcl http package and arrange for automatic use of the proxy.
#
# Example:
#   package require autoproxy
#   autoproxy::init
#   autoproxy::configure -basic -username ME -password SEKRET
#   set tok [http::geturl http://wiki.tcl.tk/]
#   http::data $tok
#
# There is a skeleton for supporting Digest or NTLM authorisation but
# this is not currently supported. This will probably need redesigning to
# support schemes that require negotiation.
#
# @(#)$Id: autoproxy.tcl,v 1.2 2004/07/19 09:22:16 patthoyts Exp $

namespace eval ::autoproxy {
    variable rcsid {$Id: autoproxy.tcl,v 1.2 2004/07/19 09:22:16 patthoyts Exp $}
    variable version 1.1.0
    variable options

    if {! [info exists options]} {
        array set options {
            proxy_host ""
            proxy_port 80
            no_proxy   {}
            basic      {} 
            digest     {} 
            ntlm       {}
        }
    }

    variable winregkey
    set winregkey [join {
        HKEY_CURRENT_USER
        Software Microsoft Windows
        CurrentVersion "Internet Settings"
    } \\]
}

# -------------------------------------------------------------------------
# Description:
#   Obtain configuration options for the server.
#
proc ::autoproxy::cget {option} {
    variable options
    switch -glob -- $option] {
        -ho* -
        -proxy_h* {set options(proxy_host)}
        -po* -
        -proxy_p* {set options(proxy_port)}
        -no* { set options(no_proxy) }
        -b*  { set options(basic) }
        -d*  { set options(digest) }
        -nt* { set options(ntlm) }
        default {
            set err [join [lsort [array names options]] ", -"]
            return -code error "bad option \"[lindex $args 0]\":\
                       must be one of -$options"
        }
    }
}

# -------------------------------------------------------------------------
# Description:
#  Configure the autoproxy package settings.
#  You may only configure one type of authorisation at a time as once we hit
#  -basic, -digest or -ntlm - all further args are passed to the protocol
#  specific script.
#
#  Of course, most of the point of this package is to fill as many of these
#  fields as possible automatically. You should call autoproxy::init to
#  do automatic configuration and then call this method to refine the details.
#
proc ::autoproxy::configure {args} {
    variable options

    if {[llength $args] == 0} {
        foreach {opt value} [array get options] {
            lappend r -$opt $value
        }
        return $r
    }

    while {[string match "-*" [lindex $args 0]]} {
        switch -glob -- [lindex $args 0] {
            -ho* -
            -proxy_h* {set options(proxy_host) [Pop args 1]}
            -po* -
            -proxy_p* {set options(proxy_port) [Pop args 1]}
            -no* { set options(no_proxy) [Pop args 1] }
            -b*  { Pop args; configure:basic $args ; break }
            -d*  { Pop args; configure:digest $args ; break }
            -nt* { Pop args; configure:ntlm $args ; break }
            --   { Pop args; break }
            default {
                set err [join [lsort [array names options]] ", -"]
                return -code error "bad option \"[lindex $args 0]\":\
                       must be one of -$options"
            }
        }
        Pop args
    }
}

# -------------------------------------------------------------------------
# Description:
#  Initialise the http proxy information from the environment or the
#  registry (Win32)
#
#  This procedure will load the http package and re-writes the
#  http::geturl method to add in the authorisation header.
#
#  A better solution will be to arrange for the http package to request the
#  authorisation key on receiving an authorisation reqest.
#
proc ::autoproxy::init {} {
    package require uri
    global tcl_platform
    global env
    variable winregkey
    variable options
    set no_proxy {}
    set httpproxy {}

    # Look for standard environment variables.
    if {[info exists env(http_proxy)]} {
        set httpproxy $env(http_proxy)
        if {[info exists env(no_proxy)]} {
            set no_proxy $env(no_proxy)
        }
    } else {
        if {$tcl_platform(platform) == "windows"} {
            package require registry 1.0
            array set reg {ProxyEnable 0 ProxyServer "" ProxyOverride {}}
            catch {
                # IE5 changed ProxyEnable from a binary to a dword value.
                switch -exact -- [registry type $winregkey "ProxyEnable"] {
                    dword {
                        set reg(ProxyEnable) [registry get $winregkey "ProxyEnable"]
                    }
                    binary {
                        set v [registry get $winregkey "ProxyEnable"]
                        binary scan $v i reg(ProxyEnable)
                    }
                    default { 
                        return -code error "unexpected type found for\
                               ProxyEnable registry item"
                    }
                }
                set reg(ProxyServer) [registry get $winregkey "ProxyServer"]
                set reg(ProxyOverride) [registry get $winregkey "ProxyOverride"]
            }
            if {![string is bool $reg(ProxyEnable)]} {
                set reg(ProxyEnable) 0
            }
            if {$reg(ProxyEnable)} {
                set httpproxy $reg(ProxyServer)
                set no_proxy  $reg(ProxyOverride)
            }
        }
    }

    # If we found something ...
    if {$httpproxy != {}} {
        # The http_proxy is supposed to be a URL - lets make sure.
        if {![regexp {\w://.*} $httpproxy]} {
            set httpproxy "http://$httpproxy"
        }
        
        # decompose the string.
        array set proxy [uri::split $httpproxy]

        # turn the no_proxy value into a tcl list
        set no_proxy [string map {; " " , " "} $no_proxy]

        # configure ourselves
        configure -proxy_host $proxy(host) \
            -proxy_port $proxy(port) \
            -no_proxy $no_proxy

        # Maybe the proxy url has authentication parameters?
        # At this time, only Basic is supported.
        if {[string length $proxy(user)] > 0} {
            configure -basic -username $proxy(user) -password $proxy(pwd)
        }

        # setup and configure the http package
        package require http
        http::config -proxyfilter [namespace origin filter]
    }
    return $httpproxy
}

# -------------------------------------------------------------------------
# Description:
#  Pop the nth element off a list. Used in options processing.
proc ::autoproxy::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# -------------------------------------------------------------------------

# Description:
#  Implement support for the Basic authentication scheme (RFC 2617).
# Options:
#  -user userid  - pass in the user ID (May require Windows NT domain
#                  as DOMAIN\\username)
#  -password pwd - pass in the user's password.
#  -realm realm  - pass in the http realm.
#
proc ::autoproxy::configure:basic {arglist} {
    variable options
    array set opts {user {} passwd {} realm {}}
    foreach {opt value} $arglist {
        switch -glob -- $opt {
            -u* { set opts(user) $value}
            -p* { set opts(passwd) $value}
            -r* { set opts(realm) $value}
            default {
                return -code error "invalid option \"$opt\": must be one of\
                     -username or -password or -realm"
            }
        }
    }

    # Not going to do this now.
    # If nothing was provided, assume they want an interactive prompt.
    #if {$opts(user) == {} || $opts(passwd) == {}} {
    #    package require BWidget
    #    set r [PasswdDlg .d -logintext $opts(user) -passwdtext $opts(passwd)]
    #    set opts(user) [lindex $r 0]
    #    set opts(passwd) [lindex $r 1]
    #}

    # Store the encoded string to avoid re-encoding all the time.
    package require base64
    set options(basic) [list "Proxy-Authorization" \
                            [concat "Basic" \
                                 [base64::encode $opts(user):$opts(passwd)]]]
    return
}

# -------------------------------------------------------------------------

# Description:
#  Implement support for the Digest authentication scheme (RFC nnnn).
# Options:
#  -user userid  - pass in the user ID (May require Windows NT domain
#                  as DOMAIN\\username)
#  -password pwd - pass in the user's password.
#  -realm domain - the authorization realm
#
proc ::autoproxy::configure:digest {arglist} {
    variable options
    array set opts {user {} passwd {} realm {}}
    foreach {opt value} $arglist {
        switch -glob -- $opt {
            -u* { set opts(user)   $value }
            -p* { set opts(passwd) $value }
            -r* { set opts(realm)  $value }
            default {
                return -code error "invalid option \"$opt\": must be one of\
                     -username, -realm or -password"
            }
        }
    }

    # If nothing was provided, assume they want an interactive prompt.
    if {$opts(user) == {} || $opts(passwd) == {}} {
        package require BWidget
        set r [PasswdDlg .d -title "Realm $opts(realm)" \
                   -logintext $opts(user) \
                   -passwdtext $opts(passwd)]
        set opts(user) [lindex $r 0]
        set opts(passwd) [lindex $r 1]
    }

    # Note: we only store the MD5 checksum of the password.
    package require md5
    set A1 [md5::md5 "$opts(user):$opts(realm):$opts(passwd)"]
    set options(digest) [list $opts(user) $opts(realm) $A1]
    return
}

# -------------------------------------------------------------------------
# Description:
#  Suport Microsoft's NTLM scheme
#  Not done as yet.
#
proc ::autoproxy::configure:ntlm {arglist} {
    variable options
    return -code error "NTLM authorization is not available"
}

# -------------------------------------------------------------------------
# Description:
#  An http package proxy filter. This attempts to work out is a request
#  should go via the configured proxy using a glob comparison against the
#  no_proxy list items. A typical no_proxy list might be
#   [list localhost *.my.domain.com 127.0.0.1]
#
#  If we are going to use the proxy - then insert the proxy authorization
#  header.
#
proc ::autoproxy::filter {host} {
    variable options

    if {$options(proxy_host) == {}} {
        return {}
    }
    
    foreach domain $options(no_proxy) {
        if {[string match $domain $host]} {
            return {}
        }
    }
    
    # Add authorisation header to the request (by Anders Ramdahl)
    upvar state State
    if {$options(basic) != {}} {
        set State(-headers) [concat $options(basic) $State(-headers)]
    } elseif {$options(digest) != {}} {
        # FIX ME there is more to Digest than this
        #set State(-headers) [linsert $State(-headers) 0 $options(digest)]
    }
    
    return [list $options(proxy_host) $options(proxy_port)]
}

# -------------------------------------------------------------------------

package provide autoproxy $::autoproxy::version

# -------------------------------------------------------------------------
#
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:
