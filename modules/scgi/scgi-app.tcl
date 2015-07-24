###
# Author: Sean Woods, yoda@etoyoc.com
###
# This file provides the "application" side of the SCGI protocol
###

package require html
package require TclOO
package require oo::meta

namespace eval ::scgi {}

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

oo::class create ::scgi::reply {  
  superclass ::httpd::reply
  
  property socket buffersize   32768
  property socket blocking     0
  property socket translation  {binary binary}


  method RequestRead {} {    
    my variable chan
    my variable data
    my variable inbuffer
    set rawdata [read $chan]
    append inbuffer $rawdata
    if {[eof $chan]} {
      my destroy
      return
    }
    if {$data(state) == "start"} {
      set colonIdx [string first : $inbuffer]
      if {$colonIdx == -1} {
        # we don't have the headers length yet
        return
      } else {
        set length [string range $inbuffer 0 $colonIdx-1]
        set inbuffer [string range $inbuffer $colonIdx+1 end]
        set data(state) headers
        set data(length) $length
      }
    }
    if {$data(state) == "headers" } {
      if {[string length $inbuffer] < $data(length)+1} {
        # we don't have the complete headers yet, wait for more
        return
      }
      set headers [string range $inbuffer 0 $data(length)-1]
      set headers [lrange [split $headers \0] 0 end-1]
      my variable query_body
      set inbuffer [string range $inbuffer $data(length)+1 end]
      set data(content_length) [dict get $headers CONTENT_LENGTH]
      my meta set query_headers $headers
      set data(state) body
    }
    
    if {[string length $inbuffer] < $data(content_length)} {
      return
    }
    my variable query_body
    set query_body $inbuffer

    # Dispatch to the URL implementation.
    if [catch {
      set code [my <server> dispatch [self]]
      if {$code eq 200} {
        my content
      }
    } err] {
      my error 500 $err
    } else {
      my output
    }
    return
    
  }
  
  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method output {} {
    my variable reply_body
    set reply_body [string trim $reply_body]
    set headers [my meta get reply_headers]
    set result "Status: [my meta get reply_status]\n"
    foreach {key value} $headers {  
      append result "$key $value" \n
    }
    append result "Content-length: [string length $reply_body]" \n \n
    append result $reply_body
    my variable chan
    puts -nonewline $chan $result
    flush $chan
    my destroy
  }
}

oo::class create scgi::app {
  superclass ::httpd::server

  property reply_class ::scgi::reply
  
}

package provide scgi::app 0.1
