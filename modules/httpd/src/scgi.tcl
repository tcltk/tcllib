###
# Return data from an SCGI process
###
::tool::define ::httpd::content.scgi {

  method scgi_info {} {
    ###
    # This method should check if a process is launched
    # or launch it if needed, and return a list of
    # HOST PORT SCRIPT_NAME
    ###
    # return {localhost 8016 /some/path}
    error unimplemented
  }

  method content {} {
    my variable sock chan
    set sockinfo [my scgi_info]
    if {$sockinfo eq {}} {
      my error 404 {Not Found}
      return
    }
    lassign $sockinfo scgihost scgiport scgiscript
    set sock [::socket $scgihost $scgiport]

    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    ###
    # Convert our query headers into netstring format.
    ###
    if {![my request exists Content-Length]} {
      set length 0
    } else {
      set length [my request get Content-Length]
    }
    set block {}
    append block CONTENT_LENGTH \x00 $length \x00
    append block SCGI \x00 1.0 \x00
    append block SCRIPT_NAME \x00 $scgiscript \x00
    set info {}
    foreach {f v} [my http_info dump] {
      dict set info $f $v
    }
    foreach {f v} [my request dump] {
      if {[string range $f 0 3] ne "HTTP"} {
        set f HTTP_[string toupper $f]
      }
      dict set info $f $v
    }
    foreach {f v} $info {
      if {$f in {CONTENT_LENGTH HTTP_STATUS}} continue
      append block [string toupper $f] \x00 $v \x00
    }
    chan puts -nonewline $sock "[string length $block]:$block,"
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $chan $sock -size $length
    }
    chan flush $sock
    ###
    # Wake this object up after the SCGI process starts to respond
    ###
    #chan configure $sock -translation {auto crlf} -blocking 0 -buffering line
    chan event $sock readable [namespace code {my output}]
  }

  method output {} {
    if {[my http_info getnull HTTP_ERROR] ne {}} {
      ###
      # If something croaked internally, handle this page as a normal reply
      ###
      next
    }
    my variable sock chan
    set replyhead [my HttpHeaders $sock]
    set replydat  [my MimeParse $replyhead]
    if {![dict exists $replydat CONTENT_LENGTH]} {
      set length 0
    } else {
      set length [dict get $replydat CONTENT_LENGTH]
    }
    ###
    # Convert the Status: header from the SCGI service to
    # a standard service reply line from a web server, but
    # otherwise spit out the rest of the headers verbatim
    ###
    set replybuffer "HTTP/1.1 [dict get $replydat HTTP_STATUS]\n"
    append replybuffer $replyhead
    chan configure $chan -translation {auto crlf} -blocking 0 -buffering full -buffersize 4096
    puts $chan $replybuffer
    ###
    # Output the body
    ###
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $sock $chan -command [namespace code [list my TransferComplete $sock]]
    } else {
      catch {close $sock}
      chan flush $chan
      my destroy
    }
  }
  ###
  # Todo: Shorten this to a http->SCGI header formatter
  # And eliminate the duplicate implementation
  ###
  method MimeParse mimetext {
    set data(mimeorder) {}
    foreach line [split $mimetext \n] {
      # This regexp picks up
      # key: value
      # MIME headers.  MIME headers may be continue with a line
      # that starts with spaces or a tab
      if {[string length [string trim $line]]==0} break
      if {[regexp {^([^ :]+):[ 	]*(.*)} $line dummy key value]} {
        # The following allows something to
        # recreate the headers exactly
        lappend data(headerlist) $key $value
        # The rest of this makes it easier to pick out
        # headers from the data(mime,headername) array
        #set key [string tolower $key]
        if {[info exists data(mime,$key)]} {
          append data(mime,$key) ,$value
        } else {
          set data(mime,$key) $value
          lappend data(mimeorder) $key
        }
        set data(key) $key
      } elseif {[regexp {^[ 	]+(.*)}  $line dummy value]} {
        # Are there really continuation lines in the spec?
        if {[info exists data(key)]} {
          append data(mime,$data(key)) " " $value
        } else {
          my error 400 "INVALID HTTP HEADER FORMAT: $line"
          tailcall my output
        }
      } else {
        my error 400 "INVALID HTTP HEADER FORMAT: $line"
        tailcall my output
      }
    }
    ###
    # To make life easier for our SCGI implementation rig things
    # such that CONTENT_LENGTH is always first
    ###
    set result {
      CONTENT_LENGTH 0
    }
    foreach {key} $data(mimeorder) {
      switch $key {
        Content-Length {
          dict set result CONTENT_LENGTH $data(mime,$key)
        }
        Content-Type {
          dict set result CONTENT_TYPE $data(mime,$key)
        }
        default {
          dict set result HTTP_[string map {"-" "_"} [string toupper $key]] $data(mime,$key)
        }
      }
    }
    return $result
  }
}

tool::class create ::httpd::reply.scgi {
  superclass ::httpd::reply

  ###
  # A modified dispatch method from a standard HTTP reply
  # Unlike in HTTP, our headers were spoon fed to use from
  # the server
  ###
  method dispatch {newsock datastate} {
    my http_info replace $datastate
    my variable chan rawrequest dipatched_time
    set chan $newsock
    chan event $chan readable {}
    chan configure $chan -translation {auto crlf} -buffering line
    set dispatched_time [clock seconds]
    try {
      # Dispatch to the URL implementation.
      # Convert SCGI headers to mime-ish equivilients
      my reset
      foreach {f v} $datastate {
        switch $f {
          CONTENT_LENGTH {
            my request set Content-Length $v
          }
          default {
            my request set $f $v
          }
        }
      }
      my content
    } on error {err info} {
      #puts stderr $::errorInfo
      my error 500 $err
    } finally {
      my output
    }
  }

  method EncodeStatus {status} {
    return "Status: $status"
  }
}

###
# Act as an  SCGI Server
###
tool::class create ::httpd::server.scgi {
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
          puts $sock "Status: 404 NOT FOUND"
          dict with query {}
          set body [subst [my template notfound]]
          puts $sock "Content-length: [string length $body]"
          puts $sock {}
          puts $sock $body
        } on error {err errdat} {
          puts stderr "FAILED ON 404: $err"
        } finally {
          catch {close $sock}
        }
      }
    } on error {err errdat} {
      try {
        #puts stderr $::errorInfo
        puts $sock "Status: 505 INTERNAL ERROR - scgi 298"
        dict with query {}
        set body [subst [my template internal_error]]
        puts $sock "Content-length: [string length $body]"
        puts $sock {}
        puts $sock $body
        my log HttpError $REQUEST_URI
      } on error {err errdat} {
        my log HttpFatal $::errorInfo
        #puts stderr "FAILED ON 505: $err $::errorInfo"
      } finally {
        catch {close $sock}
      }
    }
  }
}
