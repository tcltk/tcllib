package require Tcl 8.6 ;# try in pipeline.tcl. Possibly other things.
package require TclOO
package require uuid
package require oo::dialect

::namespace eval ::clay {}
::namespace eval ::clay::classes {}

set ::clay::trace 0
