# fileutil.tcl --
#
#	Tcl implementations of standard UNIX utilities.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: fileutil.tcl,v 1.5 2001/03/26 16:50:21 andreas_kupries Exp $

package provide fileutil 1.1

namespace eval ::fileutil {
    namespace export *
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
	    if {[regexp $pattern $line]} {
		lappend result "${lnum}:${line}"
	    }
	}
    } else {
	foreach filename $files {
	    set file [open $filename r]
	    set lnum 0
	    while {[gets $file line] >= 0} {
		incr lnum
		if {[regexp $pattern $line]} {
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
    set data [read $fd [file size $filename]]
    close $fd
    return $data
}

