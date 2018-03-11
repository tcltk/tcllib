###
# Return data from an SCGI process
###
::tool::define ::httpd::content.scgi {
  superclass ::httpd::content.cgi

  method scgi_info {} {
    ###
    # This method should check if a process is launched
    # or launch it if needed, and return a list of
    # HOST PORT SCRIPT_NAME
    ###
    # return {localhost 8016 /some/path}
    error unimplemented
  }

  method proxy_channel {} {
    set sockinfo [my scgi_info]
    if {$sockinfo eq {}} {
      my error 404 {Not Found}
      tailcall my DoOutput
    }
    lassign $sockinfo scgihost scgiport scgiscript
    my http_info set SCRIPT_NAME $scgiscript
    return [::socket $scgihost $scgiport]
  }

  method ProxyRequest {chana chanb} {
    my wait writable $chanb
    chan configure $chana -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chanb -translation binary -blocking 0 -buffering full -buffersize 4096

    set info [dict create CONTENT_LENGTH 0 SCGI 1.0 SCRIPT_NAME [my http_info get SCRIPT_NAME]]
    foreach {f v} [my http_info dump] {
      dict set info $f $v
    }
    foreach {fo v} [my request dump] {
      set f $fo
      switch [string tolower $fo] {
        content-length {
          set f CONTENT_LENGTH
        }
        content-type {
          set f CONTENT_TYPE
        }
        default {
          if {[string range $f 0 3] ne "HTTP" && $f ne "CONTENT_TYPE"} {
            set f HTTP_[string map {- _} [string toupper $f]]
          }
        }
      }
      dict set info $f $v
    }
    set length [dict get $info CONTENT_LENGTH]
    set block {}
    foreach {f v} $info {
      append block [string toupper $f] \x00 $v \x00
    }
    chan puts -nonewline $chanb "[string length $block]:$block,"
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $chana $chanb -size $length -command [info coroutine]
      yield
    }
    chan flush $chanb
  }
}

tool::define ::httpd::reply.scgi {
  superclass ::httpd::reply

  method EncodeStatus {status} {
    return "Status: $status"
  }
}

###
# Act as an  SCGI Server
###
tool::define ::httpd::server.scgi {
  superclass ::httpd::server

  property socket buffersize   32768
  property socket blocking     0
  property socket translation  {binary binary}

  property reply_class ::httpd::reply.scgi

  method Connect {uuid sock ip} {
    yield [info coroutine]
    chan event $sock readable {}
    chan configure $sock \
        -blocking 1 \
        -translation {binary binary} \
        -buffersize 4096 \
        -buffering none
    my counter url_hit
    try {
      # Read the SCGI request on byte at a time until we reach a ":"
      dict set query REQUEST_URI /
      dict set query REMOTE_ADDR     $ip
      set size {}
      while 1 {
        set char [::coroutine::util::read $sock 1]
        if {[chan eof $sock]} {
          catch {close $sock}
          return
        }
        if {$char eq ":"} break
        append size $char
      }
      # With length in hand, read the netstring encoded headers
      set inbuffer [::coroutine::util::read $sock [expr {$size+1}]]
      chan configure $sock -blocking 0 -buffersize 4096 -buffering full
      foreach {f v} [lrange [split [string range $inbuffer 0 end-1] \0] 0 end-1] {
        dict set query $f $v
        if {$f in {CONTENT_LENGTH CONTENT_TYPE}} {
          dict set query http $f $v
        } elseif {[string range $f 0 4] eq "HTTP_"} {
          dict set query http [string range $f 5 end] $v
        }
      }
      if {![dict exists $query REQUEST_PATH]} {
        set uri [dict get $query REQUEST_URI]
        set uriinfo [::uri::split $uri]
        dict set query REQUEST_PATH    [dict get $uriinfo path]
      }
      set reply [my dispatch $query]
      dict with query {}
      if {[llength $reply]} {
        if {[dict exists $reply class]} {
          set class [dict get $reply class]
        } else {
          set class [my cget reply_class]
        }
        set pageobj [$class create [namespace current]::reply$uuid [self]]
        if {[dict exists $reply mixin]} {
          oo::objdefine $pageobj mixin [dict get $reply mixin]
        }
        $pageobj dispatch $sock $reply
        my log HttpAccess $REQUEST_URI
      } else {
        try {
          my log HttpMissing $REQUEST_URI
          chan puts $sock "Status: 404 NOT FOUND"
          dict with query {}
          set body [subst [my template notfound]]
          chan puts $sock "Content-Length: [string length $body]"
          chan puts $sock {}
          chan puts $sock $body
        } on error {err errdat} {
          my <server> debug "FAILED ON 404: $err [dict get $errdat -errorinfo]"
        } finally {
          catch {chan event readable $sock {}}
          catch {chan event writeable $sock {}}
          catch {chan close $sock}
        }
      }
    } on error {err errdat} {
      try {
        my <server> debug [dict get $errdat -errorinfo]
        chan puts $sock "Status: 500 INTERNAL ERROR - scgi 298"
        dict with query {}
        set body [subst [my template internal_error]]
        chan puts $sock "Content-Length: [string length $body]"
        chan puts $sock {}
        chan puts $sock $body
        my log HttpError $REQUEST_URI
      } on error {err errdat} {
        my log HttpFatal [my http_info get REMOTE_ADDR] [dict get $errdat -errorinfo]
        my <server> debug "Failed on 500: [dict get $errdat -errorinfo]""
      } finally {
        catch {chan event readable $sock {}}
        catch {chan event writeable $sock {}}
        catch {chan close $sock}
      }
    }
  }
}
