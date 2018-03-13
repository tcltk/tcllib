#
# round number to significant digits
# according to 
# http://perfdynamics.blogspot.de/2010/04/significant-figures-in-r-and-rounding.html
# round number num to n significant digits
# works only in the range of double
# it is published under the same licence as Tcl
# (c) J. Heidemeier 2014
#
namespace eval ::siground {}
proc ::siground::signif {num n {decimalPoint .}} {
set orig $num
# arguments:
# num: number to be rounded (integer, real or exponential format)
# n: number of significant digits (positive integer)
# decimalPoint: decimal separator character for the output (default .)
# 
# reasonable figure for significant digits ?
    if {!([string is integer $n] && $n > 0)} \
        {error  "number of significant digits $n is not a positive integer"}
#
# ensure that num is numeric
# and split into sign, integer, decimal and exponent part
#
if {[regexp {^([+,-]?)([0-9]+)(\.?[0-9]*)?([eE][+-]?[0-9]+)?$} $num -> s i d e]} {
# i must contain alt least one digit
if {![string length i]} "error wrong format $num, no digit in Integerpart "
#
# type of number
# 
    set typ ""    
    if {[string length $e]} {set typ e}
    if {[string length $d]} {
        if {$typ ne {e}} {set typ d}
    } else {
        if {$typ ne {e}} {
                set typ i
#
#
#
        } else {
# reformat iexx to i.0exx bringen
            set d {.0}
       }
    }
# remove leading 0, if digits 1-9 in i-part
# or collapse several 0 to 0
#
    if {[string length $i] > 1} {
        regexp  {^(0*)([1-9][0-9]*)$} $i -> NULL DIG
        if {[string length $DIG]} {
            set i $DIG
        } else {
            set i 0 ;# collapse to one 0
        }
    }
#        
# build teststring for rounding process
#
set tstring $i
            
set decpos [expr {[string length $i] -1}]
# skip decimalpoint and append decimalpart
if {[string length $d]} {
       append tstring [string range $d 1 end]
} 
# enough digits for the rounding process       
    set ndigs [string length $tstring]
    if {$ndigs < $n} {
        return $orig
    #    error "more significant digits $n requested than available $ndigs"
    }

# x is the last significant digit
# y and z are the following 2 digits, if y or z are blank
# zeros are appended     
    set x [string index $tstring $n-1]
        if  {$ndigs == $n} {
            set y 0
        } else {
        set y [string index $tstring $n]
    }
    if {$ndigs > $n} {
        set z [string index $tstring $n+1]
    } else {
        set z 0
    }
# the actual test; pad0 pads zeros for the integerpart
    if {$y < 5} {        
        set rstring "[string range $tstring 0 $n-1][pad0 $decpos $n]"
    } elseif {$y > 5} {
         incr x
            set rstring "[string range $tstring 0 $n-2]$x[pad0 $decpos $n]"
    } else {
# y == 5; test for parity jitter
        if {$z >= 1} {
                set rstring "[string range $tstring 0 $n-1][pad0 $decpos $n]"
        } else {
            if {[isOdd $x]} {
                incr x
            }
                set rstring "[string range $tstring 0 $n-2]$x[pad0 $decpos $n]"
        }
    }
} else {
 error "number to round \"$num\" is not numeric"
}
# reformatting the output    
    switch -exact -- $typ {
        i {set result "$s$rstring"}
        d {
            set decfrac [string range $rstring $decpos+1 end]
            if {![string length $decfrac]} {
                set result "$s$rstring"
            } else {
                set result "$s[string range $rstring 0 $decpos]$decimalPoint$decfrac"
            }
        }
        e {
            set result "$s[string range $rstring 0 $decpos]$decimalPoint[string range $rstring $decpos+1 end]$e"
        }
    }
return  $result
}
#
# pad integer part with 0 if necessary
# arguments
# decpos:  index of the last digit before the decimal point
# n:  number of significant digits
#
proc ::siground::pad0 {decpos n} {

    set v {}
    incr decpos
    set x [expr {$decpos - $n}]
    
    if {$x} {
        set v [string repeat 0 $x] 
    }
    return $v
 }

proc ::siground::isOdd n {
    try {
        expr {$n & 1}
    } trap {ARITH DOMAIN} {message options} {
        return -options $options -errorinfo "$n is not an integer"
    }
}
