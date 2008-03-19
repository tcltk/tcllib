# -*- tcl -*-
# (C) 2008 Andreas Kupries <andreas_kupries@users.sourceforge.net>
##
# ###

package require  sak::animate
package require  sak::feedback
package require  sak::color

getpackage textutil::repeat textutil/repeat.tcl
#getpackage fileutil         fileutil/fileutil.tcl
getpackage doctools doctools/doctools.tcl

namespace eval ::sak::validate::manpages {
    namespace import ::textutil::repeat::blank
    namespace import ::sak::color::*
    namespace import ::sak::feedback::!
    namespace import ::sak::feedback::>>
    namespace import ::sak::feedback::+=
    namespace import ::sak::feedback::=
    namespace import ::sak::feedback::=|
    namespace import ::sak::feedback::log
}

# ###

proc ::sak::validate::manpages {modules raw log stem} {
    # assert: log => !raw
    sak::feedback::init $raw $log $stem {log unc fail warn miss}
    manpages::Do $modules
    return
}

proc ::sak::validate::manpages::Do {modules} {
    # Preprocessing of module names to allow better formatting of the
    # progress output, i.e. vertically aligned columns

    # Per module we can distinguish the following levels of
    # documentation completeness and validity

    # Completeness:
    # - No package has documentation
    # - Some, but not all packages have documentation
    # - All packages have documentation.
    #
    # Validity, restricted to the set packages which have documentation:
    # - Documentation has errors and warnings
    # - Documentation has errors, but no warnings.
    # - Documentation has no errors, but warnings.
    # - Documentation has neither errors nor warnings.

    # Progress report per module: Packages it is working on.
    # Summary is at module level:
    # - Number of packages, number of packages with documentation,
    # - Number of errors, number of warnings.

    # Full log:
    # - Lists packages without documentation.
    # - Lists packages with errors/warnings.
    # - Lists the exact errors/warnings per package, and location.

    # Global preparation: Pull information about all packages and the
    # modules they belong to.

    ::doctools::new dt -format desc -deprecated 1

    Count $modules
    MapPackages

    #!
    #Head Module
    #=| "~~ Doc'd / Pkg's !Claimed Errors . Warnings"

    InitCounters
    foreach m $modules {
	InitModuleCounters
	!
	log <$m>
	Head $m

	# Per module: Find all doctools manpages inside and process
	# them. We get errors, warnings, and determine the package(s)
	# they may belong to.

	# Per package: Have they doc files claiming them? After that,
	# are doc files left over (i.e. without a package)?

	ProcessPages    $m
	ProcessPackages $m
	ProcessUnclaimed
	ModuleSummary
    }

    #!
    #Head Module
    #=| "~~ Doc'd / Pkg's !Claimed Errors . Warnings"

    Summary

    dt destroy
    return
}

# ###

proc ::sak::validate::manpages::ProcessPages {m} {
    !claims
    dt configure -module $m
    foreach f [glob -nocomplain [file join [At $m] *.man]] {
	ProcessManpage $f
    }
    return
}

proc ::sak::validate::manpages::ProcessManpage {f} {
    =file              $f
    dt configure -file $f

    if {[catch {
	dt format [get_input $f]
    } msg]} {
	+e $msg
    } else {
	foreach {pkg _ _} $msg { +claim $pkg }
    }

    set warnings [dt warnings]
    if {![llength $warnings]} return

    foreach msg $warnings { +w $msg }
    return
}

proc ::sak::validate::manpages::ProcessPackages {m} {
    !used
    if {![HasPackages $m]} return

    foreach p [ThePackages $m] {
	+pkg $p
	if {[claimants $p]} {
	    +doc $p
	} else {
	    nodoc $p
	}
    }
    return
}

proc ::sak::validate::manpages::ProcessUnclaimed {} {
    variable claims
    if {![array size claims]} return
    foreach p [lsort -dict [array names claims]] {
	foreach fx $claims($p) { +u $fx }
    }
    return
}

###

proc ::sak::validate::manpages::=file {f} {
    variable current [file tail $f]
    = "$current ..."
    return
}

###

proc ::sak::validate::manpages::!claims {} {
    variable    claims
    array unset claims *
    return
}

proc ::sak::validate::manpages::+claim {pkg} {
    variable current
    variable claims
    lappend  claims($pkg) $current
    return
}

proc ::sak::validate::manpages::claimants {pkg} {
    variable claims
    expr { [info exists claims($pkg)] && [llength $claims($pkg)] }
}


###

proc ::sak::validate::manpages::!used {} {
    variable    used
    array unset used *
    return
}

proc ::sak::validate::manpages::+use {pkg} {
    variable used
    variable claims
    foreach fx $claims($pkg) { set used($fx) . }
    unset claims($pkg)
    return
}

###

proc ::sak::validate::manpages::MapPackages {} {
    variable    pkg
    array unset pkg *

    !
    += Package
    foreach {pname pdata} [ipackages] {
	= "$pname ..."
	foreach {pver pmodule} $pdata break
	lappend pkg($pmodule) $pname
    }
    !
    =| {Packages mapped ...}
    return
}

proc ::sak::validate::manpages::HasPackages {m} {
    variable pkg
    expr { [info exists pkg($m)] && [llength $pkg($m)] }
}

proc ::sak::validate::manpages::ThePackages {m} {
    variable pkg
    return [lsort -dict $pkg($m)]
}

###

proc ::sak::validate::manpages::+pkg {pkg} {
    variable mtotal ; incr mtotal
    variable total  ; incr total
    return
}

proc ::sak::validate::manpages::+doc {pkg} {
    variable mhavedoc ; incr mhavedoc
    variable havedoc  ; incr havedoc
    = "$pkg Ok"
    +use $pkg
    return
}

proc ::sak::validate::manpages::nodoc {pkg} {
    = "$pkg Bad"
    log "\tPackage without documentation: $pkg"
    return
}

###

proc ::sak::validate::manpages::+w {msg} {
    variable mwarnings ; incr mwarnings
    variable warnings  ; incr warnings
    variable current
    foreach {a b c} [split $msg \n] break
    log "\t$current: [Trim $a] [Trim $b] [Trim $c]"
    return
}

proc ::sak::validate::manpages::+e {msg} {
    variable merrors ; incr merrors
    variable errors  ; incr errors
    variable current
    log "\t$current $msg"
    return
}

proc ::sak::validate::manpages::+u {f} {
    variable used
    if {[info exists used($f)]} return
    variable munclaimed ; incr munclaimed
    variable unclaimed  ; incr unclaimed
    set used($f) .
    log "\tUnclaimed documentation file: $f"
    return
}

###

proc ::sak::validate::manpages::Count {modules} {
    variable maxml 0
    !
    foreach m [linsert $modules 0 Module] {
	= "M $m"
	set l [string length $m]
	if {$l > $maxml} {set maxml $l}
    }
    =| "Starting validation of documentation ..."
    return
}

proc ::sak::validate::manpages::Head {m} {
    variable maxml
    += ${m}[blank [expr {$maxml - [string length $m]}]]
    return
}

###

proc ::sak::validate::manpages::InitModuleCounters {} {
    variable mtotal     0
    variable mhavedoc   0
    variable munclaimed 0
    variable merrors    0
    variable mwarnings  0
    return
}

proc ::sak::validate::manpages::ModuleSummary {} {
    variable mtotal
    variable mhavedoc
    variable munclaimed
    variable merrors
    variable mwarnings

    set complete [F $mhavedoc]/[F $mtotal]
    set err      "E [F $merrors]"
    set warn     "W [F $mwarnings]"
    set unc      "U [F $munclaimed]"

    if {$munclaimed} {
	set unc [=cya $unc]
	>> unc
    }
    if {!$mhavedoc && $mtotal} {
	set complete [=red $complete]
	>> miss
    } elseif {$mhavedoc < $mtotal} {
	set complete [=yel $complete]
	>> miss
    }
    if {$merrors} {
	set err [red]$err
	set warn $warn[rst]
	>> fail
    } elseif {$mwarnings} {
	set warn [=yel $warn]
	>> warn
    }

    =| "~~ $complete $unc $err $warn"
    return
}

###

proc ::sak::validate::manpages::InitCounters {} {
    variable total     0
    variable havedoc   0
    variable unclaimed 0
    variable errors    0
    variable warnings  0
    return
}

proc ::sak::validate::manpages::Summary {} {
    variable total
    variable havedoc
    variable unclaimed
    variable errors
    variable warnings

    set tot   [F $total]
    set doc   [F $havedoc]
    set unc   [F $unclaimed]
    set per   [format %6.2f [expr {$havedoc*100./$total}]]
    set err   [F $errors]
    set wrn   [F $warnings]

    if {$errors}    { set err [=red $err] }
    if {$warnings}  { set wrn [=yel $wrn] }
    if {$unclaimed} { set unc [=cya $unc] }

    if {!$havedoc && $total} {
	set doc [=red $doc]
    } elseif {$havedoc < $total} {
	set doc [=yel $doc]
    }

    =| ""
    =| "#Packages:   $tot            #Errors:     $err"
    =| "#Documented: $doc (${per}%)  #Warnings:   $wrn"
    =| "#Unclaimed:  $unc"
    =| ""
    return
}

###

proc ::sak::validate::manpages::F {n} { format %6d $n }

proc ::sak::validate::manpages::Trim {text} {
    regsub {^[^:]*:} $text {} text
    return [string trim $text]
}

###

proc ::sak::validate::manpages::At {m} {
    global distribution
    return [file join $distribution modules $m]
}

# ###

namespace eval ::sak::validate::manpages {
    # Max length of module names and patchlevel information.
    variable maxml 0

    # Counters across all modules
    variable total     0 ; # Number of packages overall.				     
    variable havedoc   0 ; # Number of packages with documentation.			     
    variable unclaimed 0 ; # Number of errors found in all documentation.		     
    variable errors    0 ; # Number of warnings found in all documentation.		     
    variable warnings  0 ; # Number of manpages not claimed by a specific package.

    # Same counters, per module.
    variable mtotal     0	     
    variable mhavedoc   0	     
    variable munclaimed 0	     
    variable merrors    0	     
    variable mwarnings  0

    # Name of currently processed manpage
    variable current ""

    # Map from packages to files claiming to document them.
    variable  claims
    array set claims {}

    # Set of files taken by packages, as array
    variable  used
    array set used {}

    # Map from modules to packages contained in them
    variable  pkg
    array set pkg {}
}

##
# ###

package provide sak::validate::manpages 1.0
