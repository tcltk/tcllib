package provide inifile 0.1

namespace eval ini {}

proc ::ini::open {ini {mode r+}} {
    ::set fh [::open $ini $mode]
    fconfigure $fh -translation crlf
    array set $fh {}
    _loadfile $fh
    return $fh
}

proc ::ini::close {fh} {
    variable $fh
    commit $fh
    unset $fh
    close $fh
}

# write all changes to disk

proc ::ini::commit {fh} {
    variable $fh
    seek $fh 0 start
    array set s {}
    foreach x [array names $fh] {
        ::set s([lindex [split $x \000] 0]) 1
    }
    foreach sec [array names s] {
        puts $fh "\[$sec\]"
        foreach key [lsort -dictionary [array names $fh $sec\000*]] {
            puts $fh "[lindex [split $key \000] 1]=[::set ${fh}($key)]"
        }
        puts $fh ""
    }
    _loadfile $fh
}

proc ::ini::_loadfile {fh} {
    variable $fh
    ::set cur {}
    seek $fh 0 start
    ::set data [read $fh]
    foreach line [split $data "\n"] {
        if {[string match {\[*\]} $line]} {
            ::set cur [string range $line 1 end-1]
        } elseif {[string match {*=*} $line]} {
            ::set line [split $line =]
            ::set key [lindex $line 0]
            ::set value [join [lrange $line 1 end] =]
            ::set ${fh}($cur\000$key) $value
        }
    }
}

# return all section names

proc ::ini::sections {fh} {
    variable $fh
    array set r {}
    foreach x [array names $fh] {
        ::set r([lindex [split $x \000] 0]) 1
    }
    return [array names r]
}

#return all key names of section

proc ::ini::keys {fh sec} {
    variable $fh
    ::set r {}
    foreach x [array names $fh $sec\000*] {
        lappend r [lindex [split $x \000] 1]
    }
    return $r
}

#return all key value pairs of section

proc ::ini::get {fh sec} {
    variable $fh
    ::set r {}
    foreach x [array names $fh $sec\000*] {
        lappend r [lindex [split $x \000] 1] [::set ${fh}($x)]
    }
    return $r
}

proc ::ini::exists {fh sec {key {}}} {
    variable $fh
    if {$key == ""} {
        if {[array names $fh $sec\000*] == ""} {return 0}
        return 1
    }
    return [info exists ${fh}($sec\000$key)]
}

proc ::ini::value {fh sec key} {
    variable $fh
    return [::set ${fh}($sec\000$key)]
}

proc ::ini::set {fh sec key value} {
    variable $fh
    ::set ${fh}($sec\000$key) $value
}

proc ::ini::delete {fh sec {key {}}} {
    variable $fh
    if {$key == ""} {
        array unset $fh $sec\000$key
    }
    array unset $fh $sec\000*
}
