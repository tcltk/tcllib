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

proc loadpkglist {fname} {
    set f [open $fname r]
    foreach line [split [read $f] \n] {
	foreach {n v} $line break
	set p($n) $v
    }
    close $f
    return [array get p]
}

proc ipackages {} {
    # Determine indexed packages (ifneeded, pkgIndex.tcl)

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


proc ppackages {} {
    # Determine provided packages (provide, *.tcl - pkgIndex.tcl)

    global    p pf currentfile
    array set p {}
    foreach f [tclfiles] {
	# We ignore package indices and all files not in a module.

	if {[string equal pkgIndex.tcl [file tail $f]]} {continue}
	if {![regexp modules $f]}                       {continue}

	set fh [open $f r]

	# Source the code into a sub-interpreter. The sub interpreter
	# overloads 'package provide' so that the information about
	# new packages goes directly to us. We also make sure that the
	# sub interpreter doesn't kill us, and will not get stuck
	# early by trying to load other files, or when creating
	# procedures in namespaces which do not exist due to us
	# disabling most of the package management.

	set currentfile [eval file join [lrange [file split $f] end-1 end]]

	set ip [interp create]
	interp alias $ip package {} xPackage
	interp alias $ip source  {} xNULL
	interp alias $ip unknown {} xNULL
	interp alias $ip proc    {} xNULL
	interp alias $ip exit    {} xNULL
	if {[catch {$ip eval [read $fh]} msg]} {
	    #puts "ERROR in $currentfile:\n$msg\n"
	}
	close $fh
	interp delete $ip
    }

    set   pp [array get p]
    unset p
    return $pp 
}

proc xNULL    {args} {}
proc xPackage {cmd args} {

    if {[string equal $cmd provide]} {
	global p pf currentfile
	foreach {n v} $args break

	# No version specified, this is an inquiry, we ignore these.
	if {$v == {}} {return}

	set p($n) $v
	set pf($n) $currentfile
    }
    return
}



proc sep {} {puts ~~~~~~~~~~~~~~~~~~~~~~~~}

proc gendoc {fmt ext {mode user} {flags {}}} {
    global distribution
    global tcl_platform

    set mpe [file join $distribution modules doctools mpexpand]
    if {$tcl_platform(platform) != "unix"} {
        set mpe [list [info nameofexecutable] $mpe]
    }
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
                set target [file join doc $fmt \
                                [file rootname [file tail $f]].$ext]
                if {[file exists $target] 
                    && [file mtime $target] > [file mtime $f]} {
                    continue
                }
		puts "Gen ($fmt): $f"
		if {[catch {
		    eval exec \
			$mpe [list -module [list $m] \
                                  $fmt [list $f] [list $target] \
                                  >@ stdout 2>@ stderr]
		} msg]} {
		    puts $msg
		}
	    }
	} else {
	    foreach f $fl {
                set target [file join doc $fmt \
                                [file rootname [file tail $f]].$ext]
                if {[file exists $target] 
                    && [file mtime $target] > [file mtime $f]} {
                    continue
                }

		puts "Gen ($fmt): $f"
		if {[catch {
		    eval exec \
			$mpe [list -module [list $m] \
                                  $flags \
                                  $fmt [list $f] [list $target] \
                                  >@ stdout 2>@ stderr]
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

    set tar [auto_execok tar]
    if {$tar != {}} {
        puts "    Gzipped tarball (tcllib-${tcllib_version}.tar.gz)..."
        catch {
            exec $tar cf - tcllib-${tcllib_version} | gzip --best > tcllib-${tcllib_version}.tar.gz
        }

        set bzip [auto_execok bzip2]
        if {$bzip != {}} {
            puts "    Bzipped tarball (tcllib-${tcllib_version}.tar.bz2)..."
            exec tar cf - tcllib-${tcllib_version} | bzip2 > tcllib-${tcllib_version}.tar.bz2
        }
    }

    set zip [auto_execok zip]
    if {$zip != {}} {
        puts "    Zip archive     (tcllib-${tcllib_version}.zip)..."
        catch {
            exec $zip -r   tcllib-${tcllib_version}.zip             tcllib-${tcllib_version}
        }
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
    foreach file [glob -nocomplain [file join $src $pattern]] {
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

proc gd-tip55 {} {
    global tcllib_version tcllib_name distribution contributors
    contributors

    set md {Identifier: %N
Title:  Tcl Standard Library
Description: This package is intended to be a collection of
    Tcl packages that provide utility functions useful to a
    large collection of Tcl programmers.
Rights: BSD
Version: %V
URL: http://tcllib.sourceforge.net/
Architecture: tcl
}

    regsub {Version: %V} $md "Version: $tcllib_version" md
    regsub {Identifier: %N} $md "Identifier: $tcllib_name" md
    foreach person [lsort [array names contributors]] {
        set mail $contributors($person)
        regsub {@}  $mail " at " mail
        regsub -all {\.} $mail " dot " mail
        append md "Contributor: $person <$mail>\n"
    }

    set f [open [file join $distribution DESCRIPTION.txt] w]
    puts $f $md
    close $f
}

# Fill the global array of contributors to tcllib by processing the
# ChangeLog entries.
#
proc contributors {} {
    global distribution contributors
    if {![info exists contributors] || [array size contributors] == 0} {
        get_contributors [file join $distribution ChangeLog]

        foreach f [glob -nocomplain [file join $distribution modules *]] {
            if {![file isdirectory $f]} {continue}
            if {[string match CVS [file tail $f]]} {continue}
            if {![file exists [file join $f ChangeLog]]} {continue}
            get_contributors [file join $f ChangeLog]
        }
    }
}

proc get_contributors {changelog} {
    global contributors
    set f [open $changelog r]
    while {![eof $f]} {
        gets $f line
        if {[regexp {^[\d-]+\s+(.*?)<(.*?)>} $line r name mail]} {
            set name [string trim $name]
            if {![info exists names($name)]} {
                set contributors($name) $mail
            }
        }
    }
    close $f
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


proc validate_versions {} {
    foreach {p v} [ipackages] {set ip($p) $v}
    foreach {p v} [ppackages] {set pp($p) $v}

    set maxl 0
    foreach name [array names ip] {if {[string length $name] > $maxl} {set maxl [string length $name]}}
    foreach name [array names pp] {if {[string length $name] > $maxl} {set maxl [string length $name]}}

    foreach p [lsort [array names ip]] {
	if {![info exists pp($p)]} {
	    puts "  Indexed, no provider:           $p"
	}
    }
    foreach p [lsort [array names pp]] {
	if {![info exists ip($p)]} {
	    puts "  Provided, not indexed:          [format "%-*s | %s" $maxl $p $::pf($p)]"
	}
    }
    foreach p [lsort [array names ip]] {
	if {
	    [info exists pp($p)] && ![string equal $pp($p) $ip($p)]
	} {
	    puts "  Index/provided versions differ: [format "%-*s | %8s | %8s" $maxl $p $ip($p) $pp($p)]"
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
        contributors     - Print a list of contributors to tcllib.
	lmodules         - See above, however one module per line
	imodules         - Return list of modules known to the installer.

	packages         - Return indexed packages in tcllib, plus versions,
	                   one package per line. Extracted from the
	                   package indices found in the modules.
	provided         - Return list and versions of provided packages
	                   (in contrast to indexed).
	vcompare pkglist - Compare package list of previous 'packages'
	                   call with current packages. Marks all new
	                   and unchanged packages for higher attention.

	validate         - Check various parts of tcllib for problems.
	test ?module...? - Run testsuite for listed modules.
	                   For all modules if none specified.

	/Release engineering
	gendist  - Generate distribution from CVS snapshot
        gentip55 - Generate a TIP55-style DESCRIPTION.txt file.

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


proc nparray {a} {
    upvar $a packages

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

proc __packages {} {
    array set packages [ipackages]
    nparray packages
    return
}

proc __provided {} {
    array set packages [ppackages]
    nparray packages
    return
}


proc __vcompare {} {
    global argv
    set oldplist [lindex $argv 0]

    array set curpkg [ipackages]
    array set oldpkg [loadpkglist $oldplist]

    foreach p [array names curpkg] {set __($p) .}
    foreach p [array names oldpkg] {set __($p) .}
    set unified [lsort [array names __]]
    unset __

    set maxl 0
    foreach name $unified {
        if {[string length $name] > $maxl} {
            set maxl [string length $name]
        }
    }
    foreach name $unified {
	set suffix ""
	if {![info exists curpkg($name)]} {set curpkg($name) "--"}
	if {![info exists oldpkg($name)]} {set oldpkg($name)   "--" ; append suffix " NEW"}
	if {[string equal $oldpkg($name) $curpkg($name)]} {append suffix " \t<<<"}
        puts stdout [format "%-*s %-*s %-*s" $maxl $name 8 $oldpkg($name) 8 $curpkg($name)]$suffix
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

    puts "[incr i]: Consistency of package versions ..."
    puts "------------------------------------------------------"
    validate_versions
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
    gd-tip55
    gd-assemble
    gd-gen-archives

    puts ...Done
    return
}

proc __gentip55 {} {
    gd-tip55
    puts "Created DESCRIPTION.txt"
    return
}

proc __contributors {} {
    global contributors
    contributors
    foreach person [lsort [array names contributors]] {
        puts "$person <$contributors($person)>"
    }
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
    
    set FILES [glob -nocomplain doc/list/*.l]
    set LIST [open [file join doc list manpages.tcl] w]

    foreach file $FILES {
        set f [open $file r]
        puts $LIST [read $f]
        close $f
    }
    close $LIST

    eval file delete -force $FILES

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
