[list_begin definitions]

[call [cmd ::textutil::repeat::strRepeat] [arg text] [arg num]]

This command returns a string containing the [arg text] repeated
[arg num] times. The repetitions are joined without characters between
them. A value of [arg num] <= 0 causes the command to return an empty
string.

[para]

[emph Note]: If the Tcl core the package is loaded in provides the
command [cmd {string repeat}] then this command will be implemented in
its terms, for maximum possible speed. Otherwise a fast implementation
in Tcl will be used.

[call [cmd ::textutil::repeat::blank] [arg num]]

A convenience command. Returns a string of [arg num] spaces.

[list_end]
