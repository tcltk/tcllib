The following examples show some of the [package ::textutil::split]
package’s commands in action.

[para]
To help make the examples’ effects more visible, each element of the
returned lists is bracketed using ❬ and ❭. For non-UTF-8 aware editors
these can be replaced with [const {\u276C}] and [const {\u276D}].

[para]
This first example shows how to split strings by size.

[example {
const LINE1 "α and ℤ"
set chars [::textutil::split::splitn $LINE1] ;# splits into characters
puts ❬[join $chars "❭ ❬"]❭
set chars [split $LINE1 ""] ;# splits into characters
puts ❬[join $chars "❭ ❬"]❭
set chunks [::textutil::split::splitn $LINE1 3]
puts ❬[join $chunks "❭ ❬"]❭
=>
❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
❬α❭ ❬ ❭ ❬a❭ ❬n❭ ❬d❭ ❬ ❭ ❬ℤ❭
❬α a❭ ❬nd ❭ ❬ℤ❭
}]

This second example shows how to split strings by regexp.

[example {
const LINE2 "a, be , cat, done , eagle"
set chunks [::textutil::split::splitx $LINE2] ;# splits on [\t \r\n]+
puts ❬[join $chunks "❭ ❬"]❭
set chunks [::textutil::split::splitx $LINE2 {\s*,\s*}]
puts ❬[join $chunks "❭ ❬"]❭
set chunks [::textutil::split::splitx $LINE2 {\s*(,)\s*}]
puts ❬[join $chunks "❭ ❬"]❭
=>
❬a,❭ ❬be❭ ❬,❭ ❬cat,❭ ❬done❭ ❬,❭ ❬eagle❭
❬a❭ ❬be❭ ❬cat❭ ❬done❭ ❬eagle❭
❬a❭ ❬,❭ ❬be❭ ❬,❭ ❬cat❭ ❬,❭ ❬done❭ ❬,❭ ❬eagle❭
}]
