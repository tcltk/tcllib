
[//000000001]: # (pt::peg::to::param \- Parser Tools)
[//000000002]: # (Generated from file 'to\.inc' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2009 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (pt::peg::to::param\(n\) 1 tcllib "Parser Tools")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

pt::peg::to::param \- PEG Conversion\. Write PARAM format

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Options](#section3)

  - [PARAM code representation of parsing expression grammars](#section4)

      - [Example](#subsection1)

  - [PEG serialization format](#section5)

      - [Example](#subsection2)

  - [PE serialization format](#section6)

      - [Example](#subsection3)

  - [Bugs, Ideas, Feedback](#section7)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5  
package require pt::peg::to::param ?1?  
package require pt::peg  
package require pt::pe  

[__pt::peg::to::param__ __reset__](#1)  
[__pt::peg::to::param__ __configure__](#2)  
[__pt::peg::to::param__ __configure__ *option*](#3)  
[__pt::peg::to::param__ __configure__ *option* *value*\.\.\.](#4)  
[__pt::peg::to::param__ __convert__ *serial*](#5)  

# <a name='description'></a>DESCRIPTION

Are you lost ? Do you have trouble understanding this document ? In that case
please read the overview provided by the *[Introduction to Parser
Tools](pt\_introduction\.md)*\. This document is the entrypoint to the whole
system the current package is a part of\.

This package implements the converter from parsing expression grammars to PARAM
markup\.

It resides in the Export section of the Core Layer of Parser Tools, and can be
used either directly with the other packages of this layer, or indirectly
through the export manager provided by
__[pt::peg::export](pt\_peg\_export\.md)__\. The latter is intented for use
in untrusted environments and done through the corresponding export plugin
__pt::peg::export::param__ sitting between converter and export manager\.

![](\.\./\.\./\.\./\.\./image/arch\_core\_eplugins\.png)

# <a name='section2'></a>API

The API provided by this package satisfies the specification of the Converter
API found in the *[Parser Tools Export API](pt\_to\_api\.md)* specification\.

  - <a name='1'></a>__pt::peg::to::param__ __reset__

    This command resets the configuration of the package to its default
    settings\.

  - <a name='2'></a>__pt::peg::to::param__ __configure__

    This command returns a dictionary containing the current configuration of
    the package\.

  - <a name='3'></a>__pt::peg::to::param__ __configure__ *option*

    This command returns the current value of the specified configuration
    *option* of the package\. For the set of legal options, please read the
    section [Options](#section3)\.

  - <a name='4'></a>__pt::peg::to::param__ __configure__ *option* *value*\.\.\.

    This command sets the given configuration *option*s of the package, to the
    specified *value*s\. For the set of legal options, please read the section
    [Options](#section3)\.

  - <a name='5'></a>__pt::peg::to::param__ __convert__ *serial*

    This command takes the canonical serialization of a parsing expression
    grammar, as specified in section [PEG serialization format](#section5),
    and contained in *serial*, and generates PARAM markup encoding the
    grammar, per the current package configuration\. The created string is then
    returned as the result of the command\.

# <a name='section3'></a>Options

The converter to PARAM markup recognizes the following configuration variables
and changes its behaviour as they specify\.

  - __\-template__ string

    The value of this configuration variable is a string into which to put the
    generated text and the other configuration settings\. The various locations
    for user\-data are expected to be specified with the placeholders listed
    below\. The default value is "__@code@__"\.

      * __@user@__

        To be replaced with the value of the configuration variable
        __\-user__\.

      * __@format@__

        To be replaced with the the constant __PARAM__\.

      * __@file@__

        To be replaced with the value of the configuration variable
        __\-file__\.

      * __@name@__

        To be replaced with the value of the configuration variable
        __\-name__\.

      * __@code@__

        To be replaced with the generated text\.

  - __\-name__ string

    The value of this configuration variable is the name of the grammar for
    which the conversion is run\. The default value is __a\_pe\_grammar__\.

  - __\-user__ string

    The value of this configuration variable is the name of the user for which
    the conversion is run\. The default value is __unknown__\.

  - __\-file__ string

    The value of this configuration variable is the name of the file or other
    entity from which the grammar came, for which the conversion is run\. The
    default value is __unknown__\.

# <a name='section4'></a>PARAM code representation of parsing expression grammars

The PARAM code representation of parsing expression grammars is assembler\-like
text using the instructions of the virtual machine documented in the *[PackRat
Machine Specification](pt\_param\.md)*, plus a few more for control flow \(jump
ok, jump fail, call symbol, return\)\.

It is not really useful, except possibly as a tool demonstrating how a grammar
is compiled in general, without getting distracted by the incidentials of a
framework, i\.e\. like the supporting C and Tcl code generated by the other
PARAM\-derived formats\.

It has no direct formal specification beyond what was said above\.

## <a name='subsection1'></a>Example

Assuming the following PEG for simple mathematical expressions

    PEG calculator \(Expression\)
        Digit      <\- '0'/'1'/'2'/'3'/'4'/'5'/'6'/'7'/'8'/'9'       ;
        Sign       <\- '\-' / '\+'                                     ;
        Number     <\- Sign? Digit\+                                  ;
        Expression <\- Term \(AddOp Term\)\*                            ;
        MulOp      <\- '\*' / '/'                                     ;
        Term       <\- Factor \(MulOp Factor\)\*                        ;
        AddOp      <\- '\+'/'\-'                                       ;
        Factor     <\- '\(' Expression '\)' / Number                   ;
    END;

one possible PARAM serialization for it is

    \# \-\*\- text \-\*\-
    \# Parsing Expression Grammar 'TEMPLATE'\.
    \# Generated for unknown, from file 'TEST'

    \#
    \# Grammar Start Expression
    \#

    <<MAIN>>:
             call              sym\_Expression
             halt

    \#
    \# value Symbol 'AddOp'
    \#

    sym\_AddOp:
    \# /
    \#     '\-'
    \#     '\+'

             symbol\_restore    AddOp
      found\! jump              found\_7
             loc\_push

             call              choice\_5

       fail\! value\_clear
         ok\! value\_leaf        AddOp
             symbol\_save       AddOp
             error\_nonterminal AddOp
             loc\_pop\_discard

    found\_7:
         ok\! ast\_value\_push
             return

    choice\_5:
    \# /
    \#     '\-'
    \#     '\+'

             error\_clear

             loc\_push
             error\_push

             input\_next        "t \-"
         ok\! test\_char         "\-"

             error\_pop\_merge
         ok\! jump              oknoast\_4

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t \+"
         ok\! test\_char         "\+"

             error\_pop\_merge
         ok\! jump              oknoast\_4

             loc\_pop\_rewind
             status\_fail
             return

    oknoast\_4:
             loc\_pop\_discard
             return
    \#
    \# value Symbol 'Digit'
    \#

    sym\_Digit:
    \# /
    \#     '0'
    \#     '1'
    \#     '2'
    \#     '3'
    \#     '4'
    \#     '5'
    \#     '6'
    \#     '7'
    \#     '8'
    \#     '9'

             symbol\_restore    Digit
      found\! jump              found\_22
             loc\_push

             call              choice\_20

       fail\! value\_clear
         ok\! value\_leaf        Digit
             symbol\_save       Digit
             error\_nonterminal Digit
             loc\_pop\_discard

    found\_22:
         ok\! ast\_value\_push
             return

    choice\_20:
    \# /
    \#     '0'
    \#     '1'
    \#     '2'
    \#     '3'
    \#     '4'
    \#     '5'
    \#     '6'
    \#     '7'
    \#     '8'
    \#     '9'

             error\_clear

             loc\_push
             error\_push

             input\_next        "t 0"
         ok\! test\_char         "0"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 1"
         ok\! test\_char         "1"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 2"
         ok\! test\_char         "2"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 3"
         ok\! test\_char         "3"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 4"
         ok\! test\_char         "4"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 5"
         ok\! test\_char         "5"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 6"
         ok\! test\_char         "6"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 7"
         ok\! test\_char         "7"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 8"
         ok\! test\_char         "8"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t 9"
         ok\! test\_char         "9"

             error\_pop\_merge
         ok\! jump              oknoast\_19

             loc\_pop\_rewind
             status\_fail
             return

    oknoast\_19:
             loc\_pop\_discard
             return
    \#
    \# value Symbol 'Expression'
    \#

    sym\_Expression:
    \# /
    \#     x
    \#         '\\\('
    \#         \(Expression\)
    \#         '\\\)'
    \#     x
    \#         \(Factor\)
    \#         \*
    \#             x
    \#                 \(MulOp\)
    \#                 \(Factor\)

             symbol\_restore    Expression
      found\! jump              found\_46
             loc\_push
             ast\_push

             call              choice\_44

       fail\! value\_clear
         ok\! value\_reduce      Expression
             symbol\_save       Expression
             error\_nonterminal Expression
             ast\_pop\_rewind
             loc\_pop\_discard

    found\_46:
         ok\! ast\_value\_push
             return

    choice\_44:
    \# /
    \#     x
    \#         '\\\('
    \#         \(Expression\)
    \#         '\\\)'
    \#     x
    \#         \(Factor\)
    \#         \*
    \#             x
    \#                 \(MulOp\)
    \#                 \(Factor\)

             error\_clear

             ast\_push
             loc\_push
             error\_push

             call              sequence\_27

             error\_pop\_merge
         ok\! jump              ok\_43

             ast\_pop\_rewind
             loc\_pop\_rewind
             ast\_push
             loc\_push
             error\_push

             call              sequence\_40

             error\_pop\_merge
         ok\! jump              ok\_43

             ast\_pop\_rewind
             loc\_pop\_rewind
             status\_fail
             return

    ok\_43:
             ast\_pop\_discard
             loc\_pop\_discard
             return

    sequence\_27:
    \# x
    \#     '\\\('
    \#     \(Expression\)
    \#     '\\\)'

             loc\_push
             error\_clear

             error\_push

             input\_next        "t \("
         ok\! test\_char         "\("

             error\_pop\_merge
       fail\! jump              failednoast\_29
             ast\_push
             error\_push

             call              sym\_Expression

             error\_pop\_merge
       fail\! jump              failed\_28
             error\_push

             input\_next        "t \)"
         ok\! test\_char         "\)"

             error\_pop\_merge
       fail\! jump              failed\_28

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_28:
             ast\_pop\_rewind

    failednoast\_29:
             loc\_pop\_rewind
             return

    sequence\_40:
    \# x
    \#     \(Factor\)
    \#     \*
    \#         x
    \#             \(MulOp\)
    \#             \(Factor\)

             ast\_push
             loc\_push
             error\_clear

             error\_push

             call              sym\_Factor

             error\_pop\_merge
       fail\! jump              failed\_41
             error\_push

             call              kleene\_37

             error\_pop\_merge
       fail\! jump              failed\_41

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_41:
             ast\_pop\_rewind
             loc\_pop\_rewind
             return

    kleene\_37:
    \# \*
    \#     x
    \#         \(MulOp\)
    \#         \(Factor\)

             loc\_push
             error\_push

             call              sequence\_34

             error\_pop\_merge
       fail\! jump              failed\_38
             loc\_pop\_discard
             jump              kleene\_37

    failed\_38:
             loc\_pop\_rewind
             status\_ok
             return

    sequence\_34:
    \# x
    \#     \(MulOp\)
    \#     \(Factor\)

             ast\_push
             loc\_push
             error\_clear

             error\_push

             call              sym\_MulOp

             error\_pop\_merge
       fail\! jump              failed\_35
             error\_push

             call              sym\_Factor

             error\_pop\_merge
       fail\! jump              failed\_35

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_35:
             ast\_pop\_rewind
             loc\_pop\_rewind
             return
    \#
    \# value Symbol 'Factor'
    \#

    sym\_Factor:
    \# x
    \#     \(Term\)
    \#     \*
    \#         x
    \#             \(AddOp\)
    \#             \(Term\)

             symbol\_restore    Factor
      found\! jump              found\_60
             loc\_push
             ast\_push

             call              sequence\_57

       fail\! value\_clear
         ok\! value\_reduce      Factor
             symbol\_save       Factor
             error\_nonterminal Factor
             ast\_pop\_rewind
             loc\_pop\_discard

    found\_60:
         ok\! ast\_value\_push
             return

    sequence\_57:
    \# x
    \#     \(Term\)
    \#     \*
    \#         x
    \#             \(AddOp\)
    \#             \(Term\)

             ast\_push
             loc\_push
             error\_clear

             error\_push

             call              sym\_Term

             error\_pop\_merge
       fail\! jump              failed\_58
             error\_push

             call              kleene\_54

             error\_pop\_merge
       fail\! jump              failed\_58

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_58:
             ast\_pop\_rewind
             loc\_pop\_rewind
             return

    kleene\_54:
    \# \*
    \#     x
    \#         \(AddOp\)
    \#         \(Term\)

             loc\_push
             error\_push

             call              sequence\_51

             error\_pop\_merge
       fail\! jump              failed\_55
             loc\_pop\_discard
             jump              kleene\_54

    failed\_55:
             loc\_pop\_rewind
             status\_ok
             return

    sequence\_51:
    \# x
    \#     \(AddOp\)
    \#     \(Term\)

             ast\_push
             loc\_push
             error\_clear

             error\_push

             call              sym\_AddOp

             error\_pop\_merge
       fail\! jump              failed\_52
             error\_push

             call              sym\_Term

             error\_pop\_merge
       fail\! jump              failed\_52

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_52:
             ast\_pop\_rewind
             loc\_pop\_rewind
             return
    \#
    \# value Symbol 'MulOp'
    \#

    sym\_MulOp:
    \# /
    \#     '\*'
    \#     '/'

             symbol\_restore    MulOp
      found\! jump              found\_67
             loc\_push

             call              choice\_65

       fail\! value\_clear
         ok\! value\_leaf        MulOp
             symbol\_save       MulOp
             error\_nonterminal MulOp
             loc\_pop\_discard

    found\_67:
         ok\! ast\_value\_push
             return

    choice\_65:
    \# /
    \#     '\*'
    \#     '/'

             error\_clear

             loc\_push
             error\_push

             input\_next        "t \*"
         ok\! test\_char         "\*"

             error\_pop\_merge
         ok\! jump              oknoast\_64

             loc\_pop\_rewind
             loc\_push
             error\_push

             input\_next        "t /"
         ok\! test\_char         "/"

             error\_pop\_merge
         ok\! jump              oknoast\_64

             loc\_pop\_rewind
             status\_fail
             return

    oknoast\_64:
             loc\_pop\_discard
             return
    \#
    \# value Symbol 'Number'
    \#

    sym\_Number:
    \# x
    \#     ?
    \#         \(Sign\)
    \#     \+
    \#         \(Digit\)

             symbol\_restore    Number
      found\! jump              found\_80
             loc\_push
             ast\_push

             call              sequence\_77

       fail\! value\_clear
         ok\! value\_reduce      Number
             symbol\_save       Number
             error\_nonterminal Number
             ast\_pop\_rewind
             loc\_pop\_discard

    found\_80:
         ok\! ast\_value\_push
             return

    sequence\_77:
    \# x
    \#     ?
    \#         \(Sign\)
    \#     \+
    \#         \(Digit\)

             ast\_push
             loc\_push
             error\_clear

             error\_push

             call              optional\_70

             error\_pop\_merge
       fail\! jump              failed\_78
             error\_push

             call              poskleene\_73

             error\_pop\_merge
       fail\! jump              failed\_78

             ast\_pop\_discard
             loc\_pop\_discard
             return

    failed\_78:
             ast\_pop\_rewind
             loc\_pop\_rewind
             return

    optional\_70:
    \# ?
    \#     \(Sign\)

             loc\_push
             error\_push

             call              sym\_Sign

             error\_pop\_merge
       fail\! loc\_pop\_rewind
         ok\! loc\_pop\_discard
             status\_ok
             return

    poskleene\_73:
    \# \+
    \#     \(Digit\)

             loc\_push

             call              sym\_Digit

       fail\! jump              failed\_74

    loop\_75:
             loc\_pop\_discard
             loc\_push
             error\_push

             call              sym\_Digit

             error\_pop\_merge
         ok\! jump              loop\_75
             status\_ok

    failed\_74:
             loc\_pop\_rewind
             return
    \#
    \# value Symbol 'Sign'
    \#

    sym\_Sign:
    \# /
    \#     '\-'
    \#     '\+'

             symbol\_restore    Sign
      found\! jump              found\_86
             loc\_push

             call              choice\_5

       fail\! value\_clear
         ok\! value\_leaf        Sign
             symbol\_save       Sign
             error\_nonterminal Sign
             loc\_pop\_discard

    found\_86:
         ok\! ast\_value\_push
             return
    \#
    \# value Symbol 'Term'
    \#

    sym\_Term:
    \# \(Number\)

             symbol\_restore    Term
      found\! jump              found\_89
             loc\_push
             ast\_push

             call              sym\_Number

       fail\! value\_clear
         ok\! value\_reduce      Term
             symbol\_save       Term
             error\_nonterminal Term
             ast\_pop\_rewind
             loc\_pop\_discard

    found\_89:
         ok\! ast\_value\_push
             return

    \#
    \#

# <a name='section5'></a>PEG serialization format

Here we specify the format used by the Parser Tools to serialize Parsing
Expression Grammars as immutable values for transport, comparison, etc\.

We distinguish between *regular* and *canonical* serializations\. While a PEG
may have more than one regular serialization only exactly one of them will be
*canonical*\.

  - regular serialization

    The serialization of any PEG is a nested Tcl dictionary\.

    This dictionary holds a single key, __pt::grammar::peg__, and its value\.
    This value holds the contents of the grammar\.

    The contents of the grammar are a Tcl dictionary holding the set of
    nonterminal symbols and the starting expression\. The relevant keys and their
    values are

           * __rules__

             The value is a Tcl dictionary whose keys are the names of the
             nonterminal symbols known to the grammar\.

             Each nonterminal symbol may occur only once\.

             The empty string is not a legal nonterminal symbol\.

             The value for each symbol is a Tcl dictionary itself\. The relevant
             keys and their values in this dictionary are

                    + __is__

                      The value is the serialization of the parsing expression
                      describing the symbols sentennial structure, as specified
                      in the section [PE serialization format](#section6)\.

                    + __mode__

                      The value can be one of three values specifying how a
                      parser should handle the semantic value produced by the
                      symbol\.

                        - __value__

                          The semantic value of the nonterminal symbol is an
                          abstract syntax tree consisting of a single node node
                          for the nonterminal itself, which has the ASTs of the
                          symbol's right hand side as its children\.

                        - __leaf__

                          The semantic value of the nonterminal symbol is an
                          abstract syntax tree consisting of a single node node
                          for the nonterminal, without any children\. Any ASTs
                          generated by the symbol's right hand side are
                          discarded\.

                        - __void__

                          The nonterminal has no semantic value\. Any ASTs
                          generated by the symbol's right hand side are
                          discarded \(as well\)\.

           * __start__

             The value is the serialization of the start parsing expression of
             the grammar, as specified in the section [PE serialization
             format](#section6)\.

    The terminal symbols of the grammar are specified implicitly as the set of
    all terminal symbols used in the start expression and on the RHS of the
    grammar rules\.

  - canonical serialization

    The canonical serialization of a grammar has the format as specified in the
    previous item, and then additionally satisfies the constraints below, which
    make it unique among all the possible serializations of this grammar\.

    The keys found in all the nested Tcl dictionaries are sorted in ascending
    dictionary order, as generated by Tcl's builtin command __lsort
    \-increasing \-dict__\.

    The string representation of the value is the canonical representation of a
    Tcl dictionary\. I\.e\. it does not contain superfluous whitespace\.

## <a name='subsection2'></a>Example

Assuming the following PEG for simple mathematical expressions

    PEG calculator \(Expression\)
        Digit      <\- '0'/'1'/'2'/'3'/'4'/'5'/'6'/'7'/'8'/'9'       ;
        Sign       <\- '\-' / '\+'                                     ;
        Number     <\- Sign? Digit\+                                  ;
        Expression <\- Term \(AddOp Term\)\*                            ;
        MulOp      <\- '\*' / '/'                                     ;
        Term       <\- Factor \(MulOp Factor\)\*                        ;
        AddOp      <\- '\+'/'\-'                                       ;
        Factor     <\- '\(' Expression '\)' / Number                   ;
    END;

then its canonical serialization \(except for whitespace\) is

    pt::grammar::peg \{
        rules \{
            AddOp      \{is \{/ \{t \-\} \{t \+\}\}                                                                mode value\}
            Digit      \{is \{/ \{t 0\} \{t 1\} \{t 2\} \{t 3\} \{t 4\} \{t 5\} \{t 6\} \{t 7\} \{t 8\} \{t 9\}\}                mode value\}
            Expression \{is \{x \{n Term\} \{\* \{x \{n AddOp\} \{n Term\}\}\}\}                                        mode value\}
            Factor     \{is \{/ \{x \{t \(\} \{n Expression\} \{t \)\}\} \{n Number\}\}                                  mode value\}
            MulOp      \{is \{/ \{t \*\} \{t /\}\}                                                                mode value\}
            Number     \{is \{x \{? \{n Sign\}\} \{\+ \{n Digit\}\}\}                                                 mode value\}
            Sign       \{is \{/ \{t \-\} \{t \+\}\}                                                                mode value\}
            Term       \{is \{x \{n Factor\} \{\* \{x \{n MulOp\} \{n Factor\}\}\}\}                                    mode value\}
        \}
        start \{n Expression\}
    \}

# <a name='section6'></a>PE serialization format

Here we specify the format used by the Parser Tools to serialize Parsing
Expressions as immutable values for transport, comparison, etc\.

We distinguish between *regular* and *canonical* serializations\. While a
parsing expression may have more than one regular serialization only exactly one
of them will be *canonical*\.

  - Regular serialization

      * __Atomic Parsing Expressions__

        The string __epsilon__ is an atomic parsing expression\. It matches
        the empty string\.

        The string __dot__ is an atomic parsing expression\. It matches any
        character\.

        The string __alnum__ is an atomic parsing expression\. It matches any
        Unicode alphabet or digit character\. This is a custom extension of PEs
        based on Tcl's builtin command __string is__\.

        The string __alpha__ is an atomic parsing expression\. It matches any
        Unicode alphabet character\. This is a custom extension of PEs based on
        Tcl's builtin command __string is__\.

        The string __ascii__ is an atomic parsing expression\. It matches any
        Unicode character below U0080\. This is a custom extension of PEs based
        on Tcl's builtin command __string is__\.

        The string __control__ is an atomic parsing expression\. It matches
        any Unicode control character\. This is a custom extension of PEs based
        on Tcl's builtin command __string is__\.

        The string __digit__ is an atomic parsing expression\. It matches any
        Unicode digit character\. Note that this includes characters outside of
        the \[0\.\.9\] range\. This is a custom extension of PEs based on Tcl's
        builtin command __string is__\.

        The string __graph__ is an atomic parsing expression\. It matches any
        Unicode printing character, except for space\. This is a custom extension
        of PEs based on Tcl's builtin command __string is__\.

        The string __lower__ is an atomic parsing expression\. It matches any
        Unicode lower\-case alphabet character\. This is a custom extension of PEs
        based on Tcl's builtin command __string is__\.

        The string __print__ is an atomic parsing expression\. It matches any
        Unicode printing character, including space\. This is a custom extension
        of PEs based on Tcl's builtin command __string is__\.

        The string __punct__ is an atomic parsing expression\. It matches any
        Unicode punctuation character\. This is a custom extension of PEs based
        on Tcl's builtin command __string is__\.

        The string __space__ is an atomic parsing expression\. It matches any
        Unicode space character\. This is a custom extension of PEs based on
        Tcl's builtin command __string is__\.

        The string __upper__ is an atomic parsing expression\. It matches any
        Unicode upper\-case alphabet character\. This is a custom extension of PEs
        based on Tcl's builtin command __string is__\.

        The string __wordchar__ is an atomic parsing expression\. It matches
        any Unicode word character\. This is any alphanumeric character \(see
        alnum\), and any connector punctuation characters \(e\.g\. underscore\)\. This
        is a custom extension of PEs based on Tcl's builtin command __string
        is__\.

        The string __xdigit__ is an atomic parsing expression\. It matches
        any hexadecimal digit character\. This is a custom extension of PEs based
        on Tcl's builtin command __string is__\.

        The string __ddigit__ is an atomic parsing expression\. It matches
        any decimal digit character\. This is a custom extension of PEs based on
        Tcl's builtin command __regexp__\.

        The expression \[list t __x__\] is an atomic parsing expression\. It
        matches the terminal string __x__\.

        The expression \[list n __A__\] is an atomic parsing expression\. It
        matches the nonterminal __A__\.

      * __Combined Parsing Expressions__

        For parsing expressions __e1__, __e2__, \.\.\. the result of \[list
        / __e1__ __e2__ \.\.\. \] is a parsing expression as well\. This is
        the *ordered choice*, aka *prioritized choice*\.

        For parsing expressions __e1__, __e2__, \.\.\. the result of \[list
        x __e1__ __e2__ \.\.\. \] is a parsing expression as well\. This is
        the *sequence*\.

        For a parsing expression __e__ the result of \[list \* __e__\] is a
        parsing expression as well\. This is the *kleene closure*, describing
        zero or more repetitions\.

        For a parsing expression __e__ the result of \[list \+ __e__\] is a
        parsing expression as well\. This is the *positive kleene closure*,
        describing one or more repetitions\.

        For a parsing expression __e__ the result of \[list & __e__\] is a
        parsing expression as well\. This is the *and lookahead predicate*\.

        For a parsing expression __e__ the result of \[list \! __e__\] is a
        parsing expression as well\. This is the *not lookahead predicate*\.

        For a parsing expression __e__ the result of \[list ? __e__\] is a
        parsing expression as well\. This is the *optional input*\.

  - Canonical serialization

    The canonical serialization of a parsing expression has the format as
    specified in the previous item, and then additionally satisfies the
    constraints below, which make it unique among all the possible
    serializations of this parsing expression\.

    The string representation of the value is the canonical representation of a
    pure Tcl list\. I\.e\. it does not contain superfluous whitespace\.

    Terminals are *not* encoded as ranges \(where start and end of the range
    are identical\)\.

## <a name='subsection3'></a>Example

Assuming the parsing expression shown on the right\-hand side of the rule

    Expression <\- Term \(AddOp Term\)\*

then its canonical serialization \(except for whitespace\) is

    \{x \{n Term\} \{\* \{x \{n AddOp\} \{n Term\}\}\}\}

# <a name='section7'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *pt* of the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[EBNF](\.\./\.\./\.\./\.\./index\.md\#ebnf), [LL\(k\)](\.\./\.\./\.\./\.\./index\.md\#ll\_k\_),
[PARAM](\.\./\.\./\.\./\.\./index\.md\#param), [PEG](\.\./\.\./\.\./\.\./index\.md\#peg),
[TDPL](\.\./\.\./\.\./\.\./index\.md\#tdpl), [context\-free
languages](\.\./\.\./\.\./\.\./index\.md\#context\_free\_languages),
[conversion](\.\./\.\./\.\./\.\./index\.md\#conversion),
[expression](\.\./\.\./\.\./\.\./index\.md\#expression), [format
conversion](\.\./\.\./\.\./\.\./index\.md\#format\_conversion),
[grammar](\.\./\.\./\.\./\.\./index\.md\#grammar),
[matching](\.\./\.\./\.\./\.\./index\.md\#matching),
[parser](\.\./\.\./\.\./\.\./index\.md\#parser), [parsing
expression](\.\./\.\./\.\./\.\./index\.md\#parsing\_expression), [parsing expression
grammar](\.\./\.\./\.\./\.\./index\.md\#parsing\_expression\_grammar), [push down
automaton](\.\./\.\./\.\./\.\./index\.md\#push\_down\_automaton), [recursive
descent](\.\./\.\./\.\./\.\./index\.md\#recursive\_descent),
[serialization](\.\./\.\./\.\./\.\./index\.md\#serialization),
[state](\.\./\.\./\.\./\.\./index\.md\#state), [top\-down parsing
languages](\.\./\.\./\.\./\.\./index\.md\#top\_down\_parsing\_languages),
[transducer](\.\./\.\./\.\./\.\./index\.md\#transducer)

# <a name='category'></a>CATEGORY

Parsing and Grammars

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>
