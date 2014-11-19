###
# global.tcl
#
# This file defines Global functions that are genuinely useful
#
# Copyright (c) 2012 Sean Woods
#
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.
###

###
# topic: 4dffef8f-9697-b8e7-e868-c3ad6cae2f00
# description: Export a namespace as an ensemble command
###
proc ::ensemble_build namespace {
  #if {[info command $namespace] ne {}} {
  #  return
  #}
  namespace eval $namespace {
    namespace export *
    namespace ensemble create
  }
}

###
# topic: 74aa80cd-d83e-751b-aa89-c413b6834b12
# description:
#    Provide an implementation in Tcl
#    for a function if none exists already in C
###
proc ::ensemble_method {name args body} {
  #puts [list ensemble_method $name [info script]]
  if {[info command $name] ne {}} return
  #proc $name $args "puts $name \n $body"
  proc $name $args $body
}

###
# topic: b5d61f3f-0b7b-1501-3a31-36f8bb51d09a
# type: ensemble_method
###
ensemble_method ::dictGet {dictvar args} {
  if {[dict exists $dictvar {*}$args]} {
    return [dict get $dictvar {*}$args]
  }
  return {}
}

###
# topic: 58ef6deb-c315-edf9-c8ec-fe5ed710b07d
# type: ensemble_method
###
ensemble_method ::get varname {
  upvar 1 $varname var
  if {[info exists var]} {
    return [set var]
  }
  return {}
}

###
# topic: 84ff222d-9f57-4a40-5804-0b99485cd6ff
# type: ensemble_method
###
ensemble_method ::ladd {varname args} {
  upvar 1 $varname var
  if ![info exists var] {
    set var {}
  }
  foreach item $args {
    if { $item ni $var} {
      lappend var $item
    }
  }
  return $var
}

###
# topic: 9591fb2c-2d1d-be3e-b92d-6e993589a452
# type: ensemble_method
###
ensemble_method ::ladd_sorted {varname args} {
  upvar 1 $varname var
  if ![info exists var] {
    set var {}
  }
  foreach item $args {
    lappend var $item
  }
  set var [lsort -dictionary -unique $var]
  return $var
}

###
# topic: f0367444-a3ae-9186-1ee8-31f757fc4621
# type: ensemble_method
###
ensemble_method ::ldelete {varname args} {
  upvar 1 $varname var
  if ![info exists var] {
      return
  }
  foreach item [lsort -unique $args] {
    while {[set i [lsearch $var $item]]>=0} {
      set var [lreplace $var $i $i]
    }
  }
}

###
# topic: 7eb9cd40-c276-2439-3938-445605f3aca2
# type: ensemble_method
###
ensemble_method ::noop args {
}

