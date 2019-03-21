
[//000000001]: # (doctools_lang_syntax - Documentation tools)
[//000000002]: # (Generated from file 'doctools_lang_syntax.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (doctools_lang_syntax(n) 1.0 tcllib "Documentation tools")

# NAME

doctools_lang_syntax - doctools language syntax

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Description](#section1)

  -  [Fundamentals](#section2)

  -  [Lexical definitions](#section3)

  -  [Syntax](#section4)

  -  [Bugs, Ideas, Feedback](#section5)

  -  [See Also](#see-also)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

This document contains the formal specification of the syntax of the doctools
markup language, version 1 in Backus-Naur-Form. This document is intended to be
a reference, complementing the *[doctools language command
reference](doctools_lang_cmdref.md)*. A beginner should read the much more
informally written *[doctools language introduction](doctools_lang_intro.md)*
first before trying to understand either this document or the command reference.

# <a name='section2'></a>Fundamentals

In the broadest terms possible the *doctools markup language* is LaTeX-like,
instead of like SGML and similar languages. A document written in this language
consists primarily of text, with markup commands embedded into it.

Each markup command is a just Tcl command surrounded by a matching pair of __[__
and __]__. Which commands are available, and their arguments, i.e. syntax is
specified in the *[doctools language command
reference](doctools_lang_cmdref.md)*.

In this document we specify first the lexeme, and then the syntax, i.e. how we
can mix text and markup commands with each other.

# <a name='section3'></a>Lexical definitions

In the syntax rules listed in the next section

  1. <TEXT> stands for all text except markup commands.

  1. Any XXX stands for the markup command [xxx] including its arguments. Each
     markup command is a Tcl command surrounded by a matching pair of __[__ and
     __]__. Inside of these delimiters the usual rules for a Tcl command apply
     with regard to word quotation, nested commands, continuation lines, etc.

  1. <WHITE> stands for all text consisting only of spaces, newlines, tabulators
     and the __[comment](../../../../index.md#comment)__ markup command.

# <a name='section4'></a>Syntax

The rules listed here specify only the syntax of doctools documents. The lexical
level of the language was covered in the previous section.

Regarding the syntax of the (E)BNF itself

  1. The construct { X } stands for zero or more occurrences of X.

  1. The construct [ X ] stands for zero or one occurrence of X.

  1. The construct LIST_BEGIN<X> stands for the markup command __list_begin__
     with __X__ as its type argument.

The syntax:

    manpage = defs
              MANPAGE_BEGIN
              header
              DESCRIPTION
              body
              MANPAGE_END
              { <WHITE> }

    defs    = { INCLUDE | VSET | <WHITE> }

    header  = { TITLEDESC | MODDESC | COPYRIGHT | REQUIRE | defs | xref }

    xref    = KEYWORDS | SEE_ALSO | CATEGORY

    body    = paras { SECTION    sbody  }
    sbody   = paras { SUBSECTION ssbody }
    ssbody  = paras

    paras   = tblock { (PARA | NL) tblock }

    tblock  = { <TEXT> | defs | markup | xref | an_example | a_list }

    markup  = ARG     | CLASS | CMD     | CONST     | EMPH   | FILE
            | FUN     | LB    | METHOD  | NAMESPACE | OPT    | OPTION
            | PACKAGE | RB    | SECTREF | STRONG    | SYSCMD | TERM
            | TYPE    | URI   | USAGE   | VAR       | WIDGET

    example = EXAMPLE
            | EXAMPLE_BEGIN extext EXAMPLE_END

    extext  = { <TEXT> | defs | markup }

    a_list  = LIST_BEGIN<arguments>   argd_list   LIST_END
            | LIST_BEGIN<commands>    cmdd_list   LIST_END
            | LIST_BEGIN<definitions> def_list    LIST_END
            | LIST_BEGIN<enumerated>  enum_list   LIST_END
            | LIST_BEGIN<itemized>    item_list   LIST_END
            | LIST_BEGIN<options>     optd_list   LIST_END
            | LIST_BEGIN<tkoptions>   tkoptd_list LIST_END

    argd_list   = [ <WHITE> ] { ARG_DEF      paras }
    cmdd_list   = [ <WHITE> ] { CMD_DEF      paras }
    def_list    = [ <WHITE> ] { (DEF|CALL)   paras }
    enum_list   = [ <WHITE> ] { ENUM         paras }
    item_list   = [ <WHITE> ] { ITEM         paras }
    optd_list   = [ <WHITE> ] { OPT_DEF      paras }
    tkoptd_list = [ <WHITE> ] { TKOPTION_DEF paras }

# <a name='section5'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *doctools* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='see-also'></a>SEE ALSO

[doctools_intro](doctools_intro.md),
[doctools_lang_cmdref](doctools_lang_cmdref.md),
[doctools_lang_faq](doctools_lang_faq.md),
[doctools_lang_intro](doctools_lang_intro.md)

# <a name='keywords'></a>KEYWORDS

[doctools commands](../../../../index.md#doctools_commands), [doctools
language](../../../../index.md#doctools_language), [doctools
markup](../../../../index.md#doctools_markup), [doctools
syntax](../../../../index.md#doctools_syntax),
[markup](../../../../index.md#markup), [semantic
markup](../../../../index.md#semantic_markup)

# <a name='category'></a>CATEGORY

Documentation tools

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007 Andreas Kupries <andreas_kupries@users.sourceforge.net>
