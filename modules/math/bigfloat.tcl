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
# Web site : http://sarnold.free.fr/
########################################################################

# this line helps when I want to source this file again and again
catch {namespace delete ::math::bigfloat}

# private namespace
# this software works only with Tcl v8.4 and higher
# because it uses 64-bit integers.

package require Tcl 8.4

namespace eval ::math::bigfloat {
    # some constants
    variable karatsubaLimit
    set karatsubaLimit 40
    # ln(2) with arbitrary precision
    variable log2
    # ln(10) with arb. precision
    variable log10
    # Pi with arb. precision
    variable _pi0
}

################################################################################
# PART I
# PROCEDURES DEALING WITH BIG UNSIGNED INTEGERS
################################################################################


# global utility function
proc ::math::bigfloat::Dec {chaine} {
    set a [string trimleft $chaine 0]
    if {$a==""} {return 0}
    return $a
}

################################################################################
# input : chaine (a number)
# return : true if the number is a string containing only '0' chars
################################################################################
proc ::math::bigfloat::intIsZero {chaine} {
    if {[string trimleft $chaine 0]==""} {
        return 1
    }
    return 0
}

# right shift with upper rounding
proc ::math::bigfloat::droite {int n} {
    if {$n==0} {return $int}
    #set int [Dec $int]
    set l [string length $int]
    if {$l<=$n} {
        return 0
    }
    set int [string range $int 0 end-$n]
    return [intAdd $int 1]
}

# compares two integers as with [string compare]
proc ::math::bigfloat::intCompare {a b} {
    set a [Dec $a]
    set b [Dec $b]
    set la [string length $a]
    set lb [string length $b]
    if {$la<$lb} {return -1}
    if {$la>$lb} {return 1}
    # string compare works quite good on digits
    return [string compare $a $b]
}

################################################################################
# input : an integer N
# returns a string containing N zeros (for example : if N=3 it returns "000")
################################################################################

proc ::math::bigfloat::zero {n} {
    if {$n==0} {return ""}
    set r ""
    while {$n>100} {
        append r [format %0100s 0]
        incr n -100
    }
    append r [format %0${n}s 0]
    return $r
}



# adds n zeros at the end of $a
proc ::math::bigfloat::decale {a n} {
    append a [zero $n]
    return $a
}



# addition when b is small (smaller than a half-wide)
proc ::math::bigfloat::_intAdd {a b} {
    set b [Dec $b]
    if {[string length $b]>15} {return [add $a $b]}
    set a [Dec $a]
    set result ""
    while {[string length $a]>15} {
        set fina [Dec [string range $a end-14 end]]
        set fin [expr {wide($fina)+wide($b)}]
        set a [string range $a 0 end-15]
        if {[string length $fin]<=15} {
            set result [format %.15ld $fin]$result
            return $a$result
        }
        set result [format %.15ld [string range $fin end-14 end]]
        set b [string range $fin 0 end-15]
    }
    set fin [expr {wide($a)+wide($b)}]
    return $fin$result
}

# addition with unsigned integers
proc ::math::bigfloat::intAdd {a b} {
    set a [Dec $a]
    set b [Dec $b]
    set fina [Dec [string range $a end-14 end]]
    set finb [Dec [string range $b end-14 end]]
    set fin [expr {wide($fina)+wide($finb)}]
    set result ""
    while {1} {
        if {[string length $fin]>15} {
            set retenue [string range $fin 0 end-15]
            set fin [Dec [string range $fin end-14 end]]
        } else {set retenue ""}
        set result [format %.15lu $fin]$result
        set a [Dec $a]
        set b [Dec $b]
        if {[string length $a]>15} {
            set a [Dec [string range $a 0 end-15]]
        } else {set a ""}
        if {[string length $b]>15} {
            set b [Dec [string range $b 0 end-15]]
        } else {set b ""}
        if {$retenue!= ""} {
            if {$a=="" && $b==""} {
                return [Dec $retenue$result]
            }
            if {$a!="" && $b!=""} {
                if {[intCompare $a $b]<0} {
                    set a [Dec [_intAdd $a $retenue]]
                } else {
                    set b [Dec [_intAdd $b $retenue]]
                }
            } elseif {$a==""} {
                set a $retenue
            } else {set b $retenue}
            set fina [Dec [string range $a end-14 end]]
            set finb [Dec [string range $b end-14 end]]
            set fin [expr {wide($fina)+wide($finb)}]
        } else {
            if {$a!=""} {
                if {$b!=""} {
                    set fina [Dec [string range $a end-14 end]]
                    set finb [Dec [string range $b end-14 end]]
                    set fin [expr {wide($fina)+wide($finb)}]
                } else {
                    return [Dec $a$result]
                }
            } elseif {$b!=""} {
                return [Dec $b$result]
            } else {
                return [Dec $result]
            }
        }
    }
}


# returns a-b
# uses _add
proc ::math::bigfloat::intSub {a b} {
    if {[intCompare $a $b]<=0} {return 0}
    if {[intCompare $b 0]==0} {return $a}
    set result ""
    while {1} {
        set fina [Dec [string range $a end-14 end]]
        set finb [Dec [string range $b end-14 end]]
        set diff [expr {wide($fina)-wide($finb)}]
        set retenue 0
        if {$diff < 0} {
            set fina 1[string range $a end-14 end]
            set diff [expr {wide($fina)-wide($finb)}]
            set retenue 1
        }
        if {[string length $a]>15} {
            set a [string range $a 0 end-15]
        } else {set a 0}
        if {[string length $b]>15} {
            set b [string range $b 0 end-15]
        } else {set b 0}
        if {$retenue} {set b [_intAdd $b 1]}
        set result [format %.15lu $diff]$result
        if {$b==0} {return [Dec $a$result]}
    }
}


# multiplies $a by $b
# uses add, decale and _mul
proc ::math::bigfloat::intMul {a b} {
    if {[intCompare $a 0]==0 || [intCompare $b 0]==0} {return 0}
    set result 0
    set i 0
    # if the mean(len(a),len(b))>=30 then we can use Karatsuba multiplication algorithm
    if {[string length $a]<$::math::bigfloat::karatsubaLimit && [string length $b]<$::math::bigfloat::karatsubaLimit} {
        while {1} {
            set fina [Dec [string range $a end-7 end]]
            set finb [Dec [string range $b end-7 end]]
            set fin [expr {wide($fina)*wide($finb)}]
            if {[string length $a]>8 && [string length $b]>8} {
                set a [string range $a 0 end-8]
                set b [string range $b 0 end-8]
                set comp [intAdd [_intMul $a $finb] [_intMul $b $fina]]
                set result [intAdd $result [decale [intAdd $fin [decale $comp 8]] $i]]
                incr i 16
            } else {
                if {[string length $a]>8} {
                    set a [string range $a 0 end-8]
                    return [intAdd $result [decale [intAdd $fin [decale [_intMul $a $finb]\
                            8]] $i]]
                }
                if {[string length $b]>8} {
                    set b [string range $b 0 end-8]
                    return [intAdd $result [decale [intAdd $fin [decale [_intMul $b $fina]\
                            8]] $i]]
                }
                return [intAdd $result [decale $fin $i]]
            }
        }
    } else  {
        # begin Karatsuba algorithm
        # moitieLen is the splitting point
        if {[intCompare $a $b]>0} {
            set moitieLen [string length $a]
        } else  {
            set moitieLen [string length $b]
        }
        # this line is taken from the bignum package of tcllib
        set moitieLen [expr {($moitieLen+($moitieLen & 1))/2}]
        # splitting each operand in two equal-length numbers
        # A= A1*10^N+A2
        # B= B1*10^N+B2
        set premiereMoitieA [string range $a 0 end-$moitieLen]
        set deuxiemeMoitieA [string range $a end-[expr {$moitieLen-1}] end]
        set premiereMoitieB [string range $b 0 end-$moitieLen]
        set deuxiemeMoitieB [string range $b end-[expr {$moitieLen-1}] end]
        set premiereMoitieA [Dec $premiereMoitieA]
        set premiereMoitieB [Dec $premiereMoitieB]
        # algo. : A*B=A1*B1*10^(2N) + (A1*B0+A0*B1)*10^N + A0*B0
        set produit1 [intMul $premiereMoitieA $premiereMoitieB]
        set produit2 [intMul $deuxiemeMoitieA $deuxiemeMoitieB]
        # compute (A0+A1)*(B0+B1)
        # the middle term becomes produit3-(produit1+produit2)
        set produit3 [intMul [intAdd $premiereMoitieA $deuxiemeMoitieA] \
                [intAdd $premiereMoitieB $deuxiemeMoitieB]]
        set produit3 [intSub $produit3 [intAdd $produit1 $produit2]]
        append produit1 [zero [expr {$moitieLen*2}]]
        append produit3 [zero $moitieLen]
        return [intAdd $produit1 [intAdd $produit3 $produit2]]
        # END of Karatsuba algorithm
    }
}

proc ::math::bigfloat::_intMul {a b} {
    set b [Dec $b]
    if {[string length $b]>8} {return [intMul $a $b]}
    set a [Dec $a]
    if {$b==0||[string equal $a 0]} {return 0}
    set result ""
    set retenue 0
    while {1} {
        if {[string length $a]>8} {
            set fina [Dec [string range $a end-7 end]]
            set a [string range $a 0 end-8]
        } else {
            set fina $a
            set a ""
        }
        set fin [expr {wide($fina)*wide($b)}]
        set retenue [intAdd $retenue $fin]
        if {[string length $retenue]>8} {
            set result [string range $retenue end-7 end]$result
            set retenue [string range $retenue 0 end-8]
        } else {
            set result [format %.8lu $retenue]$result
            set retenue 0
        }
        if {$a==""} {return [Dec $retenue$result]}
    }
}



# divide $a by $b
# uses add, mul, sub and _div
# returns a list containing quotient and remainder
proc ::math::bigfloat::intDivqr {a b} {
    set a [Dec $a]
    set b [Dec $b]
    set lb [string length $b]
    if {$lb<=16} {
        set q [_intDiv $a $b]
        return [list $q [intSub $a [_intMul $q $b]]]
    }
    set cmp [intCompare $a $b]
    if {$cmp<0} {return [list 0 $a]}
    if {$cmp==0} {return [list 1 0]}
    # a/(b+c)=(a/b)/(1+c/b)
    # on va calculer une approximation supérieure et une approximation inférieure
    # du quotient
    # ici b=dmax ou dmin et c=cmax ou cmin
    set cmin $a
    set cmax $a
    set dmin $b
    set dmax $b
    # dmin est le reste de la division euclidienne
    while {[string length $dmin]>16} {
        # splitting B into $dmin$e
        set e [Dec [string range $dmin end-15 end]]
        set dmin [string range $dmin 0 end-16]
        while {wide($e)<=1} {
            # when the divider equals 1, it would loop endlessly if
            # we did not assume e=0.
            # split again B into $dmin$e * 10**16
            # A=$cmax * 10**16
            # Quand le dénominateur se termine par 16 zéros
            # le numérateur peut être décalé de 16 chiffres vers la droite
            set cmax [_intAdd [string range $cmax 0 end-16] $e]
            set e [Dec [string range $dmin end-15 end]]
            set dmin [string range $dmin 0 end-16]
        }
        # 1+c/b = next line
        set dmin [intAdd [_intDiv $dmin[format %016s 0] $e] 1]
        # a/b = next line
        set cmax [_intDiv $cmax $e]
    }
    # the next while does the same thing but with a ceiling value
    # whereas the previous while gave us the floor value
    while {[string length $dmax]>16} {
        set e [Dec [string range $dmax end-15 end]]
        set dmax [string range $dmax 0 end-16]
        while {wide($e)==0} {
            set cmin [string range $cmin 0 end-16]
            set e [Dec [string range $dmax end-15 end]]
            set dmax [string range $dmax 0 end-16]
        }
        if {wide($e)==1} {
            set e 2
        }
        set dmax [intAdd [_intDiv $dmax[format %016s 0] $e] 2]
        set cmin [_intDiv $cmin [expr {wide($e)+1}]]
    }
    set qmin [_intDiv $cmin [expr {wide($dmax)+1}]]
    set qmax [_intDiv $cmax $dmin]
    set pmin [intMul $qmin $b]
    set pmax [intMul $qmax $b]
    set rmin [intSub $a $pmin]
    set rmax [intSub $a $pmax]
    if {[intCompare $pmin $a]<=0 && [intCompare $rmin $b]<0} {
        return [list $qmin $rmin]
    }
    if {[intCompare $pmax $a]<=0 && [intCompare $rmax $b]<0} {
        return [list $qmax $rmax]
    }
    while {1} {
        # dichotomy to be redone
        set q [_intDiv [intAdd $qmin $qmax] 2]
        if {[intCompare $q $qmin]==0} {
            if {[intCompare $q $qmax]==0} {
                return [list $q [intSub $a [intMul $b $q]]]
            }
        }
        set p [intMul $q $b]
        if {[intCompare $p $a]>0} {
            set qmax $q
            continue
        }
        set r [intSub $a $p]
        if {[intCompare $r $b]>=0} {
            set qmin $q
            continue
        }
        return [list $q $r]
    }
}

# division lorsque b est un entier de moins de 17 chiffres
proc ::math::bigfloat::_intDiv {a b} {
    set result 0
    set a [Dec $a]
    while {[string length $a]>17} {
        set debuta [Dec [string range $a 0 16]]
        set a [string range $a 17 end]
        set div [expr {wide($debuta)/wide($b)}]
        set reste [expr {wide($debuta)%wide($b)}]
        set div [decale $div [string length $a]]
        set result [intAdd $result $div]
        set a [Dec $reste$a]
    }
    return [intAdd [expr {wide($a)/wide($b)}] $result]
}


################################################################################
# returns round(A/B)
# input : a & b (unsigned big integers)
################################################################################
proc ::math::bigfloat::rnddiv {a b} {
    foreach {quotient reste} [intDivqr $a $b] {break}
    if {[intCompare $reste [intDiv $b 2]]>=0} {
        return [intAdd $quotient 1]
    }
    return $quotient
}

proc ::math::bigfloat::incrdiv {a b} {
    set q [intDiv $a $b]
    return [intAdd $q 1]
}

# divide $a by $b
# uses add, mul, sub and _div
# returns a quotient
proc ::math::bigfloat::intDiv {a b} {
    return [lindex [intDivqr $a $b] 0]
}

proc ::math::bigfloat::intMod {a b} {
    return [lindex [intDivqr $a $b] 1]
}

################################################################################
# lshift : returns an integer / by 10^tronquer and rounded
################################################################################
proc ::math::bigfloat::lshift {entier {tronquer 1}} {
    set l [string length $entier]
    if {$l<$tronquer} {
        return 0
    }
    if {$l==$tronquer} {
        return [expr {([string index $entier 0]>=5)?1:0}]
    }
    set r [string range $entier 0 end-$tronquer]
    if {[string index $entier [expr {$l-$tronquer}]]>=5} {
        return [intAdd $r 1]
    }
    return $r
}

# checks that n is a BigInt
proc ::math::bigfloat::isInt {n} {
    if {[llength $n]==1} {
        if {![string is digit $n]} {
            error "not an integer : $n"
        }
        return true
    }
    return false
}

################################################################################
# PART II
# procedure that treats signed integers
################################################################################

################################################################################
# intSAdd : adds two signed integers
################################################################################
proc ::math::bigfloat::intSAdd {signeA entierA signeB entierB} {
    if {$signeA==$signeB} {
        return [list $signeA [intAdd $entierA $entierB]]
    }
    # a and b are not of the same sign
    set cmpRes [intCompare $entierA $entierB]
    if {$cmpRes==0} {
        return [list 1 0]
    }
    if {$cmpRes<0} {
        return [list $signeB [intSub $entierB $entierA]]
    }
    return [list $signeA [intSub $entierA $entierB]]
}


proc ::math::bigfloat::intSCompare {signeA entierA signeB entierB} {
    if {$signeA!=$signeB} {
        return $signeA
    }
    set cmp [intCompare $entierA $entierB]
    if {$cmp!=0} {
        return [expr {$cmp*$signeA}]
    }
    return 0
}

################################################################################
# PART III
# procedures that handle floating-point numbers
################################################################################


################################################################################
# returns the absolute value
################################################################################
proc ::math::bigfloat::abs {chaine} {
    lset chaine 0 1
    return $chaine
}


#TODO (arccos)
proc ::math::bigfloat::acos {x} {
    foreach {signe entier exp delta} $x {break}
    set precision [expr {($exp<0)?(-$exp):1}]
    if {[isnull $x]} {
        return [intdiv [pi $precision] 2]
    }
    if {$signe<=0} {
        set pi_sur_deux [intdiv [pi $precision] 2]
        return [add $pi_sur_deux [asin [abs $x]]]
    }
    if {[compare $x [fromstr 0.707]]>0} {
        set zero [fromstr 0.[zero $precision]]
        set un [fromstr 1.[zero $precision]]
        if {[equal $un $x]} {
            return $zero
        }
        set x [sqrt [sub $un [mul $x $x]]]
        return [add $zero [_asin $x]]
    }
    set pi_sur_deux [intdiv [pi $precision] 2]
    return [sub $pi_sur_deux [_asin $x]]
}


################################################################################
# returns A + B
################################################################################
proc ::math::bigfloat::add {a b} {
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [intAdd $a $b]
        }
        return [intadd $b $a]
    }
    if {[isInt $b]} {
        return [intadd $a $b]
    }
    foreach {signeA entierA expA deltaA} $a {break}
    foreach {signeB entierB expB deltaB} $b {break}

    if {$expA>$expB} {
        set diff [expr {$expA-$expB}]
        append entierA [zero $diff]
        append deltaA [zero $diff]
        foreach {signeA entierA} [intSAdd $signeA $entierA $signeB $entierB] {break}
        set deltaA [intAdd $deltaA $deltaB]
        return [normalize [list $signeA $entierA [expr {$expA-$diff}] $deltaA]]
    } elseif {$expA==$expB} {
        return [normalize [concat [intSAdd $signeA $entierA $signeB $entierB] \
                $expA [intAdd $deltaA $deltaB]]]
    } else {
        set diff [expr {$expB-$expA}]
        append entierB [zero $diff]
        append deltaB [zero $diff]

        foreach {signeB entierB} [intSAdd $signeA $entierA $signeB $entierB] {break}
        set deltaB [intAdd $deltaB $deltaA]
        return [normalize [list $signeB $entierB [expr {$expB-$diff}] $deltaB]]
    }
}

################################################################################
# returns A(BigFloat) + B(BigInt)
################################################################################
proc ::math::bigfloat::intadd {a b} {
    foreach {signeA entierA expA deltaA} $a {break}
    if {$expA>0} {
        append entierA [zero $expA]
        append deltaA [zero $expA]
        foreach {signeA entierA} [intSAdd $signeA $entierA 1 $b] {break}
        return [normalize [list $signeA $entierA 0 $deltaA]]
    } elseif {$expA==0} {
        return [normalize [concat [intSAdd $signeA $entierA 1 $b] \
                0 $deltaA]]]
    } else {
        append b [zero [expr {-$expA}]]
        foreach {signeA entierA} [intSAdd $signeA $entierA 1 $b] {break}
        return [normalize [list $signeA $entierA $expA $deltaA]]
    }
}

proc ::math::bigfloat::asin {x} {
    foreach {signe entier exp delta} $x {break}
    set precision [expr {($exp<0)?(-$exp):1}]
    if {[isnull $x]} {
        return [list 1 0[zero $precision] -$precision 1]
    }
    if {$signe<0} {
        return [opp [asin [abs $x]]]
    }
    if {[compare $x [fromstr 0.707]]>0} {
        set pi_sur_deux [intdiv [pi $precision] 2]
        set un [fromstr 1.[zero $precision]]
        if {[equal $un $x]} {
            return $pi_sur_deux
        }
        set x [sqrt [sub $un [mul $x $x]]]
        return [sub $pi_sur_deux [_asin $x]]
    }
    return [normalize [_asin $x]]
}

proc ::math::bigfloat::_asin {x} {
    # asin(x)=x + 1/2 x^3/3 + 3/2.4 x^5/5 + 3.5/2.4.6 x^7/7 + ...
    foreach {signe entier exp delta} $x {break}
    set precision [expr {-$exp}]
    if {$precision+1<[string length $entier]} {
        error "sinus greater than 1 : $x"
    }
    set resultat $entier
    set delta_final $delta
    # resultat contient le resultat final
    set carre [lshift [intMul $entier $entier] $precision]
    # carre contient l'origine au carré
    set dt [lshift [intMul [intMul $entier $delta] 2] $precision]
    set num 1
    set i 3
    set denom 2
    set delta [intAdd [intMul $delta $carre] [intMul $dt $entier]]
    set delta [droite [intDiv [intMul $delta $num] $denom] $precision]
    set entier [lshift [intMul $entier $carre] $precision]
    set entier [intDiv $entier $denom]
    set entier_temp [intDiv $entier $i]
    set delta_temp [intDiv $delta $i]
    while {[intCompare $entier_temp $delta_temp]>0} {
        set resultat [intAdd $resultat $entier_temp]
        set delta_final [intAdd $delta_final $delta_temp]
        set num [intAdd $num 2]
        set i [intAdd $i 2]
        set denom [intAdd $denom 2]
        set delta [intAdd [intMul $delta $carre] [intMul $dt $entier]]
        set delta [droite [intDiv [intMul $delta $num] $denom] $precision]
        set entier [lshift [intMul $entier $carre] $precision]
        set entier [intDiv [intMul $entier $num] $denom]
        set entier_temp [intDiv $entier $i]
        set delta_temp [intDiv $delta $i]
    }
    return [list 1 $resultat $exp $delta_final]
}

proc ::math::bigfloat::atan {x} {
    foreach {signe entier exp delta} $x {break}
    set precision [expr {($exp<0)?-$exp+1:1}]
    if {[isnull $x]} {
        return [list 1 0[zero $precision] -$precision 1]
    }
    if {$signe<0} {
        return [opp [atan [abs $x]]]
    }
    set un [list 1 1[zero $precision] -$precision 1]
    if {[compare $un $x]<0} {
        # atan(1/x)=Pi/2-atan(x)
        if {[compare $x [fromstr 2.380]]<0} {
            set pi_sur_quatre [intdiv [pi $precision] 4]
            return [add $pi_sur_quatre [atan \
                    [div [sub $x $un] [add $x $un]]]]
        }
        set pi_sur_deux [intdiv [pi $precision] 2]
        return [sub $pi_sur_deux [atan [div $un $x]]]
    }
    if {[compare $x [fromstr 0.420]]>0} {
        set pi_sur_quatre [intdiv [pi $precision] 4]
        return [sub $pi_sur_quatre [atan \
                [div [sub $un $x] [add $un $x]]\
                ]]
    }
    set precision [expr {-$exp}]
    set n [expr {int($precision*log(10)/log(42)+1)}]
    incr precision $n
    append entier [zero $n]
    append delta [zero $n]
    set result $entier
    set delta_fin $delta
    set delta_carre [intMul $delta 2]
    set carre [lshift [intMul $entier $entier] $precision]
    set div 3
    set signe -1
    set delta [droite [intAdd [intMul $delta_carre $entier] \
            [intMul $delta $carre]] $precision]
    set temp [lshift [intMul $entier $carre] $precision]
    set t [intDiv $temp $div]
    set dt [incrdiv $delta $div]
    while {![intIsZero $t]} {
        if {$signe<0} {
            set result [intSub $result $t]
        } else  {
            set result [intAdd $result $t]
        }
        set delta_fin [intAdd $delta_fin $dt]
        set div [expr {$div+2}]
        set signe [expr {-$signe}]
        set delta [droite [intAdd [intMul $delta_carre $temp] \
                [intMul $delta $carre]] $precision]
        set temp [lshift [intMul $temp $carre] $precision]
        set t [intDiv $temp $div]
        set dt [incrdiv $delta $div]
    }
    return [normalize [list 1 $result [expr {$exp-$n}] $delta_fin]]
}

proc ::math::bigfloat::_atanfract {entier precision} {
    set n [expr {int($precision*log(10)/log(25)+1)}]
    incr precision $n
    set un 1[zero $precision]
    set a [intDiv $un $entier]
    set s $a
    set carre [intMul $entier $entier]
    set signe -1
    set denom 3
    set t [intDiv $a $carre]
    set u [intDiv $t $denom]
    while {![intIsZero $u]} {
        if {$signe>0} {
            set s [intAdd $s $u]
        } else  {
            set s [intSub $s $u]
        }
        set denom [intAdd $denom 2]
        set t [intDiv $t $carre]
        set u [intDiv $t $denom]
        set signe [expr {-$signe}]
    }
    return [lshift $s $n]
}

################################################################################
# retourne la partie entière (ou 0) du nombre "number" comme la fonction ceil()
################################################################################
proc ::math::bigfloat::ceil {number} {
    set number [fromstr [tostr $number]]
    foreach {signe entier exp delta} $number {break}
    set l [string length $entier]
    if {$l+$exp<=0} {
        return [expr {![intIsZero $entier]}]
    }
    set last [string range $entier [expr {$l+$exp}] end]
    set entier [string range $entier 0 [expr {$l+$exp-1}]]
    if {![intIsZero $last]&& $signe>0} {
        set entier [intAdd $entier 1]
    }
    if {$signe<0 && ![intIsZero $entier]} {set entier "-$entier"}
    return $entier
}

# returns 0 if A and B are equal, else returns 1 or -1
# accordingly to the sign of (A - B)
proc ::math::bigfloat::compare {a b} {
    if {[equal $a $b]} {return 0}
    foreach {signeA entierA expA deltaA} $a {break}
    foreach {signeB entierB expB deltaB} $b {break}
    if {$signeA!=$signeB} {
        return $signeA
    }
    set la [string length $entierA]
    set lb [string length $entierB]
    incr la $expA
    incr lb $expB
    if {$la!=$lb} {
        if {$la>$lb} {
            return $signeA
        }
        return [expr {-$signeA}]
    }
    set diff [expr {$expA-$expB}]
    if {$diff<0} {
        set diff [expr {-$diff}]
        append entierB [zero $diff]
    } else {
        append entierA [zero $diff]
    }
    set c [intCompare $entierA $entierB]
    return [expr {$c*$signeA}]
}


################################################################################
# gets cos(x)
# throws an error if there is not enough precision on the input
################################################################################
proc ::math::bigfloat::cos {x} {
    foreach {signe entier exp delta} $x {break}
    if {$exp>-2} {
        error "not enough precision on floating-point number"
    }
    set precision [expr {-$exp}]
    # cos(2kPi+x)=cos(x)
    foreach {n entier} [divPiQuarter $signe $entier $precision] {break}
    set delta [intAdd $n $delta]
    # maintenant entier>=0
    set d [intMod $n 4]
    set signe 1
    # cos(Pi-x)=-cos(x)
    # cos(-x)=cos(x)
    switch -- $d {
        1 {set signe -1;set l [_sin2 $entier $precision $delta]}
        2 {set signe -1;set l [_cos2 $entier $precision $delta]}
        0 {set l [_cos2 $entier $precision $delta]}
        3 {set l [_sin2 $entier $precision $delta]}
        default {error "internal error"}
    }
    lset l 1 [expr {-([lindex $l 1])}]
    return [normalize [linsert $l 0 $signe]]
}


proc ::math::bigfloat::_cos2 {x precision delta} {
    set pi [_pi $precision]
    set pis4 [rnddiv $pi 4]
    set pis2 [rnddiv $pi 2]
    if {[intCompare $x $pis4]>=0} {
        # cos(Pi/2-x)=sin(x)
        set x [intSub $pis2 $x]
        incr delta 1
        return [_sin $x $precision $delta]
    }
    return [_cos $x $precision $delta]
}

# cos(x) avec x positif inferieur a Pi/4
proc ::math::bigfloat::_cos {x precision delta} {
    set un 1[zero $precision]
    set s $un
    set d [intMul $x [intMul $delta 2]]
    set d [droite $d $precision]
    set x [lshift [intMul $x $x] $precision]
    set denom1 1
    set denom2 2
    set signe -1
    set t [intDiv $x 2]
    set delta 0
    set dt $d
    while {![intIsZero $t]} {
        if {$signe<0} {
            set s [intSub $s $t]
        } else  {
            set s [intAdd $s $t]
        }
        set delta [intAdd $delta $dt]
        set denom1 [intAdd $denom1 2]
        set denom2 [intAdd $denom2 2]
        set dt [droite [intAdd [intMul $x $dt]\
                [intMul $t $d]] $precision]
        set t [lshift [intMul $x $t] $precision]
        set t [intDiv $t [intMul $denom1 $denom2]]
        set signe [expr {-$signe}]
    }
    return [list $s $precision $delta]
}


proc ::math::bigfloat::cotan {x} {
    return [::math::bigfloat::div [::math::bigfloat::cos $x] [::math::bigfloat::sin $x]]
}

proc ::math::bigfloat::divPiQuarter {signe entier precision} {
    set dpi [lshift [intMul [_pi [expr {1+$precision}]] 2]]
    # modulo 2Pi
    foreach {n entier} [intDivqr $entier $dpi] {break}
    if {$signe<0} {
        set entier [intSub $dpi $entier]
    }
    # fin modulo 2Pi
    set pi [_pi $precision]
    foreach {n entier} [intDivqr $entier $pi] {break}
    # on divise en réalité par Pi/2
    set n [intMul $n 2]
    set pis2 [rnddiv $pi 2]
    foreach {m entier} [intDivqr $entier $pis2] {break}
    return [list [intAdd $n $m] $entier]
}


################################################################################
# divide A by B and returns the result
# throw error : divide by zero
################################################################################
proc ::math::bigfloat::div {a b} {
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [intDiv $a $b]
        }
        error "trying to divide a BigInt by a BigFloat"
    }
    if {[isInt $b]} {return [intdiv $a $b]}
    foreach {signeA entierA expA deltaA} $a {break}
    foreach {signeB entierB expB deltaB} $b {break}
    foreach {signeBMoinsDelta BMoinsDelta} [intSAdd $signeB $entierB -1 $deltaB] {break}
    foreach {signeBPlusDelta BPlusDelta} [intSAdd $signeB $entierB 1 $deltaB] {break}
    if {$signeBMoinsDelta*$signeBPlusDelta<0 || [intIsZero $BMoinsDelta] \
                || [intIsZero $BPlusDelta]} {
        error "divide by zero"
    }
    set l [string length $entierB]
    append entierA [zero $l]
    append deltaA [zero $l]
    set exp [expr {$expA-$l-$expB}]
    # d(A/B)/(A/B)=dA/A + dB/B
    # dQ=dA/B + dB*A/B*B
    # QB+R=A so R=A-QB
    # dR/R=dA/R+dQ*dB/(B*Q)
    # dR = dA+dQ*dB*R/(B*Q)
    # dQ is "delta" and dR is "deltaReste"
    set delta [incrdiv [intMul $deltaB \
            $entierA] $entierB]
    set delta [incrdiv [intAdd $delta $deltaA] $entierB]
    set quotient [intDiv $entierA $entierB]
    return [normalize [list [expr {$signeA*$signeB}] $quotient $exp $delta]]
}

################################################################################
# divide a floating-point number A by an integer B
# throw error : divide by zero
################################################################################
proc ::math::bigfloat::intdiv {a b} {
    foreach {signe entier exp delta} $a {break}
    if {![isInt $b]} {
        error "intdiv : divider is not an integer"
    }
    if {[intIsZero $b]} {
        error "intdiv : divide by zero"
    }
    set l [string length $b]
    append entier [zero $l]
    append delta [zero $l]
    incr exp -$l
    set entier [intDiv $entier $b]
    set delta [rnddiv $delta $b]
    return [normalize [list $signe $entier $exp $delta]]
}

# returns 1 if A and B are equal, 0 otherwise
proc ::math::bigfloat::equal {a b} {
    foreach {asigne aint aexp adelta} $a {break}
    foreach {bsigne bint bexp bdelta} $b {break}

    foreach {asupSigne asupInt} [intSAdd $asigne $aint 1 $adelta] {break}
    foreach {ainfSigne ainfInt} [intSAdd $asigne $aint -1 $adelta] {break}
    foreach {bsupSigne bsupInt} [intSAdd $bsigne $bint 1 $bdelta] {break}
    foreach {binfSigne binfInt} [intSAdd $bsigne $bint -1 $bdelta] {break}
    set diff [expr {$aexp-$bexp}]
    if {$diff<0} {
        set diff [expr {-$diff}]
        append bsupInt [zero $diff]
        append binfInt [zero $diff]
        append bint [zero $diff]
    } else {
        append asupInt [zero $diff]
        append aint [zero $diff]
        append ainfInt [zero $diff]
    }
    if {[intSCompare $bsigne $bint $asigne $aint]>0} {
        return [expr {[intSCompare $asupSigne $asupInt $binfSigne $binfInt]>=0}]
    } else {
        return [expr {[intSCompare $bsupSigne $bsupInt $ainfSigne $ainfInt]>=0}]
    }
}

# returns exp(X)
proc ::math::bigfloat::exp {x} {
    foreach {signe entier exp delta} $x {break}
    if {$exp>=0} {
        incr exp
        append entier [zero $exp]
        append delta [zero $exp]
        set exp -1
    }
    return [normalize [_exp1 $signe $entier $exp $delta]]
}


proc ::math::bigfloat::_exp1 {signe entier exp delta} {
    set precision [expr {-$exp}]
    incr precision
    append entier 0
    append delta 0
    set log10 [_log10 $precision]
    set new_exp [intDiv $entier $log10]
    # si x<0 x=-K.log(10)+r     where K and r are >0
    if {$signe<0} {
        set new_exp [intAdd $new_exp 1]
    }
    # new_exp = integer part of x/log(10)
    # exp(K.log(10)+r)=10^K.exp(r)
    set delta [intAdd $delta $new_exp]
    foreach {signeT entier} [intSAdd 1 $entier -1\
            [intMul $new_exp $log10]] {break}
    foreach {entier delta} [_exp $entier $precision $delta] {break}
    set delta [droite $delta 1]
    incr precision -1
    # multiplier par 10^K en tenant compte du signe
    # exemple : X=-6.log(10)+0.01
    # exp(X)=exp(0.01)*1e-6
    set exp [expr {$signe*$new_exp-$precision}]
    return [list 1 [lshift $entier] $exp $delta]
}



proc ::math::bigfloat::_exp {entier precision delta} {
    if {[intCompare $entier 0]==0} {
        return [list 1[zero $precision] $delta]
    }
    set un 1[zero $precision]
    set s [intAdd $un $entier]
    set d $delta
    set dt [droite [intMul $d $entier] $precision]
    set t [lshift [intMul $entier $entier] $precision]
    set t [intDiv $t 2]
    set denom 2
    while {![intIsZero $t]} {
        set s [intAdd $s $t]
        set delta [intAdd $delta $dt]
        set denom [intAdd $denom 1]
        set dt [intAdd $dt $d]
        set t [lshift [intMul $entier $t] $precision]
        set t [intDiv $t $denom]
    }
    return [list $s $delta]
}


################################################################################
# retourne la partie entière (ou 0) du nombre "number" comme la fonction floor()
# bug : si le nombre est 0.000000... ça plante
################################################################################
proc ::math::bigfloat::floor {number} {
    set number [fromstr [tostr $number]]
    foreach {signe entier exp delta} $number {break}
    # calculons la borne supérieure et la borne inférieure de
    # l'intervalle de confiance
    set l [string length $entier]
    # si l'entier a 0 pour partie entière
    if {$l+$exp<=0} {
        # si l'entier est >0 retourner 0
        # sinon (entier < 0) retourner :
        # ### -1 si différent de zero, sinon 0
        return [expr {-(![intIsZero $entier])*($signe<0)}]
    }
    set last [string range $entier [expr {$l+$exp}] end]
    set entier [string range $entier 0 [expr {$l-1+$exp}]]
    # si signe>0 : ne rien faire (retourner la partie entière)
    # si signe<0 :
    #                - si last=0 ne rien faire
    #                - si last<>0 incrémenter la partie entière
    if {![intIsZero $last]&& $signe<0} {
        set entier [intAdd $entier 1]
    }
    if {$signe<0 && ![intIsZero $entier]} {set entier "-$entier"}
    return $entier
}


################################################################################
# returns a list formed by an integer and an exponent
# x = (A +/- C) * 10 power B
# return [list S A B C] (where S is the sign of A)
################################################################################
proc ::math::bigfloat::fromstr {chaine} {
    set tab [split $chaine e]
    if {[llength $tab]>2} {error "syntax error in number : $chaine"}
    if {[llength $tab]==2} {
        set exp [lindex $tab 1]
        set nombre [lindex $tab 0]
    } else {
        set exp 0
        set nombre [lindex $tab 0]
    }
    if {[string equal [string index $nombre 0] "-"]} {
        set signe -1
        set nombre [string range $nombre 1 end]
    } else {
        set signe 1
    }
    set delta 1
    set tab [split $nombre .]
    if {[llength $tab]>2} {error "syntax error in number : $chaine"}
    if {[llength $tab]==2} {
        set nombre [lindex $tab 0]
        set fin [lindex $tab 1]
        incr exp -[string length $fin]
        append nombre $fin
    }
    set padding [expr {1-($exp+[string length $nombre])}]
    set padding [expr {($padding>0)?($padding):0}]
    return [list $signe [zero $padding]$nombre $exp $delta]
}






################################################################################
# returns 1 if x is null, 0 otherwise
################################################################################
proc ::math::bigfloat::isnull {x} {
    foreach {signe entier exp delta} $x {break}
    if {[intCompare $delta $entier]>=0} {return 1}
    return 0
}


################################################################################
# compute log(X)
################################################################################
proc ::math::bigfloat::log {x} {
    foreach {signe entier exp delta} $x {break}
    set entier [Dec $entier]
    if {$signe<0 || ![intCompare $entier 0]} {
        error "zero logarithm error"
    }
    if {$exp<0} {
        set precision [expr {-$exp}]
        set pad [zero $precision]
    } else {
        set pad ""
        append entier [zero $exp]
        append delta [zero $exp]
        set precision 0
    }
    set n 0
    # maintenant : la précision est au moins au niveau de l'entier
    # tant que x sera supérieur à 1, on le divisera par 2
    while {[intCompare $entier 1$pad]>=0} {
        incr n
        set entier [intMul $entier 5]
        set delta [intMul $delta 5]
        append pad 0
        incr precision
    }
    set pad [string range $pad 0 end-1]
    # pour le cas où x<0.5 on le multipliera par 2
    while {[intCompare $entier 5$pad]<0} {
        set entier [intMul $entier 2]
        set delta [intMul $delta 2]
        incr n -1
    }
    # maintenant 0.5<= x <1.0
    # attention : _log retourne un entier positif
    foreach {entier delta} [_log $entier $delta] {break}
    # même lorsque n est négatif
    # log(a*2^n)= log(a)+n*log(2)
    set signeN [expr {$n<0?-1:1}]
    set n [expr {$n<0?-$n:$n}]
    # resultat = log(x)+n.log(2)
    foreach {signe entier} [intSAdd -1 $entier \
            $signeN [intMul [_log2 $precision] $n]] {break}
    set delta [intAdd $delta $n]
    return [normalize [list $signe $entier [expr {-$precision}] $delta]]
}


# compute log(0.entier)
proc ::math::bigfloat::_log {entier delta} {
    append entier 0
    append delta 0
    set l [string length $entier]
    set un 1[zero $l]
    set entier [intSub $un $entier]
    set s $entier
    set d $delta
    set dt [droite [intMul $delta $entier] $l]
    set t [intMul $entier $entier]
    set t [lshift $t $l]
    set denom 2
    set u [intDiv $t $denom]
    while {[intCompare $u 0]} {
        set s [intAdd $s $u]
        set delta [intAdd $delta $dt]
        set dt [droite [intAdd [intMul $d $t]\
                [intMul $dt $entier]] $l]
        set t [lshift [intMul $t $entier] $l]
        set denom [intAdd $denom 1]
        set u [intDiv $t $denom]
    }
    return [list [lshift $s] [droite $delta 1]]
}

proc ::math::bigfloat::__log {num denom precision} {
    # p is the precision
    # pk is the precision increment
    # 10 power pk is also the maximum number of iterations
    # for a number close to 1 but lower than 1,
    # (denom-num)/denum is (in our case) lower than 1/5
    # so the maximum nb of iterations is for:
    # 1/5*(1+1/5*(1/2+1/5*(1/3+1/5*(...))))
    # the last term is 1/n*(1/5)**n
    # for the last term to be lower than 10**(-p-pk)
    # the number of iterations has to be
    # 10**(-pk).(1/5)**(10**pk) < 10**(-p-pk)
    # log(1/5).10**pk < -p
    # 10**pk > p/log(5)
    # pk > log(10)*log(p/log(5))
    # now set the variable n to the precision increment i.e. pk
    set n [expr {int(log(10)*log($precision/log(5)))+1}]
    incr precision $n
    set num [expr {$denom-$num}]
    set s [intDiv "$num[zero $precision]" $denom]
    set t [intDiv [intMul $s $num] $denom]
    set d 2
    set u [intDiv $t $d]
    while {![intIsZero $u]} {
        set s [intAdd $s $u]
        set t [intDiv [intMul $t $num] $denom]
        set d [intAdd $d 1]
        set u [intDiv $t $d]
    }
    return [lshift $s $n]
}


# compute log(10)
proc ::math::bigfloat::_log10 {precision} {
    global log10
    incr precision 2
    if {[catch {set a $log10}]} {
        __logbis $precision
    } else {
        set l [string length $log10]
        if {$precision>$l-1} {
            __logbis $precision
        }
    }
    incr precision -1
    return [_round $log10 $precision]
}

proc ::math::bigfloat::__logbis {precision} {
    incr precision 2
    # ln(2)=3*ln(1-4/5)+ln(1-125/128)
    set a [__log 125 128 $precision]
    set b [__log 4 5 $precision]
    set r [intAdd [intMul $b 3] $a]
    global log2
    set log2 [string range $r 0 end-2]
    # ln(10)=10.ln(1-4/5)+3*ln(1-125/128)
    set r [intAdd ${b}0 [intMul $a 3]]
    global log10
    set log10 [lshift $r 2]
}


# compute log(2)
proc ::math::bigfloat::_log2 {precision} {
    global log2
    if {![info exists log2]} {
        __logbis $precision
    } else {
        set l [string length $log2]
        if {$precision>$l} {
            __logbis $precision
        }
    }
    return [_round $log2 $precision]
}


################################################################################
# returns A modulo B (like with fmod() math function
################################################################################
proc ::math::bigfloat::mod {a b} {
    if {[isInt $a] && [isInt $b]} {return [intMod $a $b]}
    if {[isInt $a]} {error "trying to divide a BigInt by a BigFloat"}
    set quotient [div $a $b]
    if {[sign $quotient]<0} {
        set quotient [ceil [opp $quotient]]
        return [add $a [mul $b $quotient]]
    }
    set quotient [floor $quotient]
    return [sub $a [mul $b $quotient]]
}

################################################################################
# returns A times B
################################################################################
proc ::math::bigfloat::mul {a b} {
    if {[isInt $a]} {
        if {[isInt $b]} {
            return [intMul $a $b]
        }
        return [intmul $b $a]
    }
    if {[isInt $b]} {return [intmul $a $b]}
    foreach {signeA entierA expA deltaA} $a {break}
    foreach {signeB entierB expB deltaB} $b {break}
    set exp [expr {$expA+$expB}]
    set entier [intMul $entierA $entierB]
    set signe [expr {$signeA*$signeB}]
    set deltaA [intMul $entierB $deltaA]
    set deltaB [intMul $entierA $deltaB]
    set delta [intAdd $deltaA $deltaB]
    return [normalize [list $signe $entier $exp $delta]]
}

################################################################################
# returns A times B, where B is a positive integer
################################################################################
proc ::math::bigfloat::intmul {a b} {
    foreach {signe entier exp delta} $a {break}
    if {![isInt $b]} {
        error "intmul : second argument is not an integer"
    }
    set entier [intMul $entier $b]
    set delta [intMul $delta $b]
    return [normalize [list $signe $entier $exp $delta]]
}

##################################################
# normalizes a number : delta (incertitude)
# has to be one digit only to avoid increases of
# the memory footprint of the number
##################################################
proc ::math::bigfloat::normalize {number} {
    foreach {signe entier exp delta} $number {break}
    set l [string length $delta]
    if {$l>1} {
        incr l -1
        set delta [droite $delta $l]
        set entier [lshift $entier $l]
        incr exp $l
    }
    set padding [expr {1-($exp+[string length $entier])}]
    set padding [expr {($padding>0)?($padding):0}]
    return [list $signe [zero $padding]$entier $exp $delta]
}



# returns -A
proc ::math::bigfloat::opp {a} {
    lset a 0 [expr {-[lindex $a 0]}]
    return $a
}

################################################################################
# gets Pi with precision digits
# after the dot (after you call [tostr] on the result)
################################################################################
proc ::math::bigfloat::pi {precision} {
    return [list 1 [_pi $precision] -$precision 1]
}

proc ::math::bigfloat::_pi {precision} {
    global _pi0
    incr precision
    if {![info exists _pi0]} {
        set _pi0 [__pi $precision]
    } elseif {[string length $_pi0]<$precision} {
        set _pi0 [__pi $precision]
    }
    if {[string length $_pi0]==$precision} {
        return $_pi0
    }
    return [_round $_pi0 $precision]
}

proc ::math::bigfloat::__pi {precision} {
    incr precision 3
    set a [intMul [_atanfract 18 $precision] 48]
    set a [intAdd $a [intMul [_atanfract 57 $precision] 32]]
    set a [intSub $a [intMul [_atanfract 239 $precision] 20]]
    incr precision -3
    return [_round $a $precision]
}

proc ::math::bigfloat::_round {entier precision} {
    return [lshift $entier [expr {[string length $entier] - $precision}]]
}

################################################################################
# returns A power B, where B is a positive integer
################################################################################
proc ::math::bigfloat::pow {a b} {
    if {![isInt $b]} {
        error "pow : exponent is not a postive integer"
    }
    set res un
    while {1} {
        foreach {quotient reste} [intDivqr $b 2] {break}
        set b $quotient
        if {$reste} {
            if {$res=="un"} {
                set res $a
            } else  {
                set res [mul $res $a]
            }
        }
        if {[intIsZero $b]} {
            return $res
        }
        set a [mul $a $a]
    }
}

################################################################################
# retourne la partie entière (ou 0) du nombre "number"
################################################################################
proc ::math::bigfloat::round {number} {
    foreach {signe entier exp delta} $number {break}
    # calculons la borne supérieure et la borne inférieure de
    # l'intervalle de confiance
    foreach {signeSup entierSup} [intSAdd $signe $entier 1 $delta] {}
    foreach {signeInf entierInf} [intSAdd $signe $entier -1 $delta] {}
    # si les signes sont différents, cela signifie que la valeur finale
    # sera 0, donc le signe doit être positif
    if {$signeSup != $signeInf} {
        set signeSup 1
        set signeInf 1
    }
    # diminuer la précision jusqu'à ce que les deux entiers soient identiques
    set diviseur 10
    set entierSup2 [rnddiv $entierSup $diviseur]
    set entierInf2 [rnddiv $entierInf $diviseur]
    incr exp
    while {[intCompare $entierSup2 $entierInf2]} {
        append diviseur 0
        set entierSup2 [rnddiv $entierSup $diviseur]
        set entierInf2 [rnddiv $entierInf $diviseur]
        incr exp
    }
    set entier $entierSup2
    set l [string length $entier]
    if {$l+$exp<1} {
        return [expr {$signeSup*([string index $entier 0]>=5)}]
    }
    set last [string index $entier [expr {$l+$exp}]]
    set entier [string range $entier 0 [expr {$l+$exp-1}]]
    if {$last>=5} {
            set entier [intAdd $entier 1]
    }
    if {$signe<0 && ![intIsZero $entier]} {set entier "-$entier"}
    return $entier
}

################################################################################
# returns the sign of x : 1 when positive or zero, -1 when negative
################################################################################
proc ::math::bigfloat::sign {x} {
    return [lindex $x 0]
}


# gets sin(x)
proc ::math::bigfloat::sin {x} {
    foreach {signe entier exp delta} $x {break}
    if {$exp>-2} {
        error "sin : not enough precision"
    }
    set precision [expr {-$exp}]
    # 2*Pi
    set pi [_pi [expr {1+$precision}]]
    set dpi [lshift [intDiv $pi 2]]
    # sin(2kPi+x)=sin(x)
    # sin(Pi-x)=sin(x)
    foreach {n entier} [divPiQuarter $signe $entier $precision] {break}
    set delta [intAdd $delta $n]
    set d [intMod $n 4]
    # maintenant entier>=0
    # sin(2Pi-x)=-sin(x)
    # sin(Pi/2+x)=cos(x)
    set signe 1
    switch  -- $d {
        0 {set l [_sin2 $entier $precision $delta]}
        1 {set l [_cos2 $entier $precision $delta]}
        2 {set signe -1;set l [_sin2 $entier $precision $delta]}
        3 {set signe -1;set l [_cos2 $entier $precision $delta]}
        default {error "internal error"}
    }
    lset l 1 [expr {-([lindex $l 1])}]
    return [normalize [linsert $l 0 $signe]]
}

proc ::math::bigfloat::_sin2 {x precision delta} {
    set pi [_pi [expr {1+$precision}]]
    set pis2 [lshift [intDiv $pi 2]]
    set pis4 [lshift [intDiv $pi 4]]
    if {[intCompare $x $pis4]>=0} {
        # sin(Pi/2-x)=cos(x)
        incr delta 1
        set x [intSub $pis2 $x]
        return [_cos $x $precision $delta]
    }
    return [_sin $x $precision $delta]
}

# sin(x) avec x positif inferieur a Pi/4
proc ::math::bigfloat::_sin {x precision delta} {
    set s $x
    set double [droite [intMul 2 [intMul $x $delta]] $precision]
    set x [lshift [intMul $x $x] $precision]
    set dt [droite [intAdd [intMul $x $delta] [intMul $s $double]] $precision]
    set t [lshift [intMul $s $x] $precision]
    set denom2 2
    set denom3 3
    set t [intDiv $t 6]
    set signe -1
    while {![intIsZero $t]} {
        if {$signe<0} {
            set s [intSub $s $t]
        } else  {
            set s [intAdd $s $t]
        }
        set delta [intAdd $delta $dt]
        set signe [expr {-$signe}]
        set denom2 [intAdd $denom2 2]
        set denom3 [intAdd $denom3 2]
        set dt [droite [intAdd [intMul $x $dt] [intMul $t $double]] $precision]
        set t [lshift [intMul $t $x] $precision]
        set dt [intAdd $dt $double]
        set t [intDiv $t [intMul $denom2 $denom3]]
    }
    return [list $s $precision $delta]
}

################################################################################
# square root with Newton-Raphson algorithm
################################################################################
proc ::math::bigfloat::sqrt {x} {
    # si x=0, retourner 0
    foreach {signe entier exp delta} $x {break}
    set len [expr {($exp<0)?(-$exp):1}]
    if {[intIsZero $entier]} {
        return 0.[zero $len]
    }
    # si x est negatif erreur de signe
    if {[lindex $x 0]<0} {
        error "negative sqrt : $x"
    }
    set x_initial $x
    set x_suivant [intdiv [add $x [list 1 1[zero $len] -$len 1]] 2]
    while {![equal $x $x_suivant]} {
        set x $x_suivant
        set x_suivant [intdiv [add $x [div $x_initial $x]] 2]
    }
    return $x
    #return [exp [intdiv [log $x] 2]]
}


# substract
proc ::math::bigfloat::sub {a b} {
    if {[isInt $a]} {
        if {[isInt $b]} {
            # warning : they are positive integers
            # so : [intSub 1 2] returns 0, not -1 !!
            return [intSub $a $b]
        }
        return [add $a [opp $b]]
    }
    if {[isInt $b]} {
        return [opp [add [opp $a] $b]]
    }
    return [add $a [opp $b]]
}

# tangente
proc ::math::bigfloat::tan {x} {
    return [::math::bigfloat::div [::math::bigfloat::sin $x] [::math::bigfloat::cos $x]]
}



################################################################################
# convertit en double avec la variable
# globale tcl_precision
################################################################################
proc ::math::bigfloat::todouble {x} {
    global tcl_precision
    set x [normalize $x]
    foreach {signe entier exp delta} $x {break}
    set entier [Dec $entier]
    set l [string length $entier]
    set tronquer [expr {$l-$tcl_precision}]
    if {$tronquer<=0} {
        return [tostr $x]
    }
    set entier [lshift $entier $tronquer]
    set delta [droite $delta $tronquer]
    if {[string length $entier]>$tcl_precision+1} {
        incr tronquer
        set entier [lshift $entier]
        set delta [droite $delta 1]
    }
    incr exp $tronquer
    set isZero [intIsZero $entier]
    set l [string length $entier]
    if {$exp>0} {
        incr exp $l
        incr exp -1
        set entier [string index $entier 0].[string range $entier 1 end]
        append entier "e+$exp"
    } elseif {$exp==0} {
        # no-op
    } else {
        set exp [expr {-$exp}]
        if {$exp < $l} {
            set n [string range $entier 0 end-$exp]
            incr exp -1
            append n .[string range $entier end-$exp end]
            set entier $n
        } elseif {$l==$exp} {
            set entier "0.$entier"
        } else  {
            set entier "[string index $entier 0].[string range $entier 1 end]e-[expr {$exp-$l+1}]"

        }
    }
    if {$signe<0 && !$isZero} {set entier "-$entier"}
    return $entier
}

################################################################################
# converts a number stored as a list to a string in which all digits are true
################################################################################
proc ::math::bigfloat::tostr {number} {
    foreach {signe entier exp delta} $number {break}
    if {[intCompare $entier 0]} {
        if {[intCompare $entier $delta]<=0} {
            return 0
        }
    }
    # calculons la borne supérieure et la borne inférieure de
    # l'intervalle de confiance
    foreach {signeSup entierSup} [intSAdd $signe $entier 1 $delta] {}
    foreach {signeInf entierInf} [intSAdd $signe $entier -1 $delta] {}
    # diminuer la précision jusqu'à ce que les deux entiers soient identiques
    set decalage 1
    set entierSup2 $entierSup
    set entierInf2 $entierInf
    while {[intCompare $entierSup2 $entierInf2] && $signeInf==$signeSup} {
        set entierSup2 [lshift $entierSup $decalage]
        set entierInf2 [lshift $entierInf $decalage]
        incr exp
        incr decalage
        if {[intIsZero $entierSup] && [intIsZero $entierInf]} {
            set entierSup [zero [expr {1-$exp}]]
            break
        }
    }
    incr decalage -1
    set entier [lshift $entier $decalage]
    set isZero [intIsZero $entier]
    set l [string length $entier]
    if {$exp>0} {
        incr exp $l
        incr exp -1
        set entier [string index $entier 0].[string range $entier 1 end]
        append entier "e+$exp"
    } elseif {$exp==0} {
        # no-op
    } else {
        set exp [expr {-$exp}]
        if {$exp < $l} {
            set n [string range $entier 0 end-$exp]
            incr exp -1
            append n .[string range $entier end-$exp end]
            set entier $n
        } elseif {$l==$exp} {
            set entier "0.$entier"
        } else  {
            set entier "[string index $entier 0].[string range $entier 1 end]e-[expr {$exp-$l+1}]"

        }
    }
    if {$signe<0 && !$isZero} {set entier "-$entier"}
    return $entier
}

################################################################################
# PART IV
# HYPERBOLIC FUNCTIONS
################################################################################

################################################################################
# hyperbolic cosinus
################################################################################
proc ::math::bigfloat::cosh {x} {
    return [intdiv [add [exp $x] [exp [opp $x]]] 2]
}

################################################################################
# hyperbolic sinus
################################################################################
proc ::math::bigfloat::sinh {x} {
    return [intdiv [sub [exp $x] [exp [opp $x]]] 2]
}

################################################################################
# hyperbolic tangent
################################################################################
proc ::math::bigfloat::tanh {x} {
    set up [exp $x]
    set down [exp [opp $x]]
    return [div [sub $up $down] [add $up $down]]
}



package provide math::bigfloat 1.0
