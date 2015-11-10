###
# Author: Sean Woods, yoda@etoyoc.com
##
# Adapted from the "minihttpd.tcl" file distributed with Tclhttpd
#
# The working elements have been updated to operate as a TclOO object
# running with Tcl 8.6+. Global variables and hard coded tables are
# now resident with the object, allowing this server to be more easily
# embedded another program, as well as be adapted and extended to
# support the SCGI module
###

package require uri
package require cron
package require tool
package require oo::dialect

namespace eval ::url {}

namespace eval ::httpd {}

::tool::class create ::httpd::reply {

  property socket buffersize   32768
  property socket blocking     0
  property socket translation  {auto crlf}

  array error_codes {
    200 {Data follows}
    204 {No Content}
    302 {Found}
    304 {Not Modified}
    400 {Bad Request}
    401 {Authorization Required}
    403 {Permission denied}
    404 {Not Found}
    408 {Request Timeout}
    411 {Length Required}
    419 {Expectation Failed}
    500 {Server Internal Error}
    501 {Server Busy}
    503 {Service Unavailable}
    504 {Service Temporarily Unavailable}
    505 {Internal Server Error}
  }
  
  property env_map {
    CONTENT_LENGTH	mime,content-length
    CONTENT_TYPE	mime,content-type
    HTTP_ACCEPT		mime,accept
    HTTP_AUTHORIZATION	mime,authorization
    HTTP_FROM		mime,from
    HTTP_REFERER	mime,referer
    HTTP_USER_AGENT	mime,user-agent
    QUERY_STRING	query
    REQUEST_METHOD	proto
    HTTP_COOKIE         mime,cookie
    HTTP_FORWARDED      mime,forwarded
    HTTP_HOST           mime,host
    HTTP_PROXY_CONNECTION mime,proxy-connection
    REMOTE_USER		remote_user
    AUTH_TYPE		auth_type
    REQUEST_URI          uri
    REQUEST_PATH         url
  }
  
  property reply_status {200 OK}

  property reply_headers_default {
    Content-Type: {text/html; charset=ISO-8859-1}
    Connection: close
  }  
  property reply_headers {}

  constructor {newsock ServerObj args} {
    my variable chan
    my variable data

    array set data {
      state start
      version 0
    }

    oo::objdefine [self] forward <server> $ServerObj
    foreach {field value} [::oo::meta::args_to_options {*}$args] {
      my meta set config $field: $value
    }
    
    set chan $newsock
    chan configure $chan \
      -blocking [my meta get socket blocking:] \
      -translation [my meta get socket translation:] \
      -buffersize [my meta get socket buffersize:]
    chan event $chan readable [namespace code {my RequestRead}]
  }
  
  ###
  # clean up on exit
  ###
  destructor {
    my <server> unregister [self]
    my variable chan
    catch {close $chan}
  }

  method error {code {msg {}}} {
    my reset
    my variable data error_codes
    if {![info exists data(url)]} {
      set data(url) {}
    }
    if {![info exists error_codes($code)]} {
      set errorstring "Unknown Error Code"
    } else {
      set errorstring $error_codes($code)
    }
    my meta set reply_headers Content-Type: {text/html; charset=ISO-8859-1}
    my meta set reply_status "$code $errorstring"
      my puts "
<HTML>
<HEAD>
<TITLE>$code $errorstring</TITLE>
</HEAD>
<BODY>"
    if {$msg eq {}} {
      my puts "
Got the error <b>$code $errorstring</b>
<p>
while trying to obtain $data(url)
      "
    } else {
      my puts "
Guru meditation #[clock seconds]
<p>
The server encountered an internal error:
<p>
<pre>$msg</pre>
<p>
For deeper understanding:
<p>
<pre>$::errorInfo</pre>
"
    }
    my puts "</BODY>
</HTML>"
    my output
  }
  
  
  ###
  # REPLACE ME:
  # This method is the "meat" of your application.
  # It writes to the result buffer via the "puts" method
  # and can tweak the headers via "meta put header_reply"
  ###
  method content {} {
    my puts "<HTML>"
    my puts "<BODY>"
    my puts "<H1>HELLO WORLD!</H1>"
    my puts "</BODY>"
    my puts "</HTML>"
  }

  ###
  # Transform this object to another class
  ###
  method morph newclass {
    set newclass ::[string trimleft $newclass :]
    if {$newclass eq [info object class [self]]} {
      return
    }
    my MorphExit
    oo::objdefine [self] class $newclass
    my MorphEnter
  }

  ###
  # Actions to perform as the new class when
  # we morph into it
  ###
  method MorphEnter {} {
    
  }
  
  ###
  # Actions to perform as our present class
  # prior to changing to our new class
  ###
  method MorphExit {} {
    
  }

  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method output {} {
    my variable reply_body
    set headers [my meta cget reply_headers]
    set result "HTTP/1.0 [my meta cget reply_status]\n"
    foreach {key value} $headers {  
      append result "$key $value" \n
    }
    append result "Content-length: [string length $reply_body]" \n \n
    append result $reply_body
    my variable chan
    puts $chan $result
    flush $chan
    my destroy
  }

  ###
  # Append to the result buffer
  ###
  method puts line {
    my variable reply_body
    append reply_body $line \n
  }

  ###
  # Read out the contents of the POST
  ###
  method query_body {} {
    my variable query_body
    return $query_body
  }

  ###
  # Read the request from the client
  # This code was adapted from the HttpdRead procedure in
  # tclhttpd
  ###
  method RequestRead {} {
    my variable chan
    my variable data
    
    if {[catch {gets $chan line} readCount]} {
      my <server> log "read error: $readCount"
      my destroy
      return
    }
  
    ###
    # TODO: Implement safeties for oversized headers
    # TODO: check fblocked
    # TODO: chan pending
    ###
    
    # State machine is a function of our state variable:
    #	start: the connection is new
    #	mime: we are reading the protocol headers
    # and how much was read. Note that
    # [string compare $readCount 0] maps -1 to -1, 0 to 0, and > 0 to 1
    set state [string compare $readCount 0],$data(state)
    switch -glob -- $state {
      1,start	{
        set data(proto) [lindex $line 0]
        set data(uri) [lindex $line 1]
        set data(version) [lindex [split [lindex $line end] /] end]
        if {[catch {::uri::split $data(uri)} data(uri_info)]} {
          my <server> log HttpError $line
          my destroy
          return
        }
        set data(query) [dict get $data(uri_info) query]
        set data(url) [dict get $data(uri_info) path]
        set data(state) mime
        set data(line) $line
        my <server> counter url_hits
      }
      0,start {
        # This can happen in between requests.
      }
      1,mime	{
        # This regexp picks up
        # key: value
        # MIME headers.  MIME headers may be continue with a line
        # that starts with spaces.
        if {[regexp {^([^ :]+):[ 	]*(.*)} $line dummy key value]} {  
          # The following allows something to
          # recreate the headers exactly

          lappend data(headerlist) $key $value

          # The rest of this makes it easier to pick out
          # headers from the data(mime,headername) array

          set key [string tolower $key]
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
            my error 400 $line
            return
          }
        } else {
          my error 400 $line
          return
        }
        ###
        # The old virtual hosts code for httpd lived here
        ###
      }
      0,mime	{
        if {$data(proto) == "POST"} {
          chan configure $chan  -translation {binary crlf}
          if {![info exists data(mime,content-length)]} {
            my error 411
            return
          }
          set data(count) $data(mime,content-length)
          if {$data(version) >= 1.1 && [info exists data(mime,expect)]} {
            if {$data(mime,expect) == "100-continue"} {
              puts $chan "100 Continue HTTP/1.1\n"
              flush $chan
            } else {
              my error 419 $data(mime,expect)
              return
            }
          }

          # Flag the need to check for an extra newline
          # in SSL connections by some browsers.

          set data(checkNewline) 1

          # Facilitate a backdoor hook between Url_DecodeQuery
          # where it will read the post data on behalf of the
          # domain handler in the case where the domain handler
          # doesn't use an Httpd call to read the post data itself.

          #Url_PostHook $chan $data(count)
        } else {
          #Url_PostHook $chan 0    ;# Clear any left-over hook
          set data(count) 0
        }
  
        # Disabling this fileevent makes it possible to use
        # http::geturl in domain handlers reliably
  
        chan event $chan readable {}
        
        ###
        # publish the bits of the data array that
        # are fit for public consumption
        ###
        foreach {field datamap} [my meta get env_map] {
          if {[info exists data($datamap)]} {
            my meta set query_headers $field $data($datamap)
          }
        }
        my meta set query_headers QUERY_STRING [dict getnull $data(uri_info) query]
        
        # Dispatch to the URL implementation.
        if {[catch {
          set code [my <server> dispatch [self]]
          if {$code eq 200} {
            my content
          }
        } err]} {
          my error 500 $err
        } else {
          my output
        }
        return
      }
      -1,* {
          if {[chan blocked $chan]} {
              # Blocked before getting a whole line
              return
          }
          if {[eof $chan]} {
            my destroy
            return
          }
      }
      default {
        my error 404 "$state ?? [expr {[eof $chan] ? "EOF" : ""}]"
        return
      }
    }
  }

  ###
  # Reset the result
  ###
  method reset {} {
    my variable reply_body
    my meta set reply_headers [my meta cget reply_headers_default]
    my meta set reply_headers Date: [my timestamp]
    
    my variable data
    
    set reply_body {}
  }
  
  ###
  # Return true of this class as waited too long to respond
  ###
  method timedOut {} {
    return 0
  }
  
  ###
  # Return a timestamp
  ###
  method timestamp {} {
    return [clock format [clock seconds] -format {%a, %d %b %Y %T %Z}]
  }
}

###
# A simplistic web server, with a few caveats:
# 1) It only really understands "GET" style queries.
# 2) It is not hardened in any way against malicious attacks
# 3) By default it will only listen on localhost
###
::tool::class create ::httpd::server {
  
  option port  {default: auto}
  option myaddr {default: 127.0.0.1}
  
  property reply_class ::httpd::reply

  constructor {args} {
    my configure {*}$args
    my start
  }
  
  destructor {
    my stop
  }

  method connect {sock ip port} {
    my variable open_connections
    set class [my cget reply_class]
    set pageobj [$class new $sock [self] remote_ip $ip remote_port $port]
    lappend open_connections $pageobj
  }

  method counter which {
    my variable counters
    incr counters($which)
  }
  

  ###
  # Clean up any process that has gone out for lunch
  ###
  method CheckTimeout {} {
    my variable open_connections
    set objlist $open_connections
    foreach obj $objlist {
      if {[catch {$obj timedOut} timeout]} {
        my unregister $obj
        continue
      }
      if {$timeout} {
        catch {close [$obj chan]}
        catch {$obj destroy}
        my unregister $obj
      }
    }
  }
  
  ###
  # REPLACE ME:
  # This method should perform any transformations
  # or setup to the page object based on headers/state/etc
  # If all is well, return 200. Any other code will be interpreted
  # as an error
  ###
  method dispatch {pageobj} {
    return 200
  }

  method log args {
    # Do nothing for now
  }
  
  method register object {
    my variable open_connections
    if { $object ni $open_connections } {
      lappend open_connections $object
    }
  }
  
  method unregister object {
    my variable open_connections
    ldelete open_connections $object
  }
  
  method start {} {
    my variable socklist open_connections
    set open_connections {}
    set port [my cget port]
    if { $port in {auto {}} } {
      set port [::nettool::allocate_port 8015]
    }
    my meta set port_listening $port
    set myaddr [my cget myaddr]
    puts [list [self] listening on $port $myaddr]

    if {$myaddr ne {}} {
      foreach ip $myaddr {
        lappend socklist [socket -server [namespace code [list my connect]] -myaddr $ip $port]
      }
    } else {
      lappend socklist [socket -server [namespace code [list my connect]] $port]
    }
    ::cron::every [self] 120 [namespace code {my CheckTimeout}]
  }

  method stop {} {
    my variable socklist
    foreach sock $socklist {
      catch {close $sock}
    }
    set socklist {}
    ::cron::cancel [self]
  }
}

package provide tool::httpd 0.1
