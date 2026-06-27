
[//000000001]: # (textutil::string \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'textutil\_string\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::string\(n\) 0\.9 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::string \- Procedures to manipulate texts and strings\.

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
package require textutil::string ?0\.9?  

[__::textutil::string::chop__ *string*](#1)  
[__::textutil::string::tail__ *string*](#2)  
[__::textutil::string::cap__ *string*](#3)  
[__::textutil::string::capEachWord__ *string*](#4)  
[__::textutil::string::uncap__ *string*](#5)  
[__::textutil::string::longestCommonPrefixList__ *list*](#6)  
[__::textutil::string::longestCommonPrefix__ ?*string*\.\.\.?](#7)  

# <a name='description'></a>DESCRIPTION

The __textutil::string__ package provides miscellaneous string manipulation
commands\.

To see how to find a common path from a list of paths, see the last of the
[Examples](#section3)\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::string::chop__ *string*

    Returns a copy of *string* with the last character removed\.

  - <a name='2'></a>__::textutil::string::tail__ *string*

    Returns a copy of *string* with the first character removed\.

  - <a name='3'></a>__::textutil::string::cap__ *string*

    Returns a copy of *string* with the first character capitalized\.

  - <a name='4'></a>__::textutil::string::capEachWord__ *string*

    Returns a copy of *string* with the first character of every word
    capitalized\.

  - <a name='5'></a>__::textutil::string::uncap__ *string*

    Returns a copy of *string* with the first character lowercased\.

  - <a name='6'></a>__::textutil::string::longestCommonPrefixList__ *list*

    Returns the longest common prefix of the strings in the given *list*\.

    If no argument is given, the empty string is returned\.

  - <a name='7'></a>__::textutil::string::longestCommonPrefix__ ?*string*\.\.\.?

    Returns the longest common prefix of the string arguments, *string*, …\.

    If a single string is given, it is returned since it is its own longest
    common prefix\. If no argument is given, the empty string is returned\.

# <a name='section3'></a>Examples

The following examples show some of the __::textutil::string__ package’s
commands in action\.

This first example shows all the commands that work on a single string\.

    const LINE "has the σαβ cogs"
    puts "“$LINE” const"
    set line [::textutil::string::chop $LINE]
    puts "“$line” chop"
    set line [::textutil::string::tail $line]
    puts "“$line” tail"
    set line [::textutil::string::cap $line]
    puts "“$line” cap"
    set line [::textutil::string::capEachWord $line]
    puts "“$line” capEachWord"
    set line [::textutil::string::uncap $line]
    puts "“$line” uncap"
    =>
    “has the σαβ cogs” const
    “has the σαβ cog” chop
    “as the σαβ cog” tail
    “As the σαβ cog” cap
    “As The Σαβ Cog” capEachWord
    “as The Σαβ Cog” uncap

This example shows the longest common prefix commands in use\.

    const LIST [list handbag handcuff handful handle handy]
    puts “[::textutil::string::longestCommonPrefixList $LIST]”
    puts “[::textutil::string::longestCommonPrefix king queen knave]”
    puts “[::textutil::string::longestCommonPrefix king kin kind kinks]”
    =>
    “hand”
    “”
    “kin”

This example shows how to use the
__::textutil::string::longestCommonPrefixList__ command to find the common
path from a list of paths\.

    proc longestCommonPath paths {
        const SEP [file separator]
        set path [::textutil::string::longestCommonPrefixList $paths]
        if {[string index $path end] ne $SEP} {
            if {[set j [string last $SEP $path]] > -1} {
                set path [string range $path 0 $j-1]
            }
        }
        if {$path ne $SEP} { set path [string trimright $path $SEP] }
        return $path
    }

    const PATHS [list /home/sally/music /home/sally/museums /home/sally/musings]
    puts [::textutil::string::longestCommonPrefixList $PATHS]
    puts [longestCommonPath $PATHS]
    puts [longestCommonPath [list /bin / /sbin]]
    =>
    /home/sally/mus
    /home/sally
    /

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

[capitalize](\.\./\.\./\.\./\.\./index\.md\#capitalize),
[chop](\.\./\.\./\.\./\.\./index\.md\#chop), [common
prefix](\.\./\.\./\.\./\.\./index\.md\#common\_prefix),
[formatting](\.\./\.\./\.\./\.\./index\.md\#formatting),
[prefix](\.\./\.\./\.\./\.\./index\.md\#prefix),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[uncapitalize](\.\./\.\./\.\./\.\./index\.md\#uncapitalize)

# <a name='category'></a>CATEGORY

Text processing
