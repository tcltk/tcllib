package require Tcl 8.6 ;# try in pipeline.tcl. Possibly other things.
package require TclOO
package require uuid
package require dicttool 1.2
package require oo::dialect

::oo::dialect::create ::clay

::namespace eval ::clay {}
::namespace eval ::clay::classes {}
::namespace eval ::clay::define {}
