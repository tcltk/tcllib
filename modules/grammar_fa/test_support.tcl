
# -------------------------------------------------------------------------
# Helper for tests: Validation of serializations.

proc validate_serial {value fa} {
    # value is list/3 ('grammar::fa' symbols states)
    # !("" in symbols)
    # states is ordered dict (key is state, value is statedata)
    # statedata is list/3 (start final trans|"")
    # start is boolean
    # final is boolean
    # trans is dict (key in symbols, value is list (state))

    # Output for debug ...
    ##puts "$fa => ($value)"

    # symbols set-equal symbols(fa)
    # states  set-equal states(fa)
    # finalstates set-equal finalstates(fa)
    # startstates set-equal startstates(fa)

    set prefix "error in serialization:"
    if {[llength $value] != 3} {
	return "$prefix list length not 3"
    }

    struct::list assign $value type symbols statedata

    if {$type ne "grammar::fa"} {
	return "$prefix unknown type \"$type\""
    }
    if {[struct::set contains $symbols ""]} {
	return "$prefix empty symbol is not legal"
    }
    if {![struct::set equal $symbols [$fa symbols]]} {
	return "$prefix set of symbols does not match"
    }
    if {[llength $statedata] % 2 == 1} {
	return "$prefix state data is not a dictionary"
    }
    array set _states $statedata
    if {[llength $statedata] != (2*[array size _states])} {
	return "$prefix state data contains duplicate states"
    }
    if {![struct::set equal [array names _states] [$fa states]]} {
	return "$prefix set of states does not match"
    }
    foreach {k v} $statedata {
	if {[llength $v] != 3} {
	    return "$prefix state list length not 3"
	}
	struct::list assign $v start final trans
	if {![string is boolean -strict $start]} {
	    return "$prefix expected boolean for start, got \"$start\""
	}
	if {($start && ![$fa start? $k]) || (!$start && [$fa start? $k])} {
	    return "$prefix start does not match"
	}
	if {![string is boolean -strict $final]} {
	    return "$prefix expected boolean for final, got \"$final\""
	}
	if {($final && ![$fa final? $k]) || (!$final && [$fa final? $k])} {
	    return "$prefix final does not match"
	}
	if {[llength $trans] % 2 == 1} {
	    return "$prefix transition data is not a dictionary"
	}
	array set _trans $trans
	if {[llength $trans] != (2*[array size _trans])} {
	    return "$prefix transition data contains duplicate symbols"
	}
	# trans keys set-equal to trans/symbols(fa,k)
	if {![struct::set equal [$fa symbols@ $k] [array names _trans]]} {
	    return "$prefix transition symbols do not match"
	}
	unset _trans

	foreach {sym destinations} $trans {
	    if {($sym ne "") && ![struct::set contains $symbols $sym]} {
		return "$prefix illegal symbol \"$sym\" in transition"
	    }
	    foreach dest $destinations {
		if {![info exists _states($dest)]} {
		    return "$prefix illegal destination state \"$dest\""
		}
	    }
	    if {![struct::set equal $destinations [$fa next $k $sym]]} {
		return "$prefix destination set does not match"
	    }
	}
    }
    return ok
}

# -------------------------------------------------------------------------
# Helper for tests: Serialization of empty FA.

set fa_empty {grammar::fa {} {}}

# -------------------------------------------------------------------------
# Helper for tests: Predefined graphs for use in tests.
# (Properties and such). Number of graphs: 30.

array set fa_pre {}

proc gen {code} {
    global      fa_pre
    uplevel #0 $fa_pre($code)
    return
}
proc def {code script} {
    global fa_pre
    set fa_pre($code) $script
    return
}


def x {
    a state add x
}
def x- {
    a state add x
    a symbol add @
    a next x @ --> x
}
def xe {
    a state add x
    a next x "" --> x
}
def xy {
    a state add x y
}
def xy- {
    a state add x y
    a symbol add @
    a next x @ --> y
}
def xye {
    a state add x y
    a next x "" --> y
}
def xyee {
    a state add x y
    a next x "" --> y
    a next y "" --> x
}
def xye- {
    a state add x y
    a symbol add @
    a next x "" --> y
    a next y @  --> x
}
def xy-- {
    a state add x y
    a symbol add @
    a next x @ --> y
    a next y @ --> x
}
def xy-= {
    a state add x y
    a symbol add @ =
    a next x @ --> y
    a next y = --> x
}
def xyz/ee {
    a state add x y z
    a next x "" --> y
    a next x "" --> z
}
def xyz/e- {
    a state add x y z
    a symbol add @
    a next x @  --> y
    a next x "" --> z
}
def xyz/-- {
    a state add x y z
    a symbol add @
    a next x @ --> y
    a next x @ --> z
}
def xyz/-= {
    a state add x y z
    a symbol add @ =
    a next x @ --> y
    a next x = --> z
}
def xyz|ee {
    a state add x y z
    a next x "" --> z
    a next y "" --> z
}
def xyz|e- {
    a state add x y z
    a symbol add @
    a next x @  --> z
    a next y "" --> z
}
def xyz|-- {
    a state add x y z
    a symbol add @
    a next x @ --> z
    a next y @ --> z
}
def xyz|-= {
    a state add x y z
    a symbol add @ =
    a next x @ --> z
    a next y = --> z
}
def xyz+eee {
    a state add x y z
    a next x "" --> y
    a next y "" --> z
    a next z "" --> x
}
def xyz+ee- {
    a state add x y z
    a symbol add @
    a next x "" --> y
    a next y "" --> z
    a next z @  --> x
}
def xyz+e-- {
    a state add x y z
    a symbol add @
    a next x "" --> y
    a next y @  --> z
    a next z @  --> x
}
def xyz+e-= {
    a state add x y z
    a symbol add @ =
    a next x "" --> y
    a next y @  --> z
    a next z =  --> x
}
def xyz+--- {
    a state add x y z
    a symbol add @
    a next x @ --> y
    a next y @ --> z
    a next z @ --> x
}
def xyz+--= {
    a state add x y z
    a symbol add @ =
    a next x @ --> y
    a next y @ --> z
    a next z = --> x
}
def xyz+-=_ {
    a state add x y z
    a symbol add @ = %
    a next x @ --> y
    a next y = --> z
    a next z % --> x
}
def xyz&eee {
    a state add x y z
    a next x "" --> y
    a next x "" --> z
    a next y "" --> z
}
def xyz&ee- {
    a state add x y z
    a symbol add @
    a next x "" --> y
    a next x "" --> z
    a next y @  --> z
}
def xyz&e-- {
    a state add x y z
    a symbol add @
    a next x "" --> y
    a next x @  --> z
    a next y @  --> z
}
def xyz&e-= {
    a state add x y z
    a symbol add @ =
    a next x "" --> y
    a next x @  --> z
    a next y =  --> z
}
def xyz&--- {
    a state add x y z
    a symbol add @
    a next x @ --> y
    a next x @ --> z
    a next y @ --> z
}
def xyz&--= {
    a state add x y z
    a symbol add @ =
    a next x @ --> y
    a next x @ --> z
    a next y = --> z
}
def xyz&-=_ {
    a state add x y z
    a symbol add @ = %
    a next x @ --> y
    a next x = --> z
    a next y % --> z
}
def xyz!ee {
    a state add x y z
    a next x "" --> y
    a next y "" --> z
}
def xyz!e- {
    a state add x y z
    a symbol add @
    a next x "" --> y
    a next y @  --> z
}
def xyz!-- {
    a state add x y z
    a symbol add @
    a next x @ --> y
    a next y @ --> z
}
def xyz!-= {
    a state add x y z
    a symbol add @ = %
    a next x @ --> y
    a next y = --> z
}
def xyz!-e {
    a state add x y z
    a symbol add @
    a next x @  --> y
    a next y "" --> z
}

# -------------------------------------------------------------------------
