#!/usr/bin/env tclsh
# request.tcl - A TclOO wrapper around the standard http/https packages
# Provides a `request` class with simple `get`, `post` and general
# `request` methods returning parsed response data.

package require Tcl 8.5
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
#   headers - header list to pass to http package
#   opts    - additional options list to pass to http package commands
#
# Response state is retained in:
#   lastToken, lastBody, lastCode, lastStatus, lastMeta

oo::class create request {
    # stored request properties
    variable req_method
    variable req_url
    variable req_body
    variable req_headers
    variable req_opts

    # instance variables to store last response
    variable lastToken
    variable lastBody
    variable lastCode
    variable lastStatus
    variable lastMeta

    constructor {{method ""} {url ""} {body ""} {headers {}} {opts {}}} {
        # Initialize instance request arguments.
        set req_method $method
        set req_url $url
        set req_body $body
        set req_headers $headers
        set req_opts $opts

        # Optional TLS registration if opts contains -tls 1.
            array set __optarr $req_opts
            if {[info exists __optarr(-tls)] && $__optarr(-tls)} {
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
    }

    method configure {args {}} {
        # Configure one or more stored attributes.
        # If called without arguments, returns a dict of current config values.
            if {[llength $args] == 0} {
            return [dict create method $req_method url $req_url body $req_body headers $req_headers opts $req_opts]
        }

        # If single dict argument provided, apply its entries
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
                        opts { set req_opts $v }
                        default { throw {request Configure} "unknown configure key $k" }
                    }
                }
                return
            }
        }

        # Otherwise expect key value pairs: -method GET -url ... or method GET url ...
        set i 0
        while {$i < [llength $args]} {
            set key [lindex $args $i]; incr i
            if {$i >= [llength $args]} { throw {request Configure} "configure requires a value for $key" }
            set val [lindex $args $i]; incr i
            set key [string trimleft $key -]
            switch -- $key {
                method { set req_method $val }
                url { set req_url $val }
                body { set req_body $val }
                headers { set req_headers $val }
                opts { set req_opts $val }
                default { throw {request Configure} "unknown configure key $key" }
            }
        }
    }

    method request {method url {body ""} {headers {}} {opts {}} } {
        # Stateless helper for a single HTTP request.
        # Returns a dict-like list with body/code/status/headers/token.
        set m [string tolower $method]
        if {[string match post $m]} {
            if {$body eq ""} {
                set token [::http::posturl $url {} -headers $headers {*}$opts]
            } else {
                set token [::http::posturl $url $body -headers $headers {*}$opts]
            }
        } elseif {[string match get $m]} {
            set token [::http::geturl $url -headers $headers {*}$opts]
        } else {
            set token [::http::geturl $url -method $method -headers $headers {*}$opts]
        }

        set lastToken $token
        set lastBody [::http::data $token]
        set lastCode [::http::ncode $token]
        set lastStatus [::http::status $token]
        if {[try {
            array set mdata [::http::meta $token]
        } on error {msg} {
            set lastMeta {}
            return
        }]} { set lastMeta mdata } else { set lastMeta {} }

        return [list body $lastBody code $lastCode status $lastStatus headers $lastMeta token $lastToken]
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
        set opts $req_opts

        try {
            if {[string match post $m]} {
                if {$body eq ""} {
                    set token [::http::posturl $url {} -headers $headers {*}$opts]
                } else {
                    set token [::http::posturl $url $body -headers $headers {*}$opts]
                }
            } elseif {[string match get $m]} {
                set token [::http::geturl $url -headers $headers {*}$opts]
            } else {
                set token [::http::geturl $url -method $req_method -headers $headers {*}$opts]
            }
        } on error {err} {
            throw {request HTTP} "HTTP request failed: $err"
        }

        set lastToken $token
        set lastBody [::http::data $token]
        set lastCode [::http::ncode $token]
        set lastStatus [::http::status $token]
        if {[try {
            array set mdata [::http::meta $token]
        } on error {msg} {
            set lastMeta {}
            return
        }]} { set lastMeta mdata } else { set lastMeta {} }

        if {![string match 2* $lastCode]} {
            throw {request HTTP} "HTTP request returned non-2xx status: $lastCode ($lastStatus)"
        }

        return $lastBody
    }

    method get {url {headers {}} {opts {}} } {
        return [my request GET $url "" $headers $opts]
    }

    method post {url {body ""} {headers {}} {opts {}} } {
        return [my request POST $url $body $headers $opts]
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
            opts { return $req_opts }
            lastBody { return $lastBody }
            lastCode { return $lastCode }
            lastStatus { return $lastStatus }
            lastMeta { return $lastMeta }
            lastToken { return $lastToken }
            default { throw {request Attribute} "unknown attribute $attr" }
        }
    }

    # Use `lastResponse` to retrieve the last response data
}

package provide request 1.0
