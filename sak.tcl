#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

# --------------------------------------------------------------
# Perform various checks and operations on the distribution.
# SAK = Swiss Army Knife.

set distribution   [file dirname [info script]]
lappend auto_path  [file join $distribution modules]

source [file join $distribution tcllib_version.tcl] ; # Get version information.

# --------------------------------------------------------------

proc tclfiles {} {
    global distribution
    package require fileutil
    set fl [fileutil::findByPattern $distribution -glob *.tcl]
    proc tclfiles {} [list return $fl]
    return $fl
}

proc modules {} {
    global distribution
    set fl [list]
    foreach f [glob -nocomplain [file join $distribution modules *]] {
	if {![file isdirectory $f]} {continue}
	if {[string match CVS [file tail $f]]} {continue}

	if {![file exists [file join $f pkgIndex.tcl]]} {continue}

	lappend fl [file tail $f]
    }
    set fl [lsort $fl]
    proc modules {} [list return $fl]
    return $fl
}


proc imodules {} {
    global distribution
    source [file join $distribution installed_modules.tcl] ; # Get list of installed modules.

    proc imodules {} [list return $modules]
    return $modules
}


proc packages {} {
    global distribution
    array set p {}
    foreach m [modules] {
	set f [open [file join $distribution modules $m pkgIndex.tcl] r]
	foreach line [split [read $f] \n] {
	    if { [regexp {#}        $line]} {continue}
	    if {![regexp {ifneeded} $line]} {continue}
	    regsub {^.*ifneeded } $line {} line
	    regsub {([0-9]) \[.*$}  $line {\1} line

	    foreach {n v} $line break
	    set p($n) $v
	}
	close $f
    }
    return [array get p]
}



proc sep {} {puts ~~~~~~~~~~~~~~~~~~~~~~~~}

proc gendoc {fmt ext {mode user} {flags {}}} {
    global distribution

    set mpe [file join $distribution modules doctools mpexpand]
    set ::env(TCLLIBPATH) [file join $distribution modules]

    foreach m [modules] {
	switch -exact -- $mode {
	    user   {set fl [glob -nocomplain [file join $distribution modules $m *.man]]}
	    dev    {set fl [glob -nocomplain [file join $distribution modules $m *.dev.man]]}
	    all    {set fl [glob -nocomplain [file join $distribution modules $m *.man]]}
	    single {set fl [list ]}
	    default {return -code error "Invalid mode $mode"}
	}
	if {[llength $fl] == 0} {continue}
	file mkdir [file join doc $fmt]

	if {$flags == {}} {
	    foreach f $fl {
		puts "Gen ($fmt): $f"
		if {[catch {
		    exec \
			[list $mpe] -module [list $m] \
			$fmt [list $f] [list [file join doc $fmt [file rootname [file tail $f]].$ext]] \
			>@ stdout 2>@ stderr
		} msg]} {
		    puts $msg
		}
	    }
	} else {
	    foreach f $fl {
		puts "Gen ($fmt): $f"
		if {[catch {
		    exec \
			[list $mpe] -module [list $m] \
			$flags \
			$fmt [list $f] [list [file join doc $fmt [file rootname [file tail $f]].$ext]] \
			>@ stdout 2>@ stderr
		} msg]} {
		    puts $msg
		}
	    }
	}
    }
}


proc gd-cleanup {} {
    global tcllib_version

    puts {Cleaning up...}

    set        fl [glob -nocomplain tcllib-${tcllib_version}*]
    foreach f $fl {
	puts "    Deleting $f ..."
	catch {file delete -force $f}
    }
    return
}

proc gd-gen-archives {} {
    global tcllib_version

    puts {Generating archives...}

    puts "    Gzipped tarball (tcllib-${tcllib_version}.tar.gz)..."
    exec tar cf - tcllib-${tcllib_version} | gzip --best > tcllib-${tcllib_version}.tar.gz 

    puts "    Zip archive     (tcllib-${tcllib_version}.zip)..."
    exec zip -r   tcllib-${tcllib_version}.zip             tcllib-${tcllib_version}

    set bzip [auto_execok bzip2]
    if {$bzip != {}} {
	puts "    Bzipped tarball (tcllib-${tcllib_version}.tar.bz2)..."
	exec tar cf - tcllib-${tcllib_version} | bzip2 > tcllib-${tcllib_version}.tar.bz2
    }

    set sdx [auto_execok sdx]
    if {$sdx != {}} {
	file rename tcllib-${tcllib_version} tcllib.vfs

	puts "    Starkit         (tcllib-${tcllib_version}.kit)..."
	exec sdx wrap tcllib
	file rename   tcllib tcllib-${tcllib_version}.kit

	if {![file exists tclkit]} {
	    puts "    No tclkit present in current working directory, no starpack."
	} else {
	    puts "    Starpack        (tcllib-${tcllib_version}.exe)..."
	    exec sdx wrap tcllib -runtime tclkit
	    file rename   tcllib tcllib-${tcllib_version}.exe
	}

	file rename tcllib.vfs tcllib-${tcllib_version}
    }

    puts {    Keeping directory for other archive types}

    ## Keep the directory for 'sdx' - kit/pack
    return
}

proc xcopy {src dest recurse {pattern *}} {
    file mkdir $dest
    foreach file [glob [file join $src $pattern]] {
        set base [file tail $file]
	set sub  [file join $dest $base]

	# Exclude CVS automatically, and possibly the temp hierarchy
	# itself too.

	if {0 == [string compare CVS $base]} {continue}
	if {[string match tcllib-*   $base]} {continue}
	if {[string match *~         $base]} {continue}

        if {[file isdirectory $file]} then {
	    if {$recurse} {
		file mkdir  $sub
		xcopy $file $sub $recurse $pattern
	    }
        } else {
	    puts -nonewline stdout . ; flush stdout

            file copy -force $file $sub
        }
    }
}

proc gd-assemble {} {
    global tcllib_version distribution

    puts "Assembling distribution in directory 'tcllib-${tcllib_version}'"

    xcopy $distribution tcllib-${tcllib_version} 1
    file delete -force \
	    tcllib-${tcllib_version}/config \
	    tcllib-${tcllib_version}/modules/ftp/example \
	    tcllib-${tcllib_version}/modules/ftpd/examples \
	    tcllib-${tcllib_version}/modules/stats \
	    tcllib-${tcllib_version}/modules/fileinput
    puts ""
    return
}


proc validate_imodules {} {
    foreach m [imodules] {set im($m) .}
    foreach m [modules]  {set dm($m) .}
    foreach m [imodules] {
	if {![info exists dm($m)]} {
	    puts "  Installed, does not exist: $m"
	}
    }
    foreach m [modules] {
	if {![info exists im($m)]} {
	    puts "  Missing in installer:      $m"
	}
    }
    return
}


proc validate_testsuites {} {
    global distribution
    foreach m [modules] {
	if {[llength [glob -nocomplain [file join $distribution modules $m *.test]]] == 0} {
	    puts "  Without testsuite : $m"
	}
    }
    return
}

proc validate_pkgIndex {} {
    global distribution
    foreach m [modules] {
	if {[llength [glob -nocomplain [file join $distribution modules $m pkgIndex.tcl]]] == 0} {
	    puts "  Without package index : $m"
	}
    }
    return
}

proc validate_doc_existence {} {
    global distribution
    foreach m [modules] {
	if {[llength [glob -nocomplain [file join $distribution modules $m {*.[13n]}]]] == 0} {
	    if {[llength [glob -nocomplain [file join $distribution modules $m {*.man}]]] == 0} {
		puts "  Without * any ** manpages : $m"
	    }
	} elseif {[llength [glob -nocomplain [file join $distribution modules $m {*.man}]]] == 0} {
	    puts "  Without doctools manpages : $m"
	} else {
	    foreach f [glob -nocomplain [file join $distribution modules $m {*.[13n]}]] {
		if {![file exists [file rootname $f].man]} {
		    puts "     no .man equivalent : $f"
		}
	    }
	}
    }
    return
}


proc validate_doc_markup {} {
    gendoc null null user -deprecated
    file delete -force [file join doc null]
    return
}


proc run-frink {} {
    global distribution
    foreach f [tclfiles] {
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	puts "$f..."
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

	catch {exec frink 2>@ stderr -H $f}
    }
    return
}

proc run-procheck {} {
    global distribution
    foreach f [tclfiles] {
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	puts "$f ..."
	puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

	catch {exec procheck >@ stdout $f}
    }
    return
}

# --------------------------------------------------------------
# Help

proc __help {} {
    puts stdout {
	Commands avalable through the swiss army knife aka SAK:

	help     - This help

	/Configuration
	version  - Return tcllib version number
	major    - Return tcllib major version number
	minor    - Return tcllib minor version number
	name     - Return tcllib package name

	/Development
	modules          - Return list of modules.
	lmodules         - See above, however one module per line
	packages         - Return packages in tcllib, plus versions,
	                   one package per line. Extracted from the
	                   package indices found in the modules.
	validate         - Check various parts of tcllib for problems.
	test ?module...? - Run testsuite for listed modules.
	                   For all modules if none specified.

	/Release engineering
	gendist  - Generate distribution from CVS snapshot

	/Documentation
	nroff    - Generate manpages
	html     - Generate HTML pages
	tmml     - Generate TMML
	text     - Generate plain text
	list     - Generate a list of manpages
	wiki     - Generate wiki markup
	latex    - Generate LaTeX pages
	dvi      - See latex, + conversion to dvi
	ps       - See dvi,   + conversion to PostScript
    }
}

# --------------------------------------------------------------
# Configuration

proc __name    {} {global tcllib_name    ; puts $tcllib_name}
proc __version {} {global tcllib_version ; puts $tcllib_version}
proc __minor   {} {global tcllib_version ; puts [lindex [split $tcllib_version .] 1]}
proc __major   {} {global tcllib_version ; puts [lindex [split $tcllib_version .] 0]}

# --------------------------------------------------------------
# Development

proc __imodules {}  {puts [imodules]}
proc __modules {}  {puts [modules]}
proc __lmodules {} {puts [join [modules] \n]}

proc __packages {} {
    array set packages [packages]

    set maxl 0
    foreach name [lsort [array names packages]] {
        if {[string length $name] > $maxl} {
            set maxl [string length $name]
        }
    }
    foreach name [lsort [array names packages]] {
        puts stdout [format "%-*s %s" $maxl $name $packages($name)]
    }
    return
}

proc __test {} {
    global argv distribution
    # Run testsuite

    set modules $argv
    if {[llength $modules] == 0} {
	set modules [modules]
    }

    exec [info nameofexecutable] \
	    [file join $distribution all.tcl] \
	    -modules $modules \
	    >@ stdout 2>@ stderr
    return
}



proc __validate {} {
    global tcllib_name tcllib_version
    set i 0

    puts "Validating $tcllib_name $tcllib_version development"
    puts "==================================================="
    puts "[incr i]: Existence of testsuites ..."
    puts "------------------------------------------------------"
    validate_testsuites
    puts "------------------------------------------------------"
    puts ""

    puts "[incr i]: Existence of package indices ..."
    puts "------------------------------------------------------"
    validate_pkgIndex
    puts "------------------------------------------------------"
    puts ""

    puts "[incr i]: Installed vs. developed modules ..."
    puts "------------------------------------------------------"
    validate_imodules
    puts "------------------------------------------------------"
    puts ""

    puts "[incr i]: Existence of documentation ..."
    puts "------------------------------------------------------"
    validate_doc_existence
    puts "------------------------------------------------------"
    puts ""

    puts "[incr i]: Validate documentation markup (doctools) ..."
    puts "------------------------------------------------------"
    validate_doc_markup
    puts "------------------------------------------------------"
    puts ""

    puts "[incr i]: Static syntax check ..."
    puts "------------------------------------------------------"

    set frink    [auto_execok frink]
    set procheck [auto_execok procheck]

    if {$frink    == {}} {puts "  Tool 'frink'    not found, no check"}
    if {$procheck == {}} {puts "  Tool 'procheck' not found, no check"}
    if {($frink == {}) || ($procheck == {})} {
	puts "------------------------------------------------------"
    }
    if {($frink == {}) && ($procheck == {})} {
	return
    }
    if {$frink    != {}} {
	run-frink
	puts "------------------------------------------------------"
    }
    if {$procheck    != {}} {
	run-procheck
	puts "------------------------------------------------------"
    }
    puts ""

    return
}


# --------------------------------------------------------------
# Release engineering

proc __gendist {} {
    gd-cleanup
    gd-assemble
    gd-gen-archives

    puts ...Done
    return
}

# --------------------------------------------------------------
# Documentation

proc __html  {} {gendoc html  html}
proc __nroff {} {gendoc nroff n}
proc __tmml  {} {gendoc tmml  tmml}
proc __text  {} {gendoc text  txt}
proc __wiki  {} {gendoc wiki  wiki}
proc __latex {} {gendoc latex tex}
proc __dvi   {} {
    __latex
    file mkdir [file join doc dvi]
    cd         [file join doc dvi]
    foreach f [glob -nocomplain ../latex/*.tex] {
	puts "Gen (dvi): $f"
	exec latex $f 1>@ stdout 2>@ stderr
    }
    cd ../..
}
proc __ps   {} {
    __dvi
    file mkdir [file join doc ps]
    cd         [file join doc ps]
    foreach f [glob -nocomplain ../dvi/*.dvi] {
	puts "Gen (dvi): $f"
	exec dvips -o [file rootname [file tail $f]].ps $f 1>@ stdout 2>@ stderr
    }
    cd ../..
}

proc __list  {} {
    gendoc list l
    exec cat [glob -nocomplain doc/list/*.l] > doc/list/manpages.tcl
    eval file delete -force [glob -nocomplain doc/list/*.l]
    return
}

# --------------------------------------------------------------

set cmd [lindex $argv 0]
if {[llength [info procs __$cmd]] == 0} {
    puts stderr "unknown command $cmd"
    set fl {}
    foreach p [lsort [info procs __*]] {
	lappend fl [string range $p 2 end]
    }
    puts stderr "use: [join $fl ", "]"
    exit 1
}

set  argv [lrange $argv 1 end]
incr argc -1

__$cmd
exit 0
