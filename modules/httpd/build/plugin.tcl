###
# httpd plugin template
###
tool::define ::httpd::plugin {
  ###
  # Any options will be saved to the local config file
  # to allow threads to pull up a snapshot of the object' configuration
  ###

  ###
  # Define a code snippet to run on plugin load
  ###
  meta set plugin load: {}

  ###
  # Define a code snippet to run within the object's Headers_Process method
  ###
  meta set plugin headers: {}

  ###
  # Define a code snippet to run within the object's dispatch method
  ###
  meta set plugin dispatch: {}

  ###
  # Define a code snippet to run within the object's writes a local config file
  ###
  meta set plugin local_config: {}

  ###
  # When after all the plugins are loaded
  # allow specially configured ones to light off a thread
  ###
  meta set plugin thread: {}

}

###
# A rudimentary plugin that dispatches URLs from a dict
# data structure
###
tool::define ::httpd::plugin.dict_dispatch {
  meta set plugin dispatch: {
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

  method uri::patterns {} {
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

  method uri::add args {
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
