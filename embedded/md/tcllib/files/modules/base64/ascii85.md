
[//000000001]: # (ascii85 \- Text encoding & decoding binary data)
[//000000002]: # (Generated from file 'ascii85\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2010, Emiliano Gavilán)
[//000000004]: # (ascii85\(n\) 1\.1\.1 tcllib "Text encoding & decoding binary data")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

ascii85 \- ascii85\-encode/decode binary data

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [EXAMPLES](#section2)

  - [References](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require ascii85 ?1\.1?  

[__::ascii85::encode__ ?__\-maxlen__ *maxlen*? ?__\-wrapchar__ *wrapchar*? *bstring*](#1)  
[__::ascii85::decode__ *estring*](#2)  

# <a name='description'></a>DESCRIPTION

This package provides commands for encoding and decoding binary strings to and
from the ascii85 encoding\. \(This encoding is also known as base85\.\)

  - <a name='1'></a>__::ascii85::encode__ ?__\-maxlen__ *maxlen*? ?__\-wrapchar__ *wrapchar*? *bstring*

    Returns an ascii85\-encoded version of the binary string *bstring* as its
    result\.

    The result string contains the *wrapchar* character after every *maxlen*
    characters of output\. The *wrapchar* defaults to newline and *maxlen*
    defaults to 76\. To prevent wrapping, set *maxlen* to __0__\.

    The command will throw an error if *maxlen* is not an integer or is
    negative, or if *bstring* is neither a binary string, nor a string
    containing only 7\-bit ASCII\.

  - <a name='2'></a>__::ascii85::decode__ *estring*

    Returns a binary string that has been ascii85\-decoded from the *estring*\.
    Any whitespace \(spaces, tabs, newlines\) in *estring* is ignored\.

# <a name='section2'></a>EXAMPLES

This example shows how to encode and decode a Tcl string to and from ascii85,
taking account of the fact that the ascii85 commands work in terms of binary
strings\.

    const UTF8_LINE "Δ÷ “Utf-8” ♞ℤ"
    set bytes [encoding convertto utf-8 $UTF8_LINE]
    set enc85 [::ascii85::encode $bytes]
    set dec85 [::ascii85::decode $enc85]
    set line [encoding convertfrom utf-8 $dec85]
    puts "ascii85='$enc85' [expr {$UTF8_LINE eq $line}]"
    =>
    ascii85='cBQ5U+Q@pA<HMh)39#IZ+QAf\ie4*' 1

If the original string is 7\-bit ASCII the conversions to and from raw bytes
using the built\-in __[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding)__ command
are not needed\. For example:

    const ASCII_LINE "! 7-bit ASCII {~^}"
    set enc85 [::ascii85::encode $ASCII_LINE]
    set dec85 [::ascii85::decode $enc85]
    set line [encoding convertfrom utf-8 $dec85]
    puts "ascii85='$enc85' [expr {$ASCII_LINE eq $line}]"
    =>
    ascii85='+Wr]q@VKp,5uU-B8K`A/?@;' 1

Wrapping can be prevented so that no whitespace is introduced:

    ascii85::encode [string repeat xyz 24]
    =>
    G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G
    ^4U[H$X^\H?a^]
    ascii85::encode -maxlen 0 [string repeat xyz 24]
    =>
    G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]G^4U[H$X^\H?a^]

# <a name='section3'></a>References

  1. [http://en\.wikipedia\.org/wiki/Ascii85](http://en\.wikipedia\.org/wiki/Ascii85)

  1. Postscript Language Reference Manual, 3rd Edition, page 131\.
     [http://www\.adobe\.com/devnet/postscript/pdfs/PLRM\.pdf](http://www\.adobe\.com/devnet/postscript/pdfs/PLRM\.pdf)

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

[ascii85](\.\./\.\./\.\./\.\./index\.md\#ascii85),
[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding)

# <a name='category'></a>CATEGORY

Text processing

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2010, Emiliano Gavilán
