# bessel.tcl --
#    Evaluate the most common Bessel functions via quadrature formulas
#

# namespace special
#    Create a convenient namespace for the "special" mathematical functions
#
namespace eval ::math::special {
   #
   # Define a number of common mathematical constants
   #
   variable pi 3.1415926
}

# J0 --
#    Zeroth-order Bessel function
#
# Arguments:
#    x         Value of the x-coordinate
# Result:
#    Value of J0(x)
#
proc ::math::special::J0 {x} {
   variable pi
   #
   # Determine the number of components (very crude heuristic)
   # (We use a quadrature formula here and use the symmetry of
   # the cos function to reduce the number of actually computed
   # components by a gfactor 2.
   #

   set ncomps [expr {2*int($x/2.0+0.5)}]
   if { $ncomps < 6 } {
      set ncomps 6
   }

   set result 0.0
   for { set i 1 } { $i < $ncomps } { incr i 2 } {
      set result [expr {$result + cos( $x * cos((2*$i-1)*$pi/(2.0*$ncomps)) ) }]
   }

   expr {2.0*$result/$ncomps}
}

# J1 --
#    First-order Bessel function
#
# Arguments:
#    x         Value of the x-coordinate
# Result:
#    Value of J1(x)
#
proc ::math::special::J1 {x} {
   variable pi
   #
   # Determine the number of components (very crude heuristic)
   # (We use a quadrature formula here and use the symmetry of
   # the cos function to reduce the number of actually computed
   # components by a gfactor 2.
   #

   set ncomps [expr {2*int($x/2.0+0.5)}]
   if { $ncomps < 6 } {
      set ncomps 6
   }

   set result 0.0
   for { set i 1 } { $i < $ncomps } { incr i 2 } {
      set factor [expr {cos((2*$i-1)*$pi/(2.0*$ncomps))}]
      set result [expr {$result + $factor * sin( $x * $factor) }]
   }

   expr {2.0*$result/$ncomps}
}

# J1/2 --
#    Half-order Bessel function
#
# Arguments:
#    x         Value of the x-coordinate
# Result:
#    Value of J1/2(x)
#
proc ::math::special::J1/2 {x} {
   variable pi
   #
   # This Bessel function can be expressed in terms of elementary
   # functions. Therefore use the explicit formula
   #
   if { $x != 0.0 } {
      expr {sqrt(2.0/$pi/$x)*sin($x)}
   } else {
      return 0
   }
}

#
# Announce the package
#
package provide math::special 0.1

# some tests --
#
if { 0 } {
foreach x {0.0 2.0 4.4 6.0 10.0 11.0 12.0 13.0 14.0} {
   puts "J0($x) = [::math::special::J0 $x] - J1($x) = [::math::special::J1 $x] \
- J1/2($x) = [::math::special::J1/2 $x]"
}
}
