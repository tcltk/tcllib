
[//000000001]: # (textutil::wcswidth \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'wcswidth\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::wcswidth\(n\) 35\.3 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::wcswidth \- Procedures to compute terminal width of strings

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Examples](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require textutil::wcswidth ?35\.3?  

[__::textutil::wcswidth__ *string*](#1)  
[__::textutil::wcswidth\_char__ *codepoint*](#2)  
[__::textutil::wcswidth\_type__ *codepoint*](#3)  

# <a name='description'></a>DESCRIPTION

The __textutil::wcswidth__ package provides commands that report character
types, character widths, and string widths, in the context of terminal \(console\)
output\.

This package’s data, and therefore its underlying the functionality, is based on
the Unicode database file
[http://www\.unicode\.org/Public/UCD/latest/ucd/EastAsianWidth\.txt](http://www\.unicode\.org/Public/UCD/latest/ucd/EastAsianWidth\.txt)\.

# <a name='section2'></a>API

This package’s commands account for double\-width characters from the various
Asian and other scripts\.

  - <a name='1'></a>__::textutil::wcswidth__ *string*

    Returns the number of character cells needed by the given *string* when
    output to a terminal\.

  - <a name='2'></a>__::textutil::wcswidth\_char__ *codepoint*

    Returns the number of character cells needed by the given *codepoint*
    Unicode character when output to a terminal\.

    *Important*: The *codepoint* Unicode character must be specified as an
    integer\.

  - <a name='3'></a>__::textutil::wcswidth\_type__ *codepoint*

    Returns the character type of the specified *codepoint* Unicode character\.

    The returned value is a string containing one of the following constants:
    __A__, __F__, __H__, __N__, __Na__, or __W__, as
    specified in
    [http://www\.unicode\.org/Public/UCD/latest/ucd/EastAsianWidth\.txt](http://www\.unicode\.org/Public/UCD/latest/ucd/EastAsianWidth\.txt)\.

    *Important*: The *codepoint* Unicode character must be specified as an
    integer\.

# <a name='section3'></a>Examples

This example shows all three commands in action\.

    const LINE "Δ÷☕M☔ℤ"
    puts "string length  = [string length $LINE]"
    puts "terminal width = [textutil::wcswidth $LINE]"
    foreach char [split $LINE ""] {
        set cp [scan $char %c]
        set pad [string repeat " " [expr {2 - [textutil::wcswidth_char $cp]}]]
        puts [format "%-2s%sU+%04X %s" $char $pad $cp [textutil::wcswidth_type $cp]]
    }
    =>
    string length  = 6
    terminal width = 8
    Δ  U+0394 A
    ÷  U+00F7 A
    ☕ U+2615 W
    M  U+004D N
    ☔ U+2614 W
    ℤ  U+2124 N

On a terminal using a monospaced font, the output shown above lines up
*perfectly*; any “wobble” seen on this page is an artifact\.

Note that if __pad__ was set to __" "__, i\.e\., taking no account of the
character widths, the output would *not* line up, e\.g\.:

    string length  = 6
    terminal width = 8
    Δ  U+0394 A
    ÷  U+00F7 A
    ☕  U+2615 W
    M  U+004D N
    ☔  U+2614 W
    ℤ  U+2124 N

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *textutil* as
the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

regexp\(n\), split\(n\), string\(n\)

# <a name='keywords'></a>KEYWORDS

[character type](\.\./\.\./\.\./\.\./index\.md\#character\_type), [character
width](\.\./\.\./\.\./\.\./index\.md\#character\_width), [double\-wide
character](\.\./\.\./\.\./\.\./index\.md\#double\_wide\_character),
[prefix](\.\./\.\./\.\./\.\./index\.md\#prefix), [regular
expression](\.\./\.\./\.\./\.\./index\.md\#regular\_expression),
[string](\.\./\.\./\.\./\.\./index\.md\#string)

# <a name='category'></a>CATEGORY

Text processing
