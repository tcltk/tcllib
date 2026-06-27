
[//000000001]: # (yencode \- Text encoding & decoding binary data)
[//000000002]: # (Generated from file 'yencode\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2002, Pat Thoyts)
[//000000004]: # (yencode\(n\) 1\.1\.4 tcllib "Text encoding & decoding binary data")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

yencode \- Y\-encode/decode binary data

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

      - [Options](#subsection1)

  - [Examples](#section2)

  - [References](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require yencode ?1\.1\.4?  

[__::yencode::encode__ *bstring*](#1)  
[__::yencode::decode__ *estring*](#2)  
[__::yencode::yencode__ ?__\-name__ *string*? ?__\-line__ *integer*? ?__\-crc32__ *boolean*? \(__\-file__ *filename* &#124; ?__\-\-__? *bstring*\)](#3)  
[__::yencode::ydecode__ \(__\-file__ *filename* &#124; ?__\-\-__? *estring*\)](#4)  

# <a name='description'></a>DESCRIPTION

This package provides a Tcl\-only implementation of the yEncode file encoding
used for Usenet messages\. This encoding packs binary data into a format that
requires an 8\-bit clean transmission layer but that escapes characters special
to the *[NNTP](\.\./\.\./\.\./\.\./index\.md\#nntp)* posting protocols\. See
[http://www\.yenc\.org](http://www\.yenc\.org) for the encoding’s details\.

  - <a name='1'></a>__::yencode::encode__ *bstring*

    Returns a yEncoded version of the binary string *bstring* as its result\.

    The command will throw an error if *bstring* is neither a binary string,
    nor a string containing only 7\-bit ASCII\.

  - <a name='2'></a>__::yencode::decode__ *estring*

    Returns a binary string that has been yEncode\-decoded from the *estring*\.

  - <a name='3'></a>__::yencode::yencode__ ?__\-name__ *string*? ?__\-line__ *integer*? ?__\-crc32__ *boolean*? \(__\-file__ *filename* &#124; ?__\-\-__? *bstring*\)

    Returns a wrapped yEncoded version of the data in the file specified by
    __\-file__ *filename* or by the binary string *bstring* as its
    result\.

    Each wrapped yEncoded result consists of a header, body, and trailer\. The
    header is a line starting with __=ybegin__ followed by a line length of
    form __line=__*length*, the size of the original data \(in bytes\) of
    form __size=__*size*, and the name of the original file of form
    __name=__*filename*, all space\-separated\. The body is the yEncoded
    data\. The trailer is a line starting with __=yend__ followed by the size
    of the original data of form __size=__*size*, and optionally \(but
    recommended\), a CRC32 checksum value of form __crc32=__*checksum*, all
    space\-separated\.

  - <a name='4'></a>__::yencode::ydecode__ \(__\-file__ *filename* &#124; ?__\-\-__? *estring*\)

    Returns a list of 3\-element lists of filename, file size, yEncode\-decoded
    bytes, from the file specified by __\-file__ *filename* or from the
    *estring*\.

## <a name='subsection1'></a>Options

  - __\-file__ *filename*

    Cause the __yencode__ or
    __[ydecode](\.\./\.\./\.\./\.\./index\.md\#ydecode)__ commands to read their
    data from the named file rather that taking a binary string parameter\.

  - __\-name__ *string*

    The yEncoded data header line contains the original file name to be used
    when unpacking the data\. Use this option to change this from the default of
    "default\.bin"\.

  - __\-line__ *integer*

    The yEncoded header line specifies the line length used for the encoding,
    and which defaults to 128\. Use this option to set a different line length\.
    Note that NNTP imposes a 1000 character line length limit and some systems
    may have trouble with more than 255 characters per line\.

  - __\-crc32__ *boolean*

    When encoding this package puts a cyclic redundancy check \(CRC\) value in the
    trailer as recommended in the yEncode specification\. This can be prevented
    by using this option and passing a false value for *boolean*, e\.g\.,
    __0__\.

# <a name='section2'></a>Examples

*The yEncoded data is not shown in the examples because it is just* *raw
bytes\.*

This example shows how to yEncode and yEncode\-decode a Tcl string, taking
account of the fact that the yEncode commands work in terms of binary strings\.

    const UTF8_LINE "Δ÷ “Utf-8” ♞ℤ"
    set bytes [encoding convertto utf-8 $UTF8_LINE]
    set ency [::yencode::encode $bytes]
    set decy [::yencode::decode $ency]
    set line [encoding convertfrom utf-8 $decy]
    puts "[expr {$UTF8_LINE eq $line}]"
    =>
    1

If the original string is 7\-bit ASCII the conversions to and from raw bytes
using the built\-in __[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding)__ command
are not needed\. For example:

    const ASCII_LINE "! 7-bit ASCII {~^}"
    set ency [::yencode::encode $ASCII_LINE]
    set decy [::yencode::decode $ency]
    set line [encoding convertfrom utf-8 $decy]
    puts "[expr {$ASCII_LINE eq $line}]"
    =>
    1

This example shows how to create a yEncoded byte string and write it to a file\.

    set bytes [encoding convertto utf-8 $UTF8_LINE]
    set ency [::yencode::yencode -name test.y $bytes]
    writeFile test.y binary $ency
    puts $ency
    =>
    =ybegin line=128 size=23 name=test.y
        … raw binary data elided …
    =yend size=23 crc32=fc01071

This example shows how to read a file containing one or more yEncoded files\.

    foreach lst [::yencode::ydecode $ency] {
        lassign $lst name size decy
        set line [encoding convertfrom utf-8 $decy]
        puts "name=$name size=$size line='$line'"
    }
    =>
    name=test.y size=23 line='Δ÷ “Utf-8” ♞ℤ'

# <a name='section3'></a>References

  1. [http://www\.yenc\.org/yenc\-draft\.1\.3\.txt](http://www\.yenc\.org/yenc\-draft\.1\.3\.txt)

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *base64* as the
category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding),
[yEnc](\.\./\.\./\.\./\.\./index\.md\#yenc),
[ydecode](\.\./\.\./\.\./\.\./index\.md\#ydecode),
[yencode](\.\./\.\./\.\./\.\./index\.md\#yencode)

# <a name='category'></a>CATEGORY

Text processing

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2002, Pat Thoyts
