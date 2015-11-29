###
# This script creates two toplevel domains:
# * Hosting the tcllib embedded documentation as static content
# * Hosting a local fossil mirror of the tcllib repository
###
set here [file dirname [file join [pwd] [info script]]]
set DEMOROOT $here
set tcllibroot [file normalize [file join $here .. .. ..]]
set auto_path [linsert $auto_path 0 [file join $tcllibroot modules]]
package require httpd
package require httpd::content

tool::class create ::docserver::reply::scgi_fossil {
  superclass httpd::content::scgi

  method scgi_info {} {
    ###
    # We could calculate this all out ahead of time
    # but it's a nice demo to be able to launch the process
    # and compute the parameters needed on the fly
    ###
    set uri    [my query_headers get REQUEST_URI]
    set prefix [my query_headers get prefix]
    set prefix [string trimright $prefix *]
    set prefix [string trimright $prefix /]
    set module tcllib
    ###
    # 
    if {![info exists ::fossil_process($module)]} {
      set info [exec fossil status]
      set dbfile {}
      foreach line [split $info \n] {
        if {[lindex $line 0] eq "repository:"} {
          set dbfile [string trim [string range $line 12 end]]
          break
        }
      }
      if {$dbfile eq {}} {
        tailcall my error 505 "Could not locate fossil respository database"
      }
      puts [list LAUNCHING $module $dbfile]
      package require processman
      package require nettool
      set port [::nettool::allocate_port 40000]
      set handle fossil:$port
      set mport [my <server> port_listening]
      set cmd [list fossil server $dbfile --port $port --localhost --scgi --baseurl http://[my query_headers get HTTP_HOST]$prefix 2>/tmp/$module.err >/tmp/$module.log]
      dict set ::fossil_process($module) port $port
      dict set ::fossil_process($module) handle $handle
      dict set ::fossil_process($module) cmd $cmd
      dict set ::fossil_process($module) SCRIPT_NAME $prefix
    }
    dict with ::fossil_process($module) {}
    if {![::processman::running $handle]} {
      puts "LAUNCHING $module as $cmd"
      set process [::processman::spawn $handle {*}$cmd]
      puts "LAUNCHED"
      my varname paused
      after 500
      puts "RESUMED"
    }
    return [list localhost $port $SCRIPT_NAME]
  }
}

tool::class create ::docserver::reply::proxy_fossil {
  superclass httpd::content::proxy

  method proxy_info {} {
    ###
    # We could calculate this all out ahead of time
    # but it's a nice demo to be able to launch the process
    # and compute the parameters needed on the fly
    ###
    set uri    [my query_headers get REQUEST_URI]
    set prefix [my query_headers get prefix]
    set prefix [string trimright $prefix *]
    set prefix [string trimright $prefix /]
    set module tcllib.proxy
    ###
    # 
    if {![info exists ::fossil_process($module)]} {
      set info [exec fossil status]
      set dbfile {}
      foreach line [split $info \n] {
        if {[lindex $line 0] eq "repository:"} {
          set dbfile [string trim [string range $line 12 end]]
          break
        }
      }
      if {$dbfile eq {}} {
        tailcall my error 505 "Could not locate fossil respository database"
      }
      puts [list LAUNCHING $module $dbfile]
      package require processman
      package require nettool
      set port [::nettool::allocate_port 40000]
      set handle fossil:$port
      set mport [my <server> port_listening]
      set cmd [list fossil server $dbfile --port $port --localhost --baseurl http://[my query_headers get HTTP_HOST]$prefix 2>/tmp/$module.err >/tmp/$module.log]
      dict set ::fossil_process($module) port $port
      dict set ::fossil_process($module) handle $handle
      dict set ::fossil_process($module) cmd $cmd
      dict set ::fossil_process($module) SCRIPT_NAME $prefix
    }
    dict with ::fossil_process($module) {}
    if {![::processman::running $handle]} {
      puts "LAUNCHING $module as $cmd"
      set process [::processman::spawn $handle {*}$cmd]
      puts "LAUNCHED"
      my varname paused
      after 500
      puts "RESUMED"
    }
    set rawreq    [my query_headers get REQUEST_RAW]
    set URI [string range [lindex $rawreq 1] [string length $prefix] end]
    if {$URI eq {}} {
      set URI /
    }
    set proxyuri "[lindex $rawreq 0] $URI [lindex $rawreq 2]"
    return [list localhost $port $proxyuri]
  }
}

tool::class create ::docserver::server {
  superclass ::httpd::server::dispatch ::httpd::server
}

::docserver::server create appmain doc_root $DEMOROOT
appmain add_uri /tcllib* [list mixin httpd::content::file path [file join $tcllibroot embedded www]]
appmain add_uri /fossil* {mixin ::docserver::reply::scgi_fossil}
appmain add_uri /proxy* {mixin ::docserver::reply::proxy_fossil}

tool::main
