package provide struct 1.0
source [file join [file dirname [info script]] stack.tcl]
source [file join [file dirname [info script]] queue.tcl]
source [file join [file dirname [info script]] tree.tcl]
namespace eval struct {
	namespace import -force stack::*
	namespace import -force queue::*
	namespace import -force tree::*
	namespace export *
}
