
[//000000001]: # (struct::disjointset \- Tcl Data Structures)
[//000000002]: # (Generated from file 'disjointset\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (struct::disjointset\(n\) 1\.2 tcllib "Tcl Data Structures")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

struct::disjointset \- Disjoint set data structure

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

      - [Methods](#subsection1)

  - [Examples](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.6 9  
package require struct::disjointset ?1\.2?  

[__::struct::disjointset__ *aDisjointSet*](#1)  
[*aDisjointSet* __add\-element__ *element*](#2)  
[*aDisjointSet* __add\-partition__ *elements*](#3)  
[*aDisjointSet* __partitions__](#4)  
[*aDisjointSet* __num\-partitions__](#5)  
[*aDisjointSet* __equal__ *a* *b*](#6)  
[*aDisjointSet* __merge__ *a* *b*](#7)  
[*aDisjointSet* __find__ *element*](#8)  
[*aDisjointSet* __exemplars__](#9)  
[*aDisjointSet* __find\-exemplar__ *element*](#10)  
[*aDisjointSet* __destroy__](#11)  

# <a name='description'></a>DESCRIPTION

This package provides a command for handling [disjoint
sets](http://en\.wikipedia\.org/wiki/Disjoint\_set\_data\_structure)\. Alternative
names for this kind of data structure are *union\-find* and *merge\-find*\.

A common use case for ordinary sets is to be able to answer the question, “does
set S contain element E?”\. The answer is a simple Boolean\.

One common use case for disjoint sets is to be able to answer the question,
“which of sets S₁, S₂, …, Sₙ contains element E?”\. The answer is a set—or
nothing, if none of the sets contains E\.

Another common use case for disjoint sets is to be able to quickly merge two
sets into one, with the resultant set still fast for finding elements\. Hence the
term *merge\-find*\.

The reason this data structure is called a *[disjoint
set](\.\./\.\./\.\./\.\./index\.md\#disjoint\_set)* is because it can be perceived as
being a *single* set with *partitions*\. In other words a disjoint set is:

  - a finite *[set](\.\./\.\./\.\./\.\./index\.md\#set)* S, containing

  - a number of *elements* E₁, E₂, …, Eₙ, grouped into

  - a set of *partitions* P₁, P₂, …, Pₙ\. The latter term applies because the
    intersection of each pair Pᵢ, Pⱼ of partitions is empty, i\.e\., ∅ = Pᵢ ∩ Pⱼ,
    with the set itself equal to the union of all the partitions, i\.e\., S = P₁ ∪
    P₂ ∪ … ∪ Pₙ\.

An alternative name for the *partitions* would be *equivalence classes* ,
where all elements in the same class are considered equal\. Here is a pictorial
representation of the concepts listed above:

    +-----------------+ The outer lines are the boundaries of the set S.
    |           /     | The inner regions delineated by the diagonal
    |  *       /   *  | lines are the partitions P₁, P₂, …, Pₙ.
    |      *  / \     | The *’s denote the elements E₁, E₂, …, Eₙ in
    |*       /   \    | the set, each in a single partition, their
    |       /  *  \   | equivalence class.
    |      / *   /    |
    | *   /\  * /     |
    |    /  \  /      |
    |   /    \/  *    |
    |  / *    \       |
    | /     *  \      |
    +-----------------+

# <a name='section2'></a>API

The package provides a single command, __::struct::disjointset__, which
provides all its functionality using methods\.

  - <a name='1'></a>__::struct::disjointset__ *aDisjointSet*

    Creates a new disjoint set object with an associated global Tcl command
    whose name is *aDisjointSet*\. This command may be used to invoke disjoint
    set methods which all have the the following general form:

    *aDisjointSet* *method* ?*arg \.\.\.*?

    The *method* and the *arg*s specify what operation to perform\.

## <a name='subsection1'></a>Methods

  - <a name='2'></a>*aDisjointSet* __add\-element__ *element*

    Creates a new partition in the *aDisjointSet*, and adds the single
    *element* to the new partition\. The command maintains the integrity of the
    disjoint set, i\.e\., if *element* is already in the disjoint set—no matter
    in which partition—this method will throw an error\.

    This method returns the empty string\.

    This method runs in constant time, *O\(1\)*\.

  - <a name='3'></a>*aDisjointSet* __add\-partition__ *elements*

    Creates a new partition in the *aDisjointSet*, and adds all the given
    *elements* to the new partition\. The command maintains the integrity of
    the disjoint set, i\.e\., if any of the elements in *elements* is already in
    the disjoint set—no matter in which partition—this method will throw an
    error\.

    This method returns the empty string\.

    This method runs in time proportional to the size of *elements*, *O\(N\)*,
    where *N* is the number of *elements*\.

  - <a name='4'></a>*aDisjointSet* __partitions__

    Returns the *aDisjointSet*’s set of partitions as a list of lists\. The
    outer lists are the partitions, the inner lists contain each partition’s
    elements\.

    This method runs in *O\(N × α\(N\)\)* time, where *N* is the number of
    elements in the disjoint set, and the *α* function is the inverse
    Ackermann function\.

  - <a name='5'></a>*aDisjointSet* __num\-partitions__

    Returns the number of partitions in the *aDisjointSet*\.

    This method runs in constant time\.

  - <a name='6'></a>*aDisjointSet* __equal__ *a* *b*

    Returns __1__ \(true\) if elements *a* and *b* in the *aDisjointSet*
    are in the same partition; otherwise returns __0__ \(false\)\.

    If one or both arguments are not in the disjoint set at all, this method
    will throw an error\.

    This method runs in amortized time *O\(α\(N\)\)*, where *N* is the number of
    elements in the larger partition, and the *α* function is the inverse
    Ackermann function\.

  - <a name='7'></a>*aDisjointSet* __merge__ *a* *b*

    Determines the partitions in the *aDisjointSet* that elements *a* and
    *b* are contained in, and merges these partitions into a single partition\.
    If the two elements were already contained in the same partition the
    disjoint set is left unchanged\.

    If one or both arguments are not in the disjoint set at all, this method
    will throw an error\.

    This method returns the empty string\.

    This method runs in amortized time *O\(α\(N\)\)*, where *N* is the number of
    elements in the larger of the partitions being merged, and the *α*
    function is the inverse Ackermann function\. The worst case time is *O\(N\)*\.

  - <a name='8'></a>*aDisjointSet* __find__ *element*

    Returns a list of the members of the partition of the *aDisjointSet* which
    contains the given *element*; or an empty string if *element* is not in
    the disjoint set\.

    This method runs in *O\(N × α\(N\)\)* time, where *N* is the total number of
    elements in the disjoint set, and the *α* function is the inverse
    Ackermann function\. See __find\-exemplar__ for a faster method, if all
    that is needed is a unique partition identifier, rather than a list of its
    elements\.

  - <a name='9'></a>*aDisjointSet* __exemplars__

    Returns a list containing an exemplar—an arbitrarily chosen member—of each
    partition in the *aDisjointSet*\.

    Note that the only operation that will change the exemplar chosen for any
    particular partition is __merge__\.

    This method runs in *O\(N × α\(N\)\)* time, where *N* is the total number of
    elements in the disjoint set, and the *α* function is the inverse
    Ackermann function\.

  - <a name='10'></a>*aDisjointSet* __find\-exemplar__ *element*

    Returns an exemplar—an arbitrarily chosen member—of the partition of the
    *aDisjointSet* that contains the given *element*\.

    If *element* is not in the disjoint set at all, this method will throw an
    error\.

    Note that the only operation that will change the exemplar chosen for any
    particular partition is __merge__\.

    This method runs in *O\(α\(N\)\)* time, where *N* is the number of elements
    in the partition containing *element*, and the *α* function is the
    inverse Ackermann function\.

  - <a name='11'></a>*aDisjointSet* __destroy__

    Destroys the *aDisjointSet* object, including the global command
    *aDisjointSet*, and all its associated memory\.

# <a name='section3'></a>Examples

The examples make use of the following
__[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ to show their results:

    proc dump_disjointset name {
        puts "$name:"
        foreach partition [$name partitions] {
            puts -nonewline "  partition "
            set sep "{"
            foreach element $partition {
                puts -nonewline $sep$element
                set sep " "
            }
            puts "}"
        }
    }

This example creates a new disjoint set called *colors* and adds one partition
with the single element *black* and another partition with the elements
*cyan*, *magenta*, *yellow*\.

    struct::disjointset colors
    colors add-element black
    puts "colors num-partitions=[colors num-partitions]"
    colors add-partition {cyan magenta yellow}
    puts "colors num-partitions=[colors num-partitions]"
    dump_disjointset colors
    =>
    colors num-partitions=1
    colors num-partitions=2
    colors:
      partition {black}
      partition {cyan magenta yellow}

This example explores some of the disjoint set API on the *colors* disjoint
set created above\.

    puts "colors equal black yellow=[colors equal black yellow]"
    puts "colors equal cyan yellow=[colors equal cyan yellow]"
    puts "colors equal cyan magenta=[colors equal cyan magenta]"
    colors merge black cyan
    puts "colors equal black yellow=[colors equal black yellow]"
    dump_disjointset colors
    =>
    colors equal black yellow=0
    colors equal cyan yellow=1
    colors equal cyan magenta=1
    colors merge black cyan
    colors equal black yellow=1
    colors:
      partition {black cyan magenta yellow}

This example continues to explore some of the disjoint set API on the *colors*
disjoint set created above\.

    colors add-partition {red green blue}
    dump_disjointset colors
    puts "[colors find-exemplar blue] [colors find-exemplar yellow]"
    colors destroy
    =>
    colors:
      partition {black cyan magenta yellow}
      partition {red green blue}
    red cyan

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *struct ::
disjointset* as the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

http://en\.wikipedia\.org/wiki/Disjoint\_set\_data\_structure

# <a name='keywords'></a>KEYWORDS

[disjoint set](\.\./\.\./\.\./\.\./index\.md\#disjoint\_set), [equivalence
class](\.\./\.\./\.\./\.\./index\.md\#equivalence\_class),
[find](\.\./\.\./\.\./\.\./index\.md\#find), [merge
find](\.\./\.\./\.\./\.\./index\.md\#merge\_find),
[partition](\.\./\.\./\.\./\.\./index\.md\#partition), [partitioned
set](\.\./\.\./\.\./\.\./index\.md\#partitioned\_set),
[union](\.\./\.\./\.\./\.\./index\.md\#union)

# <a name='category'></a>CATEGORY

Data structures
