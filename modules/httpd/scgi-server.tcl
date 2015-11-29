###
# Author: Sean Woods, yoda@etoyoc.com
###
# This file provides the server side implementation of the
# SCGI protocol. It's principle purpose is to power the test
# suite
###
package require httpd

namespace eval ::scgi {}

###
# Redirect a URL to an SCGI service
###
tool::class create ::httpd::reply_scgi {
  superclass httpd::server
  
  property scgi port 10000
  property scgi host 127.0.0.1
  
  method content {} {
    dict with [my meta get scgi] {}
    
    
    set sock [socket $host $port]
    
  }
}

###
# Minimal test harness for the .tests
# Not intended for public consumption
# (But if you find it handy, please steal!)
namespace eval ::scgi::test {}

proc ::scgi::test::send {port text} {
  set sock [socket localhost $port]
  variable reply
  set reply($sock) {}
  chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
  chan event $sock readable [list ::scgi::test::get_reply $sock]
  
  set headers {}
  set body {}
  set read_headers 1
  foreach line [split $text \n] {
    if {$read_headers} {
      if { $line eq {} } {
        set read_headers 0
      } else {
        append headers $line \n
      }
    } else {
      append body $line \n
    }
  }
  set block [::scgi::encode_request $headers $body {}]
  puts -nonewline $sock $block
  flush $sock
  puts -nonewline $sock $body
  flush $sock
  while {$reply($sock) eq {}} {
    update
  }
  #vwait [namespace current]::reply($sock)
  return $reply($sock)
}

proc ::scgi::test::get_reply {sock} {
  variable buffer
  set data [read $sock]
  append buffer($sock) $data
  if {[eof $sock]} {
    chan event $sock readable {}
    set [namespace current]::reply($sock) $buffer($sock)
    unset buffer($sock)
  }
}

namespace eval ::scgi {
  variable server_block {SCGI 1.0 SERVER_SOFTWARE {TclScgiServer/0.1}}
}

package provide scgi::server 0.1
