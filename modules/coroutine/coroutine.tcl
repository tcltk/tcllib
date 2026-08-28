## -- Tcl Module -- -*- tcl -*-
# # ## ### ##### ######## #############

# @@ Meta Begin
# Package coroutine 1.5
# Meta platform        tcl
# Meta require         {Tcl 8.6}
# Meta license         BSD
# Meta as::author      {Andreas Kupries}
# Meta as::author      {Colin Macleod}
# Meta as::author      {Colin McCormack}
# Meta as::author      {Donal Fellows}
# Meta as::author      {Kevin Kenny}
# Meta as::author      {Neil Madden}
# Meta as::author      {Peter Spjuth}
# Meta as::origin      http://wiki.tcl.tk/21555
# Meta summary         Coroutine Event and Channel Support
# Meta description     This package provides coroutine-aware
# Meta description     implementations of various event- and
# Meta description     channel related commands. It can be
# Meta description     in multiple modes: (1) Call the
# Meta description     commands through their ensemble, in
# Meta description     code which is explicitly written for
# Meta description     use within coroutines. (2) Import
# Meta description     the commands into a namespace, either
# Meta description     directly, or through 'namespace path'.
# Meta description     This allows the use from within code
# Meta description     which is not coroutine-aware per se
# Meta description     and restricted to specific namespaces.
# Meta description     A more agressive form of making code
# Meta description     coroutine-oblivious than (2) above is
# Meta description     available through the package
# Meta description     coroutine::auto, which intercepts
# Meta description     the relevant builtin commands and changes
# Meta description     their implementation dependending on the
# Meta description     context they are run in, i.e. inside or
# Meta description     outside of a coroutine.
# @@ Meta End

# Copyright (c) 2009,2014-2015 Andreas Kupries
# Copyright (c) 2009 Colin Macleod
# Copyright (c) 2009 Colin McCormack
# Copyright (c) 2009 Donal Fellows
# Copyright (c) 2009 Kevin Kenny
# Copyright (c) 2009 Neil Madden
# Copyright (c) 2009 Peter Spjuth

# # ## ### ##### ######## #############
## Requisites, and ensemble setup.

package require Tcl 8.6 9

namespace eval ::coroutine::util {

    namespace export \
	create global after exit vwait update gets read puts socket await

    namespace ensemble create
}

# # ## ### ##### ######## #############
## API. Spawn coroutines, automatic naming
##      (like thread::create).

proc ::coroutine::util::create {args} {
    ::coroutine [ID] {*}$args
}

# # ## ### ##### ######## #############
## API.
#
# global (coroutine globals (like thread global storage))
# after  (synchronous).
# exit
# update ?idletasks? [1]
# vwait
# gets               [1]
# read               [1]
# puts               [1]
# socket             [1]
#
# [1] These commands call on their builtin counterparts to get some of
#     their functionality (like proper error messages for syntax errors).

# - -- --- ----- -------- -------------

proc ::coroutine::util::global {args} {
    # Frame #1 is the coroutine-specific stack frame at its
    # bottom. Variables there are out of view of the main code, and
    # can be made visible in the entire coroutine underneath.

    # Ticket [bf8b80af]. Nothing needs to be done when the command is
    # invoked by the main procedure of the coroutine. Such code
    # already runs in frame #1, i.e. the variables are already in
    # scope, automatically.
    if {[info level] < 2} {
	return
    }

    set cmd [list upvar #1]
    foreach var $args {
	lappend cmd $var $var
    }
    tailcall {*}$cmd
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::after delay {
    ::after $delay [list [info coroutine]]
    yield
    return
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::exit {{status 0}} {
    return -level [info level] $status
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::vwait varname {
    upvar 1 $varname var
    set callback [list [namespace current]::VWaitTrace [info coroutine]]

    # Step 1. Wait for a write to the variable, using a trace to
    # restart the coroutine

    trace add    variable var write $callback
    yield
    trace remove variable var write $callback

    # Step 2. To prevent the next section of the coroutine code from
    # running entirely within the variable trace (*) we now use an
    # idle handler to defer it until the trace is definitely
    # done. This trick by Peter Spjuth.
    #
    # (*) At this point we are in VWaitTrace running the coroutine.

    ::after idle [list [info coroutine]]
    yield
    return
}


proc ::coroutine::util::VWaitTrace {coroutine args} {
    $coroutine
    return
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::update {{what {}}} {
    if {$what eq {idletasks}} {
        ::after idle [list [info coroutine]]
    } elseif {$what ne {}} {
        # Force proper error message for bad call.
        tailcall ::tcl::update $what
    } else {
        ::after 0 [list [info coroutine]]
    }
    yield
    return
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::gets args {
    # Process arguments.
    # Acceptable syntax:
    # * gets CHAN ?VARNAME?

    if {[llength $args] == 2} {
	# gets CHAN VARNAME
	lassign $args chan varname
        upvar 1 $varname line
    } elseif {[llength $args] == 1} {
	# gets CHAN
	lassign $args chan
    } else {
	# not enough, or too many arguments (0, or > 2): Calling the
	# builtin gets command with the bogus arguments gives us the
	# necessary error with the proper message.
	tailcall ::chan gets {*}$args
    }

    # Loop until we have a complete line. Yield to the event loop
    # where necessary. During
    set blocking [::chan configure $chan -blocking]
    set readable [::chan event $chan readable]
    ::chan event $chan readable [list [info coroutine]]
    ::chan configure $chan -blocking 0
    try {
	while 1 {
	    try {
		set result [::chan gets $chan line]
	    } on error {result opts} {
		return -code $result -options $opts
	    }

	    if {[::chan blocked $chan]} {
		yield
	    } else {
		if {[llength $args] == 2} {
		    return $result
		} else {
		    return $line
		}
	    }
	}
    } finally {
	::chan configure $chan -blocking $blocking
	::chan event $chan readable $readable
    }
}


proc ::coroutine::util::gets_safety {chan limit varname {timeout 120000}} {
    # Process arguments.
    # Acceptable syntax:
    # * gets CHAN ?VARNAME?

    # Loop until we have a complete line. Yield to the event loop
    # where necessary. During
    upvar 1 $varname line
    set blocking [::chan configure $chan -blocking]
    ::chan configure $chan -blocking 0
    set readable [::chan event $chan readable]
    ::chan event $chan readable [list [info coroutine] readable]
    try {
	while 1 {
	    if {[::chan pending input $chan] >= $limit} {
		error {Too many notes, Mozart. Too many notes}
	    }
	    try {
		set result [::chan gets $chan line]
	    } on error {result opts} {
		return -code $result -options $opts
	    }

	    if {[::chan blocked $chan]} {
		set timeoutevent [::after $timeout [list [info coroutine] timeout]]
		set event [yield]
		if {$event eq {timeout}} {
		  error {Connection Timed Out}
		}
		::after cancel $timeoutevent
	    } else {
		return $result
	    }
	}
    } finally {
	::chan configure $chan -blocking $blocking
	::chan event $chan readable $readable
    }
}


# - -- --- ----- -------- -------------

proc ::coroutine::util::read args {
    # Process arguments.
    # Acceptable syntax:
    # * read ?-nonewline ? CHAN
    # * read               CHAN ?n?

    if {[llength $args] > 2} {
	# Calling the builtin read command with the bogus arguments
	# gives us the necessary error with the proper message.
	::chan read {*}$args
	return
    }

    set total Inf ; # Number of characters to read. Here: Until eof.
    set chop  no  ; # Boolean flag. Determines if we have to trim a
    #               # \n from the end of the read string.

    if {[llength $args] == 2} {
	lassign $args a b
	if {$a eq {-nonewline}} {
	    set chan $b
	    set chop yes
	} else {
	    lassign $args chan total
	}
    } else {
	lassign $args chan
    }

    # Run the read loop. Yield to the event loop where
    # necessary. Differentiate between loop until eof, and loop until
    # n characters have been read (or eof reached).

    set buf {}

    set blocking [::chan configure $chan -blocking]
    set readable [::chan event $chan readable]
    ::chan event $chan readable [list [info coroutine]]
    ::chan configure $chan -blocking 0
    try {
	if {$total eq {Inf}} {
	    # Loop until eof.
	    while 1 {
		if {[::chan eof $chan]} {
		    break
		} elseif {[::chan blocked $chan]} {
		    yield
		}

		try {
		    set result [::chan read $chan]
		} on error {result opts} {
		    return -code $result -options $opts
		} 
		append buf $result
	    }
	} else {
	    # Loop until total characters have been read, or eof found,
	    # whichever is first.

	    set left $total
	    while 1 {
		if {[::chan eof $chan]} {
		    break
		} elseif {[::chan blocked $chan]} {
		    yield
		}

		try {
		    set result [::chan read $chan $left]
		} on error {result opts} {
		    return -code $result -options $opts
		}

		append buf $result
		incr left -[string length $result]
		if {!$left} {
		    break
		}
	    }
	}
    } finally {
	::chan configure $chan -blocking $blocking
	::chan event $chan readable $readable
    }

    if {$chop && [string index $buf end] eq "\n"} {
	set buf [string range $buf 0 end-1]
    }

    return $buf
}

# - -- --- ----- -------- -------------

## Yields until the channel is writable before actually writing, as
## suggested by the documentation for non-blocking puts
proc ::coroutine::util::puts args {
    # Process arguments.
    # Acceptable syntax:
    # * puts ?-nonewline? ?CHAN? string

    switch [llength $args] {
        1 {
            set ch stdout
        }
        2 {
            set ch [lindex $args 0]
            if {[string match {-*} $ch]} {
                if {$ch ne {-nonewline}} {
                    # Force proper error message for bad call
                    tailcall ::chan puts {*}$args
                }
                set ch stdout
            }
        }
        3 {
            lassign $args opt ch
            if {$opt ne {-nonewline}} {
                # Force proper error message for bad call
                tailcall ::chan puts {*}$args
            }
        }
        default {
            # Force proper error message for bad call
            tailcall ::chan puts {*}$args
        }
    }
    set blocking [::chan configure $ch -blocking]
    ::chan event $ch writable [info coroutine]
    yield
    ::chan event $ch writable {}
    try {
        ::chan puts {*}$args
    } on error {result opts} {
        return -code $result -options $opts
    } finally {
        ::chan configure $ch -blocking $blocking
    }
    return
}

# - -- --- ----- -------- -------------
## Does a non-blocking connect in the background and yields until finished.

proc ::coroutine::util::socket args {
    # Process arguments.
    # Acceptable syntax:
    # * socket ?options? host port

    if {[lsearch -exact $args -server] >= 0} {
        error "[namespace current]::socket cannot be used for server sockets."
    }
    set s [::socket -async {*}$args]
    ::chan event $s writable [info coroutine]
    while {[::chan configure $s -connecting]} {
        yield
    }
    ::chan event $s writable {}
    set errmsg [::chan configure $s -error]
    if {$errmsg ne {}} {
        ::chan close $s
        error $errmsg
    }
    return $s
}


# - -- --- ----- -------- -------------
## This goes beyond the builtin vwait, wait for multiple variables,
## result is the name of the variable which was written.
## This code mainly by Neil Madden.

proc ::coroutine::util::await args {
    set callback [list [namespace current]::AWaitSignal [info coroutine]]

    # Step 1. Wait for a write to any of the variable, using a trace
    # to restart the coroutine, and the variable written to is
    # propagated into it.

    foreach varName $args {
        upvar 1 $varName var
        trace add variable var write $callback
    }

    set choice [yield]

    foreach varName $args {
	#checker exclude warnShadowVar
        upvar 1 $varName var
        trace remove variable var write $callback
    }

    # Step 2. To prevent the next section of the coroutine code from
    # running entirely within the variable trace (*) we now use an
    # idle handler to defer it until the trace is definitely
    # done. This trick by Peter Spjuth.
    #
    # (*) At this point we are in AWaitSignal running the coroutine.

    ::after idle [list [info coroutine]]
    yield

    return $choice
}


proc ::coroutine::util::AWaitSignal {coroutine var index op} {
    if {$op ne {write}} return
    set fullvar $var
    if {$index ne {}} {append fullvar ($index)}
    $coroutine $fullvar
}

# - -- --- ----- -------- -------------

proc ::coroutine::util::exec args {
    set stdout {}
    set stderr {}
    set pipefds {}
    set filefds {}
    try {
	# Set some defaults for the switches
	set ignorestderr 0
	set dropnewline 1
	set encoding [encoding system]
	# Process the supported switches
	while {[string index [lindex $args 0] 0] eq "-"} {
	    set args [lassign $args opt]
	    switch -- $opt {
		-ignorestderr {set ignorestderr -1}
		-keepnewline {set dropnewline 0}
		-encoding {
		    set args [lassign $args encoding]
		}
		-- {break}
		default {
		    set errorcode [list TCL LOOKUP INDEX option $opt]
		    return -code error -errorcode $errorcode \
		      "bad option \"$opt\": must be\
		      -ignorestderr, -keepnewline, -encoding, or --"
		}
	    }
	}
	set mergestderr 0
	set background 0
	# Check for background operation. This must be the last argument. For
	# background execution the regular exec could be used. But that would
	# make it much harder to add this functionality to coroutine::auto
	if {[lindex $args end] eq "&"} {
	    set background 1
	    set args [lrange $args 0 end-1]
	}
	# Check for merging stderr into stdout. Must now be the last argument.
	if {[lindex $args end] eq "2>@1"} {
	    set mergestderr 1
	    set args [lrange $args 0 end-1]
	}
	# The `open` command to be used further down will throw an error if the
	# standard output has been redirected. Therefor the arguments must be
	# examined and any redirections of standard output must be extracted to
	# be handled outside of the open command.
	# Process all arguments in a loop, in case a file name specified for a
	# redirection looks like a redirection itself.
	set redir {}
	set words 0
	set cmdline [lmap arg $args {
	    if {[llength $redir]} {
		# This is the argument for a two-part redirection
		lappend redir $arg
	    } elseif {$arg in {< <@ << > 2> >& >> 2>> >>& >@ 2>@ >&@}} {
		# This is type specification of a two-part redirection
		# Save it and get the second part on the next pass of the loop
		set redir [list $arg]
		# Do not add standard output redirections to the command line
		if {[string index $arg 0] eq ">"} continue
	    } elseif {[regexp {^(>>?&?|>&?@)(.*)} $arg -> type target]} {
		# This is a standard output redirection in a single argument
		# Split it into the redirection type and its target
		set redir [list $type $target]
	    } elseif {[string match 2>* $arg]} {
		# Standard error is redirected and can further be ignored
		set ignorestderr 1
	    } elseif {![string match <* $arg]} {
		# Not a redirection, an actual command or one of its arguments
		incr words
	    }
	    if {[llength $redir] > 1} {
		# A complete redirection specification has been collected
		lassign $redir type target
		set redir {}
		if {$type in {2> 2>> 2>@}} {
		    # Standard error is redirected and can further be ignored
		    set ignorestderr 1
		} elseif {$type in {>& >>& >&@}} {
		    # Combine standard output and standard error
		    set ignorestderr 2
		}
		if {$type in {>@ >&@}} {
		    # The output is supposed to go to an existing channel.
		    # Make sure it actually exists and is writable.
		    try {
			chan event $target writable
		    } trap {TCL LOOKUP CHANNEL} {err opts} {
			# The channel doesn't exist
			return -opts [dict incr opts -level] $err
		    } on error {err opts} {
			return -code error \
			  -errorcode {TCL OPERATION EXEC BADCHAN} \
			  "channel \"$target\" wasn't opened for writing"
		    }
		    # Use the channel for standard output
		    set stdout $target
		    # For combined streams also use it for standard error
		    if {$type eq {>&@}} {set stderr $target}
		    # Do not add the argument to the command line
		    continue
		} elseif {$type in {> >> >& >>&}} {
		    # Redirect the output to a file
		    try {
			if {$type in {> >&}} {
			    # Overwrite any old file contents
			    set stdout [open $target w]
			} else {
			    # Append to any existing data in the file
			    set stdout [open $target a]
			}
		    } trap {POSIX} {err opts} {
			# Rephrase the error message to match exec
			set err "couldn't write file \"$target\":\
			  [lindex [dict get $opts -errorcode] end]"
			return -options [dict incr opts -level] $err
		    }
		    # For combined streams use the same handle for stderr
		    if {$type in {>& >>&}} {set stderr $stdout}
		    # The file needs to be closed when finished
		    lappend filefds $stdout
		    # Do not add the argument to the command line
		    continue
		}
	    }
	    set arg
	}]
	# There must not be a trailing redirect
	if {[llength $redir]} {
	    return -code error -errorcode {TCL OPERATION EXEC SYNTAX} \
	      "can't specify \"[lindex $redir 0]\" as last word in command"
	}
	# There must be some command apart from all the redirections
	if {$words == 0} {
	    return -code error -errorcode {TCL WRONGARGS} \
	      {wrong # args: should be "exec ?-option ...? arg ?arg ...?"}
	}
	if {$background && $stdout eq ""} {
	    # Running in the background without standard output redirected
	    # Then the output should go to the application's standard output
	    set stdout stdout
	    # If standard error was not redirected either, also send that to
	    # the application's standard error. Like the -ignorestderr switch.
	    if {!$ignorestderr} {set ignorestderr -1}
	}
	set er ""
	if {$mergestderr || $ignorestderr == 2} {
	    if {$mergestderr || $stderr eq $stdout} {
		# Standard error goes to the same channel as standard output
		lappend cmdline 2>@1
	    } else {
		# Redirect standard error to its own channel
		lappend cmdline 2>@ $stderr
	    }
	} elseif {$ignorestderr < 0} {
	    # Standard error has not been redirected, but was requested to be
	    # ignored by a command line switch. Send it to the application's
	    # standard error channel.
	    lappend cmdline 2>@ stderr
	} elseif {$ignorestderr == 0} {
	    # Standard error was not redirected and should not be ignored
	    # Create a pipe to collect the standard error output independent
	    # from standard output
	    lassign [chan pipe] er ew
	    # Redirect standard error into the write side of the pipe
	    lappend cmdline 2>@ $ew
	    # The write side must be closed in the parent after it has been
	    # handed over to the `open` command.
	    lappend pipefds $ew
	    # When all done, the read side of the pipe must be cleaned up
	    lappend filefds $er
	}
	# Finally the command pipeline can be opened
	#chan puts "exec $cmdline"
	set rc [catch {open [linsert $cmdline 0 |]} fp opts]
	# Close the write side of the pipe(s) in the parent, as prescribed
	# in the chan pipe manual page.
	foreach fd $pipefds {close $fd}
	set pipefds {}
	if {$rc} {
	    # The command failed. Save the error message.
	    set output $fp
	} elseif {$background} {
	    # When the external command pipeline runs in the background, the
	    # return value is a list of process identifiers of the subprocesses
	    set output [pid $fp]
	    # Let the process run in the background using a coroutine
	    coroutine bg-$fp ExecCollect $fp $stdout $er $filefds $encoding
	    set filefds {}
	} else {
	    # Collect the output
	    catch {ExecCollect $fp $stdout $er $filefds $encoding} output opts
	    set filefds {}
	    # Drop a trailing newline, unless there was a -keepnewline switch
	    if {$dropnewline && [string index $output end] eq "\n"} {
		set output [string range $output 0 end-1]
	    }
	}
	# Clear any stack trace information to hide the internals
	dict unset opts -errorinfo
	# Return the result or rethrow any errors encountered
	return -options [dict incr opts -level] $output
    } finally {
	# Make sure no helper channels are leaked
	foreach fd $pipefds {close $fd}
	foreach fd $filefds {close $fd}
    }
}


proc ::coroutine::util::ExecCollect {fp fo fe fdlist encoding} {
    try {
	set coro [info coroutine]
	if {$fo ne ""} {
	    # Transfer bytes without any encoding
	    chan configure $fp -blocking 0 -translation binary
	    chan configure $fo -blocking 0 -translation binary
	    # Can't use chan copy, because that blocks the output channel
	    chan event $fp readable [list $coro coroexeccopy $fp $fo]
	} else {
	    # Only apply the encoding when standard output is returned
	    chan configure $fp -blocking 0 -encoding $encoding
	    chan event $fp readable [list $coro coroexecdata $fp stdout]
	}
	if {$fe ne ""} {
	    chan configure $fe -blocking 0 -encoding $encoding
	    chan event $fe readable [list $coro coroexecdata $fe stderr]
	}
	set stdout {}
	set stderr {}
	while {![eof $fp]} {
	    # Wait for data to become available
	    lassign [yieldto list] token fd arg
	    if {$token eq "coroexecdata"} {
		# Append any available data to the appropriate variable
		append $arg [chan read $fd]
	    } elseif {$token eq "coroexeccopy"} {
		# Copy any available data to the output channel
		chan puts -nonewline $arg [chan read $fd]
	    }
	    # Disable the file event in case a channel is closed early
	    if {[eof $fd]} {chan event $fd readable {}}
	}
	# Do a blocking close to collect the exit code of the process
	chan configure $fp -blocking 1
	set rc [catch {close $fp} err opts]
	if {$stderr ne ""} {
	    # Tack the standard error onto the output
	    append stdout $stderr
	    # Any data on standard error is considered an error case
	    dict set opts -code error
	} elseif {$rc} {
	    # Add the error message from closing the channel to the output
	    append stdout $err
	}
	# Return the result, whether good or bad
	return -options [dict incr opts -level] $stdout
    } finally {
	# Close all the used helper channels
	foreach fd $fdlist {close $fd}
    }
}

# # ## ### ##### ######## #############
## Internal (package specific) commands

proc ::coroutine::util::ID {} {
    variable counter
    return [namespace current]::C[incr counter]
}

# # ## ### ##### ######## #############
## Internal (package specific) state

namespace eval ::coroutine::util {
    #checker exclude warnShadowVar
    variable counter 0
}

# # ## ### ##### ######## #############
## Ready
package provide coroutine 1.5
return
