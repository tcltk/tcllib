[list_begin definitions]

[call [cmd ::textutil::split::splitn] [arg string] [opt [arg len]]]

This command splits the given [arg string] into chunks of [arg len]
characters and returns a list containing these chunks. The argument
[arg len] defaults to [const 1] if none is specified. A negative
length is not allowed and will cause the command to throw an
error. Providing an empty string as input is allowed, the command will
then return an empty list. If the length of the [arg string] is not an
entire multiple of the chunk length, then the last chunk in the
generated list will be shorter than [arg len].

[call [cmd ::textutil::split::splitx] [arg string] [opt [arg regexp]]]

This command splits the [arg string] and return a list. The string is
split according to the regular expression [arg regexp] instead of a
simple list of chars.

[emph Note]: When parentheses are used in the [arg regexp], i.e. regex
capture groups, then these groups will be added into the result list
as additional elements. If the [arg string] is empty the result is the
empty list, like for [cmd split].

If [arg regexp] is empty the [arg string] is split at every character,
like [cmd split] does.

The regular expression [arg regexp] defaults to "[lb]\\t \\r\\n[rb]+".

[list_end]
