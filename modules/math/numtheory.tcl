## 
## This is the file `numtheory.tcl',
## generated with the SAK utility
## (sak docstrip/regen).
## 
## The original source files were:
## 
## numtheory.dtx  (with options: `pkg')
## 
## In other words:
## **************************************
## * This Source is not the True Source *
## **************************************
## the true source is the file from which this one was generated.
##
# Copyright (c) 2010, 2015 by Lars Hellstrom.  All rights reserved.
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package require Tcl 8.5
package provide math::numtheory 1.1
namespace eval ::math::numtheory {
   namespace export isprime
}
proc ::math::numtheory::Barrett_mod {N invN shift a} {
   set r [expr {$a - (($a * $invN) >> $shift) * $N}]
   if {$r<0} then {incr r $N}
   return $r
}
proc ::math::numtheory::Barrett_parameters {N} {
   set s [expr {8*[string length [format %llx $N]]}]
   set M [expr {-( (-1 << $s) / $N)}]
   return [list $N $M $s]
}
namespace eval ::math::numtheory {
   namespace ensemble create -command make_modulo -map {
      Barrett-parameters  Barrett_parameters
      prefix              {Make_modulo_prefix 0}
      mulprefix           {Make_modulo_prefix 1}
   }
}
proc ::math::numtheory::Barrett_mulmod {N invN shift x y} {
   set a [expr {$x*$y}]
   set r [expr {$a - (($a * $invN) >> $shift) * $N}]
   if {$r<0} then {incr r $N}
   return $r
}
proc ::math::numtheory::Plain_mod {N a} {expr {$a % $N}}
proc ::math::numtheory::Plain_mulmod {N x y} {expr {$x*$y % $N}}
proc ::math::numtheory::Make_modulo_prefix {mulQ N} {
   set P [Barrett_parameters $N]
   if {[lindex $P 2] >= 1250} then {
      return [linsert $P 0 [
         namespace which [lindex {Barrett_mod Barrett_mulmod} $mulQ]
      ]]
   } else {
      return [list [
         namespace which [lindex {Plain_mod Plain_mulmod} $mulQ]
      ] $N]
   }
}
proc ::math::numtheory::Sliding_window_powm {k i0 iL tL mulmod a} {
   set apow $a
   for {set r 1} {$r < $k} {incr r} {
      set apow [{*}$mulmod $apow $apow]
   }
   set aL [list $apow]
   set r [expr {1 << ($k-1)}]
   while {[llength $aL] < $r} {
      set apow [{*}$mulmod $apow $a]
      lappend aL $apow
   }
   set res [lindex $aL $i0]
   foreach i $iL {
      if {$i < 0} then {
         set res [{*}$mulmod $res $res]
      } else {
         for {set r 0} {$r < $k} {incr r} {
            set res [{*}$mulmod $res $res]
         }
         set res [{*}$mulmod $res [lindex $aL $i]]
      }
   }
   foreach i $tL {
      set res [{*}$mulmod $res $res]
      if {$i} then {
         set res [{*}$mulmod $res $a]
      }
   }
   return $res
}
proc ::math::numtheory::Sliding_window_cover {k bitlist} {
   if {$k>=2} then {
      set km1 [expr {$k-1}]
      set cost [expr {(1 << $km1) - 2}]
      set imL {}
      set collect 0
      foreach bit $bitlist {
         if {$collect>0} then {
            set i [expr {($i<<1) | $bit}]
            if {[incr collect -1]} then {
               lappend tail $bit
            } else {
               lappend imL $i
               incr cost
            }
         } elseif {$bit} then {
            set tail [list $bit]
            set i 0
            set collect $km1
         } else {
            lappend imL -1
         }
      }
   } else {
      set imL [list 0]
      set tail [lrange $bitlist 1 end]
      set cost 0
      set collect 1
   }
   if {$collect} then {
      foreach bit $tail {incr cost $bit}
   } else {
      set tail {}
   }
   return [list $cost $imL $tail]
}
proc ::math::numtheory::make_powm {b style data} {
   if {$b < 1} then {
      return -code error "Exponent must be positive"
   }
   switch $style {
      modulo {
         set mulmod [make_modulo mulprefix $data]
      }
      mulprefix {
         set mulmod $data
      }
      default {
         return -code error\
           {Modulo style must be "modulo" or "mulprefix"}
      }
   }
   set bitlist [split [string trimleft [
      string map {0 000 1 001 2 010 3 011 4 100 5 101 6 110 7 111}\
        [format %llo $b]
   ] 0] ""]
   if {[llength $bitlist] < 7} then {
      return [list [namespace which Sliding_window_powm]\
        1 0 {} [lrange $bitlist 1 end] $mulmod]
   }
   set x [expr {log([llength $bitlist]-1)/log(2) + 2}]
   set x [expr {$x -
      (log($x) + log($x+1)) / (1/$x + 1/($x+1) + log(2))
   }]
   set k [expr {int($x)}]
   set down [Sliding_window_cover $k $bitlist]
   incr k
   set up [Sliding_window_cover $k $bitlist]
   if {[lindex $down 0] < [lindex $up 0]} then {
      incr k -1
   } else {
      set down $up
   }
   return [list [namespace which Sliding_window_powm]\
     $k [lindex $down 1 0] [lrange [lindex $down 1] 1 end]\
     [lindex $down 2] $mulmod]
}
proc ::math::numtheory::powm {a b N} {{*}[make_powm $b modulo $N] $a}
proc ::math::numtheory::prime_trialdivision {n} {
    if {$n<2}      then {return -code return 0}
    if {$n<4}      then {return -code return 1}
    if {$n%2 == 0} then {return -code return 0}
    if {$n<9}      then {return -code return 1}
    if {$n%3 == 0} then {return -code return 0}
    if {$n%5 == 0} then {return -code return 0}
    if {$n%7 == 0} then {return -code return 0}
    if {$n<121}    then {return -code return 1}
}
proc ::math::numtheory::Miller--Rabin {n s d a} {
    set x 1
    while {$d>1} {
        if {$d & 1} then {set x [expr {$x*$a % $n}]}
        set a [expr {$a*$a % $n}]
        set d [expr {$d >> 1}]
    }
    set x [expr {$x*$a % $n}]
    if {$x == 1} then {return 0}
    for {} {$s>1} {incr s -1} {
        if {$x == $n-1} then {return 0}
        set x [expr {$x*$x % $n}]
        if {$x == 1} then {return 1}
    }
    return [expr {$x != $n-1}]
}
proc ::math::numtheory::isprime {n args} {
    prime_trialdivision $n
    set d [expr {$n-1}]; set s 0
    while {($d&1) == 0} {
        incr s
        set d [expr {$d>>1}]
    }
    if {[Miller--Rabin $n $s $d 2]} then {return 0}
    if {$n < 2047} then {return 1}
    if {[Miller--Rabin $n $s $d 3]} then {return 0}
    if {$n < 1373653} then {return 1}
    if {[Miller--Rabin $n $s $d 5]} then {return 0}
    if {$n < 25326001} then {return 1}
    if {[Miller--Rabin $n $s $d 7] || $n==3215031751} then {return 0}
    if {$n < 118670087467} then {return 1}
    array set O {-randommr 4}
    array set O $args
    for {set i $O(-randommr)} {$i >= 1} {incr i -1} {
        if {[Miller--Rabin $n $s $d [expr {(
           (round(rand()*0x100000000)-1)
           *3 | 1)
           + 10
        }]]} then {return 0}
    }
    return on
}
## 
## 
## End of file `numtheory.tcl'.