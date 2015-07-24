package require fileutil::traverse

fileutil::traverse T .
T foreach p {}


# Measuring performance
proc a {} {
   T foreach p {}
}

puts "\nPERFORMANCE\n==========="
puts [time a 1000]
