
[//000000001]: # (doctoc_lang_syntax - Documentation tools)
[//000000002]: # (Generated from file 'doctoc_lang_syntax.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (doctoc_lang_syntax(n) 1.0 tcllib "Documentation tools")

# NAME

doctoc_lang_syntax - doctoc language syntax

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

This document contains the formal specification of the syntax of the doctoc
markup language, version 1.1 in Backus-Naur-Form. This document is intended to
be a reference, complementing the *[doctoc language command
reference](doctoc_lang_cmdref.md)*. A beginner should read the much more
informally written *[doctoc language introduction](doctoc_lang_intro.md)* first
before trying to understand either this document or the command reference.

# <a name='section2'></a>Fundamentals

In the broadest terms possible the *doctoc markup language* is like SGML and
similar languages. A document written in this language consists primarily of
markup commands, with text embedded into it at some places.

Each markup command is a just Tcl command surrounded by a matching pair of __[__
and __]__. Which commands are available, and their arguments, i.e. syntax is
specified in the *[doctoc language command reference](doctoc_lang_cmdref.md)*.

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

The rules listed here specify only the syntax of doctoc documents. The lexical
level of the language was covered in the previous section.

Regarding the syntax of the (E)BNF itself

  1. The construct { X } stands for zero or more occurrences of X.

  1. The construct [ X ] stands for zero or one occurrence of X.

The syntax:

    toc       = defs
                TOC_BEGIN
                contents
                TOC_END
                { <WHITE> }

    defs      = { INCLUDE | VSET | <WHITE> }
    contents  = { defs entry } [ defs ]

    entry     = ITEM | division

    division  = DIVISION_START
                contents
                DIVISION_END

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

[doctoc_intro](doctoc_intro.md), [doctoc_lang_cmdref](doctoc_lang_cmdref.md),
[doctoc_lang_faq](doctoc_lang_faq.md), [doctoc_lang_intro](doctoc_lang_intro.md)

# <a name='keywords'></a>KEYWORDS

[doctoc commands](../../../../index.md#doctoc_commands), [doctoc
language](../../../../index.md#doctoc_language), [doctoc
markup](../../../../index.md#doctoc_markup), [doctoc
syntax](../../../../index.md#doctoc_syntax),
[markup](../../../../index.md#markup), [semantic
markup](../../../../index.md#semantic_markup)

# <a name='category'></a>CATEGORY

Documentation tools

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007-2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
