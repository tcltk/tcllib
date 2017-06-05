# -*- tcl -*-
#
# Copyright (c) 2016-2017 by Stefan Sobernig <stefan.sobernig@wu.ac.at>

# # ## ### ##### ######## ############# #####################
## Package description

## ...


# # ## ### ##### ######## ############# #####################
## Requisites

package require pt::rde::oo
package req nx

namespace eval ::pt::rde {

    ##
    ## Helper: An NX metaclass, which allows for deriving an NX class from
    ## a given TclOO class.
    ##
    
    nx::Class create ClassFactory -superclass nx::Class {
	:property prototype:required
	:method init {args} {
	    :alias instvar ::nsf::methods::object::instvar
	    namespace eval [namespace qualifier [self]] {
		namespace import ::nsf::my
	    }

	    set vars [info class variables ${:prototype}]
	    if {[llength $vars]} {
		set vars [concat :instvar $vars]
	    }
	    
	    ## clone constructor
	    lassign [info class constructor ${:prototype}] ctorParams ctorBody
	    
	    set ctorBody [string map [list @body@ $ctorBody @vars@ $vars] {
		:require namespace; apply [list {} {
		    namespace import ::nsf::my
		    @vars@
		    @body@
		} [self]]
	    }]
	    
	    :method init $ctorParams $ctorBody		       

	    ## clone all methods
	    foreach m [info class methods ${:prototype} -private] {
		lassign [info class definition ${:prototype} $m] params body
		:method $m $params [string map [list @body@ $body @vars@ $vars] {
		    @vars@
		    @body@
		}]
	    }
	}
    }

    ##
    ## ::pt::rde::nx:
    ##
    ## The NX derivative of ::pt::rde::oo, to be inherited
    ## by the generated grammar class.
    ##
    
    ClassFactory create nx -prototype ::pt::rde::oo
    
}

package provide pt::rde::nx [package req pt::rde::oo].1.0
