
[//000000001]: # (tcl::chan::fifo2 - Reflected/virtual channel support)
[//000000002]: # (Generated from file 'tcllib_fifo2.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcl::chan::fifo2(n) 1 tcllib "Reflected/virtual channel support")

# NAME

tcl::chan::fifo2 - In-memory interconnected fifo channels

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
package require tcl::chan::events ?1?  
package require tcl::chan::halfpipe ?1?  
package require tcl::chan::fifo2 ?1?  

[__::tcl::chan::fifo2__](#1)  

# <a name='description'></a>DESCRIPTION

The __tcl::chan::fifo2__ package provides a command creating pairs of channels
which live purely in memory and are connected to each other in a fifo manner.
What is written to one half of the pair can be read from the other half, in the
same order. One particular application for this is communication between
threads, with one half of the pair moved to the thread to talk to. This is
equivalent to the fifo2 channels provided by the package __Memchan__, except
that this is written in pure Tcl, not C. On the other hand, __Memchan__ is
usable with Tcl 8.4 and before, whereas this package requires Tcl 8.5 or higher,
and __[TclOO](../../../../index.md#tcloo)__.

The internal __[TclOO](../../../../index.md#tcloo)__ class implementing the
channel handler is a sub-class of the
__[tcl::chan::events](../virtchannel_core/events.md)__ framework.

# <a name='section2'></a>API

  - <a name='1'></a>__::tcl::chan::fifo2__

    This command creates a new connected pair of fifo channels and returns their
    handles, as a list containing two elements.

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

[connected fifos](../../../../index.md#connected_fifos),
[fifo](../../../../index.md#fifo), [in-memory
channel](../../../../index.md#in_memory_channel), [inter-thread
communication](../../../../index.md#inter_thread_communication), [reflected
channel](../../../../index.md#reflected_channel), [tip
219](../../../../index.md#tip_219), [virtual
channel](../../../../index.md#virtual_channel)

# <a name='category'></a>CATEGORY

Channels

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
