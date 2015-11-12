###
# Standard library of HTTP/SCGI content
# Each of these classes are intended to be mixed into
# either an HTTPD or SCGI reply
###
package require Markdown
package require fileutil::magic::mimetype
package require tool
package require fileutil
namespace eval httpd::content {}

###
# Class to deliver Static content
# When utilized, this class is fed a local filename
# by the dispatcher
###
tool::class create httpd::content::file {
  
  method local_file filename {
    if {![file exist $filename]} {
       tailcall my error 404 {Not Found}
    }
    my variable local_file
    set local_file $filename
  }
  ###
  # We don't generate content when delivering local files
  # we just go straight to output
  ###
  method content {} {
    my reset
    my variable local_file
    if {[file isdirectory $local_file]} {
      ###
      # Produce an index page
      ###
      set idxfound 0
      foreach name {
        index.html
        index.tml
        index.md
      } {
        if {[file exists [file join $local_file $name]]} {
          set idxfound 1
          set local_file [file join $local_file $name]
          break
        }
      }
      if {!$idxfound} {
        my puts "<HTML><BODY><TABLE>"
        foreach file [glob -nocomplain [file join $local_file *]] {
          my puts "<TR><TD><a href=\"[file tail $file]\">[file tail $file]</a></TD><TD>[file size $file]</TD></TR>"
        }
        my puts "</TABLE></BODY></HTML>"
        return
      }
    }
    switch [file extension $local_file] {
      .md {
        package require Markdown
        my reply_headers set Content-Type: {text/html; charset=ISO-8859-1}
        set mdtxt  [::fileutil::cat $local_file]
        my puts [::Markdown::convert $mdtxt]
      }
      .tml {
        my reply_headers set Content-Type: {text/html; charset=ISO-8859-1}
        set tmltxt  [::fileutil::cat $local_file]
        my puts [subst $tmltxt]        
      }
      default {
        ###
        # Assume we are returning a binary file
        ###
        my reply_headers set Content-Type: [::fileutil::magic::mimetype $local_file]
      }
    }
  }
}

package provide httpd::content 4.0
