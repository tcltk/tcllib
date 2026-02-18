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

Returns the longest common prefix of the strings in the given [arg list].

[para]
If no argument is given, the empty string is returned.

[call [cmd ::textutil::string::longestCommonPrefix] [opt [arg string]...]]

Returns the longest common prefix of the string arguments, [arg string], ….

[para]
If a single string is given, it is returned since it is its own longest
common prefix. If no argument is given, the empty string is returned.

[list_end]
