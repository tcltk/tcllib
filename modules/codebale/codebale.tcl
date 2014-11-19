###
# codebale.tcl
#
# This file defines routines used to bundle and manage Tcl and C
# code repositories
#
# Copyright (c) 2014 Sean Woods
#
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.
###

::namespace eval ::codebale {}

###
# topic: a5992c7f8340ba02d40e386aac95b1b8
# description: Records an alias for a Tcl keyword
###
proc ::codebale::alias {alias cname} {
  variable cnames
  set cnames($alias) $cname
}

###
# topic: 0e883f3583c0ccd3eddc6b297ac2ea77
###
proc ::codebale::buffer_append {varname args} {
  upvar 1 $varname result
  if {![info exists result]} {
    set result {}    
  }
  if {[string length $result]} {
    set result [string trimright $result \n]
    append result \n
  }
  set priorarg {}
  foreach arg $args {
    if {[string length [string trim $arg]]==0} continue
    #if {[string match $arg $priorarg]} continue
    set priorarg $arg
    append result \n [string trim $arg \n] \n
  }
  set result [string trim $result \n]
  append result \n
  return $result
}

###
# topic: 926c564aa67884986f7489f37da3fb32
###
proc ::codebale::buffer_merge args {
  set result {}
  set priorarg {}
  foreach arg $args {
    if {[string length [string trim $arg]]==0} continue
    if {[string match $arg $priorarg]} continue
    set priorarg $arg
    append result [string trim $arg \n] \n
  }
  set result [string trim $result \n]
  return $result
}

###
# topic: c1e66f4a20e397a5d2541714575c165f
###
proc ::codebale::buffer_puts {varname args} {
  upvar 1 $varname result
  if {![info exists result]} {
    set result {}    
  }
  set result [string trimright $result \n]
  #if {[string length $result]} {
  #  set result [string trimright $result \n]
  #}
  set priorarg {}
  foreach arg $args {
    #if {[string length [string trim $arg]]==0} continue
    #if {[string match $arg $priorarg]} continue
    #set priorarg $arg
    append result \n $arg
    #[string trim $arg \n]
  }
  #set result [string trim $result \n]
  #append result \n
  return $result
}

###
# topic: 951f31f2cb24992f34d97e3deb16b43f
# description: Reports back the canonical name of a tcl keyword
###
proc ::codebale::canonical alias {
  variable cnames
  if {[info exists cnames($alias)]} {
    return $cnames($alias)
  }
  return $alias
}

###
# topic: aacfe07625f74f93dada2159f53fca32
###
proc ::codebale::detect_cases cfile {
  set fin [open $cfile r]
  while {[gets $fin line] >= 0} {
    if {[regexp {^ *case *([A-Z]+)_([A-Z0-9_]+):} $line all prefix label]} {
      lappend cases($prefix) $label
    }
  }
  close $fin
  set result {}
  foreach item [array names cases] {
    lappend result [string tolower ${item}_cases.h]
  }
  return $result
}

###
# topic: ead7e6fe566070cc79f0eb2f5182465e
###
proc ::codebale::normalize_tabbing {rawblock {newspace 0}} {
  set result {}
  ###
  # clean up spaces
  ###
  set block [string map [list \t "    "] $rawblock]
  
  set spaces -1
  while {[string index $block [incr spaces]] eq " " } {}
  if { $spaces < 0} {
    return $rawblock
  }
  set count 0
  foreach line [split $block \n] {
    if {[string first " " $line] > 0} {
      set spaces -1
      break
    }
    incr count
    set i [string last " " $line]
    if { ($i+1) < $spaces } {
      set spaces [expr $i + 1]
    }
  }
  if {$spaces <= 0} {
    return $rawblock
  }
  set head [string repeat " " $newspace]
  foreach line [split $block \n] {
    append result $head [string range $line $spaces end] \n
  }
  return $result
}

###
# topic: 7958a706b48a9bc44cbbef73813e0fb2
###
proc ::codebale::rewrite_comment {spaces topic info} {
  set result {}
  set head [string repeat " " $spaces]
  set class [helpdoc one {select class from entry where entryid=:topic}]
  if { $class eq [dict getnull $info type] } {
    dict unset info type
  }

  set order [dict keys $info]
  logicset remove order type description arguments returns yields title
  set order [linsert order 0 title type]
  lappend order description arguments returns yields darglist usage example
  foreach {field} $order {
    set val [dict getnull $info $field]
    ###
    # Fields to drop for meta-data
    ###
    set dtext [split [string trim $val] \n]
    if {![llength $dtext]} {
      continue
    }
    if {[llength $dtext] == 1} {
      append result \n "${head}# ${field}: [string trim [lindex $dtext 0]]"
    } else {
      append result \n "${head}# ${field}:"
      foreach dline $dtext {
        append result \n "${head}#    [string trim $dline]"
      }
    }
  }

  set result [buffer_merge "${head}###" "${head}# topic: $topic" $result "${head}###"]
}

###
# topic: 003ce0c0d69b74076e8433492deac920
# description:
#    Descends into a directory structure, returning
#    a list of items found in the form of:
#    type object
#    where type is one of: csource source parent_name
#    and object is the full path to the file
###
proc ::codebale::sniffPath {spath stackvar} {
  upvar 1 $stackvar stack    
  set result {}
  if { ![file isdirectory $spath] } {
    switch [file extension $spath] {
      .tm {
        return [list parent_name $spath]
      }
      .tcl {
        return [list source $spath]
      }
      .h {
        return [list cheader $spath]
      }
      .c {
        return [list csource $spath]
      }
    }    
    return
  }
  foreach f [glob -nocomplain $spath/*] {
    if {[file isdirectory $f]} {
      if {[file tail $f] in {CVS build} } continue
      if {[file extension $f] eq ".vfs" } continue
      set stack [linsert $stack 0 $f]
    }
  }
  set idx 0
  foreach idxtype {
    pkgIndex.tcl tclIndex
  } {
    if {[file exists [file join $spath $idxtype]]} {
      lappend result index [file join $spath $idxtype]
    }
  }
  if {[llength $result]} {
    return $result
  }
  foreach f [glob -nocomplain $spath/*] {
    if {![file isdirectory $f]} {
      set stack [linsert $stack 0 $f]
    }
  }
  return {}
}

###
# topic: 47266d90061e780e234ec3245d85c176
###
proc ::codebale::strip_ccoments string {
  set result {}
  set idx 0
  if {![complete_ccomment $string]} {
    error "Incomplete C comment: $string"
  }
  while {[set ndx [string first "/*" $string $idx]] >=0 } {
    append result [string range $string $idx [expr {$ndx-1}]]
    set idx [string first */ $string [expr {$ndx+2}]]
    if { $idx < 0 } {
      break
    }
    incr idx 2
  }
  append result [string range $string $idx end]
}

set ::force_check 0

