###
# Class to deliver Static content
# When utilized, this class is fed a local filename
# by the dispatcher
###
::tool::define ::httpd::content.file {

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
    my puts [my html header "Listing of /$fname/"]
    my puts "Listing contents of /$fname/"
    my puts "<TABLE>"
    if {$prefix ni {/ {}}} {
      set updir [file dirname $prefix]
      if {$updir ne {}} {
        my puts "<TR><TD><a href=\"/$updir\">..</a></TD><TD></TD></TR>"
      }
    }
    foreach file [glob -nocomplain [file join $local_file *]] {
      if {[file isdirectory $file]} {
        my puts "<TR><TD><a href=\"[file join / $uri [file tail $file]]\">[file tail $file]/</a></TD><TD></TD></TR>"
      } else {
        my puts "<TR><TD><a href=\"[file join / $uri [file tail $file]]\">[file tail $file]</a></TD><TD>[file size $file]</TD></TR>"
      }
    }
    my puts "</TABLE>"
    my puts [my html footer]
  }

  method content {} {
    my variable reply_file
    set local_file [my FileName]
    if {$local_file eq {} || ![file exist $local_file]} {
      my <server> log httpNotFound [my http_info get REQUEST_URI]
      tailcall my error 404 {File Not Found}
    }
    if {[file isdirectory $local_file] || [file tail $local_file] in {index index.html index.tml index.md}} {
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
        my reply set Content-Type {text/html; charset=UTF-8}
        set mdtxt  [::fileutil::cat $local_file]
        my puts [::Markdown::convert $mdtxt]
      }
      .tml {
        my reply set Content-Type {text/html; charset=UTF-8}
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
    my variable reply_body reply_file reply_chan chan
    if {![info exists reply_file]} {
      ###
      # There is no reply file, return treat this as a normal dynamic file
      ###
      my wait writable $chan
      try {
        chan configure $chan  -translation {binary binary}
        ###
        # Return dynamic content
        ###
        set length [string length $reply_body]
        set result {}
        if {${length} > 0} {
          my reply set Content-Length [string length $reply_body]
          append result [my reply output] \n
          append result $reply_body
        } else {
          append result [my reply output]
        }
        my CacheResult $result
        chan puts -nonewline $chan $result
        my log HttpAccess {}
      } on error {err info} {
        my <server> debug [dict get $info -errorinfo]
        my log HttpError [list error: $err]
      } finally {
        tailcall my destroy
      }
    }
    chan event $chan writable {}
    chan configure $chan  -translation {binary binary}
    my log HttpAccess {}
    ###
    # Return a stream of data from a file
    ###
    set size [file size $reply_file]
    my reply set Content-Length $size
    append result [my reply output] \n
    chan puts -nonewline $chan $result
    set reply_chan [open $reply_file r]
    chan configure $reply_chan  -translation {binary binary}
    ###
    # Send any POST/PUT/etc content
    # Note, we are terminating the coroutine at this point
    # and using the file event to wake the object back up
    #
    # We *could*:
    # chan copy $sock $chan -command [info coroutine]
    # yield
    #
    # But in the field this pegs the CPU for long transfers and locks
    # up the process
    ###
    my log ChanEventCopy [list [self class] [self method]]
    chan copy $reply_chan $chan -command [namespace code [list my TransferComplete $reply_chan $chan]]

  }
}
