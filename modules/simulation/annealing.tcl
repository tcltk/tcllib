# annealing.tcl --
#     Package implementing simulated annealing for minimizing functions
#     of one or more parameters
#
# Copyright (c) 2007 by Arjen Markus <arjenmarkus@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: annealing.tcl,v 1.1 2008/01/11 13:35:18 arjenmarkus Exp $
#------------------------------------------------------------------------------

package require Tcl 8.4
package require simulation::random

# ::simulation::annealing --
#     Create the namespace
#
namespace eval ::simulation::annealing {
}


# getOption --
#     Return the value of an option
#
# Arguments:
#     option         Name of the option (without -)
# Result:
#     The value or an error message if it does not exist
#
proc ::simulation::annealing::getOption {option} {
    variable ann_option

    if { [info exists ann_option(-$option)] } {
        return $ann_option(-$option)
    } else {
        return -code error "No such option: $option"
    }
}


# setOption --
#     Set the value of an option
#
# Arguments:
#     option         Name of the option (without -)
#     value          Value of the option
# Result:
#     None
#
proc ::simulation::annealing::setOption {option value} {
    variable ann_option

    set ann_option(-$option) $value
}


# hasOption --
#     Return whether the given option exists or not
#
# Arguments:
#     option         Name of the option (without -)
# Result:
#     1 if it exists, 0 if not
#
proc ::simulation::annealing::hasOption {option} {
    variable ann_option

    if { [info exists ann_option(-$option)] } {
        return 1
    } else {
        return 0
    }
}


# findMinimum --
#     Find the (global) minimum of a function using imulated annealing
#
# Arguments:
#     args            Option-value pairs:
#                     -parameters list - triples defining parameters and ranges
#                     -function expr   - expression defining the function
#                     -code body       - body of code to define the function
#                                        (takes precedence over -function)
#                                        should set the variable "result"
#                     -init code       - code to be run at start up
#                     -final code      - code to be run at the end
#                     -trials n        - number of trials before reducing the temperature
#                     -reduce factor   - reduce the temperature by this factor
#                                        (between 0 and 1)
#                     -initial-temp t  - initial temperature
#                     -scale s         - scale of the function (order of
#                                        magnitude of the values)
#                     -estimate-scale y/n - estimate the scale (only if -scale not present)
#                     Any others can be used via the getOption procedure
#                     in the body.
#
# Result:
#     Estimated minimum and the parameters involved:
#     function value param1 value param2 value ...
#
proc ::simulation::annealing::findMinimum {args} {
    variable ann_option

    #
    # Handle the options
    #
    set ann_option(-parameters)     {}
    set ann_option(-function)       {}
    set ann_option(-code)           {}
    set ann_option(-init)           {}
    set ann_option(-final)          {}
    set ann_option(-trials)         300
    set ann_option(-reduce)         0.95
    set ann_option(-initial-temp)   1.0
    set ann_option(-scale)          {}
    set ann_option(-estimate-scale) 0

    foreach {option value} $args {
        set ann_option($option) $value
    }

    if { $ann_option(-scale) == {} } {
        if { ! $ann_option(-estimate-scale) } {
            set ann_option(-scale) 1.0
        }
    }

    if { $ann_option(-code) != {} } {
        set ann_option(-function) {}
    }

    if { $ann_option(-code) == {} && $ann_option(-function) == {} } {
        return -code error "Neither code nor function given! Nothing to optimize"
    }
    if { $ann_option(-parameters) == {} } {
        return -code error "No parameters given! Nothing to optimize"
    }

    if { $ann_option(-function) != {} } {
        set ann_option(-code) "set result \[expr {$ann_option(-function)}\]"
    }

    #
    # Create the procedure
    #
    proc FindMin {} [string map \
        [list PARAMETERS $ann_option(-parameters) \
              CODE  $ann_option(-code) \
              INIT  $ann_option(-init) \
              FINAL $ann_option(-final)] {
        #
        # Give all parameters a value
        #
        foreach {_param_ _min_ _max_} {PARAMETERS} {
            set $_param_ $_min_
        }

        set _trials_ [getOption trials]
        set _temperature_ [getOption initial-temp]
        set _reduce_      [getOption reduce]
        set _noparams_    [expr {[llength {PARAMETERS}]/3}]

        INIT

        #
        # Estimate the scale
        #
        if { [getOption estimate-scale] == 1 } {
            set _sum_ 0.0
            for { set _trial_ 0 } { $_trial_ < $_trials_/3 } { incr _trial_ } {
                set _randp_ [expr {3*int($_noparams_*rand())}]
                set _param_ [lindex {PARAMETERS} $_randp_]
                set _min_   [lindex {PARAMETERS} [expr {$_randp_+1}]]
                set _max_   [lindex {PARAMETERS} [expr {$_randp_+2}]]
                set _old_param_ [set $_param_]
                set $_param_ [expr {$_min_ + rand()*($_max_-$_min_)}]

                CODE

                set _sum_  [expr {$_sum_ + abs($result)}]
            }
            set _scale_ [expr {3.0*$_sum_/$_trials_}]
        } else {
            set _scale_ [getOption scale]
        }

        #
        # Start the outer loop
        #
        set _changes_     1

        #
        # Get the initial value of the function
        #
        CODE
        set _old_result_ $result

        while {1} {
            for { set _trial_ 0 } { $_trial_ < $_trials_} { incr _trial_ } {
                set _randp_ [expr {3*int($_noparams_*rand())}]
                set _param_ [lindex {PARAMETERS} $_randp_]
                set _min_   [lindex {PARAMETERS} [expr {$_randp_+1}]]
                set _max_   [lindex {PARAMETERS} [expr {$_randp_+2}]]
                set _old_param_ [set $_param_]
                set $_param_ [expr {$_min_ + rand()*($_max_-$_min_)}]

                CODE

                #
                # Accept the new solution?
                #
                set _rand_  [expr {rand()}]
                if { log($_rand_) < -($result-$_old_result_)/($_scale_*$_temperature_) } {
                    incr _changes_
                    set _old_result_ $result
                   #puts "Accepted: $_changes_ - $x, $y"
                } else {
                    set $_param_ $_old_param_
                   #puts "Rejected: $_changes_ - $x, $y"
                }
            }

            set _temperature_ [expr {$_reduce_ * $_temperature_}]
            if { $_changes_ == 0 } {
                break
            } else {
                set _changes_ 0
            }
        }

        set result [list result $_old_result_] ;# Note: we need the last accepted result!
        foreach {_param_ _min_ _max_} {PARAMETERS} {
            lappend result $_param_ [set $_param_]
        }

        FINAL

        return $result
    }]

    #
    # Do the actual computation and return the result
    #
    return [FindMin]
}

# Announce the package
#
package provide simulation::annealing 0.1

# main --
#     Example
#
if { 0 } {
puts [::simulation::annealing::findMinimum \
    -trials 300 \
    -parameters {x -5.0 5.0 y -5.0 5.0} \
    -function {$x*$x+$y*$y+sin(10.0*$x)+4.0*cos(20.0*$y)}]

puts "Constrained:"
puts [::simulation::annealing::findMinimum \
    -trials 3000 \
    -reduce 0.98 \
    -parameters {x -5.0 5.0 y -5.0 5.0} \
    -code {
        if { hypot($x-5.0,$y-5.0) < 4.0 } {
            set result [expr {$x*$x+$y*$y+sin(10.0*$x)+4.0*cos(20.0*$y)}]
        } else {
           set result 1.0e100
        }
    }]
}
