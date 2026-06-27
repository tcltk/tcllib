The following examples show some of the [package ::textutil::adjust]
package’s commands in action.

[para]
The following [cmd proc] and [const const] are used by the examples
below.

[example {
proc replace_spc {s {sub ▴}} { regsub -all { } $s $sub }
const LINES "Four\nsiamese cats\nheard barks\nand bolted."
}]

The [cmd replace_spc] command replaces every space in the string it is
passed with the ▴ symbol. The [const LINES] constant provides some text
for the examples to work with.
 
[subsection Justifying]

The following example show every justification option in use. Spaces
have been made visible by preserving them using [option -full] [const 1]
and replacing them with the ▴ symbol.

[para]
Normally, [option -full] would [emph not] be used and there would be
[emph no] trailing spaces in each line.

[example {
set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify left]
puts "======= left =======\n[replace_spc $lines]"
set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify center]
puts "====== center ======\n[replace_spc $lines]"
set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify plain]
puts "======= plain ======\n[replace_spc $lines]"
set lines [textutil::adjust::adjust $LINES -length 20 -full 1 -justify right]
puts "======= right ======\n[replace_spc $lines]"
=>
======= left =======
Four▴siamese▴cats▴▴▴
heard▴barks▴and▴▴▴▴▴
bolted.▴▴▴▴▴▴▴▴▴▴▴▴▴

====== center ======
▴▴Four▴siamese▴cats▴
▴▴▴heard▴barks▴and▴▴
▴▴▴▴▴▴▴bolted.▴▴▴▴▴▴

======= plain ======
Four▴siamese▴▴▴▴cats
heard▴▴▴barks▴▴▴▴and
bolted.▴▴▴▴▴▴▴▴▴▴▴▴▴

======= right ======
▴▴▴Four▴siamese▴cats
▴▴▴▴▴heard▴barks▴and
▴▴▴▴▴▴▴▴▴▴▴▴▴bolted.
}]

[subsection {Indenting and Unindenting}]

In the following example leading spaces have been made visible by using
an indent of [const {··}] rather than, say, two spaces, and other
spaces have been made visible by replacing them with the ▴ symbol. There
are no trailing spaces since [cmd textutil::adjust::indent] trims them.

[example {
set lines [textutil::adjust::adjust $LINES -length 20 -justify left]
puts "======== left =========\n[replace_spc $lines]"
set indented [textutil::adjust::indent $lines "··"]
puts "======== indent =======\n[replace_spc $indented]"
# undent only unindents spaces
set indented [regsub -all · $indented " "]
set unindented [textutil::adjust::undent $indented]
puts "======== undent =======\n[replace_spc $unindented]"
set hanging [textutil::adjust::indent $lines "··" 1]
puts "==== hanging indent ===\n[replace_spc $hanging]"
=>
======== left =========
Four▴siamese▴cats
heard▴barks▴and
bolted.
======== indent =======
··Four▴siamese▴cats
··heard▴barks▴and
··bolted.
======== undent =======
Four▴siamese▴cats
heard▴barks▴and
bolted.
==== hanging indent ===
Four▴siamese▴cats
··heard▴barks▴and
··bolted.
}]
