
[//000000001]: # (textutil::adjust \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'adjust\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil::adjust\(n\) 0\.7\.4 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil::adjust \- Procedures to adjust, indent, and undent paragraphs

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Examples](#section3)

      - [Justifying](#subsection1)

      - [Indenting and Unindenting](#subsection2)

  - [Bugs, Ideas, Feedback](#section4)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require textutil::adjust ?0\.7\.4?  

[__::textutil::adjust::adjust__ *string* ?*option value \.\.\.*?](#1)  
[__::textutil::adjust::readPatterns__ *filename*](#2)  
[__::textutil::adjust::listPredefined__](#3)  
[__::textutil::adjust::getPredefined__ *filename*](#4)  
[__::textutil::adjust::indent__ *string* *prefix* ?*skip*?](#5)  
[__::textutil::adjust::undent__ *string*](#6)  

# <a name='description'></a>DESCRIPTION

The __textutil::adjust__ package provides commands to indent, unindent, and
justify the text held in a string\.

# <a name='section2'></a>API

  - <a name='1'></a>__::textutil::adjust::adjust__ *string* ?*option value \.\.\.*?

    Returns a copy of *string* modified according to the given options\.

    Any newlines in the original *string* are treated as spaces, i\.e\., the
    input *string* is handled as a single paragraph of text\. If the result
    string is shorter than the __\-length__, it will not contain any
    newlines\. Otherwise, the result will contain newlines as needed to perform
    the desired justification\.

    Together with __::textutil::adjust::indent__ it is possible to create
    properly wrapped paragraphs with arbitrary indentations\.

    Under the hood, every newline, tab, or sequence of two or more spaces are
    treated as a single space, and single spaces are used to separate the line’s
    words\. These are the algorithm’s *real* lines\. Every *real* line is
    placed in a *logical* line, which is exactly __\-length__ characters
    wide \(even if the *real* line is shorter\)\. Every word in a *real* line
    is separated by a single space, except when the __\-justify__
    __plain__ option is used, in which case words are separated by one or
    more spaces as needed to fill the *real* line\.

    By default, trailing spaces \(including tabs which are first replaced by
    spaces\) are trimmed\. See the __\-full__ option below\.

    The following options may be given after the *string* parameter\. They
    control how the command places each *real* line in its corresponding
    *logical* line\.

      * __\-full__ *boolean*

        If set to __0__ \(false; the default\), any trailing spaces are
        deleted from each line before returning the string\. If set to __1__
        \(true\), any trailing spaces are left at the end each line\.

      * __\-hyphenate__ *boolean*

        If set to __0__ \(false; the default\), no hyphenation will be done\.
        If set to __1__ \(true\), the command will try to hyphenate the last
        word of each line when appropriate\.

        If __\-hyphenate__ is set to __1__, hyphenation patterns *must*
        have been loaded by calling the __::textutil::adjust::readPatterns__
        command, *before* the call to __::textutil::adjust::adjust__;
        otherwise __::textutil::adjust::adjust__ will throw an error\.

      * __\-justify__ __center&#124;left&#124;plain&#124;right__

        Sets the justification applied to the returned string to any one of:
        __left__ \(the default\), __center__, __plain__ \(justified\),
        or __right__\. The justification means that any line in the returned
        string \(possibly excluding the last line\), is justified according to the
        given justification\.

        If the justification is set to __plain__ \(justified\), and the number
        of printable characters in the last line is less than 90% of
        __\-length__, then the last line is justified __left__, avoiding
        the padding of this line when it is too short\. The meaning of each value
        is:

          + __center__

            Each *real* line is centered in the *logical* line by padding
            the *real* line with spaces at the beginning and end as needed\. If
            the last line is less than 90% of __\-length__, it will be
            aligned __left__ instead of __center__\. \(See also the
            __\-full__ option\.\)

          + __left__

            Each *real* line is placed at the left of the *logical* line,
            with no preceding spaces\. If __\-full__ is __1__ \(true\), the
            *real* line will be padded with spaces at the end to make it
            __\-length__ characters wide\.

          + __plain__

            Each line is fully justified\. This means that each *real* line’s
            words are placed in the *logical* line, separated by one or more
            spaces, as needed to completely fill the line with no leading or
            trailing spaces\.

          + __right__

            Each *real* line is placed at the right of the *logical* line,
            with no trailing spaces, and padded with leading spaces if needed to
            make the *real* line __\-length__ characters wide\.

      * __\-length__ *integer*

        Sets the *logical* line length to be *integer*\. The *integer* must
        be a positive integer *> 0*\. The default is __72__\.

      * __\-strictlength__ *boolean*

        If set to __0__ \(false; the default\), a line can exceed the
        specified __\-length__ if a single word is longer than
        __\-length__\. If set to __1__ \(true\), words that are longer than
        __\-length__ are split so that no line exceeds the specified
        __\-length__\.

  - <a name='2'></a>__::textutil::adjust::readPatterns__ *filename*

    Reads hyphenation patterns from the file called *filename*\.

    This command is needed only if command __::textutil::adjust::adjust__ is
    used with __\-hyphenate__ __1__ \(true\)\. In this case the call to
    __::textutil::adjust::readPatterns__ *must* be done *before* calling
    __::textutil::adjust::adjust__\.

    The __textutil::adjust__ package comes with a number of predefined
    pattern files\. Use the __::textutil::adjust::listPredefined__ command to
    list their names\.

  - <a name='3'></a>__::textutil::adjust::listPredefined__

    Returns a list of the names of the hyphenation files provided by this
    package\.

  - <a name='4'></a>__::textutil::adjust::getPredefined__ *filename*

    Returns the full path and filename of the *filename* hyphenation file\.
    *Note* that *filename* *must* be one of the names returned by
    __::textutil::adjust::listPredefined__\.

  - <a name='5'></a>__::textutil::adjust::indent__ *string* *prefix* ?*skip*?

    Returns a modified copy of *string* with every non\-skipped line prefixed
    with *prefix* and whitespace \(except for the newline\), trimmed from the
    end\. By default no lines are skipped, so all are prefixed\.

    The __skip__ option specifies how many lines to skip at the start of the
    string; its default is __0__, in which case none are skipped and all are
    prefixed\. If __skip__ is set to a value *> 0*, then that many initial
    lines in the string are skipped, i\.e\., not prefixed, while all the
    subsequent lines are prefixed\. Setting __skip__ to __1__ will create
    a conventional hanging indent\.

    Together with __::textutil::adjust::adjust__ it is possible to create
    properly wrapped paragraphs with arbitrary indentations\.

  - <a name='6'></a>__::textutil::adjust::undent__ *string*

    Returns a modified copy of *string* with any common prefix of whitespace
    removed from each line\.

    Empty lines and lines containing only whitespace are ignored for the
    computation of the prefix and all these lines are returned as empty lines\.

    *Note that this command’s name is* __undent__ *not* *unindent\.*

# <a name='section3'></a>Examples

The following examples show some of the __::textutil::adjust__ package’s
commands in action\.

The following __[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ and __const__
are used by the examples below\.

    proc replace_spc {s {sub ▴}} { regsub -all { } $s $sub }
    const LINES "Four\nsiamese cats\nheard barks\nand bolted."

The __replace\_spc__ command replaces every space in the string it is passed
with the ▴ symbol\. The __LINES__ constant provides some text for the
examples to work with\.  

## <a name='subsection1'></a>Justifying

The following example show every justification option in use\. Spaces have been
made visible by preserving them using __\-full__ __1__ and replacing them
with the ▴ symbol\.

Normally, __\-full__ would *not* be used and there would be *no* trailing
spaces in each line\.

    set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify left]
    puts "======= left =======\n[replace_spc $lines]"
    set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify center]
    puts "====== center ======\n[replace_spc $lines]"
    set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify plain]
    puts "======= plain ======\n[replace_spc $lines]"
    set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify right]
    puts "======= right ======\n[replace_spc $lines]"
    =>
    ======= left =======
    Four▴siamese▴cats▴▴▴
    heard▴barks▴and▴▴▴▴▴
    bolted.▴▴▴▴▴▴▴▴▴▴▴▴▴

    ====== center ======
    ▴▴Four▴siamese▴cats▴
    ▴▴▴heard▴barks▴and▴▴
    ▴▴▴▴▴▴▴bolted.▴▴▴▴▴▴

    ======= plain ======
    Four▴siamese▴▴▴▴cats
    heard▴▴▴barks▴▴▴▴and
    bolted.▴▴▴▴▴▴▴▴▴▴▴▴▴

    ======= right ======
    ▴▴▴Four▴siamese▴cats
    ▴▴▴▴▴heard▴barks▴and
    ▴▴▴▴▴▴▴▴▴▴▴▴▴bolted.

## <a name='subsection2'></a>Indenting and Unindenting

In the following example leading spaces have been made visible by using an
indent of __··__ rather than, say, two spaces, and other spaces have been
made visible by replacing them with the ▴ symbol\. There are no trailing spaces
since __textutil::adjust::indent__ trims them\.

    set lines [textutil::adjust::adjust $LINES -length 20 -justify left]
    puts "======== left =========\n[replace_spc $lines]"
    set indented [textutil::adjust::indent $lines "··"]
    puts "======== indent =======\n[replace_spc $indented]"
    # undent only unindents spaces
    set indented [regsub -all · $indented " "]
    set unindented [textutil::adjust::undent $indented]
    puts "======== undent =======\n[replace_spc $unindented]"
    set hanging [textutil::adjust::indent $lines "··" 1]
    puts "==== hanging indent ===\n[replace_spc $hanging]"
    =>
    ======== left =========
    Four▴siamese▴cats
    heard▴barks▴and
    bolted.
    ======== indent =======
    ··Four▴siamese▴cats
    ··heard▴barks▴and
    ··bolted.
    ======== undent =======
    Four▴siamese▴cats
    heard▴barks▴and
    bolted.
    ==== hanging indent ===
    Four▴siamese▴cats
    ··heard▴barks▴and
    ··bolted.

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *textutil* as
the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

regexp\(n\), split\(n\), string\(n\)

# <a name='keywords'></a>KEYWORDS

[TeX](\.\./\.\./\.\./\.\./index\.md\#tex),
[adjusting](\.\./\.\./\.\./\.\./index\.md\#adjusting),
[formatting](\.\./\.\./\.\./\.\./index\.md\#formatting),
[hyphenation](\.\./\.\./\.\./\.\./index\.md\#hyphenation),
[indenting](\.\./\.\./\.\./\.\./index\.md\#indenting),
[justification](\.\./\.\./\.\./\.\./index\.md\#justification),
[paragraph](\.\./\.\./\.\./\.\./index\.md\#paragraph),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[undenting](\.\./\.\./\.\./\.\./index\.md\#undenting)

# <a name='category'></a>CATEGORY

Text processing
