## 
## This is the file `docstrip.tcl',
## generated with the SAK utility
## (sak docstrip/regen).
## 
## The original source files were:
## 
## tcldocstrip.dtx  (with options: `pkg')
## 
## In other words:
## **************************************
## * This Source is not the True Source *
## **************************************
## the true source is the file from which this one was generated.
##
package require Tcl 8.4
package provide docstrip 1.0
namespace eval docstrip {}
proc docstrip::extract {text terminals args} {
   array set O {
      -metaprefix %%
      -onerror throw
      -trimlines 1
   }
   array set O $args
   foreach t $terminals {set T($t) ""}
   set stripped ""
   set block_stack [list]
   set offlevel 0
   set verbatim 0
   set lineno 1
   foreach line [split $text \n] {
      if {$O(-trimlines)} then {
         set line [string trimright $line " "]
      }
      if {$verbatim} then {
         if {$line eq $endverbline} then {
            set verbatim 0
         } elseif {!$offlevel} then {
            append stripped $line \n
         }
      } else {
         switch -glob -- $line %%* {
            if {!$offlevel} then {
               append stripped $O(-metaprefix)\
                 [string range $line 2 end] \n
            }
         } %<<* {
            set endverbline "%[string range $line 3 end]"
            set verbatim 1
         } %<* {
            if {[
               regexp -- {^%<([*/+-]?)([^>]*)>(.*)$} $line ""\
                 modifier expression line
            ]} then {
               regsub -all -- {\\|\{|\}|\$|\[|\]| |;} $expression\
                 {\\&} E
               regsub -all -- {,} $E {|} E
               regsub -all -- {[^()|&!]+} $E {[info exists T(&)]} E
               if {[catch {expr $E} val]} then {
                  switch -- [string tolower $O(-onerror)] "puts" {
                     puts stderr "docstrip: Error in expression\
                       <$expression> ignored on line $lineno."
                  } "ignore" {} default {
                     error $val "" [list DOCSTRIP EXPRERR $lineno]
                  }
                  set val -1
               }
               switch -exact -- $modifier * {
                  lappend block_stack $expression
                  if {$offlevel || !$val} then {incr offlevel}
               } / {
                  if {![llength $block_stack]} then {
                     switch -- [string tolower $O(-onerror)] "puts" {
                        puts stderr "docstrip: Spurious end\
                          block </$expression> ignored on line\
                          $lineno."
                     } "ignore" {} default {
                        error "Spurious end block </$expression>." ""\
                          [list DOCSTRIP SPURIOUS $lineno]
                     }
                  } else {
                     if {[string compare $expression\
                       [lindex $block_stack end]]} then {
                        switch -- [string tolower $O(-onerror)] "puts" {
                           puts stderr "docstrip:\
                             Found </$expression> instead of\
                             </[lindex $block_stack end]> on line\
                             $lineno."
                        } "ignore" {} default {
                           error "Found </$expression> instead of\
                             </[lindex $block_stack end]>." ""\
                             [list DOCSTRIP MISMATCH $lineno]
                        }
                     }
                     if {$offlevel} then {incr offlevel -1}
                     set block_stack [lreplace $block_stack end end]
                  }
               } - {
                  if {!$offlevel && !$val} then {
                     append stripped $line \n
                  }
               } default {
                  if {!$offlevel && $val} then {
                     append stripped $line \n
                  }
               }
            } else {
               switch -- [string tolower $O(-onerror)] "puts" {
                  puts stderr "docstrip: Malformed guard\
                    on line $lineno:"
                  puts stderr $line
               } "ignore" {} default {
                  error "Malformed guard on line $lineno." ""\
                    [list DOCSTRIP BADGUARD $lineno]
               }
            }
         } %* {}\
         {\\endinput} {
           break
         } default {
            if {!$offlevel} then {append stripped $line \n}
         }
      }
      incr lineno
   }
   return $stripped
}
proc docstrip::sourcefrom {name terminals args} {
   set F [open $name r]
   if {[llength $args]} then {
      eval [linsert $args 0 fconfigure $F]
   }
   set text [read $F]
   close $F
   set oldscr [info script]
   info script $name
   set code [catch {
      uplevel 1 [extract $text $terminals -metaprefix #]
   } res]
   info script $oldscr
   if {$code == 1} then {
      error $res $::errorInfo $::errorCode
   } else {
      return $res
   }
}
## 
## 
## End of file `docstrip.tcl'.