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
# Fossil nodes are actually handoffs to fossil passthrough handlers
###
tool::class create httpd::content::fossil_node_scgi {
  superclass httpd::content::scgi
  
  method scgi_info {} {
    file mkdir ~/tmp
    set uri    [my query_headers get REQUEST_URI]
    set prefix [my query_headers get prefix]
    set module [lindex [split $uri /] 2]
    puts [list *** $uri -> $module]
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
      set server_name [my <server> cget server_name]
      set mport [my <server> port_listening]
      set baseurl http://${server_name}:${mport}/fossil/$module
      set cmd [list fossil server --baseurl $baseurl --port $port --localhost --scgi $dbfile 2>~/tmp/$module.err >~/tmp/$module.log]
      dict set ::fossil_process($module) repo $dbfile
      dict set ::fossil_process($module) port $port
      dict set ::fossil_process($module) handle $handle
      dict set ::fossil_process($module) cmd $cmd
      dict set ::fossil_process($module) SCRIPT_NAME $prefix/$module
      ::puts [list Launching SCGI $module]
      foreach {field value} $::fossil_process($module) {
        ::puts [list $field: $value]
      }
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
