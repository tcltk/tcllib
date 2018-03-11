###
# Define the reply class
###
::tool::define ::httpd::reply {
  superclass ::httpd::mime

  constructor {ServerObj args} {
    my variable chan dispatched_time
    set dispatched_time [clock milliseconds]
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
      catch {chan event $chan readable {}}
      catch {chan event $chan writable {}}
      catch {chan flush $chan}
      catch {chan close $chan}
      set chan {}
    }
  }

  method dispatch {newsock datastate} {
    my http_info replace $datastate
    my request replace  [dict get $datastate http]
    my variable chan
    set chan $newsock
    chan event $chan readable {}
    chan configure $chan -translation {auto crlf} -buffering line
    try {
      # Initialize the reply
      my reset
      # Invoke the URL implementation.
      my content
    } on error {err info} {
      my <server> debug [dict get $info -errorinfo]
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
    my reply set Content-Type {text/html; charset=UTF-8}
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

  method log {type {info {}}} {
    my variable dispatched_time
    my <server> log $type [expr {[clock milliseconds]-$dispatched_time}]ms [dict create ip: [my http_info get REMOTE_ADDR] host: [my http_info get REMOTE_HOST] cookie: [my request get COOKIE] referrer: [my request get REFERER] user-agent: [my request get USER_AGENT] uri: [my http_info get REQUEST_URI] host: [my http_info getnull HTTP_HOST]] $info

  }

  method output {} {
    my variable chan
    chan event $chan writable [info coroutine]
    yield
    chan event $chan writable {}
    my DoOutput
  }

  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method DoOutput {} {
    my variable reply_body chan
    catch {chan event $chan writable {}}
    try {
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
      my log HttpAccess {}
    } on error {err info} {
      my <server> debug [dict get $info -errorinfo]
      my log HttpError {error: $err}
    } finally {
      my destroy
    }
  }

  method FormData {} {
    my variable chan formdata
    # Run this only once
    if {[info exists formdata]} {
      return $formdata
    }
    if {![my request exists CONTENT_LENGTH]} {
      set length 0
    } else {
      set length [my request get CONTENT_LENGTH]
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
          set body [my http_info get mimetxt]
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
    my variable chan
    set chan {}
    foreach c $args {
      catch {chan event $c readable {}}
      catch {chan event $c writable {}}
      catch {chan flush $c}
      catch {chan close $c}
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

  method RequestFind {field} {
    my variable request
    if {[dict exists $request $field]} {
      return $field
    }
    foreach item [dict keys $request] {
      if {[string tolower $item] eq [string tolower $field]} {
        return $item
      }
    }
    return $field
  }

  dictobj request request {
    field {
      tailcall my RequestFind [lindex $args 0]
    }
    get {
      set field [my RequestFind [lindex $args 0]]
      if {![dict exists $request $field]} {
        return {}
      }
      tailcall dict get $request $field
    }
    getnull {
      set field [my RequestFind [lindex $args 0]]
      if {![dict exists $request $field]} {
        return {}
      }
      tailcall dict get $request $field

    }
    exists {
      set field [my RequestFind [lindex $args 0]]
      tailcall dict exists $request $field
    }
    parse {
      if {[catch {my MimeParse [lindex $args 0]} result]} {
        my error 400 $result
        tailcall my output
      }
      set request $result
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
    my variable dispatched_time
    if {([clock seconds]-$dispatched_time)>30} {
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
