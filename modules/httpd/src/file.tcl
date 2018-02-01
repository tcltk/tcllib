
###
# Class to deliver Static content
# When utilized, this class is fed a local filename
# by the dispatcher
###
::tool::define ::httpd::content::file {

  method FileName {} {
    set uri [string trimleft [my http_info get REQUEST_URI] /]
    set path [my http_info get path]
    set prefix [my http_info get prefix]
    set fname [string range $uri [string length $prefix] end]
    if {$fname in "{} index.html index.md index"} {
      return $path
    }
    if {[file exists [file join $path $fname]]} {
      return [file join $path $fname]
    }
    if {[file exists [file join $path $fname.md]]} {
      return [file join $path $fname.md]
    }
    if {[file exists [file join $path $fname.html]]} {
      return [file join $path $fname.html]
    }
    if {[file exists [file join $path $fname.tml]]} {
      return [file join $path $fname.tml]
    }
    return {}
  }


  method DirectoryListing {local_file} {
    set uri [string trimleft [my http_info get REQUEST_URI] /]
    set path [my http_info get path]
    set prefix [my http_info get prefix]
    set fname [string range $uri [string length $prefix] end]
    my puts "<HTML><HEAD><TITLE>Listing of /$fname</TITLE></HEAD><BODY>"
    my puts "Listing contents of /$fname"
    my puts "<TABLE>"
    set updir [file dirname $fname]
    if {$updir ne {}} {
      my puts "<TR><TD><a href=\"/$updir\">..</a></TD><TD></TD></TR>"
    }
    foreach file [glob -nocomplain [file join $local_file *]] {
      my puts "<TR><TD><a href=\"[file join / $fname [file tail $file]]\">[file tail $file]</a></TD><TD>[file size $file]</TD></TR>"
    }
    my puts "</TABLE></BODY></HTML>"
  }

  method dispatch {newsock datastate} {
    # No need to process the rest of the headers
    my variable chan dipatched_time
    set dispatched_time [clock seconds]
    my http_info replace $datastate
    set chan $newsock
    my content
    my output
  }

  method content {} {
    ###
    # When delivering static content, allow web caches to save
    ###
    my reply set Cache-Control {max-age=3600}
    my variable reply_file
    set local_file [my FileName]
    if {$local_file eq {} || ![file exist $local_file]} {
      my <server> log httpNotFound [my http_info get REQUEST_URI]
       tailcall my error 404 {Not Found}
    }
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
        tailcall my DirectoryListing $local_file
      }
    }
    switch [file extension $local_file] {
      .md {
        package require Markdown
        my reply set Content-Type {text/html; charset=ISO-8859-1}
        set mdtxt  [::fileutil::cat $local_file]
        my puts [::Markdown::convert $mdtxt]
      }
      .tml {
        my reply set Content-Type {text/html; charset=ISO-8859-1}
        set tmltxt  [::fileutil::cat $local_file]
        set headers [my http_info dump]
        dict with headers {}
        my puts [subst $tmltxt]
      }
      default {
        ###
        # Assume we are returning a binary file
        ###
        my reply set Content-Type [::fileutil::magic::filetype $local_file]
        set reply_file $local_file
      }
    }
  }

  ###
  # Output the result or error to the channel
  # and destroy this object
  ###
  method DoOutput {} {
    my variable chan
    chan event $chan writable {}
    my variable reply_body reply_file reply_chan chan
    chan configure $chan  -translation {binary binary}
    if {![info exists reply_file] || [string length $reply_body]} {
      ###
      # Return dynamic content
      ###
      set reply_body [string trim $reply_body]
      my reply set Content-Length [string length $reply_body]
      append result [my reply output]
      append result $reply_body
      chan puts -nonewline $chan $result
      chan flush $chan
      my destroy
    } else {
      ###
      # Return a stream of data from a file
      ###
      set size [file size $reply_file]
      my reply set Content-Length $size
      append result [my reply output]
      chan puts -nonewline $chan $result
      set reply_chan [open $reply_file r]
      chan configure $reply_chan  -translation {binary binary}
      chan copy $reply_chan $chan -command [namespace code [list my TransferComplete $reply_chan]]
    }
  }
}
