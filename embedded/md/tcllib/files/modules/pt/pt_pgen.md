
[//000000001]: # (pt::pgen - Parser Tools)
[//000000002]: # (Generated from file 'pt_pgen.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt::pgen(n) 1.1 tcllib "Parser Tools")

# NAME

pt::pgen - Parser Generator

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [Example](#section3)

  -  [Bugs, Ideas, Feedback](#section4)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  
package require pt::pgen ?1.1?  

[__::pt::pgen__ *inputformat* *text* *resultformat* ?*options...*?](#1)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt_introduction.md)*. This document is the entrypoint to the whole system
the current package is a part of.

This package provides a command implementing a *[parser
generator](../../../../index.md#parser_generator)* taking parsing expression
grammars as input.

It is the implementation of method __generate__ of __[pt](../../apps/pt.md)__,
the *[Parser Tools Application](../../apps/pt.md)*.

As such the intended audience of this document are people wishing to modify
and/or extend this part of __[pt](../../apps/pt.md)__'s functionality. Users of
__[pt](../../apps/pt.md)__ on the other hand are hereby refered to the
applications' manpage, i.e. *[Parser Tools Application](../../apps/pt.md)*.

It resides in the User Package Layer of Parser Tools.

![](../../../../image/arch_user_pkg.png)

# <a name='section2'></a>API

  - <a name='1'></a>__::pt::pgen__ *inputformat* *text* *resultformat* ?*options...*?

    This command takes the parsing expression grammar in *text* (in the format
    specified by *inputformat*), and returns the same grammar in the format
    *resultformat* as the result of the command.

    The two known input formats are __peg__ and __json__. Introductions to them,
    including their formal specifications, can be found in the *[PEG Language
    Tutorial](pt_peg_language.md)* and *[The JSON Grammar Exchange
    Format](pt_json_language.md)*. The packages used to parse these formats are

      * __peg__

        __[pt::peg::from::peg](pt_peg_from_peg.md)__

      * __json__

        __[pt::peg::from::json](pt_peg_from_json.md)__

    On the output side the known formats, and the packages used to generate them
    are

      * __c__

        __[pt::peg::to::cparam](pt_peg_to_cparam.md)__

      * __container__

        __[pt::peg::to::container](pt_peg_to_container.md)__

      * __critcl__

        __[pt::peg::to::cparam](pt_peg_to_cparam.md)__ +
        __[pt::cparam::configuration::critcl](pt_cparam_config_critcl.md)__

      * __json__

        __[pt::peg::to::json](pt_peg_to_json.md)__

      * __oo__

        __[pt::peg::to::tclparam](pt_peg_to_tclparam.md)__ +
        __[pt::tclparam::configuration::tcloo](pt_tclparam_config_tcloo.md)__

      * __peg__

        __[pt::peg::to::peg](pt_peg_to_peg.md)__

      * __snit__

        __[pt::peg::to::tclparam](pt_peg_to_tclparam.md)__ +
        __[pt::tclparam::configuration::snit](pt_tclparam_config_snit.md)__

    The options supported by each of these formats are documented with their
    respective packages.

# <a name='section3'></a>Example

In this section we are working a complete example, starting with a PEG grammar
and ending with running the parser generated from it over some input, following
the outline shown in the figure below:

![](../../../../image/flow.png) Our grammar, assumed to the stored in the file
"calculator.peg" is

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

From this we create a snit-based parser using the script "gen"

    package require Tcl 8.5
    package require fileutil
    package require pt::pgen

    lassign $argv name
    set grammar [fileutil::cat $name.peg]
    set pclass  [pt::pgen peg $gr snit -class $name -file  $name.peg -name  $name]
    fileutil::writeFile $name.tcl $pclass
    exit 0

calling it like

    tclsh8.5 gen calculator

which leaves us with the parser package and class written to the file
"calculator.tcl". Assuming that this package is then properly installed in a
place where Tcl can find it we can now use this class via a script like

    package require calculator

    lassign $argv input
    set channel [open $input r]

    set parser [calculator]
    set ast [$parser parse $channel]
    $parser destroy
    close $channel

    ... now process the returned abstract syntax tree ...

where the abstract syntax tree stored in the variable will look like

    set ast {Expression 0 4
        {Factor 0 4
            {Term 0 2
                {Number 0 2
                    {Digit 0 0}
                    {Digit 1 1}
                    {Digit 2 2}
                }
            }
            {AddOp 3 3}
            {Term 4 4
                {Number 4 4
                    {Digit 4 4}
                }
            }
        }
    }

assuming that the input file and channel contained the text

    120+5

A more graphical representation of the tree would be

![](../../../../image/expr_ast.png) Regardless, at this point it is the user's
responsibility to work with the tree to reach whatever goal she desires. I.e.
analyze it, transform it, etc. The package __[pt::ast](pt_astree.md)__ should be
of help here, providing commands to walk such ASTs structures in various ways.

One important thing to note is that the parsers used here return a data
structure representing the structure of the input per the grammar underlying the
parser. There are *no* callbacks during the parsing process, i.e. no *parsing
actions*, as most other parsers will have.

Going back to the last snippet of code, the execution of the parser for some
input, note how the parser instance follows the specified *[Parser
API](pt_parser_api.md)*.

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
