# rtcore.tcl --
#
#	Runtime core for file type recognition engines written in pure Tcl.
#
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005      Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: rtcore.tcl,v 1.1 2005/02/10 17:34:16 andreas_kupries Exp $

#####
#
# "mime type recognition in pure tcl"
# http://wiki.tcl.tk/12526
#
# Tcl code harvested on:  10 Feb 2005, 04:06 GMT
# Wiki page last updated: ???
#
#####

# TODO - Required Functionality:

# implement full offset language
# implement pstring (pascal string, blerk)
# implement regex form (blerk!)
# implement string qualifiers

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.4

# ### ### ### ######### ######### #########
## Implementation

namespace eval ::fileutil::magic::rt {
    # Configuration flag. (De)activate debugging output.
    # This is done during initialization.
    # Changes at runtime have no effect.

    variable debug 0

    # Runtime state.

    variable fd     {}     ; # Channel to file under scrutiny
    variable strbuf {}     ; # Input cache [*].
    variable cache         ; # Cache of fetched and decoded numeric
    array set cache {}	   ; # values.
    variable result {}     ; # Accumulated recognition result.
    variable string {}     ; # Last recognized string | For substitution
    variable numeric -9999 ; # Last recognized number | into the message

    # [*] The vast majority of magic strings are in the first 4k of the file.

    namespace export open close file_start result
    namespace export emit offset Nv N S
}

# ### ### ### ######### ######### #########
## Public API, general use.

# open the file to be scanned
proc ::fileutil::magic::rt::open {file} {
    variable result {}
    variable string {}
    variable numeric -9999
    variable strbuf
    variable fd
    variable cache

    set fd [::open $file]
    ::fconfigure $fd -translation binary

    # fill the string cache
    set strbuf [::read $fd 4096]

    # clear the fetch cache
    catch {unset cache}
    array set cache {}

    return $fd
}

proc ::fileutil::magic::rt::close {} {
    variable fd
    ::close $fd
    return
}

# mark the start of a magic file in debugging
proc ::fileutil::magic::rt::file_start {name} {
    ::fileutil::magic::rt::Debug {puts stderr "File: $name"}
}

# return the emitted result
proc ::fileutil::magic::rt::result {{msg ""}} {
    variable result
    if {$msg ne ""} {emit $msg}
    return -code return [join $result " "]
}

# ### ### ### ######### ######### #########
## Public API, for use by a recognizer.

# emit a message
proc ::fileutil::magic::rt::emit {msg} {
    variable string
    variable numeric
    variable result

    set map [list \
	    \\b "" \
	    %s  $string \
	    %ld $numeric \
	    %d  $numeric \
	    ]

    lappend result [::string map $map $msg]
    return
}

# handle complex offsets - TODO
proc ::fileutil::magic::rt::offset {where} {
    ::fileutil::magic::rt::Debug {puts stderr "OFFSET: $where"}
    return 0
}

proc ::fileutil::magic::rt::Nv {type offset {qual ""}} {
    variable typemap
    variable numeric

    # unpack the type characteristics
    foreach {size scan} $typemap($type) break

    # fetch the numeric field from the file
    set numeric [Fetch $offset $size $scan]

    if {$qual ne ""} {
	# there's a mask to be applied
	set numeric [expr $numeric $qual]
    }

    ::fileutil::magic::rt::Debug {puts stderr "NV $type $offset $qual: $numeric"}
    return $numeric
}

# Numeric - get bytes of $type at $offset and $compare to $val
# qual might be a mask
proc ::fileutil::magic::rt::N {type offset comp val {qual ""}} {
    variable typemap
    variable numeric

    # unpack the type characteristics
    foreach {size scan} $typemap($type) break

    # fetch the numeric field
    set numeric [Fetch $offset $size $scan]

    # Would moving this before the fetch an optimisation ? The
    # tradeoff is that we give up filling the cache, and it is unclear
    # how often that value would be used. -- Profile!
    if {$comp eq "x"} {
	# anything matches - don't care
	return 1
    }

    # get value in binary form, then back to numeric
    # this avoids problems with sign, as both values are
    # [binary scan]-converted identically
    binary scan [binary format $scan $val] $scan val

    if {$qual ne ""} {
	# there's a mask to be applied
	set numeric [expr $numeric $qual]
    }

    # perform comparison
    set c [expr $val $comp $numeric]

    ::fileutil::magic::rt::Debug {puts stderr "numeric $type: $val $comp $numeric / $qual - $c"}
    return $c
}

proc ::fileutil::magic::rt::S {offset comp val {qual ""}} {
    variable fd
    variable string

    # convert any backslashes
    set val [subst -nocommands -novariables $val]

    if {$comp eq "x"} {
	# match anything - don't care, just get the value
	set string ""

	# Query: Can we use GetString here ?
	# Or at least the strbuf cache ?

	# move to the offset
	::seek $fd $offset
	while {
	    ([::string length $string] < 100) &&
	    [::string is print [set c [::read $fd 1]]]
	} {
	    if {[::string is space $c]} {
		break
	    }
	    append string $c
	}

	return 1
    }

    # get the string and compare it
    set string [GetString $offset [::string length $val]]
    set cmp    [::string compare $val $string]
    set c      [expr $cmp $comp 0]

    ::fileutil::magic::rt::Debug {
	puts "String '$val' $comp '$string' - $c"
	if {$c} {
	    puts "offset $offset - $string"
	}
    }
    return $c
}

# ### ### ### ######### ######### #########
## Internal. Retrieval of the data used in comparisons.

# fetch and cache a numeric value from the file
proc ::fileutil::magic::rt::Fetch {where what scan} {
    variable cache
    variable numeric
    variable fd

    if {![info exists cache($where,$what,$scan)]} {
	::seek $fd $where
	binary scan [::read $fd $what] $scan numeric
	set cache($where,$what,$scan) $numeric

	# Optimization: If we got 4 bytes, i.e. long we implicitly
	# know the short and byte data as well. Should put them into
	# the cache. -- Profile: How often does such an overlap truly
	# happen ?

    } else {
	set numeric $cache($where,$what,$scan)
    }
    return $numeric
}

proc ::fileutil::magic::rt::GetString {offset len} {
    # We have the first 1k of the file cached
    variable string
    variable strbuf
    variable fd

    set end [expr {$offset + $len - 1}]
    if {$end < 4096} {
	# in the string cache, copy the requested part.
	set string [::string range $strbuf $offset $end]
    } else {
	# an unusual one, move to the offset and read directly from
	# the file.
	::seek $fd $offset
	set string [::read $fd $len]
    }
    return $string
}

# ### ### ### ######### ######### #########
## Internal, debugging.

if {!$::fileutil::magic::rt::debug} {
    # This procedure definition is optimized out of using code by the
    # core bcc. It knows that neither argument checks are required,
    # nor is anything done. So neither results, nor errors are
    # possible, a true no-operation.
    proc ::fileutil::magic::rt::Debug {args} {}

} else {
    proc ::fileutil::magic::rt::Debug {script} {
	# Run the commands in the debug script. This usually generates
	# some output. The uplevel is required to ensure the proper
	# resolution of all variables found in the script.
	uplevel 1 $script
	return
    }
}

# ### ### ### ######### ######### #########
## Initialize constants

namespace eval ::fileutil::magic::rt {
    # maps magic typenames to field characteristics: size (#byte),
    # binary scan format

    variable typemap
}

proc ::fileutil::magic::rt::Init {} {
    variable typemap

    array set typemap {
	byte    {1 c}  ubyte   {1 c}  short    {2 S}  ushort   {2 S}
	beshort {2 S}  leshort {2 s}  ubeshort {2 S}  uleshort {2 s}
	long    {4 I}  belong  {4 I}  lelong   {4 i}  ubelong  {4 I}
	ulelong {4 i}  date    {2 S}  bedate   {2 S}  ledate   {2 s}
	ldate   {4 I}  beldate {4 I}  leldate  {4 i}
    }

    # generate short form names
    foreach {n v} [array get typemap] {
	foreach {len scan} $v break
	#puts stderr "Adding $scan - [list $len $scan]"
	set typemap($scan) [list $len $scan]
    }
}

::fileutil::magic::rt::Init
# ### ### ### ######### ######### #########
## Ready for use.

package provide fileutil::magic::rt 1.0
# EOF
