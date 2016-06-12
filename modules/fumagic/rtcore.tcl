# rtcore.tcl --
#
#	Runtime core for file type recognition engines written in pure Tcl.
#
# Copyright (c) 2016      Poor Yorick     <tk.tcl.core.tcllib@pooryorick.com>
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005      Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: rtcore.tcl,v 1.5 2005/09/28 04:51:19 andreas_kupries Exp $

#####
#
# "mime type recognition in pure tcl"
# http://wiki.tcl.tk/12526
#
# Tcl code harvested on:  10 Feb 2005, 04:06 GMT
# Wiki page last updated: ???
#
#####

#TODO  {
#    {Required Functionality} {
#	{implement full offset language} {
#	    done
#
#	    by pooryorick
#
#	    time {2016 06}
#	}
#
#	{implement pstring (pascal string, blerk)} {
#	    done
#
#	    by pooryorick
#
#	    time {2016 06}
#}
#
#	{implement regex form (blerk!)} {
#	    done
#
#	    by pooryorick
#
#	    time {2016 06}
#	}

#	{implement string qualifiers} {
#	    done
#	    
#	    by pooryorick
#
#	    time {2016 06}
#	}
#
#	{finish implementing the indirect type}
#
#	{Maybe distinguish between binary and text tests, like file(n)}
#	
#	{process and use strength directives}
#
#    }
#}

# ### ### ### ######### ######### #########
## Requirements

package require Tcl 8.6

# ### ### ### ######### ######### #########
## Implementation

namespace eval ::fileutil::magic::rt {
    # Configuration flag. (De)activate debugging output.
    # This is done during initialization.
    # Changes at runtime have no effect.

    variable debug 0

    # The maximum size of a substring to inspect from the file in question 
    variable maxstring 64

    # The maximum length of any %s substitution in a resulting description is
    variable maxpstring 64

    variable regexdefaultlen 4096

    # Runtime state.

    variable cursor 0      ; # The current offset
    variable fd     {}     ; # Channel to file under scrutiny
    variable found 0       ; # Whether the last test produced a match
    variable strbuf {}     ; # Input cache [*].
    variable cache         ; # Cache of fetched and decoded numeric
    array set cache {}	   ; # values.
    variable result {}     ; # Accumulated recognition result.
    variable extracted     ; # The value extracted for inspection
    variable  last         ; # Behind last fetch locations,
    array set last {}      ; # per nesting level.
    variable weight 0      ; # The weight of the current part. 
                           ; # Basically string length of the contributing of
			   ; # the potentially-matching part.

    variable weighttotal 0 ; # The aggregate weight of the matching components of
			   ; # the current test.

    # [*] The vast majority of magic strings are in the first 4k of the file.

    # Export APIs (full public, recognizer public)
    namespace export open close file_start result
    namespace export emit ext mime offset Nv N S Nvx Nx Sx L R I resultv U < >
}

# ### ### ### ######### ######### #########
## Public API, general use.

proc ::fileutil::magic::rt::> {} {
    upvar level level
    incr level
}

proc ::fileutil::magic::rt::< {} {
    upvar level level
    incr level -1
}

proc ::fileutil::magic::rt::classify {data} {
    set bin_rx {[\x00-\x08\x0b\x0e-\x1f]}
    if {[regexp $bin_rx $data] } {
        return binary
    } else {
        return text
    }
}

proc ::fileutil::magic::rt::mime value {
    upvar 1 mime mime
    set mime $value
}

proc ::fileutil::magic::rt::ext value {
    upvar 1 ext ext
    set ext $value
}


# open the file to be scanned
proc ::fileutil::magic::rt::open {file} {
    variable result {}
    variable extracted {} 
    variable strbuf
    variable fd
    variable cache

    set fd [::open $file]
    ::fconfigure $fd -translation binary
        
    # fill the string cache
    set strbuf [::read $fd 4096]
	set class [classify $strbuf]

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
proc ::fileutil::magic::rt::result {{msg {}}} {
    variable found
    variable result
    variable weight
    variable weighttotal
    if {$msg ne {}} {emit $msg}
    set res [list $found $weighttotal $result]
    set found 0
    set weight 0
    set weighttotal 0
    set result {}
    return -code return $res 
}

proc ::fileutil::magic::rt::resultv {{msg {}}} {
    try result on return result {
	return $result
    }
}

# ### ### ### ######### ######### #########
## Public API, for use by a recognizer.

# emit a description 
proc ::fileutil::magic::rt::emit msg {
    variable found
    variable maxpstring
    variable extracted
    variable result
    variable weight
    variable weighttotal
    set found 1
    incr weighttotal $weight

    #set map [list \
    #    \\b "" \
    #    %c [apply {extracted {
    #        if {[catch {format %c $extracted} result]} {
    #    	return {}
    #        }
    #        return $result

    #    }} $extracted] \
    #    %s  [string trim [string range $extracted 0 $maxpstring]] \
    #    %ld $extracted \
    #    %d  $extracted \
    #]
    #[::string map $map $msg]

    # {to do} {Is only taking up to the first newline really a good general rule?}
    regexp {\A[^\n\r]*} $extracted extracted2

    regsub -all {\s+} $extracted2 { } extracted2

    set arguments {}
    set count [expr {[string length $msg] - [string length [
	string map {% {}} $msg]]}]
    for {set i 0} {$i < $count} {incr i} {
	lappend arguments $extracted2
    }
    catch {set msg [format $msg {*}$arguments]}

    # Assumption: [regexp] leaves $msg untouched if it fails
    regexp {\A(\b|\\b)?(.*)$} $msg match b msg
    if {$b ne {} && [llength $result]} {
	lset result end [lindex $result end]$msg
    } else {
	lappend result $msg
    }
    return
}

proc ::fileutil::magic::rt::Nv {type offset compinvert mod mand} {
    variable typemap
    variable extracted
    variable weight

    # unpack the type characteristics
    foreach {size scan} $typemap($type) break

    # fetch the numeric field from the file
    set extracted [Fetch $offset $size $scan]

    if {$compinvert && $extracted ne {}} {
	set extracted [expr ~$extracted]
    }
    if {$mod ne {} && $extracted ne {}} {
	# there's a mask to be applied
	set extracted [expr $extracted $mod $mand]
    }

    ::fileutil::magic::rt::Debug {puts stderr "NV $type $offset $mod: $extracted"}
    set weight [string length $extracted]
    return $extracted
}

proc ::fileutil::magic::rt::use {named file name} {
    if [dict exists $named $file $name] {
	set script [dict get $named $file $name]
    } else {
	dict for {file val} $named {
	    if {[dict exists $val $name]} {
		set script [dict get $val $name]
		break
	    }
	}
    }
    if {![info exists script]} {
	return -code error [list {name not found} $key]
    }
    return $script
}

# Numeric - get bytes of $type at $offset and $compare to $val
# qual might be a mask
proc ::fileutil::magic::rt::N {
    type offset testinvert compinvert mod mand comp val} {
    variable typemap
    variable extracted
    variable weight

    # unpack the type characteristics
    foreach {size scan} $typemap($type) break

    # fetch the numeric field
    set extracted [Fetch $offset $size $scan]
    if {$extracted eq {}} {

	# Rules like the following, from the jpeg file, imply that
	# in the absence of an extracted value, a numerical value of 
	# 0 should be used

	# From jpeg:
	    ## Next, show thumbnail info, if it exists:
	    #>>18    byte        !0      \b, thumbnail %dx
	set extracted 0
    }

    # Would moving this before the fetch an optimisation ? The
    # tradeoff is that we give up filling the cache, and it is unclear
    # how often that value would be used. -- Profile!
    if {$comp eq {x}} {
	set weight 0
	# anything matches - don't care
	if {$testinvert} {
	    return 0
	} else {
	    return 1
	}
    }

    if {[string match $scan *me]} {
	set data [me4 $data]
	set scan I 
    }
    # get value in binary form, then back to numeric
    # this avoids problems with sign, as both values are
    # [binary scan]-converted identically (see [treegen1])
    binary scan [binary format $scan $val] $scan val

    if {$compinvert && $extracted ne {}} {
	set extracted [expr ~$extracted]
    }

    # perform comparison
    if {$mod ne {}} {
	# there's a mask to be applied
	set extracted [expr $extracted $mod $mand]
    }
    switch $comp {
	& {
	    set c [expr {($extracted & $val) == $val}]
	}
	^ {
	    set c [expr {($extracted & ~$val) == $extracted}]
	}
	== - != - < - > {
	    set c [expr $extracted $comp $val]
	}
	default {
	    #Should never reach this
	    return -code error [list {unknown comparison operator} $comp]
	}
    }
    # Do this last to minimize shimmering
    set weight [string length $extracted]

    ::fileutil::magic::rt::Debug {
	puts stderr "numeric $type: $val $t$comp $extracted / $mod - $c"
    }
    if {$testinvert} {
	set c [expr {!$c}]
	return $c 
    } else {
	return $c
    }
}

proc ::fileutil::magic::rt::S {type offset testinvert mod mand comp val} {
    variable cursor
    variable extracted
    variable fd
    variable maxstring
    variable regexdefaultlen
    variable weight

    # $compinvert is currently ignored for strings

    set weight [string length $val]

    switch $type {
	pstring {
	    set ptype B
	    set vincluded 0
	    # The last pstring type specifier wins 
	    foreach item $mod {
		if {$item eq {J}} {
		    set vincluded 1
		} else {
		    set ptype $item
		}
	    }
	    lassign [dict get {B {b 1} H {S 2} h {s 2} L {I 4} l {i 4}} $ptype] scan slength
	    set length [GetString $offset $slength]
	    set offset $cursor 
	    binary scan $length ${scan}u length
	    if {$vincluded} {
		set length [expr {$length - $slength}]
	    }
	    set extracted [GetString $offset $length]
	    set c [Smatch $val $comp $extracted $mod]
	}
	regex {
	    if {$mand eq {}} {
		set mand $regexdefaultlen 
	    }
	    set extracted [GetString $offset $mand]
	    if {[regexp $val $extracted match]} {
		set weight [string length $match]
	        set c 1
	    } else {
	        set c 0
	    }
	}
	search {
	    set limit $mand
	    set extracted [GetString $offset $limit]
	    if {[string first $val $extracted] >= 0} {
		set weight [string length $val]
		set c 1
	    } else {
		set c 0
	    }
	} default {
	    # get the string and compare it
	    switch $type bestring16 - lestring16 {
		set extracted [GetString $offset $maxstring]
		set extracted [string range $extracted 0 1]
		switch $type bestring16 {
		    set extracted [binary scan $extracted Su]
		} lestring16 {
		    set extracted [binary scan $extracted Su]
		}
		set extracted [format %c $extracted]
	    } default {
		# If $val is 0, give [emit] something to work with .
		if {$val eq  "\0"} {
		    set extracted [GetString $offset $maxstring]
		} else {
		    set extracted [GetString $offset [string length $val]]
		}
	    }
	    set c [Smatch $val $comp $extracted $mod]
	}
    }


    ::fileutil::magic::rt::Debug {
	puts "String '$val' $comp '$extracted' - $c"
	if {$c} {
	    puts "offset $offset - $extracted"
	}
    }
    if {$testinvert} {
	return [expr {!$c}]
    } else {
	return $c
    }
}

proc ::fileutil::magic::rt::Smatch {val op string mod} {
    variable weight
    if {$op eq {x}} {
	set weight 0
	return 1
    }

    if {![string length $string]} {
	# Nothing matches an empty $string.
	return 0
    }

    if {$op eq {>} && [string length $val] > [string length $string]} {
	return 1
    }

    # To preserve the semantics, the w operation must occur prior to the W
    # operation (Assuming the interpretation that w makes all whitespace
    # optional, relazing the requirements of W) .
    if {{w} in $mod} {
	regsub -all {\s} $string[set string {}] {} string
	regsub -all {\s} $val[set val {}] {} val
    }

    if {{W} in $mod} {
	set blanklen [::tcl::mathfunc::max 0 {*}[
	    lmap blanks [lrange [regexp -all -inline {(\s+)} $val] 1 end] {
	    expr {[$lindex blanks 1] - [$lindex blanks 0]}
	}]]
	if {![regexp "\s{$blanklen}" $string]} {
	    ::fileutil::magic::rt::Debug {
		puts "String '$val' $op '$string' - $c"
		if {$c} {
		    puts "offset $offset - $string"
		}
	    }
	    return 0
	}

	regsub -all {\s+} $string[set string {}] { } string
	regsub -all {\s+} $val[set val {}] { } val
    }


    if {{T} in $mod} {
	set string [string trim $string[set string {}]]
	set val [string tolower $val[set val {}]]
    }

    set string [string range $string  0 [string length $val]-1]

    # The remaining code may assume that $string and $val have the same length
    # .

    set opnum [dict get {< -1 == 0 eq 0 != 0 ne 0 > 1} $op]

    if {{c} in $mod || {C} in $mod} {
	if {{c} in $mod && {C} in $mod} {
	    set string [string tolower $string[set string {}]]
	    set val [string tolower $val[set val {}]]
	} elseif {{c} in $mod} {
	    foreach sc [split $string] vc [split $val] {
		if {[string is lower $sc]} {
		    set vc [string tolower $vc]
		}
		if {[::string compare $val $string] != $opnum} {
		    set res 0
		    break
		}
	    }
	} elseif {{C} in $mode} {
	    foreach vc [split $val] sc [split $string]  {
		if {[string is upper $vc]} {
		    set sc [string toupper $sc]
		}
		if {[::string compare $val $string] != $opnum} {
		    set res 0
		    break
		}
	    }
	}
    } else {
	set res [expr {[::string compare $string $val] == $opnum}]
    }
    if {$op in {!= ne}} {
	set res [expr {!$res}]
    }
    set weight [string length $val]
    return $res
}

proc ::fileutil::magic::rt::Nvx {type offset compinvert mod mand} {
    variable typemap
    variable extracted
    variable last
    variable weight

    upvar 1 level l
    # unpack the type characteristics
    foreach {size scan} $typemap($type) break
    set last($l) [expr {$offset + $size}]

    set extracted [Nv $type $offset $compinvert $mod $mand]

    ::fileutil::magic::rt::Debug {puts stderr "NVx $type $offset $extracted $mod $mand"}
    return $extracted
}

# Numeric - get bytes of $type at $offset and $compare to $val
# qual might be a mask
proc ::fileutil::magic::rt::Nx {
    type offset testinvert compinvert mod mand comp val} {

    variable cursor
    variable typemap
    variable extracted
    variable last
    variable weight

    upvar 1 level l

    set res [N $type $offset $testinvert $compinvert $mod $mand $comp $val]

    ::fileutil::magic::rt::Debug {
	puts stderr "Nx numeric $type: $val $comp $extracted / $qual - $c"
    }
    set last($l) $cursor
    return $res
}

proc ::fileutil::magic::rt::Sx {
    type offset testinvert mod mand comp val} {
    variable cursor
    variable extracted
    variable fd
    variable last
    variable weight

    upvar 1 level l

    set res [S $type $offset $testinvert $mod $mand $comp $val]
    set last($l) $cursor
    return $res
}
proc ::fileutil::magic::rt::L {newlevel} {
    # Regenerate level information in the calling context.
    upvar 1 level l ; set l $newlevel
    return
}

proc ::fileutil::magic::rt::I {offset it ioi ioo iir io} {
    # Handling of base locations specified indirectly through the
    # contents of the inspected file.
    variable typemap
    foreach {size scan} $typemap($it) break
    if {$iir} {
	set io [Fetch [expr $offset + $io] $size $scan]
    }
    set data [Fetch [expr $offset $ioo $io] $size $scan]

    if {$ioi} {
	set data [expr {~$data}]
    }
    if {$ioo ne {}} {
	set data [expr $data $ioo $io]
    }
    return $data
}

proc ::fileutil::magic::rt::R base {
    # Handling of base locations specified relative to the end of the
    # last field one level above.

    variable last   ; # Remembered locations.
    upvar 1 level l ; # The level to get data from.
    return [expr {$last([expr {$l-1}]) + $base}]
}


proc ::fileutil::magic::rt::U {file name} {
    upvar level l
    upvar named named
    set script [use $named $file $name]
    tailcall ::try $script
}

# ### ### ### ######### ######### #########
## Internal. Retrieval of the data used in comparisons.

# fetch and cache a numeric value from the file
proc ::fileutil::magic::rt::Fetch {where what scan} {
    variable cache
    variable cursor
    variable extracted
    variable strbuf
    variable fd

    # {to do} id3 length
    if {![info exists cache($where,$what,$scan)]} {
	::seek $fd $where
	set data [::read $fd $what]
	incr cursor [string length $data]
	set extracted [rtscan $data $scan]
	set cache($where,$what,$scan) [list $extracted $cursor]

	# Optimization: If we got 4 bytes, i.e. long we implicitly
	# know the short and byte data as well. Should put them into
	# the cache. -- Profile: How often does such an overlap truly
	# happen ?

    } else {
	lassign $cache($where,$what,$scan) extracted cursor
    }
    return $extracted
}

proc ::fileutil::magic::rt::rtscan {data scan} {
    if {$scan eq {me}} {
	set data [me4 $data]
	set scan I 
    }
    set numeric {}
    binary scan $data $scan numeric
    return $numeric
}

proc ::fileutil::magic::rt::me4 data {
	binary scan $data a4 chars
	set data [binary format a4 [lindex $chars 1] [
	lindex $chars 0] [lindex $chars 3] [lindex $chars 2]]
}

proc ::fileutil::magic::rt::GetString {offset len} {
    variable cursor
    # We have the first 1k of the file cached
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
    set cursor [expr {$offset + [string length $string]}]
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
    global tcl_platform

    # Set the definitions for all types which have their endianess
    # explicitly specified n their name.

    array set typemap {
	byte    {1 c}
	beshort {2 S}
	leshort {2 s}
	bedouble {8 Q}
	belong  {4 I}
	lelong  {4 i}
	bedate  {4 S}  ledate   {4 s}
	beldate {4 I}  leldate  {4 i}
	bedouble {8 Q}
	beqdate {8 W}
	beqldate {8 W}
	bequad {8 W} 
	ledouble {8 q}
	leqdate {8 w}
	leqldate {8 w}
	lequad {8 w}
	lequad {8 w} 
	leqwdate {8 w}
	medate  {4 me}
	melong  {4 me}
	meldate  {4 me}
	lestring16 {2 s}
	bestring16 {2 S}

	long  {4 Q} date  {4 Q} ldate {4 Q}
	short {2 Y} quad {8 W} 
    }

    # Now set the definitions for the types without explicit
    # endianess. They assume/use 'native' byteorder. We also put in
    # special forms for the compiler, so that it can use short names
    # for the native-endian types as well.

    # generate short form names
    foreach {n v} [array get typemap] {
	foreach {len scan} $v break
	#puts stderr "Adding $scan - [list $len $scan]"
	set typemap($scan) [list $len $scan]
    }

    # The special Q and Y short forms are incorrect, correct now to
    # use the proper native endianess.

    # {to do} {Is ldate done correctly in the procedure?  What is its byte
    # order anyway?  Native?}

    if {$tcl_platform(byteOrder) eq "littleEndian"} {
	array set typemap {Q {4 i} Y {2 s}
	    short {2 s} long {4 i} quad {8 w}
	}
    } else {
	array set typemap {Q {4 I} Y {2 S}
	    short {2 S} long {4 I} quad {8 W}
	}
    }
}

::fileutil::magic::rt::Init
# ### ### ### ######### ######### #########
## Ready for use.

package provide fileutil::magic::rt 1.2
# EOF
