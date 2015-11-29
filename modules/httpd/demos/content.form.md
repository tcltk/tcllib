httpd::content::form
=============
Back to: [Index](index.md) | [Package httpd::content](content.md)

This class is intended as a mixin. It has no ancestors, nor does it contain
any dispatch, content, or output methods.

### Method Url_Decode *data*

Translates a standard http query encoding string into a stream of key/value pairs.

### Method ReadForm

For GET requests, this method will convert the URI to key/value pairs.

For POST requests, this method will read the body of the request and convert
that block of text to a stream of key/value pairs.