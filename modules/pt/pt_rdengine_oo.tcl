# -*- tcl -*-
#
# Copyright (c) 2009-2014 by Andreas Kupries <andreas_kupries@users.sourceforge.net>

# # ## ### ##### ######## ############# #####################
## Package description

## Implementation of the PackRat Machine (PARAM), a virtual machine on
## top of which parsers for Parsing Expression Grammars (PEGs) can be
## realized. This implementation is tied to Tcl for control flow. We
## (will) have alternate implementations written in TclOO, and critcl,
## all exporting the same API.
#
## RD stands for Recursive Descent.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require struct::stack 1.4 ; # Requiring get, trim methods
package require pt::ast
package require pt::pe

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create ::pt::rde::oo {

    # # ## ### ##### ######## ############# #####################
    ## API - Lifecycle

    constructor {} {
	set selfns [self namespace]

	set mystackloc  [struct::stack ${selfns}::LOC]  ; # LS
	set mystackerr  [struct::stack ${selfns}::ERR]  ; # ES
	set mystackast  [struct::stack ${selfns}::AST]  ; # ARS/AS
	set mystackmark [struct::stack ${selfns}::MARK] ; # s.a.

	my reset {}
	return
    }

    method reset {chan} {
	set mychan    $chan      ; # IN
	set mycurrent {}         ; # CC
	set myloc     -1         ; # CL
	set myok      0          ; # ST
	set msvalue   {}         ; # SV
	set myerror   {}         ; # ER
	set mytoken   {}         ; # TC (string)
	array unset   mysymbol * ; # NC

	$mystackloc  clear
	$mystackerr  clear
	$mystackast  clear
	$mystackmark clear
	return
    }

    method data {string} {
	append mytoken $string
	return
    }

    method complete {} {
	if {$myok} {
	    set n [$mystackast size]
	    if {$n > 1} {
		set  pos [$mystackloc peek]
		incr pos
		set children [lreverse [$mystackast peek [$mystackast size]]]     ; # SaveToMark
		return [pt::ast new {} $pos $myloc {*}$children] ; # Reduce ALL
	    } elseif {$n == 0} {
		# Match, but no AST. This is possible if the grammar
		# consists of only the start expression.
		return {}
	    } else {
		return [$mystackast peek]
	    }
	} else {
	    lassign $myerror loc messages
	    return -code error [list pt::rde $loc $messages]
	}
    }

    # # ## ### ##### ######## ############# #####################
    ## API - State accessors

    method chan   {} { return $mychan }

    # - - -- --- ----- --------

    method current  {} { return $mycurrent }
    method location {} { return $myloc }
    method lmarked  {} { return [lreverse [$mystackloc get]] }

    # - - -- --- ----- --------

    method ok      {} { return $myok      }
    method value   {} { return $mysvalue  }
    method error   {} { return $myerror   }
    method emarked {} { return [lreverse [$mystackerr get]] }

    # - - -- --- ----- --------

    method tokens {{from {}} {to {}}} {
	switch -exact [llength [info level 0]] {
	    4 { return $mytoken }
	    5 { return [string range $mytoken $from $from] }
	    6 { return [string range $mytoken $from $to] }
	}
    }

    method symbols {} {
	return [array get mysymbol]
    }

    method scached {} {
	return [array names mysymbol]
    }

    # - - -- --- ----- --------

    method asts    {} { return [lreverse [$mystackast  get]] }
    method amarked {} { return [lreverse [$mystackmark get]] }
    method ast     {} { return [$mystackast peek] }

    # # ## ### ##### ######## ############# #####################
    ## Common instruction sequences

    method si:void_state_push {} { ;#X
	# i_loc_push
	# i_error_clear_push
	$mystackloc push $myloc
	set myerror {}
	$mystackerr push {}
	return
    }

    method si:void2_state_push {} { ;#X
	# i_loc_push
	# i_error_push
	$mystackloc push $myloc
	$mystackerr push {}
	return
    }

    method si:value_state_push {} { ;#X
	# i_ast_push
	# i_loc_push
	# i_error_clear_push
	$mystackmark push [$mystackast size]
	$mystackloc push $myloc
	set myerror {}
	$mystackerr push {}
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:void_state_merge {} {
	# i_error_pop_merge
	# i_loc_pop_rewind/discard

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	set last [$mystackloc pop]
	if {$myok} return
	set myloc $last
	return
    }

    method si:void_state_merge_ok {} {
	# i_error_pop_merge
	# i_loc_pop_rewind/discard
	# i_status_ok

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	set last [$mystackloc pop]
	if {$myok} return
	set myloc $last
	set myok 1
	return
    }

    method si:value_state_merge {} {
	# i_error_pop_merge
	# i_ast_pop_rewind/discard
	# i_loc_pop_rewind/discard

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	set mark [$mystackmark pop]
	set last [$mystackloc pop]
	if {$myok} return
	$mystackast trim* $mark
	set myloc $last
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:value_notahead_start {} {
	# i_loc_push
	# i_ast_push

	$mystackloc  push $myloc
	$mystackmark push [$mystackast size]
	return
    }

    method si:void_notahead_exit {} {
	# i_loc_pop_rewind
	# i_status_negate

	set myloc [$mystackloc pop]
	set myok [expr {!$myok}]
	return
    }

    method si:value_notahead_exit {} {
	# i_ast_pop_discard/rewind
	# i_loc_pop_rewind
	# i_status_negate

	set mark [$mystackmark pop]
	if {$myok} {
	    $mystackast trim* $mark
	}
	set myloc [$mystackloc pop]
	set myok [expr {!$myok}]
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:kleene_abort {} {
	# i_loc_pop_rewind/discard
	# i:fail_return

	set last [$mystackloc pop]
	if {$myok} return
	set myloc $last
	return -code return
    }

    method si:kleene_close {} {
	# i_error_pop_merge
	# i_loc_pop_rewind/discard
	# i:fail_status_ok
	# i:fail_return

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	set last [$mystackloc pop]
	if {$myok} return
	set myok 1
	set myloc $last
	return -code return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:voidvoid_branch {} {
	# i_error_pop_merge
	# i:ok_loc_pop_discard
	# i:ok_return
	# i_loc_rewind
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	if {$myok} {
	    $mystackloc pop
	    return -code return
	}
	set myloc [$mystackloc peek]
	$mystackerr push $myerror
	return
    }

    method si:voidvalue_branch {} {
	# i_error_pop_merge
	# i:ok_loc_pop_discard
	# i:ok_return
	# i_ast_push
	# i_loc_rewind
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}

	if {$myok} {
	    $mystackloc pop
	    return -code return
	}
	$mystackmark push [$mystackast size]
	set myloc [$mystackloc peek]
	$mystackerr push {}
	return
    }

    method si:valuevoid_branch {} {
	# i_error_pop_merge
	# i_ast_pop_rewind/discard
	# i:ok_loc_pop_discard
	# i:ok_return
	# i_loc_rewind
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}
	set mark [$mystackmark pop]
	if {$myok} {
	    $mystackloc pop
	    return -code return
	}
	$mystackast trim* $mark
	set myloc [$mystackloc peek]
	$mystackerr push {}
	return
    }

    method si:valuevalue_branch {} {
	# i_error_pop_merge
	# i_ast_pop_discard
	# i:ok_loc_pop_discard
	# i:ok_return
	# i_ast_rewind
	# i_loc_rewind
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}
	if {$myok} {
	    $mystackmark pop
	    $mystackloc pop
	    return -code return
	}
	$mystackast trim* [$mystackmark peek]
	set myloc [$mystackloc peek]
	$mystackerr push {}
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:voidvoid_part {} {
	# i_error_pop_merge
	# i:fail_loc_pop_rewind
	# i:fail_return
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}
	if {!$myok} {
	    set myloc [$mystackloc pop]
	    return -code return
	}
	$mystackerr push $myerror
	return
    }

    method si:voidvalue_part {} {
	# i_error_pop_merge
	# i:fail_loc_pop_rewind
	# i:fail_return
	# i_ast_push
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}
	if {!$myok} {
	    set myloc [$mystackloc pop]
	    return -code return
	}
	$mystackmark push [$mystackast size]
	$mystackerr push $myerror
	return
    }

    method si:valuevalue_part {} {
	# i_error_pop_merge
	# i:fail_ast_pop_rewind
	# i:fail_loc_pop_rewind
	# i:fail_return
	# i_error_push

	set olderror [$mystackerr pop]
	# We have either old or new error data, keep it.
	if {![llength $myerror]}  {
	    set myerror $olderror
	} elseif {[llength $olderror]} {
	    # If one of the errors is further on in the input choose
	    # that as the information to propagate.

	    lassign $myerror  loe msgse
	    lassign $olderror lon msgsn

	    if {$lon > $loe} {
		set myerror $olderror
	    } elseif {$loe == $lon} {
		# Equal locations, merge the message lists, set-like.
		set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	    }
	}
	if {!$myok} {
	    $mystackast trim* [$mystackmark pop]
	    set myloc [$mystackloc pop]
	    return -code return
	}
	$mystackerr push $myerror
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:next_str {tok} {
	# String = sequence of characters. No need for all the intermediate
	# stack churn.

	set n    [string length $tok]
	set last [expr {$myloc + $n}]
	set max  [string length $mytoken]

	incr myloc
	if {($last >= $max) && ![my ExtendTCN [expr {$last - $max + 1}]]} {
	    set myok    0
	    set myerror [list $myloc [list [list str $tok]]]
	    # i:fail_return
	    return
	}
	set lex       [string range $mytoken $myloc $last]
	set mycurrent [string index $mytoken $last]

	set myok [expr {$tok eq $lex}]

	if {$myok} {
	    set myloc $last
	    set myerror {}
	} else {
	    set myerror [list $myloc [list [list str $tok]]]
	    incr myloc -1
	}
	return
    }

    method si:next_class {tok} {
	# Class = Choice of characters. No need for stack churn.

	# i_input_next "\{t $c\}"
	# i:fail_return
	# i_test_<user class>

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list [list cl $tok]]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	# Note what is needle versus hay. The token, i.e. the string
	# of allowed characters is the hay in which the current
	# character is looked, making it the needle.
	set myok [expr {[string first $mycurrent $tok] >= 0}]

	if {$myok} {
	    set myerror {}
	} else {
	    set myerror [list $myloc [list [list cl $tok]]]
	    incr myloc -1
	}
	return
    }

    method si:next_char {tok} {
	# i_input_next "\{t $c\}"
	# i:fail_return
	# i_test_char $c

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list [list t $tok]]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [expr {$tok eq $mycurrent}]
	if {$myok} {
	    set myerror {}
	} else {
	    set myerror [list $myloc [list [list t $tok]]]
	    incr myloc -1
	}
	return
    }

    method si:next_range {toks toke} {
	#Asm::Ins i_input_next "\{.. $s $e\}"
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_range $s $e

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list [list .. $toks $toke]]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [expr {
			([string compare $toks $mycurrent] <= 0) &&
			([string compare $mycurrent $toke] <= 0)
		    }] ; # {}
	if {$myok} {
	    set myerror {}
	} else {
	    set myerror [list $myloc [list [pt::pe range $toks $toke]]]
	    incr myloc -1
	}
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:next_alnum {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_alnum"
	#Asm::Ins i_input_next alnum
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_alnum

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list alnum]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is alnum -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list alnum]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_alpha {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_alpha"
	#Asm::Ins i_input_next alpha
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_alpha

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list alpha]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is alpha -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list alpha]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_ascii {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_ascii"
	#Asm::Ins i_input_next ascii
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_ascii

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list ascii]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is ascii -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list ascii]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_control {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_control"
	#Asm::Ins i_input_next control
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_control

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list control]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is control -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list control]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_ddigit {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_ddigit"
	#Asm::Ins i_input_next ddigit
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_ddigit

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list ddigit]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string match {[0-9]} $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list ddigit]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_digit {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_digit"
	#Asm::Ins i_input_next digit
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_digit

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list digit]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is digit -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list digit]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_graph {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_graph"
	#Asm::Ins i_input_next graph
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_graph

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list graph]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is graph -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list graph]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_lower {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_lower"
	#Asm::Ins i_input_next lower
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_lower

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list lower]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is lower -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list lower]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_print {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_print"
	#Asm::Ins i_input_next print
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_print

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list print]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is print -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list print]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_punct {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_punct"
	#Asm::Ins i_input_next punct
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_punct

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list punct]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is punct -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list punct]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_space {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_space"
	#Asm::Ins i_input_next space
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_space

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list space]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is space -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list space]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_upper {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_upper"
	#Asm::Ins i_input_next upper
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_upper

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list upper]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is upper -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list upper]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_wordchar {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_wordchar"
	#Asm::Ins i_input_next wordchar
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_wordchar

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list wordchar]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is wordchar -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list wordchar]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    method si:next_xdigit {} { ; #TRACE puts "[format %8d [incr count]] RDE si:next_xdigit"
	#Asm::Ins i_input_next xdigit
	#Asm::Ins i:fail_return
	#Asm::Ins i_test_xdigit

	incr myloc
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list xdigit]]
	    # i:fail_return
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok [string is xdigit -strict $mycurrent]
	if {!$myok} {
	    set myerror [list $myloc [list xdigit]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    # - -- --- ----- -------- ------------- ---------------------

    method si:value_symbol_start {symbol} {
	# if @runtime@ i_symbol_restore $symbol
	# i:found:ok_ast_value_push
	# i:found_return
	# i_loc_push
	# i_ast_push

	set k [list $myloc $symbol]
	if {[info exists mysymbol($k)]} { 
	    lassign $mysymbol($k) myloc myok myerror mysvalue
	    if {$myok} {
		$mystackast push $mysvalue
	    }
	    return -code return
	}
	$mystackloc  push $myloc
	$mystackmark push [$mystackast size]
	return
    }

    method si:value_void_symbol_start {symbol} {
	# if @runtime@ i_symbol_restore $symbol
	# i:found_return
	# i_loc_push
	# i_ast_push

	set k [list $myloc $symbol]
	if {[info exists mysymbol($k)]} { 
	    lassign $mysymbol($k) myloc myok myerror mysvalue
	    return -code return
	}
	$mystackloc  push $myloc
	$mystackmark push [$mystackast size]
	return
    }

    method si:void_symbol_start {symbol} {
	# if @runtime@ i_symbol_restore $symbol
	# i:found:ok_ast_value_push
	# i:found_return
	# i_loc_push

	set k [list $myloc $symbol]
	if {[info exists mysymbol($k)]} { 
	    lassign $mysymbol($k) myloc myok myerror mysvalue
	    if {$myok} {
		$mystackast push $mysvalue
	    }
	    return -code return
	}
	$mystackloc push $myloc
	return
    }

    method si:void_void_symbol_start {symbol} {
	# if @runtime@ i_symbol_restore $symbol
	# i:found_return
	# i_loc_push

	set k [list $myloc $symbol]
	if {[info exists mysymbol($k)]} { 
	    lassign $mysymbol($k) myloc myok myerror mysvalue
	    return -code return
	}
	$mystackloc push $myloc
	return
    }

    method si:reduce_symbol_end {symbol} {
	# i_value_clear/reduce $symbol
	# i_symbol_save       $symbol
	# i_error_nonterminal $symbol
	# i_ast_pop_rewind
	# i_loc_pop_discard
	# i:ok_ast_value_push

	set mysvalue {}
	set at [$mystackloc pop]

	if {$myok} {
	    set  mark [$mystackmark peek];# Old size of stack before current nt pushed more.
	    set  newa [expr {[$mystackast size] - $mark}]
	    set  pos  $at
	    incr pos

	    if {!$newa} {
		set mysvalue {}
	    } elseif {$newa == 1} {
		# peek 1 => single element comes back
		set mysvalue [list [$mystackast peek]]     ; # SaveToMark
	    } else {
		# peek n > 1 => list of elements comes back
		set mysvalue [$mystackast peekr $newa]     ; # SaveToMark
	    }

	    if {$at == $myloc} {
		# The symbol did not process any input. As this is
		# signaled to be ok (*) we create a node covering an
		# empty range. (Ad *): Can happen for a RHS using
		# toplevel operators * or ?.
		set mysvalue [pt::ast new0 $symbol $pos {*}$mysvalue]
	    } else {
		set mysvalue [pt::ast new $symbol $pos $myloc {*}$mysvalue] ; # Reduce $symbol
	    }
	}

	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]

	# si:reduce_symbol_end / i_error_nonterminal -- inlined -- disabled
	if {0} {if {[llength $myerror]} {
	    set  pos $at
	    incr pos
	    lassign $myerror loc messages
	    if {$loc == $pos} {
		set myerror [list $loc [list [list n $symbol]]]
	    }
	}}

	$mystackast trim* [$mystackmark pop]
	if {$myok} {
	    $mystackast push $mysvalue
	}
	return
    }

    method si:void_leaf_symbol_end {symbol} {
	# i_value_clear/leaf $symbol
	# i_symbol_save       $symbol
	# i_error_nonterminal $symbol
	# i_loc_pop_discard
	# i:ok_ast_value_push

	set mysvalue {}
	set at [$mystackloc pop]

	if {$myok} {
	    set  pos $at
	    incr pos
	    if {$at == $myloc} {
		# The symbol did not process any input. As this is
		# signaled to be ok (*) we create a node covering an
		# empty range. (Ad *): Can happen for a RHS using
		# toplevel operators * or ?.
		set mysvalue [pt::ast new0 $symbol $pos]
	    } else {
		set mysvalue [pt::ast new $symbol $pos $myloc]
	    }
	}

	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]

	# si:void_leaf_symbol_end / i_error_nonterminal -- inlined -- disabled
	if {0} {if {[llength $myerror]} {
	    set  pos $at
	    incr pos
	    lassign $myerror loc messages
	    if {$loc == $pos} {
		set myerror [list $loc [list [list n $symbol]]]
	    }
	}}

	if {$myok} {
	    $mystackast push $mysvalue
	}
	return
    }

    method si:value_leaf_symbol_end {symbol} {
	# i_value_clear/leaf $symbol
	# i_symbol_save       $symbol
	# i_error_nonterminal $symbol
	# i_loc_pop_discard
	# i_ast_pop_rewind
	# i:ok_ast_value_push

	set mysvalue {}
	set at [$mystackloc pop]

	if {$myok} {
	    set  pos $at
	    incr pos
	    if {$at == $myloc} {
		# The symbol did not process any input. As this is
		# signaled to be ok (*) we create a node covering an
		# empty range. (Ad *): Can happen for a RHS using
		# toplevel operators * or ?.
		set mysvalue [pt::ast new0 $symbol $pos]
	    } else {
		set mysvalue [pt::ast new $symbol $pos $myloc]
	    }
	}

	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]

	# si:value_leaf_symbol_end / i_error_nonterminal -- inlined -- disabled
	if {0} {if {[llength $myerror]} {
	    set  pos $at
	    incr pos
	    lassign $myerror loc messages
	    if {$loc == $pos} {
		set myerror [list $loc [list [list n $symbol]]]
	    }
	}}

	$mystackast trim* [$mystackmark pop]
	if {$myok} {
	    $mystackast push $mysvalue
	}
	return
    }

    method si:value_clear_symbol_end {symbol} {
	# i_value_clear
	# i_symbol_save       $symbol
	# i_error_nonterminal $symbol
	# i_loc_pop_discard
	# i_ast_pop_rewind

	set mysvalue {}
	set at [$mystackloc pop]

	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]

	# si:value_clear_symbol_end / i_error_nonterminal -- inlined -- disabled
	if {0} {if {[llength $myerror]} {
	    set  pos $at
	    incr pos
	    lassign $myerror loc messages
	    if {$loc == $pos} {
		set myerror [list $loc [list [list n $symbol]]]
	    }
	}}

	$mystackast trim* [$mystackmark pop]
	return
    }

    method si:void_clear_symbol_end {symbol} {
	# i_value_clear
	# i_symbol_save       $symbol
	# i_error_nonterminal $symbol
	# i_loc_pop_discard

	set mysvalue {}
	set at [$mystackloc pop]

	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]

	# si:void_clear_symbol_end / i_error_nonterminal -- inlined -- disabled
	if {0} {if {[llength $myerror]} {
	    set  pos $at
	    incr pos
	    lassign $myerror loc messages
	    if {$loc == $pos} {
		set myerror [list $loc [list [list n $symbol]]]
	    }
	}}
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## API - Instructions - Control flow

    method i:ok_continue {} {
	if {!$myok} return
	return -code continue
    }

    method i:fail_continue {} {
	if {$myok} return
	return -code continue
    }

    method i:fail_return {} {
	if {$myok} return
	return -code return
    }

    method i:ok_return {} {
	if {!$myok} return
	return -code return
    }

    # # ## ### ##### ######## ############# #####################
    ##  API - Instructions - Unconditional matching.

    method i_status_ok {} {
	set myok 1
	return
    }

    method i_status_fail {} {
	set myok 0
	return
    }

    method i_status_negate {} {
	set myok [expr {!$myok}]
	return
    }

    # # ## ### ##### ######## ############# #####################
    ##  API - Instructions - Error handling.

    method i_error_clear {} {
	set myerror {}
	return
    }

    method i_error_push {} {
	$mystackerr push $myerror
	return
    }

    method i_error_clear_push {} {
	set myerror {}
	$mystackerr push {}
	return
    }

    method i_error_pop_merge {} {
	set olderror [$mystackerr pop]

	# We have either old or new error data, keep it.

	if {![llength $myerror]}  { set myerror $olderror ; return }
	if {![llength $olderror]} return

	# If one of the errors is further on in the input choose that as
	# the information to propagate.

	lassign $myerror  loe msgse
	lassign $olderror lon msgsn

	if {$lon > $loe} { set myerror $olderror ; return }
	if {$loe > $lon} return

	# Equal locations, merge the message lists.
	#set myerror [list $loe [struct::set union $msgse $msgsn]]
	set myerror [list $loe [lsort -uniq [list {*}$msgse {*}$msgsn]]]
	return
    }

    method i_error_nonterminal {symbol} {
	#  i_error_nonterminal -- Disabled. Generate only low-level
	#  i_error_nonterminal -- errors until we have worked out how
	#  i_error_nonterminal -- to integrate symbol information with
	#  i_error_nonterminal -- them. Do not forget where this
	#  i_error_nonterminal -- instruction is inlined.
	return

	# Inlined: Errors, Expected.
	if {![llength $myerror]} return
	set pos [$mystackloc peek]
	incr pos
	lassign $myerror loc messages
	if {$loc != $pos} return
	set myerror [list $loc [list $symbol]]
	return
    }

    # # ## ### ##### ######## ############# #####################
    ##  API - Instructions - Basic input handling and tracking

    method i_loc_pop_rewind/discard {} {
	#$myparser i:fail_loc_pop_rewind
	#$myparser i:ok_loc_pop_discard
	#return
	set last [$mystackloc pop]
	if {!$myok} {
	    set myloc $last
	}
	return
    }

    method i_loc_pop_discard {} {
	$mystackloc pop
	return
    }

    method i_loc_pop_rewind {} {
	set myloc [$mystackloc pop]
	return
    }

    method i:fail_loc_pop_rewind {} {
	if {$myok} return
	set myloc [$mystackloc pop]
	return
    }

    method i_loc_push {} {
	$mystackloc push $myloc
	return
    }

    # # ## ### ##### ######## ############# #####################
    ##  API - Instructions - AST stack handling

    method i_ast_pop_rewind/discard {} {
	#$myparser i:fail_ast_pop_rewind
	#$myparser i:ok_ast_pop_discard
	#return
	set mark [$mystackmark pop]
	if {$myok} return
	$mystackast trim $mark
	return
    }

    method i_ast_pop_discard/rewind {} {
	#$myparser i:ok_ast_pop_rewind
	#$myparser i:fail_ast_pop_discard
	#return
	set mark [$mystackmark pop]
	if {!$myok} return
	$mystackast trim $mark
	return
    }

    method i_ast_pop_discard {} {
	$mystackmark pop
	return
    }

    method i_ast_pop_rewind {} {
	$mystackast trim [$mystackmark pop]
	return
    }

    method i:fail_ast_pop_rewind {} {
	if {$myok} return
	$mystackast trim [$mystackmark pop]
	return
    }

    method i_ast_push {} {
	$mystackmark push [$mystackast size]
	return
    }

    method i:ok_ast_value_push {} {
	if {!$myok} return
	$mystackast push $mysvalue
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## API - Instructions - Nonterminal cache

    method i_symbol_restore {symbol} {
	# Satisfy from cache if possible.
	set k [list $myloc $symbol]
	if {![info exists mysymbol($k)]} { return 0 }
	lassign $mysymbol($k) myloc myok myerror mysvalue
	# We go forward, as the nonterminal matches (or not).
	return 1
    }

    method i_symbol_save {symbol} {
	# Store not only the value, but also how far
	# the match went (if it was a match).
	set at [$mystackloc peek]
	set k  [list $at $symbol]
	set mysymbol($k) [list $myloc $myok $myerror $mysvalue]
	return
    }

    # # ## ### ##### ######## ############# #####################
    ##  API - Instructions - Semantic values.

    method i_value_clear {} {
	set mysvalue {}
	return
    }

    method i_value_clear/leaf {symbol} {
	# not quite value_lead (guarded, and clear on fail)
	# Inlined clear, reduce, and optimized.
	# Clear ; if {$ok} {Reduce $symbol}
	set mysvalue {}
	if {!$myok} return
	set  pos [$mystackloc peek]
	incr pos
	set mysvalue [pt::ast new $symbol $pos $myloc]
	return
    }

    method i_value_clear/reduce {symbol} {
	set mysvalue {}
	if {!$myok} return

	set  mark [$mystackmark peek];# Old size of stack before current nt pushed more.
	set  newa [expr {[$mystackast size] - $mark}]

	set  pos  [$mystackloc  peek]
	incr pos

	if {!$newa} {
	    set mysvalue {}
	} elseif {$newa == 1} {
	    # peek 1 => single element comes back
	    set mysvalue [list [$mystackast peek]]     ; # SaveToMark
	} else {
	    # peek n > 1 => list of elements comes back
	    set mysvalue [lreverse [$mystackast peek $newa]]     ; # SaveToMark
	}

	set mysvalue [pt::ast new $symbol $pos $myloc {*}$mysvalue] ; # Reduce $symbol
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## API - Instructions - Terminal matching

    method i_input_next {msg} {
	# Inlined: Getch, Expected, ClearErrors
	# Satisfy from input cache if possible.

	incr myloc
	# May read from the input (ExtendTC), and remember the
	# information. Note: We are implicitly incrementing the
	# location!
	if {($myloc >= [string length $mytoken]) && ![my ExtendTC]} {
	    set myok    0
	    set myerror [list $myloc [list $msg]]
	    return
	}
	set mycurrent [string index $mytoken $myloc]

	set myok    1
	set myerror {}
	return
    }

    method i_test_alnum {} {
	set myok [string is alnum -strict $mycurrent]
	my OkFail [pt::pe alnum]
	return
    }

    method i_test_alpha {} {
	set myok [string is alpha -strict $mycurrent]
	my OkFail [pt::pe alpha]
	return
    }

    method i_test_ascii {} {
	set myok [string is ascii -strict $mycurrent]
	my OkFail [pt::pe ascii]
	return
    }

    method i_test_control {} {
	set myok [string is control -strict $mycurrent]
	my OkFail [pt::pe control]
	return
    }

    method i_test_char {tok} {
	set myok [expr {$tok eq $mycurrent}]
	my OkFail [pt::pe terminal $tok]
	return
    }

    method i_test_ddigit {} {
	set myok [string match {[0-9]} $mycurrent]
	my OkFail [pt::pe ddigit]
	return
    }

    method i_test_digit {} {
	set myok [string is digit -strict $mycurrent]
	my OkFail [pt::pe digit]
	return
    }

    method i_test_graph {} {
	set myok [string is graph -strict $mycurrent]
	my OkFail [pt::pe graph]
	return
    }

    method i_test_lower {} {
	set myok [string is lower -strict $mycurrent]
	my OkFail [pt::pe lower]
	return
    }

    method i_test_print {} {
	set myok [string is print -strict $mycurrent]
	my OkFail [pt::pe printable]
	return
    }

    method i_test_punct {} {
	set myok [string is punct -strict $mycurrent]
	my OkFail [pt::pe punct]
	return
    }

    method i_test_range {toks toke} {
	set myok [expr {
			([string compare $toks $mycurrent] <= 0) &&
			([string compare $mycurrent $toke] <= 0)
		    }] ; # {}
	my OkFail [pt::pe range $toks $toke]
	return
    }

    method i_test_space {} {
	set myok [string is space -strict $mycurrent]
	my OkFail [pt::pe space]
	return
    }

    method i_test_upper {} {
	set myok [string is upper -strict $mycurrent]
	my OkFail [pt::pe upper]
	return
    }

    method i_test_wordchar {} {
	set myok [string is wordchar -strict $mycurrent]
	my OkFail [pt::pe wordchar]
	return
    }

    method i_test_xdigit {} {
	set myok [string is xdigit -strict $mycurrent]
	my OkFail [pt::pe xdigit]
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Internals

    method ExtendTC {} {
	upvar 1 mychan mychan mytoken mytoken

	if {($mychan eq {}) ||
	    [eof $mychan]} {return 0}

	set ch [read $mychan 1]
	if {$ch eq {}} {
	    return 0
	}

	append mytoken $ch
	return 1
    }

    method ExtendTCN {n} {
	upvar 1 mychan mychan mytoken mytoken

	if {($mychan eq {}) ||
	    [eof $mychan]} {return 0}

	set str [read $mychan $n]
	set k   [string length $str]

	append mytoken $str
	if {$k < $n} {
	    return 0
	}

	return 1
    }

    method OkFail {msg} {
	upvar 1 myok myok myerror myerror myloc myloc
	# Inlined: Expected, Unget, ClearErrors
	if {!$myok} {
	    set myerror [list $myloc [list $msg]]
	    incr myloc -1
	} else {
	    set myerror {}
	}
	return
    }

    # # ## ### ##### ######## ############# #####################
    ## Data structures.
    ## Mainly the architectural state of the instance's PARAM.

    variable \
	mychan mycurrent myloc mystackloc \
	myok mysvalue myerror mystackerr \
	mytoken mysymbol mystackast mystackmark

    # Parser Input (channel, location (line, column)) ...........
    # Token, current parsing location, stack of locations .......
    # Match state .  ........ ............. .....................
    # Caches for tokens and nonterminals .. .....................
    # Abstract syntax tree (AST) .......... .....................

    # # ## ### ##### ######## ############# #####################
}

# # ## ### ##### ######## ############# #####################
## Ready

package provide pt::rde::oo 1.0.3
return
