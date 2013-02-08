# -*- tcl -*-
# sak::doc - Documentation facilities

package require sak::util
package require sak::doc

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

    # Relative path is necessary to handle possibility of fossil
    # repository and website as child of a larger website. Absolute
    # adressing may not point to our root, but the outer site.
    #set nav /home

    # NOTE: This may not work for the deeper nested manpages.
    # doc/tip/embedded/www/tcoc.html
    #set nav ../../../../../home

    # Indeed, not working for the nested pages.
    # Use absolute, for main location.
    set nav /tcllib

    puts "Removing old documentation..."
    file delete -force embedded
    file mkdir embedded/man
    file mkdir embedded/www

    puts "Reindex the documentation..."
    sak::doc::imake __dummy__
    sak::doc::index __dummy__

    puts "Generating manpages..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-exclude {*/doctools/tests/*} \
	-exclude {*/support/*} \
	-ext n \
	-o embedded/man \
	nroff .

    # Note: Might be better to run them separately.
    # Note @: Or we shuffle the results a bit more in the post processing stage.

    set toc [string map {.man .html} [fileutil::cat support/devel/sak/doc/toc.txt]]

    puts "Generating HTML... Pass 1, draft..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-toc $toc \
	-nav Home $nav \
	-exclude {*/doctools/tests/*} \
	-exclude {*/support/*} \
	-merge \
	-o embedded/www \
	html .

    puts "Generating HTML... Pass 2, resolving cross-references..."
    exec 2>@ stderr >@ stdout $noe apps/dtplite \
	-toc $toc \
	-nav Home $nav \
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
