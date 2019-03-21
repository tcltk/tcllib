
[//000000001]: # (nameserv::common - Name service facility)
[//000000002]: # (Generated from file 'nns_common.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (nameserv::common(n) 0.1 tcllib "Name service facility")

# NAME

nameserv::common - Name service facility, shared definitions

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [API](#section2)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [See Also](#see-also)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8  
package require nameserv::common ?0.1?  

[__::nameserv::common::port__](#1)  

# <a name='description'></a>DESCRIPTION

Please read *[Name service facility, introduction](nns_intro.md)* first.

This package is internal and of no interest to users. It provides the commands
of the name service facility which are shared by the client and server
implemented by the packages __[nameserv::server](nns_server.md)__ and
__[nameserv](nns_client.md)__ (the client).

This service is built in top of and for the package __[comm](../comm/comm.md)__.
It has nothing to do with the Internet's Domain Name System. If the reader is
looking for a package dealing with that please see Tcllib's packages
__[dns](../dns/tcllib_dns.md)__ and __resolv__.

# <a name='section2'></a>API

The package exports a single command, as specified below:

  - <a name='1'></a>__::nameserv::common::port__

    The result returned by the command is the id of the default TCP/IP port a
    nameservice server will listen on, and a name service client will try to
    connect to.

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *nameserv* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='see-also'></a>SEE ALSO

nameserv::client(n), [nameserv::server(n)](nns_server.md)

# <a name='keywords'></a>KEYWORDS

[client](../../../../index.md#client), [name
service](../../../../index.md#name_service),
[server](../../../../index.md#server)

# <a name='category'></a>CATEGORY

Networking

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2007-2008 Andreas Kupries <andreas_kupries@users.sourceforge.net>
