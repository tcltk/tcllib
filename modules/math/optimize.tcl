#----------------------------------------------------------------------
#
# math/optimize.tcl --
#
#	This file contains functions for optimization of a function
#	or expression.
#
# Copyright (c) 2004, by Arjen Markus.
# Copyright (c) 2004, by Kevin B. Kenny.  All rights reserved.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: optimize.tcl,v 1.8 2005/08/09 07:37:18 arjenmarkus Exp $
#
#----------------------------------------------------------------------

# math::optimize --
#    Namespace for the commands
#
namespace eval ::math::optimize {
   namespace export minimum  maximum solveLinearProgram linearProgramMaximum
   namespace export min_bound_1d min_unbound_1d

   # Possible extension: minimumExpr, maximumExpr
}

# minimum --
#    Minimize a given function over a given interval
#
# Arguments:
#    begin       Start of the interval
#    end         End of the interval
#    func        Name of the function to be minimized (takes one
#                argument)
#    maxerr      Maximum relative error (defaults to 1.0e-4)
# Return value:
#    Computed value for which the function is minimal
# Notes:
#    The function needs not to be differentiable, but it is supposed
#    to be continuous. There is no provision for sub-intervals where
#    the function is constant (this might happen when the maximum
#    error is very small, < 1.0e-15)
#
# Warning:
#    This procedure is deprecated - use min_bound_1d instead
#
proc ::math::optimize::minimum { begin end func {maxerr 1.0e-4} } {

   set nosteps  [expr {3+int(-log($maxerr)/log(2.0))}]
   set delta    [expr {0.5*($end-$begin)*$maxerr}]

   for { set step 0 } { $step < $nosteps } { incr step } {
      set x1 [expr {($end+$begin)/2.0}]
      set x2 [expr {$x1+$delta}]

      set fx1 [uplevel 1 $func $x1]
      set fx2 [uplevel 1 $func $x2]

      if {$fx1 < $fx2} {
         set end   $x1
      } else {
         set begin $x1
      }
   }
   return $x1
}

# maximum --
#    Maximize a given function over a given interval
#
# Arguments:
#    begin       Start of the interval
#    end         End of the interval
#    func        Name of the function to be maximized (takes one
#                argument)
#    maxerr      Maximum relative error (defaults to 1.0e-4)
# Return value:
#    Computed value for which the function is maximal
# Notes:
#    The function needs not to be differentiable, but it is supposed
#    to be continuous. There is no provision for sub-intervals where
#    the function is constant (this might happen when the maximum
#    error is very small, < 1.0e-15)
#
# Warning:
#    This procedure is deprecated - use max_bound_1d instead
#
proc ::math::optimize::maximum { begin end func {maxerr 1.0e-4} } {

   set nosteps  [expr {3+int(-log($maxerr)/log(2.0))}]
   set delta    [expr {0.5*($end-$begin)*$maxerr}]

   for { set step 0 } { $step < $nosteps } { incr step } {
      set x1 [expr {($end+$begin)/2.0}]
      set x2 [expr {$x1+$delta}]

      set fx1 [uplevel 1 $func $x1]
      set fx2 [uplevel 1 $func $x2]

      if {$fx1 > $fx2} {
         set end   $x1
      } else {
         set begin $x1
      }
   }
   return $x1
}

#----------------------------------------------------------------------
#
# min_bound_1d --
#
#       Find a local minimum of a function between two given
#       abscissae. Derivative of f is not required.
#
# Usage:
#       min_bound_1d f x1 x2 ?-option value?,,,
#
# Parameters:
#       f - Function to minimize.  Must be expressed as a Tcl
#           command, to which will be appended the value at which
#           to evaluate the function.
#       x1 - Lower bound of the interval in which to search for a
#            minimum
#       x2 - Upper bound of the interval in which to search for a minimum
#
# Options:
#       -relerror value
#               Gives the tolerance desired for the returned
#               abscissa.  Default is 1.0e-7.  Should never be less
#               than the square root of the machine precision.
#       -maxiter n
#               Constrains minimize_bound_1d to evaluate the function
#               no more than n times.  Default is 100.  If convergence
#               is not achieved after the specified number of iterations,
#               an error is thrown.
#       -guess value
#               Gives a point between x1 and x2 that is an initial guess
#               for the minimum.  f(guess) must be at most f(x1) or
#               f(x2).
#        -fguess value
#                Gives the value of the ordinate at the value of '-guess'
#                if known.  Default is to evaluate the function
#       -abserror value
#               Gives the desired absolute error for the returned
#               abscissa.  Default is 1.0e-10.
#       -trace boolean
#               A true value causes a trace to the standard output
#               of the function evaluations. Default is 0.
#
# Results:
#       Returns a two-element list comprising the abscissa at which
#       the function reaches a local minimum within the interval,
#       and the value of the function at that point.
#
# Side effects:
#       Whatever side effects arise from evaluating the given function.
#
#----------------------------------------------------------------------

proc ::math::optimize::min_bound_1d { f x1 x2 args } {

    set f [lreplace $f 0 0 [uplevel 1 [list namespace which [lindex $f 0]]]]

    set phim1 0.6180339887498949
    set twomphi 0.3819660112501051

    array set params {
        -relerror 1.0e-7
        -abserror 1.0e-10
        -maxiter 100
        -trace 0
        -fguess {}
    }
    set params(-guess) [expr { $phim1 * $x1 + $twomphi * $x2 }]

    if { ( [llength $args] % 2 ) != 0 } {
        return -code error -errorcode [list min_bound_1d wrongNumArgs] \
            "wrong \# args, should be\
                 \"[lreplace [info level 0] 1 end f x1 x2 ?-option value?...]\""
    }
    foreach { key value } $args {
        if { ![info exists params($key)] } {
            return -code error -errorcode [list min_bound_1d badoption $key] \
                "unknown option \"$key\",\
                     should be -abserror,\
                     -fguess, -guess, -initial, -maxiter, -relerror,\
                     or -trace"
        }
	set params($key) $value
    }

    # a and b presumably bracket the minimum of the function.  Make sure
    # they're in ascending order.

    if { $x1 < $x2 } {
        set a $x1; set b $x2
    } else {
        set b $x1; set a $x2
    }

    set x $params(-guess);              # Best abscissa found so far
    set w $x;                           # Second best abscissa found so far
    set v $x;                           # Most recent earlier value of w

    set e 0.0;                          # Distance moved on the step before
					# last.

    # Evaluate the function at the initial guess

    if { $params(-fguess) ne {} } {
        set fx $params(-fguess)
    } else {
        set s $f; lappend s $x; set fx [eval $s]
        if { $params(-trace) } {
            puts stdout "f($x) = $fx (initialisation)"
        }
    }
    set fw $fx
    set fv $fx

    for { set iter 0 } { $iter < $params(-maxiter) } { incr iter } {

        # Find the midpoint of the current interval

        set xm [expr { 0.5 * ( $a + $b ) }]

        # Compute the current tolerance for x, and twice its value

        set tol [expr { $params(-relerror) * abs($x) + $params(-abserror) }]
        set tol2 [expr { $tol + $tol }]
        if { abs( $x - $xm ) <= $tol2 - 0.5 * ($b - $a) } {
            return [list $x $fx]
        }
        set golden 1
        if { abs($e) > $tol } {

            # Use parabolic interpolation to find a minimum determined
            # by the evaluations at x, v, and w.  The size of the step
            # to take will be $p/$q.

            set r [expr { ( $x - $w ) * ( $fx - $fv ) }]
            set q [expr { ( $x - $v ) * ( $fx - $fw ) }]
            set p [expr { ( $x - $v ) * $q - ( $x - $w ) * $r }]
            set q [expr { 2. * ( $q - $r ) }]
            if { $q > 0 } {
                set p [expr { - $p }]
            } else {
                set q [expr { - $q }]
            }
            set olde $e
            set e $d

            # Test if parabolic interpolation results in less than half
            # the movement of the step two steps ago.

            if { abs($p) < abs( .5 * $q * $olde )
                 && $p > $q * ( $a - $x )
                 && $p < $q * ( $b - $x ) } {

                set d [expr { $p / $q }]
                set u [expr { $x + $d }]
                if { ( $u - $a ) < $tol2 || ( $b - $u ) < $tol2 } {
                    if { $xm-$x < 0 } {
                        set d [expr { - $tol }]
                    } else {
                        set d $tol
                    }
                }
                set golden 0
            }
        }

        # If parabolic interpolation didn't come up with an acceptable
        # result, use Golden Section instead.

        if { $golden } {
            if { $x >= $xm } {
                set e [expr { $a - $x }]
            } else {
                set e [expr { $b - $x }]
            }
            set d [expr { $twomphi * $e }]
        }

        # At this point, d is the size of the step to take.  Make sure
        # that it's at least $tol.

        if { abs($d) >= $tol } {
            set u [expr { $x + $d }]
        } elseif { $d < 0 } {
            set u [expr { $x - $tol }]
        } else {
            set u [expr { $x + $tol }]
        }

        # Evaluate the function

        set s $f; lappend s $u; set fu [eval $s]
        if { $params(-trace) } {
            if { $golden } {
                puts stdout "f($u)=$fu (golden section)"
            } else {
                puts stdout "f($u)=$fu (parabolic interpolation)"
            }
        }

        if { $fu <= $fx } {
            # We've the best abscissa so far.

            if { $u >= $x } {
                set a $x
            } else {
                set b $x
            }
            set v $w
            set fv $fw
            set w $x
            set fw $fx
            set x $u
            set fx $fu
        } else {

            if { $u < $x } {
                set a $u
            } else {
                set b $u
            }
            if { $fu <= $fw || $w == $x } {
                # We've the second-best abscissa so far
                set v $w
                set fv $fw
                set w $u
                set fw $fu
            } elseif { $fu <= $fv || $v == $x || $v == $w } {
                # We've the third-best so far
                set v $u
                set fv $fu
            }
        }
    }

    return -code error -errorcode [list min_bound_1d noconverge $iter] \
        "[lindex [info level 0] 0] failed to converge after $iter steps."

}

#----------------------------------------------------------------------
#
# brackmin --
#
#       Find a place along the number line where a given function has
#       a local minimum.
#
# Usage:
#       brackmin f x1 x2 ?trace?
#
# Parameters:
#       f - Function to minimize
#       x1 - Abscissa thought to be near the minimum
#       x2 - Additional abscissa thought to be near the minimum
#	trace - Boolean variable that, if true,
#               causes 'brackmin' to print a trace of its function
#               evaluations to the standard output.  Default is 0.
#
# Results:
#       Returns a three element list {x1 y1 x2 y2 x3 y3} where
#       y1=f(x1), y2=f(x2), y3=f(x3).  x2 lies between x1 and x3, and
#       y1>y2, y3>y2, proving that there is a local minimum somewhere
#       in the interval (x1,x3).
#
# Side effects:
#       Whatever effects the evaluation of f has.
#
#----------------------------------------------------------------------

proc ::math::optimize::brackmin { f x1 x2 {trace 0} } {

    set f [lreplace $f 0 0 [uplevel 1 [list namespace which [lindex $f 0]]]]

    set phi 1.6180339887498949
    set epsilon 1.0e-20
    set limit 50.

    # Choose a and b so that f(a) < f(b)

    set cmd $f; lappend cmd $x1; set fx1 [eval $cmd]
    if { $trace } {
        puts "f($x1) = $fx1 (initialisation)"
    }
    set cmd $f; lappend cmd $x2; set fx2 [eval $cmd]
    if { $trace } {
        puts "f($x2) = $fx2 (initialisation)"
    }
    if { $fx1 > $fx2 } {
        set a $x1; set fa $fx1
        set b $x2; set fb $fx2
    } else {
        set a $x2; set fa $fx2
        set b $x1; set fb $fx1
    }

    # Choose a c in the downhill direction

    set c [expr { $b + $phi * ($b - $a) }]
    set cmd $f; lappend cmd $c; set fc [eval $cmd]
    if { $trace } {
        puts "f($c) = $fc (initial dilatation by phi)"
    }

    while { $fb >= $fc } {

        # Try to do parabolic extrapolation to the minimum

        set r [expr { ($b - $a) * ($fb - $fc) }]
        set q [expr { ($b - $c) * ($fb - $fa) }]
        if { abs( $q - $r ) > $epsilon } {
            set denom [expr { $q - $r }]
        } elseif { $q > $r } {
            set denom $epsilon
        } else {
            set denom -$epsilon
        }
        set u [expr { $b - ( (($b - $c) * $q - ($b - $a) * $r)
                             / (2. * $denom) ) }]
        set ulimit [expr { $b + $limit * ( $c - $b ) }]

        # Test the extrapolated abscissa

        if { ($b - $u) * ($u - $c) > 0 } {

            # u lies between b and c.  Try to interpolate

            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (parabolic interpolation)"
            }

            if { $fu < $fc } {

                # fb > fu and fc > fu, so there is a minimum between b and c
                # with u as a starting guess.

                return [list $b $fb $u $fu $c $fc]

            }

            if { $fu > $fb } {

                # fb < fu, fb < fa, and u cannot lie between a and b
                # (because it lies between a and c).  There is a minimum
                # somewhere between a and u, with b a starting guess.

                return [list $a $fa $b $fb $u $fu]

            }

            # Parabolic interpolation was useless. Expand the
            # distance by a factor of phi and try again.

            set u [expr { $c + $phi * ($c - $b) }]
            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (parabolic interpolation failed)"
            }


        } elseif { ( $c - $u ) * ( $u - $ulimit ) > 0 } {

            # u lies between $c and $ulimit.

            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (parabolic extrapolation)"
            }

            if { $fu > $fc } {

                # minimum lies between b and u, with c an initial guess.

                return [list $b $fb $c $fc $u $fu]

            }

            # function is still decreasing fa > fb > fc > fu. Take
            # another factor-of-phi step.

            set b $c; set fb $fc
            set c $u; set fc $fu
            set u [expr { $c + $phi * ( $c - $b ) }]
            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (parabolic extrapolation ok)"
            }

        } elseif { ($u - $ulimit) * ( $ulimit - $c ) >= 0 } {

            # u went past ulimit.  Pull in to ulimit and evaluate there.

            set u $ulimit
            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (limited step)"
            }

        } else {

            # parabolic extrapolation gave a useless value.

            set u [expr { $c + $phi * ( $c - $b ) }]
            set cmd $f; lappend cmd $u; set fu [eval $cmd]
            if { $trace } {
                puts "f($u) = $fu (parabolic extrapolation failed)"
            }

        }

        set a $b; set fa $fb
        set b $c; set fb $fc
        set c $u; set fc $fu
    }

    return [list $a $fa $b $fb $c $fc]
}

#----------------------------------------------------------------------
#
# min_unbound_1d --
#
#	Minimize a function of one variable, unconstrained, derivatives
#	not required.
#
# Usage:
#       min_bound_1d f x1 x2 ?-option value?,,,
#
# Parameters:
#       f - Function to minimize.  Must be expressed as a Tcl
#           command, to which will be appended the value at which
#           to evaluate the function.
#       x1 - Initial guess at the minimum
#       x2 - Second initial guess at the minimum, used to set the
#	     initial length scale for the search.
#
# Options:
#       -relerror value
#               Gives the tolerance desired for the returned
#               abscissa.  Default is 1.0e-7.  Should never be less
#               than the square root of the machine precision.
#       -maxiter n
#               Constrains min_bound_1d to evaluate the function
#               no more than n times.  Default is 100.  If convergence
#               is not achieved after the specified number of iterations,
#               an error is thrown.
#       -abserror value
#               Gives the desired absolute error for the returned
#               abscissa.  Default is 1.0e-10.
#       -trace boolean
#               A true value causes a trace to the standard output
#               of the function evaluations. Default is 0.
#
#----------------------------------------------------------------------

proc ::math::optimize::min_unbound_1d { f x1 x2 args } {

    set f [lreplace $f 0 0 [uplevel 1 [list namespace which [lindex $f 0]]]]

    array set params {
	-relerror 1.0e-7
	-abserror 1.0e-10
	-maxiter 100
        -trace 0
    }
    if { ( [llength $args] % 2 ) != 0 } {
        return -code error -errorcode [list min_unbound_1d wrongNumArgs] \
            "wrong \# args, should be\
                 \"[lreplace [info level 0] 1 end \
                         f x1 x2 ?-option value?...]\""
    }
    foreach { key value } $args {
        if { ![info exists params($key)] } {
            return -code error -errorcode [list min_unbound_1d badoption $key] \
                "unknown option \"$key\",\
                     should be -trace"
        }
        set params($key) $value
    }
    foreach { a fa b fb c fc } [brackmin $f $x1 $x2 $params(-trace)] {
	break
    }
    return [eval [linsert [array get params] 0 \
		      min_bound_1d $f $a $c -guess $b -fguess $fb]]
}

# solveLinearProgram
#    Solve a linear program in standard form
#
# Arguments:
#    objective     Vector defining the objective function
#    constraints   Matrix of constraints (as a list of lists)
#
# Return value:
#    Computed values for the coordinates or "unbounded" or "infeasible"
#
proc ::math::optimize::solveLinearProgram { objective constraints } {
    #
    # Check the arguments first and then put them in a more convenient
    # form
    #

    foreach {nconst nvars matrix} \
        [SimplexPrepareMatrix $objective $constraints] {break}

    set solution [SimplexSolve $nconst nvars $matrix]

    if { [llength $solution] > 1 } {
        return [lrange $solution 0 [expr {$nvars-1}]]
    } else {
        return $solution
    }
}

# linearProgramMaximum --
#    Compute the value attained at the optimum
#
# Arguments:
#    objective     The coefficients of the objective function
#    result        The coordinate values as obtained by solving the program
#
# Return value:
#    Value at the maximum point
#
proc ::math::optimize::linearProgramMaximum {objective result} {

    set value    0.0

    foreach coeff $objective coord $result {
        set value [expr {$value+$coeff*$coord}]
    }

    return $value
}

# SimplexPrintMatrix
#    Debugging routine: print the matrix in easy to read form
#
# Arguments:
#    matrix        Matrix to be printed
#
# Return value:
#    None
#
# Note:
#    The tableau should be transposed ...
#
proc ::math::optimize::SimplexPrintMatrix {matrix} {
    puts "\nBasis:\t[join [lindex $matrix 0] \t]"
    foreach col [lrange $matrix 1 end] {
        puts "      \t[join $col \t]"
    }
}

# SimplexPrepareMatrix
#    Prepare the standard tableau from all program data
#
# Arguments:
#    objective     Vector defining the objective function
#    constraints   Matrix of constraints (as a list of lists)
#
# Return value:
#    List of values as a standard tableau and two values
#    for the sizes
#
proc ::math::optimize::SimplexPrepareMatrix {objective constraints} {

    #
    # Check the arguments first
    #
    set nconst [llength $constraints]
    set ncols {}
    foreach row $constraints {
        if { $ncols == {} } {
            set ncols [llength $row]
        } else {
            if { $ncols != [llength $row] } {
                return -code error -errorcode ARGS "Incorrectly formed constraints matrix"
            }
        }
    }

    set nvars [expr {$ncols-1}]

    if { [llength $objective] != $nvars } {
        return -code error -errorcode ARGS "Incorrect length for objective vector"
    }

    #
    # Set up the tableau:
    # Easiest manipulations if we store the columns first
    # So:
    # - First column is the list of variable indices in the basis
    # - Second column is the list of maximum values
    # - "nvars" columns that follow: the coefficients for the actual
    #   variables
    # - last "nconst" columns: the slack variables
    #
    set matrix   [list]
    set lastrow  [concat $objective [list 0.0]]

    set newcol   [list]
    for {set idx 0} {$idx < $nconst} {incr idx} {
        lappend newcol [expr {$nvars+$idx}]
    }
    lappend newcol "?"
    lappend matrix $newcol

    set zvector [list]
    foreach row $constraints {
        lappend zvector [lindex $row end]
    }
    lappend zvector 0.0
    lappend matrix $zvector

    for {set idx 0} {$idx < $nvars} {incr idx} {
        set newcol [list]
        foreach row $constraints {
            lappend newcol [expr {double([lindex $row $idx])}]
        }
        lappend newcol [expr {-double([lindex $lastrow $idx])}]
         lappend matrix $newcol
    }

    #
    # Add the columns for the slack variables
    #
    set zeros {}
    for {set idx 0} {$idx <= $nconst} {incr idx} {
        lappend zeros 0.0
    }
    for {set idx 0} {$idx < $nconst} {incr idx} {
        lappend matrix [lreplace $zeros $idx $idx 1.0]
    }

    return [list $nconst $nvars $matrix]
}

# SimplexSolve --
#    Solve the given linear program using the simplex method
#
# Arguments:
#    nconst        Number of constraints
#    nvars         Number of actual variables
#    tableau       Standard tableau (as a list of columns)
#
# Return value:
#    List of values for the actual variables
#
proc ::math::optimize::SimplexSolve {nconst nvars tableau} {
    set end 0
    while { !$end } {

        #
        # Find the new variable to put in the basis
        #
        set nextcol [SimplexFindNextColumn $tableau]
        if { $nextcol == -1 } {
            set end 1
            continue
        }

        #
        # Now determine which one should leave
        # TODO: is a lack of a proper row indeed an
        #       indication of the infeasibility?
        #
        set nextrow [SimplexFindNextRow $tableau $nextcol]
        if { $nextrow == -1 } {
            return "infeasible"
        }

        #
        # Make the vector for sweeping through the tableau
        #
        set vector [SimplexMakeVector $tableau $nextcol $nextrow]

        #
        # Sweep through the tableau
        #
        set tableau [SimplexNewTableau $tableau $nextcol $nextrow $vector]
    }

    #
    # Now we can return the result
    #
    SimplexResult $tableau
}

# SimplexResult --
#    Reconstruct the result vector
#
# Arguments:
#    tableau       Standard tableau (as a list of columns)
#
# Return value:
#    Vector of values representing the maximum point
#
proc ::math::optimize::SimplexResult {tableau} {
    set result {}

    set firstcol  [lindex $tableau 0]
    set secondcol [lindex $tableau 1]
    set result    {}

    set nvars     [expr {[llength $tableau]-2}]
    for {set i 0} {$i < $nvars } { incr i } {
        lappend result 0.0
    }

    set idx 0
    foreach col [lrange $firstcol 0 end-1] {
        set result [lreplace $result $col $col [lindex $secondcol $idx]]
        incr idx
    }

    return $result
}

# SimplexFindNextColumn --
#    Find the next column - the one with the largest negative
#    coefficient
#
# Arguments:
#    tableau       Standard tableau (as a list of columns)
#
# Return value:
#    Index of the column
#
proc ::math::optimize::SimplexFindNextColumn {tableau} {
    set idx        0
    set minidx    -1
    set mincoeff   0.0

    foreach col [lrange $tableau 2 end] {
        set coeff [lindex $col end]
        if { $coeff < 0.0 } {
            if { $coeff < $mincoeff } {
                set minidx $idx
               set mincoeff $coeff
            }
        }
        incr idx
    }

    return $minidx
}

# SimplexFindNextRow --
#    Find the next row - the one with the largest negative
#    coefficient
#
# Arguments:
#    tableau       Standard tableau (as a list of columns)
#    nextcol       Index of the variable that will replace this one
#
# Return value:
#    Index of the row
#
proc ::math::optimize::SimplexFindNextRow {tableau nextcol} {
    set idx        0
    set minidx    -1
    set mincoeff   {}

    set bvalues [lrange [lindex $tableau 1] 0 end-1]
    set yvalues [lrange [lindex $tableau [expr {2+$nextcol}]] 0 end-1]

    foreach rowcoeff $bvalues divcoeff $yvalues {
        if { $divcoeff > 0.0 } {
            set coeff [expr {$rowcoeff/$divcoeff}]

            if { $mincoeff == {} || $coeff < $mincoeff } {
                set minidx $idx
                set mincoeff $coeff
            }
        }
        incr idx
    }

    return $minidx
}

# SimplexMakeVector --
#    Make the "sweep" vector
#
# Arguments:
#    tableau       Standard tableau (as a list of columns)
#    nextcol       Index of the variable that will replace this one
#    nextrow       Index of the variable in the base that will be replaced
#
# Return value:
#    Vector to be used to update the coefficients of the tableau
#
proc ::math::optimize::SimplexMakeVector {tableau nextcol nextrow} {

    set idx      0
    set vector   {}
    set column   [lindex $tableau [expr {2+$nextcol}]]
    set divcoeff [lindex $column $nextrow]

    foreach colcoeff $column {
        if { $idx != $nextrow } {
            set coeff [expr {-$colcoeff/$divcoeff}]
        } else {
            set coeff [expr {1.0/$divcoeff-1.0}]
        }
        lappend vector $coeff
        incr idx
    }

    return $vector
}

# SimplexNewTableau --
#    Sweep through the tableau and create the new one
#
# Arguments:
#    tableau       Standard tableau (as a list of columns)
#    nextcol       Index of the variable that will replace this one
#    nextrow       Index of the variable in the base that will be replaced
#    vector        Vector to sweep with
#
# Return value:
#    New tableau
#
proc ::math::optimize::SimplexNewTableau {tableau nextcol nextrow vector} {

    #
    # The first column: replace the nextrow-th element
    # The second column: replace the value at the nextrow-th element
    # For all the others: the same receipe
    #
    set firstcol   [lreplace [lindex $tableau 0] $nextrow $nextrow $nextcol]
    set newtableau [list $firstcol]

    #
    # The rest of the matrix
    #
    foreach column [lrange $tableau 1 end] {
        set yval   [lindex $column $nextrow]
        set newcol {}
        foreach c $column vcoeff $vector {
            set newval [expr {$c+$yval*$vcoeff}]
            lappend newcol $newval
        }
        lappend newtableau $newcol
    }

    return $newtableau
}

# Now we can announce our presence
package provide math::optimize 1.0
