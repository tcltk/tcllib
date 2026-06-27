[list_begin definitions]

[call [cmd ::textutil::split::splitn] [arg string] [opt [arg size]]]

Returns a list of strings containing consecutive substrings of
[arg string], each [arg size] long—except for the last which will be
shorter if [arg string]’s length is not an exact multiple of [arg size].
The [arg size] defaults to [const 1], i.e., return a list of
[arg string]’s characters; this is the same as calling the built-in
[uri https://www.tcl-lang.org/man/tcl/TclCmd/split.html split] command
with a second argument of [const {""}].


[para]
If [arg string] is empty, an empty list is returned. If [arg size]
[emph {<= 0}], an error will be thrown.

[call [cmd ::textutil::split::splitx] [arg string] [opt [arg regexp]]]

Returns a list of strings containing consecutive substrings of
[arg string] split according to the [arg regexp] regular expression
which defaults to [emph "[lb]\\t \\r\\n[rb]+"] (tabs, spaces, newlines).

[para]
[emph Note]: If [arg regexp] contains capturing parentheses, then the
captured groups will be included in the result list as additional
elements.

[para]
If [arg string] is empty, an empty list is returned.
If [arg regexp] is empty, the [arg string] is split at every character;
this is the same as calling the built-in
[uri https://www.tcl-lang.org/man/tcl/TclCmd/split.html split] command
with a second argument of [const {""}].

[list_end]
