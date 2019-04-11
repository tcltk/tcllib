
[//000000001]: # (practcl \- The The Proper Rational API for C to Tool Command Language Module)
[//000000002]: # (Generated from file 'practcl\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2016\-2018 Sean Woods <yoda@etoyoc\.com>)
[//000000004]: # (practcl\(n\) 0\.11 tcllib "The The Proper Rational API for C to Tool Command Language Module")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

practcl \- The Practcl Module

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [COMMANDS](#section2)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require TclOO 1\.0  
package require practcl 0\.11  

[__CPUTS__ *varname* *body* ?*body*\.\.\.?](#1)  
[__practcl::\_isdirectory__ *path*](#2)  
[__practcl::object__ *parent* ?*keyvaluelist*?](#3)  
[__practcl::library__ ?*keyvaluelist*?](#4)  
[__practcl::exe__ ?*keyvaluelist*?](#5)  
[__practcl::product__ *parent* ?*keyvaluelist*?](#6)  
[__practcl::cheader__ *parent* ?*keyvaluelist*?](#7)  
[__practcl::csource__ *parent* ?*keyvaluelist*?](#8)  
[__practcl::module__ *parent* ?*keyvaluelist*?](#9)  
[__practcl::submodule__ *parent* ?*keyvaluelist*?](#10)  

# <a name='description'></a>DESCRIPTION

The Practcl module is a tool for integrating large modules for C API Tcl code
that requires custom Tcl types and TclOO objects\.

# <a name='section2'></a>COMMANDS

  - <a name='1'></a>__CPUTS__ *varname* *body* ?*body*\.\.\.?

    Appends blocks of text to a buffer\. This command tries to reduce the number
    of line breaks between bodies\.

  - <a name='2'></a>__practcl::\_isdirectory__ *path*

    Returns true if *path* is a directory, using the test

  - <a name='3'></a>__practcl::object__ *parent* ?*keyvaluelist*?

    A generic Practcl object

  - <a name='4'></a>__practcl::library__ ?*keyvaluelist*?

    A Practcl object representing a library container

  - <a name='5'></a>__practcl::exe__ ?*keyvaluelist*?

    A Practcl object representing a wrapped executable

  - <a name='6'></a>__practcl::product__ *parent* ?*keyvaluelist*?

    A Practcl object representing a compiled product

  - <a name='7'></a>__practcl::cheader__ *parent* ?*keyvaluelist*?

    A Practcl object representing an externally generated c header

  - <a name='8'></a>__practcl::csource__ *parent* ?*keyvaluelist*?

    A Practcl object representing an externally generated c source file

  - <a name='9'></a>__practcl::module__ *parent* ?*keyvaluelist*?

    A Practcl object representing a dynamically generated C/H/Tcl suite

  - <a name='10'></a>__practcl::submodule__ *parent* ?*keyvaluelist*?

    A Practcl object representing a dynamically generated C/H/Tcl suite,
    subordinate to a module

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *practcl* of the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[practcl](\.\./\.\./\.\./\.\./index\.md\#practcl)

# <a name='category'></a>CATEGORY

TclOO

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2016\-2018 Sean Woods <yoda@etoyoc\.com>
