# ini.tcl --
#
#	Querying and modifying old-style windows configuration files (.ini)
#
# Copyright (c) 2003	Aaron Faupell <afaupell@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: ini.tcl,v 1.2 2003/07/05 04:49:16 andreas_kupries Exp $

# The major trick in this package is the usage of the channel handle
# of an open ini file as the name for the variable to store its
# contents. To avoid confusion in what capacity a handle is used we
# use 'upvar 0 $fh data' to alias the data variable to another
# variable with a fixed, and different name, whenever we need it as
# variable. This also makes access easier as we don't have to quote
# around so much.


package provide inifile 0.1

namespace eval ini {}

proc ::ini::open {ini {mode r+}} {
    ::set       fh [::open $ini $mode]
    fconfigure $fh -translation crlf
    array set  $fh {}
    _loadfile  $fh
    return     $fh
}

proc ::ini::close {fh} {
    variable $fh
    upvar 0  $fh data
    commit   $fh
    close    $fh
    unset data
    return
}

# write all changes to disk

proc ::ini::commit {fh} {
    variable $fh
    upvar 0  $fh data

    seek $fh 0 start
    array set s {}
    foreach x [array names data] {
        ::set s([lindex [split $x \000] 0]) 1
    }
    foreach sec [array names s] {
        puts $fh "\[$sec\]"
        foreach key [lsort -dictionary [array names data $sec\000*]] {
            puts $fh "[lindex [split $key \000] 1]=$data($key)"
        }
        puts $fh ""
    }
    # NOTE: Possible bug. Not closing the fh here
    # may cause problems if the written data is
    # less than there was in the file before. As it
    # is done here the old data after the last
    # byte written remains in existence. This can
    # cause bad syntax, causing errors when reading,
    # or even leace data in existence which was
    # supposedly deleted from the file.
    #
    # Closing an reopening the file should do the
    # trick, however this also assumes that the
    # newly opened file gets the same handle as the
    # one we closed. This assumption is wrong in the
    # case of a multi-threaded interpreter, as other
    # threads may create their own files between
    # the commands to close and reopen here.
    #
    # The full solution is to decouple the externally
    # visible handle for the in file from the channel
    # handle.

    _loadfile $fh
    return
}

proc ::ini::_loadfile {fh} {
    variable $fh
    upvar 0  $fh data
    ::set cur {}
    seek $fh 0 start
    foreach line [split [read $fh] "\n"] {
        if {[string match {\[*\]} $line]} {
            ::set cur [string range $line 1 end-1]
        } elseif {[string match {*=*} $line]} {
            ::set line  [split $line =]
            ::set key   [lindex $line 0]
            ::set value [join [lrange $line 1 end] =]
            ::set data($cur\000$key) $value
        }
    }
    return
}

# return all section names

proc ::ini::sections {fh} {
    variable $fh
    upvar 0  $fh data
    array set r {}
    foreach x [array names data] {
        ::set r([lindex [split $x \000] 0]) 1
    }
    return [array names r]
}

# return all key names of section

proc ::ini::keys {fh sec} {
    variable $fh
    upvar 0  $fh data
    ::set r {}
    foreach x [array names data $sec\000*] {
        lappend r [lindex [split $x \000] 1]
    }
    return $r
}

# return all key value pairs of section

proc ::ini::get {fh sec} {
    variable $fh
    upvar 0  $fh $data
    ::set r {}
    foreach x [array names data $sec\000*] {
        lappend r [lindex [split $x \000] 1] $data($x)
    }
    return $r
}

proc ::ini::exists {fh sec {key {}}} {
    variable $fh
    upvar 0  $fh data
    if {$key == ""} {
        if {[array names data $sec\000*] == ""} {return 0}
        return 1
    }
    return [info exists data($sec\000$key)]
}

proc ::ini::value {fh sec key} {
    variable $fh
    upvar 0  $fh data
    return $data($sec\000$key)
}

proc ::ini::set {fh sec key value} {
    variable $fh
    upvar 0  $fh data
    ::set data($sec\000$key) $value
    return
}

proc ::ini::delete {fh sec {key {}}} {
    variable $fh
    upvar 0  $fh data
    if {$key == ""} {
        array unset data $sec\000$key
    }
    array unset data $sec\000*
    return
}
