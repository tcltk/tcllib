namespace eval ::textutil {
	
    namespace eval trim {
    
	variable StrU "\[ \t\]+"
	variable StrR "(${StrU})\$"
	variable StrL "^(${StrU})"

	namespace export trim trimright trimleft

	# This will be redefined later. We need it just to let
	# a chance for the next import subcommand to work
	#
	proc trimleft  { text { trim "[ \t]+" } } { }
	proc trimright { text { trim "[ \t]+" } } { }
	proc trim      { text { trim "[ \t]+" } } { }

    }

    namespace import -force trim::trim trim::trimleft trim::trimright
    namespace export trim trimleft trimright

}

proc ::textutil::trim::trimleft { text { trim "[ \t]+" } } {
    
    set trim "[ MakeStr $trim left ]"
    regsub -line -all -- $trim $text {} text

    return $text
}

proc ::textutil::trim::trimright { text { trim "[ \t]+" } } {
    
    set trim "[ MakeStr $trim right ]"
    regsub -line -all -- $trim $text {} text

    
    return $text
}

proc ::textutil::trim::trim { text { trim "[ \t]+" } } {
    
    set triml "[ MakeStr $trim left ]"
    regsub -line -all -- $triml $text {} text
    set trimr "[ MakeStr $trim right ]"
    regsub -line -all -- $trimr $text {} text
    
    return $text
}

proc ::textutil::trim::MakeStr { string pos }  {
    variable StrU
    variable StrR
    variable StrL

    if { "$string" != "$StrU" } then {
        set StrU $string
        set StrR "(${StrU})\$"
        set StrL "^(${StrU})"
    }

    if { "$pos" == "left" } then {
        return $StrL
    }

    if { "$pos" == "right" } then {
        return $StrR
    }

    error "Panic, illegal position key \"$pos\""
}
