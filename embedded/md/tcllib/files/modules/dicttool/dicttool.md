
[//000000001]: # (dicttool \- Extensions to the standard "dict" command)
[//000000002]: # (Generated from file 'dicttool\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2017 Sean Woods <yoda@etoyoc\.com>)
[//000000004]: # (dicttool\(n\) 1\.2 tcllib "Extensions to the standard "dict" command")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

dicttool \- Dictionary Tools

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Bugs, Ideas, Feedback](#section2)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require dicttool ?1\.2?  

[__ladd__ *dictVar* ?*key value \.\.\.*?](#1)  
[__ldelete__ *dictVar* ?*key value \.\.\.*?](#2)  
[__dict getnull__ *key*](#3)  
[__dict print__ *aDict*](#4)  
[__dict is\_dict__ *value*](#5)  
[__dict rmerge__ *dict1* *dict2* ?*dict3 \.\.\.*?](#6)  

# <a name='description'></a>DESCRIPTION

This package enhances the built\-in
[dict](https://www\.tcl\-lang\.org/man/tcl/TclCmd/dict\.html) command with
several new commands\. In addition, the package also defines several convenient
list commands\. \(Each command only adds itself if a command of the same name
doesn’t already exist, in case any of these are added to the core\.\)

  - <a name='1'></a>__ladd__ *dictVar* ?*key value \.\.\.*?

    This command adds every pair of *key value* elements to *dictVar*, but
    only if that element is not already present \(whether as a key or a value\)\.
    This command *must* be given pairs of *key value* elements to preserve
    *dictVar* as a __dict__\.

  - <a name='2'></a>__ldelete__ *dictVar* ?*key value \.\.\.*?

    This command deletes every pair of *key value* elements from *dictVar*\.
    Harmlessly does nothing if the pair is not already in *dictVar*\. This
    command *must* be given pairs of *key value* elements to preserve
    *dictVar* as a __dict__\.

    Use the built\-in
    [dict](https://www\.tcl\-lang\.org/man/tcl/TclCmd/dict\.html) command’s
    __dict remove__ subcommand to remove elements by key alone\.

  - <a name='3'></a>__dict getnull__ *key*

    Operates like __dict get__, however if the key *key* does not exist,
    it returns an empty list instead of throwing an error\.

    An alternative to this command is the built\-in
    [dict](https://www\.tcl\-lang\.org/man/tcl/TclCmd/dict\.html) command’s
    __dict getwithdefault__ subcommand *or* *its alias* __dict
    getdef__\. Using __dict getdef__ with a default of an empty list,
    *\{\}*, is equivalent to using __dict getnull__\.

  - <a name='4'></a>__dict print__ *aDict*

    Returns a “pretty printed” string representation of __dict__ *aDict*,
    with each nested branch on a newline, and indented with two spaces for every
    level\.

  - <a name='5'></a>__dict is\_dict__ *value*

    Returns __1__ \(true\) if *value* can be interpreted as a __dict__;
    otherwise __0__ \(false\)\.

    This command does *not* force an existing __dict__ representation to
    change into another internal representation\.

  - <a name='6'></a>__dict rmerge__ *dict1* *dict2* ?*dict3 \.\.\.*?

    Returns a __dict__ which is the result of a recursive merge of all of
    the __dict__ arguments\. Unlike the built\-in
    [dict](https://www\.tcl\-lang\.org/man/tcl/TclCmd/dict\.html) command’s
    __dict merge__ subcommand, this command descends into all of the
    __dict__’s levels\. Note that __dict__ keys which end in a : indicate
    a leaf, which will be interpreted as a literal value, and not descended into
    further\.

        set items [dict rmerge {
          option {color {default: green}}
        } {
          option {fruit {default: mango}}
        } {
          option {color {default: blue} fruit {widget: select values: {mango apple cherry grape}}}
        }]
        puts [dict print $items]
        =>
        option {
          color {
            default: blue
          }
          fruit {
            default: mango
            widget: select
            values: {mango apple cherry grape}
          }
        }

    If the built\-in
    [dict](https://www\.tcl\-lang\.org/man/tcl/TclCmd/dict\.html) command’s
    __dict merge__ subcommand had been used above, the *fruit* item’s
    *default* key\-value entry would have been lost\.

# <a name='section2'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *dict* as the
category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[dict](\.\./\.\./\.\./\.\./index\.md\#dict)

# <a name='category'></a>CATEGORY

Utilities

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2017 Sean Woods <yoda@etoyoc\.com>
