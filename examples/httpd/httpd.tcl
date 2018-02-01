###
# "Simple" webserver example
###

set DIR [file dirname [file normalize [info script]]]
set DEMOROOT [file join $DIR htdocs]
set tcllibroot  [file normalize [file join $DIR .. ..]]
set auto_path [linsert $auto_path 0 [file normalize [file join $tcllibroot modules]]]
package require httpd 4.1
###
# This script creates two toplevel domains:
# * Hosting the tcllib embedded documentation as static content
# * Hosting a local fossil mirror of the tcllib repository
###
package require httpd

proc ::fossil-list {} {
  return [::fossil all list]
}
proc ::fossil args {
  if {![info exists ::fossil_exe]} {
    set ::fossil_exe fossil
  }
  if {[llength $args]==0} {
    return $::fossil_exe
  }
  return [exec ${::fossil_exe} {*}$args]
}

tool::class create httpd::content::fossil_root {

  method content {} {
    my reset
    my puts "<HTML><HEAD><TITLE>Local Fossil Repositories</TITLE></HEAD><BODY>"
    global recipe
    my puts "<UL>"
    set dbfiles [::fossil-list]
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
    set uri    [my http_info get REQUEST_URI]
    set prefix [my http_info get prefix]
    set module [lindex [split $uri /] 2]
    file mkdir ~/tmp
    if {![info exists ::fossil_process($module)]} {
      package require processman
      package require nettool
      set port [::nettool::allocate_port 40000]
      set handle fossil:$port
      set dbfiles [::fossil-list]
      foreach file [lsort -dictionary $dbfiles]  {
        dict set result [file rootname [file tail $file]] $file
      }
      set dbfile [dict get $result $module]
      if {![file exists $dbfile]} {
        tailcall my error 400 {Not Found}
      }
      set mport [my <server> port_listening]
      set cmd [list [::fossil] server $dbfile --port $port --localhost --scgi 2>~/tmp/$module.err >~/tmp/$module.log]

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
}

tool::class create ::docserver::server {
  superclass ::httpd::server

  method log args {
    puts [list {*}$args]
  }

}

tool::define ::docserver::dynamic {

  method content {} {
    my puts "<HTML><HEAD><TITLE>IRM Dispatch Server</TITLE></HEAD><BODY>"
    my puts "<TABLE width=100%>"
    foreach {f v} [my request dump] {
        my puts "<tr><th>$f</th><td>$v</td></tr>"
    }
    my puts "<tr><td colspan=10><hr></td></tr>"
    foreach {f v} [my http_info dump] {
        my puts "<tr><th>$f</th><td>$v</td></tr>"
    }
    my puts "<tr><th>File Size</th><td>[my http_info get CONTENT_LENGTH]</td></tr>"
    my puts </TABLE>
    my puts </BODY></HTML>
  }

}

tool::define ::docserver::upload {
  superclass ::docserver::dynamic

  method content {} {
    my puts "<HTML><HEAD><TITLE>IRM Dispatch Server</TITLE></HEAD><BODY>"
    my puts "<TABLE width=100%>"
    set FORMDAT [my FormData]
    foreach {f v} [my FormData] {
        my puts "<tr><th>$f</th><td>$v</td></tr>"
    }
    my puts "<tr><td colspan=10><hr></td></tr>"
    foreach {f v} [my http_info dump] {
        my puts "<tr><th>$f</th><td>$v</td></tr>"
    }
    my puts "<tr><td colspan=10><hr></td></tr>"
    foreach part [dict getnull $FORMDAT MIME_PARTS] {
      my puts "<tr><td colspan=10><hr></td></tr>"
      foreach f [::mime::getheader $part -names] {
        my puts "<tr><th>$f</th><td>[mime::getheader $part $f]</td></tr>"
      }
      my puts "<tr><td colspan=10>[::mime::getbody $part -decode]</td></tr>"
    }
    my puts "<tr><th>File Size</th><td>[my http_info get CONTENT_LENGTH]</td></tr>"
    my puts </TABLE>
    my puts </BODY></HTML>
  }
}

set opts [::tool::args_to_options {*}$argv]
set serveropts {}
set optinfo [::docserver::server meta getnull option]
foreach {f v} $opts {
  if {[dict exists $optinfo $f]} {
    dict set serveropts $f $v
  }
}
puts $serveropts
set fossilopts {}
set optinfo [::httpd::content::fossil_root meta getnull option]
foreach {f v} $opts {
  if {[dict exists $optinfo $f]} {
    dict set fossilopts $f $v
  }
}
if {[dict exists $opts fossil]} {
  set ::fossil_exe [dict get $opts fossil]
}
puts "Server Options: $serveropts"
puts "Fossil Options: $fossilopts"


::docserver::server create appmain doc_root $DEMOROOT {*}$argv
appmain add_uri /tcllib* [list mixin httpd::content::file path [file join $tcllibroot embedded www]]
appmain add_uri /fossil [list mixin httpd::content::fossil_root {*}$fossilopts]
appmain add_uri /fossil/* [list mixin httpd::content::fossil_node_scgi {*}$fossilopts]
appmain add_uri /upload [list mixin ::docserver::upload]
appmain add_uri /dynamic [list mixin ::docserver::dynamic]
appmain add_uri /listen [list mixin ::docserver::listen]
appmain add_uri /send   [list mixin ::docserver::send]
puts [list LISTENING]
tool::main
