# # ## ### ##### ######## ############# ####################
## -*- tcl -*-
## (C) 2011 Andreas Kupries, BSD licensed.

# # ## ### ##### ######## ############# ####################
## Requisites

package require Tcl 8.5
package require TclOO

# # ## ### ##### ######## ############# #####################
## Public API implementation

# Easy callback support.
# http://wiki.tcl.tk/21595. v20, Donal Fellows
proc ::oo::Helpers::mymethod {method args} {
    list [uplevel 1 {namespace which my}] $method {*}$args
}

# # ## ### ##### ######## ############# ####################
## Ready

package provide oo::util 1
