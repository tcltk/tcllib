###
# logicset.tcl
#
# This file defines the method needed for the tcl inplementation
# of logical sets
#
# Copyright (c) 2012 Sean Woods
#
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.
###

::namespace eval ::logicset {}

###
# topic: bd1fdea7e32f113f6b4bb1fe7455d5fd
# type: ensemble_method
###
ensemble_method ::logicset::cartesian_product {A B} {
  set result {}
  foreach alement [sort $A] {
    foreach blement [sort $B] {
      lappend result $alement $blement
    }
  }
  return $result
}

###
# topic: d3032d6ab1d1656eafaba99bb80e09a9
# type: ensemble_method
###
ensemble_method ::logicset::contains {setval args} {
  foreach arg $args {
    if { $arg ni $setval } {
      return 0
    }
  }
  return 1
}

###
# topic: d642d345929481a0cd8838b825966629
# type: ensemble_method
###
ensemble_method ::logicset::empty setval {
  if {[llength $setval] == 0} {
    return 1
  }
  return 0
}

###
# topic: aaf4612470853353aba388d113cd0e78
# type: ensemble_method
###
ensemble_method ::logicset::intersection {A B} {
  set result {}
  foreach element $B {
    if { $element in $A } {
      add result $element
    }
  }
  return $result
}

###
# topic: 1a95091f2c9c788e2af75cb815d3b5d2
# type: ensemble_method
###
ensemble_method ::logicset::permutation items {
  set l [llength $items]
  if {[llength $items] < 2} {
    return $items
  } else {
    for {set j 0} {$j < $l} {incr j} {
      foreach subcomb [permutation [lreplace $items $j $j]] {
        lappend res [concat [lindex $items $j] $subcomb]
      }
    }
    return $res
  }
}

###
# topic: 5ff774e03ce3fd9638e03c83a0c7b1a4
# type: ensemble_method
###
ensemble_method ::logicset::remove {setvar args} {
  upvar 1 $setvar result
  if {![info exists result]} {
    set result {}
  }
  foreach arg $args {
    while {[set idx [lsearch $result $arg]] >= 0} {
      set result [lreplace $result $idx $idx]
    }
  }
  return $result
}

###
# topic: ca1ffbc9d3fffbc44a2ed63ed823573d
# type: ensemble_method
###
ensemble_method ::logicset::set_difference {U A} {
  set result {}
  foreach element $A {
    if { $element ni $U } {
      add result $element
    }
  }
  return $result
}

###
# topic: ddb930853ab4a3b361e1fc2133a7c79a
# type: ensemble_method
###
ensemble_method ::logicset::sort A {
  return [lsort -dictionary -unique $A]
}

###
# topic: 13e4ecbf7e85e27fc293a4b42ad48c30
# type: ensemble_method
###
ensemble_method ::logicset::symmetric_difference {A B} {
  set result {}
  foreach element $A {
    if { $element ni $B } {
      add result $element
    }
  }
  foreach element $B {
    if { $element ni $A } {
      add result $element
    }
  }
  return $result
}

###
# topic: 490744282a40261f0d63192290657d9b
# type: ensemble_method
###
ensemble_method ::logicset::union {A B} {
  set result {}
  add result {*}$A
  add result {*}$B
  return $result
}

###
# topic: 30386566-6238-3764-3963-3962333665383
# type: ensemble_method
###
#ensemble_method ::logicset::add {setvar args} {
#  upvar 1 $setvar result
#  if {![info exists result]} {
#    set result {}
#  }
#  foreach arg $args {
#    if { $args ni $result } {
#      lappend result $arg
#    }
#  }
#  return $result
#}











ensemble_build ::logicset

