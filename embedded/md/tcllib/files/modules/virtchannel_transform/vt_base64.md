
[//000000001]: # (tcl::transform::base64 - Reflected/virtual channel support)
[//000000002]: # (Generated from file 'vt_base64.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcl::transform::base64(n) 1 tcllib "Reflected/virtual channel support")

# NAME

tcl::transform::base64 - Base64 encoding transformation

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

package require Tcl 8.6  
package require tcl::transform::core ?1?  
package require tcl::transform::base64 ?1?  

[__::tcl::transform::base64__ *chan*](#1)  

# <a name='description'></a>DESCRIPTION

The __tcl::transform::base64__ package provides a command creating a channel
transformation which base64 encodes data written to it, and decodes the data
read from it.

A related transformations in this module is __[tcl::transform::hex](hex.md)__.

The internal __[TclOO](../../../../index.md#tcloo)__ class implementing the
transform handler is a sub-class of the
__[tcl::transform::core](../virtchannel_core/transformcore.md)__ framework.

# <a name='section2'></a>API

  - <a name='1'></a>__::tcl::transform::base64__ *chan*

    This command creates a base64 transformation on top of the channel *chan*
    and returns its handle.

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

[base64](../../../../index.md#base64), [channel
transformation](../../../../index.md#channel_transformation), [reflected
channel](../../../../index.md#reflected_channel), [tip
230](../../../../index.md#tip_230), [tip 317](../../../../index.md#tip_317),
[transformation](../../../../index.md#transformation), [virtual
channel](../../../../index.md#virtual_channel)

# <a name='category'></a>CATEGORY

Channels

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
