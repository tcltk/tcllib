# jpeg.tcl --
#
#       Querying and modifying JPEG image files.
#
# Copyright (c) 2004    Aaron Faupell <afaupell@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: jpeg.tcl,v 1.2 2004/05/11 06:51:54 andreas_kupries Exp $

package provide jpeg 0.1

namespace eval ::jpeg {}

proc ::jpeg::_isjpg {fh} {
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 3] != "\xFF\xD8\xFF"} { close $fh; return -code error "not a jpg file" }
    seek $fh -1 current
    return $fh
}

proc ::jpeg::getComments {file} {
    set fh [_isjpg [open $file r]]
    set comments {}

    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        if {$type == "\xFE"} {
            lappend comments [read $fh [expr $len - 2]]
        } else {
            seek $fh [expr {$len - 2}] current
        }
    }
    close $fh
    return $comments
}

proc ::jpeg::addComment {file comment} {
    set fh [_isjpg [open $file r+]]
    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        if {$type == "\xC0"} { set sof [tell $fh]; break }
        if {$type == "\xFE"} { set com [tell $fh]; break }
        seek $fh [expr {$len - 2}] current
    }

    set clen [binary format S [expr {[string length $comment] + 2}]]
    if {[info exists com]} {
        seek $fh 0 start
        set data1 [read $fh [expr {$com - 2}]]
        binary scan [read $fh 2] S len
        seek $fh [expr {$len - 2}] current
        set data2 [read $fh]
        close $fh
        set fh [open $file w]
        puts -nonewline $fh $data1$clen$comment$data2
    } elseif {[info exists sof]} {
        seek $fh [expr {$sof - 4}] start
        set data [read $fh]
        seek $fh [expr {$sof - 4}] start
        puts -nonewline $fh "\xFF\xFE$clen$comment$data"
    } else {
        close $fh
        return -code error "no image found"
    }
    close $fh
}

proc ::jpeg::dimensions {file} {
    set fh [_isjpg [open $file r]]

    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len

        if {$type == "\xC0"} {
            binary scan [read $fh 5] cSS precision height width
            close $fh
            return [list $width $height]
        }
        seek $fh [expr {$len - 2}] current
    }
    close $fh
}

proc ::jpeg::imageInfo {file} {
    set fh [_isjpg [open $file r+]]

    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len

        if {$type == "\xE0"} {
            set id [read $fh 5]
            if {$id == "JFIF\x00"} {
                binary scan [read $fh 9] cccSScc ver1 ver2 units xr yr xt yt
                close $fh
                return [list version $ver1.$ver2 units $units xdensity $xr ydensity $yr xthumb $xt ythumb $yt]
            }
            close $fh
            return
        }
        seek $fh [expr {$len - 2}] current
    }
}

proc ::jpeg::thumbnail {file} {
    set fh [_isjpg [open $file r]]

    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        set pos [tell $fh]
        if {$type == "\xE0" && [read $fh 5] == "JFXX\x00"} {
            binary scan [read $fh 1] H2 excode
            if {$excode == "10"} {
                set thumb [read $fh expr {$len - 8}]]
                close $fh
                return $thumb
            }
            break
        }
        if {$type == "\xE1" && [read $fh 6] == "Exif\x00\x00"} {
            binary scan [read $fh 2] H4 a
            if {$a == "4d4d"} {
                set end big
            } elseif {$a == "4949"} {
                set end little
            }
            if {[info exists end]} {
                _scan $end [read $fh 6] si magic next
                if {$magic != 42} continue
                set start [expr {[tell $fh] - 8}]
                seek $fh [expr {$start + $next}] start
                _scan $end [read $fh 2] s num
                seek $fh [expr {$num * 12}] current
                _scan $end [read $fh 4] s next
                if {$next <= 0} break
                seek $fh [expr {$start + $next}] start
                for {_scan $end [read $fh 2] s num} {$num > 0} {incr num -1} {
                    binary scan [read $fh 8] H2H2 t1 t2
                    if {$end == "big"} {
                        set tag $t1$t2
                    } else {
                        set tag $t2$t1
                    }
                    set value [read $fh 4]
                    if {$tag == "0103" || $tag == "0201" || $tag == "0202"} {
                        _scan $end $value i $tag
                    }
                }
                break
            }
        }
        seek $fh [expr {$pos + $len - 2}] start
    }
    if {[info exists 0103] && $0103 == 6 && [info exists 0201] && [info exists 0202]} {
        seek $fh [expr {$start + $0201}] start
        set thumb [read $fh $0202]
        close $fh
        return $thumb
    }
    close $fh
}

proc ::jpeg::exif {file} {
    set fh [_isjpg [open $file r]]
    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        set pos [tell $fh]
        if {$type == "\xE1" && [read $fh 6] == "Exif\x00\x00"} {
            binary scan [read $fh 2] H$ a
            if {$a == "4d4d"} {
                set end big
            } elseif {$a == "4949"} {
                set end little
            }
            if {[info exists end]} {
                _scan $end [read $fh 6] si magic next
                if {$magic != 42} continue
                set start [expr {[tell $fh] - 8}]
                seek $fh [expr {$start + $next}] start
                set exif [_exif $fh $end $start main]
                close $fh
                return $exif
            }
        }
        seek $fh [expr {$pos + $len - 2}] start
    }
    close $fh
    return
}

proc ::jpeg::_debug {file} {
    set fh [_isjpg [open $file r]]

    puts "marker: d8"
    puts "  SOI (Start Of Image)"
    while {[read $fh 1] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        set pos [tell $fh]
        
        binary scan $type H2 type
        puts "marker: $type len: $len"
        
        if {$type == "e0"} {
            set id [read $fh 5]
            if {$id == "JFIF\x00"} {
                puts "  JFIF"
                binary scan [read $fh 9] cccSScc ver1 ver2 units xr vr xt yt
                puts "    Header: $ver1.$ver2 $units $xr $vr $xt $yt"
            } elseif {$id == "JFXX\x00"} {
                puts "  JFXX"
                binary scan [read $fh 1] H2 excode
                puts "    Contains JFXX thumbnail: $excode"
            }
        } elseif {$type == "e1"} {
            #exif
            if {[read $fh 6] == "Exif\x00\x00"} {
                puts "  EXIF data"
                binary scan [read $fh 2] H4 a
                if {$a == "4d4d"} {
                    set end big
                } elseif {$a == "4949"} {
                    set end little
                }
                
                if {[info exists end]} {
                    binary scan [read $fh 6] si magic next
                    if {$magic != 42} continue
                    set start [expr {[tell $fh] - 8}]
                    seek $fh [expr {$start + $next}] start
                    foreach {x y} [_exif $fh $end $start main] {
                        puts "    $x:"
                        foreach {a b} $y {
                            puts "      $a $b"
                        }
                    }
                }
            } else {
                puts "  APP1 (unknown)"
            }
        } elseif {$type == "ed"} {
            if {[read $fh 18] == "Photoshop 3.0\0008BIM"} {
                puts "  Photoshop 8BIM data"
            } else {
                puts "  APP13 (unknown)"
            }
        } elseif {[string match {e[23456789abcef]} $type]} {
            puts [format "  %s%d %s" APP 0x[string index $type 1] (unknown)]
        } elseif {$type == "c0"} {
            binary scan [read $fh 5] cSS precision height width
            puts "  SOF (Start Of Frame)"
            puts "    Image dimensions: $width $height"
        } elseif {$type == "fe"} {
            puts "  Comment: [read $fh [expr $len - 2]]"
        } elseif {$type == "c4"} {
            puts "  DHT (Define Huffman Table)"
        } elseif {$type == "da"} {
            puts "  SOS (Start Of Scan)"
        } elseif {$type == "db"} {
            puts "  DQT (Define Quantization Table)"
        } elseif {$type == "dd"} {
            puts "  DRI (Define Restart Interval)"
        } elseif {$type == "d9"} {
            puts "  EOI (End Of Image)"
        } else {
            puts "  Unknown"
        }
        seek $fh [expr {$pos + $len - 2}] start
    }
}

array set ::jpeg::exif [list formatlen,1 1 formatlen,2 1 formatlen,3 2 formatlen,4 4 formatlen,5 8 formatlen,6 1 formatlen,7 1 formatlen,8 2 formatlen,9 4 formatlen,10 8 formatlen,11 4 formatlen,12 8] 
array set ::jpeg::exif {
    tag,010e ImageDescription
    tag,010f Make
    tag,0110 Model
    tag,0112 Orientation
    tag,011a XResolution
    tag,011b YResolution
    tag,0128 ResolutionUnit
    tag,0131 Software  
    tag,0132 DateTime
    tag,013e WhitePoint
    tag,013f PrimaryChromaticities
    tag,0211 YCbCrCoefficients
    tag,0213 YCbCrPositioning
    tag,0214 ReferenceBlackWhite
    tag,8298 Copyright
    
    tag,829a ExposureTime
    tag,829d FNumber
    tag,8822 ExposureProgram
    tag,8827 ISOSpeedRatings
    tag,9000 ExifVersion  
    tag,9003 DateTimeOriginal
    tag,9004 DateTimeDigitized
    tag,9101 ComponentsConfiguration
    tag,9102 CompressedBitsPerPixel
    tag,9201 ShutterSpeedValue
    tag,9202 ApertureValue
    tag,9203 BrightnessValue
    tag,9204 ExposureBiasValue
    tag,9205 MaxApertureValue
    tag,9206 SubjectDistance
    tag,9207 MeteringMode
    tag,9208 LightSource
    tag,9209 Flash
    tag,920a FocalLength
    tag,927c MakerNote
    tag,9286 UserComment
    tag,9290 SubsecTime
    tag,9291 SubsecTimeOriginal
    tag,9292 SubsecTimeDigitized
    tag,a000 FlashPixVersion
    tag,a001 ColorSpace
    tag,a002 ExifImageWidth
    tag,a003 ExifImageHeight
    tag,a004 RelatedSoundFile
    tag,a005 ExifInteroperabilityOffset
    tag,a20e FocalPlaneXResolution
    tag,a20f FocalPlaneYResolution
    tag,a210 FocalPlaneResolutionUnit
    tag,a215 ExposureIndex
    tag,a217 SensingMethod
    tag,a300 FileSource
    tag,a301 SceneType
    tag,a302 CFAPattern
    
    tag,0100 ImageWidth
    tag,0101 ImageLength
    tag,0102 BitsPerSample
    tag,0103 Compression
    tag,0106 PhotometricInterpretation
    tag,0111 StripOffsets
    tag,0115 SamplesPerPixel
    tag,0116 RowsPerStrip
    tag,0117 StripByteConunts
    tag,011a XResolution
    tag,011b YResolution
    tag,011c PlanarConfiguration
    tag,0128 ResolutionUnit
    tag,0201 JpegIFOffset
    tag,0202 JpegIFByteCount
    tag,0211 YCbCrCoefficients
    tag,0212 YCbCrSubSampling
    tag,0213 YCbCrPositioning
    tag,0214 ReferenceBlackWhite
    
    tag,0001 InteroperabilityIndex
    tag,0002 InteroperabilityVersion
    tag,1000 RelatedImageFileFormat
    tag,1001 RelatedImageWidth
    tag,1001 RelatedImageLength
}

proc ::jpeg::_scan {e v f args} {
     foreach x $args { upvar 1 $x $x }
     if {$e == "big"} {
         eval [list binary scan $v [string map {a A b B h H s S i I} $f]] $args
     } else {
         eval [list binary scan $v $f] $args
     }
}

proc ::jpeg::_format {end value type num} {
    #set t {}
    #upvar tag tag
    #foreach x [split $value {}] {
    #    _scan $end $x H2 a
    #    lappend t $a
    #}
    #puts "$tag $type $num"
    #puts $t

    if {$num > 1 && $type != 2 && $type != 7} {
        variable exif
        set r {}
        for {set i 0} {$i < $num} {incr i} {
            set len $exif(formatlen,$type)
            lappend r [_format $end [string range $value [expr {$len * $i}] [expr {($len * $i) + $len - 1}]] $type 1]
        }
        return [join $r ,]
    }
    switch -exact -- $type {
        1 { _scan $end $value c value }
        2 { set value [string trimright $value \x00] }
        3 { _scan $end $value s value }
        4 { _scan $end $value i value }
        5 {
            _scan $end $value ii n d
            set value "$n/$d"
        }
        6 { _scan $end $value c value }
        8 { _scan $end $value s value }
        9 { _scan $end $value i value }
        10 {
            _scan $end $value ii n d
            set value "$n/$d"
        }
        11 { _scan $end $value i value }
        12 { _scan $end $value w value }
    }
    #puts $value
    return $value
}

proc ::jpeg::_exif {fh end start type} {
    variable exif
    set return {}
    for {_scan $end [read $fh 2] s num} {$num > 0} {incr num -1} {
        binary scan [read $fh 2] H2H2 t1 t2
        _scan $end [read $fh 6] si format components
        if {$end == "big"} {
            set tag $t1$t2
        } else {
            set tag $t2$t1
        }
        set value [read $fh 4]
        if {$tag == "8769" || $tag == "a005"} {
            _scan $end $value i next
            set pos [tell $fh]
            seek $fh [expr {$start + $next}] start
            eval lappend return [lindex [_exif $fh $end $start $tag] 1]
            seek $fh $pos start
        }
        if {![info exists exif(formatlen,$format)]} continue
        if {![info exists exif(tag,$tag)]} continue
        set tag $exif(tag,$tag)
        set size [expr {$exif(formatlen,$format) * $components}]
        if {$size > 4} {
            set pos [tell $fh]
            _scan $end $value i value
            seek $fh [expr {$start + $value}] start
            set value [read $fh $size]
            seek $fh $pos start
        }
        lappend return $tag [_format $end $value $format $components]
    }
    _scan $end [read $fh 4] s next
    set return [list $type $return]
    if {$next != 0} {
        seek $fh [expr {$start + $next}] start
        eval lappend return [_exif $fh $end $start thumbnail]
    }
    return $return
}

