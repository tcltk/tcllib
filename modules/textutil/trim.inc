[list_begin definitions]

[call [cmd ::textutil::trim::trim] [arg string] [opt [arg regexp]]]

Remove in [arg string] any leading and trailing substring according to
the regular expression [arg regexp] and return the result as a new
string.  This is done for all [emph lines] in the string, that is any
substring between 2 newline chars, or between the beginning of the
string and a newline, or between a newline and the end of the string,
or, if the string contain no newline, between the beginning and the
end of the string.

The regular expression [arg regexp] defaults to "[lb] \\t[rb]+".

[call [cmd ::textutil::trim::trimleft] [arg string] [opt [arg regexp]]]

Remove in [arg string] any leading substring according to the regular
expression [arg regexp] and return the result as a new string. This
apply on any [emph line] in the string, that is any substring between
2 newline chars, or between the beginning of the string and a newline,
or between a newline and the end of the string, or, if the string
contain no newline, between the beginning and the end of the string.

The regular expression [arg regexp] defaults to "[lb] \\t[rb]+".

[call [cmd ::textutil::trim::trimright] [arg string] [opt [arg regexp]]]

Remove in [arg string] any trailing substring according to the regular
expression [arg regexp] and return the result as a new string. This
apply on any [emph line] in the string, that is any substring between
2 newline chars, or between the beginning of the string and a newline,
or between a newline and the end of the string, or, if the string
contain no newline, between the beginning and the end of the string.

The regular expression [arg regexp] defaults to "[lb] \\t[rb]+".

[call [cmd ::textutil::trim::trimPrefix] [arg string] [arg prefix]]

Removes the [arg prefix] from the beginning of [arg string] and
returns the result. The [arg string] is left unchanged if it doesn't
have [arg prefix] at its beginning.

[call [cmd ::textutil::trim::trimEmptyHeading] [arg string]]

Looks for empty lines (including lines consisting of only whitespace)
at the beginning of the [arg string] and removes it. The modified
string is returned as the result of the command.

[list_end]
