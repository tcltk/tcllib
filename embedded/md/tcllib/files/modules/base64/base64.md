
[//000000001]: # (base64 \- Text encoding & decoding binary data)
[//000000002]: # (Generated from file 'base64\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2000, Eric Melski)
[//000000004]: # (Copyright &copy; 2001, Miguel Sofer)
[//000000005]: # (base64\(n\) 2\.4\.2 tcllib "Text encoding & decoding binary data")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

base64 \- base64\-encode/decode binary data

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [EXAMPLES](#section2)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8  
package require base64 ?2\.4\.2?  

[__::base64::encode__ ?__\-maxlen__ *maxlen*? ?__\-wrapchar__ *wrapchar*? *string*](#1)  
[__::base64::decode__ *string*](#2)  

# <a name='description'></a>DESCRIPTION

This package provides procedures to encode binary data into base64 and back\.

  - <a name='1'></a>__::base64::encode__ ?__\-maxlen__ *maxlen*? ?__\-wrapchar__ *wrapchar*? *string*

    Base64 encodes the given binary *string* and returns the encoded result\.
    Inserts the character *wrapchar* every *maxlen* characters of output\.
    *wrapchar* defaults to newline\. *maxlen* defaults to __76__\.

    *Note* that if *maxlen* is set to __0__, the output will not be
    wrapped at all\.

    *Note well*: If your string is not simple ascii you should fix the string
    encoding before doing base64 encoding\. See the examples\.

    The command will throw an error for negative values of *maxlen*, or if
    *maxlen* is not an integer number\.

  - <a name='2'></a>__::base64::decode__ *string*

    Base64 decodes the given *string* and returns the binary data\. The decoder
    ignores whitespace in the string\.

# <a name='section2'></a>EXAMPLES

    % base64::encode "Hello, world"
    SGVsbG8sIHdvcmxk

    % base64::encode [string repeat xyz 20]
    eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6
    eHl6eHl6eHl6
    % base64::encode -wrapchar "" [string repeat xyz 20]
    eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6eHl6

    # NOTE: base64 encodes BINARY strings.
    % set chemical [encoding convertto utf-8 "C\u2088H\u2081\u2080N\u2084O\u2082"]
    % set encoded [base64::encode $chemical]
    Q+KCiEjigoHigoBO4oKET+KCgg==
    % set caffeine [encoding convertfrom utf-8 [base64::decode $encoded]]

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *base64* of the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[base64](\.\./\.\./\.\./\.\./index\.md\#base64),
[encoding](\.\./\.\./\.\./\.\./index\.md\#encoding)

# <a name='category'></a>CATEGORY

Text processing

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2000, Eric Melski  
Copyright &copy; 2001, Miguel Sofer
