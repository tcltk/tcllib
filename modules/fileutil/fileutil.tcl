# fileutil.tcl --
#
#	Tcl implementations of standard UNIX utilities.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: fileutil.tcl,v 1.4 2000/06/02 18:43:54 ericm Exp $

package provide fileutil 1.0

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

