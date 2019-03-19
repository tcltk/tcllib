# -*- tcl -*-
# Convert a doctools document into markdown formatted text
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>

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
    set base [ContextNew Itemized {
	set bullet "[WPrefix?]  [IBullet]"
    }] ; # {}

    set first [ContextNew First {
	List! bullet $bullet [set ws "[BlankM $bullet] "]
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
    
    set base [ContextNew Enumerated {
	set bullet "[WPrefix?]  [EBullet]"
    }] ; # {}

    set first [ContextNew First {
	List! bullet $bullet [set ws "[BlankM $bullet] "]
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
    
    set base [ContextNew Definitions {
	set bullet "[WPrefix?]  [IBullet]"
    }] ; # {}

    set term [ContextNew Term {
	List! bullet $bullet [set ws "[BlankM $bullet] "]
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
    set copyright   [c_get_copyright]

    MDComment  "$title - $shortdesc"
    MDComment  [c_provenance]
    MDComment  "[string trimleft $title :]($section) $version $module \"$shortdesc\""
    MDCDone

    Section NAME
    Text "$title - $description"
    CloseParagraph
    return
}

##
# # ## ### ##### ########
return
