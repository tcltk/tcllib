# -*- tcl -*-
#
# -- Core support for markdown
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>
# Freely redistributable.

################################################################

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
