#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

set tcllib_version 1.4
set distribution   [file dirname [info script]]
lappend auto_path  [file join $distribution modules]

# --------------------------------------------------------------
# Low-level commands of the installation engine.

proc i_xcopy_all {src dest} {
    run file mkdir $dest
    foreach file [glob [file join $src *]] {
        set base [file tail $file]
	set sub  [file join $dest $base]

	if {0 == [string compare CVS $base]} {continue}

        if {[file isdirectory $file]} then {
            run file mkdir  $sub
            i_xcopy_all $file $sub
        } else {
            run file copy -force $file $sub
        }
    }
}

proc i_xcopy_pattern {src dest {pattern *}} {
    run file mkdir $dest
    foreach file [glob [file join $src $pattern]] {
	if {[file isdirectory $file]} {continue}

        set base [file tail $file]
	if {0 == [string compare CVS $base]} {continue}

	set sub  [file join $dest $base]
	run file copy -force $file $sub
    }
}

# --------------------------------------------------------------
# Module specific commands

proc _null {args} {}

proc _tcl {module libdir} {
    global distribution

    i_xcopy_pattern \
	    [file join $distribution modules $module] \
	    [file join $libdir $module] \
	    *.tcl
    return
}

proc _doc {module libdir} {
    global distribution

    i_xcopy_pattern \
	    [file join $distribution modules $module] \
	    [file join $libdir $module] \
	    *.tcl

    i_xcopy_all \
	    [file join $distribution modules $module mpformats] \
	    [file join $libdir $module mpformats]
    return
}

proc _tex {module libdir} {
    global distribution

    i_xcopy_pattern \
	    [file join $distribution modules $module] \
	    [file join $libdir $module] \
	    *.tcl
    i_xcopy_pattern \
	    [file join $distribution modules $module] \
	    [file join $libdir $module] \
	    *.tex
    return
}

proc get_input {f} {return [read [set if [open $f r]]][close $if]}
proc write_out {f text} {
    global config
    if {$config(dry)} {
	puts "Generate $f"
	return
    }
    puts -nonewline [set of [open $f w]] $text
    close $of
}
proc _man {module format ext docdir} {
    global distribution argv argc argv0 config

    package require doctools
    ::doctools::new dt -format $format -module $module

    foreach f [glob -nocomplain [file join $distribution modules $module *.man]] {

	set out [file join $docdir [file rootname [file tail $f]]].$ext

	if {$config(dry)} {
	    puts "Generate $out"
	    continue
	}

	dt configure -file $f
	write_out $out [dt format [get_input $f]]

	set warnings [dt warnings]
	if {[llength $warnings] > 0} {
	    puts stderr [join $warnings \n]
	}
    }
    dt destroy
    return
}

proc _exa {module exadir} {
    global distribution
    i_xcopy_all \
	    [file join $distribution examples $module] \
	    [file join $exadir $module]
    return
}

# --------------------------------------------------------------
# List of modules to install (and definitions guiding the process)

set     modules [list]
array set guide {}
foreach {m pkg doc exa} {
    base64	_tcl  _man  _null
    calendar	_tcl  _man  _null
    cmdline	_tcl  _man  _null
    comm	_tcl  _man  _null
    control	_tcl  _man  _null
    counter	_tcl  _man  _null
    crc		_tcl  _man  _null
    csv		_tcl  _man _exa
    dns		_tcl  _man _exa
    doctools	 _doc _man _exa
    exif	_tcl  _man  _null
    fileutil	_tcl  _man  _null
    ftp		_tcl  _man _exa
    ftpd	_tcl  _man _exa
    html	_tcl  _man  _null
    htmlparse	_tcl  _man  _null
    irc		_tcl  _man _exa
    javascript	_tcl  _man  _null
    log		_tcl  _man  _null
    math	_tcl  _man  _null
    md5		_tcl  _man  _null
    md4		_tcl  _man  _null
    mime	_tcl  _man _exa
    ncgi	_tcl  _man  _null
    nntp	_tcl  _man _exa
    ntp		_tcl  _man _exa
    pop3	_tcl  _man  _null
    pop3d	_tcl  _man  _null
    profiler	_tcl  _man  _null
    report	_tcl  _man  _null
    sha1	_tcl  _man  _null
    smtpd	_tcl  _man _exa
    soundex	_tcl  _man  _null
    stooop	_tcl  _man  _null
    struct	_tcl  _man _exa
    textutil	 _tex _man  _null
    uri		_tcl  _man  _null
} {
    lappend modules $m
    set guide($m,pkg) $pkg
    set guide($m,doc) $doc
    set guide($m,exa) $exa
}

# --------------------------------------------------------------
# Use configuration to perform installation

proc run {args} {
    global config
    if {$config(dry)} {
	puts stderr [join $args]
	return
    }
    #eval $args
    return
}

proc xinstall {type args} {
    global modules guide
    foreach m $modules {
	eval $guide($m,$type) $m $args
    }
    return
}

proc doinstall {} {
    global config

    if {$config(pkg)}       {xinstall pkg $config(pkg,path)}
    if {$config(doc,nroff)} {xinstall doc nroff n    $config(doc,nroff,path)}
    if {$config(doc,html)}  {xinstall doc html  html $config(doc,html,path)}
    if {$config(exa)}       {xinstall exa $config(exa,path)}
    return
}


# --------------------------------------------------------------
# Initialize configuration.

array set config {
    pkg 1 pkg,path {}
    doc,nroff 0 doc,nroff,path {}
    doc,html  0 doc,html,path  {}
    exa 1 exa,path {}
    dry 0
}

# --------------------------------------------------------------
# Determine a default configuration, if possible

proc defaults {} {
    global tcl_platform config tcllib_version distribution

    if {[string compare $distribution [info nameofexecutable]] == 0} {
	# Starpack. No defaults for location.
    } else {
	# Starkit, or unwrapped. Derive defaults location from the
	# location of the executable running the installer, or the
	# location of its library.

	# For a starkit [info library] is inside the running
	# tclkit. Detect this and derive the lcoation from the
	# location of the executable itself for that case.

	if {[string match [info nameofexecutable]* [info library]]} {
	    set tclcorelibdir [file join [file dirname [file dirname [info nameofexecutable]]] lib xxx]
	} else {
	    set tclcorelibdir [info library]
	}

	set libdir  [file dirname $tclcorelibdir]
	set basedir [file dirname $libdir]
	set bindir  [file join $basedir bin]

	if {[string compare $tcl_platform(platform) windows] == 0} {
	    set mandir  {}
	    set htmldir [file join $basedir tcllib_doc]
	} else {
	    set mandir  [file join $basedir man mann]
	    set htmldir [file join $libdir  tcllib${tcllib_version} tcllib_doc]
	}

	set config(pkg,path)       [file join $libdir tcllib${tcllib_version}]
	set config(doc,nroff,path) $mandir
	set config(doc,html,path)  $htmldir
	set config(exa,path)       [file join $bindir tcllib_examples${tcllib_version}]
    }

    if {[string compare $tcl_platform(platform) windows] == 0} {
	set config(doc,nroff) 0
	set config(doc,html)  1
    } else {
	set config(doc,nroff) 1
	set config(doc,html)  0
    }
    return
}

# --------------------------------------------------------------
# Show configuration on stdout.

proc showconfiguration {} {
    global config tcllib_version

    puts "Installing Tcllib $tcllib_version"
    if {$config(dry)} {
	puts "\tDry run, simulation, no actual activity."
	puts ""
    }

    puts "You have chosen the following configuration ..."
    puts ""

    if {$config(pkg)} {
	puts "Packages:      $config(pkg,path)"
    } else {
	puts "Packages:      Not installed."
    }
    if {$config(exa)} {
	puts "Examples:      $config(exa,path)"
    } else {
	puts "Examples:      Not installed."
    }
    if {$config(doc,nroff) || $config(doc,html)} {
	puts "Documentation:"
	puts ""
	if {$config(doc,nroff)} {
	    puts "\tNROFF:  $config(doc,nroff,path)"
	} else {
	    puts "\tNROFF:  Not installed"
	}
	if {$config(doc,html)} {
	    puts "\tHTML:   $config(doc,html,path)"
	} else {
	    puts "\tHTML:   Not installed"
	}
    } else {
	puts "Documentation: Not installed."
    }
    puts ""
    return
}

# --------------------------------------------------------------
# Setup the installer user interface

proc handlegui {} {
    handlecmdline ; return

    ... TODO ...
}

# --------------------------------------------------------------
# Handle a command line

proc handlecmdline {} {
    processargs
    showconfiguration
    wait
    return
}

proc processargs {} {
    global argv argv0 config

    while {[llength $argv] > 0} {
	switch -exact -- [lindex $argv 0] {
	    -simulate    -
	    -dry-run     {set config(dry) 1}
	    -html        {set config(doc,html) 1}
	    -nroff       {set config(doc,nroff) 1}
	    -examples    {set config(exa) 1}
	    -pkgs        {set config(pkg) 1}
	    -no-html     {set config(doc,html) 0}
	    -no-nroff    {set config(doc,nroff) 0}
	    -no-examples {set config(exa) 0}
	    -no-pkgs     {set config(pkg) 0}
	    -pkg-path {
		set config(pkg) 1
		set config(pkg,path) [lindex $argv 1]
		set argv             [lrange $argv 1 end]
	    }
	    -nroff-path {
		set config(doc,nroff) 1
		set config(doc,nroff,path) [lindex $argv 1]
		set argv                   [lrange $argv 1 end]
	    }
	    -html-path {
		set config(doc,html) 1
		set config(doc,html,path) [lindex $argv 1]
		set argv                  [lrange $argv 1 end]
	    }
	    -example-path {
		set config(exa) 1
		set config(exa,path) [lindex $argv 1]
		set argv             [lrange $argv 1 end]
	    }
	    -help   -
	    default {
		puts stderr "usage: $argv0 ?-dry-run/-simulate? ?-html|-no-html? ?-nroff|-no-nroff? ?-examples|-no-examples? ?-pkgs|-no-pkgs? ?-pkg-path path? ?-nroff-path path? ?-html-path path? ?-example-path path?"
		exit 1
	    }
	}
	set argv [lrange $argv 1 end]
    }
    return
}

proc wait {} {
    puts -nonewline stdout "Is the chosen configuration ok ? y/N: "
    flush stdout
    set answer [gets stdin]
    if {($answer == {}) || [string match "\[Nn\]*" $answer]} {
	puts stdout "\tNo. Aborting."
	exit 0
    }
    return
}

# --------------------------------------------------------------
# Main code

proc main {} {
    defaults
    if {[catch {package require Tk}]} {
	handlecmdline
    } else {
	handlegui
    }
    doinstall
    return
}

# --------------------------------------------------------------
main
exit 0
# --------------------------------------------------------------
