# -*- tcl -*-
#
# _common.tcl
#
# (c) 2001 Andreas Kupries <andreas_kupries@sourceforge.net>
#
# Code shared between HTML and NROFF formatters.
#
################################################################

global    state
array set state {
    syn   0
    req   0
    call  {}
    mdesc {}
}


# Called before the first pass, returns number of passes required for
# the generation.

proc NumPasses {} {return 2}

# Called before the first output.
# Reset the syn flag
proc PassSetup {} {
    global state
    set    state(syn) 0
    set    state(req) 0
    return
}

# Called after the last pass.
proc PostProcess {expansion} {
    return $expansion
}

# Called to handle plain text from the input
proc HandleText {text} {
    return $text
}

# State mgmt.

proc AddCall {text} {
    global state
    append state(call) $text
    return
}

proc GetCall {} {
    global  state
    return $state(call)
}

proc SetDesc {key text} {
    global state
    set    state($key) $text
    return
}

proc GetDesc {key} {
    global state
    switch -exact $key {
	mdesc {return $state(mdesc)}
	tdesc {
	    if {![info exists state(tdesc)]} {
		return $state(mdesc)
	    }
	    return $state(tdesc)
	}
	default {
	    return -code error "Illegal description key \"$key\""
	}
    }
}

proc Syn {} {
    global   state
    set res $state(syn)
    set      state(syn) 1
    return $res
}

proc Req {{n {}}} {
    global state
    if {$n != {}} {
	set state(req) $n
    }
    return $state(req)
}
