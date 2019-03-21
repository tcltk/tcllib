
[//000000001]: # (pt_peg_op - Parser Tools)
[//000000002]: # (Generated from file 'pt_peg_op.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt_peg_op(i) 1.1.0 tcllib "Parser Tools")

# NAME

pt_peg_op - Parser Tools PE Grammar Utility Operations

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
package require pt::peg::op ?1.1.0?  

[__::peg::peg::op__ __called__ *container*](#1)  
[__::peg::peg::op__ __dechain__ *container*](#2)  
[__::peg::peg::op__ __drop unreachable__ *container*](#3)  
[__::peg::peg::op__ __drop unrealizable__ *container*](#4)  
[__::peg::peg::op__ __flatten__ *container*](#5)  
[__::peg::peg::op__ __minimize__ *container*](#6)  
[__::peg::peg::op__ __modeopt__ *container*](#7)  
[__::peg::peg::op__ __reachable__ *container*](#8)  
[__::peg::peg::op__ __realizable__ *container*](#9)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package provides a number of utility commands manipulating a PE grammar
(container) in various ways.

# <a name='section2'></a>API

  - <a name='1'></a>__::peg::peg::op__ __called__ *container*

    This command determines the static call structure for the nonterminal
    symbols of the grammar stored in the *container*.

    The result of the command is a dictionary mapping from each symbol to the
    symbols it calls. The empty string is the key used to represent the start
    expression of the grammar.

    The grammar in the container is not modified.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='2'></a>__::peg::peg::op__ __dechain__ *container*

    This command simplifies all symbols which just chain to a different symbol
    by inlining the right hand side of the called symbol in its callers. This
    works if and only the modes match properly, per the decision table below.

        caller called | dechain | notes
        --------------+---------+-----------------------
        value  value  |  yes    |  value is passed
        value  leaf   |  yes    |  value is passed
        value  void   |  yes    |  caller is implied void
        leaf   value  |  no     |  generated value was discarded, inlined would not. called may be implied void.
        leaf   leaf   |  no     |  s.a.
        leaf   void   |  no     |  s.a.
        void   value  |  no     |  caller drops value, inlined would not.
        void   leaf   |  no     |  s.a.
        void   void   |  yes    |

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='3'></a>__::peg::peg::op__ __drop unreachable__ *container*

    This command removes all symbols from the grammar which are not
    __reachable__.

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='4'></a>__::peg::peg::op__ __drop unrealizable__ *container*

    This command removes all symbols from the grammar which are not
    __realizable__.

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='5'></a>__::peg::peg::op__ __flatten__ *container*

    This command flattens (see __[pt::pe::op](pt_pexpr_op.md)__) all expressions
    in the grammar, i.e. the start expression and the right hand sides of all
    nonterminal symbols.

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='6'></a>__::peg::peg::op__ __minimize__ *container*

    This command reduces the provided grammar by applying most of the other
    methods of this package.

    After flattening the expressions it removes unreachable and unrealizable
    symbols, flattens the expressions again, then optimizes the symbol modes
    before collapsing symbol chains as much as possible.

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='7'></a>__::peg::peg::op__ __modeopt__ *container*

    This command optimizes the semantic modes of non-terminal symbols according
    to the two rules below.

    If a symbol X with mode __value__ calls no other symbols, i.e. uses only
    terminal symbols in whatever combination, then this can be represented
    simpler by using mode __leaf__.

    If a symbol X is only called from symbols with modes __leaf__ or __void__
    then this symbol should have mode __void__ also, as any AST it could
    generate will be discarded anyway.

    The result of the command is the empty string.

    The grammar in the container is directly modified. If that is not wanted, a
    copy of the original container has to be used.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='8'></a>__::peg::peg::op__ __reachable__ *container*

    This command computes the set of all nonterminal symbols which are reachable
    from the start expression of the grammar. This is essentially the transitive
    closure over __called__ and the symbol's right hand sides, beginning with
    the start expression.

    The result of the command is the list of reachable symbols.

    The grammar in the container is not modified.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

  - <a name='9'></a>__::peg::peg::op__ __realizable__ *container*

    This command computes the set of all nonterminal symbols which are
    realizable, i.e. can derive pure terminal phrases. This is done iteratively,
    starting with state unrealizable for all and any, and then updating all
    symbols which are realizable, propagating changes, until nothing changes any
    more.

    The result of the command is the list of realizable symbols.

    The grammar in the container is not modified.

    The *container* instance has to expose a method API as is provided by the
    package __[pt::peg::container](pt_peg_container.md)__.

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
