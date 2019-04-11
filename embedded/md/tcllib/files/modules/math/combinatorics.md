
[//000000001]: # (math::combinatorics \- Tcl Math Library)
[//000000002]: # (Generated from file 'combinatorics\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (math::combinatorics\(n\) 1\.2\.3 tcllib "Tcl Math Library")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

math::combinatorics \- Combinatorial functions in the Tcl Math Library

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [COMMANDS](#section2)

  - [Bugs, Ideas, Feedback](#section3)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.2  
package require math ?1\.2\.3?  

[__::math::ln\_Gamma__ *z*](#1)  
[__::math::factorial__ *x*](#2)  
[__::math::choose__ *n k*](#3)  
[__::math::Beta__ *z w*](#4)  

# <a name='description'></a>DESCRIPTION

The __[math](math\.md)__ package contains implementations of several
functions useful in combinatorial problems\.

# <a name='section2'></a>COMMANDS

  - <a name='1'></a>__::math::ln\_Gamma__ *z*

    Returns the natural logarithm of the Gamma function for the argument *z*\.

    The Gamma function is defined as the improper integral from zero to positive
    infinity of

        t**(x-1)*exp(-t) dt

    The approximation used in the Tcl Math Library is from Lanczos, *ISIAM J\.
    Numerical Analysis, series B,* volume 1, p\. 86\. For "__x__ > 1", the
    absolute error of the result is claimed to be smaller than 5\.5\*10\*\*\-10 \-\-
    that is, the resulting value of Gamma when

        exp( ln_Gamma( x) )

    is computed is expected to be precise to better than nine significant
    figures\.

  - <a name='2'></a>__::math::factorial__ *x*

    Returns the factorial of the argument *x*\.

    For integer *x*, 0 <= *x* <= 12, an exact integer result is returned\.

    For integer *x*, 13 <= *x* <= 21, an exact floating\-point result is
    returned on machines with IEEE floating point\.

    For integer *x*, 22 <= *x* <= 170, the result is exact to 1 ULP\.

    For real *x*, *x* >= 0, the result is approximated by computing
    *Gamma\(x\+1\)* using the __::math::ln\_Gamma__ function, and the result
    is expected to be precise to better than nine significant figures\.

    It is an error to present *x* <= \-1 or *x* > 170, or a value of *x*
    that is not numeric\.

  - <a name='3'></a>__::math::choose__ *n k*

    Returns the binomial coefficient *C\(n, k\)*

        C(n,k) = n! / k! (n-k)!

    If both parameters are integers and the result fits in 32 bits, the result
    is rounded to an integer\.

    Integer results are exact up to at least *n* = 34\. Floating point results
    are precise to better than nine significant figures\.

  - <a name='4'></a>__::math::Beta__ *z w*

    Returns the Beta function of the parameters *z* and *w*\.

        Beta(z,w) = Beta(w,z) = Gamma(z) * Gamma(w) / Gamma(z+w)

    Results are returned as a floating point number precise to better than nine
    significant digits provided that *w* and *z* are both at least 1\.

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *math* of the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='category'></a>CATEGORY

Mathematics
