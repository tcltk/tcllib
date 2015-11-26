###
# This file implements an extensible dispatch server for the httpd package
# The package is seperate because the code is equally applicable for either
# the httpd and scgi modes, and it also injects a suite of assumptions
# that may not be applicable to a general purpose tool
###
package require tool
package require httpd::content

tool::class create httpd::server::dispatch {
  array template
  option doc_root {default {}}
  variable url_patterns {}
  variable scgi_patterns {}
  
  method add_root {pattern class} {
    my variable url_patterns
    dict set url_patterns $pattern $class
  }

  method add_scgi {pattern info} {
    my variable scgi_patterns
    dict set scgi_patterns $pattern $info
  }
  
  method dispatch {data} {
    set reply $data
    set uri [dict get $data REQUEST_URI]
    # Search from longest pattern to shortest
    my variable url_patterns
    foreach {pattern class} $url_patterns {
      puts "<server> CHECK url $uri $pattern"
      if {[string match ${pattern} $uri]} {
        puts [list MATCH $pattern $class]
        dict set reply mixin $class
        dict set reply prefix $pattern
        return $reply
      }
    }
    set doc_root [my cget doc_root]
    if {$uri in "{} / /home /index.html /index.md /index"} {
      puts "<server> url $uri HOME"
      ###
      # Handle HOME page
      ###
      dict set reply mixin httpd::content::file
      dict set reply local_file [file join $doc_root index.md]
      return $reply
    }
    ###
    # Search for a file of the same name in doc_root
    ###
    if {$doc_root ne {}} {
      set fname [string trimleft $uri /]
      puts [list URL $fname doc_root $doc_root]
      if {[file exists [file join $doc_root $fname]]} {
        dict set reply mixin httpd::content::file
        dict set reply local_file [file join $doc_root $fname]
        return $reply
      }
    }
    puts "NOTFOUND"
    return {}
  }
  

  method TemplateSearch page {
    set doc_root [my cget doc_root]
    if {$doc_root ne {} && [file exists [file join $doc_root $page.tml]]} {
      return [::fileutil::cat [file join $doc_root $page.tml]]
    }
    if {$doc_root ne {} && [file exists [file join $doc_root $page.html]]} {
      return [::fileutil::cat [file join $doc_root $page.html]]
    }
    return [next $page]
  }
}

package provide httpd::dispatch 4.0
