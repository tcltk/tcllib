set srcdir [file dirname [file normalize [file join [pwd] [info script]]]]
set moddir [file dirname $srcdir]

set version 4.3
set tclversion 8.6
set module [file tail $moddir]
set filename $module

proc autodoc.arglist {arglist} {
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

proc autodoc.proc {resultvar commentblock name arglist body} {
  upvar 1 $resultvar result
  set info [autodoc.comment $commentblock]
  if {![dict exists $info arglist]} {
    dict set info arglist [autodoc.arglist $arglist]
  }
  dict set result proc [string trim $name :] $info
}

proc autodoc.method {resultvar commentblock name args} {
  upvar 1 $resultvar result
  set info [autodoc.comment $commentblock]
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
    dict set info arglist [autodoc.arglist $arglist]
  }
  dict set result method [string trim $name :] $info
}

proc autodoc.class {resultvar commentblock name body} {
  upvar 1 $resultvar result
  set info [autodoc.comment $commentblock]
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
        autodoc.method info $commentblock {*}[lrange $thisline 0 end-1]
        set commentblock {}
      }
      method -
      Ensemble {
        autodoc.method info $commentblock  {*}[lrange $thisline 1 end-1]
        set commentblock {}
      }
    }
    set thisline {}
  }
  dict set result class $name $info
}


proc autodoc.comment block {
  return [dict create comment $block]
}

proc autodoc.root {resultvar} {
  upvar 1 $resultvar result
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
      proc {
        autodoc.proc result $commentblock {*}[lrange $thisline 1 end]
        set commentblock {}
      }
      oo::define {
        if {[llength $thisline]==3} {
          lassign $thisline tcmd name body
          autodoc.class $commentblock $name $body
        } else {
          puts "Warning: bare oo::define in library"
        }
      }
      clay::define -
      tool::define {
        lassign $thisline tcmd name body
        autodoc.class result $commentblock $name $body
        set commentblock {}
      }
      oo::class {
        lassign $thisline tcmd mthd name body
        autodoc.class result $commentblock $name $body
        set commentblock {}
      }
    }
    set thisline {}
  }
}

set AutoDocInfo [dict create]
coroutine AutoDoc autodoc.root AutoDocInfo


set fout [open [file join $moddir ${filename}.tcl] w]
dict set map %module% $module
dict set map %version% $version
dict set map %tclversion% $tclversion
dict set map %filename% $filename
dict set map {    } {} ;# strip indentation
dict set map "\t" {    } ;# reduce indentation (see cleanup)

puts $fout [string map $map {###
    # Amalgamated package for %module%
    # Do not edit directly, tweak the source in src/ and rerun
    # build.tcl
    ###
    package require Tcl %tclversion%
    package provide %module% %version%
    namespace eval ::%module% {}
    set ::%module%::version %version%
}]

# Track what files we have included so far
set loaded {}
lappend loaded build.tcl cgi.tcl
# These files must be loaded in a particular order
foreach file {
  core.tcl
  reply.tcl
  server.tcl
  dispatch.tcl
  file.tcl
  proxy.tcl
  cgi.tcl
  scgi.tcl
  websocket.tcl
} {
  lappend loaded $file
  set fin [open [file join $srcdir $file] r]
  puts $fout "###\n# START: [file tail $file]\n###"
  set content [read $fin]
  close $fin
  puts $file
  foreach line [split $content \n] {
    AutoDoc $line
  }
  puts $fout $content
  puts $fout "###\n# END: [file tail $file]\n###"
}
# These files can be loaded in any order
foreach file [glob [file join $srcdir *.tcl]] {
  if {[file tail $file] in $loaded} continue
  lappend loaded $file
  set fin [open [file join $srcdir $file] r]
  puts $fout "###\n# START: [file tail $file]\n###"
  set content [read $fin]
  close $fin
  puts $file
  foreach line [split $content \n] {
    AutoDoc $line
  }
  puts $fout $content
  puts $fout "###\n# END: [file tail $file]\n###"
}

# Provide some cleanup and our final package provide
puts $fout [string map $map {
    namespace eval ::%module% {
	namespace export *
    }
}]
close $fout

###
# Build our pkgIndex.tcl file
###
set fout [open [file join $moddir pkgIndex.tcl] w]
puts $fout [string map $map {
    if {![package vsatisfies [package provide Tcl] %tclversion%]} {return}
    package ifneeded %module% %version% [list source [file join $dir %module%.tcl]]
}]
close $fout

###
# Build the help file
###
set manout [open [file join $moddir $filename.man] w]
set fin    [open [file join $srcdir manual.txt] r]
puts $manout [string map $map [read $fin]]
close $fin
foreach type [dict keys $AutoDocInfo] {
  dict for {name info} [dict get $AutoDocInfo $type] {
    if {$type eq "class"} {
      puts $manout "\[section \{Class  $name\}\]"
      if {[dict exists $info method]} {
        puts $manout {[list_begin definitions]}
        dict for {method minfo} [dict get $info method] {
          puts $manout {}
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
          puts $manout $line
          if {[dict exists $minfo comment]} {
            puts $manout [dict get $minfo comment]
          }
        }
        puts $manout {[list_end]}
      }
    } else {
      puts $manout "\[section [list $type $name]\]"
    }
    if {[dict exists $info comment]} {
      puts $manout [dict get $info comment]
    }
  }
}
set fin    [open [file join $srcdir footer.txt] r]
puts $manout [string map $map [read $fin]]
close $fin
close $manout
