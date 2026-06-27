The following examples show some of the [package ::textutil::trim]
package’s commands in action.

[para]
The following [cmd proc] is used by some of the examples below.

[example {
proc replace_ws s { regsub -all { } [regsub -all \t [regsub -all \n $s ⏎] →] ▴ }
}]

[para]
This example shows the use of [cmd ::textutil::trim::trimEmptyHeading]
and [cmd ::textutil::trim::trim].

[example {
const LINES1 "\t\n Alpha\t\n Beta \t\n Gamma \t\n"
puts "== const =============================\n[replace_ws $LINES1]"
set line [::textutil::trim::trimEmptyHeading $LINES1]
puts "== textutil::trim::trimEmptyHeading ==\n[replace_ws $line]"
set line [string trimleft $LINES1]
puts "== string trimleft ===================\n[replace_ws $line]"
set line [::textutil::trim::trim $LINES1]
puts "== textutil::trim::trim ==============\n[replace_ws $line]"
=>
== const =============================
→⏎▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
== textutil::trim::trimEmptyHeading ==
▴Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
== string trimleft ===================
Alpha→⏎▴Beta▴→⏎▴Gamma▴→⏎
== textutil::trim::trim ==============
⏎Alpha⏎Beta⏎Gamma⏎
}]

Notice the subtle difference in behavior between
[cmd ::textutil::trim::trimEmptyHeading] and [cmd {string trimleft}].

[para]
This example shows the use of the built-in [cmd {string trim}] in
combination with and [cmd ::textutil::trim::trim].

[example {
const LINES2 [string trim "\t\n Delta\t\n Epsilon \t\n Zeta \t\n"]
puts "== const =============================\n[replace_ws $LINES2]"
set line [::textutil::trim::trim $LINES2]
puts "== textutil::trim::trim ==============\n[replace_ws $line]"
=>
== const =============================
Delta→⏎▴Epsilon▴→⏎▴Zeta
== textutil::trim::trim ==============
Delta⏎Epsilon⏎Zeta
}]

[para]
This example contrasts the built-in [cmd {string trim}] with
[cmd ::textutil::trim::trimPrefix].

[example {
const PATH /home/homer
puts "const='$PATH'"
puts "string trim \$PATH /home='[string trim $PATH /home]'"
puts "string trim \$PATH /home='[string trim $PATH ehmo/]'"
puts "::textutil::trim::trimPrefix \$PATH\
    /home='[::textutil::trim::trimPrefix $PATH /home]'"
const LINE mimic
puts "string trim \$LINE mic='[string trim $LINE mic]'"
puts "::textutil::trim::trimPrefix \$LINE\
    mic='[::textutil::trim::trimPrefix $LINE mic]'"
=>
const='/home/homer'
string trim $PATH /home='r'
string trim $PATH /home='r'
::textutil::trim::trimPrefix $PATH /home='/homer'
string trim $LINE mic=''
::textutil::trim::trimPrefix $LINE mic='mimic'
}]

For the [var PATH] examples, the [cmd {string trim}] command trims all
the individual characters that are in the string "/home", i.e., "/",
"h", "o", "m", "e". The order of the characters in the string don’t
matter as the "ehmo/" example shows. Compare this with
[cmd ::textutil::trim::trimPrefix] which trims the literal string
"/home".

[para]
For the [var LINE] examples, the [cmd {string trim}] command trims all
the individual characters that are in the string "mic", i.e., "m",
"i", "c". Compare this with [cmd ::textutil::trim::trimPrefix]
which trims the literal string "mic"; but since the [var LINE] doesn’t
start with "mic", nothing is trimmed and the string is returned
unchanged.
