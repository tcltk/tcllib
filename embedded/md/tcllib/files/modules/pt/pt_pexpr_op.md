
[//000000001]: # (pt::pe::op - Parser Tools)
[//000000002]: # (Generated from file 'pt_pexpr_op.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt::pe::op(n) 1.0.1 tcllib "Parser Tools")

# NAME

pt::pe::op - Parsing Expression Utilities

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [PE serialization format](#section3)

      -  [Example](#subsection1)

  -  [Bugs, Ideas, Feedback](#section4)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  
package require pt::pe::op ?1.0.1?  
package require pt::pe ?1?  
package require struct::set  

[__::pt::pe::op__ __drop__ *dropset* *pe*](#1)  
[__::pt::pe::op__ __rename__ *nt* *ntnew* *pe*](#2)  
[__::pt::pe::op__ __called__ *pe*](#3)  
[__::pt::pe::op__ __flatten__ *pe*](#4)  
[__::pt::pe::op__ __fusechars__ *pe*](#5)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package provides additional commands to work with the serializations of
parsing expressions as managed by the PEG and related packages, and specified in
section [PE serialization format](#section3).

This is an internal package, for use by the higher level packages handling PEGs,
their conversion into and out of various other formats, or other uses.

# <a name='section2'></a>API

  - <a name='1'></a>__::pt::pe::op__ __drop__ *dropset* *pe*

    This command removes all occurences of any of the nonterminals symbols in
    the set *dropset* from the parsing expression *pe*, and simplifies it. This
    may result in the expression becoming "epsilon", i.e. matching nothing.

  - <a name='2'></a>__::pt::pe::op__ __rename__ *nt* *ntnew* *pe*

    This command renames all occurences of the nonterminal *nt* in the parsing
    expression *pe* into *ntnew*.

  - <a name='3'></a>__::pt::pe::op__ __called__ *pe*

    This command extracts the set of all nonterminal symbols used, i.e.
    'called', in the parsing expression *pe*.

  - <a name='4'></a>__::pt::pe::op__ __flatten__ *pe*

    This command transforms the parsing expression by eliminating sequences
    nested in sequences, and choices in choices, lifting the children of the
    nested expression into the parent. It further eliminates all sequences and
    choices with only one child, as these are redundant.

    The resulting parsing expression is returned as the result of the command.

  - <a name='5'></a>__::pt::pe::op__ __fusechars__ *pe*

    This command transforms the parsing expression by fusing adjacent terminals
    in sequences and adjacent terminals and ranges in choices, it (re)constructs
    highlevel *strings* and *character classes*.

    The resulting pseudo-parsing expression is returned as the result of the
    command and may contain the pseudo-operators __str__ for character
    sequences, aka strings, and __cl__ for character choices, aka character
    classes.

    The result is called a *pseudo-parsing expression* because it is not a true
    parsing expression anymore, and will fail a check with __::pt::peg verify__
    if the new pseudo-operators are present in the result, but is otherwise of
    sound structure for a parsing expression. Notably, the commands __::pt::peg
    bottomup__ and __::pt::peg topdown__ will process them without trouble.

# <a name='section3'></a>PE serialization format

Here we specify the format used by the Parser Tools to serialize Parsing
Expressions as immutable values for transport, comparison, etc.

We distinguish between *regular* and *canonical* serializations. While a parsing
expression may have more than one regular serialization only exactly one of them
will be *canonical*.

  - Regular serialization

      * __Atomic Parsing Expressions__

        The string __epsilon__ is an atomic parsing expression. It matches the
        empty string.

        The string __dot__ is an atomic parsing expression. It matches any
        character.

        The string __alnum__ is an atomic parsing expression. It matches any
        Unicode alphabet or digit character. This is a custom extension of PEs
        based on Tcl's builtin command __string is__.

        The string __alpha__ is an atomic parsing expression. It matches any
        Unicode alphabet character. This is a custom extension of PEs based on
        Tcl's builtin command __string is__.

        The string __ascii__ is an atomic parsing expression. It matches any
        Unicode character below U0080. This is a custom extension of PEs based
        on Tcl's builtin command __string is__.

        The string __control__ is an atomic parsing expression. It matches any
        Unicode control character. This is a custom extension of PEs based on
        Tcl's builtin command __string is__.

        The string __digit__ is an atomic parsing expression. It matches any
        Unicode digit character. Note that this includes characters outside of
        the [0..9] range. This is a custom extension of PEs based on Tcl's
        builtin command __string is__.

        The string __graph__ is an atomic parsing expression. It matches any
        Unicode printing character, except for space. This is a custom extension
        of PEs based on Tcl's builtin command __string is__.

        The string __lower__ is an atomic parsing expression. It matches any
        Unicode lower-case alphabet character. This is a custom extension of PEs
        based on Tcl's builtin command __string is__.

        The string __print__ is an atomic parsing expression. It matches any
        Unicode printing character, including space. This is a custom extension
        of PEs based on Tcl's builtin command __string is__.

        The string __punct__ is an atomic parsing expression. It matches any
        Unicode punctuation character. This is a custom extension of PEs based
        on Tcl's builtin command __string is__.

        The string __space__ is an atomic parsing expression. It matches any
        Unicode space character. This is a custom extension of PEs based on
        Tcl's builtin command __string is__.

        The string __upper__ is an atomic parsing expression. It matches any
        Unicode upper-case alphabet character. This is a custom extension of PEs
        based on Tcl's builtin command __string is__.

        The string __wordchar__ is an atomic parsing expression. It matches any
        Unicode word character. This is any alphanumeric character (see alnum),
        and any connector punctuation characters (e.g. underscore). This is a
        custom extension of PEs based on Tcl's builtin command __string is__.

        The string __xdigit__ is an atomic parsing expression. It matches any
        hexadecimal digit character. This is a custom extension of PEs based on
        Tcl's builtin command __string is__.

        The string __ddigit__ is an atomic parsing expression. It matches any
        decimal digit character. This is a custom extension of PEs based on
        Tcl's builtin command __regexp__.

        The expression [list t __x__] is an atomic parsing expression. It
        matches the terminal string __x__.

        The expression [list n __A__] is an atomic parsing expression. It
        matches the nonterminal __A__.

      * __Combined Parsing Expressions__

        For parsing expressions __e1__, __e2__, ... the result of [list / __e1__
        __e2__ ... ] is a parsing expression as well. This is the *ordered
        choice*, aka *prioritized choice*.

        For parsing expressions __e1__, __e2__, ... the result of [list x __e1__
        __e2__ ... ] is a parsing expression as well. This is the *sequence*.

        For a parsing expression __e__ the result of [list * __e__] is a parsing
        expression as well. This is the *kleene closure*, describing zero or
        more repetitions.

        For a parsing expression __e__ the result of [list + __e__] is a parsing
        expression as well. This is the *positive kleene closure*, describing
        one or more repetitions.

        For a parsing expression __e__ the result of [list & __e__] is a parsing
        expression as well. This is the *and lookahead predicate*.

        For a parsing expression __e__ the result of [list ! __e__] is a parsing
        expression as well. This is the *not lookahead predicate*.

        For a parsing expression __e__ the result of [list ? __e__] is a parsing
        expression as well. This is the *optional input*.

  - Canonical serialization

    The canonical serialization of a parsing expression has the format as
    specified in the previous item, and then additionally satisfies the
    constraints below, which make it unique among all the possible
    serializations of this parsing expression.

    The string representation of the value is the canonical representation of a
    pure Tcl list. I.e. it does not contain superfluous whitespace.

    Terminals are *not* encoded as ranges (where start and end of the range are
    identical).

## <a name='subsection1'></a>Example

Assuming the parsing expression shown on the right-hand side of the rule

    Expression <- Term (AddOp Term)*

then its canonical serialization (except for whitespace) is

    {x {n Term} {* {x {n AddOp} {n Term}}}}

# <a name='section4'></a>Bugs, Ideas, Feedback

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
