# -*- tcl -*-
# Helper rules for the creation of the memchan website from the .exp files.
# General formatting instructions ...

# htmlEscape text --
#	Replaces HTML markup characters in $text with the
#	appropriate entity references.
#

global textMap;
set    textMap {
    &    &amp;    <    &lt;     >    &gt;       
    \xa0 &nbsp;   \xb0 &deg;    \xc0 &Agrave; \xd0 &ETH;    \xe0 &agrave; \xf0 &eth;
    \xa1 &iexcl;  \xb1 &plusmn; \xc1 &Aacute; \xd1 &Ntilde; \xe1 &aacute; \xf1 &ntilde;
    \xa2 &cent;	  \xb2 &sup2;   \xc2 &Acirc;  \xd2 &Ograve; \xe2 &acirc;  \xf2 &ograve;
    \xa3 &pound;  \xb3 &sup3;   \xc3 &Atilde; \xd3 &Oacute; \xe3 &atilde; \xf3 &oacute;
    \xa4 &curren; \xb4 &acute;  \xc4 &Auml;   \xd4 &Ocirc;  \xe4 &auml;   \xf4 &ocirc;
    \xa5 &yen;	  \xb5 &micro;  \xc5 &Aring;  \xd5 &Otilde; \xe5 &aring;  \xf5 &otilde;
    \xa6 &brvbar; \xb6 &para;   \xc6 &AElig;  \xd6 &Ouml;   \xe6 &aelig;  \xf6 &ouml;
    \xa7 &sect;	  \xb7 &middot; \xc7 &Ccedil; \xd7 &times;  \xe7 &ccedil; \xf7 &divide;
    \xa8 &uml;	  \xb8 &cedil;  \xc8 &Egrave; \xd8 &Oslash; \xe8 &egrave; \xf8 &oslash;
    \xa9 &copy;	  \xb9 &sup1;   \xc9 &Eacute; \xd9 &Ugrave; \xe9 &eacute; \xf9 &ugrave;
    \xaa &ordf;	  \xba &ordm;   \xca &Ecirc;  \xda &Uacute; \xea &ecirc;  \xfa &uacute;
    \xab &laquo;  \xbb &raquo;  \xcb &Euml;   \xdb &Ucirc;  \xeb &euml;   \xfb &ucirc;
    \xac &not;	  \xbc &frac14; \xcc &Igrave; \xdc &Uuml;   \xec &igrave; \xfc &uuml;
    \xad &shy;	  \xbd &frac12; \xcd &Iacute; \xdd &Yacute; \xed &iacute; \xfd &yacute;
    \xae &reg;	  \xbe &frac34; \xce &Icirc;  \xde &THORN;  \xee &icirc;  \xfe &thorn;
    \xaf &hibar;  \xbf &iquest; \xcf &Iuml;   \xdf &szlig;  \xef &iuml;   \xff &yuml;
    {"} &quot;
} ; # " make the emacs highlighting code happy.

proc htmlEscape {text} {
    global textMap
    return [string map $textMap $text]
}



# Called to handle plain text from the input
proc HandleText {text} {
    # TODO: Proper definition of mapping special characters to their HTML escape codes.
    # Incomplete.

    return [htmlEscape $text]
}

proc state {} [list return [__file join [pwd] state]]

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


proc tag  {t} {return <$t>}
proc taga {t av} {
    # av = attribute value ...
    set avt [list]
    foreach {a v} $av {lappend avt "$a=\"$v\""}
    return "<$t [join $avt]>"
}
proc tag/ {t} {return </$t>}
proc tag_ {t block args} {
    # args = key value ...
    if {$args == {}} {return "[tag $t]$block[tag/ $t]"}
    return "[taga $t $args]$block[tag/ $t]"
}


proc ht_comment {text}   {return "<! -- $text -->"}
