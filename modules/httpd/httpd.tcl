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
package require tool 0.4
package require oo::dialect

namespace eval ::url {}

namespace eval ::httpd {}
namespace eval ::scgi {}

###
# Include handlers for SCGI headers
###
proc ::scgi::encode_request {headers body info} {
  variable server_block

  if {$body eq {}} {
    # If blank, we may be streaming content
    if {![dict exists $info CONTENT_LENGTH]} {
      dict set outdict CONTENT_LENGTH 0
    } else {
      dict set outdict CONTENT_LENGTH [dict get $info CONTENT_LENGTH]
    }
  } else {
    dict set outdict CONTENT_LENGTH [string length $body]
  }
  set outdict [dict merge $outdict $server_block $info]
  dict set outdict PWD [pwd]
  foreach {key value} $headers {
    switch $key {
      SCRIPT_NAME -
      REQUEST_METHOD -
      REQUEST_URI {
        dict set outdict $key $value
      }
      default {
        if {[string range $key 0 4] eq "HTTP_"} {
          dict set outdict $key $value
        } else {
          dict set outdict HTTP_[string map {"-" "_"} [string toupper $key]] $value
        }
      }
    }
  }  
  set result {}
  foreach {name value} $outdict {
    append result $name \x00 $value \x00
  }
  return "[string length $result]:$result,"
}

proc ::scgi::decode_headers {rawheaders} {
  #
  # Take the tokenized header data and place the usual CGI headers into $env,
  # and transform the HTTP_ variables to their original HTTP header field names
  # as best as possible.
  #
  foreach {name value} $rawheaders {
    if {[regexp {^HTTP_(.*)$} $name {} nameSuffix]} {
      set nameParts [list]
      foreach namePart [split $nameSuffix _] {
        lappend nameParts [string toupper [string tolower $namePart] 0 0]
      }
      dict set headers [join $nameParts -] $value
    } else {
      dict set env $name $value
    }
  }
  #
  # Store CONTENT_LENGTH as an HTTP header named Content-Length, too.
  #
  set contentLength [dict get $env CONTENT_LENGTH]
  if {$contentLength > 0} {
    dict set headers Content-Length $contentLength
  }
  return [list env $enc headers $headers]
}

###
# Define the reply class
###
::tool::class create ::httpd::reply {

  property reply_headers_default {
    Status: {200 OK}
    Content-Type: {text/html; charset=ISO-8859-1}
    Connection: close
  }  

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
    my <server> unregister [self]
    my variable chan
    catch {close $chan}
  }
  
  method HttpHeaders {sock {debug {}}} {
    set result {}
    ###
    # Enter blocking mode with crlf translation in order
    # to read the headers
    ###
    chan configure $sock -translation {crlf crlf} -blocking 1
    ###
    # Read until the first empty line
    ###
    while {[gets $sock line]>0} {
      if {$debug ne {}} { puts "$debug $line" }
      append mime $line \n
    }
    ###
    # Cancel blocking mode
    ###
    chan configure $sock -blocking 0
    ###
    # Return our buffer
    ###
    return $mime
  }
  method MimeParse mimetext {
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
  
  method dispatch {newsock datastate} {
    my query_headers replace $datastate
    my variable chan rawrequest
    set chan $newsock
    chan event $chan readable {}
    chan configure $chan -translation {auto crlf} -buffering line
   
    try {
      set rawrequest [my HttpHeaders $chan]
      foreach {field value} [my MimeParse $rawrequest] {
        my query_headers set $field $value
      }
      # Dispatch to the URL implementation.
      my content
    } on error {err info} {
      puts stderr $::errorInfo
      my error 500 $err
    } finally {
      my output
    }
  }
  
  dictobj query_headers query_headers {
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
  dictobj reply_headers reply_headers {
    initialize {
      Content-Type: {text/html; charset=ISO-8859-1}
      Connection: close
    }
  }

  method error {code {msg {}}} {
    #puts [list [self] ERROR $code $msg $::errorInfo]
    my query_headers set HTTP_ERROR $code
    my reset
    my variable error_codes
    set qheaders [my query_headers dump]
    if {![info exists error_codes($code)]} {
      set errorstring "Unknown Error Code"
    } else {
      set errorstring $error_codes($code)
    }
    dict with qheaders {}
    my reply_headers replace {}
    my reply_headers set Status: "$code $errorstring"
    my reply_headers set Content-Type: {text/html; charset=ISO-8859-1}
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
<pre>$::errorInfo</pre>
"
    }
    my puts "</BODY>
</HTML>"
    #my output
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

  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method output {} {
    my variable reply_body reply_chan chan
    chan configure $chan  -translation {binary binary}

    set headers [my reply_headers dump]
    if {[dict exists $headers Status:]} {
      set result "[my EncodeStatus [dict get $headers Status:]]\n"
    } else {
      set result "[my EncodeStatus {505 Internal Error}]\n"
    }
    foreach {key value} $headers {
      # Ignore Status and Content-length, if given
      if {$key in {Status: Content-length:}} continue
      append result "$key $value" \n
    }
    ###
    # Return dynamic content
    ###
    set reply_body [string trim $reply_body]
    set length [string length $reply_body]
    if {${length} > 0} {
      append result "Content-length: [string length $reply_body]" \n \n
      append result $reply_body
    } else {
      append result \n
    }
    puts -nonewline $chan $result
    chan flush $chan    
    my destroy
  }
  
  method TransferComplete args {
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
  # Reset the result
  ###
  method reset {} {
    my variable reply_body
    my reply_headers replace [my meta cget reply_headers_default]
    my reply_headers set Date: [my timestamp]
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
  
  property socket buffersize   32768
  property socket translation  {auto crlf}
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
    chan configure $sock \
      -blocking 1 \
      -translation {auto crlf} \
      -buffering line

    my counter url_hit
    try {
      set readCount [gets $sock line]
      dict set query REQUEST_METHOD  [lindex $line 0]
      set uriinfo [::uri::split [lindex $line 1]]
      dict set query REQUEST_URI     [lindex $line 1]
      dict set query REQUEST_PATH    [dict get $uriinfo path]
      dict set query REQUEST_VERSION [lindex [split [lindex $line end] /] end]
      if {[dict get $uriinfo host] eq {}} {
        set HTTP_HOST [info hostname]
      } else {
        set HTTP_HOST [dict get $uriinfo host]
      }
      dict set query HTTP_CLIENT_IP  $ip
      dict set query QUERY_STRING    [dict get $uriinfo query]
      dict set query REQUEST_RAW     $line
    } on error {err errdat} {
      puts stderr $err
      my log HttpError $line
      catch {close $sock}
      return
    }
    try {
      set reply [my dispatch $query]
      if {[llength $reply]} {
        if {[dict exists $reply class]} {
          set class [dict get $reply class]          
        } else {
          set class [my cget reply_class]
        }  
        set pageobj [$class new [self]]
        if {[dict exists $reply mixin]} {
          oo::objdefine $pageobj mixin [dict get $reply mixin]
        }
        $pageobj dispatch $sock $reply
        lappend open_connections $pageobj
      } else {
        try {
          puts $sock "HTTP/1.0 404 NOT FOUND"
          dict with query {}
          set body [subst [my template notfound]]
          puts $sock "Content-length: [string length $body]"
          puts $sock
          puts $sock $body
        } on error {err errdat} {
          puts stderr "FAILED ON 404: $err"
        } finally {
          catch {close $sock}
        }
      }
    } on error {err errdat} {
      try {
        puts stderr $::errorInfo
        puts $sock "HTTP/1.0 505 INTERNAL ERROR"
        dict with query {}
        set body [subst [my template internal_error]]
        puts $sock "Content-length: [string length $body]"
        puts $sock
        puts $sock $body
      } on error {err errdat} {
        puts stderr "FAILED ON 505: $::errorInfo"
      } finally {
        catch {close $sock}
      }
    }
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
  method dispatch {data} {
    return $data
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
  
  method port_listening {} {
    my variable port_listening
    return $port_listening
  }
  
  method start {} {
    my variable socklist open_connections port_listening
    set open_connections {}
    set port [my cget port]
    if { $port in {auto {}} } {
      package require nettool
      set port [::nettool::allocate_port 8015]
    }
    set port_listening $port
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
  

  method template page {
    my variable template
    if {[info exists template($page)]} {
      return $template($page)
    }
    set template($page) [my TemplateSearch $page]
    return $template($page)
  }
  
  method TemplateSearch page {
    set doc_root [my cget doc_root]
    if {$doc_root ne {} && [file exists [file join $doc_root $page.tml]]} {
      return [::fileutil::cat [file join $doc_root $page.tml]]
    }
    if {$doc_root ne {} && [file exists [file join $doc_root $page.html]]} {
      return [::fileutil::cat [file join $doc_root $page.html]]
    }
    switch $page {
      internal_error {
        return {
<HTML>
<HEAD><TITLE>505: Internal Server Error</TITLE></HEAD>
<BODY>
Error serving <b>${REQUEST_URI}</b>:
<p>
The server encountered an internal server error
<pre><code>
$::errorInfo
</code></pre>
</BODY>
</HTML>
        }
      }
      notfound {
        return {
<HTML>
<HEAD><TITLE>404: Page Not Found</TITLE></HEAD>
<BODY>
The page you are looking for: <b>${REQUEST_URI}</b> does not exist.
</BODY>
</HTML>
        }
      }
    }
  }
}

package provide httpd 4.0
