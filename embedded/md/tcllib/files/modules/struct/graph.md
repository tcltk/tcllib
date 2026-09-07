
[//000000001]: # (struct::graph \- Tcl Data Structures)
[//000000002]: # (Generated from file 'graph\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2002\-2009,2019 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (struct::graph\(n\) 2\.4\.4 tcllib "Tcl Data Structures")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

struct::graph \- Create and manipulate directed graph objects

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

      - [Methods](#subsection1)

  - [Changes for v2](#section3)

      - [Changes for v2\.4](#subsection2)

      - [Changes for v2\.x](#subsection3)

  - [Examples](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require struct::graph ?2\.4\.4?  
package require struct::list ?1\.8\.6?  
package require struct::set ?2\.2\.4?  

[__::struct::graph__ ?*aGraph*? ?__=__&#124;__:=__&#124;__as__&#124;__deserialize__ *source*?](#1)  
[*aGraph* __=__ *sourceGraph*](#2)  
[*aGraph* __\-\->__ *destGraph*](#3)  
[*aGraph* __append__ *key* *value*](#4)  
[*aGraph* __deserialize__ *serialization*](#5)  
[*aGraph* __destroy__](#6)  
[*aGraph* __arc append__ *arc* *key* *value*](#7)  
[*aGraph* __arc attr__ *key*](#8)  
[*aGraph* __arc attr__ *key* __\-arcs__ *list*](#9)  
[*aGraph* __arc attr__ *key* __\-glob__ *globpattern*](#10)  
[*aGraph* __arc attr__ *key* __\-regexp__ *repattern*](#11)  
[*aGraph* __arc delete__ *arc* ?*arc* \.\.\.?](#12)  
[*aGraph* __arc exists__ *arc*](#13)  
[*aGraph* __arc flip__ *arc*](#14)  
[*aGraph* __arc get__ *arc* *key*](#15)  
[*aGraph* __arc getall__ *arc* ?*glob*?](#16)  
[*aGraph* __arc getunweighted__](#17)  
[*aGraph* __arc getweight__ *arc*](#18)  
[*aGraph* __arc keys__ *arc* ?*glob*?](#19)  
[*aGraph* __arc keyexists__ *arc* *key*](#20)  
[*aGraph* __arc insert__ *start* *end* ?*name*?](#21)  
[*aGraph* __arc lappend__ *arc* *key* *value*](#22)  
[*aGraph* __arc rename__ *arc* *newname*](#23)  
[*aGraph* __arc set__ *arc* *key* ?*value*?](#24)  
[*aGraph* __arc setunweighted__ ?*weight*?](#25)  
[*aGraph* __arc setweight__ *arc* *weight*](#26)  
[*aGraph* __arc unsetweight__ *arc*](#27)  
[*aGraph* __arc hasweight__ *arc*](#28)  
[*aGraph* __arc source__ *arc*](#29)  
[*aGraph* __arc target__ *arc*](#30)  
[*aGraph* __arc nodes__ *arc*](#31)  
[*aGraph* __arc move\-source__ *arc* *newsource*](#32)  
[*aGraph* __arc move\-target__ *arc* *newtarget*](#33)  
[*aGraph* __arc move__ *arc* *newsource* *newtarget*](#34)  
[*aGraph* __arc unset__ *arc* *key*](#35)  
[*aGraph* __arc weights__](#36)  
[*aGraph* __arcs__ ?\-key *key* ?\-value *value*?? ?\-filter *cmdprefix*? ?\-in&#124;\-out&#124;\-adj&#124;\-inner&#124;\-embedding *node* ?node? \.\.\.?](#37)  
[*aGraph* __lappend__ *key* *value*](#38)  
[*aGraph* __node append__ *node* *key* *value*](#39)  
[*aGraph* __node attr__ *key*](#40)  
[*aGraph* __node attr__ *key* __\-nodes__ *list*](#41)  
[*aGraph* __node attr__ *key* __\-glob__ *globpattern*](#42)  
[*aGraph* __node attr__ *key* __\-regexp__ *repattern*](#43)  
[*aGraph* __node degree__ ?\-in&#124;\-out? *node*](#44)  
[*aGraph* __node delete__ *node* ?*node*\.\.\.?](#45)  
[*aGraph* __node exists__ *node*](#46)  
[*aGraph* __node get__ *node* *key*](#47)  
[*aGraph* __node getall__ *node* ?*glob*?](#48)  
[*aGraph* __node keys__ *node* ?*glob*?](#49)  
[*aGraph* __node keyexists__ *node* *key*](#50)  
[*aGraph* __node insert__ ?*node*\.\.\.?](#51)  
[*aGraph* __node lappend__ *node* *key* *value*](#52)  
[*aGraph* __node opposite__ *node* *arc*](#53)  
[*aGraph* __node rename__ *node* *newname*](#54)  
[*aGraph* __node set__ *node* *key* ?*value*?](#55)  
[*aGraph* __node unset__ *node* *key*](#56)  
[*aGraph* __nodes__ ?\-key *key*? ?\-value *value*? ?\-filter *cmdprefix*? ?\-in&#124;\-out&#124;\-adj&#124;\-inner&#124;\-embedding *node* *node*\.\.\.?](#57)  
[*aGraph* __get__ *key*](#58)  
[*aGraph* __getall__ ?*pattern*?](#59)  
[*aGraph* __keys__ ?*pattern*?](#60)  
[*aGraph* __keyexists__ *key*](#61)  
[*aGraph* __serialize__ ?*node*\.\.\.?](#62)  
[*aGraph* __set__ *key* ?*value*?](#63)  
[*aGraph* __swap__ *node1* *node2*](#64)  
[*aGraph* __unset__ *key*](#65)  
[*aGraph* __walk__ *node* ?\-type *type*? ?\-order *order*? ?\-dir *direction*? \-command *cmd*](#66)  

# <a name='description'></a>DESCRIPTION

A directed graph is a data structure containing two collections of elements,
*nodes* and *arcs* \(also called *edges*\), along with a relation that
connects the nodes and arcs\.

Each arc is connected to two nodes, one of which is called the
*[source](\.\./\.\./\.\./\.\./index\.md\#source)* and the other the *target*\. This
imposes a direction upon the arc, which is said to go from the source to the
target\. When an arc’s source and target are the same node, the arc is called a
*[loop](\.\./\.\./\.\./\.\./index\.md\#loop)*\.

When a node is the source or target of an arc, the node and arc are said to be
*[adjacent](\.\./\.\./\.\./\.\./index\.md\#adjacent)*\. Furthermore, if two nodes are
connected via one or more arcs, the nodes are also said to be
*[adjacent](\.\./\.\./\.\./\.\./index\.md\#adjacent)*\.

A node can be the source of any number of *outgoing arcs*, and also the target
of any number of *incoming arcs*\. The number of *outgoing arcs* is a node’s
*out\-degree*, and the number of *incoming arcs* is a node’s *in\-degree*\.

This __struct::graph__ package can manage graphs of nodes, arcs, and their
relationships\. In addition, the package supports the addition of any number of
named *attributes* which can be associated with a graph itself, as well as
with any of the graph’s nodes and arcs\.

See the __struct::graph::ops__ package for commands that implement a wide
range of common graph algorithms\.

*Note:* The major version of the __struct::graph__ package has been
changed to version 2, due to backward incompatible changes in the module’s API\.
Users of version 1 are recommended to read the section [Changes for
v2](#section3) for a full list of the changes, including incompatibilities
with version 1\.

As of version 2\.2, a critcl based C implementation is now provided, which
requires Tcl 8\.4 or later\.

# <a name='section2'></a>API

  - <a name='1'></a>__::struct::graph__ ?*aGraph*? ?__=__&#124;__:=__&#124;__as__&#124;__deserialize__ *source*?

    This command creates a new graph object with an associated global Tcl
    command\. If *aGraph* is given, the global command will be called the given
    name; otherwise, a unique name will be generated by the package itself\.

    If a *source* is specified, the new graph will be initialized from it\. For
    the operators __=__, __:=__, and __as__, the *source* argument
    is interpreted as the name of another graph object, and the assignment
    operator __=__ will be executed\. For the operator __deserialize__,
    the *source* is assumed to be a serialized graph object, and
    __deserialize__ will be executed\.

    For example:

        ::struct::graph graphA = graphB

    is equivalent to

        ::struct::graph graphA
        graphA = graphB

    and

        ::struct::graph graphA deserialize $graphB

    is equivalent to

        ::struct::graph graphA
        graphA deserialize $graphB

    Once the graph object—and its corresponding command—has been created, the
    command can be used to apply various graph operations\. These all have the
    same general form:

    *aGraph* *method* ?*arg \.\.\.*?

    The *method* and the *arg*s specify what operation to perform\.

## <a name='subsection1'></a>Methods

  - <a name='2'></a>*aGraph* __=__ *sourceGraph*

    The __=__ operator is the graph object *assignment* operator\. It
    copies the graph contained in the graph object *sourceGraph* over the
    graph data in *aGraph*\. The old contents of *aGraph* are deleted by this
    operation\.

    This operation is in effect equivalent to

    > *aGraph* __deserialize__ \[*sourceGraph* __serialize__\]

    The operation assumes that the *sourceGraph* provides a __serialize__
    method which returns a valid graph serialization\.

  - <a name='3'></a>*aGraph* __\-\->__ *destGraph*

    The __\-\->__ operator is the graph object *reverse assignment*
    operator\. It copies the graph contained in the graph object *aGraph* over
    the graph data in the object *destGraph*\. The old contents of
    *destGraph* are deleted by this operation\.

    This operation is in effect equivalent to

    > *destGraph* __deserialize__ \[*aGraph* __serialize__\]

    The operation assumes that the *destGraph* provides a __deserialize__
    method which takes a graph serialization, and that *aGraph* provides a
    __serialize__ method which returns a valid graph serialization\.

  - <a name='4'></a>*aGraph* __append__ *key* *value*

    Appends the *value* to the graph attribute associated with the given
    *key*\. Returns the new value of the graph attribute associated with the
    *key*\.

  - <a name='5'></a>*aGraph* __deserialize__ *serialization*

    This is the complement of the __serialize__ method\. It replaces the
    graph data in *aGraph* with the graph described by the *serialization*
    value\. The old contents of *aGraph* are deleted by this operation\.

  - <a name='6'></a>*aGraph* __destroy__

    Destroys the graph, including its storage space and associated command\.

  - <a name='7'></a>*aGraph* __arc append__ *arc* *key* *value*

    Appends the *value* to the given *arc*’s attribute associated with the
    given *key*\. Returns the new value of the *arc* attribute associated
    with the *key*\.

  - <a name='8'></a>*aGraph* __arc attr__ *key*

  - <a name='9'></a>*aGraph* __arc attr__ *key* __\-arcs__ *list*

  - <a name='10'></a>*aGraph* __arc attr__ *key* __\-glob__ *globpattern*

  - <a name='11'></a>*aGraph* __arc attr__ *key* __\-regexp__ *repattern*

    When no options are specified, the __arc attr__ method returns a
    __dict__ whose keys are the names of *every* arc in the *aGraph*
    graph\. For each of the resultant dict’s keys, the corresponding value is the
    value of the arc attribute associated with the given *key*\. Arcs which do
    not have the given *key* are not included in the result __dict__\.

    If one of the options is specified, in effect the same results __dict__
    is created as for no options, but filtered so that only the arcs which match
    the given option’s constraint are included in the result __dict__\.

    The possible constraints are:

      * __\-arcs__

        The value must be a list of arc names\. Only the arcs mentioned in this
        list are searched for the *key* attribute\.

      * __\-glob__

        The value is a glob pattern\. Only the arcs in the graph whose names
        match this pattern are searched for the *key* attribute\.

      * __\-regexp__

        The value is a regular expression\. Only the arcs in the graph whose
        names match this pattern are searched for the *key* attribute\.

  - <a name='12'></a>*aGraph* __arc delete__ *arc* ?*arc* \.\.\.?

    Removes the specified arcs from the graph\.

    If one or more of the arcs doesn’t exit an error is thrown\.

  - <a name='13'></a>*aGraph* __arc exists__ *arc*

    Returns __1__ \(true\) if the specified *arc* exists in the graph;
    otherwise returns __0__ \(false\)\.

  - <a name='14'></a>*aGraph* __arc flip__ *arc*

    Reverses the direction of the *arc*, i\.e\., the arc’s source and target
    nodes are exchanged with each other\.

  - <a name='15'></a>*aGraph* __arc get__ *arc* *key*

    Returns the value associated with the *arc*’s *key*\.

    If the *arc* doesn’t exist or if the *key* doesn’t exist, an error is
    thrown\.

  - <a name='16'></a>*aGraph* __arc getall__ *arc* ?*glob*?

    Returns a dictionary \(suitable for use with \[__array set__\]\) of the
    *arc*’s attribute keys and values\.

    If a *glob* pattern is specified, only the attributes whose keys match
    will be included\.

  - <a name='17'></a>*aGraph* __arc getunweighted__

    Returns a list of the names of all the graph’s arcs which have *no* weight
    associated with them\.

  - <a name='18'></a>*aGraph* __arc getweight__ *arc*

    Returns the weight associated with the *arc*\.

    If the *arc* doesn’t exist or if it has no weight, an error is thrown\.

  - <a name='19'></a>*aGraph* __arc keys__ *arc* ?*glob*?

    Returns a list of keys for the *arc*\.

    If *glob* is specified only the attributes whose names match the glob will
    be part of the returned list\.

  - <a name='20'></a>*aGraph* __arc keyexists__ *arc* *key*

    Returns __1__ \(true\) if the *arc* has the specified *key*; otherwise
    returns __0__ \(false\)\.

  - <a name='21'></a>*aGraph* __arc insert__ *start* *end* ?*name*?

    Inserts an arc into the graph beginning at the *start* node and ending at
    the *end* node\. The new arc is called *name* if specified; otherwise a
    unique system\-generated name of form *arc**x* is used\.

  - <a name='22'></a>*aGraph* __arc lappend__ *arc* *key* *value*

    Appends the given *value* \(as a list\) to the value associated with the
    *arc*’s *key* and returns the *arc*’s *key*’s new value\.

  - <a name='23'></a>*aGraph* __arc rename__ *arc* *newname*

    Renames the *arc* to *newname* and returns *newname*\.

    Thows an error if the given *arc* does not exist, or if an arc called
    *newname* already exists\.

  - <a name='24'></a>*aGraph* __arc set__ *arc* *key* ?*value*?

    Get or set the value of the given *arc*’s associated *key*\.

    If *value* *is not* specified, the value of the given *arc*’s
    associated *key* is returned\. If a *value* *is* specified, then the
    *value* is assigned to the given *key*, and the value of the given
    *arc*’s associated *key* is returned\.

    An arc may have any number of key\-value pairs associated with it\.

  - <a name='25'></a>*aGraph* __arc setunweighted__ ?*weight*?

    Sets the weight of all arcs without a weight to *weight*\. If no *weight*
    is specified it defaults to __0__\. Returns the empty string\.

  - <a name='26'></a>*aGraph* __arc setweight__ *arc* *weight*

    Sets the weight of the *arc* to *weight* and returns *weight*\.

  - <a name='27'></a>*aGraph* __arc unsetweight__ *arc*

    Removes the weight of the *arc*, if present; otherwise does nothing\.
    Returns the empty string\.

  - <a name='28'></a>*aGraph* __arc hasweight__ *arc*

    Returns __1__ \(true\) if the *arc* has a weight; otherwise returns
    __0__ \(false\)\.

  - <a name='29'></a>*aGraph* __arc source__ *arc*

    Returns the node the given *arc* begins at\.

  - <a name='30'></a>*aGraph* __arc target__ *arc*

    Returns the node the given *arc* ends at\.

  - <a name='31'></a>*aGraph* __arc nodes__ *arc*

    Returns a two\-element list of the nodes the given *arc* begins and ends
    at\.

  - <a name='32'></a>*aGraph* __arc move\-source__ *arc* *newsource*

    Changes the *arc*’s source node to *newsource*\. This can be described as
    rotating the arc around its target node\.

  - <a name='33'></a>*aGraph* __arc move\-target__ *arc* *newtarget*

    Changes the *arc*’s target node to *newtarget*\. This can be described as
    rotating the arc around its source node\.

  - <a name='34'></a>*aGraph* __arc move__ *arc* *newsource* *newtarget*

    Changes the *arc*’s source and target nodes to *newsource* and
    *newtarget* respectively\.

  - <a name='35'></a>*aGraph* __arc unset__ *arc* *key*

    Removes the *arc*’s *key* and its corresponding value\. Does nothing if
    the *key* doesn’t exist\.

  - <a name='36'></a>*aGraph* __arc weights__

    Returns a __dict__ where each key is the name of an arc which has a
    weight and each corresponding value is that arc’s weight\.

  - <a name='37'></a>*aGraph* __arcs__ ?\-key *key* ?\-value *value*?? ?\-filter *cmdprefix*? ?\-in&#124;\-out&#124;\-adj&#124;\-inner&#124;\-embedding *node* ?node? \.\.\.?

    Returns a list of the graph’s arcs\.

    If no constraint is specified, every arc is in the returned list\.

    *Constraints*

    Constraints can limit which arcs are included in the returned list based on
    the nodes that are connected by the arc, on the keyed values associated with
    the arc, or both\. A general filter command can also be used\. The constraints
    that involve connected nodes take a variable number of nodes as argument,
    specified after the name of the constraint itself\.

    At most one __\-key__ constraint may be specified, and if present then at
    most one __\-value__ constraint my also be used\. The __key__ \(and if
    present __\-value__\), if specified, will be applied *second*\. \(If two
    or more __\-key__ options are used or if a __\-value__ is used without
    a corresponding __key__, an error will be thrown\.\)

      * __\-key__ *key*

        Only return arcs that have the associated *key*\.

      * __\-value__ *value*

        Only return arcs that have the associated *key* \(which *must* be
        specified using the __\-key__ option\), *and* for which the
        *key*’s value is *value*\.

    At most one __\-filter__ command may be specified, and if present, this
    is applied *last*\. \(If two or more __\-filter__ options are used an
    error will be thrown\.\)

      * __\-filter__ *cmdprefix*

        Only return arcs for which the given *cmdprefix* returns __1__
        \(true\)\.

        For each candidate arc the *cmdprefix* is executed in the context of
        the caller\. It is called with two arguments, the name of the graph
        object, and the name of the candidate arc\. The *cmdprefix* command
        should return either __1__ \(true; to keep the arc in the list to be
        returned\), or __0__ \(false; to remove the arc from the list to be
        returned\)\.

    At most one constraint may be specified using one of __\-in__,
    __\-out__, __\-adj__, __\-inner__, or __\-embedding__\. If one of
    these is present, it is applied *first*\. \(If two or more of these options
    is used an error will be thrown\.\)

      * __\-in__

        Only return arcs whose target is one of the specified nodes\. In other
        words, compute the union of all the incoming arcs for the specified
        nodes\.

      * __\-out__

        Only return arcs whose source is one of the specified nodes\. In other
        words, compute the union of all the outgoing arcs for the specified
        nodes\.

      * __\-adj__

        Only return arcs that are adjacent to at least one of the specified
        nodes\. In other words, compute the union of all the incoming *and*
        outgoing arcs for the specified nodes \(i\.e\., the union of using
        __\-in__ and __\-out__\)\.

      * __\-inner__

        Only return arcs that are adjacent to two of the specified nodes\. This
        is the set of arcs in the subgraph formed by the specified nodes\.

      * __\-embedding__

        Only return arcs that are adjacent to exactly one of the specified
        nodes\. This is the set of arcs connecting the subgraph formed by the
        specified nodes to the rest of the graph\.

    *Note*: After specifiying one of the options above, any word with a
    leading dash which is not a valid option is treated as a node name instead
    of an invalid option\. This condition holds until either a valid option
    terminates the list of nodes, or the end of the command is reached,
    whichever comes first\.

  - <a name='38'></a>*aGraph* __lappend__ *key* *value*

    Appends the *value* \(as a list\) to the graph attribute with the given
    *key*, and returns the attribute with the *key*’s new value\.

  - <a name='39'></a>*aGraph* __node append__ *node* *key* *value*

    Appends the *value* to the *node*’s attribute with the given *key*,
    and returns the attribute with the *key*’s new value\.

  - <a name='40'></a>*aGraph* __node attr__ *key*

  - <a name='41'></a>*aGraph* __node attr__ *key* __\-nodes__ *list*

  - <a name='42'></a>*aGraph* __node attr__ *key* __\-glob__ *globpattern*

  - <a name='43'></a>*aGraph* __node attr__ *key* __\-regexp__ *repattern*

    Returns a __dict__ whose keys are node names and whose corresponding
    values are those of the nodes’ attribute values associated with the given
    *key*\.

    The returned __dict__ will include all the graph’s nodes that have the
    given *key* *or* if an optional constraint is specified, the subset of
    those nodes which match the given constraint\. This means that any nodes
    which do *not* have the given *key* or which do *not* satisfy the
    constraint \(if given\) will not be included in the returned __dict__\.

    The possible constraints are:

      * __\-nodes__

        Only the graph’s nodes that are in the given *list* and have the
        specified *key*, will be included in the results __dict__\.

      * __\-glob__

        Only the graph’s nodes whose names match the given *globpattern* glob
        pattern and have the specified *key*, will be included in the results
        __dict__\.

      * __\-regexp__

        Only the graph’s nodes whose names match the given *repattern* regular
        expression and have the specified *key*, will be included in the
        results __dict__\.

  - <a name='44'></a>*aGraph* __node degree__ ?\-in&#124;\-out? *node*

    Returns the number of arcs adjacent to the specified *node*\.

    If the __\-in__ constraint is specified, only the incoming arcs are
    counted; if the __\-out__ constraint is specified, only the outgoing arcs
    are counted\. If neither constraint is specified, then all incoming and
    outgoing arcs are counted\.

  - <a name='45'></a>*aGraph* __node delete__ *node* ?*node*\.\.\.?

    Deletes the specified nodes from the graph, *and also* deletes all the
    nodes’ arcs \(to prevent unconnected arcs\)\.

  - <a name='46'></a>*aGraph* __node exists__ *node*

    Returns __1__ \(true\) if the specified *node* exists in the graph;
    otherwise returns __0__ \(false\)\.

  - <a name='47'></a>*aGraph* __node get__ *node* *key*

    Returns the value associated with the *node*’s *key*\.

    Throws an error if the *node* does not have the given *key*\.

  - <a name='48'></a>*aGraph* __node getall__ *node* ?*glob*?

    Returns a __dict__ \(suitable for use with \[__array set__\]\) for the
    *node*\. The __dict__’s keys are attribute names \(i\.e\., their keys\) and
    the values are the corresponding attribute values\.

    If *glob* is specified, only the attributes whose names \(i\.e\., keys\) match
    this glob pattern, will included in the returned dictionary\.

  - <a name='49'></a>*aGraph* __node keys__ *node* ?*glob*?

    Returns a list of the *node*’s attribute keys\.

    If *glob* is specified, only the attributes whose names \(i\.e\., keys\) match
    this glob pattern, will included in the returned list\.

  - <a name='50'></a>*aGraph* __node keyexists__ *node* *key*

    Returns __1__ \(true\) if the *node* has the specified *key*;
    otherwise returns __0__ \(false\)\.

  - <a name='51'></a>*aGraph* __node insert__ ?*node*\.\.\.?

    Inserts one or more nodes into the graph, and returns a list of the inserted
    nodes\. These new nodes are not connected to any arcs\.

    If no node is specified, a single new node will be inserted and returned\.
    The new node will have a unique name generated by the system and having the
    form *node**x*\.

  - <a name='52'></a>*aGraph* __node lappend__ *node* *key* *value*

    Appends the *value* \(as a list\) the *node*’s attribute with the given
    *key*, and returns the attribute with the *key*’s new value\.

  - <a name='53'></a>*aGraph* __node opposite__ *node* *arc*

    Returns the node at the other end of the specified *arc*, which must be
    adjacent to the given *node*\.

  - <a name='54'></a>*aGraph* __node rename__ *node* *newname*

    Renames the *node* to *newname* and returns the node’s new name\.

    An error is thrown if the node does not exist, or if a node called
    *newname* already exists\.

  - <a name='55'></a>*aGraph* __node set__ *node* *key* ?*value*?

    Get or set the given *node*’s attribute that’s identified by the given
    *key*\.

    If *value* is not specified, this command returns the *key*’s current
    value\. If *value* is specified, this command assigns *value* to the
    *node*’s *key*\.

    Each node may have any number of keyed values associated with it\.

  - <a name='56'></a>*aGraph* __node unset__ *node* *key*

    Removes the *node*’s *key* and its associated value from the *node*’s
    attributes\. Does nothing if the *node* does not have the given *key*\.

  - <a name='57'></a>*aGraph* __nodes__ ?\-key *key*? ?\-value *value*? ?\-filter *cmdprefix*? ?\-in&#124;\-out&#124;\-adj&#124;\-inner&#124;\-embedding *node* *node*\.\.\.?

    Returns a list of the graph’s nodes\. Every node is included in the list
    unless constraints are specified\.

    Constraints can limit the nodes included in the list based on the keyed
    values associated with the node or on neighboring nodes\. The constraints
    that involve neighboring nodes take a list of nodes as argument, specified
    after the name of the constraint itself\.

    The constraints are essentially the same as for the __arcs__ method\.
    Although the exact meanings change slightly, since here the contraints
    operate on nodes rather than arcs, the general behaviour is the same,
    especially when it comes to the handling of words with a leading dash in
    node lists\.

    *Constraints*

      * __\-in__

        Return the *incoming neighbours*, i\.e\., a list of all the nodes with
        at least one outgoing arc ending in a node in the specified set of
        nodes\. \(Alternatively specified as the set of source nodes for the node
        set’s __\-in__ arcs\.\)

      * __\-out__

        Return the *outgoing neighbours*, i\.e\., a list of all the nodes with
        at least one incoming arc starting in a node in the specified set of
        nodes\. \(Alternatively specified as the set of target nodes for the node
        set’s __\-out__ arcs\.\)

      * __\-adj__

        Return the *neighbours*, i\.e\., the union of the nodes returned by
        __\-in__ and __\-out__\.

      * __\-inner__

        Return the set of neighbours \(see __\-adj__ above\) which are also in
        the given set of nodes, i\.e\., the intersection of the neighbours
        returned by __\-adj__ and the set of nodes\.

      * __\-embedding__

        Return the set of neighbours \(see __\-adj__ above\) which are *not*
        in the set of nodes, i\.e\., the difference between the neighbours
        returned by __\-adj__ and the set of nodes\.

      * __\-key__ *key*

        Return only nodes which have the given *key*\.

      * __\-value__ *value*

        Return only nodes which have the given *key* and whose associated
        value is *value*\.

        This constraint can only be used in combination with __\-key__\.

      * __\-filter__ *cmdprefix*

        Return only those nodes for which the command *cmdprefix* returns
        __1__ \(true\)\.

        The command *cmdprefix* is called with two arguments, the name of the
        graph object, and the name of the node in question\. It is executed in
        the context of the caller and must return a Boolean value, __0__
        \(false; do not include the node\) or __1__ \(true; include the node\)\.

  - <a name='58'></a>*aGraph* __get__ *key*

    Returns the value associated with the graph’s *key*\.

    Throws an error if the graph does not have the given *key*\.

    See the __set__ method\.

  - <a name='59'></a>*aGraph* __getall__ ?*pattern*?

    Returns a dictionary \(suitable for use with \[__array set__\]\) containing
    all the graph’s keys and their associated values\.

    If the *pattern* is specified only those attributes whose names match the
    pattern will be part of the returned dictionary\. The pattern is a
    __glob__ pattern\.

  - <a name='60'></a>*aGraph* __keys__ ?*pattern*?

    Returns a list of all the graph’s keys\.

    If the *pattern* is specified only those attributes whose names match the
    pattern will be part of the returned list\. The pattern is a __glob__
    pattern\.

  - <a name='61'></a>*aGraph* __keyexists__ *key*

    Returns __1__ \(true\) if the graph has the specified *key*; otherwise
    returns __0__ \(false\)\.

  - <a name='62'></a>*aGraph* __serialize__ ?*node*\.\.\.?

    Returns the graph \(or a subgraph of the graph\) serialized into a single Tcl
    value\. The value can be deserialized back into a graph using the
    __deserialize__ method\.

    The serialization is of the entire graph, unless one or more *node*s are
    specified, in which case only the subgraph spanned by the given nodes is
    serialized\.

    Since a serialized graph is a Tcl value it can be copied like any Tcl
    string, e\.g\., sent to a channel, persisted into a file, etc\.

    This method also serves as the basis for the graph’s copy constructor and
    assignment operator\.

    Every graph interface’s serialize method’s implementation must produce
    semantically equivalent serialization values so that these values may be
    used interchangeably between implementations\.

    The serialized value is a list of triples, plus a __dict__ at the end\.
    This means that *\[llength $serial\] % 3 == 1*\. Valid values include 1, 4,
    7, …\.

    The last element of the list is a __dict__ containing the attributes
    associated with the whole graph\.

    All the preceding elements are triples, one per node, each consisting of:

      1. The node’s name\.

      1. A __dict__ containing the node’s attributes\.

      1. A list of all the arcs starting at this node \(see below\)\.

    Each element of a node’s list of arcs is itself a list of three or four
    elements as follows:

      1. The arc’s name\.

      1. A reference to the arc’s destination node\. This reference is the
         integer index of the destination node in the main serialization list\.
         \(This integer will always be *>= 0* and *< \[llength $serial\]* and a
         multiple of three\.\)

         *Note:* For internal consistency serialization requires that every
         arc name used in a graph must be unique, whether in the same node, or
         at some other node\.

      1. A __dict__ containing the arc’s attributes\.

      1. An optional arc weight\. If absent it means that this arc has no
         associated weight\.

         *Note:* This information is new, compared to the serialization of
         __[graph](\.\./\.\./\.\./\.\./index\.md\#graph)__ 2\.3 and earlier\. Making
         arc weights optional in the new format preserves some compatibility
         with the old\. In particular, any graph that does *not* use weights
         will have a serialization which is deserializeable by the older graph
         package\. However, if weights are used, older packages will not be able
         to deserialize\.

    For all attribute dictionaries, each key is an attribute name and each key’s
    associated value holds the attribute’s value\.

    *Note:* The serialization’s order of nodes and of arcs within each node
    has no significance\. In other words two semantically equivalent graphs could
    have different serializations\.

        # A possible serialization for the graph structure
        #
        #        d -----> %2
        #       /         ^ \
        #      /         /   \
        #     /         b     \
        #    /         /       \
        #  %1 <- a - %0         e
        #    ^         \\      /
        #     \\        c     /
        #      \\        \\  /
        #       \\        v v
        #        f ------ %3
        # is
        #
        # %3 {} {{f 6 {}}} %0 {} {{a 6 {}} {b 9 {}} {c 0 {}}} %1 {} {{d 9 {}}} %2 {} {{e 0 {}}} {}
        #
        # This assumes that the graph has neither attribute data nor weighted arcs.

  - <a name='63'></a>*aGraph* __set__ *key* ?*value*?

    Get or set the value associated with the given graph *key*\.

    If no *value* is given the value associated with the *key* is returned\.
    If *value* is given, the *key* is set to the specified *value* and the
    *value* is returned\.

    Throws an error if no *value* is specified \(i\.e\., when getting\) and the
    graph does not have the given *key*\.

    A graph may have any number of keyed values associated with it\. See also the
    __get__ method\.

  - <a name='64'></a>*aGraph* __swap__ *node1* *node2*

    Swap the positions of *node1* and *node2* in the graph\.

  - <a name='65'></a>*aGraph* __unset__ *key*

    Removes the graph’s *key* and its corresponding value\. Does nothing if the
    *key* doesn’t exist\.

  - <a name='66'></a>*aGraph* __walk__ *node* ?\-type *type*? ?\-order *order*? ?\-dir *direction*? \-command *cmd*

    Perform a breadth\-first or depth\-first walk of the graph starting at
    *node* and going __forward__ \(the direction of outgoing arcs\) or
    __backward__ \(the opposite direction to the incoming arcs\)\.

    If specified, the walk’s type must be __dfs__ \(depth\-first; the
    default\), or __bfs__ breadth\-first\.

    If specified, the walk’s order must be __pre__ \(pre\-order; the default\),
    or __post__ \(post\-order\), or __both__\.

    Pre\-order means that a node is visited before any of its neighbours \(as
    defined by the *direction*, see below\)\. Post\-order means that a node is
    visited after any of its neighbours\. Both\-order walking means that a node is
    visited before *and* after any of its neighbours\. Note that the
    breadth\-first type of walk may *only* be combined with pre\-order; only
    depth\-first may be used with pre\-order, post\-order, or both\-order\.

    If specified, the walk’s direction must be __backward__ \(the direction
    opposite to the incoming arcs\), or __forward__ \(the direction of the
    outgoing arcs\)\.

    As the walk progresses, the command *cmd* will be evaluated at each node
    and passed three arguments\. The arguments are the call’s mode \(__enter__
    or __leave__\), the graph itself \(i\.e\., *aGraph*\), and the current
    node’s name\. For a pre\-order walk, all nodes are entered \(mode __enter__
    is passed to *cmd*\); for a post\-order all nodes are left \(mode
    __leave__ is passed\)\. In a both\-order walk the first visit to a node is
    the entry \(mode __enter__\), and the second visit is the leave \(mode
    __leave__\)\.

# <a name='section3'></a>Changes for v2

## <a name='subsection2'></a>Changes for v2\.4

The __serialize__ method’s serialization format changed to account for the
\(optional\) use of weights\. See the method’s documentation for details\.

## <a name='subsection3'></a>Changes for v2\.x

The following noteworthy changes have occurred:

  1. The API for accessing attributes and their values has been simplified\.

     All functionality regarding the default attribute "data" has been removed\.
     This default attribute no longer exists\. All accesses to attributes must
     specify the attribute’s name\. This backward *incompatible* change led to
     simplified signatures for all methods involving attributes\.

     In particular, the flag __\-key__ has gone\. Please read the
     documentation for the arc and node methods __get__, __getall__,
     __set__, __unset__, __append__, __lappend__,
     __keyexists__, and __keys__, for a description of the new APIs\.

  1. The methods __keys__ and __getall__ now take an optional glob
     pattern argument which if specified will limit the returned attribute data
     to only those keys which match the pattern\.

  1. Arcs and nodes can now be renamed\. See the documentation for the methods
     __arc rename__ and __node rename__\.

  1. The structure has been extended with APIs for graph serialization and
     deserialization, and a number of operations based on these methods \(e\.g\.,
     graph assignment, copy construction\)\.

     Please read the documentation for the methods __serialize__,
     __deserialize__, __=__, and __\-\->__, and the documentation on
     the construction of graph objects\.

     Serialization and deserialization mean that graphs can be copied like any
     Tcl string, e\.g\., sent to a channel, persisted into a file, etc\.

  1. Both __arc__’s and __node__’s now have an __attr__ method which
     supports access to attribute data regardless of arc and node relationships\.

  1. Both __arcs__ and __nodes__ have been extended with the ability to
     specify constraints to filter the arcs or nodes they return; see their
     documentation for details\.

# <a name='section4'></a>Examples

The following example shows the basics of using the __struct::graph__
package\.

An illustration of the graph used in the example:

                  SW45
            /------------------BOS
           /                   /|
          /  /--→ORD      NW35/ |
         ↙  /   / D↑  AA1387 ↙  |
      SFO  /  U/  L| /-----JFK  |
          /   A|  3| |      |   |
         |    8|  3| |      |   |
    UA120|    7|  5/ /      |   |
         |    7↓  / /       /   |DL247
         |     DFW←/      A/    |
         |    /   ↖       A|    |
         |   /AA49 \      9|   /
        LAX←/       \     0|  /
          ↖     AA523\    3↓ ↙
           \          \--MIA
            \-----------/
              AA411

The code that represents the graph shown above, along with weights \(flight
distances in kilometers\)\.

    proc visit_airport {mode graph airport} {
        puts " [expr {$mode eq "enter" ? "→" : "←"}] $graph $airport"
    }

    try { ;# Adapted from "Data Structures and Algorithms in Java"
        ::struct::graph flights
        flights node insert SFO
        flights node insert LAX
        flights node insert ORD
        flights node insert DFW
        flights node insert JFK
        flights node insert BOS
        flights node insert MIA
        flights arc insert JFK SFO SW45
        flights arc setweight SW45 4152
        flights arc insert JFK DFW AA1387
        flights arc setweight AA1387 2235
        flights arc insert JFK MIA AA903
        flights arc setweight AA903 1756
        flights arc insert BOS JFK NW35
        flights arc setweight NW35 300
        flights arc insert BOS MIA DL247
        flights arc setweight DL247 2027
        flights arc insert MIA DFW AA523
        flights arc setweight AA523 1802
        flights arc insert MIA LAX AA411
        flights arc setweight AA411 3763
        flights arc insert LAX ORD UA120
        flights arc setweight UA120 2802
        flights arc insert DFW LAX AA49
        flights arc setweight AA49 1983
        flights arc insert DFW ORD DL335
        flights arc setweight DL335 1290
        flights arc insert ORD DFW UA877
        flights arc setweight UA877 1290
        puts "flights walk ORD:"
        puts [flights walk ORD -order both -command visit_airport]
        puts "All flights: [lsort -dictionary [flights arcs]]"
        puts "Chicago flights: [flights arcs -embedding ORD]"
        puts "Chicago direct connections: [flights nodes -embedding ORD]"
    } finally {
        flights destroy
    }
    =>
    flights walk ORD:
     → flights ORD
     → flights DFW
     → flights LAX
     ← flights LAX
     ← flights DFW
     ← flights ORD

    All flights: AA49 AA411 AA523 AA903 AA1387 DL247 DL335 NW35 SW45 UA120 UA877
    Chicago flights: DL335 UA120 UA877
    Chicago direct connections: DFW LAX

# <a name='section5'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *struct ::
graph* as the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[adjacent](\.\./\.\./\.\./\.\./index\.md\#adjacent),
[arc](\.\./\.\./\.\./\.\./index\.md\#arc), [cgraph](\.\./\.\./\.\./\.\./index\.md\#cgraph),
[degree](\.\./\.\./\.\./\.\./index\.md\#degree),
[edge](\.\./\.\./\.\./\.\./index\.md\#edge), [graph](\.\./\.\./\.\./\.\./index\.md\#graph),
[loop](\.\./\.\./\.\./\.\./index\.md\#loop),
[neighbour](\.\./\.\./\.\./\.\./index\.md\#neighbour),
[node](\.\./\.\./\.\./\.\./index\.md\#node),
[serialization](\.\./\.\./\.\./\.\./index\.md\#serialization),
[subgraph](\.\./\.\./\.\./\.\./index\.md\#subgraph),
[vertex](\.\./\.\./\.\./\.\./index\.md\#vertex)

# <a name='category'></a>CATEGORY

Data structures

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2002\-2009,2019 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>
