# -*- tcl -*-
#
# -- nroff commands
#
# Copyright (c) 2003 Andreas Kupries <andreas_kupries@sourceforge.net>


################################################################
# nroff specific commands

proc nr_lp      {}          {return .LP}
proc nr_ta      {{text {}}} {return ".ta$text"}
proc nr_bld     {}          {return \\fB}
proc nr_ul      {}          {return \\fI}
proc nr_rst     {}          {return \\fR}
proc nr_p       {}          {return \n.PP\n}
proc nr_comment {text}      {return "'\\\" [join [split $text \n] "\n'\\\" "]"} ; # "
proc nr_enum    {num}       {nr_item " \[$num\]"}
proc nr_item    {{text {}}} {return ".IP$text"}
proc nr_vspace  {}          {return .sp}
proc nr_blt     {text}      {return "\n.TP\n$text"}
proc nr_bltn    {n text}    {return "\n.TP $n\n$text"}
proc nr_in      {}          {return \n.RS}
proc nr_out     {}          {return \n.RE}
proc nr_nofill  {}          {return .nf}
proc nr_fill    {}          {return .fi}
proc nr_title   {text}      {return ".TH $text"}
proc nr_include {file}      {return ".so $file"}

proc nr_bolds   {}          {return .BS}
proc nr_bolde   {}          {return .BE}

proc nr_section {name}      {return ".SH \"$name\""}


################################################################
