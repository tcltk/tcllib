[list_begin definitions]

[call [cmd ::textutil::adjust::adjust] [arg string] \
[opt [arg {option value ...}]]]

Returns a copy of [arg string] modified according to the given options.

[para]
Any newlines in the original [arg string] are treated as spaces, i.e.,
the input [arg string] is handled as a single paragraph of text. If the
result string is shorter than the [option -length], it will not contain
any newlines. Otherwise, the result will contain newlines as needed to
perform the desired justification.

[para]
Together with [cmd ::textutil::adjust::indent] it is possible to
create properly wrapped paragraphs with arbitrary indentations.

[para]
Under the hood, every newline, tab, or sequence of two or more spaces
are treated as a single space, and single spaces are used to separate
the line’s words. These are the algorithm’s [emph real] lines. Every
[emph real] line is placed in a [emph logical] line, which is exactly
[option -length] characters wide (even if the [emph real] line is
shorter). Every word in a [emph real] line is separated by a single
space, except when the [option -justify] [const plain] option is used,
in which case words are separated by one or more spaces as needed to
fill the [emph real] line.

[para]
By default, trailing spaces (including tabs which are first replaced by
spaces) are trimmed. See the [option -full] option below.

[para]
The following options may be given after the [arg string] parameter.
They control how the command places each [emph real] line in its
corresponding [emph logical] line.

[list_begin options]

[opt_def -full [arg boolean]]

If set to [const 0] (false; the default), any trailing spaces are
deleted from each line before returning the string. If set to [const 1]
(true), any trailing spaces are left at the end each line.

[opt_def -hyphenate [arg boolean]]

If set to [const 0] (false; the default), no hyphenation will be done.
If set to [const 1] (true), the command will try to hyphenate the last
word of each line when appropriate.

[para]
If [option -hyphenate] is set to [const 1], hyphenation patterns
[emph must] have been loaded by calling the
[cmd ::textutil::adjust::readPatterns] command, [emph before] the call
to [cmd ::textutil::adjust::adjust]; otherwise
[cmd ::textutil::adjust::adjust] will throw an error.

[opt_def -justify [const center|left|plain|right]]

Sets the justification applied to the returned string to any one of:
[const left] (the default), [const center], [const plain] (justified), or
[const right]. The justification means that any line in the returned
string (possibly excluding the last line), is justified according to the
given justification.

[para]
If the justification is set to [const plain] (justified), and the number
of printable characters in the last line is less than 90% of
[option -length], then the last line is justified [const left], avoiding
the padding of this line when it is too short. The meaning of each value
is:

[list_begin definitions]

[def [const center]]

Each [emph real] line is centered in the [emph logical] line by padding
the [emph real] line with spaces at the beginning and end as needed.
If the last line is less than 90% of [option -length], it will be aligned
[const left] instead of [const center].
(See also the [option -full] option.)

[def [const left]]

Each [emph real] line is placed at the left of the [emph logical] line,
with no preceding spaces. If [option -full] is [const 1] (true), the
[emph real] line will be padded with spaces at the end to make it
[option -length] characters wide.

[def [const plain]]

Each line is fully justified. This means that each
[emph real] line’s words are placed in the [emph logical] line,
separated by one or more spaces, as needed to completely fill the line
with no leading or trailing spaces.

[def [const right]]

Each [emph real] line is placed at the right of the [emph logical] line,
with no trailing spaces, and padded with leading spaces if needed to
make the [emph real] line [option -length] characters wide.

[list_end]

[opt_def  -length [arg integer]]

Sets the [emph logical] line length to be [arg integer]. The
[arg integer] must be a positive integer [emph {> 0}]. The default is
[const 72].

[opt_def -strictlength [arg boolean]]

If set to [const 0] (false; the default), a line can exceed the
specified [option -length] if a single word is longer than
[option -length]. If set to [const 1] (true), words that are longer than
[option -length] are split so that no line exceeds the specified
[option -length].

[list_end]

[call [cmd ::textutil::adjust::readPatterns] [arg filename]]

Reads hyphenation patterns from the file called [arg filename].

[para]
This command is needed only if command [cmd ::textutil::adjust::adjust]
is used with [option -hyphenate] [const 1] (true). In this case the call
to [cmd ::textutil::adjust::readPatterns] [emph must] be done
[emph before] calling [cmd ::textutil::adjust::adjust].

[para]
The [package textutil::adjust] package comes with a number of predefined
pattern files. Use the [cmd ::textutil::adjust::listPredefined] command
to list their names.

[call [cmd ::textutil::adjust::listPredefined]]

Returns a list of the names of the hyphenation files provided by this
package.

[call [cmd ::textutil::adjust::getPredefined] [arg filename]]

Returns the full path and filename of the [arg filename] hyphenation
file. [emph Note] that [arg filename] [emph must] be one of the
names returned by [cmd ::textutil::adjust::listPredefined].

[call [cmd ::textutil::adjust::indent] [arg string] [arg prefix] \
    [opt [arg skip]]]

Returns a modified copy of [arg string] with every non-skipped line
prefixed with [arg prefix] and whitespace (except for the newline),
trimmed from the end. By default no lines are skipped, so all are
prefixed.

[para]
The [option skip] option specifies how many lines to skip at the start
of the string; its default is [const 0], in which case none are skipped
and all are prefixed. If [option skip] is set to a value [emph {> 0}],
then that many initial lines in the string are skipped, i.e., not
prefixed, while all the subsequent lines are prefixed. Setting
[option skip] to [const 1] will create a conventional hanging indent.

[para]
Together with [cmd ::textutil::adjust::adjust] it is possible to
create properly wrapped paragraphs with arbitrary indentations.

[call [cmd ::textutil::adjust::undent] [arg string]]

Returns a modified copy of [arg string] with any common prefix of
whitespace removed from each line.

[para]
Empty lines and lines containing only whitespace are ignored for the
computation of the prefix and all these lines are returned as empty
lines.

[para]
[emph {Note that this command’s name is}] [cmd undent] [emph {not
unindent.}]

[list_end]
