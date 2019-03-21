
[//000000001]: # (pt::util - Parser Tools)
[//000000002]: # (Generated from file 'pt_util.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt::util(n) 1.1 tcllib "Parser Tools")

# NAME

pt::util - General utilities

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  
package require pt::ast ?1.1?  

[__::pt::util__ __error2readable__ *error* *text*](#1)  
[__::pt::util__ __error2position__ *error* *text*](#2)  
[__::pt::util__ __error2text__ *error*](#3)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package provides general utility commands.

This is a supporting package in the Core Layer of Parser Tools.

![](../../../../image/arch_core_support.png)

# <a name='section2'></a>API

  - <a name='1'></a>__::pt::util__ __error2readable__ *error* *text*

    This command takes the structured form of a syntax *error* as thrown by
    parser runtimes and the input *text* to the parser which caused that error
    and returns a string describing the error in a human-readable form.

    The input *text* is required to convert the character position of the error
    into a more readable line/column format, and to provide excerpts of the
    input around the error position.

  - <a name='2'></a>__::pt::util__ __error2position__ *error* *text*

    This command takes the structured form of a syntax *error* as thrown by
    parser runtimes and the input *text* to the parser which caused that error
    and returns a 2-element list containing the line number and column index for
    the error's character position in the input, in this order.

  - <a name='3'></a>__::pt::util__ __error2text__ *error*

    This command takes the structured form of a syntax *error* as thrown by
    parser runtimes and returns a list of strings, each describing a possible
    expected input in a human-readable form.

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *pt* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='keywords'></a>KEYWORDS

[EBNF](../../../../index.md#ebnf), [LL(k)](../../../../index.md#ll_k_),
[PEG](../../../../index.md#peg), [TDPL](../../../../index.md#tdpl),
[context-free languages](../../../../index.md#context_free_languages),
[expression](../../../../index.md#expression),
[grammar](../../../../index.md#grammar),
[matching](../../../../index.md#matching),
[parser](../../../../index.md#parser), [parsing
expression](../../../../index.md#parsing_expression), [parsing expression
grammar](../../../../index.md#parsing_expression_grammar), [push down
automaton](../../../../index.md#push_down_automaton), [recursive
descent](../../../../index.md#recursive_descent),
[state](../../../../index.md#state), [top-down parsing
languages](../../../../index.md#top_down_parsing_languages),
[transducer](../../../../index.md#transducer)

# <a name='category'></a>CATEGORY

Parsing and Grammars

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
