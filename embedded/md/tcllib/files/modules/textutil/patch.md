
[//000000001]: # (textutil::patch \- Text and string utilities)
[//000000002]: # (Generated from file 'patch\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::patch\(n\) 0\.2 tcllib "Text and string utilities")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::patch \- Application of uni\-diff patches to directory trees

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require textutil::patch ?0\.2?  

[__::textutil::patch::apply__ *basedirectory* *striplevel* *patch* *reportcmd*](#1)  
[__\{\*\}reportcmd__ __apply__ *filename*](#2)  
[__\{\*\}reportcmd__ __fail__ *filename* *hunk* *expected* *seen*](#3)  
[__\{\*\}reportcmd__ __fail\-already__ *filename* *hunk*](#4)  

# <a name='description'></a>DESCRIPTION

This package provides a single command which applies a patch in [unified diff
format](https://www\.gnu\.org/software/diffutils/manual/html\_node/Detailed\-Unified\.html)
to the files in a directory tree\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::patch::apply__ *basedirectory* *striplevel* *patch* *reportcmd*

    Applies the *patch* \(i\.e\., the text of the actual patch, not a filename\)
    to the files in the *basedirectory* using the specified *striplevel*,
    and reports actions with calls to the command prefix *reportcmd*\. Returns
    an empty string\.

    The *striplevel* argument is equivalent to the
    [patch](https://www\.man7\.org/linux/man\-pages/man1/patch\.1\.html)
    command’s __\-p__ \(or __\-\-strip__\) option with a value of
    *striplevel*\.

    Throws an error if *patch* cannot be parsed, or if nothing is done to the
    files in *basedirectory*\.

    Actions that occur during the patching, including the inability to apply a
    hunk, are reported through the command prefix *reportcmd*\. Files with
    problems are left unchanged, while files without problems—whether they are
    processed before or after problem files—will be changed in accordance with
    the *patch*\.

    Each call to the command prefix can take one of three possible forms:

      * <a name='2'></a>__\{\*\}reportcmd__ __apply__ *filename*

        This call is made at the start of each patch apply and is passed the
        *filename* of the file being patched\. An attempt is made to apply all
        collected hunks for the *filename*\.

      * <a name='3'></a>__\{\*\}reportcmd__ __fail__ *filename* *hunk* *expected* *seen*

        This call is made every time the application of a hunk fails\. The
        command is passed the *filename* being processed, the *hunk* number,
        what the *expected* text was, and what the text that was actually
        *seen* is\.

      * <a name='4'></a>__\{\*\}reportcmd__ __fail\-already__ *filename* *hunk*

        This call is made every time the application of a hunk fails due to the
        given *hunk* number having *already* been applied to the
        *filename*\.

# <a name='section3'></a>Bugs, Ideas, Feedback

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

# <a name='keywords'></a>KEYWORDS

[diff \-ruN](\.\./\.\./\.\./\.\./index\.md\#diff\_run), [diff, unified
format](\.\./\.\./\.\./\.\./index\.md\#diff\_unified\_format),
[fossil](\.\./\.\./\.\./\.\./index\.md\#fossil), [git](\.\./\.\./\.\./\.\./index\.md\#git),
[patch](\.\./\.\./\.\./\.\./index\.md\#patch), [unified format
diff](\.\./\.\./\.\./\.\./index\.md\#unified\_format\_diff)

# <a name='category'></a>CATEGORY

Text processing
