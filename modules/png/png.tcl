package provide png 0.1
package require crc32

namespace eval ::png {}

proc ::png::validate {file} {
    set fh [open $file r]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return SIG }
    set num 0
    set idat 0
    set last {}

    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        if {$len < 0} { close $fh; return BADLEN }
        set r [read $fh $len]
        binary scan [read $fh 4] I crc
        if {[eof $fh]} { close $fh; return EOF }
        if {$num == 0 && $type != "IHDR"} { close $fh; return NOHDR }
        if {$type == "IDAT"} { set idat 1 }
        if {[::crc::crc32 $type$r] != $crc} { close $fh; return CKSUM }
        set last $type
        incr num
    }
    close $fh
    if {!$idat} { return NODATA }
    if {$last != "IEND"} { return NOEND }
    return OK
}

proc ::png::imageInfo {file} {
    set fh [open $file r]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }
    binary scan [read $fh 8] Ia4 len type
    set r [read $fh $len]
    if {![eof $fh] && $type == "IHDR"} {
        binary scan $r IIccccc width height depth color compression filter interlace
	binary scan [read $fh 4] I check
	if {[::crc::crc32 IHDR$r] != $check} {
	    return -code error "header checksum failed"
	}
        close $fh
        return [list width $width height $height depth $depth color $color \
		compression $compression filter $filter interlace $interlace]
    }
    close $fh
    return
}

proc ::png::getTimestamp {file} {
    set fh [open $file r]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }

    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        if {$type == "tIME"} {
            set r [read $fh [expr {$len + 4}]]
            binary scan $r Sccccc year month day hour minute second
            close $fh
            return [clock scan "$month/$day/$year $hour:$minute:$second"]
        }
        seek $fh [expr {$len + 4}] current
    }
    close $fh
    return
}

proc ::png::setTimestamp {file time} {
    set fh [open $file r+]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }

    set    time [eval binary format Sccccc [string map {" 0" " "} [clock format $time -format "%Y %m %d %H %M %S" -gmt 1]]]
    append time [binary format I [::crc::crc32 tIME$time]]

    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        if {[eof $fh]} { close $fh; return }
        if {$type == "tIME"} {
            seek $fh 0 current
            puts -nonewline $fh $time
            close $fh
            return
        }
        if {$type == "IDAT" && ![info exists idat]} { set idat [expr {[tell $fh] - 8}] }
        seek $fh [expr {$len + 4}] current
    }
    if {![info exists idat]} { close $fh; return -code error "no timestamp or data chunk found" }
    seek $fh $idat start
    set data [read $fh]
    seek $fh $idat start
    puts -nonewline $fh [binary format I 7]tIME$time$data
    close $fh
    return
}

proc ::png::getComments {file} {
    set fh [open $file r]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }
    set text {}

    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        set pos [tell $fh]
        if {$type == "tEXt"} {
            set r [read $fh $len]
            lappend text [split $r \x00]
        } elseif {$type == "iTXt"} {
            set r [read $fh $len]
            set keyword [lindex [split $r \x00] 0]
            set r [string range $r [expr {[string length $keyword] + 1}] end]
            binary scan $r cc comp method
            if {$comp == 0} {
                lappend text [linsert [split [string range $r 2 end] \x00] 0 $keyword]
            }
        }
        seek $fh [expr {$pos + $len + 4}] start
    }
    close $fh
    return $text
}

proc ::png::removeComments {file} {
    set fh [open $file r+]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }
    set data "\x89PNG\r\n\x1a\n"
    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        if {$type == "zTXt" || $type == "iTXt" || $type == "tEXt"} {
            seek $fh [expr {$len + 4}] current
        } else {
            seek $fh -8 current
            append data [read $fh [expr {$len + 12}]]
        }
    }
    close $fh
    set fh [open $file w]
    puts -nonewline $fh $data
    close $fh
}

proc ::png::addComment {file keyword arg1 args} {
    if {[llength $args] > 0 && [llength $args] != 2} { close $fh; return -code error "wrong number of arguments" }
    set fh [open $file r+]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 8] != "\x89PNG\r\n\x1a\n"} { close $fh; return -code error "not a png file" }

    if {[llength $args] > 0} {
        set comment "iTXt$keyword\x00\x00\x00$arg1\x00[encoding convertto utf-8 [lindex $args 0]]\x00[encoding convertto utf-8 [lindex $args 1]]"
    } else {
        set comment "tEXt$keyword\x00$arg1"
    }

    append comment [binary format I [::crc::crc32 $comment]]

    while {[set r [read $fh 8]] != ""} {
        binary scan $r Ia4 len type
        if {$type ==  "IDAT"} {
            seek $fh -8 current
            set pos [tell $fh]
            set data [read $fh]
            seek $fh $pos start
            set 1 [tell $fh]
            puts -nonewline $fh $comment
            set clen [binary format I [expr {[tell $fh] - $1 - 8}]]
            seek $fh $pos start
            puts -nonewline $fh $clen$comment$data
            close $fh
            return
        }
        seek $fh [expr {$len + 4}] current
    }
    close $fh
    return -code error "no data chunk found"
}

