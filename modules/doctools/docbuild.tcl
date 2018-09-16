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
    set count 0
    set field description
    set result [dict create description {}]
    foreach line [split $block \n] {
      set line [string trim $line]
      set fwidx [string first " " $line]
      set firstword [string range $line 0 [expr {$fwidx-1}]]
      if {[string index $firstword end] eq ":"} {
        set field [string trim $firstword -]
        switch $field {
          desc {
            set field description
          }
        }
        set line [string range $line [expr {$fwidx+1}] end]
      }
      dict append result $field "$line\n"
    }
    return $result
  }

  ###
  # Process an oo::objdefine call that modifies the class object
  # itself
  ####
  method keyword.Class {resultvar commentblock name body} {
    upvar 1 $resultvar result
    set name [string trim $name :]
    if {[dict exists $result class $name]} {
      set info [dict get $result class $name]
    } else {
      set info [my comment $commentblock]
    }
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
        method -
        Ensemble {
          my keyword.class_method info $commentblock  {*}[lrange $thisline 1 end-1]
          set commentblock {}
        }
      }
      set thisline {}
    }
    dict set result class $name $info
  }

  method keyword.class {resultvar commentblock name body} {
    upvar 1 $resultvar result
    set name [string trim $name :]
    if {[dict exists $result class $name]} {
      set info [dict get $result class $name]
    } else {
      set info [my comment $commentblock]
    }
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
        class_method {
          my keyword.class_method info $commentblock  {*}[lrange $thisline 1 end-1]
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

  method keyword.class_method {resultvar commentblock name args} {
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
    dict set result class_method [string trim $name :] $info
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
        Proc -
        proc {
          set procinfo [my keyword.proc $commentblock {*}[lrange $thisline 1 end]]
          dict set info proc [string trim [lindex $thisline 1] :] $procinfo
          set commentblock {}
        }
        oo::objdefine {
          if {[llength $thisline]==3} {
            lassign $thisline tcmd name body
            my keyword.Class info $commentblock $name $body
          } else {
            puts "Warning: bare oo::define in library"
          }
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
        default {
          if {[lindex [split $cmd ::] end] eq "define"} {
            lassign $thisline tcmd name body
            my keyword.class info $commentblock $name $body
            set commentblock {}
          }
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
            append line " \[opt \""
          } else {
            append line " "
          }
          if {$positional} {
            append line "\[arg $argname"
          } else {
            append line "\[option $argname"
            if {[dict exists $arginfo type]} {
              append line " \[cmd [dict get $arginfo type]\]"
            } else {
              append line " \[cmd $argname\]"
            }
          }
          append line "\]"
          if {$mandatory==0} {
            if {[dict exists $arginfo default]} {
              append line " \[const \"[dict get $arginfo default]\"\]"
            }
            append line "\"\]"
          }
        }
      }
      append line \]
      putb result $line
      if {[dict exists $minfo description]} {
        putb result [dict get $minfo description]
      }
    }
    putb result {[list_end]}
    return $result
  }

  method section.class {class_name class_info} {
    set result {}
    putb result "\[subsection \{Class  $class_name\}\]"
    if {[dict exists $class_info ancestors]} {
      set line "\[emph \"ancestors\"\]:"
      foreach {c} [dict get $class_info ancestors] {
        append line " \[class [string trim $c :]\]"
      }
      putb result $line
      putb result {[para]}
    }
    dict for {f v} $class_info {
      if {$f in {class_method method description ancestors}} continue
      putb result "\[emph \"$f\"\]: $v"
      putb result {[para]}
    }
    if {[dict exists $class_info description]} {
      putb result [dict get $class_info description]
      putb result {[para]}
    }
    if {[dict exists $class_info class_method]} {
      putb result "\[class \{Class Methods\}\]"
      #putb result "Methods on the class object itself."
      putb result {[list_begin definitions]}
      dict for {method minfo} [dict get $class_info class_method] {
        putb result {}
        set line "\[call method \[cmd $method\]"
        if {[dict exists $minfo arglist]} {
          dict for {argname arginfo} [dict get $minfo arglist] {
            set positional 1
            set mandatory  1
            dict with arginfo {}
            if {$mandatory==0} {
              append line " \[opt \""
            } else {
              append line " "
            }
            if {$positional} {
              append line "\[arg $argname"
            } else {
              append line "\[option $argname"
              if {[dict exists $arginfo type]} {
                append line " \[method [dict get $arginfo type]\]"
              } else {
                append line " \[method $argname\]"
              }
            }
            append line "\]"
            if {$mandatory==0} {
              if {[dict exists $arginfo default]} {
                append line " \[const \"[dict get $arginfo default]\"\]"
              }
              append line "\"\]"
            }
          }
        }
        append line \]
        putb result $line
        if {[dict exists $minfo description]} {
          putb result [dict get $minfo description]
        }
      }
      putb result {[list_end]}
      putb result {[para]}
    }
    if {[dict exists $class_info method]} {
      putb result "\[class {Methods}\]"
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
              append line " \[opt \""
            } else {
              append line " "
            }
            if {$positional} {
              append line "\[arg $argname"
            } else {
              append line "\[opt $argname"
              if {[dict exists $arginfo type]} {
                append line " \[method [dict get $arginfo type]\]"
              } else {
                append line " \[method $argname\]"
              }
            }
            append line "\]"
            if {$mandatory==0} {
              if {[dict exists $arginfo default]} {
                append line " \[const \"[dict get $arginfo default]\"\]"
              }
              append line "\"\]"
            }
          }
        }
        append line \]
        putb result $line
        if {[dict exists $minfo description]} {
          putb result [dict get $minfo description]
        }
      }
      putb result {[list_end]}
      putb result {[para]}
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
          putb result "\[section Classes\]"
          dict for {class_name class_info} $sec_info {
            putb result [my section.class $class_name $class_info]
          }
        }
        default {
          putb result "\[section [list $sec_type $sec_name]\]"
          if {[dict exists $sec_info description]} {
            putb result [dict get $sec_info description]
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
