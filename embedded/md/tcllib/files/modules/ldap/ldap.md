
[//000000001]: # (ldap \- LDAP client)
[//000000002]: # (Generated from file 'ldap\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>)
[//000000004]: # (Copyright &copy; 2004 Jochen Loewer <loewerj@web\.de>)
[//000000005]: # (Copyright &copy; 2006 Michael Schlenker <mic42@users\.sourceforge\.net>)
[//000000006]: # (ldap\(n\) 1\.9\.2 tcllib "LDAP client")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

ldap \- LDAP client

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [TLS Security Considerations](#section2)

  - [COMMANDS](#section3)

  - [EXAMPLES](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.4  
package require ldap ?1\.9\.2?  

[__::ldap::connect__ *host* ?*port*?](#1)  
[__::ldap::secure\_connect__ *host* ?*port*? ?*verify\_cert*? ?*sni\_servername*?](#2)  
[__::ldap::disconnect__ *handle*](#3)  
[__::ldap::starttls__ *handle* ?*cafile*? ?*certfile*? ?*keyfile*? ?*verify\_cert*? ?*sni\_servername*?](#4)  
[__::ldap::bind__ *handle* ?*name*? ?*password*?](#5)  
[__::ldap::bindSASL__ *handle* ?*name*? ?*password*?](#6)  
[__::ldap::unbind__ *handle*](#7)  
[__::ldap::search__ *handle* *baseObject* *filterString* *attributes* *options*](#8)  
[__::ldap::searchInit__ *handle* *baseObject* *filterString* *attributes* *options*](#9)  
[__::ldap::searchNext__ *handle*](#10)  
[__::ldap::searchEnd__ *handle*](#11)  
[__::ldap::modify__ *handle* *dn* *attrValToReplace* ?*attrToDelete*? ?*attrValToAdd*?](#12)  
[__::ldap::modifyMulti__ *handle* *dn* *attrValToReplace* ?*attrValToDelete*? ?*attrValToAdd*?](#13)  
[__::ldap::add__ *handle* *dn* *attrValueTuples*](#14)  
[__::ldap::addMulti__ *handle* *dn* *attrValueTuples*](#15)  
[__::ldap::delete__ *handle* *dn*](#16)  
[__::ldap::modifyDN__ *handle* *dn* *newrdn* ?*deleteOld*? ?*newSuperior*?](#17)  
[__::ldap::info__ __[ip](\.\./\.\./\.\./\.\./index\.md\#ip)__ *handle*](#18)  
[__::ldap::info__ __bound__ *handle*](#19)  
[__::ldap::info__ __bounduser__ *handle*](#20)  
[__::ldap::info__ __connections__](#21)  
[__::ldap::info__ __[tls](\.\./\.\./\.\./\.\./index\.md\#tls)__ *handle*](#22)  
[__::ldap::info__ __saslmechanisms__ *handle*](#23)  
[__::ldap::info__ __[control](\.\./control/control\.md)__ *handle*](#24)  
[__::ldap::info__ __extensions__ *extensions*](#25)  
[__::ldap::info__ __whoami__ *handle*](#26)  

# <a name='description'></a>DESCRIPTION

The __ldap__ package provides a Tcl\-only client library for the LDAPv3
protocol as specified in RFC 4511
\([http://www\.rfc\-editor\.org/rfc/rfc4511\.txt](http://www\.rfc\-editor\.org/rfc/rfc4511\.txt)\)\.
It works by opening the standard \(or secure\) LDAP socket on the server, and then
providing a Tcl API to access the LDAP protocol commands\. All server errors are
returned as Tcl errors \(thrown\) which must be caught with the Tcl __catch__
command\.

# <a name='section2'></a>TLS Security Considerations

This package uses the __[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__ package to
handle the security for __https__ urls and other socket connections\.

Policy decisions like the set of protocols to support and what ciphers to use
are not the responsibility of __[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__, nor
of this package itself however\. Such decisions are the responsibility of
whichever application is using the package, and are likely influenced by the set
of servers the application will talk to as well\.

For example, in light of the recent [POODLE
attack](http://googleonlinesecurity\.blogspot\.co\.uk/2014/10/this\-poodle\-bites\-exploiting\-ssl\-30\.html)
discovered by Google many servers will disable support for the SSLv3 protocol\.
To handle this change the applications using
__[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__ must be patched, and not this
package, nor __[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__ itself\. Such a patch
may be as simple as generally activating __tls1__ support, as shown in the
example below\.

    package require tls
    tls::init -tls1 1 ;# forcibly activate support for the TLS1 protocol

    ... your own application code ...

# <a name='section3'></a>COMMANDS

  - <a name='1'></a>__::ldap::connect__ *host* ?*port*?

    Opens a LDAPv3 connection to the specified *host*, at the given *port*,
    and returns a token for the connection\. This token is the *handle*
    argument for all other commands\. If no *port* is specified it will default
    to __389__\.

    The command blocks until the connection has been established, or
    establishment definitely failed\.

  - <a name='2'></a>__::ldap::secure\_connect__ *host* ?*port*? ?*verify\_cert*? ?*sni\_servername*?

    Like __::ldap::connect__, except that the created connection is secured
    by SSL\. The port defaults to __636__\. This command depends on the
    availability of the package __[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__,
    which is a SSL binding for Tcl\. If
    __[TLS](\.\./\.\./\.\./\.\./index\.md\#tls)__ is not available, then this
    command will fail\.

    The command blocks until the connection has been established, or
    establishment definitely failed\.

    If *verify\_cert* is set to 1, the default, this checks the server
    certificate against the known hosts\. If *sni\_servername* is set, the given
    hostname is used as the hostname for Server Name Indication in the TLS
    handshake\.

    Use __::tls::init__ to setup defaults for trusted certificates\.

    tls::init -cadir /etc/ssl/certs/ca-certificates.crt

    TLS supports different protocol levels\. In common use are the versions 1\.0,
    1\.1 and 1\.2\. By default all those versions are offered\. If you need to
    modify the acceptable protocols, you can change the ::ldap::tlsProtocols
    list\.

  - <a name='3'></a>__::ldap::disconnect__ *handle*

    Closes the ldap connection refered to by the token *handle*\. Returns the
    empty string as its result\.

  - <a name='4'></a>__::ldap::starttls__ *handle* ?*cafile*? ?*certfile*? ?*keyfile*? ?*verify\_cert*? ?*sni\_servername*?

    Start TLS negotiation on the connection denoted by *handle*\. You need to
    set at least the *cafile* argument to a file with trusted certificates, if
    *verify\_cert* is 1, which is the default\. The *sni\_servername* can be
    used to signal a different hostname during the TLS handshake\. The announced
    protocols are determined in the same way as __::ldap::secure\_connect__\.
    You can specify a TLS client certificate with the *certfile* and
    *keyfile* options\.

  - <a name='5'></a>__::ldap::bind__ *handle* ?*name*? ?*password*?

    This command authenticates the ldap connection refered to by the token in
    *handle*, with a user name and associated password\. It blocks until a
    response from the ldap server arrives\. Its result is the empty string\. Both
    *name* and *passwd* default to the empty string if they are not
    specified\. By leaving out *name* and *passwd* you can make an anonymous
    bind to the ldap server\. You can issue __::ldap::bind__ again to bind
    with different credentials\.

  - <a name='6'></a>__::ldap::bindSASL__ *handle* ?*name*? ?*password*?

    This command uses SASL authentication mechanisms to do a multistage bind\.
    Its otherwise identical to the standard __::ldap::bind__\. This feature
    is currently experimental and subject to change\. See the documentation for
    the __[SASL](\.\./sasl/sasl\.md)__ and the "SASL\.txt" in the tcllib CVS
    repository for details how to setup and use SASL with openldap\.

  - <a name='7'></a>__::ldap::unbind__ *handle*

    This command asks the ldap server to release the last bind done for the
    connection refered to by the token in *handle*\. The *handle* is invalid
    after the unbind, as the server closes the connection\. So this is effectivly
    just a more polite disconnect operation\.

  - <a name='8'></a>__::ldap::search__ *handle* *baseObject* *filterString* *attributes* *options*

    This command performs a LDAP search below the *baseObject* tree using a
    complex LDAP search expression *filterString* and returns the specified
    *attributes* of all matching objects \(DNs\)\. If the list of *attributes*
    was empty all attributes are returned\. The command blocks until it has
    received all results\. The valid *options* are identical to the options
    listed for __::ldap::searchInit__\.

    An example of a search expression is

    set filterString "|(cn=Linus*)(sn=Torvalds*)"

    The return value of the command is a list of nested dictionaries\. The first
    level keys are object identifiers \(DNs\), second levels keys are attribute
    names\. In other words, it is in the form

    {dn1 {attr1 {val11 val12 ...} attr2 {val21...} ...}} {dn2 {a1 {v11 ...} ...}} ...

  - <a name='9'></a>__::ldap::searchInit__ *handle* *baseObject* *filterString* *attributes* *options*

    This command initiates a LDAP search below the *baseObject* tree using a
    complex LDAP search expression *filterString*\. The search gets the
    specified *attributes* of all matching objects \(DNs\)\. The command itself
    just starts the search, to retrieve the actual results, use
    __::ldap::searchNext__\. A search can be terminated at any time by
    __::ldap::searchEnd__\. This informs the server that no further results
    should be sent by sending and ABANDON message and cleans up the internal
    state of the search\. Only one __::ldap::search__ can be active at a
    given time, this includes the introspection commands __::ldap::info
    saslmechanisms__, __ldap::info control__ and __ldap::info
    extensions__, which invoke a search internally\. Error responses from the
    server due to wrong arguments or similar things are returned with the first
    __::ldap::searchNext__ call and should be checked and dealed with there\.
    If the list of requested *attributes* is empty all attributes will be
    returned\. The parameter *options* specifies the options to be used in the
    search, and has the following format:

    {-option1 value1 -option2 value2 ... }

    Following options are available:

      * __\-scope__ base one sub

        Control the scope of the search to be one of __base__, __one__,
        or __sub__, to specify a base object, one\-level or subtree search\.
        The default is __sub__\.

      * __\-derefaliases__ never search find always

        Control how aliases dereferencing is done\. Should be one of
        __never__, __always__, __search__, or __find__ to
        specify that aliases are never dereferenced, always dereferenced,
        dereferenced when searching, or dereferenced only when locating the base
        object for the search\. The default is to never dereference aliases\.

      * __\-sizelimit__ num

        Determines the maximum number of entries to return in a search\. If
        specified as 0 no limit is enforced\. The server may enforce a
        configuration dependent sizelimit, which may be lower than the one given
        by this option\. The default is 0, no limit\.

      * __\-timelimit__ seconds

        Asks the server to use a timelimit of *seconds* for the search\. Zero
        means no limit\. The default is 0, no limit\.

      * __\-attrsonly__ boolean

        If set to 1 only the attribute names but not the values will be present
        in the search result\. The default is to retrieve attribute names and
        values\.

      * __\-referencevar__ varname

        If set the search result reference LDAPURIs, if any, are returned in the
        given variable\. The caller can than decide to follow those references
        and query other LDAP servers for further results\.

  - <a name='10'></a>__::ldap::searchNext__ *handle*

    This command returns the next entry from a LDAP search initiated by
    __::ldap::searchInit__\. It returns only after a new result is received
    or when no further results are available, but takes care to keep the event
    loop alive\. The returned entry is a list with two elements: the first is the
    DN of the entry, the second is the list of attributes and values, under the
    format:

    dn {attr1 {val11 val12 ...} attr2 {val21...} ...}

    The __::ldap::searchNext__ command returns an empty list at the end of
    the search\.

  - <a name='11'></a>__::ldap::searchEnd__ *handle*

    This command terminates a LDAP search initiated by
    __::ldap::searchInit__\. It also cleans up the internal state so a new
    search can be initiated\. If the client has not yet received all results, the
    client sends an ABANDON message to inform the server that no further results
    for the previous search should to be sent\.

  - <a name='12'></a>__::ldap::modify__ *handle* *dn* *attrValToReplace* ?*attrToDelete*? ?*attrValToAdd*?

    This command modifies the object *dn* on the ldap server we are connected
    to via *handle*\. It replaces attributes with new values, deletes
    attributes, and adds new attributes with new values\. All arguments are
    dictionaries mapping attribute names to values\. The optional arguments
    default to the empty dictionary, which means that no attributes will be
    deleted nor added\.

      * dictionary *attrValToReplace* \(in\)

        No attributes will be changed if this argument is empty\. The dictionary
        contains the new attributes and their values\. They *replace all*
        attributes known to the object\.

      * dictionary *attrToDelete* \(in\)

        No attributes will be deleted if this argument is empty\. The dictionary
        values are restrictions on the deletion\. An attribute listed here will
        be deleted if and only if its current value at the server matches the
        value specified in the dictionary, or if the value in the dictionary is
        the empty string\.

      * dictionary *attrValToAdd* \(in\)

        No attributes will be added if this argument is empty\. The dictionary
        values are the values for the new attributes\.

    The command blocks until all modifications have completed\. Its result is the
    empty string\.

  - <a name='13'></a>__::ldap::modifyMulti__ *handle* *dn* *attrValToReplace* ?*attrValToDelete*? ?*attrValToAdd*?

    This command modifies the object *dn* on the ldap server we are connected
    to via *handle*\. It replaces attributes with new values, deletes
    attributes, and adds new attributes with new values\. All arguments are lists
    with the format:

    attr1 {val11 val12 ...} attr2 {val21...} ...

    where each value list may be empty for deleting all attributes\. The optional
    arguments default to empty lists of attributes to delete and to add\.

      * list *attrValToReplace* \(in\)

        No attributes will be changed if this argument is empty\. The dictionary
        contains the new attributes and their values\. They *replace all*
        attributes known to the object\.

      * list *attrValToDelete* \(in\)

        No attributes will be deleted if this argument is empty\. If no value is
        specified, the whole set of values for an attribute will be deleted\.

      * list *attrValToAdd* \(in\)

        No attributes will be added if this argument is empty\.

    The command blocks until all modifications have completed\. Its result is the
    empty string\.

  - <a name='14'></a>__::ldap::add__ *handle* *dn* *attrValueTuples*

    This command creates a new object using the specified *dn*\. The attributes
    of the new object are set to the values in the list *attrValueTuples*\.
    Multiple valuated attributes may be specified using multiple tuples\. The
    command blocks until the operation has completed\. Its result is the empty
    string\.

  - <a name='15'></a>__::ldap::addMulti__ *handle* *dn* *attrValueTuples*

    This command is the preferred one to create a new object using the specified
    *dn*\. The attributes of the new object are set to the values in the
    dictionary *attrValueTuples* \(which is keyed by the attribute names\)\. Each
    tuple is a list containing multiple values\. The command blocks until the
    operation has completed\. Its result is the empty string\.

  - <a name='16'></a>__::ldap::delete__ *handle* *dn*

    This command removes the object specified by *dn*, and all its attributes
    from the server\. The command blocks until the operation has completed\. Its
    result is the empty string\.

  - <a name='17'></a>__::ldap::modifyDN__ *handle* *dn* *newrdn* ?*deleteOld*? ?*newSuperior*?

    This command moves or copies the object specified by *dn* to a new
    location in the tree of object\. This location is specified by *newrdn*, a
    *relative* designation, or by *newrdn* and *newSuperior*, a
    *absolute* designation\. The optional argument *deleteOld* defaults to
    __true__, i\.e\. a move operation\. If *deleteOld* is not set, then the
    operation will create a copy of *dn* in the new location\. The optional
    argument *newSuperior* defaults an empty string, meaning that the object
    must not be relocated in another branch of the tree\. If this argument is
    given, the argument *deleteOld* must be specified also\. The command blocks
    until the operation has completed\. Its result is the empty string\.

  - <a name='18'></a>__::ldap::info__ __[ip](\.\./\.\./\.\./\.\./index\.md\#ip)__ *handle*

    This command returns the IP address of the remote LDAP server the handle is
    connected to\.

  - <a name='19'></a>__::ldap::info__ __bound__ *handle*

    This command returns 1 if a handle has successfully completed a
    __::ldap::bind__\. If no bind was done or it failed, a 0 is returned\.

  - <a name='20'></a>__::ldap::info__ __bounduser__ *handle*

    This command returns the username used in the bind operation if a handle has
    successfully completed a __::ldap::bind__\. If no bound was done or it
    failed, an empty string is returned\.

  - <a name='21'></a>__::ldap::info__ __connections__

    This command returns all currently existing ldap connection handles\.

  - <a name='22'></a>__::ldap::info__ __[tls](\.\./\.\./\.\./\.\./index\.md\#tls)__ *handle*

    This command returns 1 if the ldap connection *handle* used TLS/SSL for
    connection via __ldap::secure\_connect__ or completed
    __ldap::starttls__, 0 otherwise\.

  - <a name='23'></a>__::ldap::info__ __saslmechanisms__ *handle*

    Return the supported SASL mechanisms advertised by the server\. Only valid in
    a bound state \(anonymous or other\)\.

  - <a name='24'></a>__::ldap::info__ __[control](\.\./control/control\.md)__ *handle*

    Return the supported controls advertised by the server as a list of OIDs\.
    Only valid in a bound state\. This is currently experimental and subject to
    change\.

  - <a name='25'></a>__::ldap::info__ __extensions__ *extensions*

    Returns the supported LDAP extensions as list of OIDs\. Only valid in a bound
    state\. This is currently experimental and subject to change\.

  - <a name='26'></a>__::ldap::info__ __whoami__ *handle*

    Returns authzId for the current connection\. This implements the RFC 4532
    protocol extension\.

# <a name='section4'></a>EXAMPLES

A small example, extracted from the test application coming with this code\.

        package require ldap

        # Connect, bind, add a new object, modify it in various ways

        set handle [ldap::connect localhost 9009]

        set dn "cn=Manager, o=University of Michigan, c=US"
        set pw secret

        ldap::bind $handle $dn $pw

        set dn "cn=Test User,ou=People,o=University of Michigan,c=US"

        ldap::add $handle $dn {
    	objectClass     OpenLDAPperson
    	cn              {Test User}
    	mail            test.user@google.com
    	uid             testuid
    	sn              User
    	telephoneNumber +31415926535
    	telephoneNumber +27182818285
        }

        set dn "cn=Another User,ou=People,o=University of Michigan,c=US"

        ldap::addMulti $handle $dn {
    	objectClass     {OpenLDAPperson}
    	cn              {{Anotther User}}
    	mail            {test.user@google.com}
    	uid             {testuid}
    	sn              {User}
    	telephoneNumber {+31415926535 +27182818285}
        }

        # Replace all attributes
        ldap::modify $handle $dn [list drink icetea uid JOLO]

        # Add some more
        ldap::modify $handle $dn {} {} [list drink water  drink orangeJuice pager "+1 313 555 7671"]

        # Delete
        ldap::modify $handle $dn {} [list drink water  pager ""]

        # Move
        ldap::modifyDN $handle $dn "cn=Tester"

        # Kill the test object, and shut the connection down.
        set dn "cn=Tester,ou=People,o=University of Michigan,c=US"
        ldap::delete $handle $dn

        ldap::unbind     $handle
        ldap::disconnect $handle

And a another example, a simple query, and processing the results\.

        package require ldap
        set handle [ldap::connect ldap.acme.com 389]
        ldap::bind $handle
        set results [ldap::search $handle "o=acme,dc=com" "(uid=jdoe)" {}]
        foreach result $results {
    	foreach {object attributes} $result break

    	# The processing here is similar to what 'parray' does.
    	# I.e. finding the longest attribute name and then
    	# generating properly aligned output listing all attributes
    	# and their values.

    	set width 0
    	set sortedAttribs {}
    	foreach {type values} $attributes {
    	    if {[string length $type] > $width} {
    		set width [string length $type]
    	    }
    	    lappend sortedAttribs [list $type $values]
    	}

    	puts "object='$object'"

    	foreach sortedAttrib  $sortedAttribs {
    	    foreach {type values} $sortedAttrib break
    	    foreach value $values {
    		regsub -all "\[\x01-\x1f\]" $value ? value
    		puts [format "  %-${width}s %s" $type $value]
    	    }
    	}
    	puts ""
        }
        ldap::unbind $handle
        ldap::disconnect $handle

# <a name='section5'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *ldap* of the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[directory access](\.\./\.\./\.\./\.\./index\.md\#directory\_access),
[internet](\.\./\.\./\.\./\.\./index\.md\#internet),
[ldap](\.\./\.\./\.\./\.\./index\.md\#ldap), [ldap
client](\.\./\.\./\.\./\.\./index\.md\#ldap\_client),
[protocol](\.\./\.\./\.\./\.\./index\.md\#protocol), [rfc
2251](\.\./\.\./\.\./\.\./index\.md\#rfc\_2251), [rfc
4511](\.\./\.\./\.\./\.\./index\.md\#rfc\_4511), [x\.500](\.\./\.\./\.\./\.\./index\.md\#x\_500)

# <a name='category'></a>CATEGORY

Networking

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2004 Andreas Kupries <andreas\_kupries@users\.sourceforge\.net>  
Copyright &copy; 2004 Jochen Loewer <loewerj@web\.de>  
Copyright &copy; 2006 Michael Schlenker <mic42@users\.sourceforge\.net>
