###
# Simple webserver example
###

set DIR [file dirname [file normalize [info script]]]

set auto_path [linsert $auto_path 0 [file normalize [file join $DIR .. .. modules]]]
puts $auto_path
package require httpd

oo::class create mycontent {
  superclass ::httpd::reply

  method content {} {
    my puts "<HTML>"
    my puts "<BODY>"
    my puts "<H1>HELLO WORLD!</H1>"
    my puts "The time is now [my timestamp]"
    my puts "</BODY>"
    my puts "</HTML>"
  }
}

oo::class create myfile {
  superclass ::httpd::reply
  
  method notfound {} {
    my reset
    set code 404
    set errorstring [my meta getnull error_codes $code]
    my meta set reply_status "$code $errorstring"
    my puts "
<HTML>
<HEAD>
<TITLE>$code $errorstring</TITLE>
</HEAD>
<BODY>"
      my puts "
Got the error <b>$code $errorstring</b>
<p>
while trying to obtain $data(url)
      "
    my puts "</BODY>
</HTML>"
  }
  
  method content {} {
    set docroot [my <server> meta get doc_root]
    set path [my meta get query_header REQUEST_PATH]
    set path [string trimleft $path /]
    set filename [file join $docroot $path]
    if {![file exists $filename]} {
      my notfound
      return
    }
    switch [file extension $filename] {
      .html -
      .htm {
        my meta set reply_headers  Content-Type: {text/html; charset=ISO-8859-1}
        my puts [cat $filename]
      }
      .txt {
        my meta set reply_headers  Content-Type: {text/plain}
        my puts [cat $filename]
      }
      .md {
        my meta set reply_headers  Content-Type: {text/html; charset=ISO-8859-1}
        package require Markdown
        set dat [cat $filename]
        my puts [::Markdown::convert $dat]
      }
      default {
        my notfound
        return
      }
    }
  }
}

oo::class create myserver {
  superclass httpd::server
  
  method dispatch pageobj {
    set path [$pageobj meta getnull query_header REQUEST_PATH]
    set path [string trimleft $path /]
    if {$path in {{} index index.html index.htm}} {
      $pageobj meta set query_header REQUEST_PATH index.html
    }
    if {[lindex [split $path /] 0] eq "dynamic"} {
      $pageobj morph mycontent
    } else {
      $pageobj morph myfile
    }
    return 200
  }
}

myserver create MAIN doc_root [file join $DIR htdocs] port 10001
vwait forever