
[//000000001]: # (textutil \- Text and string utilities, macro processing)
[//000000002]: # (Generated from file 'textutil\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (textutil\(n\) 0\.10 tcllib "Text and string utilities, macro processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

textutil \- Procedures to manipulate texts and strings\.

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Examples](#section3)

      - [Adjust](#subsection1)

      - [Justifying](#subsection2)

      - [Indenting and Unindenting](#subsection3)

      - [Repeat](#subsection4)

      - [Split](#subsection5)

      - [String](#subsection6)

      - [Tabify](#subsection7)

      - [Trim](#subsection8)

  - [Bugs, Ideas, Feedback](#section4)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require textutil ?0\.10?  

[__::textutil::adjust::adjust__ *string* ?*option value \.\.\.*?](#1)  
[__::textutil::adjust::readPatterns__ *filename*](#2)  
[__::textutil::adjust::listPredefined__](#3)  
[__::textutil::adjust::getPredefined__ *filename*](#4)  
[__::textutil::adjust::indent__ *string* *prefix* ?*skip*?](#5)  
[__::textutil::adjust::undent__ *string*](#6)  
[__::textutil::repeat::strRepeat__ *text* *count*](#7)  
[__::textutil::repeat::blank__ *count*](#8)  
[__::textutil::split::splitn__ *string* ?*size*?](#9)  
[__::textutil::split::splitx__ *string* ?*regexp*?](#10)  
[__::textutil::string::chop__ *string*](#11)  
[__::textutil::string::tail__ *string*](#12)  
[__::textutil::string::cap__ *string*](#13)  
[__::textutil::string::capEachWord__ *string*](#14)  
[__::textutil::string::uncap__ *string*](#15)  
[__::textutil::string::longestCommonPrefixList__ *list*](#16)  
[__::textutil::string::longestCommonPrefix__ ?*string*\.\.\.?](#17)  
[__::textutil::tabify::tabify__ *string* ?*count*?](#18)  
[__::textutil::tabify::tabify2__ *string* ?*count*?](#19)  
[__::textutil::tabify::untabify__ *string* ?*count*?](#20)  
[__::textutil::tabify::untabify2__ *string* ?*count*?](#21)  
[__::textutil::trim::trim__ *string* ?*regexp*?](#22)  
[__::textutil::trim::trimleft__ *string* ?*regexp*?](#23)  
[__::textutil::trim::trimright__ *string* ?*regexp*?](#24)  
[__::textutil::trim::trimPrefix__ *string* *prefix*](#25)  
[__::textutil::trim::trimEmptyHeading__ *string*](#26)  

# <a name='description'></a>DESCRIPTION

The __textutil__ package provides commands that manipulate strings\. This
package is a bundle providing the commands of the six subpackages listed below,
all of which are in the __textutil__ namespace\.

  - __[textutil::adjust](adjust\.md)__

  - __[textutil::repeat](repeat\.md)__

  - __[textutil::split](textutil\_split\.md)__

  - __[textutil::string](textutil\_string\.md)__

  - __[textutil::tabify](tabify\.md)__

  - __[textutil::trim](trim\.md)__

The bundle is *deprecated*, and it will be removed in a future Tcllib release\.
Instead of using this package, package require specific subpackages as needed\.

For convenience, all of the __textutil__ namespace’s commands shown above
are described in the [API](#section2) section below, in addition to being
documented in the subpackages themselves\.

*Note* that the following subpackages are also in the __textutil__
namespace but are not part of the bundle, so they must be specifically package
required as needed\.

  - __[textutil::expander](expander\.md)__

  - __[textutil::patch](patch\.md)__

  - __[textutil::wcswidth](wcswidth\.md)__

The __textutil__ namespace’s commands shown above are described only in the
subpackages themselves\.

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

    The __[textutil::adjust](adjust\.md)__ package comes with a number of
    predefined pattern files\. Use the __::textutil::adjust::listPredefined__
    command to list their names\.

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

  - <a name='7'></a>__::textutil::repeat::strRepeat__ *text* *count*

    Returns a string containing the *text* repeated *count* times\.

    The repetitions are joined with no separators between them\. A value of
    *count* *<= 0* causes the command to return an empty string\.

    *Note*: If the Tcl core this package is loaded in provides the __string
    repeat__ command, then this command will be implemented in its terms, for
    maximum speed\. Otherwise a fast Tcl implementation is used\.

  - <a name='8'></a>__::textutil::repeat::blank__ *count*

    Returns a string containing *count* spaces\.

    This is a convenience for calling __::textutil::repeat::strRepeat__ with
    __" "__ as its first argument\.

  - <a name='9'></a>__::textutil::split::splitn__ *string* ?*size*?

    Returns a list of strings containing consecutive substrings of *string*,
    each *size* long—except for the last which will be shorter if *string*’s
    length is not an exact multiple of *size*\. The *size* defaults to
    __1__, i\.e\., return a list of *string*’s characters; this is the same
    as calling the built\-in
    [split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html) command with
    a second argument of __""__\.

    If *string* is empty, an empty list is returned\. If *size* *<= 0*, an
    error will be thrown\.

  - <a name='10'></a>__::textutil::split::splitx__ *string* ?*regexp*?

    Returns a list of strings containing consecutive substrings of *string*
    split according to the *regexp* regular expression which defaults to *\[\\t
    \\r\\n\]\+* \(tabs, spaces, newlines\)\.

    *Note*: If *regexp* contains capturing parentheses, then the captured
    groups will be included in the result list as additional elements\.

    If *string* is empty, an empty list is returned\. If *regexp* is empty,
    the *string* is split at every character; this is the same as calling the
    built\-in [split](https://www\.tcl\-lang\.org/man/tcl/TclCmd/split\.html)
    command with a second argument of __""__\.

  - <a name='11'></a>__::textutil::string::chop__ *string*

    Returns a copy of *string* with the last character removed\.

  - <a name='12'></a>__::textutil::string::tail__ *string*

    Returns a copy of *string* with the first character removed\.

  - <a name='13'></a>__::textutil::string::cap__ *string*

    Returns a copy of *string* with the first character capitalized\.

  - <a name='14'></a>__::textutil::string::capEachWord__ *string*

    Returns a copy of *string* with the first character of every word
    capitalized\.

  - <a name='15'></a>__::textutil::string::uncap__ *string*

    Returns a copy of *string* with the first character lowercased\.

  - <a name='16'></a>__::textutil::string::longestCommonPrefixList__ *list*

    Returns the longest common prefix of the strings in the given *list*\.

    If no argument is given, the empty string is returned\.

  - <a name='17'></a>__::textutil::string::longestCommonPrefix__ ?*string*\.\.\.?

    Returns the longest common prefix of the string arguments, *string*, …\.

    If a single string is given, it is returned since it is its own longest
    common prefix\. If no argument is given, the empty string is returned\.

  - <a name='18'></a>__::textutil::tabify::tabify__ *string* ?*count*?

    Returns a copy of *string* with any substring of *count* space
    characters replaced by a horizontal tab\. The *count* defaults to 8\.

  - <a name='19'></a>__::textutil::tabify::tabify2__ *string* ?*count*?

    Returns a copy of *string* with substrings of *count* *or fewer* space
    characters replaced by a horizontal tab using a text editor like algorithm\.
    The *count* defaults to 8\.

    The algorithm used by this command treats each line in *string* as if it
    had notional tabstops every *count* columns\. \(So, if *count* is
    __8__, at columns __8__, __16__, __24__, …\.\) Only sequences
    of *two or more* space characters that occur immediately before a notional
    tabstop are replaced with a tab\.

  - <a name='20'></a>__::textutil::tabify::untabify__ *string* ?*count*?

    Returns a copy of *string* with every horizontal tab replaced by *count*
    spaces\. The *count* defaults to 8\.

  - <a name='21'></a>__::textutil::tabify::untabify2__ *string* ?*count*?

    Returns a copy of *string* with horizontal tabs replaced by *count* *or
    fewer* space characters using a text editor like algorithm\. The *count*
    defaults to 8\.

    This command is the counterpart to __::textutil::tabify::tabify2__\. The
    algorithm used by this command treats each line in *string* as if it had
    notional tabstops every *count* columns\. \(So, if *count* is __8__,
    at columns __8__, __16__, __24__, …\.\) Instead of blindly
    replacing each horizontal tab with *count* spaces, each horizontal tab at
    a notional tabstop is replaced by enough spaces to reach the next notional
    tabstop\.

    There is one asymmetry though: A tab may be replaced by a single space, but
    not the other way around\.

  - <a name='22'></a>__::textutil::trim::trim__ *string* ?*regexp*?

    Returns a copy of *string* with any leading or trailing substring that
    matches *regexp* removed from the *string* if does not contain newlines,
    or from *every line* within the *string* if it contains newlines\. The
    *regexp* defaults to *\[ \\t\]\+*\. This default will remove leading and
    trailing spaces and tabs from the *string* if it does not contain
    newlines, or from *every line* within the *string* if it contains
    newlines\.

  - <a name='23'></a>__::textutil::trim::trimleft__ *string* ?*regexp*?

    Returns a copy of *string* with any leading substring that matches
    *regexp* removed from the *string* if does not contain newlines, or from
    *every line* within the *string* if it contains newlines\. The *regexp*
    defaults to *\[ \\t\]\+*\. This default will remove leading spaces and tabs
    from the *string* if it does not contain newlines, or from *every line*
    within the *string* if it contains newlines\.

  - <a name='24'></a>__::textutil::trim::trimright__ *string* ?*regexp*?

    Returns a copy of *string* with any trailing substring that matches
    *regexp* removed from the *string* if does not contain newlines, or from
    *every line* within the *string* if it contains newlines\. The *regexp*
    defaults to *\[ \\t\]\+*\. This default will remove trailing spaces and tabs
    from the *string* if it does not contain newlines, or from *every line*
    within the *string* if it contains newlines\.

  - <a name='25'></a>__::textutil::trim::trimPrefix__ *string* *prefix*

    Returns a copy of *string* with *prefix* removed from the start if it is
    present; otherwise returns *string* unchanged\.

    Contrast this command with the built\-in
    [string](https://www\.tcl\-lang\.org/man/tcl/TclCmd/string\.html) command’s
    __trim__, __trimleft__, __trimright__ subcommands which remove
    all characters in a given set of characters passed as a string\.

  - <a name='26'></a>__::textutil::trim::trimEmptyHeading__ *string*

    Returns a copy of *string* with any leading blank lines \(including lines
    containing only whitespace\) removed\.

# <a name='section3'></a>Examples

## <a name='subsection1'></a>Adjust

The following examples show some of the __::textutil::adjust__ package’s
commands in action\.

The following __[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ and __const__
are used by the examples below\.

    proc replace_spc {s {sub ▴}} { regsub -all { } $s $sub }
    const LINES "Four\nsiamese cats\nheard barks\nand bolted."

The __replace\_spc__ command replaces every space in the string it is passed
with the ▴ symbol\. The __LINES__ constant provides some text for the
examples to work with\.  

## <a name='subsection2'></a>Justifying

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

## <a name='subsection3'></a>Indenting and Unindenting

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

## <a name='subsection4'></a>Repeat

This tiny example shows the __::textutil::repeat__ package’s commands in
action\.

    puts [::textutil::repeat::strRepeat = 22]
    puts =[::textutil::repeat::blank 20]=
    =>
    ======================
    =                    =

## <a name='subsection5'></a>Split

The following examples show some of the __::textutil::split__ package’s
commands in action\.

To help make the examples’ effects more visible, each element of the returned
lists is bracketed using ❬ and ❭\. For non\-UTF\-8 aware editors these can be
replaced with __\\u276C__ and __\\u276D__\.

This first example shows how to split strings by size\.

    const LINE1 "α and ℤ"
    set chars [::textutil::split::splitn $LINE1] ;# splits into characters
    puts ❬[join $chars "❭ ❬"]❭
    set chars [split $LINE1 ""] ;# splits into characters
    puts ❬[join $chars "❭ ❬"]❭
    set chunks [::textutil::split::splitn $LINE1 3]
    puts ❬[join $chunks "❭ ❬"]❭
    =>
    ❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
    ❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
    ❬α a❭ ❬nd ❭ ❬ℤ❭

This second example shows how to split strings by regexp\.

    const LINE2 "a, be , cat, done , eagle"
    set chunks [::textutil::split::splitx $LINE2] ;# splits on [\t \r\n]+
    puts ❬[join $chunks "❭ ❬"]❭
    set chunks [::textutil::split::splitx $LINE2 {\s*,\s*}]
    puts ❬[join $chunks "❭ ❬"]❭
    set chunks [::textutil::split::splitx $LINE2 {\s*(,)\s*}]
    puts ❬[join $chunks "❭ ❬"]❭
    =>
    ❬a,❭ ❬be❭ ❬,❭ ❬cat,❭ ❬done❭ ❬,❭ ❬eagle❭
    ❬a❭ ❬be❭ ❬cat❭ ❬done❭ ❬eagle❭
    ❬a❭ ❬,❭ ❬be❭ ❬,❭ ❬cat❭ ❬,❭ ❬done❭ ❬,❭ ❬eagle❭

## <a name='subsection6'></a>String

The following examples show some of the __::textutil::string__ package’s
commands in action\.

This first example shows all the commands that work on a single string\.

    const LINE "has the σαβ cogs"
    puts "“$LINE” const"
    set line [::textutil::string::chop $LINE]
    puts "“$line” chop"
    set line [::textutil::string::tail $line]
    puts "“$line” tail"
    set line [::textutil::string::cap $line]
    puts "“$line” cap"
    set line [::textutil::string::capEachWord $line]
    puts "“$line” capEachWord"
    set line [::textutil::string::uncap $line]
    puts "“$line” uncap"
    =>
    “has the σαβ cogs” const
    “has the σαβ cog” chop
    “as the σαβ cog” tail
    “As the σαβ cog” cap
    “As The Σαβ Cog” capEachWord
    “as The Σαβ Cog” uncap

This example shows the longest common prefix commands in use\.

    const LIST [list handbag handcuff handful handle handy]
    puts “[::textutil::string::longestCommonPrefixList $LIST]”
    puts “[::textutil::string::longestCommonPrefix king queen knave]”
    puts “[::textutil::string::longestCommonPrefix king kin kind kinks]”
    =>
    “hand”
    “”
    “kin”

This example shows how to use the
__::textutil::string::longestCommonPrefixList__ command to find the common
path from a list of paths\.

    proc longestCommonPath paths {
        const SEP [file separator]
        set path [::textutil::string::longestCommonPrefixList $paths]
        if {[string index $path end] ne $SEP} {
            if {[set j [string last $SEP $path]] > -1} {
                set path [string range $path 0 $j-1]
            }
        }
        if {$path ne $SEP} { set path [string trimright $path $SEP] }
        return $path
    }

    const PATHS [list /home/sally/music /home/sally/museums /home/sally/musings]
    puts [::textutil::string::longestCommonPrefixList $PATHS]
    puts [longestCommonPath $PATHS]
    puts [longestCommonPath [list /bin / /sbin]]
    =>
    /home/sally/mus
    /home/sally
    /

## <a name='subsection7'></a>Tabify

The following examples show some of the __::textutil::tabify__ package’s
commands in action\.

The examples make use of a tiny helper command to make spaces and tabs distinct
and visible:

    proc replace_tab_spc s { regsub -all { } [regsub -all \t $s →] ▴ }

This example shows the __::textutil::tabify::tabify__ command in action\.

    const LINES1 "    if \{\$x\} \{\n        puts 1\n    \}"
    puts "=== original ===\n[replace_tab_spc $LINES1]\n"
    set tabbed [::textutil::tabify::tabify $LINES1]
    puts "=== 8spc→tab ===\n[replace_tab_spc $tabbed]\n"
    set tabbed [::textutil::tabify::tabify $LINES1 4]
    puts "=== 4spc→tab ===\n[replace_tab_spc $tabbed]\n"
    =>
    === original ===
    ▴▴▴▴if▴{$x}▴{
    ▴▴▴▴▴▴▴▴puts▴1
    ▴▴▴▴}

    === 8spc→tab ===
    ▴▴▴▴if▴{$x}▴{
    →puts▴1
    ▴▴▴▴}

    === 4spc→tab ===
    →if▴{$x}▴{
    →→puts▴1
    →}

## <a name='subsection8'></a>Trim

The following examples show some of the __::textutil::trim__ package’s
commands in action\.

The following __[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ is used by some of
the examples below\.

    proc replace_ws s { regsub -all { } [regsub -all \t [regsub -all \n $s ⏎] →] ▴ }

This example shows the use of __::textutil::trim::trimEmptyHeading__ and
__::textutil::trim::trim__\.

    const LINES1 "\t\n Alpha\t\n Beta \t\n Gamma \t\n"
    puts "== const =============================\n[replace_ws $LINES1]"
    set line [::textutil::trim::trimEmptyHeading $LINES1]
    puts "== textutil::trim::trimEmptyHeading ==\n[replace_ws $line]"
    set line [string trimleft $LINES1]
    puts "== string trimleft ===================\n[replace_ws $line]"
    set line [::textutil::trim::trim $LINES1]
    puts "== textutil::trim::trim ==============\n[replace_ws $line]"
    =>
    == const =============================
    →⏎▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == textutil::trim::trimEmptyHeading ==
    ▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == string trimleft ===================
    Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
    == textutil::trim::trim ==============
    ⏎Alpha⏎Beta⏎Gamma⏎

Notice the subtle difference in behavior between
__::textutil::trim::trimEmptyHeading__ and __string trimleft__\.

This example shows the use of the built\-in __string trim__ in combination
with and __::textutil::trim::trim__\.

    const LINES2 [string trim "\t\n Delta\t\n Epsilon \t\n Zeta \t\n"]
    puts "== const =============================\n[replace_ws $LINES2]"
    set line [::textutil::trim::trim $LINES2]
    puts "== textutil::trim::trim ==============\n[replace_ws $line]"
    =>
    == const =============================
    Delta→⏎▴Epsilon▴→⏎▴Zeta
    == textutil::trim::trim ==============
    Delta⏎Epsilon⏎Zeta

This example contrasts the built\-in __string trim__ with
__::textutil::trim::trimPrefix__\.

    const PATH /home/homer
    puts "const='$PATH'"
    puts "string trim \$PATH /home='[string trim $PATH /home]'"
    puts "string trim \$PATH /home='[string trim $PATH ehmo/]'"
    puts "::textutil::trim::trimPrefix \$PATH /home='[::textutil::trim::trimPrefix $PATH /home]'"
    const LINE mimic
    puts "string trim \$LINE mic='[string trim $LINE mic]'"
    puts "::textutil::trim::trimPrefix \$LINE mic='[::textutil::trim::trimPrefix $LINE mic]'"
    =>
    const='/home/homer'
    string trim $PATH /home='r'
    string trim $PATH /home='r'
    ::textutil::trim::trimPrefix $PATH /home='/homer'
    string trim $LINE mic=''
    ::textutil::trim::trimPrefix $LINE mic='mimic'

For the __PATH__ examples, the __string trim__ command trims all the
individual characters that are in the string "/home", i\.e\., "/", "h", "o", "m",
"e"\. The order of the characters in the string don’t matter as the "ehmo/"
example shows\. Compare this with __::textutil::trim::trimPrefix__ which
trims the literal string "/home"\.

For the __LINE__ examples, the __string trim__ command trims all the
individual characters that are in the string "mic", i\.e\., "m", "i", "c"\. Compare
this with __::textutil::trim::trimPrefix__ which trims the literal string
"mic"; but since the __LINE__ doesn’t start with "mic", nothing is trimmed
and the string is returned unchanged\.

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
[formatting](\.\./\.\./\.\./\.\./index\.md\#formatting),
[hyphenation](\.\./\.\./\.\./\.\./index\.md\#hyphenation),
[indenting](\.\./\.\./\.\./\.\./index\.md\#indenting),
[paragraph](\.\./\.\./\.\./\.\./index\.md\#paragraph), [regular
expression](\.\./\.\./\.\./\.\./index\.md\#regular\_expression),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[trimming](\.\./\.\./\.\./\.\./index\.md\#trimming)

# <a name='category'></a>CATEGORY

Text processing
