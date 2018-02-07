###
# Author: Sean Woods, yoda@etoyoc.com
##
# Adapted from the "minihttpd.tcl" file distributed with Tclhttpd
#
# The working elements have been updated to operate as a TclOO object
# running with Tcl 8.6+. Global variables and hard coded tables are
# now resident with the object, allowing this server to be more easily
# embedded another program, as well as be adapted and extended to
# support the SCGI module
###

package require uri
package require cron
package require coroutine
package require tool
package require mime
package require fileutil
package require websocket
###
# Standard library of HTTP/SCGI content
# Each of these classes are intended to be mixed into
# either an HTTPD or SCGI reply
###
package require Markdown
package require fileutil::magic::filetype
namespace eval httpd::content {}

namespace eval ::url {}
namespace eval ::httpd {}
namespace eval ::scgi {}


