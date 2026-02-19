The following examples show some of the [package ::textutil::tabify]
package’s commands in action.

[para]
The examples make use of a tiny helper command to make spaces and tabs
distinct and visible:

[example {
proc replace_tab_spc s { regsub -all { } [regsub -all \t $s →] ▴ }
}]

This example shows the [cmd ::textutil::tabify::tabify] command in
action.

[example {
const LINES1 "    if \{\$x\} \{\n        puts 1\n    \}"
puts "=== original ===\n[replace_tab_spc $LINES1]\n"
set tabbed [::textutil::tabify::tabify $LINES1]
puts "=== 8spc→tab ===\n[replace_tab_spc $tabbed]\n"
set tabbed [::textutil::tabify::tabify $LINES1 4]
puts "=== 4spc→tab ===\n[replace_tab_spc $tabbed]\n"
=>
=== original ===
▴▴▴▴if▴{$x}▴{
▴▴▴▴▴▴▴▴puts▴1
▴▴▴▴}
 
=== 8spc→tab ===
▴▴▴▴if▴{$x}▴{
→puts▴1
▴▴▴▴}
 
=== 4spc→tab ===
→if▴{$x}▴{
→→puts▴1
→}
}]
