# -*- tcl -*-
# sak::doc - Documentation facilities

package require sak::util

namespace eval ::sak::localdoc {}

# ###
# API commands

## ### ### ### ######### ######### #########

proc ::sak::localdoc::usage {} {
    package require sak::help
    puts stdout \n[sak::help::on localdoc]
    exit 1
}

proc ::sak::localdoc::run {} {
    set noe [info nameofexecutable]

    puts "Removing old documentation..."
    file delete -force embedded
    file mkdir embedded/man
    file mkdir embedded/www

    puts "Generating manpages..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-exclude {*/doctools/tests/*} \
	-exclude {*/support/*} \
	-ext n \
	-o embedded/man \
	nroff .

    # Note: Might be better to run them separately.
    # Note @: Or we shuffle the results a bit more in the post processing stage.

    puts "Generating HTML... Pass 1, draft..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-nav Home /home \
	-exclude {*/doctools/tests/*} \
	-exclude {*/support/*} \
	-merge \
	-o embedded/www \
	html .

    puts "Generating HTML... Pass 2, resolving cross-references..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-nav Home /home \
	-exclude {*/doctools/tests/*} \
	-exclude {*/support/*} \
	-merge \
	-o embedded/www \
	html .

    return
}

# ### ### ### ######### ######### #########

package provide sak::localdoc 1.0

##
# ###
