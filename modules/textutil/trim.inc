[list_begin definitions]

[call [cmd ::textutil::trim::trim] [arg string] [opt [arg regexp]]]

Returns a copy of [arg string] with any leading or trailing substring
that matches [arg regexp] removed from the [arg string] if does not
contain newlines, or from [emph {every line}] within the [arg string] if
it contains newlines. The [arg regexp] defaults to
[emph {[ \t]+}]. This default will remove leading and trailing
spaces and tabs from the [arg string] if it does not contain newlines,
or from [emph {every line}] within the [arg string] if it contains
newlines.

[call [cmd ::textutil::trim::trimleft] [arg string] [opt [arg regexp]]]

Returns a copy of [arg string] with any leading substring that matches
[arg regexp] removed from the [arg string] if does not contain newlines,
or from [emph {every line}] within the [arg string] if it contains
newlines. The [arg regexp] defaults to [emph {[ \t]+}]. This
default will remove leading spaces and tabs from the [arg string] if it
does not contain newlines, or from [emph {every line}] within the
[arg string] if it contains newlines.

[call [cmd ::textutil::trim::trimright] [arg string] [opt [arg regexp]]]

Returns a copy of [arg string] with any trailing substring that matches
[arg regexp] removed from the [arg string] if does not contain newlines,
or from [emph {every line}] within the [arg string] if it contains
newlines. The [arg regexp] defaults to [emph {[ \t]+}]. This
default will remove trailing spaces and tabs from the [arg string] if it
does not contain newlines, or from [emph {every line}] within the
[arg string] if it contains newlines.

[call [cmd ::textutil::trim::trimPrefix] [arg string] [arg prefix]]

Returns a copy of [arg string] with [arg prefix] removed from the start
if it is present; otherwise returns [arg string] unchanged.

[para]
Contrast this command with the built-in
[uri https://www.tcl-lang.org/man/tcl/TclCmd/string.html string]
command’s [cmd trim], [cmd trimleft], [cmd trimright] subcommands which
remove all characters in a given set of characters passed as a string.

[call [cmd ::textutil::trim::trimEmptyHeading] [arg string]]

Returns a copy of [arg string] with any leading blank lines (including
lines containing only whitespace) removed.

[list_end]
