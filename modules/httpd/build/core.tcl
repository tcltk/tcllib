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
package require dns
package require cron
package require coroutine
package require clay 0.3
package require mime
package require fileutil
package require websocket
package require Markdown
package require uuid
package require fileutil::magic::filetype

namespace eval httpd::content {}

namespace eval ::url {}
namespace eval ::httpd {}
namespace eval ::scgi {}

clay::define ::httpd::mime {

  method ChannelCopy {in out args} {
    dict set info chunk     4096
    dict set info size      -1
    foreach {f v} $args {
      dict set info [string trim $f -] $v
    }
    set total     [dict get $info size]
    set chunksize [dict get $info chunk]
    dict set info coroutine [info coroutine]
    if {$total>0 && $chunksize>$total} {
        set chunksize $total
    }
    dict set info process   [self method]
    dict set info chunk     $chunksize
    dict set info in        $in
    dict set info out       $out
    dict set info sofar     0
    dict set info complete  0
    chan copy $in $out \
        -size $chunksize \
        -command [namespace code [list my ChannelCopyEvent $info]]
    while 1 {
      set code [yield]
      if {![dict exists $code process]} break
      if {[dict get $code process] ne [self method]} {
        error "Subroutine [self method] interrupted"
      }
      if {![dict exists $code complete]} break
      if {[dict get $code complete]==1} break
    }
  }
  method ChannelCopyEvent {info {bytes 0} {error {}}} {
    dict with info {
      if {[string length $error] || [chan eof $in]} {
        set compete 1
        dict set info error $error
      }
      if {$size>=0} {
        incr sofar $bytes
        set remaining [expr {$size-$sofar}]
        if {$remaining <= 0} {
          set complete 1
        } elseif {$chunk > $remaining} {
          set chunk $remaining
        }
      }
    }
    if {[dict get $info complete]==0} {
      chan copy $in $out \
        -size $chunk \
        -command [namespace code [list my [self method] $info]]
    }
    tailcall $coroutine $info
  }

  method html_header {{title {}} args} {
    set result {}
    append result "<HTML><HEAD>"
    if {$title ne {}} {
      append result "<TITLE>$title</TITLE>"
    }
    append result "<link rel=\"stylesheet\" href=\"/style.css\">"
    append result "</HEAD><BODY>"
    return $result
  }
  method html_footer {args} {
    return "</BODY></HTML>"
  }

  method http_code_string code {
    set codes {
      200 {Data follows}
      204 {No Content}
      301 {Moved Permanently}
      302 {Found}
      303 {Moved Temporarily}
      304 {Not Modified}
      307 {Moved Permanently}
      308 {Moved Temporarily}
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
      505 {HTTP Version Not Supported}
    }
    if {[dict exists $codes $code]} {
      return [dict get $codes $code]
    }
    return {Unknown Http Code}
  }

  method HttpHeaders {sock {debug {}}} {
    set result {}
    set LIMIT 8192
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
    while 1 {
      set readCount [::coroutine::util::gets_safety $sock $LIMIT line]
      if {$readCount<=0} break
      append result $line \n
      if {[string length $result] > $LIMIT} {
        error {Headers too large}
      }
    }
    ###
    # Return our buffer
    ###
    return $result
  }

  method HttpHeaders_Default {} {
    return {Status {200 OK}
Content-Size 0
Content-Type {text/html; charset=UTF-8}
Cache-Control {no-cache}
Connection close}
  }

  method HttpServerHeaders {} {
    return {
      CONTENT_LENGTH CONTENT_TYPE QUERY_STRING REMOTE_USER AUTH_TYPE
      REQUEST_METHOD REMOTE_ADDR REMOTE_HOST REQUEST_URI REQUEST_PATH
      REQUEST_VERSION  DOCUMENT_ROOT QUERY_STRING REQUEST_RAW
      GATEWAY_INTERFACE SERVER_PORT SERVER_HTTPS_PORT
      SERVER_NAME  SERVER_SOFTWARE SERVER_PROTOCOL
    }
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
          error "INVALID HTTP HEADER FORMAT: $line"
        }
      } else {
        error "INVALID HTTP HEADER FORMAT: $line"
      }
    }
    ###
    # To make life easier for our SCGI implementation rig things
    # such that CONTENT_LENGTH is always first
    # Also map all headers specified in rfc2616 to their canonical case
    ###
    set result {}
    dict set result Content-Length 0
    foreach {key} $data(mimeorder) {
      set ckey $key
      switch [string tolower $key] {
        content-length {
          set ckey Content-Length
        }
        content-encoding {
          set ckey Content-Encoding
        }
        content-language {
          set ckey Content-Language
        }
        content-location {
          set ckey Content-Location
        }
        content-md5 {
          set ckey Content-MD5
        }
        content-range {
          set ckey Content-Range
        }
        content-type {
          set ckey Content-Type
        }
        expires {
          set ckey Expires
        }
        last-modified {
          set ckey Last-Modified
        }
        cookie {
          set ckey COOKIE
        }
        referer -
        referrer {
          # Standard misspelling in the RFC
          set ckey Referer
        }
      }
      dict set result $ckey $data(mime,$key)
    }
    return $result
  }

  method Url_Decode data {
    regsub -all {\+} $data " " data
    regsub -all {([][$\\])} $data {\\\1} data
    regsub -all {%([0-9a-fA-F][0-9a-fA-F])} $data  {[format %c 0x\1]} data
    return [subst $data]
  }

  method Url_PathCheck {urlsuffix} {
    set pathlist ""
    foreach part  [split $urlsuffix /] {
      if {[string length $part] == 0} {
        # It is important *not* to "continue" here and skip
        # an empty component because it could be the last thing,
        # /a/b/c/
        # which indicates a directory.  In this case you want
        # Auth_Check to recurse into the directory in the last step.
      }
      set part [Url_Decode $part]
    	# Disallow Mac and UNIX path separators in components
	    # Windows drive-letters are bad, too
 	    if {[regexp [/\\:] $part]} {
  	    error "URL components cannot include \ or :"
	    }
	    switch -- $part {
	      .  { }
    	  .. {
          set len [llength $pathlist]
          if {[incr len -1] < 0} {
            error "URL out of range"
          }
          set pathlist [lrange $pathlist 0 [incr len -1]]
        }
        default {
          lappend pathlist $part
        }
      }
    }
    return $pathlist
  }


  method wait {mode sock} {
    if {[info coroutine] eq {}} {
      chan event $sock $mode [list set ::httpd::lock_$sock $mode]
      vwait ::httpd::lock_$sock
    } else {
      chan event $sock $mode [info coroutine]
      yield
    }
    chan event $sock $mode {}
  }

}
