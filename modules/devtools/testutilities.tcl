# -*- tcl -*-
# Testsuite utilities / boilerplate
# Copyright (c) 2006, Andreas Kupries <andreas_kupries@users.sourceforge.net>

# ### ### ### ######### ######### #########
## Commands for common functions and boilerplate actions required by
## many testsuites of Tcllib modules and packages in a central place
## for easier maintenance.

# ### ### ### ######### ######### #########
## Declare the minimal version of Tcl required to run the package
## tested by this testsuite, and its dependencies.

proc testsNeedTcl {version} {
    # This command ensures that a minimum version of Tcl is used to
    # run the tests in the calling testsuite. If the minimum is not
    # met by the active interpreter we forcibly bail out of the
    # testsuite calling the command. The command has to be called
    # immediately after loading the utilities.

    if {[package vsatisfies [package provide Tcl] $version]} return

    puts "    Aborting the tests found in \"[file tail [info script]]\""
    puts "    Requiring at least Tcl $version, have [package present Tcl]."

    # This causes a 'return' in the calling scope.
    return -code return
}

# ### ### ### ######### ######### #########
## Declare the minimum version of Tcltest required to run the
## testsuite.

proc testsNeedTcltest {version} {
    # This command ensure that a minimum version of the Tcltest
    # support package is used to run the tests in the calling
    # testsuite. If the minimum is not met by the loaded package we
    # forcibly bail out of the testsuite calling the command. The
    # command has to be called after loading the utilities. The only
    # command allowed to come before it is 'textNeedTcl' above.

    # Note that this command will try to load a suitable version of
    # Tcltest if the package has not been loaded yet.

    if {[lsearch [namespace children] ::tcltest] == -1} {
	if {![catch {
	    package require tcltest $version
	}]} {
	    namespace import ::tcltest::*
	    return
	}
    } elseif {[package vcompare [package present tcltest] $version] >= 0} {
	return
    }

    puts "    Aborting the tests found in [file tail [info script]]."
    puts "    Requiring at least tcltest $version, have [package present tcltest]"

    # This causes a 'return' in the calling scope.
    return -code return
}

# ### ### ### ######### ######### #########
## Newer versions of the Tcltest support package for testsuite provide
## various features which make the creation and maintenance of
## testsuites much easier. I consider it important to have these
## features even if an older version of Tcltest is loaded. To this end
## we now provide emulations and implementations, conditional on the
## version of Tcltest found to be active.

# ### ### ### ######### ######### #########
## Easy definition and initialization of test constraints.

if {![package vsatisfies [package provide tcltest] 2.0]} {
    # Tcltest 2.0+ provides a documented public API to define and
    # initialize a test constraint. For earlier versions of the
    # package the user has to directly set a non-public undocumented
    # variable in the package's namespace. We create a command doing
    # this and emulating the public API.

    proc ::tcltest::testConstraint {c args} {
	variable testConstraints
        if {[llength $args] < 1} {
            if {[info exists testConstraints($c)]} {
                return $testConstraints($c)
            } else {
                return {}
            }
        } else {
            set testConstraints($c) [lindex $args 0]
        }
	return
    }
}

# ### ### ### ######### ######### #########
## Define a set of standard constraints

::tcltest::testConstraint tcl8.3only \
	[expr {![package vsatisfies [package provide Tcl] 8.4]}]

::tcltest::testConstraint tcl8.3plus \
	[expr {[package vsatisfies [package provide Tcl] 8.3]}]

::tcltest::testConstraint tcl8.4plus \
	[expr {[package vsatisfies [package provide Tcl] 8.4]}]

::tcltest::testConstraint tcl8.5plus \
	[expr {[package vsatisfies [package provide Tcl] 8.5]}]

# ### ### ### ######### ######### #########
## Cross-version code for the generation of the error messages created
## by Tcl procedures when called with the wrong number of arguments,
## either too many, or not enough.

if {[package vsatisfies [package provide Tcl] 8.5]} {
    # 8.5+
    proc ::tcltest::wrongNumArgs {functionName argList missingIndex} {
	if {[string match args [lindex $argList end]]} {
	    set argList [lreplace $argList end end ...]
	}
	if {$argList != {}} {set argList " $argList"}
	set msg "wrong # args: should be \"$functionName$argList\""
	return $msg
    }

    proc ::tcltest::tooManyArgs {functionName argList} {
	# create a different message for functions with no args
	if {[llength $argList]} {
	    if {[string match args [lindex $argList end]]} {
		set argList [lreplace $argList end end ...]
	    }
	    set msg "wrong # args: should be \"$functionName $argList\""
	} else {
	    set msg "wrong # args: should be \"$functionName\""
	}
	return $msg
    }
} elseif {[package vsatisfies [package provide Tcl] 8.4]} {
    # 8.4+
    proc ::tcltest::wrongNumArgs {functionName argList missingIndex} {
	if {$argList != {}} {set argList " $argList"}
	set msg "wrong # args: should be \"$functionName$argList\""
	return $msg
    }

    proc ::tcltest::tooManyArgs {functionName argList} {
	# create a different message for functions with no args
	if {[llength $argList]} {
	    set msg "wrong # args: should be \"$functionName $argList\""
	} else {
	    set msg "wrong # args: should be \"$functionName\""
	}
	return $msg
    }
} else {
    # 8.3+
    proc ::tcltest::wrongNumArgs {functionName argList missingIndex} {
	set msg "no value given for parameter "
	append msg "\"[lindex $argList $missingIndex]\" to "
	append msg "\"$functionName\""
	return $msg
    }

    proc ::tcltest::tooManyArgs {functionName argList} {
	set msg "called \"$functionName\" with too many arguments"
	return $msg
    }
}

# ### ### ### ######### ######### #########
## General utilities

# - dictsort -
#
#  Sort a dictionary by its keys. I.e. reorder the contents of the
#  dictionary so that in its list representation the keys are found in
#  ascending alphabetical order. In other words, this command creates
#  a canonical list representation of the input dictionary, suitable
#  for direct comparison.
#
# Arguments:
#	dict:	The dictionary to sort.
#
# Result:
#	The canonical representation of the dictionary.

proc dictsort {dict} {
    array set a $dict
    set out [list]
    foreach key [lsort [array names a]] {
	lappend out $key $a($key)
    }
    return $out
}

# ### ### ### ######### ######### #########
##

# ### ### ### ######### ######### #########
