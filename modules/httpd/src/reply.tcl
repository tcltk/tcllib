###
# Define the reply class
###
::tool::define ::httpd::reply {

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

  constructor {ServerObj args} {
    my variable chan
    oo::objdefine [self] forward <server> $ServerObj
    foreach {field value} [::oo::meta::args_to_options {*}$args] {
      my meta set config $field: $value
    }
  }

  ###
  # clean up on exit
  ###
  destructor {
    my close
  }

  method close {} {
    my variable chan
    if {[info exists chan] && $chan ne {}} {
      catch {flush $chan}
      catch {close $chan}
    }
  }

  method HttpHeaders {sock {debug {}}} {
    set result {}
    ###
    # Set up a channel event to stream the data from the socket line by
    # line. When a blank line is read, the HttpHeaderLine method will send
    # a flag which will terminate the vwait.
    #
    # We do this rather than entering blocking mode to prevent the process
    # from locking up if it's starved for input. (Or in the case of the test
    # suite, when we are opening a blocking channel on the other side of the
    # socket back to ourselves.)
    ###
    chan configure $sock -translation {auto crlf} -blocking 0 -buffering line
    try {
      while 1 {
        set readCount [::coroutine::util::gets_safety $sock 4096 line]
        if {$readCount==0} break
        append result $line \n
      }
    } trap {POSIX EBUSY} {err info} {
      # Happens...
    } on error {err info} {
      puts "ERROR $err"
      puts [dict print $info]
      tailcall my destroy
    }
    ###
    # Return our buffer
    ###
    return $result
  }

  property HttpHeaders_Default {} {
    return {Status {200 OK}
Content-Size 0
Content-Type {text/html; charset=UTF-8}
Cache-Control {no-cache}
Connection close}
  }

  method dispatch {newsock datastate} {
    my http_info replace $datastate
    my variable chan rawrequest dipatched_time
    set chan $newsock
    chan event $chan readable {}
    chan configure $chan -translation {auto crlf} -buffering line
    set dispatched_time [clock seconds]
    try {
      # Initialize the reply
      my reset
      # Process the incoming MIME headers
      set rawrequest [my HttpHeaders $chan]
      my request parse $rawrequest
      # Invoke the URL implementation.
      my content
    } on error {err info} {
      dict print $info
      #puts stderr $::errorInfo
      my error 500 $err [dict get $info -errorinfo]
    } finally {
      my output
    }
  }

  dictobj http_info http_info {
    initialize {
      CONTENT_LENGTH 0
    }
    netstring {
      set result {}
      foreach {name value} $%VARNAME% {
        append result $name \x00 $value \x00
      }
      return "[string length $result]:$result,"
    }
  }

  method error {code {msg {}} {errorInfo {}}} {
    my http_info set HTTP_ERROR $code
    my reset
    my variable error_codes
    set qheaders [my http_info dump]
    if {![info exists error_codes($code)]} {
      set errorstring "Unknown Error Code"
    } else {
      set errorstring $error_codes($code)
    }
    dict with qheaders {}
    my reply replace {}
    my reply set Status "$code $errorstring"
    my reply set Content-Type {text/html; charset=ISO-8859-1}
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
while trying to obtain $REQUEST_URI
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
<pre>$errorInfo</pre>
"
    }
    my puts "</BODY>
</HTML>"
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

  method EncodeStatus {status} {
    return "HTTP/1.0 $status"
  }

  method output {} {
    my variable chan
    chan event $chan writable [namespace code {my DoOutput}]
  }

  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method DoOutput {} {
    my variable reply_body chan
    chan event $chan writable {}
    catch {
      chan configure $chan  -translation {binary binary}
      ###
      # Return dynamic content
      ###
      set length [string length $reply_body]
      set result {}
      if {${length} > 0} {
        my reply set Content-Length [string length $reply_body]
        append result [my reply output] \n
        append result $reply_body
      } else {
        append result [my reply output]
      }
      chan puts -nonewline $chan $result
    } err
    puts $err
    my destroy
  }

  method Url_Decode data {
    regsub -all {\+} $data " " data
    regsub -all {([][$\\])} $data {\\\1} data
    regsub -all {%([0-9a-fA-F][0-9a-fA-F])} $data  {[format %c 0x\1]} data
    return [subst $data]
  }

  method FormData {} {
    my variable chan formdata rawrequest
    # Run this only once
    if {[info exists formdata]} {
      return $formdata
    }
    set rawrequest [my HttpHeaders $chan]
    my request parse $rawrequest
    if {![my request exists Content-Length]} {
      set length 0
    } else {
      set length [my request get Content-Length]
    }
    set formdata {}
    if {[my http_info get REQUEST_METHOD] in {"POST" "PUSH"}} {
      set rawtype [my request get Content-Type]
      if {[string toupper [string range $rawtype 0 8]] ne "MULTIPART"} {
        set type $rawtype
      } else {
        set type multipart
      }
      switch $type {
        multipart {
          ###
          # Ok, Multipart MIME is troublesome, farm out the parsing to a dedicated tool
          ###
          set body $rawrequest
          append body \n [my PostData $length]
          set token [::mime::initialize -string $body]
          foreach item [::mime::getheader $token -names] {
            dict set formdata $item [::mime::getheader $token $item]
          }
          foreach item {content encoding params parts size} {
            dict set formdata MIME_[string toupper $item] [::mime::getproperty $token $item]
          }
          dict set formdata MIME_TOKEN $token
        }
        application/x-www-form-urlencoded {
          # These foreach loops are structured this way to ensure there are matched
          # name/value pairs.  Sometimes query data gets garbled.
          set body [my PostData $length]
          set result {}
          foreach pair [split $body "&"] {
            foreach {name value} [split $pair "="] {
              lappend formdata [my Url_Decode $name] [my Url_Decode $value]
            }
          }
        }
      }
    } else {
      foreach pair [split [my http_info getnull QUERY_STRING] "&"] {
        foreach {name value} [split $pair "="] {
          lappend formdata [my Url_Decode $name] [my Url_Decode $value]
        }
      }
    }
    return $formdata
  }

  ###
  # Minimalist MIME Header Parser
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
    set result {}
    dict set result Content-Length 0
    foreach {key} $data(mimeorder) {
      dict set result $key $data(mime,$key)
    }
    return $result
  }

  method PostData {length} {
    my variable postdata
    # Run this only once
    if {[info exists postdata]} {
      return $postdata
    }
    set postdata {}
    if {[my http_info get REQUEST_METHOD] in {"POST" "PUSH"}} {
      my variable chan
      chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
      set postdata [::coroutine::util::read $chan $length]
    }
    return $postdata
  }

  method TransferComplete args {
    foreach c $args {
      catch {close $c}
    }
    my destroy
  }

  ###
  # Append to the result buffer
  ###
  method puts line {
    my variable reply_body
    append reply_body $line \n
  }

  dictobj request request {
    parse {
      set request [my MimeParse [lindex $args 0]]
    }
  }

  dictobj reply reply {
    output {
      set result {}
      if {![dict exists $reply Status]} {
        set status {200 OK}
      } else {
        set status [dict get $reply Status]
      }
      set result "[my EncodeStatus $status]\n"
      foreach {f v} $reply {
        if {$f in {Status}} continue
        append result "[string trimright $f :]: $v\n"
      }
      #append result \n
      return $result
    }
  }


  ###
  # Reset the result
  ###
  method reset {} {
    my variable reply_body
    my reply replace    [my HttpHeaders_Default]
    my reply set Server [my <server> cget server_string]
    my reply set Date [my timestamp]
    set reply_body {}
  }

  ###
  # Return true of this class as waited too long to respond
  ###
  method timeOutCheck {} {
    my variable dipatched_time
    if {([clock seconds]-$dipatched_time)>30} {
      ###
      # Something has lasted over 2 minutes. Kill this
      ###
      my error 505 {Operation Timed out}
      my output
    }
  }

  ###
  # Return a timestamp
  ###
  method timestamp {} {
    return [clock format [clock seconds] -format {%a, %d %b %Y %T %Z}]
  }
}
