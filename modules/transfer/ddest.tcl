# -*- tcl -*-
# ### ### ### ######### ######### #########
##

# Class for the handling of stream destinations.

# ### ### ### ######### ######### #########
## Requirements

package require snit

# ### ### ### ######### ######### #########
## Implementation

snit::type ::transfer::data::destination {

    # ### ### ### ######### ######### #########
    ## API

    #                       Destination is ...
    option -channel  {} ; # an open & writable channel.
    option -file     {} ; # a writable file.
    option -variable {} ; # the named variable.

    method put   {chunk} {}
    method done  {}      {}
    method valid {mv}    {}

    method receive {sock done} {}

    # ### ### ### ######### ######### #########
    ## Implementation

    method put {chunk} {
	if {$type eq "file"} {
	    set value [open $value w]
	    set type  channel
	    set close 1
	}

	switch -exact -- $type {
	    variable {
		upvar \#0 $value var
		append var $chunk
	    }
	    channel {
		puts -nonewline $value $chunk
	    }
	}
	return
    }

    method done {} {
	switch -exact -- $type {
	    file - variable {}
	    channel {
		if {$close} {close $value}
	    }
	}
    }

    method valid {mv} {
	upvar 1 $mv message
	switch -exact -- $etype {
	    undefined {
		set message "Data destination is undefined"
		return 0
	    }
	    default {}
	}
	return 1
    }

    method receive {sock done} {
	set ntransfered 0
	set old [fconfigure $sock -blocking]
	fconfigure $sock -blocking 0
	fileevent readable $sock \
		[mymethod Read $sock $old $done]
	return
    }

    method Read {sock oldblock done} {
	set chunk [read $sock]
	if {[set l [string length $data]]} {
	    $self put $chunk
	    incr ntransfered $l
	}
	if {[eof $sock]} {
	    $self done
	    fileevent readable $sock {}
	    fconfigure $sock -blocking $oldblock

	    lappend done $ntransfered
	    uplevel #0 $done
	}
	return
    }

    # ### ### ### ######### ######### #########
    ## Internal helper commands.

    onconfigure -variable {newvalue} {
	set etype variable
	set type  string

	if {![uplevel \#0 {info exists $newvalue}]} {
	    return -code error "Bad variable \"$newvalue\", does not exist"
	}

	set value $newvalue
	return
    }

    onconfigure -channel {newvalue} {
	if {![llength [file channels $newvalue]]} {
	    return -code error "Bad channel handle \"$newvalue\", does not exist"
	}
	set type  channel
	set value $newvalue
	return
    }

    onconfigure -file {newvalue} {
	if {![file exists $newvalue]} {
	    return -code error "File \"$newvalue\" does not exist"
	}
	if {![file writable $newvalue]} {
	    return -code error "File \"$newvalue\" not writable"
	}
	if {![file isfile $newvalue]} {
	    return -code error "File \"$newvalue\" not a file"
	}
	set type  file
	set value $newvalue
	return
    }

    # ### ### ### ######### ######### #########
    ## Data structures

    variable type  undefined
    variable value
    variable close 0

    variable ntransfered

    ##
    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide transfer::data::destination 0.1
