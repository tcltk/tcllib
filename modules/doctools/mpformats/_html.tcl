# -*- tcl -*-
# Helper rules for the creation of the memchan website from the .exp files.
# General formatting instructions ...

proc state {} [list return [file join [pwd] state]]

proc use_bg {} {
    set c [bgcolor]
    #puts stderr "using $c"
    if {$c == {}} {return ""}
    return bgcolor=$c
}


proc nbsp  {} {return "&nbsp;"}
proc p     {} {return <p>}
proc ptop  {} {return "<p valign=top>"}
proc td    {} {return "<td [use_bg]>"}
proc trtop {} {return "<tr valign=top [use_bg]>"}
proc tr    {} {return "<tr            [use_bg]>"}
proc sect {s} {return "<b>$s</b><br><hr>"}
proc link {text url} {return "<a href=\"$url\">$text</a>"}
proc table  {} {return "<table [border] width=100% cellspacing=0 cellpadding=0>"}
proc btable {} {return "<table border=1 width=100% cellspacing=0 cellpadding=0>"}
proc stable {} {return "<table [border] cellspacing=0 cellpadding=0>"}


proc tcl_cmd {cmd} {return "<b>\[$cmd]</b>"}
proc wget    {url} {exec /usr/bin/wget -q -O - $url 2>/dev/null}

proc url {tag text url} {
    set body {
	switch -exact -- $what {
	    link {return {<a href="%url%">%text%</a>}}
	    text {return {%text%}}
	    url  {return {%url%}}
	}
    }
    proc $tag {{what link}} [string map [list %text% $text %url% $url] $body]
}

proc img {tag alt img} {
    proc $tag {} [list return "<img alt=\"$alt\" src=\"$img\">"]
}

proc protect {text} {return [string map [list & "&amp;" < "&lt;" > "&gt;"] $text]}
