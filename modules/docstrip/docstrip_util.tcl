## 
## This is the file `docstrip_util.tcl',
## generated with the SAK utility
## (sak docstrip/regen).
## 
## The original source files were:
## 
## tcldocstrip.dtx  (with options: `utilpkg')
## 
## In other words:
## **************************************
## * This Source is not the True Source *
## **************************************
## the true source is the file from which this one was generated.
##
package require Tcl 8.4
package provide docstrip::util 1.0
namespace eval docstrip::util {}
proc docstrip::util::ddt2man {text} {
   set wascode 0
   set verbatim 0
   set res ""
   foreach line [split $text \n] {
      if {$verbatim} then {
         if {$line eq $endverbline} then {
            set verbatim 0
         } else {
            append res [string map {[ [lb] ] [rb]} $line] \n
         }
      } else {
         switch -glob -- $line %%* {
            if {$wacode} then {
               append res {[example_end]} \n
               set wascode 0
            }
            append res [string range $line 2 end] \n
         } %<<* {
            if {!$wascode} then {
               append res {[example_begin]} \n
               set wascode 1
            }
            set endverbline "%[string range $line 3 end]"
            set verbatim 1
         } %<* {
            if {!$wascode} then {
               append res {[example_begin]} \n
               set wascode 1
            }
            set guard ""
            regexp -- {(^%<[^>]*>)(.*)$} $line "" guard line
            append res \[ [list emph $guard] \]\
              [string map {[ [lb] ] [rb]} $line] \n
         } %* {
            if {$wascode} then {
               append res {[example_end]} \n
               set wascode 0
            }
            append res [string range $line 1 end] \n
         } {\\endinput} {
           break
         } "" {
            append res \n
         } default {
            if {!$wascode} then {
               append res {[example_begin]} \n
               set wascode 1
            }
            append res [string map {[ [lb] ] [rb]} $line] \n
         }
      }
   }
   if {$wascode} then {append res {[example_end]} \n}
   return $res
}
## 
## 
## End of file `docstrip_util.tcl'.