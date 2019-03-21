
[//000000001]: # (tcl::randomseed - Reflected/virtual channel support)
[//000000002]: # (Generated from file 'randseed.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcl::randomseed(n) 1 tcllib "Reflected/virtual channel support")

# NAME

tcl::randomseed - Utilities for random channels

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  
package require TclOO  
package require tcl::randomseed ?1?  

[__::tcl::randomseed__](#1)  
[__::tcl::combine__ *seed1* *seed2*](#2)  

# <a name='description'></a>DESCRIPTION

The __tcl::randomseed__ package provides a a few utility commands to help with
the seeding of __[tcl::chan::random](tcllib_random.md)__ channels.

# <a name='section2'></a>API

  - <a name='1'></a>__::tcl::randomseed__

    This command creates returns a list of seed integers suitable as seed
    argument for random channels. The numbers are derived from the process id,
    current time, and Tcl random number generator.

  - <a name='2'></a>__::tcl::combine__ *seed1* *seed2*

    This command takes to seed lists and combines them into a single list by
    XORing them elementwise, modulo 256. If the lists are not of equial length
    the shorter of the two is padded with 0s before merging.

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *virtchannel* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='keywords'></a>KEYWORDS

[/dev/random](../../../../index.md#_dev_random),
[merge](../../../../index.md#merge), [random](../../../../index.md#random),
[reflected channel](../../../../index.md#reflected_channel),
[seed](../../../../index.md#seed), [tip 219](../../../../index.md#tip_219),
[virtual channel](../../../../index.md#virtual_channel)

# <a name='category'></a>CATEGORY

Channels

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
