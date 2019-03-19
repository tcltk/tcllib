# -*- tcl -*-
# Convert a doctools document into markdown formatted text
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>

# Note: While markdown is a text format its intended target is HTML,
# making its formatting nearer to that with the ability to set anchors
# and refer to them, linkage in general.

# TODO: Table of contents, section linkage
# TODO: Synopsis command linkage
# TODO: package - xref
# TODO: syscmd - xref
# TODO: cmd - xref
# TODO: term -xref
# TODO: see also, keywords - xref

# # ## ### ##### ######## #############
## Load shared code and modify it to our needs.

dt_source _common.tcl
dt_source _text.tcl
dt_source fmt.text
dt_source _markdown.tcl

rename PostProcess PostProcessT
proc PostProcess {text} {
    string map [list [LB] "  \n"] [PostProcessT $text]
}

proc LB  {} { return "\1\n" }
proc LB. {} { return "\1" }

# # ## ### ##### ########
## Override crucial parts of the regular text formatter

proc In? {} {
    if {![CAttrHas mdindent]} {
	CAttrSet mdindent ""
    }
    CAttrGet mdindent
}
proc In! {ws} {
    CAttrSet mdindent $ws
}

proc NewExample {} {
    return [ContextNew Example {
	VerbatimOn ; Example! ; Prefix! "    "
    }] ; # {}
}

proc NewUnorderedList {} {
    # Itemized list - unordered list - bullet
    # 1. Base context provides indentation.
    # 2. First paragraph in a list item.
    # 3. All other paragraphs.
    ContextPush

    #puts_stderr "UL [CAttrName]"
    #puts_stderr "UL |[string map {{ } _} [In?]]|outer"

    set base [ContextNew Itemized {
	set bullet "[In?]  [IBullet]"
	set ws     "[BlankM $bullet] "
	In! $ws
    }] ; # {}

    #puts_stderr "UL |[string map {{ } _} $bullet]|[string length $bullet]"
    #puts_stderr "UL |[string map {{ } _} $ws]|[string length $ws]"

    set first [ContextNew First {
	List! bullet $bullet $ws
    }] ; ContextSet $base ; # {}

    set next [ContextNew Next {
	WPrefix! $ws
	Prefix!  $ws
    }] ; ContextSet $base ; # {}

    OUL $first $next
    ContextCommit

    ContextPop
    ContextSet $base
    return
}

proc NewOrderedList {} {
    # Ordered list - enumeration - enum
    # 1. Base context provides indentation.
    # 2. First paragraph in a list item.
    # 3. All other paragraphs.
    ContextPush

    #puts_stderr "OL [CAttrName]"
    #puts_stderr "OL |[string map {{ } _} [In?]]|outer"

    set base [ContextNew Enumerated {
	set bullet "[In?]  [EBullet]"
	set ws     "[BlankM $bullet] "
	In! $ws
    }] ; # {}

    #puts_stderr "OL |[string map {{ } _} $bullet]|[string length $bullet]"
    #puts_stderr "OL |[string map {{ } _} $ws]|[string length $ws]"

    set first [ContextNew First {
	List! bullet $bullet $ws
    }] ; ContextSet $base ; # {}

    set next [ContextNew Next {
	WPrefix! $ws
	Prefix!  $ws
    }] ; ContextSet $base ; # {}

    OUL $first $next
    ContextCommit

    ContextPop
    ContextSet $base
    return
}

proc NewDefinitionList {} {
    # Definition list - terms & definitions
    # 1. Base context provides indentation.
    # 2. Term context
    # 3. Definition context
    ContextPush

    # Markdown has no native definition lists. We translate them into
    # itemized lists, rendering the term part as the first paragraph
    # of each entry, and the definition as all following.

    #puts_stderr "DL [CAttrName]"
    #puts_stderr "DL |[string map {{ } _} [In?]]|outer"

    set base [ContextNew Definitions {
	set bullet "[In?]  [IBullet]"
	set ws "[BlankM $bullet] "
	In! $ws
    }] ; # {}

    #puts_stderr "DL |[string map {{ } _} $bullet]|[string length $bullet]"
    #puts_stderr "DL |[string map {{ } _} $ws]|[string length $ws]"

    set term [ContextNew Term {
	List! bullet $bullet $ws
	VerbatimOn
    }] ; ContextSet $base ; # {}

    set def [ContextNew Def {
	WPrefix! $ws
	Prefix!  $ws
    }] ; ContextSet $base ; # {}

    TD $term $def
    ContextCommit

    ContextPop
    ContextSet $base
    return
}

c_pass 1 fmt_usage {cmd args} {c_hold synopsis "[join [linsert $args 0 $cmd] " "][LB.]"}
c_pass 1 fmt_call  {cmd args} {c_hold synopsis "[join [linsert $args 0 $cmd] " "][LB.]"}
c_pass 1 fmt_require {pkg {version {}}} {
    set result "package require $pkg"
    if {$version != {}} {append result " $version"}
    c_hold require "$result  "
    return
}

c_pass 2 fmt_tkoption_def {name dbname dbclass} {
    set    text ""
    append text "Command-Line Switch:\t[fmt_option $name][LB]"
    append text "Database Name:\t[Strong $dbname][LB]"
    append text "Database Class:\t[Strong $dbclass]\n"
    fmt_lst_item $text
}

proc fmt_arg     {text} { Em     $text }
proc fmt_cmd     {text} { Strong $text }
proc fmt_method  {text} { Strong $text }
proc fmt_option  {text} { Strong $text }

proc fmt_uri {text {label {}}} {
    if {$label == {}} { set label $text }
    return "\[$label\]($text)"
}

proc fmt_image {text {label {}}} {
    # text = symbolic name of the image.

    # formatting based on the available data ...

    set img [dt_imgdst $text {png gif jpg}]
    if {$img != {}} {
	if {$label != {}} {
	    return "!\[\]($img \"$label\")"
	} else {
	    return "!\[\]($img)"
	}
    }

    set img [dt_imgdata $text {txt}]
    if {$img != {}} {
	# Show ASCII image like an example (code block => fixed font, no reflow)
	# A label is shown as a pseudo-caption (paragraph after image).
	fmt_example $img
	if {$label != {}} {
	    Text [String "IMAGE: $label"]
	    CloseCurrent
	}
    }

    return $img
}

c_pass 1 fmt_manpage_begin {title section version} NOP
c_pass 2 fmt_manpage_begin {title section version} {
    Off
    set module      [dt_module]
    set shortdesc   [c_get_module]
    set description [c_get_title]

    MDComment  "$title - $shortdesc"
    MDComment  [c_provenance]
    MDComment  "[string trimleft $title :]($section) $version $module \"$shortdesc\""
    MDCDone

    Section NAME
    Text "$title - $description"
    CloseParagraph
    return
}

proc c_get_copyright {} {
    return [join [c_get_copyright_r] [LB]]
}

##
# # ## ### ##### ########
return
