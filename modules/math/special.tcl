# special.tcl --
#    Provide well-known special mathematical functions
#
package require math
package require math::constants
package require math::statistics

# namespace special
#    Create a convenient namespace for the "special" mathematical functions
#
namespace eval ::math::special {
   #
   # Define a number of common mathematical constants
   #
   ::math::constants::constants pi

   #
   # Functions defined in other math submodules
   #
   namespace import ::math::Beta

   #
   # Export the various functions
   #
   namespace export Beta
   namespace export Gamma
}

# Gamma --
#    The Gamma function - synonym for "factorial"
#
proc ::math::special::Gamma {x} {
   ::math::factorial $x
}

# erf --
#    The error function
# Arguments:
#    x          The value for which the function must be evaluated
# Result:
#    erf(x)
#
proc ::math::special::erf {x} {
   set x2 $x
   if { $x > 0.0 } {
      set x2 [expr {-$x}]
   }
   if { $x2 != 0.0 } {
      set r [::math::statistics::cdf-normal 0.0 [expr {sqrt(0.5)}] $x2]
      if { $x > 0.0 } {
         return [expr {1.0-2.0*$r}]
      } else {
         return [expr {2.0*$r-1.0}]
      }
   } else {
      return 0.0
   }
}

# erfc --
#    The complement of the error function
# Arguments:
#    x          The value for which the function must be evaluated
# Result:
#    erfc(x) = 1.0-erf(x)
#
proc ::math::special::erfc {x} {
   set x2 $x
   if { $x > 0.0 } {
      set x2 [expr {-$x}]
   }
   if { $x2 != 0.0 } {
      set r [::math::statistics::cdf-normal 0.0 [expr {sqrt(0.5)}] $x2]
      if { $x > 0.0 } {
         return [expr {2.0*$r}]
      } else {
         return [expr {2.0-2.0*$r}]
      }
   } else {
      return 1.0
   }
}

# Bessel functions --
#
source [file join [file dirname [info script]] "bessel.tcl"]


