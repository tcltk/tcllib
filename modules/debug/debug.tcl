# Debug - a debug narrative logger.
# -- Colin McCormack / originally Wub server utilities
#
# Debugging areas of interest are represented by 'tokens' which have 
# independantly settable levels of interest (an integer, higher is more detailed)
#
# Debug narrative is provided as a tcl script whose value is [subst]ed in the 
# caller's scope if and only if the current level of interest matches or exceeds
# the Debug call's level of detail.  This is useful, as one can place arbitrarily
# complex narrative in code without unnecessarily evaluating it.
#
# TODO: potentially different streams for different areas of interest.
# (currently only stderr is used.  there is some complexity in efficient
# cross-threaded streams.)

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require term::ansi::code::ctrl ; # ANSI terminal control codes

namespace eval ::debug {
    namespace export -clear \
	define on off prefix suffix header trailer \
	names 2array level setting parray
    namespace ensemble create -subcommands {}
}

# # ## ### ##### ######## ############# #####################
## API & Implementation

proc ::debug::noop {args} {}

proc ::debug::debug {tag message {level 1}} {
    variable detail
    if {$detail($tag) < $level} {
	#puts stderr "$tag @@@ $detail($tag) >= $level"
	return
    }

    variable prefix
    variable suffix
    variable header
    variable trailer
    variable fds
    set fd $fds($tag)

    # Assemble the shown text from the user message and the various
    # prefixes and suffices (global + per-tag).

    set themessage ""
    if {[info exists prefix(::)]}   { append themessage $prefix(::)   }
    if {[info exists prefix($tag)]} { append themessage $prefix($tag) }
    append themessage $message
    if {[info exists suffix($tag)]} { append themessage $suffix($tag) }
    if {[info exists suffix(::)]}   { append themessage $suffix(::)   }

    # Resolve variables references and command invokations embedded
    # into the message with plain text.
    set code [catch {
	set smessage [uplevel 1 [list ::subst -nobackslashes $themessage]]
	set sheader  [uplevel 1 [list ::subst -nobackslashes $header]]
	set strailer [uplevel 1 [list ::subst -nobackslashes $trailer]]
    } __ eo]

    # And dump an internal error if that resolution failed.
    if {$code} {
	if {[catch {
	    set caller [info level -1]
	}]} { set caller GLOBAL }
	if {[string length $caller] >= 1000} {
	    set caller "[string range $caller 0 200]...[string range $caller end-200 end]"
	}
	foreach line [split $caller \n] {
	    puts -nonewline $fd "@@(DebugError from $tag ($eo): $line)"
	}
	return
    }

    # From here we have a good message to show. We only shorten it a
    # bit if its a bit excessive in size.

    if {[string length $smessage] > 4096} {
	set head [string range $smessage 0 2048]
	set tail [string range $smessage end-2048 end]
	set smessage "${head}...(truncated)...$tail"
    }

    foreach line [split $smessage \n] {
	puts $fd "$sheader$tag | $line$strailer"
    }
    return
}

# names - return names of debug tags
proc ::debug::names {} {
    variable detail
    return [lsort [array names detail]]
}

proc ::debug::2array {} {
    variable detail
    set result {}
    foreach n [lsort [array names detail]] {
	if {[interp alias {} debug.$n] ne "::Debug::noop"} {
	    lappend result $n $detail($n)
	} else {
	    lappend result $n -$detail($n)
	}
    }
    return $result
}

# level - set level and fd for tag
proc ::debug::level {tag {level ""} {fd stderr}} {
    variable detail
    if {$level ne ""} {
	set detail($tag) $level
    }

    if {![info exists detail($tag)]} {
	set detail($tag) 1
    }

    variable fds
    set fds($tag) $fd

    return $detail($tag)
}

proc ::debug::header  {text} { variable header  $text }
proc ::debug::trailer {text} { variable trailer $text }

proc ::debug::define {tag} {
    if {[interp alias {} debug.$tag] ne {}} return
    off $tag
    return
}

# Set a prefix/suffix to use for tag.
# The global (tag-independent) prefix/suffix is adressed through tag '::'.
# This works because colon (:) is an illegal character for user-specified tags.

proc ::debug::prefix {tag {theprefix {}}} {
    variable prefix
    set prefix($tag) $theprefix

    if {[interp alias {} debug.$tag] ne {}} return
    off $tag
    return
}

proc ::debug::suffix {tag {theprefix {}}} {
    variable suffix
    set suffix($tag) $theprefix

    if {[interp alias {} debug.$tag] ne {}} return
    off $tag
    return
}

# turn on debugging for tag
proc ::debug::on {tag {level ""} {fd stderr}} {
    variable active
    set active($tag) 1
    level $tag $level $fd
    interp alias {} debug.$tag {} ::debug::debug $tag
    return
}

# turn off debugging for tag
proc ::debug::off {tag {level ""} {fd stderr}} {
    variable active
    set active($tag) 1
    level $tag $level $fd
    interp alias {} debug.$tag {} ::debug::noop
    return
}

proc ::debug::setting {args} {
    if {[llength $args] == 1} {
	set args [lindex $args 0]
    }
    set fd stderr
    if {[llength $args] % 2} {
	set fd   [lindex $args end]
	set args [lrange $args 0 end-1]
    }
    foreach {tag level} $args {
	if {$level > 0} {
	    level $tag $level $fd
	    interp alias {} debug.$tag {} ::debug::debug $tag
	} else {
	    level $tag [expr {-$level}] $fd
	    interp alias {} debug.$tag {} ::debug::noop
	}
    }
    return
}

# # ## ### ##### ######## ############# #####################
## Convenience command. Format an array as multi-line message.

proc ::debug::parray {a {pattern *}} {
    upvar 1 $a array
    if {![array exists array]} {
	error "\"$a\" isn't an array"
    }
    set maxl 0
    set names [lsort [array names array $pattern]]
    foreach name $names {
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    set maxl [expr {$maxl + [string length $a] + 2}]
    set lines {}
    foreach name $names {
	set nameString [format %s(%s) $a $name]
	lappend lines [format "%-*s = %s" $maxl $nameString $array($name)]
    }
    return [join $lines \n]
}

# # ## ### ##### ######## ############# #####################

namespace eval debug {
    variable detail     ; # map: TAG -> level of interest
    variable prefix     ; # map: TAG -> message prefix to use
    variable suffix     ; # map: TAG -> message suffix to use
    variable fds        ; # map: TAG -> handle of open channel to log to.
    variable header  {} ; # per-line heading, subst'ed
    variable trailer {} ; # per-line ending, subst'ed

    # Notes:
    # - The tag '::' is reserved. "prefix" and "suffix" use it to store
    #   the global message prefix / suffix.
    # - prefix and suffix are applied per message.
    # - header and trailer are per line. And should not generate multiple lines!
}

# # ## ### ##### ######## ############# #####################
## Ready

package provide debug 1.0
return
