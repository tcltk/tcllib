# calculus.tcl --
#    Package that implements several basic numerical methods, such
#    as the integration of a one-dimensional function and the
#    solution of a system of first-order differential equations.
#
# Author: Arjen Markus (arjen.markus@wldelft.nl)
#

# math::calculus --
#    Namespace for the commands
#

namespace eval ::math::calculus {
    namespace export \
	    integral integralExpr integral2D integral3D \
	    eulerStep heunStep rungeKuttaStep \
	    boundaryValueSecondOrder solveTriDiagonal
}

# Integral --
#    Integrate a function over a given interval using the Simpson rule
#
# Arguments:
#    begin       Start of the interval
#    end         End of the interval
#    nosteps     Number of steps in which to divide the interval
#    func        Name of the function to be integrated (takes one
#                argument)
# Return value:
#    Computed integral
#
proc ::math::calculus::integral { begin end nosteps func } {

   set delta    [expr {($end-$begin)/double($nosteps)}]
   set hdelta   [expr {$delta/2.0}]
   set result   0.0
   set xval     $begin
   set func_end [$func $xval]
   for { set i 1 } { $i <= $nosteps } { incr i } {
      set func_begin  $func_end
      set func_middle [$func [expr {$xval+$hdelta}]]
      set func_end    [$func [expr {$xval+$delta}]]
      set result      [expr  {$result+$func_begin+4.0*$func_middle+$func_end}]

      set xval        [expr {$begin+double($i)*$delta}]
   }

   return [expr {$result*$delta/6.0}]
}

# IntegralExpr --
#    Integrate an expression with "x" as the integrate according to the
#    Simpson rule
#
# Arguments:
#    begin       Start of the interval
#    end         End of the interval
#    nosteps     Number of steps in which to divide the interval
#    expression  Expression with "x" as the integrate
# Return value:
#    Computed integral
#
proc ::math::calculus::integralExpr { begin end nosteps expression } {

   set delta    [expr {($end-$begin)/double($nosteps)}]
   set hdelta   [expr {$delta/2.0}]
   set result   0.0
   set x        $begin
   # FRINK: nocheck
   set func_end [expr $expression]
   for { set i 1 } { $i <= $nosteps } { incr i } {
      set func_begin  $func_end
      set x           [expr {$x+$hdelta}]
       # FRINK: nocheck
      set func_middle [expr $expression]
      set x           [expr {$x+$hdelta}]
       # FRINK: nocheck
      set func_end    [expr $expression]
      set result      [expr {$result+$func_begin+4.0*$func_middle+$func_end}]

      set x           [expr {$begin+double($i)*$delta}]
   }

   return [expr {$result*$delta/6.0}]
}

# Integral2D --
#    Integrate a given fucntion of two variables over a block,
#    using bilinear interpolation (for this moment: block function)
#
# Arguments:
#    xinterval   Start, stop and number of steps of the "x" interval
#    yinterval   Start, stop and number of steps of the "y" interval
#    func        Function of the two variables to be integrated
# Return value:
#    Computed integral
#
proc ::math::calculus::integral2D { xinterval yinterval func } {

   foreach { xbegin xend xnumber } $xinterval { break }
   foreach { ybegin yend ynumber } $yinterval { break }

   set xdelta    [expr {($xend-$xbegin)/double($xnumber)}]
   set ydelta    [expr {($yend-$ybegin)/double($ynumber)}]
   set hxdelta   [expr {$xdelta/2.0}]
   set hydelta   [expr {$ydelta/2.0}]
   set result   0.0
   set dxdy      [expr {$xdelta*$ydelta}]
   for { set j 0 } { $j < $ynumber } { incr j } {
      set y [expr {$hydelta+double($j)*$ydelta}]
      for { set i 0 } { $i < $xnumber } { incr i } {
         set x           [expr {$hxdelta+double($i)*$xdelta}]
         set func_value  [$func $x $y]
         set result      [expr {$result+$func_value}]
      }
   }

   return [expr {$result*$dxdy}]
}

# Integral3D --
#    Integrate a given fucntion of two variables over a block,
#    using trilinear interpolation (for this moment: block function)
#
# Arguments:
#    xinterval   Start, stop and number of steps of the "x" interval
#    yinterval   Start, stop and number of steps of the "y" interval
#    zinterval   Start, stop and number of steps of the "z" interval
#    func        Function of the three variables to be integrated
# Return value:
#    Computed integral
#
proc ::math::calculus::integral3D { xinterval yinterval zinterval func } {

   foreach { xbegin xend xnumber } $xinterval { break }
   foreach { ybegin yend ynumber } $yinterval { break }
   foreach { zbegin zend znumber } $zinterval { break }

   set xdelta    [expr {($xend-$xbegin)/double($xnumber)}]
   set ydelta    [expr {($yend-$ybegin)/double($ynumber)}]
   set zdelta    [expr {($zend-$zbegin)/double($znumber)}]
   set hxdelta   [expr {$xdelta/2.0}]
   set hydelta   [expr {$ydelta/2.0}]
   set hzdelta   [expr {$zdelta/2.0}]
   set result   0.0
   set dxdydz    [expr {$xdelta*$ydelta*$zdelta}]
   for { set k 0 } { $k < $znumber } { incr k } {
      set z [expr {$hzdelta+double($k)*$zdelta}]
      for { set j 0 } { $j < $ynumber } { incr j } {
         set y [expr {$hydelta+double($j)*$ydelta}]
         for { set i 0 } { $i < $xnumber } { incr i } {
            set x           [expr {$hxdelta+double($i)*$xdelta}]
            set func_value  [$func $x $y $z]
            set result      [expr {$result+$func_value}]
         }
      }
   }

   return [expr {$result*$dxdydz}]
}

# EulerStep --
#    Integrate a system of ordinary differential equations of the type
#    x' = f(x,t), where x is a vector of quantities. Integration is
#    done over a single step according to Euler's method.
#
# Arguments:
#    t           Start value of independent variable (time for instance)
#    tstep       Step size of interval
#    xvec        Vector of dependent values at the start
#    func        Function taking the arguments t and xvec to return
#                the derivative of each dependent variable.
# Return value:
#    List of values at the end of the step
#
proc ::math::calculus::eulerStep { t tstep xvec func } {

   set xderiv   [$func $t $xvec]
   set result   {}
   foreach xv $xvec dx $xderiv {
      set xnew [expr {$xv+$tstep*$dx}]
      lappend result $xnew
   }

   return $result
}

# HeunStep --
#    Integrate a system of ordinary differential equations of the type
#    x' = f(x,t), where x is a vector of quantities. Integration is
#    done over a single step according to Heun's method.
#
# Arguments:
#    t           Start value of independent variable (time for instance)
#    tstep       Step size of interval
#    xvec        Vector of dependent values at the start
#    func        Function taking the arguments t and xvec to return
#                the derivative of each dependent variable.
# Return value:
#    List of values at the end of the step
#
proc ::math::calculus::heunStep { t tstep xvec func } {

   #
   # Predictor step
   #
   set xpred    [EulerStep $t $tstep $xvec $func]

   #
   # Corrector step
   #
   set tcorr    [expr {$t+$tstep}]
   set xcorr    [EulerStep $t     $tstep $xpred $func]

   set result   {}
   foreach xv $xvec xc $xcorr {
      set xnew [expr {0.5*($xv+$xc)}]
      lappend result $xnew
   }

   return $result
}

# RungeKuttaStep --
#    Integrate a system of ordinary differential equations of the type
#    x' = f(x,t), where x is a vector of quantities. Integration is
#    done over a single step according to Runge-Kutta 4th order.
#
# Arguments:
#    t           Start value of independent variable (time for instance)
#    tstep       Step size of interval
#    xvec        Vector of dependent values at the start
#    func        Function taking the arguments t and xvec to return
#                the derivative of each dependent variable.
# Return value:
#    List of values at the end of the step
#
proc ::math::calculus::rungeKuttaStep { t tstep xvec func } {

   #
   # Four steps:
   # - t, x0 to t+Dt/2 ==> Dx1
   # - t+Dt/2, x1 to t+Dt, x2
   # - t+Dt/2, x1 to t+Dt, x2
   # - t, x0 to t+Dt, x2
   #
   set xpred    [EulerStep $t $tstep $xvec $func]

   #
   # Corrector step
   #
   set tcorr    [expr {$t+$tstep}]
   set xcorr    [EulerStep $t     $tstep $xpred $func]

   set result   {}
   foreach xv $xvec xc $xcorr {
      set xnew [expr {0.5*($xv+$xc)}]
      lappend result $xnew
   }

   return $result
}

# BoundaryValueSecondOrder --
#    Integrate a second-order differential equation and solve for
#    given boundary values.
#
#    The equation is (see the documentation):
#       d       dy   d
#       -- A(x) -- + -- B(x) y + C(x) y = D(x)
#       dx      dx   dx
#
#    The procedure uses finite differences and tridiagonal matrices to
#    solve the equation. The boundary values are put in the matrix
#    directly.
#
# Arguments:
#    coeff_func  Name of triple-valued function for coefficients A, B, C
#    force_func  Name of the function providing the force term D(x)
#    leftbnd     Left boundary condition (list of: xvalue, boundary
#                value or keyword zero-flux, zero-derivative)
#    rightbnd    Right boundary condition (ditto)
#    nostep      Number of steps
# Return value:
#    List of x-values and calculated values (x1, y1, x2, y2, ...)
#
proc ::math::calculus::boundaryValueSecondOrder {
   coeff_func force_func leftbnd rightbnd nostep } {

   if { [llength $leftbnd] != 2 || [llength $rightbnd] != 2 } {
      error "Boundary condition(s) incorrect"
   }
   if { $nostep < 1 } {
      error "Number of steps must be larger/equal 1"
   }

   #
   # Set up the matrix, as three different lists and the
   # righthand side as the fourth
   #
   set xleft  [lindex $leftbnd 0]
   set xright [lindex $rightbnd 0]
   set xstep  [expr {($xright-$xleft)/double($nostep)}]

   set acoeff {}
   set bcoeff {}
   set ccoeff {}
   set dvalue {}

   set x $xleft
   foreach {A B C} [$coeff_func $x] { break }

   set A1 [expr {$A/$xstep-0.5*$B}]
   set B1 [expr {$A/$xstep+0.5*$B+0.5*$C*$xstep}]
   set C1 0.0

   for { set i 1 } { $i <= $nostep } { incr i } {
      set x [expr {$xleft+double($i)*$xstep}]
      if { [expr {abs($x)-0.5*abs($xstep)}] < 0.0 } {
         set x 0.0
      }
      foreach {A B C} [$coeff_func $x] { break }

      set A2 0.0
      set B2 [expr {$A/$xstep-0.5*$B+0.5*$C*$xstep}]
      set C2 [expr {$A/$xstep+0.5*$B}]
      lappend acoeff [expr {$A1+$A2}]
      lappend bcoeff [expr {-$B1-$B2}]
      lappend ccoeff [expr {$C1+$C2}]
      set A1 [expr {$A/$xstep-0.5*$B}]
      set B1 [expr {$A/$xstep+0.5*$B+0.5*$C*$xstep}]
      set C1 0.0
   }
   set xvec {}
   for { set i 0 } { $i < $nostep } { incr i } {
      set x [expr {$xleft+(0.5+double($i))*$xstep}]
      if { [expr {abs($x)-0.25*abs($xstep)}] < 0.0 } {
         set x 0.0
      }
      lappend xvec   $x
      lappend dvalue [expr {$xstep*[$force_func $x]}]
   }

   #
   # Substitute the boundary values
   #
   set A  [lindex $acoeff 0]
   set D  [lindex $dvalue 0]
   set D1 [expr {$D-$A*[lindex $leftbnd 1]}]
   set C  [lindex $ccoeff end]
   set D  [lindex $dvalue end]
   set D2 [expr {$D-$C*[lindex $rightbnd 1]}]
   set dvalue [concat $D1 [lrange $dvalue 1 end-1] $D2]

   set yvec [SolveTriDiagonal $acoeff $bcoeff $ccoeff $dvalue]

   foreach x $xvec y $yvec {
      lappend result $x $y
   }
   return $result
}

# SolveTriDiagonal --
#    Solve a system of equations Ax = b where A is a tridiagonal matrix
#
# Arguments:
#    acoeff      Values on lower diagonal
#    bcoeff      Values on main diagonal
#    ccoeff      Values on upper diagonal
#    dvalue      Values on righthand side
# Return value:
#    List of values forming the solution
#
proc ::math::calculus::solveTriDiagonal { acoeff bcoeff ccoeff dvalue } {

   set nostep [llength $acoeff]
   #
   # First step: Gauss-elimination
   #
   set B [lindex $bcoeff 0]
   set C [lindex $ccoeff 0]
   set D [lindex $dvalue 0]
   set bcoeff2 [list $B]
   set dvalue2 [list $D]
   for { set i 1 } { $i < $nostep } { incr i } {
      set A2    [lindex $acoeff $i]
      set B2    [lindex $bcoeff $i]
      set C2    [lindex $ccoeff $i]
      set D2    [lindex $dvalue $i]
      set ratab [expr {$A2/$B}]
      set B2    [expr {$B2-$ratab*$C}]
      set D2    [expr {$D2-$ratab*$D}]
      lappend bcoeff2 $B2
      lappend dvalue2 $D2
      set B     $B2
      set D     $D2
   }

   #
   # Second step: substitution
   #
   set yvec {}
   set B [lindex $bcoeff2 end]
   set D [lindex $dvalue2 end]
   set y [expr {$D/$B}]
   for { set i [expr {$nostep-2}] } { $i >= 0 } { incr i -1 } {
      set yvec  [concat $y $yvec]
      set B     [lindex $bcoeff2 $i]
      set C     [lindex $ccoeff  $i]
      set D     [lindex $dvalue2 $i]
      set y     [expr {($D-$C*$y)/$B}]
   }
   set yvec [concat $y $yvec]

   return $yvec
}

# Now we can announce our presence.
package provide math::calculus 0.2
