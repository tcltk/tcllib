[list_begin definitions]

[call [cmd ::textutil::tabify::tabify] [arg string] [opt [arg count]]]

Returns a copy of [arg string] with any substring of [arg count] space
characters replaced by a horizontal tab. The [arg count] defaults to 8.

[call [cmd ::textutil::tabify::tabify2] [arg string] [opt [arg count]]]

Returns a copy of [arg string] with substrings of [arg count]
[emph {or fewer}] space characters replaced by a horizontal tab using a
text editor like algorithm. The [arg count] defaults to 8.

[para]
The algorithm used by this command treats each line in [arg string] as
if it had notional tabstops every [arg count] columns. (So, if [arg count]
is [const 8], at columns [const 8], [const 16], [const 24], ….) Only
sequences of [emph {two or more}] space characters that occur
immediately before a notional tabstop are replaced with a tab.

[call [cmd ::textutil::tabify::untabify] [arg string] [opt [arg count]]]

Untabify the [arg string] by replacing any tabulation char by a
substring of [arg count] space chars and return the result as a new
string. [arg count] defaults to 8.

[call [cmd ::textutil::tabify::untabify2] [arg string] [opt [arg count]]]

Untabify the [arg string] by replacing any tabulation char by a
substring of at most [arg count] space chars and return the result as a
new string. Unlike [cmd textutil::tabify::untabify] each tab is not
replaced by a fixed number of space characters.  The command overlays
each line in the [arg string] with tabstops every [arg count] columns
instead and replaces tabs with just enough space characters to reach
the next tabstop. This is the complement of the actions taken by
[cmd ::textutil::tabify::tabify2]. [arg count] defaults to 8.

[para]

There is one asymmetry though: A tab can be replaced with a single
space, but not the other way around.

[list_end]
