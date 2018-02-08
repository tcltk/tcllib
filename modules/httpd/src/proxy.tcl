
# Act as a proxy server
::tool::define ::httpd::content.proxy {

  method proxy_info {} {
    ###
    # This method should check if a process is launched
    # or launch it if needed, and return a list of
    # HOST PORT PROXYURI
    ###
    # return {localhost 8016 /some/path}
    error unimplemented
  }

  method content {} {
    my variable chan sock rawrequest
    set sockinfo [my proxy_info]
    if {$sockinfo eq {}} {
      tailcall my error 404 {Not Found}
    }
    lassign $sockinfo proxyhost proxyport proxyscript
    set sock [::socket $proxyhost $proxyport]

    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $sock -translation {auto crlf} -blocking 1 -buffering line

    # Pass along our modified METHOD URI PROTO
    chan puts $sock "$proxyscript"
    # Pass along the headers as we saw them
    chan puts $sock $rawrequest
    set length [my http_info get CONTENT_LENGTH]
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $chan $sock -size $length
    }
    chan flush $sock
    ###
    # Wake this object up after the proxied process starts to respond
    ###
    chan configure $sock -translation {auto crlf} -blocking 1 -buffering line
    chan event $sock readable [namespace code {my output}]
  }

  method DoOutput {} {
    my variable chan sock
    chan event $chan writable {}
    if {![info exists sock] || [my http_info getnull HTTP_ERROR] ne {}} {
      ###
      # If something croaked internally, handle this page as a normal reply
      ###
      next
      return
    }
    set length 0
    chan configure $sock -translation {crlf crlf} -blocking 1
    set replystatus [gets $sock]
    set replyhead [my HttpHeaders $sock]
    set replydat  [my MimeParse $replyhead]

    ###
    # Pass along the status line and MIME headers
    ###
    set replybuffer "$replystatus\n"
    append replybuffer $replyhead
    chan configure $chan -translation {auto crlf} -blocking 0 -buffering full -buffersize 4096
    chan puts $chan $replybuffer
    ###
    # Output the body
    ###
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    set length [dict get $replydat CONTENT_LENGTH]
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $sock $chan -command [namespace code [list my TransferComplete $sock]]
    } else {
      my destroy
    }
  }
}
