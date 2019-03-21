
[//000000001]: # (pt::cparam::configuration::critcl - Parser Tools)
[//000000002]: # (Generated from file 'pt_cparam_config_critcl.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt::cparam::configuration::critcl(n) 1.0.2 tcllib "Parser Tools")

# NAME

pt::cparam::configuration::critcl - C/PARAM, Canned configuration, Critcl

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
package require pt::cparam::configuration::critcl ?1.0.2?  

[__::pt::cparam::configuration::critcl__ __def__ *name* *pkg* *version* *cmdprefix*](#1)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package is an adjunct to __[pt::peg::to::cparam](pt_peg_to_cparam.md)__, to
make the use of this highly configurable package easier by providing a canned
configuration. When applied this configuration causes the package
__[pt::peg::to::cparam](pt_peg_to_cparam.md)__ to generate __critcl__-based
parser packages.

It is a supporting package in the Core Layer of Parser Tools.

![](/home/aku/Play/Tcllib/w-scratch/embedded/md/image/arch_core_support.png)

# <a name='section2'></a>API

  - <a name='1'></a>__::pt::cparam::configuration::critcl__ __def__ *name* *pkg* *version* *cmdprefix*

    The command applies the configuration provided by this package to the
    *cmdprefix*, causing the creation of __critcl__-based parsers whose class is
    *name*, in package *pkg* with *version*.

    The use of a command prefix as API allows application of the configuration
    to not only __[pt::peg::to::cparam](pt_peg_to_cparam.md)__
    (__pt::peg::to::cparam configure__), but also export manager instances and
    PEG containers (__$export configuration set__ and __[$container exporter]
    configuration set__ respectively).

    Or anything other command prefix accepting two arguments, option and value.

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
