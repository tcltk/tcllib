[list_begin definitions]

[call [cmd ::textutil::repeat::strRepeat] [arg text] [arg count]]

Returns a string containing the [arg text] repeated [arg count] times.

[para]
The repetitions are joined with no separators between them. A value of
[arg count] [emph {<= 0}] causes the command to return an empty string.

[para]

[emph Note]: If the Tcl core this package is loaded in provides the
[cmd {string repeat}] command, then this command will be implemented in
its terms, for maximum speed. Otherwise a fast Tcl implementation is used.

[call [cmd ::textutil::repeat::blank] [arg count]]

Returns a string containing [arg count] spaces.

[para]
This is a convenience for calling [cmd ::textutil::repeat::strRepeat]
with [const {" "}] as its first argument.

[list_end]
