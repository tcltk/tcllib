###
# Tool for build scripts to dynamically generate manual files from comments
# in source code files
###
package provide doctools::build 0.1

namespace eval ::docbuild {}


oo::class create ::docbuild::object {
  constructor {} {
    my variable coro
    set coro [info object namespace [self]]::coro
    oo::objdefine [self] forward coro $coro
    coroutine $coro {*}[namespace code {my reset}]
  }

  method arglist {arglist} {
    set result [dict create]
    foreach arg $arglist {
      set name [lindex $arg 0]
      dict set result $name positional 1
      dict set result $name mandatory  1
      if {$name in {args dictargs}} {
        switch [llength $arg] {
          1 {
            dict set result $name mandatory 0
          }
          2 {
            dict for {optname optinfo} [lindex $arg 1] {
              set optname [string trim $optname -:]
              dict set result $optname {positional 1 mandatory 0}
              dict for {f v} $optinfo {
                dict set result $optname [string trim $f -:] $v
              }
            }
          }
          default {
            error "Bad argument"
          }
        }
      } else {
        switch [llength $arg] {
          1 {
            dict set result $name mandatory 1
          }
          2 {
            dict set result $name mandatory 0
            dict set result $name default   [lindex $arg 1]
          }
          default {
            error "Bad argument"
          }
        }
      }
    }
    return $result
  }

  method comment block {
    return [dict create comment $block]
  }

  method keyword.class {resultvar commentblock name body} {
    upvar 1 $resultvar result
    set info [my comment $commentblock]
    set commentblock {}
    foreach line [split $body \n] {
      append thisline $line \n
      if {![info complete $thisline]} continue
      set thisline [string trim $thisline]
      if {[string index $thisline 0] eq "#"} {
        append commentblock [string trimleft $thisline #] \n
        set thisline {}
        continue
      }
      set cmd [string trim [lindex $thisline 0] ":"]
      switch $cmd {
        superclass {
          dict set info ancestors [lrange $thisline 1 end]
          set commentblock {}
        }
        destructor -
        constructor {
          my keyword.method info $commentblock {*}[lrange $thisline 0 end-1]
          set commentblock {}
        }
        method -
        Ensemble {
          my keyword.method info $commentblock  {*}[lrange $thisline 1 end-1]
          set commentblock {}
        }
      }
      set thisline {}
    }
    dict set result class $name $info
  }

  method keyword.method {resultvar commentblock name args} {
    upvar 1 $resultvar result
    set info [my comment $commentblock]
    switch [llength $args] {
      1 {
        set arglist [lindex $args 0]
      }
      0 {
        set arglist dictargs
        #set body [lindex $args 0]
      }
      default {error "could not interpret method $name {*}$args"}
    }
    if {![dict exists $info arglist]} {
      dict set info arglist [my arglist $arglist]
    }
    dict set result method [string trim $name :] $info
  }

  method keyword.proc {commentblock name arglist body} {
    set info [my comment $commentblock]
    if {![dict exists $info arglist]} {
      dict set info arglist [my arglist $arglist]
    }
    return $info
  }

  method reset {} {
    my variable info
    set info [dict create]
    yield [info coroutine]
    set thisline {}
    set commentblock {}
    set linec 0
    while 1 {
      set line [yield]
      append thisline $line \n
      if {![info complete $thisline]} continue
      set thisline [string trim $thisline]
      if {[string index $thisline 0] eq "#"} {
        append commentblock [string trimleft $thisline #] \n
        set thisline {}
        continue
      }
      set cmd [string trim [lindex $thisline 0] ":"]
      switch $cmd {
        if {
          # Handle an if statement
          foreach {expr body} [lrange $thisline 1 end] {


          }
        }
        proc {
          set procinfo [my keyword.proc $commentblock {*}[lrange $thisline 1 end]]
          dict set info proc [string trim [lindex $thisline 1] :] $procinfo
          set commentblock {}
        }
        oo::define {
          if {[llength $thisline]==3} {
            lassign $thisline tcmd name body
            my keyword.class info $commentblock $name $body
          } else {
            puts "Warning: bare oo::define in library"
          }
        }
        tao::define -
        clay::define -
        tool::define {
          lassign $thisline tcmd name body
          my keyword.class info $commentblock $name $body
          set commentblock {}
        }
        oo::class {
          lassign $thisline tcmd mthd name body
          my keyword.class info $commentblock $name $body
          set commentblock {}
        }
      }
      set thisline {}
    }
  }

  method section.command {procinfo} {
    set result {}
    putb result "\[section \{Commands\}\]"
    putb result {[list_begin definitions]}
    dict for {method minfo} $procinfo {
      putb result {}
      set line "\[call proc \[cmd $method\]"
      if {[dict exists $minfo arglist]} {
        dict for {argname arginfo} [dict get $minfo arglist] {
          set positional 1
          set mandatory  1
          dict with arginfo {}
          if {$mandatory==0} {
            append line " ?"
          } else {
            append line " "
          }
          if {$positional} {
            append line "\[arg $argname"
          } else {
            append line "\[opt $argname"
            if {[dict exists $arginfo type]} {
              append line " \[cmd [dict get $arginfo type]\]"
            } else {
              append line " \[cmd $argname\]"
            }
          }
          append line "\]"
          if {$mandatory==0} {
            if {[dict exists $arginfo default]} {
              append line " \[emph \"[dict get $arginfo default]\"\]"
            }
            append line "?"
          }
        }
      }
      append line \]
      putb result $line
      if {[dict exists $minfo comment]} {
        putb result [dict get $minfo comment]
      }
    }
    putb result {[list_end]}
    return $result
  }

  method section.class {class_name class_info} {
    set result {}
    putb result "\[section \{Class  $class_name\}\]"
    if {[dict exists $class_info method]} {
      putb result {[list_begin definitions]}
      dict for {method minfo} [dict get $class_info method] {
        putb result {}
        set line "\[call method \[cmd $method\]"
        if {[dict exists $minfo arglist]} {
          dict for {argname arginfo} [dict get $minfo arglist] {
            set positional 1
            set mandatory  1
            dict with arginfo {}
            if {$mandatory==0} {
              append line " ?"
            } else {
              append line " "
            }
            if {$positional} {
              append line "\[arg $argname"
            } else {
              append line "\[opt $argname"
              if {[dict exists $arginfo type]} {
                append line " \[cmd [dict get $arginfo type]\]"
              } else {
                append line " \[cmd $argname\]"
              }
            }
            append line "\]"
            if {$mandatory==0} {
              if {[dict exists $arginfo default]} {
                append line " \[emph \"[dict get $arginfo default]\"\]"
              }
              append line "?"
            }
          }
        }
        append line \]
        putb result $line
        if {[dict exists $minfo comment]} {
          putb result [dict get $minfo comment]
        }
      }
      putb result {[list_end]}
    }
    if {[dict exists $class_info comment]} {
      putb result [dict get $class_info comment]
    }
    return $result
  }

  method manpage args {
    my variable info map
    set result {}
    set header {}
    set footer {}
    dict with args {}
    putb result $header
    dict for {sec_type sec_info} $info {
      switch $sec_type {
        proc {
          putb result [my section.command $sec_info]
        }
        class {
          dict for {class_name class_info} $sec_info {
            putb result [my section.class $class_name $class_info]
          }
        }
        default {
          putb result "\[section [list $sec_type $sec_name]\]"
          if {[dict exists $sec_info comment]} {
            putb result [dict get $sec_info comment]
          }
        }
      }
    }
    putb result $footer
    putb result {[manpage_end]}
    return $result
  }

  method scan_text {text} {
    my variable linecount coro
    set linecount 0
    foreach line [split $text \n] {
      incr linecount
      $coro $line
    }
  }

  method scan_file {filename} {
    my variable linecount coro
    set fin [open $filename r]
    set linecount 0
    while {[gets $fin line]>=0} {
      incr linecount
      $coro $line
    }
    close $fin
  }
}

proc ::docbuild::cat filename {
  set fin [open $filename r]
  set data [read $fin]
  close $fin
  return $data
}


proc ::putb {buffername args} {
  upvar 1 $buffername buffer
  switch [llength $args] {
    1 {
      append buffer [lindex $args 0] \n
    }
    2 {
      append buffer [string map {*}$args] \n
    }
    default {
      error "usage: putb buffername ?map? string"
    }
  }
}
