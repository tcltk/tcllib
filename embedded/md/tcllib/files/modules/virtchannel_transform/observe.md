
[//000000001]: # (tcl::transform::observe - Reflected/virtual channel support)
[//000000002]: # (Generated from file 'observe.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcl::transform::observe(n) 1 tcllib "Reflected/virtual channel support")

# NAME

tcl::transform::observe - Observer transformation, stream copy

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
package require tcl::transform::observe ?1?  

[__::tcl::transform::observe__ *chan* *logw* *logr*](#1)  

# <a name='description'></a>DESCRIPTION

The __tcl::transform::observer__ package provides a command creating a channel
transformation which passes the read and written bytes through unchanged (like
__[tcl::transform::identity](identity.md)__), but additionally copies the data
it has seen for each direction into channels specified at construction time.

Related transformations in this module are
__[tcl::transform::adler32](adler32.md)__,
__[tcl::transform::counter](vt_counter.md)__,
__[tcl::transform::crc32](vt_crc32.md)__, and
__[tcl::transform::identity](identity.md)__.

The internal __[TclOO](../../../../index.md#tcloo)__ class implementing the
transform handler is a sub-class of the
__[tcl::transform::core](../virtchannel_core/transformcore.md)__ framework.

# <a name='section2'></a>API

  - <a name='1'></a>__::tcl::transform::observe__ *chan* *logw* *logr*

    This command creates an observer transformation on top of the channel *chan*
    and returns its handle. The channel handles *logr* and *logw* are there the
    data is copied to.

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

[channel transformation](../../../../index.md#channel_transformation),
[observer](../../../../index.md#observer), [reflected
channel](../../../../index.md#reflected_channel), [stream
copy](../../../../index.md#stream_copy), [tip
230](../../../../index.md#tip_230),
[transformation](../../../../index.md#transformation), [virtual
channel](../../../../index.md#virtual_channel)

# <a name='category'></a>CATEGORY

Channels

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
