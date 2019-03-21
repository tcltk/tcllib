
[//000000001]: # (tcl::chan::textwindow - Reflected/virtual channel support)
[//000000002]: # (Generated from file 'textwindow.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcl::chan::textwindow(n) 1 tcllib "Reflected/virtual channel support")

# NAME

tcl::chan::textwindow - Textwindow channel

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
package require tcl::chan::textwindow ?1?  

[__::tcl::chan::textwindow__ *widget*](#1)  

# <a name='description'></a>DESCRIPTION

The __tcl::chan::textwindow__ package provides a command creating write-only
channels connected to text widgets. Anything written to the channel is printed
into the associated widget.

The internal __[TclOO](../../../../index.md#tcloo)__ class implementing the
channel handler is a sub-class of the
__[tcl::chan::events](../virtchannel_core/events.md)__ framework.

# <a name='section2'></a>API

  - <a name='1'></a>__::tcl::chan::textwindow__ *widget*

    This command creates a new textwindow channel and returns its handle. Data
    written to this channel will appear in the associated *widget*.

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

[Tk](../../../../index.md#tk), [reflected
channel](../../../../index.md#reflected_channel), [text
widget](../../../../index.md#text_widget), [tip
219](../../../../index.md#tip_219), [virtual
channel](../../../../index.md#virtual_channel)

# <a name='category'></a>CATEGORY

Channels

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
