
[//000000001]: # (textutil::split \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'textutil\_split\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::split\(n\) 0\.9 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::split \- Procedures to split texts

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
package require textutil::split ?0\.9?  

[__::textutil::split::splitn__ *string* ?*size*?](#1)  
[__::textutil::split::splitx__ *string* ?*regexp*?](#2)  

# <a name='description'></a>DESCRIPTION

The __textutil::split__ package provides commands that split strings into
substrings by size, or by regular expression\.

To split on a particular character or set of characters, use the built\-in
[split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html) command\. To
split a string into its individual characters, use the built\-in
[split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html) command with a
second argument of __""__\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::split::splitn__ *string* ?*size*?

    Returns a list of strings containing consecutive substrings of *string*,
    each *size* long—except for the last which will be shorter if *string*’s
    length is not an exact multiple of *size*\. The *size* defaults to
    __1__, i\.e\., return a list of *string*’s characters; this is the same
    as calling the built\-in
    [split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html) command with
    a second argument of __""__\.

    If *string* is empty, an empty list is returned\. If *size* *<= 0*, an
    error will be thrown\.

  - <a name='2'></a>__::textutil::split::splitx__ *string* ?*regexp*?

    Returns a list of strings containing consecutive substrings of *string*
    split according to the *regexp* regular expression which defaults to *\[\\t
    \\r\\n\]\+* \(tabs, spaces, newlines\)\.

    *Note*: If *regexp* contains capturing parentheses, then the captured
    groups will be included in the result list as additional elements\.

    If *string* is empty, an empty list is returned\. If *regexp* is empty,
    the *string* is split at every character; this is the same as calling the
    built\-in [split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html)
    command with a second argument of __""__\.

# <a name='section3'></a>Examples

The following examples show some of the __::textutil::split__ package’s
commands in action\.

To help make the examples’ effects more visible, each element of the returned
lists is bracketed using ❬ and ❭\. For non\-UTF\-8 aware editors these can be
replaced with __\\u276C__ and __\\u276D__\.

This first example shows how to split strings by size\.

    const LINE1 "α and ℤ"
    set chars [::textutil::split::splitn $LINE1] ;# splits into characters
    puts ❬[join $chars "❭ ❬"]❭
    set chars [split $LINE1 ""] ;# splits into characters
    puts ❬[join $chars "❭ ❬"]❭
    set chunks [::textutil::split::splitn $LINE1 3]
    puts ❬[join $chunks "❭ ❬"]❭
    =>
    ❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
    ❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
    ❬α a❭ ❬nd ❭ ❬ℤ❭

This second example shows how to split strings by regexp\.

    const LINE2 "a, be , cat, done , eagle"
    set chunks [::textutil::split::splitx $LINE2] ;# splits on [\t \r\n]+
    puts ❬[join $chunks "❭ ❬"]❭
    set chunks [::textutil::split::splitx $LINE2 {\s*,\s*}]
    puts ❬[join $chunks "❭ ❬"]❭
    set chunks [::textutil::split::splitx $LINE2 {\s*(,)\s*}]
    puts ❬[join $chunks "❭ ❬"]❭
    =>
    ❬a,❭ ❬be❭ ❬,❭ ❬cat,❭ ❬done❭ ❬,❭ ❬eagle❭
    ❬a❭ ❬be❭ ❬cat❭ ❬done❭ ❬eagle❭
    ❬a❭ ❬,❭ ❬be❭ ❬,❭ ❬cat❭ ❬,❭ ❬done❭ ❬,❭ ❬eagle❭

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

[regular expression](\.\./\.\./\.\./\.\./index\.md\#regular\_expression),
[split](\.\./\.\./\.\./\.\./index\.md\#split),
[string](\.\./\.\./\.\./\.\./index\.md\#string)

# <a name='category'></a>CATEGORY

Text processing
