###
# This file provides the "application" side of the SCGI protocol
###

package require html
package require TclOO
package require oo::meta

namespace eval ::scgi {}

oo::class create ::scgi::reply {  


  constructor {Query_headers Query_body} {
    my variable query_headers query_body reply_headers reply_body
    set query_headers $Query_headers
    set query_body $Query_body
    my reset
  }
  
  method error {msg} {
    my variable reply_headers reply_body
    set reply_headers {Status: {500 Internal server error} Content-Type: {text/html}}
    set reply_body "
<HTML>
<HEAD>
<TITLE>505 Internal Error</TITLE>
</HEAD>
<BODY>
Guru meditation #[clock seconds]
<p>
The server encountered an internal error:
<p>
<pre>$msg</pre>
<p>
For deeper understanding:
<p>
<pre>$::errorInfo</pre>
</BODY>
</HTML>
"
  }

  method flush {} {
    my variable reply_headers reply_body
    set result {}
    foreach {key value} $reply_headers {
      append result "$key $value" \n
    }
    append result \n $reply_body \n
    return $result
  }

  ###
  # REPLACE ME:
  # This method is the "meat" of your application. It takes in the headers
  # and body of the request, and returns 
  method content {} {
    my reset
    my variable query_headers
    array set Headers $query_headers

    my puts "<HTML>"
    my puts "<BODY>"
    my puts "<H1>HELLO WORLD!</H1>"
    mt puts "</BODY>"
    my puts "</HTML>"
  }

  method reset {} {
    my variable reply_headers reply_body
    set reply_headers {Status: {200 OK} Content-Type: text-html}
    set reply_body {}
  }
  
  method reply_header {var val} {
    my variable reply_headers
    dict set reply_headers $var $val
  }

  method query_header {var} {
    my variable query_headers
    if {[dict exists $query_headers $var]} {
      return [dict get $query_headers $var]
    }
    return {}
  }

  method query_body {} {
    my variable query_body
    return $query_body
  }
  
  method puts line {
    my variable reply_body
    append reply_body $line \n
  }

}

oo::class create scgi.app {
  superclass

  constructor {args} {
    my start $args
  }
  
  destructor {
    my stop
  }
  
  method start args {
    my variable sock
    set sock [socket -server [namespace code [list my connect]] {*}$args]
  }
  
  method stop {} {
    my variable sock
    catch {close $sock}
  }
  
  method connect {sock ip port} {
    fconfigure $sock -blocking 0 -translation {binary crlf}
    fileevent $sock readable [namespace code [list my read_length $sock {}]]
  }

  ###
  # Stage 1: Read the content length
  ###
  method read_length {sock data} {
    append data [read $sock]
    if {[eof $sock]} {
      close $sock
      return
    }
    set colonIdx [string first : $data]
    if {$colonIdx == -1} {
      # we don't have the headers length yet
      fileevent $sock readable [namespace code [list my read_length $sock $data]]
      return
    } else {
      set length [string range $data 0 $colonIdx-1]
      set data [string range $data $colonIdx+1 end]
      my read_headers $sock $length $data
    }
  }

  ###
  # Stage 2: Read the headers
  ###
  method read_headers {sock length data} {
    append data [read $sock]
    if {[string length $data] < $length+1} {
      # we don't have the complete headers yet, wait for more
      fileevent $sock readable [namespace code [list my read_headers $sock $length $data]]
      return
    } else {
      set headers [string range $data 0 $length-1]
      set headers [lrange [split $headers \0] 0 end-1]
      set body [string range $data $length+1 end]
      set content_length [dict get $headers CONTENT_LENGTH]
      my read_body $sock $headers $content_length $body
    }
  }

  ###
  # Stage 3: Read the body
  ###
  method read_body {sock headers content_length body} {
    append body [read $sock]
    if {[string length $body] < $content_length} {
      # we don't have the complete body yet, wait for more
      fileevent $sock readable [namespace code [list read_body $sock $headers $content_length $body]]
      return
    } else {
      set reply_class [my ReplyClass $headers $body]
      set page [$reply_class new $sock $headers $body]
      if {[catch {$page content} msg]} {
        $page error $msg
      }
      puts $sock [$page flush]
      $page destroy
    }
  }
  
  method ReplyClass {headers body} {
    return scgi.reply
  }
  
}

package provide scgi::app 0.1
