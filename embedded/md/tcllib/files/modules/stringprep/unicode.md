
[//000000001]: # (unicode \- Unicode normalization)
[//000000002]: # (Generated from file 'unicode\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2007, Sergei Golovan <sgolovan@nes\.ru>)
[//000000004]: # (unicode\(n\) 1\.1\.1 tcllib "Unicode normalization")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

unicode \- Implementation of Unicode normalization

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Commands](#section2)

  - [Examples](#section3)

      - [Legacy examples](#subsection1)

  - [References](#section4)

  - [Authors](#section5)

  - [Bugs, Ideas, Feedback](#section6)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require unicode 1\.1\.1  

[__::unicode::normalizeS__ *form* *string*](#1)  
[__::unicode::fromstring__ *string*](#2)  
[__::unicode::tostring__ *codepointsList*](#3)  
[__::unicode::normalize__ *form* *codepointsList*](#4)  

# <a name='description'></a>DESCRIPTION

This is a Tcl implementation of Unicode normalization commands\.

*Note* that if normalization alone is insufficient \(e\.g\., for string
comparisons\), the __[stringprep](stringprep\.md)__ package may prove
useful\.

# <a name='section2'></a>Commands

The *form* argument in the commands listed below must be a string that has one
of the following values: __D__ \(canonical decomposition\), __C__
\(canonical decomposition, followed by canonical composition\), __KD__
\(compatibility decomposition\), or __KC__ \(compatibility decomposition,
followed by canonical composition\)\.

  - <a name='1'></a>__::unicode::normalizeS__ *form* *string*

    Returns a possibly modified copy of *string*, normalized in accordance
    with the given *form*\.

    This is a convenience for:

    *::unicode::tostring* \[*unicode::normalize $form*
    \[*::unicode::fromstring $string*\]\]\.

  - <a name='2'></a>__::unicode::fromstring__ *string*

    Returns a list of integer Unicode code points representing the characters in
    *string*\.

    \(These integer code points are used in __unicode__ for internal string
    representation\.\)

  - <a name='3'></a>__::unicode::tostring__ *codepointsList*

    Returns a string whose characters are those corresponding to the
    *codepointsList* of integers\.

    Every integer that is a valid Unicode code point is represented in the
    returned string by the corresponding Unicode character\. Any integer that is
    not a valid Unicode code point is represented using the Unicode replacement
    character �, U\+FFFD, unless it is sufficiently big, in which case an error
    is thrown\.

  - <a name='4'></a>__::unicode::normalize__ *form* *codepointsList*

    Returns a possibly modified copy of the *codepointsList* of integers
    \(which must all be valid Unicode code points\), normalized according to the
    given normalization *form*\.

# <a name='section3'></a>Examples

Some Unicode characters have more than one representation in a Unicode encoding
such as UTF\-8\. Normally, this is not a problem *within* a programming
language, since the language will typically always use the same representation
for any given character\. But for data read in from files or other external
sources, any of the possible representations could be used\. So in these cases
normalization may be needed\.

Here is an example of the problem:

    set a "Å"
    set b "\u212B"
    set c [encoding convertfrom utf-8 \xC3\x85]
    set d [encoding convertfrom utf-8 \xE2\x84\xAB]
    set e [encoding convertfrom utf-8 \x41\xCC\x8A]
    set s [join [list $a $b $c $d $e] ""]
    puts "s=$s a=b→[expr {$a eq $b}] a=c→[expr {$a eq $c}] a=d→[expr {$a eq $d}] a=e→[expr {$a eq $e}] b=c→[expr {$a eq $d}] b=d→[expr {$a eq $d}] b=e→[expr {$a eq $e}] c=d→[expr {$a eq $d}] c=e→[expr {$a eq $e}]"
    =>
    s=ÅÅÅÅÅ a=b→0 a=c→1 a=d→0 a=e→0 b=c→0 b=d→0 b=e→0 c=d→0 c=e→0

The above output shows that although all the characters are the same, they have
different UTF\-8 representations and do *not* compare equal\.

The solution is to normalize\. For example:

    set t [unicode::normalizeS KC $s]
    set a [string index $t 0]
    set b [string index $t 1]
    set c [string index $t 2]
    set d [string index $t 3]
    set e [string index $t 4]
    puts "t=$t a=b→[expr {$a eq $b}] a=c→[expr {$a eq $c}] a=d→[expr {$a eq $d}] a=e→[expr {$a eq $e}] b=c→[expr {$a eq $d}] b=d→[expr {$a eq $d}] b=e→[expr {$a eq $e}] c=d→[expr {$a eq $d}] c=e→[expr {$a eq $e}]"
    =>
    t=ÅÅÅÅÅ a=b→1 a=c→1 a=d→1 a=e→1 b=c→1 b=d→1 b=e→1 c=d→1 c=e→1

After normalization all the characters have the same representation and
correctly compare as equal\.

## <a name='subsection1'></a>Legacy examples

    % ::unicode::fromstring "\u0410\u0411\u0412\u0413"
    1040 1041 1042 1043
    % ::unicode::tostring {49 50 51 52 53}
    12345
    %

    % ::unicode::normalize D {7692 775}
    68 803 775
    % ::unicode::normalizeS KD "\u1d2c"
    A
    %

# <a name='section4'></a>References

  1. "Unicode Standard Annex \#15: Unicode Normalization Forms",
     \([http://unicode\.org/reports/tr15/](http://unicode\.org/reports/tr15/)\)

# <a name='section5'></a>Authors

Sergei Golovan

# <a name='section6'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *stringprep* as
the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

[stringprep\(n\)](stringprep\.md)

# <a name='keywords'></a>KEYWORDS

[normalization](\.\./\.\./\.\./\.\./index\.md\#normalization),
[unicode](\.\./\.\./\.\./\.\./index\.md\#unicode)

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007, Sergei Golovan <sgolovan@nes\.ru>
