# tfa.tcl --
#
#    Script to define tolerant floating-point comparisons
#    (Tcl-only version)
#
#    version 0.1: initial implementation, january 2002

package provide math::fuzzy 0.1

namespace eval ::math::fuzzy {
   variable eps3 2.2e-16

   namespace export teq tne tge tgt tle tlt tfloor tceil tround troundn

# determineTolerance
#    Determine the epsilon value
#
# Arguments:
#    None
#
# Result:
#    None
#
# Side effects:
#    Sets variable eps3
#
proc determineTolerance { } {
   variable eps3
   set eps 1.0
   while { [expr {1.0+$eps}] != 1.0 } {
      set eps3 [expr 3.0*$eps]
      set eps  [expr 0.5*$eps]
   }
   #set check [expr {1.0+2.0*$eps}]
   #puts "Eps3: $eps3 ($eps) ([expr {1.0-$check}] [expr 1.0-$check]"
}

# absmax --
#    Return the absolute maximum of two numbers
#
# Arguments:
#    first      First number
#    second     Second number
#
# Result:
#    Maximum of the absolute values
#
proc absmax { first second } {
   return [expr {abs($first) > abs($second)? abs($first) : abs($second)}]
}

# teq, tne, tge, tgt, tle, tlt --
#    Compare two floating-point numbers and return the logical result
#
# Arguments:
#    first      First number
#    second     Second number
#
# Result:
#    1 if the condition holds, 0 if not.
#
proc teq { first second } {
   variable eps3
   set scale [absmax $first $second]
   return [expr {abs($first-$second) <= $eps3 * $scale}]
}

proc tne { first second } {
   variable eps3

   return [expr ! [teq $first $second]]
}

proc tgt { first second } {
   variable eps3
   set scale [absmax $first $second]
   return [expr {($first-$second) > $eps3 * $scale}]
}

# tfloor --
#    Determine the "floor" of a number and return the result
#
# Arguments:
#    number     Number in question
#
# Result:
#    Largest integer number that is tolerantly smaller than the given
#    value
#
proc tfloor { number } {
   variable eps3

   set q      [expr {($number < 0.0)? (1.0-$eps3) : 1.0 }]
   set rmax   [expr {$q / (2.0 - $eps3)}]
   set eps5   [expr {$eps3/$q}]
   set vmin1  [expr {$eps5*abs(1.0+floor($number))}]
   set vmin2  [expr {($rmax < $vmin1)? $rmax : $vmin1}]
   set vmax   [expr {($eps3 > $vmin2)? $eps3 : $vmin2}]
   set result [expr {floor($number+$vmax)}]
   if { $number <= 0.0 || ($result-$number) < $rmax } {
      return $result
   } else {
      return [expr {$result-1.0}]
   }
}

# tceil --
#    Determine the "ceil" of a number and return the result
#
# Arguments:
#    number     Number in question
#
# Result:
#    Smallest integer number that is tolerantly greater than the given
#    value
#
proc tceil { number } {
   return [expr {-[tfloor -$number]}]
}

# tround --
#    Round off a number and return the result
#
# Arguments:
#    number     Number in question
#
# Result:
#    Nearest integer number to the given number
#
proc tround { number } {
   return [tround [expr {$number+0.5}]]
}

#
# Determine the tolerance once and for all
#
determineTolerance
rename determineTolerance {}

} ;# End of namespace

