# -*- tcl -*-
#
# -- nroff commands
#
# Copyright (c) 2003 Andreas Kupries <andreas_kupries@sourceforge.net>


################################################################
# nroff specific commands
#
# All dot-commands (f.e. .PP) are returned with a leading \n,
# enforcing that they are on a new line. Any empty line created
# because of this is filtered out in the post-processing step.


proc nr_lp      {}          {return \n.LP}
proc nr_ta      {{text {}}} {return ".ta$text"}
proc nr_bld     {}          {return \\fB}
proc nr_ul      {}          {return \\fI}
proc nr_rst     {}          {return \\fR}
proc nr_p       {}          {return \n.PP\n}
proc nr_comment {text}      {return "'\\\" [join [split $text \n] "\n'\\\" "]"} ; # "
proc nr_enum    {num}       {nr_item " \[$num\]"}
proc nr_item    {{text {}}} {return "\n.IP$text"}
proc nr_vspace  {}          {return \n.sp}
proc nr_blt     {text}      {return "\n.TP\n$text"}
proc nr_bltn    {n text}    {return "\n.TP $n\n$text"}
proc nr_in      {}          {return \n.RS}
proc nr_out     {}          {return \n.RE}
proc nr_nofill  {}          {return \n.nf}
proc nr_fill    {}          {return .fi}
proc nr_title   {text}      {return "\n.TH $text"}
proc nr_include {file}      {return "\n.so $file"}
proc nr_bolds   {}          {return \n.BS}
proc nr_bolde   {}          {return \n.BE}

proc nr_section {name}      {return "\n.SH \"$name\""}


################################################################

proc nroff_postprocess {nroff} {
    # Postprocessing final nroff text.
    # - Strip empty lines out of the text
    # - Remove leading and trailing whitespace from lines.
    # - Exceptions to the above: Keep empty lines and leading
    #   whitespace when in verbatim sections (no-fill-mode)

    set nfMode   [list .nf .CS]	; # commands which start no-fill mode
    set fiMode   [list .fi .CE]	; # commands which terminate no-fill mode
    set lines    [list]         ; # Result buffer
    set verbatim 0              ; # Automaton mode/state

    foreach line [split $nroff "\n"] {
	if {!$verbatim} {
	    # Normal lines, not in no-fill mode.

	    if {[lsearch -exact $nfMode [split $line]] >= 0} {
		# no-fill mode starts after this line.
		set verbatim 1
	    }

	    # Ensure that empty lines are not added.
	    # This also removes leading and trailing whitespace.

	    if {![string length $line]} {continue}
	    set line [string trim $line]
	    if {![string length $line]} {continue}
	} else {
	    # No-fill mode. We remove trailing whitespace, but keep
	    # leading whitespace and empty lines.

	    if {[lsearch -exact $fiMode [split $line]] >= 0} {
		# Normal mode resumes after this line.
		set verbatim 0
	    }
	    set line [string trimright $line]
	}
	lappend lines $line
    }
    # Return the modified result buffer
    return [join $lines "\n"]
}
