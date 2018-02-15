###
# An httpd server with a template engine
# and a shim to insert URL domains
###

::tool::define ::httpd::server {

  option port  {default: auto}
  option myaddr {default: 127.0.0.1}
  option server_string [list default: [list TclHttpd $::httpd::version]]
  option server_name [list default: [list [info hostname]]]
  option doc_root {default {}}

  property socket buffersize   32768
  property socket translation  {auto crlf}
  property reply_class ::httpd::reply

  array template
  variable url_patterns {}

  constructor {args} {
    my configure {*}$args
    my start
  }

  destructor {
    my stop
  }

  method add_uri {pattern info} {
    my variable url_patterns
    dict set url_patterns $pattern $info
  }

  method connect {sock ip port} {
    ###
    # If an IP address is blocked
    # send a "go to hell" message
    ###
    if {[my Validate_Connection $sock $ip]} {
      catch {close $sock}
      return
    }
    set uuid [my Uuid_Generate]
    set coro [coroutine [namespace current]::CORO$uuid {*}[namespace code [list my Connect $uuid $sock $ip]]]
    chan event $sock readable $coro
  }

  method Connect {uuid sock ip} {
    yield [info coroutine]
    chan event $sock readable {}

    chan configure $sock \
      -blocking 0 \
      -translation {auto crlf} \
      -buffering line

    my counter url_hit
    set line {}
    try {
      set readCount [::coroutine::util::gets_safety $sock 4096 line]
      dict set query REMOTE_ADDR     $ip
      dict set query REQUEST_METHOD  [lindex $line 0]
      set uriinfo [::uri::split [lindex $line 1]]
      dict set query REQUEST_URI     [lindex $line 1]
      dict set query REQUEST_PATH    [dict get $uriinfo path]
      dict set query REQUEST_VERSION [lindex [split [lindex $line end] /] end]
      if {[dict get $uriinfo host] eq {}} {
        if {$ip eq "127.0.0.1"} {
          dict set query HTTP_HOST localhost
        } else {
          dict set query HTTP_HOST [info hostname]
        }
      } else {
        dict set query HTTP_HOST [dict get $uriinfo host]
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
        set pageobj [$class create [namespace current]::reply$uuid [self]]
        if {[dict exists $reply mixin]} {
          oo::objdefine $pageobj mixin [dict get $reply mixin]
        }
        $pageobj dispatch $sock $reply
        my log HttpAccess $line
      } else {
        try {
          my log HttpMissing $line
          chan puts $sock "HTTP/1.0 404 NOT FOUND"
          dict with query {}
          set body [subst [my template notfound]]
          chan puts $sock "Content-Length: [string length $body]"
          chan puts $sock {}
          chan puts $sock $body
        } on error {err errdat} {
          puts stderr "FAILED ON 404: $err"
        } finally {
          catch {chan close $sock}
          catch {destroy $pageobj}
        }
      }
    } on error {err errdat} {
      try {
        #puts stderr [dict print $errdat]
        chan puts $sock "HTTP/1.0 505 INTERNAL ERROR - server 119"
        dict with query {}
        set body [subst [my template internal_error]]
        chan puts $sock "Content-Length: [string length $body]"
        chan puts $sock {}
        chan puts $sock $body
        my log HttpError $line
      } on error {err errdat} {
        my log HttpFatal $::errorInfo
        #puts stderr "FAILED ON 505: $::errorInfo"
      } finally {
        catch {chan close $sock}
        catch {destroy $pageobj}
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
    foreach obj [info commands [namespace current]::reply::*] {
      try {
        $obj timeOutCheck
      } on error {} {
        catch {$obj destroy}
      }
    }
  }

  ###
  # Route a request to the appropriate handler
  ###
  method dispatch {data} {
    set reply $data
    set uri [dict get $data REQUEST_PATH]
    # Search from longest pattern to shortest
    my variable url_patterns
    foreach {pattern info} $url_patterns {
      if {[string match ${pattern} /$uri]} {
        set reply [dict merge $data $info]
        if {![dict exists $reply prefix]} {
          dict set reply prefix [my PrefixNormalize $pattern]
        }
        return $reply
      }
    }
    set doc_root [my cget doc_root]
    if {$doc_root ne {}} {
      ###
      # Fall back to doc_root handling
      ###
      dict set reply prefix {}
      dict set reply path $doc_root
      dict set reply mixin httpd::content.file
      return $reply
    }
    return {}
  }

  method log args {
    # Do nothing for now
  }

  method port_listening {} {
    my variable port_listening
    return $port_listening
  }

  method PrefixNormalize prefix {
    set prefix [string trimright $prefix /]
    set prefix [string trimright $prefix *]
    set prefix [string trimright $prefix /]
    return $prefix
  }

  method start {} {
    # Build a namespace to contain replies
    namespace eval [namespace current]::reply {}

    my variable socklist port_listening
    set port [my cget port]
    if { $port in {auto {}} } {
      package require nettool
      set port [::nettool::allocate_port 8015]
    }
    set port_listening $port
    set myaddr [my cget myaddr]
    my log [list [self] listening on $port $myaddr]

    if {$myaddr ni {all any * {}}} {
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
    if {[info exists socklist]} {
      foreach sock $socklist {
        catch {close $sock}
      }
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

  method Uuid_Generate {} {
    my variable next_uuid
    return [incr next_uuid]
  }

  ###
  # Return true if this IP address is blocked
  # The socket will be closed immediately after returning
  # This handler is welcome to send a polite error message
  ###
  method Validate_Connection {sock ip} {
    return 0
  }
}

###
# Provide a backward compadible alias
###
::tool::define ::httpd::server::dispatch {
    superclass ::httpd::server
}
