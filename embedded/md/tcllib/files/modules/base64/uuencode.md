
[//000000001]: # (uuencode \- Text encoding & decoding binary data)
[//000000002]: # (Generated from file 'uuencode\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2002, Pat Thoyts)
[//000000004]: # (uuencode\(n\) 1\.1\.6 tcllib "Text encoding & decoding binary data")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

uuencode \- UU\-encode/decode binary data

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

      - [Options](#subsection1)

  - [Examples](#section2)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require uuencode ?1\.1\.6?  

[__::uuencode::encode__ *bstring*](#1)  
[__::uuencode::decode__ *estring*](#2)  
[__::uuencode::uuencode__ ?__\-name__ *string*? ?__\-mode__ *octal*? \(__\-file__ *filename* &#124;  ?__\-\-__? *bstring*\)](#3)  
[__::uuencode::uudecode__ \(__\-file__ *filename* &#124;  ?__\-\-__? *estring*\)](#4)  

# <a name='description'></a>DESCRIPTION

This package provides a Tcl\-only implementation of the
[__uuencode\(1p\)__](https://www\.man7\.org/linux/man\-pages/man1/uuencode\.1p\.html)
and
[__uudecode\(1p\)__](https://www\.man7\.org/linux/man\-pages/man1/uudecode\.1p\.html)
commands\. This encoding packs binary data into printable 7\-bit ASCII characters\.

  - <a name='1'></a>__::uuencode::encode__ *bstring*

    Returns a uuencoded version of the binary string *bstring* as its result\.

    All the given bytes are encoded even if they exceed the uuencode maximum
    line length\. If the number of input bytes is not a multiple of 3 then the
    string is padded with additional __\\x00__ NUL bytes\.

    The command will throw an error if *bstring* is neither a binary string,
    nor a string containing only 7\-bit ASCII\.

  - <a name='2'></a>__::uuencode::decode__ *estring*

    Returns a binary string that has been uuencode\-decoded from the *estring*,
    including any padding __\\x00__ NUL bytes at the end\.

  - <a name='3'></a>__::uuencode::uuencode__ ?__\-name__ *string*? ?__\-mode__ *octal*? \(__\-file__ *filename* &#124;  ?__\-\-__? *bstring*\)

    Returns a wrapped uuencoded version of the data in the file specified by
    __\-file__ *filename* or by the binary string *bstring* as its
    result\.

    Each wrapped uuencoded result consists of a header, body, and footer\. The
    header is a line starting with __begin__ followed by a suggested file
    mode and suggested filename\. The body consists of lines of uuencoded data,
    each prefixed with a line length character\. The footer is __end__ on its
    own line\. See
    [__uuencode\(1\)__](https://www\.man7\.org/linux/man\-pages/man1/uuencode\.1p\.html)\.

  - <a name='4'></a>__::uuencode::uudecode__ \(__\-file__ *filename* &#124;  ?__\-\-__? *estring*\)

    Returns a list of 3\-element lists of filename, file mode, uuencode\-decoded
    bytes, from the file specified by __\-file__ *filename* or from the
    *estring*\.

## <a name='subsection1'></a>Options

  - __\-file__ *filename*

    Cause the __uuencode__ or __uudecode__ commands to read their data
    from the named file rather that taking a binary string parameter\.

  - __\-name__ *string*

    The uuencoded data header line contains the suggested file name to be used
    when unpacking the data\. Use this option to change this from the default of
    "data\.dat"\.

  - __\-mode__ *octal*

    The uuencoded data header line contains a suggested permissions bit pattern
    expressed as an octal string\. To change the default of 0644 you can set this
    option\. For instance, 0755 would be suitable for an executable\. See
    [__chmod\(1\)__](https://www\.man7\.org/linux/man\-pages/man1/chmod\.1\.html)\.

# <a name='section2'></a>Examples

The examples use the subcommand __string trimright__ to trim any
__\\x00__ NUL bytes that may have been added during encoding\. *Note however,
that if the original binary strings might end* *with* __\\x00__ NUL
*bytes, a more sophisticated approach* *will be needed\.*

This example shows how to uuencode and uudecode a Tcl string, taking account of
the fact that the uuencode commands work in terms of binary strings\.

    const UTF8_LINE "Δ÷ “Utf-8” ♞ℤ"
    set bytes [encoding convertto utf-8 $UTF8_LINE]
    set encuu [::uuencode::encode $bytes]
    set decuu [string trimright [::uuencode::decode $encuu] \x00]
    set line [encoding convertfrom utf-8 $decuu]
    puts "uuencode='$encuu' [expr {$UTF8_LINE eq $line}]"
    =>
    uuencode='SI3#MR#B@)Q5=&8M..*`G2#BF9[BA*0`' 1

If the original string is 7\-bit ASCII the conversions to and from raw bytes
using the built\-in __[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding)__ command
are not needed\. For example:

    const ASCII_LINE "! 7-bit ASCII {~^}"
    set encuu [::uuencode::encode $ASCII_LINE]
    set decuu [string trimright [::uuencode::decode $encuu] \x00]
    set line [encoding convertfrom utf-8 $decuu]
    puts "uuencode='$encuu' [expr {$ASCII_LINE eq $line}]"
    =>
    uuencode='(2`W+6)I="!!4T-)22![?EY]' 1

This example shows how to create a uuencoded byte string and write it to a file\.

    const UTF8_LINE "Δ÷ “Utf-8” ♞ℤ"
    set bytes [encoding convertto utf-8 $UTF8_LINE]
    set encuu [::uuencode::uuencode -name test.uu $bytes]
    writeFile test.uu binary $encuu
    puts $encuu
    =>
    begin 644 test.uu
    7SI3#MR#B@)Q5=&8M..*`G2#BF9[BA*0`
    `
    end

This example shows how to read a file containing one or more uuencoded files\.

    foreach lst [::uuencode::uudecode -file test.uu] {
        lassign $lst name mode decuu
        set decuu [string trimright $decuu \x00]
        set line [encoding convertfrom utf-8 $decuu]
        puts "name=$name mode=$mode line='$line'"
    }
    =>
    name=test.uu mode=644 line='Δ÷ “Utf-8” ♞ℤ'

# <a name='section3'></a>Bugs, Ideas, Feedback

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
[uuencode](\.\./\.\./\.\./\.\./index\.md\#uuencode)

# <a name='category'></a>CATEGORY

Text processing

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2002, Pat Thoyts
