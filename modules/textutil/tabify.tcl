namespace eval ::textutil {

    namespace eval tabify {

	variable StrRepeat [ namespace parent ]::StrRepeat
	variable TabLen  8
	variable TabStr  [ $StrRepeat " " $TabLen ]

	namespace export tabify untabify

	# This will be redefined later. We need it just to let
	# a chance for the next import subcommand to work
	#
	proc tabify   { string { num 8 } } { }
	proc untabify { string { num 8 } } { }

    }

    namespace import -force tabify::tabify tabify::untabify
    namespace export tabify untabify
    
}

########################################################################

proc ::textutil::tabify::tabify { string { num 8 } } {
    
    set str [ MakeTabStr $num ]
    regsub -all $str $string "\t" string
    
    return $string
}

proc ::textutil::tabify::untabify { string { num 8 } } {
    
    set str [ MakeTabStr $num ]
    regsub -all "\t" $string $str string
    
    return $string
}

proc ::textutil::tabify::MakeTabStr { num } {
    variable StrRepeat
    variable TabStr
    variable TabLen

    if { $TabLen != $num } then {
	set TabLen $num
	set TabStr [ $StrRepeat " " $num ]
    }

    return $TabStr
}
