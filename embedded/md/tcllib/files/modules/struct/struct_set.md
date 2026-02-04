
[//000000001]: # (struct::set \- Tcl Data Structures)
[//000000002]: # (Generated from file 'struct\_set\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2004\-2008 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (struct::set\(n\) 2\.2\.5 tcllib "Tcl Data Structures")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

struct::set \- Commands for manipulating sets

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [COMMANDS](#section2)

  - [EXAMPLES](#section3)

  - [REFERENCES](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require struct::set ?2\.2\.4?  

[__::struct::set__ __empty__ *set*](#1)  
[__::struct::set__ __size__ *set*](#2)  
[__::struct::set__ __contains__ *set* *value*](#3)  
[__::struct::set__ __union__ ?*set1*\.\.\.?](#4)  
[__::struct::set__ __intersect__ ?*set1*\.\.\.?](#5)  
[__::struct::set__ __difference__ *set1* *set2*](#6)  
[__::struct::set__ __symdiff__ *set1* *set2*](#7)  
[__::struct::set__ __intersect3__ *set1* *set2*](#8)  
[__::struct::set__ __equal__ *set1* *set2*](#9)  
[__::struct::set__ __include__ *setVar* *value*](#10)  
[__::struct::set__ __exclude__ *setVar* *value*](#11)  
[__::struct::set__ __add__ *setVar* *set*](#12)  
[__::struct::set__ __subtract__ *setVar* *set*](#13)  
[__::struct::set__ __subsetof__ *A* *B*](#14)  

# <a name='description'></a>DESCRIPTION

The __::struct::set__ namespace contains several useful commands for
processing finite sets\.

It exports only a single command, __struct::set__\. All the functionality is
available through this command’s subcommands\.

A new empty set can be created using __::struct::set add__ *setVar \{\}*\.

*Note:* As of version 2\.2 of this package a critcl based C implementation will
be used where available, with Tcl 8\.4 or later\.

# <a name='section2'></a>COMMANDS

In the following, *set*, *set1*, and *set2* are __set__ values and
*setVar* is a __set__’s variable name\.

  - <a name='1'></a>__::struct::set__ __empty__ *set*

    Returns __1__ \(true\) if the *set* is empty; otherwise returns
    __0__ \(false\)\.

  - <a name='2'></a>__::struct::set__ __size__ *set*

    Returns the *set*’s cardinality, i\.e\., the number of elements in the
    *set*\. This could be zero\.

  - <a name='3'></a>__::struct::set__ __contains__ *set* *value*

    Returns __1__ \(true\) if the *set* contains the element *value*;
    otherwise returns __0__ \(false\)\.

  - <a name='4'></a>__::struct::set__ __union__ ?*set1*\.\.\.?

    Returns a __set__ consisting of the union of the given __set__s,
    i\.e\. *set1* ∪ *set2* ∪ …\. The resulting __set__ will contain every
    value in every given __set__, with no duplicates\.

  - <a name='5'></a>__::struct::set__ __intersect__ ?*set1*\.\.\.?

    Returns a __set__ consisting of the intersection of the given
    __set__s, i\.e\. *set1* ∩ *set2* ∩ …\. The resulting __set__ will
    contain every value that *every* one of the given __set__s has in
    common, with no duplicates\.

  - <a name='6'></a>__::struct::set__ __difference__ *set1* *set2*

    Returns a __set__ consisting of the difference between *set1* and
    *set2*, i\.e\., *set1* \- *set2*\. The resulting __set__ will contain
    every value that is in *set1* but that is *not* in *set2*\.

  - <a name='7'></a>__::struct::set__ __symdiff__ *set1* *set2*

    Returns a __set__ consisting of the symmetric difference between
    *set1* and *set2*, i\.e\., *set1* Δ *set2*\. The resulting __set__
    will contain every value that is in *set1* *or* is in *set2*, but
    *not* in both\.

  - <a name='8'></a>__::struct::set__ __intersect3__ *set1* *set2*

    Returns a combination of the methods __intersect__ and
    __difference__\.

    The return value is a three\-element list containing "*set1* ∩ *set2*",
    "*set1* \- *set2*", and "*set2* \- *set1*", in this order\. In other
    words, the intersection of *set1* and *set2*, and their differences\.

  - <a name='9'></a>__::struct::set__ __equal__ *set1* *set2*

    Returns __1__ \(true\) if the two __set__s contain exactly the same
    values; otherwise returns __0__ \(false\)\.

  - <a name='10'></a>__::struct::set__ __include__ *setVar* *value*

    Adds element *value* to the __set__ called *setVar*, creating
    *setVar* if it doesn’t exist\. Harmlessly does nothing if *value* is
    already in __set__ *setVar*\. Returns nothing\. This command can be used
    to create new __set__s\.

  - <a name='11'></a>__::struct::set__ __exclude__ *setVar* *value*

    Removes element *value* from the __set__ called *setVar*\. If
    *value* isn’t in *setVar*, the command harmlessly does nothing\. Returns
    nothing\.

  - <a name='12'></a>__::struct::set__ __add__ *setVar* *set*

    Adds every element from the __set__ value *set* to the __set__
    called *setVar*, excluding duplicates\. The __set__ *setVar* is
    created if it doesn’t exist\. Returns nothing\.

    Use __::struct::set add__ *setVar \{\}* to create a new empty set\. Use
    __::struct::set include__ to add individual values\.

  - <a name='13'></a>__::struct::set__ __subtract__ *setVar* *set*

    Removes every element from the __set__ value *set* from the
    __set__ called *setVar*\. Returns nothing\. Use __::struct::set
    exclude__ to remove individual values\.

  - <a name='14'></a>__::struct::set__ __subsetof__ *A* *B*

    Returns __1__ \(true\) if *A* ⊆ *B*, i\.e\., if __set__ *A* is a
    true subset of or equal to the __set__ *B*; otherwise returns
    __0__ \(false\)\.

# <a name='section3'></a>EXAMPLES

Creating and populating a new __set__ from scratch\. The __earth\_metals__
__set__ will be created on the first iteration of the loop and added to on
subsequent iterations\.

    foreach element {Be Mg Ca Sr Ba Ra} {
        struct::set include earth_metals $element
    }

Creating a __set__ by unioning a couple of existing __set__s\.

    set metals [struct::set union $alkali_metals $earth_metals]

Querying a __set__’s properties\.

    if {[struct::set empty $metals]} {
        puts "empty"
    } else {
        puts "[struct::set size $metals] elements"
    }

# <a name='section4'></a>REFERENCES

# <a name='section5'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *struct :: set*
as the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[cardinality](\.\./\.\./\.\./\.\./index\.md\#cardinality),
[difference](\.\./\.\./\.\./\.\./index\.md\#difference),
[emptiness](\.\./\.\./\.\./\.\./index\.md\#emptiness),
[exclusion](\.\./\.\./\.\./\.\./index\.md\#exclusion),
[inclusion](\.\./\.\./\.\./\.\./index\.md\#inclusion),
[intersection](\.\./\.\./\.\./\.\./index\.md\#intersection),
[membership](\.\./\.\./\.\./\.\./index\.md\#membership),
[set](\.\./\.\./\.\./\.\./index\.md\#set), [symmetric
difference](\.\./\.\./\.\./\.\./index\.md\#symmetric\_difference),
[union](\.\./\.\./\.\./\.\./index\.md\#union)

# <a name='category'></a>CATEGORY

Data structures

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2004\-2008 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>
