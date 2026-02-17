[list_begin definitions]

[call [cmd ::textutil::string::chop] [arg string]]

Returns a copy of [arg string] with the last character removed.

[call [cmd ::textutil::string::tail] [arg string]]

Returns a copy of [arg string] with the first character removed.

[call [cmd ::textutil::string::cap] [arg string]]

Returns a copy of [arg string] with the first character capitalized.

[call [cmd ::textutil::string::capEachWord] [arg string]]

Returns a copy of [arg string] with the first character of every word
capitalized.

[comment {Deleted the following since it does not appear to be true:
Words quoted with either backslash or dollar-sign are left untouched.}]

[call [cmd ::textutil::string::uncap] [arg string]]

Returns a copy of [arg string] with the first character lowercased.

[call [cmd ::textutil::string::longestCommonPrefixList] [arg list]]
[call [cmd ::textutil::string::longestCommonPrefix] [opt [arg string]...]]

Computes the longest common prefix for either the [arg string]s given
to the command, or the strings specified in the single [arg list], and
returns it as the result of the command.

[para]

If no strings were specified the result is the empty string.  If only
one string was specified, the string itself is returned, as it is its
own longest common prefix.

[list_end]
