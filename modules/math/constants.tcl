# constants.tcl --
#    Module defining common mathematical and numerical constants
#

# namespace constants
#    Create a convenient namespace for the constants
#
namespace eval ::math::constants {
   #
   # List of constants and their description
   #
   variable constants {
      pi        3.14159265358979323846   "ratio of circle circumference and diameter"
      e         2.71828182845904523536   "base for natural logarithm"
      ln10      2.30258509299404568402   "natural logarithm of 10"
      phi       1.61803398874989484820   "golden ratio"
      gamma     0.57721566490153286061   "Euler's constant"
      sqrt2     1.41421356237309504880   "Square root of 2"
      thirdrt2  1.25992104989487316477   "One-third power of 2"
      sqrt3     1.73205080756887729533   "Square root of 3"
      radtodeg  57.2957795131            "Conversion from radians to degrees"
      degtorad  0.017453292519943        "Conversion from degrees to radians"
      onethird  1.0/3.0                  "One third (0.3333....)"
      twothirds 2.0/3.0                  "Two thirds (0.3333....)"
      onesixth  1.0/6.0                  "One sixth (0.1666....)"
   }

   #
   # Create the variables from this list:
   # - By using expr we ensure that the best double precision
   #   approximation is assigned to the variable, rather than
   #   just the string
   # - It also allows us to rely on IEEE arithmetic if available,
   #   so that for instance 3.0*(1.0/3.0) is exactly 1.0
   #
   foreach {const value descr} $constants {
      # FRINK: nocheck
      set $const [expr 0.0+$value]
   }

   namespace export constants print-constants
}

# constants --
#    Expose the constants in the caller's routine or namespace
#
# Arguments:
#    args         List of constants to be exposed
# Result:
#    None
#
proc ::math::constants::constants {args} {

   foreach const $args {
      uplevel 1 [list variable $const [set ::math::constants::$const]]
   }
}

# print-constants --
#    Print the selected or all constants to the screen
#
# Arguments:
#    args         List of constants to be exposed
# Result:
#    None
#
proc ::math::constants::print-constants {args} {
   variable constants

   if { [llength $args] != 0 } {
      foreach const $args {
         set idx [lsearch $constants $const]
         if { $idx >= 0 } {
            set descr [lindex $constants [expr {$idx+2}]]
            puts "$const = [set ::math::constants::$const] = $descr"
         } else {
            puts "*** $const unknown ***"
         }
      }
   } else {
      foreach {const value descr} $constants {
         puts "$const = [set ::math::constants::$const] = $descr"
      }
   }
}

#
# Declare our presence
#
package provide math::constants 1.0

# some tests --
#
if { 0 } {
::math::constants::constants pi e ln10 onethird
set tcl_precision 17
puts "$pi - [expr {1.0/$pi}]"
puts $e
puts $ln10
puts "onethird: [expr {3.0*$onethird}]"
::math::constants::print-constants onethird pi e
puts "All defined constants:"
::math::constants::print-constants
}
