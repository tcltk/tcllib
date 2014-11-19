### BEGIN COPYRIGHT BLURB
#   
#   TAO - Tcl Architecture of Objects
#   Copyright (C) 2003 Sean Woods
#   
#   See the file "license.terms" for information on usage and redistribution
#   of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#   
### END COPYRIGHT BLURB

package provide listutil 1.7

proc ::tcl::mathfunc::pi {} [list return [expr 4.0*atan(1.0)]]
proc ::tcl::mathfunc::pio2 {} [list return [expr 2.0*atan(1.0)]]
proc ::tcl::mathfunc::sqrt2 {} [list return [expr sqrt(2)]]
proc ::tcl::mathfunc::e {} [list return [expr exp(1)]]

# [dict getnull] is like [dict get] but returns empty string for missing keys.
proc ::tcl::dict::getnull {dictionary args} {
  if {[exists $dictionary {*}$args]} {
    get $dictionary {*}$args
  }
}

namespace ensemble configure dict -map [dict replace\
    [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]

if 0 {
proc ::string::capitalize word {
    # Return $word with its first letter capitalized
    # Needed because sometimes [string totitle] plays games with us
    return [string toupper [string index $word 0]][string range $word 1 end]
}
}

proc iscommand {name} {
    expr {([string length [info command $name]] > 0) || [auto_load $name]}
}

proc makeproc {name arglist body} {
  if {![iscommand $name]} {
    proc $name $arglist $body
  }
}

###
# Make a new md5 command that 
# behaves like the one in tobe
###
if {[info command ::md5::md5] != {} } {
  makeproc md5Hash string {
    return [string tolower [::md5::md5 -hex $string]]
  }
} else {
  makeproc md5Hash string {
    return [irmmd5 $string]
  }
}

###
# proc: ::is_zero value
# title: Returns 1 if the value is zero or null
###
makeproc is_zero value {
  if {[string is false $value]} {
    return 1
  }
  if { $value == 0.0 } {
    return 1
  }
  return 0
}

###
# proc: ::is_zero value
# title: Returns 1 if the value is zero or null
###
makeproc if_zero {value replace} {
  if {[string is false $value]} {
    return $replace
  }
  if { $value == 0.0 } {
    return $replace
  }
  return $value
}
###
# proc: ::is_zero value
# title: Returns 1 if the value is zero or null
###
makeproc if_null {value replace} {
  if {[string is false $value]} {
    return $replace
  }
  if { $value == 0.0 } {
    return $replace
  }
  return $value
}

###
# Print a dict to the screen
###
makeproc pdict value {
  puts ***
  foreach {var val} $value {
    puts "$var: [list $val]"
  }
  puts ***
}

##############################################################
# General use procedures
# proc:  unique
# title: Returns a unique number 
#
makeproc unique {{val 0}} {
  incr val
  makeproc unique "{val $val}" [info body unique]
  return $val
}

makeproc setIfHigher {varname value} {
  upvar 1 $varname var
  if { $var < $value } {
    set var $value
  }
}

makeproc now {} { 
    return [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
}

makeproc dflt {varname i b} {
  upvar 1 $varname a
  if {![info exists a($i)] || $a($i)==""} {
    return $b
  }
  if {$a($i)<0.0} {
     return 0
  }
  return [expr {int($a($i))}]
}

makeproc setVarsFromDict {dictval varlist} {
    foreach var $varlist {
        upvar 1 $var $var
        if ![info exists $var] {
            set $var {}
        }
        if [dict exists $dictval $var] {
            set $var [dict get $dictval $var]
        }
    }
}

makeproc addAutoPath path {
    set path [file normalize $path]
    if ![file exists $path] return
    if { $path in $::auto_path } return
    foreach item $::auto_path {
        if { [file normalize $item] == $path } return
    }
    lappend ::auto_path $path
}

makeproc K {x y} { return $x }

makeproc combine args {
    foreach i $args {
        set c [llength $i]
        if { $c % 2 != 0 } {
            foreach {var val} $i {
                puts [list $var $val]
            }
            error [list Unbalanced Dict: $i $args]
        }
        lappend outstr $c
    }
    foreach {var val} [lindex $args 0] {
        dict set result $var $val
    }
    #set result [lindex $args 0]
    foreach item [lrange $args 1 end] {
        foreach {var val} $item {
            if { $val == {} } {
                if ![dict exists $result $var] {
                    dict set result $var $val
                    continue
                }
            }
            if { $val == "NULL" } {
                dict set result $var {}
                continue
            }
            dict set result $var $val
        }
    }
    return $result
}

makeproc dictGet {dict args} {
  if {[dict exists $dict {*}$args]} {
    return [dict get $dict {*}$args]
  }
  return {}
}


### Sets or unsets a flag value
makeproc flag {cmnd varname {val {}} {cd 0}} {
    upvar 1 $varname var
    if ![info exists var] {
        set var {}
    }
    if [regexp , $var] {
        set cd 1
        set var [split $var ,]
    }
    
    switch $cmnd {
        add {
            ladd var $val
        }
        remove {
            ldelete var $val
        }
        fix {
            set cd 1
        }
    }
    if $cd {
        set var [join $var ,]
    }
}

#
# A Pure Tcl implementation of the lutil command
#
makeproc lutil {command varname args} {
      
    upvar 1 $varname stack
    if ![info exists stack] {
        set stack {}
    }
    set result {}
    switch $command {
        pop {
            set result [lindex $stack 0]
            set stack [lrange $stack 1 end]
            
            set setvarn [lindex $args 0]
            if { $setvarn != {} } {
                upvar 1 $setvarn setvar
                set setvar $result
                update idletasks
                set result [expr [llength $stack] > 0]
            }
        }
        queue {
            lappend stack [lindex $args 0]
        }
        push {
            set stack [linsert [K $stack [set stack {}]] 0 [lindex $args 0]]
        }
        peek {
            set result [lindex $stack 0]
        }
    }
    return $result
}

makeproc ldelete {varname args} {
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

makeproc ladd {varname args} {
  upvar 1 $varname var
  if ![info exists var] {
      set var {}
  }
  foreach item $args {
    if {$item in $var} continue
    lappend var $item
  }
  return $var
}

makeproc ladd_sorted {varname item} {
    upvar 1 $varname var
    lappend var $item
    set var [lsort -dictionary -unique $var]
    return $var
}

makeproc lset {varname fieldlist datalist} {
    upvar 1 $varname var
    set idx -1
    foreach field $fieldlist {
        set var($field) [lindex $datalist [incr idx]]
    }
}

makeproc listset {datalist varlist} {
    set idx -1
    foreach fieldVar $varlist {
        upvar 1 $fieldVar $fieldVar
        set $fieldVar [lindex $datalist [incr idx]]
    }
}

makeproc stripList arglist {
    set lastitem $arglist
    while { [llength $arglist] == 1 } {
       set lastitem $arglist
       set arglist [lindex $arglist 0]
    }
    if { [llength $arglist] == 0 } { 
       set arglist $lastitem
    }
    return $arglist
}

###
# Reverse the order of a list
###
makeproc lreverse {list} {	
    set result {}
    foreach item $list {
       set result [linsert [K $result [set result {}]] 0 $item]
    }
    return $result
}


makeproc lmerge {varname valuelist} {
    upvar 1 $varname var
    if ![info exists var] { 
        set var {}
    }
    set result {}
    foreach a $var {
        if { [lsearch $result $a] < 0 } {
            lappend result $a
        }
    }
    foreach a $valuelist {
        if { [lsearch $result $a] < 0 } {
            lappend result $a
        }
    }
    set var $result
    return $result
}


makeproc get varname {
    upvar 1 $varname var
    if [info exists var] {
        return [set var]
    }
}


makeproc dictget {dict field} {
    if [dict exists $dict $field] {
        return [dict get $dict $field]
    }
}

makeproc pop {stackvar resultvar} {
  upvar 1 $stackvar stack 
  upvar 1 $resultvar result
  if { [set len [llength $stack]] == 0 } { 
    set result {}
    return 0
  }
  set result [lindex $stack end]
  if { $len == 1 } { 
    set stack {}
  } else {
    set stack [lrange $stack 0 end-1]
  }
  return 1 
} 


makeproc peek {stackvar} { 
  upvar 1 $stackvar stack
  return [lindex $stack end]
}

makeproc push {stackvar value} {
  upvar 1 $stackvar stack
  lappend stack $value
}

makeproc queue {stackvar val} {
    upvar 1 $stackvar stack
    lappend stack $val
}

makeproc lintersect {list value} {
    foreach item $value {
        if {[lsearch $list $item] >= 0} {
            return true
        }
    }
    return false
}

