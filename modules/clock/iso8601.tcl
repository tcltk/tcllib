## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## Copyright (c) 2004 Kevin Kenny
## Origin http://wiki.tcl.tk/13094
## Modified for Tcl 8.5 only (eval -> {*}).

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package provide clock::iso8601 0.1

# # ## ### ##### ######## ############# #####################
## API

# iso8601::parse_date --
#
#       Parse an ISO8601 date/time string in an unknown variant.
#
# Parameters:
#       string -- String to parse
#       args -- Arguments as for [clock scan]; may include any of
#               the '-base', '-gmt', '-locale' or '-timezone options.
#
# Results:
#       Returns the given date in seconds from the Posix epoch.

::clock::iso8601::parse_date { string args } {
    variable DatePatterns
    foreach { regex interpretation } $DatePatterns {
	if { [regexp "^$regex\$" $string] } {
	    return [clock scan $string -format $interpretation {*}$args]
	}
    }
    return -code error "not an iso8601 date string"
}

# iso8601::parse_time --
#
#       Parse a point-in-time in ISO8601 format
#
# Parameters:
#       string -- String to parse
#       args -- Arguments as for [clock scan]; may include any of
#               the '-base', '-gmt', '-locale' or '-timezone options.
#
# Results:
#       Returns the given time in seconds from the Posix epoch.

::clock::iso8601::parse_time { timeString args } {
    variable DatePatterns
    MatchTime $timeString field
    set pattern {}
    foreach {regex interpretation} $DatePatterns {
	if { $field($interpretation) ne {} } {
	    append pattern $interpretation
	}
    }
    append pattern $field(T)
    if { $field(%H) ne {} } {
	append pattern %H $field(Hcolon)
	if { $field(%M) ne {} } {
	    append pattern %M $field(Mcolon)
	    if { $field(%S) ne {} } {
		append pattern %S
	    }
	}
    }
    if { $field(%Z) ne {} } {
	append pattern %Z
    }

    return [clock scan $timeString -format $pattern {*}$args]
}

# # ## ### ##### ######## ############# #####################
## State

namespace eval ::clock::iso8601 {

    namespace export parse_date parse_time
    namespace ensemble create

    # Enumerate the patterns that we recognize for an ISO8601 date as both
    # the regexp patterns that match them and the [clock] patterns that scan
    # them.

    variable DatePatterns {
	{\d\d\d\d-\d\d-\d\d}            {%Y-%m-%d}
	{\d\d\d\d\d\d\d\d}              {%Y%m%d}
	{\d\d\d\d-\d\d\d}               {%Y-%j}
	{\d\d\d\d\d\d\d}                {%Y%j}
	{\d\d-\d\d-\d\d}                {%y-%m-%d}
	{\d\d\d\d\d\d}                  {%y%m%d}
	{\d\d-\d\d\d}                   {%y-%j}
	{\d\d\d\d\d}                    {%y%j}
	{--\d\d-\d\d}                   {--%m-%d}
	{--\d\d\d\d}                    {--%m%d}
	{--\d\d\d}                      {--%j}
	{---\d\d}                       {---%d}
	{\d\d\d\d-W\d\d-\d}             {%G-W%V-%u}
	{\d\d\d\dW\d\d\d}               {%GW%V%u}
	{\d\d-W\d\d-\d}                 {%g-W%V-%u}
	{\d\dW\d\d\d}                   {%gW%V%u}
	{-W\d\d-\d}                     {-W%V-%u}
	{-W\d\d\d}                      {-W%V%u}
	{-W-\d}                         {%u}
    }
}

# # ## ### ##### ######## ############# #####################
## Initialization

apply {{} {
    # MatchTime -- (constructed procedure)
    #
    #   Match an ISO8601 date/time string and indicate how it matched.
    #
    # Parameters:
    #   string -- String to match.
    #   fieldArray -- Name of an array in caller's scope that will receive
    #                 parsed fields of the time.
    #
    # Results:
    #   Returns 1 if the time was scanned successfully, 0 otherwise.
    #
    # Side effects:
    #   Initializes the field array.  The keys that are significant:
    #           - Any date pattern in 'DatePatterns' indicates that the
    #             corresponding value, if non-empty, contains a date string
    #             in the given format.
    #           - The patterns T, Hcolon, and Mcolon indicate a literal
    #             T preceding the time, a colon following the hour, or
    #             a colon following the minute.
    #           - %H, %M, %S, and %Z indicate the presence of the
    #             corresponding parts of the time.

    variable DatePatterns

    set cmd {regexp -expanded -nocase -- {PATTERN} $timeString ->}
    set re \(?:\(?:
    set sep {}
    foreach {regex interpretation} $DatePatterns {
	append re $sep \( $regex \)
	append cmd " " [list field($interpretation)]
	set sep |
    }
    append re \) {(T|[[:space:]]+)} \)?
    append cmd { field(T)}
    append re {(\d\d)(?:(:?)(\d\d)(?:(:?)(\d\d)))}
    append cmd { field(%H) field(Hcolon) } \
	{field(%M) field(Mcolon) field(%S)}
    append re {[[:space:]]*(Z|[-+]\d\d\d\d)?}
    append cmd { field(%Z)}
    set cmd [string map [list {{PATTERN}} [list $re]] \
		 $cmd]

    proc MatchTime { timeString fieldArray } "
             upvar 1 \$fieldArray field
             $cmd
         "
} ::clock::iso8601}

# # ## ### ##### ######## ############# #####################

return
# Usage examples, disabled.

if { [info exists ::argv0] && ( $::argv0 eq [info script] ) } {
    puts "::clock::iso8601::parse_date"
    puts [::clock::iso8601::parse_date 1970-01-02 -timezone :UTC]
    puts [::clock::iso8601::parse_date 1970-W01-5 -timezone :UTC]
    puts [time {::clock::iso8601::parse_date 1970-01-02 -timezone :UTC} 1000]
    puts [time {::clock::iso8601::parse_date 1970-W01-5 -timezone :UTC} 1000]
    puts "::clock::iso8601::parse_time"
    puts [clock format [::clock::iso8601::parse_time 2004-W33-2T18:52:24Z] \
	      -format {%X %x %z} -locale system]
    puts [clock format [::clock::iso8601::parse_time 18:52:24Z] \
	      -format {%X %x %z} -locale system]
    puts [time {::clock::iso8601::parse_time 2004-W33-2T18:52:24Z} 1000]
    puts [time {::clock::iso8601::parse_time 18:52:24Z} 1000]
}
