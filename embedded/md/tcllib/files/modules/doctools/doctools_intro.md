
[//000000001]: # (doctools_intro - Documentation tools)
[//000000002]: # (Generated from file 'doctools_intro.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (doctools_intro(n) 1.0 tcllib "Documentation tools")

# NAME

doctools_intro - doctools introduction

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Description](#section1)

  -  [RELATED FORMATS](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [See Also](#see-also)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

*[doctools](../../../../index.md#doctools)* (short for *documentation tools*)
stands for a set of related, yet different, entities which are working together
for the easy creation and transformation of documentation. These are

  1. A tcl based language for the semantic markup of text. Markup is represented
     by Tcl commands interspersed with the actual text.

  1. A package providing the ability to read and transform texts written in that
     markup language. It is important to note that the actual transformation of
     the input text is delegated to plugins.

  1. An API describing the interface between the package above and a plugin.

Which of the more detailed documents are relevant to the reader of this
introduction depends on their role in the documentation process.

  1. A *writer* of documentation has to understand the markup language itself. A
     beginner to doctools should read the more informally written *[doctools
     language introduction](doctools_lang_intro.md)* first. Having digested this
     the formal *[doctools language syntax](doctools_lang_syntax.md)*
     specification should become understandable. A writer experienced with
     doctools may only need the *[doctools language command
     reference](doctools_lang_cmdref.md)* from time to time to refresh her
     memory.

     While a document is written the __[dtplite](../../apps/dtplite.md)__
     application can be used to validate it, and after completion it also
     performs the conversion into the chosen system of visual markup, be it
     *roff, HTML, plain text, wiki, etc.

  1. A *processor* of documentation written in the
     *[doctools](../../../../index.md#doctools)* markup language has to know
     which tools are available for use.

     The main tool is the aforementioned __[dtplite](../../apps/dtplite.md)__
     application provided by Tcllib. A more powerful one (in terms of options
     and ability to configure it) is the __dtp__ application, provided by
     Tclapps. At the bottom level, common to both applications, however sits the
     package __[doctools](doctools.md)__, providing the basic facilities to read
     and process files containing text in the doctools format.

  1. At last, but not least, *plugin writers* have to understand the interaction
     between the __[doctools](doctools.md)__ package and its plugins, as
     described in the *[doctools plugin API
     reference](doctools_plugin_apiref.md)*.

# <a name='section2'></a>RELATED FORMATS

doctools does not stand alone, it has two companion formats. These are called
*[docidx](../../../../index.md#docidx)* and
*[doctoc](../../../../index.md#doctoc)*, and they are for the markup of *keyword
indices*, and *tables of contents*, respectively. They are described in their
own sets of documents, starting at the *[docidx introduction](docidx_intro.md)*
and the *[doctoc introduction](doctoc_intro.md)*, respectively.

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

[docidx_intro](docidx_intro.md), [doctoc_intro](doctoc_intro.md),
[doctools](doctools.md), [doctools_lang_cmdref](doctools_lang_cmdref.md),
[doctools_lang_faq](doctools_lang_faq.md),
[doctools_lang_intro](doctools_lang_intro.md),
[doctools_lang_syntax](doctools_lang_syntax.md),
[doctools_plugin_apiref](doctools_plugin_apiref.md)

# <a name='keywords'></a>KEYWORDS

[markup](../../../../index.md#markup), [semantic
markup](../../../../index.md#semantic_markup)

# <a name='category'></a>CATEGORY

Documentation tools

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007 Andreas Kupries <andreas_kupries@users.sourceforge.net>
