# pipeline.tcl --
#
# Streaming data pipeline infrastructure
#
# Copyright (C) 2019 Andy Goth <andrew.m.goth@gmail.com>
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package require Tcl 8.6
package require argparse
package provide pipeline 0.2

# Create a namespace for pipeline commands.
namespace eval ::pipeline {}

# ::pipeline::new --
# Creates a pipeline containing the specified filter command prefixes and
# returns the command name used to execute the pipeline.
#
# The returned command accepts the following method name arguments:
#
# destroy     Destroy the pipeline and cleans up all associated resources
# flow        Feed input data through the pipeline and returns the output data
# get         Get buffered output data accumulated by prior calls to [put]
# peek        Get buffered output data without clearing the output buffer
# put         Feed input data through the pipeline and buffers the output data
# run         Feed raw chunks through the pipeline and returns raw chunk output
#
# The [flow] and [put] methods accept the following additional arguments:
#
# -meta META  Arbitary metadata to associate with the input data
# -flush      Commands pipeline flush
# data        Input data, may be empty string
#
# Each argument to the [run] method is a raw chunk, which is a three-element
# list that will be used as the arguments to the first filter coroutine.
#
# A pipeline is a linear sequence of zero or more filters.  Each filter operates
# on the output of its predecessor, with the first filter operating on the input
# to the pipeline.  The output of the last filter is the output of the pipeline.
#
# Each filter is a command prefix to invoke on each pipeline input chunk.  If a
# filter command name is in the ::pipeline or :: (global) namespace, it need not
# be fully qualified.  The [pipeline::loop] command is useful to define filters.
#
# Pipelines are implemented in terms of coroutines.  The pipeline as a whole is
# a coroutine, and each filter in the pipeline is a coroutine.  Coroutines are
# automatically created by [pipeline::new], and filter commands need not create
# coroutines for themselves.  The first time the filter command is invoked, it
# must yield after completing initialization, and the yielded value is ignored.
# When the filter command returns, its coroutine is automatically destroyed.
#
# Aside from the first time the filter command is invoked (described above),
# filter coroutines are given the following three arguments:
#
# - Current input data chunk
# - Arbitrary metadata associated with the input chunk
# - 1 if the pipeline is being flushed, 0 if not
#
# If a filter command is passed zero arguments, the filter must clean up any
# resources it allocated, then return.
#
# When a filter coroutine is invoked, it must yield a list containing zero or
# more output chunks.  Each output chunk is a list containing the following:
#
# - Current output data chunk
# - Arbitrary metadata associated with the output chunk
# - 1 if flush is being commanded, 0 if not
# - 1 if the chunk is to be fed back as new pipeline input, 0 if not
#
# Output chunks may omit any number of elements.  The omitted elements will be
# replaced with the corresponding elements from the input chunk.  If restart is
# omitted, it defaults to 0.  A filter that passes its input through unmodified
# may simply yield {{}}, i.e. a list containing only an empty list.  If a filter
# yields {}, i.e. empty list, then all pipeline data is discarded and further
# filters are not invoked.
#
# Pipeline execution continues until all filter coroutines have been invoked on
# all input chunks.  If any filter output chunks contain the restart flag, the
# entire pipeline sequence will be executed again, repeating until none of the
# filters output any chunks containing the restart flag.
proc ::pipeline::new {args} {
    # Coroutine creation helper routine.
    set coroNew {apply {{args} {
        set i [llength [info commands ::pipeline::Coro*]]
        while {[info commands [set coro ::pipeline::Coro$i]] ne {}} {
            incr i
        }
        coroutine $coro {*}$args
        return $coro
    } ::pipeline}}

    # Create a coroutine command for each filter in the pipeline, as well as a
    # coroutine for the pipeline as a whole.  Return its command name.
    {*}$coroNew apply {{coros} {
        # Pipeline execution core.
        set run {apply {{coros args} {
            # Loop until the input queue is completely drained.  Filters may
            # append chunks to the the input queue, so this loop may repeat.
            set inChunks $args
            set outChunks {}
            while {$inChunks ne {}} {
                # Transfer the pipeline inputs to the first filter inputs.
                set pipeChunks $inChunks
                set inChunks {}

                # Progress through the pipeline, one filter at a time.
                foreach coro $coros {
                    # Loop through all chunks currently in the pipeline.
                    foreach inChunk $pipeChunks[set pipeChunks {}] {
                        # Invoke the filter, and process its output chunks.
                        foreach outChunk [$coro {*}$inChunk] {
                            # Fill in omitted output elements with defaults.
                            if {[llength $outChunk] < 3} {
                                lappend outChunk {*}[lrange $inChunk\
                                        [llength $outChunk] 2]
                            }

                            # Let the output chunk be the input to the next
                            # filter or to the first filter on the next pass.
                            if {[llength $outChunk] >= 4
                             && [lindex $outChunk 3]} {
                                lappend inChunks $outChunk
                            } else {
                                lappend pipeChunks $outChunk
                            }
                        }

                        # If this input chunk commands flush, ensure the last
                        # output chunk arising from this input chunk also
                        # commands flush, creating an empty chunk if needed.
                        if {[lindex $inChunk 2]} {
                            if {$pipeChunks ne {}} {
                                lset pipeChunks end 2 1
                            } else {
                                set pipeChunks {{{} {} 1}}
                            }
                        }
                    }
                }

                # Collect the outputs of the last filter in the pipeline.
                lappend outChunks {*}$pipeChunks
            }
            return $outChunks
        }}}

        # Loop until the destroy method is invoked.
        set out {}
        set buffer {}
        while {1} {
            # Yield the last result, then get the next method and its arguments.
            set args [lassign [yieldto return -level 0 $out[set out {}]] method]

            # Perform method name resolution.
            set method [tcl::prefix match -message method\
                    {destroy flow get peek put run} $method]

            # Several methods do not allow arguments.
            if {$method in {destroy get peek} && $args ne {}} {
                return -code error "wrong # args: should be\
                        \"[info coroutine] $method\""
            }

            # Invoke the method.
            switch $method {
            destroy {
                foreach coro $coros {
                    $coro
                }
                break
            } flow {
                argparse -boolean {{-meta= -default {}} -flush data}
                foreach chunk [{*}$run $coros [list $data $meta $flush]] {
                    append buffer [lindex $chunk 0]
                }
                set out $buffer
                set buffer {}
            } get {
                set out $buffer
                set buffer {}
            } peek {
                set out $buffer
            } put {
                argparse -boolean {{-meta= -default {}} -flush data}
                foreach chunk [{*}$run $coros [list $data $meta $flush]] {
                    append buffer [lindex $chunk 0]
                }
            } run {
                set out [{*}$run $coros {*}$args]
            }}
        }
    } ::pipeline} [lmap filter $args {{*}$coroNew {*}$filter}]
}

# ::pipeline::loop --
# Pipeline main loop skeleton, suitable for implementing pipeline filters.  The
# following arguments are accepted:
#
# -command    Positional arguments form a command prefix rather than a script
# -observe    Do not modify pipeline data, ignoring return value or out variable
# -result     Script result is used directly as the output chunk list
# -buffer     Wait until delimiter is encountered before invoking command
# -raw        Command operates on raw chunks rather than processed data
# -partial    Run script for partial buffers as well as complete buffers
# -separate   Disable buffered output merging
# -delim PAT  Buffer delimiter regular expression, default \n
# -trim       Strip buffer delimiter from the command argument
# script      Main loop body script or command prefix (multiple arguments)
#
# If -buffer is used, the pipeline data is divided into chunks according to the
# delimiter defined by the -delim regular expression.  The data matched by the
# regular expression is included at the end of each chunk, except for the last
# chunk which may be incomplete.  When flush is commanded, the buffer is emptied
# after being passed to the script or command prefix, even if incomplete.
#
# -buffer causes the script or command to only be executed when the buffer is
# complete or flush is commanded, unless -partial is used, in which case the
# script or command is executed for every chunk.  When the script or command is
# not executed, subsequent filters in the pipeline are not executed either.
#
# -buffer causes the output chunks of the script or command to be merged if
# possible, though they will remain distinct chunks when they command flush or
# have varying metadata or restart flags.  -separate may be used to disable
# merging of output chunks.
#
# It is an error for the -delim regular expression to match empty string.
#
# If -command is not used, the script argument is executed for each chunk that
# flows through the pipeline.  If -buffer is used (and -partial is not), the
# script is instead only executed for complete buffers and when flush is
# commanded.  The script may interact with the following variables:
#
# input       Input chunk from the pipeline executive
# out         Output chunk list to yield to the pipeline executive
# data        Current input chunk data
# meta        Arbitrary metadata associated with the input chunk
# flush       1 if pipeline is being flushed, 0 if not
#
# Additional variables are available when -buffer is used:
#
# prior       Buffered data preceding this chunk, or empty for the first
# buffer      All data since the last delimiter, excluding the current delimiter
# complete    Delimiter string if complete, empty string if buffer is incomplete
#
# The script may also freely access any other caller variables.  This allows the
# script to maintain state between iterations.
#
# If -result is used, the script result is automatically stored into the out
# variable.  The script need only evaluate to the output chunk list.  If the
# script uses [return], the return value will be stored into the out variable.
#
# At the start of each pass through the loop, the out variable defaults to {{}}.
# If -result is not used and the script does not modify this variable, the input
# will pass through to the output unmodified.  If the script does modify out, it
# is used as a list of output chunks.  See [pipeline::new] for details on the
# format and behavior of output chunk lists.
#
# Changing the input variable affects the default values that will be filled
# into omitted fields in the out variable.  As a special case, if -buffer is
# used without -partial, the default value for the first element of the out
# variable is not the first element of the input variable, but rather the
# concatenation of the buffer and complete variables.
#
# If -command is used, the script argument is instead a sequence of one or more
# arguments forming a command prefix to which the input data will be appended.
# The choice of command arguments is determined by -raw, -buffer, and -trim.
#
# If -raw is not used, the command return value is the output data.  If -buffer
# is not used, the command argument is the input chunk data.  If -buffer is
# used, the command argument is all data buffered since the last delimiter.  If
# -trim is used, the delimiter is not included in the argument.
#
# If -raw is used, the command return value is a list of zero or more output
# chunks.  The command argument is a three- or six-element list.  The first
# three elements are data, meta, and flush, and (if -buffer is used) the next
# three are prior, buffer, and complete.  See above for details.
#
# If -observe is used, the out variable, script result, or command return value
# is ignored, and the pipeline filter's output is equal to its input.  This also
# prevents -buffer from pausing the pipeline when the buffer is incomplete.
proc ::pipeline::loop {args} {
    # If [pipeline::loop] is the top level of the coroutine, recursively invoke
    # itself one time so that the [upvar] and [uplevel] commands store the
    # variables for the caller-supplied scripts in this stack frame, avoiding
    # conflict with [pipeline:loop]'s own variables.
    if {[info level] == 1} {
        unset args
        return [{*}[info level 0]]
    }

    # Parse arguments.
    argparse -boolean {
        -command
        -observe
        {-result   -forbid {command observe}}
        {-buffer   -key bufferMode}
        {-raw      -require command}
        {-partial  -require buffer}
        {-separate -require buffer}
        {-delim=   -require buffer -default {\n}}
        {-trim     -require {buffer command} -forbid raw}
        script*!
    }

    # Bind the script to the inputs and outputs.  If -command is used, convert
    # the command prefix to a script.  Otherwise, precede the script with code
    # to expand the input to separate variables.
    if {$command} {
        # Append command arguments.
        if {$raw} {
            append script " \$input"
        } elseif {!$bufferMode} {
            append script " \[lindex \$input 0\]"
        } elseif {$trim} {
            append script " \[lindex \$input 4\]"
        } else {
            append script " \[lindex \$input 4\]\[lindex \$input 5\]"
        }

        # Store the command return value into the out variable.
        if {!$observe} {
            if {$raw} {
                set script "set out \[$script\]"
            } else {
                set script "set out \[list \[list \[$script\]\]\]"
            }
        }
    } elseif {[llength $script] > 1} {
        # When -command is not used, the script must be one argument.
        return -code error "too many arguments"
    } else {
        # If -result is used, store the script result into the out variable.
        # Intercept both "ok" (normal result) and "return" codes.
        if {$result} {
            set script "try $script on ok out {} on return out {}"
        } else {
            set script [lindex $script 0]
        }

        # Load tme data into script variables.
        set vars {data meta flush}
        if {$bufferMode} {
            lappend vars prior buffer complete
        }
        set script "lassign \$input $vars\n$script"
    }

    # Get access to caller input and output variables.
    upvar 1 input input out scriptOut

    if {$bufferMode} {
        # Avoid infinite loops by rejecting patterns matching empty string.
        if {[regexp $delim {}]} {
            return -code error "delimiter pattern matches empty string: $delim"
        }

        # Loop until the pipeline is destroyed.
        set out {}
        set buffer {}
        while {[set input [yieldto return -level 0 $out]] ne {}} {
            # Concatenate the buffer with the new input data, then divide into
            # complete chunks, each chunk ending with the delimiter pattern.
            lassign $input data meta flush
            set in {}
            while {[regexp -indices -- $delim [set str $buffer$data] match]} {
                set len [expr {[lindex $match 1] - [string length $buffer]}]
                lappend in [list [string range $data 0 $len] $meta 0 $buffer\
                        [string range $str 0 [expr {[lindex $match 0] - 1}]]\
                        [string range $str {*}$match]]
                set data [string replace $data 0 $len]
                set buffer {}
            }

            # Buffer leftover data, and put it into an incomplete chunk.  Create
            # an empty chunk if there are no chunks but meta or flush are used.
            if {$data ne {} || ($in eq {} && ($meta ne {} || $flush))} {
                lappend in [list $data $meta 0 $buffer [append buffer $data] {}]
            }

            # On flush, enable flush in the last chunk, and empty the buffer.
            if {$flush} {
                lset in end 2 1
                set buffer {}
            }

            if {$observe} {
                # In observation mode, simply run the script and ignore output.
                set out {{}}
                foreach input $in {
                    if {$partial || [lindex $input 2]
                     || [lindex $input 5] ne {}} {
                        uplevel 1 $script
                    }
                }
            } else {
                # Run the script body for each input chunk and collect output
                # chunks.  When -partial is not used, flush is not commanded,
                # and the buffer is incomplete, do not run the script.
                set out {}
                foreach input $in {
                    if {$partial || [lindex $input 2]
                     || [lindex $input 5] ne {}} {
                        # Run the loop body script.
                        set scriptOut {{}}
                        uplevel 1 $script

                        # Fill in omitted output elements with defaults.
                        foreach output $scriptOut {
                            if {!$partial && ![llength $output]} {
                                set output [list [uplevel 1 {
                                    string cat $buffer $complete
                                }]]
                            }
                            if {[llength $output] < 3} {
                                lappend output {*}[lrange $input\
                                        [llength $output] 2]
                            }
                            lappend out $output
                        }
                    }
                }

                # Unless -separate is used, merge consecutive chunks having the
                # same metadata and restart flag.  Two chunks cannot be merged
                # if the first one commands flush but the second does not.
                if {!$separate} {
                    set i 0
                    set j 1
                    while {$j < [llength $out]} {
                        if {[lindex $out $i 1] eq [lindex $out $j 1]
                         && (![lindex $out $i 2] || [lindex $out $j 2])
                         && ([llength [lindex $out $i]] >= 4
                          && [lindex $out $i 3])
                         == ([llength [lindex $out $j]] >= 4
                          && [lindex $out $j 3])} {
                            lset out $i 0 [lindex $out $i 0][lindex $out $j 0]
                            lset out $i 2 [lindex $out $j 2]
                            set out [lreplace $out $j $j]
                        } else {
                            incr i
                            incr j
                        }
                    }
                }
            }
        }
    } else {
        # For unbuffered mode, far less processing is required.
        set scriptOut {}
        while {[set input [yieldto return -level 0 $scriptOut]] ne {}} {
            set scriptOut {{}}
            uplevel 1 $script
        }
    }
}

# ::pipeline::fork --
# Filter procedure for use with [pipeline::new].  Defines anonymous pipelines
# within the context of a parent pipeline.  Each input chunk is used as the
# input to the first filter of each nested pipeline.  The output of this filter
# is the output of the final filter of the first nested pipeline, and the
# outputs of the other nested pipelines are discarded.  Each [pipeline::fork]
# argument is a list of pipeline filter command prefixes.
proc ::pipeline::fork {args} {
    if {$args eq {}} {
        discard
    } else {
        set first [pipeline::new {*}[lindex $args 0]]
        set rest [lmap arg [lrange $args 1 end] {pipeline::new {*}$arg}]
        loop {
            set out [$first run $input]
            foreach coro $rest {
                $coro run $input
            }
        }
    }
}

# ::pipeline::filter --
# Filter procedure for use with [pipeline::new].  Passes or discards chunks for
# which a filter criteria script evaluates to true or false, respectively.
#
# The criteria script has access to all the same variables as the script
# argument to [pipeline::loop], including the additional variables provided by
# the -buffer switch.  The criteria script may also access variables set by the
# initial variable dict, the initialization script, or previous iterations of
# the criteria script.
#
# The following arguments are accepted:
#
# -vars VARS  Dict mapping from variable names and initial values
# -setup SCR  Initialization script
# -expr       Script is instead a Tcl math [expr] expression
# -buffer     Wait until delimiter is encountered before evaluating script
# -partial    Evaluate script for partial buffers as well as complete buffers
# -delim PAT  Buffer delimiter regular expression, default \n
# script      Script to evaluate for each chunk
proc ::pipeline::filter {args} {
    argparse {
        {-vars=   -default {}}
        {-setup=  -default {}}
        {-expr    -boolean}
        {-buffer  -pass loopArgs}
        {-partial -pass loopArgs}
        {-delim?  -pass loopArgs}
        test
    }
    if {$expr} {
        set test [list expr $test]
    }
    dict with vars {}
    eval $setup
    loop {*}$loopArgs {
        if {![eval $test]} {
            set out {}
        }
    }
}

# ::pipeline::echo --
# Filter procedure for use with [pipeline::new].  Echoes input data to a given
# channel (defaulting to stdout) then passes it through unmodified.  If this
# filter is wrapped using [pipeline::loop -buffer], and flush is not commanded,
# only complete buffers are echoed, with the delimiter appended.  Otherwise,
# chunks are echoed as soon as they are received.  The output channel is flushed
# after every write.
proc ::pipeline::echo {args} {
    argparse {
        {-buffer  -pass loopArgs}
        {-delim=  -pass loopArgs -require buffer}
        {chan?    -default stdout}
    }
    loop -observe {*}$loopArgs {
        chan puts -nonewline $chan $data
        chan flush $chan
    }
}

# ::pipeline::regsub --
# Filter procedure for use with [pipeline::new].  Applies [regsub] filtering to
# each complete buffer flowing through the pipeline.
#
# The initial arguments alternate between regular expressions and replacements.
# If an odd number of arguments are given, the final replacement is assumed to
# be empty string.  Additionally, any standard [regsub] switches may be used.
#
# Regular expressions and replacements cannot begin with "-".  One possible
# workaround is to instead begin with "\-".  Another is to precede the regular
# expression and replacement arguments with the special "--" switch.
#
# Regular expression matching and substitution are not applied to the delimiter,
# which is newline by default.  The delimiter can be changed using the -delim
# switch.  See the [pipeline::loop -buffer] documentation for more information.
#
# If the -erase switch is used, at least one regular expression substitution
# succeeded, and the result is an empty buffer, it is removed in full, and no
# delimiter is appended.  This mode allows [pipeline::regsub] to be used to
# delete entire lines of input, rather than make them be blank lines.
proc ::pipeline::regsub {args} {
    argparse -normalize -boolean -pass regsubArgs {
        {-start=    -pass regsubArgs}
        -erase
        {-delim=    -pass loopArgs}
        expReps*!
    }
    loop -buffer -result {*}$loopArgs {
        # Apply regular expression substitutions.
        foreach {exp rep} $expReps {
            ::regsub {*}$regsubArgs $exp $buffer $rep buffer
        }

        # Append the delimiter unless the buffer is being erased.
        if {!$erase || $buffer ne {}} {
            append buffer $complete
        }

        # Yield any output that may have been obtained.
        if {$buffer ne {}} {
            list [list $buffer]
        }
    }
}

# ::pipeline::trimTrailingSpace --
# Filter procedure for use with [pipeline::new].  Trims trailing whitespace from
# each buffer.  The default delimiter is newline but can be changed with -delim.
# See the documentation for [pipeline::loop -buffer] for more information.
proc ::pipeline::trimTrailingSpace {args} {
    argparse {{-delim= -ignore}}
    loop -buffer -partial -result {*}$args {
        # Find the last non-whitespace character in the current chunk.
        set output {}
        if {[regexp -indices {.*[^ \f\n\r\t\v]} $buffer end]} {
            # Find the last non-whitespace character preceding the current
            # chunk.  This was the last character that was output before.
            if {[regexp -indices {.*[^ \f\n\r\t\v]} $prior start]} {
                set start [expr {[lindex $start 1] + 1}]
            } else {
                set start 0
            }

            # Output all characters since the previous output for this buffer
            # through the final non-whitespace character in the current chunk.
            append output [string range $buffer $start [lindex $end 1]]
        }

        # If this is a complete buffer, append the delimiter to the output.
        append output $complete

        # Yield any output that may have been obtained.
        if {$output ne {}} {
            list [list $output]
        }
    }
}

# ::pipeline::squeeze --
# Filter procedure for use with [pipeline::new].  Removes empty buffers at the
# beginning and end of output and collapses consecutive empty buffers into one.
# The default delimiter is newline but can be changed with -delim.  See the
# documentation for [pipeline::loop -buffer] for more information.
proc ::pipeline::squeeze {args} {
    argparse {{-delim= -ignore}}
    set empty 1
    loop -buffer -partial {*}$args {
        if {$buffer eq {} && $complete ne {}} {
            # Do not output empty buffers.
            set out {}
            set empty 1
        } elseif {$buffer ne {}} {
            # If a non-empty buffer comes after at least one empty buffer which
            # is not at the beginning of input, precede the output chunk with
            # the most recently observed delimiter.  Otherwise, fall back on the
            # default behavior which is to pass the chunk through directly.
            if {$empty && [info exists delim]} {
                set out [list [list $delim] {}]
            }
            set empty 0
            if {$complete ne {}} {
                set delim $complete
            }
        }
    }
}

# ::pipeline::removeFixed --
# Filter procedure for use with [pipeline::new].  Removes buffers that exactly
# match one or more literal pattern strings, which do not include the delimiter.
# The -prefix switch also removes buffers that begin with any pattern string.
#
# Unlike [pipeline::regsub], this procedure does not delay output until the
# delimiter is encountered.  Buffering only happens in event of a prefix match.
#
# If a flush occurs in the middle of a partial buffer, it will be output as-is,
# even though it could potentially be followed by characters that would make it
# match the removal pattern.
#
# The default delimiter is newline but can be changed with -delim.  See the
# documentation for [pipeline::loop -buffer] for more information.
proc ::pipeline::removeFixed {args} {
    argparse -boolean {
        -prefix
        {-delim=  -pass loopArgs}
        patterns*
    }
    loop -buffer -partial {*}$loopArgs {
        foreach pattern $patterns {
            # Determine the match prefix length.
            if {$prefix && (($complete ne {} || $flush)
             || [string length $pattern] < [string length $buffer])} {
                set len [string length $pattern]
            } elseif {$complete eq {} && !$flush} {
                set len [string length $buffer]
            } else {
                set len -1
            }

            # Check for matches against the current and prior buffers.
            if {[string equal -length $len $buffer $pattern]} {
                # Discard or delay the input if the buffer is complete and
                # exactly matches the pattern, or is incomplete and is a prefix
                # of the pattern, or if prefix matching is enabled and the
                # pattern is a prefix of the buffer.
                set out {}
                break
            } elseif {$prior ne {} && [string equal\
                    -length [string length $prior] $prior $pattern]} {
                # If the partial buffer was previously discarded, provisionally
                # output it in full because it ultimately ended up not matching.
                # It may yet be discarded if it matches another pattern.
                set out [list [list $buffer$complete]]
            }
        }
    }
}

# ::pipeline::tee --
# Filter procedure for use with [pipeline::new].  Tees one pipeline off another,
# connecting the output of the current pipeline at the current point to the
# input of the other pipeline, without affecting the data flowing through the
# current pipeline.  If nothing will call [pipeline::get] on the other pipeline,
# it is best that it contain the [pipeline::discard] filter to avoid unbounded
# growth of its output buffer.
proc ::pipeline::tee {pipeline} {
    loop -observe {
        $pipeline put -meta $meta {*}[if {$flush} {list -flush}] $data
    }
}

# ::pipeline::splice --
# Filter procedure for use with [pipeline::new].  Splices one pipeline into
# another, connecting the output of the current pipeline at the current point to
# the input of the other pipeline, and vice versa.
proc ::pipeline::splice {pipeline} {
    loop -command -raw $pipeline run
}

# ::pipeline::discard --
# Filter procedure for use with [pipeline::new].  Discards all input.  The
# pipeline is ended immediately unless flush is commanded, in which case any
# subsequent filters (there probably won't be any) are executed with no input.
# This filter is useful in combination with [pipeline::tee] to terminate a teed
# pipeline on which [pipeline::get] will never be called.
proc ::pipeline::discard {} {
    loop -result {}
}

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
