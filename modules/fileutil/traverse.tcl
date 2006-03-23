# traverse.tcl --
#
#	Directory traversal.
#
# Copyright (c) 2006 by Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: traverse.tcl,v 1.2 2006/03/23 04:56:46 andreas_kupries Exp $

package require Tcl 8.3
package require snit    ; # OO core
package require control ; # Helpers for control structures

snit::type ::fileutil::traverse {

    # Incremental directory traversal.

    # API
    # create  %AUTO% basedirectory options... -> object
    # next    filevar                         -> boolean
    # foreach filevar script
    # files                                   -> list (path ...)

    # Options
    # -prefilter command-prefix
    # -filter    command-prefix
    # -errorcmd  command-prefix

    # Use cases
    #
    # (a) Basic incremental
    # - Create and configure a traversal object.
    # - Execute 'next' to retrieve one path at a time,
    #   until the command returns False, signaling that
    #   the iterator has exhausted the supply of paths.
    #   (The path is stored in the named variable).
    #
    # The execution of 'next' can be done in a loop, or via event
    # processing.

    # (b) Basic loop
    # - Create and configure a traversal object.
    # - Run a script for each path, using 'foreach'.
    #   This is a convenient standard wrapper around 'next'.
    #
    # The loop properly handles all possible Tcl result codes.

    # (c) Non-incremental, non-looping.
    # - Create and configure a traversal object.
    # - Retrieve a list of all paths via 'files'.

    # The -prefilter callback is executed for directories. Its result
    # determines if the traverser recurses into the directory or not.
    # The default is to always recurse into all directories. The call-
    # back is invoked with a single argument, the path of the
    # directory.
    #
    # The -filter callback is executed for all paths. Its result
    # determines if the current path is a valid result, and returned
    # by 'next'. The default is to accept all paths as valid. The
    # callback is invoked with a single argument, the path to check.

    # The -errorcmd callback is executed for all paths the traverser
    # has trouble with. Like being unable to cd into them, get their
    # status, etc. The default is to ignore any such problems. The
    # callback is invoked with a two arguments, the path for which the
    # error occured, and the error message. Errors thrown by the
    # filter callbacks are handled through this callback too. Errors
    # thrown by the error callback itself are not caught and ignored,
    # but allowed to pass to the caller, usually of 'next'.

    # Note: Low-level functionality, version and platform dependent is
    # implemented in procedures, and conditioally defined for optimal
    # use of features, etc. ...

    # Note: Traversal is done in depth-first pre-order.

    # Note: The options are handled only during
    # construction. Afterward they are read-only and attempts to
    # modify them will cause the system to throw errors.

    # ### ### ### ######### ######### #########
    ## Implementation

    option -filter    -default {} -readonly 1
    option -prefilter -default {} -readonly 1
    option -errorcmd  -default {} -readonly 1

    constructor {basedir args} {
	set _base    $basedir
	set _pending [list $_base]
	set _prefix  {}

	$self configurelist $args
	return
    }

    method files {} {
	set files {}
	$self foreach f {lappend files $f}
	return $files
    }

    method foreach {fvar body} {
	upvar 1 $fvar currentfile

	# (Re-)initialize the traversal state on every call.
	set _pending [list $_base]
	set _prefix  {}
	array unset _inodes *

	while {[$self next currentfile]} {
	    set code [catch {uplevel 1 $body} result]

	    # decide what to do upon the return code:
	    #
	    #               0 - the body executed successfully
	    #               1 - the body raised an error
	    #               2 - the body invoked [return]
	    #               3 - the body invoked [break]
	    #               4 - the body invoked [continue]
	    # everything else - return and pass on the results
	    #
	    switch -exact -- $code {
		0 {}
		1 {
		    return -errorinfo [::control::ErrorInfoAsCaller uplevel foreach]  \
			    -errorcode $::errorCode -code error $result
		}
		3 {
		    # FRINK: nocheck
		    return
		}
		4 {}
		default {
		    return -code $code $result
		}
	    }
	}
	return
    }

    variable _base          {} ; # Base directory (or file) to start the traversal from
    variable _pending       {} ; # Stack of paths waiting for processing (TOP at end)
    variable _prefix        {} ; # Stack of basepaths to  join with glob results (TOP at end)
    variable _inodes -array {} ; # Set of dev/inode's already visited.

    method next {fvar} {
	upvar 1 $fvar currentfile
	while {[llength $_pending]} {
	    # Take first item on stack (_pending) and interpret it.
	    # Stack empty? - Stop and signal that iteration is done.
	    # - Empty: Pop a prefix
	    # - File:  Use filter to determine validity
	    #          Ok: Stop and return this item
	    #          !ok: Continue interpretation loop.
	    # - Directory:
	    #          Use prefilter to determine if we recurse into
	    #          it. If yes, glob its contents, push them on
	    #          the stack. Also push a new prefix.
	    #          Use filter to determine validity as result.
	    #          Ok: Stop and return this item
	    #          !ok: Continue interpretation loop.

	    set top      [lindex   $_pending end]
	    set _pending [lreplace $_pending end end]

	    if {[string equal $top ""]} {
		# Pop prefix and restore previous directory. No
		# attempt at catching problems, as the parent
		# directory should exist, going up from a child.

		set _prefix [lreplace $_prefix end end]
		continue
	    }

	    set currentbase [lindex $_prefix end]
	    set fulltop     [file join $currentbase $top]

	    if {[file isfile $fulltop]} {
		if {[$self Valid $fulltop]} {
		    set currentfile $fulltop
		    return 1
		}
		continue
	    }

	    # Directory ...

	    if {[$self Recurse $fulltop]} {
		lappend _pending {}
		lappend _prefix $fulltop
		if {[catch {
		    foreach f [Glob $fulltop _inodes] {
			# If we don't remove . and .. from the file
			# list, we'll get stuck in an infinite loop in
			# an infinite loop in an infinite loop in an
			# inf...

			if {[string equal $f .]}  continue
			if {[string equal $f ..]} continue
			lappend _pending $f
		    }
		} msg]} {
		    $self Error $fulltop $msg
		}
	    }

	    if {[$self Valid $top]} {
		set currentfile $fulltop
		return 1
	    }
	}
	return 0
    }

    method Valid {path} {
	if {![llength $options(-filter)]} {return 1}
	set code [catch {uplevel #0 [linsert $options(-filter) end $path]} valid]
	if {!$code} {return $valid}
	$self Error $path $valid
	return 0
    }

    method Recurse {path} {
	if {![llength $options(-prefilter)]} {return 1}
	set code [catch {uplevel #0 [linsert $options(-prefilter) end $path]} valid]
	if {!$code} {return $valid}
	$self Error $path $valid
	return 0
    }

    method Error {path msg} {
	if {![llength $options(-errorcmd)]} return
	uplevel #0 [linsert $options(-errorcmd) end $path $msg]
	return
    }

    # Glob is a procedure, its implementation dependent on Tcl version
    # and system architecture. It definition comes below.

    ##
    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Implementation of 'Glob'.

# Glob path inodevar -> list (path ...)

if {[string equal $::tcl_platform(platform) windows]} {
    # Windows. No symbolic links, no inodes. No trouble with virtual
    # filesystems.

    # The only pattern used is *, on Windows dot-files are
    # automatically listed as well.

    if {[package vcompare [package present Tcl] 8.4] >= 0} {
	# Tcl 8.4+. glob has switches -directory, -tails

	proc ::fileutil::traverse::Glob {path iv} {
	    # Ignoring iv = inodes
	    return [glob -nocomplain -directory $path -tails *]
	}
    } else {
	# Tcl 8.3-. glob has no -directory, -tails, we have to emulate
	# it.

	proc ::fileutil::traverse::Glob {path iv} {
	    # Ignore iv = inodes
	    set oldwd [pwd]
	    set code [catch {
		cd $path
		set files [glob -nocomplain *]
	    } msg] ; # {}
	    catch {cd $oldwd}
	    if {$code} {
		return -code $code -errorinfo $::errorInfo -errorcode $::errorCode
	    }
	    return $files
	}
    }
} else {
    # Unixoid system. Use inodes to prevent infinite traversal across
    # cyclic symbolic links. Except while traversing a virtual fs,
    # where we do not have dev/inode information. But no symbolic
    # links either. Note that a virtual fs can occur only for Tcl
    # 8.4+. Pre Tcl 8.4 dev/inode checking can be done uncondtionally.

    if {[package vcompare [package present Tcl] 8.4] >= 0} {
	# Tcl 8.4+. glob has switches -directory, -tails

	proc ::fileutil::traverse::Glob {path iv} {
	    upvar 1 $iv inodes
	    set files {}
	    # Unix: Need the .* pattern as well to retrieve dot-files
	    foreach f [glob -nocomplain -directory $path -tails * .*] {
		set fx [file join $path $f]

		# SF [ 647974 ] find has problems recursing a metakit fs ...
		#
		# The following code is a HACK / workaround. We assume that virtual
		# FS's do not support links, and therefore there is no need for
		# keeping track of device/inode information. A good thing as the 
		# the virtual FS's usually give us bad data for these anyway, as
		# illustrated by the bug referenced above.

		if {[string equal native [lindex [file system $fx] 0]]} {
		    # Do not skip over previously recorded
		    # files/directories and record the new
		    # files/directories.

		    # Stat each file/directory get exact information about its identity
		    # (device, inode). Non-'stat'able files are either junk (link to
		    # non-existing target) or not readable, i.e. inaccessible. In both
		    # cases it makes sense to ignore them.

		    if {[catch {file lstat $fx stat}]} {
			continue
		    }

		    set key [list $stat(dev) $stat(ino)]
		    if {[info exists inodes($key)]} {
			continue
		    }
		    set inodes($key) 1
		}

		lappend files $f
	    }
	    return $files
	}

    } else {
	# Tcl 8.3-. glob has no -directory, -tails, we have to emulate
	# it.

	proc ::fileutil::traverse::Glob {path iv} {
	    upvar 1 $iv inodes

	    set oldwd [pwd]
	    set code [catch {
		cd $path
		set temp [glob -nocomplain * .*]
	    } msg] ; # {}
	    catch {cd $oldwd}
	    if {$code} {
		return -code $code -errorinfo $::errorInfo -errorcode $::errorCode
	    }

	    set files {}
	    # Unix: Need the .* pattern as well to retrieve dot-files
	    foreach f $temp {
		set fx [file join $path $f]

		# Do not skip over previously recorded
		# files/directories and record the new
		# files/directories.

		# Stat each file/directory get exact information about its identity
		# (device, inode). Non-'stat'able files are either junk (link to
		# non-existing target) or not readable, i.e. inaccessible. In both
		# cases it makes sense to ignore them.

		if {[catch {file lstat $fx stat}]} {
		    continue
		}

		set key [list $stat(dev) $stat(ino)]
		if {[info exists inodes($key)]} {
		    continue
		}
		set inodes($key) 1
		lappend files $f
	    }
	    return $files
	}
    }
}

# ### ### ### ######### ######### #########
## Ready

package provide fileutil::traverse 0.1
