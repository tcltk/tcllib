set srcdir [file dirname [file normalize [file join [pwd] [info script]]]]
set moddir [file dirname $srcdir]

if {[catch {package require clay 0.3}]} {
  source [file join $moddir .. clay build doctool.tcl]
}
::clay::doctool create AutoDoc
set version 4.3
set tclversion 8.6
set module [file tail $moddir]
set filename $module

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
  puts $fout "###\n# START: [file tail $file]\n###"
  set content [::clay::cat [file join $srcdir $file]]
  AutoDoc scan_text $content
  puts $fout $content
  puts $fout "###\n# END: [file tail $file]\n###"
}
# These files can be loaded in any order
foreach file [glob [file join $srcdir *.tcl]] {
  if {[file tail $file] in $loaded} continue
  lappend loaded $file
  set fin [open [file join $srcdir $file] r]
  puts $fout "###\n# START: [file tail $file]\n###"
  set content [::clay::cat [file join $srcdir $file]]
  AutoDoc scan_text $content
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

set manout [open [file join $moddir $filename.man] w]
puts $manout [AutoDoc manpage \
  header [string map $map [::clay::cat [file join $srcdir manual.txt]]] \
  footer [string map $map [::clay::cat [file join $srcdir footer.txt]]] \
]
close $manout
