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

  method dispatch {newsock datastate} {
    my http_info replace $datastate
    my request replace  [dict get $datastate http]
    my variable sock chan dispatched_time
    set chan $newsock
    try {
      chan event $chan readable {}
      chan configure $chan -translation {auto crlf} -buffering line
      # Initialize the reply
      my reset
      set sockinfo [my scgi_info]
      if {$sockinfo eq {}} {
        my error 404 {Not Found}
        tailcall my DoOutput
      }
      lassign $sockinfo scgihost scgiport scgiscript
      set sock [::socket $scgihost $scgiport]

      chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
      chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
      ###
      # Convert our query headers into netstring format.
      ###

      set info {CONTENT_LENGTH 0 SCGI 1.0}
      dict set info SCRIPT_NAME $scgiscript
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
      chan puts -nonewline $sock "[string length $block]:$block,"
      if {$length} {
        ###
        # Send any POST/PUT/etc content
        ###
        chan copy $chan $sock -size $length -command [info coroutine]
        yield
      }
      chan flush $sock
      ###
      # Wake this object up after the SCGI process starts to respond
      ###
      #chan configure $sock -translation {auto crlf} -blocking 0 -buffering line
      chan event $sock readable [info coroutine]
      yield
      chan event $sock readable {}
      if {[my http_info getnull HTTP_ERROR] ne {}} {
        ###
        # If something croaked internally, handle this page as a normal reply
        ###
        tailcall my DoOutput
      }
      set stime [clock milliseconds]
      set dtime [expr {$stime-$dispatched_time}]
      set replyhead [my HttpHeaders $sock]
      set replydat  [my MimeParse $replyhead]
      if {![dict exists $replydat Content-Length]} {
        set length 0
      } else {
        set length [dict get $replydat Content-Length]
      }
      ###
      # Convert the Status: header from the SCGI service to
      # a standard service reply line from a web server, but
      # otherwise spit out the rest of the headers verbatim
      ###
      set replybuffer "HTTP/1.1 [dict get $replydat Status]\n"
      append replybuffer $replyhead
      chan configure $chan -translation {auto crlf} -blocking 0 -buffering full -buffersize 4096
      puts $chan $replybuffer
      ###
      # Output the body
      ###
      chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
      chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
      my log HttpAccess {}
      if {$length} {
        ###
        # Send any POST/PUT/etc content
        # Note, we are terminating the coroutine at this point
        # and using the file event to wake the object back up
        #
        # We *could*:
        # chan copy $sock $chan -command [info coroutine]
        # yield
        #
        # But in the field this pegs the CPU for long transfers and locks
        # up the process
        ###
        chan copy $sock $chan -command [namespace code [list my TransferComplete $sock $chan]]
      } else {
        my TransferComplete $sock $chan
      }
    } on error {err info} {
      # If something goes wrong, for now just log the
      # result and move on
      my <server> debug [dict get $info -errorinfo]
      my TransferComplete $sock $chan
    }
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
          puts $sock "Status: 404 NOT FOUND"
          dict with query {}
          set body [subst [my template notfound]]
          puts $sock "Content-Length: [string length $body]"
          puts $sock {}
          puts $sock $body
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
        puts $sock "Status: 505 INTERNAL ERROR - scgi 298"
        dict with query {}
        set body [subst [my template internal_error]]
        puts $sock "Content-Length: [string length $body]"
        puts $sock {}
        puts $sock $body
        my log HttpError $REQUEST_URI
      } on error {err errdat} {
        my log HttpFatal [my http_info get REMOTE_ADDR] [dict get $errdat -errorinfo]
        my <server> debug "Failed on 505: [dict get $errdat -errorinfo]""
      } finally {
        catch {chan event readable $sock {}}
        catch {chan event writeable $sock {}}
        catch {chan close $sock}
      }
    }
  }
}
