namespace eval ::textutil {

    namespace eval split {

	namespace export splitx

	# This will be redefined later. We need it just to let
	# a chance for the next import subcommand to work
	#
	proc splitx [list str [list regexp "\[\t \r\n\]+"]] {}
    }

    namespace import -force split::splitx
    namespace export splitx

}

########################################################################
# This one was written by Bob Techentin (RWT in Tcl'ers Wiki):
# http://www.techentin.net
# mailto:techentin.robert@mayo.edu
#
# Later, he send me an email stated that I can use it anywhere, because
# no copyright was added, so the code is defacto in the public domain.
#
# You can found it in the Tcl'ers Wiki here:
# http://mini.net/cgi-bin/wikit/460.html
#
# Bob wrote:
# If you need to split string into list using some more complicated rule
# than builtin split command allows, use following function. It mimics
# Perl split operator which allows regexp as element separator, but,
# like builtin split, it expects string to split as first arg and regexp
# as second (optional) By default, it splits by any amount of whitespace. 
# Note that if you add parenthesis into regexp, parenthesed part of separator
# would be added into list as additional element. Just like in Perl. -- cary 
#

proc ::textutil::split::splitx [list str [list regexp "\[\t \r\n\]+"]] {
    set list  {}
    while {[regexp -indices -- $regexp $str match submatch]} {
	lappend list [string range $str 0 [expr {[lindex $match 0] -1}]]
	if {[lindex $submatch 0]>=0} {
	    lappend list [string range $str [lindex $submatch 0]\
			      [lindex $submatch 1]]
	}
	set str [string range $str [expr {[lindex $match 1]+1}] end]
    }
    lappend list $str
    return $list
}

