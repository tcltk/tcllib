# -*- tcl -*-
# Copyright (c) 2009-2018 Andreas Kupries <andreas_kupries@sourceforge.net>
# Copyright (c) 2018 Stefan Sobernig <stefan.sobernig@wu.ac.at>

# Utility commands operating on parsing expressions.

# # ## ### ##### ######## ############# #####################
## Requirements

package require Tcl 8.5 9        ; # Required runtime.
package require pt::pe         ; # PE basics
package require pt::pe::op     ; # PE transforms
package require struct::set    ; # Set operations (symbol sets)

# # ## ### ##### ######## ############# #####################
##

namespace eval ::pt::peg::op {
    namespace export \
	flatten called reachable realizable \
	drop modeopt minimize dechain

    namespace ensemble create

    namespace eval ::pt::peg::op::drop {
	namespace export \
	    unreachable unrealizable

	namespace ensemble create
    }
}

# # ## ### ##### ######## #############
## Public API

proc ::pt::peg::op::flatten {container} {
    # Flatten all expressions in the grammar, i.e. start expression
    # and nonterminal symbol right hand sides.

    $container start [pt::pe::op flatten [$container start]]

    foreach {symbol rule} [$container rules] {
	$container rule $symbol [pt::pe::op flatten $rule]
    }

    return
}

proc ::pt::peg::op::called {container} {
    # Determine static call structure for the nonterminal symbols of
    # the grammar. Result is dictionary mapping from each symbol to
    # the symbols it calls. The empty string is used to represent the
    # start expression (as key).

    lappend dict {} [pt::pe::op called [$container start]]

    foreach {symbol rule} [$container rules] {
	lappend dict $symbol [pt::pe::op called $rule]
    }

    return $dict
}

proc ::pt::peg::op::dechain {container} {

    set changed 1
    while {$changed} {
	
	set chainPairs [dict create]
	set rules [$container rules]
	array set modes [$container modes]
	set changed 0
	foreach {caller rule} $rules {
	    lassign $rule op called
	    if {$op ne "n"} continue
	    dict set chainPairs $called $caller
	}

	set ends [struct::set difference \
			[dict keys $chainPairs] \
			[dict values $chainPairs]]

	if {[struct::set empty $ends]} {
	    # stop, given a cycle
	    break
	}

	set chainPairs [dict remove $chainPairs {*}$ends]
	set changed [dict size $chainPairs]
	
	if {$changed} {
	    
	    dict for {called caller} $chainPairs {

		if {$called in [$container nonterminals]
		    && !(($modes($caller) ne "value") &&
		    (($modes($caller) ne "void") ||
		     ![info exists modes($called)] ||
		     ($modes($called) ne "void")))} {
		    
       		    $container rule $caller [$container rule $called]
		    
		} else {
		    incr changed -1
		}
	    }
	}
    }
    
    return
}

# # ## ### ##### ######## #############

proc ::pt::peg::op::modeopt {container} {

    # Optimize the semantic modes of symbols.

    # Rules.
    # 1. If a symbol X with mode 'value' calls no other symbols,
    #    i.e. uses only terminal symbols in whatever combination, then
    #    this can be represented simpler by using mode leaf.
    #
    # 2. If a symbol X is only called from symbols with modes 'leaf'
    #    or 'void' then this symbol should have mode 'void' also, as
    #    any AST it could generate will be discarded anyway.

    array set calls  [called $container]
    array set caller [Invert [array get calls]]
    array set mode   [$container modes]
    set mode() value

    # calls  = array (x -> called-by-x)
    # caller = array (x -> users-of-x)

    set changed [$container nonterminals]
    while {[llength $changed]} {
	#puts <$changed>
	set scan $changed
	set changed {}

	foreach sym $scan {
	    # Rule 1
	    if {![llength $calls($sym)] &&
		($mode($sym) eq "value")} {
		#puts (1)$sym
		set mode($sym) leaf
	    }

	    # Rule 2
	    set callmode [CallMode $caller($sym) mode]
	    if {($callmode eq "void") &&
		($mode($sym) ne "void")} {

		#puts (2)$sym
		set mode($sym) void

		# This change may change calling context and this call
		# mode of the symbols we call, so put them back up for
		# consideration.
		struct::set add changed $calls($sym)
	    }
	}
    }

    # Save the optimized modes back to the grammar.
    unset mode()
    $container modes [array get mode]
    return
}

proc ::pt::peg::op::CallMode {callers mv} {
    upvar 1 $mv mode
    set res {}
    foreach sym $callers {
	struct::set include res $mode($sym)
    }
    if {[struct::set contains $res value]} {
	return value
    } else {
	return void
    }
}

# # ## ### ##### ######## #############

proc ::pt::peg::op::minimize {container} {
    flatten           $container
    modeopt           $container; # for dechaining
    dechain           $container
    drop unrealizable $container
    drop unreachable  $container
    modeopt           $container;
    flatten           $container
    return
}

# # ## ### ##### ######## #############

proc ::pt::peg::op::reachable {container} {

    # We compute the set of all nonterminal symbols which are
    # reachable from the start expression of the grammar. This is
    # essentially the transitive closure over [called] and the symbol's
    # right hand sides, beginning with the start expression.

    set reachable {}
    set pending [pt::pe::op called [$container start]]
    set known   [$container nonterminals]

    while {[llength $pending]} {
	set new $pending
	set pending {}
	foreach symbol $new {
	    if {
		![struct::set contains $known $symbol] ||
		[struct::set contains $reachable $symbol]
	    } continue

	    struct::set add pending \
		[pt::pe::op called [$container rule $symbol]]
	}

	# Everything from the previous round is reachable, now that we
	# expanded it we can even add it to the result.
	struct::set add reachable $new
    }

    return $reachable
}

proc ::pt::peg::op::drop::unreachable {container} {

    set unreachable [struct::set difference \
			 [$container nonterminals] \
			 [pt::peg::op reachable $container]]

    if {![llength $unreachable]} return

    $container remove {*}$unreachable
    return
}

# # ## ### ##### ######## #############

proc ::pt::peg::op::realizable {container} {

    # We compute the set of all nonterminal symbols which are
    # realizable, i.e. can derive pure terminal phrases. This is done
    # iteratively, starting with state unrealizable for all and any,
    # and then updating all symbols which are realizable, propagating
    # changes, until nothing changes any more.

    set realizable {}
    array set caller [Invert [called $container]]
    # caller = array (x -> list(caller-of-x))

    set     maychange [$container nonterminals]
    lappend maychange {} ;# special marker for the start expression.

    while {[llength $maychange]} {
	set scan $maychange
	set maychange {}

	foreach symbol $scan {
	    # Ignore symbols we have a settled result for.
	    if {[struct::set contains $realizable $symbol]} \
		continue

	    set real [pt::pe bottomup pt::peg::op::Realizable \
			  [expr {
				 ($symbol eq {})
				 ? [$container start]
				 : [$container rule $symbol]
			     }]]
	    if {!$real} continue

	    struct::set include realizable $symbol

	    # Symbol may be unreachable, i.e. have no callers.
	    if {![info exists caller($symbol)]} continue
	    struct::set add maychange $caller($symbol)
	}
    }

    return $realizable
}

proc ::pt::peg::op::Realizable {pe op arguments} {
    switch -exact -- $op {
	n {
	    upvar 1 realizable realizable
	    lassign $arguments symbol
	    return [struct::set contains $realizable $symbol]
	}
	/ {
	    # Choice is realizable if we have at least one realizable
	    # branch. This is also the place where we have to remove
	    # unrealizable children when we drop unrealizable symbols
	    # from a grammar.

	    return [tcl::mathfunc::max {*}$arguments]
	}
	x - + - & - ! {
	    # All other operators are realizable if and only if all
	    # its children are realizable.

	    return [tcl::mathfunc::min {*}$arguments]
	}
	default {
	    # Terminals, special forms, Kleene closure (*), and
	    # optionals (?) are realizable by definition.
	    return 1
	}
    }
}

proc ::pt::peg::op::drop::unrealizable {container} {

    #set     all [$container nonterminals]
    set     all [::pt::peg::op reachable $container]
    lappend all {} ; # marker for start expression.

    set unrealizable \
	[struct::set difference \
	     $all [pt::peg::op realizable $container]]

    if {![llength $unrealizable]} return

    if {[struct::set contains $unrealizable {}]} {
	struct::set exclude unrealizable {}
	$container start epsilon
    }

    # Drop the unrealizable symbols.

    $container remove {*}$unrealizable

    # Phase II. For the remaining symbols, if any, rewrite their
    # expressions to get rid of the references to the dropped symbols
    # (these may occur in choice (/) operators).

    foreach symbol [$container nonterminals] {
	$container rule $symbol \
	    [pt::pe::op drop $unrealizable \
		 [$container rule $symbol]]
    }
    return
}

# # ## ### ##### ######## #############
## Internals

proc ::pt::peg::op::Invert {dict} {
    # dict   = dict (a -> list(b))
    # result = dict (b -> list(a)) 
    array set tmp {}
    foreach {a blist} $dict {
	foreach b $blist {
	    lappend tmp($b) $a
	}
    }
    return [array get tmp]
}

# # ## ### ##### ######## #############
## State / Configuration :: n/a

namespace eval ::pt::peg::op {}

# # ## ### ##### ######## ############# #####################
## Ready

package provide pt::peg::op 1.2.0
return
