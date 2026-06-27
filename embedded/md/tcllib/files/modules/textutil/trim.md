
[//000000001]: # (textutil::trim \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'trim\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::trim\(n\) 0\.8 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::trim \- Procedures to trim strings

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
package require textutil::trim ?0\.8?  

[__::textutil::trim::trim__ *string* ?*regexp*?](#1)  
[__::textutil::trim::trimleft__ *string* ?*regexp*?](#2)  
[__::textutil::trim::trimright__ *string* ?*regexp*?](#3)  
[__::textutil::trim::trimPrefix__ *string* *prefix*](#4)  
[__::textutil::trim::trimEmptyHeading__ *string*](#5)  

# <a name='description'></a>DESCRIPTION

The __textutil::trim__ package provides commands that trim strings in
various ways, including using arbitrary regular expressions\.

To trim strings of sets of characters \(such as whitespace\), use the built\-in
[string](https://www\.tcl\-lang\.org/man/tcl/TclCmd/string\.html) command’s
__trim__, __trimleft__, __trimright__ subcommands\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::trim::trim__ *string* ?*regexp*?

    Returns a copy of *string* with any leading or trailing substring that
    matches *regexp* removed from the *string* if does not contain newlines,
    or from *every line* within the *string* if it contains newlines\. The
    *regexp* defaults to *\[ \\t\]\+*\. This default will remove leading and
    trailing spaces and tabs from the *string* if it does not contain
    newlines, or from *every line* within the *string* if it contains
    newlines\.

  - <a name='2'></a>__::textutil::trim::trimleft__ *string* ?*regexp*?

    Returns a copy of *string* with any leading substring that matches
    *regexp* removed from the *string* if does not contain newlines, or from
    *every line* within the *string* if it contains newlines\. The *regexp*
    defaults to *\[ \\t\]\+*\. This default will remove leading spaces and tabs
    from the *string* if it does not contain newlines, or from *every line*
    within the *string* if it contains newlines\.

  - <a name='3'></a>__::textutil::trim::trimright__ *string* ?*regexp*?

    Returns a copy of *string* with any trailing substring that matches
    *regexp* removed from the *string* if does not contain newlines, or from
    *every line* within the *string* if it contains newlines\. The *regexp*
    defaults to *\[ \\t\]\+*\. This default will remove trailing spaces and tabs
    from the *string* if it does not contain newlines, or from *every line*
    within the *string* if it contains newlines\.

  - <a name='4'></a>__::textutil::trim::trimPrefix__ *string* *prefix*

    Returns a copy of *string* with *prefix* removed from the start if it is
    present; otherwise returns *string* unchanged\.

    Contrast this command with the built\-in
    [string](https://www\.tcl\-lang\.org/man/tcl/TclCmd/string\.html) command’s
    __trim__, __trimleft__, __trimright__ subcommands which remove
    all characters in a given set of characters passed as a string\.

  - <a name='5'></a>__::textutil::trim::trimEmptyHeading__ *string*

    Returns a copy of *string* with any leading blank lines \(including lines
    containing only whitespace\) removed\.

# <a name='section3'></a>Examples

The following examples show some of the __::textutil::trim__ package’s
commands in action\.

The following __[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ is used by some of
the examples below\.

    proc replace_ws s { regsub -all { } [regsub -all \t [regsub -all \n $s ⏎] →] ▴ }

This example shows the use of __::textutil::trim::trimEmptyHeading__ and
__::textutil::trim::trim__\.

    const LINES1 "\t\n Alpha\t\n Beta \t\n Gamma \t\n"
    puts "== const =============================\n[replace_ws $LINES1]"
    set line [::textutil::trim::trimEmptyHeading $LINES1]
    puts "== textutil::trim::trimEmptyHeading ==\n[replace_ws $line]"
    set line [string trimleft $LINES1]
    puts "== string trimleft ===================\n[replace_ws $line]"
    set line [::textutil::trim::trim $LINES1]
    puts "== textutil::trim::trim ==============\n[replace_ws $line]"
    =>
    == const =============================
    →⏎▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == textutil::trim::trimEmptyHeading ==
    ▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == string trimleft ===================
    Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == textutil::trim::trim ==============
    ⏎Alpha⏎Beta⏎Gamma⏎

Notice the subtle difference in behavior between
__::textutil::trim::trimEmptyHeading__ and __string trimleft__\.

This example shows the use of the built\-in __string trim__ in combination
with and __::textutil::trim::trim__\.

    const LINES2 [string trim "\t\n Delta\t\n Epsilon \t\n Zeta \t\n"]
    puts "== const =============================\n[replace_ws $LINES2]"
    set line [::textutil::trim::trim $LINES2]
    puts "== textutil::trim::trim ==============\n[replace_ws $line]"
    =>
    == const =============================
    Delta→⏎▴Epsilon▴→⏎▴Zeta
    == textutil::trim::trim ==============
    Delta⏎Epsilon⏎Zeta

This example contrasts the built\-in __string trim__ with
__::textutil::trim::trimPrefix__\.

    const PATH /home/homer
    puts "const='$PATH'"
    puts "string trim \$PATH /home='[string trim $PATH /home]'"
    puts "string trim \$PATH /home='[string trim $PATH ehmo/]'"
    puts "::textutil::trim::trimPrefix \$PATH /home='[::textutil::trim::trimPrefix $PATH /home]'"
    const LINE mimic
    puts "string trim \$LINE mic='[string trim $LINE mic]'"
    puts "::textutil::trim::trimPrefix \$LINE mic='[::textutil::trim::trimPrefix $LINE mic]'"
    =>
    const='/home/homer'
    string trim $PATH /home='r'
    string trim $PATH /home='r'
    ::textutil::trim::trimPrefix $PATH /home='/homer'
    string trim $LINE mic=''
    ::textutil::trim::trimPrefix $LINE mic='mimic'

For the __PATH__ examples, the __string trim__ command trims all the
individual characters that are in the string "/home", i\.e\., "/", "h", "o", "m",
"e"\. The order of the characters in the string don’t matter as the "ehmo/"
example shows\. Compare this with __::textutil::trim::trimPrefix__ which
trims the literal string "/home"\.

For the __LINE__ examples, the __string trim__ command trims all the
individual characters that are in the string "mic", i\.e\., "m", "i", "c"\. Compare
this with __::textutil::trim::trimPrefix__ which trims the literal string
"mic"; but since the __LINE__ doesn’t start with "mic", nothing is trimmed
and the string is returned unchanged\.

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

[prefix](\.\./\.\./\.\./\.\./index\.md\#prefix), [regular
expression](\.\./\.\./\.\./\.\./index\.md\#regular\_expression),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[trimming](\.\./\.\./\.\./\.\./index\.md\#trimming)

# <a name='category'></a>CATEGORY

Text processing
