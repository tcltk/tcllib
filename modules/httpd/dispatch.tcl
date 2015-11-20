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

  method add_root {pattern class} {
    my variable url_patterns
    dict set url_patterns $pattern $class
  }
  
  method dispatch {pageobj} {
    my variable page
    set dat [$pageobj query_headers dump]
    set uri [dict get $dat REQUEST_URI]
    # Search from longest pattern to shortest
    my variable url_patterns
    foreach {pattern class} $url_patterns {
      if {[string match ${pattern} $uri]} {
        $pageobj query_header set prefix $pattern
        oo::objdefine $pageobj mixin $class
        return 200
      }
    }
    set doc_root [my cget doc_root]
    if {$uri in "{} / /home /index.html /index.md /index"} {
      ###
      # Handle HOME page
      ###
      oo::objdefine $pageobj mixin httpd::content::file
      $pageobj local_file [file join $doc_root index.md]
      return 200
    }
    ###
    # Search for a file of the same name in doc_root
    ###
    if {$doc_root ne {}} {
      if {[file exists [file join $doc_root $fname]]} {
        oo::objdefine $pageobj mixin httpd::content::file
        $pageobj local_file [file join $doc_root $fname]
        return 200
      }
    }
    # Return notfound
    ###
    # Get to the end, do a page not found and die
    ###
    $pageobj reset
    $pageobj reply_headers set Status: {404 Not Found}
    $pageobj puts [subst [my template notfound]]
    $pageobj output
  }
  
  method template page {
    my variable template
    if {[info exists template($page)]} {
      return $template($page)
    }
    set template($page) [TemplateSearch $page]
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
      notfound {
        return {
<HTML>
<HEAD><TITLE>404: Page Not Found</TITLE></HEAD>
<BODY>
The page you are looking for: <b>[$pageobj query_headers get REQUEST_URI]</b> does not exist.
</BODY>
</HTML>
        }
      }
    }
  }
}

package provide httpd::dispatch 4.0
