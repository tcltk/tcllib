###
# Return data from an proxy process
###
::tool::define ::httpd::content.proxy {
  superclass ::httpd::content.exec

  method proxy_channel {} {
    ###
    # This method returns a channel to the
    # proxied socket/stdout/etc
    ###
    error unimplemented
  }

  method proxy_path {} {
    set uri [string trimleft [my http_info get REQUEST_URI] /]
    set prefix [my http_info get prefix]
    return /[string range $uri [string length $prefix] end]
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
      # Invoke the URL implementation.
      set sock [my proxy_channel]
      chan event $sock writable [info coroutine]
      yield
      chan event $sock writable {}
      chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
      chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
      puts $sock "[my http_info get REQUEST_METHOD] [my proxy_path]"
      puts $sock [my http_info get mimetxt]
      set length [my http_info get CONTENT_LENGTH]
      if {$length} {
        ###
        # Send any POST/PUT/etc content
        ###
        chan copy $chan $sock -size $length -command [info coroutine]
        yield
      }

      chan flush $sock
      set readCount [::coroutine::util::gets_safety $sock 4096 reply_status]
      set reply_status
      chan event $sock readable {}
      set statusline []
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
      # Convert the Status: header from the proxy service to
      # a standard service reply line from a web server, but
      # otherwise spit out the rest of the headers verbatim
      ###
      set replybuffer "$reply_status\n"
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
