package provide struct 1.1
source [file join [file dirname [info script]] graph.tcl]
source [file join [file dirname [info script]] queue.tcl]
source [file join [file dirname [info script]] stack.tcl]
source [file join [file dirname [info script]] tree.tcl]
source [file join [file dirname [info script]] matrix.tcl]
namespace eval struct {
	namespace import -force graph::*
	namespace import -force queue::*
	namespace import -force stack::*
	namespace import -force tree::*
	namespace import -force matrix::*
	namespace export *
}
