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
    getpackage cmdline          cmdline/cmdline.tcl
    getpackage fileutil         fileutil/fileutil.tcl
    getpackage textutil::repeat textutil/repeat.tcl
    getpackage doctools         doctools/doctools.tcl
    getpackage doctools::toc    doctools/doctoc.tcl
    getpackage doctools::idx    doctools/docidx.tcl
    getpackage dtplite          dtplite/dtplite.tcl

    set nav ../../../../home

    puts "Reindex the documentation..."
    sak::doc::imake __dummy__
    sak::doc::index __dummy__

    puts "Removing old documentation..."
    file delete -force embedded
    file mkdir embedded/man
    file mkdir embedded/www

    puts "Generating manpages..."
    dtplite::do \
	[list \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -ext n \
	     -o embedded/man \
	     nroff .]

    # Note: Might be better to run them separately.
    # Note @: Or we shuffle the results a bit more in the post processing stage.

    set map  {
	.man     .html
	modules/ tcllib/files/modules/
	apps/    tcllib/files/apps/
    }

    set toc  [string map $map [fileutil::cat support/devel/sak/doc/toc.txt]]
    set apps [string map $map [fileutil::cat support/devel/sak/doc/toc_apps.txt]]
    set mods [string map $map [fileutil::cat support/devel/sak/doc/toc_mods.txt]]
    set cats [string map $map [fileutil::cat support/devel/sak/doc/toc_cats.txt]]

    puts "Generating HTML... Pass 1, draft..."
    dtplite::do \
	[list \
	     -toc $toc \
	     -nav {Tcllib Home} $nav \
	     -post+toc Categories $cats \
	     -post+toc Modules $mods \
	     -post+toc Applications $apps \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -merge \
	     -o embedded/www \
	     html .]

    puts "Generating HTML... Pass 2, resolving cross-references..."
    dtplite::do \
	[list \
	     -toc $toc \
	     -nav {Tcllib Home} $nav \
	     -post+toc Categories $cats \
	     -post+toc Modules $mods \
	     -post+toc Applications $apps \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -merge \
	     -o embedded/www \
	     html .]

    return
}

# ### ### ### ######### ######### #########

package provide sak::localdoc 1.0

##
# ###
