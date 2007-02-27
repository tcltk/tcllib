# Copyright 2007 Eric Kemp-Benedict
# Released under the BSD license under any terms
# that allow it to be compatible with tcllib

package provide mvlinreg 0.1

package require math::linearalgebra 1.0
package require math::statistics 0.1.1

# mvlinreg = Multivariate Linear Regression
namespace eval mvlinreg {
    variable epsilon 1.0e-7
    
    namespace export tstat wls ols
    
    namespace import -force \
        ::math::linearalgebra::mkMatrix \
        ::math::linearalgebra::mkVector \
        ::math::linearalgebra::mkIdentity \
        ::math::linearalgebra::mkDiagonal \
        ::math::linearalgebra::getrow \
        ::math::linearalgebra::setrow \
        ::math::linearalgebra::getcol \
        ::math::linearalgebra::setcol \
        ::math::linearalgebra::getelem \
        ::math::linearalgebra::setelem \
        ::math::linearalgebra::dotproduct \
        ::math::linearalgebra::matmul \
        ::math::linearalgebra::add \
        ::math::linearalgebra::sub \
        ::math::linearalgebra::solveGauss
    
    # NOTE: The authors of math::linearalgebra seem to have 
    #   forgotten to export ::math::linearalgebra::transpose
        
    ########################################
    #
    # t-stats
    #
    ########################################
    # mvlinreg::tstat n ?alpha?
    # Returns inverse of the single-tailed t distribution
    #  given number of degrees of freedom & confidence
    # Defaults to alpha = 0.05
    # Iterates until result is within epsilon of the target
    proc tstat {n {alpha 0.05}} {
        variable epsilon
        variable tvals
        
        if [info exists tvals($n:$alpha)] {
            return $tvals($n:$alpha)
        }
        
        set deltat [expr {100 * $epsilon}]
        # For one-tailed distribution, 
        set ptarg [expr {1.000 - $alpha/2.0}]
        set maxiter 100
        
        # Initial value for t
        set t 2.0
        
        set niter 0
        while {abs([::math::statistics::cdf-students-t $n $t] - $ptarg) > $epsilon} {
            set pstar [::math::statistics::cdf-students-t $n $t]
            set pl [::math::statistics::cdf-students-t $n [expr {$t - $deltat}]]
            set ph [::math::statistics::cdf-students-t $n [expr {$t + $deltat}]]
            
            set t [expr {$t + 2.0 * $deltat * ($ptarg - $pstar)/($ph - $pl)}]
            
            incr niter
            if {$niter == $maxiter} {
                error "mvlinreg::tstat: Did not converge after $niter iterations"
                return {}
            }
        }
        
        # Cache the result to shorten the call in future
        set tvals($n:$alpha) $t
        
        return $t
    }
        
    ########################################
    #
    # Weighted Least Squares
    #
    ########################################
    # mvlinreg::wls w [list y x's] w [list y x's] ...
    # Returns:
    #   R-squared
    #   Adj R-squared
    #   coefficients of x's in fit
    #   standard errors of the coefficients
    #   95% confidence bounds for coefficients
    proc wls {args} {
        
        # Fill the matrices of x & y values, and weights
        # For n points, k coefficients
        
        # The number of points is equal to half the arguments (n weights, n points)
        set n [expr {[llength $args]/2}]
        
        set firstloop true
        # Sum up all y values to take an average
        set ysum 0
        # Add up the weights
        set wtsum 0
        # Count over rows (points) as you go
        set point 0
        foreach {wt pt} $args {
            
            # Check inputs
            if {[string is double $wt] == 0} {
                error "mvlinreg::wls: Weight \"$wt\" is not a number"
                return {}
            }
            
            ## -- Check dimensions, initialize
            if $firstloop {
                # k = num of vals in pt = 1 + number of x's (because of constant)
                set k [llength $pt]
                if {$n <= [expr {$k + 1}]} {
                    error "mvlinreg::wls: Too few degrees of freedom: $k variables but only $n points"
                    return {}
                }
                set X [mkMatrix $n $k]
                set y [mkVector $n]
                set I_x [mkIdentity $k]
                set I_y [mkIdentity $n]
                
                set firstloop false
                
            } else {
                # Have to have same number of x's for all points
                if {$k != [llength $pt]} {
                    error "mvlinreg::wls: Point \"$pt\" has wrong number of values (expected $k)"
                    # Clean up
                    return {}
                }
            }
            
            ## -- Extract values from set of points
            # Make a list of y values
            set yval [expr {double([lindex $pt 0])}]
            setelem y $point $yval
            set ysum [expr {$ysum + $wt * $yval}]
            set wtsum [expr {$wtsum + $wt}]
            # Add x-values to the x-matrix
            set xrow [lrange $pt 1 end]
            # Add the constant (value = 1.0)
            lappend xrow 1.0
            setrow X $point $xrow
            # Create list of weights & square root of weights
            lappend w [expr {double($wt)}]
            lappend sqrtw [expr {sqrt(double($wt))}]
            
            incr point
            
        }

        set ymean [expr {double($ysum)/$wtsum}]
        set W [mkDiagonal $w]
        set sqrtW [mkDiagonal $sqrtw]
        
        # Calculate sum os square differences for x's
        for {set r 0} {$r < $k} {incr r} {
            set xsqrsum 0.0
            set xmeansum 0.0
            # Calculate sum of squared differences as: sum(x^2) - (sum x)^2/n
            for {set t 0} {$t < $n} {incr t} {
                set xval [getelem $X $t $r]
                set xmeansum [expr {$xmeansum + double($xval)}]
                set xsqrsum [expr {$xsqrsum + double($xval * $xval)}]
            }
            lappend xsqr [expr {$xsqrsum - $xmeansum * $xmeansum/$n}]
        }
        
        ## -- Set up the X'WX matrix
        set XtW [matmul [::math::linearalgebra::transpose $X] $W]
        set XtWX [matmul $XtW $X]
        
        # Invert
        set M [solveGauss $XtWX $I_x]
        
        set beta [matmul $M [matmul $XtW $y]]
        
        ### -- Residuals & R-squared
        # 1) Generate list of diagonals of the hat matrix
        set H [matmul $X [matmul $M $XtW]]
        for {set i 0} {$i < $n} {incr i} {
            lappend h_ii [getelem $H $i $i]
        }

        set R [matmul $sqrtW [matmul [sub $I_y $H] $y]]
        set yhat [matmul $H $y]
        
        # 2) Generate list of residuals, sum of squared residuals, r-squared
        set sstot 0.0
        set ssreg 0.0
        # Note: Relying on representation of Vector as a list for y, yhat
        foreach yval $y wt $w yhatval $yhat {
            set sstot [expr {$sstot + $wt * ($yval - $ymean) * ($yval - $ymean)}]
            set ssreg [expr {$ssreg + $wt * ($yhatval - $ymean) * ($yhatval - $ymean)}]
        }
        set r2 [expr {double($ssreg)/$sstot}]
        set adjr2 [expr {1.0 - (1.0 - $r2) * ($n - 1)/($n - $k)}]
        set sumsqresid [dotproduct $R $R]
        set s2 [expr {double($sumsqresid) / double($n - $k)}]
        
        ### -- Confidence intervals for coefficients
        set tvalue [tstat [expr {$n - $k}]]
        for {set i 0} {$i < $k} {incr i} {
            set stderr [expr {sqrt($s2 * [getelem $M $i $i])}]
            set mid [lindex $beta $i]
            lappend stderrs $stderr
            lappend confinterval [list [expr {$mid - $tvalue * $stderr}] [expr {$mid + $tvalue * $stderr}]]
        }

        return [list $r2 $adjr2 $beta $stderrs $confinterval]
    }
    
    ########################################
    #
    # Ordinary (unweighted) Least Squares
    #
    ########################################
    # mvlinreg::ols [list y x's] [list y x's] ...
    # Returns:
    #   R-squared
    #   Adj R-squared
    #   coefficients of x's in fit
    #   standard errors of the coefficients
    #   95% confidence bounds for coefficients
    proc ols {args} {
        set newargs {}
        foreach pt $args {
            lappend newargs 1 $pt
        }
        return [eval wls $newargs]
    }
}
