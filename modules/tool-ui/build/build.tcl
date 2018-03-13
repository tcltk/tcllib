set srcdir [file dirname [file normalize [file join [pwd] [info script]]]]
set moddir [file dirname $srcdir]

set version 0.2.2
set tclversion 8.6
set module [file tail $moddir]

set fout [open [file join $moddir ${module}.tcl] w]
dict set map %module% $module
dict set map %version% $version
dict set map %tclversion% $tclversion
dict set map {    } {}
dict set map "\t" {    }

puts $fout [string map $map {###
    # Amalgamated package for %module%
    # Do not edit directly, tweak the source in src/ and rerun
    # build.tcl
    ###
    package require Tcl %tclversion%
    package provide %module% %version%
    namespace eval ::%module% {}
}]
if {$module ne "tool"} {
  puts $fout [string map $map {::tool::module push %module%}]
}

# Track what files we have included so far
set loaded {}
lappend loaded build.tcl
# These files must be loaded in a particular order
foreach file {
  baseclass.tcl procs.tcl stylesheet.tcl string.tcl
} {
  lappend loaded $file
  set fin [open [file join $srcdir $file] r]
  puts $fout "###\n# START: [file tail $file]\n###"
  puts $fout [read $fin]
  close $fin
  puts $fout "###\n# END: [file tail $file]\n###"
}
# These files can be loaded in any order
foreach file [glob [file join $srcdir *.tcl]] {
  if {[file tail $file] in $loaded} continue
  lappend loaded $file
  set fin [open [file join $srcdir $file] r]
  puts $fout "###\n# START: [file tail $file]\n###"
  puts $fout [read $fin]
  close $fin
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
puts $fout [string map $map {###
    if {![package vsatisfies [package provide Tcl] %tclversion%]} {return}
    package ifneeded %module% %version% [list source [file join $dir %module%.tcl]]
}]
close $fout
