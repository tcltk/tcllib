# -*- tcl -*-
#
# Copyright (c) 2016 by Stefan Sobernig <stefan.sobernig@wu.ac.at>

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
    
    nx::Class create TclClass -superclass nx::Class {
	:property clone:required
	:method init {args} {
	    :alias instvar ::nsf::methods::object::instvar
	    namespace eval [namespace qualifier [self]] {
		namespace import ::nsf::my
	    }

	    ## clone constructor
	    lassign [info class constructor ${:clone}] ctorParams ctorBody
	    :method init $ctorParams [:injectVars $ctorBody]
	    ## clone all methods
	    foreach m [info class methods ${:clone} -private] {
		lassign [info class definition ${:clone} $m] params body
		:method $m $params [:injectVars $body]
	    }
	}
	:method injectVars {body} {
	    if {![info exists :vars]} {
		set :vars [info class variables ${:clone}]
	    }
	    if {[llength ${:vars}]} {
		append tmp [list :instvar {*}${:vars}] "\n" $body;
		return $tmp
	    } else {
		return $body;
	    }
	}
    }

    ##
    ## ::pt::rde::nx: The NX derivative of ::pt::rde::oo, to be inherited
    ## by the generated grammar class. Future content of pt_rdengine_oo.tcl?
    ##
    
    TclClass create nx -clone ::pt::rde::oo
}

package provide pt::rde::nx [package req pt::rde::oo]
