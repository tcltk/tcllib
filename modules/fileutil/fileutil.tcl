# fileutil.tcl --
#
#	Tcl implementations of standard UNIX utilities.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: fileutil.tcl,v 1.14 2002/05/21 17:44:41 andreas_kupries Exp $

package require Tcl 8
package require cmdline
package provide fileutil 1.4

namespace eval ::fileutil {
    namespace export grep find findByPattern cat foreachLine touch
}

# ::fileutil::grep --
#
#	Implementation of grep.  Adapted from the Tcler's Wiki.
#
# Arguments:
#	pattern		pattern to search for.
#	files		list of files to search; if NULL, uses stdin.
#
# Results:
#	results		list of matches

proc ::fileutil::grep {pattern {files {}}} {
    set result [list]
    if {[llength $files] == 0} {
	# read from stdin
	set lnum 0
	while {[gets stdin line] >= 0} {
	    incr lnum
	    if {[regexp -- $pattern $line]} {
		lappend result "${lnum}:${line}"
	    }
	}
    } else {
	foreach filename $files {
	    set file [open $filename r]
	    set lnum 0
	    while {[gets $file line] >= 0} {
		incr lnum
		if {[regexp -- $pattern $line]} {
		    lappend result "${filename}:${lnum}:${line}"
		}
	    }
	    close $file
	}
    }
    return $result
}

# ::fileutil::find ==
#
# Two different implementations of this command, one for unix with its
# softlinks, the other for the Win* platform. The trouble with
# softlink is that they can generate circles in the directory and/or
# file structure, leading a simple recursion into infinity. So we
# record device/inode information for each file and directory we touch
# to be able to skip it should we happen to visit it again.

# Note about the general implementation: The tcl interpreter sets a
# tcl stack limit of 1000 levels to prevent infinite recursions from
# running out of bounds. As this command is implemented recursively it
# will fail for very deeply nested directory structures.

if {[string compare unix $tcl_platform(platform)]} {
    # Not a unix platform => Original implementation
    # Note: This may still fail for directories mounted via SAMBA,
    # i.e. coming from a unix server.

    # ::fileutil::find --
    #
    #	Implementation of find.  Adapted from the Tcler's Wiki.
    #
    # Arguments:
    #	basedir		directory to start searching from; default is .
    #	filtercmd	command to use to evaluate interest in each file.
    #			If NULL, all files are interesting.
    #
    # Results:
    #	files		a list of interesting files.

    proc ::fileutil::find {{basedir .} {filtercmd {}}} {
	set oldwd [pwd]
	cd $basedir
	set cwd [pwd]
	set filenames [glob -nocomplain * .*]
	set files {}
	set filt [string length $filtercmd]
	# If we don't remove . and .. from the file list, we'll get stuck in
	# an infinite loop in an infinite loop in an infinite loop in an inf...
	foreach special [list "." ".."] {
	    set index [lsearch -exact $filenames $special]
	    set filenames [lreplace $filenames $index $index]
	}
	foreach filename $filenames {
	    # Use uplevel to eval the command, not eval, so that variable 
	    # substitutions occur in the right context.
	    if {!$filt || [uplevel $filtercmd [list $filename]]} {
		lappend files [file join $cwd $filename]
	    }
	    if {[file isdirectory $filename]} {
		set files [concat $files [find $filename $filtercmd]]
	    }
	}
	cd $oldwd
	return $files
    }
} else {
    # Unix, record dev/inode to detect and break circles

    # ::fileutil::find --
    #
    #	Implementation of find.  Adapted from the Tcler's Wiki.
    #
    # Arguments:
    #	basedir		directory to start searching from; default is .
    #	filtercmd	command to use to evaluate interest in each file.
    #			If NULL, all files are interesting.
    #
    # Results:
    #	files		a list of interesting files.

    proc ::fileutil::find {{basedir .} {filtercmd {}} {nodeVar {}}} {
	if {$nodeVar == {}} {
	    # Main call, setup the device/inode structure
	    array set inodes {}
	} else {
	    # Recursive call, import the device/inode record from the caller.
	    upvar $nodeVar inodes
	}

	set oldwd [pwd]
	cd $basedir
	set cwd [pwd]
	set filenames [glob -nocomplain * .*]
	set files {}
	set filt [string length $filtercmd]
	# If we don't remove . and .. from the file list, we'll get stuck in
	# an infinite loop in an infinite loop in an infinite loop in an inf...
	foreach special [list "." ".."] {
	    set index [lsearch -exact $filenames $special]
	    set filenames [lreplace $filenames $index $index]
	}
	foreach filename $filenames {
	    # Stat each file/directory get exact information about its identity
	    # (device, inode). Non-'stat'able files are either junk (link to
	    # non-existing target) or not readable, i.e. inaccessible. In both
	    # cases it makes sense to ignore them.

	    if {[catch {file stat [file join $cwd $filename] stat}]} {
		continue
	    }

	    # No skip over previously recorded files/directories and
	    # record the new files/directories.

	    set key "$stat(dev),$stat(ino)"
	    if {[info exists inodes($key)]} {
		continue
	    }
	    set inodes($key) 1

	    # Use uplevel to eval the command, not eval, so that variable 
	    # substitutions occur in the right context.
	    if {!$filt || [uplevel $filtercmd [list $filename]]} {
		lappend files [file join $cwd $filename]
	    }
	    if {[file isdirectory $filename]} {
		set files [concat $files [find $filename $filtercmd inodes]]
	    }
	}
	cd $oldwd
	return $files
    }

    # end if
}

# ::fileutil::findByPattern --
#
#	Specialization of find. Finds files based on their names,
#	which have to match the specified patterns. Options are used
#	to specify which type of patterns (regexp-, glob-style) is
#	used.
#
# Arguments:
#	basedir		Directory to start searching from.
#	args		Options (-glob, -regexp, --) followed by a
#			list of patterns to search for.
#
# Results:
#	files		a list of interesting files.

proc ::fileutil::findByPattern {basedir args} {
    set pos 0
    set cmd ::fileutil::FindGlob
    foreach a $args {
	incr pos
	switch -glob -- $a {
	    --      {break}
	    -regexp {set cmd ::fileutil::FindRegexp}
	    -glob   {set cmd ::fileutil::FindGlob}
	    -*      {return -code error "Unknown option $a"}
	    default {incr pos -1 ; break}
	}
    }

    set args [lrange $args $pos end]

    if {[llength $args] != 1} {
	set pname [lindex [info level 0] 0]
	return -code error \
		"wrong#args for \"$pname\", should be\
		\"$pname basedir ?-regexp|-glob? ?--? patterns\""
    }

    set patterns [lindex $args 0]
    return [find $basedir [list $cmd $patterns]]
}


# ::fileutil::FindRegexp --
#
#	Internal helper. Filter command used by 'findByPattern'
#	to match files based on regular expressions.
#
# Arguments:
#	patterns	List of regular expressions to match against.
#	filename	Name of the file to match against the patterns.
# Results:
#	interesting	A boolean flag. Set to true if the file
#			matches at least one of the patterns.

proc ::fileutil::FindRegexp {patterns filename} {
    foreach p $patterns {
	if {[regexp -- $p $filename]} {
	    return 1
	}
    }
    return 0
}

# ::fileutil::FindGlob --
#
#	Internal helper. Filter command used by 'findByPattern'
#	to match files based on glob expressions.
#
# Arguments:
#	patterns	List of glob expressions to match against.
#	filename	Name of the file to match against the patterns.
# Results:
#	interesting	A boolean flag. Set to true if the file
#			matches at least one of the patterns.

proc ::fileutil::FindGlob {patterns filename} {
    foreach p $patterns {
	if {[string match $p $filename]} {
	    return 1
	}
    }
    return 0
}

# ::fileutil::stripPwd --
#
#	If the specified path references a sub directory of [pwd] it
#	is made relative to [pwd]. Otehrwise it is left unchanged.
#
# Arguments:
#	path		path to modify
#
# Results:
#	path		The (possibly) modified path

proc ::fileutil::stripPwd {path} {

    # [file split[ is used to generate a canonical form for both
    # paths, for easy comparison, and also one which is easy to modify
    # using list commands.

    set pwd   [file split [pwd]]
    set npath [file split $path]

    if {[string match ${pwd}* $npath]} {
	set path [eval file join [lrange $npath [llength $pwd] end]]
    }
    return $path
}

# ::fileutil::stripN --
#
#	Removes N elements from the beginning of the path.
#
# Arguments:
#	path		path to modify
#	n		number of elements to strip
#
# Results:
#	path		The modified path

proc ::fileutil::stripN {path n} {
    set path [file split $path]
    if {$n >= [llength $path]} {
	return {}
    } else {
	return [eval file join [lrange $path $n end]]
    }
}

# ::fileutil::cat --
#
#	Tcl implementation of the UNIX "cat" command.  Returns the contents
#	of the specified file.
#
# Arguments:
#	filename	name of the file to read.
#
# Results:
#	data		data read from the file.

proc ::fileutil::cat {filename} {
    # Don't bother catching errors, just let them propagate up
    set fd [open $filename r]
    # Use the [file size] command to get the size, which preallocates memory,
    # rather than trying to grow it as the read progresses.
    set size [file size $filename]
    if {$size} {
        set data [read $fd $size]
    } else {
        # if the file has zero bytes it is either empty, or something 
        # where [file size] reports 0 but the file actually has data (like
        # the files in the /proc filesystem on Linux)
        set data [read $fd]
    }
    close $fd
    return $data
}

# ::fileutil::foreachLine --
#
#	Executes a script for every line in a file.
#
# Arguments:
#	var		name of the variable to contain the lines
#	filename	name of the file to read.
#	cmd		The script to execute.
#
# Results:
#	None.

proc ::fileutil::foreachLine {var filename cmd} {
    upvar 1 $var line
    set fp [open $filename r]

    # -future- Use try/eval from tcllib/control
    catch {
	set code 0
	set result {}
	while {[gets $fp line] >= 0} {
	    set code [catch {uplevel 1 $cmd} result]
	    if {($code != 0) && ($code != 4)} {break}
	}
    }
    close $fp

    if {($code == 0) || ($code == 3) || ($code == 4)} {
        return $result
    }
    if {$code == 1} {
        global errorCode errorInfo
        return \
		-code      $code      \
		-errorcode $errorCode \
		-errorinfo $errorInfo \
		$result
    }
    return -code $code $result
}

# ::fileutil::touch --
#
#	Tcl implementation of the UNIX "touch" command.
#
#	touch [-a] [-m] [-c] [-r ref_file] [-t time] filename ...
#
# Arguments:
#	-a		change the access time only, unless -m also specified
#	-m		change the modification time only, unless -a also specified
#	-c		silently prevent creating a file if it did not previously exist
#	-r ref_file	use the ref_file's time instead of the current time
#	-t time		use the specified time instead of the current time
#			("time" is an integer clock value, like [clock seconds])
#	filename ...	the files to modify
#
# Results
#	None.
#
# Errors:
#	Both of "-r" and "-t" cannot be specified.

proc ::fileutil::touch {args} {
    # Don't bother catching errors, just let them propagate up

    set options {
        {a          "set the atime only"}
        {m          "set the mtime only"}
        {c          "do not create non-existant files"}
        {r.arg  ""  "use time from ref_file"}
        {t.arg  -1  "use specified time"}
    }
    array set params [::cmdline::getoptions args $options]

    # process -a and -m options
    set set_atime [set set_mtime "true"]
    if {  $params(a) && ! $params(m)} {set set_mtime "false"}
    if {! $params(a) &&   $params(m)} {set set_atime "false"}

    # process -r and -t
    set has_t [expr {$params(t) != -1}]
    set has_r [expr {[string length $params(r)] > 0}]
    if {$has_t && $has_r} {
        return -code error "Cannot specify both -r and -t"
    } elseif {$has_t} {
        set atime [set mtime $params(t)]
    } elseif {$has_r} {
        file stat $params(r) stat
        set atime $stat(atime)
        set mtime $stat(mtime)
    } else {
        set atime [set mtime [clock seconds]]
    }

    # do it
    foreach filename $args {
        if {! [file exists $filename]} {
            if {$params(c)} {continue}
            close [open $filename w]
        }
        if {$set_atime} {file atime $filename $atime}
        if {$set_mtime} {file mtime $filename $mtime}
    }
    return
}

# ::fileutil::fileType --
#
#	Do some simple heuristics to determine file type.
#
#
# Arguments:
#	filename        Name of the file to test.
#
# Results
#	type            Type of the file.  May be a list if multiple tests
#                       are positive (eg, a file could be both a directory 
#                       and a link).  In general, the list proceeds from most
#                       general (eg, binary) to most specific (eg, gif), so
#                       the full type for a GIF file would be 
#                       "binary graphic gif"
#
#                       At present, the following types can be detected:
#
#                       directory
#                       empty
#                       binary
#                       text
#                       script <interpreter>
#                       executable elf
#                       graphic gif
#                       graphic jpeg
#                       html
#                       xml <doctype>
#                       message pgp
#                       link


proc ::fileutil::fileType {filename} {
    ;## existence test
    if { ! [ file exists $filename ] } {
        set err "file not found: '$filename'"
        return -code error $err
    }
    ;## directory test
    if { [ file isdirectory $filename ] } {
        set type directory
        if { ! [ catch {file readlink $filename} ] } {
            lappend type link
        }
        return $type
    }
    ;## empty file test
    if { ! [ file size $filename ] } {
        set type empty
        if { ! [ catch {file readlink $filename} ] } {
            lappend type link
        }
        return $type
    }
    set bin_rx {[\x00-\x08\x0b\x0e-\x1f]}

    if { [ catch {
        set fid [ open $filename r ]
        fconfigure $fid -translation binary
        fconfigure $fid -buffersize 1024
        fconfigure $fid -buffering full
        set test [ read $fid 1024 ]
        ::close $fid 
    } err ] } {
        catch { ::close $fid }
        return -code error "::fileutil::fileType: $err"
    }

    if { [ regexp $bin_rx $test ] } {
        set type binary
        set binary 1
    } else {
        set type text
        set binary 0
    }
    if { [ regexp {^\#\!(\S+)} $test -> terp ] } {
        lappend type script $terp
    } elseif { $binary && [ regexp -nocase {ELF} $test ] } {
        lappend type executable elf
    } elseif { $binary && [ regexp -nocase {GIF} $test ] } {
        lappend type graphic gif
    } elseif { $binary && [ regexp -nocase {JFIF} $test ] } {
        lappend type graphic jpeg
    } elseif { ! $binary && [ regexp -nocase {\<html\>} $test ] } {
        lappend type html
    } elseif { [ regexp -nocase {\<\?xml} $test ] } {
        lappend type xml
        if { [ regexp -nocase {\<\!DOCTYPE\s+(\S+)} $test -> doctype ] } {
            lappend type $doctype
        }
    } elseif { [ regexp {BEGIN PGP MESSAGE} $test ] } {
        lappend type message pgp
    }
    ;## lastly, is it a link?
    if { ! [ catch {file readlink $filename} ] } {
        lappend type link
    }
    return $type
}
