
[//000000001]: # (docidx_lang_cmdref - Documentation tools)
[//000000002]: # (Generated from file 'docidx_lang_cmdref.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (docidx_lang_cmdref(n) 1.0 tcllib "Documentation tools")

# NAME

docidx_lang_cmdref - docidx language command reference

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [Commands](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [See Also](#see-also)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

[__[comment](../../../../index.md#comment)__ *plaintext*](#1)  
[__include__ *filename*](#2)  
[__index_begin__ *text* *title*](#3)  
[__index_end__](#4)  
[__key__ *text*](#5)  
[__lb__](#6)  
[__[manpage](../../../../index.md#manpage)__ *file* *text*](#7)  
[__rb__](#8)  
[__[url](../../../../index.md#url)__ *url* *label*](#9)  
[__vset__ *varname* *value*](#10)  
[__vset__ *varname*](#11)  

# <a name='description'></a>DESCRIPTION

This document specifies both names and syntax of all the commands which together
are the docidx markup language, version 1. As this document is intended to be a
reference the commands are listed in alphabetical order, and the descriptions
are relatively short. A beginner should read the much more informally written
*[docidx language introduction](docidx_lang_intro.md)* first.

# <a name='section2'></a>Commands

  - <a name='1'></a>__[comment](../../../../index.md#comment)__ *plaintext*

    Index markup. The argument text is marked up as a comment standing outside
    of the actual text of the document. Main use is in free-form text.

  - <a name='2'></a>__include__ *filename*

    Templating. The contents of the named file are interpreted as text written
    in the docidx markup and processed in the place of the include command. The
    markup in the file has to be self-contained. It is not possible for a markup
    command to cross the file boundaries.

  - <a name='3'></a>__index_begin__ *text* *title*

    Document structure. The command to start an index. The arguments are a label
    for the whole group of documents the index refers to (*text*) and the
    overall title text for the index (*title*), without markup.

    The label often is the name of the package (or extension) the documents
    belong to.

  - <a name='4'></a>__index_end__

    Document structure. Command to end an index. Anything in the document coming
    after this command is in error.

  - <a name='5'></a>__key__ *text*

    Index structure. This command adds the keyword *text* to the index.

  - <a name='6'></a>__lb__

    Text. The command is replaced with a left bracket. Use in free-form text.
    Required to avoid interpretation of a left bracket as the start of a markup
    command. Its usage is restricted to the arguments of other markup commands.

  - <a name='7'></a>__[manpage](../../../../index.md#manpage)__ *file* *text*

    Index structure. This command adds an element to the index which refers to a
    document. The document is specified through the symbolic name *file*. The
    *text* argument is used to label the reference.

    Symbolic names are used to preserve the convertibility of this format to any
    output format. The actual name of the file will be inserted by the chosen
    formatting engine when converting the input. This will be based on a mapping
    from symbolic to actual names given to the engine.

  - <a name='8'></a>__rb__

    Text. The command is replaced with a right bracket. Use in free-form text.
    Required to avoid interpretation of a right bracket as the end of a markup
    command. Its usage is restricted to the arguments of other commands.

  - <a name='9'></a>__[url](../../../../index.md#url)__ *url* *label*

    Index structure. This is the second command to add an element to the index.
    To refer to a document it is not using a symbolic name however, but a
    (possibly format-specific) url describing the exact location of the document
    indexed here.

  - <a name='10'></a>__vset__ *varname* *value*

    Templating. In this form the command sets the named document variable to the
    specified *value*. It does not generate output. I.e. the command is replaced
    by the empty string.

  - <a name='11'></a>__vset__ *varname*

    Templating. In this form the command is replaced by the value of the named
    document variable

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

[docidx_intro](docidx_intro.md), [docidx_lang_faq](docidx_lang_faq.md),
[docidx_lang_intro](docidx_lang_intro.md),
[docidx_lang_syntax](docidx_lang_syntax.md)

# <a name='keywords'></a>KEYWORDS

[docidx commands](../../../../index.md#docidx_commands), [docidx
language](../../../../index.md#docidx_language), [docidx
markup](../../../../index.md#docidx_markup),
[markup](../../../../index.md#markup), [semantic
markup](../../../../index.md#semantic_markup)

# <a name='category'></a>CATEGORY

Documentation tools

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007 Andreas Kupries <andreas_kupries@users.sourceforge.net>
