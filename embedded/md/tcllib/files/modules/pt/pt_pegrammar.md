
[//000000001]: # (pt::peg - Parser Tools)
[//000000002]: # (Generated from file 'pt_pegrammar.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt::peg(n) 1 tcllib "Parser Tools")

# NAME

pt::peg - Parsing Expression Grammar Serialization

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [PEG serialization format](#section3)

      -  [Example](#subsection1)

  -  [PE serialization format](#section4)

      -  [Example](#subsection2)

  -  [Bugs, Ideas, Feedback](#section5)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  
package require pt::peg ?1?  
package require pt::pe  

[__::pt::peg__ __verify__ *serial* ?*canonvar*?](#1)  
[__::pt::peg__ __verify-as-canonical__ *serial*](#2)  
[__::pt::peg__ __canonicalize__ *serial*](#3)  
[__::pt::peg__ __print__ *serial*](#4)  
[__::pt::peg__ __merge__ *seriala* *serialb*](#5)  
[__::pt::peg__ __equal__ *seriala* *serialb*](#6)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package provides commands to work with the serializations of parsing
expression grammars as managed by the Parser Tools, and specified in section
[PEG serialization format](#section3).

This is a supporting package in the Core Layer of Parser Tools.

![](../../../../image/arch_core_support.png)

# <a name='section2'></a>API

  - <a name='1'></a>__::pt::peg__ __verify__ *serial* ?*canonvar*?

    This command verifies that the content of *serial* is a valid serialization
    of a parsing expression and will throw an error if that is not the case. The
    result of the command is the empty string.

    If the argument *canonvar* is specified it is interpreted as the name of a
    variable in the calling context. This variable will be written to if and
    only if *serial* is a valid regular serialization. Its value will be a
    boolean, with __True__ indicating that the serialization is not only valid,
    but also *canonical*. __False__ will be written for a valid, but
    non-canonical serialization.

    For the specification of serializations see the section [PE serialization
    format](#section4).

  - <a name='2'></a>__::pt::peg__ __verify-as-canonical__ *serial*

    This command verifies that the content of *serial* is a valid *canonical*
    serialization of a PEG and will throw an error if that is not the case. The
    result of the command is the empty string.

    For the specification of canonical serializations see the section [PEG
    serialization format](#section3).

  - <a name='3'></a>__::pt::peg__ __canonicalize__ *serial*

    This command assumes that the content of *serial* is a valid *regular*
    serialization of a PEG and will throw an error if that is not the case.

    It will then convert the input into the *canonical* serialization of the
    contained PEG and return it as its result. If the input is already canonical
    it will be returned unchanged.

    For the specification of regular and canonical serializations see the
    section [PEG serialization format](#section3).

  - <a name='4'></a>__::pt::peg__ __print__ *serial*

    This command assumes that the argument *serial* contains a valid
    serialization of a parsing expression and returns a string containing that
    PE in a human readable form.

    The exact format of this form is not specified and cannot be relied on for
    parsing or other machine-based activities.

    For the specification of serializations see the section [PEG serialization
    format](#section3).

  - <a name='5'></a>__::pt::peg__ __merge__ *seriala* *serialb*

    This command accepts the regular serializations of two grammars and uses
    them to create their union. The result of the command is the canonical
    serialization of this unified grammar.

    A merge errors occurs if for any nonterminal symbol S occuring in both input
    grammars the two input grammars specify different semantic modes.

    The semantic mode of each nonterminal symbol S is the semantic mode of S in
    any of its input grammars. The previous rule made sure that for symbols
    occuring in both grammars these values are identical.

    The right-hand side of each nonterminal symbol S occuring in both input
    grammars is the choice between the right-hand sides of S in the input
    grammars, with the parsing expression of S in *seriala* coming first, except
    if both expressions are identical. In that case the first expression is
    taken.

    The right-hand side of each nonterminal symbol S occuring in only one of the
    input grammars is the right-hand side of S in its input grammar.

    The start expression of the unified grammar is the choice between the start
    expressions of the input grammars, with the start expression of *seriala*
    coming first, except if both expressions are identical. In that case the
    first expression is taken

  - <a name='6'></a>__::pt::peg__ __equal__ *seriala* *serialb*

    This command tests the two grammars *seriala* and *serialb* for structural
    equality. The result of the command is a boolean value. It will be set to
    __true__ if the expressions are identical, and __false__ otherwise.

    String equality is usable only if we can assume that the two grammars are
    pure Tcl lists and dictionaries.

# <a name='section3'></a>PEG serialization format

Here we specify the format used by the Parser Tools to serialize Parsing
Expression Grammars as immutable values for transport, comparison, etc.

We distinguish between *regular* and *canonical* serializations. While a PEG may
have more than one regular serialization only exactly one of them will be
*canonical*.

  - regular serialization

    The serialization of any PEG is a nested Tcl dictionary.

    This dictionary holds a single key, __pt::grammar::peg__, and its value.
    This value holds the contents of the grammar.

    The contents of the grammar are a Tcl dictionary holding the set of
    nonterminal symbols and the starting expression. The relevant keys and their
    values are

           * __rules__

             The value is a Tcl dictionary whose keys are the names of the
             nonterminal symbols known to the grammar.

             Each nonterminal symbol may occur only once.

             The empty string is not a legal nonterminal symbol.

             The value for each symbol is a Tcl dictionary itself. The relevant
             keys and their values in this dictionary are

                    + __is__

                      The value is the serialization of the parsing expression
                      describing the symbols sentennial structure, as specified
                      in the section [PE serialization format](#section4).

                    + __mode__

                      The value can be one of three values specifying how a
                      parser should handle the semantic value produced by the
                      symbol.

                        - __value__

                          The semantic value of the nonterminal symbol is an
                          abstract syntax tree consisting of a single node node
                          for the nonterminal itself, which has the ASTs of the
                          symbol's right hand side as its children.

                        - __leaf__

                          The semantic value of the nonterminal symbol is an
                          abstract syntax tree consisting of a single node node
                          for the nonterminal, without any children. Any ASTs
                          generated by the symbol's right hand side are
                          discarded.

                        - __void__

                          The nonterminal has no semantic value. Any ASTs
                          generated by the symbol's right hand side are
                          discarded (as well).

           * __start__

             The value is the serialization of the start parsing expression of
             the grammar, as specified in the section [PE serialization
             format](#section4).

    The terminal symbols of the grammar are specified implicitly as the set of
    all terminal symbols used in the start expression and on the RHS of the
    grammar rules.

  - canonical serialization

    The canonical serialization of a grammar has the format as specified in the
    previous item, and then additionally satisfies the constraints below, which
    make it unique among all the possible serializations of this grammar.

    The keys found in all the nested Tcl dictionaries are sorted in ascending
    dictionary order, as generated by Tcl's builtin command __lsort -increasing
    -dict__.

    The string representation of the value is the canonical representation of a
    Tcl dictionary. I.e. it does not contain superfluous whitespace.

## <a name='subsection1'></a>Example

Assuming the following PEG for simple mathematical expressions

    PEG calculator (Expression)
        Digit      <- '0'/'1'/'2'/'3'/'4'/'5'/'6'/'7'/'8'/'9'       ;
        Sign       <- '-' / '+'                                     ;
        Number     <- Sign? Digit+                                  ;
        Expression <- Term (AddOp Term)*                            ;
        MulOp      <- '*' / '/'                                     ;
        Term       <- Factor (MulOp Factor)*                        ;
        AddOp      <- '+'/'-'                                       ;
        Factor     <- '(' Expression ')' / Number                   ;
    END;

then its canonical serialization (except for whitespace) is

    pt::grammar::peg {
        rules {
            AddOp      {is {/ {t -} {t +}}                                                                mode value}
            Digit      {is {/ {t 0} {t 1} {t 2} {t 3} {t 4} {t 5} {t 6} {t 7} {t 8} {t 9}}                mode value}
            Expression {is {x {n Term} {* {x {n AddOp} {n Term}}}}                                        mode value}
            Factor     {is {/ {x {t (} {n Expression} {t )}} {n Number}}                                  mode value}
            MulOp      {is {/ {t *} {t /}}                                                                mode value}
            Number     {is {x {? {n Sign}} {+ {n Digit}}}                                                 mode value}
            Sign       {is {/ {t -} {t +}}                                                                mode value}
            Term       {is {x {n Factor} {* {x {n MulOp} {n Factor}}}}                                    mode value}
        }
        start {n Expression}
    }

# <a name='section4'></a>PE serialization format

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

## <a name='subsection2'></a>Example

Assuming the parsing expression shown on the right-hand side of the rule

    Expression <- Term (AddOp Term)*

then its canonical serialization (except for whitespace) is

    {x {n Term} {* {x {n AddOp} {n Term}}}}

# <a name='section5'></a>Bugs, Ideas, Feedback

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
