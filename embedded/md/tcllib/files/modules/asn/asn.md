
[//000000001]: # (asn \- ASN\.1 processing)
[//000000002]: # (Generated from file 'asn\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (Copyright &copy; 2004 Jochen Loewer <loewerj@web\.de>)
[//000000005]: # (Copyright &copy; 2004\-2011 Michael Schlenker <mic42@users\.sourceforge\.net>)
[//000000006]: # (asn\(n\) 0\.8 tcllib "ASN\.1 processing")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

asn \- ASN\.1 BER encoder/decoder

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [PUBLIC API](#section2)

      - [ENCODER](#subsection1)

      - [DECODER](#subsection2)

      - [HANDLING TAGS](#subsection3)

  - [EXAMPLES](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require asn ?0\.8\.5?  

[__::asn::asnSequence__ ?*evalue \.\.\.*?](#1)  
[__::asn::asnSequenceFromList__ *elist*](#2)  
[__::asn::asnSet__ ?*evalue \.\.\.*?](#3)  
[__::asn::asnSetFromList__ *elist*](#4)  
[__::asn::asnApplicationConstr__ *appNumber* ?*evalue \.\.\.*?](#5)  
[__::asn::asnApplication__ *appNumber* *data*](#6)  
[__::asn::asnChoice__ *appNumber* ?*evalue \.\.\.*?](#7)  
[__::asn::asnChoiceConstr__ *appNumber* ?*evalue \.\.\.*?](#8)  
[__::asn::asnInteger__ *number*](#9)  
[__::asn::asnEnumeration__ *number*](#10)  
[__::asn::asnBoolean__ *bool*](#11)  
[__::asn::asnContext__ *context* *data*](#12)  
[__::asn::asnContextConstr__ *context* ?*evalue \.\.\.*?](#13)  
[__::asn::asnObjectIdentifier__ *idlist*](#14)  
[__::asn::asnUTCTime__ *utcstring*](#15)  
[__::asn::asnNull__](#16)  
[__::asn::asnBitString__ *string*](#17)  
[__::asn::asnOctetString__ *string*](#18)  
[__::asn::asnNumericString__ *string*](#19)  
[__::asn::asnPrintableString__ *string*](#20)  
[__::asn::asnIA5String__ *string*](#21)  
[__::asn::asnBMPString__ *string*](#22)  
[__::asn::asnUTF8String__ *string*](#23)  
[__::asn::asnString__ *string*](#24)  
[__::asn::defaultStringType__ ?*type*?](#25)  
[__::asn::asnPeekByte__ *dataVar* *byteVar*](#26)  
[__::asn::asnGetLength__ *dataVar* *lengthVar*](#27)  
[__::asn::asnGetResponse__ *chan* *dataVar*](#28)  
[__::asn::asnGetInteger__ *dataVar* *intVar*](#29)  
[__::asn::asnGetEnumeration__ *dataVar* *enumVar*](#30)  
[__::asn::asnGetOctetString__ *dataVar* *stringVar*](#31)  
[__::asn::asnGetString__ *dataVar* *stringVar* ?*typeVar*?](#32)  
[__::asn::asnGetNumericString__ *dataVar* *stringVar*](#33)  
[__::asn::asnGetPrintableString__ *dataVar* *stringVar*](#34)  
[__::asn::asnGetIA5String__ *dataVar* *stringVar*](#35)  
[__::asn::asnGetBMPString__ *dataVar* *stringVar*](#36)  
[__::asn::asnGetUTF8String__ *dataVar* *stringVar*](#37)  
[__::asn::asnGetUTCTime__ *dataVar* *utcVar*](#38)  
[__::asn::asnGetBitString__ *dataVar* *bitsVar*](#39)  
[__::asn::asnGetObjectIdentifier__ *dataVar* *oidVar*](#40)  
[__::asn::asnGetBoolean__ *dataVar* *boolVar*](#41)  
[__::asn::asnGetNull__ *dataVar*](#42)  
[__::asn::asnGetSequence__ *dataVar* *sequenceVar*](#43)  
[__::asn::asnGetSet__ *dataVar* *setVar*](#44)  
[__::asn::asnGetApplication__ *dataVar* *appNumberVar* ?*contentVar*? ?*encodingTypeVar*?](#45)  
[__::asn::asnGetContext__ *dataVar* *contextNumberVar* ?*contentVar*? ?*encodingTypeVar*?](#46)  
[__::asn::asnPeekTag__ *dataVar* *tagVar* *tagtypeVar* *constrVar*](#47)  
[__::asn::asnTag__ *tagnumber* ?*class*? ?*tagstyle*?](#48)  
[__::asn::asnRetag__ *dataVar* *newTag*](#49)  

# <a name='description'></a>DESCRIPTION

The __asn__ package provides *partial* de\- and encoder commands for BER
encoded ASN\.1 data\. It can also be used for decoding DER, which is a restricted
subset of BER\.

ASN\.1 is a standard *Abstract Syntax Notation*, and BER are its *Basic
Encoding Rules*\.

See
[http://asn1\.elibel\.tm\.fr/en/standards/index\.htm](http://asn1\.elibel\.tm\.fr/en/standards/index\.htm)
for more information about the standard\.

Also see
[http://luca\.ntop\.org/Teaching/Appunti/asn1\.html](http://luca\.ntop\.org/Teaching/Appunti/asn1\.html)
for *A Layman's Guide to a Subset of ASN\.1, BER, and DER*, an RSA Laboratories
Technical Note by Burton S\. Kaliski Jr\. \(Revised November 1, 1993\)\. A text
version of this note is part of the module sources and should be read by any
implementor\.

# <a name='section2'></a>PUBLIC API

## <a name='subsection1'></a>ENCODER

  - <a name='1'></a>__::asn::asnSequence__ ?*evalue \.\.\.*?

    Takes zero or more encoded values, packs them into an ASN sequence and
    returns its encoded binary form\.

  - <a name='2'></a>__::asn::asnSequenceFromList__ *elist*

    Takes a list of encoded values, packs them into an ASN sequence and returns
    its encoded binary form\.

  - <a name='3'></a>__::asn::asnSet__ ?*evalue \.\.\.*?

    Takes zero or more encoded values, packs them into an ASN set and returns
    its encoded binary form\.

  - <a name='4'></a>__::asn::asnSetFromList__ *elist*

    Takes a list of encoded values, packs them into an ASN set and returns its
    encoded binary form\.

  - <a name='5'></a>__::asn::asnApplicationConstr__ *appNumber* ?*evalue \.\.\.*?

    Takes zero or more encoded values, packs them into an ASN application
    construct and returns its encoded binary form\.

  - <a name='6'></a>__::asn::asnApplication__ *appNumber* *data*

    Takes a single encoded value *data*, packs it into an ASN application
    construct and returns its encoded binary form\.

  - <a name='7'></a>__::asn::asnChoice__ *appNumber* ?*evalue \.\.\.*?

    Takes zero or more encoded values, packs them into an ASN choice construct
    and returns its encoded binary form\.

  - <a name='8'></a>__::asn::asnChoiceConstr__ *appNumber* ?*evalue \.\.\.*?

    Takes zero or more encoded values, packs them into an ASN choice construct
    and returns its encoded binary form\.

  - <a name='9'></a>__::asn::asnInteger__ *number*

    Returns the encoded form of the specified integer *number*\.

  - <a name='10'></a>__::asn::asnEnumeration__ *number*

    Returns the encoded form of the specified enumeration id *number*\.

  - <a name='11'></a>__::asn::asnBoolean__ *bool*

    Returns the encoded form of the specified boolean value *bool*\.

  - <a name='12'></a>__::asn::asnContext__ *context* *data*

    Takes an encoded value and packs it into a constructed value with
    application tag, the *context* number\.

  - <a name='13'></a>__::asn::asnContextConstr__ *context* ?*evalue \.\.\.*?

    Takes zero or more encoded values and packs them into a constructed value
    with application tag, the *context* number\.

  - <a name='14'></a>__::asn::asnObjectIdentifier__ *idlist*

    Takes a list of at least two integers describing an object identifier \(OID\)
    value, and returns the encoded value\.

  - <a name='15'></a>__::asn::asnUTCTime__ *utcstring*

    Returns the encoded form of the specified UTC time string\.

  - <a name='16'></a>__::asn::asnNull__

    Returns the NULL encoding\.

  - <a name='17'></a>__::asn::asnBitString__ *string*

    Returns the encoded form of the specified *string*\.

  - <a name='18'></a>__::asn::asnOctetString__ *string*

    Returns the encoded form of the specified *string*\.

  - <a name='19'></a>__::asn::asnNumericString__ *string*

    Returns the *string* encoded as an ASN\.1 NumericString\. Raises an error if
    the *string* contains characters other than decimal digits and spaces\.

  - <a name='20'></a>__::asn::asnPrintableString__ *string*

    Returns the *string* encoding as ASN\.1 PrintableString\. Raises an error if
    the *string* contains characters which are not allowed by the Printable
    String datatype\. The allowed characters are A\-Z, a\-z, 0\-9, space,
    apostrophe, colon, parentheses, plus, minus, comma, period, forward slash,
    question mark, and the equals sign\.

  - <a name='21'></a>__::asn::asnIA5String__ *string*

    Returns the *string* encoded as ASN\.1 IA5String\. Raises an error if the
    *string* contains any characters outside of the US\-ASCII range\.

  - <a name='22'></a>__::asn::asnBMPString__ *string*

    Returns the *string* encoded as ASN\.1 Basic Multilingual Plane string
    \(Which is essentialy big\-endian UCS2\)\.

  - <a name='23'></a>__::asn::asnUTF8String__ *string*

    Returns the *string* encoded as UTF8 String\. Note that some legacy
    applications such as Windows CryptoAPI may not work correctly with UTF8
    strings\. It may be safest to use BMPStrings\.

  - <a name='24'></a>__::asn::asnString__ *string*

    Returns an encoded form of *string*, choosing the most restricted ASN\.1
    string type possible\. If the string contains non\-ASCII characters, then
    there is more than one string type which can be used\. See
    __::asn::defaultStringType__\.

  - <a name='25'></a>__::asn::defaultStringType__ ?*type*?

    Selects the string type to use for the encoding of non\-ASCII strings\.
    Returns current default when called without argument\. If the argument
    *type* is supplied, it should be either __UTF8__ or __BMP__ to
    choose UTF8String or BMPString respectively\.

## <a name='subsection2'></a>DECODER

General notes:

  1. Nearly all getter \(decoder\) commands take two arguments\. These arguments
     are variable names, *except* for __::asn::asnGetResponse__\. The
     *dataVar* variable contains the encoded ASN values to decode\. When a
     value getter \(decoder\) is called, the value is stored in the second
     variable, and the remaining input is stored back in the first *dataVar*
     variable\.

  1. When getting \(decoding\), the *dataVar* variable is modified first, before
     the decoded value is stored in the second variable\. This means that if both
     arguments refer to the same variable, it will always contain the decoded
     value after the call, and not the remainder of the input\.

  - <a name='26'></a>__::asn::asnPeekByte__ *dataVar* *byteVar*

    Return a copy of the first byte of the data, without modifing *dataVar*\.
    This can be used to check for implicit tags\.

  - <a name='27'></a>__::asn::asnGetLength__ *dataVar* *lengthVar*

    Decode the length information for a block of BER data\. The tag has already
    to be removed from the data\.

  - <a name='28'></a>__::asn::asnGetResponse__ *chan* *dataVar*

    Reads an encoded ASN *sequence* from the channel *chan* and stores it
    into the variable called *dataVar*\.

  - <a name='29'></a>__::asn::asnGetInteger__ *dataVar* *intVar*

    Decodes the integer value encoded at the start of the data stored in the
    variable called *dataVar*\. The integer is stored in the variable called
    *intVar*, and the decoded bytes are removed from the start of the data in
    *dataVar*, ready for the next value to be decoded\. If the value at the
    start is not an encoded integer an error is thrown\.

  - <a name='30'></a>__::asn::asnGetEnumeration__ *dataVar* *enumVar*

    Decodes the enumeration ID value encoded at the start of the data stored in
    the variable called *dataVar*\. The enumeration ID is stored in the
    variable called *enumVar*, and the decoded bytes are removed from the
    start of the data in *dataVar*, ready for the next value to be decoded\. If
    the value at the start is not an encoded enumeration ID an error is thrown\.

  - <a name='31'></a>__::asn::asnGetOctetString__ *dataVar* *stringVar*

    Decodes the string value encoded at the start of the data stored in the
    variable called *dataVar*\. The string is stored in the variable called
    *stringVar*, and the decoded bytes are removed from the start of the data
    in *dataVar*, ready for the next value to be decoded\. If the value at the
    start is not an encoded string an error is thrown\.

  - <a name='32'></a>__::asn::asnGetString__ *dataVar* *stringVar* ?*typeVar*?

    Decodes the user\-readable string value encoded at the start of the data
    stored in the variable called *dataVar*\. The string is stored in the
    variable called *stringVar*, and the decoded bytes are removed from the
    start of the data in *dataVar*, ready for the next value to be decoded\. If
    the value at the start is not an encoded string an error is thrown\.

    This is a convenience function which is able to automatically distinguish
    all supported ASN\.1 string types and convert the input value appropriately\.

    See __::asn::asnGetPrintableString__, __::asnGetIA5String__, etc\.,
    below for the type\-specific conversion commands\.

    If the optional third argument *typeVar* is supplied, then the incoming
    string’s type is stored in the variable it names\.

    The function throws the error "Invalid command name
    asnGetSome__UnsupportedString__" if the unsupported string type
    __Unsupported__ is encountered\. You can create the appropriate function
    "asn::asnGetSome__UnsupportedString__" in your application if
    neccessary\.

  - <a name='33'></a>__::asn::asnGetNumericString__ *dataVar* *stringVar*

    Decodes the numeric string value encoded at the start of the data stored in
    the variable called *dataVar*\. The numeric string is stored in the
    variable called *stringVar*, and the decoded bytes are removed from the
    start of the data in *dataVar*, ready for the next value to be decoded\. If
    the value at the start is not an encoded numeric string an error is thrown\.

  - <a name='34'></a>__::asn::asnGetPrintableString__ *dataVar* *stringVar*

    Decodes the printable string value encoded at the start of the data stored
    in the variable called *dataVar*\. The printable string is stored in the
    variable called *stringVar*, and the decoded bytes are removed from the
    start of the data in *dataVar*, ready for the next value to be decoded\. If
    the value at the start is not an encoded printable string an error is
    thrown\.

  - <a name='35'></a>__::asn::asnGetIA5String__ *dataVar* *stringVar*

    Decodes the IA5 \(US\-ASCII\) string value encoded at the start of the data
    stored in the variable called *dataVar*\. The IA5 string is stored in the
    variable called *stringVar*, and the decoded bytes are removed from the
    start of the data in *dataVar*, ready for the next value to be decoded\. If
    the value at the start is not an encoded IA5 string an error is thrown\.

  - <a name='36'></a>__::asn::asnGetBMPString__ *dataVar* *stringVar*

    Decodes the BMP \(two\-byte unicode—UCS2\) string value encoded at the start of
    the data stored in the variable called *dataVar*\. The BMP string is
    converted into a proper Tcl string which is then stored in the variable
    called *stringVar*, and the decoded bytes are removed from the start of
    the data in *dataVar*, ready for the next value to be decoded\. If the
    value at the start is not an encoded BMP string an error is thrown\.

  - <a name='37'></a>__::asn::asnGetUTF8String__ *dataVar* *stringVar*

    Decodes the UTF8 string value encoded at the start of the data stored in the
    variable called *dataVar*\. The UTF8 string is converted into a proper Tcl
    string which is then stored in the variable called *stringVar*, and the
    decoded bytes are removed from the start of the data in *dataVar*, ready
    for the next value to be decoded\. If the value at the start is not an
    encoded UTF8 string an error is thrown\.

  - <a name='38'></a>__::asn::asnGetUTCTime__ *dataVar* *utcVar*

    Decodes the UTC time value encoded at the start of the data stored in the
    variable called *dataVar*\. The UTC time value is stored in the variable
    called *utcVar*, and the decoded bytes are removed from the start of the
    data in *dataVar*, ready for the next value to be decoded\. The value
    stored in *utcVar* is a string; to get an actual time value, use the
    __clock scan__ command\. If the value at the start is not an encoded UTC
    time value an error is thrown\.

  - <a name='39'></a>__::asn::asnGetBitString__ *dataVar* *bitsVar*

    Decodes the bit string value encoded at the start of the data stored in the
    variable called *dataVar*\. The bit string is stored in the variable called
    *bitsVar*, and the decoded bytes are removed from the start of the data in
    *dataVar*, ready for the next value to be decoded\. The value stored in
    *bitsVar* is a string that contains only __"0"__ and __"1"__
    characters\. If the value at the start is not an encoded bit string an error
    is thrown\.

  - <a name='40'></a>__::asn::asnGetObjectIdentifier__ *dataVar* *oidVar*

    Decodes the object identifier \(OID\) value encoded at the start of the data
    stored in the variable called *dataVar*\. The OID is stored in the variable
    called *oidVar*, and the decoded bytes are removed from the start of the
    data in *dataVar*, ready for the next value to be decoded\. The value
    stored in *oidVar* is a list of integers\. If the value at the start is not
    an encoded OID an error is thrown\.

  - <a name='41'></a>__::asn::asnGetBoolean__ *dataVar* *boolVar*

    Decodes the Boolean value encoded at the start of the data stored in the
    variable called *dataVar*\. The Boolean is stored in the variable called
    *boolVar*, and the decoded bytes are removed from the start of the data in
    *dataVar*, ready for the next value to be decoded\. The value stored in
    *boolVar* is either __0__ or __1__\. If the value at the start is
    not an encoded Boolean an error is thrown\.

  - <a name='42'></a>__::asn::asnGetNull__ *dataVar*

    Decodes the NULL value encoded at the start of the data stored in the
    variable called *dataVar* and removes the decoded bytes from the start of
    the data in *dataVar*, ready for the next value to be decoded\. If the
    value at the start is not an encoded NULL value an error is thrown\.

  - <a name='43'></a>__::asn::asnGetSequence__ *dataVar* *sequenceVar*

    Decodes the ASN sequence value encoded at the start of the data stored in
    the variable called *dataVar*\. The ASN sequence is stored in the variable
    called *sequenceVar*, and the decoded bytes are removed from the start of
    the data in *dataVar*, ready for the next value to be decoded\. If the
    value at the start is not an encoded ASN sequence an error is thrown\.

    The value in *sequenceVar* is encoded binary and must be further decoded
    according to the definition of the sequence, using the other decoder
    “asnGet…” commands\.

  - <a name='44'></a>__::asn::asnGetSet__ *dataVar* *setVar*

    Decodes the ASN set value encoded at the start of the data stored in the
    variable called *dataVar*\. The ASN set is stored in the variable called
    *setVar*, and the decoded bytes are removed from the start of the data in
    *dataVar*, ready for the next value to be decoded\. If the value at the
    start is not an encoded ASN set an error is thrown\.

    The value in *setVar* is encoded binary and must be further decoded
    according to the definition of the sequence, using the other decoder
    “asnGet…” commands\.

  - <a name='45'></a>__::asn::asnGetApplication__ *dataVar* *appNumberVar* ?*contentVar*? ?*encodingTypeVar*?

    Decodes the ASN application construct value encoded at the start of the data
    stored in the variable called *dataVar*\. The ASN application construct’s
    ID is stored in the variable called *appNumberVar*, and the decoded bytes
    are removed from the start of the data in *dataVar*, ready for the next
    value to be decoded\. If the value at the start is not an encoded ASN
    application construct an error is thrown\.

    If a *contentVar* is specified, then the command places all data
    associated with the ASN application construct into the named variable, in
    the binary form which can be processed using the this package’s decoder
    commands\.

    If a *encodingTypeVar* is specified, then that variable is set to
    __1__ if the encoding is constructed and __0__ if it is primitive\.

    Without the optional arguments, it is the responsibility of the caller to
    decode the remainder of the ASN application construct based on the ID
    retrieved by this command, using the package’s decoder commands\.

  - <a name='46'></a>__::asn::asnGetContext__ *dataVar* *contextNumberVar* ?*contentVar*? ?*encodingTypeVar*?

    Decodes the ASN context tag construct encoded at the start of the data
    stored in the variable called *dataVar*\. The ASN context tag construct’s
    ID is stored in the variable called *contextNumberVar*, and the decoded
    bytes are removed from the start of the data in *dataVar*, ready for the
    next value to be decoded\. If the value at the start is not an encoded ASN
    context tag construct an error is thrown\.

    If a *contentVar* is specified, then the command places all data
    associated with the ASN context tag construct into the named variable, in
    the binary form which can be processed using the this package’s decoder
    commands\.

    If a *encodingTypeVar* is specified, then that variable is set to
    __1__ if the encoding is constructed and __0__ if it is primitive\.

    Without the optional arguments, it is the responsibility of the caller to
    decode the remainder of the ASN context tag construct based on the ID
    retrieved by this command, using the package’s decoder commands\.

## <a name='subsection3'></a>HANDLING TAGS

When working with ASN\.1 you often need to decode tagged values which use a tag
that’s different from a type’s universal tag\. In these cases, to decode the
value, you must replace the tag with the type’s universal tag\. To decode a
tagged value use __::asn::asnRetag__ to change the tag to an appropriate
type so that you can use one of the decoders for primitive values\. To assist
with this the package provides three helper functions:

  - <a name='47'></a>__::asn::asnPeekTag__ *dataVar* *tagVar* *tagtypeVar* *constrVar*

    The __::asn::asnPeekTag__ command can be used to take a peek at the data
    and decode the tag value, without removing it from the data\. The *tagVar*
    is set to the tag number\. The *tagtypeVar* is set to the tag’s class,
    which is one of __UNIVERSAL__, __CONTEXT__, __APPLICATION__, or
    __PRIVATE__\. The *constrVar* is set to 1 if the tag is for a
    constructed value, or to 0 for a primitive\. The command returns the tag’s
    length\.

  - <a name='48'></a>__::asn::asnTag__ *tagnumber* ?*class*? ?*tagstyle*?

    The __::asn::asnTag__ command is used to create a tag value\. The
    *tagnumber* specifies the tag’s number\. If given, the tag’s *class* must
    be one of __UNIVERSAL__, __CONTEXT__, __APPLICATION__, or
    __PRIVATE__; or just the first letter as an abbreviation \(__U__,
    __C__, __A__, or __P__\.\) The default class is __UNIVERSAL__\.
    If given, the *tagstyle* must be either __C__ or __1__ for a
    constructed encoding, or __P__ or __0__ for a primitive encoding\.
    The default is __P__\. \(The use of __1__ and __0__ makes it easy
    to use this command with the values returned by __::asn::asnPeekTag__\.\)

  - <a name='49'></a>__::asn::asnRetag__ *dataVar* *newTag*

    Replaces the tag at the start of the data in *dataVar* with *newTag*\.
    The new tag can be created using the __::asn::asnTag__ command\.

# <a name='section3'></a>EXAMPLES

Examples that show this package in use can be found in the implementation of the
__[ldap](\.\./ldap/ldap\.md)__ package\.

When encoding text it is best to *avoid* __::asn::asnUTF8String__ since in
rare cases it may not work correctly\. For pure 7\-bit ASCII it is easiest to
encode using __::asn::asnIA5String__\. Outside the 7\-bit ASCII range convert
Tcl strings into UCS2 \(i\.e\., utf\-16le\) and encode with
__::asn::asnBMPString__\. For decoding any string use
__::asn::asnGetString__; however, for each UCS2 string, remember to convert
it back to a Tcl string\.

    # Encode
    set eflag [::asn::asnBoolean 1]
    set etotal [::asn::asnInteger 734]
    set line [encoding convertto utf-16le "€2 ÷ 3 → €⅔ ✔"]
    set eline [::asn::asnBMPString $line]
    set enote [::asn::asnIA5String "7-bit ASCII ~^"]
    set encoded [::asn::asnSequence $eflag $etotal $eline $enote]
    # Decode
    ::asn::asnGetSequence encoded sequence
    ::asn::asnGetBoolean sequence flag
    ::asn::asnGetInteger sequence total
    ::asn::asnGetString sequence bmp_line
    set line [encoding convertfrom utf-16le $bmp_line]
    ::asn::asnGetString sequence note
    puts "flag=$flag total=$total line='$line' note='$note'"
    =>
    flag=1 total=734 line='€2 ÷ 3 → €⅔ ✔' note='7-bit ASCII ~^'

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *asn* as the
category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[asn](\.\./\.\./\.\./\.\./index\.md\#asn), [ber](\.\./\.\./\.\./\.\./index\.md\#ber),
[cer](\.\./\.\./\.\./\.\./index\.md\#cer), [der](\.\./\.\./\.\./\.\./index\.md\#der),
[internet](\.\./\.\./\.\./\.\./index\.md\#internet),
[protocol](\.\./\.\./\.\./\.\./index\.md\#protocol),
[x\.208](\.\./\.\./\.\./\.\./index\.md\#x\_208), [x\.209](\.\./\.\./\.\./\.\./index\.md\#x\_209)

# <a name='category'></a>CATEGORY

Networking

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>  
Copyright &copy; 2004 Jochen Loewer <loewerj@web\.de>  
Copyright &copy; 2004\-2011 Michael Schlenker <mic42@users\.sourceforge\.net>
