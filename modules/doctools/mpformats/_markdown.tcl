# -*- tcl -*-
##
# Support for markdown, overrides parts of coore text.
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>
# Freely redistributable.
##
# # ## ### ##### ########

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
return
