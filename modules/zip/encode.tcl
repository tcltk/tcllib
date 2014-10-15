# -*- tcl -*-
# ### ### ### ######### ######### #########
## Copyright (c) 2008-2009 ActiveState Software Inc.
##                         Andreas Kupries
## BSD License
##
# Package providing commands for the generation of a zip archive.

# FUTURE: Write convenience command to zip up a whole directory.

package require Tcl 8.4

namespace eval ::zipfile {}
namespace eval ::zipfile::decode {}
namespace eval ::zipfile::encode {}

if {[package vcompare $tcl_patchLevel "8.6"] < 0} {

# Pre-8.6 Implementation

package require Trf      ; # Wrapper to zlib
package require zlibtcl

package require logger   ; # Tracing
package require crc32    ; # Tcllib, crc calculation
package require snit     ; # Tcllib, OO core
package require fileutil ; # zipdir convenience method

                   ; # Zlib usage. No commands, access through Trf

# ### ### ### ######### ######### #########
##

logger::initNamespace ::zipfile::encode
snit::type            ::zipfile::encode {

    constructor {} {}
    destructor {}

    # ### ### ### ######### ######### #########
    ##

    method comment: {text} {
	set comment $text
	return
    }

    method file: {dst owned src} {
	if {[info exists files($dst)]} {
	    return -code error -errorcode {ZIP ENCODE DUPLICATE PATH} \
		"Duplicate destination path \"$dst\""
	}
	if {![string is boolean -strict $owned]} {
	    return -code error -errorcode {ZIP ENCODE OWNED VALUE BOOLEAN} \
		"Expected boolean, got \"$owned\""
	}

	if {[catch {
	    file stat $src s
	} msg]} {
	    # Unreadable file or directory, or broken link. Ignore.
	    # TODO: Make handling configurable.
	    return
	}

	if {$::tcl_platform(platform) ne "windows"} {
	    file stat $src x
	    set attr $x(mode)
	    unset x
	} else {
	    set attr 33279 ; # 0o777 = rwxrwxrwx
	}

	if {[file isdirectory $src]} {
	    set files($dst/) [list 0 {} 0 $s(ctime) $attr]
	} else {
	    set files($dst) [list $owned $src [file size $src] $s(ctime) $attr]
	    log::debug "file: files($dst) = \{$files($dst)\}"
	}
	return
    }

    method write {archive} {
	set ch [setbinary [open $archive w]]

	set dstsorted [lsort -dict [array names files]]

	# Archive = <
	#  afile ...
	#  centralfileheader ...
	#  endofcentraldir
	# >

	foreach dst $dstsorted {
	    $self writeAFile $ch $dst
	}

	set cfh [tell $ch]

	foreach dst $dstsorted {
	    $self writeCentralFileHeader $ch $dst
	}

	set cfhsize [expr {[tell $ch] - $cfh}]

	$self writeEndOfCentralDir $ch $cfh $cfhsize
	close $ch
	return
    }

    # ### ### ### ######### ######### #########
    ##

    variable comment      {}
    variable files -array {}

    # ### ### ### ######### ######### #########
    ##

    method writeAFile {ch dst} {
	# AFile = <
	#  localfileheader
	#  file data
	# >

	foreach {owned src size ctime attr} $files($dst) break

	log::debug "write-a-file: $dst = $owned $size $src"

	# Determine if compression of the file to store will save us
	# some space. Also compute the crc checksum of the file to put
	# into the archive.

	if {$src ne ""} {
	    set c   [setbinary [open $src r]]
	    set crc [crc::crc32 -chan $c]
	    close $c
	} else {
	    set crc 0
	}

	if {$size == 0} {
	    set csize $size ; # compressed size is uncompressed
	    set cm    0     ; # uncompressed
	    set gpbf  0     ; # No flags
	} else {
	    set temp [fileutil::tempfile]
           
            set in   [setbinary [open $src r]]
            set out  [setbinary [open $temp w]]
            # Go for maximum compression
            zip -mode compress -nowrap 1 -level 9 -attach $out
            fcopy $in $out
            close $in
            close $out

	    set csize [file size $temp]
	    if {$csize < $size} {
		# Compression is good. Throw away the incoming file,
		# should we own it, then switch the upcoming copy
		# operation over to the compressed file. Which we do
		# own.

		if {$owned} {
		    file delete -force $src
		}
		set src   $temp ; # Copy the copressed temp file.
		set owned 1     ; # We own the source file now.
		set cm    8     ; # deflated
		set gpbf  2     ; # flags - deflated maximum
	    } else {
		# No space savings through compression. Throw away the
		# temp file and keep working with the original.

		file delete -force $temp

		set cm   0       ; # uncompressed
		set gpbf 0       ; # No flags
		set csize $size
	    }
	}

	# Write the local file header

	set fnlen  [string bytelength $dst]
	set offset [tell $ch] ; # location local header, needed for central header

	tag      $ch 4 3
	byte     $ch 20     ; # vnte/lsb/version = 2.0 (deflate needed)
	byte     $ch 3      ; # vnte/msb/host    = UNIX (file attributes = mode).
	short-le $ch $gpbf  ; # gpbf /deflate info
	short-le $ch $cm    ; # cm
	short-le $ch [Time $ctime] ; # lmft
	short-le $ch [Date $ctime] ; # lmfd
	long-le  $ch $crc   ; # crc32 of uncompressed file
	long-le  $ch $csize ; # compressed file size
	long-le  $ch $size  ; # uncompressed file size
	short-le $ch $fnlen ; # file name length
	short-le $ch 0      ; # extra field length, none
	str      $ch $dst   ; # file name
	# No extra field.

	if {$csize > 0} {
	    # Copy file data over. Maybe a compressed temp. file.

	    set    in [setbinary [open $src r]]
	    fcopy $in $ch
	    close $in
	}

	# Write a data descriptor repeating crc & size info, if
	# necessary.

	if {$crc == 0} {
	    tag     $ch 8 7
	    long-le $ch $crc   ; # crc32
	    long-le $ch $csize ; # compressed file size
	    long-le $ch $size  ; # uncompressed file size
	}

	# Done ... We are left with admin work ...
	#
	# Throwing away a source file we own, and recording much of
	# the data computed here for a file, for use when writing the
	# central file header.

	if {$owned} {
	    file delete -force $src
	}

	lappend files($dst) $cm $gpbf $csize $offset $crc
	return
    }

    method writeCentralFileHeader {ch dst} {
	foreach {owned src size ctime attr cm gpbf csize offset crc} $files($dst) break

	set fnlen [string bytelength $dst]

	tag      $ch 2 1
	byte     $ch 20      ; # vmb/lsb/version  = 2.0
	byte     $ch 3       ; # vmb/msb/host     = UNIX (file attributes = mode).
	byte     $ch 20      ; # vnte/lsb/version = 2.0
	byte     $ch 3       ; # vnte/msb/host    = UNIX (file attributes = mode).
	short-le $ch $gpbf   ; # gpbf /deflate info
	short-le $ch $cm     ; # cm
	short-le $ch [Time $ctime] ; # lmft
	short-le $ch [Date $ctime] ; # lmfd
	long-le  $ch $crc    ; # crc32 checksum of uncompressed file.
	long-le  $ch $csize  ; # compressed file size
	long-le  $ch $size   ; # uncompressed file size
	short-le $ch $fnlen  ; # file name length
	short-le $ch 0       ; # extra field length, none
	short-le $ch 0       ; # file comment length, none
	short-le $ch 0       ; # disk number start
	short-le $ch 0       ; # int. file attr., claim all as binary

	long-le  $ch [encode_permissions $attr] ; # ext. file attr: unix permissions.

	long-le  $ch $offset ; # relative offset of local file header
	str      $ch $dst    ; # file name
	# no extra field

	return
    }

    method writeEndOfCentralDir {ch cfhoffset cfhsize} {

	set clen   [string bytelength $comment]
	set nfiles [array size files]

	tag      $ch 6 5
	short-le $ch 0          ; # number of this disk
	short-le $ch 0          ; # number of disk with central directory
	short-le $ch $nfiles    ; # number of files in archive
	short-le $ch $nfiles    ; # number of files in archive
	long-le  $ch $cfhsize   ; # size central directory
	long-le  $ch $cfhoffset ; # offset central dir
	short-le $ch $clen      ; # archive comment length
	if {$clen} {
	    str  $ch $comment
	}
	return
    }

    proc tag {ch x y} {
	byte $ch 80 ; # 'P'
	byte $ch 75 ; # 'K'
	byte $ch $y ; # \ swapped! intentional!
	byte $ch $x ; # / little-endian number.
	return
    }

    proc byte {ch x} {
	puts -nonewline $ch [binary format c $x]
    }

    proc short-le {ch x} {
	puts -nonewline $ch [binary format s $x]
    }

    proc long-le {ch x} {
	puts -nonewline $ch [binary format i $x]
    }

    proc str {ch text} {
	fconfigure $ch -encoding utf-8
	# write the string as utf-8 to keep its bytes, exactly.
	puts -nonewline $ch $text
	fconfigure $ch -encoding binary
	return
    }

    proc setbinary {ch} {
	fconfigure $ch \
	    -encoding    binary \
	    -translation binary \
	    -eofchar     {}
	return $ch
    }

    # time = fedcba9876543210
    #        HHHHHmmmmmmSSSSS (sec/2 actually)

    proc Time {ctime} {
	foreach {h m s} [clock format $ctime -format {%H %M %S}] break
	# Remove leading zeros, i.e. prevent octal interpretation.
	deoctal h
	deoctal m
	deoctal s
	return [expr {(($h & 0x1f) << 11)|
		      (($m & 0x3f) << 5)|
		      (($s/2) & 0x1f)}]
    }

    # data = fedcba9876543210
    #        yyyyyyyMMMMddddd

    proc Date {ctime} {
	foreach {y m d} [clock format $ctime -format {%Y %m %d}] break
	deoctal y
	deoctal m
	deoctal d
	incr y -1980
	return [expr {(($y & 0xff) << 9)|
		      (($m & 0xf) << 5)|
		      ($d & 0x1f)}]
    }

    proc deoctal {nv} {
	upvar 1 $nv n
	set n [string trimleft $n 0]
	if {$n eq ""} {set n 0}
	return
    }

    proc encode_permissions {attr} {
	return [expr {$attr << 16}]
    }


    typemethod zipdir {path dst} {
	set z [$type create %AUTO%]

	set path [file dirname [file normalize [file join $path ___]]]

	foreach f [fileutil::find $path] {
	    set fx [fileutil::stripPath $path $f]
	    $z file: $fx 0 $f
	}

	file mkdir [file dirname $dst]
	$z write $dst
	$z destroy
	return
    }
}

} else {
# mkzip.tcl -- Copyright (C) 2009 Pat Thoyts <patthoyts@users.sourceforge.net>
#
#        Create ZIP archives in Tcl.
#
# Create a zipkit using mkzip filename.zkit -zipkit -directory xyz.vfs
# or a zipfile using mkzip filename.zip -directory dirname -exclude "*~"
#
# version 1.2

package require Tcl 8.6

namespace eval zip {}

# zip::timet_to_dos
#
#        Convert a unix timestamp into a DOS timestamp for ZIP times.
#
#   DOS timestamps are 32 bits split into bit regions as follows:
#                  24                16                 8                 0
#   +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+
#   |Y|Y|Y|Y|Y|Y|Y|m| |m|m|m|d|d|d|d|d| |h|h|h|h|h|m|m|m| |m|m|m|s|s|s|s|s|
#   +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+
#
proc ::zipfile::encode::timet_to_dos {time_t} {
    set s [clock format $time_t -format {%Y %m %e %k %M %S}]
    scan $s {%d %d %d %d %d %d} year month day hour min sec
    expr {(($year-1980) << 25) | ($month << 21) | ($day << 16) 
          | ($hour << 11) | ($min << 5) | ($sec >> 1)}
}

# zip::pop --
#
#        Pop an element from a list
#
proc ::zipfile::encode::pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

# zip::walk --
#
#        Walk a directory tree rooted at 'path'. The excludes list can be
#        a set of glob expressions to match against files and to avoid.
#        The match arg is internal.
#        eg: walk library {CVS/* *~ .#*} to exclude CVS and emacs cruft.
#
proc ::zipfile::encode::walk {base {excludes ""} {match *} {path {}}} {
    set result {}
    set imatch [file join $path $match]
    set files [glob -nocomplain -tails -types f -directory $base $imatch]
    foreach file $files {
        set excluded 0
        foreach glob $excludes {
            if {[string match $glob $file]} {
                set excluded 1
                break
            }
        }
        if {!$excluded} {lappend result $file}
    }
    foreach dir [glob -nocomplain -tails -types d -directory $base $imatch] {
        set subdir [walk $base $excludes $match $dir]
        if {[llength $subdir]>0} {
            set result [concat $result [list $dir] $subdir]
        }
    }
    return $result
}

# zipfile::encode::add_file_to_archive --
#
#        Add a single file to a zip archive. The zipchan channel should
#        already be open and binary. You may provide a comment for the
#        file The return value is the central directory record that
#        will need to be used when finalizing the zip archive.
#
# FIX ME: should  handle the current offset for non-seekable channels
#
proc ::zipfile::encode::add_file_to_archive {zipchan base path {comment ""}} {
    set fullpath [file join $base $path]
    set mtime [timet_to_dos [file mtime $fullpath]]
    if {[file isdirectory $fullpath]} {
        append path /
    }
    set utfpath [encoding convertto utf-8 $path]
    set utfcomment [encoding convertto utf-8 $comment]
    set flags [expr {(1<<11)}] ;# utf-8 comment and path
    set method 0               ;# store 0, deflate 8
    set attr 0                 ;# text or binary (default binary)
    set version 20             ;# minumum version req'd to extract
    set extra ""
    set crc 0
    set size 0
    set csize 0
    set data ""
    set seekable [expr {[tell $zipchan] != -1}]
    if {[file isdirectory $fullpath]} {
        set attrex 0x41ff0010  ;# 0o040777 (drwxrwxrwx)
    } elseif {[file executable $fullpath]} {
        set attrex 0x81ff0080  ;# 0o100777 (-rwxrwxrwx)
    } else {
        set attrex 0x81b60020  ;# 0o100666 (-rw-rw-rw-)
        if {[file extension $fullpath] in {".tcl" ".txt" ".c"}} {
            set attr 1         ;# text
        }
    }
  
    if {[file isfile $fullpath]} {
        set size [file size $fullpath]
        if {!$seekable} {set flags [expr {$flags | (1 << 3)}]}
    }
  
    set offset [tell $zipchan]
    set local [binary format a4sssiiiiss PK\03\04 \
                   $version $flags $method $mtime $crc $csize $size \
                   [string length $utfpath] [string length $extra]]
    append local $utfpath $extra
    puts -nonewline $zipchan $local
  
    if {[file isfile $fullpath]} {
        # If the file is under 2MB then zip in one chunk, otherwize we use
        # streaming to avoid requiring excess memory. This helps to prevent
        # storing re-compressed data that may be larger than the source when
        # handling PNG or JPEG or nested ZIP files.
        if {$size < 0x00200000} {
            set fin [::open $fullpath rb]
            set data [::read $fin]
            set crc [::zlib crc32 $data]
            set cdata [::zlib deflate $data]
            if {[string length $cdata] < $size} {
                set method 8
                set data $cdata
            }
            close $fin
            set csize [string length $data]
            puts -nonewline $zipchan $data
        } else {
            set method 8
            set fin [::open $fullpath rb]
            set zlib [::zlib stream deflate]
            while {![eof $fin]} {
                set data [read $fin 4096]
                set crc [zlib crc32 $data $crc]
                $zlib put $data
                if {[string length [set zdata [$zlib get]]]} {
                    incr csize [string length $zdata]
                    puts -nonewline $zipchan $zdata
                }
            }
            close $fin
            $zlib finalize
            set zdata [$zlib get]
            incr csize [string length $zdata]
            puts -nonewline $zipchan $zdata
            $zlib close
        }
    
        if {$seekable} {
            # update the header if the output is seekable
            set local [binary format a4sssiiii PK\03\04 \
                           $version $flags $method $mtime $crc $csize $size]
            set current [tell $zipchan]
            seek $zipchan $offset
            puts -nonewline $zipchan $local
            seek $zipchan $current
        } else {
            # Write a data descriptor record
            set ddesc [binary format a4iii PK\7\8 $crc $csize $size]
            puts -nonewline $zipchan $ddesc
        }
    }
  
    set hdr [binary format a4ssssiiiisssssii PK\01\02 0x0317 \
                 $version $flags $method $mtime $crc $csize $size \
                 [string length $utfpath] [string length $extra]\
                 [string length $utfcomment] 0 $attr $attrex $offset]
    append hdr $utfpath $extra $utfcomment
    return $hdr
}

# zipfile::encode::mkzip --
#
#        Create a zip archive in 'filename'. If a file already exists it will be
#        overwritten by a new file. If '-directory' is used, the new zip archive
#        will be rooted in the provided directory.
#        -runtime can be used to specify a prefix file. For instance, 
#        zip myzip -runtime unzipsfx.exe -directory subdir
#        will create a self-extracting zip archive from the subdir/ folder.
#        The -comment parameter specifies an optional comment for the archive.
#
#        eg: zip my.zip -directory Subdir -runtime unzipsfx.exe *.txt
# 
proc ::zipfile::encode::mkzip {filename args} {
  array set opts {
      -zipkit 0 -runtime "" -comment "" -directory ""
      -exclude {CVS/* */CVS/* *~ ".#*" "*/.#*"}
  }
  
  while {[string match -* [set option [lindex $args 0]]]} {
      switch -exact -- $option {
          -zipkit  { set opts(-zipkit) 1 }
          -comment { set opts(-comment) [encoding convertto utf-8 [pop args 1]] }
          -runtime { set opts(-runtime) [pop args 1] }
          -directory {set opts(-directory) [file normalize [pop args 1]] }
          -exclude {set opts(-exclude) [pop args 1] }
          -- { pop args ; break }
          default {
              break
          }
      }
      pop args
  }

  set zf [::open $filename wb]
  if {$opts(-runtime) ne ""} {
      set rt [::open $opts(-runtime) rb]
      fcopy $rt $zf
      close $rt
  } elseif {$opts(-zipkit)} {
      set zkd "#!/usr/bin/env tclkit\n\# This is a zip-based Tcl Module\n"
      append zkd "package require vfs::zip\n"
      append zkd "vfs::zip::Mount \[info script\] \[info script\]\n"
      append zkd "if {\[file exists \[file join \[info script\] main.tcl\]\]} \{\n"
      append zkd "    source \[file join \[info script\] main.tcl\]\n"
      append zkd "\}\n"
      append zkd \x1A
      puts -nonewline $zf $zkd
  }

  set count 0
  set cd ""

  if {$opts(-directory) ne ""} {
      set paths [walk $opts(-directory) $opts(-exclude)]
  } else {
      set paths [glob -nocomplain {*}$args]
  }
  foreach path $paths {
      puts $path
      append cd [add_file_to_archive $zf $opts(-directory) $path]
      incr count
  }
  set cdoffset [tell $zf]
  set endrec [binary format a4ssssiis PK\05\06 0 0 \
                  $count $count [string length $cd] $cdoffset\
                  [string length $opts(-comment)]]
  append endrec $opts(-comment)
  puts -nonewline $zf $cd
  puts -nonewline $zf $endrec
  close $zf

  return
}
}
# ### ### ### ######### ######### #########
## Ready
package provide zipfile::encode 0.3
return
