set srcdir [file dirname [file normalize [file join [pwd] [info script]]]]
set moddir [file dirname $srcdir]
if {[catch {package require clay 0.3}]} {
  source [file join $$moddir .. clay build doctool.tcl]
}
::clay::doctool create AutoDoc

set version 0.13
set tclversion 8.6
set module [file tail $moddir]
set filename $module

set fout [open [file join $moddir $filename.tcl] w]
fconfigure $fout -translation lf
dict set map %module% $module
dict set map %version% $version
dict set map %tclversion% $tclversion
#dict set map {    } {}
#dict set map "\t" {    }

puts $fout [string map $map {###
# Amalgamated package for %module%
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package require Tcl %tclversion%
package provide %module% %version%
namespace eval ::%module% {}
}]

# Track what files we have included so far
set loaded {}
# These files must be loaded in a particular order

###
# Load other module code that this module will need
###
foreach {omod files} {
  httpwget wget.tcl
  clay {build/procs.tcl build/class.tcl build/object.tcl build/doctool.tcl}
} {
  foreach fname $files {
    set file [file join $moddir .. $omod $fname]
    puts $fout "###\n# START: [file join $omod $fname]\n###"
    set content [::clay::cat [file join $moddir .. $omod $fname]]
    #AutoDoc scan_text $content
    puts $fout $content
    puts $fout "###\n# END: [file join $omod $fname]\n###"
  }
}

foreach file {
  setup.tcl
  docbuild.tcl
  buildutil.tcl
  fileutil.tcl
  installutil.tcl
  makeutil.tcl
  {class metaclass.tcl}

  {class toolset baseclass.tcl}
  {class toolset gcc.tcl}
  {class toolset msvc.tcl}

  {class target.tcl}
  {class object.tcl}
  {class dynamic.tcl}
  {class product.tcl}
  {class module.tcl}

  {class project baseclass.tcl}
  {class project library.tcl}
  {class project tclkit.tcl}

  {class distro baseclass.tcl}
  {class distro snapshot.tcl}
  {class distro fossil.tcl}
  {class distro git.tcl}

  {class subproject baseclass.tcl}
  {class subproject binary.tcl}
  {class subproject core.tcl}

  {class tool.tcl}

} {
  lappend loaded $file
  puts $fout "###\n# START: [file join $file]\n###"
  set content [::clay::cat [file join $srcdir {*}$file]]
  AutoDoc scan_text $content
  puts $fout $content
  puts $fout "###\n# END: [file join $file]\n###"
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
fconfigure $fout -translation lf
puts $fout [string map $map {###
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
