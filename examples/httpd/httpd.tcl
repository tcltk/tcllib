###
# Simple webserver example
###

set DIR [file dirname [file normalize [info script]]]
set DEMOROOT [file join $DIR htdocs]
set tcllibroot  [file normalize [file join $DIR .. ..]]
set auto_path [linsert $auto_path 0 [file normalize [file join $tcllibroot modules]]]
package require httpd
package require httpd::content

###
# This script creates two toplevel domains:
# * Hosting the tcllib embedded documentation as static content
# * Hosting a local fossil mirror of the tcllib repository
###
package require httpd

tool::class create httpd::content::fossil_root {
  method content {} {
    my reset
    my puts "<HTML><HEAD><TITLE>Local Fossil Repositories</TITLE></HEAD><BODY>"
    global recipe
    my puts "<UL>"
    set dbfiles [exec fossil all list]
    foreach file [lsort -dictionary $dbfiles]  {
      dict set result [file rootname [file tail $file]] $file
    }
    foreach {module dbfile} [lsort -dictionary -stride 2 $result] {
      my puts "<li><a HREF=/fossil/$module>$module</a>"
    }
    my puts {</UL></BODY></HTML>}
  }
}

###
# This driver for fossil is not a standard SCGI module
# it's more or less cargo culted from a working prototype
# developed for the GORT project. You'll note it does some
# things that are non-standard for SCGI, and that's to work
# around quirks in Fossil SCGI implementation.
#
# (Either that or my reading of SCGI specs is way, way off.
# I'm 75% sure I'm doing something wrong.)
#
# Actually, according to DRH we should really be using CGI
# because that is better supported. So until we get the
# CGI functions fleshed out, here's FOSSIL...
#
# --Sean "The Hypnotoad" Woods
###
tool::class create httpd::content::fossil_node_scgi {
  
  superclass httpd::content::scgi
  method scgi_info {} {
    set uri    [my query_headers get REQUEST_URI]
    set prefix [my query_headers get prefix]
    set module [lindex [split $uri /] 2]
    file mkdir ~/tmp
    if {![info exists ::fossil_process($module)]} {
      package require processman
      package require nettool
      set port [::nettool::allocate_port 40000]
      set handle fossil:$port
      set dbfiles [exec fossil all list]
      foreach file [lsort -dictionary $dbfiles]  {
        dict set result [file rootname [file tail $file]] $file
      }
      set dbfile [dict get $result $module]
      if {![file exists $dbfile]} {
        tailcall my error 400 {Not Found}
      }
      set mport [my <server> port_listening]
      set cmd [list fossil server $dbfile --port $port --localhost --scgi 2>~/tmp/$module.err >~/tmp/$module.log]

      dict set ::fossil_process($module) port $port
      dict set ::fossil_process($module) handle $handle
      dict set ::fossil_process($module) cmd $cmd
      dict set ::fossil_process($module) SCRIPT_NAME $prefix/$module
    }
    dict with ::fossil_process($module) {}
    if {![::processman::running $handle]} {
      set process [::processman::spawn $handle {*}$cmd]
      my varname paused
      after 500
    }
    return [list localhost $port $SCRIPT_NAME]
  }

  method content {} {
    my variable sock chan
    set sockinfo [my scgi_info]
    if {$sockinfo eq {}} {
      my error 404 {Not Found}
      return
    }
    lassign $sockinfo scgihost scgiport scgiscript
    set sock [::socket $scgihost $scgiport]
    # Add a few headers that SCGI needs
    my query_headers set SCRIPT_NAME $scgiscript
    my query_headers set SCGI 1.0    

    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    ###
    # Convert our query headers into netstring format. Note that
    # MimeParse as already rigged it such that CONTENT_LENGTH is first
    # and always populated (even if zero), per SCGI requirements
    ###
    set block [my query_headers netstring]
    puts -nonewline $sock $block
    set length [my query_headers get CONTENT_LENGTH]
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $chan $sock -size $length
    }
    chan flush $sock
    ###
    # Wake this object up after the SCGI process starts to respond
    ###
    #chan configure $sock -translation {auto crlf} -blocking 0 -buffering line
    chan event $sock readable [namespace code {my output}]
  }
  
  method dispatch {newsock datastate} {
    my query_headers replace $datastate
    my variable chan rawrequest dipatched_time
    set chan $newsock
    chan event $chan readable {}
    chan configure $chan -translation {auto crlf} -buffering line
    set dispatched_time [clock seconds]
    try {
      set rawrequest [my HttpHeaders $chan]
      foreach {field value} [my MimeParse $rawrequest] {
        my query_headers set $field $value
      }
      # Dispatch to the URL implementation.
      my content
    } on error {err info} {
      dict print $info
      #puts stderr $::errorInfo
      my error 500 $err
    } finally {
      my output
    }
  }
  
  method output {} {
    if {[my query_headers getnull HTTP_ERROR] ne {}} {
      ###
      # If something croaked internally, handle this page as a normal reply
      ###
      next
    }
    my variable sock chan
    set replyhead [my HttpHeaders $sock]
    set replydat  [my MimeParse $replyhead]
    ###
    # Convert the Status: header from the SCGI service to
    # a standard service reply line from a web server, but
    # otherwise spit out the rest of the headers verbatim
    ###
    set replybuffer "HTTP/1.1 [dict get $replydat HTTP_STATUS]\n"
    append replybuffer $replyhead
    chan configure $chan -translation {auto crlf} -blocking 0 -buffering full -buffersize 4096
    puts $chan $replybuffer
    ###
    # Output the body
    ###
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    set length [dict get $replydat CONTENT_LENGTH]
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $sock $chan -command [namespace code [list my TransferComplete $sock]]
    } else {
      catch {close $sock}
      chan flush $chan
      my destroy
    }
  }

}

tool::class create ::docserver::server {
  superclass ::httpd::server::dispatch ::httpd::server
  

  method log args {
    puts [list {*}$args]
  }
  
}

::docserver::server create appmain doc_root $DEMOROOT {*}$argv
appmain add_uri /tcllib* [list mixin httpd::content::file path [file join $tcllibroot embedded www]]
appmain add_uri /fossil {mixin httpd::content::fossil_root}
appmain add_uri /fossil/* {mixin httpd::content::fossil_node_scgi}
puts [list LISTENING]
tool::main
