# -*- tcl -*-
# ### ### ### ######### ######### #########
## Copyright (c) 2008-2009 ActiveState Software Inc.
##                         Andreas Kupries
## BSD License
##
# Package providing commands for the generation of a zip archive.

# FUTURE: Write convenience command to zip up a whole directory.

package require Tcl 8.4
package require logger   ; # Tracing
package require Trf      ; # Wrapper to zlib
package require crc32    ; # Tcllib, crc calculation
package require snit     ; # Tcllib, OO core
package require zlibtcl  ; # Zlib usage. No commands, access through Trf
package require fileutil ; # zipdir convenience method

# ### ### ### ######### ######### #########
##

logger::initNamespace ::zipfile::encode
snit::type            ::zipfile::encode {

    # ZIP64 modi: always, never, as-required


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
    ## Comment text and map of files.
    #
    # files: dst-path -> (owned, origin-path, origin-size, creation-time, permissions)
    #   Note: Directory paths are encoded using a trailing "/" on the
    #   destination path, and an empty origin path, of size 0.

    variable comment      {}
    variable files -array {}
    variable zip64        0

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
		set src   $temp ; # Copy the compressed temp file.
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

	set fnlen   [string bytelength $dst]
	set offset  [tell $ch] ; # location local header, needed for central header
	set vneeded 20 ; # vnte/lsb/version = 2.0 (deflate needed)
	# ZIP64: vneeded 45

	tag      $ch 4 3
	byte     $ch $vneeded
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

	# ZIP64: If activated an extra field with the correct sizes.
	# ZIP64: writeZip64FileExtension $ch <dict> osize, csize, disk, offset

	if {$csize > 0} {
	    # Copy file data over. Maybe a compressed temp. file.

	    set    in [setbinary [open $src r]]
	    fcopy $in $ch
	    close $in
	}

	# Write a data descriptor repeating crc & size info, if
	# necessary.

	## XXX BUG ? condition bogus - gpbf bit 3 must be set / never for us, see above
	if {$crc == 0} {
	    ## ZIP64 stores 8-byte file sizes, i.e long-long.

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

	# zip64 - version needed = 4.5

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

	# if needed for fields in the ECD, or zip64 generally activated..
	#   ZIP64: writeZip64EndOfCentralDir $ch
	#   ZIP64: writeZip64ECDLocator $ch ?offset?

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

    method writeZip64FileExtension {ch dict} {
	dict with $dict {}
	# osize, csize offset disk

	# Determine extension size based on elements to write
	set block 0
	if {[info exists osize]}  { incr block 8 }
	if {[info exists csize]}  { incr block 8 }
	if {[info exists offset]} { incr block 8 }
	if {[info exists disk]}   { incr block 4 }

	# Write extension header
	short-le $ch 1
	short-le $ch $block

	# Write the elements
	if {[info exists osize]}  { quad-le $ch $osize }
	if {[info exists csize]}  { quad-le $ch $csize }
	if {[info exists offset]} { quad-le $ch $offset }
	if {[info exists disk]}   { long-le $ch $disk   }
	return
    }

    method writeZip64EndOfCentralDir {ch offset} {

	#  0 long              signature 0x06 06 4b 50 == "PK" 6 6
	#  4 long-long         size of the "end of central directory record" = this.
	# 12 short             version made by
	# 14 short             version needed
	# 16 long              number of disk
	# 20 long              number of disk with start of central directory
	# 24 long-long         number of files in this disk
	# 32 long-long         number of files in whole archive
	# 40 long-long         offset of central dir with respect to starting disk
	# 48

	# (v2 fields: 28822222 -) appnote 7.3.4


	# 48 variable          zip64 extensible data sector

	# size = size without the leading 12 bytes (i.e. signature and size fields).
	# above structure is version 1

	set nfiles [array size files]

	tag      $ch 6 6
	quad-le  $ch 36 ;# 48-12 (size counted without lead fields (tag+size))
	short-le $ch 1
	short-le $ch 1
	long-le  $ch 1
	long-le  $ch 0
	quad-le  $ch $nfiles
	quad-le  $ch $nfiles
	quad-le  $ch $offset

	# extensible block =
	# short      ID
	# long       size
	# char[size] data

	# multiple extension blocks allowed, all of the format.

	# -----------------------------------------------
	# ID 0x001 zip64 extended information extra field

	# DATA
	# long-long : original size
	# long-long : compressed size
	# long-long : header offset
	# long      : disk start number
	#
	# each field appears only when signaled (*) to be required by
	# the corresponding field of the regular L/C directory entry.
	# the order is fixed as shown.
	#
	# (*) (long) -1, or (short) -1, depending on field size,
	#     i.e 0xFFFFFFFF and 0xFFFF
    }

    method writeZip64ECDLocator {ch offset} {
	# 0  long      signature 0x 07 06 4b 50 == "PK" 7 6
	# 4  long      number of disk holding the start of the ECD
	# 8  long-long relative offset of the ECD
	# 16 long      total number of disks
	# 20

	tag     $ch 7 6
	long-le $ch 0
	quad-le $ch $offset
	long-le $ch 1
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
	# x = 1 byte uchar
	puts -nonewline $ch [binary format c $x]
    }

    proc short-le {ch x} {
	# x = 2 byte short
	puts -nonewline $ch [binary format s $x]
    }

    proc long-le {ch x} {
	# x = 4 byte long
	puts -nonewline $ch [binary format i $x]
    }

    proc quad-le {ch x} {
	# x = 8 byte long (wideint)
	set hi [expr {($x >> 32) & 0xFFFFFFFF}]
	set lo [expr {($x      ) & 0xFFFFFFFF}]
	# lo             >>  0

	long-le $ch $lo
	long-le $ch $hi
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

# ### ### ### ######### ######### #########
## Ready
package provide zipfile::encode 0.3
return
