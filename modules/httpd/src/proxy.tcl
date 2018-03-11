::tool::define ::httpd::content.exec {
  variable exename [list tcl [info nameofexecutable] .tcl [info nameofexecutable]]

  method CgiExec {execname script arglist} {
    if { $::tcl_platform(platform) eq "windows"} {
      if {[file extension $script] eq ".exe"} {
        return [open "|[list $script] $arglist" r+]
      } else {
        if {$execname eq {}} {
          set execname [my Cgi_Executable $script]
        }
        return [open "|[list $execname $script] $arglist" r+]
      }
    } else {
      if {$execname eq {}} {
        return [open "|[list $script] $arglist 2>@1" r+]
      } else {
        return [open "|[list $execname $script] $arglist 2>@1" r+]
      }
    }
    error "CGI Not supported"
  }

  method Cgi_Executable {script} {
    if {[string tolower [file extension $script]] eq ".exe"} {
      return $script
    }
    my variable exename
    set ext [file extension $script]
    if {$ext eq {}} {
      set which [file tail $script]
    } else {
      if {[dict exists exename $ext]} {
        return [dict get $exename $ext]
      }
      switch $ext {
        .pl {
          set which perl
        }
        .py {
          set which python
        }
        .php {
          set which php
        }
        .fossil - .fos {
          set which fossil
        }
        default {
          set which tcl
        }
      }
      if {[dict exists exename $which]} {
        set result [dict get $exename $which]
        dict set exename $ext $result
        return $result
      }
    }
    if {[dict exists exename $which]} {
      return [dict get $exename $which]
    }
    if {$which eq "tcl"} {
      if {[my cget tcl_exe] ne {}} {
        dict set exename $which [my cget tcl_exe]
      } else {
        dict set exename $which [info nameofexecutable]
      }
    } else {
      if {[my cget ${which}_exe] ne {}} {
        dict set exename $which [my cget ${which}_exe]
      } elseif {"$::tcl_platform(platform)" == "windows"} {
        dict set exename $which $which.exe
      } else {
        dict set exename $which $which
      }
    }
    set result [dict get $exename $which]
    if {$ext ne {}} {
      dict set exename $ext $result
    }
    return $result
  }
}

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

  method ProxyRequest {chana chanb} {
    my wait writable $chanb
    chan configure $chana -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chanb -translation binary -blocking 0 -buffering full -buffersize 4096
    chan puts $chanb "[my http_info get REQUEST_METHOD] [my proxy_path]"
    chan puts $chanb [my http_info get mimetxt]
    set length [my http_info get CONTENT_LENGTH]
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $chana $chanb -size $length -command [info coroutine]
      yield
    }
    chan flush $chanb
  }

  method ProxyReply {chana chanb} {
    set readCount [::coroutine::util::gets_safety $chana 4096 reply_status]
    set replyhead [my HttpHeaders $chana]
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
    chan configure $chanb -translation {auto crlf} -blocking 0 -buffering full -buffersize 4096
    chan puts $chanb $replybuffer
    ###
    # Output the body
    ###
    chan configure $chana -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chanb -translation binary -blocking 0 -buffering full -buffersize 4096
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      # Note, we are terminating the coroutine at this point
      # and using the file event to wake the object back up
      #
      # We *could*:
      # chan copy $chana $chanb -command [info coroutine]
      # yield
      #
      # But in the field this pegs the CPU for long transfers and locks
      # up the process
      ###
      chan copy $chana $chanb -size $length -command [info coroutine]
      yield
    }
  }

  method dispatch {newsock datastate} {
    my http_info replace $datastate
    my request replace  [dict get $datastate http]
    my variable sock chan
    set chan $newsock
    try {
      chan configure $chan -translation {auto crlf} -buffering line
      # Initialize the reply
      my reset
      # Invoke the URL implementation.
      set sock [my proxy_channel]
      my ProxyRequest $chan $sock
      my ProxyReply $sock $chan
      my log HttpAccess {}
    } on error {err info} {
      # If something goes wrong, for now just log the
      # result and move on
      my <server> debug [dict get $info -errorinfo]
    } finally {
      my TransferComplete $sock $chan
    }
  }
}
