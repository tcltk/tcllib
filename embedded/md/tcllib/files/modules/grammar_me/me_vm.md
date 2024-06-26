
[//000000001]: # (grammar::me\_vm \- Grammar operations and usage)
[//000000002]: # (Generated from file 'me\_vm\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2005 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (grammar::me\_vm\(n\) 0\.2 tcllib "Grammar operations and usage")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

grammar::me\_vm \- Virtual machine for parsing token streams

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Description](#section1)

  - [MACHINE STATE](#section2)

  - [MACHINE INSTRUCTIONS](#section3)

      - [TERMINAL MATCHING](#subsection1)

      - [NONTERMINAL MATCHING](#subsection2)

      - [UNCONDITIONAL MATCHING](#subsection3)

      - [CONTROL FLOW](#subsection4)

      - [INPUT LOCATION HANDLING](#subsection5)

      - [ERROR HANDLING](#subsection6)

      - [SEMANTIC VALUES](#subsection7)

      - [AST STACK HANDLING](#subsection8)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

Please go and read the document __[grammar::me\_intro](me\_intro\.md)__
first for an overview of the various documents and their relations\.

This document specifies a virtual machine for the controlled matching and
parsing of token streams, creating an *[abstract syntax
tree](\.\./\.\./\.\./\.\./index\.md\#abstract\_syntax\_tree)* \(short
*[AST](\.\./\.\./\.\./\.\./index\.md\#ast)*\) reflecting the structure of the input\.
Special machine features are the caching and reuse of partial results, caching
of the encountered input, and the ability to backtrack in both input and AST
creation\.

These features make the specified virtual machine especially useful to packrat
parsers based on parsing expression grammars\. It is however not restricted to
this type of parser\. Normal LL and LR parsers can be implemented with it as
well\.

The following sections will discuss first the abstract state kept by ME virtual
machines, and then their instruction set\.

# <a name='section2'></a>MACHINE STATE

A ME virtual machine manages the following state:

  - *Current token* CT

    The token from the input under consideration by the machine\.

    This information is used and modified by the instructions defined in the
    section [TERMINAL MATCHING](#subsection1)\.

  - *Current location* CL

    The location of the *current token* in the input stream, as offset
    relative to the beginning of the stream\. The first token is considered to be
    at offset __0__\.

    This information is implicitly used and modified by the instructions defined
    in the sections [TERMINAL MATCHING](#subsection1) and [NONTERMINAL
    MATCHING](#subsection2), and can be directly queried and modified by the
    instructions defined in section [INPUT LOCATION
    HANDLING](#subsection5)\.

  - *Location stack* LS

    In addition to the above a stack of locations, for backtracking\. Locations
    can put on the stack, removed from it, and removed with setting the current
    location\.

    This information is implicitly used and modified by the instructions defined
    in the sections [TERMINAL MATCHING](#subsection1) and [NONTERMINAL
    MATCHING](#subsection2), and can be directly queried and modified by the
    instructions defined in section [INPUT LOCATION
    HANDLING](#subsection5)\.

  - *Match status* OK

    A boolean value, the result of the last attempt at matching input\. It is set
    to __true__ if that attempt was successful, and __false__ otherwise\.

    This information is influenced by the instructions defined in the sections
    [TERMINAL MATCHING](#subsection1), [NONTERMINAL
    MATCHING](#subsection2), and [UNCONDITIONAL
    MATCHING](#subsection3)\. It is queried by the instructions defined in
    the section [CONTROL FLOW](#subsection4)\.

  - *Semantic value* SV

    The semantic value associated with \(generated by\) the last attempt at
    matching input\. Contains either the empty string or a node for the abstract
    syntax tree constructed from the input\.

    This information is influenced by the instructions defined in the sections
    [SEMANTIC VALUES](#subsection7), and [AST STACK
    HANDLING](#subsection8)\.

  - *AST stack* AS

    A stack of partial abstract syntax trees constructed by the machine during
    matching\.

    This information is influenced by the instructions defined in the sections
    [SEMANTIC VALUES](#subsection7), and [AST STACK
    HANDLING](#subsection8)\.

  - *AST Marker stack* MS

    In addition to the above a stack of stacks, for backtracking\. This is
    actually a stack of markers into the AST stack, thus implicitly snapshooting
    the state of the AST stack at some point in time\. Markers can be put on the
    stack, dropped from it, and used to roll back the AST stack to an earlier
    state\.

    This information is influenced by the instructions defined in the sections
    [SEMANTIC VALUES](#subsection7), and [AST STACK
    HANDLING](#subsection8)\.

  - *Error status* ER

    Error information associated with the last attempt at matching input\.
    Contains either the empty string or a list of 2 elements, a location in the
    input and a list of error messages associated with it, in this order\.

    *Note* that error information can be set even if the last attempt at
    matching input was successful\. For example the \*\-operator \(matching a
    sub\-expression zero or more times\) in a parsing expression grammar is always
    successful, even if it encounters a problem further in the input and has to
    backtrack\. Such problems must not be forgotten when continuing to match\.

    This information is queried and influenced by the instructions defined in
    the sections [TERMINAL MATCHING](#subsection1), [NONTERMINAL
    MATCHING](#subsection2), and [ERROR HANDLING](#subsection6)\.

  - *Error stack* ES

    In addition to the above a stack of error information, to allow the merging
    of current and older error information when performing backtracking in
    choices after an unsucessful match\.

    This information is queried and influenced by the instructions defined in
    the sections [TERMINAL MATCHING](#subsection1), [NONTERMINAL
    MATCHING](#subsection2), and [ERROR HANDLING](#subsection6)\.

  - *Return stack* RS

    A stack of program counter values, i\.e\. locations in the code controlling
    the virtual machine, for the management of subroutine calls, i\.e\. the
    matching of nonterminal symbols\.

    This information is queried and influenced by the instructions defined in
    the section [NONTERMINAL MATCHING](#subsection2)\.

  - *Nonterminal cache* NC

    A cache of machine states \(A 4\-tuple containing a location in the input,
    match status *OK*, semantic value *SV*, and error status *ER*\) keyed
    by name of nonterminal symbol and location in the input stream\.

    The key location is where machine started the attempt to match the named
    nonterminal symbol, and the location in the value is where machine ended up
    after the attempt completed, independent of the success of the attempt\.

    This status is queried and influenced by the instructions defined in the
    section [NONTERMINAL MATCHING](#subsection2)\.

# <a name='section3'></a>MACHINE INSTRUCTIONS

With the machine state specified it is now possible to explain the instruction
set of ME virtual machines\. They are grouped roughly by the machine state they
influence and/or query\.

## <a name='subsection1'></a>TERMINAL MATCHING

First the instructions to match tokens from the input stream, and by extension
all terminal symbols\.

These instructions are the only ones which may retrieve a new token from the
input stream\. This is a *may* and not a *will* because the instructions will
a retrieve new token if, and only if the current location *CL* is at the head
of the stream\. If the machine has backtracked \(see __icl\_rewind__\) the
instructions will retrieve the token to compare against from the internal cache\.

  - __ict\_advance__ *message*

    This instruction tries to advance to the next token in the input stream,
    i\.e\. the one after the current location *CL*\. The instruction will fail
    if, and only if the end of the input stream is reached, i\.e\. if there is no
    next token\.

    The sucess/failure of the instruction is remembered in the match status
    *OK*\. In the case of failure the error status *ER* is set to the current
    location and the message *message*\. In the case of success the error
    status *ER* is cleared, the new token is made the current token *CT*,
    and the new location is made the current location *CL*\.

    The argument *message* is a reference to the string to put into the error
    status *ER*, if such is needed\.

  - __ict\_match\_token__ *tok* *message*

    This instruction tests the current token *CT* for equality with the
    argument *tok* and records the result in the match status *OK*\. The
    instruction fails if the current token is not equal to *tok*\.

    In case of failure the error status *ER* is set to the current location
    *CL* and the message *message*, and the current location *CL* is moved
    one token backwards\. Otherwise, i\.e\. upon success, the error status *ER*
    is cleared and the current location *CL* is not touched\.

  - __ict\_match\_tokrange__ *tokbegin* *tokend* *message*

    This instruction tests the current token *CT* for being in the range of
    tokens from *tokbegin* to *tokend* \(inclusive\) and records the result in
    the match status *OK*\. The instruction fails if the current token is not
    inside the range\.

    In case of failure the error status *ER* is set to the current location
    *CL* and the message *message*, and the current location *CL* is moved
    one token backwards\. Otherwise, i\.e\. upon success, the error status *ER*
    is cleared and the current location *CL* is not touched\.

  - __ict\_match\_tokclass__ *code* *message*

    This instruction tests the current token *CT* for being a member of the
    token class *code* and records the result in the match status *OK*\. The
    instruction fails if the current token is not a member of the specified
    class\.

    In case of failure the error status *ER* is set to the current location
    *CL* and the message *message*, and the current location *CL* is moved
    one token backwards\. Otherwise, i\.e\. upon success, the error status *ER*
    is cleared and the current location *CL* is not touched\.

    Currently the following classes are legal:

      * alnum

        A token is accepted if it is a unicode alphabetical character, or a
        digit\.

      * alpha

        A token is accepted if it is a unicode alphabetical character\.

      * digit

        A token is accepted if it is a unicode digit character\.

      * xdigit

        A token is accepted if it is a hexadecimal digit character\.

      * punct

        A token is accepted if it is a unicode punctuation character\.

      * space

        A token is accepted if it is a unicode space character\.

## <a name='subsection2'></a>NONTERMINAL MATCHING

The instructions in this section handle the matching of nonterminal symbols\.
They query the nonterminal cache *NC* for saved information, and put such
information into the cache\.

The usage of the cache is a performance aid for backtracking parsers, allowing
them to avoid an expensive rematch of complex nonterminal symbols if they have
been encountered before\.

  - __inc\_restore__ *branchlabel* *nt*

    This instruction checks if the nonterminal cache *NC* contains information
    about the nonterminal symbol *nt*, at the current location *CL*\. If that
    is the case the instruction will update the machine state \(current location
    *CL*, match status *OK*, semantic value *SV*, and error status *ER*\)
    with the found information and continue execution at the instruction refered
    to by the *branchlabel*\. The new current location *CL* will be the last
    token matched by the nonterminal symbol, i\.e\. belonging to it\.

    If no information was found the instruction will continue execution at the
    next instruction\.

    Together with __icf\_ntcall__ it is possible to generate code for
    memoized and non\-memoized matching of nonterminal symbols, either as
    subroutine calls, or inlined in the caller\.

  - __inc\_save__ *nt*

    This instruction saves the current state of the machine \(current location
    *CL*, match status *OK*, semantic value *SV*, and error status
    *ER*\), to the nonterminal cache *NC*\. It will also pop an entry from the
    location stack *LS* and save it as the start location of the match\.

    It is expected to be called at the end of matching a nonterminal symbol,
    with *nt* the name of the nonterminal symbol the code was working on\. This
    allows the instruction __inc\_restore__ to check for and retrieve the
    data, should we have to match this nonterminal symbol at the same location
    again, during backtracking\.

  - __icf\_ntcall__ *branchlabel*

    This instruction invokes the code for matching the nonterminal symbol *nt*
    as a subroutine\. To this end it stores the current program counter *PC* on
    the return stack *RS*, the current location *CL* on the location stack
    *LS*, and then continues execution at the address *branchlabel*\.

    The next matching __icf\_ntreturn__ will cause the execution to continue
    at the instruction coming after the call\.

  - __icf\_ntreturn__

    This instruction will pop an entry from the return stack *RS*, assign it
    to the program counter *PC*, and then continue execution at the new
    address\.

## <a name='subsection3'></a>UNCONDITIONAL MATCHING

The instructions in this section are the remaining match operators\. They change
the match status *OK* directly and unconditionally\.

  - __iok\_ok__

    This instruction sets the match status *OK* to __true__, indicating a
    successful match\.

  - __iok\_fail__

    This instruction sets the match status *OK* to __false__, indicating a
    failed match\.

  - __iok\_negate__

    This instruction negates the match status *OK*, turning a failure into a
    success and vice versa\.

## <a name='subsection4'></a>CONTROL FLOW

The instructions in this section implement both conditional and unconditional
control flow\. The conditional jumps query the match status *OK*\.

  - __icf\_jalways__ *branchlabel*

    This instruction sets the program counter *PC* to the address specified by
    *branchlabel* and then continues execution from there\. This is an
    unconditional jump\.

  - __icf\_jok__ *branchlabel*

    This instruction sets the program counter *PC* to the address specified by
    *branchlabel*\. This happens if, and only if the match status *OK*
    indicates a success\. Otherwise it simply continues execution at the next
    instruction\. This is a conditional jump\.

  - __icf\_jfail__ *branchlabel*

    This instruction sets the program counter *PC* to the address specified by
    *branchlabel*\. This happens if, and only if the match status *OK*
    indicates a failure\. Otherwise it simply continues execution at the next
    instruction\. This is a conditional jump\.

  - __icf\_halt__

    This instruction halts the machine and blocks any further execution\.

## <a name='subsection5'></a>INPUT LOCATION HANDLING

The instructions in this section are for backtracking, they manipulate the
current location *CL* of the machine state\. They allow a user of the machine
to query and save locations in the input, and to rewind the current location
*CL* to saved locations, making them one of the components enabling the
implementation of backtracking parsers\.

  - __icl\_push__

    This instruction pushes a copy of the current location *CL* on the
    location stack *LS*\.

  - __icl\_rewind__

    This instruction pops an entry from the location stack *LS* and then moves
    the current location *CL* back to this point in the input\.

  - __icl\_pop__

    This instruction pops an entry from the location stack *LS* and discards
    it\.

## <a name='subsection6'></a>ERROR HANDLING

The instructions in this section provide read and write access to the error
status *ER* of the machine\.

  - __ier\_push__

    This instruction pushes a copy of the current error status *ER* on the
    error stack *ES*\.

  - __ier\_clear__

    This instruction clears the error status *ER*\.

  - __ier\_nonterminal__ *message*

    This instruction checks if the error status *ER* contains an error whose
    location is just past the location found in the top entry of the location
    stack *LS*\. Nothing happens if no such error is found\. Otherwise the found
    error is replaced by an error at the location found on the stack, having the
    message *message*\.

  - __ier\_merge__

    This instruction pops an entry from the error stack *ES*, merges it with
    the current error status *ER* and stores the result of the merge as the
    new error status *ER*\.

    The merge is performed as described below:

    If one of the two error states is empty the other is chosen\. If neither
    error state is empty, and refering to different locations, then the error
    state with the location further in the input is chosen\. If both error states
    refer to the same location their messages are merged \(with removing
    duplicates\)\.

## <a name='subsection7'></a>SEMANTIC VALUES

The instructions in this section manipulate the semantic value *SV*\.

  - __isv\_clear__

    This instruction clears the semantic value *SV*\.

  - __isv\_terminal__

    This instruction creates a terminal AST node for the current token *CT*,
    makes it the semantic value *SV*, and also pushes the node on the AST
    stack *AS*\.

  - __isv\_nonterminal\_leaf__ *nt*

    This instruction creates a nonterminal AST node without any children for the
    nonterminal *nt*, and makes it the semantic value *SV*\.

    This instruction should be executed if, and only if the match status *OK*
    indicates a success\. In the case of a failure __isv\_clear__ should be
    called\.

  - __isv\_nonterminal\_range__ *nt*

    This instruction creates a nonterminal AST node for the nonterminal *nt*,
    with a single terminal node as its child, and makes this AST the semantic
    value *SV*\. The terminal node refers to the input string from the location
    found on top of the location stack *LS* to the current location *CL*
    \(both inclusive\)\.

    This instruction should be executed if, and only if the match status *OK*
    indicates a success\. In the case of a failure __isv\_clear__ should be
    called\.

  - __isv\_nonterminal\_reduce__ *nt*

    This instruction creates a nonterminal AST node for the nonterminal *nt*
    and makes it the semantic value *SV*\.

    All entries on the AST stack *AS* above the marker found in the top entry
    of the AST Marker stack *MS* become children of the new node, with the
    entry at the stack top becoming the rightmost child\. If the AST Marker stack
    *MS* is empty the whole stack is used\. The AST marker stack *MS* is left
    unchanged\.

    This instruction should be executed if, and only if the match status *OK*
    indicates a success\. In the case of a failure __isv\_clear__ should be
    called\.

## <a name='subsection8'></a>AST STACK HANDLING

The instructions in this section manipulate the AST stack *AS*, and the AST
Marker stack *MS*\.

  - __ias\_push__

    This instruction pushes the semantic value *SV* on the AST stack *AS*\.

  - __ias\_mark__

    This instruction pushes a marker for the current state of the AST stack
    *AS* on the AST Marker stack *MS*\.

  - __ias\_mrewind__

    This instruction pops an entry from the AST Marker stack *MS* and then
    proceeds to pop entries from the AST stack *AS* until the state
    represented by the popped marker has been reached again\. Nothing is done if
    the AST stack *AS* is already smaller than indicated by the popped marker\.

  - __ias\_mpop__

    This instruction pops an entry from the AST Marker stack *MS* and discards
    it\.

# <a name='section4'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *grammar\_me* of the
[Tcllib Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report
any ideas for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[grammar](\.\./\.\./\.\./\.\./index\.md\#grammar),
[parsing](\.\./\.\./\.\./\.\./index\.md\#parsing), [virtual
machine](\.\./\.\./\.\./\.\./index\.md\#virtual\_machine)

# <a name='category'></a>CATEGORY

Grammars and finite automata

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2005 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>
