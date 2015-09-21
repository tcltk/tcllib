set SCRIPT [file normalize [info script]]
set TOOL_ROOT [file dirname [file dirname $SCRIPT]]
set cwd [file dirname $SCRIPT]
if {[catch {package require shed}]} {
  puts "ADDING TOOL TO PKG PATH"
  lappend auto_path [file join $cwd .. .. shed modules]
  package require tool
  package require shed
}

tool begin tcllib
###
# Build basic description of this tool
###
tool description: {
The Tcl Standard Library
}
tool distribution: fossil
tool class: sak

###
# List of mirrors
###
tool mirror http://core.tcl.tk/tcllib 
tool mirror http://fossil.etoyoc.com/fossil/tcllib

###
# Populate the branches
###
tool branch trunk {
  version: 1.18b
  release: beta
}
tool branch tcllib-1-17 {
  version: 1.17
  release: final
}
tool branch tcllib-1-16 {
  version: 1.16
  release: final
}
tool branch tcllib-1-15 {
  version: 1.15
  release: final
}
tool branch tcllib-1-14 {
  version: 1.14
  release: final
}
tool branch tcllib-1-13 {
  version: 1.13
  release: final
}
tool branch tcllib-1-12 {
  version: 1.12
  release: final
}
tool branch tcllib-1-11-1 {
  version: 1.11.1
  release: final
}
tool branch tcllib-1-11 {
  version: 1.11
  release: final
}
tool branch tcllib-1-10 {
  version: 1.10
  release: final
}
tool branch tcllib-1-9 {
  version: 1.9
  release: final
}
tool branch tcllib-1-8 {
  version: 1.8
  release: final
}
tool branch tcllib-1-7 {
  version: 1.7
  release: final
}
tool branch tcllib-1-6-1 {
  version: 1.6.1
  release: final
}
tool branch tcllib-1-6 {
  version: 1.6
  release: final
}
tool branch tcllib-1-4 {
  version: 1.4
  release: final
}
tool branch tcllib-1-3 {
  version: 1.3
  release: final
}
tool branch tcllib-1-2-0 {
  version: 1.2.0
  release: final
}
tool branch tcllib-1-2 {
  version: 1.2
  release: final
}
tool branch tcllib-1-1 {
  version: 1.1
  release: final
}
tool branch tcllib-1-0 {
  version: 1.0
  release: final
}
tool branch tcllib-0-8 {
  version: 0.8
  release: final
}
tool branch tcllib-0-6-1 {
  version: 0.6.1
  release: final
}
tool branch tcllib-0-6 {
  version: 0.6
  release: final
}
tool branch tcllib-0-5 {
  version: 0.5
  release: final
}
tool branch tcllib-0-4 {
  version: 0.4
  release: final
}


foreach file [glob [file join $TOOL_ROOT apps *]] {
  if {[file extension $file] ne {}} continue
  application_scan $file
}

###
# Build the module section
###
foreach path [glob [file join $TOOL_ROOT modules *]] {
  tool module_path [file tail $path] $path
}
tool write [file join [file dirname $SCRIPT] tool.shed]
