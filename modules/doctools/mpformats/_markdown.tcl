# -*- tcl -*-
##
# Support for markdown, overrides parts of coore text.
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>
# Freely redistributable.
##
# # ## ### ##### ########

proc c_copyrightsymbol {} {return "&copy;"}

# Modified bulleting

DIB {- * +}
DEB {{1.} {1)}}

# # ## ### ##### ########
## `markdown` formatting

proc SectTitle {lb title} {
    upvar 1 $lb lines
    lappend lines "# $title"
    return
}

proc SubsectTitle {lb title} {
    upvar 1 $lb lines
    lappend lines "## $title"
    return
}

proc Sub3Title {lb title} {
    upvar 1 $lb lines
    lappend lines "### $title"
    return
}

proc Sub4Title {lb title} {
    upvar 1 $lb lines
    lappend lines "#### $title"
    return
}

proc Strong {text} { return __${text}__ }
proc Em     {text} { return *${text}* }

##
# # ## ### ##### ########
##

set __comments 0

proc MDComment {text} {
    global __comments
    Text "\n\[//[format %09d [incr __comments]]\]: # ($text)"
}

proc MDCDone {} {
    TextTrimLeadingSpace
    CloseParagraph [Verbatim]
}

##
# # ## ### ##### ########
##

proc MakeLink {l t} { ALink $t $l } ;# - xref - todo: consolidate

proc ALink {dst label} { return "\[$label]($dst)" }

proc SetAnchor {text {name {}}} {
    if {$name == {}} { set name [Anchor $text] }
    return "<a name='$name'></a>$text"
}

proc Anchor {text} {
    global kwid
    if {[info exists kwid($text)]} {
	return "$kwid($text)"
    }
    return [A $text]
}

proc A {text} {
    set anchor [regsub -all {[^a-zA-Z0-9]} [string tolower $text] {_}]
    set anchor [regsub -all {__+} $anchor _]
    return $anchor
}

##
# # ## ### ##### ########
return
