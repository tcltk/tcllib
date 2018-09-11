###
# An httpd server with a template engine
# and a shim to insert URL domains
###
namespace eval ::httpd::object {}
namespace eval ::httpd::coro {}

::clay::define ::httpd::server {
  superclass ::httpd::mime

  clay set server/ port auto
  clay set server/ myaddr 127.0.0.1
  clay set server/ string [list TclHttpd $::httpd::version]
  clay set server/ name [info hostname]
  clay set server/ doc_root {}
  clay set server/ reverse_dns 0
  clay set server/ configuration_file {}
  clay set server/ protocol {HTTP/1.1}
  clay set server/ name     {127.0.0.1}

  clay set socket/ buffersize   32768
  clay set socket/ translation  {auto crlf}
  clay set reply_class ::httpd::reply

  Array template
  Dict url_patterns {}

  constructor {args} {
    if {[llength $args]==1} {
      set arglist [lindex $args 0]
    } else {
      set arglist $args
    }
    foreach {var val} $arglist {
      my clay set server/ $var $val
    }
    my start
  }

  destructor {
    my stop
  }

  method connect {sock ip port} {
    ###
    # If an IP address is blocked drop the
    # connection
    ###
    if {[my Validate_Connection $sock $ip]} {
      catch {close $sock}
      return
    }
    set uuid [my Uuid_Generate]
    set coro [coroutine ::httpd::coro::$uuid {*}[namespace code [list my Connect $uuid $sock $ip]]]
    chan event $sock readable $coro
  }

  method ServerHeaders {ip http_request mimetxt} {
    set result {}
    dict set result HTTP_HOST {}
    dict set result CONTENT_LENGTH 0
    foreach {f v} [my MimeParse $mimetxt] {
      set fld [string toupper [string map {- _} $f]]
      if {$fld in {CONTENT_LENGTH CONTENT_TYPE}} {
        set qfld $fld
      } else {
        set qfld HTTP_$fld
      }
      dict set result $qfld $v
    }
    dict set result REMOTE_ADDR     $ip
    dict set result REMOTE_HOST     [my HostName $ip]
    dict set result REQUEST_METHOD  [lindex $http_request 0]
    set uriinfo [::uri::split [lindex $http_request 1]]
    dict set result uriinfo $uriinfo
    dict set result REQUEST_URI     [lindex $http_request 1]
    dict set result REQUEST_PATH    [dict get $uriinfo path]
    dict set result REQUEST_VERSION [lindex [split [lindex $http_request end] /] end]
    dict set result DOCUMENT_ROOT   [my clay get server/ doc_root]
    dict set result QUERY_STRING    [dict get $uriinfo query]
    dict set result REQUEST_RAW     $http_request
    dict set result SERVER_PORT     [my port_listening]
    dict set result SERVER_NAME     [my clay get server/ name]
    dict set result SERVER_PROTOCOL [my clay get server/ protocol]
    dict set result SERVER_SOFTWARE [my clay get server/ string]
    if {[string match 127.* $ip]} {
      dict set result LOCALHOST [expr {[lindex [split [dict getnull $result HTTP_HOST] :] 0] eq "localhost"}]
    }
    return $result
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
      set readCount [::coroutine::util::gets_safety $sock 4096 http_request]
      set mimetxt [my HttpHeaders $sock]
      dict set query UUID $uuid
      dict set query mimetxt $mimetxt
      dict set query mixin style [my clay get server/ style]
      dict set query http [my ServerHeaders $ip $http_request $mimetxt]
      my Headers_Process query
      set reply [my dispatch $query]
    } on error {err errdat} {
      my debug [list uri: [dict getnull $query REQUEST_URI] ip: $ip error: $err errorinfo: [dict get $errdat -errorinfo]]
      my log BadRequest $uuid [list ip: $ip error: $err errorinfo: [dict get $errdat -errorinfo]]
      catch {chan puts $sock "HTTP/1.0 400 Bad Request (The data is invalid)"}
      catch {chan close $sock}
      return
    }
    if {[dict size $reply]==0} {
      my log BadLocation $uuid $query
      my log BadLocation $uuid $query
      dict set query http HTTP_STATUS 404
      dict set query template notfound
      dict set query mixin reply ::httpd::content.template
    }
    try {
      set pageobj [::httpd::reply create ::httpd::object::$uuid [self]]
      tailcall $pageobj dispatch $sock $reply
    } on error {err errdat} {
      my debug [list ip: $ip error: $err errorinfo: [dict get $errdat -errorinfo]]
      my log BadRequest $uuid [list ip: $ip error: $err errorinfo: [dict get $errdat -errorinfo]]
      catch {$pageobj destroy}
      catch {chan close $sock}
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
    foreach obj [info commands ::httpd::object::*] {
      try {
        $obj timeOutCheck
      } on error {} {
        catch {$obj destroy}
      }
    }
  }

  method debug args {}

  ###
  # Route a request to the appropriate handler
  ###
  method dispatch {data} {
    set reply [my Dispatch_Local $data]
    if {[dict size $reply]} {
      return $reply
    }
    return [my Dispatch_Default $data]
  }

  method Dispatch_Default {reply} {
    ###
    # Fallback to docroot handling
    ###
    set doc_root [dict getnull $reply http DOCUMENT_ROOT]
    if {$doc_root ne {}} {
      ###
      # Fall back to doc_root handling
      ###
      dict set reply prefix {}
      dict set reply path $doc_root
      dict set reply mixin reply httpd::content.file
      return $reply
    }
    return {}
  }

  method Dispatch_Local data {}

  method Headers_Local {varname} {}

  method Headers_Process varname {}

  method HostName ipaddr {
    if {![my clay get server/ reverse_dns]} {
      return $ipaddr
    }
    set t [::dns::resolve $ipaddr]
    set result [::dns::name $t]
    ::dns::cleanup $t
    return $result
  }

  method log args {
    # Do nothing for now
  }

  method plugin {slot {class {}}} {
    if {$class eq {}} {
      set class ::httpd::plugin.$slot
    }
    if {[info command $class] eq {}} {
      error "Class $class for plugin $slot does not exist"
    }
    my clay mixinmap $slot $class
    set mixinmap [my clay get mixin]

    ###
    # Perform action on load
    ###
    set script [$class clay search plugin/ load]
    eval $script

    ###
    # rebuild the dispatch method
    ###
    set body "\n try \{"
    append body \n {
  set reply [my Dispatch_Local $data]
  if {[dict size $reply]} {return $reply}
}

    foreach {slot class} $mixinmap {
      set script [$class clay search plugin/ dispatch]
      if {[string length $script]} {
        append body \n "# SLOT $slot"
        append body \n $script
      }
    }
    append body \n {  return [my Dispatch_Default $data]}
    append body \n "\} on error \{err errdat\} \{"
    append body \n {  puts [list DISPATCH ERROR [dict get $errdat -errorinfo]] ; return {}}
    append body \n "\}"
    oo::objdefine [self] method dispatch data $body
    ###
    # rebuild the Headers_Process method
    ###
    set body "\n try \{"
    append body \n "  upvar 1 \$varname query"
    append body \n {  my Headers_Local query}
    foreach {slot class} $mixinmap {
      set script [$class clay search plugin/ headers]
      if {[string length $script]} {
        append body \n "# SLOT $slot"
        append body \n $script
      }
    }
    append body \n "\} on error \{err errdat\} \{"
    append body \n {  puts [list HEADERS ERROR [dict get $errdat -errorinfo]] ; return {}}
    append body \n "\}"

    oo::objdefine [self] method Headers_Process varname $body

    ###
    # rebuild the Threads_Start method
    ###
    set body "\n try \{"
    foreach {slot class} $mixinmap {
      set script [$class clay search plugin/ thread]
      if {[string length $script]} {
        append body \n "# SLOT $slot"
        append body \n $script
      }
    }
    append body \n "\} on error \{err errdat\} \{"
    append body \n {  puts [list THREAD START ERROR [dict get $errdat -errorinfo]] ; return {}}
    append body \n "\}"
    oo::objdefine [self] method Thread_start {} $body
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

  method source {filename} {
    source $filename
  }

  method start {} {
    # Build a namespace to contain replies
    namespace eval [namespace current]::reply {}

    my variable socklist port_listening
    if {[my clay get server/ configuration_file] ne {}} {
      source [my clay get server/ configuration_file]
    }
    set port [my clay get server/ port]
    if { $port in {auto {}} } {
      package require nettool
      set port [::nettool::allocate_port 8015]
    }
    set port_listening $port
    set myaddr [my clay get server/ myaddr]
    my debug [list [self] listening on $port $myaddr]

    if {$myaddr ni {all any * {}}} {
      foreach ip $myaddr {
        lappend socklist [socket -server [namespace code [list my connect]] -myaddr $ip $port]
      }
    } else {
      lappend socklist [socket -server [namespace code [list my connect]] $port]
    }
    ::cron::every [self] 120 [namespace code {my CheckTimeout}]
    my Thread_start
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

  Ensemble SubObject::db {} {
    return [namespace current]::Sqlite_db
  }
  Ensemble SubObject::default {} {
    return [namespace current]::$method
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
    set doc_root [my clay get server/ doc_root]
    if {$doc_root ne {} && [file exists [file join $doc_root $page.tml]]} {
      return [::fileutil::cat [file join $doc_root $page.tml]]
    }
    if {$doc_root ne {} && [file exists [file join $doc_root $page.html]]} {
      return [::fileutil::cat [file join $doc_root $page.html]]
    }
    switch $page {
      redirect {
return {
[my html_header "$HTTP_STATUS"]
The page you are looking for: <b>[my request get REQUEST_URI]</b> has moved.
<p>
If your browser does not automatically load the new location, it is
<a href=\"$msg\">$msg</a>
[my html_footer]
}
      }
      internal_error {
        return {
[my html_header "$HTTP_STATUS"]
Error serving <b>[my request get REQUEST_URI]</b>:
<p>
The server encountered an internal server error: <pre>$msg</pre>
<pre><code>
$errorInfo
</code></pre>
[my html_footer]
        }
      }
      notfound {
        return {
[my html_header "$HTTP_STATUS"]
The page you are looking for: <b>[my request get REQUEST_URI]</b> does not exist.
[my html_footer]
        }
      }
    }
  }

  method Thread_start {} {}

  method Uuid_Generate {} {
    return [::uuid::uuid generate]
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
::clay::define ::httpd::server::dispatch {
    superclass ::httpd::server
}
