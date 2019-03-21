
[//000000001]: # (doctoc_lang_intro - Documentation tools)
[//000000002]: # (Generated from file 'doctoc_lang_intro.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (doctoc_lang_intro(n) 1.0 tcllib "Documentation tools")

# NAME

doctoc_lang_intro - doctoc language introduction

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Description](#section1)

      -  [Fundamentals](#subsection1)

      -  [Basic structure](#subsection2)

      -  [Items](#subsection3)

      -  [Divisions](#subsection4)

      -  [Advanced structure](#subsection5)

      -  [Escapes](#subsection6)

  -  [FURTHER READING](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [See Also](#see-also)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

This document is an informal introduction to version 1.1 of the doctoc markup
language based on a multitude of examples. After reading this a writer should be
ready to understand the two parts of the formal specification, i.e. the *[doctoc
language syntax](doctoc_lang_syntax.md)* specification and the *[doctoc language
command reference](doctoc_lang_cmdref.md)*.

## <a name='subsection1'></a>Fundamentals

While the *doctoc markup language* is quite similar to the *doctools markup
language*, in the broadest terms possible, there is one key difference. A table
of contents consists essentially only of markup commands, with no plain text
interspersed between them, except for whitespace.

Each markup command is a Tcl command surrounded by a matching pair of __[__ and
__]__. Inside of these delimiters the usual rules for a Tcl command apply with
regard to word quotation, nested commands, continuation lines, etc. I.e.

    ... [division_start {Appendix 1}] ...

    ... [item thefile \\
            label {file description}] ...

## <a name='subsection2'></a>Basic structure

The most simple document which can be written in doctoc is

    [toc_begin GROUPTITLE TITLE]
    [toc_end]

This also shows us that all doctoc documents consist of only one part where we
will list *items* and *divisions*.

The user is free to mix these as she sees fit. This is a change from version 1
of the language, which did not allow this mixing, but only the use of either a
series of items or a series of divisions.

We will discuss the commands for each of these two possibilities in the next
sections.

## <a name='subsection3'></a>Items

Use the command __item__ to put an *item* into a table of contents. This is
essentially a reference to a section, subsection, etc. in the document, or set
of documents, the table of contents is for. The command takes three arguments, a
symbolic name for the file the item is for and two text to label the item and
describe the referenced section.

Symbolic names are used to preserve the convertibility of this format to any
output format. The actual name of any file will be inserted by the chosen
formatting engine when converting the input, based on a mapping from symbolic to
actual names given to the engine.

Here a made up example for a table of contents of this document:

    [toc_begin Doctoc {Language Introduction}]
    [__item 1 DESCRIPTION__]
    [__item 1.1 {Basic structure}__]
    [__item 1.2 Items__]
    [__item 1.3 Divisions__]
    [__item 2 {FURTHER READING}__]
    [toc_end]

## <a name='subsection4'></a>Divisions

One thing of notice in the last example in the previous section is that the
referenced sections actually had a nested structure, something which was
expressed in the item labels, by using a common prefix for all the sections
nested under section 1.

This kind of structure can be made more explicit in the doctoc language by using
divisions. Instead of using a series of plain items we use a series of divisions
for the major references, and then place the nested items inside of these.

Of course, instead of the nested items we can again use divisions and thus nest
arbitrarily deep.

A division is marked by two commands instead of one, one to start it, the other
to close the last opened division. They are:

  - __division_start__

    This command opens a new division. It takes one or two arguments, the title
    of the division, and the symbolic name of the file it refers to. The latter
    is optional. If the symbolic filename is present then the section title
    should link to the referenced document, if links are supported by the output
    format.

  - __division_end__

    This command closes the last opened and not yet closed division.

Using this we can recast the last example like this

    [toc_begin Doctoc {Language Introduction}]
    [__division_start DESCRIPTION__]
    [item 1 {Basic structure}]
    [item 2 Items]
    [item 3 Divisions]
    [__division_end__]
    [__division_start {FURTHER READING}__]
    [__division_end__]
    [toc_end]

Or, to demonstrate deeper nesting

    [toc_begin Doctoc {Language Introduction}]
    [__division_start DESCRIPTION__]
    [__division_start {Basic structure}__]
    [item 1 Do]
    [item 2 Re]
    [__division_end__]
    [__division_start Items__]
    [item a Fi]
    [item b Fo]
    [item c Fa]
    [__division_end__]
    [__division_start Divisions__]
    [item 1 Sub]
    [item 1 Zero]
    [__division_end__]
    [__division_end__]
    [__division_start {FURTHER READING}__]
    [__division_end__]
    [toc_end]

And do not forget, it is possible to freely mix items and divisions, and to have
empty divisions.

    [toc_begin Doctoc {Language Introduction}]
    [item 1 Do]
    [__division_start DESCRIPTION__]
    [__division_start {Basic structure}__]
    [item 2 Re]
    [__division_end__]
    [item a Fi]
    [__division_start Items__]
    [item b Fo]
    [item c Fa]
    [__division_end__]
    [__division_start Divisions__]
    [__division_end__]
    [__division_end__]
    [__division_start {FURTHER READING}__]
    [__division_end__]
    [toc_end]

## <a name='subsection5'></a>Advanced structure

In all previous examples we fudged a bit regarding the markup actually allowed
to be used before the __toc_begin__ command opening the document.

Instead of only whitespace the two templating commands __include__ and __vset__
are also allowed, to enable the writer to either set and/or import configuration
settings relevant to the table of contents. I.e. it is possible to write

    [__include FILE__]
    [__vset VAR VALUE__]
    [toc_begin GROUPTITLE TITLE]
    ...
    [toc_end]

Even more important, these two commands are allowed anywhere where a markup
command is allowed, without regard for any other structure.

    [toc_begin GROUPTITLE TITLE]
    [__include FILE__]
    [__vset VAR VALUE__]
    ...
    [toc_end]

The only restriction __include__ has to obey is that the contents of the
included file must be valid at the place of the inclusion. I.e. a file included
before __toc_begin__ may contain only the templating commands __vset__ and
__include__, a file included in a division may contain only items or divisions
commands, etc.

## <a name='subsection6'></a>Escapes

Beyond the 6 commands shown so far we have two more available. However their
function is not the marking up of toc structure, but the insertion of
characters, namely __[__ and __]__. These commands, __lb__ and __rb__
respectively, are required because our use of [ and ] to bracket markup commands
makes it impossible to directly use [ and ] within the text.

Our example of their use are the sources of the last sentence in the previous
paragraph, with some highlighting added.

    ...
    These commands, [cmd lb] and [cmd lb] respectively, are required
    because our use of [__lb__] and [__rb__] to bracket markup commands makes it
    impossible to directly use [__lb__] and [__rb__] within the text.
    ...

# <a name='section2'></a>FURTHER READING

Now that this document has been digested the reader, assumed to be a *writer* of
documentation should be fortified enough to be able to understand the formal
*[doctoc language syntax](doctoc_lang_syntax.md)* specification as well. From
here on out the *[doctoc language command reference](doctoc_lang_cmdref.md)*
will also serve as the detailed specification and cheat sheet for all available
commands and their syntax.

To be able to validate a document while writing it, it is also recommended to
familiarize oneself with Tclapps' ultra-configurable __dtp__.

On the other hand, doctoc is perfectly suited for the automatic generation from
doctools documents, and this is the route Tcllib's easy and simple
__[dtplite](../../apps/dtplite.md)__ goes, creating a table of contents for a
set of documents behind the scenes, without the writer having to do so on their
own.

# <a name='section3'></a>Bugs, Ideas, Feedback

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
[doctoc_lang_syntax](doctoc_lang_syntax.md)

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

Copyright &copy; 2007 Andreas Kupries <andreas_kupries@users.sourceforge.net>
