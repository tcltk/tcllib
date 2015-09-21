set SCRIPT [file normalize [info script]]
set TOOL_ROOT [file dirname [file dirname $SCRIPT]]
set cwd [file dirname $SCRIPT]
if {[catch {package require shed}]} {
  puts "ADDING TOOL TO PKG PATH"
  lappend auto_path [file join $cwd .. .. shed modules]
  package require tool
  package require shed
}

tool begin sherpa
###
# Build basic description of this tool
###
tool description: {
The reference implementation for the TOOL and SHED description languages.
}
tool distribution: fossil
tool class: tool

###
# List of mirrors
###
tool mirror http://core.tcl.tk/tcllib 
tool mirror http://fossil.etoyoc.com/fossil/tcllib

###
# Populate the branches
###
tool branch trunk {
  version: 1.18
  release: beta
}
tool branch tcllib-1-17-rc {
  version: 1.17
  release: final
}
tool branch tcllib-1-16-rc {
  version: 1.16
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
