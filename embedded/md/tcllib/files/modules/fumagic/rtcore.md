
[//000000001]: # (fileutil::magic::rt \- file utilities)
[//000000002]: # (Generated from file 'rtcore\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (fileutil::magic::rt\(n\) 2\.0 tcllib "file utilities")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

fileutil::magic::rt \- Runtime core for file type recognition engines written in
pure Tcl

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [COMMANDS](#section2)

  - [NUMERIC TYPES](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5  
package require fileutil::magic::rt ?2\.0?  

[__::fileutil::magic::rt::>__](#1)  
[__::fileutil::magic::rt::<__](#2)  
[__::fileutil::magic::rt::open__ *filename*](#3)  
[__::fileutil::magic::rt::close__](#4)  
[__::fileutil::magic::rt::file\_start__ *name*](#5)  
[__::fileutil::magic::rt::result__ ?*msg*?](#6)  
[__::fileutil::magic::rt::resultv__ ?*msg*?](#7)  
[__::fileutil::magic::rt::emit__ *msg*](#8)  
[__::fileutil::magic::rt::offset__ *where*](#9)  
[__::fileutil::magic::rt::Nv__ *type* *offset* ?*qual*?](#10)  
[__::fileutil::magic::rt::N__ *type* *offset* *comp* *val* ?*qual*?](#11)  
[__::fileutil::magic::rt::Nvx__ *type* *offset* ?*qual*?](#12)  
[__::fileutil::magic::rt::Nx__ *type* *offset* *comp* *val* ?*qual*?](#13)  
[__::fileutil::magic::rt::S__ *offset* *comp* *val* ?*qual*?](#14)  
[__::fileutil::magic::rt::Sx__ *offset* *comp* *val* ?*qual*?](#15)  
[__::fileutil::magic::rt::L__ *newlevel*](#16)  
[__::fileutil::magic::rt::I__ *base* *type* *delta*](#17)  
[__::fileutil::magic::rt::R__ *offset*](#18)  
[__::fileutil::magic::rt::U__ *fileindex* *name*](#19)  

# <a name='description'></a>DESCRIPTION

This package provides the runtime core for file type recognition engines written
in pure Tcl and is thus used by all other packages in this module, i\.e\. the two
frontend packages __fileutil::magic::mimetypes__ and
__fileutil::magic::filetypes__, and the two engine compiler packages
__[fileutil::magic::cgen](cgen\.md)__ and
__[fileutil::magic::cfront](cfront\.md)__\.

# <a name='section2'></a>COMMANDS

  - <a name='1'></a>__::fileutil::magic::rt::>__

    Shorthand for __incr level__\.

  - <a name='2'></a>__::fileutil::magic::rt::<__

    Shorthand for __incr level \-1__\.

  - <a name='3'></a>__::fileutil::magic::rt::open__ *filename*

    This command initializes the runtime and prepares the file *filename* for
    use by the system\. This command has to be invoked first, before any other
    command of this package\.

    The command returns the channel handle of the opened file as its result\.

  - <a name='4'></a>__::fileutil::magic::rt::close__

    This command closes the last file opened via
    __::fileutil::magic::rt::open__ and shuts the runtime down\. This command
    has to be invoked last, after the file has been dealt with completely\.
    Afterward another invokation of __::fileutil::magic::rt::open__ is
    required to process another file\.

    This command returns the empty string as its result\.

  - <a name='5'></a>__::fileutil::magic::rt::file\_start__ *name*

    This command marks the start of a magic file when debugging\. It returns the
    empty string as its result\.

  - <a name='6'></a>__::fileutil::magic::rt::result__ ?*msg*?

    This command returns the current result and stops processing\.

    If *msg* is specified its text is added to the result before it is
    returned\. See __::fileutil::magic::rt::emit__ for the allowed special
    character sequences\.

  - <a name='7'></a>__::fileutil::magic::rt::resultv__ ?*msg*?

    This command returns the current result\. In contrast to
    __::fileutil::magic::rt::result__ processing continues\.

    If *msg* is specified its text is added to the result before it is
    returned\. See __::fileutil::magic::rt::emit__ for the allowed special
    character sequences\.

  - <a name='8'></a>__::fileutil::magic::rt::emit__ *msg*

    This command adds the text *msg* to the result buffer\. The message may
    contain the following special character sequences\. They will be replaced
    with buffered values before the message is added to the result\. The command
    returns the empty string as its result\.

      * __\\b__

        This sequence is removed

      * __%s__

        Replaced with the last buffered string value\.

      * __%ld__

        Replaced with the last buffered numeric value\.

      * __%d__

        See above\.

  - <a name='9'></a>__::fileutil::magic::rt::offset__ *where*

  - <a name='10'></a>__::fileutil::magic::rt::Nv__ *type* *offset* ?*qual*?

    This command fetches the numeric value with *type* from the absolute
    location *offset* and returns it as its result\. The fetched value is
    further stored in the numeric buffer\.

    If *qual* is specified it is considered to be a mask and applied to the
    fetched value before it is stored and returned\. It has to have the form of a
    partial Tcl bit\-wise expression, i\.e\.

        & number

    For example:

        Nv lelong 0 &0x8080ffff

    For the possible types see section [NUMERIC TYPES](#section3)\.

  - <a name='11'></a>__::fileutil::magic::rt::N__ *type* *offset* *comp* *val* ?*qual*?

    This command behaves mostly like __::fileutil::magic::rt::Nv__, except
    that it compares the fetched and masked value against *val* as specified
    with *comp* and returns the result of that comparison\.

    The argument *comp* has to contain one of Tcl's comparison operators, and
    the comparison made will be

        <val> <comp> <fetched-and-masked-value>

    The special comparison operator __x__ signals that no comparison should
    be done, or, in other words, that the fetched value will always match
    *val*\.

  - <a name='12'></a>__::fileutil::magic::rt::Nvx__ *type* *offset* ?*qual*?

    This command behaves like __::fileutil::magic::rt::Nv__, except that it
    additionally remembers the location in the file after the fetch in the
    calling context, for the current level, for later use by
    __::fileutil::magic::rt::R__\.

  - <a name='13'></a>__::fileutil::magic::rt::Nx__ *type* *offset* *comp* *val* ?*qual*?

    This command behaves like __::fileutil::magic::rt::N__, except that it
    additionally remembers the location in the file after the fetch in the
    calling context, for the current, for later use by
    __::fileutil::magic::rt::R__\.

  - <a name='14'></a>__::fileutil::magic::rt::S__ *offset* *comp* *val* ?*qual*?

    This command behaves like __::fileutil::magic::rt::N__, except that it
    fetches and compares strings, not numeric data\. The fetched value is also
    stored in the internal string buffer instead of the numeric buffer\.

  - <a name='15'></a>__::fileutil::magic::rt::Sx__ *offset* *comp* *val* ?*qual*?

    This command behaves like __::fileutil::magic::rt::S__, except that it
    additionally remembers the location in the file after the fetch in the
    calling context, for the current level, for later use by
    __::fileutil::magic::rt::R__\.

  - <a name='16'></a>__::fileutil::magic::rt::L__ *newlevel*

    This command sets the current level in the calling context to *newlevel*\.
    The command returns the empty string as its result\.

  - <a name='17'></a>__::fileutil::magic::rt::I__ *base* *type* *delta*

    This command handles base locations specified indirectly through the
    contents of the inspected file\. It returns the sum of *delta* and the
    value of numeric *type* fetched from the absolute location *base*\.

    For the possible types see section [NUMERIC TYPES](#section3)\.

  - <a name='18'></a>__::fileutil::magic::rt::R__ *offset*

    This command handles base locations specified relative to the end of the
    last field one level above\.

    In other words, the command computes an absolute location in the file based
    on the relative *offset* and returns it as its result\. The base the offset
    is added to is the last location remembered for the level in the calling
    context\.

  - <a name='19'></a>__::fileutil::magic::rt::U__ *fileindex* *name*

    Use a named test script at the current level\.

# <a name='section3'></a>NUMERIC TYPES

  - __byte__

    8\-bit integer

  - __short__

    16\-bit integer, stored in native endianess

  - __beshort__

    see above, stored in big endian

  - __leshort__

    see above, stored in small/little endian

  - __long__

    32\-bit integer, stored in native endianess

  - __belong__

    see above, stored in big endian

  - __lelong__

    see above, stored in small/little endian

All of the types above exit in an unsigned form as well\. The type names are the
same, with the character "u" added as prefix\.

  - __date__

    32\-bit integer timestamp, stored in native endianess

  - __bedate__

    see above, stored in big endian

  - __ledate__

    see above, stored in small/little endian

  - __ldate__

    32\-bit integer timestamp, stored in native endianess

  - __beldate__

    see above, stored in big endian

  - __leldate__

    see above, stored in small/little endian

# <a name='section4'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *fileutil :: magic* of the
[Tcllib Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report
any ideas for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

file\(1\), [fileutil](\.\./fileutil/fileutil\.md), magic\(5\)

# <a name='keywords'></a>KEYWORDS

[file recognition](\.\./\.\./\.\./\.\./index\.md\#file\_recognition), [file
type](\.\./\.\./\.\./\.\./index\.md\#file\_type), [file
utilities](\.\./\.\./\.\./\.\./index\.md\#file\_utilities),
[mime](\.\./\.\./\.\./\.\./index\.md\#mime), [type](\.\./\.\./\.\./\.\./index\.md\#type)

# <a name='category'></a>CATEGORY

Programming tools
