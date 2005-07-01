########################################################################
# BigFloat for Tcl
# Copyright (C) 2003-2004  ARNOLD Stephane
#
# BIGFLOAT LICENSE TERMS
#
# This software is copyrighted by Stephane ARNOLD, (stephanearnold <at> yahoo.fr).
# The following terms apply to all files associated
# with the software unless explicitly disclaimed in individual files.
#
# The authors hereby grant permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
#
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
#
# GOVERNMENT USE: If you are acquiring this software on behalf of the
# U.S. government, the Government shall have only "Restricted Rights"
# in the software and related documentation as defined in the Federal
# Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
# are acquiring the software on behalf of the Department of Defense, the
# software shall be classified as "Commercial Computer Software" and the
# Government shall have only "Restricted Rights" as defined in Clause
# 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
# authors grant the U.S. Government and others acting in its behalf
# permission to use and distribute the software in accordance with the
# terms specified in this license.
#
########################################################################

package require math::bignum

# this line helps when I want to source this file again and again
catch {namespace delete ::math::bigfloat}

# private namespace
# this software works only with Tcl v8.4 and higher
# it is using the package math::bignum
namespace eval ::math::bigfloat {
    # cached constants
    # ln(2) with arbitrary precision
    variable Log2
    # Pi with arb. precision
    variable Pi
    variable _pi0
    # ten
    variable ten
    set ten [::math::bignum::fromstr 10]
    variable five
    set five [::math::bignum::fromstr 5]
    variable one
    set one [::math::bignum::fromstr 1]
}




################################################################################
# procedures that handle floating-point numbers
# they are sorted by name (after eventually removing the underscores)
# BigFloats are internally represented as a list :
# {"F" Mantissa Exponent Delta} where "F" is a character which determins
# the datatype, Mantissa and Delta are two Big integers and Exponent a raw integer.
#
# The BigFloat value equals to (Mantissa +/- Delta)*10^Exponent
# When calling fromstr, the Delta parameter is always set to 1.
# When you perform some computations, the Delta parameter (uncertainty) may increase.
# It is kept at 2 decimal digits at most with the normalize procedure.
# Retrieving the parameters of a BigFloat is often done with that command :
# foreach {dummy int exp delta} $bigfloat {break}
# (dummy is not used, it is just used to get the "F" marker).
# The isInt, isFloat, checkNumber and checkFloat procedures are used
# to check data types
################################################################################


################################################################################
# returns the absolute value
################################################################################
proc ::math::bigfloat::abs {number} {
    checkNumber number
    if {[isInt $number]} {
        # set sign to positive for a BigInt
        return [::math::bignum::abs $number]
    }
    # set sign to positive for a BigFloat
    set mantissa [::math::bignum::abs [lindex $number 1]]
    lset number 1 $mantissa
    return $number
}


################################################################################
# arccosinus of a BigFloat
################################################################################
proc ::math::bigfloat::acos {x} {
    # handy proc for checking datatype
    checkFloat x
    foreach {dummy entier exp delta} $x {break}
    set precision [expr {($exp<0)?(-$exp):1}]
    # acos(0.0)=Pi/2
    set piOverTwo [floatRShift [pi $precision]]
    if {[iszero $x]} {
        return $piOverTwo
    }
    # acos(-x)= Pi/2 + asin(x)
    if {[::math::bignum::sign $entier]} {
        return [add $piOverTwo [asin [abs $x]]]
    }
    # we always use _asin to compute the result
    # but as it is a Taylor development, the value given to [_asin]
    # has to be a bit smaller than 1 ; by using that trick : acos(x)=asin(sqrt(1-x^2))
    # we can limit the entry of the Taylor development below 1/sqrt(2)
    if {[compare $x [fromstr 0.7071]]>0} {
        # x > sqrt(2)/2 : trying to make _asin converge quickly 
        # creating 0 and 1 with the same precision as the entry
        set zero [list F [fromstr 0] -$precision $::math::bigfloat::one]
        set one [list F [::math::bignum::lshift $::math::bigfloat::one $precision] \
                -$precision $::math::bigfloat::one]
        # acos(1.0)=0.0
        if {[equal $one $x]} {
            return $zero
        }
        if {[compare $one $x]<0} {
            # the behavior assumed because acos(x) is not defined
            # when |x|>1
            error "acos on a number greater than 1"
        }
        # acos(x) = asin(sqrt(1 - x^2))
        # since 1 - cos(x)^2 = sin(x)^2
        # x> sqrt(2)/2 so x^2 > 1/2 so 1-x^2<1/2
        set x [sqrt [sub $one [mul $x $x]]]
        # the parameter named x is smaller than sqrt(2)/2
        return [_asin $x]
    }
    # acos(x) = Pi/2 - asin(x)
    # x<sqrt(2)/2 here too
    return [sub $piOverTwo [_asin $x]]
}


################################################################################
# returns A + B
################################################################################
proc ::math::bigfloat::add {a b} {
    checkNumber a b
    if {[isInt $a]} {
        if {[isInt $b]} {
            # intAdd adds two BigInts
            return [::math::bignum::add $a $b]
        }
        # adds the BigInt a to the BigFloat b
        return [addInt2Float $b $a]
    }
    if {[isInt $b]} {
        # ... and vice-versa
        return [addInt2Float $a $b]
    }
    # retrieving parameters from A and B
    foreach {dummy integerA expA deltaA} $a {break}
    foreach {dummy integerB expB deltaB} $b {break}
    # when a number has more precision than the other (for example,
    # when A=0.001 and B=2.01, we need to put the other at the decimal level
    # that is why we shift left the number which has the greater exponent
    if {$expA>$expB} {
        set diff [expr {$expA-$expB}]
        set integerA [::math::bignum::lshift $integerA $diff]
        set deltaA [::math::bignum::lshift $deltaA $diff]
        set integerA [::math::bignum::add $integerA $integerB]
        set deltaA [::math::bignum::add $deltaA $deltaB]
        return [normalize [list F $integerA $expB $deltaA]]
    } elseif {$expA==$expB} {
        # nothing to shift left
        return [normalize [list F [::math::bignum::add $integerA $integerB] \
                $expA [::math::bignum::add $deltaA $deltaB]]]
    } else {
        set diff [expr {$expB-$expA}]
        set integerB [::math::bignum::lshift $integerB $diff]
        set deltaB [::math::bignum::lshift $deltaB $diff]
        set integerB [::math::bignum::add $integerA $integerB]
        set deltaB [::math::bignum::add $deltaB $deltaA]
        return [normalize [list F $integerB $expA $deltaB]]
    }
}

################################################################################
# returns the sum A(BigFloat) + B(BigInt)
# the greatest advantage of this method is that the uncertainty
# of the result remains unchanged, in respect to the entry's uncertainty (deltaA)
################################################################################
proc ::math::bigfloat::addInt2Float {a b} {
    # type checking
    checkFloat a
    if {![isInt $b]} {
        error "'$b' is not a BigInt"
    }
    # retrieving data from $a
    foreach {dummy integerA expA deltaA} $a {break}
    # to add an int to a BigFloat,...
    if {$expA>0} {
        # we have to put the integer integerA
        # to the level of zero exponent : 1e8 --> 100000000e0
        set shift $expA
        set integerA [::math::bignum::lshift $integerA $shift]
        set deltaA [::math::bignum::lshift $deltaA $shift]
        set integerA [::math::bignum::add $integerA $b]
        # we have to normalize, because we have shifted the mantissa
        # and the uncertainty left
        return [normalize [list F $integerA 0 $deltaA]]
    } elseif {$expA==0} {
        # integerA is already at integer level : float=(integerA)e0
        return [normalize [list F [::math::bignum::add $integerA $b] \
                0 $deltaA]]
    } else {
        # here we have something like 234e-2 + 3
        # we have to shift the integer left by the exponent |$expA|
        set b [::math::bignum::lshift $b [expr {-$expA}]]
        set integerA [::math::bignum::add $integerA $b]
        return [normalize [list F $integerA $expA $deltaA]]
    }
}


################################################################################
# arcsinus of a BigFloat
################################################################################
proc ::math::bigfloat::asin {x} {
    # type checking
    checkFloat x
    foreach {dummy entier exp delta} $x {break}
    if {$exp>-1} {
        error "not enough precision on input (asin)"
    }
    set precision [expr {-$exp}]
    # when x=0, return 0 at the same precision as the input was
    if {[iszero $x]} {
        return [list F [fromstr 0] -$precision $::math::bigfloat::one]
    }
    # asin(-x)=-asin(x)
    if {[::math::bignum::sign $entier]} {
        return [opp [asin [abs $x]]]
    }
    set piOverTwo [floatRShift [pi $precision]]
    # now a little trick : asin(x)=Pi/2-asin(sqrt(1-x^2))
    # so we can limit the entry of the Taylor development
    # to 1/sqrt(2)~0.7071
    # the comparison is : if x>0.7071 then ...
    if {[compare $x [fromstr 0.7071]]>0} {
        set one [list F [::math::bignum::lshift $::math::bigfloat::one $precision] \
                -$precision $::math::bigfloat::one]
        # asin(1)=Pi/2 (with the same precision as the entry has)
        if {[equal $one $x]} {
            return $piOverTwo
        }
        if {[compare $x $one]>0} {
            error "asin on a number greater than 1"
        }
        set x [sqrt [sub $one [mul $x $x]]]
        return [sub $piOverTwo [_asin $x]]
    }
    return [normalize [_asin $x]]
}

################################################################################
# _asin : arcsinus of numbers between 0 and +1
################################################################################
proc ::math::bigfloat::_asin {x} {
    # Taylor development
    # asin(x)=x + 1/2 x^3/3 + 3/2.4 x^5/5 + 3.5/2.4.6 x^7/7 + ...
    foreach {dummy mantissa exp delta} $x {break}
    set precision [expr {-$exp}]
    if {$precision+1<[::math::bignum::bits $mantissa]} {
        error "sinus greater than 1"
    }
    # precision is the number of after-dot digits
    set result $mantissa
    set delta_final $delta
    # resultat is the final result, and delta_final
    # will contain the uncertainty of the result
    # square is the square of the mantissa
    set square [intMulShift $mantissa $mantissa $precision]
    # dt is the uncertainty
    set dt [intMulShift $mantissa $delta [expr {$precision-1}]]
    # these three are required to compute the fractions implicated into
    # the development (of Taylor, see former)
    set num [fromstr 1]
    # two will be used into the loop
    set two [fromstr 2]
    set i [fromstr 3]
    set denom $two
    set delta [::math::bignum::add [::math::bignum::mul $delta $square] \
            [::math::bignum::mul $dt $mantissa]]
            set delta [::math::bignum::rshift [::math::bignum::div \
                    [::math::bignum::mul $delta $num] $denom] $precision]
    set mantissa [intMulShift $mantissa $square $precision]
    set mantissa [::math::bignum::div $mantissa $denom]
    set mantissa_temp [::math::bignum::div $mantissa $i]
    set delta_temp [::math::bignum::div $delta $i]
    while {[::math::bignum::cmp $mantissa_temp $delta_temp]>0} {
        set result [::math::bignum::add $result $mantissa_temp]
        set delta_final [::math::bignum::add $delta_final $delta_temp]
        # here we have $two instead of [fromstr 2] (optimization)
        set num [::math::bignum::add $num $two]
        set i [::math::bignum::add $i $two]
        set denom [::math::bignum::add $denom $two]
        set delta [::math::bignum::add [::math::bignum::mul $delta $square] \
                [::math::bignum::mul $dt $mantissa]]
                set delta [::math::bignum::rshift [::math::bignum::div \
                        [::math::bignum::mul $delta $num] $denom] $precision]
        set mantissa [intMulShift $mantissa $square $precision]
        set mantissa [::math::bignum::div [::math::bignum::mul $mantissa $num] $denom]
        set mantissa_temp [::math::bignum::div $mantissa $i]
        set delta_temp [::math::bignum::div $delta $i]
    }
    return [list F $result $exp $delta_final]
}

################################################################################
# arctangent : returns atan(x)
################################################################################
proc ::math::bigfloat::atan {x} {
    checkFloat x
    variable one
    foreach {dummy mantissa exp delta} $x {break}
    if {$exp>=0} {
        error "not enough precision to compute atan"
    }
    set precision [expr {-$exp}]
    # atan(0)=0
    if {[iszero $x]} {
        return [list F [fromstr 0] -$precision $one]
    }
    # atan(-x)=-atan(x)
    if {[::math::bignum::sign $mantissa]} {
        return [opp [atan [abs $x]]]
    }
    # now x is strictly positive
    # at this moment, we are trying to limit |x| to a fair acceptable number
    # to ensure that Taylor development will converge quickly
    set float1 [list F [::math::bignum::lshift $one $precision] -$precision $one]
    if {[compare $float1 $x]<0} {
        # compare x to 2.4142
        if {[compare $x [fromstr 2.4142]]<0} {
            # atan(x)=Pi/4 + atan((x-1)/(x+1))
            # as 1<x<2.4142 : (x-1)/(x+1)=1-2/(x+1) belongs to
            # the range :  ]0,1-2/3.414[
            # that equals  ]0,0.414[
            set pi_sur_quatre [div [pi $precision] [fromstr 4]]
            return [add $pi_sur_quatre [atan \
                    [div [sub $x $float1] [add $x $float1]]]]
        }
        # atan(x)=Pi/2-atan(1/x)
        # 1/x < 1/2.414 so the argument is lower than 0.414
        set pi_sur_deux [div [pi $precision] [fromstr 2]]
        return [sub $pi_sur_deux [atan [div $float1 $x]]]
    }
    if {[compare $x [fromstr 0.4142]]>0} {
        # atan(x)=Pi/4 + atan((x-1)/(x+1))
        # x>0.420 so (x-1)/(x+1)=1 - 2/(x+1) > 1-2/1.414
        #                                    > -0.414
        # x<1 so (x-1)/(x+1)<0
        set pi_sur_quatre [div [pi $precision] [fromstr 4]]
        return [add $pi_sur_quatre [atan \
                [div [sub $x $float1] [add $x $float1]]]]
    }
    # precision increment : to have less uncertainty
    # we add a little more precision so that the result would be more accurate
    # Taylor development : x - x^3/3 + x^5/5 - ... + (-1)^(n+1)*x^(2n-1)/(2n-1)
    # when we have n steps in Taylor development : the nth term is :
    # x^(2n-1)/(2n-1)
    # and the loss of precision is of 2n (n sums and n divisions)
    # this command is called with x<sqrt(2)-1
    # if we add an increment to the precision, say n:
    # (sqrt(2)-1)^(2n-1)/(2n-1) has to be lower than 2^(-precision-n-1)
    # (2n-1)*log(sqrt(2)-1)-log(2n-1)<-(precision+n+1)*log(2)
    # 2n(log(sqrt(2)-1)-log(sqrt(2)))<-(precision-1)*log(2)+log(2n-1)+log(sqrt(2)-1)
    # 2n*log(1-1/sqrt(2))<-(precision-1)*log(2)+log(2n-1)+log(2)/2
    # 2n/sqrt(2)>(precision-3/2)*log(2)-log(2n-1)
    # hence log(2n-1)<2n-1
    # n*sqrt(2)>(precision-1.5)*log(2)+1-2n
    # n*(sqrt(2)+2)>(precision-1.5)*log(2)+1
    set n [expr {int((log(2)*($precision-1.5)+1)/(sqrt(2)+2)+1)}]
    incr precision $n
    set mantissa [::math::bignum::lshift $mantissa $n]
    set delta [::math::bignum::lshift $delta $n]
    # end of adding precision increment
    # now computing Taylor development :
    # atan(x)=x - x^3/3 + x^5/5 - x^7/7 ... + (-1)^n*x^(2n+1)/(2n+1)
    set result $mantissa
    set delta_fin $delta
    # we store the square of the integer (mantissa)
    set delta_square [::math::bignum::lshift $delta 1]
    set square [intMulShift $mantissa $mantissa $precision]
    # the (2n+1) divider
    set divider [fromstr 3]
    set two [fromstr 2]
    # computing precisely the uncertainty
    set delta [intIncr [::math::bignum::rshift [::math::bignum::add \
            [::math::bignum::mul $delta_square $mantissa] \
            [::math::bignum::mul $delta $square]] $precision]]
    # temp contains (-1)^n*x^(2n+1)
    set temp [opp [intMulShift $mantissa $square $precision]]
    set t [::math::bignum::div $temp $divider]
    set dt [intIncr [::math::bignum::div $delta $divider]]
    while {![::math::bignum::iszero $t]} {
        set result [::math::bignum::add $result $t]
        set delta_fin [::math::bignum::add $delta_fin $dt]
        set divider [::math::bignum::add $divider $two]
        set delta [intIncr [::math::bignum::rshift [::math::bignum::add \
                [::math::bignum::mul $delta_square [abs $temp]] \
                [::math::bignum::mul $delta $square]] $precision]]
        set temp [opp [intMulShift $temp $square $precision]]
        set t [::math::bignum::div $temp $divider]
        set dt [intIncr [::math::bignum::div $delta $divider]]
    }
    # we have to normalize because the uncertainty might be greater than 99
    # moreover it is the most often case
    return [normalize [list F $result [expr {$exp-$n}] $delta_fin]]
}

################################################################################
# compute atan(1/integer) at a given precision
# this proc is only used to compute Pi
# it is using the same Taylor development as [atan]
################################################################################
proc ::math::bigfloat::_atanfract {integer precision} {
    # Taylor development : x - x^3/3 + x^5/5 - ... + (-1)^(n+1)*x^(2n-1)/(2n-1)
    # when we have n steps in Taylor development : the nth term is :
    # 1/denom^(2n+1)/(2n+1)
    # and the loss of precision is of 2n (n sums and n divisions)
    # this command is called with integer>=5
    # if we add an increment to the precision, say n:
    # (1/5)^(2n-1)/(2n-1) has to be lower than (1/2)^(precision+n-1)
    # (2n-1)*log(5)+log(2n-1)>(precision+n-1)*log(2)
    # n(2log(5)-log(2))>(precision-1)*log(2)-log(2n-1)+log(5)
    # -log(2n-1)>-(2n-1)
    # n(2log(5)-log(2)+2)>(precision-1)*log(2)+1+log(5)
    set n [expr {int((($precision-1)*log(2)+1+log(5))/(2*log(5)-log(2)+2)+1)}]
    incr precision $n
    set one [::math::bignum::lshift $::math::bigfloat::one $precision]
    # first term of the development : 1/integer
    set a [::math::bignum::div $one $integer]
    # 's' will contain the result
    set s $a
    # integer^2
    set square [::math::bignum::mul $integer $integer]
    set denom [fromstr 3]
    set denomIncr [fromstr 2]
    # $t is (-1)^n*x^(2n+1)
    set t [opp [::math::bignum::div $a $square]]
    set u [::math::bignum::div $t $denom]
    # we break the loop when the current term of the development is null
    while {![::math::bignum::iszero $u]} {
        set s [::math::bignum::add $s $u]
        # denominator= (2n+1)
        set denom [::math::bignum::add $denom $denomIncr]
        set t [opp [::math::bignum::div $t $square]]
        set u [::math::bignum::div $t $denom]
    }
    # go back to the initial precision
    return [::math::bignum::rshift $s $n]
}

################################################################################
# returns the integer part of a BigFloat, as a BigInt
# the result is the same one you would have
# if you had called [expr {ceil($x)}]
################################################################################
proc ::math::bigfloat::ceil {number} {
    checkFloat number
    set number [normalize $number]
    if {[iszero $number]} {
        # returns the BigInt 0
        return [::math::bignum::fromstr 0]
    }
    foreach {dummy integer exp delta} $number {break}
    if {$exp>=0} {
        error "not enough precision to perform rounding (ceil)"
    }
    # saving the sign ...
    set sign [::math::bignum::sign $integer]
    set integer [abs $integer]
    # integer part
    set try [::math::bignum::rshift $integer [expr {-$exp}]]
    if {$sign} {
        return [opp $try]
    }
    # fractional part
    if {![equal [::math::bignum::lshift $try [expr {-$exp}]] $integer]} {
        return [::math::bignum::add $try $::math::bigfloat::one]
    }
    return $try
}


################################################################################
# checks each variable to be a BigFloat
# arguments : each argument is the name of a variable to be checked
################################################################################
proc ::math::bigfloat::checkFloat {args} {
    foreach x $args {
        upvar $x n
        if {![isFloat $n]} {
            error "BigFloat expected : received '$n'"
        }
    }
}

################################################################################
# checks if each number is either a BigFloat or a BigInt
# arguments : each argument is the name of a variable to be checked
################################################################################
proc ::math::bigfloat::checkNumber {args} {
    foreach i $args {
        upvar $i x
        if {![isInt $x] && ![isFloat $x]} {
            error "'$x' is not a number"
        }
    }
}


################################################################################
# returns 0 if A and B are equal, else returns 1 or -1
# accordingly to the sign of (A - B)
################################################################################
proc ::math::bigfloat::compare {a b} {
    if {[isInt $a] && [isInt $b]} {
        return [::math::bignum::cmp $a $b]
    }
    checkFloat a b
    if {[equal $a $b]} {return 0}
    return [expr {([::math::bignum::sign [lindex [sub $a $b] 1]])?-1:1}]
}




################################################################################
# gets cos(x)
# throws an error if there is not enough precision on the input
################################################################################
proc ::math::bigfloat::cos {x} {
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    if {$exp>-2} {
        error "not enough precision on floating-point number"
    }
    set precision [expr {-$exp}]
    # cos(2kPi+x)=cos(x)
    foreach {n integer} [divPiQuarter $integer $precision] {break}
    # now integer>=0 and <Pi/2
    set d [expr {[tostr $n]%4}]
    # add trigonometric circle turns number to delta
    set delta [::math::bignum::add [abs $n] $delta]
    set signe 0
    # cos(Pi-x)=-cos(x)
    # cos(-x)=cos(x)
    # cos(Pi/2-x)=sin(x)
    switch -- $d {
        1 {set signe 1;set l [_sin2 $integer $precision $delta]}
        2 {set signe 1;set l [_cos2 $integer $precision $delta]}
        0 {set l [_cos2 $integer $precision $delta]}
        3 {set l [_sin2 $integer $precision $delta]}
        default {error "internal error"}
    }
    # precision -> exp (multiplied by -1)
    lset l 1 [expr {-([lindex $l 1])}]
    # set the sign
    set integer [lindex $l 0]
    ::math::bignum::setsign integer $signe
    lset l 0 $integer
    return [normalize [linsert $l 0 F]]
}

################################################################################
# compute cos(x) where 0<=x<Pi/2
# returns : a list formed with :
# 1. the mantissa
# 2. the precision (opposite of the exponent)
# 3. the uncertainty (doubt range)
################################################################################
proc ::math::bigfloat::_cos2 {x precision delta} {
    set pi [_pi $precision]
    set pis4 [::math::bignum::rshift $pi 2]
    set pis2 [::math::bignum::rshift $pi 1]
    if {[::math::bignum::cmp $x $pis4]>=0} {
        # cos(Pi/2-x)=sin(x)
        set x [::math::bignum::sub $pis2 $x]
        set delta [intIncr $delta]
        return [_sin $x $precision $delta]
    }
    return [_cos $x $precision $delta]
}

################################################################################
# compute cos(x) where 0<=x<Pi/4
# returns : a list formed with :
# 1. the mantissa
# 2. the precision (opposite of the exponent)
# 3. the uncertainty (doubt range)
################################################################################
proc ::math::bigfloat::_cos {x precision delta} {
    variable one
    set float1 [::math::bignum::lshift $::math::bigfloat::one $precision]
    # Taylor development follows :
    # cos(x)=1-x^2/2 + x^4/4! ... + (-1)^(2n)*x^(2n)/2n!
    set s $float1
    # 'd' is the uncertainty on x^2
    set d [::math::bignum::mul $x [::math::bignum::lshift $delta 1]]
    set d [::math::bignum::rshift $d $precision]
    # x=x^2 (because in this Taylor development, there are only even powers of x)
    set x [intMulShift $x $x $precision]
    set denom1 $one
    set two [fromstr 2]
    set denom2 $two
    set t [opp [::math::bignum::rshift $x 1]]
    set delta [fromstr 0]
    set dt $d
    while {![::math::bignum::iszero $t]} {
        set s [::math::bignum::add $s $t]
        set delta [::math::bignum::add $delta $dt]
        set denom1 [::math::bignum::add $denom1 $two]
        set denom2 [::math::bignum::add $denom2 $two]
        set dt [::math::bignum::rshift [::math::bignum::add [::math::bignum::mul $x $dt]\
                [::math::bignum::mul $t $d]] $precision]
        set t [intMulShift $x $t $precision]
        set t [opp [::math::bignum::div $t [::math::bignum::mul $denom1 $denom2]]]
    }
    return [list $s $precision $delta]
}

################################################################################
# cotangent : the trivial algorithm is used
################################################################################
proc ::math::bigfloat::cotan {x} {
    return [::math::bigfloat::div [::math::bigfloat::cos $x] [::math::bigfloat::sin $x]]
}

################################################################################
# converts angles from degrees to radians
################################################################################
proc ::math::bigfloat::deg2rad {x} {
    checkFloat x
    set xLen [expr {-[lindex $x 2]}]
    if {$xLen<1} {
        error "number too loose to convert to radians"
    }
    set pi [pi $xLen 1]
    return [div [mul $x $pi] [fromstr 180]]
}



################################################################################
# private proc to get : x modulo Pi/2
# and the quotient (x divided by Pi/2)
# used by cos , sin & others
################################################################################
proc ::math::bigfloat::divPiQuarter {integer precision} {
    incr precision
    set integer [::math::bignum::lshift $integer 1]
    set dpi [_pi [expr {1+$precision}]]
    # modulo 2Pi
    foreach {n integer} [::math::bignum::divqr $integer $dpi] {break}
    # fin modulo 2Pi
    set pi [_pi $precision]
    foreach {n integer} [::math::bignum::divqr $integer $pi] {break}
    # now divide by Pi/2
    # multiply n by 2
    set n [::math::bignum::lshift $n 1]
    # pis2=pi/2
    set pis2 [::math::bignum::rshift $pi 1]
    foreach {m integer} [::math::bignum::divqr $integer $pis2] {break}
    return [list [::math::bignum::add $n $m] [::math::bignum::rshift $integer 1]]
}


################################################################################
# divide A by B and returns the result
# throw error : divide by zero
################################################################################
proc ::math::bigfloat::div {a b} {
    variable one
    checkNumber a b
    # dispatch to an appropriate procedure 
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [::math::bignum::div $a $b]
        }
        error "trying to divide a BigInt by a BigFloat"
    }
    if {[isInt $b]} {return [divFloatByInt $a $b]}
    foreach {dummy integerA expA deltaA} $a {break}
    foreach {dummy integerB expB deltaB} $b {break}
    # computes the limits of the doubt (or uncertainty) interval
    set BMin [::math::bignum::sub $integerB $deltaB]
    set BMax [::math::bignum::add $integerB $deltaB]
    if {[::math::bignum::cmp $BMin $BMax]>0} {
        # swap BMin and BMax
        set temp $BMin
        set BMin $BMax
        set BMax $temp
    }
    # multiply by zero gives zero
    if {[iszero $integerA]} {
        # why not return any number or the integer 0 ?
        # because there is an exponent that might be different between two BigFloats
        # 0.00 --> exp = -2, 0.000000 -> exp = -6
        return $a 
    }
    # test of the division by zero
    if {[::math::bignum::sign $BMin]+[::math::bignum::sign $BMax]==1 || \
                [iszero $BMin] || [iszero $BMax]} {
        error "divide by zero"
    }
    # shift A because we need accuracy
    set l [math::bignum::bits $integerB]
    set integerA [::math::bignum::lshift $integerA $l]
    set deltaA [::math::bignum::lshift $deltaA $l]
    set exp [expr {$expA-$l-$expB}]
    # relative uncertainties (dX/X) are added
    # to give the relative uncertainty of the result
    # i.e. 3% on A + 2% on B --> 5% on the quotient
    # d(A/B)/(A/B)=dA/A + dB/B
    # Q=A/B
    # dQ=dA/B + dB*A/B*B
    # dQ is "delta"
    set delta [::math::bignum::div [::math::bignum::mul $deltaB \
            [abs $integerA]] [abs $integerB]]
    set delta [::math::bignum::div [::math::bignum::add\
            [::math::bignum::add $delta $one]\
            $deltaA] [abs $integerB]]
    set quotient [::math::bignum::div $integerA $integerB]
    if {[::math::bignum::sign $integerB]+[::math::bignum::sign $integerA]==1} {
        set quotient [::math::bignum::sub $quotient $one]
    }
    return [normalize [list F $quotient $exp [::math::bignum::add $delta\
            $one]]]
}




################################################################################
# divide a BigFloat A by a BigInt B
# throw error : divide by zero
################################################################################
proc ::math::bigfloat::divFloatByInt {a b} {
    variable one
    # type check
    checkFloat a
    if {![isInt $b]} {
        error "'$b' is not a BigInt"
    }
    foreach {dummy integer exp delta} $a {break}
    # zero divider test
    if {[iszero $b]} {
        error "divide by zero"
    }
    # shift left for accuracy ; see other comments in [div] procedure
    set l [::math::bignum::bits $b]
    set integer [::math::bignum::lshift $integer $l]
    set delta [::math::bignum::lshift $delta $l]
    incr exp -$l
    set integer [::math::bignum::div $integer $b]
    # the uncertainty is always evaluated to the ceil value
    # and as an absolute value
    set delta [::math::bignum::add [::math::bignum::div $delta [abs $b]] $one]
    return [normalize [list F $integer $exp $delta]]
}





################################################################################
# returns 1 if A and B are equal, 0 otherwise
# IN : a, b (BigFloats)
################################################################################
proc ::math::bigfloat::equal {a b} {
    if {[isInt $a] && [isInt $b]} {
        return [expr {[::math::bignum::cmp $a $b]==0}]
    }
    checkFloat a b
    foreach {dummy aint aexp adelta} $a {break}
    foreach {dummy bint bexp bdelta} $b {break}
    # set all BigInt to the same level (exponent)
    # with lshift
    set diff [expr {$aexp-$bexp}]
    if {$diff<0} {
        set diff [expr {-$diff}]
        set bint [::math::bignum::lshift $bint $diff]
        set bdelta [::math::bignum::lshift $bdelta $diff]
    } elseif {$diff>0} {
        set aint [::math::bignum::lshift $aint $diff]
        set adelta [::math::bignum::lshift $adelta $diff]
    }
    # compute limits of the number's doubt range
    set asupInt [::math::bignum::add $aint $adelta]
    set ainfInt [::math::bignum::sub $aint $adelta]
    set bsupInt [::math::bignum::add $bint $bdelta]
    set binfInt [::math::bignum::sub $bint $bdelta]
    # A & B are equal
    # if their doubt ranges overlap themselves
    if {[::math::bignum::cmp $bint $aint]==0} {
        return 1
    }
    if {[::math::bignum::cmp $bint $aint]>0} {
        set r [expr {[::math::bignum::cmp $asupInt $binfInt]>=0}]
    } else {
        set r [expr {[::math::bignum::cmp $bsupInt $ainfInt]>=0}]
    }
    return $r
}

################################################################################
# returns exp(X) where X is a BigFloat
################################################################################
proc ::math::bigfloat::exp {x} {
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    if {$exp>=0} {
        # shift till exp<0 with respect to the internal representation
        # of the number
        incr exp
        set integer [::math::bignum::lshift $integer $exp]
        set delta [::math::bignum::lshift $delta $exp]
        set exp -1
    }
    set precision [expr {-$exp}]
    # add 8 bits of precision for safety
    incr precision 8
    set integer [::math::bignum::lshift $integer 8]
    set delta [::math::bignum::lshift $delta 8]
    set Log2 [_log2 $precision]
    foreach {new_exp integer} [::math::bignum::divqr $integer $Log2] {break}
    # new_exp = integer part of x/log(2)
    # integer = remainder
    # exp(K.log(2)+r)=2^K.exp(r)
    # so we just have to compute exp(r), r is small so
    # the Taylor development will converge quickly
    set delta [::math::bignum::add $delta $new_exp]
    foreach {integer delta} [_exp $integer $precision $delta] {break}
    set delta [::math::bignum::rshift $delta 8]
    incr precision -8
    # multiply by 2^K , and take care of the sign
    # example : X=-6.log(2)+0.01
    # exp(X)=exp(0.01)*2^-6
    if {![::math::bignum::iszero [::math::bignum::rshift [abs $new_exp] 30]]} {
        error "floating-point overflow due to exp"
    }
    set new_exp [tostr $new_exp]
    set exp [expr {$new_exp-$precision}]
    set delta [intIncr $delta]
    return [normalize [list F [::math::bignum::rshift $integer 8] $exp $delta]]
}


################################################################################
# private procedure to compute exponentials
# using Taylor development of exp(x) :
# exp(x)=1+ x + x^2/2 + x^3/3! +...+x^n/n!
# input : integer (the mantissa)
#         precision (the number of decimals)
#         delta (the doubt limit, or uncertainty)
# returns a list : 1. the mantissa of the result
#                  2. the doubt limit, or uncertainty
################################################################################
proc ::math::bigfloat::_exp {integer precision delta} {
    variable one
    set oneShifted [::math::bignum::lshift $one $precision]
    if {[::math::bignum::iszero $integer]} {
        # exp(0)=1
        return [list $oneShifted $delta]
    }
    set s [::math::bignum::add $oneShifted $integer]
    set two [fromstr 2]
    set d [intIncr [::math::bignum::div $delta $two]]
    set delta [::math::bignum::add $delta $delta]
    # dt = uncertainty on x^2
    set dt [intIncr [intMulShift $d $integer $precision]]
    # t= x^2/2
    set t [intMulShift $integer $integer $precision]
    set t [::math::bignum::div $t $two]
    set denom $two
    while {![::math::bignum::iszero $t]} {
        # the sum is called 's'
        set s [::math::bignum::add $s $t]
        set delta [::math::bignum::add $delta $dt]
        # we do not have to keep trace of the factorial, we just iterate divisions
        set denom [intIncr $denom]
        # add delta
        set d [intIncr [::math::bignum::div $d $denom]]
        set dt [::math::bignum::add $dt $d]
        # get x^n from x^(n-1)
        set t [intMulShift $integer $t $precision]
        # here we divide
        set t [::math::bignum::div $t $denom]
    }
    return [list $s $delta]
}
################################################################################
# divide a BigFloat by 2 power 'n'
################################################################################
proc ::math::bigfloat::floatRShift {float {n 1}} {
    return [lset float 2 [expr {[lindex $float 2]-1}]]
}



################################################################################
# procedure floor : identical to [expr floor($x)] in functionality
# arguments : number IN (a BigFloat)
# returns : the floor value as a BigInt
################################################################################
proc ::math::bigfloat::floor {number} {
    variable one
    checkFloat number
    set number [normalize $number]
    if {[::math::bignum::iszero $number]} {
        # returns the BigInt 0
        return [::math::bignum::fromstr 0]
    }
    foreach {dummy integer exp delta} $number {break}
    if {$exp>=0} {
        error "not enough precision to perform rounding (floor)"
    }
    # saving the sign ...
    set sign [::math::bignum::sign $integer]
    set integer [abs $integer]
    # integer part
    set try [::math::bignum::rshift $integer [expr {-$exp}]]
    # floor(n.xxxx)=n
    if {!$sign} {
        return $try
    }
    # floor(-n.xxxx)=-(n+1) when xxxx!=0
    if {![equal [::math::bignum::lshift $try [expr {-$exp}]] $integer]} {
        set try [::math::bignum::add $try $one]
    }
    ::math::bignum::setsign try $sign
    return $try
}


################################################################################
# returns a list formed by an integer and an exponent
# x = (A +/- C) * 10 power B
# return [list "F" A B C] (where F is the BigFloat tag)
# A and C are BigInts, B is a raw integer
# return also a BigInt when there is neither a dot, nor a 'e' exponent
#
# arguments : -base base integer
#          or integer
#          or float
#          or float trailingZeros
################################################################################
proc ::math::bigfloat::fromstr {args} {
    if {[set string [lindex $args 0]]=="-base"} {
        if {[llength $args]!=3} {
            error "should be : fromstr -base base number"
        }
        return [::math::bignum::fromstr [lindex $args 2] [lindex $args 1]]
    }
    set trailingZeros 0
    if {[llength $args]==2} {
        set trailingZeros [lindex $args 1]
    }
    if {$trailingZeros<0} {
        error "second argument has to be a positive integer"
    }
    # eliminate the sign problem
    if {[string index $string 0]=="-"} {
        set signe 1
        set string2 [string range $string 1 end]
    } else  {
        set signe 0
        set string2 $string
    }
    # integer case (not a floating-point number)
    if {[string is digit $string2]} {
        if {$trailingZeros!=0} {
            error "second argument not treated with an integer"
        }
        return [::math::bignum::fromstr $string]
    }
    set string $string2
    # floating-point number : check for an exponent
    # scientific notation
    set tab [split $string e]
    if {[llength $tab]>2} {error "syntax error in number : $string"}
    if {[llength $tab]==2} {
        set exp [lindex $tab 1]
        set number [lindex $tab 0]
    } else {
        set exp 0
        set number [lindex $tab 0]
    }
    # a floating-point number may have a dot
    set tab [split $number .]
    if {[llength $tab]>2} {error "syntax error in number : $string"}
    if {[llength $tab]==2} {
        set number [lindex $tab 0]
        set fin [lindex $tab 1]
        incr exp -[string length $fin]
    }
    append number $fin
    # this is necessary to ensure we can call fromstr (recursively) with
    # the mantissa ($number)
    if {![string is digit $number]} {
        error "$number is not a number"
    }
    incr exp -$trailingZeros
    set number [::math::bignum::mul [::math::bignum::fromstr $number]\
            [tenPow $trailingZeros]]
    ::math::bignum::setsign number $signe
    # the F tags a BigFloat
    # a BigInt in internal representation begins by the sign
    # delta is 1 as a BigInt
    return [_fromstr $number $exp]
}

################################################################################
# private procedure to transform decimal floats into binary ones
################################################################################
proc ::math::bigfloat::_fromstr {number exp} {
    variable one
    variable five
    if {$exp==0} {
        return [list F $number 0 $one]
    }
    if {$exp>0} {
        # mul by 10^exp and then normalize
        set number [::math::bignum::lshift $number 4]
        set exponent [tenPow $exp]
        set number [::math::bignum::mul $number $exponent]
        return [normalize [list F $number -4 [intIncr [::math::bignum::lshift $exponent 4]]]]
    }
    # now exp is negative or null
    # the closest power of 2 to the 'exp'th power of ten, but greater than it
    set binaryExp [expr {int(ceil(-$exp*log(10)/log(2)))+4}]
    # then compute n * 2^binaryExp / 10^(-exp)
    # (exp is negative)
    # equals n * 2^(binaryExp+exp) / 5^(-exp)
    set diff [expr {$binaryExp+$exp}]
    if {$diff<0} {
        error "internal error"
    }
    set fivePow [::math::bignum::pow $five [::math::bignum::fromstr [expr {-$exp}]]]
    set number [::math::bignum::div [::math::bignum::lshift $number \
            $diff] $fivePow]
    set delta [::math::bignum::div [::math::bignum::lshift $one \
            $diff] $fivePow]
    return [normalize [list F $number [expr {-$binaryExp}] [intIncr $delta]]]
}

################################################################################
# increment an integer (BigInt)
################################################################################
proc ::math::bigfloat::intIncr {n} {
    return [::math::bignum::add $n $::math::bigfloat::one]
}

################################################################################
# converts a BigInt into a BigFloat with a given decimal precision
################################################################################
proc ::math::bigfloat::int2float {int {decimals 1}} {
    # it seems like we need some kind of type handling
    # very odd in this Tcl world :-(
    if {![isInt $int]} {
        error "first argument is not an integer"
    }
    if {$decimals<1} {
        error "non-positive decimals number"
    }
    # the lowest number of decimals is 1, because
    # [tostr [fromstr 10.0]] returns 10.
    # (we lose 1 digit when converting back to string)
    set int [::math::bignum::mul $int [tenPow $decimals]]
    return [_fromstr $int [expr {-$decimals}]]
    
}



################################################################################
# multiplies 'leftop' by 'rightop' and rshift the result by 'shift'
################################################################################
proc ::math::bigfloat::intMulShift {leftop rightop shift} {
    return [::math::bignum::rshift [::math::bignum::mul $leftop $rightop] $shift]
}

################################################################################
# returns 1 if x is a BigFloat, 0 elsewhere
################################################################################
proc ::math::bigfloat::isFloat {x} {
    # a BigFloat is a list of : "F" mantissa exponent delta
    if {[llength $x]!=4} {
        return 0
    }
    # the marker is the letter "F"
    if {[string equal [lindex $x 0] F]} {
        return 1
    }
    return 0
}

################################################################################
# checks that n is a BigInt (a number create by math::bignum::fromstr)
################################################################################
proc ::math::bigfloat::isInt {n} {
    if {[llength $n]<3} {
        return 0
    }
    if {[string equal [lindex $n 0] bignum]} {
        return 1
    }
    return 0
}



################################################################################
# returns 1 if x is null, 0 otherwise
################################################################################
proc ::math::bigfloat::iszero {x} {
    if {[isInt $x]} {
        return [::math::bignum::iszero $x]
    }
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    set integer [::math::bignum::abs $integer]
    if {[::math::bignum::cmp $delta $integer]>=0} {return 1}
    return 0
}


################################################################################
# compute log(X)
################################################################################
proc ::math::bigfloat::log {x} {
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    if {[::math::bignum::iszero $integer]||[::math::bignum::sign $integer]} {
        error "zero logarithm error"
    }
    if {[iszero $x]} {
        error "number is null"
    }
    set precision [::math::bignum::bits $integer]
    # uncertainty of the logarithm
    set delta [intIncr [_logOnePlusEpsilon $delta $integer $precision]]
    # we got : x = 1xxxxxx (binary number with 'precision' bits) * 2^exp
    # we need : x = 0.1xxxxxx(binary) *2^(exp+precision)
    incr exp $precision
    foreach {integer deltaIncr} [_log $integer] {break}
    set delta [::math::bignum::add $delta $deltaIncr]
    # log(a * 2^exp)= log(a) + exp*log(2)
    # result = log(x) + exp*log(2)
    # as x<1 log(x)<0 but 'integer' (result of '_log') is the absolute value
    # that is why
    set integer [::math::bignum::sub \
            [::math::bignum::mul [_log2 $precision] [fromstr $exp]] $integer]
    set delta [::math::bignum::add $delta [abs [fromstr $exp]]]
    return [normalize [list F $integer -$precision $delta]]
}


################################################################################
# compute log(1-epsNum/epsDenom)=log(1-'epsilon')
# Taylor development gives -x -x^2/2 -x^3/3 -x^4/4 ...
# used by 'log' command because log(x+/-epsilon)=log(x)+log(1+/-(epsilon/x))
# so the uncertainty equals abs(log(1-epsilon/x))
# ================================================
# arguments :
# epsNum IN (the numerator of epsilon)
# epsDenom IN (the denominator of epsilon)
# precision IN (the number of bits after the dot)
#
# 'epsilon' = epsNum*2^-precision/epsDenom
################################################################################
proc ::math::bigfloat::_logOnePlusEpsilon {epsNum epsDenom precision} {
    if {[::math::bignum::cmp $epsNum $epsDenom]>=0} {
        error "number is null"
    }
    set s [::math::bignum::lshift $epsNum $precision]
    set s [::math::bignum::div $s $epsDenom]
    set divider [fromstr 2]
    set t [::math::bignum::div [::math::bignum::mul $s $epsNum] $epsDenom]
    set u [::math::bignum::div $t $divider]
    # when u (the current term of the development) is zero, we have reached our goal
    # it has converged
    while {![::math::bignum::iszero $u]} {
        set s [::math::bignum::add $s $u]
        # divider = order of the term = 'n'
        set divider [intIncr $divider]
        # t = (epsilon)^n
        set t [::math::bignum::div [::math::bignum::mul $t $epsNum] $epsDenom]
        # u = t/n = (epsilon)^n/n and is the nth term of the Taylor development
        set u [::math::bignum::div $t $divider]
    }
    return $s
}


################################################################################
# compute log(0.xxxxxxxx) : log(1-epsilon)=-eps-eps^2/2-eps^3/3...-eps^n/n
################################################################################
proc ::math::bigfloat::_log {integer} {
    # the uncertainty is nbSteps with nbSteps<=nbBits
    # take nbSteps=nbBits (the worse case) and log(nbBits+increment)=increment
    set precision [::math::bignum::bits $integer]
    set n [expr {int(log($precision+2*log($precision)))}]
    set integer [::math::bignum::lshift $integer $n]
    incr precision $n
    set delta [fromstr 3]
    set un [::math::bignum::lshift $::math::bigfloat::one $precision]
    # 1-epsilon=integer
    set integer [::math::bignum::sub $un $integer]
    set s $integer
    # t=x^2
    set t [intMulShift $integer $integer $precision]
    set denom [fromstr 2]
    # u=x^2/2 (second term)
    set u [::math::bignum::div $t $denom]
    while {![::math::bignum::iszero $u]} {
        # while the current term is not zero, it has not converged
        set s [::math::bignum::add $s $u]
        set delta [intIncr $delta]
        # t=x^n
        set t [intMulShift $t $integer $precision]
        # denom = n (the order of the current development term)
        set denom [intIncr $denom]
        # u = x^n/n (the nth term of Taylor development)
        set u [::math::bignum::div $t $denom]
    }
    # shift right to restore the precision
    set delta [intIncr [::math::bignum::rshift $delta $n]]
    return [list [::math::bignum::rshift $s $n] $delta]
}

################################################################################
# computes log(num/denom) with 'precision' bits
# you might not call this procedure directly : it assumes 'num/denom'>4/5
# and 'num/denom'<1
################################################################################
proc ::math::bigfloat::__log {num denom precision} {
    # p is the precision
    # pk is the precision increment
    # 2 power pk is also the maximum number of iterations
    # for a number close to 1 but lower than 1,
    # (denom-num)/denum is (in our case) lower than 1/5
    # so the maximum nb of iterations is for:
    # 1/5*(1+1/5*(1/2+1/5*(1/3+1/5*(...))))
    # the last term is 1/n*(1/5)^n
    # for the last term to be lower than 2^(-p-pk)
    # the number of iterations has to be
    # 2^(-pk).(1/5)^(2^pk) < 2^(-p-pk)
    # log(1/5).2^pk < -p
    # 2^pk > p/log(5)
    # pk > log(2)*log(p/log(5))
    # now set the variable n to the precision increment i.e. pk
    set n [expr {int(log(2)*log($precision/log(5)))+1}]
    incr precision $n
    set one $::math::bigfloat::one
    # log(num/denom)=log(1-(denom-num)/denom)
    set num [fromstr [expr {$denom-$num}]]
    set denom [fromstr $denom]
    set s [::math::bignum::div [::math::bignum::lshift $num $precision] $denom]
    set t [::math::bignum::div [::math::bignum::mul $s $num] $denom]
    set d [fromstr 2]
    set u [::math::bignum::div $t $d]
    while {![::math::bignum::iszero $u]} {
        set s [::math::bignum::add $s $u]
        set t [::math::bignum::div [::math::bignum::mul $t $num] $denom]
        set d [::math::bignum::add $d $one]
        set u [::math::bignum::div $t $d]
    }
    return [::math::bignum::rshift $s $n]
}

################################################################################
# computes log(2) with 'precision' bits and caches it into a namespace variable
################################################################################
proc ::math::bigfloat::__logbis {precision} {
    set increment [expr {int(log($precision)/log(2)+1)}]
    incr precision $increment
    # ln(2)=3*ln(1-4/5)+ln(1-125/128)
    set a [__log 125 128 $precision]
    set b [__log 4 5 $precision]
    set r [::math::bignum::add [::math::bignum::mul $b [fromstr 3]] $a]
    set ::math::bigfloat::Log2 [::math::bignum::rshift $r $increment]
    # formerly (when BigFloats were stored in ten radix) we had to compute log(10)
    # ln(10)=10.ln(1-4/5)+3*ln(1-125/128)
}


################################################################################
# retrieves log(2) with 'precision' bits
################################################################################
proc ::math::bigfloat::_log2 {precision} {
    variable Log2
    if {![info exists Log2]} {
        __logbis $precision
    } else {
        # the constant is cached and computed again when more precision is needed
        set l [::math::bignum::bits $Log2]
        if {$precision>$l} {
            __logbis $precision
        }
    }
    # return log(2) with 'precision' bits even when the cached value has more bits
    return [_round $Log2 $precision]
}


################################################################################
# returns A modulo B (like with fmod() math function)
################################################################################
proc ::math::bigfloat::mod {a b} {
    checkNumber a b
    if {[isInt $a] && [isInt $b]} {return [::math::bignum::mod $a $b]}
    if {[isInt $a]} {error "trying to divide a BigInt by a BigFloat"}
    set quotient [div $a $b]
    # examples : fmod(3,2)=1 quotient=1.5
    # fmod(1,2)=1 quotient=0.5
    # quotient>0 and b>0 : get floor(quotient)
    # fmod(-3,-2)=-1 quotient=1.5
    # fmod(-1,-2)=-1 quotient=0.5
    # quotient>0 and b<0 : get floor(quotient)
    # fmod(-3,2)=-1 quotient=-1.5
    # fmod(-1,2)=-1 quotient=-0.5
    # quotient<0 and b>0 : get ceil(quotient)
    # fmod(3,-2)=1 quotient=-1.5
    # fmod(1,-2)=1 quotient=-0.5
    # quotient<0 and b<0 : get ceil(quotient)
    if {[sign $quotient]} {
        set quotient [ceil $quotient]
    } else  {
        set quotient [floor $quotient]
    }
    return [sub $a [mul $quotient $b]]
}

################################################################################
# returns A times B
################################################################################
proc ::math::bigfloat::mul {a b} {
    checkNumber a b
    # dispatch the command to appropriate commands regarding types (BigInt & BigFloat)
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [::math::bignum::mul $a $b]
        }
        return [mulFloatByInt $b $a]
    }
    if {[isInt $b]} {return [mulFloatByInt $a $b]}
    # now we are sure that 'a' and 'b' are BigFloats
    foreach {dummy integerA expA deltaA} $a {break}
    foreach {dummy integerB expB deltaB} $b {break}
    # 2^expA * 2^expB = 2^(expA+expB)
    set exp [expr {$expA+$expB}]
    # mantissas are multiplied
    set integer [::math::bignum::mul $integerA $integerB]
    # compute precisely the uncertainty
    set deltaA [::math::bignum::mul [abs $integerB] $deltaA]
    set deltaB [::math::bignum::mul [abs $integerA] $deltaB]
    set delta [::math::bignum::add $deltaA $deltaB]
    # we have to normalize because 'delta' may be too big
    return [normalize [list F $integer $exp $delta]]
}

################################################################################
# returns A times B, where B is a positive integer
################################################################################
proc ::math::bigfloat::mulFloatByInt {a b} {
    checkFloat a
    foreach {dummy integer exp delta} $a {break}
    if {![isInt $b]} {
        error "second argument expected to be a BigInt"
    }
    set integer [::math::bignum::mul $integer $b]
    set delta [::math::bignum::mul $delta $b]
    return [normalize [list F $integer $exp $delta]]
}

################################################################################
# normalizes a number : delta (incertitude)
# has to be one digit only to avoid increases of
# the memory footprint of the number
################################################################################
proc ::math::bigfloat::normalize {number} {
    checkFloat number
    foreach {dummy integer exp delta} $number {break}
    set l [::math::bignum::bits $delta]
    if {$l>8} {
        incr l -8
        # always round upper the uncertainty
        set delta [::math::bignum::add [::math::bignum::rshift $delta $l]\
                $::math::bigfloat::one]
        set integer [::math::bignum::rshift $integer $l]
        incr exp $l
    }
    return [list F $integer $exp $delta]
}



################################################################################
# returns -A (the opposite)
################################################################################
proc ::math::bigfloat::opp {a} {
    checkNumber a
    if {[iszero $a]} {
        return $a
    }
    if {[isInt $a]} {
        ::math::bignum::setsign a [expr {![::math::bignum::sign $a]}]
        return $a
    }
    lset a 1 [opp [lindex $a 1]] 
    return $a
}

################################################################################
# gets Pi with precision bits
# after the dot (after you call [tostr] on the result)
################################################################################
proc ::math::bigfloat::pi {precision {binary 0}} {
    if {[llength $precision]>1} {
        if {[isInt $precision]} {
            set precision [tostr $precision]
        } else {
            error "'$precision' expected to be an integer"
        }
    }
    if {!$binary} {
        # convert bit length into decimal digit length
        set precision [expr {int(ceil($precision*log(10)/log(2)))}]
    }
    return [list F [_pi $precision] -$precision $::math::bigfloat::one]
}


proc ::math::bigfloat::_pi {precision} {
    # the constant Pi begins with 3.xxx
    # so we need 2 digits to store the digit '3'
    # and then we will have precision bits after the dot
    incr precision 2
    variable _pi0
    if {![info exists _pi0]} {
        set _pi0 [__pi $precision]
    }
    set lenPiGlobal [::math::bignum::bits $_pi0]
    if {$lenPiGlobal<$precision} {
        set _pi0 [__pi $precision]
    }
    return [::math::bignum::rshift $_pi0 [expr {[::math::bignum::bits $_pi0] - $precision}]]
}

################################################################################
# computes an integer representing Pi in binary radix, with precision bits
################################################################################
proc ::math::bigfloat::__pi {precision} {
    set safetyLimit 8
    # for safety and for the better precision, we do so ...
    incr precision $safetyLimit
    # formula found in the litterature
    set a [::math::bignum::mul [_atanfract [fromstr 18] $precision] [fromstr 48]]
    set a [::math::bignum::add $a [::math::bignum::mul \
            [_atanfract [fromstr 57] $precision] [fromstr 32]]]
    set a [::math::bignum::sub $a [::math::bignum::mul \
            [_atanfract [fromstr 239] $precision] [fromstr 20]]]
    return [::math::bignum::rshift $a $safetyLimit]
}

################################################################################
# shift right an integer until it haves $precision bits
# round at the same time
################################################################################
proc ::math::bigfloat::_round {integer precision} {
    set shift [expr {[::math::bignum::bits $integer]-$precision}]
    set result [::math::bignum::rshift $integer $shift]
    if {[::math::bignum::testbit $integer [expr {$shift-1}]]} {
        set result [::math::bignum::add $result $::math::bigfloat::one]
    }
    return $result
}

################################################################################
# returns A power B, where B is a positive integer
################################################################################
proc ::math::bigfloat::pow {a b} {
    checkNumber a
    if {![isInt $b]} {
        error "pow : exponent is not a positive integer"
    }
    # case where it is obvious that we should use the appropriate command
    # from math::bignum (added 5th March 2005)
    if {[isInt $a]} {
        return [::math::bignum::pow $a $b]
    }
    variable one
    set res $one
    while {1} {
        set remainder [::math::bignum::testbit $b 0]
        set b [::math::bignum::rshift $b 1]
        if {$remainder} {
            set res [mul $res $a]
        }
        if {[::math::bignum::iszero $b]} {
            if {[isInt $res]} {
                return $res
            }
            return [normalize $res]
        }
        set a [mul $a $a]
    }
}

################################################################################
# converts angles for radians to degrees
################################################################################
proc ::math::bigfloat::rad2deg {x} {
    checkFloat x
    set xLen [expr {-[lindex $x 2]}]
    if {$xLen<1} {
        error "number too loose to convert to degrees"
    }
    set pi [pi $xLen 1]
    return [div [mul $x [fromstr 180]] $pi]
}

################################################################################
# retourne la partie entière (ou 0) du nombre "number"
################################################################################
proc ::math::bigfloat::round {number} {
    checkFloat number
    #set number [normalize $number]
    # fetching integers (or BigInts) from the internal representation
    foreach {dummy integer exp delta} $number {break}
    if {[::math::bignum::iszero $integer]} {
        # returns the BigInt 0
        return [::math::bignum::fromstr 0]
    }
    if {$exp>=0} {
        error "not enough precision to round (in round)"
    }
    set exp [expr {-$exp}]
    # saving the sign, ...
    set sign [::math::bignum::sign $integer]
    set integer [abs $integer]
    # integer part of the number
    set try [::math::bignum::rshift $integer $exp]
    # first bit after the dot
    set way [::math::bignum::testbit $integer [expr {$exp-1}]]
    # delta is shifted so it gives the integer part of 2*delta
    set delta [::math::bignum::rshift $delta [expr {$exp-1}]]
    # when delta is too big to compute rounded value (
    if {![::math::bignum::iszero $delta]} {
        error "not enough precision to round (in round)"
    }
    if {$way} {
        set try [::math::bignum::add $try $::math::bigfloat::one]
    }
    # ... restore the sign now
    ::math::bignum::setsign try $sign
    return $try
}

################################################################################
# round and divide by 2^n
################################################################################
proc ::math::bigfloat::roundshift {integer n} {
    set exp [tenPow $n]
    foreach {result remainder} [::math::bignum::divqr $integer $exp] {}
    if {[::math::bignum::cmp $exp [::math::bignum::mul $remainder [fromstr 2]]]<=0} {
        return [::math::bignum::add $result $::math::bigfloat::one]
    }
    return $result
}

################################################################################
# gets the sign of either a bignum, or a BitFloat
# we keep the bignum convention : 0 for positive, 1 for negative
################################################################################
proc ::math::bigfloat::sign {n} {
    if {[isInt $n]} {
        return [::math::bignum::sign $n]
    }
    # sign of 0=0
    if {[iszero $n]} {return 0}
    return [::math::bignum::sign [lindex $n 1]]
}


################################################################################
# gets sin(x)
################################################################################
proc ::math::bigfloat::sin {x} {
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    if {$exp>-2} {
        error "sin : not enough precision"
    }
    set precision [expr {-$exp}]
    # sin(2kPi+x)=sin(x)
    foreach {n integer} [divPiQuarter $integer $precision] {break}
    set delta [::math::bignum::add $delta $n]
    set d [::math::bignum::mod $n [fromstr 4]]
    # maintenant integer>=0
    # sin(2Pi-x)=-sin(x)
    # sin(Pi-x)=sin(x)
    # sin(Pi/2+x)=cos(x)
    set sign 0
    switch  -- [tostr $d] {
        0 {set l [_sin2 $integer $precision $delta]}
        1 {set l [_cos2 $integer $precision $delta]}
        2 {set sign 1;set l [_sin2 $integer $precision $delta]}
        3 {set sign 1;set l [_cos2 $integer $precision $delta]}
        default {error "internal error"}
    }
    # precision --> exponent (the opposite)
    lset l 1 [expr {-([lindex $l 1])}]
    set integer [lindex $l 0]
    ::math::bignum::setsign integer $sign
    lset l 0 $integer
    return [normalize [linsert $l 0 F]]
}

proc ::math::bigfloat::_sin2 {x precision delta} {
    set pi [_pi [expr {1+$precision}]]
    set pis2 [::math::bignum::rshift $pi 2]
    set pis4 [::math::bignum::rshift $pi 3]
    if {[::math::bignum::cmp $x $pis4]>=0} {
        # sin(Pi/2-x)=cos(x)
        set delta [intIncr $delta]
        set x [::math::bignum::sub $pis2 $x]
        return [_cos $x $precision $delta]
    }
    return [_sin $x $precision $delta]
}

################################################################################
# sin(x) with 'x' lower than Pi/4 and positive
################################################################################
proc ::math::bigfloat::_sin {x precision delta} {
    set s $x
    set double [::math::bignum::rshift [::math::bignum::mul $x $delta] [expr {$precision-1}]]
    set x [intMulShift $x $x $precision]
    set dt [::math::bignum::rshift [::math::bignum::add \
            [::math::bignum::mul $x $delta] [::math::bignum::mul $s $double]] $precision]
    set t [intMulShift $s $x $precision]
    set two [fromstr 2]
    set denom2 $two
    set denom3 [fromstr 3]
    set t [opp [::math::bignum::div $t [fromstr 6]]]
    while {![::math::bignum::iszero $t]} {
        set s [::math::bignum::add $s $t]
        set delta [::math::bignum::add $delta $dt]
        set denom2 [::math::bignum::add $denom2 $two]
        set denom3 [::math::bignum::add $denom3 $two]
        set dt [::math::bignum::rshift [::math::bignum::add \
                [::math::bignum::mul $x $dt] [::math::bignum::mul $t $double]] $precision]
        set t [intMulShift $t $x $precision]
        set dt [::math::bignum::add $dt $double]
        set t [opp [::math::bignum::div $t [::math::bignum::mul $denom2 $denom3]]]
    }
    return [list $s $precision $delta]
}


################################################################################
# procedure for extracting the square root of a BigFloat
################################################################################
proc ::math::bigfloat::sqrt {x} {
    variable one
    checkFloat x
    foreach {dummy integer exp delta} $x {break}
    # si x=0, retourner 0
    if {[iszero $x]} {
        return [list F [fromstr 0] $exp $one]
    }
    # we cannot get sqrt(x) if x<0
    if {[lindex $integer 0]<0} {
        error "negative sqrt : $x"
    }
    # (n +/- delta)^1/2=n^1/2 * (1 +/- delta/n)^1/2
    # delta_final=n^1/2 * Sum(i from 1 to infinity)(delta/n)^i*(3*5*...*(2i-3))/(i!*2^i)
    # here we compute the second term of the product
    set delta [_sqrtOnePlusEpsilon $delta $integer]
    set intLen [::math::bignum::bits $integer]
    set precision $intLen
    # intLen + exp = number of bits before the dot
    set precision [expr {$precision-($intLen+$exp)}]
    # square root extraction
    set integer [::math::bignum::lshift $integer $intLen]
    incr exp -$intLen
    incr intLen $intLen
    # there is an exponent 2^n : if n is odd, we would need to compute sqrt(2)
    # if n is even, we just divide the exponent n by 2 and it is done !
    if {$exp&1} {
        incr exp -1
        set integer [::math::bignum::lshift $integer 1]
        incr intLen
    }
    # using a low-level (in bignum) root extraction procedure
    set integer [::math::bignum::sqrt $integer]
    # delta has to be multiplied by the square root
    set delta [::math::bignum::rshift [::math::bignum::mul $delta $integer] $precision]
    set delta [::math::bignum::add $delta $one]
    return [normalize [list F $integer [expr {$exp/2}] $delta]]
}



################################################################################
# compute abs(sqrt(1-delta/integer)-1)
# the returned value is a relative uncertainty
################################################################################
proc ::math::bigfloat::_sqrtOnePlusEpsilon {delta integer} {
    variable one
    set l [::math::bignum::bits $integer]
    set x [::math::bignum::div [::math::bignum::lshift $delta $l] $integer]
    set two [fromstr 2]
    set fact $two
    # eps/2
    set result [::math::bignum::div $x $two]
    # eps^2/(2!*2)
    set temp [::math::bignum::div [::math::bignum::mul $result $delta] $integer]
    set temp [::math::bignum::div [::math::bignum::div $temp $two] $fact]
    set result [::math::bignum::add $result $temp]
    set numerator [fromstr 3]
    set fact [::math::bignum::add $fact $one]
    # (eps^3)*3/(3!*2^2)
    set temp [::math::bignum::div [::math::bignum::mul $temp $delta] $integer]
    set temp [::math::bignum::div [::math::bignum::mul $temp $numerator] $two]
    set temp [::math::bignum::div $temp $fact]
    while {![::math::bignum::iszero $temp]} {
        set result [::math::bignum::add $result $temp]
        set numerator [::math::bignum::add $numerator $two]
        set fact [::math::bignum::add $fact $one]
        # u_n+1= u_n*(2n+1)/2n*eps
        set temp [::math::bignum::div [::math::bignum::mul $temp $delta] $integer]
        set temp [::math::bignum::div [::math::bignum::mul $temp $numerator] $two]
        set temp [::math::bignum::div $temp $fact]
    }
    return $result
}

################################################################################
# substracts B to A
################################################################################
proc ::math::bigfloat::sub {a b} {
    checkNumber a b
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [::math::bignum::sub $a $b]
        }
        return [add $a [opp $b]]
    }
    if {[isInt $b]} {
        return [opp [add [opp $a] $b]]
    }
    return [add $a [opp $b]]
}

################################################################################
# tangent
################################################################################
proc ::math::bigfloat::tan {x} {
    return [::math::bigfloat::div [::math::bigfloat::sin $x] [::math::bigfloat::cos $x]]
}

################################################################################
# returns a power of ten
################################################################################
proc ::math::bigfloat::tenPow {n} {
    return [::math::bignum::pow $::math::bigfloat::ten [::math::bignum::fromstr $n]]
}


################################################################################
# converts a BigInt to a double (basic floating-point type)
# with respect to the global tcl_precision
################################################################################
proc ::math::bigfloat::todouble {x} {
    global tcl_precision
    checkFloat x
    set result [tostr $x]
    set minus ""
    if {[string index $result 0]=="-"} {
        set minus -
        set result [string range $result 1 end]
    }
    set l [split $result e]
    set exp 0
    if {[llength $l]==2} {
        set exp [lindex $l 1]
    }
    set l [split [lindex $l 0] .]
    set integerPart [lindex $l 0]
    set integerLen [string length $integerPart]
    set fractionalPart [lindex $l 1]
    set len [string length [set integer $integerPart$fractionalPart]]
    if {$len>$tcl_precision} {
        set lenDiff [expr {$len-$tcl_precision}]
        # true when the number begins with a zero
        set zeroHead 0
        if {[string index $integer 0]==0} {
            incr lenDiff -1
            set zeroHead 1
        }
        set integer [tostr [roundshift [fromstr $integer] $lenDiff]]
        if {$zeroHead} {
            set integer 0$integer
        }
        set len [string length $integer]
        if {$len<$integerLen} {
            set exp [expr {$integerLen-$len}]
            # restore the true length
            set integerLen $len
        }
    }
    # number = 'sign'*'integer'*10^'exp'
    if {$exp==0} {
        set exp ""
    } else {
        set exp e$exp
    }
    set result [string range $integer 0 [expr {$integerLen-1}]]
    append result .[string range $integer $integerLen end]
    return $minus$result$exp
}

################################################################################
# converts a number stored as a list to a string in which all digits are true
################################################################################
proc ::math::bigfloat::tostr {number} {
    variable five
    if {[isInt $number]} {
        return [::math::bignum::tostr $number]
    }
    checkFloat number
    foreach {dummy integer exp delta} $number {break}
    if {[iszero $number]} {
        return 0
    }
    if {$exp>0} {
        # the power of ten the closest but greater than $exp power 2
        # if it was lower than the power of 2, we would have more precision
        # than existing in the number
        set newExp [expr {int(ceil($exp*log(2)/log(10)))}]
        # 'integer' <- 'integer' * 2^exp / 10^newExp
        # equals 'integer' * 2^(exp-newExp) / 5^newExp
        set binExp [expr {$exp-$newExp}]
        if {$binExp<0} {
            error "internal error"
        }
        set fivePower [::math::bignum::pow $five [::math::bignum::fromstr $newExp]]
        set integer [::math::bignum::div [::math::bignum::lshift $integer $binExp] \
                $fivePower]
        set delta [::math::bignum::div [::math::bignum::lshift $delta $binExp] $fivePower]
        set exp $newExp
    } elseif {$exp<0} {
        # the power of ten the closest but lower than $exp power 2
        # same remark about the precision
        set newExp [expr {int(floor(-$exp*log(2)/log(10)))}]
        # 'integer' <- 'integer' * 10^newExp / 2^(-exp)
        # equals 'integer' * 5^(newExp) / 2^(-exp-newExp)
        set fivePower [::math::bignum::pow $five \
                [::math::bignum::fromstr $newExp]]
        set binShift [expr {-$exp-$newExp}]
        set integer [::math::bignum::rshift [::math::bignum::mul $integer $fivePower] \
                $binShift]
        set delta [::math::bignum::rshift [::math::bignum::mul $delta $fivePower] \
                $binShift]
        set exp -$newExp
    }
    # saving the sign, to restore it into the result
    set sign [::math::bignum::sign $integer]
    set result [::math::bignum::abs $integer]
    set isZero [::math::bignum::iszero $result]
    # rounded 'integer' +/- 'delta'
    set up [::math::bignum::add $result $delta]
    set down [::math::bignum::sub $result $delta]
    if {[sign $up]^[sign $down]} {
        return 0
    }
    # iterate until the convergence of the rounding
    for {set shift 1} {
        [::math::bignum::cmp [roundshift $up $shift] [roundshift $down $shift]]
    } {
        incr shift
    } {}
    incr exp $shift
    set result [::math::bignum::tostr [roundshift $up $shift]]
    set l [string length $result]
    # now formatting the number the most nicely for having a good presentation
    # would'nt we allow a number being constantly displayed
    # as : 0.2947497845e+012 , would we ?
    if {$exp>0} {
        incr exp $l
        incr exp -1
        set result [string index $result 0].[string range $result 1 end]
        append result "e+$exp"
    } elseif {$exp==0} {
        # it must have a dot to be a floating-point number (syntaxically speaking)
        append result .
    } else {
        set exp [expr {-$exp}]
        if {$exp < $l} {
            set n [string range $result 0 end-$exp]
            incr exp -1
            append n .[string range $result end-$exp end]
            set result $n
        } elseif {$l==$exp} {
            set result "0.$result"
        } else  {
            set result "[string index $result 0].[string range $result 1 end]e-[expr {$exp-$l+1}]"
        }
    }
    # restore the sign : we only put a minus on numbers that are different from zero
    if {$sign==1 && !$isZero} {set result "-$result"}
    return $result
}

################################################################################
# PART IV
# HYPERBOLIC FUNCTIONS
################################################################################

################################################################################
# hyperbolic cosinus
################################################################################
proc ::math::bigfloat::cosh {x} {
    return [floatRShift [add [exp $x] [exp [opp $x]]] 1]
}

################################################################################
# hyperbolic sinus
################################################################################
proc ::math::bigfloat::sinh {x} {
    return [floatRShift [sub [exp $x] [exp [opp $x]]] 1]
}

################################################################################
# hyperbolic tangent
################################################################################
proc ::math::bigfloat::tanh {x} {
    set up [exp $x]
    set down [exp [opp $x]]
    return [div [sub $up $down] [add $up $down]]
}

namespace eval ::math::bigfloat {
    foreach function {
        add mul sub div mod pow
        iszero compare equal
        fromstr tostr todouble int2float
        isInt isFloat
        exp log sqrt round ceil floor
        sin cos tan cotan asin acos atan
        cosh sinh tanh abs opp
        pi deg2rad rad2deg
    } {
        namespace export $function
    }
}

# (AM) No "namespace import" - this should be left to the user!
#namespace import ::math::bigfloat::*

package provide math::bigfloat 1.2
