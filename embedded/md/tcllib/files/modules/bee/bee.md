
[//000000001]: # (bee \- BitTorrent)
[//000000002]: # (Generated from file 'bee\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (bee\(n\) 0\.3 tcllib "BitTorrent")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

bee \- BitTorrent Serialization Format Encoder/Decoder

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

      - [Encoder](#subsection1)

      - [Decoder](#subsection2)

  - [Format Definition](#section3)

  - [Examples](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require bee ?0\.3?  

[__::bee::encodeString__ *string*](#1)  
[__::bee::encodeNumber__ *integer*](#2)  
[__::bee::encodeListArgs__ ?*beevalue \.\.\.*?](#3)  
[__::bee::encodeList__ *listofbees*](#4)  
[__::bee::encodeDictArgs__ ?*key beevalue \.\.\.*?](#5)  
[__::bee::encodeDict__ *dictofbees*](#6)  
[__::bee::decode__ *beestring* ?*endVar*? ?*start*?](#7)  
[__::bee::decodeIndices__ *beestring* ?*endVar*? ?*start*?](#8)  
[__::bee::decodeChannel__ *chan* __\-command__ *on\_decode* ?__\-exact__? ?__\-prefix__ *data*?](#9)  
[__on\_decode__ __value__ *handle* *value*](#10)  
[__on\_decode__ __error__ *handle* *message*](#11)  
[__on\_decode__ __eof__ *handle*](#12)  
[__::bee::decodeCancel__ *handle*](#13)  
[__::bee::decodePush__ *handle* *string*](#14)  

# <a name='description'></a>DESCRIPTION

This package provides encoding and decoding commands for data in Bencode \(spoken
as “bee\-encode”\), the BitTorrent protocol’s serialization format used for data
and messages\.

# <a name='section2'></a>API

## <a name='subsection1'></a>Encoder

This package provides an encoder command for each value type \(string and
integer\), and two commands per collection type \(list and dict\), one taking a
complete Tcl collection to encode, the other taking the same data given as
arguments\.

  - <a name='1'></a>__::bee::encodeString__ *string*

    Returns the bee\-encoding of the *string*\.

  - <a name='2'></a>__::bee::encodeNumber__ *integer*

    Returns the bee\-encoding of the *integer* number\.

    This command will throw an error if *integer* is not an integer\.

  - <a name='3'></a>__::bee::encodeListArgs__ ?*beevalue \.\.\.*?

    Returns a bee\-encoded list of the given zero or more bee\-encoded
    *beevalue*s\.

  - <a name='4'></a>__::bee::encodeList__ *listofbees*

    Returns a bee\-encoded list of the given Tcl list, *listofbees*, of
    bee\-encoded values\.

  - <a name='5'></a>__::bee::encodeDictArgs__ ?*key beevalue \.\.\.*?

    Returns a bee\-encoded dict of the given zero or more pairs of Tcl string
    keys and bee\-encoded *beevalue*s\.

    This command will bee\-encode each string key itself\.

  - <a name='6'></a>__::bee::encodeDict__ *dictofbees*

    Returns a bee\-encoded dict of the given Tcl dict, *dictofbees*, whose keys
    must be Tcl strings and whose values must be bee\-encoded values\.

    This command will bee\-encode each string key itself\.

## <a name='subsection2'></a>Decoder

This package provides decoding commands for bee\-encoded strings and for
bee\-encoded data received over a channel\.

The commands for decoding a bee\-encoded string expect the string to contain one
or more complete bee\-encoded values \(which may themselves contain nested
bee\-encoded lists and dicts\)\.

The command for the incremental decoding of bee\-values arriving on a channel is
asynchronous and provides the completed decoded values via a callback\.

  - <a name='7'></a>__::bee::decode__ *beestring* ?*endVar*? ?*start*?

    Returns a bee\-decoded value from the *beestring*, starting from index
    position *start* if given—or from its default of __0__, and sets
    *endVar* if given\.

    If the bee\-encoded value is a string or integer, the equivalent Tcl string
    or integer is returned\.

    If the bee\-encoded value is a collection \(a bee\-list or a bee\-dict\), then a
    corresponding Tcl list or Tcl dict is returned\. And in either of these
    cases, all contained values \(including nested bee\-lists and bee\-dicts\) are
    all bee\-decoded, so that the result is a Tcl list or dict with all the
    nested values fully bee\-decoded into Tcl lists, dicts, strings, or integers,
    as appropriate\.

    If the option *endVar* is given, it is the name of a variable used to
    store the index position of the first character in the *beestring* that
    *follows* the value that’s just been decoded, i\.e\., the start position of
    the next value to decode\. This is useful if the *beestring* contains two
    or more bee\-encoded values concatenated together \(as opposed to a single
    bee\-encoded list of bee\-encoded values\)\. See the last example in the
    [Examples](#section4)\.

    The optional *start* is the index position from which the next bee\-encoded
    value will be read and decoded\.

  - <a name='8'></a>__::bee::decodeIndices__ *beestring* ?*endVar*? ?*start*?

    Returns a list based on the bee\-decoded value from the *beestring*,
    starting from index position *start* if given—or from its default of
    __0__, and sets *endVar* if given\. The meaning and use of *endVar*
    and *start* are exactly the same as for __::bee::decode__\.

    The returned list’s elements depend on the type of the bee\-decoded value\. In
    all cases though, the first element is a type name \(one of __string__
    __integer__ __list__ __dict__\), and the second and third
    elements are the start and end index positions in the *beestring* for the
    bee\-encoded value\. For bee\-lists and bee\-dicts there is a fourth element
    which provides details of their contained bee\-values\.

    Formally the result lists for the various types of bee\-values are:

      * string

        A list containing three elements:

          + A constant string indicating the value’s type, for strings it is
            __string__\.

          + The index position \(*>= 0*\) of the first character of the
            bee\-value in the given *beestring*\.

          + The index position \(*>= 0*\) of the last character of the bee\-value
            in the given *beestring*\.

        *Every result list, for every bee\-value, begins with these three*
        *elements\.*

      * integer

        A list containing the constant string __integer__ and—just the same
        as for strings—the start and end index positions of the bee\-value in the
        *beestring*\.

      * list

        A list containing the constant string __list__ and—just the same as
        for strings—the start and end index positions of the bee\-value in the
        *beestring*\.

        In addition the list has a fourth element, which itself contains the
        index data as described here for all the elements of the bee\-list\.

      * dictionary

        A list containing the constant string __dict__ and—just the same as
        for strings—the start and end index positions of the bee\-value in the
        *beestring*\.

        In addition the dict has a fourth element\. This element is a dictionary
        mapping from each of the bee\-dict’s string keys to a 2\-element list of
        2\-element lists\. The list’s first element’s list contains the index
        positions for the key, and the second element’s list contains the index
        positions for the value the key maps to\. This structure is the only one
        which contains not only index positions, but actual values from the
        *beestring*\. While each key’s index positions are unique, i\.e\., usable
        as a key, they are not easy to navigate when trying to find a particular
        element\. Using actual keys makes navigation much easier, which is why
        they’re provided\.

  - <a name='9'></a>__::bee::decodeChannel__ *chan* __\-command__ *on\_decode* ?__\-exact__? ?__\-prefix__ *data*?

    This command creates a decoder for a series of bee\-values arriving on the
    channel *chan* and returns a decoder handle\. Each decoding event is
    reported to the required *on\_decode* callback command\.

    The returned handle can be used to push data into the decoder or to cancel
    the decoder\.

    Attempting to create another bee decoder on the *chan* channel while an
    existing bee decoder is still active will throw an error\.

      * __\-command__

        The *on\_decode* command specified by the *required* option
        __\-command__ is used to report decoded values, errors, and channel
        EOF\.

        The callback is executed at the interpreter’s global level, with two or
        three arguments\. The possible callback signatures are:

          + <a name='10'></a>__on\_decode__ __value__ *handle* *value*

            The decoder received and successfully decoded a bee\-value\. The
            format of the equivalent Tcl *value* is the same as returned by
            __::bee::decode__\. The channel is still open and the decoder
            handle is valid\. This means that the callback is able to push data
            into the decoder or to cancel the decoder\.

          + <a name='11'></a>__on\_decode__ __error__ *handle* *message*

            The decoder encountered an error, which is not EOF\. For example, an
            invalid bee\-value\. The *message* provides details about the error\.
            The decoder handle is in the same state as for EOF, i\.e\., invalid,
            and cannot be used\. However, the channel remains open\.

          + <a name='12'></a>__on\_decode__ __eof__ *handle*

            The decoder has reached EOF on the *chan* channel\. No further
            calls to the callback will be made after this\. The channel has
            already been closed at the time of the call, and the *handle* is
            invalid and cannot be used\.

      * __\-exact__

        By default the decoder assumes that all the channel’s data consists of
        bee\-values, and reads as much as possible per event, without regard for
        boundaries between bee\-values\. This means that if the the channel
        contains non\-bee data after a series of bee\-values, the beginning of any
        non\-bee data may be lost, because it has already been read by the
        decoder, but not processed\.

        In such cases use the __\-exact__ option\. When this is specified, the
        decoder will not read any characters beyond the currently processed
        bee\-value, so that any non\-bee data is left in the channel for further
        processing after the decoder is closed\.

      * __\-prefix__

        If this option is specified its value is assumed to be the beginning of
        a bee\-value and is used to initialize the decoder’s internal buffer\.
        This feature is required if the creator of the decoder read data from
        the channel to determine if it should create the decoder or not\. Without
        the option this initial data would be lost to the decoding\.

  - <a name='13'></a>__::bee::decodeCancel__ *handle*

    This command cancels the decoder set up by __::bee::decodeChannel__ and
    represented by the handle *handle*\.

  - <a name='14'></a>__::bee::decodePush__ *handle* *string*

    This command appends the *string* to the decoder’s internal buffer\. It is
    the runtime equivalent of the __::bee::decodeChannel__ command’s
    __\-prefix__ option\. Use this command to push data back into the decoder
    when the __on\_decode value__ callback used data from the channel to
    determine if it should decode another bee\-value or not\.

# <a name='section3'></a>Format Definition

Data in the Bencode serialization format is constructed from two basic forms,
and two collection forms\. The basic forms are strings and integerss, and the
collections are lists and dictionaries\.

  - String *S*

    A string *S* of length *L* is encoded by the string
    "*L*__:__*S*", where the length is in textual form\. For example, the
    string __"Bencode format"__ would be encoded as __"14:Bencode
    format"__\.

  - Integer *N*

    An integer *N* is encoded by the string "__i__*N*__e__"\. For
    example, the integer __\-482__ would be encoded as __"i\-482e"__\.

  - List *v1* \.\.\. *vn*

    A list of the values *v1* to *vn* is encoded by the string
    "__l__*BV1*\.\.\.*BVn*__e__" where "BV__i__" is the
    bee\-encoding of the value "v__i__"\.

  - Dict *k1* \-> *v1* \.\.\.

    A dictionary mapping the string key *k*__i__ to the value
    *v*__i__, for __i__ in __1__ \.\.\. __n__ is encoded by the
    string "__d__*BK*__i__*BV*__i__\.\.\.__e__" for i in
    __1__ \.\.\. __n__, where "BK__i__" is the bee\-encoding of the key
    string "k__i__"\. and "BV__i__" is the bee\-encoding of the value
    "v__i__"\.

    *Note*: The bee\-encoding does not preserve the order of the keys in the
    input, but stores in key\-sorted order\.

Note that the type of each encoded item can be determined immediately from the
first character of its encoding:

  - __i__

    Integer\.

  - __l__

    List\.

  - __d__

    Dictionary\.

  - __\[0\-9\]__

    String\.

By prefixing integers with __i__ the format ensures that they are different
from strings, which all begin with a digit\.

# <a name='section4'></a>Examples

This example shows how to bee\-encode and bee\-decode individual strings and
integers\.

    const LABEL "Δ÷ “Utf-8” ♞ℤ"
    set labelbeeEnc [::bee::encodeString $LABEL]
    set labelbeeDec [::bee::decode $labelbeeEnc]
    puts "labelbeeEnc='$labelbeeEnc' eq LABEL → [expr {$labelbeeDec eq $LABEL}]"
    set xbeeEnc [::bee::encodeNumber 834]
    set ybeeEnc [::bee::encodeNumber -172]
    set ybeeDec [::bee::decode $ybeeEnc]
    puts "ybeeEnc='$ybeeEnc' == -172 → [expr {$ybeeDec == -172}]"
    =>
    labelbeeEnc='13:Δ÷ “Utf-8” ♞ℤ' eq LABEL → 1
    ybeeEnc='i-172e' == -172 → 1

This example shows how to bee\-encode collections of bee\-encoded values\.

    set pointbeeEnc [::bee::encodeList [list $xbeeEnc $ybeeEnc]]
    set placebeeEnc [::bee::encodeDictArgs label $labelbeeEnc point $pointbeeEnc]
    puts "pointbeeEnc='$pointbeeEnc'"
    puts "placebeeEnc='$placebeeEnc'"
    =>
    pointbeeEnc='li834ei-172ee'
    placebeeEnc='d5:label13:Δ÷ “Utf-8” ♞ℤ5:pointli834ei-172eee'

This example shows how to bee\-decode collections of bee\-encoded values\.

    set placebeeDec [::bee::decode $placebeeEnc]
    set label [dict get $placebeeDec label]
    puts "label='$label' eq LABEL → [expr {$label eq $LABEL}]"
    lassign [dict get $placebeeDec point] x y
    puts "x=$x == 834 → [expr {$x == 834}] • y=$y == -172 → [expr {$y == -172}]"
    =>
    label='Δ÷ “Utf-8” ♞ℤ' eq LABEL → 1
    x=834 == 834 → 1 • y=-172 == -172 → 1

This example shows how to bee\-decode using the __::bee::decodeIndices__
command\.

    set labelbeeDecInd [::bee::decodeIndices $labelbeeEnc]
    lassign $labelbeeDecInd type i j
    set label [::bee::decode [string range $labelbeeEnc $i $j]]
    puts "labelbeeDecInd type=$type i=$i j=$j label='$label'"
    =>
    labelbeeDecInd type=string i=0 j=15 label='Δ÷ “Utf-8” ♞ℤ'

This example shows how to bee\-encode and then bee\-decode a sequence of
*separate* bee\-encoded values\.

    set stream [::bee::encodeString "€⅔•"][::bee::encodeNumber -91][::bee::encodeString "α-ω"][::bee::encodeNumber 68]
    for {set i 0} {$i < [string length $stream]} {} {
        lappend items [::bee::decode $stream i $i]
    }
    puts "stream='$stream' items={$items} size=[llength $items]"
    =>
    stream='3:€⅔•i-91e3:α-ωi68e' items={€⅔• -91 α-ω 68} size=4

# <a name='section5'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *bee* as the
category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[BitTorrent](\.\./\.\./\.\./\.\./index\.md\#bittorrent),
[bee](\.\./\.\./\.\./\.\./index\.md\#bee),
[bittorrent](\.\./\.\./\.\./\.\./index\.md\#bittorrent),
[serialization](\.\./\.\./\.\./\.\./index\.md\#serialization),
[torrent](\.\./\.\./\.\./\.\./index\.md\#torrent)

# <a name='category'></a>CATEGORY

Networking

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>
