###
# This file provides the "application" side of the SCGI protocol
###

package require html
package require TclOO

namespace eval ::scgi::app {}

oo::class create scgi.app {
  superclass

  constructor {port} {
    my listen $port  
  }
  
  destructor {
    stop
  }
  
  method listen {port script} {
    my variable sock
    set sock [socket -server [namespace code [list my connect]] $port]
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
      my variable page
      set uuid [::uuid::uuid generate]
      dict set page $uuid sock $sock
      dict set page $uuid request-headers $headers
      dict set page $uuid request-body $body
      dict set page $uuid content_length $content_length
      dict set page $uuid reply-header Status: {200 OK}
      dict set page $uuid reply-header Content-Type: text-html
      dict set page $uuid reply-data {}
      if [catch {my reply $uuid} msg] {
        my header Status: {500 Internal server error}
        my header Content-Type: {text/html}
        dict set page $uuid reply-data [my ErrorPage $msg]
      }
      my flush $uuid
    }
  }
  
  method ErrorPage msg {
    uplevel 1 uuid uuid
    return "
<HTML>
<HEAD>
<TITLE>505 Internal Error</TITLE>
</HEAD>
<BODY>
Guru meditation #$uuid
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
  
  method flush uuid {
    my variable page
    set outbuf {}
    foreach {key value} [dict get $page $uuid reply-header] {
      append outbuf "$key $value" \n
    }
    append outbuf \n [dict get $page $uuid reply-data] \n
    puts $sock $outbuf
    close $sock
  }
  
  method header {key value} {
    upvar 1 uuid uuid
    my variable page
    dict set page $uuid reply-data $key $value
  }
    
  method puts {line} {
    upvar 1 uuid uuid
    my variable page
    dict append page $uuid reply-data "$line\n"
  }
  
  ###
  # REPLACE ME:
  # This method is the "meat" of your application. It takes in the headers
  # and body of the request, and returns 
  method reply {uuid} {
    my variable page
    array set Headers [dict get $page $uuid request-headers]

    my header Status: {200 OK}
    my header Content-Type: {text/html}
    
    my puts "<HTML>"
    my puts "<BODY>"
    my puts [::html::tableFromArray Headers]
    my puts "</BODY>"
    my puts "<H3>Body</H3>"
    my puts "<PRE>[dict get $page $uuid request-body]</PRE>"
    if {$Headers(REQUEST_METHOD) eq "GET"} {
      my puts {<FORM METHOD="post" ACTION="/scgi">}
      foreach pair [split $Headers(QUERY_STRING) &] {
        lassign [split $pair =] key val
        my puts "$key: [::html::textInput $key $val]<BR>"
      }
      my puts "<BR>"
      my puts {<INPUT TYPE="submit" VALUE="Try POST">}
    } else {
      my puts {<FORM METHOD="get" ACTION="/scgi">}
      foreach pair [split [dict get $page $uuid request-body] &] {
        lassign [split $pair =] key val
        my puts "$key: [::html::textInput $key $val]<BR>"
      }
      my puts "<BR>"
      my puts {<INPUT TYPE="submit" VALUE="Try GET">}
    }
    my puts "</FORM>"
    my puts "</HTML>"
  }
}

package provide scgi::app 0.1
