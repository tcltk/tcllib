# ### ### ### ######### ######### #########
##
# (c) 2007 Andreas Kupries.

# Multi file operations. Singleton based on the multiop processor.

# ### ### ### ######### ######### #########
## Requisites

package require fileutil::multi::op

# ### ### ### ######### ######### #########
## API & Implementation

namespace eval ::fileutil {}

# Create the multiop processor object and make it the main command
# of this package.
::fileutil::multi::op ::fileutil::multi

# ### ### ### ######### ######### #########
## Ready

package provide fileutil::multi 0.1
