# magic.tcl --
#
#	Tcl based file type recognizers
#
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005      Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: magic.tcl,v 1.1 2005/02/10 17:34:16 andreas_kupries Exp $


# ### ### ### ######### ######### #########
## Requirements.

package require Tcl 8.4
package require fileutil::magic::rt    ; # We need the runtime core.
package require fileutil::magic::/mime ; # A recognizer engine.

# ### ### ### ######### ######### #########
## Implementation

proc ::fileutil::magic::mimetype {file} {
    rt::open $file
    /mime::run
    rt::close
    return [rt::result]
}

# ### ### ### ######### ######### #########
## Ready for use.

package provide fileutil::magic 1.0
# EOF



