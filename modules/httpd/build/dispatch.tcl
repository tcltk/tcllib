::clay::define ::httpd::content.redirect {

  method reset {} {
    ###
    # Inject the location into the HTTP headers
    ###
    my variable reply_body
    set reply_body {}
    my reply replace    [my HttpHeaders_Default]
    my reply set Server [my <server> clay get server/ string]
    set msg [my clay get LOCATION]
    my reply set Location [my clay get LOCATION]
    set code  [my clay get REDIRECT_CODE]
    if {$code eq {}} {
      set code 301
    }
    my reply set Status [list $code [my http_code_string $code]]
  }

  method content {} {
    set template [my <server> template redirect]
    set msg [my clay get LOCATION]
    set HTTP_STATUS [my reply get Status]
    my puts [subst $msg]
  }
}

::clay::define ::httpd::content.cache {

  method dispatch {newsock datastate} {
    my variable chan
    set chan $newsock
    chan event $chan readable {}
    try {
      my request dispatch $datastate
      my wait writable $chan
      chan configure $chan  -translation {binary binary}
      chan puts -nonewline $chan [my clay get cache/ data]
    } on error {err info} {
      my <server> debug [dict get $info -errorinfo]
    } finally {
      my TransferComplete $chan
    }
  }
}

::clay::define ::httpd::content.template {

  method content {} {
    if {[my request get HTTP_STATUS] ne {}} {
      my reply set Status [my request get HTTP_STATUS]
    }
    my puts [subst [my <server> template [my clay get template]]]
  }
}
