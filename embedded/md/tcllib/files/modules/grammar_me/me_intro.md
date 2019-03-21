
[//000000001]: # (grammar::me_intro - Grammar operations and usage)
[//000000002]: # (Generated from file 'me_intro.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (grammar::me_intro(n) 0.1 tcllib "Grammar operations and usage")

# NAME

grammar::me_intro - Introduction to virtual machines for parsing token streams

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Description](#section1)

  -  [Bugs, Ideas, Feedback](#section2)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

This document is an introduction to and overview of the basic facilities for the
parsing and/or matching of *token* streams. One possibility often used for the
token domain are characters.

The packages themselves all provide variants of one *[virtual
machine](../../../../index.md#virtual_machine)*, called a *match engine* (short
*ME*), which has all the facilities needed for the matching and parsing of a
stream, and which are either controlled directly, or are customized with a match
program. The virtual machine is basically a pushdown automaton, with additional
elements for backtracking and/or handling of semantic data and construction of
abstract syntax trees (*[AST](../../../../index.md#ast)*).

Because of the high degree of similarity in the actual implementations of the
aforementioned virtual machine and the data structures they receive and generate
these common parts are specified in a separate document which will be referenced
by the documentation for packages actually implementing it.

The relevant documents are:

  - __[grammar::me_vm](me_vm.md)__

    Virtual machine specification.

  - __[grammar::me_ast](me_ast.md)__

    Specification of various representations used for abstract syntax trees.

  - __[grammar::me::util](me_util.md)__

    Utility commands.

  - __[grammar::me::tcl](me_tcl.md)__

    Singleton ME virtual machine implementation tied to Tcl for control flow and
    stacks. Hardwired for pull operation. Uninteruptible during processing.

  - __[grammar::me::cpu](me_cpu.md)__

    Object-based ME virtual machine implementation with explicit control flow,
    and stacks, using bytecodes. Suspend/Resumable. Push/pull operation.

  - __[grammar::me::cpu::core](me_cpucore.md)__

    Core functionality for state manipulation and stepping used in the bytecode
    based implementation of ME virtual machines.

# <a name='section2'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *grammar_me* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='keywords'></a>KEYWORDS

[CFG](../../../../index.md#cfg), [CFL](../../../../index.md#cfl),
[LL(k)](../../../../index.md#ll_k_), [PEG](../../../../index.md#peg),
[TPDL](../../../../index.md#tpdl), [context-free
grammar](../../../../index.md#context_free_grammar), [context-free
languages](../../../../index.md#context_free_languages),
[expression](../../../../index.md#expression),
[grammar](../../../../index.md#grammar),
[matching](../../../../index.md#matching),
[parsing](../../../../index.md#parsing), [parsing expression
grammar](../../../../index.md#parsing_expression_grammar), [push down
automaton](../../../../index.md#push_down_automaton), [recursive
descent](../../../../index.md#recursive_descent), [top-down parsing
languages](../../../../index.md#top_down_parsing_languages),
[transducer](../../../../index.md#transducer), [virtual
machine](../../../../index.md#virtual_machine)

# <a name='category'></a>CATEGORY

Grammars and finite automata

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2005 Andreas Kupries <andreas_kupries@users.sourceforge.net>
