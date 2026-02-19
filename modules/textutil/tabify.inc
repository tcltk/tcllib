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

Returns a copy of [arg string] with every horizontal tab replaced by
[arg count] spaces. The [arg count] defaults to 8.

[call [cmd ::textutil::tabify::untabify2] [arg string] [opt [arg count]]]

Returns a copy of [arg string] with horizontal tabs replaced by
[arg count] [emph {or fewer}] space characters using a
text editor like algorithm. The [arg count] defaults to 8.

[para]
This command is the counterpart to [cmd ::textutil::tabify::tabify2].
The algorithm used by this command treats each line in [arg string] as
if it had notional tabstops every [arg count] columns. (So, if
[arg count] is [const 8], at columns [const 8], [const 16], [const 24],
….) Instead of blindly replacing each horizontal tab with [arg count]
spaces, each horizontal tab at a notional tabstop is replaced by enough
spaces to reach the next notional tabstop.

[para]
There is one asymmetry though: A tab may be replaced by a single space,
but not the other way around.

[list_end]
