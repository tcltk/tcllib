# stats.tcl --
#
#	Procedures to manage simple counters and histograms.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: stats.tcl,v 1.1 2000/09/19 15:03:39 welch Exp $

package provide stats 1.0

namespace eval stats:: {

    # Variables of name stats::T-$tagname
    # are created as arrays to support each counter.

    # Time-based histograms are kept in sync with each other,
    # so these variables are shared among them.
    # These base times record the time corresponding to the first bucket 
    # of the per-minute, per-hour, and per-day time-based histograms.

    variable startTime
    variable minuteBase
    variable hourBase
    variable hourEnd
    variable dayBase
    variable hourIndex
    variable dayIndex

    # The time-based histogram uses an after event and a list
    # of counters to do mergeing on

    variable tagsToMerge
    if {![info exist tagsToMerge]} {
	set tagsToMerge {}
    }
    variable mergeInterval

    namespace export *
}

# stats::countInit
#
#	Set up a counter.
#
# Arguments:
#	tag	The identifier for the counter.  Pass this to stats::count
#	args	option values pairs that define characteristics of the counter:
#		See the man page for definitons.
#
# Side Effects:
#	Initializes state about a counter.

proc stats::countInit {tag args} {
    upvar #0 stats::T-$tag counter
    if {[info exists counter]} {
	unset counter
    }
    set counter(N) 0	;# Number of samples
    set counter(total) 0
    set counter(type) {}

    # With an empty type the counter is a simple accumulator
    # for which we can compute an average.  Here we loop through
    # the args to determine what additional counter attributes
    # we need to maintain in stats::count

    foreach {option value} $args {
	switch -- $option {
	    -timehist {
		variable tagsToMerge
		variable secsPerMinute
		variable startTime
		variable minuteBase
		variable hourBase
		variable dayBase
		variable hourIndex
		variable dayIndex

		upvar #0 stats::H-$tag histogram

		# Clear the per-minute histogram.

		for {set i 0} {$i < 60} {incr i} {
		    set histogram($i) 0
		}

		# The value associated with -timehist is the number of seconds
		# in each bucket.  Normally this is 60, but for
		# testing, we compress minutes.  The value is limited at
		# 60 because the per-minute buckets are accumulated into
		# per-hour buckets later.

		if {$value == "" || $value == 0 || $value > 60} {
		    set value 60
		}

		# Histogram state variables.
		# All time-base histograms share the same bucket size
		# and starting times to keep them all synchronized.
		# So, we only initialize these parameters once.

		if {![info exist secsPerMinute]} {
		    set secsPerMinute $value

		    set startTime [clock seconds]
		    set hourIndex 0
		    set dayIndex 0

		    # Align the minute base to the start of a minute
		    # The minuteEpoch is used to detect idle hours.
		    # It is moved forward in time as samples are taken.
		    # If it is still empty, there were no samples that "hour".

		    set minuteBase [clock scan [clock format $startTime \
				-format %H:%M]]
		    set minuteEpoch ""

		    # Set up a single timer for the interpreter to merge
		    # any and all time-baesd histograms.
		    # Set up the merge to happen on the "hour".
		    # partialHour is used to handle the case where secsPerMinute < 60

		    set lasthour [clock scan [clock format $startTime \
				-format %H:00]]
		    set partialHour [expr {($startTime - $lasthour) % \
				($secsPerMinute * 60)}]
		    set secs [expr ($secsPerMinute * 60) - ($partialHour)]
		    if {$secs <= $secsPerMinute} {
			set secs [expr ($secsPerMinute * 60)]
		    }

		    # After the first timer, the event occurs once each "hour"

		    set mergeInterval [expr {60 * $secsPerMinute * 1000}]
		    after [expr {$secs * 1000}] [list stats::countMergeHour $mergeInterval]
		}
		if {[lsearch $tagsToMerge $tag] < 0} {
		    lappend tagsToMerge $tag
		}

		# This records the last used slots in order to zero-out the
		# buckets that are skipped during idle periods.

		set counter(lastMinute) -1
	    }
	    -group {
		# Cluster a set of counters with a single total

		upvar #0 stats::G-$tag group
		set counter(group) $value
	    }
	    -lastn {
		# The lastN samples are kept if a vector to form a running average.

		upvar #0 stats::V-$tag vector
		set counter(lastn) $value
		set counter(index) 0
	    }
	    -hist {
		# A value-based histogram with buckets for different values.

		upvar #0 stats::H-$tag histogram
		if {[info exist histogram]} {
		    unset histogram
		}
		set counter(bucketsize) $value
	    }
	    -hist2x {
		upvar #0 stats::H-$tag histogram
		if {[info exist histogram]} {
		    unset histogram
		}
		set counter(bucketsize) $value
		set counter(mult) 2
	    }
	    -hist10x {
		upvar #0 stats::H-$tag histogram
		if {[info exist histogram]} {
		    unset histogram
		}
		set counter(bucketsize) $value
		set counter(mult) 10
	    }
	    default {
		return -code error "Unsupported option $option.\
			Must be -timehist, -lastn, -hist, -hist2x, or -hist10x."
	    }
	}
	if {[string length $option]} {
	    lappend counter(type) $option
	}
    }

    # Instead of supporting a counter that could have multiple attributes,
    # we support a single type to make counting more efficient.

    if {[llength $counter(type)] > 1} {
	return -code error "Multiple type attributes not supported.  Use only one of\
		-timehist, -lastn, -hist, -hist2x, or -hist10x."
    }
    return ""
}

# stats::countReset
#
#	Reset a counter.
#
# Arguments:
#	tag	The identifier for the counter.  Pass this to stats::count
#	args	option values pairs that affect the reset.
#		See the man page for definitons.
#
# Side Effects:
#	Re-Initializes state about a counter.

proc stats::countReset {tag args} {
    upvar #0 stats::T-$tag counter
    set counter(N) 0	;# Number of samples
    set counter(total) 0

    # With an empty type the counter is a simple accumulator
    # for which we can compute an average.  Here we loop through
    # the args to determine what additional counter attributes
    # we need to maintain in stats::count

    switch -- $counter(type) {
	""	{
	    # Simple counter
	    return
	}
	-group {
	    upvar #0 stats::G-$tag vector
	    if {[info exist vector]} {
		unset vector
	    }
	}
	-lastn {
	    upvar #0 stats::V-$tag vector
	    if {[info exist vector]} {
		unset vector
	    }
	    set counter(index) 0
	}
	-hist {
	    upvar #0 stats::H-$tag histogram
	    if {[info exist histogram]} {
		unset histogram
	    }
	}
	-hist10x -
	-hist2x {
	    upvar #0 stats::H-$tag histogram
	    if {[info exist histogram]} {
		unset histogram
	    }
	}
	-timehist {
	    # Too lazy to reset - do nothing
	    return
	}
    }
}

# stats::count
#
#	Accumulate statistics.
#
# Arguments:
#	tag	The counter identifier.
#	delta	The increment amount.  Defaults to 1.
#
# Results:
#	None
#
# Side Effects:
#	Accumlate statistics.

proc stats::count {tag {delta 1} args} {
    upvar #0 stats::T-$tag counter
    set counter(total) [expr {$counter(total) + $delta}]
    incr counter(N)

    # Instead of supporting a counter that could have multiple attributes,
    # we support a single type to make counting a skosh more efficient.

#    foreach option $counter(type) {
	switch -- $counter(type) {
	    ""	{
		# Simple counter
		return
	    }
	    -group {
		upvar #0 stats::G-$tag vector
		set subIndex [lindex $args 0]
		if {![info exists vector($subIndex)]} {
		    set vector($subIndex) 0
		}
		set vector($subIndex) [expr {$vector($subIndex) + $delta}]
	    }
	    -lastn {
		upvar #0 stats::V-$tag vector
		set vector($counter(index)) $delta
		set counter(index) [expr {($counter(index) +1)%$counter(lastn)}]
	    }
	    -hist {
		upvar #0 stats::H-$tag histogram
		set bucket [expr {int($delta / $counter(bucketsize))}]
		if {![info exist histogram($bucket)]} {
		    set histogram($bucket) 0
		}
		incr histogram($bucket)
	    }
	    -hist10x -
	    -hist2x {
		upvar #0 stats::H-$tag histogram
		set bucket 0
		for {set max $counter(bucketsize)} {$delta > $max} \
			{set max [expr {$max * $counter(mult)}]} {
		    incr bucket
		}
		if {![info exist histogram($bucket)]} {
		    set histogram($bucket) 0
		}
		incr histogram($bucket)
	    }
	    -timehist {
		upvar #0 stats::H-$tag histogram
		variable minuteBase
		variable secsPerMinute

		set minute [expr {([clock seconds] - $minuteBase) / $secsPerMinute}]
		if {$minute > 59} {
		    # this occurs while debugging if the process is
		    # stopped at a breakpoint too long.
		    set minute 59
		}

		# Initialize the current bucket and 
		# clear any buckets we've skipped since the last sample.
		
		if {$minute != $counter(lastMinute)} {
		    set histogram($minute) 0
		    for {set i [expr {$counter(lastMinute)+1}]} \
			    {$i < $minute} \
			    {incr i} {
			set histogram($i) 0
		    }
		    set counter(lastMinute) $minute
		}
		incr histogram($minute) $delta
	    }
	}
#   }
    return ""
}

# stats::countGet
#
#	Return statistics.
#
# Arguments:
#	tag	The counter identifier.
#	args	What to get
#
# Results:
#	With no args, just the counter value.
#
# Side Effects:
#	None.

proc stats::countGet {tag {option -total}} {
    upvar #0 stats::T-$tag counter
    switch -- $option {
	-total {
	    return $counter(total)
	}
	-N {
	    return $counter(N)
	}
	-avg {
	    if {$counter(N) == 0} {
		return 0
	    } else {
		return [expr {$counter(total) / double($counter(N))}]
	    }
	}
	-avgn {
	    upvar #0 stats::V-$tag vector
	    set sum 0
	    for {set i 0} {[info exist vector($i)]} {incr i} {
		set sum [expr {$sum + $vector($i)}]
	    }
	    if {$i == 0} {
		return 0
	    } else {
		return [expr {$sum / double($i)}]
	    }
	}
	-hist {
	    upvar #0 stats::H-$tag histogram
	    set result {}
	    foreach x [lsort -integer [array names histogram]] {
		lappend result $x $histogram($x)
	    }
	    return $result
	}
	-histName {
	    return stats::H-$tag
	}
	-histHour {
	    upvar #0 stats::Hour-$tag histogram
	    set result {}
	    foreach x [lsort -integer [array names histogram]] {
		lappend result $x $histogram($x)
	    }
	    return $result
	}
	-histHourName {
	    return stats::Hour-$tag
	}
	-histDay {
	    upvar #0 stats::Day-$tag histogram
	    set result {}
	    foreach x [lsort -integer [array names histogram]] {
		lappend result $x $histogram($x)
	    }
	    return $result
	}
	-histDayName {
	    return stats::Day-$tag
	}
	-all {
	    return [array get counter]
	}
	default {
	    return -code error "Invalid option $option.  Should be -all, -N, -avg, -hist, or -total."
	}
    }
}

# stats::countMergeHour
#
#	Sum the per-minute histogram into the next hourly bucket.
#	On 24-hour boundaries, sum the hourly buckets into the next day bucket.
#	This operates on all time-based histograms.
#
# Arguments:
#	none
#
# Results:
#	none
#
# Side Effects:
#	See description.

proc stats::countMergeHour {interval} {
    variable hourIndex
    variable minuteBase
    variable minuteEpoch
    variable hourBase
    variable tagsToMerge
    variable secsPerMinute

    after $interval [list stats::countMergeHour $interval]
    if {$hourIndex == 0} {
	set hourBase $minuteBase
    }
    set minuteBase [clock seconds]

    foreach tag $tagsToMerge {
	upvar #0 stats::T-$tag counter
	upvar #0 stats::H-$tag histogram
	upvar #0 stats::Hour-$tag hourhist

	# Clear any buckets we've skipped since the last sample.

	for {set i [expr {$counter(lastMinute)+1}]} {$i < 60} {incr i} {
	    set histogram($i) 0
	}
	set counter(lastMinute) -1

	# Accumulate into the next hour bucket.

	set hourhist($hourIndex) 0
	foreach i [array names histogram] {
	    set hourhist($hourIndex) [expr {$hourhist($hourIndex) + $histogram($i)}]
	}
    }
    set hourIndex [expr {($hourIndex + 1) % 24}]
    if {$hourIndex == 0} {
	stats::countMergeDay
    }

}
# stats::countMergeDay
#
#	Sum the per-minute histogram into the next hourly bucket.
#	On 24-hour boundaries, sum the hourly buckets into the next day bucket.
#	This operates on all time-based histograms.
#
# Arguments:
#	none
#
# Results:
#	none
#
# Side Effects:
#	See description.

proc stats::countMergeDay {} {
    variable dayIndex
    variable dayBase
    variable hourBase
    variable tagsToMerge

    # Save the hours histogram into a bucket for the last day
    # counter(day,$day) is the starting time for that day bucket

    if {![info exist dayBase]} {
	set dayBase $hourBase
    }
    foreach tag $tagsToMerge {
	upvar #0 stats::Day-$tag dayhist
	upvar #0 stats::Hour-$tag hourhist
	set dayhist($dayIndex) 0
	for {set i 0} {$i < 24} {incr i} {
	    if {[info exist hourhist($i)]} {
		set dayhist($dayIndex) [expr {$dayhist($dayIndex) + $hourhist($i)}]
	    }
	}
    }
    incr dayIndex
}
# stats::histHtmlDisplay
#
#	Create an html display of the histogram.
#
# Arguments:
#	none
#
# Results:
#	none
#
# Side Effects:
#	See description.

proc stats::histHtmlDisplay {tag args} {
    upvar #0 stats::T-$tag counter
    variable secsPerMinute
    variable minuteBase
    variable hourBase
    variable dayBase
    variable hourIndex
    variable dayIndex

    array set options [list \
	-title	$tag \
	-unit	"" \
	-images	/images \
	-gif	Blue.gif \
	-ongif	Red.gif \
	-max 	-1 \
	-format %.2f
    ]
    array set options $args

    switch -glob -- $options(-unit) {
	min* {
	    upvar #0 stats::H-$tag histogram
	    set histname stats::H-$tag
	    set width 3
	    if {![info exist minuteBase]} {
		return "<!-- No time-based histograms defined -->"
	    }
	    set time $minuteBase
	    set secsForMax $secsPerMinute
	    set curIndex [expr {([clock seconds] - $minuteBase) / $secsPerMinute}]
	}
	hour* {
	    upvar #0 stats::Hour-$tag histogram
	    set histname stats::Hour-$tag
	    set width 5
	    if {![info exist hourBase]} {
		return "<!-- Hour merge has not occurred -->"
	    }
	    set time $hourBase
	    set secsForMax [expr {$secsPerMinute * 60}]
	    set curIndex hourIndex
	}
	day* {
	    upvar #0 stats::Day-$tag histogram
	    set histname stats::Day-$tag
	    set width 5
	    if {![info exist dayBase]} {
		return "<!-- Hour merge has not occurred -->"
	    }
	    set time $dayBase
	    set secsForMax [expr {$secsPerMinute * 60 * 24}]
	    set curIndex dayIndex
	}
	default {
	    # Value-based histogram with arbitrary units.

	    upvar #0 stats::H-$tag histogram
	    set histname stats::H-$tag

	    set unit $options(-unit)
	    set width 4
	    set curIndex ""
	}
    }
    if {! [info exists histogram]} {
	return "<!-- $histname doesn't exist -->\n"
    }

    set total 0
    set max 0
    set base 100
    foreach {name value} [array get histogram] {
	if {$value > $max} {
	    set max $value
	    set maxName $name
	}
    }
    if {[info exists secsForMax]} {

	# Time-base histogram

	append result "<h3>$options(-title) ($counter(total) total,\
		max [format %.2f [expr {$max/double($secsForMax)}]]\
		per second)</h3>"
	append result <ul>
	append result "<h4>Starting at [clock format $time]</h4>"

    } else {

	# Value-base histogram

	set mode [expr {$counter(bucketsize) * $name}]
	append result "<h3>$options(-title), ($unit)\
		[format $options(-format) $mode]\
		mode,\
		[format $options(-format) [countGet $tag -avg]] average\
		</h3>"
	append result <ul>

	# Fill in holes in the histogram.

	set ix [lsort -integer [array names histogram]]
	for {set i [lindex $ix 0]} \
		{($i < [lindex $ix end]) &&
			(($options(-max) < 0) || ($i < $options(-max)))} \
		{incr i} {
	    if {![info exist histogram($i)]} {
		set histogram($i) 0
	    }
	}

    }

    # Display the histogram

    append result "<table cellpadding=0 cellspacing=0><tr>\n"
    append result "<td valign=top>$max</td>\n"
    set overflow 0
    foreach t [lsort -integer [array names histogram]] {
	if {($options(-max) > 0) && ($t > $options(-max))} {
	    incr overflow
	    continue
	}
	set value $histogram($t)
	if {[catch {expr {round($value * 100.0 / $max)}} percent]} {
	    set height 1
	} else {
	    set height [expr {$percent * $base / 100}]
	}
	if {$t == $curIndex} {
	    set img src=$options(-images)/$options(-ongif)
	} else {
	    set img src=$options(-images)/$options(-gif)
	}
	append result "<td valign=bottom><img $img height=$height width=$width alt=$value></td>\n"
    }
    append result "</tr>"

    # Append a row of labels at the bottom.

    switch -glob -- $options(-unit) {
	min*	{#do nothing}
	hour*	{
	    append result "<tr><td> </td>"
	    set lastLabel ""
	    foreach t [lsort -integer [array names histogram]] {

		# Label each bucket with its hour

		set label [clock format $time -format %k]
		if {$label != $lastLabel} {
		    append result "<td><font size=1>$label</font></td>"
		    set lastLabel $label
		} else {
		    append result "<td><font size=1></font></td>"
		}
		incr time [expr $secsPerMinute * 60]
	    }
	    append result </tr>
	}
	day* {
	    append result "<tr><td> </td>"
	    set skip 4
	    set i 0
	    set lastLabel ""
	    foreach t [lsort -integer [array names histogram]] {
		set label [clock format $time -format "%m/%d"]
		if {(($i % $skip) == 0) && ($label != $lastLabel)} {
		    append result "<td colspan=$skip><font size=1>$label</font></td>"
		    set lastLabel $label
		}
		incr time [expr 60 * $secsPerMinute * 24]
		incr i
	    }
	    append result </tr>
	}
	default {
	    foreach t [lsort -integer [array names histogram]] {
		if {($options(-max) > 0) && ($t > $options(-max))} {
		    break
		}

		# Label each bucket with its hour

		set label $t
		append result "<td><font size=1>$label</font></td>"
	    }
	}
    }
    append result "</table>"
    if {$overflow > 0} {
	append result "<br>(skipped $overflow samples > $options(-max))\n"
    }
    append result </ul>
    return $result
}

# stats::countStart
#
#	Start an interval timer.  This should be pre-declared with
#	type either -hist, -hist2x, or -hist20x
#
# Arguments:
#	tag		The counter identifier.
#	instance	There may be multiple intervals outstanding
#			at any time.  This serves to distinquish them.
#
# Results:
#	None
#
# Side Effects:
#	Records the starting time for the instance of this interval.

proc stats::countStart {tag instance} {
    upvar #0 stats::Time-$tag time
    set time($instance) [list [clock clicks] \
	    [clock seconds]]
}

# stats::countStop
#
#	Record an interval timer.
#
# Arguments:
#	tag		The counter identifier.
#	instance	There may be multiple intervals outstanding
#			at any time.  This serves to distinquish them.
#
# Results:
#	None
#
# Side Effects:
#	Computes the current interval and adds it to the histogram.

proc stats::countStop {tag instance} {
    upvar #0 stats::Time-$tag time

    if {![info exist time($instance)]} {
	# Extra call. Ignore so we can debug error cases.
	return
    }
    set now [list [clock clicks] \
	    [clock seconds]]
    set delMicros [expr {[lindex $now 0] - [lindex $time($instance) 0]}]
    set delSecond [expr {[lindex $now 1] - [lindex $time($instance) 1]}]
    unset time($instance)

    if {$delMicros < 0} {
	set delMicros [expr {1000000 + $delMicros}]
	incr delSecond -1
	if {$delSecond < 0} {
	    set delSecond 0
	}
    }
    stats::count $tag $delSecond.[format %06d $delMicros]
}
