# -*- tcl -*-
# checker.tcl
#
# Code used inside of a checker interpreter to ensure correct usage of
# doctools formatting commands.
#
# Copyright (c) 2003 Andreas Kupries <andreas_kupries@sourceforge.net>
# Copyright (c) 2004 Andreas Kupries <andreas_kupries@sourceforge.net>

# L10N

package require msgcat

proc ::msgcat::mcunknown {locale code} {
    return "unknown error code \"$code\" (for locale $locale)"
}

if {0} {
    puts stderr "Locale [::msgcat::mcpreferences]"
    foreach path [dt_search] {
	puts stderr "Catalogs: [::msgcat::mcload $path] - $path"
    }
} else {
    foreach path [dt_search] {
	::msgcat::mcload $path
    }
}

# State, and checker commands.
# -------------------------------------------------------------
#
# Note that the code below assumes that a command XXX provided by the
# formatter engine is accessible under the name 'fmt_XXX'.
#
# -------------------------------------------------------------

global state lstctx lstitem

# --------------+-----------------------+----------------------
# state		| allowed commands	| new state (if any)
# --------------+-----------------------+----------------------
# all except	| arg cmd opt comment	|
#  for "done"	| syscmd method option	|
#		| widget fun type class	|
#		| package var file uri	|
#		| strong emph namespace	|
# --------------+-----------------------+----------------------
# manpage_begin	| manpage_begin		| header
# --------------+-----------------------+----------------------
# header	| moddesc titledesc	| header
#		| copyright keywords	|
#		| require see_also	|
#		+-----------------------+-----------
#		| description		| body
# --------------+-----------------------+----------------------
# body		| section para list_end	| body
#		| list_begin lst_item	|
#		| call bullet usage nl	|
#		| example see_also	|
#		| keywords sectref enum	|
#		| arg_def cmd_def	|
#		| opt_def tkoption_def	|
#		| subsection		|
#		+-----------------------+-----------
#		| example_begin		| example
#		+-----------------------+-----------
#		| manpage_end		| done
# --------------+-----------------------+----------------------
# example	| example_end		| body
# --------------+-----------------------+----------------------
# done		|			|
# --------------+-----------------------+----------------------
#
# Additional checks
# --------------------------------------+----------------------
# list_begin/list_end			| Are allowed to nest.
# --------------------------------------+----------------------
#	section				| Not allowed in list context
#
#	arg_def				| Only in 'argument list'.
#	cmd_def				| Only in 'command list'.
#	nl para				| Only in list item context.
#	opt_def				| Only in 'option list'.
#	tkoption_def			| Only in 'tkoption list'.
# 	def/call			| Only in 'definition list'.
# 	enum				| Only in 'enum list'.
# 	item/bullet			| Only in 'bullet list'.
# --------------------------------------+----------------------

# -------------------------------------------------------------
# Helpers
proc Error {code {text {}}} {
    global state lstctx lstitem

    # Problematic command with all arguments (we strip the "ck_" prefix!)
    # -*- future -*- count lines of input, maintain history buffer, use
    # -*- future -*- that to provide some context here.

    set cmd  [lindex [info level 1] 0]
    set args [lrange [info level 1] 1 end]
    if {$args != {}} {append cmd " [join $args]"}

    # Use a message catalog to map the error code into a legible message.
    set msg [::msgcat::mc $code]

    if {$text != {}} {
	set msg [string map [list @ $text] $msg]
    }
    dt_error "Manpage error ($code), \"$cmd\" : ${msg}."
    return
}
proc Warn {code args} {
    set msg [::msgcat::mc $code]
    foreach {off line col} [dt_where] break
    set msg [eval [linsert $args 0 format $msg]]
    set msg "In macro at line $line, column $col:\n$msg"
    set msg [split $msg \n]
    set prefix "DocTools Warning ($code): "
    dt_warning "$prefix[join $msg "\n$prefix"]"
    return
}

proc Is    {s} {global state ; return [string equal $state $s]}
proc IsNot {s} {global state ; return [expr {![string equal $state $s]}]}
proc Go    {s} {Log " >>\[$s\]" ; global state ; set state $s; return}
proc LPush {l} {
    global lstctx lstitem
    set    lstctx [linsert $lstctx 0 $l $lstitem]
    return
}
proc LPop {} {
    global lstctx lstitem
    set    lstitem [lindex $lstctx 1]
    set    lstctx  [lrange $lstctx 2 end]
    return
}
proc LSItem {} {global lstitem ; set lstitem 1}
proc LIs  {l} {global lstctx ; string equal $l [lindex $lstctx 0]}
proc LItem {} {global lstitem ; return $lstitem}
proc LNest {} {
    global lstctx
    expr {[llength $lstctx] / 2}
}
proc LOpen {} {
    global lstctx
    expr {$lstctx != {}}
}
global    lmap ldmap
array set lmap {
    bullet   itemized    item     itemized
    arg      arguments   args     arguments
    opt      options     opts     options
    cmd      commands    cmds     commands
    enum     enumerated  tkoption tkoptions
}
array set ldmap {
    bullet   . arg . cmd . tkoption . opt .
}
proc LMap {what} {
    global lmap ldmap
    if {![info exists lmap($what)]} {
	return $what
    }
    if {[dt_deprecated] && [info exists ldmap($what)]} {
	Warn depr_ltype $what $lmap($what)
    }
    return $lmap($what)
}
proc LValid {what} {
    switch -exact -- $what {
	arguments   -
	commands    -
	definitions -
	enumerated  -
	itemized    -
	options     -
	tkoptions   {return 1}
	default     {return 0}
    }
}

proc State {} {global state ; return $state}
proc Enter {cmd} {Log "\[[State]\] $cmd"}

#proc Log* {text} {puts -nonewline $text}
#proc Log  {text} {puts            $text}
proc Log* {text} {}
proc Log  {text} {}


# -------------------------------------------------------------
# Framing
proc ck_initialize {} {
    global state   ; set state manpage_begin
    global lstctx  ; set lstctx [list]
    global lstitem ; set lstitem 0
    global sect    ; catch {unset sect} ; set sect() . ; unset sect()
    return
}
proc ck_complete {} {
    if {[Is done]} {
	if {![LOpen]} {
	    return
	} else {
	    Error end/open/list
	}
    } elseif {[Is example]} {
	Error end/open/example
    } else {
	Error end/open/mp
    }
    return
}
# -------------------------------------------------------------
# Plain text
proc plain_text {text} {
    # Only in body, not between list_begin and first item.
    # Ignore everything which is only whitespace ...

    set redux [string map [list " " "" "\t" "" "\n" ""] $text]
    if {$redux == {}} {return [fmt_plain_text $text]}
    if {[IsNot body] && [IsNot example]} {Error body}
    if {[LOpen] && ![LItem]} {Error nolisttxt}
    return [fmt_plain_text $text]
}

# -------------------------------------------------------------
# Variable handling ...

proc vset {var args} {
    switch -exact -- [llength $args] {
	0 {
	    # Retrieve contents of variable VAR
	    upvar #0 __$var data
	    return $data
	}
	1 {
	    # Set contents of variable VAR
	    global __$var
	    set    __$var [lindex $args 0]
	    return "" ; # Empty string ! Nothing for output.
	}
	default {
	    return -code error "wrong#args: set var ?value?"
	}
    }
}

# -------------------------------------------------------------
# Formatting commands
proc manpage_begin {title section version} {
    Enter manpage_begin
    if {[IsNot manpage_begin]} {Error mpbegin}
    Go header
    fmt_manpage_begin $title $section $version
}
proc moddesc {desc} {
    Enter moddesc
    if {[IsNot header]} {Error hdrcmd}
    fmt_moddesc $desc
}
proc titledesc {desc} {
    Enter titledesc
    if {[IsNot header]} {Error hdrcmd}
    fmt_titledesc $desc
}
proc copyright {text} {
    Enter copyright
    if {[IsNot header]} {Error hdrcmd}
    fmt_copyright $text
}
proc manpage_end {} {
    Enter manpage_end
    if {[IsNot body]} {Error bodycmd}
    Go done
    fmt_manpage_end
}
proc require {pkg {version {}}} {
    Enter require
    if {[IsNot header]} {Error reqcmd}
    fmt_require $pkg $version
}
proc description {} {
    Enter description
    if {[IsNot header]} {Error reqcmd}
    Go body
    fmt_description
}

global sect
proc __sid {name} {
    # Identical to 'c_sectionId' in mpformats/_common.tcl
    regsub -all {[ 	]+} [string tolower [string trim $name]] _ id
    regsub -all {"} $id _ id ; # "
    return $id
}

proc section {name} {
    global sect

    Enter section
    if {[IsNot body]} {Error bodycmd}
    if {[LOpen]}      {Error nolistcmd}

    set sid [__sid $name]
    if {[info exists sect($sid)]} {
	Warn sectambig $name
    }
    set sect($sid) .

    fmt_section $name
}
proc subsection {name} {
    global sect

    Enter subsection
    if {[IsNot body]} {Error bodycmd}
    if {[LOpen]}      {Error nolistcmd}

    set sid [__sid $name]
    if {[info exists sect($sid)]} {
	Warn sectambig $name
    }
    set sect($sid) .

    fmt_subsection $name
}
proc para {} {
    Enter para
    if {[IsNot body]} {Error bodycmd}
    if {[LOpen]}      {
	if {![LItem]} {Error nolisthdr}
	fmt_nl
    } else {
	fmt_para
    }
}
proc list_begin {what {hint {}}} {
    Enter "list_begin $what $hint"
    if {[IsNot body]}        {Error bodycmd}
    if {[LOpen] && ![LItem]} {Error nolisthdr}
    set what [LMap $what]
    if {![LValid $what]}     {Error invalidlist $what}
    LPush        $what
    fmt_list_begin $what $hint
}
proc list_end {} {
    Enter list_end
    if {[IsNot body]} {Error bodycmd}
    if {![LOpen]}     {Error listcmd}
    LPop
    fmt_list_end
}

# Deprecated command, and its common misspellings. Canon is 'def'.
proc lst_item {{text {}}} {
    if {[dt_deprecated]} {Warn depr_lstitem "\[lst_item\]"}
    def $text
}
proc list_item {{text {}}} {
    if {[dt_deprecated]} {Warn depr_lstitem "\[list_item\]"}
    def $text
}
proc listitem  {{text {}}} {
    if {[dt_deprecated]} {Warn depr_lstitem "\[listitem\]"}
    def $text
}
proc lstitem   {{text {}}} {
    if {[dt_deprecated]} {Warn depr_lstitem "\[lstitem\]"}
    def $text
}
proc def {{text {}}} {
    Enter def
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs definitions]} {Error deflist}
    LSItem
    fmt_lst_item $text
}
proc arg_def {type name {mode {}}} {
    Enter arg_def
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs arguments]}   {Error arg_list}
    LSItem
    fmt_arg_def $type $name $mode
}
proc cmd_def {command} {
    Enter cmd_def
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs commands]}    {Error cmd_list}
    LSItem
    fmt_cmd_def $command
}
proc opt_def {name {arg {}}} {
    Enter opt_def
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs options]}     {Error opt_list}
    LSItem
    fmt_opt_def $name $arg
}
proc tkoption_def {name dbname dbclass} {
    Enter tkoption_def
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs tkoptions]}   {Error tkoption_list}
    LSItem
    fmt_tkoption_def $name $dbname $dbclass
}
proc call {cmd args} {
    Enter call
    if {[IsNot body]}       {Error bodycmd}
    if {![LOpen]}           {Error listcmd}
    if {![LIs definitions]} {Error deflist}
    LSItem
    eval [linsert $args 0 fmt_call $cmd]
}
# Deprecated. Use 'item'
proc bullet {} {
    if {[dt_deprecated]} {Warn depr_bullet "\[bullet\]"}
    item
}
proc item {} {
    Enter item
    if {[IsNot body]}    {Error bodycmd}
    if {![LOpen]}        {Error listcmd}
    if {![LIs itemized]} {Error bulletlist}
    LSItem
    fmt_bullet
}
proc enum {} {
    Enter enum
    if {[IsNot body]}      {Error bodycmd}
    if {![LOpen]}          {Error listcmd}
    if {![LIs enumerated]} {Error enumlist}
    LSItem
    fmt_enum
}
proc example {code} {
    Enter example
    return [example_begin][plain_text ${code}][example_end]
}
proc example_begin {} {
    Enter example_begin
    if {[IsNot body]}        {Error bodycmd}
    if {[LOpen] && ![LItem]} {Error nolisthdr}
    Go example
    fmt_example_begin
}
proc example_end {} {
    Enter example_end
    if {[IsNot example]} {Error examplecmd}
    Go body
    fmt_example_end
}
proc see_also {args} {
    Enter see_also
    if {[Is done]} {Error nodonecmd}
    # if {[IsNot body]} {Error bodycmd}
    # if {[LOpen]}      {Error nolistcmd}
    eval [linsert $args 0 fmt_see_also]
}
proc keywords {args} {
    Enter keywords
    if {[Is done]} {Error nodonecmd}
    # if {[IsNot body]} {Error bodycmd}
    # if {[LOpen]}      {Error nolistcmd}
    eval [linsert $args 0 fmt_keywords]
}
# nl - Deprecated
proc nl {} {
    if {[dt_deprecated]} {Warn depr_nl "\[nl\]"}
    para
}
proc emph {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_emph $text
}
# strong - Deprecated
proc strong {text} {
    if {[dt_deprecated]} {Warn depr_strong "\[strong\]"}
    emph $text
}
proc arg {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_arg $text
}
proc cmd {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_cmd $text
}
proc opt {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_opt $text
}
proc comment {text} {
    if {[Is done]} {Error nodonecmd}
    return ; #fmt_comment $text
}
proc sectref {name {label {}}} {
    if {[IsNot body]}        {Error bodycmd}
    if {[LOpen] && ![LItem]} {Error nolisthdr}
    if {![string length $label]} {set label $name}
    fmt_sectref $name $label
}
proc syscmd {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_syscmd $text
}
proc method {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_method $text
}
proc option {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_option $text
}
proc widget {text} {
    if {[Is done]} {Error nodonecmd}
    widget $text
}
proc fun {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_fun $text
}
proc type {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_type $text
}
proc package {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_package $text
}
proc class {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_class $text
}
proc var {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_var $text
}
proc file {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_file $text
}

# Special case: We must not overwrite the builtin namespace command,
# as it is required by the package "msgcat".
proc _namespace {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_namespace $text
}
proc uri {text {label {}}} {
    if {[Is done]} {Error nodonecmd}
    # The label argument is left out when undefined so that we can
    # control old formatters as well, if the input is not using uri
    # labels.

    if {$label == {}} {
	fmt_uri $text
    } else {
	fmt_uri $text $label
    }
}
proc usage {args} {
    if {[Is done]} {Error nodonecmd}
    eval fmt_usage $args
}
proc const {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_const $text
}
proc term {text} {
    if {[Is done]} {Error nodonecmd}
    fmt_term $text
}

# -------------------------------------------------------------
