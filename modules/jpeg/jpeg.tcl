# jpeg.tcl --
#
#       Querying and modifying JPEG image files.
#
# Copyright (c) 2004    Aaron Faupell <afaupell@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: jpeg.tcl,v 1.4 2004/05/27 15:02:11 afaupell Exp $

package provide jpeg 0.1

namespace eval ::jpeg {}

proc ::jpeg::openJFIF {file {mode r}} {
    set fh [open $file $mode]
    fconfigure $fh -encoding binary -translation binary -eofchar {}
    if {[read $fh 3] != "\xFF\xD8\xFF"} { close $fh; return -code error "not a jpg file" }
    seek $fh -1 current
    return $fh
}

proc ::jpeg::markers {fh} {
    set chunks [list]
    while {[set x [read $fh 1]] == "\xFF"} {
        binary scan [read $fh 3] aS type len
        set len [expr {$len & 0x0000FFFF}]
        binary scan $type H2 type
        incr len -2
        lappend chunks [list $type [tell $fh] $len]
        seek $fh $len current
    }
    return $chunks
}

proc ::jpeg::imageInfo {file} {
    set fh [openJFIF $file r+]
    set app0 [lsearch -inline [markers $fh] "e0 *"]
    seek $fh [lindex $app0 1] start
    set id [read $fh 5]
    if {$id == "JFIF\x00"} {
        binary scan [read $fh 9] cccSScc ver1 ver2 units xr yr xt yt
        close $fh
        return [list version $ver1.$ver2 units $units xdensity $xr ydensity $yr xthumb $xt ythumb $yt]
    }
    close $fh
}

proc ::jpeg::dimensions {file} {
    set fh [openJFIF $file]
    set sof [lsearch -inline [markers $fh] "c0 *"]
    seek $fh [lindex $sof 1] start
    binary scan [read $fh 5] cSS precision height width
    close $fh
    return [list $width $height]
}

proc ::jpeg::getComments {file} {
    set fh [openJFIF $file]
    set comments {}
    foreach x [lsearch -all -inline [markers $fh] "fe *"] {
        seek $fh [lindex $x 1] start
        lappend comments [read $fh [lindex $x 2]]
    }
    close $fh
    return $comments
}

proc ::jpeg::addComment {file comment args} {
    set fh [openJFIF $file r+]
    set sof [lsearch -inline [markers $fh] "c0 *"]
    seek $fh [expr {[lindex $sof 1] - 4}] start
    set data2 [read $fh]
    seek $fh [expr {[lindex $sof 1] - 4}] start
    foreach x [linsert $args 0 $comment] {
        puts -nonewline $fh "\xFF\xFE[binary format S [expr {[string length $x] + 2}]]$x"
    }
    puts -nonewline $fh $data2
    close $fh
}

proc ::jpeg::replaceComment {file comment} {
    set com [getComments $file]
    removeComments $file
    eval [list addComment $file] [lreplace $com 0 0 $comment]
}

proc ::jpeg::removeComments {file} {
    set fh [openJFIF $file]
    set data "\xFF\xD8"
    foreach marker [markers $fh] {
        if {[lindex $marker 0] != "fe"} {
            seek $fh [expr {[lindex $marker 1] - 4}] start
            append data [read $fh [expr {[lindex $marker 2] + 4}]]
        }
    }
    append data [read $fh]
    close $fh
    set fh [open $file w]
    puts -nonewline $fh $data
    close $fh
}

proc ::jpeg::getThumbnail {file} {
    array set exif [getExif $file thumbnail]
    if {[info exists exif(Compression)] && \
             $exif(Compression) == 6 && \
             [info exists exif(JpegIFOffset)] && \
             [info exists exif(JpegIFByteCount)]} {
        set fh [openJFIF $file]
        seek $fh [expr {[lindex [lsearch -inline [markers $fh] "e1 *"] 1] + 6 + $exif(JpegIFOffset)}] start
        set thumb [read $fh $exif(JpegIFByteCount)]
        close $fh
        return $thumb
    }
    set fh [openJFIF $file]
    foreach x [lsearch -inline -all [markers $fh] "e0 *"] {
        seek $fh [lindex $x 1] start
        binary scan [read $fh 6] a5H2 id excode
        if {$id == "JFXX\x00" && $excode == "10"} {
            set thumb [read $fh expr {$len - 8}]]
            close $fh
            return $thumb
        }
    }
    close $fh
}

proc ::jpeg::getExif {file {type main}} {
    set fh [openJFIF $file]
    set data {}
    
    if {[set exif [lsearch -inline [markers $fh] "e1 *"]] != ""} {
        seek $fh [lindex $exif 1] start
        if {[read $fh 6] != "Exif\x00\x00"} { close $fh; return }
        set start [tell $fh]
 
        binary scan [read $fh 2] H4 a
        if {$a == "4d4d"} {
            set end big
        } elseif {$a == "4949"} {
            set end little
        }

        if {![info exists end]} { close $fh; return }
        _scan $end [read $fh 6] si magic next
        if {$magic != 42} { close $fh; return }
        seek $fh [expr {$start + $next}] start

        if {$type != "thumbnail"} {
            set data [_exif $fh $end $start]
        } else {
            _scan $end [read $fh 2] s num
            seek $fh [expr {$num * 12}] current
            _scan $end [read $fh 4] s next
            if {$next <= 0} { close $fh; return }
            seek $fh [expr {$start + $next}] start
            set data [_exif $fh $end $start]
        }
    }
    close $fh
    return $data
}

proc ::jpeg::_exif {fh byteOrder offset} {
    variable exif
    set return {}
    for {_scan $byteOrder [read $fh 2] s num} {$num > 0} {incr num -1} {
        binary scan [read $fh 2] H2H2 t1 t2
        _scan $byteOrder [read $fh 6] si format components
        if {$byteOrder == "big"} {
            set tag $t1$t2
        } else {
            set tag $t2$t1
        }
        set value [read $fh 4]
        if {$tag == "8769" || $tag == "a005"} {
            _scan $byteOrder $value i next
            set pos [tell $fh]
            seek $fh [expr {$offset + $next}] start
            eval lappend return [_exif $fh $byteOrder $offset]
            seek $fh $pos start
            continue
        }
        if {![info exists exif(formatlen,$format)]} continue
        if {[info exists exif(tag,$tag)]} { set tag $exif(tag,$tag) }
        set size [expr {$exif(formatlen,$format) * $components}]
        if {$size > 4} {
            set pos [tell $fh]
            _scan $byteOrder $value i value
            seek $fh [expr {$offset + $value}] start
            set value [read $fh $size]
            seek $fh $pos start
        }
        lappend return $tag [_format $byteOrder $value $format $components]
    }
    return $return
}


proc ::jpeg::debug {file} {
    set fh [openJFIF $file]
    
    puts "marker: d8"
    puts "  SOI (Start Of Image)"
    
    foreach marker [markers $fh] {
        seek $fh [lindex $marker 1] 
        puts "marker: [lindex $marker 0] len: [lindex $marker 2]"
        switch -glob -- [lindex $marker 0] {
            c0 {
                binary scan [read $fh 6] cSSc precision height width color
                puts "  SOF (Start Of Frame)"
                puts "    Image dimensions: $width $height"
                puts "    Precision: $precision"
                puts "    Color Components: $color"
            }
            c4 {
                puts "  DHT (Define Huffman Table)"
                binary scan [read $fh 17] cS bits symbols
                puts "    $symbols symbols"
            }
            da {
                puts "  SOS (Start Of Scan)"
                binary scan [read $fh 2] c num
                puts "    Components: $num"
            }
            db {
                puts "  DQT (Define Quantization Table)"
            }
            dd {
                puts "  DRI (Define Restart Interval)"
                binary scan [read $fh 2] S num
                puts "    Interval: $num blocks"
            }
            e0 {
                set id [read $fh 5]
                if {$id == "JFIF\x00"} {
                    puts "  JFIF"
                    binary scan [read $fh 9] cccSScc ver1 ver2 units xr vr xt yt
                    puts "    Header: $ver1.$ver2 $units $xr $vr $xt $yt"
                } elseif {$id == "JFXX\x00"} {
                    puts "  JFXX"
                    binary scan [read $fh 1] H2 excode
                    if {$excode == "10"} { set excode "10 - JPEG thumbnail" }
                    if {$excode == "11"} { set excode "11 - Palletized thumbnail" }
                    if {$excode == "13"} { set excode "13 - RGB thumbnail" }
                    puts "    Extension code: $excode"
                } else {
                    puts "  Unknown APP0 segment: $id"
                }
            }
            e1 {
                if {[read $fh 6] == "Exif\x00\x00"} {
                    puts "  EXIF data"
                    puts "    MAIN EXIF"
                    foreach {x y} [getExif $file] {
                        puts "    $x $y"
                    }
                    puts "    THUMBNAIL EXIF"
                    foreach {x y} [getExif $file thumbnail] {
                        puts "    $x $y"
                    }
                } else {
                    puts "  APP1 (unknown)"
                }
            }
            e2 {
                if {[read $fh 12] == "ICC_PROFILE\x00"} {
                    puts "  ICC profile"
                } else {
                    puts "  APP2 (unknown)"
                }
            }
            ed {
                if {[read $fh 18] == "Photoshop 3.0\0008BIM"} {
                    puts "  Photoshop 8BIM data"
                } else {
                    puts "  APP13 (unknown)"
                }
            }
            ee {
                if {[read $fh 5] == "Adobe"} {
                    puts "  Adobe metadata"
                } else {
                    puts "  APP14 (unknown)"
                }
            }
            e[3456789abcf] {
                puts [format "  %s%d %s" APP 0x[string index [lindex $marker 0] 1] (unknown)]
            }
            fe {
                puts "  Comment: [read $fh [lindex $marker 2]]"
            }
            default {
                puts "  Unknown"
            }
        }
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
    tag,1002 RelatedImageLength
    
    tag,00fe NewSubfileType
    tag,00ff SubfileType
    tag,012d TransferFunction
    tag,013b Artist
    tag,013d Predictor
    tag,0142 TileWidth
    tag,0143 TileLength
    tag,0144 TileOffsets
    tag,0145 TileByteCounts
    tag,014a SubIFDs
    tag,015b JPEGTables
    tag,828d CFARepeatPatternDim
    tag,828e CFAPattern
    tag,828f BatteryLevel
    tag,83bb IPTC/NAA
    tag,8773 InterColorProfile
    tag,8824 SpectralSensitivity
    tag,8825 GPSInfo
    tag,8828 OECF
    tag,8829 Interlace
    tag,882a TimeZoneOffset
    tag,882b SelfTimerMode
    tag,920b FlashEnergy
    tag,920c SpatialFrequencyResponse
    tag,920d Noise
    tag,9211 ImageNumber
    tag,9212 SecurityClassification
    tag,9213 ImageHistory
    tag,9214 SubjectLocation
    tag,9215 ExposureIndex
    tag,9216 TIFF/EPStandardID
    tag,a20b FlashEnergy
    tag,a20c SpatialFrequencyResponse
    tag,a214 SubjectLocation
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

