The following examples show some of the [package ::textutil::string]
package’s commands in action.

[para]
This first example shows all the commands that work on a single string.

[example {
const LINE "has the σαβ cogs"
puts "“$LINE” const"
set line [::textutil::string::chop $LINE]
puts "“$line” chop"
set line [::textutil::string::tail $line]
puts "“$line” tail"
set line [::textutil::string::cap $line]
puts "“$line” cap"
set line [::textutil::string::capEachWord $line]
puts "“$line” capEachWord"
set line [::textutil::string::uncap $line]
puts "“$line” uncap"
=>
“has the σαβ cogs” const
“has the σαβ cog” chop
“as the σαβ cog” tail
“As the σαβ cog” cap
“As The Σαβ Cog” capEachWord
“as The Σαβ Cog” uncap
}]

This example shows the longest common prefix commands in use.

[example {
const LIST [list handbag handcuff handful handle handy]
puts “[::textutil::string::longestCommonPrefixList $LIST]”
puts “[::textutil::string::longestCommonPrefix king queen knave]”
puts “[::textutil::string::longestCommonPrefix king kin kind kinks]”
=>
“hand”
“”
“kin”
}]

This example shows how to use the
[cmd ::textutil::string::longestCommonPrefixList] command to find the
common path from a list of paths.

[example {
proc longestCommonPath paths {
    const SEP [file separator]
    set path [::textutil::string::longestCommonPrefixList $paths]
    if {[string index $path end] ne $SEP} {
        if {[set j [string last $SEP $path]] > -1} {
            set path [string range $path 0 $j-1]
        }
    }
    if {$path ne $SEP} { set path [string trimright $path $SEP] }
    return $path
}
 
const PATHS [list /home/sally/music /home/sally/museums /home/sally/musings]
puts [::textutil::string::longestCommonPrefixList $PATHS]
puts [longestCommonPath $PATHS]
puts [longestCommonPath [list /bin / /sbin]]
=>
/home/sally/mus
/home/sally
/
}]
