package require mime
package require smtp

set sndr "tcl-test-script@localhost"
set rcpt "tcllib-test@localhost"
set msg "This is a sample message send from Tcl.\nAs\
always, let us check the transparency function:\n. <-- there\
should be a dot there.\nBye"

set tok [mime::.new {} -canonical text/plain -encoding 7bit -string $msg]
$tok header set Subject "Testing from Tcl"
smtp::sendmessage $tok -servers localhost \
    -header [list To $rcpt] \
    -header [list From $sndr]
$tok .destroy

