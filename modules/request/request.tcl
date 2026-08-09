#!/usr/bin/env tclsh
# request.tcl - A TclOO wrapper around the standard http/https packages
# Provides a `request` class with simple `get`, `post` and general
# `request` methods returning parsed response data.

package require Tcl 8.6
package require http

# request -- HTTP/HTTPS request wrapper
#
# This class wraps the Tcl http package with a simple object-oriented API.
# It stores request parameters on the instance and executes the request via
# `execute`. The class provides a stateless `request` helper for one-shot calls
# as well as `configure`/`cget` for managing stored request attributes.
#
# Attributes:
#   method  - HTTP method to use (GET, POST, PUT, DELETE, etc.)
#   url     - request URL
#   body    - request body for POST/PUT methods
#   headers - header list to pass to the http package
#   tls     - optional boolean used by the constructor to enable TLS support
#             for HTTPS requests via ::tls::socket
#   Any supported ::http::geturl option may also be stored as its own
#   configure attribute.
#
# Response state is retained in:
#   lastToken, lastBody, lastCode, lastStatus, lastMeta

oo::class create request {
    # stored request properties
    variable req_method
    variable req_url
    variable req_body
    variable req_headers
    variable req_http_opts

    # instance variables to store last response
    variable lastToken
    variable lastBody
    variable lastCode
    variable lastStatus
    variable lastMeta

    constructor {{method ""} {url ""} args} {
        # Initialize instance request arguments.
        set req_method $method
        set req_url $url
        set req_body ""
        set req_headers {}
        if {[llength $args] % 2 != 0} {
            throw {request Configure} "constructor requires an even number of option arguments"
        }
        set req_http_opts {}
        foreach {key value} $args {
            set key [string trimleft $key -]
            switch -- $key {
                body { set req_body $value }
                headers { set req_headers $value }
                default { dict set req_http_opts $key $value }
            }
        }

        if {[dict exists $req_http_opts tls]} {
            if {[dict get $req_http_opts tls]} {
                try {
                    package require tls
                } on error {msg} {
                    throw {request TLS} "failed to load tls package: $msg"
                }
                try {
                    ::http::register https 443 ::tls::socket
                } on error {msg} {
                    # ignore registration failures
                }
            }
            dict unset req_http_opts tls
        }
    }

    method _doHttpConfig {} {
        set configure_options {}
        foreach key {accept proxyhost proxyport proxyfilter urlencoding useragent} {
            if {[dict exists $req_http_opts $key]} {
                lappend configure_options -$key [dict get $req_http_opts $key]
            }
        }
        if {[llength $configure_options] > 0} {
            ::http::configure configure {*}$configure_options
        }
    }

    method _performHttpRequest {url method body headers opts} {
        if {[string match post $method]} {
            if {$body eq ""} {
                return [::http::posturl $url {} -headers $headers {*}$opts]
            }
            return [::http::posturl $url $body -headers $headers {*}$opts]
        } elseif {[string match get $method]} {
            return [::http::geturl $url -headers $headers {*}$opts]
        }
        return [::http::geturl $url -method $method -headers $headers {*}$opts]
    }

    method configure {args} {
        # Configure one or more stored attributes.
        # If called without arguments, returns a dict of current config values.
        if {[llength $args] == 0} {
            return [dict create method $req_method url $req_url body $req_body headers $req_headers {*}$req_http_opts]
        }

        if {[llength $args] == 1} {
            set maybe [lindex $args 0]
            if {[try {
                dict size $maybe
            } on error {msg} {
                return -code error $msg
            }]} {
                dict for {k v} $maybe {
                    set key [string trimleft $k -]
                    switch -- $key {
                        method { set req_method $v }
                        url { set req_url $v }
                        body { set req_body $v }
                        headers { set req_headers $v }
                        default { dict set req_http_opts $key $v }
                    }
                }
                return
            }
        }

        if {[llength $args] % 2 != 0} {
            throw {request Configure} "configure requires an even number of key/value arguments"
        }
        foreach {key val} $args {
            set key [string range $key 1 end] ;# strip leading dash
            switch -- $key {
                method { set req_method $val }
                url { set req_url $val }
                body { set req_body $val }
                headers { set req_headers $val }
                default { dict set req_http_opts $key $val }
            }
        }

    }

    method request {method url args} {
        # Stateless helper for a single HTTP request.
        # The body and headers may be passed in via args as named options,
        # and all other valid ::http::geturl options are forwarded as well.
        set req_method $method
        set req_url $url
        set req_body ""
        set req_headers {}
        set req_http_opts {}

        if {[llength $args] % 2 != 0} {
            throw {request Configure} "request requires an even number of option arguments"
        }
        foreach {key value} $args {
            set key [string trimleft $key -]
            switch -- $key {
                body { set req_body $value }
                headers { set req_headers $value }
                default { dict set req_http_opts $key $value }
            }
        }

        return [my execute]
    }

    method execute {} {
        # Execute the stored request parameters.
        # Throws an exception if the request fails or returns a non-2xx response.
        if {$req_method eq "" || $req_url eq ""} {
            throw {request Execute} "both method and url must be set before calling execute"
        }

        set m [string tolower $req_method]
        set url $req_url
        set body $req_body
        set headers $req_headers
        set opts {}
        set allowed [list \
            binary blocksize channel command handler keepalive method myaddr \
            progress protocol query queryblocksize querychannel queryprogress \
            strict timeout type validate]
        dict for {key value} $req_http_opts {
            if {[lsearch -exact $allowed $key] != -1} {
                lappend opts -$key $value
            }
        }

        set redirectCount 0
        set maxRedirects 5
        set redirectCodes {301 302 307 308}
        set currentUrl $url
        set token {}
        while {1} {
            if {[string match -nocase https://* $currentUrl]} {
                try {
                    package require tls
                } on error {msg} {
                    throw {request TLS} "failed to load tls package: $msg"
                }
                try {
                    ::http::register https 443 ::tls::socket
                } on error {msg} {
                    # ignore registration failures
                }
            }

            my _doHttpConfig

            try {
                set token [my _performHttpRequest $currentUrl $req_method $body $headers $opts]
            } on error {err} {
                throw {request HTTP} "HTTP request failed: $err"
            }

            set lastToken $token
            set lastBody [::http::data $token]
            set lastCode [::http::ncode $token]
            set lastStatus [::http::status $token]
            try {
                set lastMeta [::http::meta $token]
            } on error {msg} {
                set lastMeta {}
            }

            if {[lsearch -exact $redirectCodes $lastCode] != -1} {
                set location ""
                foreach {k v} $lastMeta {
                    if {[string tolower $k] eq "location"} {
                        set location $v
                        break
                    }
                }
                if {$location ne ""} {
                    if {$redirectCount >= $maxRedirects} {
                        throw {request HTTP} "too many redirects"
                    }
                    incr redirectCount
                    set currentUrl $location
                    continue
                }
            }

            if {![string match 2* $lastCode]} {
                throw [list request HTTP $lastCode] "HTTP request returned non-2xx status: $lastCode ($lastStatus)"
            }

            break
        }

        return $lastBody
    }

    method get {url args} {
        return [my request GET $url {*}$args]
    }

    method post {url args} {
        return [my request POST $url {*}$args]
    }

    method lastResponse {} {
        # Return the last response details from the most recent request.
        return [list body $lastBody code $lastCode status $lastStatus headers $lastMeta token $lastToken]
    }

    method cget {attr} {
        # Return the value of a named configuration or response attribute.
        switch -- $attr {
            method { return $req_method }
            url { return $req_url }
            body { return $req_body }
            headers { return $req_headers }
            lastBody { return $lastBody }
            lastCode { return $lastCode }
            lastStatus { return $lastStatus }
            lastMeta { return $lastMeta }
            lastToken { return $lastToken }
            default {
                if {[dict exists $req_http_opts $attr]} {
                    return [dict get $req_http_opts $attr]
                }
                throw {request Attribute} "unknown attribute $attr"
            }
        }
    }

    # Use `lastResponse` to retrieve the last response data
}

package provide request 1.0
