# ### ### ### ######### ######### #########
##
# (c) 2007 Andreas Kupries.

# DSL allowing the easy specification of multi-file copy and/or move
# and/or deletion operations. Alternate names would be scatter/gather
# processor, or maybe even assembler.

# Examples:
# (1) copy
#     into [installdir_of tls]
#     from c:/TDK/PrivateOpenSSL/bin
#     the  *.dll
#
# (2) move
#     from /sources
#     into /scratch
#     the  *
#     but not *.html
#  (Alternatively: except for *.html)
#
# (3) into /scratch
#     from /sources
#     move
#     as   pkgIndex.tcl
#     the  index
#
# (4) in /scratch
#     remove
#     the *.txt

# The language is derived from the parts of TclApp's option language
# dealing with files and their locations, yet not identical. In parts
# simplified, in parts more capable, keyword names were changed
# throughout.

# Language commands

# From the examples
#
# into        DIR           : Specify destination directory.
# in          DIR           : See 'into'.
# from        DIR           : Specify source directory.
# the         PATTERN (...) : Specify files to operate on.
# but not     PATTERN       : Specify exceptions to 'the'.
# but exclude PATTERN       : Specify exceptions to 'the'.
# except for  PATTERN       : See 'but not'.
# as          NAME          : New name for file.
# move                      : Move files.
# copy                      : Copy files.
# remove                    : Delete files.
#
# Furthermore
#
# reset     : Force to defaults.
# cd    DIR : Change destination to subdirectory.
# up        : Change destination to parent directory.
# (         : Save a copy of the current state.
# )         : Restore last saved state and make it current.

# The main active element is the command 'the'. In other words, this
# command not only specifies the files to operate on, but also
# executes the operation as defined in the current state. All other
# commands modify the state to set the operation up, and nothing
# else. To allow for a more natural syntax the active command also
# looks ahead for the commands 'as', 'but', and 'except', and executes
# them, like qualifiers, so that they take effect as if they had been
# written before. The command 'but' and 'except use identical
# constructions to handle their qualifiers, i.e. 'not' and 'for'.

# Note that the fact that most commands just modify the state allows
# us to use more off forms as specifications instead of just natural
# language sentences For example the example 2 can re-arranged into:
#
# (5) from /sources
#     into /scratch
#     but not *.html
#     move
#     the  *
#
# and the result is still a valid specification.

# Further note that the information collected by 'but', 'except', and
# 'as' is automatically reset after the associated 'the' was
# executed. However no other state is reset in that manner, allowing
# the user to avoid repetitions of unchanging information. Lets us for
# example merge the examples 2 and 3. The trivial merge is:

# (6) move
#     into /scratch
#     from /sources
#     the  *
#     but not *.html not index
#     move
#     into /scratch
#     from /sources
#     the  index
#     as   pkgIndex.tcl
#
# With less repetitions
#
# (7) move
#     into /scratch
#     from /sources
#     the  *
#     but not *.html not index
#     the  index
#     as   pkgIndex.tcl

# I have not yet managed to find a suitable syntax to specify when to
# add a new extension to the moved/copied files, or have to strip all
# extensions, a specific extension, or even replace extensions.

# Other possibilities to muse about: Load the patterns for 'not'/'for'
# from a file ... Actually, load the whole exceptions from a file,
# with its contents a proper interpretable word list. Which makes it
# general processing of include files.

# ### ### ### ######### ######### #########
## Requisites

# This processor uses the 'wip' word list interpreter as its
# foundation.

package require fileutil      ; # File testing
package require snit          ; # OO support
package require struct::stack ; # Context stack
package require wip           ; # DSL execution core

# ### ### ### ######### ######### #########
## API & Implementation

snit::type ::fileutil::multi::op {
    # ### ### ### ######### ######### #########
    ## API

    constructor {args} {} ; # create processor

    # ### ### ### ######### ######### #########
    ## API - Implementation.

    constructor {args} {
	install stack using struct::stack::stack ${selfns}::stack
	$self wip_setup

	# Mapping dsl commands to methods.
	defdva \
	    reset  Reset	(    Push	)       Pop	\
	    into   Into		in   Into	from    From	\
	    cd     ChDir	up   ChUp	as      As	\
	    move   Move		copy Copy	remove  Remove	\
	    but    But		not  Exclude	the     The	\
	    except Except	for  Exclude    exclude Exclude \
	    to     Into

	$self Reset
	runl $args
	return
    }

    destructor {
	$wip destroy
	return
    }

    method do {args} {
	return [runl $args]
    }

    # ### ### ### ######### ######### #########
    ## DSL Implementation
    wip::dsl

    # General reset of processor state
    method Reset {} {
	$stack clear
	set base  ""
	set alias ""
	set op    ""
	set src   ""
	set excl  ""
	return
    }

    # Stack manipulation
    method Push {} {
	$stack push [list $base $alias $op $src $excl]
	return
    }

    method Pop {} {
	if {![$stack size]} {
	    return -code error {Stack underflow}
	}
	foreach {base alias op src excl} [$stack pop] break
	return
    }

    # Destination directory
    method Into {dir} {
	if {$dir eq ""} {set dir [pwd]}
	if {![fileutil::test $dir edr msg {Destination directory}]} {
	    return -code error $msg
	}
	set base $dir
	return
    }

    method ChDir {dir} { Into [file join    $base $dir] ; return }
    method ChUp  {}    { Into [file dirname $base]      ; return }

    # Detail
    method As {fname} {
	set alias [ForceRelative $fname]
	return
    }

    # Operations
    method Move   {} { set op move   ; return }
    method Copy   {} { set op copy   ; return }
    method Remove {} { set op remove ; return }

    # Source directory
    method From {dir} {
	if {$dir eq ""} {set dir [pwd]}
	if {![fileutil::test $dir edr msg {Source directory}]} {
	    return -code error $msg
	}
	set src $dir
	return
    }

    # Exceptions
    method But    {} { run_next_while {not exclude} ; return }
    method Except {} { run_next_while {for}         ; return }

    method Exclude {pattern} {
	lappend excl $pattern
	return
    }

    # Define the files to operate on, and perform the operation.
    method The {pattern} {
	run_next_while {as but except exclude}

	switch -exact -- $op {
	    move   {Move   [Resolve [Exclude [Expand $src  $pattern]]]}
	    copy   {Copy   [Resolve [Exclude [Expand $src  $pattern]]]}
	    remove {Remove          [Exclude [Expand $base $pattern]] }
	}

	# Reset the per-pattern flags of the resolution context back
	# to their defaults, for the next pattern.

	set alias {}
	set excl  {}
	return
    }

    # ### ### ### ######### ######### #########
    ## DSL State

    component stack    ; # State stack     - ( )
    variable  base  "" ; # Destination dir - into, in, cd, up
    variable  alias "" ; # Detail          - as
    variable  op    "" ; # Operation       - move, copy, remove
    variable  src   "" ; # Source dir      - from
    variable  excl  "" ; # Excluded files  - but not|exclude, except for
    # incl             ; # Included files  - the (immediate use)

    # ### ### ### ######### ######### #########
    ## Internal -- Path manipulation helpers.

    proc ForceRelative {path} {
	set pathtype [file pathtype $path]
	switch -exact -- $pathtype {
	    relative {
		return $path
	    }
	    absolute {
		# Chop off the first element in the path, which is the
		# root, either '/' or 'x:/'. If this was the only
		# element assume an empty path.

		set path [lrange [file split $path] 1 end]
		if {![llength $path]} {return {}}
		return [eval [linsert $path 0 file join]]
	    }
	    volumerelative {
		return -code error {Unable to handle volumerelative path, yet}
	    }
	}

	return -code error \
	    "file pathtype returned unknown type \"$pathtype\""
    }

    proc ForceAbsolute {path} {
	return [file join [pwd] $path]
    }

    # ### ### ### ######### ######### #########
    ## Internal - Operation execution helpers

    proc Move {files} {
	upvar 1 base base src src

	foreach {s d} $files {
	    set s [file join $src  $s]
	    set d [file join $base $d]

	    file mkdir [file dirname $d]
	    file rename -force $s $d
	}
	return
    }

    proc Copy {files} {
	upvar 1 base base src src

	foreach {s d} $files {
	    set s [file join $src  $s]
	    set d [file join $base $d]

	    file mkdir [file dirname $d]
	    file copy -force $s $d
	}
	return
    }

    proc Remove {files} {
	upvar 1 base base

	foreach f $files {
	    file delete -force [file join $base $f]
	}
	return
    }

    # ### ### ### ######### ######### #########
    ## Internal -- Resolution helper commands

    proc Expand {dir pattern} {
	# FUTURE: struct::list filter ...

	set files {}
	foreach f [glob -nocomplain -directory $dir -- $pattern] {
	    if {![file isfile $f]} continue
	    lappend files [fileutil::stripPath $dir $f]
	}

	if {[llength $files]} {return $files}

	return -code error \
	    "No files matching pattern \"$pattern\" in directory \"$dir\""
    }

    proc Exclude {files} {
	upvar 1 excl excl

	# FUTURE: struct::list filter ...
	set res {}
	foreach f $files {
	    if {[IsExcluded $f $excl]} continue
	    lappend res $f
	}
	return $res
    }

    proc IsExcluded {f patterns} {
	foreach p $patterns {
	    if {[string match $p $f]} {return 1}
	}
	return 0
    }

    proc Resolve {files} {
	upvar 1 alias alias
	set res {}
	foreach f $files {

	    # Remember alias for processing and auto-invalidate to
	    # prevent contamination of the next file.

	    set thealias $alias
	    set alias    ""

	    if {$thealias eq ""} {
		set d $f
	    } else {
		set d [file join [file dirname $f] $thealias]
	    }

	    lappend res $f $d
	}
	return $res
    }

    ##
    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide fileutil::multi::op 0.1
