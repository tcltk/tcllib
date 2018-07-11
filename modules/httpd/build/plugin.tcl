###
# httpd plugin template
###
::clay::define ::httpd::plugin {
  ###
  # Any options will be saved to the local config file
  # to allow threads to pull up a snapshot of the object' configuration
  ###

  ###
  # Define a code snippet to run on plugin load
  ###
  clay set plugin/ load {}

  ###
  # Define a code snippet to run within the object's Headers_Process method
  ###
  clay set plugin/ headers {}

  ###
  # Define a code snippet to run within the object's dispatch method
  ###
  clay set plugin/ dispatch {}

  ###
  # Define a code snippet to run within the object's writes a local config file
  ###
  clay set plugin/ local_config {}

  ###
  # When after all the plugins are loaded
  # allow specially configured ones to light off a thread
  ###
  clay set plugin/ thread {}

}

###
# A rudimentary plugin that dispatches URLs from a dict
# data structure
###
::clay::define ::httpd::plugin.dict_dispatch {
  clay set plugin/ dispatch {
    set reply [my Dispatch_Dict $data]
    if {[dict size $reply]} {
      return $reply
    }
  }

  method Dispatch_Dict {data} {
    set vhost [lindex [split [dict get $data HTTP_HOST] :] 0]
    set uri   [dict get $data REQUEST_PATH]
    foreach {host pattern info} [my uri patterns] {
      if {![string match $host $vhost]} continue
      if {![string match $pattern $uri]} continue
      set buffer $data
      foreach {f v} $info {
        dict set buffer $f $v
      }
      return $buffer
    }
    return {}
  }

  Ensemble uri::patterns {} {
    my variable url_patterns url_stream
    if {![info exists url_stream]} {
      set url_stream {}
      foreach {host hostpat} $url_patterns {
        foreach {pattern info} $hostpat {
          lappend url_stream $host $pattern $info
        }
      }
    }
    return $url_stream
  }

  Ensemble uri::add args {
    my variable url_patterns url_stream
    unset -nocomplain url_stream
    switch [llength $args] {
      2 {
        set vhosts *
        lassign $args patterns info
      }
      3 {
        lassign $args vhosts patterns info
      }
      default {
        error "Usage: add_url ?vhosts? prefix info"
      }
    }
    foreach vhost $vhosts {
      foreach pattern $patterns {
        set data $info
        if {![dict exists $data prefix]} {
           dict set data prefix [my PrefixNormalize $pattern]
        }
        dict set url_patterns $vhost [string trimleft $pattern /] $data
      }
    }
  }
}

::clay::define ::httpd::reply.memchan {
  superclass ::httpd::reply

  method output {} {
    my variable reply_body
    return $reply_body
  }

  method DoOutput {} {}

  method close {} {
    # Neuter the channel closing mechanism we need the channel to stay alive
    # until the reader sucks out the info
  }
}


::clay::define ::httpd::plugin.local_memchan {

  clay set plugin/ load {
package require tcl::chan::events
package require tcl::chan::memchan
  }

  method local_memchan {command args} {
    my variable sock_to_coro
    switch $command {
      geturl {
        ###
        # Hook to allow a local process to ask for data without a socket
        ###
        set uuid [my Uuid_Generate]
        set ip 127.0.0.1
        set sock [::tcl::chan::memchan]
        set output [coroutine ::httpd::coro::$uuid {*}[namespace code [list my Connect_Local $uuid $sock GET {*}$args]]]
        return $output
      }
      default {
        error "Valid: connect geturl"
      }
    }
  }

  ###
  # A modified connection method that passes simple GET request to an object
  # and pulls data directly from the reply_body data variable in the object
  #
  # Needed because memchan is bidirectional, and we can't seem to communicate that
  # the server is one side of the link and the reply is another
  ###
  method Connect_Local {uuid sock args} {
    chan event $sock readable {}

    chan configure $sock \
      -blocking 0 \
      -translation {auto crlf} \
      -buffering line
    set ip 127.0.0.1
    dict set query UUID $uuid
    dict set query HTTP_HOST       localhost
    dict set query REMOTE_ADDR     127.0.0.1
    dict set query REMOTE_HOST     localhost
    dict set query LOCALHOST 1
    my counter url_hit

    dict set query REQUEST_METHOD  [lindex $args 0]
    set uriinfo [::uri::split [lindex $args 1]]
    dict set query REQUEST_URI     [lindex $args 1]
    dict set query REQUEST_PATH    [dict get $uriinfo path]
    dict set query REQUEST_VERSION [lindex [split [lindex $args end] /] end]
    dict set query DOCUMENT_ROOT   [my clay get server/ doc_root]
    dict set query QUERY_STRING    [dict get $uriinfo query]
    dict set query REQUEST_RAW     $args
    dict set query SERVER_PORT     [my port_listening]
    my Headers_Process query
    set reply [my dispatch $query]

    if {[llength $reply]==0} {
      my log BadLocation $uuid $query
      my log BadLocation $uuid $query
      dict set query HTTP_STATUS 404
      dict set query template notfound
      dict set query mixin reply ::httpd::content.template
    }

    set class ::httpd::reply.memchan
    set pageobj [$class create ::httpd::object::$uuid [self]]
    if {[dict exists $reply mixin]} {
      set mixinmap [dict get $reply mixin]
    } else {
      set mixinmap {}
    }
    foreach item [dict keys $reply MIXIN_*] {
      set slot [string range $reply 6 end]
      dict set mixinmap [string tolower $slot] [dict get $reply $item]
    }
    $pageobj clay mixinmap {*}$mixinmap
    if {[dict exists $reply delegate]} {
      $pageobj clay delegate {*}[dict get $reply delegate]
    }
    $pageobj dispatch $sock $reply
    set output [$pageobj output]
    catch {$pageobj destroy}
    return $output
  }
}

