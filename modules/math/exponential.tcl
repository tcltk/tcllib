# exponential.tcl --
#    Compute exponential integrals (E1, En, Ei, li, Shi, Chi, Si, Ci)
#

namespace eval ::math::special {
   variable pi 3.1415926
   variable gamma 0.57721566490153286
   variable halfpi [expr {$pi/2.0}]
}

# ComputeExponFG --
#    Compute the auxiliary functions f and g
#
# Arguments:
#    x            Parameter of the integral (x>=0)
# Result:
#    Approximate values for f and g
# Note:
#    See Abramowitz and Stegun
#
proc ::math::special::ComputeExponFG {x} {
   set x2 [expr {$x*$x}]
   set fx [expr {($x2*$x2+7.241163*$x2+2.463936)/
                 ($x2*$x2+9.068580*$x2+7.157433)/$x}]
   set gx [expr {($x2*$x2+7.547478*$x2+1.564072)/
                 ($x2*$x2+12.723684*$x2+15.723606)/$x2}]
   list $fx $gx
}


# exponential_E1 --
#    Compute the exponential integral
#
# Arguments:
#    x            Parameter of the integral (x>0)
# Result:
#    Value of E1(x) = integral from x to infinity of exp(-x)/x
# Note:
#    This relies on a rational approximation (error ~ 2e-7 (x<1) or 5e-5 (x>1)
#
proc ::math::special::exponential_E1 {x} {
   if { $x <= 0.0 } {
      error "Domain error: x must be positive"
   }

   if { $x < 1.0 } {
      return [expr {-log($x)+((((0.00107857*$x-0.00976004)*$x+0.05519968)*$x-0.24991055)*$x+0.99999193)*$x-0.57721566}]
   } else {
      set xexpe [expr {($x*$x+2.334733*$x+0.250621)/($x*$x+3.330657*$x+1.681534)}]
      return [expr {$xexpe/($x*exp($x))}]
   }
}

# exponential_E_n --
#    Compute the exponential integral of n-th order
#
# Arguments:
#    n            Order of the integral (n>=1, integer)
#    x            Parameter of the integral (x>0)
# Result:
#    Value of E1(x) = integral from 0 to x of exp(-x)/x
# Note:
#    This relies on a rational approximation (error ~ 2e-7 (x<1) or 5e-5 (x>1)
#
proc ::math::special::exponential_E_n {n x} {
   if { $x <= 0.0 } {
      error "Domain error: x must be positive"
   }
   if { $n <= 0 || ! [string is integer $n]} {
      error "Domain error: n must be positive integer"
   }

   if { $n == 1 } {
      return [exponential_E1 $x]
   } else {
      set En [exponential_E1 $x]
      for { set i 1 } { $i < $n } { incr i } {
         set Enp1 [expr {(exp(-$x)-$x*$En)/double($i)}]
         set En   $Enp1
      }
      return $Enp1
   }
}

# exponential_li --
#    Compute the logarithmic integral
# Arguments:
#    x       Value of the argument
# Result:
#    Value of the integral 1/ln(x) from 0 to x
#
proc ::math::special::exponential_li {x} {
    if { $x < 0 } {
        return -code error "Argument must be positive or zero"
    } else {
        if { $x == 0.0 } {
            return 0.0
        } else {
            return [exponential_Ei [expr {log($x)}]]
        }
    }
}

# exponential_Shi --
#    Compute the hyperbolic sine integral
# Arguments:
#    x       Value of the argument
# Result:
#    Value of the integral sinh(x)/x from 0 to x
#
proc ::math::special::exponential_Shi {x} {
    if { $x < 0 } {
        return -code error "Argument must be positive or zero"
    } else {
        if { $x == 0.0 } {
            return 0.0
        } else {
            proc g {x} {
               return [expr {sinh($x)/$x}]
            }
            return [lindex [::math::calculus::romberg g 0.0 $x] 0]
        }
    }
}

# exponential_Chi --
#    Compute the hyperbolic cosine integral
# Arguments:
#    x       Value of the argument
# Result:
#    Value of the integral (cosh(x)-1)/x from 0 to x
#
proc ::math::special::exponential_Chi {x} {
    variable gamma
    if { $x < 0 } {
        return -code error "Argument must be positive or zero"
    } else {
        if { $x == 0.0 } {
            return 0.0
        } else {
            proc g {x} {
               return [expr {(cosh($x)-1.0)/$x}]
            }
            set integral [lindex [::math::calculus::romberg g 0.0 $x] 0]
            return [expr {$gamma+log($x)+$integral}]
        }
    }
}

# exponential_Si --
#    Compute the sine integral
# Arguments:
#    x       Value of the argument
# Result:
#    Value of the integral sin(x)/x from 0 to x
#
proc ::math::special::exponential_Si {x} {
    variable halfpi
    if { $x < 0 } {
        return -code error "Argument must be positive or zero"
    } else {
        if { $x == 0.0 } {
            return 0.0
        } else {
            if { $x < 1.0 } {
                proc g {x} {
                    return [expr {sin($x)/$x}]
                }
                return [lindex [::math::calculus::romberg g 0.0 $x] 0]
            } else {
                foreach {f g} [ComputeExponFG $x] {break}
                return [expr {$halfpi-$f*cos($x)-$g*sin($x)}]
            }
        }
    }
}

# exponential_Ci --
#    Compute the cosine integral
# Arguments:
#    x       Value of the argument
# Result:
#    Value of the integral (cosh(x)-1)/x from 0 to x
#
proc ::math::special::exponential_Ci {x} {
    variable gamma

    if { $x < 0 } {
        return -code error "Argument must be positive or zero"
    } else {
        if { $x == 0.0 } {
            return 0.0
        } else {
            if { $x < 1.0 } {
                proc g {x} {
                    return [expr {(cos($x)-1.0)/$x}]
                }
                set integral [lindex [::math::calculus::romberg g 0.0 $x] 0]
                return [expr {$gamma+log($x)+$integral}]
            } else {
                foreach {f g} [ComputeExponFG $x] {break}
                return [expr {$f*sin($x)-$g*cos($x)}]
            }
        }
    }
}

# eiseries1, eineville --
#    Auxilary functions for Ei
# Arguments:
#    eps     Required accuracy
#    x       Value of the argument
# Result:
#    Value of Ei
#

proc ::math::special::_eiseries1 { x } { # Abramowitz & Stegun, 3.1.10
     variable gamma
     set sum 0.
     set fact 1.
     set pow $x
     for { set n 1 } { $n < 100 } { incr n } {
        set fact [expr { $fact * $n }]
        set term [expr { $pow / $n / $fact }]
        set sum [expr { $sum + $term }]
        if { $term < 1e-10 * $sum } break
        set pow [expr { $x * $pow }]
     }
     return [expr { $sum + $gamma + log($x) }]
}

proc ::math::special::_eineville { x } {
     # interpolate Ei(x) using tabulated values for $x >= 100/3,
     # roughly 9 significant digits available in result.
     foreach {y err} [::math::interpolate::neville {
        0.03 0.025 0.02 0.015 0.01 0.005 0.0
     } {
        1.031985028 1.026354511 1.020852278 1.015471565 1.010206253
        1.005050765 1.
     } [expr { 1.0 / $x }]] break
     return [expr { $y * exp($x) / $x }]
}

if { 0 } {
     # Original proposal by K. Kenny
proc ::math::special::_eiseries2 { eps x } {
         # http://www.library.cornell.edu/nr/bookcpdf/c6-3.pdf
     set sum 0.
     set term 1.
     for { set k 1 } { $k < 100 } { incr k } {
        set p $term
        set term [expr { $term * ( $k / $x ) }]
        if { $term < $eps } {
            break
        }
        if { $term < $p } {
            set sum [expr { $sum + $term }]
        } else {
            set sum [expr { $sum - $p }]
            break
        }
     }
     return [expr { exp($x) * ( 1.0 + $sum ) / $x }]
}
}

# exponential_Ei --
#    Compute the exponential integral of the second kind
# Arguments:
#    x       Value of the argument
# Result:
#    Principal value of the integral exp(x)/x
#    from -infinity to x
#
proc ::math::special::exponential_Ei {x} {
     variable gamma

     set eps 1e-10
     if { $x >= 100.0/3.0 } {
        return [_eineville $eps $x]
     } elseif { $x >= 1e-38 } {
        return [_eiseries1 $x]
     } else {
        return [expr { log($x) + 0.57721566490153286 }]
     }
}


# some tests --
#
# Fake struct package
package provide struct 1.0
source interpolate.tcl
source calculus.tcl

set tcl_precision 17
puts "x: E1, E2"
foreach x {0.001 0.1 0.2 0.4 0.6 0.8 0.9 1.0 2.0 2.5 3.0 5.0 10.5} {
   puts "$x: [::math::special::exponential_E1 $x] \
[::math::special::exponential_E_n 2 $x]"
}

puts "x: Ei, li"
foreach x {0.001 0.1 0.2 0.4 0.6 0.8 0.9 1.0 2.0 2.5 3.0 5.0 10.5} {
   puts "$x: [::math::special::exponential_Ei $x] "
}
#[::math::special::exponential_li $x]"

puts "x: Shi, Chi"
foreach x {0.001 0.1 0.2 0.4 0.6 0.8 0.9 1.0 2.0 2.5 3.0 5.0 10.5} {
   puts "$x: [::math::special::exponential_Shi $x] \
[::math::special::exponential_Chi $x]"
}
puts "x: Si, Ci"
foreach x {0.001 0.1 0.2 0.4 0.6 0.8 0.9 1.0 2.0 2.5 3.0 5.0 10.5} {
   puts "$x: [::math::special::exponential_Si $x] \
[::math::special::exponential_Ci $x]"
}


