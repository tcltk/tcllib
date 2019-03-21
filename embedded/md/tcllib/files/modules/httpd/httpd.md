
[//000000001]: # (tool - Tcl Web Server)
[//000000002]: # (Generated from file 'httpd.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tool(n) 4.1.1 tcllib "Tcl Web Server")

# NAME

tool - A TclOO and coroutine based web server

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [Minimal Example](#section2)

  -  [Class ::httpd::server](#section3)

  -  [Class ::httpd::reply](#section4)

  -  [Reply Method Ensembles](#section5)

  -  [Reply Method Ensemble: http_info](#section6)

  -  [Reply Method Ensemble: request](#section7)

  -  [Reply Method Ensemble: reply](#section8)

  -  [Reply Methods](#section9)

  -  [Class ::httpd::content](#section10)

  -  [Class ::httpd::content.cgi](#section11)

  -  [Class ::httpd::content.file](#section12)

  -  [Class ::httpd::content.proxy](#section13)

  -  [Class ::httpd::content.scgi](#section14)

  -  [Class ::httpd::content.websocket](#section15)

  -  [SCGI Server Functions](#section16)

  -  [Class ::httpd::reply.scgi](#section17)

  -  [Class ::httpd::server.scgi](#section18)

  -  [AUTHORS](#section19)

  -  [Bugs, Ideas, Feedback](#section20)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.6  
package require httpd ?4.1.1?  
package require sha1  
package require dicttool  
package require oo::meta  
package require oo::dialect  
package require tool  
package require coroutine  
package require fileutil  
package require fileutil::magic::filetype  
package require websocket  
package require mime  
package require cron  
package require uri  
package require Markdown  

[constructor ?port ?port?? ?myaddr ?ipaddr?|all? ?server_string ?string?? ?server_name ?string??](#1)  
[method __add_uri__ *pattern* *dict*](#2)  
[method __connect__ *sock* *ip* *port*](#3)  
[method __Connect__ *uuid* *sock* *ip*](#4)  
[method __[counter](../counter/counter.md)__ *which*](#5)  
[method __CheckTimeout__](#6)  
[method __dispatch__ *header_dict*](#7)  
[method __[log](../log/log.md)__ *args*](#8)  
[method __port_listening__](#9)  
[method __PrefixNormalize__ *prefix*](#10)  
[method __start__](#11)  
[method __stop__](#12)  
[method __template__ *page*](#13)  
[method __TemplateSearch__ *page*](#14)  
[method __Validate_Connection__ *sock* *ip*](#15)  
[method __ENSEMBLE::add__ *field* *element*](#16)  
[method __ENSEMBLE::dump__](#17)  
[method __ENSEMBLE::get__ *field*](#18)  
[method __ENSEMBLE::reset__](#19)  
[method __ENSEMBLE::remove__ *field* *element*](#20)  
[method __ENSEMBLE::replace__ *keyvaluelist*](#21)  
[method __ENSEMBLE::reset__](#22)  
[method __ENSEMBLE::set__ *field* *value*](#23)  
[method __http_info::netstring__](#24)  
[method __request::parse__ *string*](#25)  
[method __reply::output__](#26)  
[method __close__](#27)  
[method __HttpHeaders__ *sock* *?debug?*](#28)  
[method __dispatch__ *newsock* *datastate*](#29)  
[method __[error](../../../../index.md#error)__ *code* *?message?* *?errorInfo?*](#30)  
[method __content__](#31)  
[method __EncodeStatus__ *status*](#32)  
[method FormData](#33)  
[method MimeParse *mimetext*](#34)  
[method __DoOutput__](#35)  
[method PostData *length*](#36)  
[method __puts__ *string*](#37)  
[method __reset__](#38)  
[method __timeOutCheck__](#39)  
[method __[timestamp](../../../../index.md#timestamp)__](#40)  
[method __TransferComplete__ *args*](#41)  
[method __Url_Decode__ *string*](#42)  
[method cgi_info](#43)  
[option __path__](#44)  
[option __[prefix](../../../../index.md#prefix)__](#45)  
[method proxy_info](#46)  
[method scgi_info](#47)  

# <a name='description'></a>DESCRIPTION

This module implements a web server, suitable for embedding in an application.
The server is object oriented, and contains all of the fundamentals needed for a
full service website.

# <a name='section2'></a>Minimal Example

Starting a web service requires starting a class of type __httpd::server__, and
providing that server with one or more URIs to service, and __httpd::reply__
derived classes to generate them.

    tool::define ::reply.hello {
      method content {} {
        my puts "<HTML><HEAD><TITLE>IRM Dispatch Server</TITLE></HEAD><BODY>"
        my puts "<h1>Hello World!</h1>"
        my puts </BODY></HTML>
      }
    }
    ::docserver::server create HTTPD port 8015 myaddr 127.0.0.1
    HTTPD add_uri /* [list mixin reply.hello]

# <a name='section3'></a>Class ::httpd::server

This class is the root object of the webserver. It is responsible for opening
the socket and providing the initial connection negotiation.

  - <a name='1'></a>constructor ?port ?port?? ?myaddr ?ipaddr?|all? ?server_string ?string?? ?server_name ?string??

    Build a new server object. ?port? is the port to listen on

  - <a name='2'></a>method __add_uri__ *pattern* *dict*

    Set the hander for a URI pattern. Information given in the *dict* is stored
    in the data structure the __dispatch__ method uses. If a field called
    *mixin* is given, that class will be mixed into the reply object immediately
    after construction.

  - <a name='3'></a>method __connect__ *sock* *ip* *port*

    Reply to an open socket. This method builds a coroutine to manage the
    remainder of the connection. The coroutine's operations are driven by the
    __Connect__ method.

  - <a name='4'></a>method __Connect__ *uuid* *sock* *ip*

    This method reads HTTP headers, and then consults the __dispatch__ method to
    determine if the request is valid, and/or what kind of reply to generate.
    Under normal cases, an object of class __::http::reply__ is created. Fields
    the server are looking for in particular are: class: A class to use instead
    of the server's own *reply_class* mixin: A class to be mixed into the new
    object after construction. All other fields are passed along to the
    __http_info__ structure of the reply object. After the class is created and
    the mixin is mixed in, the server invokes the reply objects __dispatch__
    method. This action passes control of the socket to the reply object. The
    reply object manages the rest of the transaction, including closing the
    socket.

  - <a name='5'></a>method __[counter](../counter/counter.md)__ *which*

    Increment an internal counter.

  - <a name='6'></a>method __CheckTimeout__

    Check open connections for a time out event.

  - <a name='7'></a>method __dispatch__ *header_dict*

    Given a key/value list of information, return a data structure describing
    how the server should reply.

  - <a name='8'></a>method __[log](../log/log.md)__ *args*

    Log an event. The input for args is free form. This method is intended to be
    replaced by the user, and is a noop for a stock http::server object.

  - <a name='9'></a>method __port_listening__

    Return the actual port that httpd is listening on.

  - <a name='10'></a>method __PrefixNormalize__ *prefix*

    For the stock version, trim trailing /'s and *'s from a prefix. This method
    can be replaced by the end user to perform any other transformations needed
    for the application.

  - <a name='11'></a>method __start__

    Open the socket listener.

  - <a name='12'></a>method __stop__

    Shut off the socket listener, and destroy any pending replies.

  - <a name='13'></a>method __template__ *page*

    Return a template for the string *page*

  - <a name='14'></a>method __TemplateSearch__ *page*

    Perform a search for the template that best matches *page*. This can include
    local file searches, in-memory structures, or even database lookups. The
    stock implementation simply looks for files with a .tml or .html extension
    in the ?doc_root? directory.

  - <a name='15'></a>method __Validate_Connection__ *sock* *ip*

    Given a socket and an ip address, return true if this connection should be
    terminated, or false if it should be allowed to continue. The stock
    implementation always returns 0. This is intended for applications to be
    able to implement black lists and/or provide security based on IP address.

# <a name='section4'></a>Class ::httpd::reply

A class which shephards a request through the process of generating a reply. The
socket associated with the reply is available at all times as the *chan*
variable. The process of generating a reply begins with an __httpd::server__
generating a __http::class__ object, mixing in a set of behaviors and then
invoking the reply object's __dispatch__ method. In normal operations the
__dispatch__ method:

  1. Invokes the __reset__ method for the object to populate default headers.

  1. Invokes the __HttpHeaders__ method to stream the MIME headers out of the
     socket

  1. Invokes the __request parse__ method to convert the stream of MIME headers
     into a dict that can be read via the __request__ method.

  1. Stores the raw stream of MIME headers in the *rawrequest* variable of the
     object.

  1. Invokes the __content__ method for the object, generating an call to the
     __[error](../../../../index.md#error)__ method if an exception is raised.

  1. Invokes the __output__ method for the object

# <a name='section5'></a>Reply Method Ensembles

The __http::reply__ class and its derivatives maintain several variables as
dictionaries internally. Access to these dictionaries is managed through a
dedicated ensemble. The ensemble implements most of the same behaviors as the
__[dict](../../../../index.md#dict)__ command. Each ensemble implements the
following methods above, beyond, or modifying standard dicts:

  - <a name='16'></a>method __ENSEMBLE::add__ *field* *element*

    Add *element* to a list stored in *field*, but only if it is not already
    present om the list.

  - <a name='17'></a>method __ENSEMBLE::dump__

    Return the current contents of the data structure as a key/value list.

  - <a name='18'></a>method __ENSEMBLE::get__ *field*

    Return the value of the field *field*, or an empty string if it does not
    exist.

  - <a name='19'></a>method __ENSEMBLE::reset__

    Return a key/value list of the default contents for this data structure.

  - <a name='20'></a>method __ENSEMBLE::remove__ *field* *element*

    Remove all instances of *element* from the list stored in *field*.

  - <a name='21'></a>method __ENSEMBLE::replace__ *keyvaluelist*

    Replace the internal dict with the contents of *keyvaluelist*

  - <a name='22'></a>method __ENSEMBLE::reset__

    Replace the internal dict with the default state.

  - <a name='23'></a>method __ENSEMBLE::set__ *field* *value*

    Set the value of *field* to *value*.

# <a name='section6'></a>Reply Method Ensemble: http_info

Manages HTTP headers passed in by the server. Ensemble Methods:

  - <a name='24'></a>method __http_info::netstring__

    Return the contents of this data structure as a netstring encoded block.

# <a name='section7'></a>Reply Method Ensemble: request

Managed data from MIME headers of the request.

  - <a name='25'></a>method __request::parse__ *string*

    Replace the contents of the data structure with information encoded in a
    MIME formatted block of text (*string*).

# <a name='section8'></a>Reply Method Ensemble: reply

Manage the headers sent in the reply.

  - <a name='26'></a>method __reply::output__

    Return the contents of this data structure as a MIME encoded block
    appropriate for an HTTP response.

# <a name='section9'></a>Reply Methods

  - <a name='27'></a>method __close__

    Terminate the transaction, and close the socket.

  - <a name='28'></a>method __HttpHeaders__ *sock* *?debug?*

    Stream MIME headers from the socket *sock*, stopping at an empty line.
    Returns the stream as a block of text.

  - <a name='29'></a>method __dispatch__ *newsock* *datastate*

    Take over control of the socket *newsock*, and store that as the *chan*
    variable for the object. This method runs through all of the steps of
    reading HTTP headers, generating content, and closing the connection. (See
    class writetup).

  - <a name='30'></a>method __[error](../../../../index.md#error)__ *code* *?message?* *?errorInfo?*

    Generate an error message of the specified *code*, and display the *message*
    as the reason for the exception. *errorInfo* is passed in from calls, but
    how or if it should be displayed is a prerogative of the developer.

  - <a name='31'></a>method __content__

    Generate the content for the reply. This method is intended to be replaced
    by the mixin. Developers have the option of streaming output to a buffer via
    the __puts__ method of the reply, or simply populating the *reply_body*
    variable of the object. The information returned by the __content__ method
    is not interpreted in any way. If an exception is thrown (via the
    __[error](../../../../index.md#error)__ command in Tcl, for example) the
    caller will auto-generate a 500 {Internal Error} message. A typical
    implementation of __content__ look like:

    tool::define ::test::content.file {
    	superclass ::httpd::content.file
    	# Return a file
    	# Note: this is using the content.file mixin which looks for the reply_file variable
    	# and will auto-compute the Content-Type
    	method content {} {
    	  my reset
        set doc_root [my http_info get doc_root]
        my variable reply_file
        set reply_file [file join $doc_root index.html]
    	}
    }
    tool::define ::test::content.time {
      # return the current system time
    	method content {} {
    		my variable reply_body
        my reply set Content-Type text/plain
    		set reply_body [clock seconds]
    	}
    }
    tool::define ::test::content.echo {
    	method content {} {
    		my variable reply_body
        my reply set Content-Type [my request get CONTENT_TYPE]
    		set reply_body [my PostData [my request get CONTENT_LENGTH]]
    	}
    }
    tool::define ::test::content.form_handler {
    	method content {} {
    	  set form [my FormData]
    	  my reply set Content-Type {text/html; charset=UTF-8}
        my puts [my html header {My Dynamic Page}]
        my puts "<BODY>"
        my puts "You Sent<p>"
        my puts "<TABLE>"
        foreach {f v} $form {
          my puts "<TR><TH>$f</TH><TD><verbatim>$v</verbatim></TD>"
        }
        my puts "</TABLE><p>"
        my puts "Send some info:<p>"
        my puts "<FORM action=/[my http_info get REQUEST_PATH] method POST>"
        my puts "<TABLE>"
        foreach field {name rank serial_number} {
          set line "<TR><TH>$field</TH><TD><input name=\"$field\" "
          if {[dict exists $form $field]} {
            append line " value=\"[dict get $form $field]\"""
          }
          append line " /></TD></TR>"
          my puts $line
        }
        my puts "</TABLE>"
        my puts [my html footer]
    	}
    }

  - <a name='32'></a>method __EncodeStatus__ *status*

    Formulate a standard HTTP status header from he string provided.

  - <a name='33'></a>method FormData

    For GET requests, converts the QUERY_DATA header into a key/value list. For
    POST requests, reads the Post data and converts that information to a
    key/value list for application/x-www-form-urlencoded posts. For multipart
    posts, it composites all of the MIME headers of the post to a singular
    key/value list, and provides MIME_* information as computed by the
    __[mime](../mime/mime.md)__ package, including the MIME_TOKEN, which can be
    fed back into the mime package to read out the contents.

  - <a name='34'></a>method MimeParse *mimetext*

    Converts a block of mime encoded text to a key/value list. If an exception
    is encountered, the method will generate its own call to the
    __[error](../../../../index.md#error)__ method, and immediately invoke the
    __output__ method to produce an error code and close the connection.

  - <a name='35'></a>method __DoOutput__

    Generates the the HTTP reply, and streams that reply back across *chan*.

  - <a name='36'></a>method PostData *length*

    Stream *length* bytes from the *chan* socket, but only of the request is a
    POST or PUSH. Returns an empty string otherwise.

  - <a name='37'></a>method __puts__ *string*

    Appends the value of *string* to the end of *reply_body*, as well as a
    trailing newline character.

  - <a name='38'></a>method __reset__

    Clear the contents of the *reply_body* variable, and reset all headers in
    the __reply__ structure back to the defaults for this object.

  - <a name='39'></a>method __timeOutCheck__

    Called from the __http::server__ object which spawned this reply. Checks to
    see if too much time has elapsed while waiting for data or generating a
    reply, and issues a timeout error to the request if it has, as well as
    destroy the object and close the *chan* socket.

  - <a name='40'></a>method __[timestamp](../../../../index.md#timestamp)__

    Return the current system time in the format:

    %a, %d %b %Y %T %Z

  - <a name='41'></a>method __TransferComplete__ *args*

    Intended to be invoked from __chan copy__ as a callback. This closes every
    channel fed to it on the command line, and then destroys the object.

    ###
    # Output the body
    ###
    chan configure $sock -translation binary -blocking 0 -buffering full -buffersize 4096
    chan configure $chan -translation binary -blocking 0 -buffering full -buffersize 4096
    if {$length} {
      ###
      # Send any POST/PUT/etc content
      ###
      chan copy $sock $chan -size $SIZE -command [info coroutine]
      yield
    }
    catch {close $sock}
    chan flush $chan

  - <a name='42'></a>method __Url_Decode__ *string*

    De-httpizes a string.

# <a name='section10'></a>Class ::httpd::content

The httpd module includes several ready to use implementations of content mixins
for common use cases. Options are passed in to the __add_uri__ method of the
server.

# <a name='section11'></a>Class ::httpd::content.cgi

An implementation to relay requests to process which will accept post data
streamed in vie stdin, and sent a reply streamed to stdout.

  - <a name='43'></a>method cgi_info

    Mandatory method to be replaced by the end user. If needed, activates the
    process to proxy, and then returns a list of three values: *exec* - The
    arguments to send to exec to fire off the responding process, minus the
    stdin/stdout redirection.

# <a name='section12'></a>Class ::httpd::content.file

An implementation to deliver files from the local file system.

  - <a name='44'></a>option __path__

    The root directory on the local file system to be exposed via http.

  - <a name='45'></a>option __[prefix](../../../../index.md#prefix)__

    The prefix of the URI portion to ignore when calculating relative file
    paths.

# <a name='section13'></a>Class ::httpd::content.proxy

An implementation to relay requests to another HTTP server, and relay the
results back across the request channel.

  - <a name='46'></a>method proxy_info

    Mandatory method to be replaced by the end user. If needed, activates the
    process to proxy, and then returns a list of three values: *proxyhost* - The
    hostname where the proxy is located *proxyport* - The port to connect to
    *proxyscript* - A pre-amble block of text to send prior to the mirrored
    request

# <a name='section14'></a>Class ::httpd::content.scgi

An implementation to relay requests to a server listening on a socket expecting
SCGI encoded requests, and relay the results back across the request channel.

  - <a name='47'></a>method scgi_info

    Mandatory method to be replaced by the end user. If needed, activates the
    process to proxy, and then returns a list of three values: *scgihost* - The
    hostname where the scgi listener is located *scgiport* - The port to connect
    to *scgiscript* - The contents of the *SCRIPT_NAME* header to be sent

# <a name='section15'></a>Class ::httpd::content.websocket

A placeholder for a future implementation to manage requests that can expect to
be promoted to a Websocket. Currently it is an empty class.

# <a name='section16'></a>SCGI Server Functions

The HTTP module also provides an SCGI server implementation, as well as an HTTP
implementation. To use the SCGI functions, create an object of the
__http::server.scgi__ class instead of the __http::server__ class.

# <a name='section17'></a>Class ::httpd::reply.scgi

An modified __http::reply__ implementation that understands how to deal with
netstring encoded headers.

# <a name='section18'></a>Class ::httpd::server.scgi

A modified __http::server__ which is tailored to replying to request according
to the SCGI standard instead of the HTTP standard.

# <a name='section19'></a>AUTHORS

Sean Woods

# <a name='section20'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *network* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='keywords'></a>KEYWORDS

[TclOO](../../../../index.md#tcloo), [WWW](../../../../index.md#www),
[http](../../../../index.md#http), [httpd](../../../../index.md#httpd),
[httpserver](../../../../index.md#httpserver),
[services](../../../../index.md#services)

# <a name='category'></a>CATEGORY

Networking

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2018 Sean Woods <yoda@etoyoc.com>
