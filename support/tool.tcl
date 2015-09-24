###
# Build basic description of this tool
###

###
# List of mirrors
###
#tool mirror http://core.tcl.tk/tcllib 
#tool mirror http://fossil.etoyoc.com/fossil/tcllib
###
# Populate the branches
###
my meta set installer: sak
my release add trunk {
  distribution: official
  checkout: trunk
}
foreach release {
  1.17 1.16 1.15 1.14 1.13 1.12 1.11.1 1.11 1.10
  1.9 1.8 1.7 1.6.1 1.4 1.3 1.2.0 1.2 1.1 1.0
  0.8 0.6.1 0.6 0.5 0.4
} {
  set checkout tcllib-[join [split $release .] -]
  my release add $checkout [list version: $release checkout: $checkout distribution: official]
}

foreach file [glob [file join $::TOOL_ROOT apps *]] {
  if {[file extension $file] ne {}} continue
  my application scan $file
}

###
# Build the module section
###
foreach path [glob [file join $::TOOL_ROOT modules *]] {
  my module scan [file tail $path] $path
}
