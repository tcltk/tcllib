
namespace eval ::textutil {

    namespace eval adjust {

        variable here [file dirname [info script]]
        variable StrRepeat [ namespace parent ]::strRepeat
        variable Justify  left
        variable Length   72
        variable FullLine 0
        variable StrictLength 0
        variable Hyphenate    0
        variable HyphPatterns

        namespace export adjust indent undent

        # This will be redefined later. We need it just to let
        # a chance for the next import subcommand to work
        #
        proc adjust { text args } { }
        proc indent { text args } { }
        proc undent { text args } { }
    }

    namespace import -force adjust::adjust adjust::indent adjust::undent
    namespace export adjust indent undent

}

#########################################################################

proc ::textutil::adjust::adjust { text args } {

    if { [ string length [ string trim $text ] ] == 0 } then {
        return ""
    }

    Configure $args
    Adjust text newtext

    return $newtext
}

proc ::textutil::adjust::Configure { args } {
  variable Justify         left
  variable Length    72
  variable FullLine  0
  variable StrictLength 0
  variable Hyphenate    0
  variable HyphPatterns;                       # hyphenation patterns (TeX)

    set args [ lindex $args 0 ]
    foreach { option value } $args {
      switch -exact -- $option {
        -full {
          if { ![ string is boolean -strict $value ] } then {
            error "expected boolean but got \"$value\""
          }
          set FullLine [ string is true $value ]
        }
        -hyphenate {
          if { ![ string is boolean -strict $value ] } then {
            error "expected boolean but got \"$value\""
          }
          set Hyphenate [string is true $value]
          if { $Hyphenate && ![info exists HyphPatterns(_LOADED_)]} {
            error "hyphenation patterns not loaded!"
          }
        }
        -justify {
          set lovalue [ string tolower $value ]
          switch -exact -- $lovalue {
            left -
            right -
            center -
            plain {
              set Justify $lovalue
            }
            default {
              error "bad value \"$value\": should be center, left, plain or right"
            }
          }
        }
        -length {
          if { ![ string is integer $value ] } then {
            error "expected positive integer but got \"$value\""
          }
          if { $value < 1 } then {
            error "expected positive integer but got \"$value\""
          }
          set Length $value
        }
        -strictlength {
          if { ![ string is boolean -strict $value ] } then {
            error "expected boolean but got \"$value\""
          }
          set StrictLength [ string is true $value ]
        }
        default {
          error "bad option \"$option\": must be -full, -hyphenate, \
          -justify, -length, or -strictlength"
        }
      }
    }

    return ""
}

#
# Dies ist die relevante Routine
#

proc ::textutil::adjust::Adjust { varOrigName varNewName } {
  variable Length
  variable StrictLength
  variable Hyphenate

  upvar $varOrigName orig
  upvar $varNewName  text

  regsub -all -- "(\n)|(\t)"     $orig  " "  text
  regsub -all -- " +"            $text  " "  text
  regsub -all -- "(^ *)|( *\$)"  $text  ""   text

  set ltext [ split $text ]

  if { $StrictLength } then {

    # Limit the length of a line to $Length. If any single
    # word is long than $Length, then split the word into multiple
    # words.

    set i 0
    foreach tmpWord $ltext {
      if { [ string length $tmpWord ] > $Length } then {

        # Since the word is longer than the line length,
        # remove the word from the list of words.  Then
        # we will insert several words that are less than
        # or equal to the line length in place of this word.

        set ltext [ lreplace $ltext $i $i ]
        incr i -1
        set j 0

        # Insert a series of shorter words in place of the
        # one word that was too long.

        while { $j < [ string length $tmpWord ] } {

          # Calculate the end of the string range for this word.

          if { [ expr { [string length $tmpWord ] - $j } ] > $Length } then {
            set end [ expr { $j + $Length - 1} ]
          } else {
            set end [ string length $tmpWord ]
          }

          set ltext [ linsert $ltext [ expr {$i + 1} ] [ string range $tmpWord $j $end ] ]
          incr i
          incr j [ expr { $end - $j + 1 } ]
        }
      }
      incr i
    }
  }

  # End if { $StrictLength } ...

  set line [ lindex $ltext 0 ]
  set pos [ string length $line ]
  set text ""
  set numline 0
  set numword 1
  set words(0) 1
  set words(1) [ list $pos $line ]

  foreach word [ lrange $ltext 1 end ] {
    set size [ string length $word ]
    if { ( $pos + $size ) < $Length } then {
      # the word fits into the actual line ...
      #
      append line " $word"
      incr numword
      incr words(0)
      set words($numword) [ list $size $word ]
      incr pos
      incr pos $size
    } elseif { $Hyphenate } {
      # the word does not fit into the line and we must try to hyphenate

      set word2 [Hyphenation $word];
      set word2 [string trim $word2];
      set word3 "";
      set word4 ""

      set i 0;
      set iMax [llength $word2];

      # build up the part of the word to be kept in the current line

      while { $i < $iMax } {
        set syl [lindex $word2 $i]
        if { $pos + [string length " $word3$syl-"] > $Length } { break }
        append word3 $syl;
        incr i;
      }

      # build up the part of the hyphenated word to be transferred to
      # the next line

      while { $i < $iMax } {
        set syl [lindex $word2 $i];
        append word4 $syl;
        incr i;
      }

      # to be done in the future: code that guarantees that the
      # parts of the hyphenated word have a minimum length ..

      if {[string length $word3] && [string length $word4]} {
        # hyphenation was succesful: keep $word3 and the hyphen in the
        # current line and begin next line with $word4
        #
        # current line

        append line " $word3-"
        incr numword
        incr words(0)
        set words($numword) [list [string length $word3] $word3];
        incr pos;
        incr pos [string length $word3];

        if [string length $text] { append text "\n" }
        append text [ Justification $line [ incr numline ] words ]

        # next line

        set line "$word4"
        set pos [string length $word4];
        catch { unset words }
        set numword 1
        set words(0) 1
        set words(1) [ list $size $word ]
      } else {
        # hyphenation failed => close current line and begin
        # the next line with the unhyphenated word ($word)

        if [string length $text] { append text "\n" }
        append text [Justification $line [incr numline] words]

        set line "$word"
        set pos $size
        catch { unset words }
        set numword 1
        set words(0) 1
      }
    } else {
      # no hyphenation
      if [string length $text] { append text "\n" }
      append text [Justification $line [ incr numline ] words ]

      set line "$word"
      set pos $size
      catch { unset words }
      set numword 1
      set words(0) 1
      set words(1) [ list $size $word ]
    }
  }
  if [string length $text] { append text "\n" }
  append text [Justification $line end words]

  return $text
}

#
# Ende der relevanten Routine
#

proc ::textutil::adjust::Justification { line index arrayName } {
    variable Justify
    variable Length
    variable FullLine
    variable StrRepeat

    upvar $arrayName words

    set len [ string length $line ]
    if { $Length == $len } then {
        return $line
    }

    # Special case:
    # for the last line, and if the justification is set to 'plain'
    # the real justification is 'left' if the length of the line
    # is less than 90% (rounded) of the max length allowed. This is
    # to avoid expansion of this line when it is too small: without
    # it, the added spaces will 'unbeautify' the result.
    #

    set justify $Justify
    if { ( "$index" == "end" ) && \
             ( "$Justify" == "plain" ) && \
             ( $len < round($Length * 0.90) ) } then {
        set justify left
    }

    # For a left justification, nothing to do, but to
    # add some spaces at the end of the line if requested
    #

    if { "$justify" == "left" } then {
        set jus ""
        if { $FullLine } then {
            set jus [ $StrRepeat " " [ expr { $Length - $len } ] ]
        }
        return "${line}${jus}"
    }

    # For a right justification, just add enough spaces
    # at the beginning of the line
    #

    if { "$justify" == "right" } then {
        set jus [ $StrRepeat " " [ expr { $Length - $len } ] ]
        return "${jus}${line}"
    }

    # For a center justification, add half of the needed spaces
    # at the beginning of the line, and the rest at the end
    # only if needed.

    if { "$justify" == "center" } then {
        set mr [ expr { ( $Length - $len ) / 2 } ]
        set ml [ expr { $Length - $len - $mr } ]
        set jusl [ $StrRepeat " " $ml ]
        set jusr [ $StrRepeat " " $mr ]
        if { $FullLine } then {
            return "${jusl}${line}${jusr}"
        } else {
            return "${jusl}${line}"
        }
    }

    # For a plain justiciation, it's a little bit complex:
    # if some spaces are missing, then
    # sort the list of words in the current line by
    # decreasing size
    # foreach word, add one space before it, except if
    # it's the first word, until enough spaces are added
    # then rebuild the line
    #

    if { "$justify" == "plain" } then {
        set miss [ expr { $Length - [ string length $line ] } ]
        if { $miss == 0 } then {
            return "${line}"
        }

        for { set i 1 } { $i < $words(0) } { incr i } {
            lappend list [ eval list $i $words($i) 1 ]
        }
        lappend list [ eval list $i $words($words(0)) 0 ]
        set list [ SortList $list decreasing 1 ]

        set i 0
        while { $miss > 0 } {
            set elem [ lindex $list $i ]
            set nb [ lindex $elem 3 ]
            incr nb
            set elem [ lreplace $elem 3 3 $nb ]
            set list [ lreplace $list $i $i $elem ]
            incr miss -1
            incr i
            if { $i == $words(0) } then {
                set i 0
            }
        }
        set list [ SortList $list increasing 0 ]
        set line ""
        foreach elem $list {
            set jus [ $StrRepeat " " [ lindex $elem 3 ] ]
            set word [ lindex $elem 2 ]
            if { [ lindex $elem 0 ] == $words(0) } then {
                append line "${jus}${word}"
            } else {
                append line "${word}${jus}"
            }
        }

        return "${line}"
    }

    error "Illegal justification key \"$justify\""
}

proc ::textutil::adjust::SortList { list dir index } {

    if { [ catch { lsort -integer -$dir -index $index $list } sl ] != 0 } then {
        error "$sl"
    }

    return $sl
}

# Hyphenation utilities based on Knuth's algorithm
#
# Copyright (C) 2001-2003 by Dr.Johannes-Heinrich Vogeler
# These procedures may be used as part of the tcllib

# textutil::adjust::Hyphenation
#
#      Hyphenate a string using Knuth's algorithm
#
# Parameters:
#      str     string to be hyphenated
#
# Returns:
#      the hyphenated string

proc ::textutil::adjust::Hyphenation { str } {

  # if there are manual set hyphenation marks e.g. "Recht\-schrei\-bung"
  # use these for hyphenation and return

  if [regexp {[^\\-]*[\\-][.]*} $str] {
    regsub -all {(\\)(-)} $str {-} tmp;
    return [split $tmp -];
  }

  # otherwise follow Knuth's algorithm

  variable HyphPatterns;                       # hyphenation patterns (TeX)

  set w ".[string tolower $str].";             # transform to lower case
  set wLen [string length $w];                 # and add delimiters

  # Initialize hyphenation weights

  set s {}
  for {set i 0} {$i < $wLen} {incr i} {
    lappend s 0;
  }

  for {set i 0} {$i < $wLen} {incr i} {
    set kmax [expr $wLen-$i];
    for {set k 1} {$k < $kmax} {incr k} {
      set sw [string range $w $i [expr $i+$k]];
      if [info exists HyphPatterns($sw)] {
        set hw $HyphPatterns($sw);
        set hwLen [string length $hw];
        for {set l1 0; set l2 0} {$l1 < $hwLen} {incr l1} {
          set c [string index $hw $l1];
          if [string is digit $c] {
            set sPos [expr $i+$l2];
            if {$c > [lindex $s $sPos]} {
              set s [lreplace $s $sPos $sPos $c];
            }
          } else {
            incr l2;
          }
        }
      }
    }
  }

  # Replace all even hyphenation weigths by zero

  for {set i 0} {$i < [llength $s]} {incr i} {
    set c [lindex $s $i];
    if ![expr $c%2] { set s [lreplace $s $i $i 0] }
  }

  # Don't start with a hyphen! Take also care of words enclosed in quotes
  # or that someone has forgotten to put a blank between a punctuation
  # character and the following word etc.

  for {set i 1} {$i < [expr $wLen-1]} {incr i} {
    set c [string range $w $i end]
    if [regexp {^[:alpha:][.]*} $c] {
      for {set k 1} {$k < [expr $i+1]} {incr k} {
        set s [lreplace $s $k $k 0];
      }
      break
    }
  }

  # Don't separate the last character of a word with a hyphen

  set max [expr [llength $s]-2];
  if {$max} {set s [lreplace $s $max end 0]}

  # return the syllabels of the hyphenated word as a list!

  set ret "";
  set w ".$str.";
  for {set i 1} {$i < [expr $wLen-1]} {incr i} {
    if [lindex $s $i] { append ret - }
    append ret [string index $w $i];
  }
  return [split $ret -];
}

# textutil::adjust::listPredefined
#
#      Return the names of the hyphenation files coming with the package.
#
# Parameters:
#      None.
#
# Result:
#       List of filenames (without directory)

proc ::textutil::adjust::listPredefined {} {
    variable here
    return [glob -type f -directory $here -tails *.tex]
}

# textutil::adjust::getPredefined
#
#      Retrieve the full path for a predefined hyphenation file
#       coming with the package.
#
# Parameters:
#      name     Name of the predefined file.
#
# Results:
#       Full path to the file, or an error if it doesn't
#       exist or is matching the pattern *.tex.

proc ::textutil::adjust::getPredefined {name} {
    variable here

    if {![string match *.tex $name]} {
        return -code error \
                "Illegal hyphenation file \"$name\""
    }
    set path [file join $here $name]
    if {![file exists $path]} {
        return -code error \
                "Unknown hyphenation file \"$path\""
    }
    return $path
}

# textutil::adjust::readPatterns
#
#      Read hyphenation patterns from a file and store them in an array
#
# Parameters:
#      filNam  name of the file containing the patterns

proc ::textutil::adjust::readPatterns { filNam } {

  variable HyphPatterns;                       # hyphenation patterns (TeX)

  # HyphPatterns(_LOADED_) is used as flag for having loaded
  # hyphenation patterns from the respective file (TeX format)

  if [info exists HyphPatterns(_LOADED_)] {
    unset HyphPatterns(_LOADED_);
  }

  # the array xlat provides translation from TeX encoded characters
  # to those of the ISO-8859-1 character set

  set xlat(\"s) \337;                          # 223 := sharp s
  set xlat(\`a) \340;                          # 224 := a, grave
  set xlat(\'a) \341;                          # 225 := a, acute
  set xlat(\^a) \342;                          # 226 := a, circumflex
  set xlat(\"a) \344;                          # 228 := a, diaeresis
  set xlat(\`e) \350;                          # 232 := e, grave
  set xlat(\'e) \351;                          # 233 := e, acute
  set xlat(\^e) \352;                          # 234 := e, circumflex
  set xlat(\`i) \354;                          # 236 := i, grave
  set xlat(\'i) \355;                          # 237 := i, acute
  set xlat(\^i) \356;                          # 238 := i, circumflex
  set xlat(\~n) \361;                          # 241 := n, tilde
  set xlat(\`o) \362;                          # 242 := o, grave
  set xlat(\'o) \363;                          # 243 := o, acute
  set xlat(\^o) \364;                          # 244 := o, circumflex
  set xlat(\"o) \366;                          # 246 := o, diaeresis
  set xlat(\`u) \371;                          # 249 := u, grave
  set xlat(\'u) \372;                          # 250 := u, acute
  set xlat(\^u) \373;                          # 251 := u, circumflex
  set xlat(\"u) \374;                          # 252 := u, diaeresis

  set fd [open $filNam RDONLY];
  set status 0;

  while {[gets $fd line] >= 0} {

    switch -exact $status {
      PATTERNS {
        if [regexp {^\}[.]*} $line] {
          # End of patterns encountered: set status
          # and ignore that line
          set status 0;
          continue;
        } else {
          # This seems to be pattern definition line; to process it
          # we have first to do some editing
          #
          # 1) eat comments in a pattern definition line
          # 2) eat braces and coded linefeeds

          set z [string first "%" $line];
          if {$z > 0} { set line [string range $line 0 [expr $z-1]] }

          regsub -all {(\\n|\{|\})} $line {} tmp;
          set line $tmp;

          # Now $line should consist only of hyphenation patterns
          # separated by white space

          # Translate TeX encoded characters to ISO-8859-1 characters
          # using the array xlat defined above

          foreach x [array names xlat] {
            regsub -all {$x} $line $xlat($x) tmp;
            set line $tmp;
          }

          # split the line and create a lookup array for
          # the repective hyphenation patterns

          foreach item [split $line] {
            if [string length $item] {
              if ![string match {\\} $item] {
                # create index for hyphenation patterns

                set var $item;
                regsub -all {[0-9]} $var {} idx;
                # store hyphenation patterns as elements of an array

                set HyphPatterns($idx) $item;
              }
            }
          }
        }
      }
      EXCEPTIONS {
        if [regexp {^\}[.]*} $line] {
          # End of patterns encountered: set status
          # and ignore that line
          set status 0;
          continue;
        } else {
          # to be done in the future
        }
      }
      default {
        if [regexp {^\\endinput[.]*} $line] {
          # end of data encountered, stop processing and
          # ignore all the following text ..
          break;
        } elseif [regexp {^\\patterns[.]*} $line] {
          # begin of patterns encountered: set status
          # and ignore that line
          set status PATTERNS;
          continue;
        } elseif [regexp {^\\hyphenation[.]*} $line] {
          # some particular cases to be treated separately
          set status EXCEPTIONS
          continue;
        } else {
          set status 0;
        }
      }
    }                  ;# switch
  }

  close $fd;
  set HyphPatterns(_LOADED_) 1;

  return;
}

#######################################################

# @c The specified <a text>block is indented
# @c by <a prefix>ing each line. The first
# @c <a hang> lines ares skipped.
#
# @a text:   The paragraph to indent.
# @a prefix: The string to use as prefix for each line
# @a prefix: of <a text> with.
# @a skip:   The number of lines at the beginning to leave untouched.
#
# @r Basically <a text>, but indented a certain amount.
#
# @i indent
# @n This procedure is not checked by the testsuite.

proc ::textutil::adjust::indent {text prefix {skip 0}} {
    set text [string trim $text]

    set res [list]
    foreach line [split $text \n] {
        if {[string compare "" [string trim $line]] == 0} {
            lappend res {}
        } elseif {$skip <= 0} {
            lappend res $prefix[string trimright $line]
        } else {
            lappend res [string trimright $line]
        }
        if {$skip > 0} {incr skip -1}
    }
    return [join $res \n]
}

# Undent the block of text: Compute LCP (restricted to whitespace!)
# and remove that from each line. Note that this preverses the
# shaping of the paragraph (i.e. hanging indent are _not_ flattened)
# We ignore empty lines !!

proc ::textutil::adjust::undent {text} {

    if {$text == {}} {return {}}

    set lines [split $text \n]
    set ne [list]
    foreach l $lines {
        if {[string length [string trim $l]] == 0} continue
        lappend ne $l
    }
    set lcp [::textutil::longestCommonPrefixList $ne]

    if {[string length $lcp] == 0} {return $text}

    regexp {^([         ]*)} $lcp -> lcp

    if {[string length $lcp] == 0} {return $text}

    set len [string length $lcp]

    set res [list]
    foreach l $lines {
        if {[string length [string trim $l]] == 0} {
            lappend res {}
        } else {
            lappend res [string range $l $len end]
        }
    }
    return [join $res \n]
}
