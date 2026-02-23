
[//000000001]: # (textutil::tabify \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'tabify\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::tabify\(n\) 0\.8 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::tabify \- Procedures to \(un\)tabify strings

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
package require textutil::tabify ?0\.8?  

[__::textutil::tabify::tabify__ *string* ?*count*?](#1)  
[__::textutil::tabify::tabify2__ *string* ?*count*?](#2)  
[__::textutil::tabify::untabify__ *string* ?*count*?](#3)  
[__::textutil::tabify::untabify2__ *string* ?*count*?](#4)  

# <a name='description'></a>DESCRIPTION

The __textutil::tabify__ package provides commands for converting tabs to
spaces or spaces to tabs in strings\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::tabify::tabify__ *string* ?*count*?

    Returns a copy of *string* with any substring of *count* space
    characters replaced by a horizontal tab\. The *count* defaults to 8\.

  - <a name='2'></a>__::textutil::tabify::tabify2__ *string* ?*count*?

    Returns a copy of *string* with substrings of *count* *or fewer* space
    characters replaced by a horizontal tab using a text editor like algorithm\.
    The *count* defaults to 8\.

    The algorithm used by this command treats each line in *string* as if it
    had notional tabstops every *count* columns\. \(So, if *count* is
    __8__, at columns __8__, __16__, __24__, …\.\) Only sequences
    of *two or more* space characters that occur immediately before a notional
    tabstop are replaced with a tab\.

  - <a name='3'></a>__::textutil::tabify::untabify__ *string* ?*count*?

    Returns a copy of *string* with every horizontal tab replaced by *count*
    spaces\. The *count* defaults to 8\.

  - <a name='4'></a>__::textutil::tabify::untabify2__ *string* ?*count*?

    Returns a copy of *string* with horizontal tabs replaced by *count* *or
    fewer* space characters using a text editor like algorithm\. The *count*
    defaults to 8\.

    This command is the counterpart to __::textutil::tabify::tabify2__\. The
    algorithm used by this command treats each line in *string* as if it had
    notional tabstops every *count* columns\. \(So, if *count* is __8__,
    at columns __8__, __16__, __24__, …\.\) Instead of blindly
    replacing each horizontal tab with *count* spaces, each horizontal tab at
    a notional tabstop is replaced by enough spaces to reach the next notional
    tabstop\.

    There is one asymmetry though: A tab may be replaced by a single space, but
    not the other way around\.

# <a name='section3'></a>Examples

The following examples show some of the __::textutil::tabify__ package’s
commands in action\.

The examples make use of a tiny helper command to make spaces and tabs distinct
and visible:

    proc replace_tab_spc s { regsub -all { } [regsub -all \t $s →] ▴ }

This example shows the __::textutil::tabify::tabify__ command in action\.

    const LINES1 "    if \{\$x\} \{\n        puts 1\n    \}"
    puts "=== original ===\n[replace_tab_spc $LINES1]\n"
    set tabbed [::textutil::tabify::tabify $LINES1]
    puts "=== 8spc→tab ===\n[replace_tab_spc $tabbed]\n"
    set tabbed [::textutil::tabify::tabify $LINES1 4]
    puts "=== 4spc→tab ===\n[replace_tab_spc $tabbed]\n"
    =>
    === original ===
    ▴▴▴▴if▴{$x}▴{
    ▴▴▴▴▴▴▴▴puts▴1
    ▴▴▴▴}

    === 8spc→tab ===
    ▴▴▴▴if▴{$x}▴{
    →puts▴1
    ▴▴▴▴}

    === 4spc→tab ===
    →if▴{$x}▴{
    →→puts▴1
    →}

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

[formatting](\.\./\.\./\.\./\.\./index\.md\#formatting),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[tabstops](\.\./\.\./\.\./\.\./index\.md\#tabstops)

# <a name='category'></a>CATEGORY

Text processing
