# filetypes.tcl --
#
#	Tcl based file type recognizer using the runtime core and
#	generated from /usr/share/misc/magic.mime. Limited output,
#	but only mime-types, i.e. standardized.
#
# Copyright (c) 2016      Poor Yorick     <tk.tcl.core.tcllib@pooryorick.com>
# Copyright (c) 2004-2005 Colin McCormack <coldstore@users.sourceforge.net>
# Copyright (c) 2005-2006 Andreas Kupries <andreas_kupries@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: filetypes.tcl,v 1.6 2006/09/27 21:19:35 andreas_kupries Exp $

#####
#
# "mime type discriminator"
# http://wiki.tcl.tk/12537
#
# Tcl code harvested on:  10 Feb 2005, 04:16 GMT
# Wiki page last updated: ???
#
#####

# ### ### ### ######### ######### #########
## Requirements.

package require Tcl 8.6
package require fileutil::magic::rt    ; # We need the runtime core.

# ### ### ### ######### ######### #########
## Implementation

namespace eval ::fileutil::magic {}

proc ::fileutil::magic::filetype file {
    if {![file exists $file]} {
        return -code error "file not found: \"$file\""
    }
    if {[file isdirectory $file]} {
	return directory
    }

    rt::open $file
    try {
	set matches {}
	set coro [coroutine [info cmdcount] filetype::run]
	while 1 {
	    lassign [$coro] weight result mimetype ext 
	    if {[namespace which $coro] ne $coro} break
	    dict update matches $weight weight {
		lappend weight [list $result $mimetype $ext]
	    }
	}
    } finally {
	rt::close
    }

    set keys [dict keys $matches]
    if {[llength $keys]} {
	set res [lindex [dict get $matches [::tcl::mathfunc::max {*}$keys]] 0]
	lassign $res result mimetype ext
	foreach item $result {
	    if {$item ne {}} {
		return $res
	    }
	}
	if {$mimtetype ne {} || $ext ne {}} {
	    return $res
	}
	return {} 
    }
}

package provide fileutil::magic::filetype 1.1.2
# The actual recognizer is the command below.

##
## -- Do not edit after this line !
## -- ** BEGIN GENERATED CODE ** --

package require fileutil::magic::rt
namespace eval ::fileutil::magic::filetype {    namespace import ::fileutil::magic::rt::*}
proc ::fileutil::magic::filetype::run {} {
	
	yield [info coroutine]
	set named {7 {new-dump-be {
if {[N bedate 4 0 0 {} {} x {}]} {>

emit {Previous dump %s,}
<}


if {[N bedate 8 0 0 {} {} x {}]} {>

emit {This dump %s,}
<}


if {[N belong 12 0 0 {} {} > 0]} {>

emit {Volume %d,}
<}


if {[N belong 692 0 0 {} {} == 0]} {>

emit {Level zero, type:}
<}


if {[N belong 692 0 0 {} {} > 0]} {>

emit {Level %d, type:}
<}


switch -- [Nv belong 0 0 {} {}] 1 {>;emit {tape header,};<} 2 {>;emit {beginning of file record,};<} 3 {>;emit {map of inodes on tape,};<} 4 {>;emit {continuation of file record,};<} 5 {>;emit {end of volume,};<} 6 {>;emit {map of inodes deleted,};<} 7 {>;emit {end of medium (for floppy),};<} 
<


if {[S string 676 0 {} {} > \0]} {>

emit {Label %s,}
<}


if {[S string 696 0 {} {} > \0]} {>

emit {Filesystem %s,}
<}


if {[S string 760 0 {} {} > \0]} {>

emit {Device %s,}
<}


if {[S string 824 0 {} {} > \0]} {>

emit {Host %s,}
<}


if {[N belong 888 0 0 {} {} > 0]} {>

emit {Flags %x}
<}
} old-dump-be {
if {[N belong 12 0 0 {} {} > 0]} {>

emit {Volume %d,}
<}


if {[N belong 692 0 0 {} {} == 0]} {>

emit {Level zero, type:}
<}


if {[N belong 692 0 0 {} {} > 0]} {>

emit {Level %d, type:}
<}


switch -- [Nv belong 0 0 {} {}] 1 {>;emit {tape header,};<} 2 {>;emit {beginning of file record,};<} 3 {>;emit {map of inodes on tape,};<} 4 {>;emit {continuation of file record,};<} 5 {>;emit {end of volume,};<} 6 {>;emit {map of inodes deleted,};<} 7 {>;emit {end of medium (for floppy),};<} 
<


if {[S string 676 0 {} {} > \0]} {>

emit {Label %s,}
<}


if {[S string 696 0 {} {} > \0]} {>

emit {Filesystem %s,}
<}


if {[S string 760 0 {} {} > \0]} {>

emit {Device %s,}
<}


if {[S string 824 0 {} {} > \0]} {>

emit {Host %s,}
<}


if {[N belong 888 0 0 {} {} > 0]} {>

emit {Flags %x}
<}
} ufs2-dump-be {
if {[N beqdate 896 0 0 {} {} x {}]} {>

emit {Previous dump %s,}
<}


if {[N beqdate 904 0 0 {} {} x {}]} {>

emit {This dump %s,}
<}


if {[N belong 12 0 0 {} {} > 0]} {>

emit {Volume %d,}
<}


if {[N belong 692 0 0 {} {} == 0]} {>

emit {Level zero, type:}
<}


if {[N belong 692 0 0 {} {} > 0]} {>

emit {Level %d, type:}
<}


switch -- [Nv belong 0 0 {} {}] 1 {>;emit {tape header,};<} 2 {>;emit {beginning of file record,};<} 3 {>;emit {map of inodes on tape,};<} 4 {>;emit {continuation of file record,};<} 5 {>;emit {end of volume,};<} 6 {>;emit {map of inodes deleted,};<} 7 {>;emit {end of medium (for floppy),};<} 
<


if {[S string 676 0 {} {} > \0]} {>

emit {Label %s,}
<}


if {[S string 696 0 {} {} > \0]} {>

emit {Filesystem %s,}
<}


if {[S string 760 0 {} {} > \0]} {>

emit {Device %s,}
<}


if {[S string 824 0 {} {} > \0]} {>

emit {Host %s,}
<}


if {[N belong 888 0 0 {} {} > 0]} {>

emit {Flags %x}
<}
}} 8 {mach-o {U 8 mach-o-cpu



if {[N belong 0 0 0 {} {} x {}]} {>

emit {\b]}
<}
}} 15 {cups-le {
if {[N lelong 280 0 0 {} {} x {}]} {>

emit {\b, %d}
<}


if {[N lelong 284 0 0 {} {} x {}]} {>

emit {\bx%d dpi}
<}


if {[N lelong 376 0 0 {} {} x {}]} {>

emit {\b, %dx}
<}


if {[N lelong 380 0 0 {} {} x {}]} {>

emit {\b%d pixels}
<}


if {[N lelong 388 0 0 {} {} x {}]} {>

emit {%d bits/color}
<}


if {[N lelong 392 0 0 {} {} x {}]} {>

emit {%d bits/pixel}
<}


switch -- [Nv lelong 400 0 {} {}] 0 {>;emit ColorOrder=Chunky;<} 1 {>;emit ColorOrder=Banded;<} 2 {>;emit ColorOrder=Planar;<} 
<


switch -- [Nv lelong 404 0 {} {}] 0 {>;emit ColorSpace=gray;<} 1 {>;emit ColorSpace=RGB;<} 2 {>;emit ColorSpace=RGBA;<} 3 {>;emit ColorSpace=black;<} 4 {>;emit ColorSpace=CMY;<} 5 {>;emit ColorSpace=YMC;<} 6 {>;emit ColorSpace=CMYK;<} 7 {>;emit ColorSpace=YMCK;<} 8 {>;emit ColorSpace=KCMY;<} 9 {>;emit ColorSpace=KCMYcm;<} 10 {>;emit ColorSpace=GMCK;<} 11 {>;emit ColorSpace=GMCS;<} 12 {>;emit ColorSpace=WHITE;<} 13 {>;emit ColorSpace=GOLD;<} 14 {>;emit ColorSpace=SILVER;<} 15 {>;emit {ColorSpace=CIE XYZ};<} 16 {>;emit {ColorSpace=CIE Lab};<} 17 {>;emit ColorSpace=RGBW;<} 18 {>;emit ColorSpace=sGray;<} 19 {>;emit ColorSpace=sRGB;<} 20 {>;emit ColorSpace=AdobeRGB;<} 
<
}} 18 {keytab_entry {
if {[Sx pstring 4 0 H {} x {}]} {>

emit {\b, realm=%s}

	if {[Sx pstring [R 0] 0 H {} x {}]} {>

	emit {\b, principal=%s/}

		if {[Sx pstring [R 0] 0 H {} x {}]} {>

		emit {\b%s}

			if {[Nx belong [R 0] 0 0 {} {} x {}]} {>

			emit {\b, type=%d}

				if {[Nx bedate [R 0] 0 0 {} {} x {}]} {>

				emit {\b, date=%s}

					if {[Nx byte [R 0] 0 0 {} {} x {}]} {>

					emit {\b, kvno=%u}
<}

<}

<}

<}

<}

<}
}} 32 {linuxraid {
if {[N belong 16 0 0 {} {} x {}]} {>

emit UUID=%8x:
<}


if {[N belong 20 0 0 {} {} x {}]} {>

emit {\b%8x:}
<}


if {[N belong 24 0 0 {} {} x {}]} {>

emit {\b%8x:}
<}


if {[N belong 28 0 0 {} {} x {}]} {>

emit {\b%8x}
<}


if {[S string 32 0 {} {} x {}]} {>

emit name=%s
<}


if {[N lelong 72 0 0 {} {} x {}]} {>

emit level=%d
<}


if {[N lelong 92 0 0 {} {} x {}]} {>

emit disks=%d
<}
}} 48 {woff {
switch -- [Nv belong 4 0 {} {}] 65536 {>;emit {\b, TrueType};<} 1330926671 {>;emit {\b, CFF};<} 1953658213 {>;emit {\b, TrueType};<} 
<


if {[S default 4 0 {} {} x {}]} {>

	if {[N belong 4 0 0 {} {} x {}]} {>

	emit {\b, flavor %d}
<}

<}


if {[N belong 8 0 0 {} {} x {}]} {>

emit {\b, length %d}
<}
}} 60 {pcap-be {
if {[N beshort 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}


if {[N beshort 6 0 0 {} {} x {}]} {>

emit {\b.%d}
<}


switch -- [Nv belong 20 0 {} {}] 0 {>;emit {(No link-layer encapsulation};<} 1 {>;emit (Ethernet;<} 2 {>;emit {(3Mb Ethernet};<} 3 {>;emit (AX.25;<} 4 {>;emit (ProNET;<} 5 {>;emit (CHAOS;<} 6 {>;emit {(Token Ring};<} 7 {>;emit {(BSD ARCNET};<} 8 {>;emit (SLIP;<} 9 {>;emit (PPP;<} 10 {>;emit (FDDI;<} 11 {>;emit {(RFC 1483 ATM};<} 12 {>;emit {(raw IP};<} 13 {>;emit {(BSD/OS SLIP};<} 14 {>;emit {(BSD/OS PPP};<} 19 {>;emit {(Linux ATM Classical IP};<} 50 {>;emit {(PPP or Cisco HDLC};<} 51 {>;emit (PPP-over-Ethernet;<} 99 {>;emit {(Symantec Enterprise Firewall};<} 100 {>;emit {(RFC 1483 ATM};<} 101 {>;emit {(raw IP};<} 102 {>;emit {(BSD/OS SLIP};<} 103 {>;emit {(BSD/OS PPP};<} 104 {>;emit {(BSD/OS Cisco HDLC};<} 105 {>;emit (802.11;<} 106 {>;emit {(Linux Classical IP over ATM};<} 107 {>;emit {(Frame Relay};<} 108 {>;emit {(OpenBSD loopback};<} 109 {>;emit {(OpenBSD IPsec encrypted};<} 112 {>;emit {(Cisco HDLC};<} 113 {>;emit {(Linux "cooked"};<} 114 {>;emit (LocalTalk;<} 117 {>;emit {(OpenBSD PFLOG};<} 119 {>;emit {(802.11 with Prism header};<} 122 {>;emit {(RFC 2625 IP over Fibre Channel};<} 123 {>;emit (SunATM;<} 127 {>;emit {(802.11 with radiotap header};<} 129 {>;emit {(Linux ARCNET};<} 138 {>;emit {(Apple IP over IEEE 1394};<} 139 {>;emit {(MTP2 with pseudo-header};<} 140 {>;emit (MTP2;<} 141 {>;emit (MTP3;<} 142 {>;emit (SCCP;<} 143 {>;emit (DOCSIS;<} 144 {>;emit (IrDA;<} 147 {>;emit {(Private use 0};<} 148 {>;emit {(Private use 1};<} 149 {>;emit {(Private use 2};<} 150 {>;emit {(Private use 3};<} 151 {>;emit {(Private use 4};<} 152 {>;emit {(Private use 5};<} 153 {>;emit {(Private use 6};<} 154 {>;emit {(Private use 7};<} 155 {>;emit {(Private use 8};<} 156 {>;emit {(Private use 9};<} 157 {>;emit {(Private use 10};<} 158 {>;emit {(Private use 11};<} 159 {>;emit {(Private use 12};<} 160 {>;emit {(Private use 13};<} 161 {>;emit {(Private use 14};<} 162 {>;emit {(Private use 15};<} 163 {>;emit {(802.11 with AVS header};<} 165 {>;emit {(BACnet MS/TP};<} 166 {>;emit (PPPD;<} 169 {>;emit {(GPRS LLC};<} 177 {>;emit {(Linux LAPD};<} 187 {>;emit {(Bluetooth HCI H4};<} 189 {>;emit {(Linux USB};<} 192 {>;emit (PPI;<} 195 {>;emit (802.15.4;<} 196 {>;emit (SITA;<} 197 {>;emit {(Endace ERF};<} 201 {>;emit {(Bluetooth HCI H4 with pseudo-header};<} 202 {>;emit {(AX.25 with KISS header};<} 203 {>;emit (LAPD;<} 204 {>;emit {(PPP with direction pseudo-header};<} 205 {>;emit {(Cisco HDLC with direction pseudo-header};<} 206 {>;emit {(Frame Relay with direction pseudo-header};<} 209 {>;emit {(Linux IPMB};<} 215 {>;emit {(802.15.4 with non-ASK PHY header};<} 220 {>;emit {(Memory-mapped Linux USB};<} 224 {>;emit {(Fibre Channel FC-2};<} 225 {>;emit {(Fibre Channel FC-2 with frame delimiters};<} 226 {>;emit {(Solaris IPNET};<} 227 {>;emit (SocketCAN;<} 228 {>;emit {(Raw IPv4};<} 229 {>;emit {(Raw IPv6};<} 230 {>;emit {(802.15.4 without FCS};<} 231 {>;emit {(D-Bus messages};<} 235 {>;emit (DVB-CI;<} 236 {>;emit (MUX27010;<} 237 {>;emit {(STANAG 5066 D_PDUs};<} 239 {>;emit {(Linux netlink NFLOG messages};<} 240 {>;emit {(Hilscher netAnalyzer};<} 241 {>;emit {(Hilscher netAnalyzer with delimiters};<} 242 {>;emit (IP-over-Infiniband;<} 243 {>;emit {(MPEG-2 Transport Stream packets};<} 244 {>;emit {(ng4t ng40};<} 245 {>;emit {(NFC LLCP};<} 247 {>;emit (Infiniband;<} 248 {>;emit (SCTP;<} 
<


if {[N belong 16 0 0 {} {} x {}]} {>

emit {\b, capture length %d)}
<}
}} 72 {help-ver-date {
if {[N leshort 0 0 0 {} {} == 876]} {>

	if {[N leshort 4 0 0 {} {} == 1]} {>

	emit Windows

		switch -- [Nv leshort 2 0 {} {}] 15 {>;emit 3.x;<} 21 {>;emit 3.0;<} 33 {>;emit 3.1;<} 39 {>;emit x.y;<} 51 {>;emit 95;<} 
<

		if {[S default 2 0 {} {} x {}]} {>

		emit y.z

			if {[N leshort 2 0 0 {} {} x {}]} {>

			emit 0x%x
<}

<}

		if {[N leshort 2 0 0 {} {} x {}]} {>

		emit help
<}

		if {[N ldate 6 0 0 {} {} x {}]} {>

		emit {\b, %s}
<}

	mime application/winhelp

	ext hlp

<}

<}
} cnt-name {
if {[S string 0 0 {} {} eq \ ]} {>

	if {[S regex 1 0 c {} eq ^(\[^\xd>\]*|.*.hlp)]} {>

	emit {MS Windows help file Content, based "%s"}
	mime text/plain

	ext cnt

<}

<}
}} 85 {xbase-type {
if {[N byte 0 0 0 {} {} < 2]} {>

<}


if {[N byte 0 0 0 {} {} > 1]} {>

	switch -- [Nv byte 0 0 {} {}] 2 {>;emit FoxBase;<} 3 {>;emit {FoxBase+/dBase III}
	mime application/x-dbf
;<} 4 {>;emit {dBase IV}
	mime application/x-dbf
;<} 5 {>;emit {dBase V}
	mime application/x-dbf
;<} 48 {>;emit {Visual FoxPro}
	mime application/x-dbf
;<} 49 {>;emit {Visual FoxPro, autoincrement}
	mime application/x-dbf
;<} 50 {>;emit {Visual FoxPro, with field type Varchar}
	mime application/x-dbf
;<} 67 {>;emit {dBase IV, with SQL table}
	mime application/x-dbf
;<} 123 {>;emit {dBase IV, with memo}
	mime application/x-dbf
;<} -125 {>;emit {FoxBase+/dBase III, with memo .DBT}
	mime application/x-dbf
;<} -121 {>;emit {VISUAL OBJECTS, with memo file}
	mime application/x-dbf
;<} -117 {>;emit {dBase IV, with memo .DBT}
	mime application/x-dbf
;<} -114 {>;emit {dBase IV, with SQL table}
	mime application/x-dbf
;<} -77 {>;emit Flagship;<} -53 {>;emit {dBase IV with SQL table, with memo .DBT}
	mime application/x-dbf
;<} -27 {>;emit {Clipper SIX with memo}
	mime application/x-dbf
;<} -11 {>;emit {FoxPro with memo}
	mime application/x-dbf
;<} 
<

	if {[S default 0 0 {} {} x {}]} {>

	emit xBase

		if {[N byte 0 0 0 {} {} x {}]} {>

		emit (0x%x)
<}

	mime application/x-dbf

<}

<}
} xbase-date {
if {[N belong 0 0 0 {} {} x {}]} {>

<}


if {[N byte 1 0 0 {} {} < 13]} {>

	if {[N byte 1 0 0 {} {} > 0]} {>

		if {[N byte 2 0 0 {} {} > 0]} {>

			if {[N byte 2 0 0 {} {} < 32]} {>

				if {[N byte 0 0 0 {} {} x {}]} {>

					if {[N byte 0 0 0 {} {} < 100]} {>

					emit {\b %.2d}
<}

					if {[N byte 0 0 0 {} {} > 99]} {>

					emit {\b %d}
<}

<}

				if {[N byte 1 0 0 {} {} x {}]} {>

				emit {\b-%d}
<}

				if {[N byte 2 0 0 {} {} x {}]} {>

				emit {\b-%d}
<}

<}

<}

<}

<}
} dbase3-memo-print {
if {[N byte 0 0 0 {} {} x {}]} {>

emit {dBase III DBT}
<}


if {[N byte 16 0 0 {} {} != 3]} {>

emit {\b, version number %u}
<}


if {[N lelong 0 0 0 {} {} != 0]} {>

emit {\b, next free block index %u}
<}


if {[N leshort 20 0 0 {} {} != 0]} {>

emit {\b, block length %u}
<}


if {[S string 512 0 {} {} > \0]} {>

emit {\b, 1st item "%s"}
<}
} dbase4-memo-print {
if {[N lelong 0 0 0 {} {} x {}]} {>

emit {dBase IV DBT}
mime application/x-dbt

ext dbt

<}


if {[N belong 8 0 0 {} {} > 536870912]} {>

	if {[N leshort 20 0 0 {} {} > 0]} {>

		if {[S string 8 0 {} {} > \0]} {>

		emit {\b of %-.8s.DBF}
<}

<}

<}


if {[N lelong 4 0 0 {} {} != 0]} {>

	if {[N lelong 4 0 0 & 63 == 0]} {>

	emit {\b, blocks size %u}
<}

<}


if {[N leshort 20 0 0 {} {} > 0]} {>

emit {\b, block length %u}
<}


if {[N lelong 0 0 0 {} {} != 0]} {>

emit {\b, next free block index %u}
<}


if {[Nx leshort 20 0 0 {} {} > 0]} {>

	if {[Nx belong [I 20 leshort 0 0 0 0] 0 0 {} {} x {}]} {>
U 85 dbase4-memofield-print

<}

<}


if {[Nx leshort 20 0 0 {} {} == 0]} {>

	if {[Nx belong 512 0 0 {} {} x {}]} {>
U 85 dbase4-memofield-print

<}

<}
} dbase4-memofield-print {
if {[N belong 0 0 0 {} {} != 4294903808]} {>

	if {[N lelong 0 0 0 {} {} x {}]} {>

	emit {\b, next free block %u}
<}

	if {[N lelong 4 0 0 {} {} x {}]} {>

	emit {\b, next used block %u}
<}

<}


if {[N belong 0 0 0 {} {} == 4294903808]} {>

	if {[N lelong 4 0 0 {} {} x {}]} {>

	emit {\b, field length %d}

		if {[S string 8 0 {} {} > \0]} {>

		emit {\b, 1st used item "%s"}
<}

<}

<}
} foxpro-memo-print {
if {[N belong 0 0 0 {} {} x {}]} {>

emit {FoxPro FPT}
<}


if {[N beshort 6 0 0 {} {} x {}]} {>

emit {\b, blocks size %u}
<}


if {[N belong 0 0 0 {} {} != 0]} {>

emit {\b, next free block index %u}
<}


if {[N belong 512 0 0 {} {} < 3]} {>

emit {\b, field type %u}
<}


if {[N belong 512 0 0 {} {} == 1]} {>

	if {[N belong 516 0 0 {} {} > 0]} {>

	emit {\b, field length %d}

		if {[S string 520 0 {} {} > \0]} {>

		emit {\b, 1st item "%s"}
<}

<}

<}
}} 111 {ico-dir {
if {[N byte 0 0 0 {} {} == 1]} {>

emit {- 1 icon}
<}


if {[N byte 0 0 0 {} {} > 1]} {>

emit {- %d icons}
<}


if {[N byte 2 0 0 {} {} == 0]} {>

emit {\b, 256x}
<}


if {[N byte 2 0 0 {} {} != 0]} {>

emit {\b, %dx}
<}


if {[N byte 3 0 0 {} {} == 0]} {>

emit {\b256}
<}


if {[N byte 3 0 0 {} {} != 0]} {>

emit {\b%d}
<}


if {[N byte 4 0 0 {} {} != 0]} {>

emit {\b, %d colors}
<}
} cur-dir {
if {[N byte 0 0 0 {} {} == 1]} {>

emit {- 1 icon}
<}


if {[N byte 0 0 0 {} {} > 1]} {>

emit {- %d icons}
<}


if {[N byte 2 0 0 {} {} == 0]} {>

emit {\b, 256x}
<}


if {[N byte 2 0 0 {} {} != 0]} {>

emit {\b, %dx}
<}


if {[N byte 3 0 0 {} {} == 0]} {>

emit {\b256}
<}


if {[N byte 3 0 0 {} {} != 0]} {>

emit {\b%d}
<}


if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\b, hotspot @%dx}
<}


if {[N leshort 8 0 0 {} {} x {}]} {>

emit {\b%d}
<}
}} 121 {ktrace {
if {[N leshort 4 0 0 {} {} == 7]} {>

	if {[N leshort 6 0 0 {} {} < 3]} {>

	emit {NetBSD ktrace file version %d}

		if {[S string 12 0 {} {} x {}]} {>

		emit {from %s}
<}

		if {[S string 56 0 {} {} x {}]} {>

		emit {\b, emulation %s}
<}

		if {[N lelong 8 0 0 {} {} < 65536]} {>

		emit {\b, pid=%d}
<}

<}

<}
}} 122 {PIT-entry {
if {[N lequad 0 0 0 & 18446744060824649724 == 0]} {>

	if {[N byte 36 0 0 {} {} != 0]} {>

		if {[S string 36 0 {} {} > \0]} {>

		emit %-.32s
<}

		if {[N lelong 12 0 0 & 2 == 2]} {>

		emit {\b+RW}
<}

		if {[N lelong 8 0 0 {} {} x {}]} {>

		emit (0x%x)
<}

		if {[S string 68 0 {} {} > \0]} {>

		emit {"%-.64s"}
<}

<}

<}
}} 165 {gpt-mbr-type {
if {[N byte 450 0 0 {} {} == 238]} {>

	if {[N lelong 454 0 0 {} {} == 1]} {>

		if {[S string 462 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

		emit {\b (with hybrid MBR)}
<}

<}

	if {[N lelong 454 0 0 {} {} != 1]} {>

	emit {\b (nonstandard: not at LBA 1)}
<}

<}


if {[N byte 466 0 0 {} {} == 238]} {>

	if {[N lelong 470 0 0 {} {} == 1]} {>

		if {[S string 478 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

			if {[S string 446 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

			emit {\b (with hybrid MBR)}
<}

<}

		if {[S string 478 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

		emit {\b (with hybrid MBR)}
<}

<}

	if {[N lelong 470 0 0 {} {} != 1]} {>

	emit {\b (nonstandard: not at LBA 1)}
<}

<}


if {[N byte 482 0 0 {} {} == 238]} {>

	if {[N lelong 486 0 0 {} {} == 1]} {>

		if {[S string 494 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

			if {[S string 446 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

			emit {\b (with hybrid MBR)}
<}

<}

		if {[S string 494 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

		emit {\b (with hybrid MBR)}
<}

<}

	if {[N lelong 486 0 0 {} {} != 1]} {>

	emit {\b (nonstandard: not at LBA 1)}
<}

<}


if {[N byte 498 0 0 {} {} == 238]} {>

	if {[N lelong 502 0 0 {} {} == 1]} {>

		if {[S string 446 0 {} {} ne \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

		emit {\b (with hybrid MBR)}
<}

<}

	if {[N lelong 502 0 0 {} {} != 1]} {>

	emit {\b (nonstandard: not at LBA 1)}
<}

<}
} gpt-table {
if {[N leshort 10 0 0 {} {} x {}]} {>

emit {\b, version %u}
<}


if {[N leshort 8 0 0 {} {} x {}]} {>

emit {\b.%u}
<}


if {[N lelong 56 0 0 {} {} x {}]} {>

emit {\b, GUID: %08x}
<}


if {[N leshort 60 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}


if {[N leshort 62 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}


if {[N beshort 64 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}


if {[N beshort 66 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}


if {[N belong 68 0 0 {} {} x {}]} {>

emit {\b%08x}
<}


if {[N lequad 32 0 0 + 1 x {}]} {>

emit {\b, disk size: %lld sectors}
<}
}} 177 {elf-mips {
switch -- [Nv lelong 0 0 & 4026531840] 0 {>;emit MIPS-I;<} 268435456 {>;emit MIPS-II;<} 536870912 {>;emit MIPS-III;<} 805306368 {>;emit MIPS-IV;<} 1073741824 {>;emit MIPS-V;<} 1342177280 {>;emit MIPS32;<} 1610612736 {>;emit MIPS64;<} 1879048192 {>;emit {MIPS32 rel2};<} -2147483648 {>;emit {MIPS64 rel2};<} -1879048192 {>;emit {MIPS32 rel6};<} -1610612736 {>;emit {MIPS64 rel6};<} 
<
} elf-sparc {
switch -- [Nv lelong 0 0 & 16776960] 256 {>;emit {V8+ Required,};<} 512 {>;emit {Sun UltraSPARC1 Extensions Required,};<} 1024 {>;emit {HaL R1 Extensions Required,};<} 2048 {>;emit {Sun UltraSPARC3 Extensions Required,};<} 
<


switch -- [Nv lelong 0 0 & 3] 0 {>;emit {total store ordering,};<} 1 {>;emit {partial store ordering,};<} 2 {>;emit {relaxed memory ordering,};<} 
<
} elf-pa-risc {
if {[N leshort 2 0 0 {} {} == 532]} {>

emit 2.0
<}


if {[N leshort 0 0 0 {} {} & 8]} {>

emit (LP64)
<}
} elf-le {
switch -- [Nv leshort 16 0 {} {}] 0 {>;emit {no file type,}
mime application/octet-stream
;<} 1 {>;emit relocatable,
mime application/x-object
;<} 2 {>;emit executable,
mime application/x-executable
;<} 3 {>;emit {shared object,}
mime application/x-sharedlib
;<} 4 {>;emit {core file}
mime application/x-coredump
;<} 
<


if {[N leshort 16 0 0 {} {} & 65280]} {>

emit processor-specific,
<}


if {[S clear 18 0 {} {} x {}]} {>

<}


switch -- [Nv leshort 18 0 {} {}] 0 {>;emit {no machine,};<} 1 {>;emit {AT&T WE32100,};<} 2 {>;emit SPARC,;<} 3 {>;emit {Intel 80386,};<} 4 {>;emit {Motorola m68k,}

	if {[N byte 4 0 0 {} {} == 1]} {>

		if {[N lelong 36 0 0 {} {} & 16777216]} {>

		emit 68000,
<}

		if {[N lelong 36 0 0 {} {} & 8454144]} {>

		emit CPU32,
<}

		if {[N lelong 36 0 0 {} {} == 0]} {>

		emit 68020,
<}

<}
;<} 5 {>;emit {Motorola m88k,};<} 6 {>;emit {Intel 80486,};<} 7 {>;emit {Intel 80860,};<} 8 {>;emit MIPS,

	if {[N byte 4 0 0 {} {} == 1]} {>

		if {[N lelong 36 0 0 {} {} & 32]} {>

		emit N32
<}

<}
;<} 10 {>;emit MIPS,

	if {[N byte 4 0 0 {} {} == 1]} {>

		if {[N lelong 36 0 0 {} {} & 32]} {>

		emit N32
<}

<}
;<} 8 {>;
	switch -- [Nv byte 4 0 {} {}] 1 {>;U 177 elf-mips
;<} 2 {>;U 177 elf-mips
;<} 
<
;<} 9 {>;emit Amdahl,;<} 10 {>;emit {MIPS (deprecated),};<} 11 {>;emit RS6000,;<} 15 {>;emit PA-RISC,

	switch -- [Nv byte 4 0 {} {}] 1 {>;U 177 elf-pa-risc
;<} 2 {>;U 177 elf-pa-risc
;<} 
<
;<} 16 {>;emit nCUBE,;<} 17 {>;emit {Fujitsu VPP500,};<} 18 {>;emit SPARC32PLUS,

	if {[N byte 4 0 0 {} {} == 1]} {>
U 177 elf-sparc

<}
;<} 19 {>;emit {Intel 80960,};<} 20 {>;emit {PowerPC or cisco 4500,};<} 21 {>;emit {64-bit PowerPC or cisco 7500,};<} 22 {>;emit {IBM S/390,};<} 23 {>;emit {Cell SPU,};<} 24 {>;emit {cisco SVIP,};<} 25 {>;emit {cisco 7200,};<} 36 {>;emit {NEC V800 or cisco 12000,};<} 37 {>;emit {Fujitsu FR20,};<} 38 {>;emit {TRW RH-32,};<} 39 {>;emit {Motorola RCE,};<} 40 {>;emit ARM,

	if {[N byte 4 0 0 {} {} == 1]} {>

		switch -- [Nv lelong 36 0 & 4278190080] 67108864 {>;emit EABI4;<} 83886080 {>;emit EABI5;<} 
<

		if {[N lelong 36 0 0 {} {} & 8388608]} {>

		emit BE8
<}

		if {[N lelong 36 0 0 {} {} & 4194304]} {>

		emit LE8
<}

<}
;<} 41 {>;emit Alpha,;<} 42 {>;emit {Renesas SH,};<} 43 {>;emit {SPARC V9,}

	if {[N byte 4 0 0 {} {} == 2]} {>
U 177 elf-sparc

<}
;<} 44 {>;emit {Siemens Tricore Embedded Processor,};<} 45 {>;emit {Argonaut RISC Core, Argonaut Technologies Inc.,};<} 46 {>;emit {Renesas H8/300,};<} 47 {>;emit {Renesas H8/300H,};<} 48 {>;emit {Renesas H8S,};<} 49 {>;emit {Renesas H8/500,};<} 50 {>;emit IA-64,;<} 51 {>;emit {Stanford MIPS-X,};<} 52 {>;emit {Motorola Coldfire,};<} 53 {>;emit {Motorola M68HC12,};<} 54 {>;emit {Fujitsu MMA,};<} 55 {>;emit {Siemens PCP,};<} 56 {>;emit {Sony nCPU,};<} 57 {>;emit {Denso NDR1,};<} 58 {>;emit Start*Core,;<} 59 {>;emit {Toyota ME16,};<} 60 {>;emit ST100,;<} 61 {>;emit {Tinyj emb.,};<} 62 {>;emit x86-64,;<} 63 {>;emit {Sony DSP,};<} 64 {>;emit {DEC PDP-10,};<} 65 {>;emit {DEC PDP-11,};<} 66 {>;emit FX66,;<} 67 {>;emit {ST9+ 8/16 bit,};<} 68 {>;emit {ST7 8 bit,};<} 69 {>;emit MC68HC16,;<} 70 {>;emit MC68HC11,;<} 71 {>;emit MC68HC08,;<} 72 {>;emit MC68HC05,;<} 73 {>;emit {SGI SVx or Cray NV1,};<} 74 {>;emit {ST19 8 bit,};<} 75 {>;emit {Digital VAX,};<} 76 {>;emit {Axis cris,};<} 77 {>;emit {Infineon 32-bit embedded,};<} 78 {>;emit {Element 14 64-bit DSP,};<} 79 {>;emit {LSI Logic 16-bit DSP,};<} 80 {>;emit MMIX,;<} 81 {>;emit {Harvard machine-independent,};<} 82 {>;emit {SiTera Prism,};<} 83 {>;emit {Atmel AVR 8-bit,};<} 84 {>;emit {Fujitsu FR30,};<} 85 {>;emit {Mitsubishi D10V,};<} 86 {>;emit {Mitsubishi D30V,};<} 87 {>;emit {NEC v850,};<} 88 {>;emit {Renesas M32R,};<} 89 {>;emit {Matsushita MN10300,};<} 90 {>;emit {Matsushita MN10200,};<} 91 {>;emit picoJava,;<} 92 {>;emit OpenRISC,;<} 93 {>;emit {ARC Cores Tangent-A5,};<} 94 {>;emit {Tensilica Xtensa,};<} 95 {>;emit {Alphamosaic VideoCore,};<} 96 {>;emit {Thompson Multimedia,};<} 97 {>;emit {NatSemi 32k,};<} 98 {>;emit {Tenor Network TPC,};<} 99 {>;emit {Trebia SNP 1000,};<} 100 {>;emit {STMicroelectronics ST200,};<} 101 {>;emit {Ubicom IP2022,};<} 102 {>;emit {MAX Processor,};<} 103 {>;emit {NatSemi CompactRISC,};<} 104 {>;emit {Fujitsu F2MC16,};<} 105 {>;emit {TI msp430,};<} 106 {>;emit {Analog Devices Blackfin,};<} 107 {>;emit {S1C33 Family of Seiko Epson,};<} 108 {>;emit {Sharp embedded,};<} 109 {>;emit {Arca RISC,};<} 110 {>;emit {PKU-Unity Ltd.,};<} 111 {>;emit {eXcess: 16/32/64-bit,};<} 112 {>;emit {Icera Deep Execution Processor,};<} 113 {>;emit {Altera Nios II,};<} 114 {>;emit {NatSemi CRX,};<} 115 {>;emit {Motorola XGATE,};<} 116 {>;emit {Infineon C16x/XC16x,};<} 117 {>;emit {Renesas M16C series,};<} 118 {>;emit {Microchip dsPIC30F,};<} 119 {>;emit {Freescale RISC core,};<} 120 {>;emit {Renesas M32C series,};<} 131 {>;emit {Altium TSK3000 core,};<} 132 {>;emit {Freescale RS08,};<} 134 {>;emit {Cyan Technology eCOG2,};<} 135 {>;emit {Sunplus S+core7 RISC,};<} 136 {>;emit {New Japan Radio (NJR) 24-bit DSP,};<} 137 {>;emit {Broadcom VideoCore III,};<} 138 {>;emit LatticeMico32,;<} 139 {>;emit {Seiko Epson C17 family,};<} 140 {>;emit {TI TMS320C6000 DSP family,};<} 141 {>;emit {TI TMS320C2000 DSP family,};<} 142 {>;emit {TI TMS320C55x DSP family,};<} 160 {>;emit {STMicroelectronics 64bit VLIW DSP,};<} 161 {>;emit {Cypress M8C,};<} 162 {>;emit {Renesas R32C series,};<} 163 {>;emit {NXP TriMedia family,};<} 164 {>;emit {QUALCOMM DSP6,};<} 165 {>;emit {Intel 8051 and variants,};<} 166 {>;emit {STMicroelectronics STxP7x family,};<} 167 {>;emit {Andes embedded RISC,};<} 168 {>;emit {Cyan eCOG1X family,};<} 169 {>;emit {Dallas MAXQ30,};<} 170 {>;emit {New Japan Radio (NJR) 16-bit DSP,};<} 171 {>;emit {M2000 Reconfigurable RISC,};<} 172 {>;emit {Cray NV2 vector architecture,};<} 173 {>;emit {Renesas RX family,};<} 174 {>;emit META,;<} 175 {>;emit {MCST Elbrus,};<} 176 {>;emit {Cyan Technology eCOG16 family,};<} 177 {>;emit {NatSemi CompactRISC,};<} 178 {>;emit {Freescale Extended Time Processing Unit,};<} 179 {>;emit {Infineon SLE9X,};<} 180 {>;emit {Intel L1OM,};<} 181 {>;emit {Intel K1OM,};<} 183 {>;emit {ARM aarch64,};<} 185 {>;emit {Atmel 32-bit family,};<} 186 {>;emit {STMicroeletronics STM8 8-bit,};<} 187 {>;emit {Tilera TILE64,};<} 188 {>;emit {Tilera TILEPro,};<} 189 {>;emit {Xilinx MicroBlaze 32-bit RISC,};<} 190 {>;emit {NVIDIA CUDA architecture,};<} 191 {>;emit {Tilera TILE-Gx,};<} 197 {>;emit {Renesas RL78 family,};<} 199 {>;emit {Renesas 78K0R,};<} 200 {>;emit {Freescale 56800EX,};<} 201 {>;emit {Beyond BA1,};<} 202 {>;emit {Beyond BA2,};<} 203 {>;emit {XMOS xCORE,};<} 204 {>;emit {Microchip 8-bit PIC(r),};<} 210 {>;emit {KM211 KM32,};<} 211 {>;emit {KM211 KMX32,};<} 212 {>;emit {KM211 KMX16,};<} 213 {>;emit {KM211 KMX8,};<} 214 {>;emit {KM211 KVARC,};<} 215 {>;emit {Paneve CDP,};<} 216 {>;emit {Cognitive Smart Memory,};<} 217 {>;emit {iCelero CoolEngine,};<} 218 {>;emit {Nanoradio Optimized RISC,};<} 243 {>;emit {UCB RISC-V,};<} 4183 {>;emit {AVR (unofficial),};<} 4185 {>;emit {MSP430 (unofficial),};<} 4643 {>;emit {Adapteva Epiphany (unofficial),};<} 9520 {>;emit {Morpho MT (unofficial),};<} 13104 {>;emit {FR30 (unofficial),};<} 13350 {>;emit {OpenRISC (obsolete),};<} 18056 {>;emit {Infineon C166 (unofficial),};<} 21569 {>;emit {Cygnus FRV (unofficial),};<} 23205 {>;emit {DLX (unofficial),};<} 30288 {>;emit {Cygnus D10V (unofficial),};<} 30326 {>;emit {Cygnus D30V (unofficial),};<} -32233 {>;emit {Ubicom IP2xxx (unofficial),};<} -31630 {>;emit {OpenRISC (obsolete),};<} -28635 {>;emit {Cygnus PowerPC (unofficial),};<} -28634 {>;emit {Alpha (unofficial),};<} -28607 {>;emit {Cygnus M32R (unofficial),};<} -28544 {>;emit {Cygnus V850 (unofficial),};<} -23664 {>;emit {IBM S/390 (obsolete),};<} -21561 {>;emit {Old Xtensa (unofficial),};<} -21179 {>;emit {xstormy16 (unofficial),};<} -17749 {>;emit {Old MicroBlaze (unofficial),,};<} -16657 {>;emit {Cygnus MN10300 (unofficial),};<} -8531 {>;emit {Cygnus MN10200 (unofficial),};<} -4083 {>;emit {Toshiba MeP (unofficial),};<} -336 {>;emit {Renesas M32C (unofficial),};<} -326 {>;emit {Vitesse IQ2000 (unofficial),};<} -325 {>;emit {NIOS (unofficial),};<} -275 {>;emit {Moxie (unofficial),};<} 
<


if {[S default 18 0 {} {} x {}]} {>

	if {[N leshort 18 0 0 {} {} x {}]} {>

	emit {*unknown arch 0x%x*}
<}

<}


switch -- [Nv lelong 20 0 {} {}] 0 {>;emit {invalid version};<} 1 {>;emit {version 1};<} 
<
}} 180 {pgp {
switch -- [Nv byte 0 0 {} {}] 103 {>;emit {Reserved (old)};<} 104 {>;emit {Public-Key Encrypted Session Key (old)};<} 105 {>;emit {Signature (old)};<} 106 {>;emit {Symmetric-Key Encrypted Session Key (old)};<} 107 {>;emit {One-Pass Signature (old)};<} 108 {>;emit {Secret-Key (old)};<} 109 {>;emit {Public-Key (old)};<} 110 {>;emit {Secret-Subkey (old)};<} 111 {>;emit {Compressed Data (old)};<} 112 {>;emit {Symmetrically Encrypted Data (old)};<} 113 {>;emit {Marker (old)};<} 114 {>;emit {Literal Data (old)};<} 115 {>;emit {Trust (old)};<} 116 {>;emit {User ID (old)};<} 117 {>;emit {Public-Subkey (old)};<} 118 {>;emit {Unused (old)};<} 119 {>;
	switch -- [Nv byte 1 0 & 192] 0 {>;emit Reserved;<} 64 {>;emit {Public-Key Encrypted Session Key};<} -128 {>;emit Signature;<} -64 {>;emit {Symmetric-Key Encrypted Session Key};<} 
<
;<} 120 {>;
	switch -- [Nv byte 1 0 & 192] 0 {>;emit {One-Pass Signature};<} 64 {>;emit Secret-Key;<} -128 {>;emit Public-Key;<} -64 {>;emit Secret-Subkey;<} 
<
;<} 121 {>;
	switch -- [Nv byte 1 0 & 192] 0 {>;emit {Compressed Data};<} 64 {>;emit {Symmetrically Encrypted Data};<} -128 {>;emit Marker;<} -64 {>;emit {Literal Data};<} 
<
;<} 122 {>;
	switch -- [Nv byte 1 0 & 192] 0 {>;emit Trust;<} 64 {>;emit {User ID};<} -128 {>;emit Public-Subkey;<} -64 {>;emit {Unused [z%x]};<} 
<
;<} 48 {>;
	switch -- [Nv byte 1 0 & 192] 0 {>;emit {Unused [0%x]};<} 64 {>;emit {User Attribute};<} -128 {>;emit {Sym. Encrypted and Integrity Protected Data };<} -64 {>;emit {Modification Detection Code};<} 
<
;<} 
<
} crypto {
switch -- [Nv byte 0 0 {} {}] 0 {>;emit {Plaintext or unencrypted data};<} 1 {>;emit IDEA;<} 2 {>;emit TripleDES;<} 3 {>;emit {CAST5 (128 bit key)};<} 4 {>;emit {Blowfish (128 bit key, 16 rounds)};<} 7 {>;emit {AES with 128-bit key};<} 8 {>;emit {AES with 192-bit key};<} 9 {>;emit {AES with 256-bit key};<} 10 {>;emit {Twofish with 256-bit key};<} 
<
} hash {
switch -- [Nv byte 0 0 {} {}] 1 {>;emit MD5;<} 2 {>;emit SHA-1;<} 3 {>;emit RIPE-MD/160;<} 8 {>;emit SHA256;<} 9 {>;emit SHA384;<} 10 {>;emit SHA512;<} 11 {>;emit SHA224;<} 
<
} chkcrypto {U 180 crypto


switch -- [Nv byte 1 0 {} {}] 0 {>;emit {Simple S2K};<} 1 {>;emit {Salted S2K};<} 3 {>;emit {Salted&Iterated S2K};<} 
<

U 180 hash
} keyprolog {
if {[N byte 0 0 0 {} {} == 4]} {>

<}


if {[N beldate 1 0 0 {} {} x {}]} {>

emit {created on %s -}
<}


switch -- [Nv byte 5 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign)};<} 2 {>;emit {RSA Encrypt-Only};<} 
<
} keyend {
if {[S string 0 0 {} {} eq \x00\x11\x01\x00\x01]} {>

emit e=65537
<}

U 180 crypto


switch -- [Nv byte 5 0 {} {}] -1 {>;emit checksummed
U 180 chkcrypto
;<} -2 {>;emit hashed
U 180 chkcrypto
;<} 
<
} x1024 {U 180 keyprolog


if {[S string 6 0 {} {} eq \x03\xfe]} {>

<}


if {[S string 6 0 {} {} eq \x03\xff]} {>

<}


if {[S string 6 0 {} {} eq \x04\x00]} {>

<}

U 180 keyend
} x2048 {U 180 keyprolog


if {[S string 6 0 {} {} eq \x80\x00]} {>

<}


if {[S string 6 0 {} {} eq \x07\xfe]} {>

<}


if {[S string 6 0 {} {} eq \x07\xff]} {>

<}

U 180 keyend
} x3072 {U 180 keyprolog


if {[S string 6 0 {} {} eq \x0b\xfe]} {>

<}


if {[S string 6 0 {} {} eq \x0b\xff]} {>

<}


if {[S string 6 0 {} {} eq \x0c\x00]} {>

<}

U 180 keyend
} x4096 {U 180 keyprolog


if {[S string 6 0 {} {} eq \x10\x00]} {>

<}


if {[S string 6 0 {} {} eq \x0f\xfe]} {>

<}


if {[S string 6 0 {} {} eq \x0f\xff]} {>

<}

U 180 keyend
} x8192 {U 180 keyprolog


if {[S string 6 0 {} {} eq \x20\x00]} {>

<}


if {[S string 6 0 {} {} eq \x1f\xfe]} {>

<}


if {[S string 6 0 {} {} eq \x1f\xff]} {>

<}

U 180 keyend
} pgpkey {
if {[S string 0 0 {} {} eq \x01\xd8]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xeb]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xfb]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xfd]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xf3]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xee]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xfe]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x01\xf4]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x0d]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x03]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x05]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x15]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x00]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x10]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x04]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x06]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x02\x16]} {>

emit 1024b
U 180 x1024

<}


if {[S string 0 0 {} {} eq \x03\x98]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xab]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xbb]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xbd]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xcd]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xb3]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xc3]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xc5]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xd5]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xae]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xbe]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xc0]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xd0]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xb4]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xc4]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xc6]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x03\xd6]} {>

emit 2048b
U 180 x2048

<}


if {[S string 0 0 {} {} eq \x05X]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05k]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\{]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\}]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x8d]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05s]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x83]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x85]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x95]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05n]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x7e]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x80]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x90]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05t]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x84]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x86]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x05\x96]} {>

emit 3072b
U 180 x3072

<}


if {[S string 0 0 {} {} eq \x07\[]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07\x18]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07+]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07\;]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07=]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07M]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x073]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07C]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07E]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07U]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07.]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07>]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07@]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07P]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x074]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07D]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07F]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x07V]} {>

emit 4096b
U 180 x4096

<}


if {[S string 0 0 {} {} eq \x0e\[]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e\x18]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e+]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e\;]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e=]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eM]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e3]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eC]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eE]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eU]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e.]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e>]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e@]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eP]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0e4]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eD]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eF]} {>

emit 8192b
U 180 x8192

<}


if {[S string 0 0 {} {} eq \x0eV]} {>

emit 8192b
U 180 x8192

<}
}} 185 {aportisdoc {
if {[N beshort [I 78 belong 0 0 0 0] 0 0 {} {} == 1]} {>

emit {\b, uncompressed}
<}


if {[N beshort [I 78 belong 0 0 0 0] 0 0 {} {} > 1]} {>

	if {[N belong [I 78 belong 0 + 0 4] 0 0 {} {} x {}]} {>

	emit {\b, %d bytes uncompressed}
<}

<}
}} 193 {sereal {
if {[N byte 4 0 0 & 15 x {}]} {>

emit {(version %d,}
<}


switch -- [Nv byte 4 0 & 240] 0 {>;emit uncompressed);<} 16 {>;emit {compressed with non-incremental Snappy)};<} 32 {>;emit {compressed with incremental Snappy)};<} 
<


if {[N byte 4 0 0 & 240 > 32]} {>

emit {unknown subformat, flag: %d>>4)}
<}
}} 210 {mach-o-cpu {
switch -- [Nv belong 0 0 & 16777216] 0 {>;
	switch -- [Nv belong 0 0 & 16777215] 1 {>;
		switch -- [Nv belong 4 0 & 16777215] 0 {>;emit vax;<} 1 {>;emit vax11/780;<} 2 {>;emit vax11/785;<} 3 {>;emit vax11/750;<} 4 {>;emit vax11/730;<} 5 {>;emit uvaxI;<} 6 {>;emit uvaxII;<} 7 {>;emit vax8200;<} 8 {>;emit vax8500;<} 9 {>;emit vax8600;<} 10 {>;emit vax8650;<} 11 {>;emit vax8800;<} 12 {>;emit uvaxIII;<} 
<

		if {[N belong 4 0 0 & 16777215 > 12]} {>

		emit {vax subarchitecture=%d}
<}
;<} 2 {>;emit romp;<} 3 {>;emit architecture=3;<} 4 {>;emit ns32032;<} 5 {>;emit ns32332;<} 6 {>;emit m68k;<} 7 {>;
		switch -- [Nv belong 4 0 & 15] 3 {>;emit i386;<} 4 {>;emit i486

			switch -- [Nv belong 4 0 & 16777200] 0 {>;;<} 128 {>;emit {\bsx};<} 
<
;<} 5 {>;emit i586;<} 6 {>;
			switch -- [Nv belong 4 0 & 16777200] 0 {>;emit p6;<} 16 {>;emit pentium_pro;<} 32 {>;emit pentium_2_m0x20;<} 48 {>;emit pentium_2_m3;<} 64 {>;emit pentium_2_m0x40;<} 80 {>;emit pentium_2_m5;<} 
<

			if {[N belong 4 0 0 & 16777200 > 80]} {>

			emit pentium_2_m0x%x
<}
;<} 7 {>;emit celeron

			switch -- [Nv belong 4 0 & 16777200] 0 {>;emit {\b_m0x%x};<} 16 {>;emit {\b_m0x%x};<} 32 {>;emit {\b_m0x%x};<} 48 {>;emit {\b_m0x%x};<} 64 {>;emit {\b_m0x%x};<} 80 {>;emit {\b_m0x%x};<} 96 {>;;<} 112 {>;emit {\b_mobile};<} 
<

			if {[N belong 4 0 0 & 16777200 > 112]} {>

			emit {\b_m0x%x}
<}
;<} 8 {>;emit pentium_3

			switch -- [Nv belong 4 0 & 16777200] 0 {>;;<} 16 {>;emit {\b_m};<} 32 {>;emit {\b_xeon};<} 
<

			if {[N belong 4 0 0 & 16777200 > 32]} {>

			emit {\b_m0x%x}
<}
;<} 9 {>;emit pentiumM

			if {[N belong 4 0 0 & 16777200 == 0]} {>

<}

			if {[N belong 4 0 0 & 16777200 > 0]} {>

			emit {\b_m0x%x}
<}
;<} 10 {>;emit pentium_4

			switch -- [Nv belong 4 0 & 16777200] 0 {>;;<} 16 {>;emit {\b_m};<} 
<

			if {[N belong 4 0 0 & 16777200 > 16]} {>

			emit {\b_m0x%x}
<}
;<} 11 {>;emit itanium

			switch -- [Nv belong 4 0 & 16777200] 0 {>;;<} 16 {>;emit {\b_2};<} 
<

			if {[N belong 4 0 0 & 16777200 > 16]} {>

			emit {\b_m0x%x}
<}
;<} 12 {>;emit xeon

			switch -- [Nv belong 4 0 & 16777200] 0 {>;;<} 16 {>;emit {\b_mp};<} 
<

			if {[N belong 4 0 0 & 16777200 > 16]} {>

			emit {\b_m0x%x}
<}
;<} 
<

		if {[N belong 4 0 0 & 15 > 12]} {>

		emit {ia32 family=%d}

			if {[N belong 4 0 0 & 16777200 == 0]} {>

<}

			if {[N belong 4 0 0 & 16777200 > 0]} {>

			emit model=%x
<}

<}
;<} 8 {>;emit mips

		switch -- [Nv belong 4 0 & 16777215] 1 {>;emit R2300;<} 2 {>;emit R2600;<} 3 {>;emit R2800;<} 4 {>;emit R2000a;<} 5 {>;emit R2000;<} 6 {>;emit R3000a;<} 7 {>;emit R3000;<} 
<

		if {[N belong 4 0 0 & 16777215 > 7]} {>

		emit subarchitecture=%d
<}
;<} 9 {>;emit ns32532;<} 10 {>;emit mc98000;<} 11 {>;emit hppa

		switch -- [Nv belong 4 0 & 16777215] 0 {>;emit 7100;<} 1 {>;emit 7100LC;<} 
<

		if {[N belong 4 0 0 & 16777215 > 1]} {>

		emit subarchitecture=%d
<}
;<} 12 {>;emit arm

		switch -- [Nv belong 4 0 & 16777215] 0 {>;;<} 1 {>;emit subarchitecture=%d;<} 2 {>;emit subarchitecture=%d;<} 3 {>;emit subarchitecture=%d;<} 4 {>;emit subarchitecture=%d;<} 5 {>;emit {\bv4t};<} 6 {>;emit {\bv6};<} 7 {>;emit {\bv5tej};<} 8 {>;emit {\bxscale};<} 9 {>;emit {\bv7};<} 10 {>;emit {\bv7f};<} 11 {>;emit {\bv7s};<} 12 {>;emit {\bv7k};<} 13 {>;emit {\bv8};<} 14 {>;emit {\bv6m};<} 15 {>;emit {\bv7m};<} 16 {>;emit {\bv7em};<} 
<

		if {[N belong 4 0 0 & 16777215 > 16]} {>

		emit subarchitecture=%d
<}
;<} 13 {>;
		switch -- [Nv belong 4 0 & 16777215] 0 {>;emit mc88000;<} 1 {>;emit mc88100;<} 2 {>;emit mc88110;<} 
<

		if {[N belong 4 0 0 & 16777215 > 2]} {>

		emit {mc88000 subarchitecture=%d}
<}
;<} 14 {>;emit SPARC;<} 15 {>;emit i860g;<} 16 {>;emit alpha;<} 17 {>;emit rs6000;<} 18 {>;emit ppc

		switch -- [Nv belong 4 0 & 16777215] 0 {>;;<} 1 {>;emit {\b_601};<} 2 {>;emit {\b_602};<} 3 {>;emit {\b_603};<} 4 {>;emit {\b_603e};<} 5 {>;emit {\b_603ev};<} 6 {>;emit {\b_604};<} 7 {>;emit {\b_604e};<} 8 {>;emit {\b_620};<} 9 {>;emit {\b_650};<} 10 {>;emit {\b_7400};<} 11 {>;emit {\b_7450};<} 100 {>;emit {\b_970};<} 
<

		if {[N belong 4 0 0 & 16777215 > 100]} {>

		emit subarchitecture=%d
<}
;<} 
<

	if {[N belong 0 0 0 & 16777215 > 18]} {>

	emit architecture=%d
<}
;<} 16777216 {>;
	switch -- [Nv belong 0 0 & 16777215] 0 {>;emit {64-bit architecture=%d};<} 1 {>;emit {64-bit architecture=%d};<} 2 {>;emit {64-bit architecture=%d};<} 3 {>;emit {64-bit architecture=%d};<} 4 {>;emit {64-bit architecture=%d};<} 5 {>;emit {64-bit architecture=%d};<} 6 {>;emit {64-bit architecture=%d};<} 7 {>;emit x86_64

		switch -- [Nv belong 4 0 & 16777215] 0 {>;emit subarchitecture=%d;<} 1 {>;emit subarchitecture=%d;<} 2 {>;emit subarchitecture=%d;<} 3 {>;;<} 4 {>;emit {\b_arch1};<} 8 {>;emit {\b_haswell};<} 
<

		if {[N belong 4 0 0 & 16777215 > 4]} {>

		emit subarchitecture=%d
<}
;<} 8 {>;emit {64-bit architecture=%d};<} 9 {>;emit {64-bit architecture=%d};<} 10 {>;emit {64-bit architecture=%d};<} 11 {>;emit {64-bit architecture=%d};<} 12 {>;emit arm64

		switch -- [Nv belong 4 0 & 16777215] 0 {>;;<} 1 {>;emit {\bv8};<} 
<
;<} 13 {>;emit {64-bit architecture=%d};<} 14 {>;emit {64-bit architecture=%d};<} 15 {>;emit {64-bit architecture=%d};<} 16 {>;emit {64-bit architecture=%d};<} 17 {>;emit {64-bit architecture=%d};<} 18 {>;emit ppc64

		switch -- [Nv belong 4 0 & 16777215] 0 {>;;<} 1 {>;emit {\b_601};<} 2 {>;emit {\b_602};<} 3 {>;emit {\b_603};<} 4 {>;emit {\b_603e};<} 5 {>;emit {\b_603ev};<} 6 {>;emit {\b_604};<} 7 {>;emit {\b_604e};<} 8 {>;emit {\b_620};<} 9 {>;emit {\b_650};<} 10 {>;emit {\b_7400};<} 11 {>;emit {\b_7450};<} 100 {>;emit {\b_970};<} 
<

		if {[N belong 4 0 0 & 16777215 > 100]} {>

		emit subarchitecture=%d
<}
;<} 
<

	if {[N belong 0 0 0 & 16777215 > 18]} {>

	emit {64-bit architecture=%d}
<}
;<} 
<
} mach-o-be {
if {[N byte 0 0 0 {} {} == 207]} {>

emit 64-bit
<}

U 210 mach-o-cpu


switch -- [Nv belong 12 0 {} {}] 1 {>;emit object;<} 2 {>;emit executable;<} 3 {>;emit {fixed virtual memory shared library};<} 4 {>;emit core;<} 5 {>;emit {preload executable};<} 6 {>;emit {dynamically linked shared library};<} 7 {>;emit {dynamic linker};<} 8 {>;emit bundle;<} 9 {>;emit {dynamically linked shared library stub};<} 10 {>;emit {dSYM companion file};<} 11 {>;emit {kext bundle};<} 
<


if {[N belong 12 0 0 {} {} > 11]} {>

	if {[N belong 12 0 0 {} {} x {}]} {>

	emit filetype=%d
<}

<}


if {[N belong 24 0 0 {} {} > 0]} {>

emit {\b, flags:<}

	if {[N belong 24 0 0 {} {} & 1]} {>

	emit {\bNOUNDEFS}
<}

	if {[N belong 24 0 0 {} {} & 2]} {>

	emit {\b|INCRLINK}
<}

	if {[N belong 24 0 0 {} {} & 4]} {>

	emit {\b|DYLDLINK}
<}

	if {[N belong 24 0 0 {} {} & 8]} {>

	emit {\b|BINDATLOAD}
<}

	if {[N belong 24 0 0 {} {} & 16]} {>

	emit {\b|PREBOUND}
<}

	if {[N belong 24 0 0 {} {} & 32]} {>

	emit {\b|SPLIT_SEGS}
<}

	if {[N belong 24 0 0 {} {} & 64]} {>

	emit {\b|LAZY_INIT}
<}

	if {[N belong 24 0 0 {} {} & 128]} {>

	emit {\b|TWOLEVEL}
<}

	if {[N belong 24 0 0 {} {} & 256]} {>

	emit {\b|FORCE_FLAT}
<}

	if {[N belong 24 0 0 {} {} & 512]} {>

	emit {\b|NOMULTIDEFS}
<}

	if {[N belong 24 0 0 {} {} & 1024]} {>

	emit {\b|NOFIXPREBINDING}
<}

	if {[N belong 24 0 0 {} {} & 2048]} {>

	emit {\b|PREBINDABLE}
<}

	if {[N belong 24 0 0 {} {} & 4096]} {>

	emit {\b|ALLMODSBOUND}
<}

	if {[N belong 24 0 0 {} {} & 8192]} {>

	emit {\b|SUBSECTIONS_VIA_SYMBOLS}
<}

	if {[N belong 24 0 0 {} {} & 16384]} {>

	emit {\b|CANONICAL}
<}

	if {[N belong 24 0 0 {} {} & 32768]} {>

	emit {\b|WEAK_DEFINES}
<}

	if {[N belong 24 0 0 {} {} & 65536]} {>

	emit {\b|BINDS_TO_WEAK}
<}

	if {[N belong 24 0 0 {} {} & 131072]} {>

	emit {\b|ALLOW_STACK_EXECUTION}
<}

	if {[N belong 24 0 0 {} {} & 262144]} {>

	emit {\b|ROOT_SAFE}
<}

	if {[N belong 24 0 0 {} {} & 524288]} {>

	emit {\b|SETUID_SAFE}
<}

	if {[N belong 24 0 0 {} {} & 1048576]} {>

	emit {\b|NO_REEXPORTED_DYLIBS}
<}

	if {[N belong 24 0 0 {} {} & 2097152]} {>

	emit {\b|PIE}
<}

	if {[N belong 24 0 0 {} {} & 4194304]} {>

	emit {\b|DEAD_STRIPPABLE_DYLIB}
<}

	if {[N belong 24 0 0 {} {} & 8388608]} {>

	emit {\b|HAS_TLV_DESCRIPTORS}
<}

	if {[N belong 24 0 0 {} {} & 16777216]} {>

	emit {\b|NO_HEAP_EXECUTION}
<}

	if {[N belong 24 0 0 {} {} & 33554432]} {>

	emit {\b|APP_EXTENSION_SAFE}
<}

	if {[N belong 24 0 0 {} {} x {}]} {>

	emit {\b>}
<}

<}
}} 219 {lharc-file {
if {[S string 2 0 {} {} eq -]} {>

	if {[S string 6 0 {} {} eq -]} {>

		if {[N byte 20 0 0 {} {} < 4]} {>

			if {[S regex 3 0 {} {} eq ^(lh\[0-9a-ex\]|lz\[s2-8\]|pm\[012\]|pc1)]} {>

			emit {\b }

				if {[S string 2 0 {} {} eq -lz]} {>

				emit {\b }

					if {[S string 2 0 {} {} eq -lzs]} {>

					emit {LHa/LZS archive data}
<}

					if {[S regex 3 0 {} {} eq ^lz\[45\]]} {>

					emit {LHarc 1.x archive data}
<}

					if {[S regex 3 0 {} {} eq ^lz\[2378\]]} {>

					emit {LArc archive}
<}

				ext lzs

<}

				if {[S string 2 0 {} {} eq -lh]} {>

				emit {\b }

					if {[S regex 3 0 {} {} eq ^lh\[01\]]} {>

					emit {LHarc 1.x/ARX archive data}

						if {[S string 2 0 {} {} eq -lh1]} {>

						emit {\b }
						ext lha/lzh/ice

<}

<}

					if {[S regex 3 0 {} {} eq ^lh\[23d\]]} {>

					emit {LHa 2.x? archive data}
<}

					if {[S regex 3 0 {} {} eq ^lh\[7\]]} {>

					emit {LHa (2.x)/LHark archive data}
<}

					if {[S regex 3 0 {} {} eq ^lh\[456\]]} {>

					emit {LHa (2.x) archive data}

						if {[S string 2 0 {} {} eq -lh5]} {>

						emit {\b }
						ext lha/lzh/rom/bin

<}

<}

					if {[S regex 3 0 {} {} eq ^lh\[89a-ce\]]} {>

					emit {LHa (Joe Jared) archive}
<}

					if {[S string 2 0 {} {} eq -lhx]} {>

					emit {LHa (UNLHA32) archive}
<}

					if {[S regex 3 0 {} {} ne ^(lh1|lh5)]} {>

					emit {\b }
					ext lha/lzh

<}

					if {[S default 2 0 {} {} x {}]} {>

					emit {LHa (unknown) archive}
<}

<}

				if {[S regex 3 0 {} {} eq ^pm\[012\]]} {>

				emit {PMarc archive data}
				ext pma

<}

				if {[S string 3 0 {} {} x {}]} {>

				emit {[%3.3s]}
U 219 lharc-header

<}

			mime application/x-lzh-compressed

<}

<}

<}

<}
} lharc-header {
if {[N byte 0 0 0 {} {} x {}]} {>

<}


switch -- [Nv byte 20 0 {} {}] 1 {>;
	if {[N byte [I 21 byte 0 + 0 24] 0 0 {} {} < 33]} {>

	emit {\b, 0x%x OS}
<}

	if {[N byte [I 21 byte 0 + 0 24] 0 0 {} {} > 32]} {>

	emit {\b, '%c' OS}
<}
;<} 2 {>;
	if {[N byte 23 0 0 {} {} < 33]} {>

	emit {\b, 0x%x OS}
<}

	if {[N byte 23 0 0 {} {} > 32]} {>

	emit {\b, '%c' OS}
<}
;<} 
<


if {[N byte 20 0 0 {} {} < 2]} {>

	if {[N byte 21 0 0 {} {} > 0]} {>

	emit {\b, with}

		if {[S pstring 21 0 {} {} x {}]} {>

		emit {"%s"}
<}

<}

<}
} rar-file-header {
switch -- [Nv byte 24 0 {} {}] 15 {>;emit {\b, v1.5};<} 20 {>;emit {\b, v2.0};<} 29 {>;emit {\b, v4};<} 
<


switch -- [Nv byte 15 0 {} {}] 0 {>;emit {\b, os: MS-DOS};<} 1 {>;emit {\b, os: OS/2};<} 2 {>;emit {\b, os: Win32};<} 3 {>;emit {\b, os: Unix};<} 4 {>;emit {\b, os: Mac OS};<} 5 {>;emit {\b, os: BeOS};<} 
<
} rar-archive-header {
if {[N leshort 3 0 0 & 511 > 0]} {>

emit {\b, flags:}

	if {[N leshort 3 0 0 {} {} & 1]} {>

	emit ArchiveVolume
<}

	if {[N leshort 3 0 0 {} {} & 2]} {>

	emit Commented
<}

	if {[N leshort 3 0 0 {} {} & 4]} {>

	emit Locked
<}

	if {[N leshort 3 0 0 {} {} & 16]} {>

	emit NewVolumeNaming
<}

	if {[N leshort 3 0 0 {} {} & 8]} {>

	emit Solid
<}

	if {[N leshort 3 0 0 {} {} & 32]} {>

	emit Authenticated
<}

	if {[N leshort 3 0 0 {} {} & 64]} {>

	emit RecoveryRecordPresent
<}

	if {[N leshort 3 0 0 {} {} & 128]} {>

	emit EncryptedBlockHeader
<}

	if {[N leshort 3 0 0 {} {} & 256]} {>

	emit FirstVolume
<}

<}
}} 235 {jpeg_segment {
switch -- [Nv beshort 0 0 {} {}] -2 {>;
	if {[S pstring 2 0 {H J} {} x {}]} {>

	emit {\b, comment: "%s"}
<}
;<} -64 {>;U 235 jpeg_segment

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {\b, baseline, precision %d}
<}

	if {[N beshort 7 0 0 {} {} x {}]} {>

	emit {\b, %dx}
<}

	if {[N beshort 5 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b, frames %d}
<}
;<} -63 {>;U 235 jpeg_segment

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {\b, extended sequential, precision %d}
<}

	if {[N beshort 7 0 0 {} {} x {}]} {>

	emit {\b, %dx}
<}

	if {[N beshort 5 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b, frames %d}
<}
;<} -62 {>;U 235 jpeg_segment

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {\b, progressive, precision %d}
<}

	if {[N beshort 7 0 0 {} {} x {}]} {>

	emit {\b, %dx}
<}

	if {[N beshort 5 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b, frames %d}
<}
;<} -60 {>;U 235 jpeg_segment
;<} -31 {>;
	if {[S string 4 0 {} {} eq Exif]} {>

	emit {\b, Exif Standard: [}

		if {[S string 10 0 {} {} x {}]} {>

		emit {\b]}
<}

<}
;<} 
<


if {[N beshort 0 0 0 & 65504 == 65504]} {>
U 235 jpeg_segment

<}


if {[N beshort 0 0 0 & 65488 == 65488]} {>

	if {[N beshort 0 0 0 & 65504 != 65504]} {>
U 235 jpeg_segment

<}

<}
}} 239 {display-coff {
if {[N leshort 18 0 0 & 36480 == 0]} {>

	if {[S clear 0 0 {} {} x {}]} {>

<}

	switch -- [Nv leshort 0 0 {} {}] 332 {>;emit {Intel 80386};<} 1280 {>;emit {Hitachi SH big-endian};<} 1360 {>;emit {Hitachi SH little-endian};<} 
<

	if {[S default 0 0 {} {} x {}]} {>

		if {[N leshort 0 0 0 {} {} x {}]} {>

		emit {type 0x%04x}
<}

<}

	if {[N leshort 0 0 0 {} {} x {}]} {>

	emit COFF
<}

	if {[N leshort 18 0 0 {} {} ^ 2]} {>

	emit {object file}
<}

	if {[N leshort 18 0 0 {} {} & 2]} {>

	emit executable
<}

	if {[N leshort 18 0 0 {} {} & 1]} {>

	emit {\b, no relocation info}
<}

	if {[N leshort 18 0 0 {} {} & 4]} {>

	emit {\b, no line number info}
<}

	if {[N leshort 18 0 0 {} {} & 8]} {>

	emit {\b, stripped}
<}

	if {[N leshort 18 0 0 {} {} ^ 8]} {>

	emit {\b, not stripped}
<}

	if {[N leshort 2 0 0 {} {} < 2]} {>

	emit {\b, %d section}
<}

	if {[N leshort 2 0 0 {} {} > 1]} {>

	emit {\b, %d sections}
<}

	if {[N lelong 8 0 0 {} {} > 0]} {>

	emit {\b, symbol offset=0x%x}
<}

	if {[N lelong 12 0 0 {} {} > 0]} {>

	emit {\b, %d symbols}
<}

	if {[N leshort 16 0 0 {} {} > 0]} {>

	emit {\b, optional header size %d}
<}

<}
}} 240 {sega-mega-drive-header {
if {[N byte 288 0 0 {} {} > 32]} {>

	if {[S string 288 0 {} {} > \0]} {>

	emit {\b: "%.16s"}
<}

<}


if {[N byte 288 0 0 {} {} < 33]} {>

	if {[S string 336 0 {} {} > \0]} {>

	emit {\b: "%.16s"}
<}

<}


if {[S string 384 0 {} {} > \0]} {>

emit (%.14s

	if {[S string 272 0 {} {} > \0]} {>

	emit {\b, %.16s}
<}

<}


if {[N byte 384 0 0 {} {} == 0]} {>

	if {[S string 272 0 {} {} > \0]} {>

	emit (%.16s
<}

<}


if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b)}
<}
} sega-genesis-smd-header {
if {[N byte 0 0 0 {} {} x {}]} {>

emit {%dx16k blocks}
<}


if {[N byte 2 0 0 {} {} == 0]} {>

emit {\b, last in series or standalone}
<}


if {[N byte 2 0 0 {} {} > 0]} {>

emit {\b, split ROM}
<}
} sega-master-system-rom-header {
switch -- [Nv byte 15 0 & 240] 48 {>;emit {Sega Master System};<} 64 {>;emit {Sega Master System};<} 80 {>;emit {Sega Game Gear};<} 96 {>;emit {Sega Game Gear};<} 112 {>;emit {Sega Game Gear};<} 
<


if {[N byte 15 0 0 & 240 < 48]} {>

emit {Sega Master System / Game Gear}
<}


if {[N byte 15 0 0 & 240 > 112]} {>

emit {Sega Master System / Game Gear}
<}


if {[N byte 0 0 0 {} {} x {}]} {>

emit {ROM image:}
<}


switch -- [Nv byte 14 0 & 240] 16 {>;emit 1;<} 32 {>;emit 2;<} 48 {>;emit 3;<} 64 {>;emit 4;<} 80 {>;emit 5;<} 96 {>;emit 6;<} 112 {>;emit 7;<} -128 {>;emit 8;<} -112 {>;emit 9;<} -96 {>;emit 10;<} -80 {>;emit 11;<} -64 {>;emit 12;<} -48 {>;emit 13;<} -32 {>;emit 14;<} -16 {>;emit 15;<} 0 {>;
	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit %04x
<}
;<} 
<


if {[N byte 14 0 0 & 240 != 0]} {>

	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit {\b%04x}
<}

<}


if {[N byte 14 0 0 & 15 x {}]} {>

emit (Rev.%02d)
<}


switch -- [Nv byte 15 0 & 15] 10 {>;emit {(8 KB)};<} 11 {>;emit {(16 KB)};<} 12 {>;emit {(32 KB)};<} 13 {>;emit {(48 KB)};<} 14 {>;emit {(64 KB)};<} 15 {>;emit {(128 KB)};<} 0 {>;emit {(256 KB)};<} 1 {>;emit {(512 KB)};<} 2 {>;emit {(1 MB)};<} 
<
} sega-saturn-disc-header {
if {[S string 96 0 {} {} > \0]} {>

emit {\b: "%.32s"}
<}


if {[S string 32 0 {} {} > \0]} {>

emit (%.10s

	if {[S string 42 0 {} {} > \0]} {>

	emit {\b, %.6s)}
<}

	if {[N byte 42 0 0 {} {} == 0]} {>

	emit {\b)}
<}

<}
} sega-dreamcast-disc-header {
if {[S string 128 0 {} {} > \0]} {>

emit {\b: "%.32s"}
<}


if {[S string 64 0 {} {} > \0]} {>

emit (%.10s

	if {[S string 74 0 {} {} > \0]} {>

	emit {\b, %.6s)}
<}

	if {[N byte 74 0 0 {} {} == 0]} {>

	emit {\b)}
<}

<}
} nintendo-gcn-disc-common {
if {[S string 32 0 {} {} x {}]} {>

emit {"%.64s"}
<}


if {[S string 0 0 {} {} x {}]} {>

emit (%.6s
<}


if {[N byte 6 0 0 {} {} > 0]} {>

	switch -- [Nv byte 6 0 {} {}] 1 {>;emit {\b, Disc 2};<} 2 {>;emit {\b, Disc 3};<} 3 {>;emit {\b, Disc 4};<} 
<

<}


if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b, Rev.%02u)}
<}
} nintendo-3ds-NCCH {
if {[S string 256 0 {} {} eq NCCH]} {>

	if {[S string 336 0 {} {} > \0]} {>

	emit {\b: "%.16s"}
<}

	if {[N leshort 274 0 0 {} {} x {}]} {>

	emit (v%u)
<}

	if {[N byte 396 0 0 {} {} == 2]} {>

	emit {(New3DS only)}
<}

<}
}} 243 {partid {
switch -- [Nv byte 0 0 {} {}] 0 {>;emit Unused;<} 1 {>;emit {12-bit FAT};<} 2 {>;emit {XENIX /};<} 3 {>;emit {XENIX /usr};<} 4 {>;emit {16-bit FAT, less than 32M};<} 5 {>;emit {extended partition};<} 6 {>;emit {16-bit FAT, more than 32M};<} 7 {>;emit {OS/2 HPFS, NTFS, QNX2, Adv. UNIX};<} 8 {>;emit {AIX or os, or etc.};<} 9 {>;emit {AIX boot partition or Coherent};<} 10 {>;emit {O/2 boot manager or Coherent swap};<} 11 {>;emit {32-bit FAT};<} 12 {>;emit {32-bit FAT, LBA-mapped};<} 13 {>;emit {7XXX, LBA-mapped};<} 14 {>;emit {16-bit FAT, LBA-mapped};<} 15 {>;emit {extended partition, LBA-mapped};<} 16 {>;emit OPUS;<} 17 {>;emit {OS/2 DOS 12-bit FAT};<} 18 {>;emit {Compaq diagnostics};<} 20 {>;emit {OS/2 DOS 16-bit FAT <32M};<} 22 {>;emit {OS/2 DOS 16-bit FAT >=32M};<} 23 {>;emit {OS/2 hidden IFS};<} 24 {>;emit {AST Windows swapfile};<} 25 {>;emit {Willowtech Photon coS};<} 27 {>;emit {hidden win95 fat 32};<} 28 {>;emit {hidden win95 fat 32 lba};<} 29 {>;emit {hidden win95 fat 16 lba};<} 32 {>;emit {Willowsoft OFS1};<} 33 {>;emit reserved;<} 35 {>;emit reserved;<} 36 {>;emit {NEC DOS};<} 38 {>;emit reserved;<} 49 {>;emit reserved;<} 50 {>;emit {Alien Internet Services NOS};<} 51 {>;emit reserved;<} 52 {>;emit reserved;<} 53 {>;emit {JFS on OS2};<} 54 {>;emit reserved;<} 56 {>;emit Theos;<} 57 {>;emit {Plan 9, or Theos spanned};<} 58 {>;emit {Theos ver 4 4gb partition};<} 59 {>;emit {Theos ve 4 extended partition};<} 60 {>;emit {PartitionMagic recovery};<} 61 {>;emit {Hidden Netware};<} 64 {>;emit {VENIX 286 or LynxOS};<} 65 {>;emit PReP;<} 66 {>;emit {linux swap sharing DRDOS disk};<} 67 {>;emit {linux sharing DRDOS disk};<} 68 {>;emit {GoBack change utility};<} 69 {>;emit {Boot US Boot manager};<} 70 {>;emit {EUMEL/Elan or Ergos 3};<} 71 {>;emit {EUMEL/Elan or Ergos 3};<} 72 {>;emit {EUMEL/Elan or Ergos 3};<} 74 {>;emit {ALFX/THIN filesystem for DOS};<} 76 {>;emit {Oberon partition};<} 77 {>;emit QNX4.x;<} 78 {>;emit {QNX4.x 2nd part};<} 79 {>;emit {QNX4.x 3rd part};<} 80 {>;emit {DM (disk manager)};<} 81 {>;emit {DM6 Aux1 (or Novell)};<} 82 {>;emit {CP/M or Microport SysV/AT};<} 83 {>;emit {DM6 Aux3};<} 84 {>;emit {DM6 DDO};<} 85 {>;emit {EZ-Drive (disk manager)};<} 86 {>;emit {Golden Bow (disk manager)};<} 87 {>;emit {Drive PRO};<} 92 {>;emit {Priam Edisk (disk manager)};<} 97 {>;emit SpeedStor;<} 99 {>;emit {GNU HURD or Mach or Sys V/386};<} 100 {>;emit {Novell Netware 2.xx or Speedstore};<} 101 {>;emit {Novell Netware 3.xx};<} 102 {>;emit {Novell 386 Netware};<} 103 {>;emit Novell;<} 104 {>;emit Novell;<} 105 {>;emit Novell;<} 112 {>;emit {DiskSecure Multi-Boot};<} 113 {>;emit reserved;<} 115 {>;emit reserved;<} 116 {>;emit reserved;<} 117 {>;emit PC/IX;<} 118 {>;emit reserved;<} 119 {>;emit {M2FS/M2CS partition};<} 120 {>;emit {XOSL boot loader filesystem};<} -128 {>;emit {MINIX until 1.4a};<} -127 {>;emit {MINIX since 1.4b};<} -126 {>;emit {Linux swap or Solaris};<} -125 {>;emit {Linux native};<} -124 {>;emit {OS/2 hidden C: drive};<} -123 {>;emit {Linux extended partition};<} -122 {>;emit {NT FAT volume set};<} -121 {>;emit {NTFS volume set or HPFS mirrored};<} -118 {>;emit {Linux Kernel AiR-BOOT partition};<} -117 {>;emit {Legacy Fault tolerant FAT32};<} -116 {>;emit {Legacy Fault tolerant FAT32 ext};<} -115 {>;emit {Hidden free FDISK FAT12};<} -114 {>;emit {Linux Logical Volume Manager};<} -112 {>;emit {Hidden free FDISK FAT16};<} -111 {>;emit {Hidden free FDISK DOS EXT};<} -110 {>;emit {Hidden free FDISK FAT16 Big};<} -109 {>;emit {Amoeba filesystem};<} -108 {>;emit {Amoeba bad block table};<} -107 {>;emit {MIT EXOPC native partitions};<} -105 {>;emit {Hidden free FDISK FAT32};<} -104 {>;emit {Datalight ROM-DOS Super-Boot};<} -103 {>;emit {Mylex EISA SCSI};<} -102 {>;emit {Hidden free FDISK FAT16 LBA};<} -101 {>;emit {Hidden free FDISK EXT LBA};<} -97 {>;emit BSDI?;<} -96 {>;emit {IBM Thinkpad hibernation};<} -95 {>;emit {HP Volume expansion (SpeedStor)};<} -93 {>;emit {HP Volume expansion (SpeedStor)};<} -92 {>;emit {HP Volume expansion (SpeedStor)};<} -91 {>;emit {386BSD partition type};<} -90 {>;emit {OpenBSD partition type};<} -89 {>;emit {NeXTSTEP 486};<} -88 {>;emit {Apple UFS};<} -87 {>;emit {NetBSD partition type};<} -86 {>;emit {Olivetty Fat12 1.44MB Service part};<} -85 {>;emit {Apple Boot};<} -82 {>;emit {SHAG OS filesystem};<} -81 {>;emit {Apple HFS};<} -80 {>;emit {BootStar Dummy};<} -79 {>;emit reserved;<} -77 {>;emit reserved;<} -76 {>;emit reserved;<} -74 {>;emit reserved;<} -73 {>;emit {BSDI BSD/386 filesystem};<} -72 {>;emit {BSDI BSD/386 swap};<} -69 {>;emit {Boot Wizard Hidden};<} -66 {>;emit {Solaris 8 partition type};<} -65 {>;emit {Solaris partition type};<} -64 {>;emit CTOS;<} -63 {>;emit {DRDOS/sec (FAT-12)};<} -62 {>;emit {Hidden Linux};<} -61 {>;emit {Hidden Linux swap};<} -60 {>;emit {DRDOS/sec (FAT-16, < 32M)};<} -59 {>;emit {DRDOS/sec (EXT)};<} -58 {>;emit {DRDOS/sec (FAT-16, >= 32M)};<} -57 {>;emit {Syrinx (Cyrnix?) or HPFS disabled};<} -56 {>;emit {Reserved for DR-DOS 8.0+};<} -55 {>;emit {Reserved for DR-DOS 8.0+};<} -54 {>;emit {Reserved for DR-DOS 8.0+};<} -53 {>;emit {DR-DOS 7.04+ Secured FAT32 CHS};<} -52 {>;emit {DR-DOS 7.04+ Secured FAT32 LBA};<} -51 {>;emit {CTOS Memdump};<} -50 {>;emit {DR-DOS 7.04+ FAT16X LBA};<} -49 {>;emit {DR-DOS 7.04+ EXT LBA};<} -48 {>;emit {REAL/32 secure big partition};<} -47 {>;emit {Old Multiuser DOS FAT12};<} -44 {>;emit {Old Multiuser DOS FAT16 Small};<} -43 {>;emit {Old Multiuser DOS Extended};<} -42 {>;emit {Old Multiuser DOS FAT16 Big};<} -40 {>;emit {CP/M 86};<} -37 {>;emit {CP/M or Concurrent CP/M};<} -35 {>;emit {Hidden CTOS Memdump};<} -34 {>;emit {Dell PowerEdge Server utilities};<} -33 {>;emit {DG/UX virtual disk manager};<} -32 {>;emit {STMicroelectronics ST AVFS};<} -31 {>;emit {DOS access or SpeedStor 12-bit};<} -29 {>;emit {DOS R/O or Storage Dimensions};<} -28 {>;emit {SpeedStor 16-bit FAT < 1024 cyl.};<} -27 {>;emit reserved;<} -26 {>;emit reserved;<} -21 {>;emit BeOS;<} -18 {>;emit {GPT Protective MBR};<} -17 {>;emit {EFI system partition};<} -16 {>;emit {Linux PA-RISC boot loader};<} -15 {>;emit {SpeedStor or Storage Dimensions};<} -14 {>;emit {DOS 3.3+ Secondary};<} -13 {>;emit reserved;<} -12 {>;emit {SpeedStor large partition};<} -11 {>;emit {Prologue multi-volumen partition};<} -10 {>;emit reserved;<} -7 {>;emit {pCache: ext2/ext3 persistent cache};<} -6 {>;emit {Bochs x86 emulator};<} -5 {>;emit {VMware File System};<} -4 {>;emit {VMware Swap};<} -3 {>;emit {Linux RAID partition persistent sb};<} -2 {>;emit {LANstep or IBM PS/2 IML};<} -1 {>;emit {Xenix Bad Block Table};<} 
<
} DOS-filename {
if {[N byte 0 0 0 & 223 > 0]} {>

	if {[N byte 0 0 0 {} {} x {}]} {>

	emit {\b%c}

		if {[N byte 1 0 0 & 223 > 0]} {>

			if {[N byte 1 0 0 {} {} x {}]} {>

			emit {\b%c}

				if {[N byte 2 0 0 & 223 > 0]} {>

					if {[N byte 2 0 0 {} {} x {}]} {>

					emit {\b%c}

						if {[N byte 3 0 0 & 223 > 0]} {>

							if {[N byte 3 0 0 {} {} x {}]} {>

							emit {\b%c}

								if {[N byte 4 0 0 & 223 > 0]} {>

									if {[N byte 4 0 0 {} {} x {}]} {>

									emit {\b%c}

										if {[N byte 5 0 0 & 223 > 0]} {>

											if {[N byte 5 0 0 {} {} x {}]} {>

											emit {\b%c}

												if {[N byte 6 0 0 & 223 > 0]} {>

													if {[N byte 6 0 0 {} {} x {}]} {>

													emit {\b%c}

														if {[N byte 7 0 0 & 223 > 0]} {>

															if {[N byte 7 0 0 {} {} x {}]} {>

															emit {\b%c}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

	if {[N byte 8 0 0 & 223 > 0]} {>

	emit {\b.}

		if {[N byte 8 0 0 {} {} x {}]} {>

		emit {\b%c}

			if {[N byte 9 0 0 & 223 > 0]} {>

				if {[N byte 9 0 0 {} {} x {}]} {>

				emit {\b%c}

					if {[N byte 10 0 0 & 223 > 0]} {>

						if {[N byte 10 0 0 {} {} x {}]} {>

						emit {\b%c}
<}

<}

<}

<}

<}

<}

<}
} 2xDOS-filename {
if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b }
<}

U 243 DOS-filename


if {[N byte 11 0 0 {} {} x {}]} {>

emit {\b+}
<}

U 243 DOS-filename
} partition-table {U 243 partition-entry-test

U 243 partition-entry-test

U 243 partition-entry-test

U 243 partition-entry-test
} partition-entry-test {
if {[N byte 4 0 0 {} {} > 0]} {>

	if {[N byte 0 0 0 {} {} == 0]} {>
U 243 partition-entry

<}

	if {[N byte 0 0 0 {} {} > 127]} {>
U 243 partition-entry

<}

<}
} partition-entry {
if {[N byte 4 0 0 {} {} > 0]} {>

emit {\b; partition}

	if {[N leshort 64 0 0 {} {} == 43605]} {>

	emit 1
<}

	if {[N leshort 48 0 0 {} {} == 43605]} {>

	emit 2
<}

	if {[N leshort 32 0 0 {} {} == 43605]} {>

	emit 3
<}

	if {[N leshort 16 0 0 {} {} == 43605]} {>

	emit 4
<}

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {: ID=0x%x}
<}

	if {[N byte 0 0 0 & 128 == 128]} {>

	emit {\b, active}
<}

	if {[N byte 0 0 0 {} {} > 128]} {>

	emit 0x%x
<}

	if {[N byte 1 0 0 {} {} x {}]} {>

	emit {\b, start-CHS (}
<}
U 243 partition-chs

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {\b), end-CHS (}
<}
U 243 partition-chs

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b), startsector %u}
<}

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit {\b, %u sectors}
<}

<}
} partition-chs {
if {[N byte 1 0 0 {} {} x {}]} {>

emit {\b0x}
<}


switch -- [Nv byte 1 0 & 192] 64 {>;emit {\b1};<} -128 {>;emit {\b2};<} -64 {>;emit {\b3};<} 
<


if {[N byte 2 0 0 {} {} x {}]} {>

emit {\b%x}
<}


if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b,%u}
<}


if {[N byte 1 0 0 & 63 x {}]} {>

emit {\b,%u}
<}
} cdrom {
if {[S string 38913 0 {} {} ne NSR0]} {>

emit {ISO 9660 CD-ROM filesystem data}
mime application/x-iso9660-image

<}


if {[S string 38913 0 {} {} eq NSR0]} {>

emit {UDF filesystem data}

	if {[S string 38917 0 {} {} eq 1]} {>

	emit {(version 1.0)}
<}

	if {[S string 38917 0 {} {} eq 2]} {>

	emit {(version 1.5)}
<}

	if {[S string 38917 0 {} {} eq 3]} {>

	emit {(version 2.0)}
<}

	if {[N byte 38917 0 0 {} {} > 51]} {>

	emit {(unknown version, ID 0x%X)}
<}

	if {[N byte 38917 0 0 {} {} < 49]} {>

	emit {(unknown version, ID 0x%X)}
<}

mime application/x-iso9660-image

<}


if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {(DOS/MBR boot sector)}
<}


if {[S string 32808 0 T {} > \0]} {>

emit '%s'
<}


if {[S string 34816 0 {} {} eq \000CD001\001EL\ TORITO\ SPECIFICATION]} {>

emit (bootable)
<}
}} 252 {riff-wave {
switch -- [Nv leshort 0 0 {} {}] 1 {>;emit {\b, Microsoft PCM}

	if {[N leshort 14 0 0 {} {} > 0]} {>

		if {[N leshort 14 0 0 {} {} < 1024]} {>

		emit {\b, %d bit}
<}

<}
;<} 2 {>;emit {\b, Microsoft ADPCM};<} 6 {>;emit {\b, ITU G.711 A-law};<} 7 {>;emit {\b, ITU G.711 mu-law};<} 8 {>;emit {\b, Microsoft DTS};<} 17 {>;emit {\b, IMA ADPCM};<} 20 {>;emit {\b, ITU G.723 ADPCM (Yamaha)};<} 49 {>;emit {\b, GSM 6.10};<} 64 {>;emit {\b, ITU G.721 ADPCM};<} 80 {>;emit {\b, MPEG};<} 85 {>;emit {\b, MPEG Layer 3};<} 8193 {>;emit {\b, DTS};<} 
<


switch -- [Nv leshort 2 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<


if {[N leshort 2 0 0 {} {} > 2]} {>

	if {[N leshort 2 0 0 {} {} < 128]} {>

	emit {\b, %d channels}
<}

<}


if {[N lelong 4 0 0 {} {} > 0]} {>

	if {[N lelong 4 0 0 {} {} < 1000000]} {>

	emit {%d Hz}
<}

<}
} riff-walk {
if {[S string 0 0 {} {} eq fmt\x20]} {>

	if {[N lelong 4 0 0 {} {} < 128]} {>
U 252 riff-wave

<}

<}


if {[Sx string 0 0 {} {} eq LIST]} {>
U 252 riff-walk

<}


if {[Sx string 0 0 {} {} eq DISP]} {>
U 252 riff-walk

<}


if {[Sx string 0 0 {} {} eq bext]} {>
U 252 riff-walk

<}


if {[Sx string 0 0 {} {} eq Fake]} {>
U 252 riff-walk

<}


if {[Sx string 0 0 {} {} eq fact]} {>
U 252 riff-walk

<}


if {[S string 0 0 {} {} eq VP8]} {>

	if {[N byte 11 0 0 {} {} == 157]} {>

		if {[N byte 12 0 0 {} {} == 1]} {>

			if {[N byte 13 0 0 {} {} == 42]} {>

			emit {\b, VP8 encoding}

				if {[N leshort 14 0 0 & 16383 x {}]} {>

				emit {\b, %d}
<}

				if {[N leshort 16 0 0 & 16383 x {}]} {>

				emit {\bx%d, Scaling:}
<}

				switch -- [Nv leshort 14 0 & 49152] 0 {>;emit {\b [none]};<} 4096 {>;emit {\b [5/4]};<} 8192 {>;emit {\b [5/3]};<} 12288 {>;emit {\b [2]};<} 0 {>;emit {\bx[none]};<} 4096 {>;emit {\bx[5/4]};<} 8192 {>;emit {\bx[5/3]};<} 12288 {>;emit {\bx[2]};<} 
<

				switch -- [Nv byte 15 0 & 128] 0 {>;emit {\b, YUV color};<} -128 {>;emit {\b, bad color specification};<} 
<

				switch -- [Nv byte 15 0 & 64] 64 {>;emit {\b, no clamping required};<} 0 {>;emit {\b, decoders should clamp};<} 
<

<}

<}

<}

<}
}} 262 {tga-image {
if {[N byte 2 0 0 {} {} < 34]} {>

emit {Targa image data}
mime image/x-tga

ext tga/tpic/icb/vda/vst

<}


switch -- [Nv byte 2 0 & 247] 1 {>;emit {- Map};<} 2 {>;emit {- RGB}

	if {[N byte 17 0 0 & 15 > 0]} {>

	emit {\bA}
<}
;<} 3 {>;emit {- Mono};<} 
<


switch -- [Nv byte 2 0 {} {}] 32 {>;emit {- Color};<} 33 {>;emit {- Color};<} 
<


if {[N byte 1 0 0 {} {} == 1]} {>

emit (

	if {[N leshort 3 0 0 {} {} > 0]} {>

	emit {\b%d-}
<}

	if {[N leshort 5 0 0 {} {} x {}]} {>

	emit {\b%d)}
<}

<}


if {[N byte 2 0 0 & 8 == 8]} {>

emit {- RLE}
<}


if {[N leshort 12 0 0 {} {} > 0]} {>

emit {%d x}
<}


if {[N leshort 12 0 0 {} {} == 0]} {>

emit {65536 x}
<}


if {[N leshort 14 0 0 {} {} > 0]} {>

emit %d
<}


if {[N leshort 14 0 0 {} {} == 0]} {>

emit 65536
<}


if {[N byte 16 0 0 {} {} x {}]} {>

emit {x %d}
<}


if {[N leshort 8 0 0 {} {} > 0]} {>

emit +%d
<}


if {[N leshort 10 0 0 {} {} > 0]} {>

emit +%d
<}


if {[N byte 17 0 0 & 15 > 0]} {>

emit {- %d-bit alpha}
<}


if {[N byte 17 0 0 {} {} & 32]} {>

emit {- top}
<}


if {[N byte 17 0 0 {} {} & 16]} {>

emit {- right}
<}


switch -- [Nv byte 17 0 & 192] 64 {>;emit {- interleave};<} -128 {>;emit {- four way interleave};<} -64 {>;emit {- reserved};<} 
<


if {[N byte 0 0 0 {} {} > 0]} {>

	if {[S string 18 0 {} {} x {}]} {>

	emit {"%s"}
<}

<}


if {[Sx search 18 0 {} 4261301 eq s]} {>

emit {TRUEVISION-XFILE.\0	}

	if {[Nx lelong [R -8] 0 0 {} {} > 0]} {>

		if {[Nx leshort [I [R -4] lelong 0 0 0 0] 0 0 {} {} == 495]} {>

			if {[Sx string [R 0] 0 {} {} > \0]} {>

			emit {- author "%-.40s"}
<}

			if {[Sx string [R 41] 0 {} {} > \0]} {>

			emit {- comment "%-.80s"}
<}

			if {[Nx bequad [R 365] 0 0 & 18446744073709486080 != 0]} {>

				if {[Nx leshort [R -6] 0 0 {} {} x {}]} {>

				emit %d
<}

				if {[Nx leshort [R -8] 0 0 {} {} x {}]} {>

				emit {\b-%d}
<}

				if {[Nx leshort [R -4] 0 0 {} {} x {}]} {>

				emit {\b-%d}
<}

<}

			if {[Nx bequad [R 371] 0 0 & 18446744073709486080 != 0]} {>

				if {[Nx leshort [R -8] 0 0 {} {} x {}]} {>

				emit %d
<}

				if {[Nx leshort [R -6] 0 0 {} {} x {}]} {>

				emit {\b:%.2d}
<}

				if {[Nx leshort [R -4] 0 0 {} {} x {}]} {>

				emit {\b:%.2d}
<}

<}

			if {[Sx string [R 377] 0 {} {} > \0]} {>

			emit {- job "%-.40s"}
<}

			if {[Nx bequad [R 418] 0 0 & 18446744073709486080 != 0]} {>

				if {[Nx leshort [R -8] 0 0 {} {} x {}]} {>

				emit %d
<}

				if {[Nx leshort [R -6] 0 0 {} {} x {}]} {>

				emit {\b:%.2d}
<}

				if {[Nx leshort [R -4] 0 0 {} {} x {}]} {>

				emit {\b:%.2d}
<}

<}

			if {[Sx string [R 424] 0 {} {} > \0]} {>

			emit {- %-.40s}
<}

			if {[Nx byte [R 424] 0 0 {} {} > 0]} {>

				if {[Nx leshort [R 40] 0 0 / 100 x {}]} {>

				emit %d
<}

				if {[Nx leshort [R 40] 0 0 % 100 x {}]} {>

				emit {\b.%d}
<}

				if {[Nx byte [R 42] 0 0 {} {} > 32]} {>

				emit {\b%c}
<}

<}

			if {[Nx lelong [R 468] 0 0 {} {} > 0]} {>

			emit {- keycolor 0x%8.8x}
<}

			if {[Nx leshort [R 474] 0 0 {} {} > 0]} {>

				if {[Nx leshort [R -4] 0 0 {} {} > 0]} {>

				emit {- aspect %d}
<}

				if {[Nx leshort [R -2] 0 0 {} {} x {}]} {>

				emit {\b/%d}
<}

<}

			if {[Nx leshort [R 478] 0 0 {} {} > 0]} {>

				if {[Nx leshort [R -4] 0 0 {} {} > 0]} {>

				emit {- gamma %d}
<}

				if {[Nx leshort [R -2] 0 0 {} {} x {}]} {>

				emit {\b/%d}
<}

<}

<}

<}

<}
} netpbm {
if {[Sx regex 3 0 s {} eq \[0-9\]\{1,50\}\ \[0-9\]\{1,50\}]} {>

emit {Netpbm image data}

	if {[Sx regex [R 0] 0 {} {} eq \[0-9\]\{1,50\}]} {>

	emit {\b, size = %s x}

		if {[Sx regex [R 0] 0 {} {} eq \[0-9\]\{1,50\}]} {>

		emit {\b %s}
<}

<}

<}
} tiff_ifd {
if {[N leshort 0 0 0 {} {} x {}]} {>

emit {\b, direntries=%d}
<}

U 262 tiff_entry
} tiff_entry {
switch -- [Nv leshort 0 0 {} {}] 254 {>;U 262 tiff_entry
;<} 256 {>;
	if {[N lelong 4 0 0 {} {} == 1]} {>
U 262 tiff_entry

		if {[N leshort 8 0 0 {} {} x {}]} {>

		emit {\b, width=%d}
<}

<}
;<} 257 {>;
	if {[N lelong 4 0 0 {} {} == 1]} {>

		if {[N leshort 8 0 0 {} {} x {}]} {>

		emit {\b, height=%d}
<}
U 262 tiff_entry

<}
;<} 258 {>;
	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {\b, bps=%d}
<}
U 262 tiff_entry
;<} 259 {>;
	if {[N lelong 4 0 0 {} {} == 1]} {>

	emit {\b, compression=}

		switch -- [Nv leshort 8 0 {} {}] 1 {>;emit {\bnone};<} 2 {>;emit {\bhuffman};<} 3 {>;emit {\bbi-level group 3};<} 4 {>;emit {\bbi-level group 4};<} 5 {>;emit {\bLZW};<} 6 {>;emit {\bJPEG (old)};<} 7 {>;emit {\bJPEG};<} 8 {>;emit {\bdeflate};<} 9 {>;emit {\bJBIG, ITU-T T.85};<} 10 {>;emit {\bJBIG, ITU-T T.43};<} 32766 {>;emit {\bNeXT RLE 2-bit};<} -32763 {>;emit {\bPackBits (Macintosh RLE)};<} -32727 {>;emit {\bThunderscan RLE};<} -32641 {>;emit {\bRasterPadding (CT or MP)};<} -32640 {>;emit {\bRLE (Line Work)};<} -32639 {>;emit {\bRLE (High-Res Cont-Tone)};<} -32638 {>;emit {\bRLE (Binary Line Work)};<} -32590 {>;emit {\bDeflate (PKZIP)};<} -32589 {>;emit {\bKodak DCS};<} -30875 {>;emit {\bJBIG};<} -30824 {>;emit {\bJPEG2000};<} -30823 {>;emit {\bNikon NEF Compressed};<} 
<

		if {[S default 8 0 {} {} x {}]} {>

			if {[N leshort 8 0 0 {} {} x {}]} {>

			emit {\b(unknown 0x%x)}
<}

<}
U 262 tiff_entry

<}
;<} 262 {>;emit {\b, PhotometricIntepretation=}

	if {[S clear 8 0 {} {} x {}]} {>

<}

	switch -- [Nv leshort 8 0 {} {}] 0 {>;emit {\bWhiteIsZero};<} 1 {>;emit {\bBlackIsZero};<} 2 {>;emit {\bRGB};<} 3 {>;emit {\bRGB Palette};<} 4 {>;emit {\bTransparency Mask};<} 5 {>;emit {\bCMYK};<} 6 {>;emit {\bYCbCr};<} 8 {>;emit {\bCIELab};<} 
<

	if {[S default 8 0 {} {} x {}]} {>

		if {[N leshort 8 0 0 {} {} x {}]} {>

		emit {\b(unknown=0x%x)}
<}

<}
U 262 tiff_entry
;<} 266 {>;
	if {[N lelong 4 0 0 {} {} == 1]} {>
U 262 tiff_entry

<}
;<} 269 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, name=%s}
U 262 tiff_entry

<}
;<} 270 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, description=%s}
U 262 tiff_entry

<}
;<} 271 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, manufacturer=%s}
U 262 tiff_entry

<}
;<} 272 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, model=%s}
U 262 tiff_entry

<}
;<} 273 {>;U 262 tiff_entry
;<} 274 {>;emit {\b, orientation=}

	switch -- [Nv leshort 8 0 {} {}] 1 {>;emit {\bupper-left};<} 3 {>;emit {\blower-right};<} 6 {>;emit {\bupper-right};<} 8 {>;emit {\blower-left};<} 9 {>;emit {\bundefined};<} 
<

	if {[S default 8 0 {} {} x {}]} {>

		if {[N leshort 8 0 0 {} {} x {}]} {>

		emit {\b[*%d*]}
<}

<}
U 262 tiff_entry
;<} 282 {>;
	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b, xresolution=%d}
<}
U 262 tiff_entry
;<} 283 {>;
	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b, yresolution=%d}
<}
U 262 tiff_entry
;<} 296 {>;
	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {\b, resolutionunit=%d}
<}
U 262 tiff_entry
;<} 305 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, software=%s}
<}
U 262 tiff_entry
;<} 306 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, datetime=%s}
<}
U 262 tiff_entry
;<} 316 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, hostcomputer=%s}
<}
U 262 tiff_entry
;<} 318 {>;U 262 tiff_entry
;<} 319 {>;U 262 tiff_entry
;<} 529 {>;U 262 tiff_entry
;<} 531 {>;U 262 tiff_entry
;<} 532 {>;U 262 tiff_entry
;<} -32104 {>;
	if {[S string [I 8 lelong 0 0 0 0] 0 {} {} x {}]} {>

	emit {\b, copyright=%s}
<}
U 262 tiff_entry
;<} -30871 {>;U 262 tiff_entry
;<} -30683 {>;emit {\b, GPS-Data}
U 262 tiff_entry
;<} 
<
} gem_info {
if {[N beshort 0 0 0 {} {} < 3]} {>

emit GEM

	if {[N beshort 2 0 0 {} {} > 9]} {>

		if {[S string 16 0 {} {} eq STTT\0\x10]} {>

		emit STTT
<}

		if {[S string 16 0 {} {} eq TIMG\0]} {>

		emit TIMG
<}

		if {[S string 16 0 {} {} eq \0\x80]} {>

			if {[N beshort 2 0 0 {} {} == 24]} {>

			emit NOSIG
<}

			if {[N beshort 2 0 0 {} {} != 24]} {>

			emit HYPERPAINT
<}

<}

		if {[S default 16 0 {} {} x {}]} {>

			if {[S string 16 0 {} {} ne XIMG\0]} {>

			emit NOSIG
<}

<}

<}

	if {[S string 16 0 {} {} eq XIMG\0]} {>

	emit {XIMG Image data}
	ext img/ximg

<}

	if {[S string 16 0 {} {} ne XIMG\0]} {>

	emit {Image data}
	ext img

<}

	if {[N beshort 2 0 0 {} {} == 9]} {>

	emit (Ventura)
<}

	if {[N beshort 12 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N beshort 14 0 0 {} {} x {}]} {>

	emit %d,
<}

	if {[N beshort 4 0 0 {} {} x {}]} {>

	emit {%d planes,}
<}

	if {[N beshort 8 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N beshort 10 0 0 {} {} x {}]} {>

	emit {%d pixelsize}
<}

	if {[N beshort 6 0 0 {} {} != 2]} {>

	emit {\b, pattern size %d}
<}

mime image/x-gem

<}
} sega-pvr-image-header {
if {[N leshort 12 0 0 {} {} x {}]} {>

emit {%d x}
<}


if {[N leshort 14 0 0 {} {} x {}]} {>

emit %d
<}


switch -- [Nv byte 8 0 {} {}] 0 {>;emit {\b, ARGB1555};<} 1 {>;emit {\b, RGB565};<} 2 {>;emit {\b, ARGB4444};<} 3 {>;emit {\b, YUV442};<} 4 {>;emit {\b, Bump};<} 5 {>;emit {\b, 4bpp};<} 6 {>;emit {\b, 8bpp};<} 
<


switch -- [Nv byte 9 0 {} {}] 1 {>;emit {\b, square twiddled};<} 2 {>;emit {\b, square twiddled & mipmap};<} 3 {>;emit {\b, VQ};<} 4 {>;emit {\b, VQ & mipmap};<} 5 {>;emit {\b, 8-bit CLUT twiddled};<} 6 {>;emit {\b, 4-bit CLUT twiddled};<} 7 {>;emit {\b, 8-bit direct twiddled};<} 8 {>;emit {\b, 4-bit direct twiddled};<} 9 {>;emit {\b, rectangle};<} 11 {>;emit {\b, rectangular stride};<} 13 {>;emit {\b, rectangular twiddled};<} 16 {>;emit {\b, small VQ};<} 17 {>;emit {\b, small VQ & mipmap};<} 18 {>;emit {\b, square twiddled & mipmap};<} 
<
} sega-pvr-xbox-dds-header {
if {[N lelong 16 0 0 {} {} x {}]} {>

emit {%d x}
<}


if {[N lelong 12 0 0 {} {} x {}]} {>

emit %d,
<}


if {[S string 84 0 {} {} x {}]} {>

emit %.4s
<}
} sega-gvr-image-header {
if {[N beshort 12 0 0 {} {} x {}]} {>

emit {%d x}
<}


if {[N beshort 14 0 0 {} {} x {}]} {>

emit %d
<}


switch -- [Nv byte 11 0 {} {}] 0 {>;emit {\b, I4};<} 1 {>;emit {\b, I8};<} 2 {>;emit {\b, IA4};<} 3 {>;emit {\b, IA8};<} 4 {>;emit {\b, RGB565};<} 5 {>;emit {\b, RGB5A3};<} 6 {>;emit {\b, ARGB8888};<} 8 {>;emit {\b, CI4};<} 9 {>;emit {\b, CI8};<} 14 {>;emit {\b, DXT1};<} 
<
}} 267 {swf-details {
if {[S string 0 0 {} {} eq F]} {>

emit {Macromedia Flash data}
mime application/x-shockwave-flash

<}


if {[S string 0 0 {} {} eq C]} {>

emit {Macromedia Flash data (compressed)}
mime application/x-shockwave-flash

<}


if {[S string 0 0 {} {} eq Z]} {>

emit {Macromedia Flash data (lzma compressed)}
mime application/x-shockwave-flash

<}


if {[N byte 3 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}
}}}
	foreach test {{
switch -- [Nvx beshort 0 0 {} {}] 5493 {>;emit {fsav macro virus signatures}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit (%d-
<}

if {[N byte 11 0 0 {} {} > 0]} {>

emit {\b%02d-}
<}

if {[N byte 10 0 0 {} {} > 0]} {>

emit {\b%02d)}
<}
;<} 368 {>;emit {WE32000 COFF}

if {[N beshort 18 0 0 {} {} ^ 16]} {>

emit object
<}

if {[N beshort 18 0 0 {} {} & 16]} {>

emit executable
<}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N beshort 18 0 0 {} {} ^ 4096]} {>

emit {N/A on 3b2/300 w/paging}
<}

if {[N beshort 18 0 0 {} {} & 8192]} {>

emit {32100 required}
<}

if {[N beshort 18 0 0 {} {} & 16384]} {>

emit {and MAU hardware required}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (pure);<} 267 {>;emit {(demand paged)};<} 291 {>;emit {(target shared library)};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 369 {>;emit {WE32000 COFF executable (TV)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} -30771 {>;emit {OS9/6809 module:}

switch -- [Nv byte 6 0 & 15] 0 {>;emit non-executable;<} 1 {>;emit {machine language};<} 2 {>;emit {BASIC I-code};<} 3 {>;emit {Pascal P-code};<} 4 {>;emit {C I-code};<} 5 {>;emit {COBOL I-code};<} 6 {>;emit {Fortran I-code};<} 
<

switch -- [Nv byte 6 0 & 240] 16 {>;emit {program executable};<} 32 {>;emit subroutine;<} 48 {>;emit multi-module;<} 64 {>;emit {data module};<} -64 {>;emit {system module};<} -48 {>;emit {file manager};<} -32 {>;emit {device driver};<} -16 {>;emit {device descriptor};<} 
<
;<} 19196 {>;emit {OS9/68K module:}

if {[N byte 20 0 0 & 128 == 128]} {>

emit re-entrant
<}

if {[N byte 20 0 0 & 64 == 64]} {>

emit ghost
<}

if {[N byte 20 0 0 & 32 == 32]} {>

emit system-state
<}

switch -- [Nv byte 19 0 {} {}] 1 {>;emit {machine language};<} 2 {>;emit {BASIC I-code};<} 3 {>;emit {Pascal P-code};<} 4 {>;emit {C I-code};<} 5 {>;emit {COBOL I-code};<} 6 {>;emit {Fortran I-code};<} 
<

switch -- [Nv byte 18 0 {} {}] 1 {>;emit {program executable};<} 2 {>;emit subroutine;<} 3 {>;emit multi-module;<} 4 {>;emit {data module};<} 11 {>;emit {trap library};<} 12 {>;emit {system module};<} 13 {>;emit {file manager};<} 14 {>;emit {device driver};<} 15 {>;emit {device descriptor};<} 
<
;<} -7408 {>;emit {Amiga Workbench}

if {[N beshort 2 0 0 {} {} == 1]} {>

	switch -- [Nv byte 48 0 {} {}] 1 {>;emit {disk icon};<} 2 {>;emit {drawer icon};<} 3 {>;emit {tool icon};<} 4 {>;emit {project icon};<} 5 {>;emit {garbage icon};<} 6 {>;emit {device icon};<} 7 {>;emit {kickstart icon};<} 8 {>;emit {workbench application icon};<} 
<

<}

if {[N beshort 2 0 0 {} {} > 1]} {>

emit {icon, vers. %d}
<}
;<} 3840 {>;emit {AmigaOS bitmap font};<} 3843 {>;emit {AmigaOS outline font};<} 17746 {>;
if {[N byte 4 0 0 {} {} == 0]} {>

emit {Apple Driver Map}

	if {[N beshort 2 0 0 {} {} x {}]} {>

	emit {\b, blocksize %d}
<}

	if {[N belong 4 0 0 {} {} x {}]} {>

	emit {\b, blockcount %d}
<}

	if {[N beshort 10 0 0 {} {} x {}]} {>

	emit {\b, devtype %d}
<}

	if {[N beshort 12 0 0 {} {} x {}]} {>

	emit {\b, devid %d}
<}

	if {[N beshort 20 0 0 {} {} x {}]} {>

	emit {\b, descriptors %d}
<}

<}
;<} 336 {>;emit {mc68k COFF}

if {[N beshort 18 0 0 {} {} ^ 16]} {>

emit object
<}

if {[N beshort 18 0 0 {} {} & 16]} {>

emit executable
<}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[S string 168 0 {} {} eq .lowmem]} {>

emit {Apple toolbox}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (pure);<} 267 {>;emit {(demand paged)};<} 273 {>;emit (standalone);<} 
<
;<} 337 {>;emit {mc68k executable (shared)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 338 {>;emit {mc68k executable (shared demand paged)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 364 {>;emit {68K BCS executable};<} 365 {>;emit {88K BCS executable};<} 24602 {>;emit {Atari 68xxx executable,}

if {[N belong 2 0 0 {} {} x {}]} {>

emit {text len %u,}
<}

if {[N belong 6 0 0 {} {} x {}]} {>

emit {data len %u,}
<}

if {[N belong 10 0 0 {} {} x {}]} {>

emit {BSS len %u,}
<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit {symboltab len %u,}
<}

if {[N belong 18 0 0 {} {} == 0]} {>

<}

if {[N belong 22 0 0 {} {} & 1]} {>

emit {fastload flag,}
<}

if {[N belong 22 0 0 {} {} & 2]} {>

emit {may be loaded to alternate RAM,}
<}

if {[N belong 22 0 0 {} {} & 4]} {>

emit {malloc may be from alternate RAM,}
<}

if {[N belong 22 0 0 {} {} x {}]} {>

emit {flags: 0x%X,}
<}

if {[N beshort 26 0 0 {} {} == 0]} {>

emit {no relocation tab}
<}

if {[N beshort 26 0 0 {} {} != 0]} {>

emit {+ relocation tab}
<}

if {[S string 30 0 {} {} eq SFX]} {>

emit {[Self-Extracting LZH SFX archive]}
<}

if {[S string 38 0 {} {} eq SFX]} {>

emit {[Self-Extracting LZH SFX archive]}
<}

if {[S string 44 0 {} {} eq ZIP!]} {>

emit {[Self-Extracting ZIP SFX archive]}
<}
;<} 100 {>;emit {Atari 68xxx CPX file}

if {[N beshort 8 0 0 {} {} x {}]} {>

emit {(version %04x)}
<}
;<} 2057 {>;emit {Bentley/Intergraph MicroStation}

if {[N byte 2 0 0 {} {} == 254]} {>

	if {[N beshort 4 0 0 {} {} == 6144]} {>

	emit {CIT raster CAD}
<}

<}
;<} -31486 {>;emit {GPG encrypted data}
mime text/PGP # encoding: data
;<} -26367 {>;emit {GPG key public ring}
mime application/x-gnupg-keyring
;<} 351 {>;emit {370 XA sysV executable }

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 30 0 0 {} {} > 0]} {>

emit {- 5.2 format}
<}
;<} 346 {>;emit {370 XA sysV pure executable }

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 30 0 0 {} {} > 0]} {>

emit {- 5.2 format}
<}
;<} 22529 {>;emit {370 sysV pure executable}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 23041 {>;emit {370 XA sysV pure executable}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 23809 {>;emit {370 sysV executable}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 24321 {>;emit {370 XA sysV executable}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 345 {>;emit {SVR2 executable (Amdahl-UTS)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 24 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 348 {>;emit {SVR2 pure executable (Amdahl-UTS)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 24 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 344 {>;emit {SVR2 pure executable (USS/370)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 24 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 349 {>;emit {SVR2 executable (USS/370)}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 24 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 518 {>;emit {ALAN game data}

if {[N byte 2 0 0 {} {} < 10]} {>

emit {version 2.6%d}
<}
;<} 30463 {>;emit {squeezed data,}

if {[S string 4 0 {} {} x {}]} {>

emit {original name %s}
<}
;<} 30462 {>;emit {crunched data,}

if {[S string 2 0 {} {} x {}]} {>

emit {original name %s}
<}
;<} 30461 {>;emit {LZH compressed data,}

if {[S string 2 0 {} {} x {}]} {>

emit {original name %s}
<}
;<} 32639 {>;emit {RDI Acoustic Doppler Current Profiler (ADCP)};<} 312 {>;emit {interLaced eXtensible Trace (LXT) file}

if {[N beshort 2 0 0 {} {} > 0]} {>

emit {(Version %u)}
<}
;<} -511 {>;emit {MySQL table definition file}

if {[N byte 2 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} 392 {>;emit {Tower/XP rel 2 object}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 397 {>;emit {Tower/XP rel 2 object}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 400 {>;emit {Tower/XP rel 3 object}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 405 {>;emit {Tower/XP rel 3 object}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 408 {>;emit {Tower32/600/400 68020 object}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 
<

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 416 {>;emit {Tower32/800 68020}

if {[N beshort 18 0 0 {} {} & 8192]} {>

emit {w/68881 object}
<}

if {[N beshort 18 0 0 {} {} & 16384]} {>

emit {compatible object}
<}

if {[N beshort 18 0 0 {} {} & 24576]} {>

emit object
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 267 {>;emit {pure executable};<} 
<

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 421 {>;emit {Tower32/800 68010}

if {[N beshort 18 0 0 {} {} & 16384]} {>

emit {compatible object}
<}

if {[N beshort 18 0 0 {} {} & 24576]} {>

emit object
<}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit executable;<} 267 {>;emit {pure executable};<} 
<

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 1280 {>;
if {[N beshort 18 0 0 & 36480 == 0]} {>
U 154 display-coff

<}
;<} 352 {>;emit {MIPSEB ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 354 {>;emit {MIPSEL-BE ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 24577 {>;emit {MIPSEB-LE ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 25089 {>;emit {MIPSEL ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 355 {>;emit {MIPSEB MIPS-II ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 358 {>;emit {MIPSEL-BE MIPS-II ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 25345 {>;emit {MIPSEB-LE MIPS-II ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 26113 {>;emit {MIPSEL MIPS-II ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 320 {>;emit {MIPSEB MIPS-III ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 322 {>;emit {MIPSEL-BE MIPS-III ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (swapped);<} 267 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 16385 {>;emit {MIPSEB-LE MIPS-III ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 16897 {>;emit {MIPSEL MIPS-III ECOFF executable}

switch -- [Nv beshort 20 0 {} {}] 1793 {>;emit (impure);<} 2049 {>;emit (swapped);<} 2817 {>;emit (paged);<} 
<

if {[N belong 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 8 0 0 {} {} == 0]} {>

emit stripped
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 384 {>;emit {MIPSEB Ucode};<} 386 {>;emit {MIPSEL-BE Ucode};<} -1279 {>;emit {QDOS object}

if {[S pstring 2 0 {} {} x {}]} {>

emit '%s'
<}
;<} 2935 {>;emit {ATSC A/52 aka AC-3 aka Dolby Digital stream,}

switch -- [Nv byte 4 0 & 192] 0 {>;emit {48 kHz,};<} 64 {>;emit {44.1 kHz,};<} -128 {>;emit {32 kHz,};<} -64 {>;emit {reserved frequency,};<} 
<

switch -- [Nv byte 5 0 & 7] 0 {>;emit {\b, complete main (CM)};<} 1 {>;emit {\b, music and effects (ME)};<} 2 {>;emit {\b, visually impaired (VI)};<} 3 {>;emit {\b, hearing impaired (HI)};<} 4 {>;emit {\b, dialogue (D)};<} 5 {>;emit {\b, commentary (C)};<} 6 {>;emit {\b, emergency (E)};<} 
<

if {[N beshort 5 0 0 & 2016 == 1824]} {>

emit {\b, voiceover (VO) }
<}

if {[N beshort 5 0 0 & 2016 > 1824]} {>

emit {\b, karaoke}
<}

switch -- [Nv byte 6 0 & 224] 0 {>;emit {1+1 front,}

	if {[N byte 6 0 0 & 16 == 16]} {>

	emit {LFE on,}
<}
;<} 32 {>;emit {1 front/0 rear,}

	if {[N byte 6 0 0 & 16 == 16]} {>

	emit {LFE on,}
<}
;<} 64 {>;emit {2 front/0 rear,}

	switch -- [Nv byte 6 0 & 24] 0 {>;emit {Dolby Surround not indicated};<} 8 {>;emit {not Dolby Surround encoded};<} 16 {>;emit {Dolby Surround encoded};<} 24 {>;emit {reserved Dolby Surround mode};<} 
<

	if {[N byte 6 0 0 & 4 == 4]} {>

	emit {LFE on,}
<}
;<} 96 {>;emit {3 front/0 rear,}

	if {[N byte 6 0 0 & 4 == 4]} {>

	emit {LFE on,}
<}
;<} -128 {>;emit {2 front/1 rear,}

	if {[N byte 6 0 0 & 4 == 4]} {>

	emit {LFE on,}
<}
;<} -96 {>;emit {3 front/1 rear,}

	if {[N byte 6 0 0 & 1 == 1]} {>

	emit {LFE on,}
<}
;<} -64 {>;emit {2 front/2 rear,}

	if {[N byte 6 0 0 & 4 == 4]} {>

	emit {LFE on,}
<}
;<} -32 {>;emit {3 front/2 rear,}

	if {[N byte 6 0 0 & 1 == 1]} {>

	emit {LFE on,}
<}
;<} 
<

switch -- [Nv byte 4 0 & 62] 0 {>;emit {\b, 32 kbit/s};<} 2 {>;emit {\b, 40 kbit/s};<} 4 {>;emit {\b, 48 kbit/s};<} 6 {>;emit {\b, 56 kbit/s};<} 8 {>;emit {\b, 64 kbit/s};<} 10 {>;emit {\b, 80 kbit/s};<} 12 {>;emit {\b, 96 kbit/s};<} 14 {>;emit {\b, 112 kbit/s};<} 16 {>;emit {\b, 128 kbit/s};<} 18 {>;emit {\b, 160 kbit/s};<} 20 {>;emit {\b, 192 kbit/s};<} 22 {>;emit {\b, 224 kbit/s};<} 24 {>;emit {\b, 256 kbit/s};<} 26 {>;emit {\b, 320 kbit/s};<} 28 {>;emit {\b, 384 kbit/s};<} 30 {>;emit {\b, 448 kbit/s};<} 32 {>;emit {\b, 512 kbit/s};<} 34 {>;emit {\b, 576 kbit/s};<} 36 {>;emit {\b, 640 kbit/s};<} 
<

mime audio/vnd.dolby.dd-raw
;<} -26368 {>;emit {PGP key public ring}
mime application/x-pgp-keyring
;<} -27391 {>;emit {PGP key security ring}
mime application/x-pgp-keyring
;<} -27392 {>;emit {PGP key security ring}
mime application/x-pgp-keyring
;<} -23040 {>;emit {PGP encrypted data}
mime text/PGP # encoding: armored data
;<} 378 {>;emit {amd 29k coff noprebar executable};<} 890 {>;emit {amd 29k coff prebar executable};<} -8185 {>;emit {amd 29k coff archive};<} 479 {>;emit {executable (RISC System/6000 V3.1) or obj module}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 260 {>;emit {shared library};<} 261 {>;emit {ctab data};<} -508 {>;emit {structured file};<} 503 {>;emit {64-bit XCOFF executable or object module}

if {[N belong 20 0 0 {} {} == 0]} {>

emit {not stripped}
<}
;<} 21930 {>;emit {BIOS (ia32) ROM Ext.}

if {[S string 5 0 {} {} eq USB]} {>

emit USB
<}

if {[S string 7 0 {} {} eq LDR]} {>

emit {UNDI image}
<}

if {[S string 30 0 {} {} eq IBM]} {>

emit {IBM comp. Video}
<}

if {[S string 26 0 {} {} eq Adaptec]} {>

emit Adaptec
<}

if {[S string 28 0 {} {} eq Adaptec]} {>

emit Adaptec
<}

if {[S string 42 0 {} {} eq PROMISE]} {>

emit Promise
<}

if {[N byte 2 0 0 {} {} x {}]} {>

emit (%d*512)
<}

mime application/octet-stream

ext rom/bin
;<} 407 {>;emit {Apollo m68k COFF executable}

if {[N beshort 18 0 0 {} {} ^ 16384]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 404 {>;emit {apollo a88k COFF executable}

if {[N beshort 18 0 0 {} {} ^ 16384]} {>

emit {not stripped}
<}

if {[N beshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 200 {>;emit {hp200 (68010) BSD}

switch -- [Nv beshort 2 0 {} {}] 263 {>;emit {impure binary};<} 264 {>;emit {read-only binary};<} 267 {>;emit {demand paged binary};<} 
<
;<} 300 {>;emit {hp300 (68020+68881) BSD}

switch -- [Nv beshort 2 0 {} {}] 263 {>;emit {impure binary};<} 264 {>;emit {read-only binary};<} 267 {>;emit {demand paged binary};<} 
<
;<} -147 {>;emit {very old 16-bit-int big-endian archive};<} -155 {>;emit {old 16-bit-int big-endian archive}

if {[S string 2 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}
;<} 3599 {>;emit {Atari MSA archive data}

if {[N beshort 2 0 0 {} {} x {}]} {>

emit {\b, %d sectors per track}
<}

switch -- [Nv beshort 4 0 {} {}] 0 {>;emit {\b, 1 sided};<} 1 {>;emit {\b, 2 sided};<} 
<

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {\b, starting track: %d}
<}

if {[N beshort 8 0 0 {} {} x {}]} {>

emit {\b, ending track: %d}
<}
;<} 9 {>;
if {[Nx belong 2 0 0 {} {} == 267390960]} {>

	if {[Nx belong [R 0] 0 0 {} {} == 267390960]} {>

		if {[Nx byte [R 0] 0 0 {} {} == 0]} {>

<}

		if {[Nx beshort [R 1] 0 0 {} {} == 1]} {>

<}

		if {[Sx string [R 3] 0 {} {} eq a]} {>

		emit {Xilinx BIT data}

			if {[Sx pstring [R 0] 0 H {} x {}]} {>

			emit {- from %s}

				if {[Sx string [R 1] 0 {} {} eq b]} {>

					if {[Sx pstring [R 0] 0 H {} x {}]} {>

					emit {- for %s}

						if {[Sx string [R 1] 0 {} {} eq c]} {>

							if {[Sx pstring [R 0] 0 H {} x {}]} {>

							emit {- built %s}

								if {[Sx string [R 1] 0 {} {} eq d]} {>

									if {[Sx pstring [R 0] 0 H {} x {}]} {>

									emit {\b(%s)}

										if {[Sx string [R 1] 0 {} {} eq e]} {>

											if {[Nx belong [R 0] 0 0 {} {} x {}]} {>

											emit {- data length 0x%x}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}
;<} -40 {>;emit {JPEG image data}

if {[S string 6 0 {} {} eq JFIF]} {>

emit {\b, JFIF standard}

	if {[N byte 11 0 0 {} {} x {}]} {>

	emit {\b %d.}
<}

	if {[N byte 12 0 0 {} {} x {}]} {>

	emit {\b%02d}
<}

	switch -- [Nv byte 13 0 {} {}] 0 {>;emit {\b, aspect ratio};<} 1 {>;emit {\b, resolution (DPI)};<} 2 {>;emit {\b, resolution (DPCM)};<} 
<

	if {[N beshort 14 0 0 {} {} x {}]} {>

	emit {\b, density %dx}
<}

	if {[N beshort 16 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

	if {[N beshort 4 0 0 {} {} x {}]} {>

	emit {\b, segment length %d}
<}

	if {[N byte 18 0 0 {} {} != 0]} {>

	emit {\b, thumbnail %dx}

		if {[N byte 19 0 0 {} {} x {}]} {>

		emit {\b%d}
<}

<}

<}

if {[S string 6 0 {} {} eq Exif]} {>

emit {\b, Exif standard: [}

	if {[S string 12 0 {} {} x {}]} {>

	emit {\b]}
<}

<}
U 235 jpeg_segment

mime image/jpeg

ext jpeg/jpg/jpe/jfif
;<} 14541 {>;emit {C64 PCLink Image};<} -32760 {>;
if {[S string 6 0 {} {} eq BS93]} {>

emit {Lynx homebrew cartridge}

	if {[N beshort 2 0 0 {} {} x {}]} {>

	emit {\b, RAM start $%04x}
<}

<}

if {[S string 6 0 {} {} eq LYNX]} {>

emit {Lynx cartridge}

	if {[N beshort 2 0 0 {} {} x {}]} {>

	emit {\b, RAM start $%04x}
<}

<}
;<} -21928 {>;emit {floppy image data (IBM SaveDskF, old)};<} -21927 {>;emit {floppy image data (IBM SaveDskF)};<} -21926 {>;emit {floppy image data (IBM SaveDskF, compressed)};<} -30875 {>;emit {disk quotas file};<} 1286 {>;emit {IRIS Showcase file}

if {[N byte 2 0 0 {} {} == 73]} {>

emit -
<}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {- version %d}
<}
;<} 550 {>;emit {IRIS Showcase template}

if {[N byte 2 0 0 {} {} == 99]} {>

emit -
<}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {- version %d}
<}
;<} -21267 {>;emit {Java serialization data}

if {[N beshort 2 0 0 {} {} > 4]} {>

emit {\b, version %d}
<}
;<} -32768 {>;emit {lif file};<} 474 {>;emit {SGI image data}

if {[N byte 2 0 0 {} {} == 1]} {>

emit {\b, RLE}
<}

if {[N byte 3 0 0 {} {} == 2]} {>

emit {\b, high precision}
<}

if {[N beshort 4 0 0 {} {} x {}]} {>

emit {\b, %d-D}
<}

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {\b, %d x}
<}

if {[N beshort 8 0 0 {} {} x {}]} {>

emit %d
<}

if {[N beshort 10 0 0 {} {} x {}]} {>

emit {\b, %d channel}
<}

if {[N beshort 10 0 0 {} {} != 1]} {>

emit {\bs}
<}

if {[S string 80 0 {} {} > 0]} {>

emit {\b, "%s"}
<}
;<} 4112 {>;emit {PEX Binary Archive};<} 1 {>;
switch -- [Nv beshort 2 0 {} {}] 8 {>;U 262 gem_info
;<} 9 {>;U 262 gem_info
;<} 24 {>;U 262 gem_info
;<} 25 {>;U 262 gem_info
;<} 
<
;<} 
<
} {
if {[S string 0 0 {} {} eq ClamAV-VDB:]} {>

if {[S string 11 0 {} {} > \0]} {>

emit {Clam AntiVirus database %-.23s}

	if {[S string 34 0 {} {} eq :]} {>

		if {[S string 35 0 {} {} ne :]} {>

		emit {\b, version }

			if {[S string 35 0 {} {} x {}]} {>

			emit {\b%-.1s}

				if {[S string 36 0 {} {} ne :]} {>

					if {[S string 36 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[S string 37 0 {} {} ne :]} {>

							if {[S string 37 0 {} {} x {}]} {>

							emit {\b%-.1s}

								if {[S string 38 0 {} {} ne :]} {>

									if {[S string 38 0 {} {} x {}]} {>

									emit {\b%-.1s}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

if {[S string 512 0 {} {} eq \037\213]} {>

emit {\b, gzipped}
<}

if {[S string 769 0 {} {} eq ustar\0]} {>

emit {\b, tarred}
<}

<}
} {
if {[S string 0 0 {} {} eq AVG7_ANTIVIRUS_VAULT_FILE]} {>

emit {AVG 7 Antivirus vault file data}
<}
} {
if {[S string 0 0 {} {} eq X5O!P%@AP\[4\\PZX54(P^)7CC)7\}\$EICAR]} {>

if {[S string 33 0 {} {} eq -STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*]} {>

emit {EICAR virus test files}
<}

<}
} {
switch -- [Nvx belong 0 0 {} {}] -307499301 {>;emit RPM

if {[N byte 4 0 0 {} {} x {}]} {>

emit v%d
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

switch -- [Nv beshort 6 0 {} {}] 1 {>;emit src;<} 0 {>;emit bin

	switch -- [Nv beshort 8 0 {} {}] 1 {>;emit i386/x86_64;<} 2 {>;emit Alpha/Sparc64;<} 3 {>;emit Sparc;<} 4 {>;emit MIPS;<} 5 {>;emit PowerPC;<} 6 {>;emit 68000;<} 7 {>;emit SGI;<} 8 {>;emit RS6000;<} 9 {>;emit IA64;<} 10 {>;emit Sparc64;<} 11 {>;emit MIPSel;<} 12 {>;emit ARM;<} 13 {>;emit MiNT;<} 14 {>;emit S/390;<} 15 {>;emit S/390x;<} 16 {>;emit PowerPC64;<} 17 {>;emit SuperH;<} 18 {>;emit Xtensa;<} 255 {>;emit noarch;<} 
<
;<} 
<

mime application/x-rpm
;<} -889275714 {>;
if {[N belong 4 0 0 {} {} > 30]} {>

emit {compiled Java class data,}

	if {[N beshort 6 0 0 {} {} x {}]} {>

	emit {version %d.}
<}

	if {[N beshort 4 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

	switch -- [Nv belong 4 0 {} {}] 46 {>;emit {(Java 1.2)};<} 47 {>;emit {(Java 1.3)};<} 48 {>;emit {(Java 1.4)};<} 49 {>;emit {(Java 1.5)};<} 50 {>;emit {(Java 1.6)};<} 51 {>;emit {(Java 1.7)};<} 52 {>;emit {(Java 1.8)};<} 
<

mime application/x-java-applet

<}
;<} -889270259 {>;emit {JAR compressed with pack200,}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d.}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b%d}
mime application/x-java-pack200

<}
;<} -889270259 {>;emit {JAR compressed with pack200,}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d.}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b%d}
mime application/x-java-pack200

<}
;<} -889275714 {>;
if {[N belong 4 0 0 {} {} == 1]} {>

emit {Mach-O universal binary with 1 architecture:}
U 8 mach-o

mime application/x-mach-binary

<}

if {[N belong 4 0 0 {} {} > 1]} {>

	if {[N belong 4 0 0 {} {} < 20]} {>

	emit {Mach-O universal binary with %d architectures:}
U 8 mach-o

	mime application/x-mach-binary

<}

	switch -- [Nv belong 4 0 {} {}] 2 {>;U 8 mach-o
;<} 3 {>;U 8 mach-o
;<} 4 {>;U 8 mach-o
;<} 5 {>;U 8 mach-o
;<} 6 {>;U 8 mach-o
;<} 
<

<}
;<} 263 {>;emit {Plan 9 executable, Motorola 68k};<} 491 {>;emit {Plan 9 executable, Intel 386};<} 583 {>;emit {Plan 9 executable, Intel 960};<} 683 {>;emit {Plan 9 executable, SPARC};<} 1031 {>;emit {Plan 9 executable, MIPS R3000};<} 1163 {>;emit {Plan 9 executable, AT&T DSP 3210};<} 1303 {>;emit {Plan 9 executable, MIPS R4000 BE};<} 1451 {>;emit {Plan 9 executable, AMD 29000};<} 1607 {>;emit {Plan 9 executable, ARM 7-something};<} 1771 {>;emit {Plan 9 executable, PowerPC};<} 1943 {>;emit {Plan 9 executable, MIPS R4000 LE};<} 2123 {>;emit {Plan 9 executable, DEC Alpha};<} 84017152 {>;emit {Kerberos Keytab file}
U 18 keytab_entry
;<} -976170042 {>;emit {DOS EPS Binary File}

if {[N long 4 0 0 {} {} > 0]} {>

emit {Postscript starts at byte %d}

	if {[N long 8 0 0 {} {} > 0]} {>

	emit {length %d}

		if {[N long 12 0 0 {} {} > 0]} {>

		emit {Metafile starts at byte %d}

			if {[N long 16 0 0 {} {} > 0]} {>

			emit {length %d}
<}

<}

		if {[N long 20 0 0 {} {} > 0]} {>

		emit {TIFF starts at byte %d}

			if {[N long 24 0 0 {} {} > 0]} {>

			emit {length %d}
<}

<}

<}

<}
;<} -951729837 {>;emit GEOS

switch -- [Nv byte 40 0 {} {}] 1 {>;emit executable;<} 2 {>;emit VMFile;<} 3 {>;emit binary;<} 4 {>;emit {directory label};<} 
<

if {[N byte 40 0 0 {} {} < 1]} {>

emit unknown
<}

if {[N byte 40 0 0 {} {} > 4]} {>

emit unknown
<}

if {[S string 4 0 {} {} > \0]} {>

emit {\b, name "%s"}
<}
;<} -1195374706 {>;emit {Linux kernel}

if {[S string 483 0 {} {} eq Loading]} {>

emit {version 1.3.79 or older}
<}

if {[S string 489 0 {} {} eq Loading]} {>

emit {from prehistoric times}
<}
;<} 1330597709 {>;emit {User-mode Linux COW file}

if {[N belong 4 0 0 {} {} < 3]} {>

emit {\b, version %d}

	if {[S string 8 0 {} {} > \0]} {>

	emit {\b, backing file %s}
<}

<}

if {[N belong 4 0 0 {} {} > 2]} {>

emit {\b, version %d}

	if {[S string 32 0 {} {} > \0]} {>

	emit {\b, backing file %s}
<}

<}
;<} -1195374706 {>;emit Linux

if {[N belong 486 0 0 {} {} == 1162627923]} {>

emit {ELKS Kernel}
<}

if {[N belong 486 0 0 {} {} != 1162627923]} {>

emit {style boot sector}
<}
;<} -804389139 {>;
if {[Nx byte [R [I 8 belong 0 0 0 0]] 0 0 {} {} x {}]} {>

	if {[Nx byte [R [I 12 belong 0 0 0 0]] 0 0 {} {} x {}]} {>

		if {[N belong 20 0 0 {} {} > 1]} {>

		emit {Device Tree Blob version %d}

			if {[N belong 4 0 0 {} {} x {}]} {>

			emit {\b, size=%d}
<}

			if {[N belong 20 0 0 {} {} > 1]} {>

				if {[N belong 28 0 0 {} {} x {}]} {>

				emit {\b, boot CPU=%d}
<}

<}

			if {[N belong 20 0 0 {} {} > 2]} {>

				if {[N belong 32 0 0 {} {} x {}]} {>

				emit {\b, string block size=%d}
<}

<}

			if {[N belong 20 0 0 {} {} > 16]} {>

				if {[N belong 36 0 0 {} {} x {}]} {>

				emit {\b, DT structure block size=%d}
<}

<}

<}

<}

<}
;<} 1018 {>;emit {AmigaOS shared library};<} 1011 {>;emit {AmigaOS loadseg()ble executable/binary};<} 999 {>;emit {AmigaOS object/library data};<} -2147479551 {>;emit {AmigaOS outline tag};<} -1040441407 {>;emit {Common Trace Format (CTF) trace data (BE)};<} 1976638807 {>;emit {Common Trace Format (CTF) packetized metadata (BE)}

if {[N byte 35 0 0 {} {} x {}]} {>

emit {\b, v%d}
<}

if {[N byte 36 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 4 {>;emit {X11 SNF font data, MSB first}
mime application/x-font-sfn
;<} 335698201 {>;emit {libGrx font data,}

if {[N leshort 8 0 0 {} {} x {}]} {>

emit %dx
<}

if {[N leshort 10 0 0 {} {} x {}]} {>

emit {\b%d}
<}

if {[S string 40 0 {} {} x {}]} {>

emit %s
<}
;<} -12169394 {>;emit {DOS code page font data collection};<} -1059131379 {>;emit {GStreamer binary registry}

if {[S string 4 0 {} {} x {}]} {>

emit {\b, version %s}
<}
;<} -1582119980 {>;emit {tcpdump capture file (big-endian)}
U 60 pcap-be

mime application/vnd.tcpdump.pcap
;<} -1582117580 {>;emit {extended tcpdump capture file (big-endian)}
U 60 pcap-be
;<} 168627466 {>;
if {[N belong 8 0 0 {} {} == 439041101]} {>

emit {pcap-ng capture file}

	if {[N beshort 12 0 0 {} {} x {}]} {>

	emit {- version %d}
<}

	if {[N beshort 14 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

<}
;<} 525398 {>;emit {SunOS core file}

switch -- [Nv belong 4 0 {} {}] 432 {>;emit (SPARC)

	if {[S string 132 0 {} {} > \0]} {>

	emit {from '%s'}
<}

	switch -- [Nv belong 116 0 {} {}] 3 {>;emit (quit);<} 4 {>;emit {(illegal instruction)};<} 5 {>;emit {(trace trap)};<} 6 {>;emit (abort);<} 7 {>;emit {(emulator trap)};<} 8 {>;emit {(arithmetic exception)};<} 9 {>;emit (kill);<} 10 {>;emit {(bus error)};<} 11 {>;emit {(segmentation violation)};<} 12 {>;emit {(bad argument to system call)};<} 29 {>;emit {(resource lost)};<} 
<

	if {[N belong 120 0 0 {} {} x {}]} {>

	emit (T=%dK,
<}

	if {[N belong 124 0 0 {} {} x {}]} {>

	emit D=%dK,
<}

	if {[N belong 128 0 0 {} {} x {}]} {>

	emit S=%dK)
<}
;<} 826 {>;emit (68K)

	if {[S string 128 0 {} {} > \0]} {>

	emit {from '%s'}
<}
;<} 456 {>;emit {(SPARC 4.x BCP)}

	if {[S string 152 0 {} {} > \0]} {>

	emit {from '%s'}
<}
;<} 
<
;<} 333312 {>;emit {AppleSingle encoded Macintosh file};<} 333319 {>;emit {AppleDouble encoded Macintosh file};<} -86111232 {>;emit {Mac OS X Code Requirement}

if {[N belong 8 0 0 {} {} == 1]} {>

emit (opExpr)
<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- %d bytes}
<}
;<} -86111231 {>;emit {Mac OS X Code Requirement Set}

if {[N belong 8 0 0 {} {} > 1]} {>

emit {containing %d items}
<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- %d bytes}
<}
;<} -86111230 {>;emit {Mac OS X Code Directory}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {version %x}
<}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {flags 0x%x}
<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- %d bytes}
<}
;<} -86111040 {>;emit {Mac OS X Detached Code Signature (non-executable)}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- %d bytes}
<}
;<} -86111039 {>;emit {Mac OS X Detached Code Signature}

if {[N belong 8 0 0 {} {} > 1]} {>

emit {(%d elements)}
<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- %d bytes}
<}
;<} 1347223552 {>;emit {Apple Partition Map}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {\b, map block count %d}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {\b, start block %d}
<}

if {[N belong 12 0 0 {} {} x {}]} {>

emit {\b, block count %d}
<}

if {[S string 16 0 {} {} > 0]} {>

emit {\b, name %s}
<}

if {[S string 48 0 {} {} > 0]} {>

emit {\b, type %s}
<}

if {[S string 124 0 {} {} > 0]} {>

emit {\b, processor %s}
<}

if {[S string 140 0 {} {} > 0]} {>

emit {\b, boot arguments %s}
<}

if {[N belong 92 0 0 {} {} & 1]} {>

emit {\b, valid}
<}

if {[N belong 92 0 0 {} {} & 2]} {>

emit {\b, allocated}
<}

if {[N belong 92 0 0 {} {} & 4]} {>

emit {\b, in use}
<}

if {[N belong 92 0 0 {} {} & 8]} {>

emit {\b, has boot info}
<}

if {[N belong 92 0 0 {} {} & 16]} {>

emit {\b, readable}
<}

if {[N belong 92 0 0 {} {} & 32]} {>

emit {\b, writable}
<}

if {[N belong 92 0 0 {} {} & 64]} {>

emit {\b, pic boot code}
<}

if {[N belong 92 0 0 {} {} & 128]} {>

emit {\b, chain compatible driver}
<}

if {[N belong 92 0 0 {} {} & 256]} {>

emit {\b, real driver}
<}

if {[N belong 92 0 0 {} {} & 512]} {>

emit {\b, chain driver}
<}

if {[N belong 92 0 0 {} {} & 1024]} {>

emit {\b, mount at startup}
<}

if {[N belong 92 0 0 {} {} & 2048]} {>

emit {\b, is the startup partition}
<}
;<} 440786851 {>;
if {[Sx search 4 0 {} 4096 eq \x42\x82]} {>

	if {[Sx string [R 1] 0 {} {} eq webm]} {>

	emit WebM
	mime video/webm

<}

	if {[Sx string [R 1] 0 {} {} eq matroska]} {>

	emit {Matroska data}
	mime video/x-matroska

<}

<}
;<} 1297241678 {>;emit {VMware nvram };<} 518517022 {>;emit {Pulsar POP3 daemon mailbox cache file.}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {Version: %d.}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {\b%d}
<}
;<} 324508365 {>;emit {GNU dbm 1.x or ndbm database, big endian, 32-bit}
mime application/x-gdbm
;<} 324508366 {>;emit {GNU dbm 1.x or ndbm database, big endian, old}
mime application/x-gdbm
;<} 324508367 {>;emit {GNU dbm 1.x or ndbm database, big endian, 64-bit}
mime application/x-gdbm
;<} 398689 {>;emit {Berkeley DB}

switch -- [Nv belong 8 0 {} {}] 4321 {>;
	if {[N belong 4 0 0 {} {} > 2]} {>

	emit 1.86
<}

	if {[N belong 4 0 0 {} {} < 3]} {>

	emit 1.85
<}

	if {[N belong 4 0 0 {} {} > 0]} {>

	emit {(Hash, version %d, big-endian)}
<}
;<} 1234 {>;
	if {[N belong 4 0 0 {} {} > 2]} {>

	emit 1.86
<}

	if {[N belong 4 0 0 {} {} < 3]} {>

	emit 1.85
<}

	if {[N belong 4 0 0 {} {} > 0]} {>

	emit {(Hash, version %d, native byte-order)}
<}
;<} 
<
;<} 340322 {>;emit {Berkeley DB 1.85/1.86}

if {[N belong 4 0 0 {} {} > 0]} {>

emit {(Btree, version %d, big-endian)}
<}
;<} 134551296 {>;emit {Bentley/Intergraph MicroStation DGN cell library};<} 134872578 {>;emit {Bentley/Intergraph MicroStation DGN vector CAD};<} -938869246 {>;emit {Bentley/Intergraph MicroStation DGN vector CAD};<} 32 {>;
if {[N byte 4 0 0 {} {} == 1]} {>

	if {[S string 8 0 {} {} eq KBXf]} {>

	emit {GPG keybox database}

		if {[N byte 5 0 0 {} {} == 1]} {>

		emit {version %d}
<}

		if {[N bedate 16 0 0 {} {} x {}]} {>

		emit {\b, created-at %s}
<}

		if {[N bedate 20 0 0 {} {} x {}]} {>

		emit {\b, last-maintained %s}
<}

<}

<}
;<} 834535424 {>;emit {Microsoft Word Document}
mime application/msword
;<} 6656 {>;emit {Lotus 1-2-3}

switch -- [Nv belong 4 0 {} {}] 1049600 {>;emit {wk3 document data};<} 34604032 {>;emit {wk4 document data};<} 125829376 {>;emit {fm3 or fmb document data};<} 125829120 {>;emit {fm3 or fmb document data};<} 
<

mime application/x-123
;<} 512 {>;emit {Lotus 1-2-3}

switch -- [Nv belong 4 0 {} {}] 100926976 {>;emit {wk1 document data};<} 109052416 {>;emit {fmt document data};<} 
<

mime application/x-123
;<} 256 {>;
switch -- [Nv byte 9 0 {} {}] 0 {>;
	if {[N byte 0 0 0 {} {} x {}]} {>

	emit {MS Windows icon resource}
	mime image/x-icon

<}
U 111 ico-dir
;<} -1 {>;
	if {[N byte 0 0 0 {} {} x {}]} {>

	emit {MS Windows icon resource}
	mime image/x-icon

<}
U 111 ico-dir
;<} 
<
;<} 512 {>;
switch -- [Nv byte 9 0 {} {}] 0 {>;
	if {[N byte 0 0 0 {} {} x {}]} {>

	emit {MS Windows cursor resource}
	mime image/x-cur

<}
U 111 cur-dir
;<} -1 {>;
	if {[N byte 0 0 0 {} {} x {}]} {>

	emit {MS Windows cursor resource}
	mime image/x-cur

<}
U 111 cur-dir
;<} 
<
;<} -976170042 {>;emit {DOS EPS Binary File}

if {[N long 4 0 0 {} {} > 0]} {>

emit {Postscript starts at byte %d}

	if {[N long 8 0 0 {} {} > 0]} {>

	emit {length %d}

		if {[N long 12 0 0 {} {} > 0]} {>

		emit {Metafile starts at byte %d}

			if {[N long 16 0 0 {} {} > 0]} {>

			emit {length %d}
<}

<}

		if {[N long 20 0 0 {} {} > 0]} {>

		emit {TIFF starts at byte %d}

			if {[N long 24 0 0 {} {} > 0]} {>

			emit {length %d}
<}

<}

<}

<}
;<} 1010974665 {>;
if {[N belong 4 0 0 {} {} == 1787282127]} {>

emit {Adrift game file version}

	switch -- [Nv belong 8 0 {} {}] -1807403423 {>;emit 3.80;<} -1807403167 {>;emit 3.90;<} -1824178591 {>;emit 4.0;<} -1840955807 {>;emit 5.0;<} 
<

	if {[S default 8 0 {} {} x {}]} {>

	emit unknown
	mime application/x-adrift

<}

<}
;<} 440786851 {>;emit {EBML file}

if {[Sx search 4 0 b 100 eq \102\202]} {>

	if {[Sx string [R 1] 0 {} {} x {}]} {>

	emit {\b, creator %.8s}
<}

<}
;<} 1886869041 {>;emit {Cracklib password index, big endian}

if {[N belong 4 0 0 {} {} > -1]} {>

emit {(%i words)}
<}
;<} 393218 {>;emit {GDSII Stream file}

if {[N byte 4 0 0 {} {} == 0]} {>

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {version %d.0}
<}

<}

if {[N byte 4 0 0 {} {} > 0]} {>

emit {version %d}

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

<}
;<} 13 {>;
if {[N beshort 4 0 0 {} {} == 2569]} {>

	if {[S string 6 0 {} {} eq OSMHeader]} {>

	emit {OpenStreetMap Protocolbuffer Binary Format}
<}

<}
;<} 1 {>;
if {[N byte 4 0 0 & 31 == 7]} {>

emit {JVT NAL sequence, H.264 video}

	switch -- [Nv byte 5 0 {} {}] 66 {>;emit {\b, baseline};<} 77 {>;emit {\b, main};<} 88 {>;emit {\b, extended};<} 
<

	if {[N byte 7 0 0 {} {} x {}]} {>

	emit {\b @ L %u}
<}

<}
;<} 807842421 {>;emit {Microsoft ASF}
mime video/x-ms-asf
;<} -1722938102 {>;emit {python 1.5/1.6 byte-compiled};<} -2017063670 {>;emit {python 2.0 byte-compiled};<} 720047370 {>;emit {python 2.1 byte-compiled};<} 770510090 {>;emit {python 2.2 byte-compiled};<} 1005718794 {>;emit {python 2.3 byte-compiled};<} 1844579594 {>;emit {python 2.4 byte-compiled};<} -1275982582 {>;emit {python 2.5 byte-compiled};<} -772666102 {>;emit {python 2.6 byte-compiled};<} 66260234 {>;emit {python 2.7 byte-compiled};<} 990645514 {>;emit {python 3.0 byte-compiled};<} 1326189834 {>;emit {python 3.1 byte-compiled};<} 1812729098 {>;emit {python 3.2 byte-compiled};<} -1643377398 {>;emit {python 3.3 byte-compiled};<} -301200118 {>;emit {python 3.4 byte-compiled};<} 1920139830 {>;emit {rdiff network-delta data};<} 1920139574 {>;emit {rdiff network-delta signature data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {(block length=%d,}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {signature strength=%d)}
<}
;<} 1314148939 {>;emit {MultiTrack sound data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}
;<} 779248125 {>;emit {RealAudio sound file}
mime audio/x-pn-realaudio
;<} 1688404224 {>;emit {IRCAM file (VAX little-endian)};<} 107364 {>;emit {IRCAM file (VAX big-endian)};<} 1688404480 {>;emit {IRCAM file (Sun big-endian)};<} 172900 {>;emit {IRCAM file (Sun little-endian)};<} 1688404736 {>;emit {IRCAM file (MIPS little-endian)};<} 238436 {>;emit {IRCAM file (MIPS big-endian)};<} 1688404992 {>;emit {IRCAM file (NeXT big-endian)};<} 1688404992 {>;emit {IRCAM file (NeXT big-endian)};<} 303972 {>;emit {IRCAM file (NeXT little-endian)};<} 196608 {>;
if {[N belong 49124 0 0 {} {} < 47104]} {>

	if {[N belong 49128 0 0 {} {} < 47104]} {>

		if {[N belong 49132 0 0 {} {} < 47104]} {>

			if {[N belong 49136 0 0 {} {} < 47104]} {>

			emit {QL OS dump data,}

				if {[S string 49148 0 {} {} > \0]} {>

				emit {type %.3s,}
<}

				if {[S string 49142 0 {} {} > \0]} {>

				emit {version %.4s}
<}

<}

<}

<}

<}
;<} 1257963521 {>;emit {QL plugin-ROM data,}

if {[S pstring 9 0 {} {} eq \0]} {>

emit un-named
<}

if {[S pstring 9 0 {} {} > \0]} {>

emit {named: %s}
<}
;<} 1936484385 {>;emit {Allegro datafile (packed)};<} 1936484398 {>;emit {Allegro datafile (not packed/autodetect)};<} 1936484395 {>;emit {Allegro datafile (appended exe data)};<} 505 {>;emit {AIX compiled message catalog};<} 327 {>;emit {Convex old-style object}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 331 {>;emit {Convex old-style demand paged executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 333 {>;emit {Convex old-style pre-paged executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 335 {>;emit {Convex old-style pre-paged, non-swapped executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 70231 {>;emit {Core file};<} 385 {>;emit {Convex SOFF}

if {[N belong 88 0 0 & 983040 == 0]} {>

emit c1
<}

if {[N belong 88 0 0 {} {} & 65536]} {>

emit c2
<}

if {[N belong 88 0 0 {} {} & 131072]} {>

emit c2mp
<}

if {[N belong 88 0 0 {} {} & 262144]} {>

emit parallel
<}

if {[N belong 88 0 0 {} {} & 524288]} {>

emit intrinsic
<}

if {[N belong 88 0 0 {} {} & 1]} {>

emit {demand paged}
<}

if {[N belong 88 0 0 {} {} & 2]} {>

emit pre-paged
<}

if {[N belong 88 0 0 {} {} & 4]} {>

emit non-swapped
<}

if {[N belong 88 0 0 {} {} & 8]} {>

emit POSIX
<}

if {[N belong 84 0 0 {} {} & 2147483648]} {>

emit executable
<}

if {[N belong 84 0 0 {} {} & 1073741824]} {>

emit object
<}

if {[N belong 84 0 0 & 536870912 == 0]} {>

emit {not stripped}
<}

switch -- [Nv belong 84 0 & 402653184] 0 {>;emit {native fpmode};<} 268435456 {>;emit {ieee fpmode};<} 402653184 {>;emit {undefined fpmode};<} 
<
;<} 389 {>;emit {Convex SOFF core};<} 391 {>;emit {Convex SOFF checkpoint}

if {[N belong 88 0 0 & 983040 == 0]} {>

emit c1
<}

if {[N belong 88 0 0 {} {} & 65536]} {>

emit c2
<}

if {[N belong 88 0 0 {} {} & 131072]} {>

emit c2mp
<}

if {[N belong 88 0 0 {} {} & 262144]} {>

emit parallel
<}

if {[N belong 88 0 0 {} {} & 524288]} {>

emit intrinsic
<}

if {[N belong 88 0 0 {} {} & 8]} {>

emit POSIX
<}

switch -- [Nv belong 84 0 & 402653184] 0 {>;emit {native fpmode};<} 268435456 {>;emit {ieee fpmode};<} 402653184 {>;emit {undefined fpmode};<} 
<
;<} 263 {>;emit {a.out big-endian 32-bit executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 264 {>;emit {a.out big-endian 32-bit pure executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 267 {>;emit {a.out big-endian 32-bit demand paged executable}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 256 {>;
if {[Nx beshort [I 4 belong 0 + 0 24] 0 0 {} {} x {}]} {>

	switch -- [Nvx belong [R 4] 0 {} {}] 1936092788 {>;emit {Mac OSX datafork font, TrueType};<} 1179602516 {>;emit {Mac OSX datafork font, 'FONT'};<} 1313230420 {>;emit {Mac OSX datafork font, 'NFNT'};<} 1347375956 {>;emit {Mac OSX datafork font, PostScript};<} 
<

<}
;<} 1279543401 {>;emit {ld.so hints file (Big Endian}

if {[N belong 4 0 0 {} {} > 0]} {>

emit {\b, version %d)}
<}

if {[N belong 4 0 0 {} {} < 1]} {>

emit {\b)}
<}
;<} -364936773 {>;emit {Conary changeset data};<} 34603270 {>;emit {PA-RISC1.1 relocatable object};<} 34603271 {>;emit {PA-RISC1.1 executable}

if {[N belong 168 0 0 {} {} & 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34603272 {>;emit {PA-RISC1.1 shared executable}

if {[N belong 168 0 0 & 4 == 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34603275 {>;emit {PA-RISC1.1 demand-load executable}

if {[N belong 168 0 0 & 4 == 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34603278 {>;emit {PA-RISC1.1 shared library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34603277 {>;emit {PA-RISC1.1 dynamic load library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34865414 {>;emit {PA-RISC2.0 relocatable object};<} 34865415 {>;emit {PA-RISC2.0 executable}

if {[N belong 168 0 0 {} {} & 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34865416 {>;emit {PA-RISC2.0 shared executable}

if {[N belong 168 0 0 {} {} & 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34865419 {>;emit {PA-RISC2.0 demand-load executable}

if {[N belong 168 0 0 {} {} & 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34865422 {>;emit {PA-RISC2.0 shared library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34865421 {>;emit {PA-RISC2.0 dynamic load library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34275590 {>;emit {PA-RISC1.0 relocatable object};<} 34275591 {>;emit {PA-RISC1.0 executable}

if {[N belong 168 0 0 & 4 == 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34275592 {>;emit {PA-RISC1.0 shared executable}

if {[N belong 168 0 0 & 4 == 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34275595 {>;emit {PA-RISC1.0 demand-load executable}

if {[N belong 168 0 0 & 4 == 4]} {>

emit {dynamically linked}
<}

if {[N belong [I 144 long 0 0 0 0] 0 0 {} {} == 89060912]} {>

emit {dynamically linked}
<}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34275598 {>;emit {PA-RISC1.0 shared library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 34275597 {>;emit {PA-RISC1.0 dynamic load library}

if {[N belong 96 0 0 {} {} > 0]} {>

emit {- not stripped}
<}
;<} 557605234 {>;emit {archive file}

switch -- [Nv belong 68 0 {} {}] 34276889 {>;emit {- PA-RISC1.0 relocatable library};<} 34604569 {>;emit {- PA-RISC1.1 relocatable library};<} 34670105 {>;emit {- PA-RISC1.2 relocatable library};<} 34866713 {>;emit {- PA-RISC2.0 relocatable library};<} 
<
;<} 34341128 {>;emit {HP s200 pure executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 8 0 0 {} {} & 2147483648]} {>

emit {save fp regs}
<}

if {[N belong 8 0 0 {} {} & 1073741824]} {>

emit {dynamically linked}
<}

if {[N belong 8 0 0 {} {} & 536870912]} {>

emit debuggable
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34341127 {>;emit {HP s200 executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 8 0 0 {} {} & 2147483648]} {>

emit {save fp regs}
<}

if {[N belong 8 0 0 {} {} & 1073741824]} {>

emit {dynamically linked}
<}

if {[N belong 8 0 0 {} {} & 536870912]} {>

emit debuggable
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34341131 {>;emit {HP s200 demand-load executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 8 0 0 {} {} & 2147483648]} {>

emit {save fp regs}
<}

if {[N belong 8 0 0 {} {} & 1073741824]} {>

emit {dynamically linked}
<}

if {[N belong 8 0 0 {} {} & 536870912]} {>

emit debuggable
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34341126 {>;emit {HP s200 relocatable executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N beshort 6 0 0 {} {} > 0]} {>

emit {- highwater %d}
<}

if {[N belong 8 0 0 {} {} & 2147483648]} {>

emit {save fp regs}
<}

if {[N belong 8 0 0 {} {} & 536870912]} {>

emit debuggable
<}

if {[N belong 8 0 0 {} {} & 268435456]} {>

emit PIC
<}
;<} 34210056 {>;emit {HP s200 (2.x release) pure executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34210055 {>;emit {HP s200 (2.x release) executable}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34341134 {>;emit {HP s200 shared library}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N beshort 6 0 0 {} {} > 0]} {>

emit {- highwater %d}
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 34341133 {>;emit {HP s200 dynamic load library}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N beshort 6 0 0 {} {} > 0]} {>

emit {- highwater %d}
<}

if {[N belong 36 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 65389 {>;emit {very old 32-bit-int big-endian archive};<} 65381 {>;emit {old 32-bit-int big-endian archive}

if {[S string 4 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}
;<} 518520576 {>;emit {EET archive}
mime application/x-eet
;<} 123 {>;emit {dar archive,}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {label "%.8x}

	if {[N belong 8 0 0 {} {} x {}]} {>

	emit %.8x

		if {[N beshort 12 0 0 {} {} x {}]} {>

		emit %.4x\"
<}

<}

<}

if {[N byte 14 0 0 {} {} == 84]} {>

emit {end slice}
<}

switch -- [Nv beshort 14 0 {} {}] 20046 {>;emit multi-part;<} 20051 {>;emit {multi-part, with -S};<} 
<
;<} 326773060 {>;emit {NeWS bitmap font};<} 326773063 {>;emit {NeWS font family};<} 326773072 {>;emit {scalable OpenFont binary};<} 326773073 {>;emit {encrypted scalable OpenFont binary};<} -302060034 {>;emit {Sun 'jks' Java Keystore File data};<} 101117429 {>;emit {Adobe InDesign}

if {[S string 16 0 {} {} eq DOCUMENT]} {>

emit Document
<}
;<} -11534511 {>;emit {JPEG 2000 codestream};<} 1125466468 {>;emit {X64 Image};<} -12432129 {>;emit {WRAptor packer (c64)};<} 554074152 {>;emit {Sega Dreamcast VMU game image};<} 199600449 {>;emit {SGI disk label (volume header)};<} 1481003842 {>;emit {SGI XFS filesystem data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {(blksz %d,}
<}

if {[N beshort 104 0 0 {} {} x {}]} {>

emit {inosz %d,}
<}

if {[N beshort 100 0 0 {} {} ^ 8196]} {>

emit {v1 dirs)}
<}

if {[N beshort 100 0 0 {} {} & 8196]} {>

emit {v2 dirs)}
<}
;<} 684539205 {>;emit {Linux Compressed ROM File System data, big endian}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {size %u}
<}

if {[N belong 8 0 0 {} {} & 1]} {>

emit {version #2}
<}

if {[N belong 8 0 0 {} {} & 2]} {>

emit sorted_dirs
<}

if {[N belong 8 0 0 {} {} & 4]} {>

emit hole_support
<}

if {[N belong 32 0 0 {} {} x {}]} {>

emit {CRC 0x%x,}
<}

if {[N belong 36 0 0 {} {} x {}]} {>

emit {edition %u,}
<}

if {[N belong 40 0 0 {} {} x {}]} {>

emit {%u blocks,}
<}

if {[N belong 44 0 0 {} {} x {}]} {>

emit {%u files}
<}
;<} 876099889 {>;emit {Linux Journalled Flash File system, big endian};<} 654645590 {>;emit {u-boot legacy uImage,}

if {[S string 32 0 {} {} x {}]} {>

emit %s,
<}

switch -- [Nv byte 28 0 {} {}] 0 {>;emit {Invalid os/};<} 1 {>;emit OpenBSD/;<} 2 {>;emit NetBSD/;<} 3 {>;emit FreeBSD/;<} 4 {>;emit 4.4BSD/;<} 5 {>;emit Linux/;<} 6 {>;emit SVR4/;<} 7 {>;emit Esix/;<} 8 {>;emit Solaris/;<} 9 {>;emit Irix/;<} 10 {>;emit SCO/;<} 11 {>;emit Dell/;<} 12 {>;emit NCR/;<} 13 {>;emit LynxOS/;<} 14 {>;emit VxWorks/;<} 15 {>;emit pSOS/;<} 16 {>;emit QNX/;<} 17 {>;emit Firmware/;<} 18 {>;emit RTEMS/;<} 19 {>;emit ARTOS/;<} 20 {>;emit {Unity OS/};<} 21 {>;emit INTEGRITY/;<} 
<

switch -- [Nv byte 29 0 {} {}] 0 {>;emit {\bInvalid CPU,};<} 1 {>;emit {\bAlpha,};<} 2 {>;emit {\bARM,};<} 3 {>;emit {\bIntel x86,};<} 4 {>;emit {\bIA64,};<} 5 {>;emit {\bMIPS,};<} 6 {>;emit {\bMIPS 64-bit,};<} 7 {>;emit {\bPowerPC,};<} 8 {>;emit {\bIBM S390,};<} 9 {>;emit {\bSuperH,};<} 10 {>;emit {\bSparc,};<} 11 {>;emit {\bSparc 64-bit,};<} 12 {>;emit {\bM68K,};<} 13 {>;emit {\bNios-32,};<} 14 {>;emit {\bMicroBlaze,};<} 15 {>;emit {\bNios-II,};<} 16 {>;emit {\bBlackfin,};<} 17 {>;emit {\bAVR32,};<} 18 {>;emit {\bSTMicroelectronics ST200,};<} 
<

switch -- [Nv byte 30 0 {} {}] 0 {>;emit {Invalid Image};<} 1 {>;emit {Standalone Program};<} 2 {>;emit {OS Kernel Image};<} 3 {>;emit {RAMDisk Image};<} 4 {>;emit {Multi-File Image};<} 5 {>;emit {Firmware Image};<} 6 {>;emit {Script File};<} 7 {>;emit {Filesystem Image (any type)};<} 8 {>;emit {Binary Flat Device Tree BLOB};<} 
<

switch -- [Nv byte 31 0 {} {}] 0 {>;emit {(Not compressed),};<} 1 {>;emit (gzip),;<} 2 {>;emit (bzip2),;<} 3 {>;emit (lzma),;<} 
<

if {[N belong 12 0 0 {} {} x {}]} {>

emit {%d bytes,}
<}

if {[N bedate 8 0 0 {} {} x {}]} {>

emit %s,
<}

if {[N belong 16 0 0 {} {} x {}]} {>

emit {Load Address: 0x%08X,}
<}

if {[N belong 20 0 0 {} {} x {}]} {>

emit {Entry Point: 0x%08X,}
<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {Header CRC: 0x%08X,}
<}

if {[N belong 24 0 0 {} {} x {}]} {>

emit {Data CRC: 0x%08X}
<}
;<} 50331648 {>;
if {[N belong 8 0 0 {} {} == 3959554048]} {>

emit {VMS Alpha executable}

	if {[S string 75264 0 {} {} eq PK\003\004]} {>

	emit {\b, Info-ZIP SFX archive v5.12 w/decryption}
<}

<}
;<} 1396917837 {>;emit {IRIS Showcase file}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}
;<} 1413695053 {>;emit {IRIS Showcase template}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}
;<} -559039810 {>;emit {IRIX Parallel Arena}

if {[N belong 8 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} -559043152 {>;emit {IRIX core dump}

if {[N belong 4 0 0 {} {} == 1]} {>

emit of
<}

if {[S string 16 0 {} {} > \0]} {>

emit '%s'
<}
;<} -559043264 {>;emit {IRIX 64-bit core dump}

if {[N belong 4 0 0 {} {} == 1]} {>

emit of
<}

if {[S string 16 0 {} {} > \0]} {>

emit '%s'
<}
;<} -1161903941 {>;emit {IRIX N32 core dump}

if {[N belong 4 0 0 {} {} == 1]} {>

emit of
<}

if {[S string 16 0 {} {} > \0]} {>

emit '%s'
<}
;<} 9994 {>;emit {ESRI Shapefile}

if {[N belong 4 0 0 {} {} == 0]} {>

<}

if {[N belong 8 0 0 {} {} == 0]} {>

<}

if {[N belong 12 0 0 {} {} == 0]} {>

<}

if {[N belong 16 0 0 {} {} == 0]} {>

<}

if {[N belong 20 0 0 {} {} == 0]} {>

<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {version %d}
<}

if {[N belong 24 0 0 {} {} x {}]} {>

emit {length %d}
<}

switch -- [Nv lelong 32 0 {} {}] 0 {>;emit {type Null Shape};<} 1 {>;emit {type Point};<} 3 {>;emit {type PolyLine};<} 5 {>;emit {type Polygon};<} 8 {>;emit {type MultiPoint};<} 11 {>;emit {type PointZ};<} 13 {>;emit {type PolyLineZ};<} 15 {>;emit {type PolygonZ};<} 18 {>;emit {type MultiPointZ};<} 21 {>;emit {type PointM};<} 23 {>;emit {type PolyLineM};<} 25 {>;emit {type PolygonM};<} 28 {>;emit {type MultiPointM};<} 31 {>;emit {type MultiPatch};<} 
<
;<} -17957139 {>;emit {Java KeyStore}
mime application/x-java-keystore
;<} -825307442 {>;emit {Java JCE KeyStore}
mime application/x-java-jce-keystore
;<} -249691108 {>;emit {magic binary file for file(1) cmd}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {(version %d) (big endian)}
<}
;<} 1504078485 {>;emit {Sun raster image data}

if {[N belong 4 0 0 {} {} > 0]} {>

emit {\b, %d x}
<}

if {[N belong 8 0 0 {} {} > 0]} {>

emit %d,
<}

if {[N belong 12 0 0 {} {} > 0]} {>

emit %d-bit,
<}

switch -- [Nv belong 20 0 {} {}] 0 {>;emit {old format,};<} 2 {>;emit compressed,;<} 3 {>;emit RGB,;<} 4 {>;emit TIFF,;<} 5 {>;emit IFF,;<} 65535 {>;emit {reserved for testing,};<} 
<

switch -- [Nv belong 24 0 {} {}] 0 {>;emit {no colormap};<} 1 {>;emit {RGB colormap};<} 2 {>;emit {raw colormap};<} 
<
;<} 235082497 {>;emit {Hierarchical Data Format (version 4) data}
mime application/x-hdf
;<} 
<
} {
if {[S string 0 0 {} {} eq drpm]} {>

emit {Delta RPM}

if {[S string 12 0 {} {} x {}]} {>

emit %s

	switch -- [Nv beshort 8 0 {} {}] 11 {>;emit MIPSel;<} 12 {>;emit ARM;<} 13 {>;emit MiNT;<} 14 {>;emit S/390;<} 15 {>;emit S/390x;<} 16 {>;emit PowerPC64;<} 17 {>;emit SuperH;<} 18 {>;emit Xtensa;<} 
<

	if {[S string 10 0 {} {} x {}]} {>

	emit %s
<}

<}

mime application/x-rpm

<}
} {
if {[S string 0 0 {} {} eq XIA1]} {>

emit {Chiasmus encrypted data}
<}
} {
if {[S string 0 0 {} {} eq XIS]} {>

emit {Chiasmus key}
<}
} {
if {[S string 0 0 {} {} eq lect]} {>

emit {DEC SRC Virtual Paper Lectern file}
<}
} {
if {[S string 0 0 {} {} eq \#\ PaCkAgE\ DaTaStReAm]} {>

emit {pkg Datastream (SVR4)}
mime application/x-svr4-package

<}
} {
if {[S string 0 0 {} {} eq LBLSIZE=]} {>

emit {VICAR image data}

if {[S string 32 0 {} {} eq BYTE]} {>

emit {\b, 8 bits  = VAX byte}
<}

if {[S string 32 0 {} {} eq HALF]} {>

emit {\b, 16 bits = VAX word     = Fortran INTEGER*2}
<}

if {[S string 32 0 {} {} eq FULL]} {>

emit {\b, 32 bits = VAX longword = Fortran INTEGER*4}
<}

if {[S string 32 0 {} {} eq REAL]} {>

emit {\b, 32 bits = VAX longword = Fortran REAL*4}
<}

if {[S string 32 0 {} {} eq DOUB]} {>

emit {\b, 64 bits = VAX quadword = Fortran REAL*8}
<}

if {[S string 32 0 {} {} eq COMPLEX]} {>

emit {\b, 64 bits = VAX quadword = Fortran COMPLEX*8}
<}

<}
} {
if {[S string 43 0 {} {} eq SFDU_LABEL]} {>

emit {VICAR label file}
<}
} {
switch -- [Nv belong 24 0 {} {}] 60012 {>;emit {new-fs dump file (big endian), }
U 7 new-dump-be
;<} 60011 {>;emit {old-fs dump file (big endian), }
U 7 old-dump-be
;<} 424935705 {>;emit {new-fs dump file (ufs2, big endian), }
U 7 ufs2-dump-be
;<} 60013 {>;emit {dump format, 4.2 or 4.3 BSD (IDC compatible)};<} 60014 {>;emit {dump format, Convex Storage Manager by-reference dump};<} 1562156707 {>;emit {Nintendo Wii disc image:}
U 240 nintendo-gcn-disc-common
;<} 
<
} {
switch -- [Nv lelong 24 0 {} {}] 60012 {>;emit {new-fs dump file (little endian), }
U 7 new-dump-be
;<} 60011 {>;emit {old-fs dump file (little endian), }
U 7 old-dump-be
;<} 424935705 {>;emit {new-fs dump file (ufs2, little endian), }
U 7 ufs2-dump-be
;<} 
<
} {
if {[N leshort 18 0 0 {} {} == 60011]} {>

emit {old-fs dump file (16-bit, assuming PDP-11 endianness),}

if {[N medate 2 0 0 {} {} x {}]} {>

emit {Previous dump %s,}
<}

if {[N medate 6 0 0 {} {} x {}]} {>

emit {This dump %s,}
<}

if {[N leshort 10 0 0 {} {} > 0]} {>

emit {Volume %d,}
<}

switch -- [Nv leshort 0 0 {} {}] 1 {>;emit {tape header.};<} 2 {>;emit {beginning of file record.};<} 3 {>;emit {map of inodes on tape.};<} 4 {>;emit {continuation of file record.};<} 5 {>;emit {end of volume.};<} 6 {>;emit {map of inodes deleted.};<} 7 {>;emit {end of medium (for floppy).};<} 
<

<}
} {
if {[S string 0 0 {} {} eq %XDELTA%]} {>

emit {XDelta binary patch file 0.14}
<}
} {
if {[S string 0 0 {} {} eq %XDZ000%]} {>

emit {XDelta binary patch file 0.18}
<}
} {
if {[S string 0 0 {} {} eq %XDZ001%]} {>

emit {XDelta binary patch file 0.20}
<}
} {
if {[S string 0 0 {} {} eq %XDZ002%]} {>

emit {XDelta binary patch file 1.0}
<}
} {
if {[S string 0 0 {} {} eq %XDZ003%]} {>

emit {XDelta binary patch file 1.0.4}
<}
} {
if {[S string 0 0 {} {} eq %XDZ004%]} {>

emit {XDelta binary patch file 1.1}
<}
} {
if {[S string 0 0 {} {} eq \xD6\xC3\xC4\x00]} {>

emit {VCDIFF binary diff}
<}
} {
if {[S string 0 0 {} {} eq <!DOCTYPE\040RCC>]} {>

emit {Qt Resource Collection file}
<}
} {
if {[S string 0 0 {} {} eq qres\0\0]} {>

emit {Qt Binary Resource file}
<}
} {
if {[S search 0 0 {} 1024 eq The\040Resource\040Compiler\040for\040Qt]} {>

emit {Qt C-code resource file}
<}
} {
if {[S string 0 0 {} {} eq \x3c\xb8\x64\x18\xca\xef\x9c\x95]} {>

if {[S string 8 0 {} {} eq \xcd\x21\x1c\xbf\x60\xa1\xbd\xdd]} {>

emit {Qt Translation file}
<}

<}
} {
if {[S search 0 0 {} 1 eq //!Mup]} {>

emit {Mup music publication program input text}

if {[S string 6 0 {} {} eq -Arkkra]} {>

emit (Arkkra)

	if {[S string 13 0 {} {} eq -]} {>

		if {[S string 16 0 {} {} eq .]} {>

			if {[S string 14 0 {} {} x {}]} {>

			emit {\b, need V%.4s}
<}

<}

		if {[S string 15 0 {} {} eq .]} {>

			if {[S string 14 0 {} {} x {}]} {>

			emit {\b, need V%.3s}
<}

<}

<}

<}

if {[S string 6 0 {} {} eq -]} {>

	if {[S string 9 0 {} {} eq .]} {>

		if {[S string 7 0 {} {} x {}]} {>

		emit {\b, need V%.4s}
<}

<}

	if {[S string 8 0 {} {} eq .]} {>

		if {[S string 7 0 {} {} x {}]} {>

		emit {\b, need V%.3s}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \311\304]} {>

emit {ID tags data}

if {[N short 2 0 0 {} {} > 0]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/sh]} {>

emit {POSIX shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /bin/sh]} {>

emit {POSIX shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/csh]} {>

emit {C shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/ksh]} {>

emit {Korn shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /bin/ksh]} {>

emit {Korn shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/tcsh]} {>

emit {Tenex C shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/tcsh]} {>

emit {Tenex C shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/tcsh]} {>

emit {Tenex C shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/tcsh]} {>

emit {Tenex C shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/zsh]} {>

emit {Paul Falstad's zsh script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/zsh]} {>

emit {Paul Falstad's zsh script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/zsh]} {>

emit {Paul Falstad's zsh script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/ash]} {>

emit {Neil Brown's ash script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/ae]} {>

emit {Neil Brown's ae script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/nawk]} {>

emit {new awk script text executable}
mime text/x-nawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/nawk]} {>

emit {new awk script text executable}
mime text/x-nawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/nawk]} {>

emit {new awk script text executable}
mime text/x-nawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/gawk]} {>

emit {GNU awk script text executable}
mime text/x-gawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/gawk]} {>

emit {GNU awk script text executable}
mime text/x-gawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/gawk]} {>

emit {GNU awk script text executable}
mime text/x-gawk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/awk]} {>

emit {awk script text executable}
mime text/x-awk

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/awk]} {>

emit {awk script text executable}
mime text/x-awk

<}
} {
if {[S regex 0 0 {} 4096 eq ^\\s\{0,100\}BEGIN\\s\{0,100\}\[\{\]]} {>

emit {awk or perl script text}
<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/rc]} {>

emit {Plan 9 rc shell script text executable}
<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /bin/bash]} {>

emit {Bourne-Again shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /bin/bash]} {>

emit {Bourne-Again shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/bash]} {>

emit {Bourne-Again shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /usr/bin/bash]} {>

emit {Bourne-Again shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bash]} {>

emit {Bourne-Again shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /usr/local/bash]} {>

emit {Bourne-Again shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/local/bin/bash]} {>

emit {Bourne-Again shell script text executable}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w b} {} eq \#!\ /usr/local/bin/bash]} {>

emit {Bourne-Again shell script executable (binary data)}
mime text/x-shellscript

<}
} {
if {[S string 0 0 {w t} {} eq \#!\ /usr/bin/env\ bash]} {>

emit {Bourne-Again shell script text executable}
mime text/x-shellscript

<}
} {
if {[S search 0 0 c 1 eq <?php]} {>

emit {PHP script text}
mime text/x-php

<}
} {
if {[S search 0 0 {} 1 eq <?\n]} {>

emit {PHP script text}
mime text/x-php

<}
} {
if {[S search 0 0 {} 1 eq <?\r]} {>

emit {PHP script text}
mime text/x-php

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/php]} {>

emit {PHP script text executable}
mime text/x-php

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/php]} {>

emit {PHP script text executable}
mime text/x-php

<}
} {
if {[S string 0 0 {} {} eq <?php]} {>

if {[S regex 5 0 {} {} eq \[\ \n\]]} {>

	if {[S string 6 0 {} {} eq /*\ Smarty\ version]} {>

	emit {Smarty compiled template}

		if {[S regex 24 0 {} {} eq \[0-9.\]+]} {>

		emit {\b, version %s}
		mime text/x-php

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq Zend\x00]} {>

emit {PHP script Zend Optimizer data}
<}
} {
if {[S string 0 0 t {} eq \$!]} {>

emit {DCL command file}
<}
} {
if {[S string 0 0 {} {} eq \#!/usr/bin/pdmenu]} {>

emit {Pdmenu configuration file text}
<}
} {
if {[S string 0 0 {} {} eq RaS]} {>

if {[S string 3 0 {} {} eq t]} {>

emit {Cups Raster version 1, Big Endian}
<}

if {[S string 3 0 {} {} eq 2]} {>

emit {Cups Raster version 2, Big Endian}
<}

if {[S string 3 0 {} {} eq 3]} {>

emit {Cups Raster version 3, Big Endian}
mime application/vnd.cups-raster

<}
U 15 cups-le

<}
} {
if {[S string 1 0 {} {} eq SaR]} {>

if {[S string 0 0 {} {} eq t]} {>

emit {Cups Raster version 1, Little Endian}
<}

if {[S string 0 0 {} {} eq 2]} {>

emit {Cups Raster version 2, Little Endian}
<}

if {[S string 0 0 {} {} eq 3]} {>

emit {Cups Raster version 3, Little Endian}
mime application/vnd.cups-raster

<}
U 15 cups-le

<}
} {
switch -- [Nvx lelong 0 0 {} {}] -1010055483 {>;emit {RISC OS Chunk data}

if {[S string 12 0 {} {} eq OBJ_]} {>

emit {\b, AOF object}
<}

if {[S string 12 0 {} {} eq LIB_]} {>

emit {\b, ALF library}
<}
;<} -21555 {>;emit {MLSSA datafile,}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {algorithm %d,}
<}

if {[N lelong 10 0 0 {} {} x {}]} {>

emit {%d samples}
<}
;<} 6553863 {>;emit {Linux/i386 impure executable (OMAGIC)}

if {[N lelong 16 0 0 {} {} == 0]} {>

emit {\b, stripped}
<}
;<} 6553864 {>;emit {Linux/i386 pure executable (NMAGIC)}

if {[N lelong 16 0 0 {} {} == 0]} {>

emit {\b, stripped}
<}
;<} 6553867 {>;emit {Linux/i386 demand-paged executable (ZMAGIC)}

if {[N lelong 16 0 0 {} {} == 0]} {>

emit {\b, stripped}
<}
;<} 6553804 {>;emit {Linux/i386 demand-paged executable (QMAGIC)}

if {[N lelong 16 0 0 {} {} == 0]} {>

emit {\b, stripped}
<}
;<} 336851773 {>;emit {SYSLINUX' LSS16 image data}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {\b, width %d}
<}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\b, height %d}
<}

mime image/x-lss16
;<} -109248628 {>;emit {SE Linux policy}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit v%d
<}

if {[N lelong 20 0 0 {} {} == 1]} {>

emit MLS
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {%d symbols}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {%d ocons}
<}
;<} -109248628 {>;emit {SE Linux policy}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit v%d
<}

if {[N lelong 20 0 0 {} {} == 1]} {>

emit MLS
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {%d symbols}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {%d ocons}
<}
;<} -570294007 {>;emit {locale archive}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {%d strings}
<}
;<} -1456779524 {>;emit {Linux Software RAID}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {version 1.1 (%d)}
<}
U 32 linuxraid
;<} 1160843812 {>;emit {iproute2 routes dump};<} 1194725922 {>;emit {iproute2 addresses dump};<} 1414939417 {>;emit {CRIU image file v1.1};<} 1427134784 {>;emit {CRIU service file};<} 1479618838 {>;emit {CRIU inventory};<} -1040441407 {>;emit {Common Trace Format (CTF) trace data (LE)};<} 1976638807 {>;emit {Common Trace Format (CTF) packetized metadata (LE)}

if {[N byte 35 0 0 {} {} x {}]} {>

emit {\b, v%d}
<}

if {[N byte 36 0 0 {} {} x {}]} {>

emit {\b.%d}
<}
;<} 4 {>;
if {[N lelong 104 0 0 {} {} == 4]} {>

emit {X11 SNF font data, LSB first}
mime application/x-font-sfn

<}
;<} 38177486 {>;emit {Bochs Sparse disk image};<} 204 {>;emit {386 compact demand paged pure executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 32 0 0 {} {} == 106]} {>

emit {(uses shared libs)}
<}
;<} -1582119980 {>;emit {tcpdump capture file (little-endian)}
U 60 pcap-be

mime application/vnd.tcpdump.pcap
;<} -1582117580 {>;emit {extended tcpdump capture file (little-endian)}
U 60 pcap-be
;<} 168627466 {>;
if {[N lelong 8 0 0 {} {} == 439041101]} {>

emit {pcap-ng capture file}

	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit {- version %d}
<}

	if {[N leshort 14 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

<}
;<} 220991 {>;
if {[Nx leshort [I 4 lelong 0 + 0 9] 0 0 {} {} == 10555]} {>

emit MS

	if {[S string 212 0 {} {} eq \x62\x6D\x66\x01\x00]} {>

	emit {Windows help annotation}
	mime application/x-winhelp

	ext ann

<}

	if {[Sx string 212 0 {} {} ne \x62\x6D\x66\x01\x00]} {>

		if {[S string [I 4 lelong 0 + 0 101] 0 {} {} eq |Pete]} {>

		emit {Windows help Global Index}
		mime application/x-winhelp

		ext gid

<}

		if {[Sx string [I 4 lelong 0 + 0 101] 0 {} {} ne |Pete]} {>

			if {[Sx search 16 0 {} 18863 eq s]} {>

			emit {\x6c\x03 	}
U 72 help-ver-date

				if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

					if {[Sx search [R 0] 0 {} 27055 eq s]} {>

					emit {\x6c\x03 	}
U 72 help-ver-date

						if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

							if {[Sx search [R 0] 0 {} 18863 eq s]} {>

							emit {\x6c\x03 	}
U 72 help-ver-date

								if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

									if {[Sx search [R 0] 0 {} 18863 eq s]} {>

									emit {\x6c\x03 	}
U 72 help-ver-date

										if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

											if {[Sx search [R 0] 0 {} 18863 eq s]} {>

											emit {\x6c\x03 	}
U 72 help-ver-date

												if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

													if {[Sx search [R 0] 0 {} 18863 eq s]} {>

													emit {\x6c\x03 	}
U 72 help-ver-date

														if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

															if {[Sx search [R 0] 0 {} 18863 eq s]} {>

															emit {\x6c\x03 	}
U 72 help-ver-date

																if {[Nx leshort [R 4] 0 0 {} {} != 1]} {>

																emit {Windows y.z help}
																mime application/winhelp

																ext hlp

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

			if {[S search 16 0 {} 18863 eq s]} {>

			emit {\x6c\x03 	}
<}

			if {[S default 16 0 {} {} x {}]} {>

			emit {Windows help Bookmark}
			mime application/x-winhelp

			ext /bmk

<}

<}

<}

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit {\b, %d bytes}
<}

<}
;<} 1313096225 {>;emit {Microsoft Outlook email folder}

switch -- [Nv leshort 10 0 {} {}] 14 {>;emit (<=2002);<} 23 {>;emit (>=2003);<} 
<
;<} 324508365 {>;emit {GNU dbm 1.x or ndbm database, little endian, 32-bit}
mime application/x-gdbm
;<} 324508366 {>;emit {GNU dbm 1.x or ndbm database, little endian, old}
mime application/x-gdbm
;<} 324508367 {>;emit {GNU dbm 1.x or ndbm database, little endian, 64-bit}
mime application/x-gdbm
;<} 340322 {>;emit {Berkeley DB 1.85/1.86}

if {[N lelong 4 0 0 {} {} > 0]} {>

emit {(Btree, version %d, little-endian)}
<}
;<} -109248628 {>;emit {SE Linux policy}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit v%d
<}

if {[N lelong 20 0 0 {} {} == 1]} {>

emit MLS
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {%d symbols}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {%d ocons}
<}
;<} 518 {>;emit b.out

if {[N leshort 30 0 0 {} {} & 16]} {>

emit overlay
<}

if {[N leshort 30 0 0 {} {} & 2]} {>

emit separate
<}

if {[N leshort 30 0 0 {} {} & 4]} {>

emit pure
<}

if {[N leshort 30 0 0 {} {} & 2048]} {>

emit segmented
<}

if {[N leshort 30 0 0 {} {} & 1024]} {>

emit standalone
<}

if {[N leshort 30 0 0 {} {} & 1]} {>

emit executable
<}

if {[N leshort 30 0 0 {} {} ^ 1]} {>

emit {object file}
<}

if {[N leshort 30 0 0 {} {} & 16384]} {>

emit V2.3
<}

if {[N leshort 30 0 0 {} {} & 32768]} {>

emit V3.0
<}

if {[N byte 28 0 0 {} {} & 4]} {>

emit 86
<}

if {[N byte 28 0 0 {} {} & 11]} {>

emit 186
<}

if {[N byte 28 0 0 {} {} & 9]} {>

emit 286
<}

if {[N byte 28 0 0 {} {} & 41]} {>

emit 286
<}

if {[N byte 28 0 0 {} {} & 10]} {>

emit 386
<}

if {[N leshort 30 0 0 {} {} & 4]} {>

emit {Large Text}
<}

if {[N leshort 30 0 0 {} {} & 2]} {>

emit {Large Data}
<}

if {[N leshort 30 0 0 {} {} & 258]} {>

emit {Huge Objects Enabled}
<}
;<} 234 {>;emit {BALANCE NS32000 .o}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 4330 {>;emit {BALANCE NS32000 executable (0 @ 0)}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 8426 {>;emit {BALANCE NS32000 executable (invalid @ 0)}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 12522 {>;emit {BALANCE NS32000 standalone executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 250739385 {>;
switch -- [Nvx lelong 4 0 {} {}] 1 {>;emit {Universal EFI binary with 1 architecture}

	switch -- [Nvx lelong [R 0] 0 {} {}] 7 {>;emit {\b, i386};<} 16777223 {>;emit {\b, x86_64};<} 
<
;<} 2 {>;emit {Universal EFI binary with 2 architectures}

	switch -- [Nvx lelong [R 0] 0 {} {}] 7 {>;emit {\b, i386};<} 16777223 {>;emit {\b, x86_64};<} 
<

	switch -- [Nvx lelong [R 20] 0 {} {}] 7 {>;emit {\b, i386};<} 16777223 {>;emit {\b, x86_64};<} 
<
;<} 
<

if {[N lelong 4 0 0 {} {} > 2]} {>

emit {Universal EFI binary with %d architectures}
<}
;<} -61205 {>;emit {DR-DOS executable (COM)};<} 4 {>;
if {[N lelong 12 0 0 {} {} == 280]} {>

emit {Windows Recycle Bin INFO2 file (Win98 or below)}
<}
;<} 5 {>;
if {[N lelong 12 0 0 {} {} == 800]} {>

emit {Windows Recycle Bin INFO2 file (Win2k - WinXP)}
<}
;<} 134769520 {>;emit {TurboC BGI file};<} 134761296 {>;emit {TurboC Font file};<} 76 {>;
if {[N lelong 4 0 0 {} {} == 136193]} {>

emit {Windows shortcut file}
<}
;<} 1212429320 {>;emit {4DOS help file}

if {[S string 4 0 {} {} x {}]} {>

emit {\b, version %-4.4s}
<}
;<} 1 {>;
if {[S string 40 0 {} {} eq \ EMF]} {>

emit {Windows Enhanced Metafile (EMF) image data}

	if {[N lelong 44 0 0 {} {} x {}]} {>

	emit {version 0x%x}
<}

<}
;<} 407708164 {>;emit {LZ4 compressed data (v1.4+)}
mime application/x-lz4
;<} 407642371 {>;emit {LZ4 compressed data (v1.0-v1.3)}
mime application/x-lz4
;<} 407642370 {>;emit {LZ4 compressed data (v0.1-v0.9)}
mime application/x-lz4
;<} 1437209140 {>;emit {Valve Pak file}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {\b, version %u}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, %u entries}
<}
;<} -1641380927 {>;emit {Unreal Engine Package,}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version: %i}
<}

if {[N lelong 12 0 0 {} {} != 0]} {>

emit {\b, names: %i}
<}

if {[N lelong 28 0 0 {} {} != 0]} {>

emit {\b, imports: %i}
<}

if {[N lelong 20 0 0 {} {} != 0]} {>

emit {\b, exports: %i}
<}
;<} 459141 {>;emit {ECOFF NetBSD/alpha binary}

switch -- [Nv leshort 10 0 {} {}] 1 {>;emit {not stripped};<} 0 {>;emit stripped;<} 
<
;<} 305436790 {>;
if {[N lequad 28 0 0 & 18446744060824649724 == 0]} {>

	if {[N lelong 4 0 0 {} {} < 128]} {>

	emit {Partition Information Table for Samsung smartphone}

		if {[N lelong 4 0 0 {} {} x {}]} {>

		emit {\b, %d entries}
<}

		if {[N lelong 4 0 0 {} {} > 0]} {>

		emit {\b; #1}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 1]} {>

		emit {\b; #2}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 2]} {>

		emit {\b; #3}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 3]} {>

		emit {\b; #4}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 4]} {>

		emit {\b; #5}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 5]} {>

		emit {\b; #6}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 6]} {>

		emit {\b; #7}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 7]} {>

		emit {\b; #8}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 8]} {>

		emit {\b; #9}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 9]} {>

		emit {\b; #10}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 10]} {>

		emit {\b; #11}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 11]} {>

		emit {\b; #12}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 12]} {>

		emit {\b; #13}
U 122 PIT-entry

<}

		if {[N lelong 4 0 0 {} {} > 13]} {>

		emit {\b; #14}
U 122 PIT-entry

<}

		if {[N lelong 4 0 0 {} {} > 14]} {>

		emit {\b; #15}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 15]} {>

		emit {\b; #16}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 16]} {>

		emit {\b; #17}
<}
U 122 PIT-entry

		if {[N lelong 4 0 0 {} {} > 17]} {>

		emit {\b; #18}
<}
U 122 PIT-entry

<}

<}
;<} -316211398 {>;emit {Android sparse image}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {\b, version: %d}
<}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {\b, Total of %d}
<}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {\b %d-byte output blocks in}
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit {\b %d input chunks.}
<}
;<} 524291 {>;emit {Android binary XML};<} 1 {>;
if {[N lelong 4 0 0 {} {} == 100]} {>

	if {[N lelong 8 0 0 {} {} == 10000]} {>

		if {[N lelong 12 0 0 {} {} == 50]} {>

			if {[N lelong 16 0 0 {} {} == 50000]} {>

				if {[N lelong 20 0 0 {} {} == 100]} {>

					if {[N lelong 24 0 0 {} {} == 1000]} {>

						if {[N lelong 28 0 0 {} {} == 1000]} {>

							if {[N lelong 36 0 0 {} {} == 10]} {>

								if {[N lelong 40 0 0 {} {} == 100]} {>

									if {[N lelong 32 0 0 {} {} x {}]} {>

									emit {LG robot VR6[234]xx %dm^2 navigation}
<}

									switch -- [Nv lelong 136040 0 {} {}] -1 {>;emit {reuse map data};<} 0 {>;emit {map data};<} 
<

									if {[N lelong 136040 0 0 {} {} > 0]} {>

									emit {spurious map data}
<}

									if {[N lelong 136040 0 0 {} {} < -1]} {>

									emit {spurious map data}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}
;<} 1886869041 {>;emit {Cracklib password index, little endian}

if {[N long 4 0 0 {} {} > 0]} {>

emit {(%i words)}
<}

if {[N long 4 0 0 {} {} == 0]} {>

emit (\"64-bit\")

	if {[N long 8 0 0 {} {} > -1]} {>

	emit {(%i words)}
<}

<}
;<} 33645 {>;emit {PDP-11 single precision APL workspace};<} 33644 {>;emit {PDP-11 double precision APL workspace};<} 6583086 {>;emit {DEC audio data:}

switch -- [Nv lelong 12 0 {} {}] 1 {>;emit {8-bit ISDN mu-law,}
mime audio/x-dec-basic
;<} 2 {>;emit {8-bit linear PCM [REF-PCM],}
mime audio/x-dec-basic
;<} 3 {>;emit {16-bit linear PCM,}
mime audio/x-dec-basic
;<} 4 {>;emit {24-bit linear PCM,}
mime audio/x-dec-basic
;<} 5 {>;emit {32-bit linear PCM,}
mime audio/x-dec-basic
;<} 6 {>;emit {32-bit IEEE floating point,}
mime audio/x-dec-basic
;<} 7 {>;emit {64-bit IEEE floating point,}
mime audio/x-dec-basic
;<} 23 {>;emit {8-bit ISDN mu-law compressed (CCITT G.721 ADPCM voice enc.),}
mime audio/x-dec-basic
;<} 
<

switch -- [Nv belong 12 0 {} {}] 8 {>;emit {Fragmented sample data,};<} 10 {>;emit {DSP program,};<} 11 {>;emit {8-bit fixed point,};<} 12 {>;emit {16-bit fixed point,};<} 13 {>;emit {24-bit fixed point,};<} 14 {>;emit {32-bit fixed point,};<} 18 {>;emit {16-bit linear with emphasis,};<} 19 {>;emit {16-bit linear compressed,};<} 20 {>;emit {16-bit linear with emphasis and compression,};<} 21 {>;emit {Music kit DSP commands,};<} 24 {>;emit {compressed (8-bit CCITT G.722 ADPCM)};<} 25 {>;emit {compressed (3-bit CCITT G.723.3 ADPCM),};<} 26 {>;emit {compressed (5-bit CCITT G.723.5 ADPCM),};<} 27 {>;emit {8-bit A-law (CCITT G.711),};<} 
<

switch -- [Nv lelong 20 0 {} {}] 1 {>;emit mono,;<} 2 {>;emit stereo,;<} 4 {>;emit quad,;<} 
<

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {%d Hz}
<}
;<} -109248625 {>;emit {SE Linux modular policy}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {%d sections,}

	if {[N lelong [I 12 lelong 0 0 0 0] 0 0 {} {} == 4185718669]} {>

		if {[N lelong [I 12 lelong 0 + 0 27] 0 0 {} {} x {}]} {>

		emit {mod version %d,}
<}

		switch -- [Nv lelong [I 12 lelong 0 + 0 31] 0 {} {}] 0 {>;emit {Not MLS,};<} 1 {>;emit MLS,;<} 
<

		switch -- [Nv lelong [I 12 lelong 0 + 0 23] 0 {} {}] 2 {>;
			if {[S string [I 12 lelong 0 + 0 47] 0 {} {} > \0]} {>

			emit {module name %s}
<}
;<} 1 {>;emit base;<} 
<

<}

<}
;<} 329904510 {>;emit {ST40 component image format}

if {[S string 4 0 {} {} > \0]} {>

emit {\b, name '%s'}
<}
;<} 263 {>;emit {a.out little-endian 32-bit executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 32 0 0 {} {} == 106]} {>

emit {(uses BSD/OS shared libs)}
<}
;<} 264 {>;emit {a.out little-endian 32-bit pure executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 32 0 0 {} {} == 106]} {>

emit {(uses BSD/OS shared libs)}
<}
;<} 267 {>;emit {a.out little-endian 32-bit demand paged pure executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 32 0 0 {} {} == 106]} {>

emit {(uses BSD/OS shared libs)}
<}
;<} 267429210 {>;emit {Intel serial flash for ICH/PCH ROM <= 5 or 3400 series A-step};<} 1279543401 {>;emit {ld.so hints file (Little Endian}

if {[N lelong 4 0 0 {} {} > 0]} {>

emit {\b, version %d)}
<}

if {[N belong 4 0 0 {} {} < 1]} {>

emit {\b)}
<}
;<} 33647 {>;emit {VAX single precision APL workspace};<} 33646 {>;emit {VAX double precision APL workspace};<} 272 {>;emit {a.out VAX demand paged (first page unmapped) pure executable}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 65389 {>;emit {very old 32-bit-int little-endian archive};<} 65381 {>;emit {old 32-bit-int little-endian archive}

if {[S string 4 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}
;<} 236525 {>;emit {PDP-11 old archive};<} 236526 {>;emit {PDP-11 4.0 archive};<} 270539386 {>;emit {Symbian installation file (Symbian OS 9.x)}
mime x-epoc/x-sisx-app
;<} 268435511 {>;emit {Psion Series 5}

switch -- [Nv lelong 4 0 {} {}] 268435513 {>;emit {font file};<} 268435514 {>;emit {printer driver};<} 268435515 {>;emit clipboard;<} 268435522 {>;emit {multi-bitmap image}
mime image/x-epoc-mbm
;<} 268435562 {>;emit {application information file};<} 268435565 {>;
	switch -- [Nv lelong 8 0 {} {}] 268435581 {>;emit {Sketch image}
	mime image/x-epoc-sketch
;<} 268435582 {>;emit {voice note};<} 268435583 {>;emit {Word file}
	mime application/x-epoc-word
;<} 268435589 {>;emit {OPL program (TextEd)}
	mime application/x-epoc-opl
;<} 268435591 {>;emit {Comms settings};<} 268435592 {>;emit {Sheet file}
	mime application/x-epoc-sheet
;<} 268435908 {>;emit {EasyFax initialisation file};<} 
<
;<} 268435571 {>;emit {OPO module}
mime application/x-epoc-opo
;<} 268435572 {>;emit {OPL application}
mime application/x-epoc-app
;<} 268435594 {>;emit {exported multi-bitmap image};<} 268435821 {>;
	if {[N lelong 8 0 0 {} {} == 268435591]} {>

	emit {Comms names}
<}
;<} 
<
;<} 268435521 {>;emit {Psion Series 5 ROM multi-bitmap image};<} 268435536 {>;emit {Psion Series 5}

switch -- [Nv lelong 4 0 {} {}] 268435565 {>;emit database

	switch -- [Nv lelong 8 0 {} {}] 268435588 {>;emit {Agenda file}
	mime application/x-epoc-agenda
;<} 268435590 {>;emit {Data file}
	mime application/x-epoc-data
;<} 268438762 {>;emit {Jotter file}
	mime application/x-epoc-jotter
;<} 
<
;<} 268435684 {>;emit {ini file};<} 
<
;<} 268435577 {>;emit {Psion Series 5 binary:}

switch -- [Nv lelong 4 0 {} {}] 0 {>;emit DLL;<} 268435529 {>;emit {comms hardware library};<} 268435530 {>;emit {comms protocol library};<} 268435549 {>;emit OPX;<} 268435564 {>;emit application;<} 268435597 {>;emit DLL;<} 268435628 {>;emit {logical device driver};<} 268435629 {>;emit {physical device driver};<} 268435685 {>;emit {file transfer protocol};<} 268435685 {>;emit {file transfer protocol};<} 268435776 {>;emit {printer definition};<} 268435777 {>;emit {printer definition};<} 
<
;<} 268435578 {>;emit {Psion Series 5 executable};<} 186106078 {>;emit {LLVM bitcode, wrapper}

switch -- [Nv lelong 16 0 {} {}] 16777223 {>;emit x86_64;<} 7 {>;emit i386;<} 18 {>;emit ppc;<} 16777234 {>;emit ppc64;<} 12 {>;emit arm;<} 
<
;<} 574529400 {>;emit {Transport Neutral Encapsulation Format}
mime application/vnd.ms-tnef
;<} -1700603645 {>;emit {Keepass password database}

switch -- [Nv lelong 4 0 {} {}] -1253311643 {>;emit {1.x KDB}

	if {[N lelong 48 0 0 {} {} > 0]} {>

	emit {\b, %d groups}
<}

	if {[N lelong 52 0 0 {} {} > 0]} {>

	emit {\b, %d entries}
<}

	switch -- [Nv lelong 8 0 & 15] 1 {>;emit {\b, SHA-256};<} 2 {>;emit {\b, AES};<} 4 {>;emit {\b, RC4};<} 8 {>;emit {\b, Twofish};<} 
<

	if {[N lelong 120 0 0 {} {} > 0]} {>

	emit {\b, %d key transformation rounds}
<}
;<} -1253311641 {>;emit {2.x KDBX};<} 
<
;<} 453186358 {>;emit {L	Netboot image,}

if {[N lelong 4 0 0 & 4294967040 == 0]} {>

	switch -- [Nv lelong 4 0 & 256] 0 {>;emit {mode 2};<} 256 {>;emit {mode 3};<} 
<

<}

if {[N lelong 4 0 0 & 4294967040 != 0]} {>

emit {unknown mode}
<}
;<} 8127978 {>;emit {pxelinux loader (version 2.13 or older)};<} 1617337446 {>;emit {pxelinux loader};<} -1073740310 {>;emit {pxelinux loader (version 3.70 or newer)};<} 684539205 {>;emit {Linux Compressed ROM File System data, little endian}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {size %u}
<}

if {[N lelong 8 0 0 {} {} & 1]} {>

emit {version #2}
<}

if {[N lelong 8 0 0 {} {} & 2]} {>

emit sorted_dirs
<}

if {[N lelong 8 0 0 {} {} & 4]} {>

emit hole_support
<}

if {[N lelong 32 0 0 {} {} x {}]} {>

emit {CRC 0x%x,}
<}

if {[N lelong 36 0 0 {} {} x {}]} {>

emit {edition %u,}
<}

if {[N lelong 40 0 0 {} {} x {}]} {>

emit {%u blocks,}
<}

if {[N lelong 44 0 0 {} {} x {}]} {>

emit {%u files}
<}
;<} 876099889 {>;emit {Linux Journalled Flash File system, little endian};<} 459106 {>;emit {LFS filesystem image}

switch -- [Nv lelong 4 0 {} {}] 1 {>;emit {version 1,}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b blocks %u,}
<}

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit {\b blocks per segment %u,}
<}
;<} 2 {>;emit {version 2,}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b fragments %u,}
<}

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit {\b bytes per segment %u,}
<}
;<} 
<

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {\b disk blocks %u,}
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit {\b block size %u,}
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {\b fragment size %u,}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {\b fragments per block %u,}
<}

if {[N lelong 32 0 0 {} {} x {}]} {>

emit {\b start for free list %u,}
<}

if {[N lelong 36 0 0 {} {} x {}]} {>

emit {\b number of free blocks %d,}
<}

if {[N lelong 40 0 0 {} {} x {}]} {>

emit {\b number of files %u,}
<}

if {[N lelong 44 0 0 {} {} x {}]} {>

emit {\b blocks available for writing %d,}
<}

if {[N lelong 48 0 0 {} {} x {}]} {>

emit {\b inodes in cache %d,}
<}

if {[N lelong 52 0 0 {} {} x {}]} {>

emit {\b inode file disk address 0x%x,}
<}

if {[N lelong 56 0 0 {} {} x {}]} {>

emit {\b inode file inode number %u,}
<}

if {[N lelong 60 0 0 {} {} x {}]} {>

emit {\b address of last segment written 0x%x,}
<}

if {[N lelong 64 0 0 {} {} x {}]} {>

emit {\b address of next segment to write 0x%x,}
<}

if {[N lelong 68 0 0 {} {} x {}]} {>

emit {\b address of current segment written 0x%x}
<}
;<} 101718065 {>;
if {[N leshort 22 0 0 {} {} == 0]} {>

emit {UBIfs image}
<}

if {[N lequad 8 0 0 {} {} x {}]} {>

emit {\b, sequence number %llu}
<}

if {[N leshort 16 0 0 {} {} x {}]} {>

emit {\b, length %u}
<}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {\b, CRC 0x%08x}
<}
;<} 592003669 {>;
if {[N leshort 4 0 0 {} {} < 2]} {>

<}

if {[S string 5 0 {} {} eq \0\0\0]} {>

<}

if {[S string 28 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

<}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {UBI image, version %u}
<}
;<} 320013059 {>;emit {SpeedShop data file};<} 16922978 {>;emit {mdbm file, version 0 (obsolete)};<} -249691108 {>;emit {magic binary file for file(1) cmd}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {(version %d) (little endian)}
<}
;<} 1638399 {>;emit {GEM Metafile data}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version %d}
<}
;<} 987654321 {>;emit {DCX multi-page PCX image data};<} -681629056 {>;emit {Cineon image data}

if {[N belong 200 0 0 {} {} > 0]} {>

emit {\b, %d x}
<}

if {[N belong 204 0 0 {} {} > 0]} {>

emit %d
<}
;<} 20000630 {>;emit {OpenEXR image data,}

if {[N lelong 4 0 0 & 255 x {}]} {>

emit {version %d,}
<}

if {[N lelong 4 0 0 {} {} ^ 512]} {>

emit {storage: scanline}
<}

if {[N lelong 4 0 0 {} {} & 512]} {>

emit {storage: tiled}
<}

if {[Sx search 8 0 {} 4096 eq compression\0]} {>

emit {\b, compression:}

	switch -- [Nvx byte [R 16] 0 {} {}] 0 {>;emit none;<} 1 {>;emit rle;<} 2 {>;emit zips;<} 3 {>;emit zip;<} 4 {>;emit piz;<} 5 {>;emit pxr24;<} 6 {>;emit b44;<} 7 {>;emit b44a;<} 
<

	if {[Nx byte [R 16] 0 0 {} {} > 7]} {>

	emit unknown
<}

<}

if {[Sx search 8 0 {} 4096 eq dataWindow\0]} {>

emit {\b, dataWindow:}

	if {[Nx lelong [R 10] 0 0 {} {} x {}]} {>

	emit (%d
<}

	if {[Nx lelong [R 14] 0 0 {} {} x {}]} {>

	emit %d)-
<}

	if {[Nx lelong [R 18] 0 0 {} {} x {}]} {>

	emit {\b(%d}
<}

	if {[Nx lelong [R 22] 0 0 {} {} x {}]} {>

	emit %d)
<}

<}

if {[Sx search 8 0 {} 4096 eq displayWindow\0]} {>

emit {\b, displayWindow:}

	if {[Nx lelong [R 10] 0 0 {} {} x {}]} {>

	emit (%d
<}

	if {[Nx lelong [R 14] 0 0 {} {} x {}]} {>

	emit %d)-
<}

	if {[Nx lelong [R 18] 0 0 {} {} x {}]} {>

	emit {\b(%d}
<}

	if {[Nx lelong [R 22] 0 0 {} {} x {}]} {>

	emit %d)
<}

<}

if {[Sx search 8 0 {} 4096 eq lineOrder\0]} {>

emit {\b, lineOrder:}

	switch -- [Nvx byte [R 14] 0 {} {}] 0 {>;emit {increasing y};<} 1 {>;emit {decreasing y};<} 2 {>;emit {random y};<} 
<

	if {[Nx byte [R 14] 0 0 {} {} > 2]} {>

	emit unknown
<}

<}

mime image/x-exr
;<} 16 {>;emit {TIM image,}

switch -- [Nv lelong 4 0 {} {}] 8 {>;emit 4-Bit,;<} 9 {>;emit 8-Bit,;<} 2 {>;emit 15-Bit,;<} 3 {>;emit 24-Bit,;<} 
<

if {[N lelong 4 0 0 {} {} & 8]} {>

	if {[N leshort [I 8 lelong 0 + 0 12] 0 0 {} {} x {}]} {>

	emit {Pixel at (%d,}
<}

	if {[N leshort [I 8 lelong 0 + 0 14] 0 0 {} {} x {}]} {>

	emit {\b%d)}
<}

	if {[N leshort [I 8 lelong 0 + 0 16] 0 0 {} {} x {}]} {>

	emit Size=%dx
<}

	if {[N leshort [I 8 lelong 0 + 0 18] 0 0 {} {} x {}]} {>

	emit {\b%d,}
<}

	switch -- [Nv lelong 4 0 {} {}] 8 {>;emit {16 CLUT Entries at};<} 9 {>;emit {256 CLUT Entries at};<} 
<

	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit (%d,
<}

	if {[N leshort 14 0 0 {} {} x {}]} {>

	emit {\b%d)}
<}

<}

if {[N lelong 4 0 0 {} {} ^ 8]} {>

	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit {Pixel at (%d,}
<}

	if {[N leshort 14 0 0 {} {} x {}]} {>

	emit {\b%d)}
<}

	if {[N leshort 16 0 0 {} {} x {}]} {>

	emit Size=%dx
<}

	if {[N leshort 18 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

<}
;<} -2147417760 {>;emit {MDEC video stream,}

if {[N leshort 16 0 0 {} {} x {}]} {>

emit %dx
<}

if {[N leshort 18 0 0 {} {} x {}]} {>

emit {\b%d}
<}
;<} 
<
} {
switch -- [Nv lelong 16 0 {} {}] -285212655 {>;emit {RISC OS AIF executable};<} 267429210 {>;emit {Intel serial flash for PCH ROM};<} 
<
} {
if {[S string 0 0 {} {} eq Draw]} {>

emit {RISC OS Draw file data}
<}
} {
if {[S string 0 0 {} {} eq FONT\0]} {>

emit {RISC OS outline font data,}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq FONT\1]} {>

emit {RISC OS 1bpp font data,}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq FONT\4]} {>

emit {RISC OS 4bpp font data}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq Maestro\r]} {>

emit {RISC OS music file}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version %d}
<}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {type %d}
<}

<}
} {
if {[S string 0 0 {} {} eq \x02\x01\x13\x13\x13\x01\x0d\x10]} {>

emit {Digital Symphony sound sample (RISC OS),}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[S pstring 9 0 {} {} x {}]} {>

emit {named "%s",}
<}

switch -- [Nv byte [I 9 byte 0 + 0 19] 0 {} {}] 0 {>;emit {8-bit logarithmic};<} 1 {>;emit {LZW-compressed linear};<} 2 {>;emit {8-bit linear signed};<} 3 {>;emit {16-bit linear signed};<} 4 {>;emit {SigmaDelta-compressed linear};<} 5 {>;emit {SigmaDelta-compressed logarithmic};<} 
<

if {[N byte [I 9 byte 0 + 0 19] 0 0 {} {} > 5]} {>

emit {unknown format}
<}

<}
} {
if {[S string 0 0 {} {} eq \x02\x01\x13\x13\x14\x12\x01\x0b]} {>

emit {Digital Symphony song (RISC OS),}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N byte 9 0 0 {} {} == 1]} {>

emit {1 voice,}
<}

if {[N byte 9 0 0 {} {} != 1]} {>

emit {%d voices,}
<}

if {[N leshort 10 0 0 {} {} == 1]} {>

emit {1 track,}
<}

if {[N leshort 10 0 0 {} {} != 1]} {>

emit {%d tracks,}
<}

if {[N leshort 12 0 0 {} {} == 1]} {>

emit {1 pattern}
<}

if {[N leshort 12 0 0 {} {} != 1]} {>

emit {%d patterns}
<}

<}
} {
if {[S string 0 0 {} {} eq \x02\x01\x13\x13\x10\x14\x12\x0e]} {>

switch -- [Nv byte 9 0 {} {}] 0 {>;emit {Digital Symphony sequence (RISC OS),}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {version %d,}
<}

	if {[N byte 10 0 0 {} {} == 1]} {>

	emit {1 line,}
<}

	if {[N byte 10 0 0 {} {} != 1]} {>

	emit {%d lines,}
<}

	if {[N leshort 11 0 0 {} {} == 1]} {>

	emit {1 position}
<}

	if {[N leshort 11 0 0 {} {} != 1]} {>

	emit {%d positions}
<}
;<} 1 {>;emit {Digital Symphony pattern data (RISC OS),}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {version %d,}
<}

	if {[N leshort 10 0 0 {} {} == 1]} {>

	emit {1 pattern}
<}

	if {[N leshort 10 0 0 {} {} != 1]} {>

	emit {%d patterns}
<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq \320\317\021\340\241\261\032\341]} {>

emit {OLE 2 Compound Document}

if {[S string 1152 0 {} {} eq D\000g\000n\000~\000H]} {>

emit {: Microstation V8 DGN}
<}

if {[S string 1152 0 {} {} eq V\000i\000s\000i\000o\000D\000o\000c]} {>

emit {: Visio Document}
<}

<}
} {
if {[S string 0 0 {} {} eq KarmaRHD\040Version]} {>

emit {Karma Data Structure Version}

if {[N belong 16 0 0 {} {} x {}]} {>

emit %u
<}

<}
} {
if {[S string 0 0 {} {} eq \037\135\211]} {>

emit {FuseCompress(ed) data}

switch -- [Nv byte 3 0 {} {}] 0 {>;emit {(none format)};<} 1 {>;emit {(bz2 format)};<} 2 {>;emit {(gz format)};<} 3 {>;emit {(lzo format)};<} 4 {>;emit {(xor format)};<} 
<

if {[N byte 3 0 0 {} {} > 4]} {>

emit {(unknown format)}
<}

if {[N long 4 0 0 {} {} x {}]} {>

emit {uncompressed size: %d}
<}

<}
} {
if {[S search 0 0 {} 1 eq begin\ ]} {>

emit {uuencoded or xxencoded text}
<}
} {
if {[S search 0 0 {} 1 eq xbtoa\ Begin]} {>

emit {btoa'd text}
<}
} {
if {[S search 0 0 {} 1 eq \$\012ship]} {>

emit {ship'd binary text}
<}
} {
if {[S search 0 0 {} 1 eq Decode\ the\ following\ with\ bdeco]} {>

emit {bencoded News text}
<}
} {
if {[S search 11 0 {} 1 eq must\ be\ converted\ with\ BinHex]} {>

emit {BinHex binary text}

if {[S search 41 0 {} 1 x {}]} {>

emit {\b, version %.3s}
<}

<}
} {
if {[Sx string 0 0 {} {} eq %!]} {>

emit {PostScript document text}

if {[Sx string 2 0 {} {} eq PS-Adobe-]} {>

emit conforming

	if {[Sx string 11 0 {} {} > \0]} {>

	emit {DSC level %.3s}

		if {[S string 15 0 {} {} eq EPS]} {>

		emit {\b, type %s}
<}

		if {[S string 15 0 {} {} eq Query]} {>

		emit {\b, type %s}
<}

		if {[S string 15 0 {} {} eq ExitServer]} {>

		emit {\b, type %s}
<}

		if {[Sx search 15 0 {} 1000 eq %%LanguageLevel:\ ]} {>

			if {[Sx string [R 0] 0 {} {} > \0]} {>

			emit {\b, Level %s}
<}

<}

<}

<}

mime application/postscript

<}
} {
if {[Sx string 0 0 {} {} eq \004%!]} {>

emit {PostScript document text}

if {[Sx string 3 0 {} {} eq PS-Adobe-]} {>

emit conforming

	if {[Sx string 12 0 {} {} > \0]} {>

	emit {DSC level %.3s}

		if {[S string 16 0 {} {} eq EPS]} {>

		emit {\b, type %s}
<}

		if {[S string 16 0 {} {} eq Query]} {>

		emit {\b, type %s}
<}

		if {[S string 16 0 {} {} eq ExitServer]} {>

		emit {\b, type %s}
<}

		if {[Sx search 16 0 {} 1000 eq %%LanguageLevel:\ ]} {>

			if {[Sx string [R 0] 0 {} {} > \0]} {>

			emit {\b, Level %s}
<}

<}

<}

<}

mime application/postscript

<}
} {
if {[S string 0 0 {} {} eq \033%-12345X%!PS]} {>

emit {PostScript document}
<}
} {
if {[Sx string 0 0 {} {} eq *PPD-Adobe:\x20]} {>

emit {PPD file}

if {[Sx string [R 0] 0 {} {} x {}]} {>

emit {\b, version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq \033%-12345X@PJL]} {>

emit {HP Printer Job Language data}
<}
} {
if {[Sx string 0 0 {} {} eq \033%-12345X@PJL]} {>

emit {HP Printer Job Language data}

if {[Sx string [R 0] 0 {} {} > \0]} {>

emit {%s			}

	if {[Sx string [R 0] 0 {} {} > \0]} {>

	emit {%s			}

		if {[Sx string [R 0] 0 {} {} > \0]} {>

		emit {%s		}

			if {[Sx string [R 0] 0 {} {} > \0]} {>

			emit {%s		}
<}

<}

<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq \033%-12345X@PJL]} {>

if {[Sx search [R 0] 0 {} 10000 eq %!]} {>

emit {PJL encapsulated PostScript document text}
<}

<}
} {
if {[S string 0 0 {} {} eq \033%-12345X@PJL]} {>

emit {HP Printer Job Language data}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE=HBPL]} {>

emit {- HBPL}
<}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE=HIPERC]} {>

emit {- Oki Data HIPERC}
<}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE=LAVAFLOW]} {>

emit {- Konica Minolta LAVAFLOW}
<}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE=QPDL]} {>

emit {- Samsung QPDL}
<}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE\ =\ QPDL]} {>

emit {- Samsung QPDL}
<}

if {[S search 0 0 {} 10000 eq @PJL\ ENTER\ LANGUAGE=ZJS]} {>

emit {- HP ZJS}
<}

<}
} {
if {[S string 0 0 {} {} eq \033E\033]} {>

emit {HP PCL printer data}

if {[S string 3 0 {} {} eq &l0A]} {>

emit {- default page size}
<}

if {[S string 3 0 {} {} eq &l1A]} {>

emit {- US executive page size}
<}

if {[S string 3 0 {} {} eq &l2A]} {>

emit {- US letter page size}
<}

if {[S string 3 0 {} {} eq &l3A]} {>

emit {- US legal page size}
<}

if {[S string 3 0 {} {} eq &l26A]} {>

emit {- A4 page size}
<}

if {[S string 3 0 {} {} eq &l80A]} {>

emit {- Monarch envelope size}
<}

if {[S string 3 0 {} {} eq &l81A]} {>

emit {- No. 10 envelope size}
<}

if {[S string 3 0 {} {} eq &l90A]} {>

emit {- Intl. DL envelope size}
<}

if {[S string 3 0 {} {} eq &l91A]} {>

emit {- Intl. C5 envelope size}
<}

if {[S string 3 0 {} {} eq &l100A]} {>

emit {- Intl. B5 envelope size}
<}

if {[S string 3 0 {} {} eq &l-81A]} {>

emit {- No. 10 envelope size (landscape)}
<}

if {[S string 3 0 {} {} eq &l-90A]} {>

emit {- Intl. DL envelope size (landscape)}
<}

<}
} {
if {[S string 0 0 {} {} eq @document(]} {>

emit {Imagen printer}

if {[S string 10 0 {} {} eq language\ impress]} {>

emit {(imPRESS data)}
<}

if {[S string 10 0 {} {} eq language\ daisy]} {>

emit {(daisywheel text)}
<}

if {[S string 10 0 {} {} eq language\ diablo]} {>

emit {(daisywheel text)}
<}

if {[S string 10 0 {} {} eq language\ printer]} {>

emit {(line printer emulation)}
<}

if {[S string 10 0 {} {} eq language\ tektronix]} {>

emit {(Tektronix 4014 emulation)}
<}

<}
} {
if {[S string 0 0 {} {} eq Rast]} {>

emit {RST-format raster font data}

if {[S string 45 0 {} {} > 0]} {>

emit {face %s}
<}

<}
} {
if {[S string 0 0 {} {} eq \033\[K\002\0\0\017\033(a\001\0\001\033(g]} {>

emit {Canon Bubble Jet BJC formatted data}
<}
} {
if {[S string 0 0 {} {} eq \x1B\x40\x1B\x28\x52\x08\x00\x00REMOTE1P]} {>

emit {Epson Stylus Color 460 data}
<}
} {
if {[S string 0 0 {} {} eq JZJZ]} {>

if {[S string 18 0 {} {} eq ZZ]} {>

emit {Zenographics ZjStream printer data (big-endian)}
<}

<}
} {
if {[S string 0 0 {} {} eq ZJZJ]} {>

if {[S string 18 0 {} {} eq ZZ]} {>

emit {Zenographics ZjStream printer data (little-endian)}
<}

<}
} {
if {[S string 0 0 {} {} eq OAK]} {>

if {[N byte 7 0 0 {} {} == 0]} {>

<}

if {[N byte 11 0 0 {} {} == 0]} {>

emit {Oak Technologies printer stream}
<}

<}
} {
if {[S string 0 0 {} {} eq %!VMF]} {>

emit {SunClock's Vector Map Format data}
<}
} {
if {[S string 0 0 {} {} eq \xbe\xefABCDEFGH]} {>

emit {HP LaserJet 1000 series downloadable firmware   }
<}
} {
if {[S string 0 0 {} {} eq \x1b\x01@EJL]} {>

emit {Epson ESC/Page language printer data}
<}
} {
if {[S string 0 0 {} {} eq \000\000\0001\000\000\0000\000\000\0000\000\000\0002\000\000\0000\000\000\0000\000\000\0003]} {>

emit {old ACE/gr binary file}

if {[N byte 39 0 0 {} {} > 0]} {>

emit {- version %c}
<}

<}
} {
if {[S string 0 0 {} {} eq \#\ xvgr\ parameter\ file]} {>

emit {ACE/gr ascii file}
<}
} {
if {[S string 0 0 {} {} eq \#\ xmgr\ parameter\ file]} {>

emit {ACE/gr ascii file}
<}
} {
if {[S string 0 0 {} {} eq \#\ ACE/gr\ parameter\ file]} {>

emit {ACE/gr ascii file}
<}
} {
if {[S string 0 0 {} {} eq \#\ Grace\ project\ file]} {>

emit {Grace project file}

if {[S string 23 0 {} {} eq @version\ ]} {>

emit (version

	if {[N byte 32 0 0 {} {} > 0]} {>

	emit %c
<}

	if {[S string 33 0 {} {} > \0]} {>

	emit {\b.%.2s}
<}

	if {[S string 35 0 {} {} > \0]} {>

	emit {\b.%.2s)}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \#\ ACE/gr\ fit\ description\ ]} {>

emit {ACE/gr fit description file}
<}
} {
if {[S string 0 0 {} {} eq \037\213]} {>

if {[N byte 3 0 0 {} {} & 4]} {>

	if {[S string 12 0 {} {} eq BC]} {>

		if {[N leshort 14 0 0 {} {} & 2]} {>

		emit {Blocked GNU Zip Format (BGZF; gzip compatible)}

			if {[N leshort 16 0 0 {} {} x {}]} {>

			emit {\b, block length %d}
			mime application/x-gzip

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TBI\1]} {>

emit {SAMtools TBI (Tabix index format)}

if {[N lelong 4 0 0 {} {} == 1]} {>

emit {\b, with %d reference sequence}
<}

if {[N lelong 4 0 0 {} {} > 1]} {>

emit {\b, with %d reference sequences}
<}

if {[N lelong 8 0 0 {} {} & 65536]} {>

emit {\b, using half-closed-half-open coordinates (BED style)}
<}

if {[N lelong 8 0 0 {} {} ^ 65536]} {>

	switch -- [Nv lelong 8 0 {} {}] 0 {>;emit {\b, using closed and one based coordinates (GFF style)};<} 1 {>;emit {\b, using SAM format};<} 2 {>;emit {\b, using VCF format};<} 
<

<}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {\b, sequence name column: %d}
<}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {\b, region start column: %d}
<}

if {[N lelong 8 0 0 {} {} == 0]} {>

	if {[N lelong 20 0 0 {} {} x {}]} {>

	emit {\b, region end column: %d}
<}

<}

if {[N byte 24 0 0 {} {} x {}]} {>

emit {\b, comment character: %c}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {\b, skip line count: %d}
<}

<}
} {
if {[Sx string 0 0 {} {} eq BAM\1]} {>

emit {SAMtools BAM (Binary Sequence Alignment/Map)}

if {[Nx lelong 4 0 0 {} {} > 0]} {>

	if {[Sx regex [R 0] 0 {} {} eq ^\[@\]HD\t.*VN:]} {>

	emit {\b, with SAM header}

		if {[Sx regex [R 0] 0 {} {} eq \[0-9.\]+]} {>

		emit {\b version %s}
<}

<}

	if {[Nx lelong [R [I 4 long 0 0 0 0]] 0 0 {} {} > 0]} {>

	emit {\b, with %d reference sequences}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq BAI\1]} {>

emit {SAMtools BAI (BAM indexing format)}

if {[N lelong 4 0 0 {} {} > 0]} {>

emit {\b, with %d reference sequences}
<}

<}
} {
if {[S string 0 0 {} {} eq CRAM]} {>

emit CRAM

if {[N byte 4 0 0 {} {} > -1]} {>

emit {version %d.}
<}

if {[N byte 5 0 0 {} {} > -1]} {>

emit {\b%d}
<}

if {[S string 6 0 {} {} > \0]} {>

emit {(identified as %s)}
<}

<}
} {
if {[Sx regex 0 0 {} {} eq ^\[!-?A-~\]\{1,255\}(\t\[^\t\]+)\{11\}]} {>

if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{1\}\[0-9\]\{1,5\}\t]} {>

	if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{2\}\\*|\[^*=\]*\t]} {>

		if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{3\}\[0-9\]\{1,9\}\t]} {>

			if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{4\}\[0-9\]\{1,3\}\t]} {>

				if {[Sx regex 0 0 {} {} eq \t\\*|(\[0-9\]+\[MIDNSHPX=\])+)\t]} {>

					if {[Sx regex 0 0 {} {} eq \t(\\*|=|\[!-()+->?-~\]\[!-~\]*)\t]} {>

						if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{7\}\[0-9\]\{1,9\}\t]} {>

							if {[Sx regex 0 0 {} {} eq \t\[+-\]\{0,1\}\[0-9\]\{1,9\}\t.*\t]} {>

								if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{9\}(\\*|\[A-Za-z=.\]+)\t]} {>

									if {[Sx regex 0 0 {} {} eq ^(\[^\t\]+\t)\{10\}\[!-~\]+]} {>

									emit {Sequence Alignment/Map (SAM)}

										if {[Sx regex 0 0 {} {} eq ^\[@\]HD\t.*VN:]} {>

										emit {\b, with header}

											if {[Sx regex [R 0] 0 {} {} eq \[0-9.\]+]} {>

											emit {\b version %s}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq *STA]} {>

emit Aster*x

if {[S string 7 0 {} {} eq WORD]} {>

emit {Words Document}
<}

if {[S string 7 0 {} {} eq GRAP]} {>

emit Graphic
<}

if {[S string 7 0 {} {} eq SPRE]} {>

emit Spreadsheet
<}

if {[S string 7 0 {} {} eq MACR]} {>

emit Macro
<}

<}
} {
if {[S string 0 0 {} {} eq 2278]} {>

emit {Aster*x Version 2}

switch -- [Nv byte 29 0 {} {}] 54 {>;emit {Words Document};<} 53 {>;emit Graphic;<} 50 {>;emit Spreadsheet;<} 56 {>;emit Macro;<} 
<

<}
} {
if {[S string 0 0 {} {} eq NPFF]} {>

emit {NItpicker Flow File }

if {[N byte 4 0 0 {} {} x {}]} {>

emit V%d.
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit %d
<}

if {[N bedate 6 0 0 {} {} x {}]} {>

emit {started: %s}
<}

if {[N bedate 10 0 0 {} {} x {}]} {>

emit {stopped: %s}
<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit {Bytes: %u}
<}

if {[N belong 18 0 0 {} {} x {}]} {>

emit {Bytes1: %u}
<}

if {[N belong 22 0 0 {} {} x {}]} {>

emit {Flows: %u}
<}

if {[N belong 26 0 0 {} {} x {}]} {>

emit {Pkts: %u}
<}

<}
} {
if {[N beshort 0 0 0 & 65408 == 61440]} {>

emit {SysEx File -}

switch -- [Nv byte 1 0 {} {}] 1 {>;emit Sequential;<} 2 {>;emit IDP;<} 3 {>;emit OctavePlateau;<} 4 {>;emit Moog;<} 5 {>;emit Passport;<} 6 {>;emit Lexicon;<} 7 {>;emit {Kurzweil/Future Retro}

	if {[N byte 3 0 0 {} {} == 119]} {>

	emit 777
<}

	switch -- [Nv byte 4 0 {} {}] 0 {>;emit Bank;<} 1 {>;emit Song;<} 
<

	switch -- [Nv byte 5 0 {} {}] 15 {>;emit 16;<} 14 {>;emit 15;<} 13 {>;emit 14;<} 12 {>;emit 13;<} 11 {>;emit 12;<} 10 {>;emit 11;<} 9 {>;emit 10;<} 8 {>;emit 9;<} 7 {>;emit 8;<} 6 {>;emit 7;<} 5 {>;emit 6;<} 4 {>;emit 5;<} 3 {>;emit 4;<} 2 {>;emit 3;<} 1 {>;emit 2;<} 0 {>;emit 1;<} 16 {>;emit (ALL);<} 
<

	if {[N byte 2 0 0 {} {} x {}]} {>

	emit {\b, Channel %d}
<}
;<} 8 {>;emit Fender;<} 9 {>;emit Gulbransen;<} 10 {>;emit AKG;<} 11 {>;emit Voyce;<} 12 {>;emit Waveframe;<} 13 {>;emit ADA;<} 14 {>;emit Garfield;<} 15 {>;emit Ensoniq;<} 16 {>;emit Oberheim

	if {[N byte 2 0 0 {} {} == 6]} {>

	emit {Matrix 6 series}
<}

	switch -- [Nv byte 3 0 {} {}] 10 {>;emit {Dump (All)};<} 1 {>;emit {Dump (Bank)};<} 
<

	if {[N belong 4 0 0 {} {} == 132110]} {>

	emit {Matrix 1000}

		if {[N byte 11 0 0 {} {} < 2]} {>

		emit {User bank %d}
<}

		if {[N byte 11 0 0 {} {} > 1]} {>

		emit {Preset bank %d}
<}

<}
;<} 17 {>;emit Apple;<} 18 {>;emit GreyMatter;<} 20 {>;emit PalmTree;<} 21 {>;emit JLCooper;<} 22 {>;emit Lowrey;<} 23 {>;emit AdamsSmith;<} 24 {>;emit E-mu;<} 25 {>;emit Harmony;<} 26 {>;emit ART;<} 27 {>;emit Baldwin;<} 28 {>;emit Eventide;<} 29 {>;emit Inventronics;<} 31 {>;emit Clarity;<} 33 {>;emit SIEL;<} 34 {>;emit Synthaxe;<} 36 {>;emit Hohner;<} 37 {>;emit Twister;<} 38 {>;emit Solton;<} 39 {>;emit Jellinghaus;<} 40 {>;emit Southworth;<} 41 {>;emit PPG;<} 42 {>;emit JEN;<} 43 {>;emit SSL;<} 44 {>;emit AudioVertrieb;<} 47 {>;emit ELKA

	if {[N byte 3 0 0 {} {} == 9]} {>

	emit EK-44
<}
;<} 48 {>;emit Dynacord;<} 49 {>;emit Jomox;<} 51 {>;emit Clavia;<} 57 {>;emit Soundcraft;<} 62 {>;emit Waldorf

	switch -- [Nv byte 2 0 {} {}] 0 {>;emit microWave;<} 14 {>;emit {microwave2 / XT};<} 15 {>;emit {Q / Q+};<} 16 {>;emit microQ

		switch -- [Nv byte 4 0 {} {}] 0 {>;emit {SNDR (Sound Request)};<} 16 {>;emit {SNDD (Sound Dump)};<} 32 {>;emit {SNDP (Sound Parameter Change)};<} 48 {>;emit {SNDQ (Sound Parameter Inquiry)};<} 112 {>;emit {(Sound Reserved)};<} 1 {>;emit {MULR (Multi Request)};<} 17 {>;emit {MULD (Multi Dump)};<} 33 {>;emit {MULP (Multi Parameter Change)};<} 49 {>;emit {MULQ (Multi Parameter Inquiry)};<} 113 {>;emit {OS (Multi Reserved)};<} 2 {>;emit {DRMR (Drum Map Request)};<} 18 {>;emit {DRMD (Drum Map Dump)};<} 34 {>;emit {DRMP (Drum Map Parameter Change)};<} 50 {>;emit {DRMQ (Drum Map Parameter Inquiry)};<} 114 {>;emit {BIN (Drum Map Reserved)};<} 4 {>;emit {GLBR (Global Parameter Request)};<} 20 {>;emit {GLBD (Global Parameter Dump)};<} 36 {>;emit {GLBP (Global Parameter Parameter Change)};<} 52 {>;emit {GLBQ (Global Parameter Parameter Inquiry)};<} 
<
;<} 17 {>;emit rackAttack

		switch -- [Nv byte 4 0 {} {}] 0 {>;emit {SNDR (Sound Parameter Request)};<} 16 {>;emit {SNDD (Sound Parameter Dump)};<} 32 {>;emit {SNDP (Sound Parameter Parameter Change)};<} 48 {>;emit {SNDQ (Sound Parameter Parameter Inquiry)};<} 1 {>;emit {PRGR (Program Parameter Request)};<} 17 {>;emit {PRGD (Program Parameter Dump)};<} 33 {>;emit {PRGP (Program Parameter Parameter Change)};<} 49 {>;emit {PRGQ (Program Parameter Parameter Inquiry)};<} 113 {>;emit {OS (Program Parameter Reserved)};<} 3 {>;emit {PATR (Pattern Parameter Request)};<} 19 {>;emit {PATD (Pattern Parameter Dump)};<} 35 {>;emit {PATP (Pattern Parameter Parameter Change)};<} 51 {>;emit {PATQ (Pattern Parameter Parameter Inquiry)};<} 4 {>;emit {GLBR (Global Parameter Request)};<} 20 {>;emit {GLBD (Global Parameter Dump)};<} 36 {>;emit {GLBP (Global Parameter Parameter Change)};<} 52 {>;emit {GLBQ (Global Parameter Parameter Inquiry)};<} 5 {>;emit {EFXR (FX Parameter Request)};<} 21 {>;emit {EFXD (FX Parameter Dump)};<} 37 {>;emit {EFXP (FX Parameter Parameter Change)};<} 53 {>;emit {EFXQ (FX Parameter Parameter Inquiry)};<} 7 {>;emit {MODR (Mode Command Request)};<} 23 {>;emit {MODD (Mode Command Dump)};<} 39 {>;emit {MODP (Mode Command Parameter Change)};<} 55 {>;emit {MODQ (Mode Command Parameter Inquiry)};<} 
<
;<} 3 {>;emit Wave

		switch -- [Nv byte 4 0 {} {}] 0 {>;emit {SBPR (Soundprogram)};<} 1 {>;emit {SAPR (Performance)};<} 2 {>;emit {SWAVE (Wave)};<} 3 {>;emit {SWTBL (Wave control table)};<} 4 {>;emit {SVT (Velocity Curve)};<} 5 {>;emit {STT (Tuning Table)};<} 6 {>;emit {SGLB (Global Parameters)};<} 7 {>;emit {SARRMAP (Performance Program Change Map)};<} 8 {>;emit {SBPRMAP (Sound Program Change Map)};<} 9 {>;emit {SBPRPAR (Sound Parameter)};<} 10 {>;emit {SARRPAR (Performance Parameter)};<} 11 {>;emit {SINSPAR (Instrument/External Parameter)};<} 15 {>;emit {SBULK (Bulk Switch on/off)};<} 
<
;<} 
<

	switch -- [Nv byte 3 0 {} {}] 0 {>;emit {(default id)};<} 127 {>;emit {Microwave I}

		switch -- [Nv byte 4 0 {} {}] 0 {>;emit {SNDR (Sound Request)};<} 16 {>;emit {SNDD (Sound Dump)};<} 32 {>;emit {SNDP (Sound Parameter Change)};<} 48 {>;emit {SNDQ (Sound Parameter Inquiry)};<} 112 {>;emit {BOOT (Sound Reserved)};<} 1 {>;emit {MULR (Multi Request)};<} 17 {>;emit {MULD (Multi Dump)};<} 33 {>;emit {MULP (Multi Parameter Change)};<} 49 {>;emit {MULQ (Multi Parameter Inquiry)};<} 113 {>;emit {OS (Multi Reserved)};<} 2 {>;emit {DRMR (Drum Map Request)};<} 18 {>;emit {DRMD (Drum Map Dump)};<} 34 {>;emit {DRMP (Drum Map Parameter Change)};<} 50 {>;emit {DRMQ (Drum Map Parameter Inquiry)};<} 114 {>;emit {BIN (Drum Map Reserved)};<} 3 {>;emit {PATR (Sequencer Pattern Request)};<} 19 {>;emit {PATD (Sequencer Pattern Dump)};<} 35 {>;emit {PATP (Sequencer Pattern Parameter Change)};<} 51 {>;emit {PATQ (Sequencer Pattern Parameter Inquiry)};<} 115 {>;emit {AFM (Sequencer Pattern Reserved)};<} 4 {>;emit {GLBR (Global Parameter Request)};<} 20 {>;emit {GLBD (Global Parameter Dump)};<} 36 {>;emit {GLBP (Global Parameter Parameter Change)};<} 52 {>;emit {GLBQ (Global Parameter Parameter Inquiry)};<} 7 {>;emit {MODR (Mode Parameter Request)};<} 23 {>;emit {MODD (Mode Parameter Dump)};<} 39 {>;emit {MODP (Mode Parameter Parameter Change)};<} 55 {>;emit {MODQ (Mode Parameter Parameter Inquiry)};<} 
<
;<} 
<

	if {[N byte 3 0 0 {} {} > 0]} {>

	emit (

		if {[N byte 3 0 0 {} {} < 127]} {>

		emit {\bdevice %d)}
<}

		if {[N byte 3 0 0 {} {} == 127]} {>

		emit {\bbroadcast id)}
<}

<}
;<} 64 {>;emit Kawai

	switch -- [Nv byte 3 0 {} {}] 32 {>;emit K1;<} 34 {>;emit K4;<} 
<
;<} 65 {>;emit Roland

	switch -- [Nv byte 3 0 {} {}] 20 {>;emit D-50;<} 43 {>;emit U-220;<} 2 {>;emit TR-707;<} 
<
;<} 66 {>;emit Korg

	if {[N byte 3 0 0 {} {} == 25]} {>

	emit M1
<}
;<} 67 {>;emit Yamaha;<} 68 {>;emit Casio;<} 70 {>;emit Kamiya;<} 71 {>;emit Akai;<} 72 {>;emit Victor;<} 73 {>;emit Mesosha;<} 75 {>;emit Fujitsu;<} 76 {>;emit Sony;<} 78 {>;emit Teac;<} 80 {>;emit Matsushita;<} 81 {>;emit Fostex;<} 82 {>;emit Zoom;<} 84 {>;emit Matsushita;<} 87 {>;emit {Acoustic tech. lab.};<} 
<

switch -- [Nv belong 1 0 & 4294967040] 29696 {>;emit {Ta Horng};<} 29952 {>;emit e-Tek;<} 30208 {>;emit E-Voice;<} 30464 {>;emit Midisoft;<} 30720 {>;emit Q-Sound;<} 30976 {>;emit Westrex;<} 31232 {>;emit Nvidia*;<} 31488 {>;emit ESS;<} 31744 {>;emit Mediatrix;<} 32000 {>;emit Brooktree;<} 32256 {>;emit Otari;<} 32512 {>;emit {Key Electronics};<} 65536 {>;emit Shure;<} 65792 {>;emit AuraSound;<} 66048 {>;emit Crystal;<} 66304 {>;emit Rockwell;<} 66560 {>;emit {Silicon Graphics};<} 66816 {>;emit Midiman;<} 67072 {>;emit PreSonus;<} 67584 {>;emit Topaz;<} 67840 {>;emit {Cast Lightning};<} 68096 {>;emit Microsoft;<} 68352 {>;emit {Sonic Foundry};<} 68608 {>;emit {Line 6};<} 68864 {>;emit {Beatnik Inc.};<} 69120 {>;emit {Van Koerving};<} 69376 {>;emit {Altech Systems};<} 69632 {>;emit {S & S Research};<} 69888 {>;emit {VLSI Technology};<} 70144 {>;emit Chromatic;<} 70400 {>;emit Sapphire;<} 70656 {>;emit IDRC;<} 70912 {>;emit {Justonic Tuning};<} 71168 {>;emit TorComp;<} 71424 {>;emit {Newtek Inc.};<} 71680 {>;emit {Sound Sculpture};<} 71936 {>;emit {Walker Technical};<} 72192 {>;emit {Digital Harmony};<} 72448 {>;emit InVision;<} 72704 {>;emit T-Square;<} 72960 {>;emit Nemesys;<} 73216 {>;emit DBX;<} 73472 {>;emit Syndyne;<} 73728 {>;emit {Bitheadz	};<} 73984 {>;emit Cakewalk;<} 74240 {>;emit Staccato;<} 74496 {>;emit {National Semicon.};<} 74752 {>;emit {Boom Theory};<} 75008 {>;emit {Virtual DSP Corp};<} 75264 {>;emit Antares;<} 75520 {>;emit {Angel Software};<} 75776 {>;emit {St Louis Music};<} 76032 {>;emit {Lyrrus dba G-VOX};<} 76288 {>;emit {Ashley Audio};<} 76544 {>;emit Vari-Lite;<} 76800 {>;emit {Summit Audio};<} 77056 {>;emit {Aureal Semicon.};<} 77312 {>;emit SeaSound;<} 77568 {>;emit {U.S. Robotics};<} 77824 {>;emit Aurisis;<} 78080 {>;emit {Nearfield Multimedia};<} 78336 {>;emit {FM7 Inc.};<} 78592 {>;emit {Swivel Systems};<} 78848 {>;emit Hyperactive;<} 79104 {>;emit MidiLite;<} 79360 {>;emit Radical;<} 79616 {>;emit {Roger Linn};<} 79872 {>;emit Helicon;<} 80128 {>;emit Event;<} 80384 {>;emit {Sonic Network};<} 80640 {>;emit {Realtime Music};<} 80896 {>;emit {Apogee Digital};<} 2108160 {>;emit {Medeli Electronics};<} 2108416 {>;emit {Charlie Lab};<} 2108672 {>;emit {Blue Chip Music};<} 2108928 {>;emit {BEE OH Corp};<} 2109184 {>;emit {LG Semicon America};<} 2109440 {>;emit TESI;<} 2109696 {>;emit EMAGIC;<} 2109952 {>;emit Behringer;<} 2110208 {>;emit {Access Music};<} 2110464 {>;emit Synoptic;<} 2110720 {>;emit {Hanmesoft Corp};<} 2110976 {>;emit Terratec;<} 2111232 {>;emit {Proel SpA};<} 2111488 {>;emit {IBK MIDI};<} 2111744 {>;emit IRCAM;<} 2112000 {>;emit {Propellerhead Software};<} 2112256 {>;emit {Red Sound Systems};<} 2112512 {>;emit {Electron ESI AB};<} 2112768 {>;emit {Sintefex Audio};<} 2113024 {>;emit {Music and More};<} 2113280 {>;emit Amsaro;<} 2113536 {>;emit {CDS Advanced Technology};<} 2113792 {>;emit {Touched by Sound};<} 2114048 {>;emit {DSP Arts};<} 2114304 {>;emit {Phil Rees Music};<} 2114560 {>;emit {Stamer Musikanlagen GmbH};<} 2114816 {>;emit Soundart;<} 2115072 {>;emit {C-Mexx Software};<} 2115328 {>;emit {Klavis Tech.};<} 2115584 {>;emit {Noteheads AB};<} 
<

<}
} {
if {[S string 0 0 {} {} eq T707]} {>

emit {Roland TR-707 Data}
<}
} {
if {[S string 0 0 {} {} eq \000\004\036\212\200]} {>

emit {3b2 core file}

if {[S string 364 0 {} {} > \0]} {>

emit {of '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq \007\001\000]} {>

emit {Linux/i386 object file}

if {[N lelong 20 0 0 {} {} > 4128]} {>

emit {\b, DLL library}
<}

<}
} {
if {[S string 0 0 {} {} eq \01\03\020\04]} {>

emit {Linux-8086 impure executable}

if {[N long 28 0 0 {} {} != 0]} {>

emit {not stripped}
<}

<}
} {
if {[S string 0 0 {} {} eq \01\03\040\04]} {>

emit {Linux-8086 executable}

if {[N long 28 0 0 {} {} != 0]} {>

emit {not stripped}
<}

<}
} {
if {[S string 0 0 {} {} eq \243\206\001\0]} {>

emit {Linux-8086 object file}
<}
} {
if {[S string 0 0 {} {} eq \01\03\020\20]} {>

emit {Minix-386 impure executable}

if {[N long 28 0 0 {} {} != 0]} {>

emit {not stripped}
<}

<}
} {
if {[S string 0 0 {} {} eq \01\03\040\20]} {>

emit {Minix-386 executable}

if {[N long 28 0 0 {} {} != 0]} {>

emit {not stripped}
<}

<}
} {
if {[S string 0 0 {} {} eq \01\03\04\20]} {>

emit {Minix-386 NSYM/GNU executable}

if {[N long 28 0 0 {} {} != 0]} {>

emit {not stripped}
<}

<}
} {
if {[N lelong 216 0 0 {} {} == 273]} {>

emit {Linux/i386 core file}

if {[S string 220 0 {} {} > \0]} {>

emit {of '%s'}
<}

if {[N lelong 200 0 0 {} {} > 0]} {>

emit {(signal %d)}
<}

<}
} {
if {[S string 2 0 {} {} eq LILO]} {>

emit {Linux/i386 LILO boot/chain loader}
<}
} {
if {[S string 28 0 {} {} eq make\ config]} {>

emit {Linux make config build file (old)}
<}
} {
if {[S search 49 0 {} 70 eq Kernel\ Configuration]} {>

emit {Linux make config build file}
<}
} {
switch -- [Nv leshort 0 0 {} {}] 1078 {>;emit {Linux/i386 PC Screen Font v1 data,}

if {[N byte 2 0 0 & 1 == 0]} {>

emit {256 characters,}
<}

if {[N byte 2 0 0 & 1 != 0]} {>

emit {512 characters,}
<}

if {[N byte 2 0 0 & 2 == 0]} {>

emit {no directory,}
<}

if {[N byte 2 0 0 & 2 != 0]} {>

emit {Unicode directory,}
<}

if {[N byte 3 0 0 {} {} > 0]} {>

emit 8x%d
<}
;<} 4097 {>;emit {LANalyzer capture file};<} 4103 {>;emit {LANalyzer capture file};<} -155 {>;emit x.out

if {[S string 2 0 {} {} eq __.SYMDEF]} {>

emit randomized
<}

if {[N byte 0 0 0 {} {} x {}]} {>

emit archive
<}
;<} 518 {>;emit {Microsoft a.out}

if {[N leshort 8 0 0 {} {} == 1]} {>

emit {Middle model}
<}

if {[N leshort 30 0 0 {} {} & 16]} {>

emit overlay
<}

if {[N leshort 30 0 0 {} {} & 2]} {>

emit separate
<}

if {[N leshort 30 0 0 {} {} & 4]} {>

emit pure
<}

if {[N leshort 30 0 0 {} {} & 2048]} {>

emit segmented
<}

if {[N leshort 30 0 0 {} {} & 1024]} {>

emit standalone
<}

if {[N leshort 30 0 0 {} {} & 8]} {>

emit fixed-stack
<}

if {[N byte 28 0 0 {} {} & 128]} {>

emit byte-swapped
<}

if {[N byte 28 0 0 {} {} & 64]} {>

emit word-swapped
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit not-stripped
<}

if {[N leshort 30 0 0 {} {} ^ 49152]} {>

emit pre-SysV
<}

if {[N leshort 30 0 0 {} {} & 16384]} {>

emit V2.3
<}

if {[N leshort 30 0 0 {} {} & 32768]} {>

emit V3.0
<}

if {[N byte 28 0 0 {} {} & 4]} {>

emit 86
<}

if {[N byte 28 0 0 {} {} & 11]} {>

emit 186
<}

if {[N byte 28 0 0 {} {} & 9]} {>

emit 286
<}

if {[N byte 28 0 0 {} {} & 10]} {>

emit 386
<}

if {[N byte 31 0 0 {} {} < 64]} {>

emit {small model}
<}

switch -- [Nv byte 31 0 {} {}] 72 {>;emit {large model	};<} 73 {>;emit {huge model };<} 
<

if {[N leshort 30 0 0 {} {} & 1]} {>

emit executable
<}

if {[N leshort 30 0 0 {} {} ^ 1]} {>

emit {object file}
<}

if {[N leshort 30 0 0 {} {} & 64]} {>

emit {Large Text}
<}

if {[N leshort 30 0 0 {} {} & 32]} {>

emit {Large Data}
<}

if {[N leshort 30 0 0 {} {} & 288]} {>

emit {Huge Objects Enabled}
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 320 {>;emit {old Microsoft 8086 x.out}

if {[N byte 3 0 0 {} {} & 4]} {>

emit separate
<}

if {[N byte 3 0 0 {} {} & 2]} {>

emit pure
<}

if {[N byte 0 0 0 {} {} & 1]} {>

emit executable
<}

if {[N byte 0 0 0 {} {} ^ 1]} {>

emit relocatable
<}

if {[N lelong 20 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 1408 {>;emit {XENIX 8086 relocatable or 80286 small model};<} 4843 {>;emit {SYMMETRY i386 .o}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 8939 {>;emit {SYMMETRY i386 executable (0 @ 0)}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 13035 {>;emit {SYMMETRY i386 executable (invalid @ 0)}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N lelong 124 0 0 {} {} > 0]} {>

emit {version %d}
<}
;<} 17131 {>;
if {[N lelong 124 0 0 {} {} > -1]} {>

	if {[N lelong 124 0 0 {} {} != 28867614]} {>

	emit {SYMMETRY i386 standalone executable}

		if {[N lelong 16 0 0 {} {} > 0]} {>

		emit {not stripped}
<}

		if {[N lelong 124 0 0 {} {} > 0]} {>

		emit {version %d}
<}

<}

<}
;<} 3468 {>;
if {[N leshort 4 0 0 {} {} == 515]} {>

	switch -- [Nv leshort 2 0 {} {}] 516 {>;emit {GPG symmetrically encrypted data (3DES cipher)};<} 772 {>;emit {GPG symmetrically encrypted data (CAST5 cipher)};<} 1028 {>;emit {GPG symmetrically encrypted data (BLOWFISH cipher)};<} 1796 {>;emit {GPG symmetrically encrypted data (AES cipher)};<} 2052 {>;emit {GPG symmetrically encrypted data (AES192 cipher)};<} 2308 {>;emit {GPG symmetrically encrypted data (AES256 cipher)};<} 2564 {>;emit {GPG symmetrically encrypted data (TWOFISH cipher)};<} 2820 {>;emit {GPG symmetrically encrypted data (CAMELLIA128 cipher)};<} 3076 {>;emit {GPG symmetrically encrypted data (CAMELLIA192 cipher)};<} 3332 {>;emit {GPG symmetrically encrypted data (CAMELLIA256 cipher)};<} 
<

<}
;<} 358 {>;emit {MS Windows COFF MIPS R4000 object file};<} 388 {>;emit {MS Windows COFF Alpha object file};<} 616 {>;emit {MS Windows COFF Motorola 68000 object file};<} 496 {>;emit {MS Windows COFF PowerPC object file};<} 656 {>;emit {MS Windows COFF PA-RISC object file};<} -24712 {>;emit TNEF
mime application/vnd.ms-tnef
;<} 21020 {>;emit {COFF DSP21k}

if {[N lelong 18 0 0 {} {} & 2]} {>

emit executable,
<}

if {[N lelong 18 0 0 {} {} ^ 2]} {>

	if {[N lelong 18 0 0 {} {} & 1]} {>

	emit {static object,}
<}

	if {[N lelong 18 0 0 {} {} ^ 1]} {>

	emit {relocatable object,}
<}

<}

if {[N lelong 18 0 0 {} {} & 8]} {>

emit stripped
<}

if {[N lelong 18 0 0 {} {} ^ 8]} {>

emit {not stripped}
<}
;<} 263 {>;emit {PDP-11 executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 15 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 257 {>;
if {[N lelong 68 0 0 {} {} != 88]} {>

emit {PDP-11 UNIX/RT ldp}
<}
;<} 261 {>;emit {PDP-11 old overlay};<} 264 {>;emit {PDP-11 pure executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 15 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 265 {>;emit {PDP-11 separate I&D executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N byte 15 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 287 {>;emit {PDP-11 kernel overlay};<} 267 {>;emit {PDP-11 demand-paged pure executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 280 {>;emit {PDP-11 overlaid pure executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 281 {>;emit {PDP-11 overlaid separate executable}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 13123 {>;emit {Clarion Developer (v2 and above) data file}

if {[N leshort 2 0 0 {} {} & 1]} {>

emit {\b, locked}
<}

if {[N leshort 2 0 0 {} {} & 4]} {>

emit {\b, encrypted}
<}

if {[N leshort 2 0 0 {} {} & 8]} {>

emit {\b, memo file exists}
<}

if {[N leshort 2 0 0 {} {} & 16]} {>

emit {\b, compressed}
<}

if {[N leshort 2 0 0 {} {} & 64]} {>

emit {\b, read only}
<}

if {[N lelong 5 0 0 {} {} x {}]} {>

emit {\b, %d records}
<}
;<} 13133 {>;emit {Clarion Developer (v2 and above) memo data};<} 18912 {>;emit {Clarion Developer (v2 and above) help data};<} 21020 {>;emit {SHARC COFF binary}

if {[N leshort 2 0 0 {} {} > 1]} {>

emit {, %d sections}

	if {[N lelong 12 0 0 {} {} > 0]} {>

	emit {, not stripped}
<}

<}
;<} 1360 {>;
if {[N leshort 18 0 0 & 36480 == 0]} {>
U 154 display-coff

<}
;<} 443 {>;
if {[N leshort 2 0 0 {} {} == 256]} {>

emit {Brooktrout 301 fax image,}

	if {[N leshort 9 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 45 0 0 {} {} x {}]} {>

	emit %d
<}

	switch -- [Nv leshort 6 0 {} {}] 200 {>;emit {\b, fine resolution};<} 100 {>;emit {\b, normal resolution};<} 
<

	switch -- [Nv byte 11 0 {} {}] 1 {>;emit {\b, G3 compression};<} 2 {>;emit {\b, G32D compression};<} 
<

<}
;<} 322 {>;emit {basic-16 executable}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 323 {>;emit {basic-16 executable (TV)}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 328 {>;emit {x86 executable}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 329 {>;emit {x86 executable (TV)}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 330 {>;emit {iAPX 286 executable small model (COFF)}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 338 {>;emit {iAPX 286 executable large model (COFF)}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 332 {>;U 190 display-coff
;<} 376 {>;emit {VAX COFF executable}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N leshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 381 {>;emit {VAX COFF pure executable}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N leshort 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} -147 {>;emit {very old 16-bit-int little-endian archive};<} -155 {>;emit {old 16-bit-int little-endian archive}

if {[S string 2 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}
;<} -5536 {>;emit {ARJ archive data}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b, v%d,}
<}

if {[N byte 8 0 0 {} {} & 4]} {>

emit multi-volume,
<}

if {[N byte 8 0 0 {} {} & 16]} {>

emit slash-switched,
<}

if {[N byte 8 0 0 {} {} & 32]} {>

emit backup,
<}

if {[S string 34 0 {} {} x {}]} {>

emit {original name: %s,}
<}

switch -- [Nv byte 7 0 {} {}] 0 {>;emit {os: MS-DOS};<} 1 {>;emit {os: PRIMOS};<} 2 {>;emit {os: Unix};<} 3 {>;emit {os: Amiga};<} 4 {>;emit {os: Macintosh};<} 5 {>;emit {os: OS/2};<} 6 {>;emit {os: Apple ][ GS};<} 7 {>;emit {os: Atari ST};<} 8 {>;emit {os: NeXT};<} 9 {>;emit {os: VAX/VMS};<} 
<

if {[N byte 3 0 0 {} {} > 0]} {>

emit %d\]
<}

mime application/x-arj
;<} -5247 {>;emit {PRCS packaged project};<} 6532 {>;emit {Linux old jffs2 filesystem data little endian};<} 6533 {>;emit {Linux jffs2 filesystem data little endian};<} -13230 {>;emit {RLE image data,}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N leshort 8 0 0 {} {} x {}]} {>

emit %d
<}

if {[N leshort 2 0 0 {} {} > 0]} {>

emit {\b, lower left corner: %d}
<}

if {[N leshort 4 0 0 {} {} > 0]} {>

emit {\b, lower right corner: %d}
<}

if {[N byte 10 0 0 & 1 == 1]} {>

emit {\b, clear first}
<}

if {[N byte 10 0 0 & 2 == 2]} {>

emit {\b, no background}
<}

if {[N byte 10 0 0 & 4 == 4]} {>

emit {\b, alpha channel}
<}

if {[N byte 10 0 0 & 8 == 8]} {>

emit {\b, comment}
<}

if {[N byte 11 0 0 {} {} > 0]} {>

emit {\b, %d color channels}
<}

if {[N byte 12 0 0 {} {} > 0]} {>

emit {\b, %d bits per pixel}
<}

if {[N byte 13 0 0 {} {} > 0]} {>

emit {\b, %d color map channels}
<}
;<} 662 {>;emit {Atari ATR image};<} 387 {>;
switch -- [Nv leshort 24 0 {} {}] 264 {>;emit {COFF format alpha pure};<} 267 {>;emit {COFF format alpha demand paged}

	if {[N leshort 22 0 0 & 12288 != 8192]} {>

	emit executable
<}

	if {[N leshort 22 0 0 & 8192 != 0]} {>

	emit {dynamically linked}
<}

	if {[N lelong 16 0 0 {} {} != 0]} {>

	emit {not stripped}
<}

	if {[N lelong 16 0 0 {} {} == 0]} {>

	emit stripped
<}

	if {[N byte 27 0 0 {} {} x {}]} {>

	emit {- version %d}
<}

	if {[N byte 26 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

	if {[N byte 28 0 0 {} {} x {}]} {>

	emit {\b-%d}
<}
;<} 263 {>;emit {COFF format alpha object}

	if {[N leshort 22 0 0 & 12288 == 8192]} {>

	emit {shared library}
<}

	if {[N byte 27 0 0 {} {} x {}]} {>

	emit {- version %d}
<}

	if {[N byte 26 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

	if {[N byte 28 0 0 {} {} x {}]} {>

	emit {\b-%d}
<}
;<} 
<
;<} 392 {>;emit {Alpha compressed COFF};<} 399 {>;emit {Alpha u-code object};<} 
<
} {
if {[S string 0 0 {} {} eq \x72\xb5\x4a\x86\x00\x00]} {>

emit {Linux/i386 PC Screen Font v2 data,}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {%d characters,}
<}

if {[N lelong 12 0 0 & 1 == 0]} {>

emit {no directory,}
<}

if {[N lelong 12 0 0 & 1 != 0]} {>

emit {Unicode directory,}
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit %d
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {\bx%d}
<}

<}
} {
if {[S string 4086 0 {} {} eq SWAP-SPACE]} {>

emit {Linux/i386 swap file}
<}
} {
if {[S string 4076 0 {} {} eq SWAPSPACE2S1SUSPEND]} {>

emit {Linux/i386 swap file (new style) with SWSUSP1 image}
<}
} {
if {[S string 4076 0 {} {} eq SWAPSPACE2LINHIB0001]} {>

emit {Linux/i386 swap file (new style) (compressed hibernate)}
<}
} {
if {[S string 4086 0 {} {} eq SWAPSPACE2]} {>

emit {Linux/i386 swap file (new style),}

if {[N long 1024 0 0 {} {} x {}]} {>

emit {version %d (4K pages),}
<}

if {[N long 1028 0 0 {} {} x {}]} {>

emit {size %d pages,}
<}

if {[S string 1052 0 {} {} eq \0]} {>

emit {no label,}
<}

if {[S string 1052 0 {} {} > \0]} {>

emit LABEL=%s,
<}

if {[N belong 1036 0 0 {} {} x {}]} {>

emit UUID=%08x
<}

if {[N beshort 1040 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N beshort 1042 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N beshort 1044 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N belong 1046 0 0 {} {} x {}]} {>

emit {\b-%08x}
<}

if {[N beshort 1050 0 0 {} {} x {}]} {>

emit {\b%04x}
<}

<}
} {
if {[S string 65526 0 {} {} eq SWAPSPACE2]} {>

emit {Linux/ppc swap file}
<}
} {
if {[S string 16374 0 {} {} eq SWAPSPACE2]} {>

emit {Linux/ia64 swap file}
<}
} {
if {[S string 514 0 {} {} eq HdrS]} {>

emit {Linux kernel}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {x86 boot executable}

	if {[N leshort 518 0 0 {} {} > 511]} {>

		switch -- [Nv byte 529 0 {} {}] 0 {>;emit zImage,;<} 1 {>;emit bzImage,;<} 
<

		if {[N lelong 526 0 0 {} {} > 0]} {>

			if {[S string [I 526 leshort 0 + 0 512] 0 {} {} > \0]} {>

			emit {version %s,}
<}

<}

<}

	switch -- [Nv leshort 498 0 {} {}] 1 {>;emit RO-rootFS,;<} 0 {>;emit RW-rootFS,;<} 
<

	if {[N leshort 508 0 0 {} {} > 0]} {>

	emit {root_dev 0x%X,}
<}

	if {[N leshort 502 0 0 {} {} > 0]} {>

	emit {swap_dev 0x%X,}
<}

	if {[N leshort 504 0 0 {} {} > 0]} {>

	emit {RAMdisksize %u KB,}
<}

	switch -- [Nv leshort 506 0 {} {}] -1 {>;emit {Normal VGA};<} -2 {>;emit {Extended VGA};<} -3 {>;emit {Prompt for Videomode};<} 
<

	if {[N leshort 506 0 0 {} {} > 0]} {>

	emit {Video mode %d}
<}

<}

<}
} {
if {[S search 8 0 {} 1 eq \ A\ _text]} {>

emit {Linux kernel symbol map text}
<}
} {
if {[S search 0 0 {} 1 eq Begin3]} {>

emit {Linux Software Map entry text}
<}
} {
if {[S search 0 0 {} 1 eq Begin4]} {>

emit {Linux Software Map entry text (new format)}
<}
} {
if {[S string 0 0 {} {} eq \xb8\xc0\x07\x8e\xd8\xb8\x00\x90]} {>

emit Linux

if {[N leshort 497 0 0 {} {} == 0]} {>

emit {x86 boot sector}

	switch -- [Nv belong 514 0 {} {}] 142 {>;emit {of a kernel from the dawn of time!};<} -1869686604 {>;emit {version 0.99-1.1.42};<} -1869686600 {>;emit {for memtest86};<} 
<

<}

if {[N leshort 497 0 0 {} {} != 0]} {>

emit {x86 kernel}

	if {[N leshort 504 0 0 {} {} > 0]} {>

	emit {RAMdisksize=%u KB}
<}

	if {[N leshort 502 0 0 {} {} > 0]} {>

	emit swap=0x%X
<}

	if {[N leshort 508 0 0 {} {} > 0]} {>

	emit root=0x%X

		switch -- [Nv leshort 498 0 {} {}] 1 {>;emit {\b-ro};<} 0 {>;emit {\b-rw};<} 
<

<}

	switch -- [Nv leshort 506 0 {} {}] -1 {>;emit vga=normal;<} -2 {>;emit vga=extended;<} -3 {>;emit vga=ask;<} 
<

	if {[N leshort 506 0 0 {} {} > 0]} {>

	emit vga=%d
<}

	switch -- [Nv belong 514 0 {} {}] -1869686655 {>;emit {version 1.1.43-1.1.45};<} 364020173 {>;
		if {[N belong 2702 0 0 {} {} == 1437227610]} {>

		emit {version 1.1.46-1.2.13,1.3.0}
<}

		if {[N belong 2713 0 0 {} {} == 1437227610]} {>

		emit {version 1.3.1,2}
<}

		if {[N belong 2723 0 0 {} {} == 1437227610]} {>

		emit {version 1.3.3-1.3.30}
<}

		if {[N belong 2726 0 0 {} {} == 1437227610]} {>

		emit {version 1.3.31-1.3.41}
<}

		if {[N belong 2859 0 0 {} {} == 1437227610]} {>

		emit {version 1.3.42-1.3.45}
<}

		if {[N belong 2807 0 0 {} {} == 1437227610]} {>

		emit {version 1.3.46-1.3.72}
<}
;<} 
<

	if {[S string 514 0 {} {} eq HdrS]} {>

		if {[N leshort 518 0 0 {} {} > 511]} {>

			switch -- [Nv byte 529 0 {} {}] 0 {>;emit {\b, zImage};<} 1 {>;emit {\b, bzImage};<} 
<

			if {[S string [I 526 leshort 0 + 0 512] 0 {} {} > \0]} {>

			emit {\b, version %s}
<}

<}

<}

<}

<}
} {
if {[Sx string 8 0 {} {} eq \x02\x00\x00\x18\x60\x00\x00\x50\x02\x00\x00\x68\x60\x00\x00\x50\x40\x40\x40\x40\x40\x40\x40\x40]} {>

emit {Linux S390}

if {[Sx search 65536 0 b 4096 eq \x00\x0a\x00\x00\x8b\xad\xcc\xcc]} {>

	if {[Sx string [R 0] 0 {} {} eq \xc1\x00\xef\xe3\xf0\x68\x00\x00]} {>

	emit {Z10 64bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \xc1\x00\xef\xc3\x00\x00\x00\x00]} {>

	emit {Z9-109 64bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \xc0\x00\x20\x00\x00\x00\x00\x00]} {>

	emit {Z990 64bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \x00\x00\x00\x00\x00\x00\x00\x00]} {>

	emit {Z900 64bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \x81\x00\xc8\x80\x00\x00\x00\x00]} {>

	emit {Z10 32bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \x81\x00\xc8\x80\x00\x00\x00\x00]} {>

	emit {Z9-109 32bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \x80\x00\x20\x00\x00\x00\x00\x00]} {>

	emit {Z990 32bit kernel}
<}

	if {[Sx string [R 0] 0 {} {} eq \x80\x00\x00\x00\x00\x00\x00\x00]} {>

	emit {Z900 32bit kernel}
<}

<}

<}
} {
if {[N lelong 36 0 0 {} {} == 24061976]} {>

emit {Linux kernel ARM boot executable zImage (little-endian)}
<}
} {
if {[N belong 36 0 0 {} {} == 24061976]} {>

emit {Linux kernel ARM boot executable zImage (big-endian)}
<}
} {
if {[N lelong 0 0 0 & 4278190335 == 3271557353]} {>

emit {Linux-Dev86 executable, headerless}

if {[S string 5 0 {} {} eq .]} {>

	if {[S string 4 0 {} {} > \0]} {>

	emit {\b, libc version %s}
<}

<}

<}
} {
if {[N lelong 0 0 0 & 4278255615 == 67109633]} {>

emit {Linux-8086 executable}

if {[N byte 2 0 0 & 1 != 0]} {>

emit {\b, unmapped zero page}
<}

if {[N byte 2 0 0 & 32 == 0]} {>

emit {\b, impure}
<}

if {[N byte 2 0 0 & 32 != 0]} {>

	if {[N byte 2 0 0 & 16 != 0]} {>

	emit {\b, A_EXEC}
<}

<}

if {[N byte 2 0 0 & 2 != 0]} {>

emit {\b, A_PAL}
<}

if {[N byte 2 0 0 & 4 != 0]} {>

emit {\b, A_NSYM}
<}

if {[N byte 2 0 0 & 8 != 0]} {>

emit {\b, A_STAND}
<}

if {[N byte 2 0 0 & 64 != 0]} {>

emit {\b, A_PURE}
<}

if {[N byte 2 0 0 & 128 != 0]} {>

emit {\b, A_TOVLY}
<}

if {[N long 28 0 0 {} {} != 0]} {>

emit {\b, not stripped}
<}

if {[S string 37 0 {} {} eq .]} {>

	if {[S string 36 0 {} {} > \0]} {>

	emit {\b, libc version %s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq OOOM]} {>

emit {User-Mode-Linux's Copy-On-Write disk image}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq HM\001]} {>

emit {LVM1 (Linux Logical Volume Manager), version 1}

if {[S string 300 0 {} {} > \0]} {>

emit {, System ID: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq HM\002]} {>

emit {LVM1 (Linux Logical Volume Manager), version 2}

if {[S string 300 0 {} {} > \0]} {>

emit {, System ID: %s}
<}

<}
} {
if {[Sx string 536 0 {} {} eq LVM2\ 001]} {>

emit {LVM2 PV (Linux Logical Volume Manager)}

if {[Nx byte [R [I [R -12] lelong 0 - 0 33]] 0 0 {} {} x {}]} {>

	if {[Sx string [R 0] 0 {} {} > \x2f]} {>

	emit {\b, UUID: %.6s}
<}

	if {[Sx string [R 6] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 10] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 14] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 18] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 22] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 26] 0 {} {} > \x2f]} {>

	emit {\b-%.6s}
<}

	if {[Nx lequad [R 32] 0 0 {} {} x {}]} {>

	emit {\b, size: %lld}
<}

<}

<}
} {
if {[Sx string 24 0 {} {} eq LVM2\ 001]} {>

emit {LVM2 PV (Linux Logical Volume Manager)}

if {[Nx byte [R [I [R -12] lelong 0 - 0 33]] 0 0 {} {} x {}]} {>

	if {[Sx string [R 0] 0 {} {} > \x2f]} {>

	emit {\b, UUID: %.6s}
<}

	if {[Sx string [R 6] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 10] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 14] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 18] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 22] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 26] 0 {} {} > \x2f]} {>

	emit {\b-%.6s}
<}

	if {[Nx lequad [R 32] 0 0 {} {} x {}]} {>

	emit {\b, size: %lld}
<}

<}

<}
} {
if {[Sx string 1048 0 {} {} eq LVM2\ 001]} {>

emit {LVM2 PV (Linux Logical Volume Manager)}

if {[Nx byte [R [I [R -12] lelong 0 - 0 33]] 0 0 {} {} x {}]} {>

	if {[Sx string [R 0] 0 {} {} > \x2f]} {>

	emit {\b, UUID: %.6s}
<}

	if {[Sx string [R 6] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 10] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 14] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 18] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 22] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 26] 0 {} {} > \x2f]} {>

	emit {\b-%.6s}
<}

	if {[Nx lequad [R 32] 0 0 {} {} x {}]} {>

	emit {\b, size: %lld}
<}

<}

<}
} {
if {[Sx string 1560 0 {} {} eq LVM2\ 001]} {>

emit {LVM2 PV (Linux Logical Volume Manager)}

if {[Nx byte [R [I [R -12] lelong 0 - 0 33]] 0 0 {} {} x {}]} {>

	if {[Sx string [R 0] 0 {} {} > \x2f]} {>

	emit {\b, UUID: %.6s}
<}

	if {[Sx string [R 6] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 10] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 14] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 18] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 22] 0 {} {} > \x2f]} {>

	emit {\b-%.4s}
<}

	if {[Sx string [R 26] 0 {} {} > \x2f]} {>

	emit {\b-%.6s}
<}

	if {[Nx lequad [R 32] 0 0 {} {} x {}]} {>

	emit {\b, size: %lld}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq SnAp]} {>

emit {LVM Snapshot (CopyOnWrite store)}

if {[N lelong 4 0 0 {} {} != 0]} {>

emit {- valid,}
<}

if {[N lelong 4 0 0 {} {} == 0]} {>

emit {- invalid,}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {chunk_size %d}
<}

<}
} {
if {[S string 0 0 {} {} eq LUKS\xba\xbe]} {>

emit {LUKS encrypted file,}

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {ver %d}
<}

if {[S string 8 0 {} {} x {}]} {>

emit {[%s,}
<}

if {[S string 40 0 {} {} x {}]} {>

emit %s,
<}

if {[S string 72 0 {} {} x {}]} {>

emit %s\]
<}

if {[S string 168 0 {} {} x {}]} {>

emit {UUID: %s}
<}

<}
} {
if {[Sx string 0 0 {} {} eq LinuxGuestRecord]} {>

emit {Xen saved domain}

if {[Sx search 20 0 {} 256 eq (name]} {>

	if {[Sx string [R 1] 0 {} {} x {}]} {>

	emit {(name %s)}
<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq LinuxGuestRecord]} {>

emit {Xen saved domain}

if {[Sx search 20 0 {} 256 eq (name]} {>

emit (name

	if {[Sx string [R 1] 0 {} {} x {}]} {>

	emit %s...)
<}

<}

<}
} {
if {[S string 0 0 {} {} eq LPKSHHRH]} {>

if {[N byte 16 0 0 & 252 == 0]} {>

	if {[N bequad 24 0 0 {} {} > 0]} {>

		if {[N bequad 32 0 0 {} {} > 0]} {>

			if {[N bequad 40 0 0 {} {} > 0]} {>

				if {[N bequad 48 0 0 {} {} > 0]} {>

					if {[N bequad 56 0 0 {} {} > 0]} {>

						if {[N bequad 64 0 0 {} {} > 0]} {>

						emit {Journal file}

							if {[N leqdate 184 0 0 {} {} == 0]} {>

							emit empty
<}

							switch -- [Nv byte 16 0 {} {}] 0 {>;emit {\b, offline};<} 1 {>;emit {\b, online};<} 2 {>;emit {\b, archived};<} 
<

							if {[N lelong 8 0 0 & 1 == 1]} {>

							emit {\b, sealed}
<}

							if {[N lelong 12 0 0 & 1 == 1]} {>

							emit {\b, compressed}
<}

						mime application/octet-stream

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[N lequad 4104 0 0 {} {} == 8]} {>

if {[S string 4120 0 {} {} eq \xc6\x85\x73\xf6\x4e\x1a\x45\xca\x82\x65\xf5\x7f\x48\xba\x6d\x81]} {>

emit BCache

	switch -- [Nv lequad 4112 0 {} {}] 0 {>;emit {cache device};<} 1 {>;emit {backing device};<} 3 {>;emit {cache device};<} 4 {>;emit {backing device};<} 
<

	if {[S string 4168 0 {} {} > 0]} {>

	emit {\b, label "%.32s"}
<}

	if {[N belong 4136 0 0 {} {} x {}]} {>

	emit {\b, uuid %08x}
<}

	if {[N beshort 4140 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N beshort 4142 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N beshort 4144 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N belong 4146 0 0 {} {} x {}]} {>

	emit {\b-%08x}
<}

	if {[N beshort 4150 0 0 {} {} x {}]} {>

	emit {\b%04x}
<}

	if {[N belong 4152 0 0 {} {} x {}]} {>

	emit {\b, set uuid %08x}
<}

	if {[N beshort 4156 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N beshort 4158 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N beshort 4160 0 0 {} {} x {}]} {>

	emit {\b-%04x}
<}

	if {[N belong 4162 0 0 {} {} x {}]} {>

	emit {\b-%08x}
<}

	if {[N beshort 4166 0 0 {} {} x {}]} {>

	emit {\b%04x}
<}

<}

<}
} {
if {[N lelong 4096 0 0 {} {} == 2838187772]} {>

emit {Linux Software RAID}

if {[N lelong 4100 0 0 {} {} x {}]} {>

emit {version 1.2 (%d)}
<}
U 32 linuxraid

<}
} {
if {[S string 0 0 {} {} eq \0mlocate]} {>

emit {mlocate database}

if {[N byte 12 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N byte 13 0 0 {} {} == 1]} {>

emit {\b, require visibility}
<}

if {[S string 16 0 {} {} x {}]} {>

emit {\b, root %s}
<}

<}
} {
if {[S string 0 0 {} {} eq KDUMP]} {>

emit {Kdump compressed dump}

if {[N long 8 0 0 {} {} x {}]} {>

emit v%d
<}

if {[S string 12 0 {} {} > \0]} {>

emit {\b, system %s}
<}

if {[S string 77 0 {} {} > \0]} {>

emit {\b, node %s}
<}

if {[S string 142 0 {} {} > \0]} {>

emit {\b, release %s}
<}

if {[S string 207 0 {} {} > \0]} {>

emit {\b, version %s}
<}

if {[S string 272 0 {} {} > \0]} {>

emit {\b, machine %s}
<}

if {[S string 337 0 {} {} > \0]} {>

emit {\b, domain %s}
<}

<}
} {
if {[S search 0 0 {c W} 100 eq constant\ story]} {>

emit {Inform source text}
<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.asciiz]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.byte]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.even]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.globl]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.text]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.file]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
if {[S regex 0 0 {} {} eq ^\[\040\t\]\{0,50\}\\.type]} {>

emit {assembler source text}
mime text/x-asm

<}
} {
switch -- [Nvx long 0 0 {} {}] 59399 {>;emit {object file (z8000 a.out)};<} 59400 {>;emit {pure object file (z8000 a.out)};<} 59401 {>;emit {separate object file (z8000 a.out)};<} 59397 {>;emit {overlay object file (z8000 a.out)};<} 1351614727 {>;emit {Pyramid 90x family executable};<} 1351614728 {>;emit {Pyramid 90x family pure executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 1351614731 {>;emit {Pyramid 90x family demand paged pure executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 61374 {>;emit {OSF/Rose object};<} 262 {>;emit {68k Blit mpx/mux executable};<} 1886817234 {>;emit {CLISP memory image data};<} -762612112 {>;emit {CLISP memory image data, other endian};<} -97271666 {>;emit {SunPC 4.0 Hard Disk};<} 268 {>;emit {unknown demand paged pure executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 270 {>;emit {unknown readable demand paged pure executable};<} 398689 {>;emit {Berkeley DB}

switch -- [Nv belong 8 0 {} {}] 4321 {>;
	if {[N belong 4 0 0 {} {} > 2]} {>

	emit 1.86
<}

	if {[N belong 4 0 0 {} {} < 3]} {>

	emit 1.85
<}

	if {[N belong 4 0 0 {} {} > 0]} {>

	emit {(Hash, version %d, native byte-order)}
<}
;<} 1234 {>;
	if {[N belong 4 0 0 {} {} > 2]} {>

	emit 1.86
<}

	if {[N belong 4 0 0 {} {} < 3]} {>

	emit 1.85
<}

	if {[N belong 4 0 0 {} {} > 0]} {>

	emit {(Hash, version %d, little-endian)}
<}
;<} 
<

mime application/x-dbm
;<} 340322 {>;emit {Berkeley DB 1.85/1.86}

if {[N long 4 0 0 {} {} > 0]} {>

emit {(Btree, version %d, native byte-order)}
<}
;<} 395726 {>;emit {Jaleo XFS file}

if {[N long 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N long 8 0 0 {} {} x {}]} {>

emit {- [%d -}
<}

if {[N long 20 0 0 {} {} x {}]} {>

emit {\b%dx}
<}

if {[N long 24 0 0 {} {} x {}]} {>

emit {\b%dx}
<}

switch -- [Nv long 28 0 {} {}] 1008 {>;emit {\bYUV422]};<} 1000 {>;emit {\bRGB24]};<} 
<
;<} -569244523 {>;emit {GNU-format message catalog data};<} -1794895138 {>;emit {GNU-format message catalog data};<} 269 {>;emit {i960 b.out relocatable object}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 1145263299 {>;emit {DACT compressed data}

if {[N byte 4 0 0 {} {} > -1]} {>

emit {(version %i.}
<}

if {[N byte 5 0 0 {} {} > -1]} {>

emit %i.
<}

if {[N byte 6 0 0 {} {} > -1]} {>

emit %i)
<}

if {[N long 7 0 0 {} {} > 0]} {>

emit {, original size: %i bytes}
<}

if {[N long 15 0 0 {} {} > 30]} {>

emit {, block size: %i bytes}
<}
;<} 31415 {>;emit {Mirage Assembler m.out executable};<} -1042103351 {>;emit {SPSS Portable File}

if {[S string 40 0 {} {} x {}]} {>

emit %s
<}
;<} 1145263299 {>;emit {DACT compressed data}

if {[N byte 4 0 0 {} {} > -1]} {>

emit {(version %i.}
<}

if {[N byte 5 0 0 {} {} > -1]} {>

emit {$BS%i.}
<}

if {[N byte 6 0 0 {} {} > -1]} {>

emit {$BS%i)}
<}

if {[N long 7 0 0 {} {} > 0]} {>

emit {$BS, original size: %i bytes}
<}

if {[N long 15 0 0 {} {} > 30]} {>

emit {$BS, block size: %i bytes}
<}
;<} 168757262 {>;emit {TML 0123 byte-order format};<} 252317192 {>;emit {TML 1032 byte-order format};<} 135137807 {>;emit {TML 2301 byte-order format};<} 235409162 {>;emit {TML 3210 byte-order format};<} 34078982 {>;emit {HP s500 relocatable executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 34078983 {>;emit {HP s500 executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 34078984 {>;emit {HP s500 pure executable}

if {[N long 16 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 65381 {>;emit {HP old archive};<} 34275173 {>;emit {HP s200 old archive};<} 34406245 {>;emit {HP s200 old archive};<} 34144101 {>;emit {HP s500 old archive};<} 22552998 {>;emit {HP core file};<} 1302851304 {>;emit {HP-WINDOWS font}

if {[N byte 8 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 34341132 {>;emit {compiled Lisp};<} 33132 {>;emit {apl workspace};<} -1 {>;
if {[Nx belong [R 0] 0 0 {} {} == 2862175590]} {>

emit {Xilinx RAW bitstream (.BIN)}
<}
;<} 33132 {>;emit {APL workspace (Ken's original?)};<} 1123028772 {>;emit {Artisan image data}

switch -- [Nv long 4 0 {} {}] 1 {>;emit {\b, rectangular 24-bit};<} 2 {>;emit {\b, rectangular 8-bit with colormap};<} 3 {>;emit {\b, rectangular 32-bit (24-bit with matte)};<} 
<
;<} 1234567 {>;emit {X image};<} 
<
} {
if {[S string 0 0 {} {} eq spec]} {>

emit SPEC

if {[S string 4 0 {} {} eq .cpu]} {>

emit CPU

	if {[S string 8 0 {} {} < :]} {>

	emit {\b%.4s}
<}

	if {[S string 12 0 {} {} eq .]} {>

	emit {raw result text}
<}

<}

<}
} {
if {[S string 17 0 {} {} eq version=SPECjbb]} {>

emit SPECjbb

if {[S string 32 0 {} {} < :]} {>

emit {\b%.4s}

	if {[S string 37 0 {} {} < :]} {>

	emit {v%.4s raw result text}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq BEGIN\040SPECWEB]} {>

emit SPECweb

if {[S string 13 0 {} {} < :]} {>

emit {\b%.2s}

	if {[S string 15 0 {} {} eq _SSL]} {>

	emit {\b_SSL}

		if {[S string 20 0 {} {} < :]} {>

		emit {v%.4s raw result text}
<}

<}

	if {[S string 16 0 {} {} < :]} {>

	emit {v%.4s raw result text}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \0\0\1\236\0\0\0\0\0\0\0\0\0\0\0\0]} {>

emit {BEA TUXEDO DES mask data}
<}
} {
if {[S string 20 0 {} {} eq 45]} {>

if {[S regex 0 0 l 1 eq (^\[0-9\]\{5\})\[acdnp\]\[^bhlnqsu-z\]]} {>

emit {MARC21 Bibliographic}
mime application/marc

<}

if {[S regex 0 0 l 1 eq (^\[0-9\]\{5\})\[acdnosx\]\[z\]]} {>

emit {MARC21 Authority}
mime application/marc

<}

if {[S regex 0 0 l 1 eq (^\[0-9\]\{5\})\[cdn\]\[uvxy\]]} {>

emit {MARC21 Holdings}
mime application/marc

<}

<}
} {
if {[S regex 0 0 l 1 eq (^\[0-9\]\{5\})\[acdn\]\[w\]]} {>

emit {MARC21 Classification}

if {[S regex 0 0 l 1 eq (^\[0-9\]\{5\})\[cdn\]\[q\]]} {>

emit {MARC21 Community}
mime application/marc

<}

if {[S regex 0 0 l 1 eq (^.\{21\})(\[^0\]\{2\})]} {>

emit (non-conforming)
mime application/marc

<}

mime application/marc

<}
} {
switch -- [Nv short 0 0 {} {}] 373 {>;emit {i386 COFF object};<} 286 {>;emit {Berkeley vfont data};<} 7681 {>;emit {byte-swapped Berkeley vfont data};<} 1793 {>;emit {VAX-order 68K Blit (standalone) executable};<} 262 {>;emit {VAX-order2 68k Blit mpx/mux executable};<} 1537 {>;emit {VAX-order 68k Blit mpx/mux executable};<} 340 {>;emit Encore

switch -- [Nv short 20 0 {} {}] 263 {>;emit executable;<} 264 {>;emit {pure executable};<} 267 {>;emit {demand-paged executable};<} 271 {>;emit {unsupported executable};<} 
<

if {[N long 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N short 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N short 22 0 0 {} {} == 0]} {>

emit -
<}
;<} 341 {>;emit {Encore unsupported executable}

if {[N long 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N short 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N short 22 0 0 {} {} == 0]} {>

emit -
<}
;<} 21845 {>;emit {VISX image file}

switch -- [Nv byte 2 0 {} {}] 0 {>;emit (zero);<} 1 {>;emit {(unsigned char)};<} 2 {>;emit {(short integer)};<} 3 {>;emit {(float 32)};<} 4 {>;emit {(float 64)};<} 5 {>;emit {(signed char)};<} 6 {>;emit (bit-plane);<} 7 {>;emit (classes);<} 8 {>;emit (statistics);<} 10 {>;emit {(ascii text)};<} 15 {>;emit {(image segments)};<} 100 {>;emit {(image set)};<} 101 {>;emit {(unsigned char vector)};<} 102 {>;emit {(short integer vector)};<} 103 {>;emit {(float 32 vector)};<} 104 {>;emit {(float 64 vector)};<} 105 {>;emit {(signed char vector)};<} 106 {>;emit {(bit plane vector)};<} 121 {>;emit {(feature vector)};<} 122 {>;emit {(feature vector library)};<} 124 {>;emit {(chain code)};<} 126 {>;emit {(bit vector)};<} -126 {>;emit (graph);<} -125 {>;emit {(adjacency graph)};<} -124 {>;emit {(adjacency graph library)};<} 
<

if {[S string 2 0 {} {} eq .VISIX]} {>

emit {(ascii text)}
<}
;<} 20549 {>;emit {Microsoft Document Imaging Format};<} 7967 {>;emit {old packed data}
mime application/octet-stream
;<} 8191 {>;emit {compacted data}
mime application/octet-stream
;<} -13563 {>;emit {huf output}
mime application/octet-stream
;<} 10775 {>;emit {"compact bitmap" format (Poskanzer)};<} 381 {>;emit {CLIPPER COFF executable (VAX #)}

switch -- [Nv short 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit {(5.2 compatible)};<} 265 {>;emit (pure);<} 267 {>;emit {(demand paged)};<} 291 {>;emit {(target shared library)};<} 
<

if {[N long 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N short 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 383 {>;emit {CLIPPER COFF executable}

switch -- [Nv short 18 0 & 30720] 0 {>;emit {C1 R1 };<} 2048 {>;emit {C2 R1};<} 4096 {>;emit {C3 R1};<} 30720 {>;emit TEST;<} 
<

switch -- [Nv short 20 0 {} {}] 263 {>;emit (impure);<} 264 {>;emit (pure);<} 265 {>;emit {(separate I&D)};<} 267 {>;emit (paged);<} 291 {>;emit {(target shared library)};<} 
<

if {[N long 12 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N short 22 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N long 48 0 0 & 1 == 1]} {>

emit {alignment trap enabled}
<}

switch -- [Nv byte 52 0 {} {}] 1 {>;emit -Ctnc;<} 2 {>;emit -Ctsw;<} 3 {>;emit -Ctpw;<} 4 {>;emit -Ctcb;<} 
<

switch -- [Nv byte 53 0 {} {}] 1 {>;emit -Cdnc;<} 2 {>;emit -Cdsw;<} 3 {>;emit -Cdpw;<} 4 {>;emit -Cdcb;<} 
<

switch -- [Nv byte 54 0 {} {}] 1 {>;emit -Csnc;<} 2 {>;emit -Cssw;<} 3 {>;emit -Cspw;<} 4 {>;emit -Cscb;<} 
<
;<} 256 {>;
if {[S search 2 0 {} 9 eq \0\0]} {>

<}

if {[S default 2 0 {} {} x {}]} {>

	if {[N belong 0 0 0 {} {} != 107364]} {>

		if {[N beshort 2 0 0 {} {} != 8]} {>

			if {[S search 11 0 {} 262 eq \x06DESIGN]} {>

<}

			if {[S default 11 0 {} {} x {}]} {>

				if {[S search 27118 0 {} 1864 eq DreamWorld]} {>

<}

				if {[S default 27118 0 {} {} x {}]} {>

					if {[N bequad 8 0 0 {} {} != 3314931918822244867]} {>

						if {[N bequad 8 0 0 {} {} != 6768475576809644948]} {>

						emit {raw G3 (Group 3) FAX, byte-padded}
						mime image/g3fax

						ext g3

<}

<}

<}

<}

<}

<}

<}
;<} 5120 {>;
if {[S search 2 0 {} 9 eq \0\0]} {>

<}

if {[S default 2 0 {} {} x {}]} {>

emit {raw G3 (Group 3) FAX}
mime image/g3fax

ext g3

<}
;<} 392 {>;emit {Perkin-Elmer executable};<} -16162 {>;emit {Compiled PSI (v1) data};<} -16166 {>;emit {Compiled PSI (v2) data}

if {[S string 3 0 {} {} > \0]} {>

emit (%s)
<}
;<} -21846 {>;emit {SoftQuad DESC or font file binary}

if {[N short 2 0 0 {} {} > 0]} {>

emit {- version %d}
<}
;<} 29127 {>;emit {cpio archive}
mime application/x-cpio
;<} -14479 {>;emit {byte-swapped cpio archive}
mime application/x-cpio # encoding: swapped
;<} 272 {>;emit {0420 Alliant virtual executable}

if {[N short 2 0 0 {} {} & 32]} {>

emit {common library}
<}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 273 {>;emit {0421 Alliant compact executable}

if {[N short 2 0 0 {} {} & 32]} {>

emit {common library}
<}

if {[N long 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 10012 {>;
if {[S regex 16 0 s {} eq ^\[0-78\]\[0-9.\]\{4\}]} {>

emit {Sendmail frozen configuration}

	if {[S string 16 0 {} {} > \0]} {>

	emit {- version %s}
<}

ext fc

<}
;<} 601 {>;emit {mumps avl global}

if {[N byte 2 0 0 {} {} > 0]} {>

emit (V%d)
<}

if {[N byte 6 0 0 {} {} > 0]} {>

emit {with %d byte name}
<}

if {[N byte 7 0 0 {} {} > 0]} {>

emit {and %d byte data cells}
<}
;<} 602 {>;emit {mumps blt global}

if {[N byte 2 0 0 {} {} > 0]} {>

emit (V%d)
<}

if {[N short 8 0 0 {} {} > 0]} {>

emit {- %d byte blocks}
<}

switch -- [Nv byte 15 0 {} {}] 0 {>;emit {- P/D format};<} 1 {>;emit {- P/K/D format};<} 2 {>;emit {- K/D format};<} 
<

if {[N byte 15 0 0 {} {} > 2]} {>

emit {- Bad Flags}
<}
;<} 283 {>;emit {Curses screen image};<} 284 {>;emit {Curses screen image};<} 24672 {>;emit {Dyalog APL transfer};<} 1281 {>;emit {locale data table}

switch -- [Nv short 6 0 {} {}] 36 {>;emit {for MIPS};<} 64 {>;emit {for Alpha};<} 
<
;<} 
<
} {
if {[S string 0 0 {} {} eq GRG]} {>

emit {Gringotts data file}

if {[S string 3 0 {} {} eq 1]} {>

emit {v.1, MCRYPT S2K, SERPENT crypt, SHA-256 hash, ZLib lvl.9}
<}

if {[S string 3 0 {} {} eq 2]} {>

emit {v.2, MCRYPT S2K, }

	switch -- [Nv byte 8 0 & 112] 0 {>;emit {RIJNDAEL-128 crypt,};<} 16 {>;emit {SERPENT crypt,};<} 32 {>;emit {TWOFISH crypt, };<} 48 {>;emit {CAST-256 crypt,};<} 64 {>;emit {SAFER+ crypt,};<} 80 {>;emit {LOKI97 crypt,};<} 96 {>;emit {3DES crypt,};<} 112 {>;emit {RIJNDAEL-256 crypt,};<} 
<

	switch -- [Nv byte 8 0 & 8] 0 {>;emit {SHA1 hash,};<} 8 {>;emit {RIPEMD-160 hash,};<} 
<

	switch -- [Nv byte 8 0 & 4] 0 {>;emit ZLib;<} 4 {>;emit BZip2;<} 
<

	switch -- [Nv byte 8 0 & 3] 0 {>;emit lvl.0;<} 1 {>;emit lvl.3;<} 2 {>;emit lvl.6;<} 3 {>;emit lvl.9;<} 
<

<}

if {[S string 3 0 {} {} eq 3]} {>

emit {v.3, OpenPGP S2K, }

	switch -- [Nv byte 8 0 & 112] 0 {>;emit {RIJNDAEL-128 crypt,};<} 16 {>;emit {SERPENT crypt,};<} 32 {>;emit {TWOFISH crypt, };<} 48 {>;emit {CAST-256 crypt,};<} 64 {>;emit {SAFER+ crypt,};<} 80 {>;emit {LOKI97 crypt,};<} 96 {>;emit {3DES crypt,};<} 112 {>;emit {RIJNDAEL-256 crypt,};<} 
<

	switch -- [Nv byte 8 0 & 8] 0 {>;emit {SHA1 hash,};<} 8 {>;emit {RIPEMD-160 hash,};<} 
<

	switch -- [Nv byte 8 0 & 4] 0 {>;emit ZLib;<} 4 {>;emit BZip2;<} 
<

	switch -- [Nv byte 8 0 & 3] 0 {>;emit lvl.0;<} 1 {>;emit lvl.3;<} 2 {>;emit lvl.6;<} 3 {>;emit lvl.9;<} 
<

<}

if {[S string 3 0 {} {} > 3]} {>

emit {v.%.1s (unknown details)}
<}

<}
} {
if {[S regex 0 0 {} {} eq ^%?\[\ \t\]*SiSU\[\ \t\]+insert]} {>

emit {SiSU text insert}

if {[S regex 5 0 {} {} eq \[0-9.\]+]} {>

emit %s
<}

<}
} {
if {[S regex 0 0 {} {} eq ^%\[\ \t\]+SiSU\[\ \t\]+master]} {>

emit {SiSU text master}

if {[S regex 5 0 {} {} eq \[0-9.\]+]} {>

emit %s
<}

<}
} {
if {[S regex 0 0 {} {} eq ^%?\[\ \t\]*SiSU\[\ \t\]+text]} {>

emit {SiSU text}

if {[S regex 5 0 {} {} eq \[0-9.\]+]} {>

emit %s
<}

<}
} {
if {[S regex 0 0 {} {} eq ^%?\[\ \t\]*SiSU\[\ \t\]\[0-9.\]+]} {>

emit {SiSU text}

if {[S regex 5 0 {} {} eq \[0-9.\]+]} {>

emit %s
<}

<}
} {
if {[S regex 0 0 {} {} eq ^%*\[\ \t\]*sisu-\[0-9.\]+]} {>

emit {SiSU text}

if {[S regex 5 0 {} {} eq \[0-9.\]+]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq FC14]} {>

emit {Future Composer 1.4 Module sound file}
<}
} {
if {[S string 0 0 {} {} eq SMOD]} {>

emit {Future Composer 1.3 Module sound file}
<}
} {
if {[S string 0 0 {} {} eq AON4artofnoise]} {>

emit {Art Of Noise Module sound file}
<}
} {
if {[S string 1 0 {} {} eq MUGICIAN/SOFTEYES]} {>

emit {Mugician Module sound file}
<}
} {
if {[S string 58 0 {} {} eq SIDMON\ II\ -\ THE]} {>

emit {Sidmon 2.0 Module sound file}
<}
} {
if {[S string 0 0 {} {} eq Synth4.0]} {>

emit {Synthesis Module sound file}
<}
} {
if {[S string 0 0 {} {} eq ARP.]} {>

emit {The Holy Noise Module sound file}
<}
} {
if {[S string 0 0 {} {} eq BeEp\0]} {>

emit {JamCracker Module sound file}
<}
} {
if {[S string 0 0 {} {} eq COSO\0]} {>

emit {Hippel-COSO Module sound file}
<}
} {
if {[S string 0 0 {} {} eq \#\#\ version]} {>

emit {catalog translation}
<}
} {
if {[S string 0 0 {} {} eq EMOD\0]} {>

emit {Amiga E module}
<}
} {
if {[S string 8 0 {} {} eq ECXM\0]} {>

emit {ECX module}
<}
} {
if {[S string 0 0 c {} eq @database]} {>

emit {AmigaGuide file}
<}
} {
if {[S string 0 0 {} {} eq RDSK]} {>

emit {Rigid Disk Block}

if {[S string 160 0 {} {} x {}]} {>

emit {on %.24s}
<}

<}
} {
if {[S string 0 0 {} {} eq DOS\0]} {>

emit {Amiga DOS disk}
<}
} {
if {[S string 0 0 {} {} eq DOS\1]} {>

emit {Amiga FFS disk}
<}
} {
if {[S string 0 0 {} {} eq DOS\2]} {>

emit {Amiga Inter DOS disk}
<}
} {
if {[S string 0 0 {} {} eq DOS\3]} {>

emit {Amiga Inter FFS disk}
<}
} {
if {[S string 0 0 {} {} eq DOS\4]} {>

emit {Amiga Fastdir DOS disk}
<}
} {
if {[S string 0 0 {} {} eq DOS\5]} {>

emit {Amiga Fastdir FFS disk}
<}
} {
if {[S string 0 0 {} {} eq KICK]} {>

emit {Kickstart disk}
<}
} {
if {[S string 0 0 {} {} eq LZX]} {>

emit {LZX compressed archive (Amiga)}
<}
} {
if {[S string 0 0 {} {} eq .KEY]} {>

emit {AmigaDOS script}
<}
} {
if {[S string 0 0 {} {} eq .key]} {>

emit {AmigaDOS script}
<}
} {
if {[S string 0 0 {} {} eq \#!teapot\012xdr]} {>

emit {teapot work sheet (XDR format)}
<}
} {
if {[Sx string 0 0 {} {} eq /*\x20CTF\x20]} {>

emit {Common Trace Format (CTF) plain text metadata}

if {[Sx regex [R 0] 0 {} {} eq \[0-9\]+.\[0-9\]+]} {>

emit {\b, v%s}
<}

<}
} {
if {[S string 0 0 {} {} eq \074\074bbx\076\076]} {>

emit BBx

if {[S string 7 0 {} {} eq \000]} {>

emit {indexed file}
<}

if {[S string 7 0 {} {} eq \001]} {>

emit {serial file}
<}

if {[S string 7 0 {} {} eq \002]} {>

emit {keyed file}

	if {[N short 13 0 0 {} {} == 0]} {>

	emit (sort)
<}

<}

if {[S string 7 0 {} {} eq \004]} {>

emit program

	if {[N byte 18 0 0 {} {} x {}]} {>

	emit {(LEVEL %d)}

		if {[S string 23 0 {} {} > \000]} {>

		emit psaved
<}

<}

<}

if {[S string 7 0 {} {} eq \006]} {>

emit {mkeyed file}

	if {[N short 13 0 0 {} {} == 0]} {>

	emit (sort)
<}

	if {[S string 8 0 {} {} eq \000]} {>

	emit (mkey)
<}

<}

<}
} {
if {[Sx string 0 0 t {} eq <?xml]} {>

if {[Sx search 20 0 {} 400 eq \ xmlns=]} {>

	if {[Sx regex [R 0] 0 {} {} eq \['\"\]http://earth.google.com/kml]} {>

	emit {Google KML document}

		if {[Sx string [R 1] 0 {} {} eq 2.0']} {>

		emit {\b, version 2.0}
<}

		if {[Sx string [R 1] 0 {} {} eq 2.1']} {>

		emit {\b, version 2.1}
<}

		if {[Sx string [R 1] 0 {} {} eq 2.2']} {>

		emit {\b, version 2.2}
<}

	mime application/vnd.google-earth.kml+xml

<}

	if {[Sx regex [R 0] 0 {} {} eq \['\"\]http://www.opengis.net/kml]} {>

	emit {OpenGIS KML document}

		if {[Sx string [R 1] 0 t {} eq 2.2]} {>

		emit {\b, version 2.2}
<}

	mime application/vnd.google-earth.kml+xml

<}

<}

<}
} {
if {[S string 0 0 {} {} eq PK\003\004]} {>

if {[N byte 4 0 0 {} {} == 20]} {>

	if {[S string 30 0 {} {} eq doc.kml]} {>

	emit {Compressed Google KML Document, including resources.}
	mime application/vnd.google-earth.kmz

<}

<}

<}
} {
if {[S search 0 0 {} 1 eq FONT]} {>

emit {ASCII vfont text}
<}
} {
if {[S string 0 0 {} {} eq %!PS-AdobeFont-1.]} {>

emit {PostScript Type 1 font text}

if {[S string 20 0 {} {} > \0]} {>

emit (%s)
<}

<}
} {
if {[S string 6 0 {} {} eq %!PS-AdobeFont-1.]} {>

emit {PostScript Type 1 font program data}
<}
} {
if {[S string 0 0 {} {} eq %!FontType1]} {>

emit {PostScript Type 1 font program data}
<}
} {
if {[S string 6 0 {} {} eq %!FontType1]} {>

emit {PostScript Type 1 font program data}
<}
} {
if {[S string 0 0 {} {} eq %!PS-Adobe-3.0\ Resource-Font]} {>

emit {PostScript Type 1 font text}
<}
} {
if {[S search 0 0 {} 1 eq STARTFONT\ ]} {>

emit {X11 BDF font text}
<}
} {
if {[S string 0 0 {} {} eq FILE]} {>

if {[S string 8 0 {} {} eq PFF2]} {>

	if {[N belong 4 0 0 {} {} == 4]} {>

		if {[S string 12 0 {} {} eq NAME]} {>

		emit {GRUB2 font}

			if {[N belong 16 0 0 {} {} > 0]} {>

				if {[S string 20 0 {} {} > \0]} {>

				emit {"%-s"}
<}

<}

		mime application/x-font-pf2

		ext pf2

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \001fcp]} {>

emit {X11 Portable Compiled Font data}

switch -- [Nv byte 12 0 {} {}] 2 {>;emit {\b, LSB first};<} 10 {>;emit {\b, MSB first};<} 
<

<}
} {
if {[S string 0 0 {} {} eq D1.0\015]} {>

emit {X11 Speedo font data}
<}
} {
if {[S string 0 0 {} {} eq flf]} {>

emit {FIGlet font}

if {[S string 3 0 {} {} > 2a]} {>

emit {version %-2.2s}
<}

<}
} {
if {[S string 0 0 {} {} eq flc]} {>

emit {FIGlet controlfile}

if {[S string 3 0 {} {} > 2a]} {>

emit {version %-2.2s}
<}

<}
} {
switch -- [Nv belong 7 0 {} {}] 4540225 {>;emit {DOS code page font data};<} 5654852 {>;emit {DOS code page font data (from Linux?)};<} 
<
} {
if {[S string 4098 0 {} {} eq DOSFONT]} {>

emit {DOSFONT2 encrypted font data}
<}
} {
if {[S string 0 0 {} {} eq PFR1]} {>

emit {Portable Font Resource font data (new)}

if {[S string 102 0 {} {} > 0]} {>

emit {\b: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq PFR0]} {>

emit {Portable Font Resource font data (old)}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq \000\001\000\000\000]} {>

emit {TrueType font data}
mime application/x-font-ttf

<}
} {
if {[S string 0 0 {} {} eq \007\001\001\000Copyright\ (c)\ 199]} {>

emit {Adobe Multiple Master font}
<}
} {
if {[S string 0 0 {} {} eq \012\001\001\000Copyright\ (c)\ 199]} {>

emit {Adobe Multiple Master font}
<}
} {
if {[S string 0 0 {} {} eq ttcf]} {>

emit {TrueType font collection data}

switch -- [Nv belong 4 0 {} {}] 65536 {>;emit {\b, 1.0}

	if {[N belong 8 0 0 {} {} > 0]} {>

	emit {\b, %d fonts}
<}
;<} 131072 {>;emit {\b, 2.0}

	if {[N belong 8 0 0 {} {} > 0]} {>

	emit {\b, %d fonts}

		if {[N belong 16 0 0 {} {} == 1146308935]} {>

		emit {\b, digitally signed}
<}

<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq OTTO]} {>

emit {OpenType font data}
mime application/vnd.ms-opentype

<}
} {
if {[S string 0 0 {} {} eq SplineFontDB:]} {>

emit {Spline Font Database }

if {[S string 14 0 {} {} x {}]} {>

emit {version %s}
<}

mime application/vnd.font-fontforge-sfd

<}
} {
if {[S string 34 0 {} {} eq LP]} {>

emit {Embedded OpenType (EOT)}
mime application/vnd.ms-fontobject

<}
} {
if {[S string 0 0 {} {} eq wOFF]} {>

emit {Web Open Font Format}
U 48 woff

if {[N beshort 20 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N beshort 22 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

<}
} {
if {[S string 0 0 {} {} eq wOF2]} {>

emit {Web Open Font Format (Version 2)}
U 48 woff

if {[N beshort 24 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N beshort 26 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

<}
} {
if {[S string 0 0 {} {} eq conectix]} {>

emit {Microsoft Disk Image, Virtual Server or Virtual PC}
<}
} {
if {[S string 0 0 {} {} eq LibvirtQemudSave]} {>

emit {Libvirt QEMU Suspend Image}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {\b, version %u}
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit {\b, XML length %u}
<}

if {[N lelong 24 0 0 {} {} == 1]} {>

emit {\b, running}
<}

if {[N lelong 28 0 0 {} {} == 1]} {>

emit {\b, compressed}
<}

<}
} {
if {[S string 0 0 {} {} eq LibvirtQemudPart]} {>

emit {Libvirt QEMU partial Suspend Image}
<}
} {
if {[S string 0 0 b {} eq COWD]} {>

emit VMWare3

switch -- [Nv byte 4 0 {} {}] 3 {>;emit {disk image}

	if {[N lelong 32 0 0 {} {} x {}]} {>

	emit (%d/
<}

	if {[N lelong 36 0 0 {} {} x {}]} {>

	emit {\b%d/}
<}

	if {[N lelong 40 0 0 {} {} x {}]} {>

	emit {\b%d)}
<}
;<} 2 {>;emit {undoable disk image}

	if {[S string 32 0 {} {} > \0]} {>

	emit (%s)
<}
;<} 
<

<}
} {
if {[S string 0 0 b {} eq VMDK]} {>

emit {VMware4 disk image}
<}
} {
if {[S string 0 0 b {} eq KDMV]} {>

emit {VMware4 disk image}
<}
} {
if {[S string 0 0 b {} eq QFI\xFB]} {>

emit {QEMU QCOW Image}

switch -- [Nv belong 4 0 {} {}] 1 {>;emit (v1)

	if {[N belong 12 0 0 {} {} > 0]} {>

	emit {\b, has backing file (}

		if {[S string [I 12 belong 0 0 0 0] 0 {} {} > \0]} {>

		emit {\bpath %s}

			if {[N bedate 20 0 0 {} {} > 0]} {>

			emit {\b, mtime %s)}
<}

			if {[S default 20 0 {} {} x {}]} {>

			emit {\b)}
<}

<}

<}

	if {[N bequad 24 0 0 {} {} x {}]} {>

	emit {\b, %lld bytes}
<}

	if {[N belong 36 0 0 {} {} == 1]} {>

	emit {\b, AES-encrypted}
<}
;<} 2 {>;emit (v2)

	if {[N bequad 8 0 0 {} {} > 0]} {>

	emit {\b, has backing file}

		if {[S string [I 12 belong 0 0 0 0] 0 {} {} > \0]} {>

		emit {(path %s)}
<}

<}

	if {[N bequad 24 0 0 {} {} x {}]} {>

	emit {\b, %lld bytes}
<}

	if {[N belong 32 0 0 {} {} == 1]} {>

	emit {\b, AES-encrypted}
<}
;<} 3 {>;emit (v3)

	if {[N bequad 8 0 0 {} {} > 0]} {>

	emit {\b, has backing file}

		if {[S string [I 12 belong 0 0 0 0] 0 {} {} > \0]} {>

		emit {(path %s)}
<}

<}

	if {[N bequad 24 0 0 {} {} x {}]} {>

	emit {\b, %lld bytes}
<}

	if {[N belong 32 0 0 {} {} == 1]} {>

	emit {\b, AES-encrypted}
<}
;<} 
<

if {[S default 4 0 {} {} x {}]} {>

emit {(unknown version)}
<}

<}
} {
if {[S string 0 0 b {} eq QEVM]} {>

emit {QEMU suspend to disk image}
<}
} {
if {[S string 0 0 b {} eq QED\0]} {>

emit {QEMU QED Image}
<}
} {
if {[N lelong 64 0 0 {} {} == 3201962111]} {>

emit {VirtualBox Disk Image}

if {[N leshort 68 0 0 {} {} > 0]} {>

emit {\b, major %u}
<}

if {[N leshort 70 0 0 {} {} > 0]} {>

emit {\b, minor %u}
<}

if {[S string 0 0 {} {} > \0]} {>

emit (%s)
<}

if {[N lequad 368 0 0 {} {} x {}]} {>

emit {\b, %lld bytes}
<}

<}
} {
if {[S string 0 0 b {} eq Bochs\ Virtual\ HD\ Image]} {>

emit {Bochs disk image,}

if {[S string 32 0 {} {} x {}]} {>

emit {type %s,}
<}

if {[S string 48 0 {} {} x {}]} {>

emit {subtype %s}
<}

<}
} {
if {[S string 0 0 {} {} eq :)\n]} {>

emit {Smile binary data}

if {[N byte 3 0 0 & 240 x {}]} {>

emit {version %d:}
<}

switch -- [Nv byte 3 0 & 4] 4 {>;emit {binary raw,};<} 0 {>;emit {binary encoded,};<} 
<

switch -- [Nv byte 3 0 & 2] 2 {>;emit {shared String values enabled,};<} 0 {>;emit {shared String values disabled,};<} 
<

switch -- [Nv byte 3 0 & 1] 1 {>;emit {shared field names enabled};<} 0 {>;emit {shared field names disabled};<} 
<

<}
} {
if {[S string 0 0 {} {} eq OggS]} {>

emit {Ogg data}

if {[N byte 4 0 0 {} {} != 0]} {>

emit {UNKNOWN REVISION %u}
<}

if {[N byte 4 0 0 {} {} == 0]} {>

	if {[S string 28 0 {} {} eq \x7fFLAC]} {>

	emit {\b, FLAC audio}
	mime audio/ogg

<}

	if {[S string 28 0 {} {} eq \x80theora]} {>

	emit {\b, Theora video}
	mime video/ogg

<}

	if {[S string 28 0 {} {} eq \x80kate\0\0\0\0]} {>

	emit {\b, Kate (Karaoke and Text)}

		if {[N byte 37 0 0 {} {} x {}]} {>

		emit v%u
<}

		if {[N byte 38 0 0 {} {} x {}]} {>

		emit {\b.%u,}
<}

		if {[N byte 40 0 0 {} {} == 0]} {>

		emit {utf8 encoding,}
<}

		if {[N byte 40 0 0 {} {} != 0]} {>

		emit {unknown character encoding,}
<}

		if {[S string 60 0 {} {} > \0]} {>

		emit {language %s,}
<}

		if {[S string 60 0 {} {} eq \0]} {>

		emit {no language set,}
<}

		if {[S string 76 0 {} {} > \0]} {>

		emit {category %s}
<}

		if {[S string 76 0 {} {} eq \0]} {>

		emit {no category set}
<}

	mime application/ogg

<}

	if {[S string 28 0 {} {} eq fishead\0]} {>

	emit {\b, Skeleton}

		if {[N leshort 36 0 0 {} {} x {}]} {>

		emit v%u
<}

		if {[N leshort 40 0 0 {} {} x {}]} {>

		emit {\b.%u}
<}

	mime video/ogg

<}

	if {[S string 28 0 {} {} eq Speex\ \ \ ]} {>

	emit {\b, Speex audio}
	mime audio/ogg

<}

	if {[S string 28 0 {} {} eq \x01video\0\0\0]} {>

	emit {\b, OGM video}

		if {[S string 37 0 c {} eq div3]} {>

		emit {(DivX 3)}
<}

		if {[S string 37 0 c {} eq divx]} {>

		emit {(DivX 4)}
<}

		if {[S string 37 0 c {} eq dx50]} {>

		emit {(DivX 5)}
<}

		if {[S string 37 0 c {} eq xvid]} {>

		emit (XviD)
<}

	mime video/ogg

<}

	if {[S string 28 0 {} {} eq \x01vorbis]} {>

	emit {\b, Vorbis audio,}

		if {[N lelong 35 0 0 {} {} != 0]} {>

		emit {UNKNOWN VERSION %u,}
<}

		if {[N lelong 35 0 0 {} {} == 0]} {>

			switch -- [Nv byte 39 0 {} {}] 1 {>;emit mono,;<} 2 {>;emit stereo,;<} 
<

			if {[N byte 39 0 0 {} {} > 2]} {>

			emit {%u channels,}
<}

			if {[N lelong 40 0 0 {} {} x {}]} {>

			emit {%u Hz}
<}

			if {[S string 48 0 {} {} < \xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff]} {>

			emit {\b,}

				if {[N lelong 52 0 0 {} {} != -1]} {>

					if {[N lelong 52 0 0 {} {} != 0]} {>

						if {[N lelong 52 0 0 {} {} != -1000]} {>

							if {[N lelong 52 0 0 {} {} x {}]} {>

							emit <%u
<}

<}

<}

<}

				if {[N lelong 48 0 0 {} {} != -1]} {>

					if {[N lelong 48 0 0 {} {} x {}]} {>

					emit ~%u
<}

<}

				if {[N lelong 44 0 0 {} {} != -1]} {>

					if {[N lelong 44 0 0 {} {} != -1000]} {>

						if {[N lelong 44 0 0 {} {} != 0]} {>

							if {[N lelong 44 0 0 {} {} x {}]} {>

							emit >%u
<}

<}

<}

<}

				if {[S string 48 0 {} {} < \xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff]} {>

				emit bps
<}

<}

<}

		if {[S string [I 84 byte 0 + 0 85] 0 {} {} eq \x03vorbis]} {>

			if {[S string [I 84 byte 0 + 0 96] 0 c {} eq Xiphophorus\ libVorbis\ I]} {>

			emit {\b, created by: Xiphophorus libVorbis I}

				if {[S string [I 84 byte 0 + 0 120] 0 {} {} > 00000000]} {>

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} < 20000508]} {>

					emit {(<beta1, prepublic)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20000508]} {>

					emit {(1.0 beta 1 or beta 2)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} > 20000508]} {>

						if {[S string [I 84 byte 0 + 0 120] 0 {} {} < 20001031]} {>

						emit (beta2-3)
<}

<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20001031]} {>

					emit {(1.0 beta 3)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} > 20001031]} {>

						if {[S string [I 84 byte 0 + 0 120] 0 {} {} < 20010225]} {>

						emit (beta3-4)
<}

<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20010225]} {>

					emit {(1.0 beta 4)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} > 20010225]} {>

						if {[S string [I 84 byte 0 + 0 120] 0 {} {} < 20010615]} {>

						emit (beta4-RC1)
<}

<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20010615]} {>

					emit {(1.0 RC1)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20010813]} {>

					emit {(1.0 RC2)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20010816]} {>

					emit {(RC2 - Garf tuned v1)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20011014]} {>

					emit {(RC2 - Garf tuned v2)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20011217]} {>

					emit {(1.0 RC3)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} eq 20011231]} {>

					emit {(1.0 RC3)}
<}

					if {[S string [I 84 byte 0 + 0 120] 0 {} {} > 20011231]} {>

					emit {(pre-1.0 CVS)}
<}

<}

<}

			if {[S string [I 84 byte 0 + 0 96] 0 c {} eq Xiph.Org\ libVorbis\ I]} {>

			emit {\b, created by: Xiph.Org libVorbis I}

				if {[S string [I 84 byte 0 + 0 117] 0 {} {} > 00000000]} {>

					if {[S string [I 84 byte 0 + 0 117] 0 {} {} < 20020717]} {>

					emit {(pre-1.0 CVS)}
<}

					if {[S string [I 84 byte 0 + 0 117] 0 {} {} eq 20020717]} {>

					emit (1.0)
<}

					if {[S string [I 84 byte 0 + 0 117] 0 {} {} eq 20030909]} {>

					emit (1.0.1)
<}

					if {[S string [I 84 byte 0 + 0 117] 0 {} {} eq 20040629]} {>

					emit {(1.1.0 RC1)}
<}

<}

<}

<}

	mime audio/ogg

<}

	if {[S string 28 0 {} {} eq OpusHead]} {>

	emit {\b, Opus audio,}

		if {[N byte 36 0 0 {} {} > 15]} {>

		emit {UNKNOWN VERSION %u,}
<}

		if {[N byte 36 0 0 {} {} & 15]} {>

		emit {version 0.%d}

			if {[N byte 46 0 0 {} {} > 1]} {>

				if {[N byte 46 0 0 {} {} != 255]} {>

				emit {unknown channel mapping family %u,}
<}

				if {[N byte 37 0 0 {} {} x {}]} {>

				emit {%u channels}
<}

<}

			switch -- [Nv byte 46 0 {} {}] 0 {>;
				switch -- [Nv byte 37 0 {} {}] 1 {>;emit mono;<} 2 {>;emit stereo;<} 
<
;<} 1 {>;
				switch -- [Nv byte 37 0 {} {}] 1 {>;emit mono;<} 2 {>;emit stereo;<} 3 {>;emit {linear surround};<} 4 {>;emit quadraphonic;<} 5 {>;emit {5.0 surround};<} 6 {>;emit {5.1 surround};<} 7 {>;emit {6.1 surround};<} 8 {>;emit {7.1 surround};<} 
<
;<} 
<

			if {[N lelong 40 0 0 {} {} != 0]} {>

			emit {\b, %u Hz}
<}

<}

	mime audio/ogg

<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq GnomeKeyring\n\r\0\n]} {>

emit {GNOME keyring}

if {[Nx byte [R 0] 0 0 {} {} == 0]} {>

emit {\b, major version 0}

	if {[Nx byte [R 0] 0 0 {} {} == 0]} {>

	emit {\b, minor version 0}

		if {[Nx byte [R 0] 0 0 {} {} == 0]} {>

		emit {\b, crypto type 0 (AES)}
<}

		if {[Nx byte [R 0] 0 0 {} {} > 0]} {>

		emit {\b, crypto type %u (unknown)}
<}

		if {[Nx byte [R 1] 0 0 {} {} == 0]} {>

		emit {\b, hash type 0 (MD5)}
<}

		if {[Nx byte [R 1] 0 0 {} {} > 0]} {>

		emit {\b, hash type %u (unknown)}
<}

		if {[Nx belong [R 2] 0 0 {} {} == 4294967295]} {>

		emit {\b, name NULL}
<}

		if {[Nx belong [R 2] 0 0 {} {} != 4294967295]} {>

			if {[Nx belong [R -4] 0 0 {} {} > 255]} {>

			emit {\b, name too long for file's pstring type}
<}

			if {[Nx belong [R -4] 0 0 {} {} < 256]} {>

				if {[Sx pstring [R -1] 0 {} {} x {}]} {>

				emit {\b, name "%s"}

					if {[Nx beqdate [R 0] 0 0 {} {} x {}]} {>

					emit {\b, last modified %s}
<}

					if {[Nx beqdate [R 8] 0 0 {} {} x {}]} {>

					emit {\b, created %s}
<}

					if {[Nx belong [R 16] 0 0 {} {} & 1]} {>

						if {[Nx belong [R 0] 0 0 {} {} x {}]} {>

						emit {\b, locked if idle for %u seconds}
<}

<}

					if {[Nx belong [R 16] 0 0 {} {} ^ 1]} {>

					emit {\b, not locked if idle}
<}

					if {[Nx belong [R 24] 0 0 {} {} x {}]} {>

					emit {\b, hash iterations %u}
<}

					if {[Nx bequad [R 28] 0 0 {} {} x {}]} {>

					emit {\b, salt %llu}
<}

					if {[Nx belong [R 52] 0 0 {} {} x {}]} {>

					emit {\b, %u item(s)}
<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 4 0 {} {} eq gtktalog]} {>

emit {GNOME Catalogue (gtktalog)}

if {[S string 13 0 {} {} > \0]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq GVariant]} {>

emit {GVariant Database file,}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq GOBJ\nMETADATA\r\n\032]} {>

emit {G-IR binary database}

if {[N byte 16 0 0 {} {} x {}]} {>

emit {\b, v%d}
<}

if {[N byte 17 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N leshort 20 0 0 {} {} x {}]} {>

emit {\b, %d entries}
<}

if {[N leshort 22 0 0 {} {} x {}]} {>

emit {\b/%d local}
<}

<}
} {
if {[S search 0 0 {} 1 eq \#\#Sketch]} {>

emit {Sketch document text}
<}
} {
switch -- [Nv belong 0 0 & 16777215] 196875 {>;emit {SPARC demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 36 0 0 {} {} == 3020947457]} {>

emit {(uses shared libs)}
<}
;<} 196872 {>;emit {SPARC pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 36 0 0 {} {} == 3020947457]} {>

emit {(uses shared libs)}
<}
;<} 196871 {>;emit SPARC

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}

if {[N belong 36 0 0 {} {} == 3020947457]} {>

emit {(uses shared libs)}
<}
;<} 196875 {>;emit {a.out SunOS SPARC demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 196872 {>;emit {a.out SunOS SPARC pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 196871 {>;emit {a.out SunOS SPARC}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 131339 {>;emit {a.out SunOS mc68020 demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 131336 {>;emit {a.out SunOS mc68020 pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 131335 {>;emit {a.out SunOS mc68020}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 65803 {>;emit {a.out SunOS mc68010 demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 65800 {>;emit {a.out SunOS mc68010 pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 65799 {>;emit {a.out SunOS mc68010}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 
<
} {
if {[S string 0 0 {} {} eq %SEMI-OASIS\r\n]} {>

emit {OASIS Stream file}
<}
} {
if {[S string 0 0 {} {} eq \0177BEAM!]} {>

emit {Old Erlang BEAM file}

if {[N short 6 0 0 {} {} > 0]} {>

emit {- version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq FOR1]} {>

if {[S string 8 0 {} {} eq BEAM]} {>

emit {Erlang BEAM file}
<}

<}
} {
if {[S string 4 0 {} {} eq Tue\ Jan\ 22\ 14:32:44\ MET\ 1991]} {>

emit {Erlang JAM file - version 4.2}
<}
} {
if {[S string 79 0 {} {} eq Tue\ Jan\ 22\ 14:32:44\ MET\ 1991]} {>

emit {Erlang JAM file - version 4.2}
<}
} {
if {[S string 4 0 {} {} eq 1.0\ Fri\ Feb\ 3\ 09:55:56\ MET\ 1995]} {>

emit {Erlang JAM file - version 4.3}
<}
} {
switch -- [Nvx bequad 0 0 {} {}] 11259375 {>;emit {Erlang DETS file};<} -6518119229588284681 {>;emit {Hash::SharedMem master file, big-endian}

if {[N bequad 8 0 0 {} {} < 16777216]} {>

	if {[N byte 15 0 0 {} {} > 2]} {>

	emit {\b, line size 2^%d byte}
<}

	if {[N byte 14 0 0 {} {} > 2]} {>

	emit {\b, page size 2^%d byte}
<}

	if {[N byte 13 0 0 {} {} & 1]} {>

		if {[N byte 13 0 0 {} {} > 1]} {>

		emit {\b, max fanout %d}
<}

<}

<}
;<} -4137723088997562430 {>;emit {Hash::SharedMem data file, big-endian}

if {[N bequad 8 0 0 {} {} < 16777216]} {>

	if {[N byte 15 0 0 {} {} > 2]} {>

	emit {\b, line size 2^%d byte}
<}

	if {[N byte 14 0 0 {} {} > 2]} {>

	emit {\b, page size 2^%d byte}
<}

	if {[N byte 13 0 0 {} {} & 1]} {>

		if {[N byte 13 0 0 {} {} > 1]} {>

		emit {\b, max fanout %d}
<}

<}

<}
;<} -5199405631432697327 {>;
if {[N bequad 8 0 0 {} {} == 11983515692459535757]} {>

emit {Windows Television DVR Media}
<}
;<} -9207870847048482801 {>;emit {Nintendo 64 ROM image}

if {[S string 32 0 {} {} > \0]} {>

emit {\b: "%.20s"}
<}

if {[S string 59 0 {} {} x {}]} {>

emit (%.4s
<}

if {[N byte 63 0 0 {} {} x {}]} {>

emit {\b, Rev.%02u)}
<}
;<} 3999266915158593280 {>;emit {Nintendo 64 ROM image (V64)};<} 1315192064904724480 {>;emit {Nintendo 64 ROM image (wordswapped)};<} 4616813591155179520 {>;emit {Nintendo 64 ROM image (32-bit byteswapped)};<} 3585022330545405070 {>;
if {[Nx leshort 4 0 0 {} {} x {}]} {>

	if {[Sx search 181 0 {} 166 eq Error\ \0\r\n]} {>

	emit {NetBSD mbr}

		if {[N belong 440 0 0 {} {} > 0]} {>

		emit {\b,Serial 0x%-.8x}
<}

		if {[S search 187 0 {} 71 eq \xcd\x13\x5a\x52\x52]} {>

		emit {\b,bootselector}
<}

		if {[S search 150 0 {} 1 eq \x66\x87\xca\x66\x01\xca\x66\x89\x16\x3a\x07\xbe\x32\x07\xb4\x42\x5a\x52\xcd\x13]} {>

		emit {\b,boot extended}
<}

		if {[S search 304 0 {} 55 eq \xee\x80\xc2\x05\xec\xa8\x40]} {>

		emit {\b,serial IO}
<}

		if {[Sx search 196 0 {} 106 eq No\ active\ partition\0]} {>

			if {[Sx string [R 0] 0 {} {} eq Disk\ read\ error\0]} {>

				if {[Sx string [R 0] 0 {} {} eq No\ operating\ system\0]} {>

				emit {\b,verbose}
<}

<}

<}

		if {[S search 125 0 {} 7 eq \x5a\x52\xb4\x08\xcd\x13]} {>

		emit {\b,CHS}
<}

		if {[S search 164 0 {} 84 eq \xbb\xaa\x55\xb4\x41\x5a\x52\xcd\x13]} {>

		emit {\b,LBA-check}
<}

		if {[Sx search 38 0 {} 21 eq \xBB\x94\x07]} {>

			if {[Nx bequad [R -9] 0 0 & 13691207746446080916 == 13690943863638768532]} {>

				if {[Sx search 181 0 {} 166 eq Error\ \0]} {>

					if {[Sx string [R 3] 0 {} {} x {}]} {>

					emit {\b,"%s"}
<}

<}

<}

<}
U 243 partition-table

<}

<}
;<} 
<
} {
if {[S string 0 0 {} {} eq PLUS3DOS\032]} {>

emit {Spectrum +3 data}

switch -- [Nv byte 15 0 {} {}] 0 {>;emit {- BASIC program};<} 1 {>;emit {- number array};<} 2 {>;emit {- character array};<} 3 {>;emit {- memory block}

	if {[N belong 16 0 0 {} {} == 1769536]} {>

	emit (screen)
<}
;<} 4 {>;emit {- Tasword document};<} 
<

if {[S string 15 0 {} {} eq TAPEFILE]} {>

emit {- ZXT tapefile}
<}

<}
} {
if {[S string 0 0 {} {} eq \023\000\000]} {>

if {[S string 4 0 {} {} > \0]} {>

	if {[S string 4 0 {} {} < \177]} {>

	emit {Spectrum .TAP data "%-10.10s"}

		switch -- [Nv byte 3 0 {} {}] 0 {>;emit {- BASIC program};<} 1 {>;emit {- number array};<} 2 {>;emit {- character array};<} 3 {>;emit {- memory block}

			if {[N belong 14 0 0 {} {} == 1769536]} {>

			emit (screen)
<}
;<} 
<

<}

<}

<}
} {
if {[S string 0 0 {} {} eq ZXTape!\x1a]} {>

emit {Spectrum .TZX data}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version %d}
<}

if {[N byte 9 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

<}
} {
if {[S string 0 0 {} {} eq RZX!]} {>

emit {Spectrum .RZX data}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

<}
} {
if {[S string 0 0 {} {} eq MV\ -\ CPCEMU\ Disk-Fil]} {>

emit {Amstrad/Spectrum .DSK data}
<}
} {
if {[S string 0 0 {} {} eq MV\ -\ CPC\ format\ Dis]} {>

emit {Amstrad/Spectrum DU54 .DSK data}
<}
} {
if {[S string 0 0 {} {} eq EXTENDED\ CPC\ DSK\ Fil]} {>

emit {Amstrad/Spectrum Extended .DSK data}
<}
} {
if {[S string 0 0 {} {} eq SINCLAIR]} {>

emit {Spectrum .SCL Betadisk image}
<}
} {
if {[S string 0 0 {} {} eq RS-IDE\x1a]} {>

emit {Spectrum .HDF hard disk image}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b, version 0x%02x}
<}

<}
} {
if {[S string 0 0 {} {} eq RTSS]} {>

emit {NetMon capture file}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

switch -- [Nv leshort 6 0 {} {}] 0 {>;emit (Unknown);<} 1 {>;emit (Ethernet);<} 2 {>;emit {(Token Ring)};<} 3 {>;emit (FDDI);<} 4 {>;emit (ATM);<} 
<

if {[N leshort 6 0 0 {} {} > 4]} {>

emit {(type %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq GMBU]} {>

emit {NetMon capture file}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

switch -- [Nv leshort 6 0 {} {}] 0 {>;emit (Unknown);<} 1 {>;emit (Ethernet);<} 2 {>;emit {(Token Ring)};<} 3 {>;emit (FDDI);<} 4 {>;emit (ATM);<} 5 {>;emit {(IP-over-IEEE 1394)};<} 6 {>;emit (802.11);<} 7 {>;emit {(Raw IP)};<} 8 {>;emit {(Raw IP)};<} 9 {>;emit {(Raw IP)};<} 
<

if {[N leshort 6 0 0 {} {} > 9]} {>

emit {(type %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq TRSNIFF\ data\ \ \ \ \032]} {>

emit {Sniffer capture file}

if {[N byte 33 0 0 {} {} == 2]} {>

emit (compressed)
<}

if {[N leshort 23 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N leshort 25 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

switch -- [Nv byte 32 0 {} {}] 0 {>;emit {(Token Ring)};<} 1 {>;emit (Ethernet);<} 2 {>;emit (ARCNET);<} 3 {>;emit (StarLAN);<} 4 {>;emit {(PC Network broadband)};<} 5 {>;emit (LocalTalk);<} 6 {>;emit (Znet);<} 7 {>;emit {(Internetwork Analyzer)};<} 9 {>;emit (FDDI);<} 10 {>;emit (ATM);<} 
<

<}
} {
if {[S string 0 0 {} {} eq XCP\0]} {>

emit {NetXRay capture file}

if {[S string 4 0 {} {} > \0]} {>

emit {- version %s}
<}

switch -- [Nv leshort 44 0 {} {}] 0 {>;emit (Ethernet);<} 1 {>;emit {(Token Ring)};<} 2 {>;emit (FDDI);<} 3 {>;emit (WAN);<} 8 {>;emit (ATM);<} 9 {>;emit (802.11);<} 
<

<}
} {
if {[S string 0 0 {} {} eq iptrace\ 1.0]} {>

emit {"iptrace" capture file}
<}
} {
if {[S string 0 0 {} {} eq iptrace\ 2.0]} {>

emit {"iptrace" capture file}
<}
} {
if {[S string 0 0 {} {} eq \x54\x52\x00\x64\x00]} {>

emit {"nettl" capture file}
<}
} {
if {[S string 0 0 {} {} eq \x42\xd2\x00\x34\x12\x66\x22\x88]} {>

emit {RADCOM WAN/LAN Analyzer capture file}
<}
} {
if {[S string 0 0 {} {} eq NetS]} {>

emit {NetStumbler log file}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, %d stations found}
<}

<}
} {
if {[S string 0 0 {} {} eq \177ver]} {>

emit {EtherPeek/AiroPeek/OmniPeek capture file}
<}
} {
if {[S string 0 0 {} {} eq \x05VNF]} {>

emit {Visual Networks traffic capture file}
<}
} {
if {[S string 0 0 {} {} eq ObserverPktBuffe]} {>

emit {Network Instruments Observer capture file}
<}
} {
if {[S string 0 0 {} {} eq \xaa\xaa\xaa\xaa]} {>

emit {5View capture file}
<}
} {
if {[S search 0 0 {} 4096 eq (setq\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[S search 0 0 {} 4096 eq (defvar\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[S search 0 0 {} 4096 eq (defparam\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[S search 0 0 {} 4096 eq (defun\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[S search 0 0 {} 4096 eq (autoload\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[S search 0 0 {} 4096 eq (custom-set-variables\ ]} {>

emit {Lisp/Scheme program text}
mime text/x-lisp

<}
} {
if {[Sx string 0 0 {} {} eq \012(]} {>

if {[Sx regex [R 0] 0 {} {} eq ^(defun|defvar|defconst|defmacro|setq|fset)]} {>

emit {Emacs v18 byte-compiled Lisp data}
mime application/x-elc

ext elc

<}

if {[Sx regex [R 0] 0 {} {} eq ^(put|provide|require|random)]} {>

emit {Emacs v18 byte-compiled Lisp data}
mime application/x-elc

ext elc

<}

<}
} {
if {[S string 0 0 {} {} eq \;ELC]} {>

if {[N byte 4 0 0 {} {} > 18]} {>

emit {Emacs/XEmacs v%d byte-compiled Lisp data}
mime application/x-elc		

ext elc

<}

<}
} {
if {[S string 0 0 {} {} eq (SYSTEM::VERSION\040']} {>

emit {CLISP byte-compiled Lisp program (pre 2004-03-27)}
<}
} {
if {[S string 0 0 {} {} eq (|SYSTEM|::|VERSION|\040']} {>

emit {CLISP byte-compiled Lisp program text}
<}
} {
if {[S string 0 0 {} {} eq \372\372\372\372]} {>

emit {MIT scheme (library?)}
<}
} {
if {[S search 0 0 {} 1 eq <TeXmacs|]} {>

emit {TeXmacs document text}
mime text/texmacs

<}
} {
if {[S string 0 0 {} {} eq \#SUNPC_CONFIG]} {>

emit {SunPC 4.0 Properties Values}
<}
} {
if {[S string 0 0 {} {} eq snoop]} {>

emit {Snoop capture file}

if {[N belong 8 0 0 {} {} > 0]} {>

emit {- version %d}
<}

switch -- [Nv belong 12 0 {} {}] 0 {>;emit {(IEEE 802.3)};<} 1 {>;emit {(IEEE 802.4)};<} 2 {>;emit {(IEEE 802.5)};<} 3 {>;emit {(IEEE 802.6)};<} 4 {>;emit (Ethernet);<} 5 {>;emit (HDLC);<} 6 {>;emit {(Character synchronous)};<} 7 {>;emit {(IBM channel-to-channel adapter)};<} 8 {>;emit (FDDI);<} 9 {>;emit (Other);<} 10 {>;emit {(type %d)};<} 11 {>;emit {(type %d)};<} 12 {>;emit {(type %d)};<} 13 {>;emit {(type %d)};<} 14 {>;emit {(type %d)};<} 15 {>;emit {(type %d)};<} 16 {>;emit {(Fibre Channel)};<} 17 {>;emit (ATM);<} 18 {>;emit {(ATM Classical IP)};<} 19 {>;emit {(type %d)};<} 20 {>;emit {(type %d)};<} 21 {>;emit {(type %d)};<} 22 {>;emit {(type %d)};<} 23 {>;emit {(type %d)};<} 24 {>;emit {(type %d)};<} 25 {>;emit {(type %d)};<} 26 {>;emit {(IP over Infiniband)};<} 
<

if {[N belong 12 0 0 {} {} > 26]} {>

emit {(type %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq Cobalt\ Networks\ Inc.\nFirmware\ v]} {>

emit {Paged COBALT boot rom}

if {[S string 38 0 {} {} x {}]} {>

emit V%.4s
<}

<}
} {
if {[S string 0 0 {} {} eq CRfs]} {>

emit {COBALT boot rom data (Flat boot rom or file system)}
<}
} {
if {[S search 0 0 t 1 eq FiLeStArTfIlEsTaRt]} {>

emit {binscii (apple ][) text}
<}
} {
if {[S string 0 0 {} {} eq \x0aGL]} {>

emit {Binary II (apple ][) data}
<}
} {
if {[S string 0 0 {} {} eq \x76\xff]} {>

emit {Squeezed (apple ][) data}
<}
} {
if {[S string 0 0 {} {} eq NuFile]} {>

emit {NuFile archive (apple ][) data}
<}
} {
if {[S string 0 0 {} {} eq N\xf5F\xe9l\xe5]} {>

emit {NuFile archive (apple ][) data}
<}
} {
if {[S string 0 0 {} {} eq 2IMG]} {>

emit {Apple ][ 2IMG Disk Image}

if {[S string 4 0 {} {} eq XGS!]} {>

emit {\b, XGS}
<}

if {[S string 4 0 {} {} eq CTKG]} {>

emit {\b, Catakig}
<}

if {[S string 4 0 {} {} eq ShIm]} {>

emit {\b, Sheppy's ImageMaker}
<}

if {[S string 4 0 {} {} eq WOOF]} {>

emit {\b, Sweet 16}
<}

if {[S string 4 0 {} {} eq B2TR]} {>

emit {\b, Bernie ][ the Rescue}
<}

if {[S string 4 0 {} {} ne nfc]} {>

emit {\b, ASIMOV2}
<}

if {[S string 4 0 {} {} x {}]} {>

emit {\b, Unknown Format}
<}

switch -- [Nv byte 12 0 {} {}] 0 {>;emit {\b, DOS 3.3 sector order}

	if {[N byte 16 0 0 {} {} == 0]} {>

	emit {\b, Volume 254}
<}

	if {[N byte 16 0 0 & 127 x {}]} {>

	emit {\b, Volume %u}
<}
;<} 1 {>;emit {\b, ProDOS sector order}

	if {[N short 20 0 0 {} {} x {}]} {>

	emit {\b, %u Blocks}
<}
;<} 2 {>;emit {\b, NIB data};<} 
<

<}
} {
if {[S string 0 0 {} {} eq package0]} {>

emit {Newton package, NOS 1.x,}

if {[N belong 12 0 0 {} {} & 2147483648]} {>

emit AutoRemove,
<}

if {[N belong 12 0 0 {} {} & 1073741824]} {>

emit CopyProtect,
<}

if {[N belong 12 0 0 {} {} & 268435456]} {>

emit NoCompression,
<}

if {[N belong 12 0 0 {} {} & 67108864]} {>

emit Relocation,
<}

if {[N belong 12 0 0 {} {} & 33554432]} {>

emit UseFasterCompression,
<}

if {[N belong 16 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq package1]} {>

emit {Newton package, NOS 2.x,}

if {[N belong 12 0 0 {} {} & 2147483648]} {>

emit AutoRemove,
<}

if {[N belong 12 0 0 {} {} & 1073741824]} {>

emit CopyProtect,
<}

if {[N belong 12 0 0 {} {} & 268435456]} {>

emit NoCompression,
<}

if {[N belong 12 0 0 {} {} & 67108864]} {>

emit Relocation,
<}

if {[N belong 12 0 0 {} {} & 33554432]} {>

emit UseFasterCompression,
<}

if {[N belong 16 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq package4]} {>

emit {Newton package,}

switch -- [Nv byte 8 0 {} {}] 8 {>;emit {NOS 1.x,};<} 9 {>;emit {NOS 2.x,};<} 
<

if {[N belong 12 0 0 {} {} & 2147483648]} {>

emit AutoRemove,
<}

if {[N belong 12 0 0 {} {} & 1073741824]} {>

emit CopyProtect,
<}

if {[N belong 12 0 0 {} {} & 268435456]} {>

emit NoCompression,
<}

<}
} {
if {[S string 4 0 {} {} eq O]} {>

if {[N bequad 84 0 0 {} {} ^ 71494644084571648]} {>

	if {[S regex 5 0 s {} eq \[=.<>|!^\x8a\]\{79\}]} {>

	emit {AppleWorks Word Processor}

		if {[N byte 183 0 0 {} {} == 30]} {>

		emit 3.0
<}

		if {[N byte 183 0 0 {} {} != 30]} {>

			if {[N byte 183 0 0 {} {} != 0]} {>

			emit 0x%x
<}

<}

		if {[S string 5 0 {} {} x {}]} {>

		emit {\b, tabstop ruler "%6.6s"}
<}

		if {[N byte 85 0 0 & 1 > 0]} {>

		emit {\b, zoomed}
<}

		if {[N byte 90 0 0 & 1 > 0]} {>

		emit {\b, paginated}
<}

		if {[N byte 92 0 0 & 1 > 0]} {>

		emit {\b, with mail merge}
<}

		if {[N byte 91 0 0 {} {} > 0]} {>

			if {[N byte 91 0 0 {} {} x {}]} {>

			emit {\b, %d/10 inch left margin}
<}

<}

	mime application/x-appleworks3

	ext awp

<}

<}

<}
} {
if {[N belong 0 0 0 & 16711935 == 524288]} {>

if {[N leshort 2 0 0 {} {} > 0]} {>

emit {Applesoft BASIC program data, first line number %d}
<}

<}
} {
switch -- [Nv belong 0 0 & 4278255615] 1677774848 {>;emit {Apple Mechanic font};<} 1442840576 {>;
if {[S regex 1 0 s {} eq ^\[0-9\]]} {>

emit {ps database}

	if {[S string 1 0 {} {} > \0]} {>

	emit {version %s}
<}

	if {[S string 4 0 {} {} > \0]} {>

	emit {from kernel %s}
<}

<}
;<} 
<
} {
if {[S string 0 0 {} {} eq bplist00]} {>

emit {Apple binary property list}
<}
} {
if {[S string 0 0 {} {} eq bplist]} {>

if {[N byte 6 0 0 {} {} x {}]} {>

emit {\bCoreFoundation binary property list data, version 0x%c}

	if {[N byte 7 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

<}

if {[S string 6 0 {} {} eq 00]} {>

emit {\b}

	switch -- [Nv byte 8 0 & 240] 0 {>;emit {\b}

		switch -- [Nv byte 8 0 & 15] 0 {>;emit {\b, root type: null};<} 8 {>;emit {\b, root type: false boolean};<} 9 {>;emit {\b, root type: true boolean};<} 
<
;<} 16 {>;emit {\b, root type: integer};<} 32 {>;emit {\b, root type: real};<} 48 {>;emit {\b, root type: date};<} 64 {>;emit {\b, root type: data};<} 80 {>;emit {\b, root type: ascii string};<} 96 {>;emit {\b, root type: unicode string};<} -128 {>;emit {\b, root type: uid (CORRUPT)};<} -96 {>;emit {\b, root type: array};<} -48 {>;emit {\b, root type: dictionary};<} 
<

<}

<}
} {
if {[S string 2 0 {} {} eq typedstream]} {>

emit {NeXT/Apple typedstream data, big endian}

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N byte 0 0 0 {} {} < 5]} {>

emit {\b}

	if {[N byte 13 0 0 {} {} == 129]} {>

	emit {\b}

		if {[N beshort 14 0 0 {} {} x {}]} {>

		emit {\b, system %d}
<}

<}

<}

<}
} {
if {[S string 2 0 {} {} eq streamtyped]} {>

emit {NeXT/Apple typedstream data, little endian}

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N byte 0 0 0 {} {} < 5]} {>

emit {\b}

	if {[N byte 13 0 0 {} {} == 129]} {>

	emit {\b}

		if {[N leshort 14 0 0 {} {} x {}]} {>

		emit {\b, system %d}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq caff]} {>

emit {CoreAudio Format audio file}

if {[N beshort 4 0 0 {} {} < 10]} {>

emit {version %d}
<}

if {[N beshort 6 0 0 {} {} x {}]} {>

<}

<}
} {
if {[S string 0 0 {} {} eq kych]} {>

emit {Mac OS X Keychain File}
<}
} {
if {[S string 4 0 {} {} eq innotek\ VirtualBox\ Disk\ Image]} {>

emit %s
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\1Bud1\0]} {>

emit {Apple Desktop Services Store}
<}
} {
if {[S string 0 0 {} {} eq \000\000\001\000]} {>

if {[N leshort 4 0 0 {} {} == 0]} {>

	if {[N lelong 16 0 0 {} {} == 0]} {>

	emit {Apple HFS/HFS+ resource fork}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq NEKO]} {>

emit {NekoVM bytecode}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {(%d global symbols,}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {%d global fields,}
<}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {%d bytecode ops)}
mime application/x-nekovm-bytecode

<}

<}
} {
if {[S search 0 0 w 1 eq \#\040xmcd]} {>

emit {CDDB(tm) format CD text data}
<}
} {
if {[S string 0 0 {} {} eq ZyXEL\002]} {>

emit {ZyXEL voice data}

if {[N byte 10 0 0 {} {} == 0]} {>

emit {- CELP encoding}
<}

switch -- [Nv byte 10 0 & 11] 1 {>;emit {- ADPCM2 encoding};<} 2 {>;emit {- ADPCM3 encoding};<} 3 {>;emit {- ADPCM4 encoding};<} 8 {>;emit {- New ADPCM3 encoding};<} 
<

if {[N byte 10 0 0 & 4 == 4]} {>

emit {with resync}
<}

<}
} {
if {[S search 0 0 {} 1024 eq eval\ \"exec\ perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ \"exec\ /bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ \"exec\ /usr/bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ \"exec\ /usr/local/bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ 'exec\ perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ 'exec\ /bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ 'exec\ /usr/bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ 'exec\ /usr/local/bin/perl]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq eval\ '(exit\ \$?0)'\ &&\ eval\ 'exec]} {>

emit {Perl script text}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq \#!/usr/bin/env\ perl]} {>

emit {Perl script text executable}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq \#!\ /usr/bin/env\ perl]} {>

emit {Perl script text executable}
mime text/x-perl

<}
} {
if {[S search 0 0 {} 1024 eq \#!]} {>

if {[S regex 0 0 {} {} eq ^\#!.*/bin/perl(\[\[:space:\]\].*)*\$]} {>

emit {Perl script text executable}
mime text/x-perl

<}

<}
} {
if {[S search 0 0 {} 1024 eq package]} {>

if {[S regex 0 0 {} {} eq ^package\[\ \t\]+\[0-9A-Za-z_:\]+\ *\;]} {>

emit {Perl5 module source text}
<}

<}
} {
if {[S search 0 0 {} 1024 ne p]} {>

if {[S regex 0 0 {} {} eq ^package\[\ \t\]+\[0-9A-Za-z_:\]+\ *\;]} {>

	if {[S regex 0 0 {} {} eq ^1\ *\;|^(use|sub|my)\ .*\[(\;\{=\]]} {>

	emit {Perl5 module source text}
<}

<}

<}
} {
if {[S search 0 0 W 1024 eq =pod\n]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq \n=pod\n]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq =head1\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq \n=head1\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq =head2\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq \n=head2\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq =encoding\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S search 0 0 W 1024 eq \n=encoding\ ]} {>

emit {Perl POD document text}
<}
} {
if {[S string 0 0 {} {} eq perl-store]} {>

emit {perl Storable (v0.6) data}

if {[N byte 4 0 0 {} {} > 0]} {>

emit {(net-order %d)}

	if {[N byte 4 0 0 {} {} & 1]} {>

	emit (network-ordered)
<}

	switch -- [Nv byte 4 0 {} {}] 3 {>;emit {(major 1)};<} 2 {>;emit {(major 1)};<} 
<

<}

<}
} {
if {[S string 0 0 {} {} eq pst0]} {>

emit {perl Storable (v0.7) data}

if {[N byte 4 0 0 {} {} > 0]} {>

	if {[N byte 4 0 0 {} {} & 1]} {>

	emit (network-ordered)
<}

	switch -- [Nv byte 4 0 {} {}] 5 {>;emit {(major 2)};<} 4 {>;emit {(major 2)};<} 
<

	if {[N byte 5 0 0 {} {} > 0]} {>

	emit {(minor %d)}
<}

<}

<}
} {
switch -- [Nv lequad 0 0 {} {}] -6518119229588284681 {>;emit {Hash::SharedMem master file, little-endian}

if {[N lequad 8 0 0 {} {} < 16777216]} {>

	if {[N byte 8 0 0 {} {} > 2]} {>

	emit {\b, line size 2^%d byte}
<}

	if {[N byte 9 0 0 {} {} > 2]} {>

	emit {\b, page size 2^%d byte}
<}

	if {[N byte 10 0 0 {} {} & 1]} {>

		if {[N byte 10 0 0 {} {} > 1]} {>

		emit {\b, max fanout %d}
<}

<}

<}
;<} -4137723088997562430 {>;emit {Hash::SharedMem data file, little-endian}

if {[N lequad 8 0 0 {} {} < 16777216]} {>

	if {[N byte 8 0 0 {} {} > 2]} {>

	emit {\b, line size 2^%d byte}
<}

	if {[N byte 9 0 0 {} {} > 2]} {>

	emit {\b, page size 2^%d byte}
<}

	if {[N byte 10 0 0 {} {} & 1]} {>

		if {[N byte 10 0 0 {} {} > 1]} {>

		emit {\b, max fanout %d}
<}

<}

<}
;<} 16325548649369164 {>;emit {MS Advisor help file};<} 
<
} {
if {[S string 0 0 t {} eq \#!\ /]} {>

emit a

if {[S string 3 0 {} {} > \0]} {>

emit {%s script text executable}
<}

<}
} {
if {[S string 0 0 b {} eq \#!\ /]} {>

emit a

if {[S string 3 0 {} {} > \0]} {>

emit {%s script executable (binary data)}
<}

<}
} {
if {[S string 0 0 t {} eq \#!\t/]} {>

emit a

if {[S string 3 0 {} {} > \0]} {>

emit {%s script text executable}
<}

<}
} {
if {[S string 0 0 b {} eq \#!\t/]} {>

emit a

if {[S string 3 0 {} {} > \0]} {>

emit {%s script executable (binary data)}
<}

<}
} {
if {[S string 0 0 t {} eq \#!/]} {>

emit a

if {[S string 2 0 {} {} > \0]} {>

emit {%s script text executable}
<}

<}
} {
if {[S string 0 0 b {} eq \#!/]} {>

emit a

if {[S string 2 0 {} {} > \0]} {>

emit {%s script executable (binary data)}
<}

<}
} {
if {[S string 0 0 t {} eq \#!\ ]} {>

emit {script text executable}

if {[S string 3 0 {} {} > \0]} {>

emit {for %s}
<}

<}
} {
if {[S string 0 0 b {} eq \#!\ ]} {>

emit {script executable}

if {[S string 3 0 {} {} > \0]} {>

emit {for %s (binary data)}
<}

<}
} {
if {[S string 0 0 t {} eq \#!/usr/bin/env]} {>

emit a

if {[S string 15 0 t {} > \0]} {>

emit {%s script text executable}
<}

<}
} {
if {[S string 0 0 b {} eq \#!/usr/bin/env]} {>

emit a

if {[S string 15 0 b {} > \0]} {>

emit {%s script executable (binary data)}
<}

<}
} {
if {[S string 0 0 t {} eq \#!\ /usr/bin/env]} {>

emit a

if {[S string 16 0 t {} > \0]} {>

emit {%s script text executable}
<}

<}
} {
if {[S string 0 0 b {} eq \#!\ /usr/bin/env]} {>

emit a

if {[S string 16 0 b {} > \0]} {>

emit {%s script executable (binary data)}
<}

<}
} {
if {[S string 0 0 {} {} eq XPCOM\nTypeLib\r\n\032]} {>

emit {XPConnect Typelib}

if {[N byte 16 0 0 {} {} x {}]} {>

emit {version %d}

	if {[N byte 17 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq **TI80**]} {>

emit {TI-80 Graphing Calculator File.}
<}
} {
if {[S string 0 0 {} {} eq **TI81**]} {>

emit {TI-81 Graphing Calculator File.}
<}
} {
if {[S string 0 0 {} {} eq **TI73**]} {>

emit {TI-73 Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit {(real number)};<} 1 {>;emit (list);<} 2 {>;emit (matrix);<} 3 {>;emit (equation);<} 4 {>;emit (string);<} 5 {>;emit (program);<} 6 {>;emit {(assembly program)};<} 7 {>;emit (picture);<} 8 {>;emit (gdb);<} 12 {>;emit {(complex number)};<} 15 {>;emit {(window settings)};<} 16 {>;emit (zoom);<} 17 {>;emit {(table setup)};<} 19 {>;emit (backup);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI82**]} {>

emit {TI-82 Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit (real);<} 1 {>;emit (list);<} 2 {>;emit (matrix);<} 3 {>;emit (Y-variable);<} 5 {>;emit (program);<} 6 {>;emit {(protected prgm)};<} 7 {>;emit (picture);<} 8 {>;emit (gdb);<} 11 {>;emit {(window settings)};<} 12 {>;emit {(window settings)};<} 13 {>;emit {(table setup)};<} 14 {>;emit (screenshot);<} 15 {>;emit (backup);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI83**]} {>

emit {TI-83 Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit (real);<} 1 {>;emit (list);<} 2 {>;emit (matrix);<} 3 {>;emit (Y-variable);<} 4 {>;emit (string);<} 5 {>;emit (program);<} 6 {>;emit {(protected prgm)};<} 7 {>;emit (picture);<} 8 {>;emit (gdb);<} 11 {>;emit {(window settings)};<} 12 {>;emit {(window settings)};<} 13 {>;emit {(table setup)};<} 14 {>;emit (screenshot);<} 19 {>;emit (backup);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI83F*]} {>

emit {TI-83+ Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit {(real number)};<} 1 {>;emit (list);<} 2 {>;emit (matrix);<} 3 {>;emit (equation);<} 4 {>;emit (string);<} 5 {>;emit (program);<} 6 {>;emit {(assembly program)};<} 7 {>;emit (picture);<} 8 {>;emit (gdb);<} 12 {>;emit {(complex number)};<} 15 {>;emit {(window settings)};<} 16 {>;emit (zoom);<} 17 {>;emit {(table setup)};<} 19 {>;emit (backup);<} 21 {>;emit {(application variable)};<} 23 {>;emit {(group of variable)};<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI85**]} {>

emit {TI-85 Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit {(real number)};<} 1 {>;emit {(complex number)};<} 2 {>;emit {(real vector)};<} 3 {>;emit {(complex vector)};<} 4 {>;emit {(real list)};<} 5 {>;emit {(complex list)};<} 6 {>;emit {(real matrix)};<} 7 {>;emit {(complex matrix)};<} 8 {>;emit {(real constant)};<} 9 {>;emit {(complex constant)};<} 10 {>;emit (equation);<} 12 {>;emit (string);<} 13 {>;emit {(function GDB)};<} 14 {>;emit {(polar GDB)};<} 15 {>;emit {(parametric GDB)};<} 16 {>;emit {(diffeq GDB)};<} 17 {>;emit (picture);<} 18 {>;emit (program);<} 19 {>;emit (range);<} 23 {>;emit {(window settings)};<} 24 {>;emit {(window settings)};<} 25 {>;emit {(window settings)};<} 26 {>;emit {(window settings)};<} 27 {>;emit (zoom);<} 29 {>;emit (backup);<} 30 {>;emit (unknown);<} 42 {>;emit (equation);<} 
<

if {[S string 50 0 {} {} eq ZS4]} {>

emit {- ZShell Version 4 File.}
<}

if {[S string 50 0 {} {} eq ZS3]} {>

emit {- ZShell Version 3 File.}
<}

<}
} {
if {[S string 0 0 {} {} eq **TI86**]} {>

emit {TI-86 Graphing Calculator}

switch -- [Nv byte 59 0 {} {}] 0 {>;emit {(real number)};<} 1 {>;emit {(complex number)};<} 2 {>;emit {(real vector)};<} 3 {>;emit {(complex vector)};<} 4 {>;emit {(real list)};<} 5 {>;emit {(complex list)};<} 6 {>;emit {(real matrix)};<} 7 {>;emit {(complex matrix)};<} 8 {>;emit {(real constant)};<} 9 {>;emit {(complex constant)};<} 10 {>;emit (equation);<} 12 {>;emit (string);<} 13 {>;emit {(function GDB)};<} 14 {>;emit {(polar GDB)};<} 15 {>;emit {(parametric GDB)};<} 16 {>;emit {(diffeq GDB)};<} 17 {>;emit (picture);<} 18 {>;emit (program);<} 19 {>;emit (range);<} 23 {>;emit {(window settings)};<} 24 {>;emit {(window settings)};<} 25 {>;emit {(window settings)};<} 26 {>;emit {(window settings)};<} 27 {>;emit (zoom);<} 29 {>;emit (backup);<} 30 {>;emit (unknown);<} 42 {>;emit (equation);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI89**]} {>

emit {TI-89 Graphing Calculator}

switch -- [Nv byte 72 0 {} {}] 0 {>;emit (expression);<} 4 {>;emit (list);<} 6 {>;emit (matrix);<} 10 {>;emit (data);<} 11 {>;emit (text);<} 12 {>;emit (string);<} 13 {>;emit {(graphic data base)};<} 14 {>;emit (figure);<} 16 {>;emit (picture);<} 18 {>;emit (program);<} 19 {>;emit (function);<} 20 {>;emit (macro);<} 28 {>;emit (zipped);<} 33 {>;emit (assembler);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI92**]} {>

emit {TI-92 Graphing Calculator}

switch -- [Nv byte 72 0 {} {}] 0 {>;emit (expression);<} 4 {>;emit (list);<} 6 {>;emit (matrix);<} 10 {>;emit (data);<} 11 {>;emit (text);<} 12 {>;emit (string);<} 13 {>;emit {(graphic data base)};<} 14 {>;emit (figure);<} 16 {>;emit (picture);<} 18 {>;emit (program);<} 19 {>;emit (function);<} 20 {>;emit (macro);<} 29 {>;emit (backup);<} 
<

<}
} {
if {[S string 0 0 {} {} eq **TI92P*]} {>

emit {TI-92+/V200 Graphing Calculator}

switch -- [Nv byte 72 0 {} {}] 0 {>;emit (expression);<} 4 {>;emit (list);<} 6 {>;emit (matrix);<} 10 {>;emit (data);<} 11 {>;emit (text);<} 12 {>;emit (string);<} 13 {>;emit {(graphic data base)};<} 14 {>;emit (figure);<} 16 {>;emit (picture);<} 18 {>;emit (program);<} 19 {>;emit (function);<} 20 {>;emit (macro);<} 28 {>;emit (zipped);<} 33 {>;emit (assembler);<} 
<

<}
} {
if {[S string 22 0 {} {} eq Advanced]} {>

emit {TI-XX Graphing Calculator (FLASH)}
<}
} {
if {[S string 0 0 {} {} eq **TIFL**]} {>

emit {TI-XX Graphing Calculator (FLASH)}

if {[N byte 8 0 0 {} {} > 0]} {>

emit {- Revision %d}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b.%d,}
<}

<}

if {[N byte 12 0 0 {} {} > 0]} {>

emit {Revision date %02x}

	if {[N byte 13 0 0 {} {} x {}]} {>

	emit {\b/%02x}
<}

	if {[N beshort 14 0 0 {} {} x {}]} {>

	emit {\b/%04x,}
<}

<}

if {[S string 17 0 {} {} > /0]} {>

emit {name: '%s',}
<}

switch -- [Nv byte 48 0 {} {}] 116 {>;emit {device: TI-73,};<} 115 {>;emit {device: TI-83+,};<} -104 {>;emit {device: TI-89,};<} -120 {>;emit {device: TI-92+,};<} 
<

switch -- [Nv byte 49 0 {} {}] 35 {>;emit {type: OS upgrade,};<} 36 {>;emit {type: application,};<} 37 {>;emit {type: certificate,};<} 62 {>;emit {type: license,};<} 
<

if {[N lelong 74 0 0 {} {} > 0]} {>

emit {size: %d bytes}
<}

<}
} {
if {[S string 0 0 {} {} eq VTI]} {>

emit {Virtual TI skin}

if {[S string 3 0 {} {} eq v]} {>

emit {- Version}

	if {[N byte 4 0 0 {} {} > 0]} {>

	emit {\b %c}
<}

	if {[N byte 6 0 0 {} {} x {}]} {>

	emit {\b.%c}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq TiEmu]} {>

emit {TiEmu skin}

if {[S string 6 0 {} {} eq v]} {>

emit {- Version}

	if {[N byte 7 0 0 {} {} > 0]} {>

	emit {\b %c}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b.%c}
<}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \xCF\xAD\x12\xFE]} {>

emit {MS Outlook Express DBX file}

switch -- [Nv byte 4 0 {} {}] -59 {>;emit {\b, message database};<} -58 {>;emit {\b, folder database};<} -57 {>;emit {\b, account information};<} 48 {>;emit {\b, offline database};<} 
<

<}
} {
if {[S string 0 0 {} {} eq PAGE]} {>

if {[S string 4 0 {} {} eq DUMP]} {>

emit {MS Windows 32bit crash dump}

	switch -- [Nv byte 92 0 {} {}] 0 {>;emit {\b, no PAE};<} 1 {>;emit {\b, PAE};<} 
<

	switch -- [Nv lelong 3976 0 {} {}] 1 {>;emit {\b, full dump};<} 2 {>;emit {\b, kernel dump};<} 3 {>;emit {\b, small dump};<} 
<

	if {[N lelong 104 0 0 {} {} x {}]} {>

	emit {\b, %d pages}
<}

<}

if {[S string 4 0 {} {} eq DU64]} {>

emit {MS Windows 64bit crash dump}

	switch -- [Nv lelong 3992 0 {} {}] 1 {>;emit {\b, full dump};<} 2 {>;emit {\b, kernel dump};<} 3 {>;emit {\b, small dump};<} 
<

	if {[N lequad 144 0 0 {} {} x {}]} {>

	emit {\b, %lld pages}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq ElfFile\0]} {>

emit {MS Windows Vista Event Log}

if {[N leshort 42 0 0 {} {} x {}]} {>

emit {\b, %d chunks}

	if {[N lelong 16 0 0 {} {} x {}]} {>

	emit {\b (no. %d in use)}
<}

<}

if {[N lelong 24 0 0 {} {} > 1]} {>

emit {\b, next record no. %d}
<}

if {[N lelong 24 0 0 {} {} == 1]} {>

emit {\b, empty}
<}

if {[N lelong 120 0 0 {} {} & 1]} {>

emit {\b, DIRTY}
<}

if {[N lelong 120 0 0 {} {} & 2]} {>

emit {\b, FULL}
<}

<}
} {
if {[S string 0 0 {} {} eq \120\115\103\103]} {>

emit {MS Windows 3.1 group files}
<}
} {
if {[Sx regex 0 0 {} {} eq ^(:|\;)]} {>

if {[Sx search 0 0 {} 45 eq :Base]} {>
U 72 cnt-name

<}

if {[S search 0 0 {} 45 eq :Base]} {>

<}

if {[Sx default 0 0 {} {} x {}]} {>

	if {[Sx search 0 0 {} 45 eq :Title]} {>
U 72 cnt-name

<}

<}

<}
} {
if {[S string 0 0 {} {} eq tfMR]} {>

emit {MS Windows help Full Text Search index}

if {[S string 16 0 {} {} > \0]} {>

emit {for "%s"}
<}

mime application/x-winhelp-fts

ext fts

<}
} {
if {[S string 0 0 {} {} eq HyperTerminal\ ]} {>

if {[S string 15 0 {} {} eq 1.0\ --\ HyperTerminal\ data\ file]} {>

emit {MS Windows HyperTerminal profile}
<}

<}
} {
if {[S string 0 0 {} {} eq \114\0\0\0\001\024\002\0\0\0\0\0\300\0\0\0\0\0\0\106]} {>

emit {MS Windows shortcut}

if {[N lelong 20 0 0 & 1 == 1]} {>

emit {\b, Item id list present}
<}

if {[N lelong 20 0 0 & 2 == 2]} {>

emit {\b, Points to a file or directory}
<}

if {[N lelong 20 0 0 & 4 == 4]} {>

emit {\b, Has Description string}
<}

if {[N lelong 20 0 0 & 8 == 8]} {>

emit {\b, Has Relative path}
<}

if {[N lelong 20 0 0 & 16 == 16]} {>

emit {\b, Has Working directory}
<}

if {[N lelong 20 0 0 & 32 == 32]} {>

emit {\b, Has command line arguments}
<}

if {[N lelong 20 0 0 & 64 == 64]} {>

emit {\b, Icon}

	if {[N lelong 56 0 0 {} {} x {}]} {>

	emit {\b number=%d}
<}

<}

if {[N lelong 24 0 0 & 1 == 1]} {>

emit {\b, Read-Only}
<}

if {[N lelong 24 0 0 & 2 == 2]} {>

emit {\b, Hidden}
<}

if {[N lelong 24 0 0 & 4 == 4]} {>

emit {\b, System}
<}

if {[N lelong 24 0 0 & 8 == 8]} {>

emit {\b, Volume Label}
<}

if {[N lelong 24 0 0 & 16 == 16]} {>

emit {\b, Directory}
<}

if {[N lelong 24 0 0 & 32 == 32]} {>

emit {\b, Archive}
<}

if {[N lelong 24 0 0 & 64 == 64]} {>

emit {\b, Encrypted}
<}

if {[N lelong 24 0 0 & 128 == 128]} {>

emit {\b, Normal}
<}

if {[N lelong 24 0 0 & 256 == 256]} {>

emit {\b, Temporary}
<}

if {[N lelong 24 0 0 & 512 == 512]} {>

emit {\b, Sparse}
<}

if {[N lelong 24 0 0 & 1024 == 1024]} {>

emit {\b, Reparse point}
<}

if {[N lelong 24 0 0 & 2048 == 2048]} {>

emit {\b, Compressed}
<}

if {[N lelong 24 0 0 & 4096 == 4096]} {>

emit {\b, Offline}
<}

if {[N leqwdate 28 0 0 {} {} x {}]} {>

emit {\b, ctime=%s}
<}

if {[N leqwdate 36 0 0 {} {} x {}]} {>

emit {\b, mtime=%s}
<}

if {[N leqwdate 44 0 0 {} {} x {}]} {>

emit {\b, atime=%s}
<}

if {[N lelong 52 0 0 {} {} x {}]} {>

emit {\b, length=%u, window=}
<}

if {[N lelong 60 0 0 & 1 == 1]} {>

emit {\bhide}
<}

if {[N lelong 60 0 0 & 2 == 2]} {>

emit {\bnormal}
<}

if {[N lelong 60 0 0 & 4 == 4]} {>

emit {\bshowminimized}
<}

if {[N lelong 60 0 0 & 8 == 8]} {>

emit {\bshowmaximized}
<}

if {[N lelong 60 0 0 & 16 == 16]} {>

emit {\bshownoactivate}
<}

if {[N lelong 60 0 0 & 32 == 32]} {>

emit {\bminimize}
<}

if {[N lelong 60 0 0 & 64 == 64]} {>

emit {\bshowminnoactive}
<}

if {[N lelong 60 0 0 & 128 == 128]} {>

emit {\bshowna}
<}

if {[N lelong 60 0 0 & 256 == 256]} {>

emit {\brestore}
<}

if {[N lelong 60 0 0 & 512 == 512]} {>

emit {\bshowdefault}
<}

<}
} {
if {[S string 0 0 {} {} eq \164\146\115\122\012\000\000\000\001\000\000\000]} {>

emit {MS Windows help cache}
<}
} {
if {[S string 0 0 {} {} eq Client\ UrlCache\ MMF]} {>

emit {Internet Explorer cache file}

if {[S string 20 0 {} {} > \0]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq regf]} {>

emit {MS Windows registry file, NT/2000 or above}
<}
} {
if {[S string 0 0 {} {} eq CREG]} {>

emit {MS Windows 95/98/ME registry file}
<}
} {
if {[S string 0 0 {} {} eq SHCC3]} {>

emit {MS Windows 3.1 registry file}
<}
} {
if {[S string 0 0 {} {} eq REGEDIT4\r\n\r\n]} {>

emit {Windows Registry text (Win95 or above)}
<}
} {
if {[Sx string 0 0 {} {} eq Windows\ Registry\ Editor\ ]} {>

if {[Sx string [R 0] 0 {} {} eq Version\ 5.00\r\n\r\n]} {>

emit {Windows Registry text (Win2K or above)}
<}

<}
} {
if {[Sx regex 0 0 s {} eq \\`(\\r\\n|\;|\[\[\])]} {>

if {[Sx search [R 0] 0 {} 8192 eq \[]} {>

	if {[Sx regex [R 0] 0 c {} eq ^(autorun)\]\r\n]} {>

		if {[Nx byte [R 0] 0 0 {} {} == 91]} {>

		emit {INItialization configuration}
		mime application/x-wine-extension-ini

<}

		if {[Nx byte [R 0] 0 0 {} {} != 91]} {>

		emit {Microsoft Windows Autorun file}
		mime application/x-setupscript

<}

<}

	if {[Sx regex [R 0] 0 c {} eq ^(version|strings)\]]} {>

	emit {Windows setup INFormation}
	mime application/x-setupscript

<}

	if {[Sx regex [R 0] 0 c {} eq ^(WinsockCRCList|OEMCPL)\]]} {>

	emit {Windows setup INFormation}
	mime text/inf

<}

	if {[Sx regex [R 0] 0 c {} eq ^(.ShellClassInfo|DeleteOnCopy|LocalizedFileNames)\]]} {>

	emit {Windows desktop.ini}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(don't\ load)\]]} {>

	emit {Windows CONTROL.INI}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(ndishlp\\\$|protman\\\$|NETBEUI\\\$)\]]} {>

	emit {Windows PROTOCOL.INI}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(windows|Compatibility|embedding)\]]} {>

	emit {Windows WIN.INI}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(boot|386enh|drivers)\]]} {>

	emit {Windows SYSTEM.INI}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(SafeList)\]]} {>

	emit {Windows IOS.INI}
	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(boot\x20loader)\]]} {>

	emit {Windows boot.ini}

		if {[Nx byte [R 0] 0 0 {} {} x {}]} {>

<}

	mime application/x-wine-extension-ini

<}

	if {[Sx regex [R 0] 0 c {} eq ^(menu)\]\r\n]} {>

	emit {MS-DOS CONFIG.SYS}
<}

	if {[Sx regex [R 0] 0 c {} eq ^(Paths)\]\r\n]} {>

	emit {MS-DOS MSDOS.SYS}
<}

	switch -- [Nvx bequad [R 0] 0 & 18437736737013759967] 24207144355233875 {>;
		if {[Nx bequad [R 0] 0 0 & 18437736737013759999 == 20548012607406173]} {>

		emit {Windows setup INFormation }
		mime application/x-setupscript

<}
;<} 23362783849611337 {>;
		if {[Nx bequad [R 0] 0 0 & 18437736737013759999 == 21955353131548765]} {>

		emit {Windows setup INFormation }
		mime application/x-setupscript

<}
;<} 
<

	if {[Sx default [R 0] 0 {} {} x {}]} {>

		if {[Sx search [R 0] 0 {} 8192 eq \[]} {>

			if {[Sx string [R 0] 0 c {} eq version]} {>

			emit {Windows setup INFormation }
			mime application/x-setupscript

<}

			if {[Nx bequad [R 0] 0 0 & 18437736737013759967 == 24207144355233875]} {>

				if {[Nx bequad [R 0] 0 0 & 18437736737013759999 == 20548012607406173]} {>

				emit {Windows setup INFormation }
				mime application/x-setupscript

<}

<}

<}

<}

<}

<}
} {
if {[N leshort 0 0 0 & 65278 == 0]} {>

if {[N lelong 4 0 0 & 4244635136 == 0]} {>

	if {[N lelong 68 0 0 {} {} > 87]} {>

		if {[N belong [I 68 lelong 0 - 0 1] 0 0 & 4292920601 == 4194328]} {>

		emit {Windows Precompiled iNF}

			if {[N leshort 0 0 0 {} {} != 257]} {>

				if {[N byte 1 0 0 {} {} x {}]} {>

				emit {\b, version %u}
<}

				if {[N byte 0 0 0 {} {} x {}]} {>

				emit {\b.%u}
<}

<}

			if {[N leshort 2 0 0 {} {} != 2]} {>

			emit {\b, InfStyle %u}
<}

			switch -- [Nv lelong 4 0 & 1] 1 {>;emit {\b, unicoded};<} 1 {>;
				if {[S lestring16 [I 20 lelong 0 0 0 0] 0 {} {} x {}]} {>

				emit {"%s"}
<}
;<} 
<

			if {[N lelong 4 0 0 & 32 == 32]} {>

			emit {\b, digitally signed}
<}

			if {[N lelong 20 0 0 {} {} x {}]} {>

			emit {\b, at 0x%x}
<}

			if {[N lelong 4 0 0 & 1 != 1]} {>

				if {[S string [I 20 lelong 0 0 0 0] 0 {} {} x {}]} {>

				emit {"%s"}
<}

<}

			if {[N lelong 68 0 0 {} {} > 87]} {>

				if {[N lelong 4 0 0 & 1 == 1]} {>

					if {[N bequad [I 68 lelong 0 0 0 0] 0 0 {} {} == 4827922573759108864]} {>

<}

					if {[N bequad [I 68 lelong 0 0 0 0] 0 0 {} {} != 4827922573759108864]} {>

						if {[S lestring16 [I 68 lelong 0 0 0 0] 0 {} {} x {}]} {>

						emit {\b, WinDirPath "%s"}
<}

<}

<}

				if {[N lelong 4 0 0 & 1 != 1]} {>

					if {[S string [I 68 lelong 0 0 0 0] 0 {} {} ne C:\\WINDOWS]} {>

					emit {\b, WinDirPath "%s"}
<}

<}

<}

			if {[N lelong 72 0 0 {} {} > 0]} {>

			emit {\b,}

				if {[N lelong 4 0 0 & 1 == 1]} {>

					if {[S lestring16 [I 72 lelong 0 0 0 0] 0 {} {} x {}]} {>

					emit {OsLoaderPath "%s"}
<}

<}

				if {[N lelong 4 0 0 & 1 != 1]} {>

					if {[S string [I 72 lelong 0 0 0 0] 0 {} {} x {}]} {>

					emit {OsLoaderPath "%s"}
<}

<}

<}

			if {[N leshort 78 0 0 {} {} != 1031]} {>

			emit {\b, LanguageId %x}
<}

			if {[N lelong 80 0 0 {} {} > 0]} {>

			emit {\b,}

				if {[N lelong 4 0 0 & 1 == 1]} {>

					if {[S lestring16 [I 80 lelong 0 0 0 0] 0 {} {} x {}]} {>

					emit {SourcePath "%s"}
<}

<}

				if {[N lelong 4 0 0 & 1 != 1]} {>

					if {[S string [I 80 lelong 0 0 0 0] 0 {} {} > \0]} {>

					emit {SourcePath "%s"}
<}

<}

<}

			if {[N lelong 84 0 0 {} {} > 0]} {>

			emit {\b,}

				if {[N lelong 4 0 0 & 1 == 1]} {>

					if {[S lestring16 [I 84 lelong 0 0 0 0] 0 {} {} x {}]} {>

					emit {InfName "%s"}
<}

<}

				if {[N lelong 4 0 0 & 1 != 1]} {>

					if {[S string [I 84 lelong 0 0 0 0] 0 {} {} > \0]} {>

					emit {InfName "%s"}
<}

<}

<}

		mime application/x-pnf

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TAPE]} {>

if {[N lequad 20 0 0 {} {} == 0]} {>

	if {[N leshort 28 0 0 {} {} == 0]} {>

		if {[N lelong 36 0 0 {} {} == 0]} {>

			if {[N lelong 4 0 0 & 4294770656 == 0]} {>

			emit {Windows NTbackup archive}

				switch -- [Nv byte 10 0 {} {}] 1 {>;emit {\b NetWare};<} 13 {>;emit {\b NetWare SMS};<} 14 {>;emit {\b NT};<} 24 {>;emit {\b 3};<} 25 {>;emit {\b OS/2};<} 26 {>;emit {\b 95};<} 27 {>;emit {\b Macintosh};<} 28 {>;emit {\b UNIX};<} 
<

				if {[N lelong 4 0 0 & 4 != 0]} {>

				emit {\b, compressed}
<}

				if {[N lelong 4 0 0 & 8 != 0]} {>

				emit {\b, End Of Medium hit}
<}

				if {[N lelong 4 0 0 & 131072 == 0]} {>

					if {[N lelong 4 0 0 & 65536 != 0]} {>

					emit {\b, with catalog}
<}

<}

				if {[N lelong 4 0 0 & 131072 != 0]} {>

				emit {\b, with file catalog}
<}

				if {[N leshort 60 0 0 {} {} > 1]} {>

				emit {\b, sequence %u}
<}

				if {[N leshort 62 0 0 {} {} > 0]} {>

				emit {\b, 0x%x encrypted}
<}

				if {[N leshort 64 0 0 {} {} != 2]} {>

				emit {\b, soft size %u*512}
<}

				if {[N leshort 68 0 0 {} {} > 0]} {>

					if {[N leshort 70 0 0 {} {} > 0]} {>

						switch -- [Nv byte 48 0 {} {}] 1 {>;
							if {[S string [I 70 leshort 0 0 0 0] 0 {} {} > \0]} {>

							emit {\b, name: %s}
<}
;<} 2 {>;
							if {[S lestring16 [I 70 leshort 0 0 0 0] 0 {} {} x {}]} {>

							emit {\b, name: %s}
<}
;<} 
<

<}

<}

				if {[N leshort 72 0 0 {} {} > 0]} {>

<}

				if {[N leshort 74 0 0 {} {} > 0]} {>

					switch -- [Nv byte 48 0 {} {}] 1 {>;
						if {[S string [I 74 leshort 0 0 0 0] 0 {} {} > \0]} {>

						emit {\b, label: %s}
<}
;<} 2 {>;
						if {[S lestring16 [I 74 leshort 0 0 0 0] 0 {} {} x {}]} {>

						emit {\b, label: %s}
<}
;<} 
<

<}

				if {[N leshort 86 0 0 {} {} x {}]} {>

				emit {\b, software (0x%x)}
<}

				if {[N leshort 80 0 0 {} {} > 0]} {>

					if {[N leshort 82 0 0 {} {} > 0]} {>

						switch -- [Nv byte 48 0 {} {}] 1 {>;
							if {[S string [I 82 leshort 0 0 0 0] 0 {} {} > \0]} {>

							emit {\b: %s}
<}
;<} 2 {>;
							if {[S lestring16 [I 82 leshort 0 0 0 0] 0 {} {} x {}]} {>

							emit {\b: %s}
<}
;<} 
<

<}

<}

				if {[N leshort 84 0 0 {} {} != 1024]} {>

				emit {\b, block size %u}
<}

			ext bkf

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq RGDB]} {>

emit {CRDA wireless regulatory database file}

if {[N belong 4 0 0 {} {} == 19]} {>

emit {(Version 1)}
<}

<}
} {
if {[S string 0 0 {} {} eq BLENDER]} {>

emit Blender3D,

if {[S string 7 0 {} {} eq _]} {>

emit {saved as 32-bits}

	if {[S string 8 0 {} {} eq v]} {>

	emit {little endian}

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {with version %c.}
<}

		if {[N byte 10 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[N byte 11 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[S string 64 0 {} {} eq GLOB]} {>

		emit {\b.}

			if {[N leshort 88 0 0 {} {} x {}]} {>

			emit {\b%.4d}
<}

<}

<}

	if {[S string 8 0 {} {} eq V]} {>

	emit {big endian}

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {with version %c.}
<}

		if {[N byte 10 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[N byte 11 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[S string 64 0 {} {} eq GLOB]} {>

		emit {\b.}

			if {[N beshort 88 0 0 {} {} x {}]} {>

			emit {\b%.4d}
<}

<}

<}

<}

if {[S string 7 0 {} {} eq -]} {>

emit {saved as 64-bits}

	if {[S string 8 0 {} {} eq v]} {>

	emit {little endian}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {with version %c.}
<}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

	if {[N byte 11 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

	if {[S string 68 0 {} {} eq GLOB]} {>

	emit {\b.}

		if {[N leshort 96 0 0 {} {} x {}]} {>

		emit {\b%.4d}
<}

<}

	if {[S string 8 0 {} {} eq V]} {>

	emit {big endian}

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {with version %c.}
<}

		if {[N byte 10 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[N byte 11 0 0 {} {} x {}]} {>

		emit {\b%c}
<}

		if {[S string 68 0 {} {} eq GLOB]} {>

		emit {\b.}

			if {[N beshort 96 0 0 {} {} x {}]} {>

			emit {\b%.4d}
<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \#!BPY]} {>

emit {Blender3D BPython script}
<}
} {
if {[S string 0 0 {} {} eq SSH\ PRIVATE\ KEY]} {>

emit {OpenSSH RSA1 private key,}

if {[S string 28 0 {} {} > \0]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ OPENSSH\ PRIVATE\ KEY-----]} {>

emit {OpenSSH private key}
<}
} {
if {[S string 0 0 {} {} eq ssh-dss\ ]} {>

emit {OpenSSH DSA public key}
<}
} {
if {[S string 0 0 {} {} eq ssh-rsa\ ]} {>

emit {OpenSSH RSA public key}
<}
} {
if {[S string 0 0 {} {} eq ecdsa-sha2-nistp256]} {>

emit {OpenSSH ECDSA public key}
<}
} {
if {[S string 0 0 {} {} eq ecdsa-sha2-nistp384]} {>

emit {OpenSSH ECDSA public key}
<}
} {
if {[S string 0 0 {} {} eq ecdsa-sha2-nistp521]} {>

emit {OpenSSH ECDSA public key}
<}
} {
if {[S string 0 0 {} {} eq ssh-ed25519]} {>

emit {OpenSSH ED25519 public key}
<}
} {
if {[S string 0 0 t {} eq Content-Type:\ ]} {>

if {[S string 14 0 {} {} > \0]} {>

emit %s
<}

<}
} {
if {[S string 0 0 t {} eq Content-Type:]} {>

if {[S string 13 0 {} {} > \0]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq Interpress/Xerox]} {>

emit {Xerox InterPress data}

if {[S string 16 0 {} {} eq /]} {>

emit (version

	if {[S string 17 0 {} {} > \0]} {>

	emit %s)
<}

<}

<}
} {
if {[S string 0 0 {} {} eq bFLT]} {>

emit {BFLT executable}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N belong 4 0 0 {} {} == 4]} {>

	if {[N belong 36 0 0 & 1 == 1]} {>

	emit ram
<}

	if {[N belong 36 0 0 & 2 == 2]} {>

	emit gotpic
<}

	if {[N belong 36 0 0 & 4 == 4]} {>

	emit gzip
<}

	if {[N belong 36 0 0 & 8 == 8]} {>

	emit gzdata
<}

<}

<}
} {
if {[S search 0 0 w 1 eq \#!/bin/node]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S search 0 0 w 1 eq \#!/usr/bin/node]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S search 0 0 w 1 eq \#!/bin/nodejs]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S search 0 0 w 1 eq \#!/usr/bin/nodejs]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ node]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ nodejs]} {>

emit {Node.js script text executable}
mime application/javascript

<}
} {
if {[S string 0 0 {} {} eq S0]} {>

emit {Motorola S-Record; binary data in text format}
<}
} {
switch -- [Nv belong 0 0 & 4294967280] 1612316672 {>;emit {Atari ST M68K contiguous executable}

if {[N belong 2 0 0 {} {} x {}]} {>

emit (txt=%d,
<}

if {[N belong 6 0 0 {} {} x {}]} {>

emit dat=%d,
<}

if {[N belong 10 0 0 {} {} x {}]} {>

emit bss=%d,
<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit sym=%d)
<}
;<} 1612382208 {>;emit {Atari ST M68K non-contig executable}

if {[N belong 2 0 0 {} {} x {}]} {>

emit (txt=%d,
<}

if {[N belong 6 0 0 {} {} x {}]} {>

emit dat=%d,
<}

if {[N belong 10 0 0 {} {} x {}]} {>

emit bss=%d,
<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit sym=%d)
<}
;<} 2038050864 {>;emit {DeepFreezer archive data};<} 
<
} {
if {[S string 0 0 {} {} eq %TGIF\ ]} {>

emit {Tgif file version}

if {[S string 6 0 {} {} x {}]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq GDBM]} {>

emit {GNU dbm 2.x database}
mime application/x-gdbm

<}
} {
switch -- [Nv long 12 0 {} {}] 398689 {>;emit {Berkeley DB}

if {[N long 16 0 0 {} {} > 0]} {>

emit {(Hash, version %d, native byte-order)}
<}
;<} 340322 {>;emit {Berkeley DB}

if {[N long 16 0 0 {} {} > 0]} {>

emit {(Btree, version %d, native byte-order)}
<}
;<} 270931 {>;emit {Berkeley DB}

if {[N long 16 0 0 {} {} > 0]} {>

emit {(Queue, version %d, native byte-order)}
<}
;<} 264584 {>;emit {Berkeley DB}

if {[N long 16 0 0 {} {} > 0]} {>

emit {(Log, version %d, native byte-order)}
<}
;<} 
<
} {
switch -- [Nv belong 12 0 {} {}] 398689 {>;emit {Berkeley DB}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {(Hash, version %d, big-endian)}
<}
;<} 340322 {>;emit {Berkeley DB}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {(Btree, version %d, big-endian)}
<}
;<} 270931 {>;emit {Berkeley DB}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {(Queue, version %d, big-endian)}
<}
;<} 264584 {>;emit {Berkeley DB }

if {[N belong 16 0 0 {} {} > 0]} {>

emit {(Log, version %d, big-endian)}
<}
;<} 
<
} {
switch -- [Nv lelong 12 0 {} {}] 398689 {>;emit {Berkeley DB}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {(Hash, version %d, little-endian)}
<}
;<} 340322 {>;emit {Berkeley DB}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {(Btree, version %d, little-endian)}
<}
;<} 270931 {>;emit {Berkeley DB}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {(Queue, version %d, little-endian)}
<}
;<} 264584 {>;emit {Berkeley DB}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {(Log, version %d, little-endian)}
<}
;<} 
<
} {
if {[S string 0 0 b {} eq RRD\0]} {>

emit {RRDTool DB}

if {[S string 4 0 b {} x {}]} {>

emit {version %s}

	if {[N short 10 0 0 {} {} != 0]} {>

	emit {16bit aligned}

		if {[N bedouble 10 0 0 {} {} == 8.642135e+130]} {>

		emit big-endian

			if {[N short 18 0 0 {} {} x {}]} {>

			emit {32bit long (m68k)}
<}

<}

<}

	if {[N short 10 0 0 {} {} == 0]} {>

		if {[N long 12 0 0 {} {} != 0]} {>

		emit {32bit aligned}

			if {[N bedouble 12 0 0 {} {} == 8.642135e+130]} {>

			emit big-endian

				if {[N long 20 0 0 {} {} == 0]} {>

				emit {64bit long}
<}

				if {[N long 20 0 0 {} {} != 0]} {>

				emit {32bit long  }
<}

<}

			if {[N ledouble 12 0 0 {} {} == 8.642135e+130]} {>

			emit little-endian

				if {[N long 24 0 0 {} {} == 0]} {>

				emit {64bit long}
<}

				if {[N long 24 0 0 {} {} != 0]} {>

				emit {32bit long (i386)}
<}

<}

			if {[S string 12 0 {} {} eq \x43\x2b\x1f\x5b\x2f\x25\xc0\xc7]} {>

			emit middle-endian

				if {[N short 24 0 0 {} {} != 0]} {>

				emit {32bit long (arm)}
<}

<}

<}

<}

	if {[N quad 8 0 0 {} {} == 0]} {>

	emit {64bit aligned}

		if {[N bedouble 16 0 0 {} {} == 8.642135e+130]} {>

		emit big-endian

			if {[N long 24 0 0 {} {} == 0]} {>

			emit {64bit long (s390x)}
<}

			if {[N long 24 0 0 {} {} != 0]} {>

			emit {32bit long (hppa/mips/ppc/s390/SPARC)}
<}

<}

		if {[N ledouble 16 0 0 {} {} == 8.642135e+130]} {>

		emit little-endian

			if {[N long 28 0 0 {} {} == 0]} {>

			emit {64bit long (alpha/amd64/ia64)}
<}

			if {[N long 28 0 0 {} {} != 0]} {>

			emit {32bit long (armel/mipsel)}
<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq root\0]} {>

emit {ROOT file}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {Version %d}
<}

if {[N belong 33 0 0 {} {} x {}]} {>

emit {(Compression: %d)}
<}

<}
} {
if {[Nx belong 0 0 0 & 65535 < 3104]} {>

if {[Nx byte 2 0 0 {} {} > 0]} {>

	if {[Nx byte 3 0 0 {} {} > 0]} {>

		if {[Nx byte 3 0 0 {} {} < 32]} {>

			if {[Nx byte 0 0 0 {} {} > 1]} {>

				if {[Nx byte 27 0 0 {} {} == 0]} {>

					if {[N belong 24 0 0 & 4294967295 > 19931136]} {>

<}

					if {[Nx belong 24 0 0 & 4294967295 < 19931137]} {>

						if {[Nx belong 24 0 0 & 4294967295 == 0]} {>

							if {[Nx belong 12 0 0 & 4294967038 == 0]} {>

								if {[N byte 28 0 0 {} {} x {}]} {>

<}

								if {[Nx byte 28 0 0 & 248 == 0]} {>

									if {[Nx leshort 8 0 0 {} {} > 31]} {>

										if {[Nx byte 32 0 0 {} {} > 0]} {>
U 85 xbase-type

											if {[N byte 0 0 0 {} {} x {}]} {>

											emit {\b DBF}
<}

											if {[N lelong 4 0 0 {} {} == 0]} {>

											emit {\b, no records}
<}

											if {[N lelong 4 0 0 {} {} > 0]} {>

											emit {\b, %d record}

												if {[N lelong 4 0 0 {} {} > 1]} {>

												emit {\bs}
<}

<}

											if {[N leshort 10 0 0 {} {} x {}]} {>

											emit {* %d}
<}

											if {[N byte 1 0 0 {} {} x {}]} {>

											emit {\b, update-date}
<}
U 85 xbase-date

											if {[N byte 29 0 0 {} {} > 0]} {>

											emit {\b, codepage ID=0x%x}
<}

											if {[N byte 28 0 0 & 1 == 1]} {>

											emit {\b, with index file .MDX}
<}

											if {[N byte 28 0 0 & 2 == 2]} {>

											emit {\b, with memo .FPT}
<}

											if {[N byte 28 0 0 & 4 == 4]} {>

											emit {\b, DataBaseContainer}
<}

											if {[N leshort 8 0 0 {} {} > 0]} {>

<}

											if {[Nx byte [I 8 leshort 0 + 0 1] 0 0 {} {} > 0]} {>

												if {[N leshort 8 0 0 {} {} > 0]} {>

												emit {\b, at offset %d}
<}

												if {[Nx byte [I 8 leshort 0 + 0 1] 0 0 {} {} > 0]} {>

													if {[Sx string [R -1] 0 {} {} > \0]} {>

													emit {1st record "%s"}
<}

<}

<}

<}

<}

<}

<}

<}

						if {[N belong 24 0 0 & 20183039 > 0]} {>

							if {[N byte 47 0 0 {} {} == 0]} {>

								if {[N byte 559 0 0 & 239 == 0]} {>

									if {[N beshort 45 0 0 {} {} < 3104]} {>

										if {[N byte 45 0 0 {} {} > 0]} {>

											if {[N byte 46 0 0 {} {} < 32]} {>

												if {[N byte 46 0 0 {} {} > 0]} {>
U 85 xbase-type

													if {[N byte 0 0 0 {} {} x {}]} {>

													emit {\b MDX}
<}

													if {[N byte 1 0 0 {} {} x {}]} {>

													emit {\b, creation-date}
<}
U 85 xbase-date

													if {[N byte 44 0 0 {} {} x {}]} {>

													emit {\b, update-date}
<}
U 85 xbase-date

													if {[N leshort 28 0 0 {} {} x {}]} {>

													emit {\b, %d}
<}

													if {[N byte 25 0 0 {} {} x {}]} {>

													emit {\b/%d tags}
<}

													if {[N byte 26 0 0 {} {} x {}]} {>

													emit {* %d}
<}

<}

												if {[S string 548 0 {} {} x {}]} {>

												emit {\b, 1st tag "%.11s"}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[N byte 16 0 0 {} {} < 4]} {>

if {[N byte 16 0 0 {} {} != 2]} {>

	if {[N byte 16 0 0 {} {} != 1]} {>

		if {[N lelong 0 0 0 {} {} > 0]} {>

			if {[N belong 17 0 0 & 4294835712 == 0]} {>

				if {[N belong 20 0 0 & 4278263963 == 0]} {>

					switch -- [Nv byte 16 0 {} {}] 3 {>;U 85 dbase3-memo-print
;<} 0 {>;
						if {[N leshort 20 0 0 {} {} == 0]} {>

							if {[N long 8 0 0 {} {} == 0]} {>

								if {[N beshort 6 0 0 {} {} > 0]} {>

									if {[N short 4 0 0 {} {} == 0]} {>
U 85 foxpro-memo-print

<}

<}

								if {[N beshort 6 0 0 {} {} == 0]} {>

									if {[N beshort 510 0 0 {} {} == 0]} {>

										if {[N belong 512 0 0 {} {} < 4278189827]} {>

											if {[N belong 512 0 0 {} {} > 522199072]} {>

												if {[N byte 513 0 0 {} {} > 0]} {>
U 85 dbase3-memo-print

<}

<}

<}

<}

<}

<}

							if {[N belong 8 0 0 {} {} != 0]} {>

								if {[N beshort 510 0 0 {} {} == 0]} {>

									if {[N byte 0 0 0 {} {} > 5]} {>

										if {[N byte 0 0 0 {} {} < 48]} {>
U 85 dbase3-memo-print

<}

<}

<}

<}

<}

						if {[N leshort 20 0 0 {} {} > 0]} {>

							if {[N leshort 20 0 0 & 32783 == 0]} {>
U 85 dbase4-memo-print

<}

<}
;<} 
<

<}

<}

<}

<}

<}

<}
} {
if {[S string 4 0 {} {} eq Standard\ Jet\ DB]} {>

emit {Microsoft Access Database}
mime application/x-msaccess

<}
} {
if {[S string 4 0 {} {} eq Standard\ ACE\ DB]} {>

emit {Microsoft Access Database}
mime application/x-msaccess

<}
} {
switch -- [Nv belong 4 0 {} {}] -271733879 {>;
if {[N belong 132 0 0 {} {} == 0]} {>

emit {Extensible storage engine}

	switch -- [Nv lelong 12 0 {} {}] 0 {>;emit DataBase
	ext edb/sdb
;<} 1 {>;emit STreaMing
	ext stm
;<} 
<

	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {\b, version 0x%x}
<}

	if {[N leshort 10 0 0 {} {} > 0]} {>

	emit {revision 0x%4.4x}
<}

	if {[N belong 0 0 0 {} {} x {}]} {>

	emit {\b, checksum 0x%8.8x}
<}

	if {[N lequad 236 0 0 {} {} x {}]} {>

	emit {\b, page size %lld}
<}

	switch -- [Nv lelong 52 0 {} {}] 1 {>;emit {\b, JustCreated};<} 2 {>;emit {\b, DirtyShutdown};<} 4 {>;emit {\b, BeingConverted};<} 5 {>;emit {\b, ForceDetach};<} 
<

	if {[N lelong 216 0 0 {} {} x {}]} {>

	emit {\b, Windows version %d}
<}

	if {[N lelong 220 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

mime application/x-ms-ese

<}
;<} 19195 {>;emit {QDOS executable}

if {[S pstring 9 0 {} {} x {}]} {>

emit '%s'
<}
;<} 2097152000 {>;emit GLF_BINARY_LSB_FIRST;<} 125 {>;emit GLF_BINARY_MSB_FIRST;<} 268435456 {>;emit GLS_BINARY_LSB_FIRST;<} 16 {>;emit GLS_BINARY_MSB_FIRST;<} 
<
} {
if {[S string 8 0 {} {} eq sdbf]} {>

if {[N byte 7 0 0 {} {} == 0]} {>

	if {[N leshort 12 0 0 {} {} == 30722]} {>

	emit {Windows application compatibility Shim DataBase}
	mime application/x-ms-sdb

	ext sdb

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TDB\ file]} {>

emit {TDB database}

if {[N lelong 32 0 0 {} {} == 637606253]} {>

emit {version 6, little-endian}

	if {[N lelong 36 0 0 {} {} x {}]} {>

	emit {hash size %d bytes}
<}

<}

<}
} {
if {[S string 2 0 {} {} eq ICE]} {>

emit {ICE authority data}
<}
} {
if {[S string 10 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 11 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 12 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 13 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 14 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 15 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 16 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 17 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 18 0 {} {} eq MIT-MAGIC-COOKIE-1]} {>

emit {X11 Xauthority data}
<}
} {
if {[S string 0 0 {} {} eq PGDMP]} {>

emit {PostgreSQL custom database dump}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {- v%d}
<}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N beshort 5 0 0 {} {} < 257]} {>

emit {\b-0}
<}

if {[N beshort 5 0 0 {} {} > 256]} {>

	if {[N byte 7 0 0 {} {} x {}]} {>

	emit {\b-%d}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq @(\#)ADF\ Database]} {>

emit {CGNS Advanced Data Format}
<}
} {
if {[S string 0 0 {} {} eq ToKyO\ CaBiNeT\n]} {>

emit {Tokyo Cabinet}

if {[S string 14 0 {} {} x {}]} {>

emit {\b (%s)}
<}

switch -- [Nv byte 32 0 {} {}] 0 {>;emit {\b, Hash}
mime application/x-tokyocabinet-hash
;<} 1 {>;emit {\b, B+ tree}
mime application/x-tokyocabinet-btree
;<} 2 {>;emit {\b, Fixed-length}
mime application/x-tokyocabinet-fixed
;<} 3 {>;emit {\b, Table}
mime application/x-tokyocabinet-table
;<} 
<

if {[N byte 33 0 0 {} {} & 1]} {>

emit {\b, [open]}
<}

if {[N byte 33 0 0 {} {} & 2]} {>

emit {\b, [fatal]}
<}

if {[N byte 34 0 0 {} {} x {}]} {>

emit {\b, apow=%d}
<}

if {[N byte 35 0 0 {} {} x {}]} {>

emit {\b, fpow=%d}
<}

if {[N byte 36 0 0 {} {} & 1]} {>

emit {\b, [large]}
<}

if {[N byte 36 0 0 {} {} & 2]} {>

emit {\b, [deflate]}
<}

if {[N byte 36 0 0 {} {} & 4]} {>

emit {\b, [bzip]}
<}

if {[N byte 36 0 0 {} {} & 8]} {>

emit {\b, [tcbs]}
<}

if {[N byte 36 0 0 {} {} & 16]} {>

emit {\b, [excodec]}
<}

if {[N lequad 40 0 0 {} {} x {}]} {>

emit {\b, bnum=%lld}
<}

if {[N lequad 48 0 0 {} {} x {}]} {>

emit {\b, rnum=%lld}
<}

if {[N lequad 56 0 0 {} {} x {}]} {>

emit {\b, fsiz=%lld}
<}

<}
} {
if {[S string 0 0 {} {} eq \\\[depot\\\]\n\f]} {>

emit {Quick Database Manager, little endian}
<}
} {
if {[S string 0 0 {} {} eq \\\[DEPOT\\\]\n\f]} {>

emit {Quick Database Manager, big endian}
<}
} {
if {[S string 0 0 {} {} eq ToKyO\ CaBiNeT\n]} {>

emit {TokyoCabinet database}

if {[S string 14 0 {} {} x {}]} {>

emit {(version %s)}
<}

<}
} {
if {[S string 0 0 {} {} eq FS21]} {>

emit {Zope Object Database File Storage v3 (data)}
<}
} {
if {[S string 0 0 {} {} eq FS30]} {>

emit {Zope Object Database File Storage v4 (data)}
<}
} {
if {[S string 0 0 {} {} eq ZEC3]} {>

emit {Zope Object Database Client Cache File (data)}
<}
} {
if {[S string 0 0 {} {} eq IDA1]} {>

emit {IDA (Interactive Disassembler) database}
<}
} {
if {[S string 0 0 {} {} eq hopperdb]} {>

emit {Hopper database}
<}
} {
if {[Nx byte 5 0 0 {} {} > 0]} {>

if {[Nx belong [I 5 byte 0 + 0 7] 0 0 & 4093636608 == 0]} {>

	if {[Sx search [R 1] 0 {} 2 eq DESIGN]} {>

	emit {Panorama database}

		if {[S pstring 5 0 {} {} x {}]} {>

		emit {\b, "%s"}
<}

	ext pan

<}

<}

<}
} {
if {[S string 0 0 {} {} eq core]} {>

emit {core file (Xenix)}
<}
} {
switch -- [Nv byte 0 0 {} {}] -128 {>;
if {[N leshort 1 0 0 {} {} < 1022]} {>

	if {[N leshort 1 0 0 {} {} > 0]} {>

		if {[N byte 3 0 0 {} {} > 0]} {>

			if {[S regex 4 0 {} {} eq \[a-zA-Z_/\]\{1,8\}\[.\]]} {>

			emit {8086 relocatable (Microsoft)}

				if {[S pstring 3 0 {} {} x {}]} {>

				emit {\b, "%s"}
<}

			mime application/x-object

			ext o/a

<}

<}

<}

<}
;<} -23 {>;emit {DOS executable (COM)}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, boot code}
<}

if {[S string 6 0 {} {} eq SFX\ of\ LHarc]} {>

emit (%s)
<}
;<} -116 {>;
if {[S string 4 0 {} {} ne O====]} {>

	if {[S string 5 0 {} {} ne MAIN]} {>

		if {[N byte 4 0 0 {} {} > 13]} {>

		emit {DOS executable (COM, 0x8C-variant)}
		mime application/x-dosexec

		ext com

<}

<}

<}
;<} -72 {>;
if {[S string 0 0 {} {} ne \xb8\xc0\x07\x8e]} {>

	if {[N lelong 1 0 0 & 4294967294 == 567102718]} {>

	emit {COM executable (32-bit COMBOOT}

		switch -- [Nv lelong 1 0 {} {}] 567102719 {>;emit {\b)};<} 567102718 {>;emit {\b, relocatable)};<} 
<

	mime application/x-c32-comboot-syslinux-exec

	ext c32

<}

	if {[S default 1 0 {} {} x {}]} {>

	emit {COM executable for DOS}
	mime application/x-dosexec

	ext com

<}

<}
;<} -116 {>;emit {PGP symmetric key encrypted data -}

switch -- [Nv byte 1 0 {} {}] 13 {>;;<} 12 {>;;<} 
<

if {[N byte 2 0 0 {} {} == 4]} {>

<}
U 180 crypto

switch -- [Nv byte 4 0 {} {}] 1 {>;emit {salted -}
U 180 hash

	switch -- [Nv byte 14 0 {} {}] -46 {>;emit .;<} -55 {>;emit .;<} 
<
;<} 3 {>;emit {salted & iterated -}
U 180 hash

	switch -- [Nv byte 15 0 {} {}] -46 {>;emit .;<} -55 {>;emit .;<} 
<
;<} 
<
;<} -107 {>;emit {PGP	Secret Key -}
U 180 pgpkey
;<} -105 {>;emit {PGP	Secret Sub-key -}
U 180 pgpkey
;<} -99 {>;emit {PGP	Secret Sub-key -}
U 180 pgpkey
;<} 32 {>;
if {[N leshort 1 0 0 {} {} == 7]} {>

	if {[N byte 118 0 0 {} {} == 32]} {>

		if {[N leshort 119 0 0 {} {} == 117]} {>

		emit {TomTom activity file, v7}

			if {[N leldate 8 0 0 {} {} x {}]} {>

			emit (%s,
<}

			if {[N byte 3 0 0 {} {} x {}]} {>

			emit {device firmware %d.}
<}

			if {[N byte 4 0 0 {} {} x {}]} {>

			emit {\b%d.}
<}

			if {[N byte 5 0 0 {} {} x {}]} {>

			emit {\b%d,}
<}

			if {[N leshort 6 0 0 {} {} x {}]} {>

			emit {product ID %04d)}
<}

<}

<}

<}
;<} 0 {>;
if {[S string 12 0 {} {} eq \x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x40\x00]} {>

emit {Soundtrakker 128 ST2 music,}

	if {[S string 1 0 {} {} x {}]} {>

	emit {name: %s}
<}

<}
;<} -2 {>;
if {[N leshort 1 0 0 {} {} == 0]} {>

	if {[N leshort 5 0 0 {} {} == 0]} {>

		switch -- [Nv leshort 3 0 {} {}] 14335 {>;emit {MSX SC2/GRP raw image};<} 27136 {>;emit {MSX Graph Saurus SR5 raw image};<} -11265 {>;emit {MSX screen 7-12 raw image};<} -11264 {>;emit {MSX Graph Saurus SR7/SR8/SRS raw image};<} 
<

		if {[N leshort 3 0 0 {} {} > 30366]} {>

			if {[N leshort 3 0 0 {} {} < 32768]} {>

			emit {MSX GE5/GE6 raw image}

				if {[N leshort 3 0 0 {} {} == 32767]} {>

				emit {\b, with sprite patterns}
<}

<}

<}

<}

<}
;<} -3 {>;
if {[N leshort 1 0 0 {} {} == 0]} {>

	if {[N leshort 5 0 0 {} {} == 0]} {>

		if {[N leshort 3 0 0 {} {} > 317]} {>

		emit {MSX Graph Saurus compressed image}
<}

<}

<}
;<} -1 {>;
if {[N leshort 3 0 0 {} {} == 10]} {>

	if {[N leshort 1 0 0 {} {} > 32768]} {>

	emit {MSX-BASIC program}
<}

<}
;<} -2 {>;
if {[N leshort 1 0 0 {} {} == 1]} {>

	if {[N leshort 5 0 0 {} {} == 65535]} {>

		if {[N byte 6 0 0 {} {} == 10]} {>

		emit {MSX Mega-Assembler source}
<}

<}

<}
;<} 38 {>;
if {[S regex 16 0 s {} eq ^\[0-78\]\[0-9.\]\{4\}]} {>

emit {Sendmail frozen configuration}

	if {[S string 16 0 {} {} > \0]} {>

	emit {- version %s}
<}

ext fc

<}
;<} 
<
} {
if {[S string 0 0 {} {} eq .MCAD\t]} {>

emit {Mathcad document}
<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/lua]} {>

emit {Lua script text executable}
mime text/x-lua

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/lua]} {>

emit {Lua script text executable}
mime text/x-lua

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ lua]} {>

emit {Lua script text executable}
mime text/x-lua

<}
} {
if {[S search 0 0 {} 1 eq \#!\ /usr/bin/env\ lua]} {>

emit {Lua script text executable}
mime text/x-lua

<}
} {
if {[S string 0 0 {} {} eq \033Lua]} {>

emit {Lua bytecode,}

switch -- [Nv byte 4 0 {} {}] 80 {>;emit {version 5.0};<} 81 {>;emit {version 5.1};<} 82 {>;emit {version 5.2};<} 
<

<}
} {
switch -- [Nv belong 0 0 & 4294967040] -2063526912 {>;emit {cisco IOS microcode}

if {[S string 7 0 {} {} > \0]} {>

emit {for '%s'}
<}
;<} -2063480064 {>;emit {cisco IOS experimental microcode}

if {[S string 7 0 {} {} > \0]} {>

emit {for '%s'}
<}
;<} -16906496 {>;emit {MySQL MyISAM index file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16906240 {>;emit {MySQL MyISAM compressed data file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16905984 {>;emit {MySQL Maria index file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16905728 {>;emit {MySQL Maria compressed data file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16907008 {>;emit {MySQL ISAM index file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16906752 {>;emit {MySQL ISAM compressed data file}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {Version %d}
<}
;<} -16905472 {>;
if {[S string 4 0 {} {} eq MARIALOG]} {>

emit {MySQL Maria transaction log file}

	if {[N byte 3 0 0 {} {} x {}]} {>

	emit {Version %d}
<}

<}
;<} -16905216 {>;
if {[S string 4 0 {} {} eq MACF]} {>

emit {MySQL Maria control file}

	if {[N byte 3 0 0 {} {} x {}]} {>

	emit {Version %d}
<}

<}
;<} 256 {>;
switch -- [Nv byte 3 0 {} {}] -70 {>;emit {MPEG sequence}

	if {[N byte 4 0 0 {} {} & 64]} {>

	emit {\b, v2, program multiplex}
<}

	if {[N byte 4 0 0 {} {} ^ 64]} {>

	emit {\b, v1, system multiplex}
<}

mime video/mpeg
;<} -69 {>;emit {MPEG sequence, v1/2, multiplex (missing pack header)};<} -80 {>;emit {MPEG sequence, v4}

	if {[N belong 5 0 0 {} {} == 437]} {>

		if {[N byte 9 0 0 {} {} & 128]} {>

			switch -- [Nv byte 10 0 & 240] 16 {>;emit {\b, video};<} 32 {>;emit {\b, still texture};<} 48 {>;emit {\b, mesh};<} 64 {>;emit {\b, face};<} 
<

<}

		switch -- [Nv byte 9 0 & 248] 8 {>;emit {\b, video};<} 16 {>;emit {\b, still texture};<} 24 {>;emit {\b, mesh};<} 32 {>;emit {\b, face};<} 
<

<}

	switch -- [Nv byte 4 0 {} {}] 1 {>;emit {\b, simple @ L1};<} 2 {>;emit {\b, simple @ L2};<} 3 {>;emit {\b, simple @ L3};<} 4 {>;emit {\b, simple @ L0};<} 17 {>;emit {\b, simple scalable @ L1};<} 18 {>;emit {\b, simple scalable @ L2};<} 33 {>;emit {\b, core @ L1};<} 34 {>;emit {\b, core @ L2};<} 50 {>;emit {\b, main @ L2};<} 51 {>;emit {\b, main @ L3};<} 53 {>;emit {\b, main @ L4};<} 66 {>;emit {\b, n-bit @ L2};<} 81 {>;emit {\b, scalable texture @ L1};<} 97 {>;emit {\b, simple face animation @ L1};<} 98 {>;emit {\b, simple face animation @ L2};<} 99 {>;emit {\b, simple face basic animation @ L1};<} 100 {>;emit {\b, simple face basic animation @ L2};<} 113 {>;emit {\b, basic animation text @ L1};<} 114 {>;emit {\b, basic animation text @ L2};<} -127 {>;emit {\b, hybrid @ L1};<} -126 {>;emit {\b, hybrid @ L2};<} -111 {>;emit {\b, advanced RT simple @ L!};<} -110 {>;emit {\b, advanced RT simple @ L2};<} -109 {>;emit {\b, advanced RT simple @ L3};<} -108 {>;emit {\b, advanced RT simple @ L4};<} -95 {>;emit {\b, core scalable @ L1};<} -94 {>;emit {\b, core scalable @ L2};<} -93 {>;emit {\b, core scalable @ L3};<} -79 {>;emit {\b, advanced coding efficiency @ L1};<} -78 {>;emit {\b, advanced coding efficiency @ L2};<} -77 {>;emit {\b, advanced coding efficiency @ L3};<} -76 {>;emit {\b, advanced coding efficiency @ L4};<} -63 {>;emit {\b, advanced core @ L1};<} -62 {>;emit {\b, advanced core @ L2};<} -47 {>;emit {\b, advanced scalable texture @ L1};<} -46 {>;emit {\b, advanced scalable texture @ L2};<} -45 {>;emit {\b, advanced scalable texture @ L3};<} -31 {>;emit {\b, simple studio @ L1};<} -30 {>;emit {\b, simple studio @ L2};<} -29 {>;emit {\b, simple studio @ L3};<} -28 {>;emit {\b, simple studio @ L4};<} -27 {>;emit {\b, core studio @ L1};<} -26 {>;emit {\b, core studio @ L2};<} -25 {>;emit {\b, core studio @ L3};<} -24 {>;emit {\b, core studio @ L4};<} -16 {>;emit {\b, advanced simple @ L0};<} -15 {>;emit {\b, advanced simple @ L1};<} -14 {>;emit {\b, advanced simple @ L2};<} -13 {>;emit {\b, advanced simple @ L3};<} -12 {>;emit {\b, advanced simple @ L4};<} -11 {>;emit {\b, advanced simple @ L5};<} -9 {>;emit {\b, advanced simple @ L3b};<} -8 {>;emit {\b, FGS @ L0};<} -7 {>;emit {\b, FGS @ L1};<} -6 {>;emit {\b, FGS @ L2};<} -5 {>;emit {\b, FGS @ L3};<} -4 {>;emit {\b, FGS @ L4};<} -3 {>;emit {\b, FGS @ L5};<} 
<

mime video/mpeg4-generic
;<} -75 {>;emit {MPEG sequence, v4}

	if {[N byte 4 0 0 {} {} & 128]} {>

		switch -- [Nv byte 5 0 & 240] 16 {>;emit {\b, video (missing profile header)};<} 32 {>;emit {\b, still texture (missing profile header)};<} 48 {>;emit {\b, mesh (missing profile header)};<} 64 {>;emit {\b, face (missing profile header)};<} 
<

<}

	switch -- [Nv byte 4 0 & 248] 8 {>;emit {\b, video (missing profile header)};<} 16 {>;emit {\b, still texture (missing profile header)};<} 24 {>;emit {\b, mesh (missing profile header)};<} 32 {>;emit {\b, face (missing profile header)};<} 
<

mime video/mpeg4-generic
;<} -77 {>;emit {MPEG sequence}

	switch -- [Nv belong 12 0 {} {}] 440 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 434 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 437 {>;emit {\b, v2,}

		switch -- [Nv byte 16 0 & 15] 1 {>;emit {\b HP};<} 2 {>;emit {\b Spt};<} 3 {>;emit {\b SNR};<} 4 {>;emit {\b MP};<} 5 {>;emit {\b SP};<} 
<

		switch -- [Nv byte 17 0 & 240] 64 {>;emit {\b@HL};<} 96 {>;emit {\b@H-14};<} -128 {>;emit {\b@ML};<} -96 {>;emit {\b@LL};<} 
<

		if {[N byte 17 0 0 {} {} & 8]} {>

		emit {\b progressive}
<}

		if {[N byte 17 0 0 {} {} ^ 8]} {>

		emit {\b interlaced}
<}

		switch -- [Nv byte 17 0 & 6] 2 {>;emit {\b Y'CbCr 4:2:0 video};<} 4 {>;emit {\b Y'CbCr 4:2:2 video};<} 6 {>;emit {\b Y'CbCr 4:4:4 video};<} 
<
;<} 
<

	if {[N byte 11 0 0 {} {} & 2]} {>

		if {[N byte 75 0 0 {} {} & 1]} {>

			switch -- [Nv belong 140 0 {} {}] 440 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 434 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 437 {>;emit {\b, v2,}

				switch -- [Nv byte 144 0 & 15] 1 {>;emit {\b HP};<} 2 {>;emit {\b Spt};<} 3 {>;emit {\b SNR};<} 4 {>;emit {\b MP};<} 5 {>;emit {\b SP};<} 
<

				switch -- [Nv byte 145 0 & 240] 64 {>;emit {\b@HL};<} 96 {>;emit {\b@H-14};<} -128 {>;emit {\b@ML};<} -96 {>;emit {\b@LL};<} 
<

				if {[N byte 145 0 0 {} {} & 8]} {>

				emit {\b progressive}
<}

				if {[N byte 145 0 0 {} {} ^ 8]} {>

				emit {\b interlaced}
<}

				switch -- [Nv byte 145 0 & 6] 2 {>;emit {\b Y'CbCr 4:2:0 video};<} 4 {>;emit {\b Y'CbCr 4:2:2 video};<} 6 {>;emit {\b Y'CbCr 4:4:4 video};<} 
<
;<} 
<

<}

<}

	switch -- [Nv belong 76 0 {} {}] 440 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 434 {>;emit {\b, v1, progressive Y'CbCr 4:2:0 video};<} 437 {>;emit {\b, v2,}

		switch -- [Nv byte 80 0 & 15] 1 {>;emit {\b HP};<} 2 {>;emit {\b Spt};<} 3 {>;emit {\b SNR};<} 4 {>;emit {\b MP};<} 5 {>;emit {\b SP};<} 
<

		switch -- [Nv byte 81 0 & 240] 64 {>;emit {\b@HL};<} 96 {>;emit {\b@H-14};<} -128 {>;emit {\b@ML};<} -96 {>;emit {\b@LL};<} 
<

		if {[N byte 81 0 0 {} {} & 8]} {>

		emit {\b progressive}
<}

		if {[N byte 81 0 0 {} {} ^ 8]} {>

		emit {\b interlaced}
<}

		switch -- [Nv byte 81 0 & 6] 2 {>;emit {\b Y'CbCr 4:2:0 video};<} 4 {>;emit {\b Y'CbCr 4:2:2 video};<} 6 {>;emit {\b Y'CbCr 4:4:4 video};<} 
<
;<} 
<

	switch -- [Nv belong 4 0 & 4294967040] 2013542400 {>;emit {\b, HD-TV 1920P}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 16:9}
<}
;<} 1342188800 {>;emit {\b, SD-TV 1280I}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 16:9}
<}
;<} 805453824 {>;emit {\b, PAL Capture}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 4:3}
<}
;<} 671211520 {>;emit {\b, LD-TV 640P}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 4:3}
<}
;<} 335605760 {>;emit {\b, 320x240}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 4:3}
<}
;<} 251699200 {>;emit {\b, 240x160}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 4:3}
<}
;<} 167802880 {>;emit {\b, 160x120}

		if {[N byte 7 0 0 & 240 == 16]} {>

		emit {\b, 4:3}
<}
;<} 
<

	switch -- [Nv beshort 4 0 & 65520] 11264 {>;emit {\b, 4CIF}

		switch -- [Nv beshort 5 0 & 4095] 480 {>;emit {\b NTSC};<} 576 {>;emit {\b PAL};<} 
<

		switch -- [Nv byte 7 0 & 240] 32 {>;emit {\b, 4:3};<} 48 {>;emit {\b, 16:9};<} 64 {>;emit {\b, 11:5};<} -128 {>;emit {\b, PAL 4:3};<} -64 {>;emit {\b, NTSC 4:3};<} 
<
;<} 5632 {>;emit {\b, CIF}

		switch -- [Nv beshort 5 0 & 4095] 240 {>;emit {\b NTSC};<} 288 {>;emit {\b PAL};<} 576 {>;emit {\b PAL 625}

			switch -- [Nv byte 7 0 & 240] 32 {>;emit {\b, 4:3};<} 48 {>;emit {\b, 16:9};<} 64 {>;emit {\b, 11:5};<} 
<
;<} 
<

		switch -- [Nv byte 7 0 & 240] 32 {>;emit {\b, 4:3};<} 48 {>;emit {\b, 16:9};<} 64 {>;emit {\b, 11:5};<} -128 {>;emit {\b, PAL 4:3};<} -64 {>;emit {\b, NTSC 4:3};<} 
<
;<} 11520 {>;emit {\b, CCIR/ITU}

		switch -- [Nv beshort 5 0 & 4095] 480 {>;emit {\b NTSC 525};<} 576 {>;emit {\b PAL 625};<} 
<

		switch -- [Nv byte 7 0 & 240] 32 {>;emit {\b, 4:3};<} 48 {>;emit {\b, 16:9};<} 64 {>;emit {\b, 11:5};<} 
<
;<} 7680 {>;emit {\b, SVCD}

		switch -- [Nv beshort 5 0 & 4095] 480 {>;emit {\b NTSC 525};<} 576 {>;emit {\b PAL 625};<} 
<

		switch -- [Nv byte 7 0 & 240] 32 {>;emit {\b, 4:3};<} 48 {>;emit {\b, 16:9};<} 64 {>;emit {\b, 11:5};<} 
<
;<} 
<

	switch -- [Nv byte 7 0 & 15] 1 {>;emit {\b, 23.976 fps};<} 2 {>;emit {\b, 24 fps};<} 3 {>;emit {\b, 25 fps};<} 4 {>;emit {\b, 29.97 fps};<} 5 {>;emit {\b, 30 fps};<} 6 {>;emit {\b, 50 fps};<} 7 {>;emit {\b, 59.94 fps};<} 8 {>;emit {\b, 60 fps};<} 
<

	if {[N byte 11 0 0 {} {} & 4]} {>

	emit {\b, Constrained}
<}

mime video/mpeg
;<} 
<

if {[N byte 3 0 0 & 31 == 7]} {>

emit {MPEG sequence, H.264 video}

	switch -- [Nv byte 4 0 {} {}] 66 {>;emit {\b, baseline};<} 77 {>;emit {\b, main};<} 88 {>;emit {\b, extended};<} 
<

	if {[N byte 6 0 0 {} {} x {}]} {>

	emit {\b @ L %u}
<}

<}
;<} 520552448 {>;emit DIF

if {[N byte 4 0 0 {} {} & 1]} {>

emit {(DVCPRO) movie file}
<}

if {[N byte 4 0 0 {} {} ^ 1]} {>

emit {(DV) movie file}
<}

if {[N byte 3 0 0 {} {} & 128]} {>

emit (PAL)
<}

if {[N byte 3 0 0 {} {} ^ 128]} {>

emit (NTSC)
<}
;<} 
<
} {
if {[S string 0 0 {} {} eq +/v8]} {>

emit {Unicode text, UTF-7}
<}
} {
if {[S string 0 0 {} {} eq +/v9]} {>

emit {Unicode text, UTF-7}
<}
} {
if {[S string 0 0 {} {} eq +/v+]} {>

emit {Unicode text, UTF-7}
<}
} {
if {[S string 0 0 {} {} eq +/v/]} {>

emit {Unicode text, UTF-7}
<}
} {
if {[S string 0 0 {} {} eq \335\163\146\163]} {>

emit {Unicode text, UTF-8-EBCDIC}
<}
} {
if {[S string 0 0 {} {} eq \000\000\376\377]} {>

emit {Unicode text, UTF-32, big-endian}
<}
} {
if {[S string 0 0 {} {} eq \377\376\000\000]} {>

emit {Unicode text, UTF-32, little-endian}
<}
} {
if {[S string 0 0 {} {} eq \016\376\377]} {>

emit {Unicode text, SCSU (Standard Compression Scheme for Unicode)}
<}
} {
if {[S string 0 0 {} {} eq \x55\x7A\x6E\x61]} {>

emit {xo65 object,}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version %d,}
<}

switch -- [Nv leshort 6 0 & 1] 1 {>;emit {with debug info};<} 0 {>;emit {no debug info};<} 
<

<}
} {
if {[S string 0 0 {} {} eq \x6E\x61\x55\x7A]} {>

emit {xo65 library,}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq \x01\x00\x6F\x36\x35]} {>

emit o65

switch -- [Nv leshort 6 0 & 4096] 0 {>;emit executable,;<} 4096 {>;emit object,;<} 
<

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d,}
<}

switch -- [Nv leshort 6 0 & 32768] -32768 {>;emit 65816,;<} 0 {>;emit 6502,;<} 
<

switch -- [Nv leshort 6 0 & 8192] 8192 {>;emit {32 bit,};<} 0 {>;emit {16 bit,};<} 
<

switch -- [Nv leshort 6 0 & 16384] 16384 {>;emit {page reloc,};<} 0 {>;emit {byte reloc,};<} 
<

switch -- [Nv leshort 6 0 & 3] 0 {>;emit {alignment 1};<} 1 {>;emit {alignment 2};<} 2 {>;emit {alignment 4};<} 3 {>;emit {alignment 256};<} 
<

<}
} {
if {[S string 0 0 {} {} eq \{title]} {>

emit {Chord text file}
<}
} {
if {[S string 0 0 {} {} eq ptab\003\000]} {>

emit {Power-Tab v3 Tablature File}
<}
} {
if {[S string 0 0 {} {} eq ptab\004\000]} {>

emit {Power-Tab v4 Tablature File}
<}
} {
if {[Sx search 1 0 {} 100 eq InternetShortcut]} {>

emit {MS Windows 95 Internet shortcut text}

if {[Sx search 17 0 {} 100 eq URL=]} {>

emit (URL=<

	if {[Sx string [R 0] 0 {} {} x {}]} {>

	emit {\b%s>)}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq HSP\x01\x9b\x00]} {>

emit {OS/2 INF}

if {[S string 107 0 {} {} > 0]} {>

emit (%s)
<}

<}
} {
if {[S string 0 0 {} {} eq HSP\x10\x9b\x00]} {>

emit {OS/2 HLP}

if {[S string 107 0 {} {} > 0]} {>

emit (%s)
<}

<}
} {
if {[S string 0 0 {} {} eq \xff\xff\xff\xff\x14\0\0\0]} {>

emit {OS/2 INI}
<}
} {
if {[S string 1 0 {} {} eq mkx]} {>

emit {Compiled XKB Keymap: lsb,}

if {[N byte 0 0 0 {} {} > 0]} {>

emit {version %d}
<}

if {[N byte 0 0 0 {} {} == 0]} {>

emit obsolete
<}

<}
} {
if {[S string 0 0 {} {} eq xkm]} {>

emit {Compiled XKB Keymap: msb,}

if {[N byte 3 0 0 {} {} > 0]} {>

emit {version %d}
<}

if {[N byte 3 0 0 {} {} == 0]} {>

emit obsolete
<}

<}
} {
if {[S string 0 0 {} {} eq xFSdump0]} {>

emit {xfsdump archive}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {(version %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq Xcur]} {>

emit {Xcursor data}

if {[N leshort 10 0 0 {} {} x {}]} {>

emit {version %d}

	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

<}

mime image/x-xcursor

<}
} {
if {[S string 0 0 {} {} eq \010\011\376]} {>

emit Microstation

if {[S string 3 0 {} {} eq \002]} {>

	if {[S string 30 0 {} {} eq \026\105]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \034\105]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \073\107]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \073\110]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \106\107]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \110\103]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \120\104]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \172\104]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \172\105]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \172\106]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \234\106]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \273\105]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \306\106]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \310\104]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \341\104]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \372\103]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \372\104]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \372\106]} {>

	emit DGNFile
<}

	if {[S string 30 0 {} {} eq \376\103]} {>

	emit DGNFile
<}

<}

if {[S string 4 0 {} {} eq \030\000\000]} {>

emit CITFile
<}

if {[S string 4 0 {} {} eq \030\000\003]} {>

emit CITFile
<}

<}
} {
if {[S string 0 0 {} {} eq MC0.0]} {>

emit {DWG AutoDesk AutoCAD Release 1.0}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1.2]} {>

emit {DWG AutoDesk AutoCAD Release 1.2}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1.3]} {>

emit {DWG AutoDesk AutoCAD Release 1.3}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1.40]} {>

emit {DWG AutoDesk AutoCAD Release 1.40}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1.50]} {>

emit {DWG AutoDesk AutoCAD Release 2.05}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC2.10]} {>

emit {DWG AutoDesk AutoCAD Release 2.10}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC2.21]} {>

emit {DWG AutoDesk AutoCAD Release 2.21}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC2.22]} {>

emit {DWG AutoDesk AutoCAD Release 2.22}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1001]} {>

emit {DWG AutoDesk AutoCAD Release 2.22}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1002]} {>

emit {DWG AutoDesk AutoCAD Release 2.50}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1003]} {>

emit {DWG AutoDesk AutoCAD Release 2.60}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1004]} {>

emit {DWG AutoDesk AutoCAD Release 9}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1006]} {>

emit {DWG AutoDesk AutoCAD Release 10}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1009]} {>

emit {DWG AutoDesk AutoCAD Release 11/12}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1012]} {>

emit {DWG AutoDesk AutoCAD Release 13}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1014]} {>

emit {DWG AutoDesk AutoCAD Release 14}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1015]} {>

emit {DWG AutoDesk AutoCAD 2000/2002}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1018]} {>

emit {DWG AutoDesk AutoCAD 2004/2005/2006}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1021]} {>

emit {DWG AutoDesk AutoCAD 2007/2008/2009}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1024]} {>

emit {DWG AutoDesk AutoCAD 2010/2011/2012}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq AC1027]} {>

emit {DWG AutoDesk AutoCAD 2013/2014}
mime image/vnd.dwg

<}
} {
if {[S string 0 0 {} {} eq KF]} {>

switch -- [Nv belong 2 0 {} {}] 1308622860 {>;emit {Kompas drawing 12.0 SP1 };<} 1291845644 {>;emit {Kompas drawing 12.0 };<} 838860811 {>;emit {Kompas drawing 11.0 SP1 };<} 822083595 {>;emit {Kompas drawing 11.0 };<} 588251146 {>;emit {Kompas drawing 10.0 SP1 };<} 554696714 {>;emit {Kompas drawing 10.0 };<} 134217737 {>;emit {Kompas drawing 9.0 SP1 };<} 83886089 {>;emit {Kompas drawing 9.0 };<} 855703560 {>;emit {Kompas drawing 8+ };<} 436207624 {>;emit {Kompas drawing 8.0 };<} 738263303 {>;emit {Kompas drawing 7+ };<} 83886087 {>;emit {Kompas drawing 7.0 };<} 838860806 {>;emit {Kompas drawing 6+ };<} 150994950 {>;emit {Kompas drawing 6.0 };<} 1543540741 {>;emit {Kompas drawing 5.11R03 };<} 1409323013 {>;emit {Kompas drawing 5.11R02 };<} 1358991365 {>;emit {Kompas drawing 5.11R01 };<} 570462213 {>;emit {Kompas drawing 5.10R03 };<} 570462213 {>;emit {Kompas drawing 5.10R02 mar };<} 553684997 {>;emit {Kompas drawing 5.10R02 febr };<} 419467269 {>;emit {Kompas drawing 5.10R01 };<} -201293819 {>;emit {Kompas drawing 5.9R01.003 };<} 469794821 {>;emit {Kompas drawing 5.9R01.002 };<} 285245445 {>;emit {Kompas drawing 5.8R01.003 };<} 
<

<}
} {
if {[S string 0 0 {} {} eq MegaCad23\0]} {>

emit {MegaCAD 2D/3D drawing}
<}
} {
if {[S string 0 0 {} {} eq \336\22\4\225]} {>

emit {GNU message catalog (little endian),}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {revision %d.}
<}

if {[N leshort 4 0 0 {} {} > 0]} {>

emit {\b%d,}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {%d messages,}
<}

	if {[N lelong 36 0 0 {} {} x {}]} {>

	emit {%d sysdep messages}
<}

<}

if {[N leshort 4 0 0 {} {} == 0]} {>

emit {\b%d,}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {%d messages}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \225\4\22\336]} {>

emit {GNU message catalog (big endian),}

if {[N beshort 4 0 0 {} {} x {}]} {>

emit {revision %d.}
<}

if {[N beshort 6 0 0 {} {} > 0]} {>

emit {\b%d,}

	if {[N belong 8 0 0 {} {} x {}]} {>

	emit {%d messages,}
<}

	if {[N belong 36 0 0 {} {} x {}]} {>

	emit {%d sysdep messages}
<}

<}

if {[N beshort 6 0 0 {} {} == 0]} {>

emit {\b%d,}

	if {[N belong 8 0 0 {} {} x {}]} {>

	emit {%d messages}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \001gpg]} {>

emit {GPG key trust database}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 39 0 {} {} eq <gmr:Workbook]} {>

emit {Gnumeric spreadsheet}
<}
} {
if {[S string 0 0 {} {} eq \0LOCATE]} {>

emit {GNU findutils locate database data}

if {[S string 7 0 {} {} > \0]} {>

emit {\b, format %s}
<}

if {[S string 7 0 {} {} eq 02]} {>

emit {\b (frcode)}
<}

<}
} {
if {[Sx search 0 0 {} 1024 eq \nmsgid]} {>

if {[Sx search [R 0] 0 {} 1024 eq \nmsgstr]} {>

emit {GNU gettext message catalogue text}
mime text/x-po

<}

<}
} {
if {[S string 0 0 {} {} eq btsnoop\0]} {>

emit BTSnoop

if {[N belong 8 0 0 {} {} x {}]} {>

emit {version %d,}
<}

switch -- [Nv belong 12 0 {} {}] 1001 {>;emit {Unencapsulated HCI};<} 1002 {>;emit {HCI UART (H4)};<} 1003 {>;emit {HCI BCSP};<} 1004 {>;emit {HCI Serial (H5)}

	if {[N belong 12 0 0 {} {} x {}]} {>

	emit {type %d}
<}
;<} 
<

<}
} {
if {[Sx string 0 0 {} {} eq \$Suite]} {>

emit {TTCN Abstract Test Suite}

if {[Sx string [R 1] 0 {} {} eq \$SuiteId]} {>

	if {[Sx string [R 1] 0 {} {} > \n]} {>

	emit %s
<}

<}

if {[Sx string [R 2] 0 {} {} eq \$SuiteId]} {>

	if {[Sx string [R 1] 0 {} {} > \n]} {>

	emit %s
<}

<}

if {[Sx string [R 3] 0 {} {} eq \$SuiteId]} {>

	if {[Sx string [R 1] 0 {} {} > \n]} {>

	emit %s
<}

<}

<}
} {
if {[S string 0 0 {} {} eq mscdocument]} {>

emit {Message Sequence Chart (document)}
<}
} {
if {[S string 0 0 {} {} eq msc]} {>

emit {Message Sequence Chart (chart)}
<}
} {
if {[S string 0 0 {} {} eq submsc]} {>

emit {Message Sequence Chart (subchart)}
<}
} {
if {[S search 0 0 {} 100 eq yyprevious]} {>

emit {C program text (from lex)}

if {[S search 3 0 {} 1 > \0]} {>

emit {for %s}
<}

<}
} {
if {[S search 0 0 {} 100 eq generated\ by\ flex]} {>

emit {C program text (from flex)}
<}
} {
if {[S search 0 0 {} 1 eq %\{]} {>

emit {lex description text}
<}
} {
if {[S string 0 0 {} {} eq \376PBC\r\n\032\n]} {>

emit {Parrot bytecode}

if {[N byte 64 0 0 {} {} x {}]} {>

emit %d.
<}

if {[N byte 72 0 0 {} {} x {}]} {>

emit {\b%d,}
<}

if {[N byte 8 0 0 {} {} > 0]} {>

emit {%d byte words,}
<}

switch -- [Nv byte 16 0 {} {}] 0 {>;emit little-endian,;<} 1 {>;emit big-endian,;<} 
<

switch -- [Nv byte 32 0 {} {}] 0 {>;emit {IEEE-754 8 byte double floats,};<} 1 {>;emit {x86 12 byte long double floats,};<} 2 {>;emit {IEEE-754 16 byte long double floats,};<} 3 {>;emit {MIPS 16 byte long double floats,};<} 4 {>;emit {AIX 16 byte long double floats,};<} 5 {>;emit {4-byte floats,};<} 
<

if {[N byte 40 0 0 {} {} x {}]} {>

emit {Parrot %d.}
<}

if {[N byte 48 0 0 {} {} x {}]} {>

emit {\b%d.}
<}

if {[N byte 56 0 0 {} {} x {}]} {>

emit {\b%d}
<}

<}
} {
if {[S search 0 0 {} 8192 eq (input,]} {>

emit {Pascal source text}
mime text/x-pascal

<}
} {
if {[S string 0 0 {} {} eq !<bout>]} {>

emit {b.out archive}

if {[S string 8 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}

<}
} {
if {[S string 0 0 {} {} eq WARC/]} {>

emit {WARC Archive}

if {[S string 5 0 {} {} x {}]} {>

emit {version %.4s}
mime application/warc

<}

<}
} {
if {[Sx string 0 0 {} {} eq filedesc://]} {>

emit {Internet Archive File}

if {[Sx search 11 0 {} 256 eq \x0A]} {>

emit {\b}

	if {[Nx byte [R 0] 0 0 {} {} > 0]} {>

	emit {\b version %c}
<}

<}

mime application/x-ia-arc

<}
} {
if {[S string 0 0 {} {} eq *BEGIN]} {>

emit Applixware

if {[S string 7 0 {} {} eq WORDS]} {>

emit {Words Document}
<}

if {[S string 7 0 {} {} eq GRAPHICS]} {>

emit Graphic
<}

if {[S string 7 0 {} {} eq RASTER]} {>

emit Bitmap
<}

if {[S string 7 0 {} {} eq SPREADSHEETS]} {>

emit Spreadsheet
<}

if {[S string 7 0 {} {} eq MACRO]} {>

emit Macro
<}

if {[S string 7 0 {} {} eq BUILDER]} {>

emit {Builder Object}
<}

<}
} {
if {[S string 0 0 t {} eq @]} {>

if {[S string 1 0 {c W} {} eq \ echo\ off]} {>

emit {DOS batch file text}
mime text/x-msdos-batch

<}

if {[S string 1 0 {c W} {} eq echo\ off]} {>

emit {DOS batch file text}
mime text/x-msdos-batch

<}

if {[S string 1 0 {c W} {} eq rem]} {>

emit {DOS batch file text}
mime text/x-msdos-batch

<}

if {[S string 1 0 {c W} {} eq set\ ]} {>

emit {DOS batch file text}
mime text/x-msdos-batch

<}

<}
} {
if {[S search 100 0 {} 65535 eq rxfuncadd]} {>

if {[S regex 100 0 c {} eq ^\[\ \t\]\{0,10\}call\[\ \t\]\{1,10\}rxfunc]} {>

emit {OS/2 REXX batch file text}
<}

<}
} {
if {[S search 100 0 {} 65535 eq say]} {>

if {[S regex 100 0 c {} eq ^\[\ \t\]\{0,10\}say\ \['\"\]]} {>

emit {OS/2 REXX batch file text}
<}

<}
} {
if {[Sx string 0 0 b {} eq MZ]} {>

if {[N leshort 24 0 0 {} {} < 64]} {>

emit {MS-DOS executable}
mime application/x-dosexec

<}

if {[Nx leshort 24 0 0 {} {} > 63]} {>

	if {[Sx string [I 60 lelong 0 0 0 0] 0 {} {} eq PE\0\0]} {>

	emit PE

		switch -- [Nv leshort [I 60 lelong 0 + 0 24] 0 {} {}] 267 {>;emit {\b32 executable};<} 523 {>;emit {\b32+ executable};<} 263 {>;emit {ROM image};<} 267 {>;
			if {[N lelong [I 60 lelong 0 + 0 232] 0 0 {} {} > 0]} {>

			emit {Mono/.Net assembly}
<}
;<} 523 {>;
			if {[N lelong [I 60 lelong 0 + 0 248] 0 0 {} {} > 0]} {>

			emit {Mono/.Net assembly}
<}
;<} 
<

		if {[Sx default [I 60 lelong 0 + 0 24] 0 {} {} x {}]} {>

		emit {Unknown PE signature}

			if {[Nx leshort [R 0] 0 0 {} {} x {}]} {>

			emit 0x%x
<}

<}

		if {[N leshort [I 60 lelong 0 + 0 22] 0 0 & 8192 > 0]} {>

		emit (DLL)
<}

		switch -- [Nv leshort [I 60 lelong 0 + 0 92] 0 {} {}] 1 {>;emit (native);<} 2 {>;emit (GUI);<} 3 {>;emit (console);<} 7 {>;emit (POSIX);<} 9 {>;emit {(Windows CE)};<} 10 {>;emit {(EFI application)};<} 11 {>;emit {(EFI boot service driver)};<} 12 {>;emit {(EFI runtime driver)};<} 13 {>;emit {(EFI ROM)};<} 14 {>;emit (XBOX);<} 15 {>;emit {(Windows boot application)};<} 
<

		if {[Sx default [I 60 lelong 0 + 0 92] 0 {} {} x {}]} {>

		emit {(Unknown subsystem}

			if {[Nx leshort [R 0] 0 0 {} {} x {}]} {>

			emit 0x%x)
<}

<}

		switch -- [Nv leshort [I 60 lelong 0 + 0 4] 0 {} {}] 332 {>;emit {Intel 80386};<} 358 {>;emit {MIPS R4000};<} 360 {>;emit {MIPS R10000};<} 388 {>;emit Alpha;<} 418 {>;emit {Hitachi SH3};<} 422 {>;emit {Hitachi SH4};<} 448 {>;emit ARM;<} 450 {>;emit {ARM Thumb};<} 452 {>;emit {ARMv7 Thumb};<} 496 {>;emit PowerPC;<} 512 {>;emit {Intel Itanium};<} 614 {>;emit MIPS16;<} 616 {>;emit {Motorola 68000};<} 656 {>;emit PA-RISC;<} 870 {>;emit MIPSIV;<} 1126 {>;emit {MIPS16 with FPU};<} 3772 {>;emit {EFI byte code};<} -31132 {>;emit x86-64;<} -16146 {>;emit MSIL;<} 
<

		if {[Sx default [I 60 lelong 0 + 0 4] 0 {} {} x {}]} {>

		emit {Unknown processor type}

			if {[Nx leshort [R 0] 0 0 {} {} x {}]} {>

			emit 0x%x
<}

<}

		if {[N leshort [I 60 lelong 0 + 0 22] 0 0 & 512 > 0]} {>

		emit {(stripped to external PDB)}
<}

		if {[N leshort [I 60 lelong 0 + 0 22] 0 0 & 4096 > 0]} {>

		emit {system file}
<}

		if {[S string [I 8 leshort 0 * 0 16] 0 {} {} eq 32STUB]} {>

		emit {\b, 32rtm DOS extender}
<}

		if {[S string [I 8 leshort 0 * 0 16] 0 {} {} ne 32STUB]} {>

		emit {\b, for MS Windows}
<}

		if {[S string [I 60 lelong 0 + 0 248] 0 {} {} eq UPX0]} {>

		emit {\b, UPX compressed}
<}

		if {[S search [I 60 lelong 0 + 0 248] 0 {} 320 eq PEC2]} {>

		emit {\b, PECompact2 compressed}
<}

		if {[Sx search [I 60 lelong 0 + 0 248] 0 {} 320 eq UPX2]} {>

			if {[Sx string [I [R 16] lelong 0 + 1 -4] 0 {} {} eq PK\3\4]} {>

			emit {\b, ZIP self-extracting archive (Info-Zip)}
<}

<}

		if {[Sx search [I 60 lelong 0 + 0 248] 0 {} 320 eq .idata]} {>

			if {[Sx string [I [R 14] lelong 0 + 1 -4] 0 {} {} eq PK\3\4]} {>

			emit {\b, ZIP self-extracting archive (Info-Zip)}
<}

			if {[Sx string [I [R 14] lelong 0 + 1 -4] 0 {} {} eq ZZ0]} {>

			emit {\b, ZZip self-extracting archive}
<}

			if {[Sx string [I [R 14] lelong 0 + 1 -4] 0 {} {} eq ZZ1]} {>

			emit {\b, ZZip self-extracting archive}
<}

<}

		if {[Sx search [I 60 lelong 0 + 0 248] 0 {} 320 eq .rsrc]} {>

			if {[Sx string [I [R 15] lelong 0 + 1 -4] 0 {} {} eq a\\\4\5]} {>

			emit {\b, WinHKI self-extracting archive}
<}

			if {[Sx string [I [R 15] lelong 0 + 1 -4] 0 {} {} eq Rar!]} {>

			emit {\b, RAR self-extracting archive}
<}

			if {[Sx search [I [R 15] lelong 0 + 1 -4] 0 {} 12288 eq MSCF]} {>

			emit {\b, InstallShield self-extracting archive}
<}

			if {[Sx search [I [R 15] lelong 0 + 1 -4] 0 {} 32 eq Nullsoft]} {>

			emit {\b, Nullsoft Installer self-extracting archive}
<}

<}

		if {[Sx search [I 60 lelong 0 + 0 248] 0 {} 320 eq .data]} {>

			if {[Sx string [I [R 15] lelong 0 0 0 0] 0 {} {} eq WEXTRACT]} {>

			emit {\b, MS CAB-Installer self-extracting archive}
<}

<}

		if {[Sx search [I 60 lelong 0 + 0 248] 0 {} 320 eq .petite\0]} {>

		emit {\b, Petite compressed}

			if {[Nx byte [I 60 lelong 0 + 0 247] 0 0 {} {} x {}]} {>

				if {[Sx string [I [R 260] lelong 0 + 1 -4] 0 {} {} eq !sfx!]} {>

				emit {\b, ACE self-extracting archive}
<}

<}

<}

		if {[S search [I 60 lelong 0 + 0 248] 0 {} 320 eq .WISE]} {>

		emit {\b, WISE installer self-extracting archive}
<}

		if {[S search [I 60 lelong 0 + 0 248] 0 {} 320 eq .dz\0\0\0]} {>

		emit {\b, Dzip self-extracting archive}
<}

		if {[Sx search [R [I 60 lelong 0 + 0 248]] 0 {} 256 eq _winzip_]} {>

		emit {\b, ZIP self-extracting archive (WinZip)}
<}

		if {[Sx search [R [I 60 lelong 0 + 0 248]] 0 {} 256 eq SharedD]} {>

		emit {\b, Microsoft Installer self-extracting archive}
<}

		if {[S string 48 0 {} {} eq Inno]} {>

		emit {\b, InnoSetup self-extracting archive}
<}

	mime application/x-dosexec

<}

	if {[S string [I 60 lelong 0 0 0 0] 0 {} {} ne PE\0\0]} {>

	emit {MS-DOS executable}
	mime application/x-dosexec

<}

	if {[Sx string [I 60 lelong 0 0 0 0] 0 {} {} eq NE]} {>

	emit {\b, NE}

		switch -- [Nv byte [I 60 lelong 0 + 0 54] 0 {} {}] 1 {>;emit {for OS/2 1.x};<} 2 {>;emit {for MS Windows 3.x};<} 3 {>;emit {for MS-DOS};<} 4 {>;emit {for Windows 386};<} 5 {>;emit {for Borland Operating System Services};<} -127 {>;emit {for MS-DOS, Phar Lap DOS extender};<} 
<

		if {[S default [I 60 lelong 0 + 0 54] 0 {} {} x {}]} {>

			if {[N byte [I 60 lelong 0 + 0 54] 0 0 {} {} x {}]} {>

			emit {(unknown OS %x)}
<}

<}

		switch -- [Nv leshort [I 60 lelong 0 + 0 12] 0 & 32771] -32766 {>;emit (DLL);<} -32767 {>;emit (driver);<} 
<

		if {[Sx string [R [I [R 36] leshort 0 - 0 1]] 0 {} {} eq ARJSFX]} {>

		emit {\b, ARJ self-extracting archive}
<}

		if {[S search [I 60 lelong 0 + 0 112] 0 {} 128 eq WinZip(R)\ Self-Extractor]} {>

		emit {\b, ZIP self-extracting archive (WinZip)}
<}

	mime application/x-dosexec

<}

	if {[Sx string [I 60 lelong 0 0 0 0] 0 {} {} eq LX\0\0]} {>

	emit {\b, LX}

		if {[N leshort [I 60 lelong 0 + 0 10] 0 0 {} {} < 1]} {>

		emit {(unknown OS)}
<}

		switch -- [Nv leshort [I 60 lelong 0 + 0 10] 0 {} {}] 1 {>;emit {for OS/2};<} 2 {>;emit {for MS Windows};<} 3 {>;emit {for DOS};<} 
<

		if {[N leshort [I 60 lelong 0 + 0 10] 0 0 {} {} > 3]} {>

		emit {(unknown OS)}
<}

		if {[N lelong [I 60 lelong 0 + 0 16] 0 0 & 163840 == 32768]} {>

		emit (DLL)
<}

		if {[N lelong [I 60 lelong 0 + 0 16] 0 0 & 131072 > 0]} {>

		emit {(device driver)}
<}

		if {[N lelong [I 60 lelong 0 + 0 16] 0 0 & 768 == 768]} {>

		emit (GUI)
<}

		if {[N lelong [I 60 lelong 0 + 0 16] 0 0 & 164608 < 768]} {>

		emit (console)
<}

		switch -- [Nv leshort [I 60 lelong 0 + 0 8] 0 {} {}] 1 {>;emit i80286;<} 2 {>;emit i80386;<} 3 {>;emit i80486;<} 
<

		if {[Sx string [I 8 leshort 0 * 0 16] 0 {} {} eq emx]} {>

		emit {\b, emx}

			if {[Sx string [R 1] 0 {} {} x {}]} {>

			emit %s
<}

<}

		if {[Sx string [R [I [R 84] lelong 0 - 0 3]] 0 {} {} eq arjsfx]} {>

		emit {\b, ARJ self-extracting archive}
<}

	mime application/x-dosexec

<}

	if {[S string [I 60 lelong 0 0 0 0] 0 {} {} eq W3]} {>

	emit {\b, W3 for MS Windows}
	mime application/x-dosexec

<}

	if {[Sx string [I 60 lelong 0 0 0 0] 0 {} {} eq LE\0\0]} {>

	emit {\b, LE executable}

		switch -- [Nvx leshort [I 60 lelong 0 + 0 10] 0 {} {}] 1 {>;
			if {[S search 576 0 {} 256 eq DOS/4G]} {>

			emit {for MS-DOS, DOS4GW DOS extender}
<}

			if {[S search 576 0 {} 512 eq WATCOM\ C/C++]} {>

			emit {for MS-DOS, DOS4GW DOS extender}
<}

			if {[S search 1088 0 {} 256 eq CauseWay\ DOS\ Extender]} {>

			emit {for MS-DOS, CauseWay DOS extender}
<}

			if {[S search 64 0 {} 64 eq PMODE/W]} {>

			emit {for MS-DOS, PMODE/W DOS extender}
<}

			if {[S search 64 0 {} 64 eq STUB/32A]} {>

			emit {for MS-DOS, DOS/32A DOS extender (stub)}
<}

			if {[S search 64 0 {} 128 eq STUB/32C]} {>

			emit {for MS-DOS, DOS/32A DOS extender (configurable stub)}
<}

			if {[S search 64 0 {} 128 eq DOS/32A]} {>

			emit {for MS-DOS, DOS/32A DOS extender (embedded)}
<}

			if {[Nx lelong [R 36] 0 0 {} {} < 80]} {>

				if {[Sx string [I [R 76] lelong 0 0 0 0] 0 {} {} eq \xfc\xb8WATCOM]} {>

					if {[Sx search [R 0] 0 {} 8 eq 3\xdbf\xb9]} {>

					emit {\b, 32Lite compressed}
<}

<}

<}
;<} 2 {>;emit {for MS Windows};<} 3 {>;emit {for DOS};<} 4 {>;emit {for MS Windows (VxD)};<} 
<

		if {[Sx string [I [R 124] lelong 0 + 0 38] 0 {} {} eq UPX]} {>

		emit {\b, UPX compressed}
<}

		if {[Sx string [R [I [R 84] lelong 0 - 0 3]] 0 {} {} eq UNACE]} {>

		emit {\b, ACE self-extracting archive}
<}

	mime application/x-dosexec

<}

	if {[N lelong 60 0 0 {} {} > 536870912]} {>

		if {[N leshort [I 4 leshort 0 * 0 512] 0 0 {} {} != 332]} {>

		emit {\b, MZ for MS-DOS}
		mime application/x-dosexec

<}

<}

<}

if {[Nx long 2 0 0 {} {} != 0]} {>

	if {[Nx leshort 24 0 0 {} {} < 64]} {>

		if {[Nx leshort [I 4 leshort 0 * 0 512] 0 0 {} {} != 332]} {>

			if {[Sx string [R [I 2 leshort 0 - 0 514]] 0 {} {} ne LE]} {>

				if {[Sx string [R -2] 0 {} {} ne BW]} {>

				emit {\b, MZ for MS-DOS}
				mime application/x-dosexec

<}

<}

			if {[Sx string [R [I 2 leshort 0 - 0 514]] 0 {} {} eq LE]} {>

			emit {\b, LE}

				if {[S search 576 0 {} 256 eq DOS/4G]} {>

				emit {for MS-DOS, DOS4GW DOS extender}
<}

<}

			if {[Sx string [R [I 2 leshort 0 - 0 514]] 0 {} {} eq BW]} {>

				if {[S search 576 0 {} 256 eq DOS/4G]} {>

				emit {\b, LE for MS-DOS, DOS4GW DOS extender (embedded)}
<}

				if {[S search 576 0 {} 256 ne DOS/4G]} {>

				emit {\b, BW collection for MS-DOS}
<}

<}

<}

<}

<}

if {[Nx leshort [I 4 leshort 0 * 0 512] 0 0 {} {} == 332]} {>

emit {\b, COFF}

	if {[S string [I 8 leshort 0 * 0 16] 0 {} {} eq go32stub]} {>

	emit {for MS-DOS, DJGPP go32 DOS extender}
<}

	if {[Sx string [I 8 leshort 0 * 0 16] 0 {} {} eq emx]} {>

		if {[Sx string [R 1] 0 {} {} x {}]} {>

		emit {for DOS, Win or OS/2, emx %s}
<}

<}

	if {[Nx byte [R [I [R 66] lelong 0 - 0 3]] 0 0 {} {} x {}]} {>

		if {[Sx string [R 38] 0 {} {} eq UPX]} {>

		emit {\b, UPX compressed}
<}

<}

	if {[Sx search [R 44] 0 {} 160 eq .text]} {>

		if {[Nx lelong [R 11] 0 0 {} {} < 8192]} {>

			if {[Nx lelong [R 0] 0 0 {} {} > 24576]} {>

			emit {\b, 32lite compressed}
<}

<}

<}

mime application/x-dosexec

<}

if {[S string [I 8 leshort 0 * 0 16] 0 {} {} eq \$WdX]} {>

emit {\b, WDos/X DOS extender}
<}

if {[S string 53 0 {} {} eq \x8e\xc0\xb9\x08\x00\xf3\xa5\x4a\x75\xeb\x8e\xc3\x8e\xd8\x33\xff\xbe\x30\x00\x05]} {>

emit {\b, aPack compressed}
<}

if {[S string 231 0 {} {} eq LH/2\ ]} {>

emit {Self-Extract \b, %s}
<}

if {[S string 28 0 {} {} eq UC2X]} {>

emit {\b, UCEXE compressed}
<}

if {[S string 28 0 {} {} eq WWP\ ]} {>

emit {\b, WWPACK compressed}
<}

if {[S string 28 0 {} {} eq RJSX]} {>

emit {\b, ARJ self-extracting archive}
<}

if {[S string 28 0 {} {} eq diet]} {>

emit {\b, diet compressed}
<}

if {[S string 28 0 {} {} eq LZ09]} {>

emit {\b, LZEXE v0.90 compressed}
<}

if {[S string 28 0 {} {} eq LZ91]} {>

emit {\b, LZEXE v0.91 compressed}
<}

if {[S string 28 0 {} {} eq tz]} {>

emit {\b, TinyProg compressed}
<}

if {[S string 30 0 {} {} eq Copyright\ 1989-1990\ PKWARE\ Inc.]} {>

emit {Self-extracting PKZIP archive}
mime application/zip

<}

if {[S string 30 0 {} {} eq PKLITE\ Copr.]} {>

emit {Self-extracting PKZIP archive}
mime application/zip

<}

if {[S search 32 0 {} 224 eq aRJsfX]} {>

emit {\b, ARJ self-extracting archive}
<}

if {[S string 32 0 {} {} eq AIN]} {>

	if {[S string 35 0 {} {} eq 2]} {>

	emit {\b, AIN 2.x compressed}
<}

	if {[S string 35 0 {} {} < 2]} {>

	emit {\b, AIN 1.x compressed}
<}

	if {[S string 35 0 {} {} > 2]} {>

	emit {\b, AIN 1.x compressed}
<}

<}

if {[S string 36 0 {} {} eq LHa's\ SFX]} {>

emit {\b, LHa self-extracting archive}
mime application/x-lha

<}

if {[S string 36 0 {} {} eq LHA's\ SFX]} {>

emit {\b, LHa self-extracting archive}
mime application/x-lha

<}

if {[S string 36 0 {} {} eq \ \$ARX]} {>

emit {\b, ARX self-extracting archive}
<}

if {[S string 36 0 {} {} eq \ \$LHarc]} {>

emit {\b, LHarc self-extracting archive}
<}

if {[S string 32 0 {} {} eq SFX\ by\ LARC]} {>

emit {\b, LARC self-extracting archive}
<}

if {[S string 64 0 {} {} eq aPKG]} {>

emit {\b, aPackage self-extracting archive}
<}

if {[S string 100 0 {} {} eq W\ Collis\0\0]} {>

emit {\b, Compack compressed}
<}

if {[Sx string 122 0 {} {} eq Windows\ self-extracting\ ZIP]} {>

emit {\b, ZIP self-extracting archive}

	if {[Sx search [R 244] 0 {} 320 eq \x0\x40\x1\x0]} {>

		if {[Sx string [I [R 0] lelong 0 + 1 4] 0 {} {} eq MSCF]} {>

		emit {\b, WinHKI CAB self-extracting archive}
<}

<}

<}

if {[S string 1638 0 {} {} eq -lh5-]} {>

emit {\b, LHa self-extracting archive v2.13S}
<}

if {[S string 96392 0 {} {} eq Rar!]} {>

emit {\b, RAR self-extracting archive}
<}

if {[Nx long [I 4 leshort 0 * 0 512] 0 0 {} {} x {}]} {>

	if {[Nx byte [R [I 2 leshort 0 - 0 517]] 0 0 {} {} x {}]} {>

		if {[Sx string [R 0] 0 {} {} eq PK\3\4]} {>

		emit {\b, ZIP self-extracting archive}
<}

		if {[Sx string [R 0] 0 {} {} eq Rar!]} {>

		emit {\b, RAR self-extracting archive}
<}

		if {[Sx string [R 0] 0 {} {} eq !\x11]} {>

		emit {\b, AIN 2.x self-extracting archive}
<}

		if {[Sx string [R 0] 0 {} {} eq !\x12]} {>

		emit {\b, AIN 2.x self-extracting archive}
<}

		if {[Sx string [R 0] 0 {} {} eq !\x17]} {>

		emit {\b, AIN 1.x self-extracting archive}
<}

		if {[Sx string [R 0] 0 {} {} eq !\x18]} {>

		emit {\b, AIN 1.x self-extracting archive}
<}

		if {[Sx search [R 7] 0 {} 400 eq **ACE**]} {>

		emit {\b, ACE self-extracting archive}
<}

		if {[Sx search [R 0] 0 {} 1152 eq UC2SFX\ Header]} {>

		emit {\b, UC2 self-extracting archive}
<}

<}

<}

if {[S search [I 8 leshort 0 * 0 16] 0 {} 32 eq PKSFX]} {>

emit {\b, ZIP self-extracting archive (PKZIP)}
<}

if {[S string 49801 0 {} {} eq \x79\xff\x80\xff\x76\xff]} {>

emit {\b, CODEC archive v3.21}

	if {[N leshort 49824 0 0 {} {} == 1]} {>

	emit {\b, 1 file}
<}

	if {[N leshort 49824 0 0 {} {} > 1]} {>

	emit {\b, %u files}
<}

<}

<}
} {
if {[Sx string 0 0 b {} eq KCF]} {>

emit {FreeDOS KEYBoard Layout collection}

if {[N leshort 3 0 0 {} {} x {}]} {>

emit {\b, version 0x%x}
<}

if {[Nx byte 6 0 0 {} {} > 0]} {>

	if {[S string 7 0 {} {} > \0]} {>

	emit {\b, author=%-.14s}
<}

	if {[Sx search 7 0 {} 254 eq \xff]} {>

	emit {\b, info=}

		if {[Sx string [R 0] 0 {} {} x {}]} {>

		emit {\b%-.15s}
<}

<}

<}

<}
} {
if {[S string 0 0 b {} eq KLF]} {>

emit {FreeDOS KEYBoard Layout file}

if {[N leshort 3 0 0 {} {} x {}]} {>

emit {\b, version 0x%x}
<}

if {[N byte 5 0 0 {} {} > 0]} {>

	if {[S string 8 0 {} {} x {}]} {>

	emit {\b, name=%-.2s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \xffKEYB\ \ \ \0\0\0\0]} {>

if {[S string 12 0 {} {} eq \0\0\0\0`\004\360]} {>

emit {MS-DOS KEYBoard Layout file}
<}

<}
} {
if {[N lequad 0 0 0 & 8388071129087 == 4294967295]} {>

emit {DOS executable (}

if {[S search 40 0 {} 7 eq UPX!]} {>

emit {\bUPX compressed }
<}

switch -- [Nv leshort 4 0 & 32768] 0 {>;emit {\bblock device driver};<} -32768 {>;emit {\b}

	if {[N leshort 4 0 0 & 8 == 8]} {>

	emit {\bclock }
<}

	if {[N leshort 4 0 0 & 16 == 16]} {>

	emit {\bfast }
<}

	if {[N leshort 4 0 0 & 3 > 0]} {>

	emit {\bstandard }

		if {[N leshort 4 0 0 & 1 == 1]} {>

		emit {\binput}
<}

		if {[N leshort 4 0 0 & 3 == 3]} {>

		emit {\b/}
<}

		if {[N leshort 4 0 0 & 2 == 2]} {>

		emit {\boutput }
<}

<}

	if {[N leshort 4 0 0 & 32768 == 32768]} {>

	emit {\bcharacter device driver}
<}
;<} 0 {>;
	if {[N leshort 4 0 0 & 2 == 2]} {>

	emit {\b,32-bit sector-}
<}
;<} -32768 {>;
	if {[N leshort 4 0 0 & 8192 == 8192]} {>

	emit {\b,until busy-}
<}
;<} -32768 {>;
	if {[N leshort 4 0 0 & 26688 > 0]} {>

	emit {\bsupport}
<}
;<} 0 {>;
	if {[N leshort 4 0 0 & 18498 > 0]} {>

	emit {\bsupport}
<}
;<} 
<

if {[N byte 0 0 0 {} {} x {}]} {>

	if {[S search 40 0 {} 7 eq UPX!]} {>

<}

	if {[S default 40 0 {} {} x {}]} {>

		if {[N byte 12 0 0 {} {} > 39]} {>

		emit {\b }

			if {[N byte 10 0 0 {} {} > 32]} {>

				if {[N byte 10 0 0 {} {} != 46]} {>

					if {[N byte 10 0 0 {} {} != 42]} {>

					emit {\b%c}
<}

<}

<}

			if {[N byte 11 0 0 {} {} > 32]} {>

				if {[N byte 11 0 0 {} {} != 46]} {>

				emit {\b%c}
<}

<}

			if {[N byte 12 0 0 {} {} > 32]} {>

				if {[N byte 12 0 0 {} {} != 57]} {>

					if {[N byte 12 0 0 {} {} != 46]} {>

					emit {\b%c}
<}

<}

<}

<}

		if {[N byte 13 0 0 {} {} > 32]} {>

			if {[N byte 13 0 0 {} {} != 46]} {>

			emit {\b%c}
<}

			if {[N byte 14 0 0 {} {} > 32]} {>

				if {[N byte 14 0 0 {} {} != 46]} {>

				emit {\b%c}
<}

<}

			if {[N byte 15 0 0 {} {} > 32]} {>

				if {[N byte 15 0 0 {} {} != 46]} {>

				emit {\b%c}
<}

<}

			if {[N byte 16 0 0 {} {} > 32]} {>

				if {[N byte 16 0 0 {} {} != 46]} {>

					if {[N byte 16 0 0 {} {} < 203]} {>

					emit {\b%c}
<}

<}

<}

			if {[N byte 17 0 0 {} {} > 32]} {>

				if {[N byte 17 0 0 {} {} != 46]} {>

					if {[N byte 17 0 0 {} {} < 144]} {>

					emit {\b%c}
<}

<}

<}

<}

		if {[N leshort 4 0 0 & 32768 == 32768]} {>

			if {[N byte 12 0 0 {} {} < 47]} {>

				if {[S string 22 0 {} {} > \0]} {>

				emit {\b%-.5s}
<}

<}

<}

<}

<}

if {[N leshort 4 0 0 & 64 == 64]} {>

emit {\b,IOCTL-}
<}

if {[N leshort 4 0 0 & 2048 == 2048]} {>

emit {\b,close media-}
<}

if {[N leshort 4 0 0 & 16384 == 16384]} {>

emit {\b,control strings-}
<}

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b)}
<}

<}
} {
if {[N beshort 0 0 0 & 60301 > 60160]} {>

if {[N byte 0 0 0 {} {} == 235]} {>

	if {[N leshort 510 0 0 {} {} == 43605]} {>

	emit {DOS executable (COM), boot code}
<}

	if {[S string 85 0 {} {} eq UPX]} {>

	emit {DOS executable (COM), UPX compressed}
<}

	if {[S string 4 0 {} {} eq \ \$ARX]} {>

	emit {DOS executable (COM), ARX self-extracting archive}
<}

	if {[S string 4 0 {} {} eq \ \$LHarc]} {>

	emit {DOS executable (COM), LHarc self-extracting archive}
<}

	if {[S string 526 0 {} {} eq SFX\ by\ LARC]} {>

	emit {DOS executable (COM), LARC self-extracting archive}
<}

<}

<}
} {
if {[S string 0 0 b {} eq \x81\xfc]} {>

if {[S string 4 0 {} {} eq \x77\x02\xcd\x20\xb9]} {>

	if {[S string 36 0 {} {} eq UPX!]} {>

	emit {FREE-DOS executable (COM), UPX compressed}
<}

<}

<}
} {
if {[S string 252 0 {} {} eq Must\ have\ DOS\ version]} {>

emit {DR-DOS executable (COM)}
<}
} {
if {[S string 34 0 {} {} eq UPX!]} {>

emit {FREE-DOS executable (COM), UPX compressed}
<}
} {
if {[S string 35 0 {} {} eq UPX!]} {>

emit {FREE-DOS executable (COM), UPX compressed}
<}
} {
if {[S string 2 0 {} {} eq \xcd\x21]} {>

emit {COM executable for DOS}
<}
} {
if {[S string 4 0 {} {} eq \xcd\x21]} {>

emit {COM executable for DOS}
<}
} {
if {[S string 5 0 {} {} eq \xcd\x21]} {>

emit {COM executable for DOS}
<}
} {
if {[S string 7 0 {} {} eq \xcd\x21]} {>

if {[N byte 0 0 0 {} {} != 184]} {>

emit {COM executable for DOS}
<}

<}
} {
if {[S string 10 0 {} {} eq \xcd\x21]} {>

if {[S string 5 0 {} {} ne \xcd\x21]} {>

emit {COM executable for DOS}
<}

<}
} {
if {[S string 13 0 {} {} eq \xcd\x21]} {>

emit {COM executable for DOS}
<}
} {
if {[S string 18 0 {} {} eq \xcd\x21]} {>

emit {COM executable for MS-DOS}
<}
} {
if {[S string 23 0 {} {} eq \xcd\x21]} {>

emit {COM executable for MS-DOS}
<}
} {
if {[S string 30 0 {} {} eq \xcd\x21]} {>

emit {COM executable for MS-DOS}
<}
} {
if {[S string 70 0 {} {} eq \xcd\x21]} {>

emit {COM executable for DOS}
<}
} {
if {[S search 6 0 {} 10 eq \xfc\x57\xf3\xa5\xc3]} {>

emit {COM executable for MS-DOS}
<}
} {
if {[S search 6 0 {} 10 eq \xfc\x57\xf3\xa4\xc3]} {>

emit {COM executable for DOS}

if {[S search 24 0 {} 16 eq \x50\xa4\xff\xd5\x73]} {>

emit {\b, aPack compressed}
<}

<}
} {
if {[S string 60 0 {} {} eq W\ Collis\0\0]} {>

emit {COM executable for MS-DOS, Compack compressed}
<}
} {
if {[S string 0 0 b {} eq LZ]} {>

emit {MS-DOS executable (built-in)}
<}
} {
if {[S string 0 0 b {} eq \320\317\021\340\241\261\032\341AAFB\015\000OM\006\016\053\064\001\001\001\377]} {>

emit {AAF legacy file using MS Structured Storage}

switch -- [Nv byte 30 0 {} {}] 9 {>;emit {(512B sectors)};<} 12 {>;emit {(4kB sectors)};<} 
<

<}
} {
if {[S string 0 0 b {} eq \320\317\021\340\241\261\032\341\001\002\001\015\000\002\000\000\006\016\053\064\003\002\001\001]} {>

emit {AAF file using MS Structured Storage}

switch -- [Nv byte 30 0 {} {}] 9 {>;emit {(512B sectors)};<} 12 {>;emit {(4kB sectors)};<} 
<

<}
} {
if {[S string 2080 0 {} {} eq Microsoft\ Word\ 6.0\ Document]} {>

emit %s
mime application/msword

<}
} {
if {[S string 2080 0 {} {} eq Documento\ Microsoft\ Word\ 6]} {>

emit {Spanish Microsoft Word 6 document data}
mime application/msword

<}
} {
if {[S string 2112 0 {} {} eq MSWordDoc]} {>

emit {Microsoft Word document data}
mime application/msword

<}
} {
if {[S string 0 0 b {} eq PO^Q`]} {>

emit {Microsoft Word 6.0 Document}
mime application/msword

<}
} {
if {[S string 0 0 b {} eq \376\067\0\043]} {>

emit {Microsoft Office Document}
mime application/msword

<}
} {
if {[S string 0 0 b {} eq \333\245-\0\0\0]} {>

emit {Microsoft Office Document}
mime application/msword

<}
} {
if {[S string 512 0 b {} eq \354\245\301]} {>

emit {Microsoft Word Document}
mime application/msword

<}
} {
if {[S string 0 0 b {} eq \xDB\xA5\x2D\x00]} {>

emit {Microsoft WinWord 2.0 Document}
mime application/msword

<}
} {
if {[S string 2080 0 {} {} eq Microsoft\ Excel\ 5.0\ Worksheet]} {>

emit %s
mime application/vnd.ms-excel

<}
} {
if {[S string 0 0 b {} eq \xDB\xA5\x2D\x00]} {>

emit {Microsoft WinWord 2.0 Document}
mime application/msword

<}
} {
if {[S string 2080 0 {} {} eq Foglio\ di\ lavoro\ Microsoft\ Exce]} {>

emit %s
mime application/vnd.ms-excel

<}
} {
if {[S string 2114 0 {} {} eq Biff5]} {>

emit {Microsoft Excel 5.0 Worksheet}
mime application/vnd.ms-excel

<}
} {
if {[S string 2121 0 {} {} eq Biff5]} {>

emit {Microsoft Excel 5.0 Worksheet}
mime application/vnd.ms-excel

<}
} {
if {[S string 0 0 b {} eq \x09\x04\x06\x00\x00\x00\x10\x00]} {>

emit {Microsoft Excel Worksheet}
mime application/vnd.ms-excel

<}
} {
if {[S string 0 0 b {} eq WordPro\0]} {>

emit {Lotus WordPro}
mime application/vnd.lotus-wordpro

<}
} {
if {[S string 0 0 b {} eq WordPro\r\373]} {>

emit {Lotus WordPro}
mime application/vnd.lotus-wordpro

<}
} {
if {[S string 0 0 {} {} eq \x71\xa8\x00\x00\x01\x02]} {>

if {[S string 12 0 {} {} eq Stirling\ Technologies,]} {>

emit {InstallShield Uninstall Script}
<}

<}
} {
if {[S string 0 0 b {} eq Nullsoft\ AVS\ Preset\ ]} {>

emit {Winamp plug in}
<}
} {
if {[S string 0 0 b {} eq \327\315\306\232]} {>

emit {ms-windows metafont .wmf}
<}
} {
if {[S string 0 0 b {} eq \002\000\011\000]} {>

emit {ms-windows metafont .wmf}
<}
} {
if {[S string 0 0 b {} eq \001\000\011\000]} {>

emit {ms-windows metafont .wmf}
<}
} {
if {[S string 0 0 b {} eq \003\001\001\004\070\001\000\000]} {>

emit {tz3 ms-works file}
<}
} {
if {[S string 0 0 b {} eq \003\002\001\004\070\001\000\000]} {>

emit {tz3 ms-works file}
<}
} {
if {[S string 0 0 b {} eq \003\003\001\004\070\001\000\000]} {>

emit {tz3 ms-works file}
<}
} {
if {[S string 0 0 {} {} eq \211\000\077\003\005\000\063\237\127\065\027\266\151\064\005\045\101\233\021\002]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 {} {} eq \211\000\077\003\005\000\063\237\127\066\027\266\151\064\005\045\101\233\021\002]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 {} {} eq \211\000\077\003\005\000\063\237\127\067\027\266\151\064\005\045\101\233\021\002]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 {} {} eq \211\000\077\003\005\000\063\237\127\070\027\266\151\064\005\045\101\233\021\002]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 {} {} eq \211\000\077\003\005\000\063\237\127\071\027\266\151\064\005\045\101\233\021\002]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 {} {} eq \211\000\225\003\005\000\062\122\207\304\100\345\042]} {>

emit {PGP sig}
<}
} {
if {[S string 0 0 b {} eq MDIF\032\000\010\000\000\000\372\046\100\175\001\000\001\036\001\000]} {>

emit {MS Windows special zipped file}
<}
} {
if {[S string 0 0 b {} eq \102\101\050\000\000\000\056\000\000\000\000\000\000\000]} {>

emit {Icon for MS Windows}
<}
} {
if {[S string 0 0 b {} eq PK\010\010BGI]} {>

emit {Borland font }

if {[S string 4 0 {} {} > \0]} {>

emit %s
<}

<}
} {
if {[S string 0 0 b {} eq pk\010\010BGI]} {>

emit {Borland device }

if {[S string 4 0 {} {} > \0]} {>

emit %s
<}

<}
} {
switch -- [Nv belong 0 0 & 4294902015] 65554 {>;emit {PFM data}

if {[S string 4 0 {} {} eq \000\000]} {>

<}

if {[S string 6 0 {} {} > \060]} {>

emit {- %s}
<}
;<} 65538 {>;emit {PFM data}

if {[S string 4 0 {} {} eq \000\000]} {>

<}

if {[S string 6 0 {} {} > \060]} {>

emit {- %s}
<}
;<} 
<
} {
if {[S string 9 0 {} {} eq GERBILDOC]} {>

emit {First Choice document}
<}
} {
if {[S string 9 0 {} {} eq GERBILDB]} {>

emit {First Choice database}
<}
} {
if {[S string 9 0 {} {} eq GERBILCLIP]} {>

emit {First Choice database}
<}
} {
if {[S string 0 0 {} {} eq GERBIL]} {>

emit {First Choice device file}
<}
} {
if {[S string 9 0 {} {} eq RABBITGRAPH]} {>

emit {RabbitGraph file}
<}
} {
if {[S string 0 0 {} {} eq DCU1]} {>

emit {Borland Delphi .DCU file}
<}
} {
if {[S string 0 0 {} {} eq !<spell>]} {>

emit {MKS Spell hash list (old format)}
<}
} {
if {[S string 0 0 {} {} eq !<spell2>]} {>

emit {MKS Spell hash list}
<}
} {
if {[S string 0 0 {} {} eq TPF0]} {>

if {[S pstring 4 0 {} {} > \0]} {>

emit {Delphi compiled form '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq PMCC]} {>

emit {Windows 3.x .GRP file}
<}
} {
if {[S string 1 0 {} {} eq RDC-meg]} {>

emit {MegaDots }

if {[N byte 8 0 0 {} {} > 47]} {>

emit {version %c}
<}

if {[N byte 9 0 0 {} {} > 47]} {>

emit {\b.%c file}
<}

<}
} {
if {[Sx string 369 0 {} {} eq MICROSOFT\ PIFEX\0]} {>

emit {Windows Program Information File}

if {[S string 36 0 {} {} > \0]} {>

emit {\b for %.63s}
<}

if {[S string 101 0 {} {} > \0]} {>

emit {\b, directory=%.64s}
<}

if {[S string 165 0 {} {} > \0]} {>

emit {\b, parameters=%.64s}
<}

if {[Sx search 391 0 {} 2901 eq WINDOWS\ VMM\ 4.0\0]} {>

	if {[Nx byte [R 94] 0 0 {} {} > 0]} {>

		if {[Sx string [R -1] 0 {} {} < PIFMGR.DLL]} {>

		emit {\b, icon=%s}
<}

		if {[Sx string [R -1] 0 {} {} > PIFMGR.DLL]} {>

		emit {\b, icon=%s}
<}

<}

	if {[Nx byte [R 240] 0 0 {} {} > 0]} {>

		if {[Sx string [R -1] 0 {} {} < Terminal]} {>

		emit {\b, font=%.32s}
<}

		if {[Sx string [R -1] 0 {} {} > Terminal]} {>

		emit {\b, font=%.32s}
<}

<}

	if {[Nx byte [R 272] 0 0 {} {} > 0]} {>

		if {[Sx string [R -1] 0 {} {} < Lucida\ Console]} {>

		emit {\b, TrueTypeFont=%.32s}
<}

		if {[Sx string [R -1] 0 {} {} > Lucida\ Console]} {>

		emit {\b, TrueTypeFont=%.32s}
<}

<}

<}

if {[S search 391 0 {} 2901 eq WINDOWS\ NT\ \ 3.1\0]} {>

emit {\b, Windows NT-style}
<}

if {[S search 391 0 {} 2901 eq CONFIG\ \ SYS\ 4.0\0]} {>

emit {\b +CONFIG.SYS}
<}

if {[S search 391 0 {} 2901 eq AUTOEXECBAT\ 4.0\0]} {>

emit {\b +AUTOEXEC.BAT}
<}

mime application/x-dosexec

<}
} {
if {[S string 0 0 {} {} eq NG\0\001]} {>

if {[N lelong 2 0 0 {} {} == 256]} {>

emit {Norton Guide}

	if {[S string 8 0 {} {} > \0]} {>

	emit {"%-.40s"}
<}

	if {[S string 48 0 {} {} > \0]} {>

	emit {\b, %-.66s}
<}

	if {[S string 114 0 {} {} > \0]} {>

	emit %-.66s
<}

<}

<}
} {
if {[S string 0 0 b {} eq ITSF\003\000\000\000\x60\000\000\000]} {>

emit {MS Windows HtmlHelp Data}
<}
} {
if {[S string 2 0 b {} eq GFA-BASIC3]} {>

emit {GFA-BASIC 3 data}
<}
} {
if {[S string 0 0 b {} eq MSCF\0\0\0\0]} {>

emit {Microsoft Cabinet archive data}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, %u bytes}
<}

if {[N leshort 28 0 0 {} {} == 1]} {>

emit {\b, 1 file}
<}

if {[N leshort 28 0 0 {} {} > 1]} {>

emit {\b, %u files}
<}

mime application/vnd.ms-cab-compressed

<}
} {
if {[S string 0 0 b {} eq ISc(]} {>

emit {InstallShield Cabinet archive data}

if {[N byte 5 0 0 & 240 == 96]} {>

emit {version 6,}
<}

if {[N byte 5 0 0 & 240 != 96]} {>

emit {version 4/5,}
<}

if {[N lelong [I 12 lelong 0 + 0 40] 0 0 {} {} x {}]} {>

emit {%u files}
<}

<}
} {
if {[S string 0 0 b {} eq MSCE\0\0\0\0]} {>

emit {Microsoft WinCE install header}

switch -- [Nv lelong 20 0 {} {}] 0 {>;emit {\b, architecture-independent};<} 103 {>;emit {\b, Hitachi SH3};<} 104 {>;emit {\b, Hitachi SH4};<} 2577 {>;emit {\b, StrongARM};<} 4000 {>;emit {\b, MIPS R4000};<} 10003 {>;emit {\b, Hitachi SH3};<} 10004 {>;emit {\b, Hitachi SH3E};<} 10005 {>;emit {\b, Hitachi SH4};<} 70001 {>;emit {\b, ARM 7TDMI};<} 
<

if {[N leshort 52 0 0 {} {} == 1]} {>

emit {\b, 1 file}
<}

if {[N leshort 52 0 0 {} {} > 1]} {>

emit {\b, %u files}
<}

if {[N leshort 56 0 0 {} {} == 1]} {>

emit {\b, 1 registry entry}
<}

if {[N leshort 56 0 0 {} {} > 1]} {>

emit {\b, %u registry entries}
<}

<}
} {
if {[S string 0 0 b {} eq \320\317\021\340\241\261\032\341]} {>

emit {Microsoft Office Document}

if {[S string 546 0 {} {} eq bjbj]} {>

emit {Microsoft Word Document}
mime application/msword

<}

if {[S string 546 0 {} {} eq jbjb]} {>

emit {Microsoft Word Document}
mime application/msword

<}

<}
} {
if {[S string 0 0 b {} eq \224\246\056]} {>

emit {Microsoft Word Document}
mime application/msword

<}
} {
if {[S string 512 0 {} {} eq R\0o\0o\0t\0\ \0E\0n\0t\0r\0y]} {>

emit {Microsoft Word Document}
mime application/msword

<}
} {
if {[S string 0 0 b {} eq \$RBU]} {>

if {[S string 23 0 {} {} eq Dell]} {>

emit {%s system BIOS}
<}

if {[N byte 5 0 0 {} {} == 2]} {>

	if {[N byte 48 0 0 {} {} x {}]} {>

	emit {version %d.}
<}

	if {[N byte 49 0 0 {} {} x {}]} {>

	emit {\b%d.}
<}

	if {[N byte 50 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

<}

if {[N byte 5 0 0 {} {} < 2]} {>

	if {[S string 48 0 {} {} x {}]} {>

	emit {version %.3s}
<}

<}

<}
} {
if {[S string 0 0 b {} eq DDS\040\174\000\000\000]} {>

emit {Microsoft DirectDraw Surface (DDS),}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {%d x}
<}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit %d,
<}

if {[S string 84 0 {} {} x {}]} {>

emit %.4s
<}

<}
} {
if {[S string 0 0 b {} eq ITOLITLS]} {>

emit {Microsoft Reader eBook Data}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, version %u}
mime application/x-ms-reader

<}

<}
} {
if {[S string 0 0 b {} eq B000FF\n]} {>

emit {Windows Embedded CE binary image}
<}
} {
if {[S string 0 0 b {} eq MSWIM\000\000\000]} {>

emit {Windows imaging (WIM) image}
<}
} {
if {[S string 0 0 b {} eq WLPWM\000\000\000]} {>

emit {Windows imaging (WIM) image, wimlib pipable format}
<}
} {
if {[S string 0 0 {} {} eq \xfc\x03\x00]} {>

emit {Mallard BASIC program data (v1.11)}
<}
} {
if {[S string 0 0 {} {} eq \xfc\x04\x00]} {>

emit {Mallard BASIC program data (v1.29+)}
<}
} {
if {[S string 0 0 {} {} eq \xfc\x03\x01]} {>

emit {Mallard BASIC protected program data (v1.11)}
<}
} {
if {[S string 0 0 {} {} eq \xfc\x04\x01]} {>

emit {Mallard BASIC protected program data (v1.29+)}
<}
} {
if {[S string 0 0 {} {} eq MIOPEN]} {>

emit {Mallard BASIC Jetsam data}
<}
} {
if {[S string 0 0 {} {} eq Jetsam0]} {>

emit {Mallard BASIC Jetsam index data}
<}
} {
if {[S string 0 0 {} {} eq \211\277\036\203]} {>

emit {Virtutech CRAFF}

if {[N belong 4 0 0 {} {} x {}]} {>

emit v%d
<}

switch -- [Nv belong 20 0 {} {}] 0 {>;emit uncompressed;<} 1 {>;emit bzipp2ed;<} 2 {>;emit gzipped;<} 
<

if {[N belong 24 0 0 {} {} == 0]} {>

emit {not clean}
<}

<}
} {
if {[S string 0 0 {} {} eq \064\024\012\000\035\000\000\000]} {>

emit {Mathematica version 2 notebook}
ext mb

<}
} {
if {[S string 0 0 {} {} eq \064\024\011\000\035\000\000\000]} {>

emit {Mathematica version 2 notebook}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\n\n::\[\011frontEndVersion\ =\ ]} {>

emit {Mathematica notebook}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\r\r::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\r\n\r\n::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\015]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\n\r\n\r::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\r::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\r\n::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\n\n::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*^\n::\[\011]} {>

emit {Mathematica notebook version 2.x}
ext mb

<}
} {
if {[S string 0 0 {} {} eq (*This\ is\ a\ Mathematica\ binary\ ]} {>

emit {Mathematica binary file}

if {[S string 88 0 {} {} > \0]} {>

emit {from %s}
<}

<}
} {
if {[S string 0 0 {} {} eq MMAPBF\000\001\000\000\000\203\000\001\000]} {>

emit {Mathematica PBF (fonts I think)}
<}
} {
if {[S string 4 0 {} {} eq \ A~]} {>

emit {MAthematica .ml file}
<}
} {
if {[S string 0 0 {} {} eq (***********************]} {>

emit {Mathematica 3.0 notebook}
<}
} {
if {[S string 0 0 {} {} eq MATLAB]} {>

emit {Matlab v5 mat-file}

switch -- [Nv short 126 0 {} {}] 18765 {>;emit {(big endian)}

	if {[N beshort 124 0 0 {} {} x {}]} {>

	emit {version 0x%04x}
<}
;<} 19785 {>;emit {(little endian)}

	if {[N leshort 124 0 0 {} {} x {}]} {>

	emit {version 0x%04x}
<}
;<} 
<

<}
} {
if {[Sx string 60 0 {} {} eq RINEX]} {>

if {[Sx search 80 0 {} 256 eq XXRINEXB]} {>

emit {RINEX Data, GEO SBAS Broadcast}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/broadcast

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXD]} {>

emit {RINEX Data, Observation (Hatanaka comp)}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/observation

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXC]} {>

emit {RINEX Data, Clock}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/clock

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXH]} {>

emit {RINEX Data, GEO SBAS Navigation}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/navigation

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXG]} {>

emit {RINEX Data, GLONASS Navigation}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/navigation

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXL]} {>

emit {RINEX Data, Galileo Navigation}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/navigation

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXM]} {>

emit {RINEX Data, Meteorological}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/meteorological

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXN]} {>

emit {RINEX Data, Navigation	}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/navigation

<}

<}

if {[Sx search 80 0 {} 256 eq XXRINEXO]} {>

emit {RINEX Data, Observation}

	if {[Sx string [R 32] 0 {} {} x {}]} {>

	emit {\b, date %15.15s}
<}

	if {[S string 5 0 {} {} x {}]} {>

	emit {\b, version %6.6s}
	mime rinex/observation

<}

<}

<}
} {
if {[S string 0 0 {} {} eq GRIB]} {>

switch -- [Nv byte 7 0 {} {}] 1 {>;emit {Gridded binary (GRIB) version 1};<} 2 {>;emit {Gridded binary (GRIB) version 2};<} 
<

<}
} {
if {[N byte 0 0 0 {} {} > 0]} {>

if {[N byte 0 0 0 {} {} < 9]} {>

	if {[N belong 16 0 0 & 4261474544 == 12336]} {>

		if {[N byte 0 0 0 {} {} < 10]} {>

			if {[N beshort 2 0 0 {} {} < 10]} {>

				if {[S regex 18 0 {} {} eq \[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]]} {>

					if {[N byte 0 0 0 {} {} < 10]} {>

					emit {Infocom (Z-machine %d,}

						if {[N beshort 2 0 0 {} {} < 10]} {>

						emit {Release %d /}

							if {[S string 18 0 {} {} > \0]} {>

							emit {Serial %.6s)}
							mime application/x-zmachine

<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq Glul]} {>

emit {Glulx game data}

if {[N beshort 4 0 0 {} {} x {}]} {>

emit {(Version %d}

	if {[N byte 6 0 0 {} {} x {}]} {>

	emit {\b.%d}
<}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {\b.%d)}
<}

<}

if {[S string 36 0 {} {} eq Info]} {>

emit {Compiled by Inform}
mime application/x-glulx

<}

<}
} {
if {[S string 0 0 {} {} eq TADS2\ bin]} {>

emit TADS

if {[N belong 9 0 0 {} {} != 168630784]} {>

emit {game data, CORRUPTED}
<}

if {[N belong 9 0 0 {} {} == 168630784]} {>

	if {[S string 13 0 {} {} > \0]} {>

	emit {%s game data}
	mime application/x-tads

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TADS2\ rsc]} {>

emit TADS

if {[N belong 9 0 0 {} {} != 168630784]} {>

emit {resource data, CORRUPTED}
<}

if {[N belong 9 0 0 {} {} == 168630784]} {>

	if {[S string 13 0 {} {} > \0]} {>

	emit {%s resource data}
	mime application/x-tads

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TADS2\ save/g]} {>

emit TADS

if {[N belong 12 0 0 {} {} != 168630784]} {>

emit {saved game data, CORRUPTED}
<}

if {[N belong 12 0 0 {} {} == 168630784]} {>

	if {[S string [I 16 leshort 0 + 0 32] 0 {} {} > \0]} {>

	emit {%s saved game data}
	mime application/x-tads

<}

<}

<}
} {
if {[S string 0 0 {} {} eq TADS2\ save]} {>

emit TADS

if {[N belong 10 0 0 {} {} != 168630784]} {>

emit {saved game data, CORRUPTED}
<}

if {[N belong 10 0 0 {} {} == 168630784]} {>

	if {[S string 14 0 {} {} > \0]} {>

	emit {%s saved game data}
	mime application/x-tads

<}

<}

<}
} {
if {[S string 0 0 {} {} eq T3-image\015\012\032]} {>

if {[N leshort 11 0 0 {} {} x {}]} {>

emit {TADS 3 game data (format version %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq T3-state-v]} {>

if {[S string 14 0 {} {} eq \015\012\032]} {>

emit {TADS 3 saved game data (format version}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit %c
<}

	if {[N byte 11 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

	if {[N byte 12 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

	if {[N byte 13 0 0 {} {} x {}]} {>

	emit {\b%c)}
	mime application/x-t3vm-image

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \037\235]} {>

emit {compress'd data}

if {[N byte 2 0 0 & 128 > 0]} {>

emit {block compressed}
<}

if {[N byte 2 0 0 & 31 x {}]} {>

emit {%d bits}
<}

mime application/x-compress

<}
} {
if {[S string 0 0 {} {} eq \037\213]} {>

emit {gzip compressed data}

if {[N byte 2 0 0 {} {} < 8]} {>

emit {\b, reserved method}
<}

if {[N byte 2 0 0 {} {} > 8]} {>

emit {\b, unknown method}
<}

if {[N byte 3 0 0 {} {} & 1]} {>

emit {\b, ASCII}
<}

if {[N byte 3 0 0 {} {} & 2]} {>

emit {\b, has CRC}
<}

if {[N byte 3 0 0 {} {} & 4]} {>

emit {\b, extra field}
<}

if {[N byte 3 0 0 & 12 == 8]} {>

	if {[S string 10 0 {} {} x {}]} {>

	emit {\b, was "%s"}
<}

<}

if {[N byte 3 0 0 {} {} & 16]} {>

emit {\b, has comment}
<}

if {[N byte 3 0 0 {} {} & 32]} {>

emit {\b, encrypted}
<}

if {[N ledate 4 0 0 {} {} > 0]} {>

emit {\b, last modified: %s}
<}

switch -- [Nv byte 8 0 {} {}] 2 {>;emit {\b, max compression};<} 4 {>;emit {\b, max speed};<} 
<

switch -- [Nv byte 9 0 {} {}] 0 {>;emit {\b, from FAT filesystem (MS-DOS, OS/2, NT)};<} 1 {>;emit {\b, from Amiga};<} 2 {>;emit {\b, from VMS};<} 3 {>;emit {\b, from Unix};<} 4 {>;emit {\b, from VM/CMS};<} 5 {>;emit {\b, from Atari};<} 6 {>;emit {\b, from HPFS filesystem (OS/2, NT)};<} 7 {>;emit {\b, from MacOS};<} 8 {>;emit {\b, from Z-System};<} 9 {>;emit {\b, from CP/M};<} 10 {>;emit {\b, from TOPS/20};<} 11 {>;emit {\b, from NTFS filesystem (NT)};<} 12 {>;emit {\b, from QDOS};<} 13 {>;emit {\b, from Acorn RISCOS};<} 
<

mime application/x-gzip

<}
} {
if {[S string 0 0 {} {} eq \037\036]} {>

emit {packed data}

if {[N belong 2 0 0 {} {} > 1]} {>

emit {\b, %d characters originally}
<}

if {[N belong 2 0 0 {} {} == 1]} {>

emit {\b, %d character originally}
<}

mime application/octet-stream

<}
} {
if {[S string 0 0 {} {} eq \377\037]} {>

emit {compacted data}
mime application/octet-stream

<}
} {
if {[S string 0 0 {} {} eq BZh]} {>

emit {bzip2 compressed data}

if {[N byte 3 0 0 {} {} > 47]} {>

emit {\b, block size = %c00k}
<}

mime application/x-bzip2

<}
} {
if {[S string 0 0 {} {} eq LZIP]} {>

emit {lzip compressed data}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b, version: %d}
<}

mime application/x-lzip

<}
} {
if {[S string 0 0 {} {} eq \037\237]} {>

emit {frozen file 2.1}
<}
} {
if {[S string 0 0 {} {} eq \037\236]} {>

emit {frozen file 1.0 (or gzip 0.5)}
<}
} {
if {[S string 0 0 {} {} eq \037\240]} {>

emit {SCO compress -H (LZH) data}
<}
} {
if {[S string 0 0 {} {} eq \x89\x4c\x5a\x4f\x00\x0d\x0a\x1a\x0a]} {>

emit {lzop compressed data}

if {[N beshort 9 0 0 {} {} < 2368]} {>

	if {[N byte 9 0 0 & 240 == 0]} {>

	emit {- version 0.}
<}

	if {[N beshort 9 0 0 & 4095 x {}]} {>

	emit {\b%03x,}
<}

	switch -- [Nv byte 13 0 {} {}] 1 {>;emit LZO1X-1,;<} 2 {>;emit LZO1X-1(15),;<} 3 {>;emit LZO1X-999,;<} 
<

	switch -- [Nv byte 14 0 {} {}] 0 {>;emit {os: MS-DOS};<} 1 {>;emit {os: Amiga};<} 2 {>;emit {os: VMS};<} 3 {>;emit {os: Unix};<} 5 {>;emit {os: Atari};<} 6 {>;emit {os: OS/2};<} 7 {>;emit {os: MacOS};<} 10 {>;emit {os: Tops/20};<} 11 {>;emit {os: WinNT};<} 14 {>;emit {os: Win32};<} 
<

<}

if {[N beshort 9 0 0 {} {} > 2361]} {>

	switch -- [Nv byte 9 0 & 240] 0 {>;emit {- version 0.};<} 16 {>;emit {- version 1.};<} 32 {>;emit {- version 2.};<} 
<

	if {[N beshort 9 0 0 & 4095 x {}]} {>

	emit {\b%03x,}
<}

	switch -- [Nv byte 15 0 {} {}] 1 {>;emit LZO1X-1,;<} 2 {>;emit LZO1X-1(15),;<} 3 {>;emit LZO1X-999,;<} 
<

	switch -- [Nv byte 17 0 {} {}] 0 {>;emit {os: MS-DOS};<} 1 {>;emit {os: Amiga};<} 2 {>;emit {os: VMS};<} 3 {>;emit {os: Unix};<} 5 {>;emit {os: Atari};<} 6 {>;emit {os: OS/2};<} 7 {>;emit {os: MacOS};<} 10 {>;emit {os: Tops/20};<} 11 {>;emit {os: WinNT};<} 14 {>;emit {os: Win32};<} 
<

<}

<}
} {
if {[S string 0 0 {} {} eq \037\241]} {>

emit {Quasijarus strong compressed data}
<}
} {
if {[S string 0 0 {} {} eq XPKF]} {>

emit {Amiga xpkf.library compressed data}
<}
} {
if {[S string 0 0 {} {} eq PP11]} {>

emit {Power Packer 1.1 compressed data}
<}
} {
if {[S string 0 0 {} {} eq PP20]} {>

emit {Power Packer 2.0 compressed data,}

switch -- [Nv belong 4 0 {} {}] 151587081 {>;emit {fast compression};<} 151652874 {>;emit {mediocre compression};<} 151653131 {>;emit {good compression};<} 151653388 {>;emit {very good compression};<} 151653389 {>;emit {best compression};<} 
<

<}
} {
if {[S string 0 0 {} {} eq 7z\274\257\047\034]} {>

emit {7-zip archive data,}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {version %d}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b.%d}
mime application/x-7z-compressed

ext 7z/cb7

<}

<}
} {
if {[N lelong 0 0 0 & 16777215 == 93]} {>

switch -- [Nv leshort 12 0 {} {}] 255 {>;emit {LZMA compressed data,}

	if {[N lequad 5 0 0 {} {} == 18446744073709551615]} {>

	emit streamed
<}

	if {[N lequad 5 0 0 {} {} != 18446744073709551615]} {>

	emit {non-streamed, size %lld}
<}

mime application/x-lzma
;<} 0 {>;emit {LZMA compressed data,}

	if {[N lequad 5 0 0 {} {} == 18446744073709551615]} {>

	emit streamed
<}

	if {[N lequad 5 0 0 {} {} != 18446744073709551615]} {>

	emit {non-streamed, size %lld}
<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq LRZI]} {>

emit {LRZIP compressed data}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b.%d}
mime application/x-lrzip

<}

<}
} {
if {[S string 2 0 {} {} eq -afx-]} {>

emit {AFX compressed file data}
<}
} {
if {[S string 0 0 {} {} eq RZIP]} {>

emit {rzip compressed data}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N belong 6 0 0 {} {} x {}]} {>

emit {(%d bytes)}
<}

<}
} {
if {[S string 0 0 {} {} eq ArC\x01]} {>

emit {FreeArc archive <http://freearc.org>}
<}
} {
if {[S string 0 0 {} {} eq \377\006\0\0sNaPpY]} {>

emit {snappy framed data}
mime application/x-snappy-framed

<}
} {
if {[S string 0 0 {} {} eq qpress10]} {>

emit {qpress compressed data}
mime application/x-qpress

<}
} {
if {[S string 0 0 b {} x {}]} {>

if {[N beshort 0 0 0 % 31 == 0]} {>

	if {[N byte 0 0 0 & 15 == 8]} {>

		if {[N byte 0 0 0 & 128 == 0]} {>

		emit {zlib compressed data}
		mime application/zlib

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq Identification_Information]} {>

emit {FGDC ASCII metadata}
<}
} {
if {[Sx string 0 0 {} {} eq KEB\ ]} {>

emit {Knudsen seismic KEL binary (KEB) -}

if {[Sx regex 4 0 {} {} eq \[-A-Z0-9\]*]} {>

emit {Software: %s}

	if {[Sx regex [R 1] 0 {} {} eq V\[0-9\]*.\[0-9\]*]} {>

	emit {version %s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq HCA]} {>

emit {LADS Caris Ascii Format (CAF) bathymetric lidar}

if {[S regex 4 0 {} {} eq \[0-9\]*.\[0-9\]*]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq HCB]} {>

emit {LADS Caris Binary Format (CBF) bathymetric lidar waveform data}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {version %d .}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit %d
<}

<}
} {
if {[N beshort 4 0 0 {} {} == 8194]} {>

emit {GeoSwath RDF}
<}
} {
if {[S string 0 0 {} {} eq Start:-]} {>

emit {GeoSwatch auf text file}
<}
} {
if {[S string 0 0 {} {} eq SB2100]} {>

emit {SeaBeam 2100 multibeam sonar}
<}
} {
if {[S string 0 0 {} {} eq SB2100DR]} {>

emit {SeaBeam 2100 DR multibeam sonar}
<}
} {
if {[S string 0 0 {} {} eq SB2100PR]} {>

emit {SeaBeam 2100 PR multibeam sonar}
<}
} {
if {[S string 0 0 {} {} eq \$HSF]} {>

emit {XSE multibeam}
<}
} {
if {[Sx string 8 0 {} {} eq GSF-v]} {>

emit {SAIC generic sensor format (GSF) sonar data,}

if {[Sx regex [R 0] 0 {} {} eq \[0-9\]*.\[0-9\]*]} {>

emit {version %s}
<}

<}
} {
if {[S string 9 0 {} {} eq MGD77]} {>

emit {MGD77 Header, Marine Geophysical Data Exchange Format}
<}
} {
if {[S string 1 0 {} {} eq Swath\ Data\ File:]} {>

emit {mbsystem info cache}
<}
} {
if {[S string 0 0 {} {} eq HDCS]} {>

emit {Caris multibeam sonar related data}
<}
} {
if {[S string 1 0 {} {} eq Start/Stop\ parameter\ header:]} {>

emit {Caris ASCII project summary}
<}
} {
if {[S string 0 0 {} {} eq %%\ TDR\ 2.0]} {>

emit {IVS Fledermaus TDR file}
<}
} {
if {[S string 0 0 {} {} eq U3D]} {>

emit {ECMA-363, Universal 3D}
<}
} {
if {[S string 0 0 {} {} eq \$@MID@\$]} {>

emit {elog journal entry}
<}
} {
if {[S string 0 0 {} {} eq DSBB]} {>

emit {Surfer 6 binary grid file}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {\b, %d}
<}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\bx%d}
<}

if {[N ledouble 8 0 0 {} {} x {}]} {>

emit {\b, minx=%g}
<}

if {[N ledouble 16 0 0 {} {} x {}]} {>

emit {\b, maxx=%g}
<}

if {[N ledouble 24 0 0 {} {} x {}]} {>

emit {\b, miny=%g}
<}

if {[N ledouble 32 0 0 {} {} x {}]} {>

emit {\b, maxy=%g}
<}

if {[N ledouble 40 0 0 {} {} x {}]} {>

emit {\b, minz=%g}
<}

if {[N ledouble 48 0 0 {} {} x {}]} {>

emit {\b, maxz=%g}
<}

<}
} {
if {[S string 0 0 {} {} eq RuneCT]} {>

emit {Citrus locale declaration for LC_CTYPE}
<}
} {
if {[N belong 5 0 0 {} {} == 0]} {>

if {[N belong 8 0 0 {} {} == 2101256]} {>

emit {BlackBerry RIM ETP file}

	if {[S string 22 0 {} {} x {}]} {>

	emit {\b for %s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq IDP2]} {>

emit {Quake II 3D Model file,}

if {[N long 20 0 0 {} {} x {}]} {>

emit {%u skin(s),}
<}

if {[N long 8 0 0 {} {} x {}]} {>

emit {(%u x}
<}

if {[N long 12 0 0 {} {} x {}]} {>

emit %u),
<}

if {[N long 40 0 0 {} {} x {}]} {>

emit {%u frame(s),}
<}

if {[N long 16 0 0 {} {} x {}]} {>

emit {Frame size %u bytes,}
<}

if {[N long 24 0 0 {} {} x {}]} {>

emit {%u vertices/frame,}
<}

if {[N long 28 0 0 {} {} x {}]} {>

emit {%u texture coordinates,}
<}

if {[N long 32 0 0 {} {} x {}]} {>

emit {%u triangles/frame}
<}

<}
} {
if {[S string 0 0 {} {} eq IBSP]} {>

emit Quake

switch -- [Nv long 4 0 {} {}] 38 {>;emit {II Map file (BSP)};<} 46 {>;emit {III Map file (BSP)};<} 
<

<}
} {
if {[S string 0 0 {} {} eq IDS2]} {>

emit {Quake II SP2 sprite file}
<}
} {
if {[S string 0 0 {} {} eq \xcb\x1dBoom\xe6\xff\x03\x01]} {>

emit {Boom or linuxdoom demo}
<}
} {
if {[S string 24 0 {} {} eq LxD\ 203]} {>

emit {Linuxdoom save}

if {[S string 0 0 {} {} x {}]} {>

emit {, name=%s}
<}

if {[S string 44 0 {} {} x {}]} {>

emit {, world=%s}
<}

<}
} {
if {[S string 0 0 {} {} eq PACK]} {>

emit {Quake I or II world or extension}

if {[N lelong 8 0 0 {} {} > 0]} {>

emit {\b, %d entries}
<}

<}
} {
if {[S string 0 0 {} {} eq 5\x0aIntroduction]} {>

emit {Quake I save: start Introduction}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Slipgate_Complex]} {>

emit {Quake I save: e1m1 The slipgate complex}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aCastle_of_the_Damned]} {>

emit {Quake I save: e1m2 Castle of the damned}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Necropolis]} {>

emit {Quake I save: e1m3 The necropolis}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Grisly_Grotto]} {>

emit {Quake I save: e1m4 The grisly grotto}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aZiggurat_Vertigo]} {>

emit {Quake I save: e1m8 Ziggurat vertigo (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aGloom_Keep]} {>

emit {Quake I save: e1m5 Gloom keep}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Door_To_Chthon]} {>

emit {Quake I save: e1m6 The door to Chthon}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_House_of_Chthon]} {>

emit {Quake I save: e1m7 The house of Chthon}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Installation]} {>

emit {Quake I save: e2m1 The installation}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Ogre_Citadel]} {>

emit {Quake I save: e2m2 The ogre citadel}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Crypt_of_Decay]} {>

emit {Quake I save: e2m3 The crypt of decay (dopefish lives!)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aUnderearth]} {>

emit {Quake I save: e2m7 Underearth (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Ebon_Fortress]} {>

emit {Quake I save: e2m4 The ebon fortress}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Wizard's_Manse]} {>

emit {Quake I save: e2m5 The wizard's manse}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Dismal_Oubliette]} {>

emit {Quake I save: e2m6 The dismal oubliette}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aTermination_Central]} {>

emit {Quake I save: e3m1 Termination central}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aVaults_of_Zin]} {>

emit {Quake I save: e3m2 Vaults of Zin}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Tomb_of_Terror]} {>

emit {Quake I save: e3m3 The tomb of terror}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSatan's_Dark_Delight]} {>

emit {Quake I save: e3m4 Satan's dark delight}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Haunted_Halls]} {>

emit {Quake I save: e3m7 The haunted halls (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aWind_Tunnels]} {>

emit {Quake I save: e3m5 Wind tunnels}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aChambers_of_Torment]} {>

emit {Quake I save: e3m6 Chambers of torment}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Sewage_System]} {>

emit {Quake I save: e4m1 The sewage system}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Tower_of_Despair]} {>

emit {Quake I save: e4m2 The tower of despair}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Elder_God_Shrine]} {>

emit {Quake I save: e4m3 The elder god shrine}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Palace_of_Hate]} {>

emit {Quake I save: e4m4 The palace of hate}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aHell's_Atrium]} {>

emit {Quake I save: e4m5 Hell's atrium}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Nameless_City]} {>

emit {Quake I save: e4m8 The nameless city (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Pain_Maze]} {>

emit {Quake I save: e4m6 The pain maze}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aAzure_Agony]} {>

emit {Quake I save: e4m7 Azure agony}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aShub-Niggurath's_Pit]} {>

emit {Quake I save: end Shub-Niggurath's pit}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aPlace_of_Two_Deaths]} {>

emit {Quake I save: dm1 Place of two deaths}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aClaustrophobopolis]} {>

emit {Quake I save: dm2 Claustrophobopolis}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Abandoned_Base]} {>

emit {Quake I save: dm3 The abandoned base}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Bad_Place]} {>

emit {Quake I save: dm4 The bad place}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Cistern]} {>

emit {Quake I save: dm5 The cistern}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Dark_Zone]} {>

emit {Quake I save: dm6 The dark zone}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aCommand_HQ]} {>

emit {Quake I save: start Command HQ}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Pumping_Station]} {>

emit {Quake I save: hip1m1 The pumping station}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aStorage_Facility]} {>

emit {Quake I save: hip1m2 Storage facility}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aMilitary_Complex]} {>

emit {Quake I save: hip1m5 Military complex (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Lost_Mine]} {>

emit {Quake I save: hip1m3 The lost mine}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aResearch_Facility]} {>

emit {Quake I save: hip1m4 Research facility}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aAncient_Realms]} {>

emit {Quake I save: hip2m1 Ancient realms}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Gremlin's_Domain]} {>

emit {Quake I save: hip2m6 The gremlin's domain (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Black_Cathedral]} {>

emit {Quake I save: hip2m2 The black cathedral}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Catacombs]} {>

emit {Quake I save: hip2m3 The catacombs}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Crypt__]} {>

emit {Quake I save: hip2m4 The crypt}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aMortum's_Keep]} {>

emit {Quake I save: hip2m5 Mortum's keep}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aTur_Torment]} {>

emit {Quake I save: hip3m1 Tur torment}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aPandemonium]} {>

emit {Quake I save: hip3m2 Pandemonium}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aLimbo]} {>

emit {Quake I save: hip3m3 Limbo}
<}
} {
if {[S string 0 0 {} {} eq 5\x0athe_Edge_of_Oblivion]} {>

emit {Quake I save: hipdm1 The edge of oblivion (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Gauntlet]} {>

emit {Quake I save: hip3m4 The gauntlet}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aArmagon's_Lair]} {>

emit {Quake I save: hipend Armagon's lair}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Academy]} {>

emit {Quake I save: start The academy}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Lab]} {>

emit {Quake I save: d1 The lab}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aArea_33]} {>

emit {Quake I save: d1b Area 33}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSECRET_MISSIONS]} {>

emit {Quake I save: d3b Secret missions}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Hospital]} {>

emit {Quake I save: d10 The hospital (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Genetics_Lab]} {>

emit {Quake I save: d11 The genetics lab (secret)}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aBACK_2_MALICE]} {>

emit {Quake I save: d4b Back to Malice}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aArea44]} {>

emit {Quake I save: d1c Area 44}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aTakahiro_Towers]} {>

emit {Quake I save: d2 Takahiro towers}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aA_Rat's_Life]} {>

emit {Quake I save: d3 A rat's life}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aInto_The_Flood]} {>

emit {Quake I save: d4 Into the flood}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Flood]} {>

emit {Quake I save: d5 The flood}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aNuclear_Plant]} {>

emit {Quake I save: d6 Nuclear plant}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Incinerator_Plant]} {>

emit {Quake I save: d7 The incinerator plant}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Foundry]} {>

emit {Quake I save: d7b The foundry}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Underwater_Base]} {>

emit {Quake I save: d8 The underwater base}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aTakahiro_Base]} {>

emit {Quake I save: d9 Takahiro base}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aTakahiro_Laboratories]} {>

emit {Quake I save: d12 Takahiro laboratories}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aStayin'_Alive]} {>

emit {Quake I save: d13 Stayin' alive}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aB.O.S.S._HQ]} {>

emit {Quake I save: d14 B.O.S.S. HQ}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSHOWDOWN!]} {>

emit {Quake I save: d15 Showdown!}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aThe_Seventh_Precinct]} {>

emit {Quake I save: ddm1 The seventh precinct}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSub_Station]} {>

emit {Quake I save: ddm2 Sub station}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aCrazy_Eights!]} {>

emit {Quake I save: ddm3 Crazy eights!}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aEast_Side_Invertationa]} {>

emit {Quake I save: ddm4 East side invertationa}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSlaughterhouse]} {>

emit {Quake I save: ddm5 Slaughterhouse}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aDOMINO]} {>

emit {Quake I save: ddm6 Domino}
<}
} {
if {[S string 0 0 {} {} eq 5\x0aSANDRA'S_LADDER]} {>

emit {Quake I save: ddm7 Sandra's ladder}
<}
} {
if {[S string 0 0 {} {} eq MComprHD]} {>

emit {MAME CHD compressed hard disk image,}

if {[N belong 12 0 0 {} {} x {}]} {>

emit {version %u}
<}

<}
} {
if {[S string 0 0 {} {} eq IWAD]} {>

emit {doom main IWAD data}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {containing %d lumps}
<}

<}
} {
if {[S string 0 0 {} {} eq PWAD]} {>

emit {doom patch PWAD data}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {containing %d lumps}
<}

<}
} {
if {[S string 0 0 {} {} eq KenSilverman]} {>

emit {Build engine group file}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {containing %d files}
<}

<}
} {
if {[S string 0 0 {} {} eq Warcraft\ III\ recorded\ game]} {>

emit %s
<}
} {
if {[S string 0 0 {} {} eq HM3W]} {>

emit {Warcraft III map file}
<}
} {
if {[Sx regex 0 0 {} {} eq \\(\;.*GM\\\[\[0-9\]\{1,2\}\\\]]} {>

emit {Smart Game Format}

if {[Sx search 2 0 b 512 eq GM\[]} {>

	if {[Sx string [R 0] 0 {} {} eq 1\]]} {>

	emit (Go)
<}

	if {[Sx string [R 0] 0 {} {} eq 2\]]} {>

	emit (Othello)
<}

	if {[Sx string [R 0] 0 {} {} eq 3\]]} {>

	emit (chess)
<}

	if {[Sx string [R 0] 0 {} {} eq 4\]]} {>

	emit (Gomoku+Renju)
<}

	if {[Sx string [R 0] 0 {} {} eq 5\]]} {>

	emit {(Nine Men's Morris)}
<}

	if {[Sx string [R 0] 0 {} {} eq 6\]]} {>

	emit (Backgammon)
<}

	if {[Sx string [R 0] 0 {} {} eq 7\]]} {>

	emit {(Chinese chess)}
<}

	if {[Sx string [R 0] 0 {} {} eq 8\]]} {>

	emit (Shogi)
<}

	if {[Sx string [R 0] 0 {} {} eq 9\]]} {>

	emit {(Lines of Action)}
<}

	if {[Sx string [R 0] 0 {} {} eq 10\]]} {>

	emit (Ataxx)
<}

	if {[Sx string [R 0] 0 {} {} eq 11\]]} {>

	emit (Hex)
<}

	if {[Sx string [R 0] 0 {} {} eq 12\]]} {>

	emit (Jungle)
<}

	if {[Sx string [R 0] 0 {} {} eq 13\]]} {>

	emit (Neutron)
<}

	if {[Sx string [R 0] 0 {} {} eq 14\]]} {>

	emit {(Philosopher's Football)}
<}

	if {[Sx string [R 0] 0 {} {} eq 15\]]} {>

	emit (Quadrature)
<}

	if {[Sx string [R 0] 0 {} {} eq 16\]]} {>

	emit (Trax)
<}

	if {[Sx string [R 0] 0 {} {} eq 17\]]} {>

	emit (Tantrix)
<}

	if {[Sx string [R 0] 0 {} {} eq 18\]]} {>

	emit (Amazons)
<}

	if {[Sx string [R 0] 0 {} {} eq 19\]]} {>

	emit (Octi)
<}

	if {[Sx string [R 0] 0 {} {} eq 20\]]} {>

	emit (Gess)
<}

	if {[Sx string [R 0] 0 {} {} eq 21\]]} {>

	emit (Twixt)
<}

	if {[Sx string [R 0] 0 {} {} eq 22\]]} {>

	emit (Zertz)
<}

	if {[Sx string [R 0] 0 {} {} eq 23\]]} {>

	emit (Plateau)
<}

	if {[Sx string [R 0] 0 {} {} eq 24\]]} {>

	emit (Yinsh)
<}

	if {[Sx string [R 0] 0 {} {} eq 25\]]} {>

	emit (Punct)
<}

	if {[Sx string [R 0] 0 {} {} eq 26\]]} {>

	emit (Gobblet)
<}

	if {[Sx string [R 0] 0 {} {} eq 27\]]} {>

	emit (hive)
<}

	if {[Sx string [R 0] 0 {} {} eq 28\]]} {>

	emit (Exxit)
<}

	if {[Sx string [R 0] 0 {} {} eq 29\]]} {>

	emit (Hnefatal)
<}

	if {[Sx string [R 0] 0 {} {} eq 30\]]} {>

	emit (Kuba)
<}

	if {[Sx string [R 0] 0 {} {} eq 31\]]} {>

	emit (Tripples)
<}

	if {[Sx string [R 0] 0 {} {} eq 32\]]} {>

	emit (Chase)
<}

	if {[Sx string [R 0] 0 {} {} eq 33\]]} {>

	emit {(Tumbling Down)}
<}

	if {[Sx string [R 0] 0 {} {} eq 34\]]} {>

	emit (Sahara)
<}

	if {[Sx string [R 0] 0 {} {} eq 35\]]} {>

	emit (Byte)
<}

	if {[Sx string [R 0] 0 {} {} eq 36\]]} {>

	emit (Focus)
<}

	if {[Sx string [R 0] 0 {} {} eq 37\]]} {>

	emit (Dvonn)
<}

	if {[Sx string [R 0] 0 {} {} eq 38\]]} {>

	emit (Tamsk)
<}

	if {[Sx string [R 0] 0 {} {} eq 39\]]} {>

	emit (Gipf)
<}

	if {[Sx string [R 0] 0 {} {} eq 40\]]} {>

	emit (Kropki)
<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq Gamebryo\ File\ Format,\ Version\ ]} {>

emit {Gamebryo game engine file}

if {[Sx regex [R 0] 0 {} {} eq \[0-9a-z.\]+]} {>

emit {\b, version %s}
<}

<}
} {
if {[Sx string 0 0 {} {} eq \;Gamebryo\ KFM\ File\ Version\ ]} {>

emit {Gamebryo game engine animation File}

if {[Sx regex [R 0] 0 {} {} eq \[0-9a-z.\]+]} {>

emit {\b, version %s}
<}

<}
} {
if {[Sx string 0 0 {} {} eq NetImmerse\ File\ Format,\ Versio]} {>

if {[Sx string [R 0] 0 {} {} eq n\ ]} {>

emit {NetImmerse game engine file}

	if {[Sx regex [R 0] 0 {} {} eq \[0-9a-z.\]+]} {>

	emit {\b, version %s}
<}

<}

<}
} {
if {[S regex 2 0 c {} eq \\(\;.*GM\\\[\[0-9\]\{1,2\}\\\]]} {>

emit {Smart Game Format}

if {[S regex 2 0 c {} eq GM\\\[1\\\]]} {>

emit {- Go Game}
<}

if {[S regex 2 0 c {} eq GM\\\[6\\\]]} {>

emit {- BackGammon Game}
<}

if {[S regex 2 0 c {} eq GM\\\[11\\\]]} {>

emit {- Hex Game}
<}

if {[S regex 2 0 c {} eq GM\\\[18\\\]]} {>

emit {- Amazons Game}
<}

if {[S regex 2 0 c {} eq GM\\\[19\\\]]} {>

emit {- Octi Game}
<}

if {[S regex 2 0 c {} eq GM\\\[20\\\]]} {>

emit {- Gess Game}
<}

if {[S regex 2 0 c {} eq GM\\\[21\\\]]} {>

emit {- twix Game}
<}

<}
} {
switch -- [Nv belong 0 0 & 67108863] 8782091 {>;emit {a.out NetBSD/i386 demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782088 {>;emit {a.out NetBSD/i386 pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782087 {>;emit {a.out NetBSD/i386}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782151 {>;emit {a.out NetBSD/i386 core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 8847627 {>;emit {a.out NetBSD/m68k demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 8192]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 8192]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 8192]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8847624 {>;emit {a.out NetBSD/m68k pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8847623 {>;emit {a.out NetBSD/m68k}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N belong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N belong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8847687 {>;emit {a.out NetBSD/m68k core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N belong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 8913163 {>;emit {a.out NetBSD/m68k4k demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8913160 {>;emit {a.out NetBSD/m68k4k pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8913159 {>;emit {a.out NetBSD/m68k4k}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N belong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N belong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8913223 {>;emit {a.out NetBSD/m68k4k core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N belong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 8978699 {>;emit {a.out NetBSD/ns32532 demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8978696 {>;emit {a.out NetBSD/ns32532 pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8978695 {>;emit {a.out NetBSD/ns32532}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8978759 {>;emit {a.out NetBSD/ns32532 core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9765191 {>;emit {a.out NetBSD/powerpc core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}
;<} 9044235 {>;emit {a.out NetBSD/SPARC demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 8192]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 8192]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 8192]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9044232 {>;emit {a.out NetBSD/SPARC pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9044231 {>;emit {a.out NetBSD/SPARC}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N belong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N belong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9044295 {>;emit {a.out NetBSD/SPARC core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N belong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9109771 {>;emit {a.out NetBSD/pmax demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9109768 {>;emit {a.out NetBSD/pmax pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9109767 {>;emit {a.out NetBSD/pmax}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9109831 {>;emit {a.out NetBSD/pmax core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9175307 {>;emit {a.out NetBSD/vax 1k demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9175304 {>;emit {a.out NetBSD/vax 1k pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9175303 {>;emit {a.out NetBSD/vax 1k}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9175367 {>;emit {a.out NetBSD/vax 1k core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9830667 {>;emit {a.out NetBSD/vax 4k demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9830664 {>;emit {a.out NetBSD/vax 4k pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9830663 {>;emit {a.out NetBSD/vax 4k}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9830727 {>;emit {a.out NetBSD/vax 4k core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9240903 {>;emit {a.out NetBSD/alpha core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9306379 {>;emit {a.out NetBSD/mips demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N belong 20 0 0 {} {} < 8192]} {>

	emit {shared library}
<}

	if {[N belong 20 0 0 {} {} == 8192]} {>

	emit {dynamically linked executable}
<}

	if {[N belong 20 0 0 {} {} > 8192]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9306376 {>;emit {a.out NetBSD/mips pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9306375 {>;emit {a.out NetBSD/mips}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N belong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N belong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N belong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9306439 {>;emit {a.out NetBSD/mips core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N belong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 9371915 {>;emit {a.out NetBSD/arm32 demand paged}

if {[N byte 0 0 0 {} {} & 128]} {>

	if {[N lelong 20 0 0 {} {} < 4096]} {>

	emit {shared library}
<}

	if {[N lelong 20 0 0 {} {} == 4096]} {>

	emit {dynamically linked executable}
<}

	if {[N lelong 20 0 0 {} {} > 4096]} {>

	emit {dynamically linked executable}
<}

<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9371912 {>;emit {a.out NetBSD/arm32 pure}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

emit executable
<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9371911 {>;emit {a.out NetBSD/arm32}

if {[N byte 0 0 0 {} {} & 128]} {>

emit {dynamically linked executable}
<}

if {[N byte 0 0 0 {} {} ^ 128]} {>

	if {[N byte 0 0 0 {} {} & 64]} {>

	emit {position independent}
<}

	if {[N lelong 20 0 0 {} {} != 0]} {>

	emit executable
<}

	if {[N lelong 20 0 0 {} {} == 0]} {>

	emit {object file}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 9371975 {>;emit {a.out NetBSD/arm core}

if {[S string 12 0 {} {} > \0]} {>

emit {from '%s'}
<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {(signal %d)}
<}
;<} 
<
} {
if {[N belong 0 0 0 & 65535 == 36810]} {>

emit {NetBSD kernel core file}

switch -- [Nv belong 0 0 & 67043328] 0 {>;emit {\b, Unknown};<} 65536 {>;emit {\b, sun 68010/68020};<} 131072 {>;emit {\b, sun 68020};<} 6553600 {>;emit {\b, 386 PC};<} 8781824 {>;emit {\b, i386 BSD};<} 8847360 {>;emit {\b, m68k BSD (8K pages)};<} 8912896 {>;emit {\b, m68k BSD (4K pages)};<} 8978432 {>;emit {\b, ns32532 BSD};<} 9043968 {>;emit {\b, SPARC/32 BSD};<} 9109504 {>;emit {\b, pmax BSD};<} 9175040 {>;emit {\b, vax BSD (1K pages)};<} 9240576 {>;emit {\b, alpha BSD};<} 9306112 {>;emit {\b, mips BSD (Big Endian)};<} 9371648 {>;emit {\b, arm6 BSD};<} 9437184 {>;emit {\b, m68k BSD (2K pages)};<} 9502720 {>;emit {\b, sh3 BSD};<} 9764864 {>;emit {\b, ppc BSD (Big Endian)};<} 9830400 {>;emit {\b, vax BSD (4K pages)};<} 9895936 {>;emit {\b, mips1 BSD};<} 9961472 {>;emit {\b, mips2 BSD};<} 10027008 {>;emit {\b, m88k BSD};<} 9568256 {>;emit {\b, parisc BSD};<} 10158080 {>;emit {\b, sh5/64 BSD};<} 10223616 {>;emit {\b, SPARC/64 BSD};<} 10289152 {>;emit {\b, amd64 BSD};<} 10354688 {>;emit {\b, sh5/32 BSD};<} 10420224 {>;emit {\b, ia64 BSD};<} 11993088 {>;emit {\b, aarch64 BSD};<} 12058624 {>;emit {\b, or1k BSD};<} 12124160 {>;emit {\b, Risk-V BSD};<} 13107200 {>;emit {\b, hp200 BSD};<} 19660800 {>;emit {\b, hp300 BSD};<} 34275328 {>;emit {\b, hp800 HP-UX};<} 34340864 {>;emit {\b, hp200/hp300 HP-UX};<} 
<

switch -- [Nv belong 0 0 & 4227858432] 67108864 {>;emit {\b, CPU};<} 134217728 {>;emit {\b, DATA};<} 268435456 {>;emit {\b, STACK};<} 
<

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {\b, (headersize = %d}
<}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\b, segmentsize = %d}
<}

if {[N lelong 6 0 0 {} {} x {}]} {>

emit {\b, segments = %d)}
<}

<}
} {
if {[S string 56 0 {} {} eq netbsd]} {>
U 121 ktrace

<}
} {
if {[S string 56 0 {} {} eq linux]} {>
U 121 ktrace

<}
} {
if {[S string 56 0 {} {} eq sunos]} {>
U 121 ktrace

<}
} {
if {[S string 56 0 {} {} eq hpux]} {>
U 121 ktrace

<}
} {
if {[S string 0 0 {} {} eq dex\n]} {>

if {[S regex 0 0 {} {} eq dex\n\[0-9\]\{2\}\0]} {>

emit {Dalvik dex file}
<}

if {[S string 4 0 {} {} > 000]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq dey\n]} {>

if {[S regex 0 0 {} {} eq dey\n\[0-9\]\{2\}\0]} {>

emit {Dalvik dex file (optimized for host)}
<}

if {[S string 4 0 {} {} > 000]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq ANDROID!]} {>

emit {Android bootimg}

if {[S string 1024 0 {} {} eq LOKI\01]} {>

emit {\b, LOKI'd}
<}

if {[N lelong 8 0 0 {} {} > 0]} {>

emit {\b, kernel}

	if {[N lelong 12 0 0 {} {} > 0]} {>

	emit {\b (0x%x)}
<}

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {\b, ramdisk}

	if {[N lelong 20 0 0 {} {} > 0]} {>

	emit {\b (0x%x)}
<}

<}

if {[N lelong 24 0 0 {} {} > 0]} {>

emit {\b, second stage}

	if {[N lelong 28 0 0 {} {} > 0]} {>

	emit {\b (0x%x)}
<}

<}

if {[N lelong 36 0 0 {} {} > 0]} {>

emit {\b, page size: %d}
<}

if {[S string 38 0 {} {} > 0]} {>

emit {\b, name: %s}
<}

if {[S string 64 0 {} {} > 0]} {>

emit {\b, cmdline (%s)}
<}

<}
} {
if {[S string 0 0 b {} eq ANDROID\ BACKUP\n1\n]} {>

emit {Android Backup}

if {[S string 17 0 {} {} eq 0\n]} {>

emit {\b, Not-Compressed}
<}

if {[S string 17 0 {} {} eq 1\n]} {>

emit {\b, Compressed}

	if {[S regex 19 0 l 1 eq ^(\[^n\n\]|n\[^o\]|no\[^n\]|non\[^e\]|none.+).*]} {>

	emit {\b, Encrypted (%s)}
<}

	if {[S string 19 0 {} {} eq none\n]} {>

	emit {\b, Not-Encrypted}
<}

<}

<}
} {
if {[N lelong 2 0 0 {} {} == 1194011726]} {>

emit {VXL data file,}

if {[N leshort 0 0 0 {} {} > 0]} {>

emit {schema version no %d}
<}

<}
} {
if {[S string 0 0 {} {} eq FCS1.0]} {>

emit {Flow Cytometry Standard (FCS) data, version 1.0}
<}
} {
if {[S string 0 0 {} {} eq FCS2.0]} {>

emit {Flow Cytometry Standard (FCS) data, version 2.0}
<}
} {
if {[S string 0 0 {} {} eq FCS3.0]} {>

emit {Flow Cytometry Standard (FCS) data, version 3.0}
<}
} {
if {[S string 0 0 {} {} eq AMANDA:\ ]} {>

emit {AMANDA }

if {[S string 8 0 {} {} eq TAPESTART\ DATE]} {>

emit {tape header file,}

	if {[S string 23 0 {} {} eq X]} {>

		if {[S string 25 0 {} {} > \ ]} {>

		emit {Unused %s}
<}

<}

	if {[S string 23 0 {} {} > \ ]} {>

	emit {DATE %s}
<}

<}

if {[S string 8 0 {} {} eq FILE\ ]} {>

emit {dump file,}

	if {[S string 13 0 {} {} > \ ]} {>

	emit {DATE %s}
<}

<}

<}
} {
if {[S search 0 0 {} 1 eq \0\0\0\0pwV1]} {>

emit {Cracklib password index, big endian ("64-bit")}

if {[N belong 12 0 0 {} {} > 0]} {>

emit {(%i words)}
<}

<}
} {
if {[S string 0 0 {} {} eq FLIF]} {>

emit FLIF

if {[S string 4 0 {} {} < H]} {>

emit {image data}

	if {[N beshort 6 0 0 {} {} x {}]} {>

	emit {\b, %u}
<}

	if {[N beshort 8 0 0 {} {} x {}]} {>

	emit {\bx%u}
<}

	if {[S string 5 0 {} {} eq 1]} {>

	emit {\b, 8-bit/color,}
<}

	if {[S string 5 0 {} {} eq 2]} {>

	emit {\b, 16-bit/color,}
<}

	if {[S string 4 0 {} {} eq 1]} {>

	emit {\b, grayscale, non-interlaced}
<}

	if {[S string 4 0 {} {} eq 3]} {>

	emit {\b, RGB, non-interlaced}
<}

	if {[S string 4 0 {} {} eq 4]} {>

	emit {\b, RGBA, non-interlaced}
<}

	if {[S string 4 0 {} {} eq A]} {>

	emit {\b, grayscale}
<}

	if {[S string 4 0 {} {} eq C]} {>

	emit {\b, RGB, interlaced}
<}

	if {[S string 4 0 {} {} eq D]} {>

	emit {\b, RGBA, interlaced}
<}

<}

if {[S string 4 0 {} {} > H]} {>

emit {\b, animation data}

	if {[N byte 5 0 0 {} {} < 255]} {>

	emit {\b, %i frames}

		if {[N beshort 7 0 0 {} {} x {}]} {>

		emit {\b, %u}
<}

		if {[N beshort 9 0 0 {} {} x {}]} {>

		emit {\bx%u}
<}

		if {[S string 6 0 {} {} eq 1]} {>

		emit {\b, 8-bit/color}
<}

		if {[S string 6 0 {} {} eq 2]} {>

		emit {\b, 16-bit/color}
<}

<}

	if {[N byte 5 0 0 {} {} == 255]} {>

		if {[N beshort 6 0 0 {} {} x {}]} {>

		emit {\b, %i frames,}
<}

		if {[N beshort 9 0 0 {} {} x {}]} {>

		emit {\b, %u}
<}

		if {[N beshort 11 0 0 {} {} x {}]} {>

		emit {\bx%u}
<}

		if {[S string 8 0 {} {} eq 1]} {>

		emit {\b, 8-bit/color}
<}

		if {[S string 8 0 {} {} eq 2]} {>

		emit {\b, 16-bit/color}
<}

<}

	if {[S string 4 0 {} {} eq Q]} {>

	emit {\b, grayscale, non-interlaced}
<}

	if {[S string 4 0 {} {} eq S]} {>

	emit {\b, RGB, non-interlaced}
<}

	if {[S string 4 0 {} {} eq T]} {>

	emit {\b, RGBA, non-interlaced}
<}

	if {[S string 4 0 {} {} eq a]} {>

	emit {\b, grayscale}
<}

	if {[S string 4 0 {} {} eq c]} {>

	emit {\b, RGB, interlaced}
<}

	if {[S string 4 0 {} {} eq d]} {>

	emit {\b, RGBA, interlaced}
<}

<}

<}
} {
if {[S regex 0 0 l 100 ne ^\[^Cc\ \t\].*\$]} {>

if {[S regex 0 0 l 100 eq ^\[Cc\]\[\ \t\]]} {>

emit {FORTRAN program text}
mime text/x-fortran

<}

<}
} {
if {[S string 0 0 t {} eq GIMP\ Gradient]} {>

emit {GIMP gradient data}
<}
} {
if {[S string 0 0 t {} eq GIMP\ Palette]} {>

emit {GIMP palette data}
<}
} {
if {[S string 0 0 {} {} eq gimp\ xcf]} {>

emit {GIMP XCF image data,}

if {[S string 9 0 {} {} eq file]} {>

emit {version 0,}
<}

if {[S string 9 0 {} {} eq v]} {>

emit version

	if {[S string 10 0 {} {} > \0]} {>

	emit %s,
<}

<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit {%u x}
<}

if {[N belong 18 0 0 {} {} x {}]} {>

emit %u,
<}

switch -- [Nv belong 22 0 {} {}] 0 {>;emit {RGB Color};<} 1 {>;emit Greyscale;<} 2 {>;emit {Indexed Color};<} 
<

if {[N belong 22 0 0 {} {} > 2]} {>

emit {Unknown Image Type.}
<}

mime image/x-xcf

<}
} {
if {[S string 20 0 {} {} eq GPAT]} {>

emit {GIMP pattern data,}

if {[S string 24 0 {} {} x {}]} {>

emit %s
<}

<}
} {
if {[S string 20 0 {} {} eq GIMP]} {>

emit {GIMP brush data}
<}
} {
if {[S string 0 0 {} {} eq \#\040GIMP\040Curves\040File]} {>

emit {GIMP curve file}
<}
} {
if {[S string 0 0 {} {} eq MTZ\040]} {>

emit {MTZ reflection file}
<}
} {
if {[S string 92 0 {} {} eq PLOT%%84]} {>

emit {Plot84 plotting file}

if {[N byte 52 0 0 {} {} == 1]} {>

emit {, Little-endian}
<}

if {[N byte 55 0 0 {} {} == 1]} {>

emit {, Big-endian}
<}

<}
} {
if {[S string 0 0 {} {} eq EZD_MAP]} {>

emit {NEWEZD Electron Density Map}
<}
} {
if {[S string 109 0 {} {} eq MAP\040(]} {>

emit {Old EZD Electron Density Map}
<}
} {
if {[S string 0 0 c {} eq :-)\040Origin]} {>

emit {BRIX Electron Density Map}

if {[S string 170 0 {} {} > 0]} {>

emit {, Sigma:%.12s}
<}

<}
} {
if {[S string 7 0 {} {} eq 18\040!NTITLE]} {>

emit {XPLOR ASCII Electron Density Map}
<}
} {
if {[S string 9 0 {} {} eq \040!NTITLE\012\040REMARK]} {>

emit {CNS ASCII electron density map}
<}
} {
if {[S string 208 0 {} {} eq MAP\040]} {>

emit {CCP4 Electron Density Map}

switch -- [Nv byte 212 0 {} {}] 17 {>;emit {\b, Big-endian};<} 34 {>;emit {\b, VAX format};<} 68 {>;emit {\b, Little-endian};<} 85 {>;emit {\b, Convex native};<} 
<

<}
} {
if {[S string 0 0 {} {} eq R-AXIS4\ \ \ ]} {>

emit {R-Axis Area Detector Image:}

if {[N lelong 796 0 0 {} {} < 20]} {>

emit {Little-endian, IP #%d,}

	if {[N lelong 768 0 0 {} {} > 0]} {>

	emit Size=%dx
<}

	if {[N lelong 772 0 0 {} {} > 0]} {>

	emit {\b%d}
<}

<}

if {[N belong 796 0 0 {} {} < 20]} {>

emit {Big-endian, IP #%d,}

	if {[N belong 768 0 0 {} {} > 0]} {>

	emit Size=%dx
<}

	if {[N belong 772 0 0 {} {} > 0]} {>

	emit {\b%d}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq RAXIS\ \ \ \ \ ]} {>

emit {R-Axis Area Detector Image, Win32:}

if {[N lelong 796 0 0 {} {} < 20]} {>

emit {Little-endian, IP #%d,}

	if {[N lelong 768 0 0 {} {} > 0]} {>

	emit Size=%dx
<}

	if {[N lelong 772 0 0 {} {} > 0]} {>

	emit {\b%d}
<}

<}

if {[N belong 796 0 0 {} {} < 20]} {>

emit {Big-endian, IP #%d,}

	if {[N belong 768 0 0 {} {} > 0]} {>

	emit Size=%dx
<}

	if {[N belong 772 0 0 {} {} > 0]} {>

	emit {\b%d}
<}

<}

<}
} {
if {[S string 1028 0 {} {} eq MMX\000\000\000\000\000\000\000\000\000\000\000\000\000]} {>

emit {MAR Area Detector Image,}

if {[N long 1072 0 0 {} {} > 1]} {>

emit Compressed(%d),
<}

if {[N long 1100 0 0 {} {} > 1]} {>

emit {%d headers,}
<}

if {[N long 1104 0 0 {} {} > 0]} {>

emit {%d x}
<}

if {[N long 1108 0 0 {} {} > 0]} {>

emit %d,
<}

if {[N long 1120 0 0 {} {} > 0]} {>

emit {%d bits/pixel}
<}

<}
} {
if {[S string 0 0 {} {} eq \000\060\000\040\000\110\000\105\000\101\000\104]} {>

emit {GEDCOM data}
<}
} {
if {[S string 0 0 {} {} eq \060\000\040\000\110\000\105\000\101\000\104\000]} {>

emit {GEDCOM data}
<}
} {
if {[S string 0 0 {} {} eq \376\377\000\060\000\040\000\110\000\105\000\101\000\104]} {>

emit {GEDCOM data}
<}
} {
if {[S string 0 0 {} {} eq \377\376\060\000\040\000\110\000\105\000\101\000\104\000]} {>

emit {GEDCOM data}
<}
} {
if {[Sx string 0 0 {} {} eq HEADER\ \ \ \ ]} {>

if {[Sx regex [R 0] 0 l 1 eq ^.\{40\}]} {>

	if {[Sx regex [R 0] 0 l 1 eq \[0-9\]\{2\}-\[A-Z\]\{3\}-\[0-9\]\{2\}\ \{3\}]} {>

		if {[Sx regex [R 0] 0 {l s} 1 eq \[A-Z0-9\]\{4\}.\{14\}\$]} {>

			if {[Sx regex [R 0] 0 l 1 eq \[A-Z0-9\]\{4\}]} {>

			emit {Protein Data Bank data, ID Code %s}
			mime chemical/x-pdb

<}

			if {[S regex 0 0 l 1 eq \[0-9\]\{2\}-\[A-Z\]\{3\}-\[0-9\]\{2\}]} {>

			emit {\b, %s}
<}

<}

<}

<}

<}
} {
if {[S search 0 0 {} 1 eq %%!!]} {>

emit {X-Post-It-Note text}
<}
} {
if {[S string 0 0 c {} eq BEGIN:VCALENDAR]} {>

emit {vCalendar calendar file}
mime text/calendar

<}
} {
if {[Sx string 0 0 c {} eq BEGIN:VCARD]} {>

emit {vCard visiting card}

if {[Sx search 12 0 c 14000 eq VERSION:]} {>

	if {[Sx string [R 0] 0 {} {} x {}]} {>

	emit {\b, version %-.3s}
<}

<}

mime text/vcard

<}
} {
if {[S search 0 0 {} 80 eq .la\ -\ a\ libtool\ library\ file]} {>

emit {libtool library file}
<}
} {
if {[S search 0 0 {} 80 eq .lo\ -\ a\ libtool\ object\ file]} {>

emit {libtool object file}
<}
} {
if {[S string 0 0 {} {} eq MDMP]} {>

emit {Mini DuMP crash report}

if {[N lelong 4 0 0 & 65535 != 42899]} {>

emit {\b, version 0x%4.4x}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, %d streams}
<}

if {[N lelong 12 0 0 {} {} != 32]} {>

emit {\b, 0x%8.8x RVA}
<}

if {[N lelong 16 0 0 {} {} != 0]} {>

emit {\b, CheckSum 0x%8.8x}
<}

if {[N ledate 20 0 0 {} {} x {}]} {>

emit {\b, %s}
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {\b, 0x%x type}
<}

mime application/x-dmp

ext dmp/mdmp

<}
} {
if {[S string 0 0 {} {} eq \#\x20abook\x20addressbook\x20file]} {>

emit {abook address book}
mime application/x-abook-addressbook

<}
} {
if {[S string 4 0 {} {} eq pgscriptver]} {>

emit {IslandWrite document}
<}
} {
if {[S string 13 0 {} {} eq DrawFile]} {>

emit {IslandDraw document}
<}
} {
if {[S string 0 0 {} {} eq book\0\0\0\0mark\0\0\0\0]} {>

emit {MacOS Alias file}
<}
} {
if {[S string 0 0 {} {} eq \376bin]} {>

emit {MySQL replication log}
<}
} {
if {[S string 0 0 {} {} eq iRivDB]} {>

emit {iRiver Database file}

if {[S string 11 0 {} {} > \0]} {>

emit {Version %s}
<}

if {[S string 39 0 {} {} eq iHP-100]} {>

emit {[H Series]}
<}

<}
} {
if {[S string 0 0 {} {} eq **\ This\ file\ contains\ an\ SQLite]} {>

emit {SQLite 2.x database}
<}
} {
if {[S string 0 0 {} {} eq SQLite\ format\ 3]} {>

emit {SQLite 3.x database}

if {[N belong 60 0 0 {} {} == 1598903374]} {>

emit {(Monotone source repository)}
<}

switch -- [Nv belong 68 0 {} {}] 252006674 {>;emit {(Fossil checkout)};<} 252006675 {>;emit {(Fossil global configuration)};<} 252006673 {>;emit {(Fossil repository)};<} 1113932898 {>;emit {(Bentley Systems BeSQLite Database)};<} 1113934958 {>;emit {(Bentley Systems Localization File)};<} 1196444487 {>;emit {(OGC GeoPackage file)};<} 
<

if {[S default 68 0 {} {} x {}]} {>

	if {[N belong 68 0 0 {} {} != 0]} {>

	emit {\b, application id %u}
<}

	if {[N belong 60 0 0 {} {} != 0]} {>

	emit {\b, user version %d}
<}

<}

if {[N belong 96 0 0 {} {} x {}]} {>

emit {\b, last written using SQLite version %d}
<}

mime application/x-sqlite3

ext sqlite/sqlite3/db/dbe

<}
} {
switch -- [Nv belong 0 0 & 4294967294] 931071618 {>;emit {SQLite Write-Ahead Log,}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

ext sqlite-wal/db-wal
;<} -17958194 {>;emit Mach-O
U 210 mach-o-be

mime application/x-mach-binary
;<} 
<
} {
if {[S string 0 0 {} {} eq \xd9\xd5\x05\xf9\x20\xa1\x63\xd7]} {>

emit {SQLite Rollback Journal}
<}
} {
if {[Sx string 0 0 {} {} eq PSDB\0]} {>

emit {Panasonic channel list DataBase}

if {[Sx string 126 0 {} {} eq SQLite\ format\ 3]} {>

<}

ext db/bin

<}
} {
if {[S string 0 0 {} {} eq Caml1999]} {>

emit OCaml

if {[S string 8 0 {} {} eq X]} {>

emit {exec file}
<}

if {[S string 8 0 {} {} eq I]} {>

emit {interface file (.cmi)}
<}

if {[S string 8 0 {} {} eq O]} {>

emit {object file (.cmo)}
<}

if {[S string 8 0 {} {} eq A]} {>

emit {library file (.cma)}
<}

if {[S string 8 0 {} {} eq Y]} {>

emit {native object file (.cmx)}
<}

if {[S string 8 0 {} {} eq Z]} {>

emit {native library file (.cmxa)}
<}

if {[S string 8 0 {} {} eq M]} {>

emit {abstract syntax tree implementation file}
<}

if {[S string 8 0 {} {} eq N]} {>

emit {abstract syntax tree interface file}
<}

if {[S string 9 0 {} {} > \0]} {>

emit {(Version %3.3s)}
<}

<}
} {
if {[S string 4 0 {} {} eq pipe]} {>

emit {CLIPPER instruction trace}
<}
} {
if {[S string 4 0 {} {} eq prof]} {>

emit {CLIPPER instruction profile}
<}
} {
if {[S string 0 0 {} {} eq gpch]} {>

emit {GCC precompiled header}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {(version %c}
<}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b%c)}
<}

switch -- [Nv byte 4 0 {} {}] 67 {>;emit {for C};<} 111 {>;emit {for Objective C};<} 43 {>;emit {for C++};<} 79 {>;emit {for Objective C++};<} 
<

<}
} {
if {[S string 0 0 {} {} eq PGF]} {>

emit {Progressive Graphics image data,}

if {[S string 3 0 {} {} eq 2]} {>

emit {version %s,}
<}

if {[S string 3 0 {} {} eq 4]} {>

emit {version %s,}
<}

if {[S string 3 0 {} {} eq 5]} {>

emit {version %s,}
<}

if {[S string 3 0 {} {} eq 6]} {>

emit {version %s,}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit %d,
<}

	if {[N byte 16 0 0 {} {} x {}]} {>

	emit {%d levels,}
<}

	if {[N byte 17 0 0 {} {} x {}]} {>

	emit {compression level %d,}
<}

	if {[N byte 18 0 0 {} {} x {}]} {>

	emit {%d bpp,}
<}

	if {[N byte 19 0 0 {} {} x {}]} {>

	emit {%d channels,}
<}

	if {[S clear 20 0 {} {} x {}]} {>

<}

	switch -- [Nv byte 20 0 {} {}] 0 {>;emit bitmap,;<} 1 {>;emit {gray scale,};<} 2 {>;emit {indexed color,};<} 3 {>;emit {RGB color,};<} 4 {>;emit {CYMK color,};<} 5 {>;emit {HSL color,};<} 6 {>;emit {HSB color,};<} 7 {>;emit multi-channel,;<} 8 {>;emit {duo tone,};<} 9 {>;emit {LAB color,};<} 10 {>;emit {gray scale 16,};<} 11 {>;emit {RGB color 48,};<} 12 {>;emit {LAB color 48,};<} 13 {>;emit {CYMK color 64,};<} 14 {>;emit {deep multi-channel,};<} 15 {>;emit {duo tone 16,};<} 17 {>;emit {RGBA color,};<} 18 {>;emit {gray scale 32,};<} 19 {>;emit {RGB color 12,};<} 20 {>;emit {RGB color 16,};<} -1 {>;emit {unknown format,};<} 
<

	if {[S default 20 0 {} {} x {}]} {>

	emit {format }

		if {[N byte 20 0 0 {} {} x {}]} {>

		emit {\b %d,}
<}

<}

	if {[N byte 21 0 0 {} {} x {}]} {>

	emit {%d bpc}
<}

<}

mime image/x-pgf

<}
} {
if {[S string 8 0 {} {} eq \001s\ ]} {>

emit {SCCS archive data}
<}
} {
if {[Sx search 1090 0 {} 7393 eq \x19\xDB\xD8\xE2\xD9\xC4\xE2\xE2\xD7\xC3]} {>

emit {IBM OS/400 save file data}

switch -- [Nvx byte [R 212] 0 {} {}] 1 {>;emit {\b, created with SAVOBJ};<} 2 {>;emit {\b, created with SAVLIB};<} 7 {>;emit {\b, created with SAVCFG};<} 8 {>;emit {\b, created with SAVSECDTA};<} 10 {>;emit {\b, created with SAVSECDTA};<} 11 {>;emit {\b, created with SAVDLO};<} 13 {>;emit {\b, created with SAVLICPGM};<} 17 {>;emit {\b, created with SAVCHGOBJ};<} 
<

switch -- [Nvx byte [R 213] 0 {} {}] 68 {>;emit {\b, at least V5R4 to open};<} 67 {>;emit {\b, at least V5R3 to open};<} 66 {>;emit {\b, at least V5R2 to open};<} 65 {>;emit {\b, at least V5R1 to open};<} 64 {>;emit {\b, at least V4R5 to open};<} 63 {>;emit {\b, at least V4R4 to open};<} 62 {>;emit {\b, at least V4R3 to open};<} 60 {>;emit {\b, at least V4R2 to open};<} 61 {>;emit {\b, at least V4R1M4 to open};<} 59 {>;emit {\b, at least V4R1 to open};<} 58 {>;emit {\b, at least V3R7 to open};<} 53 {>;emit {\b, at least V3R6 to open};<} 54 {>;emit {\b, at least V3R2 to open};<} 52 {>;emit {\b, at least V3R1 to open};<} 49 {>;emit {\b, at least V3R0M5 to open};<} 48 {>;emit {\b, at least V2R3 to open};<} 
<

<}
} {
if {[S string 0 0 {} {} eq \xd9\xd9\xf7]} {>

emit {Concise Binary Object Representation (CBOR) container}

if {[N byte 3 0 0 {} {} < 32]} {>

emit {(positive integer)}
<}

if {[N byte 3 0 0 {} {} < 64]} {>

	if {[N byte 3 0 0 {} {} > 31]} {>

	emit {(negative integer)}
<}

<}

if {[N byte 3 0 0 {} {} < 96]} {>

	if {[N byte 3 0 0 {} {} > 63]} {>

	emit {(byte string)}
<}

<}

if {[N byte 3 0 0 {} {} < 128]} {>

	if {[N byte 3 0 0 {} {} > 95]} {>

	emit {(text string)}
<}

<}

if {[N byte 3 0 0 {} {} < 160]} {>

<}

if {[N byte 3 0 0 {} {} > 127]} {>

emit (array)
<}

if {[N byte 3 0 0 {} {} < 192]} {>

	if {[N byte 3 0 0 {} {} > 159]} {>

	emit (map)
<}

<}

if {[N byte 3 0 0 {} {} < 224]} {>

	if {[N byte 3 0 0 {} {} > 191]} {>

	emit (tagged)
<}

<}

if {[N byte 3 0 0 {} {} > 223]} {>

emit (other)
<}

mime application/cbor

<}
} {
if {[S string 0 0 {} {} eq .SYSTEM]} {>

emit {SHARC architecture file}
<}
} {
if {[S string 0 0 {} {} eq .system]} {>

emit {SHARC architecture file}
<}
} {
if {[S string 0 0 {} {} eq \000\017\102\104\000\000\000\000\000\000\001\000\000\000\000\002\000\000\000\002\000\000\004\000]} {>

emit {Netscape Address book}
<}
} {
if {[S string 0 0 {} {} eq \000\017\102\111]} {>

emit {Netscape Communicator address book}
<}
} {
if {[S string 0 0 {} {} eq \#\ Netscape\ folder\ cache]} {>

emit {Netscape folder cache}
<}
} {
if {[S string 0 0 {} {} eq \000\036\204\220\000]} {>

emit {Netscape folder cache}
<}
} {
if {[S string 0 0 {} {} eq SX961999]} {>

emit Net2phone
<}
} {
if {[S string 0 0 {} {} eq JG\004\016\0\0\0\0]} {>

emit {AOL ART image}
<}
} {
if {[S string 0 0 {} {} eq JG\003\016\0\0\0\0]} {>

emit {AOL ART image}
<}
} {
if {[S string 0 0 {} {} eq MOVI]} {>

emit {Silicon Graphics movie file}
mime video/x-sgi-movie

<}
} {
if {[S string 4 0 {} {} eq moov]} {>

emit {Apple QuickTime}

if {[S string 12 0 {} {} eq mvhd]} {>

emit {\b movie (fast start)}
<}

if {[S string 12 0 {} {} eq mdra]} {>

emit {\b URL}
<}

if {[S string 12 0 {} {} eq cmov]} {>

emit {\b movie (fast start, compressed header)}
<}

if {[S string 12 0 {} {} eq rmra]} {>

emit {\b multiple URLs}
<}

mime video/quicktime

<}
} {
if {[S string 4 0 {} {} eq mdat]} {>

emit {Apple QuickTime movie (unoptimized)}
mime video/quicktime

<}
} {
if {[S string 4 0 {} {} eq idsc]} {>

emit {Apple QuickTime image (fast start)}
mime image/x-quicktime

<}
} {
if {[S string 4 0 {} {} eq pckg]} {>

emit {Apple QuickTime compressed archive}
mime application/x-quicktime-player

<}
} {
if {[S string 4 0 W {} eq jP]} {>

emit {JPEG 2000 image}
mime image/jp2

<}
} {
switch -- [Nv beshort 0 0 & 65534] -6 {>;
switch -- [Nv byte 2 0 & 240] 16 {>;emit {MPEG ADTS, layer III, v1,  32 kbps}
mime audio/mpeg
;<} 32 {>;emit {MPEG ADTS, layer III, v1,  40 kbps}
mime audio/mpeg
;<} 48 {>;emit {MPEG ADTS, layer III, v1,  48 kbps}
mime audio/mpeg
;<} 64 {>;emit {MPEG ADTS, layer III, v1,  56 kbps}
mime audio/mpeg
;<} 80 {>;emit {MPEG ADTS, layer III, v1,  64 kbps}
mime audio/mpeg
;<} 96 {>;emit {MPEG ADTS, layer III, v1,  80 kbps}
mime audio/mpeg
;<} 112 {>;emit {MPEG ADTS, layer III, v1,  96 kbps}
mime audio/mpeg
;<} -128 {>;emit {MPEG ADTS, layer III, v1, 112 kbps}
mime audio/mpeg
;<} -112 {>;emit {MPEG ADTS, layer III, v1, 128 kbps}
mime audio/mpeg
;<} -96 {>;emit {MPEG ADTS, layer III, v1, 160 kbps}
mime audio/mpeg
;<} -80 {>;emit {MPEG ADTS, layer III, v1, 192 kbps}
mime audio/mpeg
;<} -64 {>;emit {MPEG ADTS, layer III, v1, 224 kbps}
mime audio/mpeg
;<} -48 {>;emit {MPEG ADTS, layer III, v1, 256 kbps}
mime audio/mpeg
;<} -32 {>;emit {MPEG ADTS, layer III, v1, 320 kbps}
mime audio/mpeg
;<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 44.1 kHz};<} 4 {>;emit {\b, 48 kHz};<} 8 {>;emit {\b, 32 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<
;<} -4 {>;emit {MPEG ADTS, layer II, v1}

switch -- [Nv byte 2 0 & 240] 16 {>;emit {\b,  32 kbps};<} 32 {>;emit {\b,  48 kbps};<} 48 {>;emit {\b,  56 kbps};<} 64 {>;emit {\b,  64 kbps};<} 80 {>;emit {\b,  80 kbps};<} 96 {>;emit {\b,  96 kbps};<} 112 {>;emit {\b, 112 kbps};<} -128 {>;emit {\b, 128 kbps};<} -112 {>;emit {\b, 160 kbps};<} -96 {>;emit {\b, 192 kbps};<} -80 {>;emit {\b, 224 kbps};<} -64 {>;emit {\b, 256 kbps};<} -48 {>;emit {\b, 320 kbps};<} -32 {>;emit {\b, 384 kbps};<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 44.1 kHz};<} 4 {>;emit {\b, 48 kHz};<} 8 {>;emit {\b, 32 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<

mime audio/mpeg
;<} -14 {>;emit {MPEG ADTS, layer III, v2}

switch -- [Nv byte 2 0 & 240] 16 {>;emit {\b,   8 kbps};<} 32 {>;emit {\b,  16 kbps};<} 48 {>;emit {\b,  24 kbps};<} 64 {>;emit {\b,  32 kbps};<} 80 {>;emit {\b,  40 kbps};<} 96 {>;emit {\b,  48 kbps};<} 112 {>;emit {\b,  56 kbps};<} -128 {>;emit {\b,  64 kbps};<} -112 {>;emit {\b,  80 kbps};<} -96 {>;emit {\b,  96 kbps};<} -80 {>;emit {\b, 112 kbps};<} -64 {>;emit {\b, 128 kbps};<} -48 {>;emit {\b, 144 kbps};<} -32 {>;emit {\b, 160 kbps};<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 22.05 kHz};<} 4 {>;emit {\b, 24 kHz};<} 8 {>;emit {\b, 16 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<

mime audio/mpeg
;<} -12 {>;emit {MPEG ADTS, layer II, v2}

switch -- [Nv byte 2 0 & 240] 16 {>;emit {\b,   8 kbps};<} 32 {>;emit {\b,  16 kbps };<} 48 {>;emit {\b,  24 kbps};<} 64 {>;emit {\b,  32 kbps};<} 80 {>;emit {\b,  40 kbps};<} 96 {>;emit {\b,  48 kbps};<} 112 {>;emit {\b,  56 kbps};<} -128 {>;emit {\b,  64 kbps};<} -112 {>;emit {\b,  80 kbps};<} -96 {>;emit {\b,  96 kbps};<} -80 {>;emit {\b, 112 kbps};<} -64 {>;emit {\b, 128 kbps};<} -48 {>;emit {\b, 144 kbps};<} -32 {>;emit {\b, 160 kbps};<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 22.05 kHz};<} 4 {>;emit {\b, 24 kHz};<} 8 {>;emit {\b, 16 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<

mime audio/mpeg
;<} -10 {>;emit {MPEG ADTS, layer I, v2}

switch -- [Nv byte 2 0 & 240] 16 {>;emit {\b,  32 kbps};<} 32 {>;emit {\b,  48 kbps};<} 48 {>;emit {\b,  56 kbps};<} 64 {>;emit {\b,  64 kbps};<} 80 {>;emit {\b,  80 kbps};<} 96 {>;emit {\b,  96 kbps};<} 112 {>;emit {\b, 112 kbps};<} -128 {>;emit {\b, 128 kbps};<} -112 {>;emit {\b, 144 kbps};<} -96 {>;emit {\b, 160 kbps};<} -80 {>;emit {\b, 176 kbps};<} -64 {>;emit {\b, 192 kbps};<} -48 {>;emit {\b, 224 kbps};<} -32 {>;emit {\b, 256 kbps};<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 22.05 kHz};<} 4 {>;emit {\b, 24 kHz};<} 8 {>;emit {\b, 16 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<

mime audio/mpeg
;<} -30 {>;emit {MPEG ADTS, layer III,  v2.5}

switch -- [Nv byte 2 0 & 240] 16 {>;emit {\b,   8 kbps};<} 32 {>;emit {\b,  16 kbps};<} 48 {>;emit {\b,  24 kbps};<} 64 {>;emit {\b,  32 kbps};<} 80 {>;emit {\b,  40 kbps};<} 96 {>;emit {\b,  48 kbps};<} 112 {>;emit {\b,  56 kbps};<} -128 {>;emit {\b,  64 kbps};<} -112 {>;emit {\b,  80 kbps};<} -96 {>;emit {\b,  96 kbps};<} -80 {>;emit {\b, 112 kbps};<} -64 {>;emit {\b, 128 kbps};<} -48 {>;emit {\b, 144 kbps};<} -32 {>;emit {\b, 160 kbps};<} 
<

switch -- [Nv byte 2 0 & 12] 0 {>;emit {\b, 11.025 kHz};<} 4 {>;emit {\b, 12 kHz};<} 8 {>;emit {\b, 8 kHz};<} 
<

switch -- [Nv byte 3 0 & 192] 0 {>;emit {\b, Stereo};<} 64 {>;emit {\b, JntStereo};<} -128 {>;emit {\b, 2x Monaural};<} -64 {>;emit {\b, Monaural};<} 
<

mime audio/mpeg
;<} 
<
} {
if {[S string 0 0 {} {} eq ADIF]} {>

emit {MPEG ADIF, AAC}

if {[N byte 4 0 0 {} {} & 128]} {>

	if {[N byte 13 0 0 {} {} & 16]} {>

	emit {\b, VBR}
<}

	if {[N byte 13 0 0 {} {} ^ 16]} {>

	emit {\b, CBR}
<}

	switch -- [Nv byte 16 0 & 30] 2 {>;emit {\b, single stream};<} 4 {>;emit {\b, 2 streams};<} 6 {>;emit {\b, 3 streams};<} 
<

	if {[N byte 16 0 0 {} {} & 8]} {>

	emit {\b, 4 or more streams}
<}

	if {[N byte 16 0 0 {} {} & 16]} {>

	emit {\b, 8 or more streams}
<}

	if {[N byte 4 0 0 {} {} & 128]} {>

	emit {\b, Copyrighted}
<}

	if {[N byte 13 0 0 {} {} & 64]} {>

	emit {\b, Original Source}
<}

	if {[N byte 13 0 0 {} {} & 32]} {>

	emit {\b, Home Flag}
<}

<}

if {[N byte 4 0 0 {} {} ^ 128]} {>

	if {[N byte 4 0 0 {} {} & 16]} {>

	emit {\b, VBR}
<}

	if {[N byte 4 0 0 {} {} ^ 16]} {>

	emit {\b, CBR}
<}

	switch -- [Nv byte 7 0 & 30] 2 {>;emit {\b, single stream};<} 4 {>;emit {\b, 2 streams};<} 6 {>;emit {\b, 3 streams};<} 
<

	if {[N byte 7 0 0 {} {} & 8]} {>

	emit {\b, 4 or more streams}
<}

	if {[N byte 7 0 0 {} {} & 16]} {>

	emit {\b, 8 or more streams}
<}

	if {[N byte 4 0 0 {} {} & 64]} {>

	emit {\b, Original Stream(s)}
<}

	if {[N byte 4 0 0 {} {} & 32]} {>

	emit {\b, Home Source}
<}

<}

mime audio/x-hx-aac-adif

<}
} {
if {[N beshort 0 0 0 & 65526 == 65520]} {>

emit {MPEG ADTS, AAC}

if {[N byte 1 0 0 {} {} & 8]} {>

emit {\b, v2}
<}

if {[N byte 1 0 0 {} {} ^ 8]} {>

emit {\b, v4}

	if {[N byte 2 0 0 {} {} & 192]} {>

	emit {\b LTP}
<}

<}

switch -- [Nv byte 2 0 & 192] 0 {>;emit {\b Main};<} 64 {>;emit {\b LC};<} -128 {>;emit {\b SSR};<} 
<

switch -- [Nv byte 2 0 & 60] 0 {>;emit {\b, 96 kHz};<} 4 {>;emit {\b, 88.2 kHz};<} 8 {>;emit {\b, 64 kHz};<} 12 {>;emit {\b, 48 kHz};<} 16 {>;emit {\b, 44.1 kHz};<} 20 {>;emit {\b, 32 kHz};<} 24 {>;emit {\b, 24 kHz};<} 28 {>;emit {\b, 22.05 kHz};<} 32 {>;emit {\b, 16 kHz};<} 36 {>;emit {\b, 12 kHz};<} 40 {>;emit {\b, 11.025 kHz};<} 44 {>;emit {\b, 8 kHz};<} 
<

switch -- [Nv beshort 2 0 & 448] 64 {>;emit {\b, monaural};<} 128 {>;emit {\b, stereo};<} 192 {>;emit {\b, stereo + center};<} 256 {>;emit {\b, stereo+center+LFE};<} 320 {>;emit {\b, surround};<} 384 {>;emit {\b, surround + LFE};<} 
<

if {[N beshort 2 0 0 {} {} & 448]} {>

emit {\b, surround + side}
<}

mime audio/x-hx-aac-adts

<}
} {
if {[N beshort 0 0 0 & 65504 == 22240]} {>

emit {MPEG-4 LOAS}

if {[N byte 3 0 0 & 224 == 64]} {>

	switch -- [Nv byte 4 0 & 60] 4 {>;emit {\b, single stream};<} 8 {>;emit {\b, 2 streams};<} 12 {>;emit {\b, 3 streams};<} 
<

	if {[N byte 4 0 0 {} {} & 8]} {>

	emit {\b, 4 or more streams}
<}

	if {[N byte 4 0 0 {} {} & 32]} {>

	emit {\b, 8 or more streams}
<}

<}

if {[N byte 3 0 0 & 192 == 0]} {>

	switch -- [Nv byte 4 0 & 120] 8 {>;emit {\b, single stream};<} 16 {>;emit {\b, 2 streams};<} 24 {>;emit {\b, 3 streams};<} 
<

	if {[N byte 4 0 0 {} {} & 32]} {>

	emit {\b, 4 or more streams}
<}

	if {[N byte 4 0 0 {} {} & 64]} {>

	emit {\b, 8 or more streams}
<}

<}

mime audio/x-mp4a-latm

<}
} {
switch -- [Nv leshort 4 0 {} {}] -20719 {>;
if {[N leshort 8 0 0 {} {} == 320]} {>

	if {[N leshort 10 0 0 {} {} == 200]} {>

		if {[N leshort 12 0 0 {} {} == 8]} {>

		emit {FLI animation, 320x200x8}

			if {[N leshort 6 0 0 {} {} x {}]} {>

			emit {\b, %d frames}
<}

			if {[N leshort 16 0 0 {} {} x {}]} {>

			emit {\b, %d/70s per frame}
<}

		mime video/x-fli

<}

<}

<}
;<} -20718 {>;
if {[N leshort 12 0 0 {} {} == 8]} {>

emit {FLC animation}

	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {\b, %d}
<}

	if {[N leshort 10 0 0 {} {} x {}]} {>

	emit {\bx%dx8}
<}

	if {[N leshort 6 0 0 {} {} x {}]} {>

	emit {\b, %d frames}
<}

	if {[N leshort 16 0 0 {} {} x {}]} {>

	emit {\b, %dms per frame}
<}

mime video/x-flc

<}
;<} 2304 {>;
if {[N byte 15 0 0 {} {} == 1]} {>

	if {[N byte 20 0 0 {} {} == 0]} {>

		if {[S string 30 0 {} {} eq \ \ \ ]} {>

			if {[N byte 35 0 0 {} {} == 1]} {>

				if {[N byte 37 0 0 {} {} == 0]} {>

					if {[S string 21 0 {} {} > \x30]} {>

						if {[S string 21 0 {} {} < \x5A]} {>

						emit {Konami King's Valley-2 custom stage, title: "%-8.8s"}

							if {[N byte 29 0 0 {} {} < 32]} {>

							emit {\b, theme: %d}
<}

<}

<}

<}

<}

<}

<}

<}
;<} 
<
} {
if {[N belong 0 0 0 & 4284481296 == 1195376656]} {>

if {[N byte 188 0 0 {} {} == 71]} {>

emit {MPEG transport stream data}
<}

<}
} {
if {[S string 0 0 {} {} eq \x8aMNG]} {>

emit {MNG video data,}

if {[N belong 4 0 0 {} {} != 218765834]} {>

emit CORRUPTED,
<}

if {[N belong 4 0 0 {} {} == 218765834]} {>

	if {[N belong 16 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N belong 20 0 0 {} {} x {}]} {>

	emit %d
<}

<}

mime video/x-mng

<}
} {
if {[S string 0 0 {} {} eq \x8bJNG]} {>

emit {JNG video data,}

if {[N belong 4 0 0 {} {} != 218765834]} {>

emit CORRUPTED,
<}

if {[N belong 4 0 0 {} {} == 218765834]} {>

	if {[N belong 16 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N belong 20 0 0 {} {} x {}]} {>

	emit %d
<}

<}

mime video/x-jng

<}
} {
if {[S string 3 0 {} {} eq \x0D\x0AVersion:Vivo]} {>

emit {Vivo video data}
<}
} {
if {[S string 0 0 w {} eq \#VRML\ V1.0\ ascii]} {>

emit {VRML 1 file}
mime model/vrml

<}
} {
if {[S string 0 0 w {} eq \#VRML\ V2.0\ utf8]} {>

emit {ISO/IEC 14772 VRML 97 file}
mime model/vrml

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=\"]} {>

if {[S search 20 0 {c w} 1000 eq <!DOCTYPE\ X3D]} {>

emit {X3D (Extensible 3D) model xml text}
mime model/x3d

<}

<}
} {
if {[S string 0 0 {} {} eq HVQM4]} {>

emit %s

if {[S string 6 0 {} {} > \0]} {>

emit v%s
<}

if {[N byte 0 0 0 {} {} x {}]} {>

emit {GameCube movie,}
<}

if {[N beshort 52 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N beshort 54 0 0 {} {} x {}]} {>

emit %d,
<}

if {[N beshort 38 0 0 {} {} x {}]} {>

emit %dus,
<}

if {[N beshort 66 0 0 {} {} == 0]} {>

emit {no audio}
<}

if {[N beshort 66 0 0 {} {} > 0]} {>

emit {%dHz audio}
<}

<}
} {
if {[S string 0 0 {} {} eq DVDVIDEO-VTS]} {>

emit {Video title set,}

if {[N byte 33 0 0 {} {} x {}]} {>

emit v%x
<}

<}
} {
if {[S string 0 0 {} {} eq DVDVIDEO-VMG]} {>

emit {Video manager,}

if {[N byte 33 0 0 {} {} x {}]} {>

emit v%x
<}

<}
} {
if {[S string 0 0 {} {} eq NuppelVideo]} {>

emit {MythTV NuppelVideo}

if {[S string 12 0 {} {} x {}]} {>

emit v%s
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit (%d
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {\bx%d),}
<}

if {[S string 36 0 {} {} eq P]} {>

emit {\bprogressive,}
<}

if {[S string 36 0 {} {} eq I]} {>

emit {\binterlaced,}
<}

if {[N ledouble 40 0 0 {} {} x {}]} {>

emit {\baspect:%.2f,}
<}

if {[N ledouble 48 0 0 {} {} x {}]} {>

emit {\bfps:%.2f}
<}

<}
} {
if {[S string 0 0 {} {} eq MythTV]} {>

emit {MythTV NuppelVideo}

if {[S string 12 0 {} {} x {}]} {>

emit v%s
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit (%d
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {\bx%d),}
<}

if {[S string 36 0 {} {} eq P]} {>

emit {\bprogressive,}
<}

if {[S string 36 0 {} {} eq I]} {>

emit {\binterlaced,}
<}

if {[N ledouble 40 0 0 {} {} x {}]} {>

emit {\baspect:%.2f,}
<}

if {[N ledouble 48 0 0 {} {} x {}]} {>

emit {\bfps:%.2f}
<}

<}
} {
if {[S string 0 0 {} {} eq BIK]} {>

emit {Bink Video}

if {[S regex 3 0 {} {} eq \[a-z\]]} {>

emit rev.%s
<}

if {[N lelong 20 0 0 {} {} x {}]} {>

emit {\b, %d}
<}

if {[N lelong 24 0 0 {} {} x {}]} {>

emit {\bx%d}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, %d frames}
<}

if {[N lelong 32 0 0 {} {} x {}]} {>

emit {at rate %d/}
<}

if {[N lelong 28 0 0 {} {} > 1]} {>

emit {\b%d}
<}

if {[N lelong 40 0 0 {} {} == 0]} {>

emit {\b, no audio}
<}

if {[N lelong 40 0 0 {} {} != 0]} {>

emit {\b, %d audio track}

	if {[N lelong 40 0 0 {} {} != 1]} {>

	emit {\bs}
<}

	if {[N leshort 48 0 0 {} {} x {}]} {>

	emit %dHz
<}

	if {[N byte 51 0 0 & 32 == 0]} {>

	emit mono
<}

	if {[N byte 51 0 0 & 32 != 0]} {>

	emit stereo
<}

<}

<}
} {
if {[S string 0 0 {} {} eq nut/multimedia\ container\0]} {>

emit {NUT multimedia container}
<}
} {
if {[S string 0 0 {} {} eq NSVf]} {>

emit {Nullsoft Video}
<}
} {
if {[S string 4 0 {} {} eq RED1]} {>

emit {REDCode Video}
<}
} {
if {[S string 0 0 {} {} eq AMVS]} {>

emit {MTV Multimedia File}
<}
} {
if {[S string 0 0 {} {} eq ARMovie\012]} {>

emit ARMovie
<}
} {
if {[S string 0 0 {} {} eq Interplay\040MVE\040File\032]} {>

emit {Interplay MVE Movie}
<}
} {
if {[S string 0 0 {} {} eq FILM]} {>

emit {Sega FILM/CPK Multimedia,}

if {[N belong 32 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N belong 28 0 0 {} {} x {}]} {>

emit %d
<}

<}
} {
if {[S string 0 0 {} {} eq THP\0]} {>

emit {Nintendo THP Multimedia}
<}
} {
if {[S string 0 0 {} {} eq BBCD]} {>

emit {BBC Dirac Video}
<}
} {
if {[S string 0 0 {} {} eq SMK]} {>

emit {RAD Game Tools Smacker Multimedia}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {version %c,}
<}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit %d,
<}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {%d frames}
<}

<}
} {
if {[S string 0 0 {} {} eq FORM]} {>

emit {IFF data}

if {[S string 8 0 {} {} eq AIFF]} {>

emit {\b, AIFF audio}
mime audio/x-aiff

<}

if {[S string 8 0 {} {} eq AIFC]} {>

emit {\b, AIFF-C compressed audio}
mime audio/x-aiff

<}

if {[S string 8 0 {} {} eq 8SVX]} {>

emit {\b, 8SVX 8-bit sampled sound voice}
mime audio/x-aiff

<}

if {[S string 8 0 {} {} eq 16SV]} {>

emit {\b, 16SV 16-bit sampled sound voice}
<}

if {[S string 8 0 {} {} eq SAMP]} {>

emit {\b, SAMP sampled audio}
<}

if {[S string 8 0 {} {} eq MAUD]} {>

emit {\b, MAUD MacroSystem audio}
<}

if {[S string 8 0 {} {} eq SMUS]} {>

emit {\b, SMUS simple music}
<}

if {[S string 8 0 {} {} eq CMUS]} {>

emit {\b, CMUS complex music}
<}

if {[S string 8 0 {} {} eq ILBMBMHD]} {>

emit {\b, ILBM interleaved image}

	if {[N beshort 20 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N beshort 22 0 0 {} {} x {}]} {>

	emit %d
<}

<}

if {[S string 8 0 {} {} eq RGBN]} {>

emit {\b, RGBN 12-bit RGB image}
<}

if {[S string 8 0 {} {} eq RGB8]} {>

emit {\b, RGB8 24-bit RGB image}
<}

if {[S string 8 0 {} {} eq DEEP]} {>

emit {\b, DEEP TVPaint/XiPaint image}
<}

if {[S string 8 0 {} {} eq DR2D]} {>

emit {\b, DR2D 2-D object}
<}

if {[S string 8 0 {} {} eq TDDD]} {>

emit {\b, TDDD 3-D rendering}
<}

if {[S string 8 0 {} {} eq LWOB]} {>

emit {\b, LWOB 3-D object}
<}

if {[S string 8 0 {} {} eq LWO2]} {>

emit {\b, LWO2 3-D object, v2}
<}

if {[S string 8 0 {} {} eq LWLO]} {>

emit {\b, LWLO 3-D layered object}
<}

if {[S string 8 0 {} {} eq REAL]} {>

emit {\b, REAL Real3D rendering}
<}

if {[S string 8 0 {} {} eq MC4D]} {>

emit {\b, MC4D MaxonCinema4D rendering}
<}

if {[S string 8 0 {} {} eq ANIM]} {>

emit {\b, ANIM animation}
<}

if {[S string 8 0 {} {} eq YAFA]} {>

emit {\b, YAFA animation}
<}

if {[S string 8 0 {} {} eq SSA\ ]} {>

emit {\b, SSA super smooth animation}
<}

if {[S string 8 0 {} {} eq ACBM]} {>

emit {\b, ACBM continuous image}
<}

if {[S string 8 0 {} {} eq FAXX]} {>

emit {\b, FAXX fax image}
<}

if {[S string 8 0 {} {} eq FTXT]} {>

emit {\b, FTXT formatted text}
<}

if {[S string 8 0 {} {} eq CTLG]} {>

emit {\b, CTLG message catalog}
<}

if {[S string 8 0 {} {} eq PREF]} {>

emit {\b, PREF preferences}
<}

if {[S string 8 0 {} {} eq DTYP]} {>

emit {\b, DTYP datatype description}
<}

if {[S string 8 0 {} {} eq PTCH]} {>

emit {\b, PTCH binary patch}
<}

if {[S string 8 0 {} {} eq AMFF]} {>

emit {\b, AMFF AmigaMetaFile format}
<}

if {[S string 8 0 {} {} eq WZRD]} {>

emit {\b, WZRD StormWIZARD resource}
<}

if {[S string 8 0 {} {} eq DOC\ ]} {>

emit {\b, DOC desktop publishing document}
<}

if {[S string 8 0 {} {} eq WVQA]} {>

emit {\b, Westwood Studios VQA Multimedia,}

	if {[N leshort 24 0 0 {} {} x {}]} {>

	emit {%d video frames,}
<}

	if {[N leshort 26 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 28 0 0 {} {} x {}]} {>

	emit %d
<}

<}

if {[S string 8 0 {} {} eq MOVE]} {>

emit {\b, Wing Commander III Video}

	if {[S string 12 0 {} {} eq _PC_]} {>

	emit {\b, PC version}
<}

	if {[S string 12 0 {} {} eq 3DO_]} {>

	emit {\b, 3DO version}
<}

<}

if {[S string 8 0 {} {} eq IFRS]} {>

emit {\b, Blorb Interactive Fiction}

	if {[S string 24 0 {} {} eq Exec]} {>

	emit {with executable chunk}
<}

<}

if {[S string 8 0 {} {} eq IFZS]} {>

emit {\b, Z-machine or Glulx saved game file (Quetzal)}
mime application/x-blorb

<}

<}
} {
if {[S string 0 0 {} {} eq ACMP]} {>

emit {Map file for the AssaultCube FPS game}
<}
} {
if {[S string 0 0 {} {} eq CUBE]} {>

emit {Map file for cube and cube2 engine games}
<}
} {
if {[S string 0 0 {} {} eq MAPZ)]} {>

emit {Map file for the Blood Frontier/Red Eclipse FPS games}
<}
} {
if {[S string 0 0 t {} eq \"\"\"]} {>

emit {Python script text executable}
<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/python]} {>

emit {Python script text executable}
mime text/x-python

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/python]} {>

emit {Python script text executable}
mime text/x-python

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ python]} {>

emit {Python script text executable}
mime text/x-python

<}
} {
if {[S search 0 0 {} 10 eq \#!\ /usr/bin/env\ python]} {>

emit {Python script text executable}
mime text/x-python

<}
} {
if {[S regex 0 0 {} {} eq ^from\\s+(\\w|\\.)+\\s+import.*\$]} {>

emit {Python script text executable}
mime text/x-python

<}
} {
if {[Sx search 0 0 {} 4096 eq def\ __init__]} {>

if {[Sx search [R 0] 0 {} 64 eq self]} {>

emit {Python script text executable}
mime text/x-python

<}

<}
} {
if {[Sx search 0 0 {} 4096 eq try:]} {>

if {[Sx regex [R 0] 0 {} {} eq ^\\s*except.*:]} {>

emit {Python script text executable}
mime text/x-python

<}

if {[Sx search [R 0] 0 {} 4096 eq finally:]} {>

emit {Python script text executable}
mime text/x-python

<}

<}
} {
if {[Sx regex 0 0 {} {} eq ^(\ |\\t)\{0,50\}def\ \{1,50\}\[a-zA-Z\]\{1,100\}]} {>

if {[Sx regex [R 0] 0 {} {} eq \ \{0,50\}\\((\[a-zA-Z\]|,|\ )\{1,255\}\\):\$]} {>

emit {Python script text executable}
mime text/x-python

<}

<}
} {
if {[S string 0 0 {} {} eq GOOF----]} {>

emit {Guile Object}

if {[S string 8 0 {} {} eq LE]} {>

emit {\b, little endian}
<}

if {[S string 8 0 {} {} eq BE]} {>

emit {\b, big endian}
<}

if {[S string 11 0 {} {} eq 4]} {>

emit {\b, 32bit}
<}

if {[S string 11 0 {} {} eq 8]} {>

emit {\b, 64bit}
<}

if {[S regex 13 0 {} {} eq ...]} {>

emit {\b, bytecode v%s}
<}

<}
} {
if {[S string 514 0 {} {} eq \377\377\377\377\000]} {>

if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

emit {Claris clip art}
<}

<}
} {
if {[S string 514 0 {} {} eq \377\377\377\377\001]} {>

if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

emit {Claris clip art}
<}

<}
} {
if {[S string 0 0 {} {} eq \002\000\210\003\102\117\102\117\000\001\206]} {>

emit {Claris works document}
<}
} {
if {[S string 0 0 {} {} eq \020\341\000\000\010\010]} {>

emit {Claris Works palette files .plt}
<}
} {
if {[S string 0 0 {} {} eq \002\271\262\000\040\002\000\164]} {>

emit {Claris works dictionary}
<}
} {
if {[S string 1 0 {} {} eq PC\ Research,\ Inc]} {>

emit Digifax-G3-File

switch -- [Nv byte 29 0 {} {}] 1 {>;emit {\b, fine resolution};<} 0 {>;emit {\b, normal resolution};<} 
<

<}
} {
if {[S string 0 0 {} {} eq RMD1]} {>

emit {raw modem data}

if {[S string 4 0 {} {} > \0]} {>

emit {(%s /}
<}

if {[N short 20 0 0 {} {} > 0]} {>

emit {compression type 0x%04x)}
<}

<}
} {
if {[S string 0 0 {} {} eq PVF1\n]} {>

emit {portable voice format}

if {[S string 5 0 {} {} > \0]} {>

emit {(binary %s)}
<}

<}
} {
if {[S string 0 0 {} {} eq PVF2\n]} {>

emit {portable voice format}

if {[S string 5 0 {} {} > \0]} {>

emit {(ascii %s)}
<}

<}
} {
if {[S search 0 0 {} 1 eq diff\ ]} {>

emit {diff output text}
mime text/x-diff

<}
} {
if {[S search 0 0 {} 1 eq ***\ ]} {>

emit {diff output text}
mime text/x-diff

<}
} {
if {[S search 0 0 {} 1 eq Only\ in\ ]} {>

emit {diff output text}
mime text/x-diff

<}
} {
if {[S search 0 0 {} 1 eq Common\ subdirectories:\ ]} {>

emit {diff output text}
mime text/x-diff

<}
} {
if {[S search 0 0 {} 1 eq Index:]} {>

emit {RCS/CVS diff output text}
mime text/x-diff

<}
} {
if {[S string 0 0 b {} eq BSDIFF40]} {>

emit {bsdiff(1) patch file}
<}
} {
if {[Sx search 0 0 {} 4096 eq ---\ ]} {>

if {[Sx search [R 0] 0 {} 1024 eq \n]} {>

	if {[Sx search [R 0] 0 {} 1 eq +++\ ]} {>

		if {[Sx search [R 0] 0 {} 1024 eq \n]} {>

			if {[Sx search [R 0] 0 {} 1 eq @@]} {>

			emit {unified diff output text}
			mime text/x-diff

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq MeTaSt00r3]} {>

emit {Metastore data file, }

if {[N bequad 10 0 0 {} {} x {}]} {>

emit {version %0llx}
<}

<}
} {
if {[S string 0 0 {} {} eq \{\\rtf]} {>

emit {Rich Text Format data,}

if {[S string 5 0 {} {} eq 1]} {>

emit {version 1,}

	if {[S string 6 0 {} {} eq \\ansi]} {>

	emit ANSI
<}

	if {[S string 6 0 {} {} eq \\mac]} {>

	emit {Apple Macintosh}
<}

	if {[S string 6 0 {} {} eq \\pc]} {>

	emit {IBM PC, code page 437}
<}

	if {[S string 6 0 {} {} eq \\pca]} {>

	emit {IBM PS/2, code page 850}
<}

	if {[S default 6 0 {} {} x {}]} {>

	emit {unknown character set}
<}

<}

if {[S default 5 0 {} {} x {}]} {>

emit {unknown version}
<}

mime text/rtf

<}
} {
switch -- [Nvx leshort 510 0 {} {}] -21931 {>;
if {[Sx string 3 0 {} {} ne MS]} {>

	if {[Sx string 3 0 {} {} ne SYSLINUX]} {>

		if {[Sx string 3 0 {} {} ne MTOOL]} {>

			if {[Sx string 3 0 {} {} ne NEWLDR]} {>

				if {[Sx string 5 0 {} {} ne DOS]} {>

					if {[Sx string 82 0 {} {} ne FAT32]} {>

						if {[Sx string 514 0 {} {} ne HdrS]} {>

							if {[Sx string 422 0 {} {} ne Be\ Boot\ Loader]} {>

								if {[Nx byte 450 0 0 {} {} == 238]} {>

									if {[Nx byte 466 0 0 {} {} != 238]} {>

										if {[Nx byte 482 0 0 {} {} != 238]} {>

											if {[Nx byte 498 0 0 {} {} != 238]} {>

												if {[Sx string [I 454 lelong 0 * 0 8192] 0 {} {} eq EFI\ PART]} {>

												emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

													if {[N byte 0 0 0 {} {} x {}]} {>

													emit {of 8192 bytes		}
<}

<}

												if {[Sx string [I 454 lelong 0 * 0 8192] 0 {} {} ne EFI\ PART]} {>

													if {[Sx string [I 454 lelong 0 * 0 4096] 0 {} {} eq EFI\ PART]} {>

													emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

														if {[N byte 0 0 0 {} {} x {}]} {>

														emit {of 4096 bytes}
<}

<}

													if {[Sx string [I 454 lelong 0 * 0 4096] 0 {} {} ne EFI\ PART]} {>

														if {[Sx string [I 454 lelong 0 * 0 2048] 0 {} {} eq EFI\ PART]} {>

														emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

															if {[N byte 0 0 0 {} {} x {}]} {>

															emit {of 2048 bytes}
<}

<}

														if {[Sx string [I 454 lelong 0 * 0 2048] 0 {} {} ne EFI\ PART]} {>

															if {[Sx string [I 454 lelong 0 * 0 1024] 0 {} {} eq EFI\ PART]} {>

															emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																if {[N byte 0 0 0 {} {} x {}]} {>

																emit {of 1024 bytes}
<}

<}

															if {[Sx string [I 454 lelong 0 * 0 1024] 0 {} {} ne EFI\ PART]} {>

																if {[Sx string [I 454 lelong 0 * 0 512] 0 {} {} eq EFI\ PART]} {>

																emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																	if {[N byte 0 0 0 {} {} x {}]} {>

																	emit {of 512 bytes}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

								if {[Nx byte 450 0 0 {} {} != 238]} {>

									if {[Nx byte 466 0 0 {} {} == 238]} {>

										if {[Nx byte 482 0 0 {} {} != 238]} {>

											if {[Nx byte 498 0 0 {} {} != 238]} {>

												if {[Sx string [I 470 lelong 0 * 0 8192] 0 {} {} eq EFI\ PART]} {>

												emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

													if {[N byte 0 0 0 {} {} x {}]} {>

													emit {of 8192 bytes		}
<}

<}

												if {[Sx string [I 470 lelong 0 * 0 8192] 0 {} {} ne EFI\ PART]} {>

													if {[Sx string [I 470 lelong 0 * 0 4096] 0 {} {} eq EFI\ PART]} {>

													emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

														if {[N byte 0 0 0 {} {} x {}]} {>

														emit {of 4096 bytes}
<}

<}

													if {[Sx string [I 470 lelong 0 * 0 4096] 0 {} {} ne EFI\ PART]} {>

														if {[Sx string [I 470 lelong 0 * 0 2048] 0 {} {} eq EFI\ PART]} {>

														emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

															if {[N byte 0 0 0 {} {} x {}]} {>

															emit {of 2048 bytes}
<}

<}

														if {[Sx string [I 470 lelong 0 * 0 2048] 0 {} {} ne EFI\ PART]} {>

															if {[Sx string [I 470 lelong 0 * 0 1024] 0 {} {} eq EFI\ PART]} {>

															emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																if {[N byte 0 0 0 {} {} x {}]} {>

																emit {of 1024 bytes}
<}

<}

															if {[Sx string [I 470 lelong 0 * 0 1024] 0 {} {} ne EFI\ PART]} {>

																if {[Sx string [I 470 lelong 0 * 0 512] 0 {} {} eq EFI\ PART]} {>

																emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																	if {[N byte 0 0 0 {} {} x {}]} {>

																	emit {of 512 bytes}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

								if {[Nx byte 450 0 0 {} {} != 238]} {>

									if {[Nx byte 466 0 0 {} {} != 238]} {>

										if {[Nx byte 482 0 0 {} {} == 238]} {>

											if {[Nx byte 498 0 0 {} {} != 238]} {>

												if {[Sx string [I 486 lelong 0 * 0 8192] 0 {} {} eq EFI\ PART]} {>

												emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

													if {[N byte 0 0 0 {} {} x {}]} {>

													emit {of 8192 bytes		}
<}

<}

												if {[Sx string [I 486 lelong 0 * 0 8192] 0 {} {} ne EFI\ PART]} {>

													if {[Sx string [I 486 lelong 0 * 0 4096] 0 {} {} eq EFI\ PART]} {>

													emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

														if {[N byte 0 0 0 {} {} x {}]} {>

														emit {of 4096 bytes}
<}

<}

													if {[Sx string [I 486 lelong 0 * 0 4096] 0 {} {} ne EFI\ PART]} {>

														if {[Sx string [I 486 lelong 0 * 0 2048] 0 {} {} eq EFI\ PART]} {>

														emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

															if {[N byte 0 0 0 {} {} x {}]} {>

															emit {of 2048 bytes}
<}

<}

														if {[Sx string [I 486 lelong 0 * 0 2048] 0 {} {} ne EFI\ PART]} {>

															if {[Sx string [I 486 lelong 0 * 0 1024] 0 {} {} eq EFI\ PART]} {>

															emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																if {[N byte 0 0 0 {} {} x {}]} {>

																emit {of 1024 bytes}
<}

<}

															if {[Sx string [I 486 lelong 0 * 0 1024] 0 {} {} ne EFI\ PART]} {>

																if {[Sx string [I 486 lelong 0 * 0 512] 0 {} {} eq EFI\ PART]} {>

																emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																	if {[N byte 0 0 0 {} {} x {}]} {>

																	emit {of 512 bytes}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

								if {[Nx byte 450 0 0 {} {} != 238]} {>

									if {[Nx byte 466 0 0 {} {} != 238]} {>

										if {[Nx byte 482 0 0 {} {} != 238]} {>

											if {[Nx byte 498 0 0 {} {} == 238]} {>

												if {[Sx string [I 502 lelong 0 * 0 8192] 0 {} {} eq EFI\ PART]} {>

												emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

													if {[N byte 0 0 0 {} {} x {}]} {>

													emit {of 8192 bytes		}
<}

<}

												if {[Sx string [I 502 lelong 0 * 0 8192] 0 {} {} ne EFI\ PART]} {>

													if {[Sx string [I 502 lelong 0 * 0 4096] 0 {} {} eq EFI\ PART]} {>

													emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

														if {[N byte 0 0 0 {} {} x {}]} {>

														emit {of 4096 bytes}
<}

<}

													if {[Sx string [I 502 lelong 0 * 0 4096] 0 {} {} ne EFI\ PART]} {>

														if {[Sx string [I 502 lelong 0 * 0 2048] 0 {} {} eq EFI\ PART]} {>

														emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

															if {[N byte 0 0 0 {} {} x {}]} {>

															emit {of 2048 bytes}
<}

<}

														if {[Sx string [I 502 lelong 0 * 0 2048] 0 {} {} ne EFI\ PART]} {>

															if {[Sx string [I 502 lelong 0 * 0 1024] 0 {} {} eq EFI\ PART]} {>

															emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																if {[N byte 0 0 0 {} {} x {}]} {>

																emit {of 1024 bytes}
<}

<}

															if {[Sx string [I 502 lelong 0 * 0 1024] 0 {} {} ne EFI\ PART]} {>

																if {[Sx string [I 502 lelong 0 * 0 512] 0 {} {} eq EFI\ PART]} {>

																emit {GPT partition table}
U 165 gpt-mbr-type
U 165 gpt-table

																	if {[N byte 0 0 0 {} {} x {}]} {>

																	emit {of 512 bytes}
<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}
;<} -21931 {>;emit {DOS/MBR boot sector}

if {[S string 2 0 {} {} eq OSBS]} {>

emit {OS/BS MBR}
<}

if {[Sx search 0 0 {} 2 eq \x33\xc0\x8e\xd0\xbc\x00\x7c]} {>

emit MS-MBR

	switch -- [Nvx bequad 8 0 {} {}] -8361970615780901892 {>;
		switch -- [Nvx byte 22 0 {} {}] -13 {>;emit {\b,DOS 2}

			if {[Sx regex 219 0 {} {} eq Author\ -\ ]} {>

			emit Author:

				if {[Sx string [R 0] 0 {} {} x {}]} {>

				emit {"%s"}
<}

<}
;<} -14 {>;
			if {[N bequad 34 0 0 {} {} == 13797911610017883509]} {>

			emit {\b,NEC 3.3}
<}

			if {[S default 34 0 {} {} x {}]} {>

			emit {\b,D0S version 3.3-7.0}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Invalid\ partition\ table]} {>

				emit english
<}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Ung\201ltige\ Partitionstabelle]} {>

				emit german
<}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Table\ de\ partition\ invalide]} {>

				emit french
<}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Tabela\ de\ parti\207ao\ inv\240lida]} {>

				emit portuguese
<}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Tabla\ de\ partici\242n\ no\ v\240lida]} {>

				emit spanish
<}

				if {[S string [I 73 byte 0 0 0 0] 0 {} {} eq Tavola\ delle\ partizioni\ non\ valida]} {>

				emit italian
<}

				if {[N byte 73 0 0 {} {} > 0]} {>

				emit {at offset 0x%x}

					if {[S string [I 73 byte 0 0 0 0] 0 {} {} > \0]} {>

					emit {"%s"}
<}

<}

				if {[N byte 116 0 0 {} {} > 0]} {>

				emit {at offset 0x%x}

					if {[S string [I 116 byte 0 0 0 0] 0 {} {} > \0]} {>

					emit {"%s"}
<}

<}

				if {[N byte 121 0 0 {} {} > 0]} {>

				emit {at offset 0x%x}

					if {[S string [I 121 byte 0 0 0 0] 0 {} {} > \0]} {>

					emit {"%s"}
<}

<}

<}
;<} 
<
;<} 5766665946185735036 {>;
		switch -- [Nv bequad 24 0 {} {}] -890362806220115708 {>;emit 9M

			if {[S string [I 60 byte 0 + 0 255] 0 {} {} eq Invalid\ partition\ table]} {>

			emit english
<}

			if {[S string [I 60 byte 0 + 0 255] 0 {} {} eq Ung\201ltige\ Partitionstabelle]} {>

			emit german
<}

			if {[S string [I 60 byte 0 + 0 255] 0 {} {} eq Table\ de\ partition\ erron\202e]} {>

			emit french
<}

			if {[S string [I 60 byte 0 + 0 255] 0 {} {} eq \215\245\257\340\240\242\250\253\354\255\240\357\ \342\240\241\253\250\346\240]} {>

			emit russian
<}

			if {[N byte 60 0 0 {} {} x {}]} {>

			emit {at offset 0x%x+0xFF}
<}

			if {[S string [I 60 byte 0 + 0 255] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 189 0 0 {} {} x {}]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 189 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 169 0 0 {} {} x {}]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 169 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}
;<} -890362810515083004 {>;emit XP

			switch -- [Nv belong 436 0 & 16777215] 2901091 {>;emit english;<} 2902126 {>;emit german;<} 
<

			if {[N byte 437 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 437 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 438 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 438 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 439 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 439 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}
;<} 
<
;<} -4571478261170913536 {>;
		switch -- [Nv bequad 236 0 {} {}] 8447458234516915024 {>;emit Vista

			if {[N belong 436 0 0 & 16777215 == 6453913]} {>

			emit english
<}

			if {[N byte 437 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 437 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 438 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 438 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 439 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 439 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}
;<} 7386461203189481845 {>;emit {Windows 7}

			if {[N belong 436 0 0 & 16777215 == 6519706]} {>

			emit english
<}

			if {[N byte 437 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 437 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 438 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 438 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}

			if {[N byte 439 0 0 {} {} > 0]} {>

			emit {at offset 0x1%x}
<}

			if {[S string [I 439 byte 0 + 0 256] 0 {} {} > \0]} {>

			emit {"%s"}
<}
;<} 
<
;<} 
<

	if {[N lelong 440 0 0 {} {} > 0]} {>

	emit {\b, disk signature 0x%-.4x}
<}

	if {[N leshort 218 0 0 {} {} == 0]} {>

		if {[N lelong 220 0 0 {} {} > 0]} {>

		emit {\b, created}

			if {[N byte 220 0 0 {} {} x {}]} {>

			emit {with driveID 0x%x}
<}

			if {[N byte 223 0 0 {} {} x {}]} {>

			emit {at %x}
<}

			if {[N byte 222 0 0 {} {} x {}]} {>

			emit {\b:%x}
<}

			if {[N byte 221 0 0 {} {} x {}]} {>

			emit {\b:%x}
<}

<}

<}

<}

if {[N bequad 0 0 0 {} {} == 18066242684150922240]} {>

	if {[N bequad 8 0 0 {} {} == 142985680396521176]} {>

	emit {MS-MBR,D0S version 3.21 spanish}
<}

<}

if {[S string 157 0 {} {} eq Invalid\ partition\ table\$]} {>

	if {[S string 181 0 {} {} eq No\ Operating\ System\$]} {>

		if {[S string 201 0 {} {} eq Operating\ System\ load\ error\$]} {>

		emit {\b, DR-DOS MBR, Version 7.01 to 7.03}
<}

<}

<}

if {[S string 157 0 {} {} eq Invalid\ partition\ table\$]} {>

	if {[S string 181 0 {} {} eq No\ operating\ system\$]} {>

		if {[S string 201 0 {} {} eq Operating\ system\ load\ error\$]} {>

		emit {\b, DR-DOS MBR, Version 7.01 to 7.03}
<}

<}

<}

if {[S string 342 0 {} {} eq Invalid\ partition\ table\$]} {>

	if {[S string 366 0 {} {} eq No\ operating\ system\$]} {>

		if {[S string 386 0 {} {} eq Operating\ system\ load\ error\$]} {>

		emit {\b, DR-DOS MBR, version 7.01 to 7.03}
<}

<}

<}

if {[S string 295 0 {} {} eq NEWLDR\0]} {>

	if {[S string 302 0 {} {} eq Bad\ PT\ \$]} {>

		if {[S string 310 0 {} {} eq No\ OS\ \$]} {>

			if {[S string 317 0 {} {} eq OS\ load\ err\$]} {>

				if {[S string 329 0 {} {} eq Moved\ or\ missing\ IBMBIO.LDR\n\r]} {>

					if {[S string 358 0 {} {} eq Press\ any\ key\ to\ continue.\n\r\$]} {>

						if {[S string 387 0 {} {} eq Copyright\ (c)\ 1984,1998]} {>

							if {[S string 411 0 {} {} eq Caldera\ Inc.\0]} {>

							emit {\b, DR-DOS MBR (IBMBIO.LDR)}
<}

<}

<}

<}

<}

<}

<}

<}

if {[S search 325 0 {} 7 eq Default:\ F]} {>

emit {\b, FREE-DOS MBR}
<}

if {[S string 64 0 {} {} eq no\ active\ partition\ found]} {>

	if {[S string 96 0 {} {} eq read\ error\ while\ reading\ drive]} {>

	emit {\b, FREE-DOS Beta 0.9 MBR}
<}

<}

if {[S search 387 0 {} 4 eq \0\ Error!\r]} {>

	if {[S search 378 0 {} 7 eq Virus!]} {>

		if {[S search 397 0 {} 4 eq Booting\ ]} {>

			if {[S search 408 0 {} 4 eq HD1/\0]} {>

			emit {\b, Ranish MBR (}

				if {[S string 416 0 {} {} eq Writing\ changes...]} {>

				emit {\b2.37}

					if {[N byte 438 0 0 {} {} x {}]} {>

					emit {\b,0x%x dots}
<}

					if {[N byte 440 0 0 {} {} > 0]} {>

					emit {\b,virus check}
<}

					if {[N byte 441 0 0 {} {} > 0]} {>

					emit {\b,partition %c}
<}

<}

				if {[S string 416 0 {} {} ne Writing\ changes...]} {>

				emit {\b}

					if {[N byte 418 0 0 {} {} == 1]} {>

					emit {\bvirus check,}
<}

					if {[N byte 419 0 0 {} {} x {}]} {>

					emit {\b0x%x seconds}
<}

					if {[N byte 420 0 0 & 15 > 0]} {>

					emit {\b,partition}

						if {[N byte 420 0 0 & 15 < 5]} {>

						emit {\b %x}
<}

						if {[N byte 420 0 0 & 15 == 15]} {>

						emit {\b ask}
<}

<}

<}

				if {[N byte 420 0 0 {} {} x {}]} {>

				emit {\b)}
<}

<}

<}

<}

<}

if {[S string 362 0 {} {} eq MBR\ Error\ \0\r]} {>

	if {[S string 376 0 {} {} eq ress\ any\ key\ to\ ]} {>

		if {[S string 392 0 {} {} eq boot\ from\ floppy...\0]} {>

		emit {\b, Acronis MBR}
<}

<}

<}

if {[S string 309 0 {} {} eq No\ bootable\ partition\ found\r]} {>

	if {[S string 339 0 {} {} eq I/O\ Error\ reading\ boot\ sector\r]} {>

	emit {\b, Visopsys MBR}
<}

<}

if {[S string 349 0 {} {} eq No\ bootable\ partition\ found\r]} {>

	if {[S string 379 0 {} {} eq I/O\ Error\ reading\ boot\ sector\r]} {>

	emit {\b, simple Visopsys MBR}
<}

<}

if {[S string 64 0 {} {} eq SBML]} {>

	if {[S string 43 0 {} {} eq SMART\ BTMGR]} {>

		if {[S string 430 0 {} {} eq SBMK\ Bad!\r]} {>

		emit {\b, Smart Boot Manager}

			if {[S string 6 0 {} {} > \0]} {>

			emit {\b, version %s}
<}

<}

<}

<}

if {[S string 382 0 {} {} eq XOSLLOADXCF]} {>

emit {\b, eXtended Operating System Loader}
<}

if {[S string 6 0 {} {} eq LILO]} {>

emit {\b, LInux i386 boot LOader}

	if {[S string 120 0 {} {} eq LILO]} {>

	emit {\b, version 22.3.4 SuSe}
<}

	if {[S string 172 0 {} {} eq LILO]} {>

	emit {\b, version 22.5.8 Debian}
<}

<}

if {[S search 342 0 {} 60 eq \0Geom\0]} {>

	if {[N byte 65 0 0 {} {} < 2]} {>

		if {[N byte 62 0 0 {} {} > 2]} {>

		emit {\b; GRand Unified Bootloader}

			if {[N byte 62 0 0 {} {} x {}]} {>

			emit {\b, stage1 version 0x%x}
<}

			if {[N byte 64 0 0 {} {} < 255]} {>

			emit {\b, boot drive 0x%x}
<}

			if {[N byte 65 0 0 {} {} > 0]} {>

			emit {\b, LBA flag 0x%x}
<}

			if {[N leshort 66 0 0 {} {} < 32768]} {>

			emit {\b, stage2 address 0x%x}
<}

			if {[N leshort 66 0 0 {} {} > 32768]} {>

			emit {\b, stage2 address 0x%x}
<}

			if {[N lelong 68 0 0 {} {} > 1]} {>

			emit {\b, 1st sector stage2 0x%x}
<}

			if {[N leshort 72 0 0 {} {} < 2048]} {>

			emit {\b, stage2 segment 0x%x}
<}

			if {[N leshort 72 0 0 {} {} > 2048]} {>

			emit {\b, stage2 segment 0x%x}
<}

			if {[S string 402 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

				if {[S string 394 0 {} {} eq stage1]} {>

				emit {\b, GRUB version 0.5.95}
<}

<}

			if {[S string 382 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

				if {[S string 376 0 {} {} eq GRUB\ \0]} {>

				emit {\b, GRUB version 0.93 or 1.94}
<}

<}

			if {[S string 383 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

				if {[S string 377 0 {} {} eq GRUB\ \0]} {>

				emit {\b, GRUB version 0.94}
<}

<}

			if {[S string 385 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

				if {[S string 379 0 {} {} eq GRUB\ \0]} {>

				emit {\b, GRUB version 0.95 or 0.96}
<}

<}

			if {[S string 391 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

				if {[S string 385 0 {} {} eq GRUB\ \0]} {>

				emit {\b, GRUB version 0.97}
<}

<}

<}

		if {[S string 343 0 {} {} eq Geom\0Read\0\ Error\0]} {>

			if {[S string 321 0 {} {} eq Loading\ stage1.5]} {>

			emit {\b, GRUB version x.y}
<}

<}

		if {[S string 380 0 {} {} eq Geom\0Hard\ Disk\0Read\0\ Error\0]} {>

			if {[S string 374 0 {} {} eq GRUB\ \0]} {>

			emit {\b, GRUB version n.m}
<}

<}

<}

<}

if {[S string 395 0 {} {} eq chksum\0\ ERROR!\0]} {>

emit {\b, Gujin bootloader}
<}

if {[S string 3 0 {} {} eq BCDL]} {>

	if {[S string 498 0 {} {} eq BCDL\ \ \ \ BIN]} {>

	emit {\b, Bootable CD Loader (1.50Z)}
<}

<}

if {[S string 3 0 {} {} ne IHISK]} {>

	if {[N belong 0 0 0 {} {} != 3099592590]} {>

		if {[S string 514 0 {} {} ne HdrS]} {>

			if {[S string 422 0 {} {} ne Be\ Boot\ Loader]} {>

				if {[S string 32769 0 {} {} eq CD001]} {>
U 243 cdrom

<}

				if {[N belong 0 0 0 & 4244635648 == 3909091328]} {>

					if {[N bequad [I 1 byte 0 + 0 2] 0 0 {} {} == 18028402503091929230]} {>
U 243 partition-table

<}

<}

				if {[N belong 0 0 0 & 4244635648 != 3909091328]} {>

					if {[S string 0 0 {} {} ne RRaA]} {>

						if {[N bequad 0 0 0 {} {} != 18043126232640415371]} {>

							if {[N bequad 0 0 0 {} {} != 7354297128558431054]} {>

								if {[S string 0 0 {} {} ne \r\n]} {>

									if {[N byte 446 0 0 {} {} == 0]} {>
U 243 partition-table

<}

									if {[N byte 446 0 0 {} {} > 127]} {>
U 243 partition-table

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

if {[S string 442 0 {} {} eq Non-system\ disk,\ ]} {>

	if {[S string 459 0 {} {} eq press\ any\ key...\x7\0]} {>

	emit {\b, Acronis Startup Recovery Loader}

		if {[N byte 447 0 0 {} {} x {}]} {>

		emit {\b }
<}
U 243 DOS-filename

<}

<}

if {[S string 185 0 {} {} eq FDBOOT\ Version\ ]} {>

	if {[S string 204 0 {} {} eq \rNo\ Systemdisk.\ ]} {>

		if {[S string 220 0 {} {} eq Booting\ from\ harddisk.\n\r]} {>

<}

		if {[S string 245 0 {} {} eq Cannot\ load\ from\ harddisk.\n\r]} {>

			if {[S string 273 0 {} {} eq Insert\ Systemdisk\ ]} {>

				if {[S string 291 0 {} {} eq and\ press\ any\ key.\n\r]} {>

				emit {\b, FDBOOT harddisk Bootloader}

					if {[S string 200 0 {} {} > \0]} {>

					emit {\b, version %-3s}
<}

<}

<}

<}

<}

<}

if {[S string 242 0 {} {} eq Bootsector\ from\ C.H.\ Hochst\204]} {>

<}

if {[Sx search 242 0 {} 127 eq Bootsector\ from\ C.H.\ Hochst]} {>

	if {[Sx search 278 0 {} 127 eq No\ Systemdisk.\ Booting\ from\ harddisk]} {>

		if {[Sx search 208 0 {} 261 eq Cannot\ load\ from\ harddisk.]} {>

			if {[Sx search 236 0 {} 235 eq Insert\ Systemdisk\ and\ press\ any\ key.]} {>

				if {[Sx search 180 0 {} 96 eq Disk\ formatted\ with\ WinImage\ ]} {>

				emit {\b, WinImage harddisk Bootloader}

					if {[Sx string [R 0] 0 {} {} x {}]} {>

					emit {\b, version %-4.4s}
<}

<}

<}

<}

<}

<}

if {[N byte [I 1 byte 0 + 0 2] 0 0 {} {} == 14]} {>

	if {[N byte [I 1 byte 0 + 0 3] 0 0 {} {} == 31]} {>

		if {[N byte [I 1 byte 0 + 0 4] 0 0 {} {} == 190]} {>

			if {[N byte [I 1 byte 0 + 0 5] 0 0 & 211 == 83]} {>

				if {[N byte [I 1 byte 0 + 0 6] 0 0 {} {} == 124]} {>

					if {[N byte [I 1 byte 0 + 0 7] 0 0 {} {} == 172]} {>

						if {[N byte [I 1 byte 0 + 0 8] 0 0 {} {} == 34]} {>

							if {[N byte [I 1 byte 0 + 0 9] 0 0 {} {} == 192]} {>

								if {[N byte [I 1 byte 0 + 0 10] 0 0 {} {} == 116]} {>

									if {[N byte [I 1 byte 0 + 0 11] 0 0 {} {} == 11]} {>

										if {[N byte [I 1 byte 0 + 0 12] 0 0 {} {} == 86]} {>

											if {[N byte [I 1 byte 0 + 0 13] 0 0 {} {} == 180]} {>

											emit {\b, mkdosfs boot message display}

												switch -- [Nv byte [I 1 byte 0 + 0 5] 0 {} {}] 91 {>;
													if {[S string 91 0 {} {} > \0]} {>

													emit {"%-s"}
<}
;<} 119 {>;
													if {[S string 119 0 {} {} > \0]} {>

													emit {"%-s"}
<}
;<} 
<

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

<}

if {[S string 214 0 {} {} eq Please\ try\ to\ install\ FreeDOS\ ]} {>

emit {\b, DOS Emulator boot message display}
<}

if {[S string 103 0 {} {} eq This\ is\ not\ a\ bootable\ disk.\ ]} {>

	if {[S string 132 0 {} {} eq Please\ insert\ a\ bootable\ ]} {>

		if {[S string 157 0 {} {} eq floppy\ and\r\n]} {>

			if {[S string 169 0 {} {} eq press\ any\ key\ to\ try\ again...\r]} {>

			emit {\b, FREE-DOS message display}
<}

<}

<}

<}

if {[S string 66 0 {} {} eq Solaris\ Boot\ Sector]} {>

	if {[S string 99 0 {} {} eq Incomplete\ MDBoot\ load.]} {>

		if {[S string 89 0 {} {} eq Version]} {>

		emit {\b, Sun Solaris Bootloader}

			if {[N byte 97 0 0 {} {} x {}]} {>

			emit {version %c}
<}

<}

<}

<}

if {[S string 408 0 {} {} eq OS/2\ !!\ SYS01475\r\0]} {>

	if {[S string 429 0 {} {} eq OS/2\ !!\ SYS02025\r\0]} {>

		if {[S string 450 0 {} {} eq OS/2\ !!\ SYS02027\r\0]} {>

<}

		if {[S string 469 0 {} {} eq OS2BOOT\ \ \ \ ]} {>

		emit {\b, IBM OS/2 Warp bootloader}
<}

<}

<}

if {[S string 409 0 {} {} eq OS/2\ !!\ SYS01475\r\0]} {>

	if {[S string 430 0 {} {} eq OS/2\ !!\ SYS02025\r\0]} {>

		if {[S string 451 0 {} {} eq OS/2\ !!\ SYS02027\r\0]} {>

<}

		if {[S string 470 0 {} {} eq OS2BOOT\ \ \ \ ]} {>

		emit {\b, IBM OS/2 Warp Bootloader}
<}

<}

<}

if {[S string 112 0 {} {} eq This\ disk\ is\ not\ bootable\r]} {>

	if {[S string 142 0 {} {} eq If\ you\ wish\ to\ make\ it\ bootable]} {>

		if {[S string 176 0 {} {} eq run\ the\ DOS\ program\ SYS\ ]} {>

<}

		if {[S string 200 0 {} {} eq after\ the\r]} {>

			if {[S string 216 0 {} {} eq system\ has\ been\ loaded\r\n]} {>

				if {[S string 242 0 {} {} eq Please\ insert\ a\ DOS\ diskette\ ]} {>

<}

				if {[S string 271 0 {} {} eq into\r\n\ the\ drive\ and\ ]} {>

					if {[S string 292 0 {} {} eq strike\ any\ key...\0]} {>

					emit {\b, IBM OS/2 Warp message display}
<}

<}

<}

<}

<}

<}

if {[S string 430 0 {} {} eq NTLDR\ is\ missing\xFF\r\n]} {>

	if {[S string 449 0 {} {} eq Disk\ error\xFF\r\n]} {>

		if {[S string 462 0 {} {} eq Press\ any\ key\ to\ restart\r]} {>

		emit {\b, Microsoft Windows XP Bootloader}

			if {[N byte 417 0 0 & 223 > 0]} {>

				if {[S string 417 0 {} {} x {}]} {>

				emit %-.5s

					if {[N byte 422 0 0 & 223 > 0]} {>

						if {[S string 422 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

<}

				if {[N byte 425 0 0 & 223 > 0]} {>

					if {[S string 425 0 {} {} > \ ]} {>

					emit {\b.%-.3s}
<}

<}

<}

			if {[N byte 371 0 0 {} {} > 32]} {>

				if {[N byte 368 0 0 & 223 > 0]} {>

					if {[S string 368 0 {} {} x {}]} {>

					emit %-.5s

						if {[N byte 373 0 0 & 223 > 0]} {>

							if {[S string 373 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

					if {[N byte 376 0 0 & 223 > 0]} {>

						if {[S string 376 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

if {[S string 430 0 {} {} eq NTLDR\ nicht\ gefunden\xFF\r\n]} {>

	if {[S string 453 0 {} {} eq Datentr\204gerfehler\xFF\r\n]} {>

		if {[S string 473 0 {} {} eq Neustart\ mit\ beliebiger\ Taste\r]} {>

		emit {\b, Microsoft Windows XP Bootloader (german)}

			if {[N byte 417 0 0 & 223 > 0]} {>

				if {[S string 417 0 {} {} x {}]} {>

				emit %-.5s

					if {[N byte 422 0 0 & 223 > 0]} {>

						if {[S string 422 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

<}

				if {[N byte 425 0 0 & 223 > 0]} {>

					if {[S string 425 0 {} {} > \ ]} {>

					emit {\b.%-.3s}
<}

<}

<}

			if {[S string 379 0 {} {} eq \0]} {>

				if {[N byte 368 0 0 & 223 > 0]} {>

					if {[S string 368 0 {} {} x {}]} {>

					emit %-.5s

						if {[N byte 373 0 0 & 223 > 0]} {>

							if {[S string 373 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

if {[S string 430 0 {} {} eq NTLDR\ fehlt\xFF\r\n]} {>

	if {[S string 444 0 {} {} eq Datentr\204gerfehler\xFF\r\n]} {>

		if {[S string 464 0 {} {} eq Neustart\ mit\ beliebiger\ Taste\r]} {>

		emit {\b, Microsoft Windows XP Bootloader (2.german)}

			if {[N byte 417 0 0 & 223 > 0]} {>

				if {[S string 417 0 {} {} x {}]} {>

				emit %-.5s

					if {[N byte 422 0 0 & 223 > 0]} {>

						if {[S string 422 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

<}

				if {[N byte 425 0 0 & 223 > 0]} {>

					if {[S string 425 0 {} {} > \ ]} {>

					emit {\b.%-.3s}
<}

<}

<}

			if {[N byte 371 0 0 {} {} > 32]} {>

				if {[N byte 368 0 0 & 223 > 0]} {>

					if {[S string 368 0 {} {} x {}]} {>

					emit %-.5s

						if {[N byte 373 0 0 & 223 > 0]} {>

							if {[S string 373 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

					if {[N byte 376 0 0 & 223 > 0]} {>

						if {[S string 376 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

if {[S string 430 0 {} {} eq NTLDR\ fehlt\xFF\r\n]} {>

	if {[S string 444 0 {} {} eq Medienfehler\xFF\r\n]} {>

		if {[S string 459 0 {} {} eq Neustart:\ Taste\ dr\201cken\r]} {>

		emit {\b, Microsoft Windows XP Bootloader (3.german)}

			if {[N byte 371 0 0 {} {} > 32]} {>

				if {[N byte 368 0 0 & 223 > 0]} {>

					if {[S string 368 0 {} {} x {}]} {>

					emit %-.5s

						if {[N byte 373 0 0 & 223 > 0]} {>

							if {[S string 373 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

					if {[N byte 376 0 0 & 223 > 0]} {>

						if {[S string 376 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

<}

<}

			if {[N byte 417 0 0 & 223 > 0]} {>

				if {[S string 417 0 {} {} x {}]} {>

				emit %-.5s

					if {[N byte 422 0 0 & 223 > 0]} {>

						if {[S string 422 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

<}

				if {[N byte 425 0 0 & 223 > 0]} {>

					if {[S string 425 0 {} {} > \ ]} {>

					emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

if {[S string 430 0 {} {} eq Datentr\204ger\ entfernen\xFF\r\n]} {>

	if {[S string 454 0 {} {} eq Medienfehler\xFF\r\n]} {>

		if {[S string 469 0 {} {} eq Neustart:\ Taste\ dr\201cken\r]} {>

		emit {\b, Microsoft Windows XP Bootloader (4.german)}

			if {[S string 379 0 {} {} eq \0]} {>

				if {[N byte 368 0 0 & 223 > 0]} {>

					if {[S string 368 0 {} {} x {}]} {>

					emit %-.5s

						if {[N byte 373 0 0 & 223 > 0]} {>

							if {[S string 373 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

					if {[N byte 376 0 0 & 223 > 0]} {>

						if {[S string 376 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

<}

<}

			if {[N byte 417 0 0 & 223 > 0]} {>

				if {[S string 417 0 {} {} x {}]} {>

				emit %-.5s

					if {[N byte 422 0 0 & 223 > 0]} {>

						if {[S string 422 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

<}

				if {[N byte 425 0 0 & 223 > 0]} {>

					if {[S string 425 0 {} {} > \ ]} {>

					emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

if {[S string 389 0 {} {} eq Fehler\ beim\ Lesen\ ]} {>

	if {[S string 407 0 {} {} eq des\ Datentr\204gers]} {>

		if {[S string 426 0 {} {} eq NTLDR\ fehlt]} {>

			if {[S string 440 0 {} {} eq NTLDR\ ist\ komprimiert]} {>

				if {[S string 464 0 {} {} eq Neustart\ mit\ Strg+Alt+Entf\r]} {>

				emit {\b, Microsoft Windows XP Bootloader NTFS (german)}
<}

<}

<}

<}

<}

if {[S string 313 0 {} {} eq A\ disk\ read\ error\ occurred.\r]} {>

	if {[S string 345 0 {} {} eq A\ kernel\ file\ is\ missing\ ]} {>

		if {[S string 370 0 {} {} eq from\ the\ disk.\r]} {>

			if {[S string 484 0 {} {} eq NTLDR\ is\ compressed]} {>

				if {[S string 429 0 {} {} eq Insert\ a\ system\ diskette\ ]} {>

					if {[S string 454 0 {} {} eq and\ restart\r\nthe\ system.\r]} {>

					emit {\b, Microsoft Windows XP Bootloader NTFS}
<}

<}

<}

<}

<}

<}

if {[N byte 472 0 0 & 223 > 0]} {>

	if {[S string 389 0 {} {} eq Invalid\ system\ disk\xFF\r\n]} {>

		if {[S string 411 0 {} {} eq Disk\ I/O\ error]} {>

			if {[S string 428 0 {} {} eq Replace\ the\ disk,\ and\ ]} {>

				if {[S string 455 0 {} {} eq press\ any\ key]} {>

				emit {\b, Microsoft Windows 98 Bootloader}

					if {[N byte 472 0 0 & 223 > 0]} {>

						if {[S string 472 0 {} {} x {}]} {>

						emit {\b %-.2s}

							if {[N byte 474 0 0 & 223 > 0]} {>

								if {[S string 474 0 {} {} x {}]} {>

								emit {\b%-.5s}

									if {[N byte 479 0 0 & 223 > 0]} {>

										if {[S string 479 0 {} {} x {}]} {>

										emit {\b%-.1s}
<}

<}

<}

<}

<}

						if {[N byte 480 0 0 & 223 > 0]} {>

							if {[S string 480 0 {} {} x {}]} {>

							emit {\b.%-.3s}
<}

<}

						if {[N byte 483 0 0 & 223 > 0]} {>

						emit {\b+}

							if {[S string 483 0 {} {} x {}]} {>

							emit {\b%-.5s}

								if {[N byte 488 0 0 & 223 > 0]} {>

									if {[S string 488 0 {} {} x {}]} {>

									emit {\b%-.3s}
<}

<}

<}

							if {[N byte 491 0 0 & 223 > 0]} {>

								if {[S string 491 0 {} {} x {}]} {>

								emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

	if {[S string 390 0 {} {} eq Invalid\ system\ disk\xFF\r\n]} {>

		if {[S string 412 0 {} {} eq Disk\ I/O\ error\xFF\r\n]} {>

			if {[S string 429 0 {} {} eq Replace\ the\ disk,\ and\ ]} {>

				if {[S string 451 0 {} {} eq then\ press\ any\ key\r]} {>

				emit {\b, Microsoft Windows 98 Bootloader}
<}

<}

<}

<}

	if {[S string 388 0 {} {} eq Ungueltiges\ System\ \xFF\r\n]} {>

		if {[S string 410 0 {} {} eq E/A-Fehler\ \ \ \ \xFF\r\n]} {>

			if {[S string 427 0 {} {} eq Datentraeger\ wechseln\ und\ ]} {>

				if {[S string 453 0 {} {} eq Taste\ druecken\r]} {>

				emit {\b, Microsoft Windows 95/98/ME Bootloader (german)}

					if {[N byte 497 0 0 & 223 > 0]} {>

						if {[S string 497 0 {} {} x {}]} {>

						emit %-.5s

							if {[N byte 502 0 0 & 223 > 0]} {>

								if {[S string 502 0 {} {} x {}]} {>

								emit {\b%-.1s}

									if {[N byte 503 0 0 & 223 > 0]} {>

										if {[S string 503 0 {} {} x {}]} {>

										emit {\b%-.1s}

											if {[N byte 504 0 0 & 223 > 0]} {>

												if {[S string 504 0 {} {} x {}]} {>

												emit {\b%-.1s}
<}

<}

<}

<}

<}

<}

<}

<}

					if {[N byte 505 0 0 & 223 > 0]} {>

						if {[S string 505 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

					if {[N byte 472 0 0 & 223 > 0]} {>

					emit or

						if {[S string 472 0 {} {} x {}]} {>

						emit {\b %-.2s}

							if {[N byte 474 0 0 & 223 > 0]} {>

								if {[S string 474 0 {} {} x {}]} {>

								emit {\b%-.5s}

									if {[N byte 479 0 0 & 223 > 0]} {>

										if {[S string 479 0 {} {} x {}]} {>

										emit {\b%-.1s}
<}

<}

<}

<}

<}

						if {[N byte 480 0 0 & 223 > 0]} {>

							if {[S string 480 0 {} {} x {}]} {>

							emit {\b.%-.3s}
<}

<}

						if {[N byte 483 0 0 & 223 > 0]} {>

						emit {\b+}

							if {[S string 483 0 {} {} x {}]} {>

							emit {\b%-.5s}

								if {[N byte 488 0 0 & 223 > 0]} {>

									if {[S string 488 0 {} {} x {}]} {>

									emit {\b%-.3s}
<}

<}

<}

							if {[N byte 491 0 0 & 223 > 0]} {>

								if {[S string 491 0 {} {} x {}]} {>

								emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

	if {[S string 390 0 {} {} eq Ungueltiges\ System\ \xFF\r\n]} {>

		if {[S string 412 0 {} {} eq E/A-Fehler\ \ \ \ \xFF\r\n]} {>

			if {[S string 429 0 {} {} eq Datentraeger\ wechseln\ und\ ]} {>

				if {[S string 455 0 {} {} eq Taste\ druecken\r]} {>

				emit {\b, Microsoft Windows 95/98/ME Bootloader (German)}

					if {[N byte 497 0 0 & 223 > 0]} {>

						if {[S string 497 0 {} {} x {}]} {>

						emit %-.7s

							if {[N byte 504 0 0 & 223 > 0]} {>

								if {[S string 504 0 {} {} x {}]} {>

								emit {\b%-.1s}
<}

<}

<}

<}

					if {[N byte 505 0 0 & 223 > 0]} {>

						if {[S string 505 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

					if {[N byte 472 0 0 & 223 > 0]} {>

					emit or

						if {[S string 472 0 {} {} x {}]} {>

						emit {\b %-.2s}

							if {[N byte 474 0 0 & 223 > 0]} {>

								if {[S string 474 0 {} {} x {}]} {>

								emit {\b%-.6s}
<}

<}

<}

						if {[N byte 480 0 0 & 223 > 0]} {>

							if {[S string 480 0 {} {} x {}]} {>

							emit {\b.%-.3s}
<}

<}

						if {[N byte 483 0 0 & 223 > 0]} {>

						emit {\b+}

							if {[S string 483 0 {} {} x {}]} {>

							emit {\b%-.5s}

								if {[N byte 488 0 0 & 223 > 0]} {>

									if {[S string 488 0 {} {} x {}]} {>

									emit {\b%-.3s}
<}

<}

<}

							if {[N byte 491 0 0 & 223 > 0]} {>

								if {[S string 491 0 {} {} x {}]} {>

								emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

	if {[S string 389 0 {} {} eq Ungueltiges\ System\ \xFF\r\n]} {>

		if {[S string 411 0 {} {} eq E/A-Fehler\ \ \ \ \xFF\r\n]} {>

			if {[S string 428 0 {} {} eq Datentraeger\ wechseln\ und\ ]} {>

				if {[S string 454 0 {} {} eq Taste\ druecken\r]} {>

				emit {\b, Microsoft Windows 95/98/ME Bootloader (GERMAN)}

					if {[S string 472 0 {} {} x {}]} {>

					emit %-.2s

						if {[N byte 474 0 0 & 223 > 0]} {>

							if {[S string 474 0 {} {} x {}]} {>

							emit {\b%-.5s}
<}

							if {[N byte 479 0 0 & 223 > 0]} {>

								if {[S string 479 0 {} {} x {}]} {>

								emit {\b%-.1s}
<}

<}

<}

<}

					if {[N byte 480 0 0 & 223 > 0]} {>

						if {[S string 480 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

					if {[N byte 483 0 0 & 223 > 0]} {>

					emit {\b+}

						if {[S string 483 0 {} {} x {}]} {>

						emit {\b%-.5s}
<}

						if {[N byte 488 0 0 & 223 > 0]} {>

							if {[S string 488 0 {} {} x {}]} {>

							emit {\b%-.2s}
<}

							if {[N byte 490 0 0 & 223 > 0]} {>

								if {[S string 490 0 {} {} x {}]} {>

								emit {\b%-.1s}
<}

<}

<}

						if {[N byte 491 0 0 & 223 > 0]} {>

							if {[S string 491 0 {} {} x {}]} {>

							emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

if {[N byte 479 0 0 & 223 > 0]} {>

	if {[S string 416 0 {} {} eq Kein\ System\ oder\ ]} {>

		if {[S string 433 0 {} {} eq Laufwerksfehler]} {>

			if {[S string 450 0 {} {} eq Wechseln\ und\ Taste\ dr\201cken]} {>

			emit {\b, Microsoft DOS Bootloader (german)}

				if {[S string 479 0 {} {} x {}]} {>

				emit {\b %-.2s}

					if {[N byte 481 0 0 & 223 > 0]} {>

						if {[S string 481 0 {} {} x {}]} {>

						emit {\b%-.6s}
<}

<}

<}

				if {[N byte 487 0 0 & 223 > 0]} {>

					if {[S string 487 0 {} {} x {}]} {>

					emit {\b.%-.3s}
<}

					if {[N byte 490 0 0 & 223 > 0]} {>

					emit {\b+}

						if {[S string 490 0 {} {} x {}]} {>

						emit {\b%-.5s}

							if {[N byte 495 0 0 & 223 > 0]} {>

								if {[S string 495 0 {} {} x {}]} {>

								emit {\b%-.3s}
<}

<}

<}

						if {[N byte 498 0 0 & 223 > 0]} {>

							if {[S string 498 0 {} {} x {}]} {>

							emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

if {[Sx search 376 0 {} 41 eq Non-System\ disk\ or\ ]} {>

	if {[Sx search 395 0 {} 41 eq disk\ error\r]} {>

		if {[Sx search 407 0 {} 41 eq Replace\ and\ ]} {>

			if {[S search 419 0 {} 41 eq press\ ]} {>

			emit {\b,}
<}

			if {[S search 419 0 {} 41 eq strike\ ]} {>

			emit {\b, old}
<}

			if {[Sx search 426 0 {} 41 eq any\ key\ when\ ready\r]} {>

			emit {MS or PC-DOS bootloader}

				if {[Sx search 468 0 {} 18 eq \0]} {>

					if {[Sx string [R 0] 0 {} {} x {}]} {>

					emit {\b %-.2s}

						if {[Nx byte [R -20] 0 0 & 223 > 0]} {>

							if {[Sx string [R -1] 0 {} {} x {}]} {>

							emit {\b%-.4s}

								if {[Nx byte [R -16] 0 0 & 223 > 0]} {>

									if {[Sx string [R -1] 0 {} {} x {}]} {>

									emit {\b%-.2s}
<}

<}

<}

<}

<}

					if {[Nx byte [R 8] 0 0 & 223 > 0]} {>

					emit {\b.}

						if {[Sx string [R -1] 0 {} {} x {}]} {>

						emit {\b%-.3s}
<}

<}

					if {[Nx byte [R 11] 0 0 & 223 > 0]} {>

					emit {\b+}

						if {[Sx string [R -1] 0 {} {} x {}]} {>

						emit {\b%-.5s}

							if {[Nx byte [R -6] 0 0 & 223 > 0]} {>

								if {[Sx string [R -1] 0 {} {} x {}]} {>

								emit {\b%-.1s}

									if {[Nx byte [R -5] 0 0 & 223 > 0]} {>

										if {[Sx string [R -1] 0 {} {} x {}]} {>

										emit {\b%-.2s}
<}

<}

<}

<}

<}

						if {[Nx byte [R 7] 0 0 & 223 > 0]} {>

						emit {\b.}

							if {[Sx string [R -1] 0 {} {} x {}]} {>

							emit {\b%-.3s}
<}

<}

<}

<}

<}

<}

<}

<}

if {[S string 441 0 {} {} eq Cannot\ load\ from\ harddisk.\n\r]} {>

	if {[S string 469 0 {} {} eq Insert\ Systemdisk\ ]} {>

		if {[S string 487 0 {} {} eq and\ press\ any\ key.\n\r]} {>

		emit {\b, MS (2.11) DOS bootloader}
<}

<}

<}

if {[S string 54 0 {} {} eq SYS]} {>

	if {[S string 324 0 {} {} eq VASKK]} {>

		if {[S string 495 0 {} {} eq NEWLDR\0]} {>

		emit {\b, DR-DOS Bootloader (LOADER.SYS)}
<}

<}

<}

if {[S string 98 0 {} {} eq Press\ a\ key\ to\ retry\0\r]} {>

	if {[S string 120 0 {} {} eq Cannot\ find\ file\ \0\r]} {>

		if {[S string 139 0 {} {} eq Disk\ read\ error\0\r]} {>

			if {[S string 156 0 {} {} eq Loading\ ...\0]} {>

			emit {\b, DR-DOS (3.41) Bootloader}

				if {[N byte 44 0 0 & 223 > 0]} {>

					if {[S string 44 0 {} {} x {}]} {>

					emit {\b %-.6s}

						if {[N byte 50 0 0 & 223 > 0]} {>

							if {[S string 50 0 {} {} x {}]} {>

							emit {\b%-.2s}
<}

<}

<}

					if {[N byte 52 0 0 & 223 > 0]} {>

						if {[S string 52 0 {} {} x {}]} {>

						emit {\b.%-.3s}
<}

<}

<}

<}

<}

<}

<}

if {[S string 70 0 {} {} eq IBMBIO\ \ COM]} {>

	if {[S string 472 0 {} {} eq Cannot\ load\ DOS!\ ]} {>

		if {[S string 489 0 {} {} eq Any\ key\ to\ retry]} {>

		emit {\b, DR-DOS Bootloader}
<}

<}

	if {[S string 471 0 {} {} eq Cannot\ load\ DOS\ ]} {>

<}

	if {[S string 487 0 {} {} eq press\ key\ to\ retry]} {>

	emit {\b, Open-DOS Bootloader}
<}

<}

if {[S string 444 0 {} {} eq KERNEL\ \ SYS]} {>

	if {[S string 314 0 {} {} eq BOOT\ error!]} {>

	emit {\b, FREE-DOS Bootloader}
<}

<}

if {[S string 499 0 {} {} eq KERNEL\ \ SYS]} {>

	if {[S string 305 0 {} {} eq BOOT\ err!\0]} {>

	emit {\b, Free-DOS Bootloader}
<}

<}

if {[S string 449 0 {} {} eq KERNEL\ \ SYS]} {>

	if {[S string 319 0 {} {} eq BOOT\ error!]} {>

	emit {\b, FREE-DOS 0.5 Bootloader}
<}

<}

if {[S string 449 0 {} {} eq Loading\ FreeDOS]} {>

	if {[N lelong 431 0 0 {} {} > 0]} {>

	emit {\b, FREE-DOS 0.95,1.0 Bootloader}

		if {[N byte 497 0 0 & 223 > 0]} {>

			if {[S string 497 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 503 0 0 & 223 > 0]} {>

					if {[S string 503 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 504 0 0 & 223 > 0]} {>

							if {[S string 504 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 505 0 0 & 223 > 0]} {>

				if {[S string 505 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

<}

if {[S string 331 0 {} {} eq Error!.0]} {>

emit {\b, FREE-DOS 1.0 bootloader}
<}

if {[S string 125 0 {} {} eq Loading\ FreeDOS...\r]} {>

	if {[S string 311 0 {} {} eq BOOT\ error!\r]} {>

	emit {\b, FREE-DOS bootloader}

		if {[N byte 441 0 0 & 223 > 0]} {>

			if {[S string 441 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 447 0 0 & 223 > 0]} {>

					if {[S string 447 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 448 0 0 & 223 > 0]} {>

							if {[S string 448 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 449 0 0 & 223 > 0]} {>

				if {[S string 449 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

<}

if {[S string 124 0 {} {} eq FreeDOS\0]} {>

	if {[S string 331 0 {} {} eq \ err\0]} {>

	emit {\b, FREE-DOS BETa 0.9 Bootloader}

		if {[N byte 497 0 0 & 223 > 0]} {>

			if {[S string 497 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 503 0 0 & 223 > 0]} {>

					if {[S string 503 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 504 0 0 & 223 > 0]} {>

							if {[S string 504 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 505 0 0 & 223 > 0]} {>

				if {[S string 505 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

	if {[S string 333 0 {} {} eq \ err\0]} {>

	emit {\b, FREE-DOS BEta 0.9 Bootloader}

		if {[N byte 497 0 0 & 223 > 0]} {>

			if {[S string 497 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 503 0 0 & 223 > 0]} {>

					if {[S string 503 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 504 0 0 & 223 > 0]} {>

							if {[S string 504 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 505 0 0 & 223 > 0]} {>

				if {[S string 505 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

	if {[S string 334 0 {} {} eq \ err\0]} {>

	emit {\b, FREE-DOS Beta 0.9 Bootloader}

		if {[N byte 497 0 0 & 223 > 0]} {>

			if {[S string 497 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 503 0 0 & 223 > 0]} {>

					if {[S string 503 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 504 0 0 & 223 > 0]} {>

							if {[S string 504 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 505 0 0 & 223 > 0]} {>

				if {[S string 505 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

<}

if {[S string 336 0 {} {} eq Error!\ ]} {>

	if {[S string 343 0 {} {} eq Hit\ a\ key\ to\ reboot.]} {>

	emit {\b, FREE-DOS Beta 0.9sr1 Bootloader}

		if {[N byte 497 0 0 & 223 > 0]} {>

			if {[S string 497 0 {} {} x {}]} {>

			emit {\b %-.6s}

				if {[N byte 503 0 0 & 223 > 0]} {>

					if {[S string 503 0 {} {} x {}]} {>

					emit {\b%-.1s}

						if {[N byte 504 0 0 & 223 > 0]} {>

							if {[S string 504 0 {} {} x {}]} {>

							emit {\b%-.1s}
<}

<}

<}

<}

<}

			if {[N byte 505 0 0 & 223 > 0]} {>

				if {[S string 505 0 {} {} x {}]} {>

				emit {\b.%-.3s}
<}

<}

<}

<}

<}

if {[N lelong 478 0 0 {} {} == 0]} {>

	if {[S string [I 1 byte 0 + 0 326] 0 {} {} eq I/O\ Error\ reading\ ]} {>

		if {[S string [I 1 byte 0 + 0 344] 0 {} {} eq Visopsys\ loader\r]} {>

			if {[S string [I 1 byte 0 + 0 361] 0 {} {} eq Press\ any\ key\ to\ continue.\r]} {>

			emit {\b, Visopsys loader}
<}

<}

<}

<}

if {[N byte 494 0 0 {} {} > 77]} {>

	if {[S string 495 0 {} {} > E]} {>

		if {[S string 495 0 {} {} < S]} {>

			if {[S string 3 0 {} {} eq BootProg]} {>

<}

			if {[N byte 499 0 0 & 223 > 0]} {>

			emit {\b, COM/EXE Bootloader }
U 243 DOS-filename

				if {[S string 492 0 {} {} eq RENF]} {>

				emit {\b, FAT (12 bit)}
<}

				if {[S string 495 0 {} {} eq RENF]} {>

				emit {\b, FAT (16 bit)}
<}

<}

<}

<}

<}

if {[S string 0 0 {} {} eq RRaA]} {>

	if {[S string 484 0 {} {} eq rrAa]} {>

	emit {\b, FSInfosector}

		if {[N lelong 488 0 0 {} {} < 4294967295]} {>

		emit {\b, %u free clusters}
<}

		if {[N lelong 492 0 0 {} {} < 4294967295]} {>

		emit {\b, last allocated cluster %u}
<}

<}

<}

if {[N byte 3 0 0 {} {} == 0]} {>

	if {[N byte 446 0 0 {} {} == 0]} {>

		if {[N byte 450 0 0 {} {} > 0]} {>

			if {[N byte 482 0 0 {} {} == 0]} {>

				if {[N byte 498 0 0 {} {} == 0]} {>

					if {[N byte 466 0 0 {} {} < 16]} {>

						switch -- [Nv byte 466 0 {} {}] 5 {>;emit {\b, extended partition table};<} 15 {>;emit {\b, extended partition table (LBA)};<} 0 {>;emit {\b, extended partition table (last)};<} 
<

<}

<}

<}

<}

<}

<}

if {[N lelong 512 0 0 {} {} == 2186691927]} {>

emit {\b, BSD disklabel}
<}
;<} 
<
} {
if {[S string 0 0 {} {} eq EFI\ PART]} {>

emit {GPT data structure (nonstandard: at LBA 0)}
U 165 gpt-table

if {[N byte 0 0 0 {} {} x {}]} {>

emit {(sector size unknown)}
<}

<}
} {
if {[S string 0 0 {} {} eq .snd]} {>

emit {Sun/NeXT audio data:}

switch -- [Nv belong 12 0 {} {}] 1 {>;emit {8-bit ISDN mu-law,}
mime audio/basic
;<} 2 {>;emit {8-bit linear PCM [REF-PCM],}
mime audio/basic
;<} 3 {>;emit {16-bit linear PCM,}
mime audio/basic
;<} 4 {>;emit {24-bit linear PCM,}
mime audio/basic
;<} 5 {>;emit {32-bit linear PCM,}
mime audio/basic
;<} 6 {>;emit {32-bit IEEE floating point,}
mime audio/basic
;<} 7 {>;emit {64-bit IEEE floating point,}
mime audio/basic
;<} 8 {>;emit {Fragmented sample data,};<} 10 {>;emit {DSP program,};<} 11 {>;emit {8-bit fixed point,};<} 12 {>;emit {16-bit fixed point,};<} 13 {>;emit {24-bit fixed point,};<} 14 {>;emit {32-bit fixed point,};<} 18 {>;emit {16-bit linear with emphasis,};<} 19 {>;emit {16-bit linear compressed,};<} 20 {>;emit {16-bit linear with emphasis and compression,};<} 21 {>;emit {Music kit DSP commands,};<} 23 {>;emit {8-bit ISDN mu-law compressed (CCITT G.721 ADPCM voice enc.),}
mime audio/x-adpcm
;<} 24 {>;emit {compressed (8-bit CCITT G.722 ADPCM)};<} 25 {>;emit {compressed (3-bit CCITT G.723.3 ADPCM),};<} 26 {>;emit {compressed (5-bit CCITT G.723.5 ADPCM),};<} 27 {>;emit {8-bit A-law (CCITT G.711),};<} 
<

switch -- [Nv belong 20 0 {} {}] 1 {>;emit mono,;<} 2 {>;emit stereo,;<} 4 {>;emit quad,;<} 
<

if {[N belong 16 0 0 {} {} > 0]} {>

emit {%d Hz}
<}

<}
} {
if {[S string 0 0 {} {} eq MThd]} {>

emit {Standard MIDI data}

if {[N beshort 8 0 0 {} {} x {}]} {>

emit {(format %d)}
<}

if {[N beshort 10 0 0 {} {} x {}]} {>

emit {using %d track}
<}

if {[N beshort 10 0 0 {} {} > 1]} {>

emit {\bs}
<}

if {[N beshort 12 0 0 & 32767 x {}]} {>

emit {at 1/%d}
<}

if {[N beshort 12 0 0 & 32768 > 0]} {>

emit SMPTE
<}

mime audio/midi

<}
} {
if {[S string 0 0 {} {} eq CTMF]} {>

emit {Creative Music (CMF) data}
mime audio/x-unknown

<}
} {
if {[S string 0 0 {} {} eq SBI]} {>

emit {SoundBlaster instrument data}
mime audio/x-unknown

<}
} {
if {[S string 0 0 {} {} eq Creative\ Voice\ File]} {>

emit {Creative Labs voice data}

if {[N byte 19 0 0 {} {} == 26]} {>

<}

if {[N byte 23 0 0 {} {} > 0]} {>

emit {- version %d}
<}

if {[N byte 22 0 0 {} {} > 0]} {>

emit {\b.%d}
<}

mime audio/x-unknown

<}
} {
if {[S string 0 0 {} {} eq EMOD]} {>

emit {Extended MOD sound data,}

if {[N byte 4 0 0 & 240 x {}]} {>

emit {version %d}
<}

if {[N byte 4 0 0 & 15 x {}]} {>

emit {\b.%d,}
<}

if {[N byte 45 0 0 {} {} x {}]} {>

emit {%d instruments}
<}

switch -- [Nv byte 83 0 {} {}] 0 {>;emit (module);<} 1 {>;emit (song);<} 
<

<}
} {
if {[S string 0 0 {} {} eq .RMF\0\0\0]} {>

emit {RealMedia file}
mime application/vnd.rn-realmedia

<}
} {
if {[S string 0 0 {} {} eq MAS_U]} {>

emit {ULT(imate) Module sound data}
<}
} {
if {[S string 44 0 {} {} eq SCRM]} {>

emit {ScreamTracker III Module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq GF1PATCH110\0ID\#000002\0]} {>

emit {GUS patch}
<}
} {
if {[S string 0 0 {} {} eq GF1PATCH100\0ID\#000002\0]} {>

emit {Old GUS	patch}
<}
} {
if {[S string 0 0 {} {} eq MAS_UTrack_V00]} {>

if {[S string 14 0 {} {} > /0]} {>

emit {ultratracker V1.%.1s module sound data}
mime audio/x-mod

<}

<}
} {
if {[S string 0 0 {} {} eq UN05]} {>

emit {MikMod UNI format module sound data}
<}
} {
if {[S string 0 0 {} {} eq Extended\ Module:]} {>

emit {Fasttracker II module sound data}

if {[S string 17 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 21 0 c {} eq !SCREAM!]} {>

emit {Screamtracker 2 module sound data}
mime audio/x-mod

<}
} {
if {[S string 21 0 {} {} eq BMOD2STM]} {>

emit {Screamtracker 2 module sound data}
mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq M.K.]} {>

emit {4-channel Protracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq M!K!]} {>

emit {4-channel Protracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq FLT4]} {>

emit {4-channel Startracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq FLT8]} {>

emit {8-channel Startracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq 4CHN]} {>

emit {4-channel Fasttracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq 6CHN]} {>

emit {6-channel Fasttracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq 8CHN]} {>

emit {8-channel Fasttracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq CD81]} {>

emit {8-channel Octalyser module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq OKTA]} {>

emit {8-channel Octalyzer module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq 16CN]} {>

emit {16-channel Taketracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 1080 0 {} {} eq 32CN]} {>

emit {32-channel Taketracker module sound data}

if {[S string 0 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

mime audio/x-mod

<}
} {
if {[S string 0 0 {} {} eq TOC]} {>

emit {TOC sound file}
<}
} {
if {[S string 0 0 {} {} eq SIDPLAY\ INFOFILE]} {>

emit {Sidplay info file}
<}
} {
if {[S string 0 0 {} {} eq PSID]} {>

emit {PlaySID v2.2+ (AMIGA) sidtune}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {w/ header v%d,}
<}

if {[N beshort 14 0 0 {} {} == 1]} {>

emit {single song,}
<}

if {[N beshort 14 0 0 {} {} > 1]} {>

emit {%d songs,}
<}

if {[N beshort 16 0 0 {} {} > 0]} {>

emit {default song: %d}
<}

if {[S string 22 0 {} {} > \0]} {>

emit {name: "%s"}
<}

if {[S string 54 0 {} {} > \0]} {>

emit {author: "%s"}
<}

if {[S string 86 0 {} {} > \0]} {>

emit {copyright: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq RSID]} {>

emit {RSID sidtune PlaySID compatible}

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {w/ header v%d,}
<}

if {[N beshort 14 0 0 {} {} == 1]} {>

emit {single song,}
<}

if {[N beshort 14 0 0 {} {} > 1]} {>

emit {%d songs,}
<}

if {[N beshort 16 0 0 {} {} > 0]} {>

emit {default song: %d}
<}

if {[S string 22 0 {} {} > \0]} {>

emit {name: "%s"}
<}

if {[S string 54 0 {} {} > \0]} {>

emit {author: "%s"}
<}

if {[S string 86 0 {} {} > \0]} {>

emit {copyright: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq NIST_1A\n\ \ \ 1024\n]} {>

emit {NIST SPHERE file}
<}
} {
if {[S string 0 0 {} {} eq SOUND\ SAMPLE\ DATA\ ]} {>

emit {Sample Vision file}
<}
} {
if {[S string 0 0 {} {} eq 2BIT]} {>

emit {Audio Visual Research file,}

switch -- [Nv beshort 12 0 {} {}] 0 {>;emit mono,;<} -1 {>;emit stereo,;<} 
<

if {[N beshort 14 0 0 {} {} x {}]} {>

emit {%d bits}
<}

switch -- [Nv beshort 16 0 {} {}] 0 {>;emit unsigned,;<} -1 {>;emit signed,;<} 
<

if {[N belong 22 0 0 & 16777215 x {}]} {>

emit {%d Hz,}
<}

switch -- [Nv beshort 18 0 {} {}] 0 {>;emit {no loop,};<} -1 {>;emit loop,;<} 
<

if {[N byte 21 0 0 {} {} < 128]} {>

emit {note %d,}
<}

switch -- [Nv byte 22 0 {} {}] 0 {>;emit {replay 5.485 KHz};<} 1 {>;emit {replay 8.084 KHz};<} 2 {>;emit {replay 10.971 KHz};<} 3 {>;emit {replay 16.168 KHz};<} 4 {>;emit {replay 21.942 KHz};<} 5 {>;emit {replay 32.336 KHz};<} 6 {>;emit {replay 43.885 KHz};<} 7 {>;emit {replay 47.261 KHz};<} 
<

<}
} {
if {[S string 0 0 {} {} eq _SGI_SoundTrack]} {>

emit {SGI SoundTrack project file}
<}
} {
if {[S string 0 0 {} {} eq ID3]} {>

emit {Audio file with ID3 version 2}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b.%d}

	if {[N byte 5 0 0 {} {} & 128]} {>

	emit {\b, unsynchronized frames}
<}

	if {[N byte 5 0 0 {} {} & 64]} {>

	emit {\b, extended header}
<}

	if {[N byte 5 0 0 {} {} & 32]} {>

	emit {\b, experimental}
<}

	if {[N byte 5 0 0 {} {} & 16]} {>

	emit {\b, footer present}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq NESM\x1a]} {>

emit {NES Sound File}

if {[S string 14 0 {} {} > \0]} {>

emit {("%s" by}
<}

if {[S string 46 0 {} {} > \0]} {>

emit {%s, copyright}
<}

if {[S string 78 0 {} {} > \0]} {>

emit %s),
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {%d tracks,}
<}

if {[N byte 122 0 0 & 2 == 1]} {>

emit {dual PAL/NTSC}
<}

switch -- [Nv byte 122 0 & 1] 1 {>;emit PAL;<} 0 {>;emit NTSC;<} 
<

<}
} {
if {[Sx string 0 0 {} {} eq NSFE]} {>

emit {Extended NES Sound File}

if {[Sx search 48 0 {} 4096 eq auth]} {>

	if {[Sx string [R 0] 0 {} {} > \0]} {>

	emit (\"%s\"

		if {[Sx string [R 1] 0 {} {} > \0]} {>

		emit {by %s}

			if {[Sx string [R 1] 0 {} {} > \0]} {>

			emit {\b, copyright %s}

				if {[Sx string [R 1] 0 {} {} > \0]} {>

				emit {\b, ripped by %s}
<}

<}

<}

<}

<}

if {[N byte 20 0 0 {} {} x {}]} {>

emit {\b), %d tracks,}
<}

switch -- [Nv byte 18 0 & 2] 1 {>;emit {dual PAL/NTSC};<} 0 {>;
	switch -- [Nv byte 18 0 & 1] 1 {>;emit PAL;<} 0 {>;emit NTSC;<} 
<
;<} 
<

<}
} {
if {[Sx string 0 0 {} {} eq SNES-SPC700\ Sound\ File\ Data\ v]} {>

emit {SNES SPC700 sound file}

if {[Sx string [R 0] 0 {} {} eq 0.30]} {>

emit {\b, version %s}

	switch -- [Nv byte 35 0 {} {}] 27 {>;emit {\b, without ID666 tag};<} 26 {>;emit {\b, with ID666 tag}

		if {[S string 46 0 {} {} > \0]} {>

		emit {\b, song "%.32s"}
<}

		if {[S string 78 0 {} {} > \0]} {>

		emit {\b, game "%.32s"}
<}
;<} 
<

<}

<}
} {
if {[S string 0 0 {} {} eq IMPM]} {>

emit {Impulse Tracker module sound data -}

if {[S string 4 0 {} {} > \0]} {>

emit {"%s"}
<}

if {[N leshort 40 0 0 {} {} != 0]} {>

emit {compatible w/ITv%x}
<}

if {[N leshort 42 0 0 {} {} != 0]} {>

emit {created w/ITv%x}
<}

mime audio/x-mod

<}
} {
if {[S string 60 0 {} {} eq IM10]} {>

emit {Imago Orpheus module sound data -}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq IMPS]} {>

emit {Impulse Tracker Sample}

if {[N byte 18 0 0 {} {} & 2]} {>

emit {16 bit}
<}

if {[N byte 18 0 0 {} {} ^ 2]} {>

emit {8 bit}
<}

if {[N byte 18 0 0 {} {} & 4]} {>

emit stereo
<}

if {[N byte 18 0 0 {} {} ^ 4]} {>

emit mono
<}

<}
} {
if {[S string 0 0 {} {} eq IMPI]} {>

emit {Impulse Tracker Instrument}

if {[N leshort 28 0 0 {} {} != 0]} {>

emit ITv%x
<}

if {[N byte 30 0 0 {} {} != 0]} {>

emit {%d samples}
<}

<}
} {
if {[S string 0 0 {} {} eq LM8953]} {>

emit {Yamaha TX Wave}

switch -- [Nv byte 22 0 {} {}] 73 {>;emit looped;<} -55 {>;emit non-looped;<} 
<

switch -- [Nv byte 23 0 {} {}] 1 {>;emit 33kHz;<} 2 {>;emit 50kHz;<} 3 {>;emit 16kHz;<} 
<

<}
} {
if {[S string 76 0 {} {} eq SCRS]} {>

emit {Scream Tracker Sample}

switch -- [Nv byte 0 0 {} {}] 1 {>;emit sample;<} 2 {>;emit {adlib melody};<} 
<

if {[N byte 0 0 0 {} {} > 2]} {>

emit {adlib drum}
<}

if {[N byte 31 0 0 {} {} & 2]} {>

emit stereo
<}

if {[N byte 31 0 0 {} {} ^ 2]} {>

emit mono
<}

if {[N byte 31 0 0 {} {} & 4]} {>

emit {16bit little endian}
<}

if {[N byte 31 0 0 {} {} ^ 4]} {>

emit 8bit
<}

switch -- [Nv byte 30 0 {} {}] 0 {>;emit unpacked;<} 1 {>;emit packed;<} 
<

<}
} {
if {[S string 0 0 {} {} eq MMD0]} {>

emit {MED music file, version 0}
<}
} {
if {[S string 0 0 {} {} eq MMD1]} {>

emit {OctaMED Pro music file, version 1}
<}
} {
if {[S string 0 0 {} {} eq MMD3]} {>

emit {OctaMED Soundstudio music file, version 3}
<}
} {
if {[S string 0 0 {} {} eq OctaMEDCmpr]} {>

emit {OctaMED Soundstudio compressed file}
<}
} {
if {[S string 0 0 {} {} eq MED]} {>

emit MED_Song
<}
} {
if {[S string 0 0 {} {} eq SymM]} {>

emit {Symphonie SymMOD music file}
<}
} {
if {[S string 0 0 {} {} eq THX]} {>

emit {AHX version}

switch -- [Nv byte 3 0 {} {}] 0 {>;emit {1 module data};<} 1 {>;emit {2 module data};<} 
<

<}
} {
if {[S string 0 0 {} {} eq OKTASONG]} {>

emit {Oktalyzer module data}
<}
} {
if {[S string 0 0 {} {} eq DIGI\ Booster\ module\0]} {>

emit %s

if {[N byte 20 0 0 {} {} > 0]} {>

emit %c

	if {[N byte 21 0 0 {} {} > 0]} {>

	emit {\b%c}

		if {[N byte 22 0 0 {} {} > 0]} {>

		emit {\b%c}

			if {[N byte 23 0 0 {} {} > 0]} {>

			emit {\b%c}
<}

<}

<}

<}

if {[S string 610 0 {} {} > \0]} {>

emit {\b, "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq DBM0]} {>

emit {DIGI Booster Pro Module}

if {[N byte 4 0 0 {} {} > 0]} {>

emit V%X.

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {\b%02X}
<}

<}

if {[S string 16 0 {} {} > \0]} {>

emit {\b, "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq FTMN]} {>

emit {FaceTheMusic module}

if {[S string 16 0 {} {} > \0d]} {>

emit {\b, "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq AMShdr\32]} {>

emit {Velvet Studio AMS Module v2.2}
<}
} {
if {[S string 0 0 {} {} eq Extreme]} {>

emit {Extreme Tracker AMS Module v1.3}
<}
} {
if {[S string 0 0 {} {} eq DDMF]} {>

emit {Xtracker DMF Module}

if {[N byte 4 0 0 {} {} x {}]} {>

emit v%i
<}

if {[S string 13 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

if {[S string 43 0 {} {} > \0]} {>

emit {Composer: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq DSM\32]} {>

emit {Dynamic Studio Module DSM}
<}
} {
if {[S string 0 0 {} {} eq SONG]} {>

emit {DigiTrekker DTM Module}
<}
} {
if {[S string 0 0 {} {} eq DMDL]} {>

emit {DigiTrakker MDL Module}
<}
} {
if {[S string 0 0 {} {} eq PSM\32]} {>

emit {Protracker Studio PSM Module}
<}
} {
if {[S string 44 0 {} {} eq PTMF]} {>

emit {Poly Tracker PTM Module}

if {[S string 0 0 {} {} > \32]} {>

emit {Title: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq MT20]} {>

emit {MadTracker 2.0 Module MT2}
<}
} {
if {[S string 0 0 {} {} eq RAD\40by\40REALiTY!!]} {>

emit {RAD Adlib Tracker Module RAD}
<}
} {
if {[S string 0 0 {} {} eq RTMM]} {>

emit {RTM Module}
<}
} {
if {[S string 1062 0 {} {} eq MaDoKaN96]} {>

emit {XMS Adlib Module}

if {[S string 0 0 {} {} > \0]} {>

emit {Composer: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq AMF]} {>

emit {AMF Module}

if {[S string 4 0 {} {} > \0]} {>

emit {Title: "%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq MODINFO1]} {>

emit {Open Cubic Player Module Inforation MDZ}
<}
} {
if {[S string 0 0 {} {} eq Extended\40Instrument:]} {>

emit {Fast Tracker II Instrument}
<}
} {
if {[S string 0 0 {} {} eq \210NOA\015\012\032]} {>

emit {NOA Nancy Codec Movie file}
<}
} {
if {[S string 0 0 {} {} eq MMMD]} {>

emit {Yamaha SMAF file}
<}
} {
if {[S string 0 0 {} {} eq \001Sharp\040JisakuMelody]} {>

emit {SHARP Cell-Phone ringing Melody}

if {[S string 20 0 {} {} eq Ver01.00]} {>

emit {Ver. 1.00}

	if {[N byte 32 0 0 {} {} x {}]} {>

	emit {, %d tracks}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq fLaC]} {>

emit {FLAC audio bitstream data}

if {[N byte 4 0 0 & 127 > 0]} {>

emit {\b, unknown version}
<}

if {[N byte 4 0 0 & 127 == 0]} {>

emit {\b}

	switch -- [Nv beshort 20 0 & 496] 48 {>;emit {\b, 4 bit};<} 80 {>;emit {\b, 6 bit};<} 112 {>;emit {\b, 8 bit};<} 176 {>;emit {\b, 12 bit};<} 240 {>;emit {\b, 16 bit};<} 368 {>;emit {\b, 24 bit};<} 
<

	switch -- [Nv byte 20 0 & 14] 0 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 4 {>;emit {\b, 3 channels};<} 6 {>;emit {\b, 4 channels};<} 8 {>;emit {\b, 5 channels};<} 10 {>;emit {\b, 6 channels};<} 12 {>;emit {\b, 7 channels};<} 14 {>;emit {\b, 8 channels};<} 
<

	switch -- [Nv belong 17 0 & 16777200] 705600 {>;emit {\b, 44.1 kHz};<} 768000 {>;emit {\b, 48 kHz};<} 512000 {>;emit {\b, 32 kHz};<} 352800 {>;emit {\b, 22.05 kHz};<} 384000 {>;emit {\b, 24 kHz};<} 256000 {>;emit {\b, 16 kHz};<} 176400 {>;emit {\b, 11.025 kHz};<} 192000 {>;emit {\b, 12 kHz};<} 128000 {>;emit {\b, 8 kHz};<} 1536000 {>;emit {\b, 96 kHz};<} 1024000 {>;emit {\b, 64 kHz};<} 
<

	if {[N byte 21 0 0 & 15 > 0]} {>

	emit {\b, >4G samples}
<}

	if {[N byte 21 0 0 & 15 == 0]} {>

	emit {\b}

		if {[N belong 22 0 0 {} {} > 0]} {>

		emit {\b, %u samples}
<}

		if {[N belong 22 0 0 {} {} == 0]} {>

		emit {\b, length unknown}
<}

<}

<}

mime audio/x-flac

<}
} {
if {[S string 0 0 {} {} eq VBOX]} {>

emit {VBOX voice message data}
<}
} {
if {[S string 8 0 {} {} eq RB40]} {>

emit {RBS Song file}

if {[S string 29 0 {} {} eq ReBorn]} {>

emit {created by ReBorn}
<}

if {[S string 37 0 {} {} eq Propellerhead]} {>

emit {created by ReBirth}
<}

<}
} {
if {[S string 0 0 {} {} eq A\#S\#C\#S\#S\#L\#V\#3]} {>

emit {Synthesizer Generator or Kimwitu data}
<}
} {
if {[S string 0 0 {} {} eq A\#S\#C\#S\#S\#L\#HUB]} {>

emit {Kimwitu++ data}
<}
} {
if {[S string 0 0 {} {} eq TFMX-SONG]} {>

emit {TFMX module sound data}
<}
} {
if {[S string 0 0 {} {} eq MAC\040]} {>

emit {Monkey's Audio compressed format}

if {[N leshort 4 0 0 {} {} > 3979]} {>

emit {version %d}

	switch -- [Nv leshort [I 8 lelong 0 0 0 0] 0 {} {}] 1000 {>;emit {with fast compression};<} 2000 {>;emit {with normal compression};<} 3000 {>;emit {with high compression};<} 4000 {>;emit {with extra high compression};<} 5000 {>;emit {with insane compression};<} 
<

	switch -- [Nv leshort [I 8 lelong 0 + 0 18] 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<

	if {[N lelong [I 8 lelong 0 + 0 20] 0 0 {} {} x {}]} {>

	emit {\b, sample rate %d}
<}

<}

if {[N leshort 4 0 0 {} {} < 3980]} {>

emit {version %d}

	switch -- [Nv leshort 6 0 {} {}] 1000 {>;emit {with fast compression};<} 2000 {>;emit {with normal compression};<} 3000 {>;emit {with high compression};<} 4000 {>;emit {with extra high compression};<} 5000 {>;emit {with insane compression};<} 
<

	switch -- [Nv leshort 10 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<

	if {[N lelong 12 0 0 {} {} x {}]} {>

	emit {\b, sample rate %d}
<}

<}

mime audio/x-ape

<}
} {
if {[S string 0 0 {} {} eq RAWADATA]} {>

emit {RdosPlay RAW}
<}
} {
if {[S string 1068 0 {} {} eq RoR]} {>

emit {AMUSIC Adlib Tracker}
<}
} {
if {[S string 0 0 {} {} eq JCH]} {>

emit EdLib
<}
} {
if {[S string 0 0 {} {} eq mpu401tr]} {>

emit {MPU-401 Trakker}
<}
} {
if {[S string 0 0 {} {} eq SAdT]} {>

emit {Surprise! Adlib Tracker}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {Version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq XAD!]} {>

emit {eXotic ADlib}
<}
} {
if {[S string 0 0 {} {} eq ofTAZ!]} {>

emit {eXtra Simple Music}
<}
} {
if {[S string 0 0 {} {} eq ZXAYEMUL]} {>

emit {Spectrum 128 tune}
<}
} {
if {[S string 0 0 {} {} eq \0BONK]} {>

emit BONK,

if {[N byte 14 0 0 {} {} x {}]} {>

emit {%d channel(s),}
<}

switch -- [Nv byte 15 0 {} {}] 1 {>;emit lossless,;<} 0 {>;emit lossy,;<} 
<

if {[N byte 16 0 0 {} {} x {}]} {>

emit mid-side
<}

<}
} {
if {[S string 384 0 {} {} eq LockStream]} {>

emit {LockStream Embedded file (mostly MP3 on old Nokia phones)}
<}
} {
if {[S string 0 0 {} {} eq TWIN97012000]} {>

emit {VQF data}

switch -- [Nv short 27 0 {} {}] 0 {>;emit {\b, Mono};<} 1 {>;emit {\b, Stereo};<} 
<

if {[N short 31 0 0 {} {} > 0]} {>

emit {\b, %d kbit/s}
<}

if {[N short 35 0 0 {} {} > 0]} {>

emit {\b, %d kHz}
<}

<}
} {
if {[S string 0 0 {} {} eq Winamp\ EQ\ library\ file]} {>

emit %s

if {[S string 23 0 {} {} x {}]} {>

emit {\b%.4s}
<}

<}
} {
if {[S string 0 0 {} {} eq \[Equalizer\ preset\]]} {>

emit {XMMS equalizer preset}
<}
} {
if {[S search 0 0 {} 1 eq \#EXTM3U]} {>

emit {M3U playlist text}
<}
} {
if {[S search 0 0 {} 1 eq \[playlist\]]} {>

emit {PLS playlist text}
<}
} {
if {[S string 1 0 {} {} eq \[licq\]]} {>

emit {LICQ configuration file}
<}
} {
if {[S string 0 0 {} {} eq ICE!]} {>

emit {SNDH Atari ST music}
<}
} {
if {[S string 0 0 {} {} eq SC68\ Music-file\ /\ (c)\ (BeN)jami]} {>

emit {sc68 Atari ST music}
<}
} {
if {[S string 0 0 {} {} eq MP+]} {>

emit {Musepack audio (MP+)}

if {[N byte 3 0 0 {} {} == 255]} {>

emit {\b, SV pre8}
<}

switch -- [Nv byte 3 0 & 15] 6 {>;emit {\b, SV 6};<} 8 {>;emit {\b, SV 8};<} 7 {>;emit {\b, SV 7}

	switch -- [Nv byte 3 0 & 240] 0 {>;emit {\b.0};<} 16 {>;emit {\b.1};<} -16 {>;emit {\b.15};<} 
<

	switch -- [Nv byte 10 0 & 240] 0 {>;emit {\b, no profile};<} 16 {>;emit {\b, profile 'Unstable/Experimental'};<} 80 {>;emit {\b, quality 0};<} 96 {>;emit {\b, quality 1};<} 112 {>;emit {\b, quality 2 (Telephone)};<} -128 {>;emit {\b, quality 3 (Thumb)};<} -112 {>;emit {\b, quality 4 (Radio)};<} -96 {>;emit {\b, quality 5 (Standard)};<} -80 {>;emit {\b, quality 6 (Xtreme)};<} -64 {>;emit {\b, quality 7 (Insane)};<} -48 {>;emit {\b, quality 8 (BrainDead)};<} -32 {>;emit {\b, quality 9};<} -16 {>;emit {\b, quality 10};<} 
<

	switch -- [Nv byte 27 0 {} {}] 0 {>;emit {\b, Buschmann 1.7.0-9, Klemm 0.90-1.05};<} 102 {>;emit {\b, Beta 1.02};<} 104 {>;emit {\b, Beta 1.04};<} 105 {>;emit {\b, Alpha 1.05};<} 106 {>;emit {\b, Beta 1.06};<} 110 {>;emit {\b, Release 1.1};<} 111 {>;emit {\b, Alpha 1.11};<} 112 {>;emit {\b, Beta 1.12};<} 113 {>;emit {\b, Alpha 1.13};<} 114 {>;emit {\b, Beta 1.14};<} 115 {>;emit {\b, Alpha 1.15};<} 
<
;<} 
<

mime audio/x-musepack

<}
} {
if {[S string 0 0 {} {} eq MPCK]} {>

emit {Musepack audio (MPCK)}
mime audio/x-musepack

<}
} {
if {[S string 0 0 {} {} eq BEGIN:IMELODY]} {>

emit {iMelody Ringtone Format}
<}
} {
if {[S string 0 0 {} {} eq \030FICHIER\ GUITAR\ PRO\ v3.]} {>

emit {Guitar Pro Ver. 3 Tablature}
<}
} {
if {[S string 60 0 {} {} eq SONG]} {>

emit {SoundFX Module sound file}
<}
} {
if {[S string 0 0 {} {} eq \#!AMR]} {>

emit {Adaptive Multi-Rate Codec (GSM telephony)}
<}
} {
if {[S string 0 0 {} {} eq SCgf]} {>

emit {SuperCollider3 Synth Definition file,}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq TTA1]} {>

emit {True Audio Lossless Audio}
<}
} {
if {[S string 0 0 {} {} eq wvpk]} {>

emit {WavPack Lossless Audio}
<}
} {
if {[S string 0 0 {} {} eq Vgm\ ]} {>

if {[N byte 9 0 0 {} {} > 0]} {>

emit {VGM Video Game Music dump v}

	if {[N byte 9 0 0 / 16 > 0]} {>

	emit {\b%d}
<}

	if {[N byte 9 0 0 & 15 x {}]} {>

	emit {\b%d}
<}

	if {[N byte 8 0 0 / 16 x {}]} {>

	emit {\b.%d}
<}

	if {[N byte 8 0 0 & 15 > 0]} {>

	emit {\b%d}
<}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {\b, soundchip(s)=}
<}

	if {[N lelong 12 0 0 {} {} > 0]} {>

	emit SN76489,
<}

	if {[N lelong 16 0 0 {} {} > 0]} {>

	emit YM2413,
<}

	if {[N lelong 44 0 0 {} {} > 0]} {>

	emit YM2612,
<}

	if {[N lelong 48 0 0 {} {} > 0]} {>

	emit YM2151,
<}

	if {[N lelong 56 0 0 {} {} > 0]} {>

	emit {Sega PCM,}
<}

	if {[N lelong 52 0 0 {} {} > 12]} {>

		if {[N lelong 64 0 0 {} {} > 0]} {>

		emit RF5C68,
<}

<}

	if {[N lelong 52 0 0 {} {} > 16]} {>

		if {[N lelong 68 0 0 {} {} > 0]} {>

		emit YM2203,
<}

<}

	if {[N lelong 52 0 0 {} {} > 20]} {>

		if {[N lelong 72 0 0 {} {} > 0]} {>

		emit YM2608,
<}

<}

	if {[N lelong 52 0 0 {} {} > 24]} {>

		if {[N lelong 76 0 0 {} {} > 0]} {>

		emit YM2610,
<}

		if {[N lelong 76 0 0 {} {} < 0]} {>

		emit YM2610B,
<}

<}

	if {[N lelong 52 0 0 {} {} > 28]} {>

		if {[N lelong 80 0 0 {} {} > 0]} {>

		emit YM3812,
<}

<}

	if {[N lelong 52 0 0 {} {} > 32]} {>

		if {[N lelong 84 0 0 {} {} > 0]} {>

		emit YM3526,
<}

<}

	if {[N lelong 52 0 0 {} {} > 36]} {>

		if {[N lelong 88 0 0 {} {} > 0]} {>

		emit Y8950,
<}

<}

	if {[N lelong 52 0 0 {} {} > 40]} {>

		if {[N lelong 92 0 0 {} {} > 0]} {>

		emit YMF262,
<}

<}

	if {[N lelong 52 0 0 {} {} > 44]} {>

		if {[N lelong 96 0 0 {} {} > 0]} {>

		emit YMF278B,
<}

<}

	if {[N lelong 52 0 0 {} {} > 48]} {>

		if {[N lelong 100 0 0 {} {} > 0]} {>

		emit YMF271,
<}

<}

	if {[N lelong 52 0 0 {} {} > 52]} {>

		if {[N lelong 104 0 0 {} {} > 0]} {>

		emit YMZ280B,
<}

<}

	if {[N lelong 52 0 0 {} {} > 56]} {>

		if {[N lelong 108 0 0 {} {} > 0]} {>

		emit RF5C164,
<}

<}

	if {[N lelong 52 0 0 {} {} > 60]} {>

		if {[N lelong 112 0 0 {} {} > 0]} {>

		emit PWM,
<}

<}

	if {[N lelong 52 0 0 {} {} > 64]} {>

		if {[N lelong 116 0 0 {} {} > 0]} {>

			switch -- [Nv byte 120 0 {} {}] 0 {>;emit AY-3-8910,;<} 1 {>;emit AY-3-8912,;<} 2 {>;emit AY-3-8913,;<} 3 {>;emit AY-3-8930,;<} 16 {>;emit YM2149,;<} 17 {>;emit YM3439,;<} 
<

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq SCOW]} {>

switch -- [Nv byte 4 0 {} {}] -60 {>;emit {GVOX Encore music, version 5.0 or above};<} -62 {>;emit {GVOX Encore music, version < 5.0};<} 
<

<}
} {
if {[S string 0 0 {} {} eq ZBOT]} {>

if {[N byte 4 0 0 {} {} == 197]} {>

emit {GVOX Encore music, version < 5.0}
<}

<}
} {
if {[Sx string 0 0 {} {} eq AUDIMG]} {>

if {[Nx byte 13 0 0 {} {} < 13]} {>

emit {Garmin Voice Processing Module}

	if {[S string 6 0 {} {} x {}]} {>

	emit {\b, version %3.3s}
<}

	if {[N byte 12 0 0 {} {} x {}]} {>

	emit {\b, %.2d}
<}

	if {[N byte 13 0 0 {} {} x {}]} {>

	emit {\b.%.2d}
<}

	if {[N leshort 14 0 0 {} {} x {}]} {>

	emit {\b.%.4d}
<}

	if {[N byte 11 0 0 {} {} x {}]} {>

	emit %.2d
<}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit {\b:%.2d}
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b:%.2d}
<}

	if {[N byte 18 0 0 {} {} x {}]} {>

	emit {\b, language ID %d}
<}

	if {[Nx leshort 16 0 0 {} {} > 0]} {>

		if {[Nx lelong [I 16 leshort 0 0 0 0] 0 0 {} {} > 0]} {>

		emit {\b, at offset 0x%x}

			if {[Nx lelong [I 16 leshort 0 + 0 4] 0 0 {} {} > 0]} {>

			emit {%d Bytes}

				if {[Sx string [I [R -8] lelong 0 0 0 0] 0 {} {} eq RIFF]} {>

<}

<}

<}

<}

mime audio/x-vpm-wav-garmin

ext vpm

<}

<}
} {
if {[S string 0 0 {} {} eq NetWare\ Loadable\ Module]} {>

emit {NetWare Loadable Module}
<}
} {
if {[S string 0 0 {} {} eq \001\001\001\001]} {>

emit {MMDF mailbox}
<}
} {
if {[S string 0 0 {} {} eq UTE+]} {>

emit {uterus file}

if {[S string 4 0 {} {} eq v]} {>

emit {\b, version}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit %c
<}

if {[S string 6 0 {} {} eq .]} {>

emit {\b.}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[S string 8 0 {} {} eq <>]} {>

emit {\b, big-endian}

	if {[N belong 16 0 0 {} {} > 0]} {>

	emit {\b, slut size %u}
<}

<}

if {[S string 8 0 {} {} eq ><]} {>

emit {\b, litte-endian}

	if {[N lelong 16 0 0 {} {} > 0]} {>

	emit {\b, slut size %u}
<}

<}

if {[N byte 10 0 0 {} {} & 8]} {>

emit {\b, compressed}
<}

<}
} {
if {[S string 0 0 {} {} eq QL5]} {>

emit {QL disk dump data,}

if {[S string 3 0 {} {} eq A]} {>

emit {720 KB,}
<}

if {[S string 3 0 {} {} eq B]} {>

emit {1.44 MB,}
<}

if {[S string 3 0 {} {} eq C]} {>

emit {3.2 MB,}
<}

if {[S string 4 0 {} {} > \0]} {>

emit label:%.10s
<}

<}
} {
if {[S string 0 0 {} {} eq NqNqNq`\004]} {>

emit {QL firmware executable (BCPL)}
<}
} {
if {[S string 0 0 {} {} eq \177OLF]} {>

emit OLF

switch -- [Nv byte 4 0 {} {}] 0 {>;emit {invalid class};<} 1 {>;emit 32-bit;<} 2 {>;emit 64-bit;<} 
<

switch -- [Nv byte 7 0 {} {}] 0 {>;emit {invalid os};<} 1 {>;emit OpenBSD;<} 2 {>;emit NetBSD;<} 3 {>;emit FreeBSD;<} 4 {>;emit 4.4BSD;<} 5 {>;emit Linux;<} 6 {>;emit SVR4;<} 7 {>;emit esix;<} 8 {>;emit Solaris;<} 9 {>;emit Irix;<} 10 {>;emit SCO;<} 11 {>;emit Dell;<} 12 {>;emit NCR;<} 
<

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {invalid byte order};<} 1 {>;emit LSB

	switch -- [Nv leshort 16 0 {} {}] 0 {>;emit {no file type,};<} 1 {>;emit relocatable,;<} 2 {>;emit executable,;<} 3 {>;emit {shared object,};<} 4 {>;emit {core file}

		if {[S string [I 56 long 0 + 0 204] 0 {} {} > \0]} {>

		emit {of '%s'}
<}

		if {[N lelong [I 56 long 0 + 0 16] 0 0 {} {} > 0]} {>

		emit {(signal %d),}
<}
;<} 
<

	if {[N leshort 16 0 0 {} {} & 65280]} {>

	emit processor-specific,
<}

	switch -- [Nv leshort 18 0 {} {}] 0 {>;emit {no machine,};<} 1 {>;emit {AT&T WE32100 - invalid byte order,};<} 2 {>;emit {SPARC - invalid byte order,};<} 3 {>;emit {Intel 80386,};<} 4 {>;emit {Motorola 68000 - invalid byte order,};<} 5 {>;emit {Motorola 88000 - invalid byte order,};<} 6 {>;emit {Intel 80486,};<} 7 {>;emit {Intel 80860,};<} 8 {>;emit {MIPS R3000_BE - invalid byte order,};<} 9 {>;emit {Amdahl - invalid byte order,};<} 10 {>;emit {MIPS R3000_LE,};<} 11 {>;emit {RS6000 - invalid byte order,};<} 15 {>;emit {PA-RISC - invalid byte order,};<} 16 {>;emit nCUBE,;<} 17 {>;emit VPP500,;<} 18 {>;emit SPARC32PLUS,;<} 20 {>;emit PowerPC,;<} -28634 {>;emit Alpha,;<} 
<

	switch -- [Nv lelong 20 0 {} {}] 0 {>;emit {invalid version};<} 1 {>;emit {version 1};<} 
<

	if {[N lelong 36 0 0 {} {} == 1]} {>

	emit {MathCoPro/FPU/MAU Required}
<}
;<} 2 {>;emit MSB

	switch -- [Nv beshort 16 0 {} {}] 0 {>;emit {no file type,};<} 1 {>;emit relocatable,;<} 2 {>;emit executable,;<} 3 {>;emit {shared object,};<} 4 {>;emit {core file,}

		if {[S string [I 56 long 0 + 0 204] 0 {} {} > \0]} {>

		emit {of '%s'}
<}

		if {[N belong [I 56 long 0 + 0 16] 0 0 {} {} > 0]} {>

		emit {(signal %d),}
<}
;<} 
<

	if {[N beshort 16 0 0 {} {} & 65280]} {>

	emit processor-specific,
<}

	switch -- [Nv beshort 18 0 {} {}] 0 {>;emit {no machine,};<} 1 {>;emit {AT&T WE32100,};<} 2 {>;emit SPARC,;<} 3 {>;emit {Intel 80386 - invalid byte order,};<} 4 {>;emit {Motorola 68000,};<} 5 {>;emit {Motorola 88000,};<} 6 {>;emit {Intel 80486 - invalid byte order,};<} 7 {>;emit {Intel 80860,};<} 8 {>;emit {MIPS R3000_BE,};<} 9 {>;emit Amdahl,;<} 10 {>;emit {MIPS R3000_LE - invalid byte order,};<} 11 {>;emit RS6000,;<} 15 {>;emit PA-RISC,;<} 16 {>;emit nCUBE,;<} 17 {>;emit VPP500,;<} 18 {>;emit SPARC32PLUS,;<} 20 {>;emit {PowerPC or cisco 4500,};<} 21 {>;emit {cisco 7500,};<} 24 {>;emit {cisco SVIP,};<} 25 {>;emit {cisco 7200,};<} 36 {>;emit {cisco 12000,};<} -28634 {>;emit Alpha,;<} 
<

	switch -- [Nv belong 20 0 {} {}] 0 {>;emit {invalid version};<} 1 {>;emit {version 1};<} 
<

	if {[N belong 36 0 0 {} {} == 1]} {>

	emit {MathCoPro/FPU/MAU Required}
<}
;<} 
<

if {[S string 8 0 {} {} > \0]} {>

emit (%s)
<}

<}
} {
if {[S string 0 0 {} {} eq %PDF-]} {>

emit {PDF document}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b, version %c}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b.%c}
<}

mime application/pdf

<}
} {
if {[S string 0 0 {} {} eq \012%PDF-]} {>

emit {PDF document}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {\b, version %c}
<}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {\b.%c}
<}

mime application/pdf

<}
} {
if {[S string 0 0 {} {} eq %FDF-]} {>

emit {FDF document}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b, version %c}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b.%c}
<}

mime application/vnd.fdf

<}
} {
if {[N beshort 0 0 0 & 4095 == 2766]} {>

emit PARIX

switch -- [Nv byte 0 0 & 240] -128 {>;emit T800;<} -112 {>;emit T9000;<} 
<

switch -- [Nv byte 19 0 & 2] 2 {>;emit executable;<} 0 {>;emit object;<} 
<

if {[N byte 19 0 0 & 12 == 0]} {>

emit {not stripped}
<}

<}
} {
if {[S string 1 0 {} {} eq policy_module(]} {>

emit {SE Linux policy module source}
<}
} {
if {[S string 2 0 {} {} eq policy_module(]} {>

emit {SE Linux policy module source}
<}
} {
if {[S string 0 0 {} {} eq \#\#\ <summary>]} {>

emit {SE Linux policy interface source}
<}
} {
if {[S string 0 0 {} {} eq \177ELF]} {>

emit ELF

switch -- [Nv byte 4 0 {} {}] 0 {>;emit {invalid class};<} 1 {>;emit 32-bit;<} 2 {>;emit 64-bit;<} 
<

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {invalid byte order};<} 1 {>;emit LSB
U 177 elf-le
;<} 2 {>;emit MSB
U 177 elf-le
;<} 
<

if {[N byte 4 0 0 {} {} < 128]} {>

	if {[S string 8 0 {} {} > \0]} {>

	emit (%s)
<}

<}

if {[S string 8 0 {} {} eq \0]} {>

	switch -- [Nv byte 7 0 {} {}] 0 {>;emit (SYSV);<} 1 {>;emit (HP-UX);<} 2 {>;emit (NetBSD);<} 3 {>;emit (GNU/Linux);<} 4 {>;emit (GNU/Hurd);<} 5 {>;emit (86Open);<} 6 {>;emit (Solaris);<} 7 {>;emit (Monterey);<} 8 {>;emit (IRIX);<} 9 {>;emit (FreeBSD);<} 10 {>;emit (Tru64);<} 11 {>;emit {(Novell Modesto)};<} 12 {>;emit (OpenBSD);<} 
<

<}

if {[S string 8 0 {} {} eq \2]} {>

	switch -- [Nv byte 7 0 {} {}] 13 {>;emit (OpenVMS);<} 97 {>;emit (ARM);<} -1 {>;emit (embedded);<} 
<

<}

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/tcl]} {>

emit {Tcl script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/tcl]} {>

emit {Tcl script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ tcl]} {>

emit {Tcl script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 {} 1 eq \#!\ /usr/bin/env\ tcl]} {>

emit {Tcl script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/wish]} {>

emit {Tcl/Tk script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/wish]} {>

emit {Tcl/Tk script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ wish]} {>

emit {Tcl/Tk script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 {} 1 eq \#!\ /usr/bin/env\ wish]} {>

emit {Tcl/Tk script text executable}
mime text/x-tcl

<}
} {
if {[S search 0 0 {} 1 eq package\ req]} {>

if {[S regex 0 0 {} {} eq ^package\[\ \t\]+req]} {>

emit {Tcl script}
<}

<}
} {
if {[S search 0 0 {} 1 ne p]} {>

if {[S regex 0 0 {} {} eq ^package\[\ \t\]+req]} {>

emit {Tcl script}
<}

<}
} {
if {[S string 0 0 {} {} eq \210OPS]} {>

emit {Interleaf saved data}
<}
} {
if {[S string 0 0 {} {} eq <!OPS]} {>

emit {Interleaf document text}

if {[S string 5 0 {} {} eq ,\ Version\ =]} {>

emit {\b, version}

	if {[S string 17 0 {} {} > \0]} {>

	emit %.3s
<}

<}

<}
} {
if {[Sx string 2 0 {} {} eq ---BEGIN\ PGP\ PUBLIC\ KEY\ BLOCK-]} {>

emit {PGP public key block}

if {[Sx search 10 0 {} 100 eq \n\n]} {>
U 180 pgp

<}

mime application/pgp-keys

<}
} {
if {[Sx string 0 0 {} {} eq -----BEGIN\040PGP\40MESSAGE-]} {>

emit {PGP message}

if {[Sx search 10 0 {} 100 eq \n\n]} {>
U 180 pgp

<}

mime application/pgp

<}
} {
if {[Sx string 0 0 {} {} eq -----BEGIN\040PGP\40SIGNATURE-]} {>

emit {PGP signature}

if {[Sx search 10 0 {} 100 eq \n\n]} {>
U 180 pgp

<}

mime application/pgp-signature

<}
} {
if {[S string 0 0 {} {} eq \x84\x8c\x03]} {>

emit {PGP RSA encrypted session key -}

if {[N lelong 3 0 0 {} {} x {}]} {>

emit {keyid: %X}
<}

if {[N lelong 7 0 0 {} {} x {}]} {>

emit %X
<}

switch -- [Nv byte 11 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign) 1024b};<} 2 {>;emit {RSA Encrypt-Only 1024b};<} 
<

if {[S string 12 0 {} {} eq \x04\x00]} {>

<}

if {[S string 12 0 {} {} eq \x03\xff]} {>

<}

if {[S string 12 0 {} {} eq \x03\xfe]} {>

<}

if {[S string 12 0 {} {} eq \x03\xfd]} {>

<}

if {[S string 12 0 {} {} eq \x03\xfc]} {>

<}

if {[S string 12 0 {} {} eq \x03\xfb]} {>

<}

if {[S string 12 0 {} {} eq \x03\xfa]} {>

<}

if {[S string 12 0 {} {} eq \x03\xf9]} {>

<}

if {[N byte 142 0 0 {} {} == 210]} {>

emit .
<}

<}
} {
if {[S string 0 0 {} {} eq \x85\x01\x0c\x03]} {>

emit {PGP RSA encrypted session key -}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {keyid: %X}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit %X
<}

switch -- [Nv byte 12 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign) 2048b};<} 2 {>;emit {RSA Encrypt-Only 2048b};<} 
<

if {[S string 13 0 {} {} eq \x08\x00]} {>

<}

if {[S string 13 0 {} {} eq \x07\xff]} {>

<}

if {[S string 13 0 {} {} eq \x07\xfe]} {>

<}

if {[S string 13 0 {} {} eq \x07\xfd]} {>

<}

if {[S string 13 0 {} {} eq \x07\xfc]} {>

<}

if {[S string 13 0 {} {} eq \x07\xfb]} {>

<}

if {[S string 13 0 {} {} eq \x07\xfa]} {>

<}

if {[S string 13 0 {} {} eq \x07\xf9]} {>

<}

if {[N byte 271 0 0 {} {} == 210]} {>

emit .
<}

<}
} {
if {[S string 0 0 {} {} eq \x85\x01\x8c\x03]} {>

emit {PGP RSA encrypted session key -}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {keyid: %X}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit %X
<}

switch -- [Nv byte 12 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign) 3072b};<} 2 {>;emit {RSA Encrypt-Only 3072b};<} 
<

if {[S string 13 0 {} {} eq \x0c\x00]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xff]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xfe]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xfd]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xfc]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xfb]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xfa]} {>

<}

if {[S string 13 0 {} {} eq \x0b\xf9]} {>

<}

if {[N byte 399 0 0 {} {} == 210]} {>

emit .
<}

<}
} {
if {[S string 0 0 {} {} eq \x85\x02\x0c\x03]} {>

emit {PGP RSA encrypted session key -}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {keyid: %X}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit %X
<}

switch -- [Nv byte 12 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign) 4096b};<} 2 {>;emit {RSA Encrypt-Only 4096b};<} 
<

if {[S string 13 0 {} {} eq \x10\x00]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xff]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xfe]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xfd]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xfc]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xfb]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xfa]} {>

<}

if {[S string 13 0 {} {} eq \x0f\xf9]} {>

<}

if {[N byte 527 0 0 {} {} == 210]} {>

emit .
<}

<}
} {
if {[S string 0 0 {} {} eq \x85\x04\x0c\x03]} {>

emit {PGP RSA encrypted session key -}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {keyid: %X}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit %X
<}

switch -- [Nv byte 12 0 {} {}] 1 {>;emit {RSA (Encrypt or Sign) 8129b};<} 2 {>;emit {RSA Encrypt-Only 8129b};<} 
<

if {[S string 13 0 {} {} eq \x20\x00]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xff]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xfe]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xfd]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xfc]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xfb]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xfa]} {>

<}

if {[S string 13 0 {} {} eq \x1f\xf9]} {>

<}

if {[N byte 1039 0 0 {} {} == 210]} {>

emit .
<}

<}
} {
if {[S string 0 0 {} {} eq LUKS\xba\xbe]} {>

emit {LUKS encrypted file,}

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {ver %d}
<}

if {[S string 8 0 {} {} x {}]} {>

emit {[%s,}
<}

if {[S string 40 0 {} {} x {}]} {>

emit %s,
<}

if {[S string 72 0 {} {} x {}]} {>

emit %s\]
<}

if {[S string 168 0 {} {} x {}]} {>

emit {UUID: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq HWB\000\377\001\000\000\000]} {>

emit {Microsoft Visual C .APS file}
<}
} {
if {[S string 0 0 {} {} eq \102\157\162\154\141\156\144\040\103\053\053\040\120\162\157]} {>

emit {MSVC .ide}
<}
} {
if {[S string 0 0 {} {} eq \000\000\000\000\040\000\000\000\377]} {>

emit {MSVC .res}
<}
} {
if {[S string 0 0 {} {} eq \377\003\000\377\001\000\020\020\350]} {>

emit {MSVC .res}
<}
} {
if {[S string 0 0 {} {} eq \377\003\000\377\001\000\060\020\350]} {>

emit {MSVC .res}
<}
} {
if {[S string 0 0 {} {} eq \360\015\000\000]} {>

emit {Microsoft Visual C library}
<}
} {
if {[S string 0 0 {} {} eq \360\075\000\000]} {>

emit {Microsoft Visual C library}
<}
} {
if {[S string 0 0 {} {} eq \360\175\000\000]} {>

emit {Microsoft Visual C library}
<}
} {
if {[S string 0 0 {} {} eq DTJPCH0\000\022\103\006\200]} {>

emit {Microsoft Visual C .pch}
<}
} {
if {[S string 0 0 {} {} eq Microsoft\ C/C++\ ]} {>

if {[S search 24 0 {} 14 eq \r\n\x1A]} {>

emit {MSVC program database}

	if {[S regex 16 0 {} {} eq (\[0-9.\]+)]} {>

	emit {ver %s}
<}

	if {[N leshort 30 0 0 {} {} == 0]} {>

		if {[N lelong 32 0 0 {} {} x {}]} {>

		emit {\b, %d}
<}

		if {[N lelong 40 0 0 {} {} x {}]} {>

		emit {\b*%d bytes}
<}

<}

	if {[N leshort 30 0 0 {} {} != 0]} {>

		if {[N lelong 44 0 0 {} {} x {}]} {>

		emit {\b, %d}
<}

		if {[N leshort 50 0 0 {} {} x {}]} {>

		emit {\b*%d bytes}
<}

<}

mime application/x-ms-pdb

ext pdb

<}

<}
} {
if {[S string 0 0 {} {} eq \000\002\000\007\000]} {>

emit {MSVC .sbr}

if {[S string 5 0 {} {} > \0]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq \002\000\002\001]} {>

emit {MSVC .bsc}
<}
} {
if {[S string 0 0 {} {} eq 1.00\ .0000.0000\000\003]} {>

emit {MSVC .wsp version 1.0000.0000}
<}
} {
if {[N beshort 6 0 0 {} {} == 263]} {>

emit {unicos (cray) executable}
<}
} {
if {[S string 596 0 {} {} eq \130\337\377\377]} {>

emit {Ultrix core file}

if {[S string 600 0 {} {} > \0]} {>

emit {from '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq Joy!peffpwpc]} {>

emit {header for PowerPC PEF executable}
<}
} {
if {[S string 0 0 {} {} eq avaobj]} {>

emit {AVR assembler object code}

if {[S string 7 0 {} {} > \0]} {>

emit {version '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq gmon]} {>

emit {GNU prof performance data}

if {[N long 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq \xc0HRB]} {>

emit {Harbour HRB file}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 0 0 {} {} eq \xc0HBV]} {>

emit {Harbour variable dump file}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S search 0 0 {} 1 eq !_TAG]} {>

emit {Exuberant Ctags tag file text}
<}
} {
if {[S string 60 0 {} {} eq SDocSilX]} {>

emit {iSiloX E-book}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[Sx string 60 0 {} {} eq BOOKMOBI]} {>

emit {Mobipocket E-book}

if {[Nx belong [I 78 belong 0 0 0 0] 0 0 {} {} x {}]} {>

	if {[Sx string [R [I [R 80] belong 0 - 0 4]] 0 {} {} > \0]} {>

	emit {"%s"}
<}

<}
U 185 aportisdoc

<}
} {
if {[S string 60 0 {} {} eq TEXtREAd]} {>

emit {AportisDoc/PalmDOC E-book}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}
U 185 aportisdoc

<}
} {
if {[S string 60 0 {} {} eq BVokBDIC]} {>

emit {BDicty PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DB99DBOS]} {>

emit {DB PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq vIMGView]} {>

emit {FireViewer/ImageViewer PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq PmDBPmDB]} {>

emit {HanDBase PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq InfoINDB]} {>

emit {InfoView PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq ToGoToGo]} {>

emit {iSilo PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq JfDbJBas]} {>

emit {JFile PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq JfDbJFil]} {>

emit {JFile Pro PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DATALSdb]} {>

emit {List PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq Mdb1Mdb1]} {>

emit {MobileDB PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq PNRdPPrs]} {>

emit {PeanutPress PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DataPlkr]} {>

emit {Plucker PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DataSprd]} {>

emit {QuickSheet PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq SM01SMem]} {>

emit {SuperMemo PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq TEXtTlDc]} {>

emit {TealDoc PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq InfoTlIf]} {>

emit {TealInfo PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DataTlMl]} {>

emit {TealMeal PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq DataTlPt]} {>

emit {TealPaint PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq dataTDBP]} {>

emit {ThinkDB PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq TdatTide]} {>

emit {Tides PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq ToRaTRPW]} {>

emit {TomeRaider PalmOS document}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq zTXT]} {>

emit {A GutenPalm zTXT e-book}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

switch -- [Nv byte [I 78 belong 0 0 0 0] 0 {} {}] 0 {>;
	if {[N byte [I 78 belong 0 + 0 1] 0 0 {} {} x {}]} {>

	emit (v0.%02d)
<}
;<} 1 {>;
	if {[N byte [I 78 belong 0 + 0 1] 0 0 {} {} x {}]} {>

	emit (v1.%02d)

		if {[N beshort [I 78 belong 0 + 0 10] 0 0 {} {} > 0]} {>

			if {[N beshort [I 78 belong 0 + 0 10] 0 0 {} {} < 2]} {>

			emit {- 1 bookmark}
<}

			if {[N beshort [I 78 belong 0 + 0 10] 0 0 {} {} > 1]} {>

			emit {- %d bookmarks}
<}

<}

		if {[N beshort [I 78 belong 0 + 0 14] 0 0 {} {} > 0]} {>

			if {[N beshort [I 78 belong 0 + 0 14] 0 0 {} {} < 2]} {>

			emit {- 1 annotation}
<}

			if {[N beshort [I 78 belong 0 + 0 14] 0 0 {} {} > 1]} {>

			emit {- %d annotations}
<}

<}

<}
;<} 
<

if {[N byte [I 78 belong 0 0 0 0] 0 0 {} {} > 1]} {>

emit (v%d.

	if {[N byte [I 78 belong 0 + 0 1] 0 0 {} {} x {}]} {>

	emit %02d)
<}

<}

<}
} {
if {[S string 60 0 {} {} eq libr]} {>

if {[N beshort 32 0 0 & 65470 == 0]} {>

	if {[S string 0 0 {} {} > \0]} {>

	emit {Palm OS dynamic library data "%s"}
<}

<}

<}
} {
if {[S string 60 0 {} {} eq ptch]} {>

emit {Palm OS operating system patch data}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 60 0 {} {} eq BOOKMOBI]} {>

emit {Mobipocket E-book}

if {[S string 0 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq 0xabcdef]} {>

emit {AIX message catalog}
<}
} {
if {[S string 0 0 {} {} eq <aiaff>]} {>

emit archive
<}
} {
if {[S string 0 0 {} {} eq <bigaf>]} {>

emit {archive (big format)}
<}
} {
if {[N belong 4 0 0 {} {} & 267312560]} {>

if {[N byte 7 0 0 & 3 != 3]} {>

emit {AIX core file}

	if {[N byte 1 0 0 {} {} & 1]} {>

	emit fulldump
<}

	if {[N byte 7 0 0 {} {} & 1]} {>

	emit 32-bit

		if {[S string 1760 0 {} {} > \0]} {>

		emit {\b, %s}
<}

<}

	if {[N byte 7 0 0 {} {} & 2]} {>

	emit 64-bit

		if {[S string 1316 0 {} {} > \0]} {>

		emit {\b, %s}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \x30\x00\x00\x7C]} {>

if {[S string 36 0 {} {} eq \x00\x3E]} {>

emit {Micro Focus File with Header (DAT)}
mime application/octet-stream

<}

<}
} {
if {[S string 0 0 {} {} eq \x30\x7E\x00\x00]} {>

if {[S string 36 0 {} {} eq \x00\x3E]} {>

emit {Micro Focus File with Header (DAT)}
mime application/octet-stream

<}

<}
} {
if {[S string 39 0 {} {} eq \x02]} {>

if {[S string 136 0 {} {} eq \x02\x02\x04\x04]} {>

emit {Micro Focus Index File (IDX)}
mime application/octet-stream

<}

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/bin/ruby]} {>

emit {Ruby script text executable}
mime text/x-ruby

<}
} {
if {[S search 0 0 w 1 eq \#!\ /usr/local/bin/ruby]} {>

emit {Ruby script text executable}
mime text/x-ruby

<}
} {
if {[S search 0 0 {} 1 eq \#!/usr/bin/env\ ruby]} {>

emit {Ruby script text executable}
mime text/x-ruby

<}
} {
if {[S search 0 0 {} 1 eq \#!\ /usr/bin/env\ ruby]} {>

emit {Ruby script text executable}
mime text/x-ruby

<}
} {
if {[S regex 0 0 {} {} eq ^\[\ \t\]*require\[\ \t\]'\[A-Za-z_/\]+']} {>

if {[S regex 0 0 {} {} eq include\ \[A-Z\]|def\ \[a-z\]|\ do\$]} {>

	if {[S regex 0 0 {} {} eq ^\[\ \t\]*end(\[\ \t\]*\[\;\#\].*)?\$]} {>

	emit {Ruby script text}
	mime text/x-ruby

<}

<}

<}
} {
if {[S regex 0 0 {} {} eq ^\[\ \t\]*(class|module)\[\ \t\]\[A-Z\]]} {>

if {[S regex 0 0 {} {} eq (modul|includ)e\ \[A-Z\]|def\ \[a-z\]]} {>

	if {[S regex 0 0 {} {} eq ^\[\ \t\]*end(\[\ \t\]*\[\;\#\].*)?\$]} {>

	emit {Ruby module source text}
	mime text/x-ruby

<}

<}

<}
} {
if {[S string 0 0 {} {} eq POLYSAVE]} {>

emit {Poly/ML saved state}

if {[N long 8 0 0 {} {} x {}]} {>

emit {version %u}
<}

<}
} {
if {[S string 0 0 {} {} eq POLYMODU]} {>

emit {Poly/ML saved module}

if {[N long 8 0 0 {} {} x {}]} {>

emit {version %u}
<}

<}
} {
if {[Sx string 0 0 b {} eq =srl]} {>

emit {Sereal data packet}
U 193 sereal

mime application/sereal

<}
} {
if {[Sx string 0 0 b {} eq =\xF3rl]} {>

emit {Sereal data packet}
U 193 sereal

mime application/sereal

<}
} {
if {[Sx string 0 0 b {} eq =\xC3\xB3rl]} {>

emit {Sereal data packet, UTF-8 encoded}
U 193 sereal

mime application/sereal

<}
} {
if {[S string 0 0 {} {} eq \367\002]} {>

emit {TeX DVI file}

if {[S string 16 0 {} {} > \0]} {>

emit (%s)
<}

mime application/x-dvi

<}
} {
if {[S string 0 0 {} {} eq \367\203]} {>

emit {TeX generic font data}
<}
} {
if {[S string 0 0 {} {} eq \367\131]} {>

emit {TeX packed font data}

if {[S string 3 0 {} {} > \0]} {>

emit (%s)
<}

<}
} {
if {[S string 0 0 {} {} eq \367\312]} {>

emit {TeX virtual font data}
<}
} {
if {[S search 0 0 {} 1 eq This\ is\ TeX,]} {>

emit {TeX transcript text}
<}
} {
if {[S search 0 0 {} 1 eq This\ is\ METAFONT,]} {>

emit {METAFONT transcript text}
<}
} {
if {[S string 2 0 {} {} eq \000\021]} {>

emit {TeX font metric data}

if {[S string 33 0 {} {} > \0]} {>

emit (%s)
<}

mime application/x-tex-tfm

<}
} {
if {[S string 2 0 {} {} eq \000\022]} {>

emit {TeX font metric data}

if {[S string 33 0 {} {} > \0]} {>

emit (%s)
<}

mime application/x-tex-tfm

<}
} {
if {[S search 0 0 {} 1 eq \\input\ texinfo]} {>

emit {Texinfo source text}
mime text/x-texinfo

<}
} {
if {[S search 0 0 {} 1 eq This\ is\ Info\ file]} {>

emit {GNU Info text}
mime text/x-info

<}
} {
if {[S search 0 0 {} 4096 eq \\input]} {>

emit {TeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\begin]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\section]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\setlength]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\documentstyle]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\chapter]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\documentclass]} {>

emit {LaTeX 2e document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\relax]} {>

emit {LaTeX auxiliary file}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq \\contentsline]} {>

emit {LaTeX table of contents}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 4096 eq %\ -*-latex-*-]} {>

emit {LaTeX document text}
mime text/x-tex

<}
} {
if {[S search 0 0 {} 1 eq \\ifx]} {>

emit {TeX document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\indexentry]} {>

emit {LaTeX raw index file}
<}
} {
if {[S search 0 0 {} 4096 eq \\begin\{theindex\}]} {>

emit {LaTeX sorted index}
<}
} {
if {[S search 0 0 {} 4096 eq \\glossaryentry]} {>

emit {LaTeX raw glossary}
<}
} {
if {[S search 0 0 {} 4096 eq \\begin\{theglossary\}]} {>

emit {LaTeX sorted glossary}
<}
} {
if {[S search 0 0 {} 4096 eq This\ is\ makeindex]} {>

emit {Makeindex log file}
<}
} {
if {[S search 0 0 c 1 eq @article\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @book\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @inbook\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @incollection\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @inproceedings\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @manual\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @misc\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @preamble\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @phdthesis\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @techreport\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 0 0 c 1 eq @unpublished\{]} {>

emit {BibTeX text file}
<}
} {
if {[S search 73 0 {} 1 eq %%%\ \ ]} {>

emit BibTeX-file\{\ BibTex\ text\ file\ (with\ full\ header)
<}
} {
if {[S search 73 0 {} 1 eq %%%\ \ @BibTeX-style-file\{]} {>

emit {BibTeX style text file (with full header)}
<}
} {
if {[S search 0 0 {} 1 eq %\ BibTeX\ standard\ bibliography\ ]} {>

emit {BibTeX standard bibliography style text file}
<}
} {
if {[S search 0 0 {} 1 eq %\ BibTeX\ `]} {>

emit {BibTeX custom bibliography style text file}
<}
} {
if {[S search 0 0 {} 1 eq @c\ @mapfile\{]} {>

emit {TeX font aliases text file}
<}
} {
if {[S string 0 0 {} {} eq \#LyX]} {>

emit {LyX document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupcolors\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\definecolor\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupinteraction\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\useURL\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setuppapersize\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setuplayout\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupfooter\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupfootertexts\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setuppagenumbering\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupbodyfont\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setuphead\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupitemize\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupwhitespace\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S search 0 0 {} 4096 eq \\setupindenting\[]} {>

emit {ConTeXt document text}
<}
} {
if {[S string 0 0 {} {} eq <!SQ\ DTD>]} {>

emit {Compiled SGML rules file}

if {[S string 9 0 {} {} > \0]} {>

emit {Type %s}
<}

<}
} {
if {[S string 0 0 {} {} eq <!SQ\ A/E>]} {>

emit {A/E SGML Document binary}

if {[S string 9 0 {} {} > \0]} {>

emit {Type %s}
<}

<}
} {
if {[S string 0 0 {} {} eq <!SQ\ STS>]} {>

emit {A/E SGML binary styles file}

if {[S string 9 0 {} {} > \0]} {>

emit {Type %s}
<}

<}
} {
if {[S search 0 0 {} 1 eq SQ\ BITMAP1]} {>

emit {SoftQuad Raster Format text}
<}
} {
if {[S string 0 0 {} {} eq X\ ]} {>

emit {SoftQuad troff Context intermediate}

if {[S string 2 0 {} {} eq 495]} {>

emit {for AT&T 495 laser printer}
<}

if {[S string 2 0 {} {} eq hp]} {>

emit {for Hewlett-Packard LaserJet}
<}

if {[S string 2 0 {} {} eq impr]} {>

emit {for IMAGEN imPRESS}
<}

if {[S string 2 0 {} {} eq ps]} {>

emit {for PostScript}
<}

<}
} {
if {[S string 0 0 {} {} eq X\ 495]} {>

emit {SoftQuad troff Context intermediate for AT&T 495 laser printer}
<}
} {
if {[S string 0 0 {} {} eq X\ hp]} {>

emit {SoftQuad troff Context intermediate for HP LaserJet}
<}
} {
if {[S string 0 0 {} {} eq X\ impr]} {>

emit {SoftQuad troff Context intermediate for IMAGEN imPRESS}
<}
} {
if {[S string 0 0 {} {} eq X\ ps]} {>

emit {SoftQuad troff Context intermediate for PostScript}
<}
} {
if {[S string 0 0 {} {} eq XPCOM\nMozFASL\r\n\x1A]} {>

emit {Mozilla XUL fastload data}
<}
} {
if {[S string 0 0 {} {} eq mozLz4a]} {>

emit {Mozilla lz4 compressed bookmark data}
<}
} {
if {[Sx string 0 0 {} {} eq \0m\3]} {>

emit {mcrypt 2.5 encrypted data,}

if {[Sx string 4 0 {} {} > \0]} {>

emit {algorithm: %s,}

	if {[Nx leshort [R 1] 0 0 {} {} > 0]} {>

	emit {keysize: %d bytes,}

		if {[Sx string [R 0] 0 {} {} > \0]} {>

		emit {mode: %s,}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \0m\2]} {>

emit {mcrypt 2.2 encrypted data,}

switch -- [Nv byte 3 0 {} {}] 0 {>;emit {algorithm: blowfish-448,};<} 1 {>;emit {algorithm: DES,};<} 2 {>;emit {algorithm: 3DES,};<} 3 {>;emit {algorithm: 3-WAY,};<} 4 {>;emit {algorithm: GOST,};<} 6 {>;emit {algorithm: SAFER-SK64,};<} 7 {>;emit {algorithm: SAFER-SK128,};<} 8 {>;emit {algorithm: CAST-128,};<} 9 {>;emit {algorithm: xTEA,};<} 10 {>;emit {algorithm: TWOFISH-128,};<} 11 {>;emit {algorithm: RC2,};<} 12 {>;emit {algorithm: TWOFISH-192,};<} 13 {>;emit {algorithm: TWOFISH-256,};<} 14 {>;emit {algorithm: blowfish-128,};<} 15 {>;emit {algorithm: blowfish-192,};<} 16 {>;emit {algorithm: blowfish-256,};<} 100 {>;emit {algorithm: RC6,};<} 101 {>;emit {algorithm: IDEA,};<} 
<

switch -- [Nv byte 4 0 {} {}] 0 {>;emit {mode: CBC,};<} 1 {>;emit {mode: ECB,};<} 2 {>;emit {mode: CFB,};<} 3 {>;emit {mode: OFB,};<} 4 {>;emit {mode: nOFB,};<} 
<

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {keymode: 8bit};<} 1 {>;emit {keymode: 4bit};<} 2 {>;emit {keymode: SHA-1 hash};<} 3 {>;emit {keymode: MD5 hash};<} 
<

<}
} {
if {[S string 0 0 {} {} eq HG10]} {>

emit {Mercurial changeset bundle}

if {[S string 4 0 {} {} eq UN]} {>

emit (uncompressed)
<}

if {[S string 4 0 {} {} eq GZ]} {>

emit {(gzip compressed)}
<}

if {[S string 4 0 {} {} eq BZ]} {>

emit {(bzip2 compressed)}
<}

<}
} {
if {[S string 11 0 {} {} eq must\ be\ converted\ with\ BinHex]} {>

emit {BinHex binary text}

if {[S string 41 0 {} {} x {}]} {>

emit {\b, version %.3s}
<}

mime application/mac-binhex40

<}
} {
if {[S string 0 0 {} {} eq SIT!]} {>

emit {StuffIt Archive (data)}

if {[S string 2 0 {} {} x {}]} {>

emit {: %s}
<}

mime application/x-stuffit

<}
} {
if {[S string 0 0 {} {} eq SITD]} {>

emit {StuffIt Deluxe (data)}

if {[S string 2 0 {} {} x {}]} {>

emit {: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq Seg]} {>

emit {StuffIt Deluxe Segment (data)}

if {[S string 2 0 {} {} x {}]} {>

emit {: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq StuffIt]} {>

emit {StuffIt Archive}
mime application/x-stuffit

<}
} {
if {[S string 102 0 {} {} eq mBIN]} {>

emit {MacBinary III data with surprising version number}
<}
} {
if {[S string 0 0 {} {} eq SAS]} {>

emit SAS

if {[S string 24 0 {} {} eq DATA]} {>

emit {data file}
<}

if {[S string 24 0 {} {} eq CATALOG]} {>

emit catalog
<}

if {[S string 24 0 {} {} eq INDEX]} {>

emit {data file index}
<}

if {[S string 24 0 {} {} eq VIEW]} {>

emit {data view}
<}

<}
} {
if {[S string 84 0 {} {} eq SAS]} {>

emit {SAS 7+}

if {[S string 156 0 {} {} eq DATA]} {>

emit {data file}
<}

if {[S string 156 0 {} {} eq CATALOG]} {>

emit catalog
<}

if {[S string 156 0 {} {} eq INDEX]} {>

emit {data file index}
<}

if {[S string 156 0 {} {} eq VIEW]} {>

emit {data view}
<}

<}
} {
if {[S string 0 0 {} {} eq \$FL2]} {>

emit {SPSS System File}

if {[S string 24 0 {} {} x {}]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq \$FL3]} {>

emit {SPSS System File}

if {[S string 24 0 {} {} x {}]} {>

emit %s
<}

<}
} {
switch -- [Nvx beshort 1024 0 {} {}] -11561 {>;emit {Macintosh MFS data}

if {[N beshort 0 0 0 {} {} == 19531]} {>

emit (bootable)
<}

if {[N beshort 1034 0 0 {} {} & 32768]} {>

emit (locked)
<}

if {[N beldate 1026 0 0 - 2082844800 x {}]} {>

emit {created: %s,}
<}

if {[N beldate 1030 0 0 - 2082844800 > 0]} {>

emit {last backup: %s,}
<}

if {[N belong 1044 0 0 {} {} x {}]} {>

emit {block size: %d,}
<}

if {[N beshort 1042 0 0 {} {} x {}]} {>

emit {number of blocks: %d,}
<}

if {[S pstring 1060 0 {} {} x {}]} {>

emit {volume name: %s}
<}
;<} 16964 {>;
if {[N beshort 1038 0 0 {} {} == 3]} {>

	if {[N byte 1060 0 0 {} {} < 28]} {>

	emit {Macintosh HFS data}

		if {[N beshort 0 0 0 {} {} == 19531]} {>

		emit (bootable)
<}

		if {[N beshort 1034 0 0 {} {} & 32768]} {>

		emit (locked)
<}

		if {[N beshort 1034 0 0 {} {} ^ 256]} {>

		emit (mounted)
<}

		if {[N beshort 1034 0 0 {} {} & 512]} {>

		emit {(spared blocks)}
<}

		if {[N beshort 1034 0 0 {} {} & 2048]} {>

		emit (unclean)
<}

		if {[N beshort 1148 0 0 {} {} == 18475]} {>

		emit {(Embedded HFS+ Volume)}
<}

		if {[N belong 1044 0 0 {} {} x {}]} {>

		emit {block size: %d,}
<}

		if {[N beshort 1042 0 0 {} {} x {}]} {>

		emit {number of blocks: %d,}
<}

		if {[S pstring 1060 0 {} {} x {}]} {>

		emit {volume name: %s}
<}

	mime application/x-apple-diskimage

	ext hfs/dmg

<}

<}
;<} 18475 {>;emit {Macintosh HFS Extended}

if {[Nx beshort [R 0] 0 0 {} {} x {}]} {>

emit {version %d data}
<}

if {[N beshort 0 0 0 {} {} == 19531]} {>

emit (bootable)
<}

if {[N belong 1028 0 0 {} {} ^ 256]} {>

emit (mounted)
<}

if {[Nx belong [R 2] 0 0 {} {} & 512]} {>

emit {(spared blocks)}
<}

if {[Nx belong [R 2] 0 0 {} {} & 2048]} {>

emit (unclean)
<}

if {[Nx belong [R 2] 0 0 {} {} & 32768]} {>

emit (locked)
<}

if {[Sx string [R 6] 0 {} {} x {}]} {>

emit {last mounted by: '%.4s',}
<}

if {[Nx beldate [R 14] 0 0 - 2082844800 x {}]} {>

emit {created: %s,}
<}

if {[Nx bedate [R 18] 0 0 - 2082844800 x {}]} {>

emit {last modified: %s,}
<}

if {[Nx bedate [R 22] 0 0 - 2082844800 > 0]} {>

emit {last backup: %s,}
<}

if {[Nx bedate [R 26] 0 0 - 2082844800 > 0]} {>

emit {last checked: %s,}
<}

if {[Nx belong [R 38] 0 0 {} {} x {}]} {>

emit {block size: %d,}
<}

if {[Nx belong [R 42] 0 0 {} {} x {}]} {>

emit {number of blocks: %d,}
<}

if {[Nx belong [R 46] 0 0 {} {} x {}]} {>

emit {free blocks: %d}
<}
;<} 
<
} {
if {[S string 0 0 {} {} eq BOMStore]} {>

emit {Mac OS X bill of materials (BOM) file}
<}
} {
if {[S string 0 0 {} {} eq TZif]} {>

emit {timezone data}

if {[N byte 4 0 0 {} {} == 0]} {>

emit {\b, old version}
<}

if {[N byte 4 0 0 {} {} > 0]} {>

emit {\b, version %c}
<}

switch -- [Nv belong 20 0 {} {}] 0 {>;emit {\b, no gmt time flags};<} 1 {>;emit {\b, 1 gmt time flag};<} 1 {>;emit {\b, 1 std time flag};<} 
<

if {[N belong 20 0 0 {} {} > 1]} {>

emit {\b, %d gmt time flags}
<}

if {[N belong 24 0 0 {} {} == 0]} {>

emit {\b, no std time flags}
<}

if {[N belong 24 0 0 {} {} > 1]} {>

emit {\b, %d std time flags}
<}

switch -- [Nv belong 28 0 {} {}] 0 {>;emit {\b, no leap seconds};<} 1 {>;emit {\b, 1 leap second};<} 
<

if {[N belong 28 0 0 {} {} > 1]} {>

emit {\b, %d leap seconds}
<}

switch -- [Nv belong 32 0 {} {}] 0 {>;emit {\b, no transition times};<} 1 {>;emit {\b, 1 transition time};<} 
<

if {[N belong 32 0 0 {} {} > 1]} {>

emit {\b, %d transition times}
<}

switch -- [Nv belong 36 0 {} {}] 0 {>;emit {\b, no abbreviation chars};<} 1 {>;emit {\b, 1 abbreviation char};<} 
<

if {[N belong 36 0 0 {} {} > 1]} {>

emit {\b, %d abbreviation chars}
<}

<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\2\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\4\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\5\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\6\0]} {>

emit {old timezone data}
<}
} {
if {[S string 0 0 t {} eq \[KDE\ Desktop\ Entry\]]} {>

emit {KDE desktop entry}
mime application/x-kdelnk

<}
} {
if {[S string 0 0 t {} eq \#\ KDE\ Config\ File]} {>

emit {KDE config file}
mime application/x-kdelnk

<}
} {
if {[S string 0 0 t {} eq \#\ xmcd]} {>

emit {xmcd database file for kscd}
mime text/x-xmcd

<}
} {
if {[S string 0 0 {} {} eq IsZ!]} {>

emit {ISO Zipped file}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b, header size %u}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b, version %u}
<}

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {\b, serial %u}
<}

if {[N byte 17 0 0 {} {} > 0]} {>

emit {\b, password protected}
<}

<}
} {
switch -- [Nv lelong 0 0 & 67108863] 8782087 {>;emit FreeBSD/i386

if {[N lelong 20 0 0 {} {} < 4096]} {>

	if {[N byte 3 0 0 & 192 & 128]} {>

	emit {shared library}
<}

	switch -- [Nv byte 3 0 & 192] 64 {>;emit {PIC object};<} 0 {>;emit object;<} 
<

<}

if {[N lelong 20 0 0 {} {} > 4095]} {>

	switch -- [Nv byte 3 0 & 128] -128 {>;emit {dynamically linked executable};<} 0 {>;emit executable;<} 
<

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782088 {>;emit {FreeBSD/i386 pure}

if {[N lelong 20 0 0 {} {} < 4096]} {>

	if {[N byte 3 0 0 & 192 & 128]} {>

	emit {shared library}
<}

	switch -- [Nv byte 3 0 & 192] 64 {>;emit {PIC object};<} 0 {>;emit object;<} 
<

<}

if {[N lelong 20 0 0 {} {} > 4095]} {>

	switch -- [Nv byte 3 0 & 128] -128 {>;emit {dynamically linked executable};<} 0 {>;emit executable;<} 
<

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782091 {>;emit {FreeBSD/i386 demand paged}

if {[N lelong 20 0 0 {} {} < 4096]} {>

	if {[N byte 3 0 0 & 192 & 128]} {>

	emit {shared library}
<}

	switch -- [Nv byte 3 0 & 192] 64 {>;emit {PIC object};<} 0 {>;emit object;<} 
<

<}

if {[N lelong 20 0 0 {} {} > 4095]} {>

	switch -- [Nv byte 3 0 & 128] -128 {>;emit {dynamically linked executable};<} 0 {>;emit executable;<} 
<

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 8782028 {>;emit {FreeBSD/i386 compact demand paged}

if {[N lelong 20 0 0 {} {} < 4096]} {>

	if {[N byte 3 0 0 & 192 & 128]} {>

	emit {shared library}
<}

	switch -- [Nv byte 3 0 & 192] 64 {>;emit {PIC object};<} 0 {>;emit object;<} 
<

<}

if {[N lelong 20 0 0 {} {} > 4095]} {>

	switch -- [Nv byte 3 0 & 128] -128 {>;emit {dynamically linked executable};<} 0 {>;emit executable;<} 
<

<}

if {[N lelong 16 0 0 {} {} > 0]} {>

emit {not stripped}
<}
;<} 
<
} {
if {[S string 7 0 {} {} eq \357\020\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

emit {FreeBSD/i386 a.out core file}

if {[S string 1039 0 {} {} > \0]} {>

emit {from '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq SCRSHOT_]} {>

emit {scrshot(1) screenshot,}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N byte 9 0 0 {} {} == 2]} {>

emit {%d bytes in header,}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit {%d chars wide by}
<}

	if {[N byte 11 0 0 {} {} x {}]} {>

	emit {%d chars high}
<}

<}

<}
} {
if {[N leshort 0 0 0 & 65532 == 38400]} {>

emit {little endian ispell}

switch -- [Nv byte 0 0 {} {}] 0 {>;emit {hash file (?),};<} 1 {>;emit {3.0 hash file,};<} 2 {>;emit {3.1 hash file,};<} 3 {>;emit {hash file (?),};<} 
<

switch -- [Nv leshort 2 0 {} {}] 0 {>;emit {8-bit, no capitalization, 26 flags};<} 1 {>;emit {7-bit, no capitalization, 26 flags};<} 2 {>;emit {8-bit, capitalization, 26 flags};<} 3 {>;emit {7-bit, capitalization, 26 flags};<} 4 {>;emit {8-bit, no capitalization, 52 flags};<} 5 {>;emit {7-bit, no capitalization, 52 flags};<} 6 {>;emit {8-bit, capitalization, 52 flags};<} 7 {>;emit {7-bit, capitalization, 52 flags};<} 8 {>;emit {8-bit, no capitalization, 128 flags};<} 9 {>;emit {7-bit, no capitalization, 128 flags};<} 10 {>;emit {8-bit, capitalization, 128 flags};<} 11 {>;emit {7-bit, capitalization, 128 flags};<} 12 {>;emit {8-bit, no capitalization, 256 flags};<} 13 {>;emit {7-bit, no capitalization, 256 flags};<} 14 {>;emit {8-bit, capitalization, 256 flags};<} 15 {>;emit {7-bit, capitalization, 256 flags};<} 
<

if {[N leshort 4 0 0 {} {} > 0]} {>

emit {and %d string characters}
<}

<}
} {
if {[N beshort 0 0 0 & 65532 == 38400]} {>

emit {big endian ispell}

switch -- [Nv byte 1 0 {} {}] 0 {>;emit {hash file (?),};<} 1 {>;emit {3.0 hash file,};<} 2 {>;emit {3.1 hash file,};<} 3 {>;emit {hash file (?),};<} 
<

switch -- [Nv beshort 2 0 {} {}] 0 {>;emit {8-bit, no capitalization, 26 flags};<} 1 {>;emit {7-bit, no capitalization, 26 flags};<} 2 {>;emit {8-bit, capitalization, 26 flags};<} 3 {>;emit {7-bit, capitalization, 26 flags};<} 4 {>;emit {8-bit, no capitalization, 52 flags};<} 5 {>;emit {7-bit, no capitalization, 52 flags};<} 6 {>;emit {8-bit, capitalization, 52 flags};<} 7 {>;emit {7-bit, capitalization, 52 flags};<} 8 {>;emit {8-bit, no capitalization, 128 flags};<} 9 {>;emit {7-bit, no capitalization, 128 flags};<} 10 {>;emit {8-bit, capitalization, 128 flags};<} 11 {>;emit {7-bit, capitalization, 128 flags};<} 12 {>;emit {8-bit, no capitalization, 256 flags};<} 13 {>;emit {7-bit, no capitalization, 256 flags};<} 14 {>;emit {8-bit, capitalization, 256 flags};<} 15 {>;emit {7-bit, capitalization, 256 flags};<} 
<

if {[N beshort 4 0 0 {} {} > 0]} {>

emit {and %d string characters}
<}

<}
} {
if {[S string 0 0 {} {} eq ISPL]} {>

emit ispell

if {[N long 4 0 0 {} {} x {}]} {>

emit {hash file version %d,}
<}

if {[N long 8 0 0 {} {} x {}]} {>

emit {lexletters %d,}
<}

if {[N long 12 0 0 {} {} x {}]} {>

emit {lexsize %d,}
<}

if {[N long 16 0 0 {} {} x {}]} {>

emit {hashsize %d,}
<}

if {[N long 20 0 0 {} {} x {}]} {>

emit {stblsize %d}
<}

<}
} {
if {[S string 0 0 {} {} eq DAF/SPK]} {>

emit {NASA SPICE file (binary format)}
<}
} {
if {[S string 0 0 {} {} eq DAFETF\ NAIF\ DAF\ ENCODED]} {>

emit {NASA SPICE file (transfer format)}
<}
} {
if {[S string 0 0 {} {} eq Bagpipe]} {>

emit Bagpipe

if {[S string 8 0 {} {} eq Reader]} {>

emit Reader

	if {[S string 15 0 {} {} > \0]} {>

	emit {(version %.3s)}
<}

<}

if {[S string 8 0 {} {} eq Music\ Writer]} {>

emit {Music Writer}

	if {[S string 20 0 {} {} eq :]} {>

		if {[S string 21 0 {} {} > \0]} {>

		emit {(version %.3s)}
<}

<}

	if {[S string 21 0 {} {} eq Gold]} {>

	emit Gold

		if {[S string 25 0 {} {} eq :]} {>

			if {[S string 26 0 {} {} > \0]} {>

			emit {(version %.3s)}
<}

<}

<}

<}

<}
} {
if {[S string 8 0 {} {} eq .FIT]} {>

emit {FIT Map data}

if {[N byte 15 0 0 {} {} == 0]} {>

	if {[N belong 35 0 0 {} {} x {}]} {>

	emit {\b, unit id %d}
<}

	if {[N lelong 39 0 0 {} {} x {}]} {>

	emit {\b, serial %u}
<}

	if {[N leldate 43 0 0 + 631065600 x {}]} {>

	emit {\b, %s}
<}

	if {[N leshort 47 0 0 {} {} x {}]} {>

	emit {\b, manufacturer %d}
<}

	if {[N leshort 47 0 0 {} {} == 1]} {>

	emit {\b (garmin)}
<}

	if {[N leshort 49 0 0 {} {} x {}]} {>

	emit {\b, product %d}
<}

	if {[N byte 53 0 0 {} {} x {}]} {>

	emit {\b, type %d}
<}

	switch -- [Nv byte 53 0 {} {}] 1 {>;emit {\b (Device)};<} 2 {>;emit {\b (Settings)};<} 3 {>;emit {\b (Sports/Cycling)};<} 4 {>;emit {\b (Activity)};<} 8 {>;emit {\b (Elevations)};<} 10 {>;emit {\b (Totals)};<} 
<

<}

<}
} {
if {[S string 48 0 {} {} eq SymExe]} {>

emit {SymbOS executable}

if {[N byte 54 0 0 {} {} x {}]} {>

emit v%c
<}

if {[N byte 55 0 0 {} {} x {}]} {>

emit {\b.%c}
<}

if {[S string 15 0 {} {} x {}]} {>

emit {\b, name: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq INFOq\0]} {>

emit {SymbOS DOX document}
<}
} {
if {[S string 0 0 {} {} eq SMD1]} {>

emit {SymbOS driver}

if {[N byte 19 0 0 {} {} x {}]} {>

emit {\b, name: %c}
<}

if {[N byte 20 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 21 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 22 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 23 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 24 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 25 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 26 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 27 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 28 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 29 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 30 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 31 0 0 {} {} x {}]} {>

emit {\b%c}
<}

<}
} {
if {[S string 0 0 {} {} eq SymVid]} {>

emit {SymbOS video}

if {[N byte 6 0 0 {} {} x {}]} {>

emit v%c
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {\b.%c}
<}

<}
} {
if {[N lelong 0 0 0 & 4294967294 == 4277009102]} {>

emit Mach-O
U 210 mach-o-be

mime application/x-mach-binary

<}
} {
if {[S string 0 0 b {} eq MGS]} {>

emit {MSX Gigamix MGSDRV3 music file, }

if {[N beshort 6 0 0 {} {} == 3338]} {>

	if {[N byte 3 0 0 {} {} x {}]} {>

	emit {\bv%c}
<}

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {\b.%c}
<}

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

	if {[S string 8 0 {} {} > \0]} {>

	emit {\b, title: %s}
<}

<}

<}
} {
if {[S string 1 0 b {} eq mgs2\ ]} {>

emit {MSX Gigamix MGSDRV2 music file}

if {[N leshort 6 0 0 {} {} == 128]} {>

	if {[N leshort 46 0 0 {} {} == 0]} {>

		if {[S string 48 0 {} {} > \0]} {>

		emit {\b, title: %s}
<}

<}

<}

<}
} {
if {[S string 0 0 b {} eq KSCC]} {>

emit {KSS music file v1.03}

if {[N byte 14 0 0 {} {} == 0]} {>

	switch -- [Nv byte 15 0 & 2] 0 {>;emit {\b, soundchips: AY-3-8910, SCC(+)};<} 2 {>;emit {\b, soundchip(s): SN76489}

		if {[N byte 15 0 0 & 4 == 4]} {>

		emit stereo
<}
;<} 
<

	if {[N byte 15 0 0 & 1 == 1]} {>

	emit {\b, YM2413}
<}

	if {[N byte 15 0 0 & 8 == 8]} {>

	emit {\b, Y8950}
<}

<}

<}
} {
if {[S string 0 0 b {} eq KSSX]} {>

emit {KSS music file v1.20}

if {[N byte 14 0 0 & 239 == 0]} {>

	switch -- [Nv byte 15 0 & 64] 0 {>;emit {\b, 60Hz};<} 64 {>;emit {\b, 50Hz};<} 
<

	switch -- [Nv byte 15 0 & 2] 0 {>;emit {\b, soundchips: AY-3-8910, SCC(+)};<} 2 {>;emit {\b, soundchips: SN76489}

		if {[N byte 15 0 0 & 4 == 4]} {>

		emit stereo
<}
;<} 
<

	if {[N byte 15 0 0 & 1 == 1]} {>

	emit {\b, }

		switch -- [Nv byte 15 0 & 24] 0 {>;emit {\bYM2413};<} 8 {>;emit {\bYM2413, Y8950};<} 24 {>;emit {\bYM2413+Y8950 pseudostereo};<} 
<

<}

	if {[N byte 15 0 0 & 24 == 16]} {>

	emit {\b, Majyutsushi DAC}
<}

<}

<}
} {
if {[S string 0 0 b {} eq MBMS]} {>

if {[N byte 4 0 0 {} {} == 16]} {>

emit {MSX Moonblaster for MoonSound music}
<}

<}
} {
if {[S string 0 0 b {} eq MPK]} {>

emit {MSX Music Player K-kaz song}

if {[N beshort 6 0 0 {} {} == 3338]} {>

	if {[N byte 3 0 0 {} {} x {}]} {>

	emit v%c
<}

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit {\b.%c}
<}

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {\b%c}
<}

<}

<}
} {
if {[N beshort 53 0 0 {} {} == 3338]} {>

if {[N beshort 123 0 0 {} {} == 3338]} {>

	if {[N byte 125 0 0 {} {} == 26]} {>

		if {[N leshort 135 0 0 {} {} == 0]} {>

		emit {MSX OPX Music file}

			switch -- [Nv byte 134 0 {} {}] 0 {>;emit v1.5

				if {[S string 0 0 {} {} > \32]} {>

				emit {\b, title: %s}
<}
;<} 1 {>;emit v2.4

				if {[S string 0 0 {} {} > \32]} {>

				emit {\b, title: %s}
<}
;<} 
<

<}

<}

<}

<}
} {
if {[S string 139 0 b {} eq SCMD]} {>

if {[N leshort 206 0 0 {} {} == 0]} {>

emit {MSX SCMD Music file}

	if {[S string 143 0 {} {} > \0]} {>

	emit {\b, title: %s}
<}

<}

<}
} {
if {[Sx search 0 0 {} 65535 eq \r\n@title]} {>

if {[Sx search [R 0] 0 {} 65535 eq \r\n@m=\[]} {>

emit {MSX SCMD source MML file}
<}

<}
} {
if {[Sx string 0 0 b {} eq MAKI02\ \ ]} {>

emit {Maki-chan image,}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {system ID: %c}
<}

if {[N byte 9 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 10 0 0 {} {} x {}]} {>

emit {\b%c}
<}

if {[N byte 11 0 0 {} {} x {}]} {>

emit {\b%c,}
<}

if {[Sx search 13 0 {} 512 eq \x1A]} {>

	if {[Nx leshort [R 8] 0 0 + 1 x {}]} {>

	emit %dx
<}

	if {[Nx leshort [R 10] 0 0 + 1 x {}]} {>

	emit {\b%d,}
<}

	switch -- [Nvx byte [R 3] 0 & 130] -128 {>;emit {256 colors};<} 0 {>;emit {16 colors};<} 1 {>;emit {8 colors};<} 
<

	switch -- [Nvx byte [R 3] 0 & 4] 4 {>;emit digital;<} 0 {>;emit analog;<} 
<

	if {[Nx byte [R 3] 0 0 & 1 == 1]} {>

	emit {\b, 2:1 dot aspect ratio}
<}

<}

<}
} {
if {[S string 0 0 b {} eq PIC\x1A]} {>

if {[N lelong 4 0 0 {} {} == 0]} {>

emit {Japanese PIC image file}
<}

<}
} {
if {[S string 0 0 b {} eq G9B]} {>

if {[N leshort 1 0 0 {} {} == 11]} {>

	if {[N leshort 3 0 0 {} {} > 10]} {>

		if {[N byte 5 0 0 {} {} > 0]} {>

		emit {MSX G9B image, depth=%d}

			if {[N leshort 8 0 0 {} {} x {}]} {>

			emit {\b, %dx}
<}

			if {[N leshort 10 0 0 {} {} x {}]} {>

			emit {\b%d}
<}

			if {[N byte 5 0 0 {} {} < 9]} {>

				switch -- [Nv byte 6 0 {} {}] 0 {>;
					if {[N byte 7 0 0 {} {} x {}]} {>

					emit {\b, codec=%d RGB color palettes}
<}
;<} 64 {>;emit {\b, codec=RGB fixed color};<} -128 {>;emit {\b, codec=YJK};<} -64 {>;emit {\b, codec=YUV};<} 
<

<}

			if {[N byte 5 0 0 {} {} > 8]} {>

			emit {codec=RGB fixed color}
<}

			switch -- [Nv byte 12 0 {} {}] 0 {>;emit {\b, raw};<} 1 {>;emit {\b, bitbuster compression};<} 
<

<}

<}

<}

<}
} {
if {[S string 0 0 b {} eq AB]} {>

switch -- [Nv leshort 2 0 {} {}] 16 {>;emit {MSX ROM}

	if {[N leshort 2 0 0 {} {} x {}]} {>

	emit {\b, init=0x%4x}
<}

	if {[N leshort 4 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%4x}
<}

	if {[N leshort 6 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%4x}
<}

	if {[N leshort 8 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%4x}
<}
;<} 16400 {>;emit {MSX ROM}

	if {[N leshort 2 0 0 {} {} x {}]} {>

	emit {\b, init=0x%04x}
<}

	if {[N leshort 4 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%04x}
<}

	if {[N leshort 6 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%04x}
<}

	if {[N leshort 8 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%04x}
<}
;<} -32752 {>;emit {MSX ROM}

	if {[N leshort 2 0 0 {} {} x {}]} {>

	emit {\b, init=0x%04x}
<}

	if {[N leshort 4 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%04x}
<}

	if {[N leshort 6 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%04x}
<}

	if {[N leshort 8 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%04x}
<}
;<} 
<

<}
} {
if {[S string 0 0 b {} eq AB]} {>

if {[N leshort 2 0 0 {} {} > 10]} {>

	if {[S string 10 0 {} {} eq \0\0\0\0\0\0]} {>

	emit {MSX ROM}

		if {[S string 16 0 {} {} eq YZ\0\0\0\0]} {>

		emit {Konami Game Master 2 MSX ROM}
<}

		if {[S string 16 0 {} {} eq CD]} {>

		emit {\b, Konami RC-}

			if {[N byte 18 0 0 {} {} x {}]} {>

			emit {\b%d}
<}

			if {[N byte 19 0 0 / 16 x {}]} {>

			emit {\b%d}
<}

			if {[N byte 19 0 0 & 15 x {}]} {>

			emit {\b%d}
<}

<}

		if {[S string 16 0 {} {} eq EF]} {>

		emit {\b, Konami RC-}

			if {[N byte 18 0 0 {} {} x {}]} {>

			emit {\b%d}
<}

			if {[N byte 19 0 0 / 16 x {}]} {>

			emit {\b%d}
<}

			if {[N byte 19 0 0 & 15 x {}]} {>

			emit {\b%d}
<}

<}

		if {[N leshort 2 0 0 {} {} x {}]} {>

		emit {\b, init=0x%04x}
<}

		if {[N leshort 4 0 0 {} {} > 0]} {>

		emit {\b, stat=0x%04x}
<}

		if {[N leshort 6 0 0 {} {} > 0]} {>

		emit {\b, dev=0x%04x}
<}

		if {[N leshort 8 0 0 {} {} > 0]} {>

		emit {\b, bas=0x%04x}
<}

<}

<}

if {[N leshort 2 0 0 {} {} == 0]} {>

	if {[N leshort 4 0 0 {} {} == 0]} {>

		if {[N leshort 6 0 0 {} {} == 0]} {>

			if {[N leshort 8 0 0 {} {} > 0]} {>

			emit {MSX BASIC program in ROM, bas=0x%04x}
<}

<}

<}

<}

<}
} {
if {[S string 16384 0 b {} eq AB]} {>

if {[N leshort 16386 0 0 {} {} > 16400]} {>

	if {[S string 16394 0 {} {} eq \0\0\0\0\0\0]} {>

	emit {MSX MegaROM with nonstandard page order}
<}

	if {[N leshort 16386 0 0 {} {} x {}]} {>

	emit {\b, init=0x%04x}
<}

	if {[N leshort 16388 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%04x}
<}

	if {[N leshort 16390 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%04x}
<}

	if {[N leshort 16392 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%04x}
<}

<}

<}
} {
if {[S string 32768 0 b {} eq AB]} {>

if {[N leshort 32770 0 0 {} {} > 16400]} {>

	if {[S string 32778 0 {} {} eq \0\0\0\0\0\0]} {>

	emit {MSX MegaROM with nonstandard page order}
<}

	if {[N leshort 32770 0 0 {} {} x {}]} {>

	emit {\b, init=0x%04x}
<}

	if {[N leshort 32772 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%04x}
<}

	if {[N leshort 32774 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%04x}
<}

	if {[N leshort 32776 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%04x}
<}

<}

<}
} {
if {[S string 245760 0 {} {} eq AB]} {>

if {[S string 245768 0 b {} eq \0\0\0\0\0\0\0\0]} {>

emit {MSX MegaROM with nonstandard page order}

	if {[N leshort 245762 0 0 {} {} x {}]} {>

	emit {\b, init=0x%04x}
<}

	if {[N leshort 245764 0 0 {} {} > 0]} {>

	emit {\b, stat=0x%04x}
<}

	if {[N leshort 245766 0 0 {} {} > 0]} {>

	emit {\b, dev=0x%04x}
<}

	if {[N leshort 245768 0 0 {} {} > 0]} {>

	emit {\b, bas=0x%04x}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \x1F\xA6\xDE\xBA\xCC\x13\x7D\x74]} {>

emit {MSX cassette archive}
<}
} {
if {[S string 0 0 {} {} eq ExecROM\ patchfile\x1A]} {>

emit {MSX ExecROM patchfile}

if {[N byte 18 0 0 / 16 x {}]} {>

emit v%d
<}

if {[N byte 18 0 0 & 15 x {}]} {>

emit {\b.%d}
<}

if {[N byte 19 0 0 {} {} x {}]} {>

emit {\b, contains %d patches}
<}

<}
} {
if {[S string 0 0 t {} eq /1\ :pserver:]} {>

emit {cvs password text file}
<}
} {
if {[S string 0 0 {} {} eq \#\ v2\ git\ bundle\n]} {>

emit {Git bundle}
<}
} {
if {[S string 0 0 {} {} eq PACK\0]} {>

emit {Git pack}

if {[N belong 4 0 0 {} {} > 0]} {>

emit {\b, version %d}

	if {[N belong 8 0 0 {} {} > 0]} {>

	emit {\b, %d objects}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \377tOc]} {>

emit {Git pack index}

if {[N belong 4 0 0 {} {} == 2]} {>

emit {\b, version 2}
<}

<}
} {
if {[S string 0 0 {} {} eq DIRC]} {>

emit {Git index}

if {[N belong 4 0 0 {} {} > 0]} {>

emit {\b, version %d}

	if {[N belong 8 0 0 {} {} > 0]} {>

	emit {\b, %d entries}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq HG10]} {>

emit {Mercurial bundle,}

if {[S string 4 0 {} {} eq UN]} {>

emit uncompressed
<}

if {[S string 4 0 {} {} eq BZ]} {>

emit {bzip2 compressed}
<}

<}
} {
if {[S string 0 0 {} {} eq SVN-fs-dump-format-version:]} {>

emit {Subversion dumpfile}

if {[S string 28 0 {} {} > \0]} {>

emit {(version: %s)}
<}

<}
} {
if {[S string 0 0 {} {} eq \#\ Bazaar\ revision\ bundle\ v]} {>

emit {Bazaar Bundle}
<}
} {
if {[S string 0 0 {} {} eq \#\ Bazaar\ merge\ directive\ format]} {>

emit {Bazaar merge directive}
<}
} {
if {[S string 0 0 {} {} eq Bitmapfile]} {>

emit {HP Bitmapfile}
<}
} {
if {[S string 0 0 {} {} eq IMGfile]} {>

emit {CIS 	compimg HP Bitmapfile}
<}
} {
if {[S string 0 0 {} {} eq msgcat01]} {>

emit {HP NLS message catalog,}

if {[N long 8 0 0 {} {} > 0]} {>

emit {%d messages}
<}

<}
} {
if {[S string 0 0 {} {} eq HPHP]} {>

emit HP

if {[S string 4 0 {} {} eq 48]} {>

emit {48 binary}
<}

if {[S string 4 0 {} {} eq 49]} {>

emit {49 binary}
<}

if {[N byte 7 0 0 {} {} > 64]} {>

emit {- Rev %c}
<}

switch -- [Nv leshort 8 0 {} {}] 10513 {>;emit (ADR);<} 10547 {>;emit (REAL);<} 10581 {>;emit (LREAL);<} 10615 {>;emit (COMPLX);<} 10653 {>;emit (LCOMPLX);<} 10687 {>;emit (CHAR);<} 10728 {>;emit (ARRAY);<} 10762 {>;emit (LNKARRAY);<} 10796 {>;emit (STRING);<} 10830 {>;emit (HXS);<} 10868 {>;emit (LIST);<} 10902 {>;emit (DIR);<} 10936 {>;emit (ALG);<} 10970 {>;emit (UNIT);<} 11004 {>;emit (TAGGED);<} 11038 {>;emit (GROB);<} 11072 {>;emit (LIB);<} 11106 {>;emit (BACKUP);<} 11144 {>;emit (LIBDATA);<} 11677 {>;emit (PROG);<} 11724 {>;emit (CODE);<} 11848 {>;emit (GNAME);<} 11885 {>;emit (LNAME);<} 11922 {>;emit (XLIB);<} 
<

<}
} {
if {[S string 0 0 {} {} eq %%HP:]} {>

emit {HP text}

if {[S string 6 0 {} {} eq T(0)]} {>

emit {- T(0)}
<}

if {[S string 6 0 {} {} eq T(1)]} {>

emit {- T(1)}
<}

if {[S string 6 0 {} {} eq T(2)]} {>

emit {- T(2)}
<}

if {[S string 6 0 {} {} eq T(3)]} {>

emit {- T(3)}
<}

if {[S string 10 0 {} {} eq A(D)]} {>

emit A(D)
<}

if {[S string 10 0 {} {} eq A(R)]} {>

emit A(R)
<}

if {[S string 10 0 {} {} eq A(G)]} {>

emit A(G)
<}

if {[S string 14 0 {} {} eq F(.)]} {>

emit {F(.);}
<}

if {[S string 14 0 {} {} eq F(,)]} {>

emit {F(,);}
<}

<}
} {
if {[S string 0 0 {} {} eq HP3]} {>

if {[S string 3 0 {} {} eq 8]} {>

emit {HP 38}
<}

if {[S string 3 0 {} {} eq 9]} {>

emit {HP 39}
<}

if {[S string 4 0 {} {} eq Bin]} {>

emit binary
<}

if {[S string 4 0 {} {} eq Asc]} {>

emit ASCII
<}

if {[S string 7 0 {} {} eq A]} {>

emit {(Directory List)}
<}

if {[S string 7 0 {} {} eq B]} {>

emit (Zaplet)
<}

if {[S string 7 0 {} {} eq C]} {>

emit (Note)
<}

if {[S string 7 0 {} {} eq D]} {>

emit (Program)
<}

if {[S string 7 0 {} {} eq E]} {>

emit (Variable)
<}

if {[S string 7 0 {} {} eq F]} {>

emit (List)
<}

if {[S string 7 0 {} {} eq G]} {>

emit (Matrix)
<}

if {[S string 7 0 {} {} eq H]} {>

emit (Library)
<}

if {[S string 7 0 {} {} eq I]} {>

emit {(Target List)}
<}

if {[S string 7 0 {} {} eq J]} {>

emit {(ASCII Vector specification)}
<}

if {[S string 7 0 {} {} eq K]} {>

emit (wildcard)
<}

<}
} {
if {[S string 0 0 {} {} eq HP3]} {>

if {[S string 3 0 {} {} eq 8]} {>

emit {HP 38}
<}

if {[S string 3 0 {} {} eq 9]} {>

emit {HP 39}
<}

if {[S string 4 0 {} {} eq Bin]} {>

emit binary
<}

if {[S string 4 0 {} {} eq Asc]} {>

emit ASCII
<}

if {[S string 7 0 {} {} eq A]} {>

emit {(Directory List)}
<}

if {[S string 7 0 {} {} eq B]} {>

emit (Zaplet)
<}

if {[S string 7 0 {} {} eq C]} {>

emit (Note)
<}

if {[S string 7 0 {} {} eq D]} {>

emit (Program)
<}

if {[S string 7 0 {} {} eq E]} {>

emit (Variable)
<}

if {[S string 7 0 {} {} eq F]} {>

emit (List)
<}

if {[S string 7 0 {} {} eq G]} {>

emit (Matrix)
<}

if {[S string 7 0 {} {} eq H]} {>

emit (Library)
<}

if {[S string 7 0 {} {} eq I]} {>

emit {(Target List)}
<}

if {[S string 7 0 {} {} eq J]} {>

emit {(ASCII Vector specification)}
<}

if {[S string 7 0 {} {} eq K]} {>

emit (wildcard)
<}

<}
} {
if {[S string 16 0 {} {} eq HP-UX]} {>

if {[N belong 0 0 0 {} {} == 2]} {>

	if {[N belong 12 0 0 {} {} == 60]} {>

		switch -- [Nv belong 76 0 {} {}] 256 {>;
			if {[N belong 88 0 0 {} {} == 68]} {>

				if {[N belong 160 0 0 {} {} == 1]} {>

					if {[N belong 172 0 0 {} {} == 4]} {>

						if {[N belong 176 0 0 {} {} == 1]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 144 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}
;<} 1 {>;
			if {[N belong 88 0 0 {} {} == 4]} {>

				if {[N belong 92 0 0 {} {} == 1]} {>

					if {[N belong 96 0 0 {} {} == 256]} {>

						if {[N belong 108 0 0 {} {} == 68]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 164 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}
;<} 
<

<}

<}

<}
} {
if {[S string 36 0 {} {} eq HP-UX]} {>

if {[N belong 0 0 0 {} {} == 1]} {>

	if {[N belong 12 0 0 {} {} == 4]} {>

		if {[N belong 16 0 0 {} {} == 1]} {>

			if {[N belong 20 0 0 {} {} == 2]} {>

				if {[N belong 32 0 0 {} {} == 60]} {>

					if {[N belong 96 0 0 {} {} == 256]} {>

						if {[N belong 108 0 0 {} {} == 68]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 164 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 100 0 {} {} eq HP-UX]} {>

if {[N belong 0 0 0 {} {} == 256]} {>

	if {[N belong 12 0 0 {} {} == 68]} {>

		if {[N belong 84 0 0 {} {} == 2]} {>

			if {[N belong 96 0 0 {} {} == 60]} {>

				if {[N belong 160 0 0 {} {} == 1]} {>

					if {[N belong 172 0 0 {} {} == 4]} {>

						if {[N belong 176 0 0 {} {} == 1]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 68 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 120 0 {} {} eq HP-UX]} {>

switch -- [Nv belong 0 0 {} {}] 1 {>;
	if {[N belong 12 0 0 {} {} == 4]} {>

		if {[N belong 16 0 0 {} {} == 1]} {>

			if {[N belong 20 0 0 {} {} == 256]} {>

				if {[N belong 32 0 0 {} {} == 68]} {>

					if {[N belong 104 0 0 {} {} == 2]} {>

						if {[N belong 116 0 0 {} {} == 60]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 88 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}

<}

<}
;<} 256 {>;
	if {[N belong 12 0 0 {} {} == 68]} {>

		if {[N belong 84 0 0 {} {} == 1]} {>

			if {[N belong 96 0 0 {} {} == 4]} {>

				if {[N belong 100 0 0 {} {} == 1]} {>

					if {[N belong 104 0 0 {} {} == 2]} {>

						if {[N belong 116 0 0 {} {} == 44]} {>

							if {[N belong 180 0 0 {} {} == 4]} {>

							emit {core file}

								if {[S string 68 0 {} {} > \0]} {>

								emit {from '%s'}
<}

								switch -- [Nv belong 196 0 {} {}] 3 {>;emit {- received SIGQUIT};<} 4 {>;emit {- received SIGILL};<} 5 {>;emit {- received SIGTRAP};<} 6 {>;emit {- received SIGABRT};<} 7 {>;emit {- received SIGEMT};<} 8 {>;emit {- received SIGFPE};<} 10 {>;emit {- received SIGBUS};<} 11 {>;emit {- received SIGSEGV};<} 12 {>;emit {- received SIGSYS};<} 33 {>;emit {- received SIGXCPU};<} 34 {>;emit {- received SIGXFSZ};<} 
<

<}

<}

<}

<}

<}

<}

<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq GSTIm\0\0]} {>

emit {GNU SmallTalk}

switch -- [Nv byte 7 0 & 1] 0 {>;emit {LE image version}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit %d.
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b%d.}
<}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {\b%d}
<}
;<} 1 {>;emit {BE image version}

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit %d.
<}

	if {[N byte 9 0 0 {} {} x {}]} {>

	emit {\b%d.}
<}

	if {[N byte 10 0 0 {} {} x {}]} {>

	emit {\b%d}
<}
;<} 
<

<}
} {
if {[S regex 0 0 {} {} eq ^dnl\ ]} {>

emit {M4 macro processor script text}
mime text/x-m4

<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ CERTIFICATE-----]} {>

emit {PEM certificate}
<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ CERTIFICATE\ REQ]} {>

emit {PEM certificate request}
<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ RSA\ PRIVATE]} {>

emit {PEM RSA private key}
<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ DSA\ PRIVATE]} {>

emit {PEM DSA private key}
<}
} {
if {[S string 0 0 {} {} eq -----BEGIN\ EC\ PRIVATE]} {>

emit {PEM EC private key}
<}
} {
if {[S string 257 0 {} {} eq ustar\0]} {>

emit {POSIX tar archive}
mime application/x-tar # encoding: posix

<}
} {
if {[S string 257 0 {} {} eq ustar\040\040\0]} {>

emit {GNU tar archive}
mime application/x-tar # encoding: gnu

<}
} {
if {[Sx string 0 0 {} {} eq GNU\ tar-]} {>

emit {GNU tar incremental snapshot data}

if {[Sx regex [R 0] 0 {} {} eq \[0-9\].\[0-9\]+-\[0-9\]+]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq 070707]} {>

emit {ASCII cpio archive (pre-SVR4 or odc)}
<}
} {
if {[S string 0 0 {} {} eq 070701]} {>

emit {ASCII cpio archive (SVR4 with no CRC)}
<}
} {
if {[S string 0 0 {} {} eq 070702]} {>

emit {ASCII cpio archive (SVR4 with CRC)}
<}
} {
if {[S string 0 0 {} {} eq <ar>]} {>

emit {System V Release 1 ar archive}
mime application/x-archive

<}
} {
if {[S string 0 0 {} {} eq !<arch>\ndebian]} {>

if {[S string 8 0 {} {} eq debian-split]} {>

emit {part of multipart Debian package}
mime application/vnd.debian.binary-package

<}

if {[S string 8 0 {} {} eq debian-binary]} {>

emit {Debian binary package}
mime application/vnd.debian.binary-package

<}

if {[S string 8 0 {} {} ne debian]} {>

<}

if {[S string 68 0 {} {} > \0]} {>

emit {(format %s)}
<}

<}
} {
if {[S string 0 0 {} {} eq !<arch>\n__________E]} {>

emit {MIPS archive}

if {[S string 20 0 {} {} eq U]} {>

emit {with MIPS Ucode members}
<}

if {[S string 21 0 {} {} eq L]} {>

emit {with MIPSEL members}
<}

if {[S string 21 0 {} {} eq B]} {>

emit {with MIPSEB members}
<}

if {[S string 19 0 {} {} eq L]} {>

emit {and an EL hash table}
<}

if {[S string 19 0 {} {} eq B]} {>

emit {and an EB hash table}
<}

if {[S string 22 0 {} {} eq X]} {>

emit {-- out of date}
<}

mime application/x-archive

<}
} {
if {[S search 0 0 {} 1 eq -h-]} {>

emit {Software Tools format archive text}
<}
} {
if {[S string 0 0 {} {} eq !<arch>]} {>

emit {current ar archive}

if {[S string 8 0 {} {} eq __.SYMDEF]} {>

emit {random library}
<}

if {[S string 68 0 {} {} eq __.SYMDEF\ SORTED]} {>

emit {random library}
<}

mime application/x-archive

<}
} {
if {[S string 0 0 {} {} eq !<thin>\n]} {>

emit {thin archive with}

switch -- [Nv belong 68 0 {} {}] 0 {>;emit {no symbol entries};<} 1 {>;emit {%d symbol entry};<} 
<

if {[N belong 68 0 0 {} {} > 1]} {>

emit {%d symbol entries}
<}

<}
} {
switch -- [Nv lelong 0 0 & 2155937791] 2074 {>;emit {ARC archive data, dynamic LZW}
mime application/x-arc
;<} 2330 {>;emit {ARC archive data, squashed}
mime application/x-arc
;<} 538 {>;emit {ARC archive data, uncompressed}
mime application/x-arc
;<} 794 {>;emit {ARC archive data, packed}
mime application/x-arc
;<} 1050 {>;emit {ARC archive data, squeezed}
mime application/x-arc
;<} 1562 {>;emit {ARC archive data, crunched}
mime application/x-arc
;<} 2586 {>;emit {PAK archive data}
mime application/x-arc
;<} 5146 {>;emit {ARC+ archive data}
mime application/x-arc
;<} 18458 {>;emit {HYP archive data}
mime application/x-arc
;<} 4612 {>;emit {gfxboot compiled html help file};<} 
<
} {
if {[S string 0 0 {} {} eq \032archive]} {>

emit {RISC OS archive (ArcFS format)}
<}
} {
if {[S string 0 0 {} {} eq Archive\000]} {>

emit {RISC OS archive (ArcFS format)}
<}
} {
if {[S string 0 0 {} {} eq CRUSH]} {>

emit {Crush archive data}
<}
} {
if {[S string 0 0 {} {} eq HLSQZ]} {>

emit {Squeeze It archive data}
<}
} {
if {[S string 0 0 {} {} eq SQWEZ]} {>

emit {SQWEZ archive data}
<}
} {
if {[S string 0 0 {} {} eq HPAK]} {>

emit {HPack archive data}
<}
} {
if {[S string 0 0 {} {} eq \x91\x33HF]} {>

emit {HAP archive data}
<}
} {
if {[S string 0 0 {} {} eq MDmd]} {>

emit {MDCD archive data}
<}
} {
if {[S string 0 0 {} {} eq LIM\x1a]} {>

emit {LIM archive data}
<}
} {
if {[S string 3 0 {} {} eq LH5]} {>

emit {SAR archive data}
<}
} {
if {[S string 0 0 {} {} eq \212\3SB\020\0]} {>

emit {BSArc/BS2 archive data}
<}
} {
if {[S string 0 0 {} {} eq BSA\0]} {>

emit {BSArc archive data}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[S string 2 0 {} {} eq -ah]} {>

emit {MAR archive data}
<}
} {
if {[S string 0 0 {} {} eq JRchive]} {>

emit {JRC archive data}
<}
} {
if {[S string 0 0 {} {} eq DS\0]} {>

emit {Quantum archive data}
<}
} {
if {[S string 0 0 {} {} eq PK\3\6]} {>

emit {ReSOF archive data}
<}
} {
if {[S string 0 0 {} {} eq 7\4]} {>

emit {QuArk archive data}
<}
} {
if {[S string 14 0 {} {} eq YC]} {>

emit {YAC archive data}
<}
} {
if {[S string 0 0 {} {} eq X1]} {>

emit {X1 archive data}
<}
} {
if {[S string 0 0 {} {} eq XhDr]} {>

emit {X1 archive data}
<}
} {
if {[N belong 0 0 0 & 4294959104 == 1996431360]} {>

emit {CDC Codec archive data}
<}
} {
if {[S string 0 0 {} {} eq \xad6\"]} {>

emit {AMGC archive data}
<}
} {
if {[S string 0 0 {} {} eq N\xc3\xb5F\xc3\xa9lx\xc3\xa5]} {>

emit {NuLIB archive data}
<}
} {
if {[S string 0 0 {} {} eq LEOLZW]} {>

emit {PAKLeo archive data}
<}
} {
if {[S string 0 0 {} {} eq SChF]} {>

emit {ChArc archive data}
<}
} {
if {[S string 0 0 {} {} eq PSA]} {>

emit {PSA archive data}
<}
} {
if {[S string 0 0 {} {} eq DSIGDCC]} {>

emit {CrossePAC archive data}
<}
} {
if {[S string 0 0 {} {} eq \x1f\x9f\x4a\x10\x0a]} {>

emit {Freeze archive data}
<}
} {
if {[S string 0 0 {} {} eq \xc2\xa8MP\xc2\xa8]} {>

emit {KBoom archive data}
<}
} {
if {[S string 0 0 {} {} eq \x76\xff]} {>

emit {NSQ archive data}
<}
} {
if {[S string 0 0 {} {} eq Dirk\ Paehl]} {>

emit {DPA archive data}
<}
} {
if {[S string 0 0 {} {} eq \0\6]} {>

if {[S search 12 0 {} 261 eq DESIGN]} {>

<}

if {[S default 12 0 {} {} x {}]} {>

emit {TTComp archive, binary, 4K dictionary}
<}

<}
} {
if {[S string 0 0 {} {} eq ESP]} {>

emit {ESP archive data}
<}
} {
if {[S string 0 0 {} {} eq \1ZPK\1]} {>

emit {ZPack archive data}
<}
} {
if {[S string 0 0 {} {} eq \xbc\x40]} {>

emit {Sky archive data}
<}
} {
if {[S string 0 0 {} {} eq UFA]} {>

emit {UFA archive data}
<}
} {
if {[S string 0 0 {} {} eq -H2O]} {>

emit {DRY archive data}
<}
} {
if {[S string 0 0 {} {} eq FOXSQZ]} {>

emit {FoxSQZ archive data}
<}
} {
if {[S string 0 0 {} {} eq ,AR7]} {>

emit {AR7 archive data}
<}
} {
if {[S string 0 0 {} {} eq PPMZ]} {>

emit {PPMZ archive data}
<}
} {
if {[S string 4 0 {} {} eq \x88\xf0\x27]} {>

emit {MS Compress archive data}

if {[S string 9 0 {} {} eq \0]} {>

	if {[S string 0 0 {} {} eq KWAJ]} {>

		if {[S string 7 0 {} {} eq \321\003]} {>

		emit {MS Compress archive data}

			if {[N long 14 0 0 {} {} > 0]} {>

			emit {\b, original size: %d bytes}
<}

			if {[N byte 18 0 0 {} {} > 101]} {>

				if {[S string 18 0 {} {} x {}]} {>

				emit {\b, was %.8s}
<}

				if {[S string [I 10 byte 0 - 0 4] 0 {} {} x {}]} {>

				emit {\b.%.3s}
<}

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq MP3\x1a]} {>

emit {MP3-Archiver archive data}
<}
} {
if {[S string 0 0 {} {} eq OZ\xc3\x9d]} {>

emit {ZET archive data}
<}
} {
if {[S string 0 0 {} {} eq \x65\x5d\x13\x8c\x08\x01\x03\x00]} {>

emit {TSComp archive data}
<}
} {
if {[S string 0 0 {} {} eq gW\4\1]} {>

emit {ARQ archive data}
<}
} {
if {[S string 3 0 {} {} eq OctSqu]} {>

emit {Squash archive data}
<}
} {
if {[S string 0 0 {} {} eq \5\1\1\0]} {>

emit {Terse archive data}
<}
} {
if {[S string 0 0 {} {} eq \x01\x08\x0b\x08\xef\x00\x9e\x32\x30\x36\x31]} {>

emit {PUCrunch archive data}
<}
} {
if {[S string 0 0 {} {} eq UHA]} {>

emit {UHarc archive data}
<}
} {
if {[S string 0 0 {} {} eq \2AB]} {>

emit {ABComp archive data}
<}
} {
if {[S string 0 0 {} {} eq \3AB2]} {>

emit {ABComp archive data}
<}
} {
if {[S string 0 0 {} {} eq CO\0]} {>

emit {CMP archive data}
<}
} {
if {[S string 0 0 {} {} eq \x93\xb9\x06]} {>

emit {Splint archive data}
<}
} {
if {[S string 0 0 {} {} eq \x13\x5d\x65\x8c]} {>

emit {InstallShield Z archive Data}
<}
} {
if {[S string 1 0 {} {} eq GTH]} {>

emit {Gather archive data}
<}
} {
if {[S string 0 0 {} {} eq BOA]} {>

emit {BOA archive data}
<}
} {
if {[S string 0 0 {} {} eq ULEB\xa]} {>

emit {RAX archive data}
<}
} {
if {[S string 0 0 {} {} eq ULEB\0]} {>

emit {Xtreme archive data}
<}
} {
if {[S string 0 0 {} {} eq @\xc3\xa2\1\0]} {>

emit {Pack Magic archive data}
<}
} {
if {[N belong 0 0 0 & 4278190079 == 436421733]} {>

emit {BTS archive data}
<}
} {
if {[S string 0 0 {} {} eq Ora\ ]} {>

emit {ELI 5750 archive data}
<}
} {
if {[S string 0 0 {} {} eq \x1aFC\x1a]} {>

emit {QFC archive data}
<}
} {
if {[S string 0 0 {} {} eq \x1aQF\x1a]} {>

emit {QFC archive data}
<}
} {
if {[S string 0 0 {} {} eq RNC]} {>

emit {PRO-PACK archive data}
<}
} {
if {[S string 0 0 {} {} eq 777]} {>

emit {777 archive data}
<}
} {
if {[S string 0 0 {} {} eq sTaC]} {>

emit {LZS221 archive data}
<}
} {
if {[S string 0 0 {} {} eq HPA]} {>

emit {HPA archive data}
<}
} {
if {[S string 0 0 {} {} eq LG]} {>

emit {Arhangel archive data}
<}
} {
if {[S string 0 0 {} {} eq 0123456789012345BZh]} {>

emit {EXP1 archive data}
<}
} {
if {[S string 0 0 {} {} eq IMP\xa]} {>

emit {IMP archive data}
<}
} {
if {[S string 0 0 {} {} eq \x00\x9E\x6E\x72\x76\xFF]} {>

emit {NRV archive data}
<}
} {
if {[S string 0 0 {} {} eq \x73\xb2\x90\xf4]} {>

emit {Squish archive data}
<}
} {
if {[S string 0 0 {} {} eq PHILIPP]} {>

emit {Par archive data}
<}
} {
if {[S string 0 0 {} {} eq PAR]} {>

emit {Par archive data}
<}
} {
if {[S string 0 0 {} {} eq UB]} {>

emit {HIT archive data}
<}
} {
if {[N belong 0 0 0 & 4294963200 == 1396846592]} {>

emit {SBX archive data}
<}
} {
if {[S string 0 0 {} {} eq NSK]} {>

emit {NaShrink archive data}
<}
} {
if {[S string 0 0 {} {} eq \#\ CAR\ archive\ header]} {>

emit {SAPCAR archive data}
<}
} {
if {[S string 0 0 {} {} eq CAR\ 2.00RG]} {>

emit {SAPCAR archive data}
<}
} {
if {[S string 0 0 {} {} eq DST]} {>

emit {Disintegrator archive data}
<}
} {
if {[S string 0 0 {} {} eq ASD]} {>

emit {ASD archive data}
<}
} {
if {[S string 0 0 {} {} eq ISc(]} {>

emit {InstallShield CAB}
<}
} {
if {[S string 0 0 {} {} eq T4\x1a]} {>

emit {TOP4 archive data}
<}
} {
if {[S string 0 0 {} {} eq BH\5\7]} {>

emit {BlakHole archive data}
<}
} {
if {[S string 0 0 {} {} eq BIX0]} {>

emit {BIX archive data}
<}
} {
if {[S string 0 0 {} {} eq ChfLZ]} {>

emit {ChiefLZA archive data}
<}
} {
if {[S string 0 0 {} {} eq Blink]} {>

emit {Blink archive data}
<}
} {
if {[S string 0 0 {} {} eq \xda\xfa]} {>

emit {Logitech Compress archive data}
<}
} {
if {[S string 1 0 {} {} eq (C)\ STEPANYUK]} {>

emit {ARS-Sfx archive data}
<}
} {
if {[S string 0 0 {} {} eq AKT32]} {>

emit {AKT32 archive data}
<}
} {
if {[S string 0 0 {} {} eq AKT]} {>

emit {AKT archive data}
<}
} {
if {[S string 0 0 {} {} eq MSTSM]} {>

emit {NPack archive data}
<}
} {
if {[S string 0 0 {} {} eq \0\x50\0\x14]} {>

emit {PFT archive data}
<}
} {
if {[S string 0 0 {} {} eq SEM]} {>

emit {SemOne archive data}
<}
} {
if {[S string 0 0 {} {} eq \x8f\xaf\xac\x84]} {>

emit {PPMD archive data}
<}
} {
if {[S string 0 0 {} {} eq FIZ]} {>

emit {FIZ archive data}
<}
} {
if {[N belong 0 0 0 & 4294963440 == 1297285120]} {>

emit {MSXiE archive data}
<}
} {
if {[S string 0 0 {} {} eq <DC-]} {>

emit {DC archive data}
<}
} {
if {[S string 0 0 {} {} eq \4TPAC\3]} {>

emit {TPac archive data}
<}
} {
if {[S string 0 0 {} {} eq Ai\1\1\0]} {>

emit {Ai archive data}
<}
} {
if {[S string 0 0 {} {} eq Ai\1\0\0]} {>

emit {Ai archive data}
<}
} {
if {[S string 0 0 {} {} eq Ai\2\0]} {>

emit {Ai32 archive data}
<}
} {
if {[S string 0 0 {} {} eq Ai\2\1]} {>

emit {Ai32 archive data}
<}
} {
if {[S string 0 0 {} {} eq SBC]} {>

emit {SBC archive data}
<}
} {
if {[S string 0 0 {} {} eq YBS]} {>

emit {Ybs archive data}
<}
} {
if {[S string 0 0 {} {} eq \x9e\0\0]} {>

emit {DitPack archive data}
<}
} {
if {[S string 0 0 {} {} eq DMS!]} {>

emit {DMS archive data}
<}
} {
if {[S string 0 0 {} {} eq \x8f\xaf\xac\x8c]} {>

emit {EPC archive data}
<}
} {
if {[S string 0 0 {} {} eq VS\x1a]} {>

emit {VSARC archive data}
<}
} {
if {[S string 0 0 {} {} eq PDZ]} {>

emit {PDZ archive data}
<}
} {
if {[S string 0 0 {} {} eq rdqx]} {>

emit {ReDuq archive data}
<}
} {
if {[S string 0 0 {} {} eq GCAX]} {>

emit {GCA archive data}
<}
} {
if {[S string 0 0 {} {} eq pN]} {>

emit {PPMN archive data}
<}
} {
if {[S string 3 0 {} {} eq WINIMAGE]} {>

emit {WinImage archive data}
<}
} {
if {[S string 0 0 {} {} eq CMP0CMP]} {>

emit {Compressia archive data}
<}
} {
if {[S string 0 0 {} {} eq UHB]} {>

emit {UHBC archive data}
<}
} {
if {[S string 0 0 {} {} eq \x61\x5C\x04\x05]} {>

emit {WinHKI archive data}
<}
} {
if {[S string 0 0 {} {} eq WWP]} {>

emit {WWPack archive data}
<}
} {
if {[S string 0 0 {} {} eq \xffBSG]} {>

emit {BSN archive data}
<}
} {
if {[S string 1 0 {} {} eq \xffBSG]} {>

emit {BSN archive data}
<}
} {
if {[S string 3 0 {} {} eq \xffBSG]} {>

emit {BSN archive data}
<}
} {
if {[S string 1 0 {} {} eq \0\xae\2]} {>

emit {BSN archive data}
<}
} {
if {[S string 1 0 {} {} eq \0\xae\3]} {>

emit {BSN archive data}
<}
} {
if {[S string 1 0 {} {} eq \0\xae\7]} {>

emit {BSN archive data}
<}
} {
if {[S string 0 0 {} {} eq \x33\x18]} {>

emit {AIN archive data}
<}
} {
if {[S string 0 0 {} {} eq \x33\x17]} {>

emit {AIN archive data}
<}
} {
if {[S string 0 0 {} {} eq SZ\x0a\4]} {>

emit {SZip archive data}
<}
} {
if {[S string 0 0 {} {} eq jm]} {>

if {[S string 2 0 {} {} eq \x2\x4]} {>

emit {Xpack DiskImage archive data}
<}

<}
} {
if {[S string 0 0 {} {} eq xpa]} {>

emit XPA

if {[S string 0 0 {} {} eq xpa\0\1]} {>

emit {\b32 archive data}
<}

if {[N beshort 3 0 0 {} {} != 1]} {>

emit {\bck archive data}
<}

ext xpa

<}
} {
if {[S string 0 0 {} {} eq \xcd\ jm]} {>

emit {Xpack single archive data}
ext xpa

<}
} {
if {[S string 0 0 {} {} eq DZ]} {>

emit {Dzip archive data}

if {[N byte 2 0 0 {} {} x {}]} {>

emit {\b, version %i}
<}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {\b.%i}
<}

<}
} {
if {[S string 0 0 {} {} eq ZZ\ \0\0]} {>

emit {ZZip archive data}
<}
} {
if {[S string 0 0 {} {} eq ZZ0]} {>

emit {ZZip archive data}
<}
} {
if {[S string 0 0 {} {} eq \xaa\x40\x5f\x77\x1f\xe5\x82\x0d]} {>

emit {PAQ archive data}
<}
} {
if {[S string 0 0 {} {} eq PAQ]} {>

emit {PAQ archive data}

if {[N byte 3 0 0 & 240 == 48]} {>

	if {[N byte 3 0 0 {} {} x {}]} {>

	emit (v%c)
<}

<}

<}
} {
if {[S string 14 0 {} {} eq \x1aJar\x1b]} {>

emit {JAR (ARJ Software, Inc.) archive data}
<}
} {
if {[S string 0 0 {} {} eq JARCS]} {>

emit {JAR (ARJ Software, Inc.) archive data}
<}
} {
switch -- [Nv leshort 2 0 {} {}] -5536 {>;emit {ARJ archive data};<} 14336 {>;emit {BS image,}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {Version %d,}
<}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {Quantization %d,}
<}

if {[N leshort 0 0 0 {} {} x {}]} {>

emit {(Decompresses to %d words)}
<}
;<} 
<
} {
if {[N belong 0 0 0 & 4294902012 == 1212219392]} {>

emit {HA archive data}

if {[N leshort 2 0 0 {} {} == 1]} {>

emit {1 file,}
<}

if {[N leshort 2 0 0 {} {} > 1]} {>

emit {%u files,}
<}

switch -- [Nv byte 4 0 & 15] 0 {>;emit {first is type CPY};<} 1 {>;emit {first is type ASC};<} 2 {>;emit {first is type HSC};<} 14 {>;emit {first is type DIR};<} 15 {>;emit {first is type SPECIAL};<} 
<

<}
} {
if {[S string 0 0 {} {} eq HPAK]} {>

emit {HPACK archive data}
<}
} {
if {[S string 0 0 {} {} eq \351,\001JAM\ ]} {>

emit {JAM archive,}

if {[S string 7 0 {} {} > \0]} {>

emit {version %.4s}
<}

if {[N byte 38 0 0 {} {} == 39]} {>

emit -

	if {[S string 43 0 {} {} > \0]} {>

	emit {label %.11s,}
<}

	if {[N lelong 39 0 0 {} {} x {}]} {>

	emit {serial %08x,}
<}

	if {[S string 54 0 {} {} > \0]} {>

	emit {fstype %.8s}
<}

<}

<}
} {
if {[S string 2 0 {} {} eq -lh0-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh1-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz2-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz3-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz4-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz5-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz7-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lz8-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lzs-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lhd-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh2-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh3-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh4-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh5-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh6-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh7-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh8-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lh9-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lha-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lhb-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lhc-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lhe-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lhx-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -lZ]} {>

emit {PUT archive data}
<}
} {
if {[S string 2 0 {} {} eq -sw1-]} {>

emit {Swag archive data}
<}
} {
if {[S string 0 0 {} {} eq Rar!\x1a\7\0]} {>

emit {RAR archive data}

switch -- [Nv byte [I 12 lelong 0 + 0 9] 0 {} {}] 116 {>;U 219 rar-file-header
;<} 122 {>;U 219 rar-file-header
;<} 
<

if {[N byte 9 0 0 {} {} == 115]} {>
U 219 rar-archive-header

<}

mime application/x-rar

ext rar/cbr

<}
} {
if {[S string 0 0 {} {} eq Rar!\x1a\7\1\0]} {>

emit {RAR archive data, v5}
mime application/x-rar

ext rar

<}
} {
if {[S string 0 0 {} {} eq RE\x7e\x5e]} {>

emit {RAR archive data (<v1.5)}
mime application/x-rar

ext rar/cbr

<}
} {
if {[S string 0 0 {} {} eq SQSH]} {>

emit {squished archive data (Acorn RISCOS)}
<}
} {
if {[S string 0 0 {} {} eq UC2\x1a]} {>

emit {UC2 archive data}
<}
} {
if {[S string 0 0 {} {} eq PK\x07\x08PK\x03\x04]} {>

emit {Zip multi-volume archive data, at least PKZIP v2.50 to extract}
mime application/zip

ext zip/cbz

<}
} {
if {[S string 0 0 {} {} eq PK\005\006]} {>

emit {Zip archive data (empty)}
mime application/zip

ext zip/cbz

<}
} {
if {[S string 0 0 {} {} eq PK\003\004]} {>

if {[S string 26 0 {} {} eq \x8\0\0\0mimetypeapplication/]} {>

	if {[S string 50 0 {} {} eq vnd.kde.]} {>

	emit {KOffice (>=1.2)}

		if {[S string 58 0 {} {} eq karbon]} {>

		emit {Karbon document}
<}

		if {[S string 58 0 {} {} eq kchart]} {>

		emit {KChart document}
<}

		if {[S string 58 0 {} {} eq kformula]} {>

		emit {KFormula document}
<}

		if {[S string 58 0 {} {} eq kivio]} {>

		emit {Kivio document}
<}

		if {[S string 58 0 {} {} eq kontour]} {>

		emit {Kontour document}
<}

		if {[S string 58 0 {} {} eq kpresenter]} {>

		emit {KPresenter document}
<}

		if {[S string 58 0 {} {} eq kspread]} {>

		emit {KSpread document}
<}

		if {[S string 58 0 {} {} eq kword]} {>

		emit {KWord document}
<}

<}

	if {[S string 50 0 {} {} eq vnd.sun.xml.]} {>

	emit {OpenOffice.org 1.x}

		if {[S string 62 0 {} {} eq writer]} {>

		emit Writer

			if {[N byte 68 0 0 {} {} != 46]} {>

			emit document
<}

			if {[S string 68 0 {} {} eq .template]} {>

			emit template
<}

			if {[S string 68 0 {} {} eq .global]} {>

			emit {global document}
<}

<}

		if {[S string 62 0 {} {} eq calc]} {>

		emit Calc

			if {[N byte 66 0 0 {} {} != 46]} {>

			emit spreadsheet
<}

			if {[S string 66 0 {} {} eq .template]} {>

			emit template
<}

<}

		if {[S string 62 0 {} {} eq draw]} {>

		emit Draw

			if {[N byte 66 0 0 {} {} != 46]} {>

			emit document
<}

			if {[S string 66 0 {} {} eq .template]} {>

			emit template
<}

<}

		if {[S string 62 0 {} {} eq impress]} {>

		emit Impress

			if {[N byte 69 0 0 {} {} != 46]} {>

			emit presentation
<}

			if {[S string 69 0 {} {} eq .template]} {>

			emit template
<}

<}

		if {[S string 62 0 {} {} eq math]} {>

		emit {Math document}
<}

		if {[S string 62 0 {} {} eq base]} {>

		emit {Database file}
<}

<}

	if {[S string 50 0 {} {} eq vnd.oasis.opendocument.]} {>

	emit OpenDocument

		if {[S string 73 0 {} {} eq text]} {>

			if {[N byte 77 0 0 {} {} != 45]} {>

			emit Text
			mime application/vnd.oasis.opendocument.text

<}

			if {[S string 77 0 {} {} eq -template]} {>

			emit {Text Template}
			mime application/vnd.oasis.opendocument.text-template

<}

			if {[S string 77 0 {} {} eq -web]} {>

			emit {HTML Document Template}
			mime application/vnd.oasis.opendocument.text-web

<}

			if {[S string 77 0 {} {} eq -master]} {>

			emit {Master Document}
			mime application/vnd.oasis.opendocument.text-master

<}

<}

		if {[S string 73 0 {} {} eq graphics]} {>

			if {[N byte 81 0 0 {} {} != 45]} {>

			emit Drawing
			mime application/vnd.oasis.opendocument.graphics

<}

			if {[S string 81 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.graphics-template

<}

<}

		if {[S string 73 0 {} {} eq presentation]} {>

			if {[N byte 85 0 0 {} {} != 45]} {>

			emit Presentation
			mime application/vnd.oasis.opendocument.presentation

<}

			if {[S string 85 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.presentation-template

<}

<}

		if {[S string 73 0 {} {} eq spreadsheet]} {>

			if {[N byte 84 0 0 {} {} != 45]} {>

			emit Spreadsheet
			mime application/vnd.oasis.opendocument.spreadsheet

<}

			if {[S string 84 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.spreadsheet-template

<}

<}

		if {[S string 73 0 {} {} eq chart]} {>

			if {[N byte 78 0 0 {} {} != 45]} {>

			emit Chart
			mime application/vnd.oasis.opendocument.chart

<}

			if {[S string 78 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.chart-template

<}

<}

		if {[S string 73 0 {} {} eq formula]} {>

			if {[N byte 80 0 0 {} {} != 45]} {>

			emit Formula
			mime application/vnd.oasis.opendocument.formula

<}

			if {[S string 80 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.formula-template

<}

<}

		if {[S string 73 0 {} {} eq database]} {>

		emit Database
		mime application/vnd.oasis.opendocument.database

<}

		if {[S string 73 0 {} {} eq image]} {>

			if {[N byte 78 0 0 {} {} != 45]} {>

			emit Image
			mime application/vnd.oasis.opendocument.image

<}

			if {[S string 78 0 {} {} eq -template]} {>

			emit Template
			mime application/vnd.oasis.opendocument.image-template

<}

<}

<}

	if {[S string 50 0 {} {} eq epub+zip]} {>

	emit {EPUB document}
	mime application/epub+zip

<}

	if {[S string 50 0 {} {} ne epub+zip]} {>

		if {[S string 50 0 {} {} ne vnd.oasis.opendocument.]} {>

			if {[S string 50 0 {} {} ne vnd.sun.xml.]} {>

				if {[S string 50 0 {} {} ne vnd.kde.]} {>

					if {[S regex 38 0 {} {} eq \[!-OQ-~\]+]} {>

					emit {Zip data (MIME type "%s"?)}
					mime application/zip

<}

<}

<}

<}

<}

<}

if {[S string 26 0 {} {} eq \x8\0\0\0mimetype]} {>

	if {[S string 38 0 {} {} ne application/]} {>

		if {[S regex 38 0 {} {} eq \[!-OQ-~\]+]} {>

		emit {Zip data (MIME type "%s"?)}
		mime application/zip

<}

<}

<}

if {[N leshort [I 26 leshort 0 + 0 30] 0 0 {} {} == 51966]} {>

emit {Java archive data (JAR)}
mime application/java-archive

<}

if {[N leshort [I 26 leshort 0 + 0 30] 0 0 {} {} != 51966]} {>

	if {[S string 26 0 {} {} ne \x8\0\0\0mimetype]} {>

		if {[S string 30 0 {} {} eq Payload/]} {>

			if {[S search 38 0 {} 64 eq .app/]} {>

			emit {iOS App}
			mime application/x-ios-app

<}

<}

<}

<}

if {[N leshort [I 26 leshort 0 + 0 30] 0 0 {} {} != 51966]} {>

	if {[S string 26 0 {} {} ne \x8\0\0\0mimetype]} {>

	emit {Zip archive data}

		switch -- [Nv byte 4 0 {} {}] 9 {>;emit {\b, at least v0.9 to extract};<} 10 {>;emit {\b, at least v1.0 to extract};<} 11 {>;emit {\b, at least v1.1 to extract};<} 20 {>;emit {\b, at least v2.0 to extract};<} 45 {>;emit {\b, at least v4.5 to extract};<} 
<

		if {[S string 353 0 {} {} eq WINZIP]} {>

		emit {\b, WinZIP self-extracting}
<}

	mime application/zip

<}

<}

<}
} {
if {[S string 0 0 {} {} eq VCLMTF]} {>

emit {StarView MetaFile}

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {\b, size %d}
<}

<}
} {
if {[N lelong 20 0 0 {} {} == 4257523676]} {>

emit {Zoo archive data}

if {[N byte 4 0 0 {} {} > 48]} {>

emit {\b, v%c.}

	if {[N byte 6 0 0 {} {} > 47]} {>

	emit {\b%c}

		if {[N byte 7 0 0 {} {} > 47]} {>

		emit {\b%c}
<}

<}

<}

if {[N byte 32 0 0 {} {} > 0]} {>

emit {\b, modify: v%d}

	if {[N byte 33 0 0 {} {} x {}]} {>

	emit {\b.%d+}
<}

<}

if {[N lelong 42 0 0 {} {} == 4257523676]} {>

emit {\b,}

	if {[N byte 70 0 0 {} {} > 0]} {>

	emit {extract: v%d}

		if {[N byte 71 0 0 {} {} x {}]} {>

		emit {\b.%d+}
<}

<}

<}

mime application/x-zoo

<}
} {
if {[S string 10 0 {} {} eq \#\ This\ is\ a\ shell\ archive]} {>

emit {shell archive text}
mime application/octet-stream

<}
} {
if {[S string 0 0 {} {} eq \0\ \ \ \ \ \ \ \ \ \ \ \0\0]} {>

emit {LBR archive data}
<}
} {
if {[S string 2 0 {} {} eq -pm0-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -pm1-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -pm2-]} {>
U 219 lharc-file

<}
} {
if {[S string 2 0 {} {} eq -pms-]} {>

emit {PMarc SFX archive (CP/M, DOS)}
ext com

<}
} {
if {[S string 5 0 {} {} eq -pc1-]} {>

emit {PopCom compressed executable (CP/M)}
<}
} {
if {[S string 4 0 {} {} eq gtktalog\ ]} {>

emit {GTKtalog catalog data,}

if {[S string 13 0 {} {} eq 3]} {>

emit {version 3}

	if {[N beshort 14 0 0 {} {} == 26490]} {>

	emit (gzipped)
<}

	if {[N beshort 14 0 0 {} {} != 26490]} {>

	emit {(not gzipped)}
<}

<}

if {[S string 13 0 {} {} > 3]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq PAR\0]} {>

emit {PARity archive data}

if {[N leshort 48 0 0 {} {} == 0]} {>

emit {- Index file}
<}

if {[N leshort 48 0 0 {} {} > 0]} {>

emit {- file number %d}
<}

<}
} {
if {[S string 0 0 {} {} eq d8:announce]} {>

emit {BitTorrent file}
mime application/x-bittorrent

<}
} {
if {[S string 0 0 {} {} eq d13:announce-list]} {>

emit {BitTorrent file}
mime application/x-bittorrent

<}
} {
if {[S string 0 0 {} {} eq PK00PK\003\004]} {>

emit {Zip archive data}
<}
} {
if {[S string 7 0 {} {} eq **ACE**]} {>

emit {ACE archive data}

if {[N byte 15 0 0 {} {} > 0]} {>

emit {version %d}
<}

switch -- [Nv byte 16 0 {} {}] 0 {>;emit {\b, from MS-DOS};<} 1 {>;emit {\b, from OS/2};<} 2 {>;emit {\b, from Win/32};<} 3 {>;emit {\b, from Unix};<} 4 {>;emit {\b, from MacOS};<} 5 {>;emit {\b, from WinNT};<} 6 {>;emit {\b, from Primos};<} 7 {>;emit {\b, from AppleGS};<} 8 {>;emit {\b, from Atari};<} 9 {>;emit {\b, from Vax/VMS};<} 10 {>;emit {\b, from Amiga};<} 11 {>;emit {\b, from Next};<} 
<

if {[N byte 14 0 0 {} {} x {}]} {>

emit {\b, version %d to extract}
<}

if {[N leshort 5 0 0 {} {} & 128]} {>

emit {\b, multiple volumes,}

	if {[N byte 17 0 0 {} {} x {}]} {>

	emit {\b (part %d),}
<}

<}

if {[N leshort 5 0 0 {} {} & 2]} {>

emit {\b, contains comment}
<}

if {[N leshort 5 0 0 {} {} & 512]} {>

emit {\b, sfx}
<}

if {[N leshort 5 0 0 {} {} & 1024]} {>

emit {\b, small dictionary}
<}

if {[N leshort 5 0 0 {} {} & 2048]} {>

emit {\b, multi-volume}
<}

if {[N leshort 5 0 0 {} {} & 4096]} {>

emit {\b, contains AV-String}

	if {[S string 30 0 {} {} eq \x16*UNREGISTERED\x20VERSION*]} {>

	emit (unregistered)
<}

<}

if {[N leshort 5 0 0 {} {} & 8192]} {>

emit {\b, with recovery record}
<}

if {[N leshort 5 0 0 {} {} & 16384]} {>

emit {\b, locked}
<}

if {[N leshort 5 0 0 {} {} & 32768]} {>

emit {\b, solid}
<}

<}
} {
if {[S string 26 0 {} {} eq sfArk]} {>

emit {sfArk compressed Soundfont}

if {[S string 21 0 {} {} eq 2]} {>

	if {[S string 1 0 {} {} > \0]} {>

	emit {Version %s}
<}

	if {[S string 42 0 {} {} > \0]} {>

	emit {: %s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq Packed\ File\ ]} {>

emit {Personal NetWare Packed File}

if {[S string 12 0 {} {} x {}]} {>

emit {\b, was "%.12s"}
<}

<}
} {
if {[S string 0 0 {} {} eq RZIP]} {>

emit {rzip compressed data}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N belong 6 0 0 {} {} x {}]} {>

emit {(%d bytes)}
<}

<}
} {
if {[N lelong 8 0 0 {} {} == 268436505]} {>

emit {Symbian installation file}

switch -- [Nv lelong 4 0 {} {}] 268435565 {>;emit {(EPOC release 3/4/5)};<} 268450322 {>;emit {(EPOC release 6)};<} 
<

mime application/vnd.symbian.install

<}
} {
if {[S string 0 0 {} {} eq MPQ\032]} {>

emit {MoPaQ (MPQ) archive}
<}
} {
if {[S string 0 0 {} {} eq KGB_arch]} {>

emit {KGB Archiver file}

if {[S string 10 0 {} {} x {}]} {>

emit {with compression level %.1s}
<}

<}
} {
if {[S string 0 0 {} {} eq xar!]} {>

emit {xar archive}

if {[N beshort 6 0 0 {} {} x {}]} {>

emit {version %d,}
<}

switch -- [Nv belong 24 0 {} {}] 0 {>;emit {no checksum};<} 1 {>;emit {SHA-1 checksum};<} 2 {>;emit {MD5 checksum};<} 
<

mime application/x-xar

<}
} {
if {[S string 0 0 {} {} eq PAR2]} {>

emit {Parity Archive Volume Set}
<}
} {
if {[S string 12 0 {} {} eq BB02]} {>

emit {Bacula volume}

if {[N bedate 20 0 0 {} {} x {}]} {>

emit {\b, started %s}
<}

<}
} {
if {[S string 0 0 {} {} eq zPQ]} {>

emit {ZPAQ stream}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {\b, level %d}
<}

<}
} {
if {[S string 0 0 {} {} eq 7kSt]} {>

emit {ZPAQ file}
<}
} {
if {[S string 0 0 {} {} eq L\0R\0F\0\0\0]} {>

emit {BBeB ebook data, unencrypted}

if {[N beshort 8 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

switch -- [Nv byte 36 0 {} {}] 1 {>;emit {\b, front-to-back};<} 16 {>;emit {\b, back-to-front};<} 
<

if {[N beshort 42 0 0 {} {} x {}]} {>

emit {\b, (%dx,}
<}

if {[N beshort 44 0 0 {} {} x {}]} {>

emit %d)
<}

<}
} {
if {[Nx belong 0 0 0 & 4294965232 == 4277076224]} {>

emit {Norton GHost image}

switch -- [Nv byte 2 0 & 8] 0 {>;emit {\b, first file};<} 8 {>;emit {\b, split file}

	if {[N byte 4 0 0 {} {} x {}]} {>

	emit id=0x%x
<}
;<} 0 {>;
	if {[N bequad 12 0 0 {} {} != 0]} {>

	emit {\b, password protected}
<}

	if {[N byte 44 0 0 {} {} != 1]} {>

		if {[N byte 10 0 0 {} {} == 1]} {>

		emit {\b, sector copy}
<}

		if {[N byte 43 0 0 {} {} == 1]} {>

		emit {\b, boot track}
<}

<}

	if {[N byte 44 0 0 {} {} == 1]} {>

	emit {\b, disc sector copy}
<}

	if {[S string 255 0 {} {} > \0]} {>

	emit {"%-.254s"}
<}
;<} 
<

switch -- [Nv byte 3 0 {} {}] 0 {>;emit {\b, no compression};<} 2 {>;emit {\b, fast compression (Z1)};<} 3 {>;emit {\b, medium compression (Z2)};<} 
<

if {[N byte 3 0 0 {} {} > 3]} {>

	if {[N byte 3 0 0 {} {} < 11]} {>

	emit {\b, compression (Z%d-1)}
<}

<}

if {[Sx search 3592 0 {} 7776 eq \x55\xAA]} {>

<}

<}
} {
if {[S string 0 0 {} {} eq Cr24]} {>

emit {Google Chrome extension}

if {[N long 4 0 0 {} {} x {}]} {>

emit {\b, version %u}
<}

mime application/x-chrome-extension

<}
} {
if {[S string 0 0 {} {} eq PWS3]} {>

emit {Password Safe V3 database}
<}
} {
if {[S string 0 0 {} {} eq StartFontMetrics]} {>

emit {ASCII font metrics}
<}
} {
if {[S string 0 0 {} {} eq StartFont]} {>

emit {ASCII font bits}
<}
} {
switch -- [Nv belong 8 0 {} {}] 326773573 {>;emit {X11/NeWS bitmap font};<} 326773576 {>;emit {X11/NeWS font family};<} 
<
} {
if {[S search 0 0 {} 1 eq -----BEGIN\ CERTIFICATE------]} {>

emit {RFC1421 Security Certificate text}
<}
} {
if {[S search 0 0 {} 1 eq -----BEGIN\ NEW\ CERTIFICATE]} {>

emit {RFC1421 Security Certificate Signing Request text}
<}
} {
if {[S string 0 0 {} {} eq <list>\n<protocol\ bbn-m]} {>

emit {Diamond Multimedia Document}
<}
} {
if {[S string 2 0 {} {} eq \040\040\040\040\040\040\040\040\040\040\040ML4D\040'92]} {>

emit {Smith Corona PWP}

switch -- [Nv byte 24 0 {} {}] 2 {>;emit {\b, single spaced};<} 3 {>;emit {\b, 1.5 spaced};<} 4 {>;emit {\b, double spaced};<} 
<

switch -- [Nv byte 25 0 {} {}] 66 {>;emit {\b, letter};<} 84 {>;emit {\b, legal};<} 
<

if {[N byte 26 0 0 {} {} == 70]} {>

emit {\b, A4}
<}

<}
} {
if {[S string 0 0 {} {} eq \xffWPC]} {>

switch -- [Nv byte 8 0 {} {}] 1 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {WordPerfect macro};<} 2 {>;emit {WordPerfect help file};<} 3 {>;emit {WordPerfect keyboard file};<} 10 {>;emit {WordPerfect document};<} 11 {>;emit {WordPerfect dictionary};<} 12 {>;emit {WordPerfect thesaurus};<} 13 {>;emit {WordPerfect block};<} 14 {>;emit {WordPerfect rectangular block};<} 15 {>;emit {WordPerfect column block};<} 16 {>;emit {WordPerfect printer data};<} 19 {>;emit {WordPerfect printer data};<} 20 {>;emit {WordPerfect driver resource data};<} 22 {>;emit {WordPerfect graphic image};<} 23 {>;emit {WordPerfect hyphenation code};<} 24 {>;emit {WordPerfect hyphenation data};<} 25 {>;emit {WordPerfect macro resource data};<} 27 {>;emit {WordPerfect hyphenation lex};<} 29 {>;emit {WordPerfect wordlist};<} 30 {>;emit {WordPerfect equation resource data};<} 33 {>;emit {WordPerfect spell rules};<} 34 {>;emit {WordPerfect dictionary rules};<} 39 {>;emit {WordPerfect spell rules (Microlytics)};<} 43 {>;emit {WordPerfect settings file};<} 44 {>;emit {WordPerfect 3.5 document};<} 45 {>;emit {WordPerfect 4.2 document};<} 69 {>;emit {WordPerfect dialog file};<} 76 {>;emit {WordPerfect button bar};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel WordPerfect: Unknown filetype %d}
<}

<}
;<} 2 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {Corel shell macro};<} 10 {>;emit {Corel shell definition};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Shell: Unknown filetype %d}
<}

<}
;<} 3 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {Corel Notebook macro};<} 2 {>;emit {Corel Notebook help file};<} 3 {>;emit {Corel Notebook keyboard file};<} 10 {>;emit {Corel Notebook definition};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Notebook: Unknown filetype %d}
<}

<}
;<} 4 {>;
	if {[N byte 9 0 0 {} {} == 2]} {>

	emit {Corel Calculator help file}
<}

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Calculator: Unknown filetype %d}
<}

<}
;<} 5 {>;
	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel File Manager: Unknown filetype %d}
<}

<}
;<} 6 {>;
	switch -- [Nv byte 9 0 {} {}] 2 {>;emit {Corel Calendar help file};<} 10 {>;emit {Corel Calendar data file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Calendar: Unknown filetype %d}
<}

<}
;<} 7 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {Corel Editor macro};<} 2 {>;emit {Corel Editor help file};<} 3 {>;emit {Corel Editor keyboard file};<} 25 {>;emit {Corel Editor macro resource file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Program Editor/Ed Editor: Unknown filetype %d}
<}

<}
;<} 8 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {Corel Macro editor macro};<} 2 {>;emit {Corel Macro editor help file};<} 3 {>;emit {Corel Macro editor keyboard file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Macro Editor: Unknown filetype %d}
<}

<}
;<} 9 {>;
	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Plan Perfect: Unknown filetype %d}
<}

<}
;<} 10 {>;
	switch -- [Nv byte 9 0 {} {}] 1 {>;emit {Corel PlanPerfect macro};<} 2 {>;emit {Corel PlanPerfect help file};<} 3 {>;emit {Corel PlanPerfect keyboard file};<} 10 {>;emit {Corel PlanPerfect worksheet};<} 15 {>;emit {Corel PlanPerfect printer definition};<} 18 {>;emit {Corel PlanPerfect graphic definition};<} 19 {>;emit {Corel PlanPerfect data};<} 20 {>;emit {Corel PlanPerfect temporary printer};<} 25 {>;emit {Corel PlanPerfect macro resource data};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel DataPerfect: Unknown filetype %d}
<}

<}
;<} 11 {>;
	switch -- [Nv byte 9 0 {} {}] 2 {>;emit {Corel Mail help file};<} 5 {>;emit {Corel Mail distribution list};<} 10 {>;emit {Corel Mail out box};<} 11 {>;emit {Corel Mail in box};<} 20 {>;emit {Corel Mail users archived mailbox};<} 21 {>;emit {Corel Mail archived message database};<} 22 {>;emit {Corel Mail archived attachments};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Mail: Unknown filetype %d}
<}

<}
;<} 12 {>;
	if {[N byte 9 0 0 {} {} == 11]} {>

	emit {Corel Printer temporary file}
<}

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Printer: Unknown filetype %d}
<}

<}
;<} 13 {>;
	switch -- [Nv byte 9 0 {} {}] 2 {>;emit {Corel Scheduler help file};<} 10 {>;emit {Corel Scheduler in file};<} 11 {>;emit {Corel Scheduler out file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Scheduler: Unknown filetype %d}
<}

<}
;<} 14 {>;
	switch -- [Nv byte 9 0 {} {}] 10 {>;emit {Corel GroupWise settings file};<} 17 {>;emit {Corel GroupWise directory services};<} 43 {>;emit {Corel GroupWise settings file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel WordPerfect Office: Unknown filetype %d}
<}

<}
;<} 15 {>;
	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel DrawPerfect: Unknown filetype %d}
<}

<}
;<} 16 {>;
	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel LetterPerfect: Unknown filetype %d}
<}

<}
;<} 17 {>;
	switch -- [Nv byte 9 0 {} {}] 10 {>;emit {Corel Terminal resource data};<} 11 {>;emit {Corel Terminal resource data};<} 43 {>;emit {Corel Terminal resource data};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Terminal: Unknown filetype %d}
<}

<}
;<} 18 {>;
	switch -- [Nv byte 9 0 {} {}] 10 {>;emit {Corel loadable file};<} 11 {>;emit {Corel GUI loadable text};<} 12 {>;emit {Corel graphics resource data};<} 13 {>;emit {Corel printer settings file};<} 14 {>;emit {Corel port definition file};<} 15 {>;emit {Corel print queue parameters};<} 16 {>;emit {Corel compressed file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel loadable file: Unknown filetype %d}
<}

<}

	switch -- [Nv byte 15 0 {} {}] 0 {>;emit {\b, optimized for Intel};<} 1 {>;emit {\b, optimized for Non-Intel};<} 
<
;<} 20 {>;
	switch -- [Nv byte 9 0 {} {}] 10 {>;emit {Corel Network service msg file};<} 11 {>;emit {Corel Network service msg file};<} 12 {>;emit {Corel Async gateway login msg};<} 14 {>;emit {Corel GroupWise message file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {Corel Network service: Unknown filetype %d}
<}

<}
;<} 31 {>;
	switch -- [Nv byte 9 0 {} {}] 20 {>;emit {GroupWise admin domain database};<} 21 {>;emit {GroupWise admin host database};<} 23 {>;emit {GroupWise admin remote host database};<} 24 {>;emit {GroupWise admin ADS deferment data file};<} 
<

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {GroupWise: Unknown filetype %d}
<}

<}
;<} 33 {>;
	if {[N byte 9 0 0 {} {} == 10]} {>

	emit {IntelliTAG (SGML) compiled DTD}
<}

	if {[S default 9 0 {} {} x {}]} {>

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {IntelliTAG: Unknown filetype %d}
<}

<}
;<} 
<

if {[S default 8 0 {} {} x {}]} {>

	if {[N byte 8 0 0 {} {} x {}]} {>

	emit {Unknown Corel/Wordperfect product %d,}

		if {[N byte 9 0 0 {} {} x {}]} {>

		emit {file type %d}
<}

<}

<}

if {[N byte 10 0 0 {} {} == 0]} {>

emit {\b, v5.}
<}

if {[N byte 10 0 0 {} {} != 0]} {>

emit {\b, v%d.}
<}

if {[N byte 11 0 0 {} {} x {}]} {>

emit {\b%d}
<}

<}
} {
if {[S string 0 0 {} {} eq HWP\ Document\ File]} {>

emit {Hangul (Korean) Word Processor File 3.0}
<}
} {
if {[S string 512 0 {} {} eq R\0o\0o\0t\0]} {>

emit {Hangul (Korean) Word Processor File 2000}
mime application/x-hwp

<}
} {
if {[S string 0 0 {} {} eq CSBK]} {>

emit {Ted Neslson's CosmicBook hypertext file}
<}
} {
if {[S string 2 0 {} {} eq EYWR]} {>

emit {AmigaWriter file}
<}
} {
if {[S string 0 0 {} {} eq \\1cw\ ]} {>

emit {ChiWriter file}

if {[S string 5 0 {} {} > \0]} {>

emit {version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq \\1cw]} {>

emit {ChiWriter file}
<}
} {
if {[S string 2 0 {} {} eq IIXPR3]} {>

emit {Intel Quark Express Document (English)}
<}
} {
if {[S string 2 0 {} {} eq IIXPRa]} {>

emit {Intel Quark Express Document (Korean)}
<}
} {
if {[S string 2 0 {} {} eq MMXPR3]} {>

emit {Motorola Quark Express Document (English)}
mime application/x-quark-xpress-3

<}
} {
if {[S string 2 0 {} {} eq MMXPRa]} {>

emit {Motorola Quark Express Document (Korean)}
<}
} {
if {[S string 0 0 {} {} eq DOC]} {>

if {[N byte 43 0 0 {} {} == 20]} {>

emit {Just System Word Processor Ichitaro v4}
mime application/x-ichitaro4

<}

if {[S string 144 0 {} {} eq JDASH]} {>

emit application/x-ichitaro4
<}

<}
} {
if {[S string 0 0 {} {} eq DOC]} {>

if {[N byte 43 0 0 {} {} == 21]} {>

emit {Just System Word Processor Ichitaro v5}
mime application/x-ichitaro5

<}

<}
} {
if {[S string 0 0 {} {} eq DOC]} {>

if {[N byte 43 0 0 {} {} == 22]} {>

emit {Just System Word Processor Ichitaro v6}
mime application/x-ichitaro6

<}

<}
} {
if {[S string 0 0 w {} eq <map\ version]} {>

emit {Freemind document}
mime application/x-freemind

<}
} {
if {[S string 0 0 w {} eq <map\ version=\"freeplane]} {>

emit {Freeplane document}
mime application/x-freeplane

<}
} {
if {[S string 0 0 {} {} eq <SCRIBUSUTF8\ Version]} {>

emit {Scribus Document}
<}
} {
if {[S string 0 0 {} {} eq <SCRIBUSUTF8NEW\ Version]} {>

emit {Scribus Document}
mime application/x-scribus

<}
} {
if {[S string 0 0 {} {} eq llvm]} {>

emit {LLVM byte-codes, uncompressed}
<}
} {
if {[S string 0 0 {} {} eq llvc0]} {>

emit {LLVM byte-codes, null compression}
<}
} {
if {[S string 0 0 {} {} eq llvc1]} {>

emit {LLVM byte-codes, gzip compression}
<}
} {
if {[S string 0 0 {} {} eq llvc2]} {>

emit {LLVM byte-codes, bzip2 compression}
<}
} {
if {[S string 0 0 {} {} eq BC\xc0\xde]} {>

emit {LLVM IR bitcode}
<}
} {
if {[S string 0 0 {} {} eq FTNCHEK_\ P]} {>

emit {project file for ftnchek}

if {[S string 10 0 {} {} eq 1]} {>

emit {version 2.7}
<}

if {[S string 10 0 {} {} eq 2]} {>

emit {version 2.8 to 2.10}
<}

if {[S string 10 0 {} {} eq 3]} {>

emit {version 2.11 or later}
<}

<}
} {
if {[S string 0 0 {} {} eq Octave-1-L]} {>

emit {Octave binary data (little endian)}
<}
} {
if {[S string 0 0 {} {} eq Octave-1-B]} {>

emit {Octave binary data (big endian)}
<}
} {
if {[S string 0 0 {} {} eq <MakerFile]} {>

emit {FrameMaker document}

if {[S string 11 0 {} {} eq 5.5]} {>

emit (5.5
<}

if {[S string 11 0 {} {} eq 5.0]} {>

emit (5.0
<}

if {[S string 11 0 {} {} eq 4.0]} {>

emit (4.0
<}

if {[S string 11 0 {} {} eq 3.0]} {>

emit (3.0
<}

if {[S string 11 0 {} {} eq 2.0]} {>

emit (2.0
<}

if {[S string 11 0 {} {} eq 1.0]} {>

emit (1.0
<}

if {[N byte 14 0 0 {} {} x {}]} {>

emit %c)
<}

mime application/x-mif

<}
} {
if {[S string 0 0 {} {} eq <MIFFile]} {>

emit {FrameMaker MIF (ASCII) file}

if {[S string 9 0 {} {} eq 4.0]} {>

emit (4.0)
<}

if {[S string 9 0 {} {} eq 3.0]} {>

emit (3.0)
<}

if {[S string 9 0 {} {} eq 2.0]} {>

emit (2.0)
<}

if {[S string 9 0 {} {} eq 1.0]} {>

emit (1.x)
<}

mime application/x-mif

<}
} {
if {[S search 0 0 {} 1 eq <MakerDictionary]} {>

emit {FrameMaker Dictionary text}

if {[S string 17 0 {} {} eq 3.0]} {>

emit (3.0)
<}

if {[S string 17 0 {} {} eq 2.0]} {>

emit (2.0)
<}

if {[S string 17 0 {} {} eq 1.0]} {>

emit (1.x)
<}

mime application/x-mif

<}
} {
if {[S string 0 0 {} {} eq <MakerScreenFont]} {>

emit {FrameMaker Font file}

if {[S string 17 0 {} {} eq 1.01]} {>

emit (%s)
<}

mime application/x-mif

<}
} {
if {[S string 0 0 {} {} eq <MML]} {>

emit {FrameMaker MML file}
mime application/x-mif

<}
} {
if {[S string 0 0 {} {} eq <BookFile]} {>

emit {FrameMaker Book file}

if {[S string 10 0 {} {} eq 3.0]} {>

emit (3.0
<}

if {[S string 10 0 {} {} eq 2.0]} {>

emit (2.0
<}

if {[S string 10 0 {} {} eq 1.0]} {>

emit (1.0
<}

if {[N byte 13 0 0 {} {} x {}]} {>

emit %c)
<}

mime application/x-mif

<}
} {
if {[S string 0 0 {} {} eq <Maker\040Intermediate\040Print\040File]} {>

emit {FrameMaker IPL file}
mime application/x-mif

<}
} {
if {[S string 0 0 t {} eq Relay-Version:]} {>

emit {old news text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq \#!\ rnews]} {>

emit {batched news text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq N\#!\ rnews]} {>

emit {mailed, batched news text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq Forward\ to]} {>

emit {mail forwarding text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq Pipe\ to]} {>

emit {mail piping text}
mime message/rfc822

<}
} {
if {[S string 0 0 {t c} {} eq delivered-to:]} {>

emit {SMTP mail text}
mime message/rfc822

<}
} {
if {[S string 0 0 {t c} {} eq return-path:]} {>

emit {SMTP mail text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq Path:]} {>

emit {news text}
mime message/news

<}
} {
if {[S string 0 0 t {} eq Xref:]} {>

emit {news text}
mime message/news

<}
} {
if {[S string 0 0 t {} eq From:]} {>

emit {news or mail text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq Article]} {>

emit {saved news text}
mime message/news

<}
} {
if {[S string 0 0 t {} eq BABYL]} {>

emit {Emacs RMAIL text}
<}
} {
if {[S string 0 0 t {} eq Received:]} {>

emit {RFC 822 mail text}
mime message/rfc822

<}
} {
if {[S string 0 0 t {} eq MIME-Version:]} {>

emit {MIME entity text}
<}
} {
if {[S string 0 0 {} {} eq *mbx*]} {>

emit {MBX mail folder}
<}
} {
if {[S string 0 0 {} {} eq \241\002\213\015skiplist\ file\0\0\0]} {>

emit {Cyrus skiplist DB}
<}
} {
if {[S string 0 0 {} {} eq \241\002\213\015twoskip\ file\0\0\0\0]} {>

emit {Cyrus twoskip DB}
<}
} {
if {[S string 0 0 {} {} eq JAM\0]} {>

emit {JAM message area header file}

if {[N leshort 12 0 0 {} {} > 0]} {>

emit {(%d messages)}
<}

<}
} {
if {[S string 0 0 {} {} eq CyrSBytecode]} {>

emit {Cyrus sieve bytecode data,}

if {[N belong 12 0 0 {} {} == 1]} {>

emit {version 1, big-endian}
<}

if {[N lelong 12 0 0 {} {} == 1]} {>

emit {version 1, little-endian}
<}

if {[N belong 12 0 0 {} {} x {}]} {>

emit {version %d, network-endian}
<}

<}
} {
if {[S string 0 0 {} {} eq RSRC]} {>

emit {National Instruments,}

if {[S string 8 0 {} {} eq LV]} {>

emit {LabVIEW File,}

	if {[S string 10 0 {} {} eq SB]} {>

	emit {Code Resource File, data}
<}

	if {[S string 10 0 {} {} eq IN]} {>

	emit {Virtual Instrument Program, data}
<}

	if {[S string 10 0 {} {} eq AR]} {>

	emit {VI Library, data}
<}

<}

if {[S string 8 0 {} {} eq LMNULBVW]} {>

emit {Portable File Names, data}
<}

if {[S string 8 0 {} {} eq rsc]} {>

emit {Resources File, data}
<}

<}
} {
if {[S string 0 0 {} {} eq VMAP]} {>

emit {National Instruments, VXI File, data}
<}
} {
if {[S string 0 0 {} {} eq @CT\ ]} {>

emit {T602 document data,}

if {[S string 4 0 {} {} eq 0]} {>

emit Kamenicky
<}

if {[S string 4 0 {} {} eq 1]} {>

emit {CP 852}
<}

if {[S string 4 0 {} {} eq 2]} {>

emit KOI8-CS
<}

if {[S string 4 0 {} {} > 2]} {>

emit {unknown encoding}
<}

<}
} {
if {[S string 0 0 {} {} eq VimCrypt~]} {>

emit {Vim encrypted file data}
<}
} {
if {[Sx string 0 0 {} {} eq b0VIM\ ]} {>

emit {Vim swap file}

if {[Sx string [R 0] 0 {} {} > \0]} {>

emit {\b, version %s}
<}

<}
} {
if {[S string 0 0 {} {} eq hsi1]} {>

emit {JPEG image data, HSI proprietary}
<}
} {
if {[S string 0 0 {} {} eq \x00\x00\x00\x0C\x6A\x50\x20\x20\x0D\x0A\x87\x0A]} {>

emit {JPEG 2000}

if {[S string 20 0 {} {} eq \x6a\x70\x32\x20]} {>

emit {Part 1 (JP2)}
mime image/jp2

<}

if {[S string 20 0 {} {} eq \x6a\x70\x78\x20]} {>

emit {Part 2 (JPX)}
mime image/jpx

<}

if {[S string 20 0 {} {} eq \x6a\x70\x6d\x20]} {>

emit {Part 6 (JPM)}
mime image/jpm

<}

if {[S string 20 0 {} {} eq \x6d\x6a\x70\x32]} {>

emit {Part 3 (MJ2)}
mime video/mj2

<}

<}
} {
if {[N beshort 45 0 0 {} {} == 65362]} {>

<}
} {
if {[S string 0 0 {} {} eq divert(-1)\n]} {>

emit {sendmail m4 text file}
<}
} {
if {[S string 0 0 {} {} eq FP1]} {>

emit {libfprint fingerprint data V1}

if {[N beshort 3 0 0 {} {} x {}]} {>

emit {\b, driver_id %x}
<}

if {[N belong 5 0 0 {} {} x {}]} {>

emit {\b, devtype %x}
<}

<}
} {
if {[S string 0 0 {} {} eq FP2]} {>

emit {libfprint fingerprint data V2}

if {[N beshort 3 0 0 {} {} x {}]} {>

emit {\b, driver_id %x}
<}

if {[N belong 5 0 0 {} {} x {}]} {>

emit {\b, devtype %x}
<}

<}
} {
switch -- [Nv belong 91392 0 {} {}] 302072064 {>;emit {D64 Image};<} 302072192 {>;emit {D71 Image};<} 
<
} {
if {[N belong 399360 0 0 {} {} == 671302656]} {>

emit {D81 Image}
<}
} {
if {[S string 0 0 {} {} eq C64\40CARTRIDGE]} {>

emit {CCS C64 Emultar Cartridge Image}
<}
} {
if {[S string 0 0 {} {} eq GCR-1541]} {>

emit {GCR Image}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {version: %i}
<}

if {[N byte 9 0 0 {} {} x {}]} {>

emit {tracks: %i}
<}

<}
} {
if {[S string 9 0 {} {} eq PSUR]} {>

emit {ARC archive (c64)}
<}
} {
if {[S string 2 0 {} {} eq -LH1-]} {>

emit {LHA archive (c64)}
<}
} {
if {[S string 0 0 {} {} eq C64File]} {>

emit {PC64 Emulator file}

if {[S string 8 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[S string 0 0 {} {} eq C64Image]} {>

emit {PC64 Freezer Image}
<}
} {
if {[S string 0 0 {} {} eq CBM\144\0\0]} {>

emit {Power 64 C64 Emulator Snapshot}
<}
} {
if {[S string 0 0 {} {} eq C64S\x20tape\x20file]} {>

emit {T64 tape Image}

if {[N leshort 32 0 0 {} {} x {}]} {>

emit Version:0x%x
<}

if {[N leshort 36 0 0 {} {} != 0]} {>

emit Entries:%i
<}

if {[S string 40 0 {} {} x {}]} {>

emit Name:%.24s
<}

<}
} {
if {[S string 0 0 {} {} eq C64\x20tape\x20image\x20file\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0]} {>

emit {T64 tape Image}

if {[N leshort 32 0 0 {} {} x {}]} {>

emit Version:0x%x
<}

if {[N leshort 36 0 0 {} {} != 0]} {>

emit Entries:%i
<}

if {[S string 40 0 {} {} x {}]} {>

emit Name:%.24s
<}

<}
} {
if {[S string 0 0 {} {} eq C64S\x20tape\x20image\x20file\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0]} {>

emit {T64 tape Image}

if {[N leshort 32 0 0 {} {} x {}]} {>

emit Version:0x%x
<}

if {[N leshort 36 0 0 {} {} != 0]} {>

emit Entries:%i
<}

if {[S string 40 0 {} {} x {}]} {>

emit Name:%.24s
<}

<}
} {
if {[S string 0 0 {} {} eq C64-TAPE-RAW]} {>

emit {C64 Raw Tape File (.tap),}

if {[N byte 12 0 0 {} {} x {}]} {>

emit Version:%u,
<}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {Length:%u cycles}
<}

<}
} {
if {[S string 0 0 {} {} eq NES\x1A]} {>

emit {iNES ROM image}

switch -- [Nv byte 7 0 & 12] 8 {>;emit {(NES 2.0)};<} 8 {>;
	switch -- [Nv byte 12 0 & 3] 0 {>;emit {[NTSC]};<} 1 {>;emit {[PAL]};<} 
<

	if {[N byte 12 0 0 & 2 == 2]} {>

	emit {[NTSC+PAL]}
<}
;<} 
<

if {[N byte 4 0 0 {} {} x {}]} {>

emit {\b: %ux16k PRG}
<}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {\b, %ux16k CHR}
<}

if {[N byte 6 0 0 & 8 == 8]} {>

emit {[4-Scr]}
<}

switch -- [Nv byte 6 0 & 9] 0 {>;emit {[H-mirror]};<} 1 {>;emit {[V-mirror]};<} 
<

if {[N byte 6 0 0 & 2 == 2]} {>

emit {[SRAM]}
<}

if {[N byte 6 0 0 & 4 == 4]} {>

emit {[Trainer]}
<}

switch -- [Nv byte 7 0 & 3] 2 {>;emit {[PC10]};<} 1 {>;emit {[VS}

	if {[N byte 7 0 0 & 12 == 8]} {>

		switch -- [Nv byte 13 0 & 15] 0 {>;emit {\b, RP2C03B};<} 1 {>;emit {\b, RP2C03G};<} 2 {>;emit {\b, RP2C04-0001};<} 3 {>;emit {\b, RP2C04-0002};<} 4 {>;emit {\b, RP2C04-0003};<} 5 {>;emit {\b, RP2C04-0004};<} 6 {>;emit {\b, RP2C03B};<} 7 {>;emit {\b, RP2C03C};<} 8 {>;emit {\b, RP2C05-01};<} 9 {>;emit {\b, RP2C05-02};<} 10 {>;emit {\b, RP2C05-03};<} 11 {>;emit {\b, RP2C05-04};<} 12 {>;emit {\b, RP2C05-05};<} 
<

<}

	if {[N byte 7 0 0 {} {} x {}]} {>

	emit {\b]}
<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq UNIF]} {>

if {[N lelong 4 0 0 {} {} < 16]} {>

emit {UNIF v%d format NES ROM image}
<}

<}
} {
if {[N bequad 260 0 0 {} {} == 14910686532989681675]} {>

emit {Game Boy ROM image}

if {[N byte 323 0 0 & 128 == 128]} {>

	if {[S string 308 0 {} {} > \0]} {>

	emit {\b: "%.15s"}
<}

<}

if {[N byte 323 0 0 & 128 != 128]} {>

	if {[S string 308 0 {} {} > \0]} {>

	emit {\b: "%.16s"}
<}

<}

if {[N byte 332 0 0 {} {} x {}]} {>

emit (Rev.%02u)
<}

if {[N byte 331 0 0 {} {} == 51]} {>

	if {[N byte 326 0 0 {} {} == 3]} {>

		if {[N byte 323 0 0 & 128 == 128]} {>

		emit {[SGB+CGB]}
<}

		if {[N byte 323 0 0 & 128 != 128]} {>

		emit {[SGB]}
<}

<}

	if {[N byte 326 0 0 {} {} != 3]} {>

		switch -- [Nv byte 323 0 & 192] -128 {>;emit {[CGB]};<} -64 {>;emit {[CGB ONLY]};<} 
<

<}

<}

switch -- [Nv byte 327 0 {} {}] 0 {>;emit {[ROM ONLY]};<} 1 {>;emit {[MBC1]};<} 2 {>;emit {[MBC1+RAM]};<} 3 {>;emit {[MBC1+RAM+BATT]};<} 5 {>;emit {[MBC2]};<} 6 {>;emit {[MBC2+BATTERY]};<} 8 {>;emit {[ROM+RAM]};<} 9 {>;emit {[ROM+RAM+BATTERY]};<} 11 {>;emit {[MMM01]};<} 12 {>;emit {[MMM01+SRAM]};<} 13 {>;emit {[MMM01+SRAM+BATT]};<} 15 {>;emit {[MBC3+TIMER+BATT]};<} 16 {>;emit {[MBC3+TIMER+RAM+BATT]};<} 17 {>;emit {[MBC3]};<} 18 {>;emit {[MBC3+RAM]};<} 19 {>;emit {[MBC3+RAM+BATT]};<} 25 {>;emit {[MBC5]};<} 26 {>;emit {[MBC5+RAM]};<} 27 {>;emit {[MBC5+RAM+BATT]};<} 28 {>;emit {[MBC5+RUMBLE]};<} 29 {>;emit {[MBC5+RUMBLE+SRAM]};<} 30 {>;emit {[MBC5+RUMBLE+SRAM+BATT]};<} -4 {>;emit {[Pocket Camera]};<} -3 {>;emit {[Bandai TAMA5]};<} -2 {>;emit {[Hudson HuC-3]};<} -1 {>;emit {[Hudson HuC-1]};<} 
<

switch -- [Nv byte 328 0 {} {}] 0 {>;emit {\b, ROM: 256Kbit};<} 1 {>;emit {\b, ROM: 512Kbit};<} 2 {>;emit {\b, ROM: 1Mbit};<} 3 {>;emit {\b, ROM: 2Mbit};<} 4 {>;emit {\b, ROM: 4Mbit};<} 5 {>;emit {\b, ROM: 8Mbit};<} 6 {>;emit {\b, ROM: 16Mbit};<} 7 {>;emit {\b, ROM: 32Mbit};<} 82 {>;emit {\b, ROM: 9Mbit};<} 83 {>;emit {\b, ROM: 10Mbit};<} 84 {>;emit {\b, ROM: 12Mbit};<} 
<

switch -- [Nv byte 329 0 {} {}] 1 {>;emit {\b, RAM: 16Kbit};<} 2 {>;emit {\b, RAM: 64Kbit};<} 3 {>;emit {\b, RAM: 128Kbit};<} 4 {>;emit {\b, RAM: 1Mbit};<} 5 {>;emit {\b, RAM: 512Kbit};<} 
<

<}
} {
if {[S string 0 0 {} {} eq SEGADISCSYSTEM\ \ ]} {>

emit {Sega Mega CD disc image}
U 240 sega-mega-drive-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, 2048-byte sectors}
<}

<}
} {
if {[S string 0 0 {} {} eq SEGABOOTDISC\ \ \ \ ]} {>

emit {Sega Mega CD disc image}
U 240 sega-mega-drive-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, 2048-byte sectors}
<}

<}
} {
if {[S string 16 0 {} {} eq SEGADISCSYSTEM\ \ ]} {>

emit {Sega Mega CD disc image}
U 240 sega-mega-drive-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, 2352-byte sectors}
<}

<}
} {
if {[S string 16 0 {} {} eq SEGABOOTDISC\ \ \ \ ]} {>

emit {Sega Mega CD disc image}
U 240 sega-mega-drive-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {\b, 2352-byte sectors}
<}

<}
} {
if {[S string 256 0 {} {} eq SEGA]} {>

if {[N bequad 960 0 0 {} {} == 5566821131383687237]} {>

emit {Sega 32X ROM image}
U 240 sega-mega-drive-header

<}

if {[N bequad 960 0 0 {} {} != 5566821131383687237]} {>

	if {[N belong 261 0 0 {} {} == 1346978639]} {>

	emit {Sega Pico ROM image}
U 240 sega-mega-drive-header

<}

	if {[N belong 261 0 0 {} {} != 1346978639]} {>

		if {[N beshort 384 0 0 {} {} == 16978]} {>

		emit {Sega Mega CD Boot ROM image}
<}

		if {[N beshort 384 0 0 {} {} != 16978]} {>

		emit {Sega Mega Drive / Genesis ROM image}
<}
U 240 sega-mega-drive-header

<}

<}

<}
} {
if {[S string 640 0 {} {} eq EAGN]} {>

if {[N beshort 8 0 0 {} {} == 43707]} {>

emit {Sega Mega Drive / Genesis ROM image (SMD format):}
U 240 sega-genesis-smd-header

<}

<}
} {
if {[S string 640 0 {} {} eq EAMG]} {>

if {[N beshort 8 0 0 {} {} == 43707]} {>

emit {Sega Mega Drive / Genesis ROM image (SMD format):}
U 240 sega-genesis-smd-header

<}

<}
} {
if {[S string 32752 0 {} {} eq TMR\ SEGA]} {>
U 240 sega-master-system-rom-header

<}
} {
if {[S string 16368 0 {} {} eq TMR\ SEGA]} {>
U 240 sega-master-system-rom-header

<}
} {
if {[S string 8176 0 {} {} eq TMR\ SEGA]} {>
U 240 sega-master-system-rom-header

<}
} {
if {[S string 0 0 {} {} eq SEGA\ SEGASATURN\ ]} {>

emit {Sega Saturn disc image}
U 240 sega-saturn-disc-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {(2048-byte sectors)}
<}

<}
} {
if {[S string 16 0 {} {} eq SEGA\ SEGASATURN\ ]} {>

emit {Sega Saturn disc image}
U 240 sega-saturn-disc-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {(2352-byte sectors)}
<}

<}
} {
if {[S string 0 0 {} {} eq SEGA\ SEGAKATANA\ ]} {>

emit {Sega Dreamcast disc image}
U 240 sega-dreamcast-disc-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {(2048-byte sectors)}
<}

<}
} {
if {[S string 16 0 {} {} eq SEGA\ SEGAKATANA\ ]} {>

emit {Sega Dreamcast disc image}
U 240 sega-dreamcast-disc-header

if {[N byte 0 0 0 {} {} x {}]} {>

emit {(2352-byte sectors)}
<}

<}
} {
if {[S string 0 0 {} {} eq LCDi]} {>

emit {Dream Animator file}
<}
} {
if {[N bequad 4 0 0 {} {} == 2666041169113948705]} {>

emit {Game Boy Advance ROM image}

if {[S string 160 0 {} {} > \0]} {>

emit {\b: "%.12s"}
<}

if {[S string 172 0 {} {} x {}]} {>

emit (%.6s
<}

if {[N byte 188 0 0 {} {} x {}]} {>

emit {\b, Rev.%02u)}
<}

<}
} {
switch -- [Nv bequad 192 0 {} {}] 2666041169113948705 {>;emit {Nintendo DS ROM image}

if {[S string 0 0 {} {} > \0]} {>

emit {\b: "%.12s"}
<}

if {[S string 12 0 {} {} x {}]} {>

emit (%.6s
<}

if {[N byte 30 0 0 {} {} x {}]} {>

emit {\b, Rev.%02u)}
<}

switch -- [Nv byte 18 0 {} {}] 2 {>;emit {(DSi enhanced)};<} 3 {>;emit {(DSi only)};<} 
<
;<} -4008115836254384158 {>;emit {Nintendo DS Slot-2 ROM image (PassMe)};<} 
<
} {
if {[S string 10 0 {} {} eq BY\ SNK\ CORPORATION]} {>

emit {Neo Geo Pocket}

if {[N byte 35 0 0 {} {} == 16]} {>

emit Color
<}

if {[N byte 0 0 0 {} {} x {}]} {>

emit {ROM image}
<}

if {[S string 36 0 {} {} > \0]} {>

emit {\b: "%.12s"}
<}

if {[N byte 31 0 0 {} {} == 255]} {>

emit {(debug mode enabled)}
<}

<}
} {
if {[S string 0 0 {} {} eq PS-X\ EXE]} {>

emit {Sony Playstation executable}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit PC=0x%08x,
<}

if {[N lelong 20 0 0 {} {} != 0]} {>

emit GP=0x%08x,
<}

if {[N lelong 24 0 0 {} {} != 0]} {>

emit {.text=[0x%08x,}

	if {[N lelong 28 0 0 {} {} x {}]} {>

	emit {\b0x%x],}
<}

<}

if {[N lelong 32 0 0 {} {} != 0]} {>

emit {.data=[0x%08x,}

	if {[N lelong 36 0 0 {} {} x {}]} {>

	emit {\b0x%x],}
<}

<}

if {[N lelong 40 0 0 {} {} != 0]} {>

emit {.bss=[0x%08x,}

	if {[N lelong 44 0 0 {} {} x {}]} {>

	emit {\b0x%x],}
<}

<}

if {[N lelong 48 0 0 {} {} != 0]} {>

emit Stack=0x%08x,
<}

if {[N lelong 48 0 0 {} {} == 0]} {>

emit {No Stack!,}
<}

if {[N lelong 52 0 0 {} {} != 0]} {>

emit StackSize=0x%x,
<}

if {[S string 113 0 {} {} x {}]} {>

emit (%s)
<}

<}
} {
if {[S string 0 0 {} {} eq CPE]} {>

emit {CPE executable}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {(version %d)}
<}

<}
} {
if {[Sx string 0 0 {} {} eq XBEH]} {>

emit {XBE, Microsoft Xbox executable}

if {[Nx lelong 4 0 0 {} {} == 0]} {>

	if {[Nx lelong [R 2] 0 0 {} {} == 0]} {>

		if {[Nx lelong [R 2] 0 0 {} {} == 0]} {>

		emit {\b, not signed}
<}

<}

<}

if {[Nx lelong 4 0 0 {} {} > 0]} {>

	if {[Nx lelong [R 2] 0 0 {} {} > 0]} {>

		if {[Nx lelong [R 2] 0 0 {} {} > 0]} {>

		emit {\b, signed}
<}

<}

<}

if {[N lelong 260 0 0 {} {} == 65536]} {>

	if {[N lelong [I 280 long 0 - 0 65376] 0 0 & 2147483655 == 2147483655]} {>

	emit {\b, all regions}
<}

	if {[N lelong [I 280 long 0 - 0 65376] 0 0 & 2147483655 != 2147483655]} {>

		if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} > 0]} {>

		emit (regions:

			if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} & 1]} {>

			emit NA
<}

			if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} & 2]} {>

			emit Japan
<}

			if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} & 4]} {>

			emit Rest_of_World
<}

			if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} & 2147483648]} {>

			emit Manufacturer
<}

<}

		if {[N lelong [I 280 long 0 - 0 65376] 0 0 {} {} > 0]} {>

		emit {\b)}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq XIP0]} {>

emit {XIP, Microsoft Xbox data}
<}
} {
if {[S string 0 0 {} {} eq XTF0]} {>

emit {XTF, Microsoft Xbox data}
<}
} {
if {[S string 0 0 {} {} eq \x01ZZZZZ\x01]} {>

emit {3DO "Opera" file system}
<}
} {
if {[S string 0 0 {} {} eq GBS]} {>

emit {Nintendo Gameboy Music/Audio Data}

if {[S string 16 0 {} {} > \0]} {>

emit {("%s" by}
<}

if {[S string 48 0 {} {} > \0]} {>

emit {%s, copyright}
<}

if {[S string 80 0 {} {} > \0]} {>

emit %s),
<}

if {[N byte 3 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {%d tracks}
<}

<}
} {
if {[S string 0 0 {} {} eq PPF30]} {>

emit {Playstation Patch File version 3.0}

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {\b, PPF 1.0 patch};<} 1 {>;emit {\b, PPF 2.0 patch};<} 2 {>;emit {\b, PPF 3.0 patch}

	switch -- [Nv byte 56 0 {} {}] 0 {>;emit {\b, Imagetype BIN (any)};<} 1 {>;emit {\b, Imagetype GI (PrimoDVD)};<} 
<

	switch -- [Nv byte 57 0 {} {}] 0 {>;emit {\b, Blockcheck disabled};<} 1 {>;emit {\b, Blockcheck enabled};<} 
<

	switch -- [Nv byte 58 0 {} {}] 0 {>;emit {\b, Undo data not available};<} 1 {>;emit {\b, Undo data available};<} 
<
;<} 
<

if {[S string 6 0 {} {} x {}]} {>

emit {\b, description: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq PPF20]} {>

emit {Playstation Patch File version 2.0}

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {\b, PPF 1.0 patch};<} 1 {>;emit {\b, PPF 2.0 patch}

	if {[N lelong 56 0 0 {} {} > 0]} {>

	emit {\b, size of file to patch %d}
<}
;<} 
<

if {[S string 6 0 {} {} x {}]} {>

emit {\b, description: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq PPF10]} {>

emit {Playstation Patch File version 1.0}

if {[N byte 5 0 0 {} {} == 0]} {>

emit {\b, Simple Encoding}
<}

if {[S string 6 0 {} {} x {}]} {>

emit {\b, description: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq SMV\x1A]} {>

emit {SNES9x input recording}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {\b, version %d}
<}

if {[N lelong 4 0 0 {} {} < 5]} {>

	if {[N ledate 8 0 0 {} {} x {}]} {>

	emit {\b, recorded at %s}
<}

	if {[N lelong 12 0 0 {} {} > 0]} {>

	emit {\b, rerecorded %d times}
<}

	if {[N lelong 16 0 0 {} {} x {}]} {>

	emit {\b, %d frames long}
<}

	if {[N byte 20 0 0 {} {} > 0]} {>

	emit {\b, data for controller(s):}

		if {[N byte 20 0 0 {} {} & 1]} {>

		emit {#1}
<}

		if {[N byte 20 0 0 {} {} & 2]} {>

		emit {#2}
<}

		if {[N byte 20 0 0 {} {} & 4]} {>

		emit {#3}
<}

		if {[N byte 20 0 0 {} {} & 8]} {>

		emit {#4}
<}

		if {[N byte 20 0 0 {} {} & 16]} {>

		emit {#5}
<}

<}

	if {[N byte 21 0 0 {} {} ^ 1]} {>

	emit {\b, begins from snapshot}
<}

	if {[N byte 21 0 0 {} {} & 1]} {>

	emit {\b, begins from reset}
<}

	if {[N byte 21 0 0 {} {} ^ 2]} {>

	emit {\b, NTSC standard}
<}

	if {[N byte 21 0 0 {} {} & 2]} {>

	emit {\b, PAL standard}
<}

	if {[N byte 23 0 0 {} {} & 1]} {>

	emit {\b, settings:}

		if {[N lelong 4 0 0 {} {} < 4]} {>

			if {[N byte 23 0 0 {} {} & 2]} {>

			emit WIP1Timing
<}

<}

		if {[N byte 23 0 0 {} {} & 4]} {>

		emit Left+Right
<}

		if {[N byte 23 0 0 {} {} & 8]} {>

		emit VolumeEnvX
<}

		if {[N byte 23 0 0 {} {} & 16]} {>

		emit FakeMute
<}

		if {[N byte 23 0 0 {} {} & 32]} {>

		emit SyncSound
<}

		if {[N lelong 4 0 0 {} {} > 3]} {>

			if {[N byte 23 0 0 {} {} & 128]} {>

			emit NoCPUShutdown
<}

<}

<}

	if {[N lelong 4 0 0 {} {} < 4]} {>

		if {[N lelong 24 0 0 {} {} > 35]} {>

			if {[N leshort 32 0 0 {} {} != 0]} {>

				if {[S lestring16 32 0 {} {} x {}]} {>

				emit {\b, metadata: "%s"}
<}

<}

<}

<}

	if {[N lelong 4 0 0 {} {} > 3]} {>

		if {[N byte 36 0 0 {} {} > 0]} {>

		emit {\b, port 1:}

			switch -- [Nv byte 36 0 {} {}] 1 {>;emit joypad;<} 2 {>;emit mouse;<} 3 {>;emit SuperScope;<} 4 {>;emit Justifier;<} 5 {>;emit multitap;<} 
<

<}

		if {[N byte 36 0 0 {} {} > 0]} {>

		emit {\b, port 2:}

			switch -- [Nv byte 37 0 {} {}] 1 {>;emit joypad;<} 2 {>;emit mouse;<} 3 {>;emit SuperScope;<} 4 {>;emit Justifier;<} 5 {>;emit multitap;<} 
<

<}

		if {[N lelong 24 0 0 {} {} > 67]} {>

			if {[N leshort 64 0 0 {} {} != 0]} {>

				if {[S lestring16 64 0 {} {} x {}]} {>

				emit {\b, metadata: "%s"}
<}

<}

<}

<}

	if {[N byte 23 0 0 {} {} & 64]} {>

	emit {\b, ROM:}

		if {[N lelong [I 24 lelong 0 - 0 26] 0 0 {} {} x {}]} {>

		emit {CRC32 0x%08x}
<}

		if {[S string [I 24 lelong 0 - 0 23] 0 {} {} x {}]} {>

		emit {"%s"}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq SCVM]} {>

emit {ScummVM savegame}

if {[S string 12 0 {} {} > \0]} {>

emit {"%s"}
<}

<}
} {
if {[N belong 28 0 0 {} {} == 3258163005]} {>

emit {Nintendo GameCube disc image:}
U 240 nintendo-gcn-disc-common

<}
} {
if {[S string 0 0 {} {} eq WBFS]} {>

if {[N belong 536 0 0 {} {} == 1562156707]} {>

emit {Nintendo Wii disc image (WBFS format):}
U 240 nintendo-gcn-disc-common

<}

<}
} {
if {[S string 256 0 {} {} eq NCSD]} {>

if {[N lequad 280 0 0 {} {} == 0]} {>

emit {Nintendo 3DS Game Card image}
U 240 nintendo-3ds-NCCH

	switch -- [Nv byte 397 0 {} {}] 0 {>;emit {(inner device)};<} 1 {>;emit (Card1);<} 2 {>;emit (Card2);<} 3 {>;emit {(extended device)};<} 
<

<}

switch -- [Nv bequad 280 0 {} {}] 72622751638093824 {>;emit {Nintendo 3DS eMMC dump (Old3DS)};<} 72622751654871040 {>;emit {Nintendo 3DS eMMC dump (New3DS)};<} 
<

<}
} {
if {[S string 256 0 {} {} eq NCCH]} {>

emit {Nintendo 3DS}

switch -- [Nv byte 397 0 & 2] 0 {>;emit {File Archive (CFA)};<} 2 {>;emit {Executable Image (CXI)};<} 
<
U 240 nintendo-3ds-NCCH

<}
} {
if {[S string 0 0 {} {} eq SMDH]} {>

emit {Nintendo 3DS SMDH file}

if {[N leshort 520 0 0 {} {} != 0]} {>

	if {[S lestring16 520 0 {} {} x {}]} {>

	emit {\b: "%.128s"}
<}

	if {[N leshort 904 0 0 {} {} != 0]} {>

		if {[S lestring16 904 0 {} {} x {}]} {>

		emit {by %.128s}
<}

<}

<}

if {[N leshort 520 0 0 {} {} == 0]} {>

	if {[N leshort 8 0 0 {} {} != 0]} {>

		if {[S lestring16 8 0 {} {} x {}]} {>

		emit {\b: "%.128s"}
<}

		if {[N leshort 392 0 0 {} {} != 0]} {>

			if {[S lestring16 392 0 {} {} x {}]} {>

			emit {by %.128s}
<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq 3DSX]} {>

emit {Nintendo 3DS Homebrew Application (3DSX)}
<}
} {
if {[N byte 0 0 0 {} {} > 0]} {>

if {[N byte 0 0 0 {} {} < 3]} {>

	if {[S string 1 0 {} {} eq ATARI7800]} {>

	emit {Atari 7800 ROM image}

		if {[S string 17 0 {} {} > \0]} {>

		emit {\b: "%.32s"}
<}

		switch -- [Nv byte 57 0 {} {}] 0 {>;emit (NTSC);<} 1 {>;emit (PAL);<} 
<

		if {[N byte 54 0 0 & 1 == 1]} {>

		emit (POKEY)
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq g\ GCE]} {>

emit {Vectrex ROM image}

if {[S string 17 0 {} {} > \0]} {>

emit {\b: "%.16s"}
<}

<}
} {
if {[S search 0 0 {} 8192 eq \"libhdr\"]} {>

emit {BCPL source text}
mime text/x-bcpl

<}
} {
if {[S search 0 0 {} 8192 eq \"LIBHDR\"]} {>

emit {BCPL source text}
mime text/x-bcpl

<}
} {
if {[S regex 0 0 {} {} eq ^\#include]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^char\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^double\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^extern\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^float\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^struct\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^union\[\ \t\n\]+]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S search 0 0 {} 8192 eq main(]} {>

emit {C source text}
mime text/x-c

<}
} {
if {[S regex 0 0 {} {} eq ^template\[\ \t\]+<.*>\[\ \t\n\]+]} {>

emit {C++ source text}
mime text/x-c++

<}
} {
if {[S regex 0 0 {} {} eq ^virtual\[\ \t\n\]+]} {>

emit {C++ source text}
mime text/x-c++

<}
} {
if {[S regex 0 0 {} {} eq ^class\[\ \t\n\]+]} {>

emit {C++ source text}
mime text/x-c++

<}
} {
if {[S regex 0 0 {} {} eq ^public:]} {>

emit {C++ source text}
mime text/x-c++

<}
} {
if {[S regex 0 0 {} {} eq ^private:]} {>

emit {C++ source text}
mime text/x-c++

<}
} {
if {[S string 0 0 {} {} eq cscope]} {>

emit {cscope reference data}

if {[S string 7 0 {} {} x {}]} {>

emit {version %.2s}
<}

if {[S string 7 0 {} {} > 14]} {>

	if {[S search 10 0 {} 100 eq \ -q\ ]} {>

	emit {with inverted index}
<}

<}

if {[S search 10 0 {} 100 eq \ -c\ ]} {>

emit {text (non-compressed)}
<}

<}
} {
if {[S string 0 0 {} {} eq \366\366\366\366]} {>

emit {PC formatted floppy with no filesystem}
<}
} {
if {[N beshort 508 0 0 {} {} == 55998]} {>

if {[N long 504 0 0 {} {} > 0]} {>

emit {Sun disk label}

	if {[S string 0 0 {} {} x {}]} {>

	emit '%s

		if {[S string 31 0 {} {} > \0]} {>

		emit {\b%s}

			if {[S string 63 0 {} {} > \0]} {>

			emit {\b%s}

				if {[S string 95 0 {} {} > \0]} {>

				emit {\b%s}
<}

<}

<}

<}

	if {[S string 0 0 {} {} x {}]} {>

	emit {\b'}
<}

	if {[N short 476 0 0 {} {} > 0]} {>

	emit {%d rpm,}
<}

	if {[N short 478 0 0 {} {} > 0]} {>

	emit {%d phys cys,}
<}

	if {[N short 480 0 0 {} {} > 0]} {>

	emit {%d alts/cyl,}
<}

	if {[N short 486 0 0 {} {} > 0]} {>

	emit {%d interleave,}
<}

	if {[N short 488 0 0 {} {} > 0]} {>

	emit {%d data cyls,}
<}

	if {[N short 490 0 0 {} {} > 0]} {>

	emit {%d alt cyls,}
<}

	if {[N short 492 0 0 {} {} > 0]} {>

	emit {%d heads/partition,}
<}

	if {[N short 494 0 0 {} {} > 0]} {>

	emit {%d sectors/track,}
<}

	if {[N long 500 0 0 {} {} > 0]} {>

	emit {start cyl %d,}
<}

	if {[N long 504 0 0 {} {} x {}]} {>

	emit {%d blocks}
<}

<}

if {[N belong 512 0 0 & 16777215 == 196871]} {>

emit {\b, boot block present}
<}

<}
} {
if {[Sx string 0 0 {} {} eq SBMBAKUP_]} {>

emit {Smart Boot Manager backup file}

if {[Sx string 9 0 {} {} x {}]} {>

emit {\b, version %-5.5s}

	if {[Sx string 14 0 {} {} eq _]} {>

		if {[S string 15 0 {} {} x {}]} {>

		emit %-.1s

			if {[S string 16 0 {} {} eq _]} {>

			emit {\b.}

				if {[S string 17 0 {} {} x {}]} {>

				emit {\b%-.1s}

					if {[S string 18 0 {} {} eq _]} {>

					emit {\b.}

						if {[S string 19 0 {} {} x {}]} {>

						emit {\b%-.1s}
<}

<}

<}

<}

<}

		if {[N byte 22 0 0 {} {} == 0]} {>

			if {[N byte 21 0 0 {} {} x {}]} {>

			emit {\b, from drive 0x%x}
<}

<}

		if {[N byte 22 0 0 {} {} > 0]} {>

			if {[S string 21 0 {} {} x {}]} {>

			emit {\b, from drive %s}
<}

<}

		if {[Sx search 535 0 {} 17 eq \x55\xAA]} {>

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq DOSEMU\0]} {>

if {[N leshort 638 0 0 {} {} == 43605]} {>

	if {[N byte 19 0 0 {} {} == 128]} {>

		if {[N byte [I 19 byte 0 - 0 1] 0 0 {} {} == 0]} {>

		emit {DOS Emulator image}

			if {[N lelong 7 0 0 {} {} > 0]} {>

			emit {\b, %u heads}
<}

			if {[N lelong 11 0 0 {} {} > 0]} {>

			emit {\b, %d sectors/track}
<}

			if {[N lelong 15 0 0 {} {} > 0]} {>

			emit {\b, %d cylinders}
<}

<}

<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq PNCIHISK\0]} {>

emit {Norton Utilities disc image data}

if {[Sx search 509 0 {} 1026 eq \x55\xAA\xeb]} {>

<}

<}
} {
if {[S string 0 0 {} {} eq PNCIUNDO]} {>

emit {Norton Disk Doctor UnDo file}
<}
} {
if {[S search 30 0 {} 481 eq \x55\xAA]} {>

if {[N leshort 11 0 0 {} {} < 512]} {>

	if {[N leshort [I 11 leshort 0 - 0 2] 0 0 {} {} == 43605]} {>

	emit {DOS/MBR boot sector}
<}

<}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {DOS/MBR boot sector}
<}

<}
} {
if {[S string 0 0 {} {} eq FATX]} {>

emit {FATX filesystem data}
<}
} {
if {[S string 0 0 {} {} eq -rom1fs-]} {>

emit {romfs filesystem, version 1}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {%d bytes,}
<}

if {[S string 16 0 {} {} x {}]} {>

emit {named %s.}
<}

<}
} {
if {[S string 395 0 {} {} eq OS/2]} {>

emit {OS/2 Boot Manager}
<}
} {
if {[Nx lequad 0 0 0 & 10416825940200975098 == 10416825940192586490]} {>

if {[Sx search 631 0 {} 689 eq ISOLINUX\ ]} {>

emit {isolinux Loader}

	if {[Sx string [R 0] 0 {} {} x {}]} {>

	emit {(version %-4.4s)}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq LDLINUX\ SYS\ ]} {>

emit {SYSLINUX loader}

if {[S string 12 0 {} {} x {}]} {>

emit {(older version %-4.4s)}
<}

<}
} {
if {[S string 0 0 {} {} eq \r\nSYSLINUX\ ]} {>

emit {SYSLINUX loader}

if {[S string 11 0 {} {} x {}]} {>

emit {(version %-4.4s)}
<}

<}
} {
if {[N lelong 0 0 0 & 2156960747 == 9443563]} {>

if {[S search 434 0 {} 47 eq Boot\ failed]} {>

	if {[S search 482 0 {} 132 eq \0LDLINUX\ SYS]} {>

	emit {Syslinux bootloader (version 2.13 or older)}
<}

	if {[N byte 1 0 0 {} {} == 88]} {>

	emit {Syslinux bootloader (version 3.0-3.9)}
<}

<}

if {[S search 459 0 {} 30 eq Boot\ error\r\n\0]} {>

	if {[N byte 1 0 0 {} {} == 88]} {>

	emit {Syslinux bootloader (version 3.10 or newer)}
<}

<}

<}
} {
if {[Sx search 16 0 {} 4 eq \xbf\x00\x06\xb9\x00\x01]} {>

if {[Sx search 94 0 {} 249 eq Missing\ operating\ system]} {>

	if {[S search 408 0 {} 4 eq HD1/\0]} {>

<}

	if {[Sx default 408 0 {} {} x {}]} {>

		if {[Sx search 250 0 {} 118 eq \0Operating\ system\ load]} {>

		emit {SYSLINUX MBR}

			if {[Sx search 292 0 {} 98 eq error]} {>

				if {[Sx string [R 0] 0 {} {} eq \r]} {>

				emit {(version 3.35 or older)}
<}

				if {[Sx string [R 0] 0 {} {} eq .\r]} {>

				emit {(version 3.52 or newer)}
<}

				if {[Sx default [R 0] 0 {} {} x {}]} {>

				emit {(version 3.36-3.51 )}
<}

<}

<}

<}

<}

if {[S search 368 0 {} 106 eq \0Disk\ error\ on\ boot\r\n]} {>

emit {SYSLINUX GPT-MBR}

	if {[S search 156 0 {} 10 eq \0Boot\ partition\ not\ found\r\n]} {>

		if {[S search 270 0 {} 10 eq \0OS\ not\ bootable\r\n]} {>

		emit {(version 3.86 or older)}
<}

<}

	if {[S search 174 0 {} 10 eq \0Missing\ OS\r\n]} {>

		if {[S search 189 0 {} 10 eq \0Multiple\ active\ partitions\r\n]} {>

		emit {(version 4.00 or newer)}
<}

<}

<}

<}
} {
if {[N bequad 0 0 0 & 16958463276293816320 == 16958462726538002432]} {>

if {[N bequad [I 1 byte 0 + 0 2] 0 0 {} {} == 18028402503091929230]} {>

	if {[S string 376 0 {} {} eq No\ operating\ system\r\n\0]} {>

		if {[S string 398 0 {} {} eq Disk\ error\r\n\0FDD\0HDD\0]} {>

			if {[S string 419 0 {} {} eq \ EBIOS\r\n\0]} {>

			emit {AdvanceMAME mbr}
<}

<}

<}

<}

<}
} {
if {[Nx lequad 0 0 0 & 14851535477856547324 == 10232179249133924860]} {>

if {[Sx string [I 444 leshort 0 0 0 0] 0 {} {} eq NDTmbr]} {>

	if {[Sx string [R -14] 0 {} {} eq 1234F\0]} {>

	emit {Turton mbr (}

		if {[N byte [I 444 leshort 0 + 0 7] 0 0 {} {} x {}]} {>

		emit {\b%u<=}
<}

		if {[N byte [I 444 leshort 0 + 0 9] 0 0 {} {} x {}]} {>

		emit {\bVersion<=%u}
<}

		if {[N byte [I 444 leshort 0 + 0 8] 0 0 & 1 == 1]} {>

		emit {\b,Y2K-Fix}
<}

		if {[N byte [I 444 leshort 0 + 0 8] 0 0 & 2 == 2]} {>

		emit {\b,TestDisk}
<}

		if {[N byte [I 444 leshort 0 + 0 9] 0 0 {} {} < 2]} {>

			if {[N byte [I 444 leshort 0 + 0 12] 0 0 {} {} != 18]} {>

			emit {\b,%u/18 seconds}
<}

			if {[N byte [I 444 leshort 0 + 0 13] 0 0 {} {} < 2]} {>

			emit {\b,floppy 0x%x}
<}

			if {[N byte [I 444 leshort 0 + 0 13] 0 0 {} {} > 1]} {>

				if {[N byte [I 444 leshort 0 + 0 13] 0 0 {} {} != 128]} {>

				emit {\b,drive 0x%x}
<}

<}

<}

		if {[N byte [I 444 leshort 0 + 0 9] 0 0 {} {} > 1]} {>

			if {[N leshort [I 444 leshort 0 + 0 12] 0 0 {} {} != 18]} {>

			emit {\b,%u/18 seconds}
<}

			if {[N byte [I 444 leshort 0 + 0 14] 0 0 {} {} < 2]} {>

			emit {\b,floppy 0x%x}
<}

			if {[N byte [I 444 leshort 0 + 0 14] 0 0 {} {} > 1]} {>

				if {[N byte [I 444 leshort 0 + 0 14] 0 0 {} {} != 128]} {>

				emit {\b,drive 0x%x}
<}

<}

<}

		if {[N byte 0 0 0 {} {} x {}]} {>

		emit {\b)}
<}

<}

<}

<}
} {
if {[N leshort 512 0 0 {} {} == 28906]} {>

if {[N beshort 518 0 0 {} {} > 768]} {>

	if {[N byte 530 0 0 {} {} > 41]} {>

		if {[N byte 531 0 0 {} {} > 41]} {>

			if {[N byte 531 0 0 {} {} > 41]} {>

			emit {GRand Unified Bootloader}
<}

			if {[N byte 535 0 0 {} {} == 255]} {>

			emit stage1_5
<}

			if {[N byte 535 0 0 {} {} < 255]} {>

			emit stage2
<}

			if {[N byte 518 0 0 {} {} x {}]} {>

			emit {\b version %u}
<}

			if {[N byte 519 0 0 {} {} x {}]} {>

			emit {\b.%u}
<}

			if {[N lelong 520 0 0 {} {} < 16777215]} {>

			emit {\b, installed partition %u}
<}

			if {[N lelong 520 0 0 {} {} > 16777215]} {>

			emit {\b, installed partition %u}
<}

			if {[N lelong 524 0 0 & 774897664 == 774897664]} {>

				if {[N byte 524 0 0 {} {} x {}]} {>

				emit {\b, identifier 0x%x}
<}

				if {[N byte 525 0 0 {} {} > 0]} {>

				emit {\b, LBA flag 0x%x}
<}

				if {[S string 526 0 {} {} > \0]} {>

				emit {\b, GRUB version %-s}

					if {[N long 533 0 0 {} {} == 4294967295]} {>

						if {[S string 537 0 {} {} > \0]} {>

						emit {\b, configuration file %-s}
<}

<}

					if {[N long 533 0 0 {} {} != 4294967295]} {>

						if {[S string 533 0 {} {} > \0]} {>

						emit {\b, configuration file %-s}
<}

<}

<}

<}

			if {[N lelong 524 0 0 & 774897664 != 774897664]} {>

				if {[N lelong 524 0 0 {} {} > 0]} {>

				emit {\b, saved entry %d}
<}

				if {[N byte 528 0 0 {} {} x {}]} {>

				emit {\b, identifier 0x%x}
<}

				if {[N byte 529 0 0 {} {} > 0]} {>

				emit {\b, LBA flag 0x%x}
<}

				if {[S string 530 0 {} {} > \0]} {>

				emit {\b, GRUB version %-s}
<}

				if {[N long 535 0 0 {} {} == 4294967295]} {>

					if {[S string 539 0 {} {} > \0]} {>

					emit {\b, configuration file %-s}
<}

<}

				if {[N long 535 0 0 {} {} != 4294967295]} {>

					if {[S string 535 0 {} {} > \0]} {>

					emit {\b, configuration file %-s}
<}

<}

<}

<}

<}

<}

<}
} {
if {[Nx lelong 0 0 0 & 2151678185 == 233]} {>

if {[Nx leshort 11 0 0 & 31 == 0]} {>

	if {[Nx leshort 11 0 0 {} {} < 32769]} {>

		if {[Nx leshort 11 0 0 {} {} > 31]} {>

			if {[Nx byte 21 0 0 & 240 == 240]} {>

				switch -- [Nv byte 0 0 {} {}] -21 {>;emit {DOS/MBR boot sector}

					if {[N byte 1 0 0 {} {} x {}]} {>

					emit {\b, code offset 0x%x+2}
<}
;<} -23 {>;
					if {[N leshort 1 0 0 {} {} x {}]} {>

					emit {\b, code offset 0x%x+3}
<}
;<} 
<

				if {[S string 3 0 {} {} > \0]} {>

				emit {\b, OEM-ID "%-.8s"}

					if {[S string 8 0 {} {} eq IHC]} {>

					emit {\b cached by Windows 9M}
<}

<}

				if {[N leshort 11 0 0 {} {} > 512]} {>

				emit {\b, Bytes/sector %u}
<}

				if {[N leshort 11 0 0 {} {} < 512]} {>

				emit {\b, Bytes/sector %u}
<}

				if {[N byte 13 0 0 {} {} > 1]} {>

				emit {\b, sectors/cluster %u}
<}

				if {[S string 82 0 c {} eq fat32]} {>

					if {[N leshort 14 0 0 {} {} != 32]} {>

					emit {\b, reserved sectors %u}
<}

<}

				if {[S string 82 0 c {} ne fat32]} {>

					if {[N leshort 14 0 0 {} {} > 1]} {>

					emit {\b, reserved sectors %u}
<}

<}

				if {[N byte 16 0 0 {} {} > 2]} {>

				emit {\b, FATs %u}
<}

				switch -- [Nvx byte 16 0 {} {}] 1 {>;emit {\b, FAT  %u};<} 0 {>;
					if {[Nx leshort 17 0 0 {} {} == 0]} {>

						if {[Nx leshort 19 0 0 {} {} == 0]} {>

							if {[Nx leshort 22 0 0 {} {} == 0]} {>

							emit {\b; NTFS}

								if {[N leshort 24 0 0 {} {} > 0]} {>

								emit {\b, sectors/track %u}
<}

								if {[N lelong 36 0 0 {} {} != 8388736]} {>

								emit {\b, physical drive 0x%x}
<}

								if {[N lequad 40 0 0 {} {} > 0]} {>

								emit {\b, sectors %lld}
<}

								if {[N lequad 48 0 0 {} {} > 0]} {>

								emit {\b, $MFT start cluster %lld}
<}

								if {[N lequad 56 0 0 {} {} > 0]} {>

								emit {\b, $MFTMirror start cluster %lld}
<}

								if {[N lelong 64 0 0 {} {} < 256]} {>

									if {[N lelong 64 0 0 {} {} < 128]} {>

									emit {\b, clusters/RecordSegment %d}
<}

									if {[N byte 64 0 0 {} {} > 127]} {>

									emit {\b, bytes/RecordSegment 2^(-1*%i)}
<}

<}

								if {[N lelong 68 0 0 {} {} < 256]} {>

									if {[N lelong 68 0 0 {} {} < 128]} {>

									emit {\b, clusters/index block %d}
<}

									if {[N byte 68 0 0 {} {} > 127]} {>

									emit {\b, bytes/index block 2^(-1*%i)}
<}

<}

								if {[N lequad 72 0 0 {} {} x {}]} {>

								emit {\b, serial number 0%llx}
<}

								if {[N lelong 80 0 0 {} {} > 0]} {>

								emit {\b, checksum 0x%x}
<}

								if {[Nx lelong 600 0 0 & 37008 == 37008]} {>

<}

<}

<}

<}
;<} 
<

				if {[N byte 16 0 0 {} {} > 0]} {>

<}

				if {[N leshort 17 0 0 {} {} > 0]} {>

				emit {\b, root entries %u}
<}

				if {[N leshort 19 0 0 {} {} > 0]} {>

				emit {\b, sectors %u (volumes <=32 MB) }
<}

				if {[N byte 21 0 0 {} {} > 240]} {>

				emit {\b, Media descriptor 0x%x}
<}

				if {[N byte 21 0 0 {} {} < 240]} {>

				emit {\b, Media descriptor 0x%x}
<}

				if {[N leshort 22 0 0 {} {} > 0]} {>

				emit {\b, sectors/FAT %u}
<}

				if {[N leshort 24 0 0 {} {} x {}]} {>

				emit {\b, sectors/track %u}
<}

				if {[N byte 26 0 0 {} {} > 2]} {>

				emit {\b, heads %u}
<}

				if {[N byte 26 0 0 {} {} == 1]} {>

				emit {\b, heads %u}
<}

				if {[N leshort 11 0 0 {} {} > 32]} {>

					if {[N byte 38 0 0 & 86 == 0]} {>

						if {[N lelong 28 0 0 {} {} > 0]} {>

						emit {\b, hidden sectors %u}
<}

						if {[N lelong 32 0 0 {} {} > 0]} {>

						emit {\b, sectors %u (volumes > 32 MB) }
<}

						if {[S string 82 0 c {} ne fat32]} {>

							if {[N byte 36 0 0 {} {} != 128]} {>

								if {[N byte 36 0 0 {} {} != 0]} {>

								emit {\b, physical drive 0x%x}
<}

<}

							if {[N byte 37 0 0 {} {} > 0]} {>

							emit {\b, reserved 0x%x}
<}

							if {[N byte 38 0 0 {} {} != 41]} {>

							emit {\b, dos < 4.0 BootSector (0x%x)}
<}

							if {[N byte 38 0 0 & 254 == 40]} {>

								if {[N lelong 39 0 0 {} {} x {}]} {>

								emit {\b, serial number 0x%x}
<}

<}

							if {[N byte 38 0 0 {} {} == 41]} {>

								if {[S string 43 0 {} {} < NO\ NAME]} {>

								emit {\b, label: "%11.11s"}
<}

								if {[S string 43 0 {} {} > NO\ NAME]} {>

								emit {\b, label: "%11.11s"}
<}

								if {[S string 43 0 {} {} eq NO\ NAME]} {>

								emit {\b, unlabeled}
<}

<}

<}

<}

<}

				if {[S string 82 0 c {} ne fat32]} {>

					if {[S string 54 0 {} {} eq FAT12]} {>

					emit {\b, FAT (12 bit)}
<}

					if {[S string 54 0 {} {} eq FAT16]} {>

					emit {\b, FAT (16 bit)}
<}

					if {[S default 54 0 {} {} x {}]} {>

						if {[N byte 21 0 0 {} {} < 240]} {>

						emit {\b, FAT (12 bit by descriptor)}
<}

						switch -- [Nv byte 21 0 {} {}] -16 {>;
							if {[N lelong 32 0 0 {} {} > 65535]} {>

							emit {\b, FAT (16 bit by descriptor+sectors)}
<}

							if {[S default 32 0 {} {} x {}]} {>

							emit {\b, FAT (12 bit by descriptor+sectors)}
<}
;<} -8 {>;
							if {[N bequad 19 0 0 {} {} == 14988815201611612161]} {>

							emit {\b, FAT (12 bit by descriptor+geometry)}
<}

							if {[S default 19 0 {} {} x {}]} {>

							emit {\b, FAT (1Y bit by descriptor)}
<}
;<} -6 {>;
							if {[N bequad 19 0 0 {} {} == 9224209873305600001]} {>

							emit {\b, FAT (12 bit by descriptor+geometry)}
<}

							if {[S default 19 0 {} {} x {}]} {>

							emit {\b, FAT (1Y bit by descriptor)}
<}
;<} 
<

						if {[S default 21 0 {} {} x {}]} {>

						emit {\b, FAT (12 bit by descriptor)}
<}

<}

<}

				if {[S string 82 0 c {} eq fat32]} {>

				emit {\b, FAT (32 bit)}

					if {[N lelong 36 0 0 {} {} x {}]} {>

					emit {\b, sectors/FAT %u}
<}

					if {[N leshort 40 0 0 {} {} > 0]} {>

					emit {\b, extension flags 0x%x}
<}

					if {[N leshort 42 0 0 {} {} > 0]} {>

					emit {\b, fsVersion %u}
<}

					if {[N lelong 44 0 0 {} {} > 2]} {>

					emit {\b, rootdir cluster %u}
<}

					if {[N leshort 48 0 0 {} {} > 1]} {>

					emit {\b, infoSector %u}
<}

					if {[N leshort 48 0 0 {} {} < 1]} {>

					emit {\b, infoSector %u}
<}

					switch -- [Nv leshort 50 0 {} {}] -1 {>;emit {\b, no Backup boot sector};<} 0 {>;emit {\b, no Backup boot sector};<} 
<

					if {[S default 50 0 {} {} x {}]} {>

						if {[N leshort 50 0 0 {} {} x {}]} {>

						emit {\b, Backup boot sector %u}
<}

<}

					if {[N lelong 52 0 0 {} {} > 0]} {>

					emit {\b, reserved1 0x%x}
<}

					if {[N lelong 56 0 0 {} {} > 0]} {>

					emit {\b, reserved2 0x%x}
<}

					if {[N lelong 60 0 0 {} {} > 0]} {>

					emit {\b, reserved3 0x%x}
<}

					if {[N byte 64 0 0 {} {} != 128]} {>

						if {[N byte 64 0 0 {} {} > 0]} {>

						emit {\b, physical drive 0x%x}
<}

<}

					if {[N byte 65 0 0 {} {} > 0]} {>

					emit {\b, reserved 0x%x}
<}

					if {[N byte 66 0 0 {} {} != 41]} {>

					emit {\b, dos < 4.0 BootSector (0x%x)}
<}

					if {[N byte 66 0 0 {} {} == 41]} {>

						if {[N lelong 67 0 0 {} {} x {}]} {>

						emit {\b, serial number 0x%x}
<}

						if {[S string 71 0 {} {} < NO\ NAME]} {>

						emit {\b, label: "%11.11s"}
<}

						if {[S string 71 0 {} {} > NO\ NAME]} {>

						emit {\b, label: "%11.11s"}
<}

						if {[S string 71 0 {} {} eq NO\ NAME]} {>

						emit {\b, unlabeled}
<}

<}

<}

				if {[N byte 21 0 0 {} {} != 248]} {>

					if {[S string 54 0 {} {} ne FAT16]} {>

						if {[N lelong [I 11 leshort 0 0 0 0] 0 0 & 16777200 == 16777200]} {>

						emit {\b, followed by FAT}
						mime application/x-ima

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[N lelong 86 0 0 & 4294905855 == 2425357035]} {>

if {[N lelong [I 0 leshort 0 * 0 2] 0 0 & 4294967040 == 262144]} {>

	if {[S lestring16 2 0 {} {} x {}]} {>

	emit {Microsoft Windows XP/VISTA bootloader %-5.5s}
<}

	if {[S string 18 0 {} {} eq \$]} {>

		if {[S lestring16 12 0 {} {} x {}]} {>

		emit {\b%-2.2s}
<}

<}

<}

<}
} {
if {[N lelong 9564 0 0 {} {} == 72020]} {>

emit {Unix Fast File system [v1] (little-endian),}

if {[S string 8404 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[N ledate 8224 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[N byte 8401 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[N lelong 8228 0 0 {} {} x {}]} {>

emit {number of blocks %d,}
<}

if {[N lelong 8232 0 0 {} {} x {}]} {>

emit {number of data blocks %d,}
<}

if {[N lelong 8236 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[N lelong 8240 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[N lelong 8244 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[N lelong 8252 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

if {[N lelong 8256 0 0 {} {} x {}]} {>

emit {rotational delay %dms,}
<}

if {[N lelong 8260 0 0 {} {} x {}]} {>

emit {disk rotational speed %drps,}
<}

switch -- [Nv lelong 8320 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[Nx lelong 42332 0 0 {} {} == 424935705]} {>

emit {Unix Fast File system [v2] (little-endian)}

if {[Sx string [R -1164] 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[Sx string [R -696] 0 {} {} > \0]} {>

emit {volume name %s,}
<}

if {[Nx leqldate [R -304] 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[Nx byte [R -1167] 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[Nx byte [R -1168] 0 0 {} {} x {}]} {>

emit {readonly flag %d,}
<}

if {[Nx lequad [R -296] 0 0 {} {} x {}]} {>

emit {number of blocks %lld,}
<}

if {[Nx lequad [R -288] 0 0 {} {} x {}]} {>

emit {number of data blocks %lld,}
<}

if {[Nx lelong [R -1332] 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[Nx lelong [R -1328] 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[Nx lelong [R -1324] 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[Nx lelong [R -180] 0 0 {} {} x {}]} {>

emit {average file size %d,}
<}

if {[Nx lelong [R -176] 0 0 {} {} x {}]} {>

emit {average number of files in dir %d,}
<}

if {[Nx lequad [R -272] 0 0 {} {} x {}]} {>

emit {pending blocks to free %lld,}
<}

if {[Nx lelong [R -264] 0 0 {} {} x {}]} {>

emit {pending inodes to free %d,}
<}

if {[Nx lequad [R -664] 0 0 {} {} x {}]} {>

emit {system-wide uuid %0llx,}
<}

if {[Nx lelong [R -1316] 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

switch -- [Nvx lelong [R -1248] 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[Nx lelong 66908 0 0 {} {} == 424935705]} {>

emit {Unix Fast File system [v2] (little-endian)}

if {[Sx string [R -1164] 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[Sx string [R -696] 0 {} {} > \0]} {>

emit {volume name %s,}
<}

if {[Nx leqldate [R -304] 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[Nx byte [R -1167] 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[Nx byte [R -1168] 0 0 {} {} x {}]} {>

emit {readonly flag %d,}
<}

if {[Nx lequad [R -296] 0 0 {} {} x {}]} {>

emit {number of blocks %lld,}
<}

if {[Nx lequad [R -288] 0 0 {} {} x {}]} {>

emit {number of data blocks %lld,}
<}

if {[Nx lelong [R -1332] 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[Nx lelong [R -1328] 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[Nx lelong [R -1324] 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[Nx lelong [R -180] 0 0 {} {} x {}]} {>

emit {average file size %d,}
<}

if {[Nx lelong [R -176] 0 0 {} {} x {}]} {>

emit {average number of files in dir %d,}
<}

if {[Nx lequad [R -272] 0 0 {} {} x {}]} {>

emit {pending blocks to free %lld,}
<}

if {[Nx lelong [R -264] 0 0 {} {} x {}]} {>

emit {pending inodes to free %d,}
<}

if {[Nx lequad [R -664] 0 0 {} {} x {}]} {>

emit {system-wide uuid %0llx,}
<}

if {[Nx lelong [R -1316] 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

switch -- [Nvx lelong [R -1248] 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[N belong 9564 0 0 {} {} == 72020]} {>

emit {Unix Fast File system [v1] (big-endian),}

if {[N belong 7168 0 0 {} {} == 1279345228]} {>

emit {Apple UFS Volume}

	if {[S string 7186 0 {} {} x {}]} {>

	emit {named %s,}
<}

	if {[N belong 7176 0 0 {} {} x {}]} {>

	emit {volume label version %d,}
<}

	if {[N bedate 7180 0 0 {} {} x {}]} {>

	emit {created on %s,}
<}

<}

if {[S string 8404 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[N bedate 8224 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[N byte 8401 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[N belong 8228 0 0 {} {} x {}]} {>

emit {number of blocks %d,}
<}

if {[N belong 8232 0 0 {} {} x {}]} {>

emit {number of data blocks %d,}
<}

if {[N belong 8236 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[N belong 8240 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[N belong 8244 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[N belong 8252 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

if {[N belong 8256 0 0 {} {} x {}]} {>

emit {rotational delay %dms,}
<}

if {[N belong 8260 0 0 {} {} x {}]} {>

emit {disk rotational speed %drps,}
<}

switch -- [Nv belong 8320 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[Nx belong 42332 0 0 {} {} == 424935705]} {>

emit {Unix Fast File system [v2] (big-endian)}

if {[Sx string [R -1164] 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[Sx string [R -696] 0 {} {} > \0]} {>

emit {volume name %s,}
<}

if {[Nx beqldate [R -304] 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[Nx byte [R -1167] 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[Nx byte [R -1168] 0 0 {} {} x {}]} {>

emit {readonly flag %d,}
<}

if {[Nx bequad [R -296] 0 0 {} {} x {}]} {>

emit {number of blocks %lld,}
<}

if {[Nx bequad [R -288] 0 0 {} {} x {}]} {>

emit {number of data blocks %lld,}
<}

if {[Nx belong [R -1332] 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[Nx belong [R -1328] 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[Nx belong [R -1324] 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[Nx belong [R -180] 0 0 {} {} x {}]} {>

emit {average file size %d,}
<}

if {[Nx belong [R -176] 0 0 {} {} x {}]} {>

emit {average number of files in dir %d,}
<}

if {[Nx bequad [R -272] 0 0 {} {} x {}]} {>

emit {pending blocks to free %lld,}
<}

if {[Nx belong [R -264] 0 0 {} {} x {}]} {>

emit {pending inodes to free %d,}
<}

if {[Nx bequad [R -664] 0 0 {} {} x {}]} {>

emit {system-wide uuid %0llx,}
<}

if {[Nx belong [R -1316] 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

switch -- [Nvx belong [R -1248] 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[Nx belong 66908 0 0 {} {} == 424935705]} {>

emit {Unix Fast File system [v2] (big-endian)}

if {[Sx string [R -1164] 0 {} {} x {}]} {>

emit {last mounted on %s,}
<}

if {[Sx string [R -696] 0 {} {} > \0]} {>

emit {volume name %s,}
<}

if {[Nx beqldate [R -304] 0 0 {} {} x {}]} {>

emit {last written at %s,}
<}

if {[Nx byte [R -1167] 0 0 {} {} x {}]} {>

emit {clean flag %d,}
<}

if {[Nx byte [R -1168] 0 0 {} {} x {}]} {>

emit {readonly flag %d,}
<}

if {[Nx bequad [R -296] 0 0 {} {} x {}]} {>

emit {number of blocks %lld,}
<}

if {[Nx bequad [R -288] 0 0 {} {} x {}]} {>

emit {number of data blocks %lld,}
<}

if {[Nx belong [R -1332] 0 0 {} {} x {}]} {>

emit {number of cylinder groups %d,}
<}

if {[Nx belong [R -1328] 0 0 {} {} x {}]} {>

emit {block size %d,}
<}

if {[Nx belong [R -1324] 0 0 {} {} x {}]} {>

emit {fragment size %d,}
<}

if {[Nx belong [R -180] 0 0 {} {} x {}]} {>

emit {average file size %d,}
<}

if {[Nx belong [R -176] 0 0 {} {} x {}]} {>

emit {average number of files in dir %d,}
<}

if {[Nx bequad [R -272] 0 0 {} {} x {}]} {>

emit {pending blocks to free %lld,}
<}

if {[Nx belong [R -264] 0 0 {} {} x {}]} {>

emit {pending inodes to free %d,}
<}

if {[Nx bequad [R -664] 0 0 {} {} x {}]} {>

emit {system-wide uuid %0llx,}
<}

if {[Nx belong [R -1316] 0 0 {} {} x {}]} {>

emit {minimum percentage of free blocks %d,}
<}

switch -- [Nvx belong [R -1248] 0 {} {}] 0 {>;emit {TIME optimization};<} 1 {>;emit {SPACE optimization};<} 
<

<}
} {
if {[N leshort 1080 0 0 {} {} == 61267]} {>

emit Linux

if {[N lelong 1100 0 0 {} {} x {}]} {>

emit {rev %d}
<}

if {[N leshort 1086 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

if {[N lelong 1116 0 0 {} {} ^ 4]} {>

emit {ext2 filesystem data}

	if {[N leshort 1082 0 0 {} {} ^ 1]} {>

	emit {(mounted or unclean)}
<}

<}

if {[N lelong 1116 0 0 {} {} & 4]} {>

	if {[N lelong 1120 0 0 {} {} < 64]} {>

		if {[N lelong 1124 0 0 {} {} < 8]} {>

		emit {ext3 filesystem data}
<}

		if {[N lelong 1124 0 0 {} {} > 7]} {>

		emit {ext4 filesystem data}
<}

<}

	if {[N lelong 1120 0 0 {} {} > 63]} {>

	emit {ext4 filesystem data}
<}

<}

if {[N belong 1128 0 0 {} {} x {}]} {>

emit {\b, UUID=%08x}
<}

if {[N beshort 1132 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N beshort 1134 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N beshort 1136 0 0 {} {} x {}]} {>

emit {\b-%04x}
<}

if {[N belong 1138 0 0 {} {} x {}]} {>

emit {\b-%08x}
<}

if {[N beshort 1142 0 0 {} {} x {}]} {>

emit {\b%04x}
<}

if {[S string 1144 0 {} {} > 0]} {>

emit {\b, volume name "%s"}
<}

if {[N lelong 1120 0 0 {} {} & 4]} {>

emit {(needs journal recovery)}
<}

if {[N leshort 1082 0 0 {} {} & 2]} {>

emit (errors)
<}

if {[N lelong 1120 0 0 {} {} & 1]} {>

emit (compressed)
<}

if {[N lelong 1120 0 0 {} {} & 64]} {>

emit (extents)
<}

if {[N lelong 1120 0 0 {} {} & 128]} {>

emit (64bit)
<}

if {[N lelong 1124 0 0 {} {} & 2]} {>

emit {(large files)}
<}

if {[N lelong 1124 0 0 {} {} & 8]} {>

emit {(huge files)}
<}

<}
} {
switch -- [Nv leshort 1040 0 {} {}] 4991 {>;
if {[N beshort 1026 0 0 {} {} < 100]} {>

<}

if {[N beshort 1026 0 0 {} {} > -1]} {>

emit {Minix filesystem, V1, 14 char names, %d zones}
<}

if {[S string 30 0 {} {} eq minix]} {>

emit {\b, bootable}
<}
;<} 5007 {>;
if {[N beshort 1026 0 0 {} {} < 100]} {>

<}

if {[N beshort 1026 0 0 {} {} > -1]} {>

emit {Minix filesystem, V1, 30 char names, %d zones}
<}

if {[S string 30 0 {} {} eq minix]} {>

emit {\b, bootable}
<}
;<} 
<
} {
switch -- [Nv beshort 1040 0 {} {}] 4991 {>;
if {[N beshort 1026 0 0 {} {} < 100]} {>

<}

if {[N beshort 1026 0 0 {} {} > -1]} {>

emit {Minix filesystem, V1 (big endian), %d zones}
<}

if {[S string 30 0 {} {} eq minix]} {>

emit {\b, bootable}
<}
;<} 5007 {>;
if {[N beshort 1026 0 0 {} {} < 100]} {>

<}

if {[N beshort 1026 0 0 {} {} > -1]} {>

emit {Minix filesystem, V1, 30 char names (big endian), %d zones}
<}

if {[S string 30 0 {} {} eq minix]} {>

emit {\b, bootable}
<}
;<} 
<
} {
if {[N belong 2048 0 0 {} {} == 1190930176]} {>

emit {Atari-ST Minix kernel image}

if {[S string 19 0 {} {} eq \240\005\371\005\0\011\0\2\0]} {>

emit {\b, 720k floppy}
<}

if {[S string 19 0 {} {} eq \320\002\370\005\0\011\0\1\0]} {>

emit {\b, 360k floppy}
<}

<}
} {
if {[S string 19 0 {} {} eq \320\002\360\003\0\011\0\1\0]} {>

emit {DOS floppy 360k}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, DOS/MBR hard disk boot sector}
<}

<}
} {
if {[S string 19 0 {} {} eq \240\005\371\003\0\011\0\2\0]} {>

emit {DOS floppy 720k}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, DOS/MBR hard disk boot sector}
<}

<}
} {
if {[S string 19 0 {} {} eq \100\013\360\011\0\022\0\2\0]} {>

emit {DOS floppy 1440k}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, DOS/MBR hard disk boot sector}
<}

<}
} {
if {[S string 19 0 {} {} eq \240\005\371\005\0\011\0\2\0]} {>

emit {DOS floppy 720k, IBM}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, DOS/MBR hard disk boot sector}
<}

<}
} {
if {[S string 19 0 {} {} eq \100\013\371\005\0\011\0\2\0]} {>

emit {DOS floppy 1440k, mkdosfs}

if {[N leshort 510 0 0 {} {} == 43605]} {>

emit {\b, DOS/MBR hard disk boot sector}
<}

<}
} {
if {[S string 19 0 {} {} eq \320\002\370\005\0\011\0\1\0]} {>

emit {Atari-ST floppy 360k}
<}
} {
if {[S string 19 0 {} {} eq \240\005\371\005\0\011\0\2\0]} {>

emit {Atari-ST floppy 720k}
<}
} {
if {[S string 37633 0 {} {} eq CD001]} {>

emit {ISO 9660 CD-ROM filesystem data (raw 2352 byte sectors)}
mime application/x-iso9660-image

<}
} {
if {[S string 32777 0 {} {} eq CDROM]} {>

emit {High Sierra CD-ROM filesystem data}
<}
} {
if {[S string 32769 0 {} {} eq CD001]} {>
U 243 cdrom

<}
} {
if {[S string 0 0 {} {} eq CISO]} {>

emit {Compressed ISO CD image}
<}
} {
if {[S string 65588 0 {} {} eq ReIsErFs]} {>

emit {ReiserFS V3.5}
<}
} {
if {[S string 65588 0 {} {} eq ReIsEr2Fs]} {>

emit {ReiserFS V3.6}
<}
} {
if {[S string 65588 0 {} {} eq ReIsEr3Fs]} {>

emit {ReiserFS V3.6.19}

if {[N leshort 65580 0 0 {} {} x {}]} {>

emit {block size %d}
<}

if {[N leshort 65586 0 0 {} {} & 2]} {>

emit {(mounted or unclean)}
<}

if {[N lelong 65536 0 0 {} {} x {}]} {>

emit {num blocks %d}
<}

switch -- [Nv lelong 65600 0 {} {}] 1 {>;emit {tea hash};<} 2 {>;emit {yura hash};<} 3 {>;emit {r5 hash};<} 
<

<}
} {
if {[S string 0 0 {} {} eq ESTFBINR]} {>

emit {EST flat binary}
<}
} {
if {[S string 0 0 {} {} eq VoIP\ Startup\ and]} {>

emit {Aculab VoIP firmware}

if {[S string 35 0 {} {} x {}]} {>

emit {format %s}
<}

<}
} {
if {[S string 0 0 {} {} eq sqsh]} {>

emit {Squashfs filesystem, big endian,}

if {[N beshort 28 0 0 {} {} x {}]} {>

emit {version %d.}
<}

if {[N beshort 30 0 0 {} {} x {}]} {>

emit {\b%d,}
<}

if {[N beshort 28 0 0 {} {} < 3]} {>

	if {[N belong 8 0 0 {} {} x {}]} {>

	emit {%d bytes,}
<}

<}

if {[N beshort 28 0 0 {} {} > 2]} {>

	if {[N beshort 28 0 0 {} {} < 4]} {>

		if {[N bequad 63 0 0 {} {} x {}]} {>

		emit {%lld bytes,}
<}

<}

	if {[N beshort 28 0 0 {} {} > 3]} {>

		if {[N bequad 40 0 0 {} {} x {}]} {>

		emit {%lld bytes,}
<}

<}

<}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {%d inodes,}
<}

if {[N beshort 28 0 0 {} {} < 2]} {>

	if {[N beshort 32 0 0 {} {} x {}]} {>

	emit {blocksize: %d bytes,}
<}

<}

if {[N beshort 28 0 0 {} {} > 1]} {>

	if {[N beshort 28 0 0 {} {} < 4]} {>

		if {[N belong 51 0 0 {} {} x {}]} {>

		emit {blocksize: %d bytes,}
<}

<}

	if {[N beshort 28 0 0 {} {} > 3]} {>

		if {[N belong 12 0 0 {} {} x {}]} {>

		emit {blocksize: %d bytes,}
<}

<}

<}

if {[N beshort 28 0 0 {} {} < 4]} {>

	if {[N bedate 39 0 0 {} {} x {}]} {>

	emit {created: %s}
<}

<}

if {[N beshort 28 0 0 {} {} > 3]} {>

	if {[N bedate 8 0 0 {} {} x {}]} {>

	emit {created: %s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq hsqs]} {>

emit {Squashfs filesystem, little endian,}

if {[N leshort 28 0 0 {} {} x {}]} {>

emit {version %d.}
<}

if {[N leshort 30 0 0 {} {} x {}]} {>

emit {\b%d,}
<}

if {[N leshort 28 0 0 {} {} < 3]} {>

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {%d bytes,}
<}

<}

if {[N leshort 28 0 0 {} {} > 2]} {>

	if {[N leshort 28 0 0 {} {} < 4]} {>

		if {[N lequad 63 0 0 {} {} x {}]} {>

		emit {%lld bytes,}
<}

<}

	if {[N leshort 28 0 0 {} {} > 3]} {>

		if {[N lequad 40 0 0 {} {} x {}]} {>

		emit {%lld bytes,}
<}

<}

<}

if {[N lelong 4 0 0 {} {} x {}]} {>

emit {%d inodes,}
<}

if {[N leshort 28 0 0 {} {} < 2]} {>

	if {[N leshort 32 0 0 {} {} x {}]} {>

	emit {blocksize: %d bytes,}
<}

<}

if {[N leshort 28 0 0 {} {} > 1]} {>

	if {[N leshort 28 0 0 {} {} < 4]} {>

		if {[N lelong 51 0 0 {} {} x {}]} {>

		emit {blocksize: %d bytes,}
<}

<}

	if {[N leshort 28 0 0 {} {} > 3]} {>

		if {[N lelong 12 0 0 {} {} x {}]} {>

		emit {blocksize: %d bytes,}
<}

<}

<}

if {[N leshort 28 0 0 {} {} < 4]} {>

	if {[N ledate 39 0 0 {} {} x {}]} {>

	emit {created: %s}
<}

<}

if {[N leshort 28 0 0 {} {} > 3]} {>

	if {[N ledate 8 0 0 {} {} x {}]} {>

	emit {created: %s}
<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq \x01\xb3\xa1\x13\x22]} {>

emit {AFS Dump}

if {[Nx belong [R 0] 0 0 {} {} x {}]} {>

emit (v%d)

	if {[Nx byte [R 0] 0 0 {} {} == 118]} {>

		if {[Nx belong [R 0] 0 0 {} {} x {}]} {>

		emit {Vol %d,}

			if {[Nx byte [R 0] 0 0 {} {} == 110]} {>

				if {[Sx string [R 0] 0 {} {} x {}]} {>

				emit %s

					if {[Nx byte [R 1] 0 0 {} {} == 116]} {>

						if {[Nx beshort [R 0] 0 0 {} {} == 2]} {>

							if {[Nx bedate [R 4] 0 0 {} {} x {}]} {>

							emit {on: %s}
<}

							if {[Nx bedate [R 0] 0 0 {} {} == 0]} {>

							emit {full dump}
<}

							if {[Nx bedate [R 0] 0 0 {} {} != 0]} {>

							emit {incremental since: %s}
<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq DISO]} {>

emit {Delta ISO data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[Sx string 4 0 {} {} eq \x01\x00\x01\x00\x01\x00]} {>

if {[Sx string [I 0 leshort 0 + 0 16] 0 {} {} eq \x01\x01]} {>

	if {[Nx byte [R [I [R 0] byte 0 + 0 8]] 0 0 {} {} == 66]} {>

	emit {OpenVMS backup saveset data}

		if {[N lelong 40 0 0 {} {} x {}]} {>

		emit {(block size %d,}
<}

		if {[S string 49 0 {} {} > \0]} {>

		emit {original name '%s',}
<}

		switch -- [Nv short 2 0 {} {}] 1024 {>;emit {VAX generated)};<} 2048 {>;emit {AXP generated)};<} 4096 {>;emit {I64 generated)};<} 
<

<}

<}

<}
} {
if {[S string 8 0 {} {} eq OracleCFS]} {>

emit {Oracle Clustered Filesystem,}

if {[N long 4 0 0 {} {} x {}]} {>

emit {rev %d}
<}

if {[N long 0 0 0 {} {} x {}]} {>

emit {\b.%d,}
<}

if {[S string 560 0 {} {} x {}]} {>

emit {label: %.64s,}
<}

if {[S string 136 0 {} {} x {}]} {>

emit {mountpoint: %.128s}
<}

<}
} {
if {[S string 32 0 {} {} eq ORCLDISK]} {>

emit {Oracle ASM Volume,}

if {[S string 40 0 {} {} x {}]} {>

emit {Disk Name: %0.12s}
<}

<}
} {
if {[S string 32 0 {} {} eq ORCLCLRD]} {>

emit {Oracle ASM Volume (cleared),}

if {[S string 40 0 {} {} x {}]} {>

emit {Disk Name: %0.12s}
<}

<}
} {
if {[S string 8 0 {} {} eq OracleCFS]} {>

emit {Oracle Clustered Filesystem,}

if {[N long 4 0 0 {} {} x {}]} {>

emit {rev %d}
<}

if {[N long 0 0 0 {} {} x {}]} {>

emit {\b.%d,}
<}

if {[S string 560 0 {} {} x {}]} {>

emit {label: %.64s,}
<}

if {[S string 136 0 {} {} x {}]} {>

emit {mountpoint: %.128s}
<}

<}
} {
if {[S string 32 0 {} {} eq ORCLDISK]} {>

emit {Oracle ASM Volume,}

if {[S string 40 0 {} {} x {}]} {>

emit {Disk Name: %0.12s}
<}

<}
} {
if {[S string 32 0 {} {} eq ORCLCLRD]} {>

emit {Oracle ASM Volume (cleared),}

if {[S string 40 0 {} {} x {}]} {>

emit {Disk Name: %0.12s}
<}

<}
} {
if {[S string 0 0 {} {} eq CPQRFBLO]} {>

emit {Compaq/HP RILOE floppy image}
<}
} {
if {[S string 1008 0 {} {} eq DECFILE11]} {>

emit {Files-11 On-Disk Structure}

if {[N byte 525 0 0 {} {} x {}]} {>

emit {(ODS-%d);}
<}

if {[S string 1017 0 {} {} eq A]} {>

emit {RSX-11, VAX/VMS or OpenVMS VAX file system;}
<}

if {[S string 1017 0 {} {} eq B]} {>

	switch -- [Nv byte 525 0 {} {}] 2 {>;emit {VAX/VMS or OpenVMS file system;};<} 5 {>;emit {OpenVMS Alpha or Itanium file system;};<} 
<

<}

if {[S string 984 0 {} {} x {}]} {>

emit {volume label is '%-12.12s'}
<}

<}
} {
if {[S string 0 0 {} {} eq DAA\x0\x0\x0\x0\x0]} {>

emit {PowerISO Direct-Access-Archive}
<}
} {
if {[S string 0 0 {} {} eq \1\0\0\0\0\0\0\300\0\2\0\0]} {>

emit {Marvell Libertas firmware}
<}
} {
if {[N belong 65536 0 0 {} {} == 18225520]} {>

switch -- [Nv belong 65560 0 {} {}] 1309 {>;emit {GFS1 Filesystem}

	if {[N belong 65572 0 0 {} {} x {}]} {>

	emit {(blocksize %d,}
<}

	if {[S string 65632 0 {} {} > \0]} {>

	emit {lockproto %s)}
<}
;<} 1801 {>;emit {GFS2 Filesystem}

	if {[N belong 65572 0 0 {} {} x {}]} {>

	emit {(blocksize %d,}
<}

	if {[S string 65632 0 {} {} > \0]} {>

	emit {lockproto %s)}
<}
;<} 
<

<}
} {
if {[S string 65600 0 {} {} eq _BHRfS_M]} {>

emit {BTRFS Filesystem}

if {[S string 65835 0 {} {} > \0]} {>

emit {label "%s",}
<}

if {[N lelong 65680 0 0 {} {} x {}]} {>

emit {sectorsize %d,}
<}

if {[N lelong 65684 0 0 {} {} x {}]} {>

emit {nodesize %d,}
<}

if {[N lelong 65688 0 0 {} {} x {}]} {>

emit {leafsize %d,}
<}

if {[N belong 65568 0 0 {} {} x {}]} {>

emit UUID=%08x-
<}

if {[N beshort 65572 0 0 {} {} x {}]} {>

emit {\b%04x-}
<}

if {[N beshort 65574 0 0 {} {} x {}]} {>

emit {\b%04x-}
<}

if {[N beshort 65576 0 0 {} {} x {}]} {>

emit {\b%04x-}
<}

if {[N beshort 65578 0 0 {} {} x {}]} {>

emit {\b%04x}
<}

if {[N belong 65580 0 0 {} {} x {}]} {>

emit {\b%08x,}
<}

if {[N lequad 65656 0 0 {} {} x {}]} {>

emit %lld/
<}

if {[N lequad 65648 0 0 {} {} x {}]} {>

emit {\b%lld bytes used,}
<}

if {[N lequad 65672 0 0 {} {} x {}]} {>

emit {%lld devices}
<}

<}
} {
if {[S string 0 0 {} {} eq *dvdisaster*]} {>

emit {dvdisaster error correction file}
<}
} {
if {[S string 0 0 {} {} eq XFSM]} {>

if {[S string 512 0 {} {} eq XFSB]} {>

emit {XFS filesystem metadump image}
<}

<}
} {
if {[S string 0 0 {} {} eq CROMFS]} {>

emit CROMFS

if {[S string 6 0 {} {} > \0]} {>

emit {\b version %2.2s,}
<}

if {[N lequad 8 0 0 {} {} > 0]} {>

emit {\b block data at %lld,}
<}

if {[N lequad 16 0 0 {} {} > 0]} {>

emit {\b fblock table at %lld,}
<}

if {[N lequad 24 0 0 {} {} > 0]} {>

emit {\b inode table at %lld,}
<}

if {[N lequad 32 0 0 {} {} > 0]} {>

emit {\b root at %lld,}
<}

if {[N lelong 40 0 0 {} {} > 0]} {>

emit {\b fblock size = %d,}
<}

if {[N lelong 44 0 0 {} {} > 0]} {>

emit {\b block size = %d,}
<}

if {[N lequad 48 0 0 {} {} > 0]} {>

emit {\b bytes = %lld}
<}

<}
} {
if {[S string 0 0 {} {} eq XFSM]} {>

if {[S string 512 0 {} {} eq XFSB]} {>

emit {XFS filesystem metadump image}
<}

<}
} {
if {[S string 0 0 {} {} eq DISO]} {>

emit {Delta ISO data,}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {version %d}
<}

<}
} {
if {[Sx string 32768 0 {} {} eq JFS1]} {>

if {[Nx lelong [R 0] 0 0 {} {} < 3]} {>

emit {JFS2 filesystem image}

	if {[Sx regex [R 144] 0 {} {} eq \[\x20-\x7E\]\{1,16\}]} {>

	emit {(label "%s")}
<}

	if {[Nx lequad [R 0] 0 0 {} {} x {}]} {>

	emit {\b, %lld blocks}
<}

	if {[Nx lelong [R 8] 0 0 {} {} x {}]} {>

	emit {\b, blocksize %d}
<}

	if {[Nx lelong [R 32] 0 0 & 6 > 0]} {>

	emit (dirty)
<}

	if {[Nx lelong [R 36] 0 0 {} {} > 0]} {>

	emit (compressed)
<}

<}

<}
} {
if {[S string 0 0 {} {} eq td\000]} {>

emit {floppy image data (TeleDisk, compressed)}
<}
} {
if {[S string 0 0 {} {} eq TD\000]} {>

emit {floppy image data (TeleDisk)}
<}
} {
if {[S string 0 0 {} {} eq CQ\024]} {>

emit {floppy image data (CopyQM, }

if {[N leshort 16 0 0 {} {} x {}]} {>

emit {%d sectors, }
<}

if {[N leshort 18 0 0 {} {} x {}]} {>

emit {%d heads.)}
<}

<}
} {
if {[S string 0 0 {} {} eq ACT\020Apricot\020disk\020image\032\004]} {>

emit {floppy image data (ApriDisk)}
<}
} {
if {[S string 0 0 {} {} eq \074CPM_Disk\076]} {>

emit {disk image data (YAZE)}
<}
} {
if {[S string 0 0 {} {} eq \0\0\0ReFS\0]} {>

emit {ReFS filesystem image}
<}
} {
if {[S string 0 0 {} {} eq EVF\x09\x0d\x0a\xff\x00]} {>

emit {EWF/Expert Witness/EnCase image file format}
<}
} {
if {[N lelong 32 0 0 & 4294967039 == 672]} {>

if {[S string 16 0 {} {} eq \0\0\0\0\0\0\0\0\0\0]} {>

	if {[S string 640 0 {} {} eq \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]} {>

		if {[N byte 26 0 0 & 239 == 0]} {>

			if {[N byte 27 0 0 & 143 == 0]} {>

				if {[N byte 27 0 0 & 70 < 64]} {>

					if {[N lelong 28 0 0 {} {} > 33]} {>

						if {[S regex 0 0 {} {} eq \[\[:print:\]\]*]} {>

						emit {NEC PC-88 disk image, name=%s}

							switch -- [Nv byte 27 0 {} {}] 0 {>;emit {\b, media=2D};<} 16 {>;emit {\b, media=2DD};<} 32 {>;emit {\b, media=2HD};<} 48 {>;emit {\b, media=1D};<} 64 {>;emit {\b, media=1DD};<} 
<

							if {[N byte 26 0 0 {} {} == 16]} {>

							emit {\b, write-protected}
<}

<}

<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 8 0 {} {} eq \000\000\000\002\365\272\313\254]} {>

emit {ZFS shapshot (big-endian machine),}

if {[N belong 20 0 0 {} {} x {}]} {>

emit {version %u,}
<}

switch -- [Nv belong 32 0 {} {}] 0 {>;emit {type: NONE,};<} 1 {>;emit {type: META,};<} 2 {>;emit {type: ZFS,};<} 3 {>;emit {type: ZVOL,};<} 4 {>;emit {type: OTHER,};<} 5 {>;emit {type: ANY,};<} 
<

if {[N belong 32 0 0 {} {} > 5]} {>

emit {type: UNKNOWN (%u),}
<}

if {[N byte 40 0 0 {} {} x {}]} {>

emit {destination GUID: %02X}
<}

if {[N byte 41 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 42 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 43 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 44 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 45 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 46 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 47 0 0 {} {} x {}]} {>

emit %02X,
<}

if {[N long 48 0 0 {} {} > 0]} {>

	if {[N long 52 0 0 {} {} > 0]} {>

		if {[N byte 48 0 0 {} {} x {}]} {>

		emit {source GUID: %02X}
<}

		if {[N byte 49 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 50 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 51 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 52 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 53 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 54 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 55 0 0 {} {} x {}]} {>

		emit %02X,
<}

<}

<}

if {[S string 56 0 {} {} > \0]} {>

emit {name: '%s'}
<}

<}
} {
if {[S string 8 0 {} {} eq \254\313\272\365\002\000\000\000]} {>

emit {ZFS shapshot (little-endian machine),}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {version %u,}
<}

switch -- [Nv lelong 32 0 {} {}] 0 {>;emit {type: NONE,};<} 1 {>;emit {type: META,};<} 2 {>;emit {type: ZFS,};<} 3 {>;emit {type: ZVOL,};<} 4 {>;emit {type: OTHER,};<} 5 {>;emit {type: ANY,};<} 
<

if {[N lelong 32 0 0 {} {} > 5]} {>

emit {type: UNKNOWN (%u),}
<}

if {[N byte 47 0 0 {} {} x {}]} {>

emit {destination GUID: %02X}
<}

if {[N byte 46 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 45 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 44 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 43 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 42 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 41 0 0 {} {} x {}]} {>

emit %02X
<}

if {[N byte 40 0 0 {} {} x {}]} {>

emit %02X,
<}

if {[N long 48 0 0 {} {} > 0]} {>

	if {[N long 52 0 0 {} {} > 0]} {>

		if {[N byte 55 0 0 {} {} x {}]} {>

		emit {source GUID: %02X}
<}

		if {[N byte 54 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 53 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 52 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 51 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 50 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 49 0 0 {} {} x {}]} {>

		emit %02X
<}

		if {[N byte 48 0 0 {} {} x {}]} {>

		emit %02X,
<}

<}

<}

if {[S string 56 0 {} {} > \0]} {>

emit {name: '%s'}
<}

<}
} {
if {[Sx string 0 0 {} {} eq PK\003\004]} {>

if {[Sx regex 30 0 {} {} eq \\\[Content_Types\\\]\\.xml|_rels/\\.rels]} {>

	if {[Sx search [I 18 lelong 0 + 0 49] 0 {} 2000 eq PK\003\004]} {>

		if {[Sx search [R 26] 0 {} 1000 eq PK\003\004]} {>

			if {[Sx string [R 26] 0 {} {} eq word/]} {>

			emit {Microsoft Word 2007+}
			mime application/vnd.openxmlformats-officedocument.wordprocessingml.document

<}

			if {[Sx string [R 26] 0 {} {} eq ppt/]} {>

			emit {Microsoft PowerPoint 2007+}
			mime application/vnd.openxmlformats-officedocument.presentationml.presentation

<}

			if {[Sx string [R 26] 0 {} {} eq xl/]} {>

			emit {Microsoft Excel 2007+}
			mime application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

<}

			if {[Sx default [R 26] 0 {} {} x {}]} {>

			emit {Microsoft OOXML}
<}

<}

<}

<}

<}
} {
if {[S string 39 0 {} {} eq <gmr:Workbook]} {>

emit {Gnumeric spreadsheet}
mime application/x-gnumeric

<}
} {
if {[S string 0 0 {} {} eq \xb0\0\x30\0]} {>

emit {VMS VAX executable}

if {[S string 44032 0 {} {} eq PK\003\004]} {>

emit {\b, Info-ZIP SFX archive v5.12 w/decryption}
<}

<}
} {
if {[S string 0 0 {} {} eq kbd!map]} {>

emit {kbd map file}

if {[N byte 8 0 0 {} {} > 0]} {>

emit {Ver %d:}
<}

if {[N short 10 0 0 {} {} > 0]} {>

emit {with %d table(s)}
<}

<}
} {
if {[S string 0 0 {} {} eq \x43\x72\x73\x68\x44\x75\x6d\x70]} {>

emit {IRIX vmcore dump of}

if {[S string 36 0 {} {} > \0]} {>

emit '%s'
<}

<}
} {
if {[S string 0 0 {} {} eq SGIAUDIT]} {>

emit {SGI Audit file}

if {[N byte 8 0 0 {} {} x {}]} {>

emit {- version %d}
<}

if {[N byte 9 0 0 {} {} x {}]} {>

emit {\b.%d}
<}

<}
} {
if {[S string 0 0 {} {} eq WNGZWZSC]} {>

emit {Wingz compiled script}
<}
} {
if {[S string 0 0 {} {} eq WNGZWZSS]} {>

emit {Wingz spreadsheet}
<}
} {
if {[S string 0 0 {} {} eq WNGZWZHP]} {>

emit {Wingz help file}
<}
} {
if {[S string 0 0 {} {} eq \#Inventor\040V]} {>

emit {IRIS Inventor 1.0 file}
<}
} {
if {[S string 0 0 {} {} eq \#Inventor\040V2]} {>

emit {Open Inventor 2.0 file}
<}
} {
if {[S string 0 0 {} {} eq glfHeadMagic()\;]} {>

emit GLF_TEXT
<}
} {
if {[S string 0 0 {} {} eq glsBeginGLS(]} {>

emit GLS_TEXT
<}
} {
if {[S string 0 0 {} {} eq PmNs]} {>

emit {PCP compiled namespace (V.0)}
<}
} {
if {[S string 0 0 {} {} eq PmN]} {>

emit {PCP compiled namespace}

if {[S string 3 0 {} {} > \0]} {>

emit (V.%1.1s)
<}

<}
} {
if {[N belong 3 0 0 {} {} == 2219836710]} {>

emit {PCP archive}

if {[N byte 7 0 0 {} {} x {}]} {>

emit (V.%d)
<}

switch -- [Nv belong 20 0 {} {}] -2 {>;emit {temporal index};<} -1 {>;emit metadata;<} 0 {>;emit {log volume #0};<} 
<

if {[N belong 20 0 0 {} {} > 0]} {>

emit {log volume #%d}
<}

if {[S string 24 0 {} {} > \0]} {>

emit {host: %s}
<}

<}
} {
if {[S string 0 0 {} {} eq PCPFolio]} {>

emit PCP

if {[S string 9 0 {} {} eq Version:]} {>

emit {Archive Folio}
<}

if {[S string 18 0 {} {} > \0]} {>

emit (V.%s)
<}

<}
} {
if {[S string 0 0 {} {} eq \#pmchart]} {>

emit {PCP pmchart view}

if {[S string 9 0 {} {} eq Version]} {>

<}

if {[S string 17 0 {} {} > \0]} {>

emit (V%-3.3s)
<}

<}
} {
if {[S string 0 0 {} {} eq \#kmchart]} {>

emit {PCP kmchart view}

if {[S string 9 0 {} {} eq Version]} {>

<}

if {[S string 17 0 {} {} > \0]} {>

emit (V.%s)
<}

<}
} {
if {[S string 0 0 {} {} eq pmview]} {>

emit {PCP pmview config}

if {[S string 7 0 {} {} eq Version]} {>

<}

if {[S string 15 0 {} {} > \0]} {>

emit (V%-3.3s)
<}

<}
} {
if {[S string 0 0 {} {} eq \#pmlogger]} {>

emit {PCP pmlogger config}

if {[S string 10 0 {} {} eq Version]} {>

<}

if {[S string 18 0 {} {} > \0]} {>

emit (V%1.1s)
<}

<}
} {
if {[S string 0 0 {} {} eq \#pmdahotproc]} {>

emit {PCP pmdahotproc config}

if {[S string 13 0 {} {} eq Version]} {>

<}

if {[S string 21 0 {} {} > \0]} {>

emit (V%-3.3s)
<}

<}
} {
if {[S string 0 0 {} {} eq PcPh]} {>

emit {PCP Help}

if {[S string 4 0 {} {} eq 1]} {>

emit Index
<}

if {[S string 4 0 {} {} eq 2]} {>

emit Text
<}

if {[S string 5 0 {} {} > \0]} {>

emit (V.%1.1s)
<}

<}
} {
if {[S string 0 0 {} {} eq \#pmieconf-rules]} {>

emit {PCP pmieconf rules}

if {[S string 16 0 {} {} > \0]} {>

emit (V.%1.1s)
<}

<}
} {
if {[S string 3 0 {} {} eq pmieconf-pmie]} {>

emit {PCP pmie config}

if {[S string 17 0 {} {} > \0]} {>

emit (V.%1.1s)
<}

<}
} {
if {[S string 0 0 {} {} eq mdbm]} {>

emit {mdbm file,}

if {[N byte 5 0 0 {} {} x {}]} {>

emit {version %d,}
<}

if {[N byte 6 0 0 {} {} x {}]} {>

emit {2^%d pages,}
<}

if {[N byte 7 0 0 {} {} x {}]} {>

emit {pagesize 2^%d,}
<}

if {[N byte 17 0 0 {} {} x {}]} {>

emit {hash %d,}
<}

if {[N byte 11 0 0 {} {} x {}]} {>

emit {dataformat %d}
<}

<}
} {
if {[S string 0 0 t {} eq //Maya\040ASCII]} {>

emit {Alias Maya Ascii File,}

if {[S string 13 0 {} {} > \0]} {>

emit {version %s}
<}

<}
} {
if {[S string 8 0 {} {} eq MAYAFOR4]} {>

emit {Alias Maya Binary File,}

if {[S string 32 0 {} {} > \0]} {>

emit {version %s scene}
<}

<}
} {
if {[S string 8 0 {} {} eq MayaFOR4]} {>

emit {Alias Maya Binary File,}

if {[S string 32 0 {} {} > \0]} {>

emit {version %s scene}
<}

<}
} {
if {[S string 8 0 {} {} eq CIMG]} {>

emit {Alias Maya Image File}
<}
} {
if {[S string 8 0 {} {} eq DEEP]} {>

emit {Alias Maya Image File}
<}
} {
if {[S string 0 0 {} {} eq \000MVR4\nI]} {>

emit {MapleVr4 library}
<}
} {
if {[S string 0 0 {} {} eq \000\004\000\000]} {>

emit {Maple help database}
<}
} {
if {[S string 0 0 {} {} eq <PACKAGE=]} {>

emit {Maple help file}
<}
} {
if {[S string 0 0 {} {} eq <HELP\ NAME=]} {>

emit {Maple help file}
<}
} {
if {[S string 0 0 {} {} eq \n<HELP\ NAME=]} {>

emit {Maple help file with extra carriage return at start (yuck)}
<}
} {
if {[S string 0 0 {} {} eq \#\ daub]} {>

emit {Maple help file, old style}
<}
} {
if {[S string 0 0 {} {} eq \000\000\001\044\000\221]} {>

emit {Maple worksheet}
<}
} {
if {[S string 0 0 {} {} eq WriteNow\000\002\000\001\000\000\000\000\100\000\000\000\000\000]} {>

emit {Maple worksheet, but weird}
<}
} {
if {[S string 0 0 {} {} eq \{VERSION\ ]} {>

emit {Maple worksheet}

if {[S string 9 0 {} {} > \0]} {>

emit {version %.1s.}

	if {[S string 11 0 {} {} > \0]} {>

	emit %.1s
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \0\0\001\$]} {>

emit {Maple something}

if {[S string 4 0 {} {} eq \000\105]} {>

emit {An old revision}
<}

if {[S string 4 0 {} {} eq \001\122]} {>

emit {The latest save}
<}

<}
} {
if {[S string 0 0 {} {} eq \#\n\#\#\ <SHAREFILE=]} {>

emit {Maple something}
<}
} {
if {[S string 0 0 {} {} eq \n\#\n\#\#\ <SHAREFILE=]} {>

emit {Maple something}
<}
} {
if {[S string 0 0 {} {} eq \#\#\ <SHAREFILE=]} {>

emit {Maple something}
<}
} {
if {[S string 0 0 {} {} eq \#\r\#\#\ <SHAREFILE=]} {>

emit {Maple something}
<}
} {
if {[S string 0 0 {} {} eq \r\#\r\#\#\ <SHAREFILE=]} {>

emit {Maple something}
<}
} {
if {[S string 0 0 {} {} eq \#\ \r\#\#\ <DESCRIBE>]} {>

emit {Maple something anomalous.}
<}
} {
if {[S string 36 0 {} {} eq acspAPPL]} {>

emit {ColorSync ICC Profile}
mime application/vnd.iccprofile

<}
} {
if {[S string 36 0 {} {} eq acspMSFT]} {>

emit {Microsoft ICM Color Profile}
mime application/vnd.iccprofile

<}
} {
if {[S string 36 0 {} {} eq acspSGI\ ]} {>

emit {SGI ICC Profile}
mime application/vnd.iccprofile

<}
} {
if {[S string 36 0 {} {} eq acspSUNW]} {>

emit {Sun KCMS ICC Profile}
mime application/vnd.iccprofile

<}
} {
if {[S string 36 0 {} {} eq acsp]} {>

emit {ICC Profile}
mime application/vnd.iccprofile

<}
} {
if {[Sx string 0 0 {} {} eq RIFF]} {>

emit {RIFF (little-endian) data}

if {[S string 8 0 {} {} eq PAL]} {>

emit {\b, palette}

	if {[N leshort 16 0 0 {} {} x {}]} {>

	emit {\b, version %d}
<}

	if {[N leshort 18 0 0 {} {} x {}]} {>

	emit {\b, %d entries}
<}

<}

if {[S string 8 0 {} {} eq RDIB]} {>

emit {\b, device-independent bitmap}

	if {[S string 16 0 {} {} eq BM]} {>

		switch -- [Nv leshort 30 0 {} {}] 12 {>;emit {\b, OS/2 1.x format}

			if {[N leshort 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N leshort 36 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 64 {>;emit {\b, OS/2 2.x format}

			if {[N leshort 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N leshort 36 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 40 {>;emit {\b, Windows 3.x format}

			if {[N lelong 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N lelong 38 0 0 {} {} x {}]} {>

			emit {%d x}
<}

			if {[N leshort 44 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 
<

<}

<}

if {[S string 8 0 {} {} eq RMID]} {>

emit {\b, MIDI}
<}

if {[S string 8 0 {} {} eq RMMP]} {>

emit {\b, multimedia movie}
<}

if {[S string 8 0 {} {} eq RMP3]} {>

emit {\b, MPEG Layer 3 audio}
<}

if {[S string 8 0 {} {} eq WAVE]} {>

emit {\b, WAVE audio}

	if {[S string 12 0 {} {} > \0]} {>
U 252 riff-walk

<}

mime audio/x-wav

<}

if {[S string 8 0 {} {} eq CDRA]} {>

emit {\b, Corel Draw Picture}
mime image/x-coreldraw

<}

if {[S string 8 0 {} {} eq CDR6]} {>

emit {\b, Corel Draw Picture, version 6}
mime image/x-coreldraw

<}

if {[S string 8 0 {} {} eq NUNDROOT]} {>

emit {\b, Steinberg CuBase}
<}

if {[Sx string 8 0 {} {} eq AVI\040]} {>

emit {\b, AVI}

	if {[Sx string 12 0 {} {} eq LIST]} {>

		if {[Sx string 20 0 {} {} eq hdrlavih]} {>

			if {[Nx lelong [R 36] 0 0 {} {} x {}]} {>

			emit {\b, %u x}
<}

			if {[Nx lelong [R 40] 0 0 {} {} x {}]} {>

			emit %u,
<}

			if {[Nx lelong [R 4] 0 0 {} {} > 1000000]} {>

			emit {<1 fps,}
<}

			switch -- [Nvx lelong [R 4] 0 {} {}] 1000000 {>;emit {1.00 fps,};<} 500000 {>;emit {2.00 fps,};<} 333333 {>;emit {3.00 fps,};<} 250000 {>;emit {4.00 fps,};<} 200000 {>;emit {5.00 fps,};<} 166667 {>;emit {6.00 fps,};<} 142857 {>;emit {7.00 fps,};<} 125000 {>;emit {8.00 fps,};<} 111111 {>;emit {9.00 fps,};<} 100000 {>;emit {10.00 fps,};<} 83333 {>;emit {12.00 fps,};<} 66667 {>;emit {15.00 fps,};<} 50000 {>;emit {20.00 fps,};<} 41708 {>;emit {23.98 fps,};<} 41667 {>;emit {24.00 fps,};<} 40000 {>;emit {25.00 fps,};<} 33367 {>;emit {29.97 fps,};<} 33333 {>;emit {30.00 fps,};<} 
<

			if {[Nx lelong [R 4] 0 0 {} {} < 101010]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 99010]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 100000]} {>

					emit {~10 fps,}
<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 84034]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 82645]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 83333]} {>

					emit {~12 fps,}
<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 67114]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 66225]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 66667]} {>

					emit {~15 fps,}
<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 41841]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 41494]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 41708]} {>

						if {[Nx lelong [R -4] 0 0 {} {} != 41667]} {>

						emit {~24 fps,}
<}

<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 40161]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 39841]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 40000]} {>

					emit {~25 fps,}
<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 33445]} {>

				if {[Nx lelong [R -4] 0 0 {} {} > 33223]} {>

					if {[Nx lelong [R -4] 0 0 {} {} != 33367]} {>

						if {[Nx lelong [R -4] 0 0 {} {} != 33333]} {>

						emit {~30 fps,}
<}

<}

<}

<}

			if {[Nx lelong [R 4] 0 0 {} {} < 32224]} {>

			emit {>30 fps,}
<}

<}

		if {[Sx string 88 0 {} {} eq LIST]} {>

			if {[Sx string 96 0 {} {} eq strlstrh]} {>

				if {[Sx string 108 0 {} {} eq vids]} {>

				emit video:

					if {[Nx lelong [R 0] 0 0 {} {} == 0]} {>

					emit uncompressed
<}

					if {[S string [I 104 lelong 0 + 0 108] 0 {} {} eq strf]} {>

						switch -- [Nv lelong [I 104 lelong 0 + 0 132] 0 {} {}] 1 {>;emit {RLE 8bpp};<} 0 {>;;<} 
<

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq cvid]} {>

						emit Cinepak
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq i263]} {>

						emit {Intel I.263}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq iv32]} {>

						emit {Indeo 3.2}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq iv41]} {>

						emit {Indeo 4.1}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq iv50]} {>

						emit {Indeo 5.0}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq mp42]} {>

						emit {Microsoft MPEG-4 v2}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq mp43]} {>

						emit {Microsoft MPEG-4 v3}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq fmp4]} {>

						emit {FFMpeg MPEG-4}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq mjpg]} {>

						emit {Motion JPEG}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq div3]} {>

						emit {DivX 3}

							if {[S string 112 0 c {} eq div3]} {>

							emit Low-Motion
<}

							if {[S string 112 0 c {} eq div4]} {>

							emit Fast-Motion
<}

<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq divx]} {>

						emit {DivX 4}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq dx50]} {>

						emit {DivX 5}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq xvid]} {>

						emit XviD
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq h264]} {>

						emit H.264
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq wmv3]} {>

						emit {Windows Media Video 9}
<}

						if {[S string [I 104 lelong 0 + 0 132] 0 c {} eq h264]} {>

						emit {X.264 or H.264}
<}

<}

<}

<}

			if {[S string [I 92 lelong 0 + 0 96] 0 {} {} eq LIST]} {>

				if {[S string [I 92 lelong 0 + 0 104] 0 {} {} eq strlstrh]} {>

					if {[S string [I 92 lelong 0 + 0 116] 0 {} {} eq auds]} {>

					emit {\b, audio:}

						if {[S string [I 92 lelong 0 + 0 172] 0 {} {} eq strf]} {>

							switch -- [Nv leshort [I 92 lelong 0 + 0 180] 0 {} {}] 1 {>;emit {uncompressed PCM};<} 2 {>;emit ADPCM;<} 6 {>;emit aLaw;<} 7 {>;emit uLaw;<} 80 {>;emit {MPEG-1 Layer 1 or 2};<} 85 {>;emit {MPEG-1 Layer 3};<} 8192 {>;emit {Dolby AC3};<} 353 {>;emit DivX;<} 
<

							switch -- [Nv leshort [I 92 lelong 0 + 0 182] 0 {} {}] 1 {>;emit (mono,;<} 2 {>;emit (stereo,;<} 
<

							if {[N leshort [I 92 lelong 0 + 0 182] 0 0 {} {} > 2]} {>

							emit {(%d channels,}
<}

							if {[N lelong [I 92 lelong 0 + 0 184] 0 0 {} {} x {}]} {>

							emit {%d Hz)}
<}

<}

						if {[S string [I 92 lelong 0 + 0 180] 0 {} {} eq strf]} {>

							switch -- [Nv leshort [I 92 lelong 0 + 0 188] 0 {} {}] 1 {>;emit {uncompressed PCM};<} 2 {>;emit ADPCM;<} 85 {>;emit {MPEG-1 Layer 3};<} 8192 {>;emit {Dolby AC3};<} 353 {>;emit DivX;<} 
<

							switch -- [Nv leshort [I 92 lelong 0 + 0 190] 0 {} {}] 1 {>;emit (mono,;<} 2 {>;emit (stereo,;<} 
<

							if {[N leshort [I 92 lelong 0 + 0 190] 0 0 {} {} > 2]} {>

							emit {(%d channels,}
<}

							if {[N lelong [I 92 lelong 0 + 0 192] 0 0 {} {} x {}]} {>

							emit {%d Hz)}
<}

<}

<}

<}

<}

<}

<}

mime video/x-msvideo

<}

if {[S string 8 0 {} {} eq ACON]} {>

emit {\b, animated cursor}
<}

if {[S string 8 0 {} {} eq sfbk]} {>

emit SoundFont/Bank
<}

if {[S string 8 0 {} {} eq CDXA]} {>

emit {\b, wrapped MPEG-1 (CDXA)}
<}

if {[S string 8 0 {} {} eq 4XMV]} {>

emit {\b, 4X Movie file }
<}

if {[S string 8 0 {} {} eq AMV\040]} {>

emit {\b, AMV }
<}

if {[S string 8 0 {} {} eq WEBP]} {>

emit {\b, Web/P image}
U 252 riff-walk

mime image/webp

<}

<}
} {
if {[S string 0 0 {} {} eq RIFX]} {>

emit {RIFF (big-endian) data}

if {[S string 8 0 {} {} eq PAL]} {>

emit {\b, palette}

	if {[N beshort 16 0 0 {} {} x {}]} {>

	emit {\b, version %d}
<}

	if {[N beshort 18 0 0 {} {} x {}]} {>

	emit {\b, %d entries}
<}

<}

if {[S string 8 0 {} {} eq RDIB]} {>

emit {\b, device-independent bitmap}

	if {[S string 16 0 {} {} eq BM]} {>

		switch -- [Nv beshort 30 0 {} {}] 12 {>;emit {\b, OS/2 1.x format}

			if {[N beshort 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N beshort 36 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 64 {>;emit {\b, OS/2 2.x format}

			if {[N beshort 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N beshort 36 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 40 {>;emit {\b, Windows 3.x format}

			if {[N belong 34 0 0 {} {} x {}]} {>

			emit {\b, %d x}
<}

			if {[N belong 38 0 0 {} {} x {}]} {>

			emit {%d x}
<}

			if {[N beshort 44 0 0 {} {} x {}]} {>

			emit %d
<}
;<} 
<

<}

<}

if {[S string 8 0 {} {} eq RMID]} {>

emit {\b, MIDI}
<}

if {[S string 8 0 {} {} eq RMMP]} {>

emit {\b, multimedia movie}
<}

if {[S string 8 0 {} {} eq WAVE]} {>

emit {\b, WAVE audio}

	if {[N leshort 20 0 0 {} {} == 1]} {>

	emit {\b, Microsoft PCM}

		if {[N leshort 34 0 0 {} {} > 0]} {>

		emit {\b, %d bit}
<}

<}

	switch -- [Nv beshort 22 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<

	if {[N beshort 22 0 0 {} {} > 2]} {>

	emit {\b, %d channels}
<}

	if {[N belong 24 0 0 {} {} > 0]} {>

	emit {%d Hz}
<}

<}

if {[S string 8 0 {} {} eq CDRA]} {>

emit {\b, Corel Draw Picture}
<}

if {[S string 8 0 {} {} eq CDR6]} {>

emit {\b, Corel Draw Picture, version 6}
<}

if {[S string 8 0 {} {} eq AVI\040]} {>

emit {\b, AVI}
<}

if {[S string 8 0 {} {} eq ACON]} {>

emit {\b, animated cursor}
<}

if {[S string 8 0 {} {} eq NIFF]} {>

emit {\b, Notation Interchange File Format}
<}

if {[S string 8 0 {} {} eq sfbk]} {>

emit SoundFont/Bank
<}

<}
} {
if {[Sx string 0 0 {} {} eq riff\x2E\x91\xCF\x11\xA5\xD6\x28\xDB\x04\xC1\x00\x00]} {>

emit {Sony Wave64 RIFF data}

if {[Sx string 24 0 {} {} eq wave\xF3\xAC\xD3\x11\x8C\xD1\x00\xC0\x4F\x8E\xDB\x8A]} {>

emit {\b, WAVE 64 audio}

	if {[Sx search 40 0 {} 256 eq fmt\x20\xF3\xAC\xD3\x11\x8C\xD1\x00\xC0\x4F\x8E\xDB\x8A]} {>

	emit {\b}

		switch -- [Nvx leshort [R 10] 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<

		if {[Nx leshort [R 10] 0 0 {} {} > 2]} {>

		emit {\b, %d channels}
<}

		if {[Nx lelong [R 12] 0 0 {} {} > 0]} {>

		emit {%d Hz}
<}

<}

mime audio/x-w64

<}

<}
} {
if {[Sx string 0 0 {} {} eq RF64\xff\xff\xff\xffWAVEds64]} {>

emit {MBWF/RF64 audio}

if {[Sx search 40 0 {} 256 eq fmt\x20]} {>

emit {\b}

	switch -- [Nvx leshort [R 6] 0 {} {}] 1 {>;emit {\b, mono};<} 2 {>;emit {\b, stereo};<} 
<

	if {[Nx leshort [R 6] 0 0 {} {} > 2]} {>

	emit {\b, %d channels}
<}

	if {[Nx lelong [R 8] 0 0 {} {} > 0]} {>

	emit {%d Hz}
<}

<}

mime audio/x-wav

<}
} {
if {[S regex 0 0 {} {} eq ^import.*\;\$]} {>

emit {Java source}
mime text/x-java

<}
} {
if {[S string 0 0 {} {} eq JAVA\x20PROFILE\x201.0.]} {>

if {[N short 18 0 0 {} {} == 0]} {>

	if {[N short 17 0 0 - 49 < 2]} {>

	emit {Java HPROF dump,}
<}

	if {[N beqdate 23 0 0 / 1000 x {}]} {>

	emit {created %s}
<}

<}

<}
} {
if {[Sx string 0 0 {} {} eq wsdl]} {>

emit {PHP WSDL cache,}

if {[N byte 4 0 0 {} {} x {}]} {>

emit {version 0x%02x}
<}

if {[N ledate 6 0 0 {} {} x {}]} {>

emit {\b, created %s}
<}

if {[Nx lelong 10 0 0 {} {} < 2147483647]} {>

	if {[Sx pstring 10 0 l {} x {}]} {>

	emit {\b, uri: "%s"}

		if {[Nx lelong [R 0] 0 0 {} {} < 2147483647]} {>

			if {[Sx pstring [R -4] 0 l {} x {}]} {>

			emit {\b, source: "%s"}

				if {[Nx lelong [R 0] 0 0 {} {} < 2147483647]} {>

					if {[Sx pstring [R -4] 0 l {} x {}]} {>

					emit {\b, target_ns: "%s"}
<}

<}

<}

<}

<}

<}

<}
} {
if {[S string 0 0 t {} eq \#\ Magic]} {>

emit {magic text file for file(1) cmd}
<}
} {
if {[S string 38 0 {} {} eq Spreadsheet]} {>

emit {sc spreadsheet file}
mime application/x-sc

<}
} {
if {[S string 0 0 {} {} eq \032\001]} {>

if {[N byte 16 0 0 {} {} > 32]} {>

	if {[S regex 12 0 {} {} eq ^\[a-zA-Z0-9\]\[a-zA-Z0-9.\]\[^|\]*]} {>

	emit {Compiled terminfo entry "%-s"}
	mime application/x-terminfo

<}

<}

<}
} {
if {[S search 0 0 {} 1 eq .\\\"]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S search 0 0 {} 1 eq '\\\"]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S search 0 0 {} 1 eq '.\\\"]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S search 0 0 {} 1 eq \\\"]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S search 0 0 {} 1 eq ''']} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S regex 0 0 l 20 eq ^\\.\[A-Za-z0-9\]\[A-Za-z0-9\]\[\ \t\]]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S regex 0 0 l 20 eq ^\\.\[A-Za-z0-9\]\[A-Za-z0-9\]\$]} {>

emit {troff or preprocessor input text}
mime text/troff

<}
} {
if {[S search 0 0 {} 1 eq x\ T]} {>

emit {ditroff output text}

if {[S search 4 0 {} 1 eq cat]} {>

emit {for the C/A/T phototypesetter}
<}

if {[S search 4 0 {} 1 eq ps]} {>

emit {for PostScript}
<}

if {[S search 4 0 {} 1 eq dvi]} {>

emit {for DVI}
<}

if {[S search 4 0 {} 1 eq ascii]} {>

emit {for ASCII}
<}

if {[S search 4 0 {} 1 eq lj4]} {>

emit {for LaserJet 4}
<}

if {[S search 4 0 {} 1 eq latin1]} {>

emit {for ISO 8859-1 (Latin 1)}
<}

if {[S search 4 0 {} 1 eq X75]} {>

emit {for xditview at 75dpi}

	if {[S search 7 0 {} 1 eq -12]} {>

	emit (12pt)
<}

<}

if {[S search 4 0 {} 1 eq X100]} {>

emit {for xditview at 100dpi}

	if {[S search 8 0 {} 1 eq -12]} {>

	emit (12pt)
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \100\357]} {>

emit {very old (C/A/T) troff output data}
<}
} {
if {[N bequad 0 0 0 & 71710148363550912 == 0]} {>

if {[N byte 2 0 0 {} {} > 0]} {>

	if {[N byte 2 0 0 {} {} < 34]} {>

		if {[N byte 16 0 0 {} {} < 33]} {>

			if {[N byte 16 0 0 & 192 == 0]} {>

				if {[N byte 1 0 0 {} {} == 0]} {>

					if {[N leshort 3 0 0 {} {} == 0]} {>
U 262 tga-image

<}

<}

				if {[N byte 1 0 0 {} {} > 0]} {>
U 262 tga-image

<}

<}

<}

<}

<}

<}
} {
if {[S search 0 0 {} 1 eq P1]} {>
U 262 netpbm

<}
} {
if {[S search 0 0 {} 1 eq P2]} {>
U 262 netpbm

<}
} {
if {[S search 0 0 {} 1 eq P3]} {>
U 262 netpbm

<}
} {
if {[S string 0 0 {} {} eq P4]} {>
U 262 netpbm

<}
} {
if {[S string 0 0 {} {} eq P5]} {>
U 262 netpbm

<}
} {
if {[S string 0 0 {} {} eq P6]} {>
U 262 netpbm

<}
} {
if {[S string 0 0 {} {} eq P7]} {>

emit {Netpbm PAM image file}
mime image/x-portable-pixmap

<}
} {
if {[S string 0 0 {} {} eq \117\072]} {>

emit {Solitaire Image Recorder format}

if {[S string 4 0 {} {} eq \013]} {>

emit {MGI Type 11}
<}

if {[S string 4 0 {} {} eq \021]} {>

emit {MGI Type 17}
<}

<}
} {
if {[S string 0 0 {} {} eq .MDA]} {>

emit {MicroDesign data}

switch -- [Nv byte 21 0 {} {}] 48 {>;emit {version 2};<} 51 {>;emit {version 3};<} 
<

<}
} {
if {[S string 0 0 {} {} eq .MDP]} {>

emit {MicroDesign page data}

switch -- [Nv byte 21 0 {} {}] 48 {>;emit {version 2};<} 51 {>;emit {version 3};<} 
<

<}
} {
if {[S string 0 0 {} {} eq IIN1]} {>

emit {NIFF image data}
mime image/x-niff

<}
} {
if {[S string 0 0 {} {} eq II\x1a\0\0\0HEAPCCDR]} {>

emit {Canon CIFF raw image data}

if {[N leshort 16 0 0 {} {} x {}]} {>

emit {\b, version %d.}
<}

if {[N leshort 14 0 0 {} {} x {}]} {>

emit {\b%d}
<}

mime image/x-canon-crw

<}
} {
if {[S string 0 0 {} {} eq II\x2a\0\x10\0\0\0CR]} {>

emit {Canon CR2 raw image data}

if {[N byte 10 0 0 {} {} x {}]} {>

emit {\b, version %d.}
<}

if {[N byte 11 0 0 {} {} x {}]} {>

emit {\b%d}
<}

mime image/x-canon-cr2

<}
} {
if {[S string 0 0 {} {} eq MM\x00\x2a]} {>

emit {TIFF image data, big-endian}
U 262 tiff_ifd

mime image/tiff

<}
} {
if {[S string 0 0 {} {} eq II\x2a\x00]} {>

emit {TIFF image data, little-endian}
U 262 tiff_ifd

mime image/tiff

<}
} {
if {[S string 0 0 {} {} eq MM\x00\x2b]} {>

emit {Big TIFF image data, big-endian}
mime image/tiff

<}
} {
if {[S string 0 0 {} {} eq II\x2b\x00]} {>

emit {Big TIFF image data, little-endian}
mime image/tiff

<}
} {
if {[S string 0 0 {} {} eq \x89PNG\x0d\x0a\x1a\x0a]} {>

emit {PNG image data}

if {[N belong 16 0 0 {} {} x {}]} {>

emit {\b, %d x}
<}

if {[N belong 20 0 0 {} {} x {}]} {>

emit %d,
<}

if {[N byte 24 0 0 {} {} x {}]} {>

emit %d-bit
<}

switch -- [Nv byte 25 0 {} {}] 0 {>;emit grayscale,;<} 2 {>;emit {\b/color RGB,};<} 3 {>;emit colormap,;<} 4 {>;emit gray+alpha,;<} 6 {>;emit {\b/color RGBA,};<} 
<

switch -- [Nv byte 28 0 {} {}] 0 {>;emit non-interlaced;<} 1 {>;emit interlaced;<} 
<

mime image/png

<}
} {
if {[S string 0 0 {} {} eq GIF94z]} {>

emit {ZIF image (GIF+deflate alpha)}
mime image/x-unknown

<}
} {
if {[S string 0 0 {} {} eq FGF95a]} {>

emit {FGF image (GIF+deflate beta)}
mime image/x-unknown

<}
} {
if {[S string 0 0 {} {} eq PBF]} {>

emit {PBF image (deflate compression)}
mime image/x-unknown

<}
} {
if {[S string 0 0 {} {} eq GIF8]} {>

emit {GIF image data}

if {[S string 4 0 {} {} eq 7a]} {>

emit {\b, version 8%s,}
<}

if {[S string 4 0 {} {} eq 9a]} {>

emit {\b, version 8%s,}
<}

if {[N leshort 6 0 0 {} {} > 0]} {>

emit {%d x}
<}

if {[N leshort 8 0 0 {} {} > 0]} {>

emit %d
<}

mime image/gif

<}
} {
if {[S string 0 0 {} {} eq \361\0\100\273]} {>

emit {CMU window manager raster image data}

if {[N lelong 4 0 0 {} {} > 0]} {>

emit {%d x}
<}

if {[N lelong 8 0 0 {} {} > 0]} {>

emit %d,
<}

if {[N lelong 12 0 0 {} {} > 0]} {>

emit %d-bit
<}

<}
} {
if {[S string 0 0 {} {} eq id=ImageMagick]} {>

emit {MIFF image data}
<}
} {
if {[S search 0 0 {} 1 eq \#FIG]} {>

emit {FIG image text}

if {[S string 5 0 {} {} x {}]} {>

emit {\b, version %.3s}
<}

<}
} {
if {[S string 0 0 {} {} eq ARF_BEGARF]} {>

emit {PHIGS clear text archive}
<}
} {
if {[S string 0 0 {} {} eq @(\#)SunPHIGS]} {>

emit SunPHIGS

if {[S string 40 0 {} {} eq SunBin]} {>

emit binary
<}

if {[S string 32 0 {} {} eq archive]} {>

emit archive
<}

<}
} {
if {[S string 0 0 {} {} eq GKSM]} {>

emit {GKS Metafile}

if {[S string 24 0 {} {} eq SunGKS]} {>

emit {\b, SunGKS}
<}

<}
} {
if {[S string 0 0 {} {} eq BEGMF]} {>

emit {clear text Computer Graphics Metafile}
<}
} {
if {[S string 0 0 {} {} eq yz]} {>

emit {MGR bitmap, modern format, 8-bit aligned}
<}
} {
if {[S string 0 0 {} {} eq zz]} {>

emit {MGR bitmap, old format, 1-bit deep, 16-bit aligned}
<}
} {
if {[S string 0 0 {} {} eq xz]} {>

emit {MGR bitmap, old format, 1-bit deep, 32-bit aligned}
<}
} {
if {[S string 0 0 {} {} eq yx]} {>

emit {MGR bitmap, modern format, squeezed}
<}
} {
if {[S string 0 0 {} {} eq %bitmap\0]} {>

emit {FBM image data}

switch -- [Nv long 30 0 {} {}] 49 {>;emit {\b, mono};<} 51 {>;emit {\b, color};<} 
<

<}
} {
if {[S string 1 0 {} {} eq PC\ Research,\ Inc]} {>

emit {group 3 fax data}

switch -- [Nv byte 29 0 {} {}] 0 {>;emit {\b, normal resolution (204x98 DPI)};<} 1 {>;emit {\b, fine resolution (204x196 DPI)};<} 
<

<}
} {
if {[S string 0 0 {} {} eq Sfff]} {>

emit {structured fax file}
<}
} {
if {[S string 0 0 {} {} eq \x11\x06]} {>

emit {Award BIOS Logo, 136 x 84}
mime image/x-award-bioslogo

<}
} {
if {[S string 0 0 {} {} eq \x11\x09]} {>

emit {Award BIOS Logo, 136 x 126}
mime image/x-award-bioslogo

<}
} {
if {[S string 0 0 {} {} eq AWBM]} {>

if {[N leshort 4 0 0 {} {} < 1981]} {>

emit {Award BIOS bitmap}

	if {[N leshort 4 0 0 & 3 == 0]} {>

		if {[N leshort 4 0 0 {} {} x {}]} {>

		emit {\b, %d}
<}

		if {[N leshort 6 0 0 {} {} x {}]} {>

		emit {x %d}
<}

<}

	if {[N leshort 4 0 0 & 3 > 0]} {>

	emit {\b,}

		switch -- [Nv leshort 4 0 & 3] 1 {>;
			if {[N leshort 4 0 0 {} {} x {}]} {>

			emit %d+3
<}
;<} 2 {>;
			if {[N leshort 4 0 0 {} {} x {}]} {>

			emit %d+2
<}
;<} 3 {>;
			if {[N leshort 4 0 0 {} {} x {}]} {>

			emit %d+1
<}
;<} 
<

		if {[N leshort 6 0 0 {} {} x {}]} {>

		emit {x %d}
<}

<}

mime image/x-award-bmp

<}

<}
} {
if {[S string 0 0 {} {} eq BM]} {>

switch -- [Nv leshort 14 0 {} {}] 12 {>;emit {PC bitmap, OS/2 1.x format}

	if {[N leshort 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N leshort 20 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 64 {>;emit {PC bitmap, OS/2 2.x format}

	if {[N leshort 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N leshort 20 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 40 {>;emit {PC bitmap, Windows 3.x format}

	if {[N lelong 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N lelong 22 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 28 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 124 {>;emit {PC bitmap, Windows 98/2000 and newer format}

	if {[N lelong 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N lelong 22 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 28 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 108 {>;emit {PC bitmap, Windows 95/NT4 and newer format}

	if {[N lelong 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N lelong 22 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 28 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 128 {>;emit {PC bitmap, Windows NT/2000 format}

	if {[N lelong 18 0 0 {} {} x {}]} {>

	emit {\b, %d x}
<}

	if {[N lelong 22 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 28 0 0 {} {} x {}]} {>

	emit %d
<}

mime image/x-ms-bmp
;<} 
<

<}
} {
if {[S search 0 0 {} 1 eq /*\ XPM\ */]} {>

emit {X pixmap image text}
mime image/x-xpmi

<}
} {
if {[S string 0 0 {} {} eq Imagefile\ version-]} {>

emit {iff image data}

if {[S string 10 0 {} {} > \0]} {>

emit %s
<}

<}
} {
if {[S string 0 0 {} {} eq IT01]} {>

emit {FIT image data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {\b, %d x}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N belong 12 0 0 {} {} x {}]} {>

emit %d
<}

<}
} {
if {[S string 0 0 {} {} eq IT02]} {>

emit {FIT image data}

if {[N belong 4 0 0 {} {} x {}]} {>

emit {\b, %d x}
<}

if {[N belong 8 0 0 {} {} x {}]} {>

emit {%d x}
<}

if {[N belong 12 0 0 {} {} x {}]} {>

emit %d
<}

<}
} {
if {[S string 2048 0 {} {} eq PCD_IPI]} {>

emit {Kodak Photo CD image pack file}

switch -- [Nv byte 3586 0 & 3] 0 {>;emit {, landscape mode};<} 1 {>;emit {, portrait mode};<} 2 {>;emit {, landscape mode};<} 3 {>;emit {, portrait mode};<} 
<

<}
} {
if {[S string 0 0 {} {} eq PCD_OPA]} {>

emit {Kodak Photo CD overview pack file}
<}
} {
if {[S string 0 0 {} {} eq SIMPLE\ \ =]} {>

emit {FITS image data}

if {[S string 109 0 {} {} eq 8]} {>

emit {\b, 8-bit, character or unsigned binary integer}
<}

if {[S string 108 0 {} {} eq 16]} {>

emit {\b, 16-bit, two's complement binary integer}
<}

if {[S string 107 0 {} {} eq \ 32]} {>

emit {\b, 32-bit, two's complement binary integer}
<}

if {[S string 107 0 {} {} eq -32]} {>

emit {\b, 32-bit, floating point, single precision}
<}

if {[S string 107 0 {} {} eq -64]} {>

emit {\b, 64-bit, floating point, double precision}
<}

<}
} {
if {[S string 0 0 {} {} eq This\ is\ a\ BitMap\ file]} {>

emit {Lisp Machine bit-array-file}
<}
} {
if {[S string 128 0 {} {} eq DICM]} {>

emit {DICOM medical imaging data}
mime application/dicom

ext dcm/dicom/dic

<}
} {
if {[N belong 0 0 0 {} {} > 100]} {>

if {[N belong 8 0 0 {} {} < 3]} {>

	if {[N belong 12 0 0 {} {} < 33]} {>

		if {[N belong 4 0 0 {} {} == 7]} {>

		emit {XWD X Window Dump image data}

			if {[S string 100 0 {} {} > \0]} {>

			emit {\b, "%s"}
<}

			if {[N belong 16 0 0 {} {} x {}]} {>

			emit {\b, %dx}
<}

			if {[N belong 20 0 0 {} {} x {}]} {>

			emit {\b%dx}
<}

			if {[N belong 12 0 0 {} {} x {}]} {>

			emit {\b%d}
<}

		mime image/x-xwindowdump

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq NJPL1I00]} {>

emit {PDS (JPL) image data}
<}
} {
if {[S string 2 0 {} {} eq NJPL1I]} {>

emit {PDS (JPL) image data}
<}
} {
if {[S string 0 0 {} {} eq CCSD3ZF]} {>

emit {PDS (CCSD) image data}
<}
} {
if {[S string 2 0 {} {} eq CCSD3Z]} {>

emit {PDS (CCSD) image data}
<}
} {
if {[S string 0 0 {} {} eq PDS_]} {>

emit {PDS image data}
<}
} {
if {[S string 0 0 {} {} eq LBLSIZE=]} {>

emit {PDS (VICAR) image data}
<}
} {
if {[S string 0 0 {} {} eq pM85]} {>

emit {Atari ST STAD bitmap image data (hor)}

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {(white background)};<} -1 {>;emit {(black background)};<} 
<

<}
} {
if {[S string 0 0 {} {} eq pM86]} {>

emit {Atari ST STAD bitmap image data (vert)}

switch -- [Nv byte 5 0 {} {}] 0 {>;emit {(white background)};<} -1 {>;emit {(black background)};<} 
<

<}
} {
if {[N belong 0 0 0 & 4294508032 == 167772160]} {>

if {[N byte 3 0 0 {} {} > 0]} {>

	if {[N byte 1 0 0 {} {} < 6]} {>

		if {[N byte 1 0 0 {} {} != 1]} {>

		emit PCX

			switch -- [Nv byte 1 0 {} {}] 0 {>;emit {ver. 2.5 image data};<} 2 {>;emit {ver. 2.8 image data, with palette};<} 3 {>;emit {ver. 2.8 image data, without palette};<} 4 {>;emit {for Windows image data};<} 5 {>;emit {ver. 3.0 image data};<} 
<

			if {[N leshort 4 0 0 {} {} x {}]} {>

			emit {bounding box [%d,}
<}

			if {[N leshort 6 0 0 {} {} x {}]} {>

			emit {%d] -}
<}

			if {[N leshort 8 0 0 {} {} x {}]} {>

			emit {[%d,}
<}

			if {[N leshort 10 0 0 {} {} x {}]} {>

			emit %d\],
<}

			if {[N byte 65 0 0 {} {} > 1]} {>

			emit {%d planes each of}
<}

			if {[N byte 3 0 0 {} {} x {}]} {>

			emit %d-bit
<}

			switch -- [Nv byte 68 0 {} {}] 1 {>;emit colour,;<} 2 {>;emit grayscale,;<} 
<

			if {[S default 68 0 {} {} x {}]} {>

			emit image,
<}

			if {[N leshort 12 0 0 {} {} > 0]} {>

			emit {%d x}

				if {[N leshort 14 0 0 {} {} x {}]} {>

				emit {%d dpi,}
<}

<}

			switch -- [Nv byte 2 0 {} {}] 0 {>;emit uncompressed;<} 1 {>;emit {RLE compressed};<} 
<

		mime image/x-pcx

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq 8BPS]} {>

emit {Adobe Photoshop Image}

if {[N beshort 4 0 0 {} {} == 2]} {>

emit (PSB)
<}

if {[N belong 18 0 0 {} {} x {}]} {>

emit {\b, %d x}
<}

if {[N belong 14 0 0 {} {} x {}]} {>

emit %d,
<}

switch -- [Nv beshort 24 0 {} {}] 0 {>;emit bitmap;<} 1 {>;emit grayscale

	if {[N beshort 12 0 0 {} {} == 2]} {>

	emit {with alpha}
<}
;<} 2 {>;emit indexed;<} 3 {>;emit RGB

	if {[N beshort 12 0 0 {} {} == 4]} {>

	emit {\bA}
<}
;<} 4 {>;emit CMYK

	if {[N beshort 12 0 0 {} {} == 5]} {>

	emit {\bA}
<}
;<} 7 {>;emit multichannel;<} 8 {>;emit duotone;<} 9 {>;emit lab;<} 
<

if {[N beshort 12 0 0 {} {} > 1]} {>

	if {[N beshort 12 0 0 {} {} x {}]} {>

	emit {\b, %dx}
<}

<}

if {[N beshort 12 0 0 {} {} == 1]} {>

emit {\b,}
<}

if {[N beshort 22 0 0 {} {} x {}]} {>

emit {%d-bit channel}
<}

if {[N beshort 12 0 0 {} {} > 1]} {>

emit {\bs}
<}

mime image/vnd.adobe.photoshop

<}
} {
if {[S string 0 0 {} {} eq P7\ 332]} {>

emit {XV thumbnail image data}
<}
} {
if {[S string 0 0 {} {} eq NITF]} {>

emit {National Imagery Transmission Format}

if {[S string 25 0 {} {} > \0]} {>

emit {dated %.14s}
<}

<}
} {
if {[S string 16 0 {} {} eq XIMG\0]} {>
U 262 gem_info

<}
} {
if {[S string 16 0 {} {} eq STTT\0\x10]} {>
U 262 gem_info

<}
} {
if {[S string 16 0 {} {} eq TIMG\0]} {>
U 262 gem_info

<}
} {
if {[S string 0 0 {} {} eq \0\nSMJPEG]} {>

emit SMJPEG

if {[N belong 8 0 0 {} {} x {}]} {>

emit {%d.x data}
<}

if {[S string 16 0 {} {} eq _SND]} {>

emit {\b,}

	if {[N beshort 24 0 0 {} {} > 0]} {>

	emit {%d Hz}
<}

	switch -- [Nv byte 26 0 {} {}] 8 {>;emit 8-bit;<} 16 {>;emit 16-bit;<} 
<

	if {[S string 28 0 {} {} eq NONE]} {>

	emit uncompressed
<}

	if {[N byte 27 0 0 {} {} == 1]} {>

	emit mono
<}

	if {[N byte 28 0 0 {} {} == 2]} {>

	emit stereo
<}

	if {[S string 32 0 {} {} eq _VID]} {>

	emit {\b,}

		if {[N belong 40 0 0 {} {} > 0]} {>

		emit {%d frames}
<}

		if {[N beshort 44 0 0 {} {} > 0]} {>

		emit {(%d x}
<}

		if {[N beshort 46 0 0 {} {} > 0]} {>

		emit %d)
<}

<}

<}

if {[S string 16 0 {} {} eq _VID]} {>

emit {\b,}

	if {[N belong 24 0 0 {} {} > 0]} {>

	emit {%d frames}
<}

	if {[N beshort 28 0 0 {} {} > 0]} {>

	emit {(%d x}
<}

	if {[N beshort 30 0 0 {} {} > 0]} {>

	emit %d)
<}

<}

<}
} {
if {[S string 0 0 {} {} eq Paint\ Shop\ Pro\ Image\ File]} {>

emit {Paint Shop Pro Image File}
<}
} {
if {[S string 0 0 {} {} eq P7\ 332]} {>

emit {XV "thumbnail file" (icon) data}
<}
} {
if {[S string 0 0 {} {} eq KiSS]} {>

emit KISS/GS

switch -- [Nv byte 4 0 {} {}] 16 {>;emit color

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {%d bit}
<}

	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {%d colors}
<}

	if {[N leshort 10 0 0 {} {} x {}]} {>

	emit {%d groups}
<}
;<} 32 {>;emit cell

	if {[N byte 5 0 0 {} {} x {}]} {>

	emit {%d bit}
<}

	if {[N leshort 8 0 0 {} {} x {}]} {>

	emit {%d x}
<}

	if {[N leshort 10 0 0 {} {} x {}]} {>

	emit %d
<}

	if {[N leshort 12 0 0 {} {} x {}]} {>

	emit +%d
<}

	if {[N leshort 14 0 0 {} {} x {}]} {>

	emit +%d
<}
;<} 
<

<}
} {
if {[S string 0 0 {} {} eq C\253\221g\230\0\0\0]} {>

emit {Webshots Desktop .wbz file}
<}
} {
if {[S string 0 0 {} {} eq CKD_P370]} {>

emit {Hercules CKD DASD image file}

if {[N long 8 0 0 {} {} x {}]} {>

emit {\b, %d heads per cylinder}
<}

if {[N long 12 0 0 {} {} x {}]} {>

emit {\b, track size %d bytes}
<}

if {[N byte 16 0 0 {} {} x {}]} {>

emit {\b, device type 33%2.2X}
<}

<}
} {
if {[S string 0 0 {} {} eq CKD_C370]} {>

emit {Hercules compressed CKD DASD image file}

if {[N long 8 0 0 {} {} x {}]} {>

emit {\b, %d heads per cylinder}
<}

if {[N long 12 0 0 {} {} x {}]} {>

emit {\b, track size %d bytes}
<}

if {[N byte 16 0 0 {} {} x {}]} {>

emit {\b, device type 33%2.2X}
<}

<}
} {
if {[S string 0 0 {} {} eq CKD_S370]} {>

emit {Hercules CKD DASD shadow file}

if {[N long 8 0 0 {} {} x {}]} {>

emit {\b, %d heads per cylinder}
<}

if {[N long 12 0 0 {} {} x {}]} {>

emit {\b, track size %d bytes}
<}

if {[N byte 16 0 0 {} {} x {}]} {>

emit {\b, device type 33%2.2X}
<}

<}
} {
if {[S string 0 0 {} {} eq \146\031\0\0]} {>

emit {Squeak image data}
<}
} {
if {[S search 0 0 {} 1 eq 'From\040Squeak]} {>

emit {Squeak program text}
<}
} {
if {[S string 0 0 {} {} eq PaRtImAgE-VoLuMe]} {>

emit PartImage

if {[S string 32 0 {} {} eq 0.6.1]} {>

emit {file version %s}

	if {[N lelong 96 0 0 {} {} > -1]} {>

	emit {volume %d}
<}

	if {[S string 512 0 {} {} > \0]} {>

	emit {type %s}
<}

	if {[S string 5120 0 {} {} > \0]} {>

	emit {device %s,}
<}

	if {[S string 5632 0 {} {} > \0]} {>

	emit {original filename %s,}
<}

	switch -- [Nv lelong 10052 0 {} {}] 0 {>;emit {not compressed};<} 1 {>;emit {gzip compressed};<} 2 {>;emit {bzip2 compressed};<} 
<

	if {[N lelong 10052 0 0 {} {} > 2]} {>

	emit {compressed with unknown algorithm}
<}

<}

if {[S string 32 0 {} {} > 0.6.1]} {>

emit {file version %s}
<}

if {[S string 32 0 {} {} < 0.6.1]} {>

emit {file version %s}
<}

<}
} {
if {[N leshort 14 0 0 {} {} < 2]} {>

if {[N leshort 62 0 0 {} {} < 2]} {>

	if {[N leshort 54 0 0 {} {} == 12345]} {>

	emit {Bio-Rad .PIC Image File}

		if {[N leshort 0 0 0 {} {} > 0]} {>

		emit {%d x}
<}

		if {[N leshort 2 0 0 {} {} > 0]} {>

		emit %d,
<}

		if {[N leshort 4 0 0 {} {} == 1]} {>

		emit {1 image in file}
<}

		if {[N leshort 4 0 0 {} {} > 1]} {>

		emit {%d images in file}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq \000MRM]} {>

emit {Minolta Dimage camera raw image data}
<}
} {
if {[S string 0 0 {} {} eq AT&TFORM]} {>

if {[S string 12 0 {} {} eq DJVM]} {>

emit {DjVu multiple page document}
mime image/vnd.djvu

<}

if {[S string 12 0 {} {} eq DJVU]} {>

emit {DjVu image or single page document}
mime image/vnd.djvu

<}

if {[S string 12 0 {} {} eq DJVI]} {>

emit {DjVu shared document}
mime image/vnd.djvu

<}

if {[S string 12 0 {} {} eq THUM]} {>

emit {DjVu page thumbnails}
mime image/vnd.djvu

<}

<}
} {
if {[S string 0 0 {} {} eq SDPX]} {>

emit {DPX image data, big-endian,}

if {[N beshort 768 0 0 {} {} < 4]} {>

	if {[N belong 772 0 0 {} {} x {}]} {>

	emit %dx
<}

	if {[N belong 776 0 0 {} {} x {}]} {>

	emit {\b%d,}
<}

<}

if {[N beshort 768 0 0 {} {} > 3]} {>

	if {[N belong 776 0 0 {} {} x {}]} {>

	emit %dx
<}

	if {[N belong 772 0 0 {} {} x {}]} {>

	emit {\b%d,}
<}

<}

switch -- [Nv beshort 768 0 {} {}] 0 {>;emit {left to right/top to bottom};<} 1 {>;emit {right to left/top to bottom};<} 2 {>;emit {left to right/bottom to top};<} 3 {>;emit {right to left/bottom to top};<} 4 {>;emit {top to bottom/left to right};<} 5 {>;emit {top to bottom/right to left};<} 
<

switch -- [Nv leshort 768 0 {} {}] 6 {>;emit {bottom to top/left to right};<} 7 {>;emit {bottom to top/right to left};<} 
<

mime image/x-dpx

<}
} {
if {[S string 0 0 {} {} eq CDF\001]} {>

emit {NetCDF Data Format data}
<}
} {
if {[S string 0 0 {} {} eq \211HDF\r\n\032\n]} {>

emit {Hierarchical Data Format (version 5) data}
mime application/x-hdf

<}
} {
if {[S string 512 0 {} {} eq \211HDF\r\n\032\n]} {>

emit {Hierarchical Data Format (version 5) with 512 bytes user block}
mime application/x-hdf

<}
} {
if {[S string 1024 0 {} {} eq \211HDF\r\n\032\n]} {>

emit {Hierarchical Data Format (version 5) with 1k user block}
mime application/x-hdf

<}
} {
if {[S string 2048 0 {} {} eq \211HDF\r\n\032\n]} {>

emit {Hierarchical Data Format (version 5) with 2k user block}
mime application/x-hdf

<}
} {
if {[S string 4096 0 {} {} eq \211HDF\r\n\032\n]} {>

emit {Hierarchical Data Format (version 5) with 4k user block}
mime application/x-hdf

<}
} {
if {[S string 0 0 {} {} eq XARA\243\243]} {>

emit {Xara graphics file}
<}
} {
if {[S string 0 0 {} {} eq CPC\262]} {>

emit {Cartesian Perceptual Compression image}
mime image/x-cpi

<}
} {
if {[S string 0 0 {} {} eq C565]} {>

emit {OLPC firmware icon image data}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {%u x}
<}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit %u
<}

<}
} {
if {[S string 0 0 {} {} eq \xce\xda\xde\xfa]} {>

emit {Cytovision Metaphases file}
<}
} {
if {[S string 0 0 {} {} eq \xed\xad\xef\xac]} {>

emit {Cytovision Karyotype file}
<}
} {
if {[S string 0 0 {} {} eq \x0b\x00\x03\x00]} {>

emit {Cytovision FISH Probe file}
<}
} {
if {[S string 0 0 {} {} eq \xed\xfe\xda\xbe]} {>

emit {Cytovision FLEX file}
<}
} {
if {[S string 0 0 {} {} eq \xed\xab\xed\xfe]} {>

emit {Cytovision FLEX file}
<}
} {
if {[S string 0 0 {} {} eq \xad\xfd\xea\xad]} {>

emit {Cytovision RATS file}
<}
} {
if {[S string 0 0 {} {} eq \xff\xa0\xff\xa8\x00]} {>

emit {Wavelet Scalar Quantization image data}
<}
} {
if {[S string 0 0 b {} eq PCO-]} {>

emit {PCO B16 image data}

if {[N lelong 12 0 0 {} {} x {}]} {>

emit {\b, %dx}
<}

if {[N lelong 16 0 0 {} {} x {}]} {>

emit {\b%d}
<}

switch -- [Nv lelong 20 0 {} {}] 0 {>;emit {\b, short header};<} -1 {>;emit {\b, extended header}

	switch -- [Nv lelong 24 0 {} {}] 0 {>;emit {\b, grayscale}

		switch -- [Nv lelong 36 0 {} {}] 0 {>;emit {linear LUT};<} 1 {>;emit {logarithmic LUT};<} 
<

		if {[N lelong 28 0 0 {} {} x {}]} {>

		emit {[%d}
<}

		if {[N lelong 32 0 0 {} {} x {}]} {>

		emit {\b,%d]}
<}
;<} 1 {>;emit {\b, color}

		switch -- [Nv lelong 64 0 {} {}] 0 {>;emit {linear LUT};<} 1 {>;emit {logarithmic LUT};<} 
<

		if {[N lelong 40 0 0 {} {} x {}]} {>

		emit {r[%d}
<}

		if {[N lelong 44 0 0 {} {} x {}]} {>

		emit {\b,%d]}
<}

		if {[N lelong 48 0 0 {} {} x {}]} {>

		emit {g[%d}
<}

		if {[N lelong 52 0 0 {} {} x {}]} {>

		emit {\b,%d]}
<}

		if {[N lelong 56 0 0 {} {} x {}]} {>

		emit {b[%d}
<}

		if {[N lelong 60 0 0 {} {} x {}]} {>

		emit {\b,%d]}
<}
;<} 
<
;<} 
<

<}
} {
if {[S string 0 0 t {} eq \[BitmapInfo2\]]} {>

emit {Polar Monitor Bitmap text}
mime image/x-polar-monitor-bitmap

<}
} {
if {[S string 0 0 {} {} eq GARMIN\ BITMAP\ 01]} {>

emit {Garmin Bitmap file}

if {[S string 47 0 {} {} > 0]} {>

emit {\b, version %4.4s}
<}

if {[N leshort 85 0 0 {} {} > 0]} {>

emit {\b, %dx}

	if {[N leshort 83 0 0 {} {} x {}]} {>

	emit {\b%d}
<}

<}

ext srf

<}
} {
if {[S string 0 0 {} {} eq IIO2H]} {>

emit {Ulead Photo Explorer5}
<}
} {
if {[S string 0 0 {} {} eq Xcur]} {>

emit {X11 cursor}
<}
} {
if {[S string 0 0 {} {} eq MMOR]} {>

emit {Olympus ORF raw image data, big-endian}
mime image/x-olympus-orf

<}
} {
if {[S string 0 0 {} {} eq IIRO]} {>

emit {Olympus ORF raw image data, little-endian}
mime image/x-olympus-orf

<}
} {
if {[S string 0 0 {} {} eq IIRS]} {>

emit {Olympus ORF raw image data, little-endian}
mime image/x-olympus-orf

<}
} {
if {[S string 0 0 {} {} eq HDMV0100]} {>

emit {AVCHD Clip Information}
<}
} {
if {[S string 0 0 {} {} eq \#?RADIANCE\n]} {>

emit {Radiance HDR image data}
<}
} {
if {[S string 0 0 {} {} eq PFS1\x0a]} {>

emit {PFS HDR image data}

if {[S regex 1 0 {} {} eq \[0-9\]*\ ]} {>

emit {\b, %s}

	if {[S regex 1 0 {} {} eq \ \[0-9\]\{4\}]} {>

	emit {\bx%s}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq FOVb]} {>

emit {Foveon X3F raw image data}

if {[N leshort 6 0 0 {} {} x {}]} {>

emit {\b, version %d.}
<}

if {[N leshort 4 0 0 {} {} x {}]} {>

emit {\b%d}
<}

if {[N lelong 28 0 0 {} {} x {}]} {>

emit {\b, %dx}
<}

if {[N lelong 32 0 0 {} {} x {}]} {>

emit {\b%d}
<}

mime image/x-x3f

<}
} {
if {[S string 0 0 {} {} eq PDN3]} {>

emit {Paint.NET image data}
mime image/x-paintnet

<}
} {
if {[S string 0 0 {} {} eq \x46\x4d\x52\x00]} {>

emit {ISO/IEC 19794-2 Format Minutiae Record (FMR)}
<}
} {
if {[N bequad 90 0 0 {} {} == 6290772526005243648]} {>

emit {JPEG-XR Image}

if {[N byte 98 0 0 & 8 == 8]} {>

emit {\b, hard tiling}
<}

if {[N byte 99 0 0 & 128 == 128]} {>

emit {\b, tiling present}
<}

if {[N byte 99 0 0 & 64 == 64]} {>

emit {\b, codestream present}
<}

if {[N byte 99 0 0 & 56 x {}]} {>

emit {\b, spatial xform=}
<}

switch -- [Nv byte 99 0 & 56] 0 {>;emit {\bTL};<} 8 {>;emit {\bBL};<} 16 {>;emit {\bTR};<} 24 {>;emit {\bBR};<} 32 {>;emit {\bBT};<} 40 {>;emit {\bRB};<} 48 {>;emit {\bLT};<} 56 {>;emit {\bLB};<} 
<

switch -- [Nv byte 100 0 & 128] -128 {>;emit {\b, short header}

	if {[N beshort 102 0 0 + 1 x {}]} {>

	emit {\b, %d}
<}

	if {[N beshort 104 0 0 + 1 x {}]} {>

	emit {\bx%d}
<}
;<} 0 {>;emit {\b, long header}

	if {[N belong 102 0 0 + 1 x {}]} {>

	emit {\b, %x}
<}

	if {[N belong 106 0 0 + 1 x {}]} {>

	emit {\bx%x}
<}
;<} 
<

if {[N beshort 101 0 0 & 15 x {}]} {>

emit {\b, bitdepth=}

	switch -- [Nv beshort 101 0 & 15] 0 {>;emit {\b1-WHITE=1};<} 1 {>;emit {\b8};<} 2 {>;emit {\b16};<} 3 {>;emit {\b16-SIGNED};<} 4 {>;emit {\b16-FLOAT};<} 5 {>;emit {\b(reserved 5)};<} 6 {>;emit {\b32-SIGNED};<} 7 {>;emit {\b32-FLOAT};<} 8 {>;emit {\b5};<} 9 {>;emit {\b10};<} 10 {>;emit {\b5-6-5};<} 11 {>;emit {\b(reserved %d)};<} 12 {>;emit {\b(reserved %d)};<} 13 {>;emit {\b(reserved %d)};<} 14 {>;emit {\b(reserved %d)};<} 15 {>;emit {\b1-BLACK=1};<} 
<

<}

if {[N beshort 101 0 0 & 240 x {}]} {>

emit {\b, colorfmt=}

	switch -- [Nv beshort 101 0 & 240] 0 {>;emit {\bYONLY};<} 16 {>;emit {\bYUV240};<} 32 {>;emit {\bYWV422};<} 48 {>;emit {\bYWV444};<} 64 {>;emit {\bCMYK};<} 80 {>;emit {\bCMYKDIRECT};<} 96 {>;emit {\bNCOMPONENT};<} 112 {>;emit {\bRGB};<} 128 {>;emit {\bRGBE};<} 
<

	if {[N beshort 101 0 0 & 240 > 128]} {>

	emit {\b(reserved 0x%x)}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq \x42\x50\x47\xFB]} {>

emit {BPG (Better Portable Graphics)}
mime image/bpg

<}
} {
if {[S string 0 0 {} {} eq icns]} {>

emit {Mac OS X icon}

if {[N belong 4 0 0 {} {} > 0]} {>

	if {[N belong 4 0 0 {} {} x {}]} {>

	emit {\b, %d bytes}
<}

	if {[S string 8 0 {} {} x {}]} {>

	emit {\b, "%4.4s" type}
<}

<}

mime image/x-icns

ext icns

<}
} {
if {[S string 0 0 {} {} eq farbfeld]} {>

emit {farbfeld image data,}

if {[N belong 8 0 0 {} {} x {}]} {>

emit %dx
<}

if {[N belong 12 0 0 {} {} x {}]} {>

emit {\b%d}
<}

<}
} {
if {[S string 0 0 {} {} eq PVRT]} {>

if {[S string 16 0 {} {} eq DDS\040\174\000\000\000]} {>

emit {Sega PVR (Xbox) image:}
U 262 sega-pvr-xbox-dds-header

<}

if {[N belong 16 0 0 {} {} != 1145328416]} {>

emit {Sega PVR image:}
U 262 sega-pvr-image-header

<}

<}
} {
if {[S string 0 0 {} {} eq GBIX]} {>

if {[S string 16 0 {} {} eq PVRT]} {>

	if {[S string 16 0 {} {} eq DDS\040\174\000\000\000]} {>

	emit {Sega PVR (Xbox) image:}
U 262 sega-pvr-xbox-dds-header

<}

	if {[N belong 16 0 0 {} {} != 1145328416]} {>

	emit {Sega PVR image:}
U 262 sega-pvr-image-header

<}

	if {[N lelong 8 0 0 {} {} x {}]} {>

	emit {\b, global index = %u}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq GVRT]} {>

emit {Sega GVR image:}
U 262 sega-gvr-image-header

<}
} {
if {[S string 0 0 {} {} eq GBIX]} {>

if {[S string 16 0 {} {} eq GVRT]} {>

emit {Sega GVR image:}
U 262 sega-gvr-image-header

	if {[N belong 8 0 0 {} {} x {}]} {>

	emit {\b, global index = %u}
<}

<}

<}
} {
if {[S string 0 0 {} {} eq C\0\0\0R\0\0\0]} {>

emit BLCR

switch -- [Nv lelong 16 0 {} {}] 1 {>;emit x86;<} 3 {>;emit alpha;<} 5 {>;emit x86-64;<} 7 {>;emit ARM;<} 
<

if {[N lelong 8 0 0 {} {} x {}]} {>

emit {context data (little endian, version %d)}
<}

<}
} {
if {[S string 0 0 {} {} eq \0\0\0C\0\0\0R]} {>

emit BLCR

switch -- [Nv belong 16 0 {} {}] 2 {>;emit SPARC;<} 4 {>;emit ppc;<} 6 {>;emit ppc64;<} 7 {>;emit ARMEB;<} 8 {>;emit SPARC64;<} 
<

if {[N belong 8 0 0 {} {} x {}]} {>

emit {context data (big endian, version %d)}
<}

<}
} {
if {[N beshort 0 0 0 & 65376 == 43520]} {>

if {[N byte 1 0 0 {} {} != 4]} {>

	if {[N beshort 2 0 0 {} {} > 0]} {>

	emit {Dyalog APL}

		switch -- [Nv byte 1 0 {} {}] 0 {>;emit aplcore;<} 1 {>;emit {component file 32-bit non-journaled non-checksummed};<} 2 {>;emit {external variable exclusive};<} 3 {>;emit workspace

			switch -- [Nv byte 7 0 & 40] 0 {>;emit 32-bit;<} 32 {>;emit 64-bit;<} 
<

			switch -- [Nv byte 7 0 & 12] 0 {>;emit classic;<} 4 {>;emit unicode;<} 
<

			switch -- [Nv byte 7 0 & 136] 0 {>;emit big-endian;<} -128 {>;emit little-endian;<} 
<
;<} 6 {>;emit {external variable shared};<} 7 {>;emit session;<} 8 {>;emit {mapped file 32-bit};<} 9 {>;emit {component file 64-bit non-journaled non-checksummed};<} 10 {>;emit {mapped file 64-bit};<} 11 {>;emit {component file 32-bit level 1 journaled non-checksummed};<} 12 {>;emit {component file 64-bit level 1 journaled non-checksummed};<} 13 {>;emit {component file 32-bit level 1 journaled checksummed};<} 14 {>;emit {component file 64-bit level 1 journaled checksummed};<} 15 {>;emit {component file 32-bit level 2 journaled checksummed};<} 16 {>;emit {component file 64-bit level 2 journaled checksummed};<} 17 {>;emit {component file 32-bit level 3 journaled checksummed};<} 18 {>;emit {component file 64-bit level 3 journaled checksummed};<} 19 {>;emit {component file 32-bit non-journaled checksummed};<} 20 {>;emit {component file 64-bit non-journaled checksummed};<} 21 {>;emit {component file under construction};<} 22 {>;emit {DFS component file 64-bit level 1 journaled checksummed};<} 23 {>;emit {DFS component file 64-bit level 2 journaled checksummed};<} 24 {>;emit {DFS component file 64-bit level 3 journaled checksummed};<} 25 {>;emit {external workspace};<} -128 {>;emit DDB;<} 
<

		if {[N byte 2 0 0 {} {} x {}]} {>

		emit {version %d}
<}

		if {[N byte 3 0 0 {} {} x {}]} {>

		emit {\b.%d}
<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq <?xml\ version=\"]} {>

if {[S string 15 0 {} {} > \0]} {>

	if {[S search 19 0 {} 4096 eq <svg]} {>

	emit {SVG Scalable Vector Graphics image}
	mime image/svg+xml

<}

	if {[S search 19 0 {} 4096 eq <gnc-v2]} {>

	emit {GnuCash file}
	mime application/x-gnucash

<}

<}

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=\"]} {>

if {[S string 15 0 {} {} > \0]} {>

	if {[S search 19 0 {} 4096 eq <urlset]} {>

	emit {XML Sitemap document text}
	mime application/xml-sitemap

<}

<}

<}
} {
if {[S string 0 0 {} {} eq <?xml\ version=\"]} {>

if {[S string 15 0 {} {} > \0]} {>

	if {[S search 19 0 {} 4096 eq <osm]} {>

	emit {OpenStreetMap XML data}
<}

<}

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=\"]} {>

if {[S search 19 0 {c W b t} 4096 eq <!doctype\ html]} {>

emit {XHTML document text}

	if {[S string 15 0 {} {} > \0]} {>

	emit {(version %.3s)}
	mime text/html

<}

<}

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=']} {>

if {[S search 19 0 {c W b t} 4096 eq <!doctype\ html]} {>

emit {XHTML document text}

	if {[S string 15 0 {} {} > \0]} {>

	emit {(version %.3s)}
	mime text/html

<}

<}

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=\"]} {>

if {[S search 19 0 {c W b t} 4096 eq <html]} {>

emit {broken XHTML document text}

	if {[S string 15 0 {} {} > \0]} {>

	emit {(version %.3s)}
	mime text/html

<}

<}

<}
} {
if {[S search 0 0 {c W t} 4096 eq <!doctype\ html]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <head>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <head\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <title>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <title\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <html>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <html\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <script>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <script\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <style>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <style\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <table>]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c W t} 4096 eq <table\ ]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 4096 eq <a\ href=]} {>

emit {HTML document text}
mime text/html

<}
} {
if {[S search 0 0 {c w t} 1 eq <?xml]} {>

emit {XML document text}
mime text/xml

<}
} {
if {[S string 0 0 t {} eq <?xml\ version\ \"]} {>

emit XML
mime text/xml

<}
} {
if {[S string 0 0 t {} eq <?xml\ version=\"]} {>

emit XML

if {[S string 15 0 t {} > \0]} {>

emit {%.3s document text}

	if {[S search 23 0 {} 1 eq <xsl:stylesheet]} {>

	emit {(XSL stylesheet)}
<}

	if {[S search 24 0 {} 1 eq <xsl:stylesheet]} {>

	emit {(XSL stylesheet)}
<}

<}

mime text/xml

<}
} {
if {[S string 0 0 {} {} eq <?xml\ version=']} {>

emit XML

if {[S string 15 0 t {} > \0]} {>

emit {%.3s document text}

	if {[S search 23 0 {} 1 eq <xsl:stylesheet]} {>

	emit {(XSL stylesheet)}
<}

	if {[S search 24 0 {} 1 eq <xsl:stylesheet]} {>

	emit {(XSL stylesheet)}
<}

<}

mime text/xml

<}
} {
if {[S search 0 0 {w t} 1 eq <?XML]} {>

emit {broken XML document text}
mime text/xml

<}
} {
if {[S search 0 0 {c w t} 4096 eq <!doctype]} {>

emit {exported SGML document text}
<}
} {
if {[S search 0 0 {c w t} 4096 eq <!subdoc]} {>

emit {exported SGML subdocument text}
<}
} {
if {[S search 0 0 {c w t} 4096 eq <!--]} {>

emit {exported SGML document text}
<}
} {
if {[S search 0 0 {} 1 eq \#\ HTTP\ Cookie\ File]} {>

emit {Web browser cookie text}
<}
} {
if {[S search 0 0 {} 1 eq \#\ Netscape\ HTTP\ Cookie\ File]} {>

emit {Netscape cookie text}
<}
} {
if {[S search 0 0 {} 1 eq \#\ KDE\ Cookie\ File]} {>

emit {Konqueror cookie text}
<}
} {
if {[S regex 0 0 l 100 eq ^CFLAGS]} {>

emit {makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^VPATH]} {>

emit {makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^LDFLAGS]} {>

emit {makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^all:]} {>

emit {makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^.PRECIOUS]} {>

emit {makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^.BEGIN]} {>

emit {BSD makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^.include]} {>

emit {BSD makefile script text}
mime text/x-makefile

<}
} {
if {[S regex 0 0 l 100 eq ^SUBDIRS]} {>

emit {automake makefile script text}
mime text/x-makefile

<}
} {
if {[S string 1 0 {} {} eq WS]} {>

if {[N lelong 4 0 0 {} {} != 0]} {>

	if {[N byte 3 0 0 {} {} == 255]} {>

	emit Suspicious
U 267 swf-details

<}

	if {[N byte 3 0 0 {} {} < 32]} {>

		if {[N byte 3 0 0 {} {} != 0]} {>
U 267 swf-details

<}

<}

<}

<}
} {
if {[S string 0 0 {} {} eq FLV\x01]} {>

emit {Macromedia Flash Video}
mime video/x-flv

<}
} {
if {[S string 0 0 {} {} eq AGD2\xbe\xb8\xbb\xcd\x00]} {>

emit {Macromedia Freehand 7 Document}
<}
} {
if {[S string 0 0 {} {} eq AGD3\xbe\xb8\xbb\xcc\x00]} {>

emit {Macromedia Freehand 8 Document}
<}
} {
if {[S string 0 0 {} {} eq AGD4\xbe\xb8\xbb\xcb\x00]} {>

emit {Macromedia Freehand 9 Document}
<}
} {
if {[S string 0 0 {} {} eq !<arch>\n________64E]} {>

emit {Alpha archive}

if {[S string 22 0 {} {} eq X]} {>

emit {-- out of date}
<}

<}
} {
if {[S string 0 0 {} {} eq Core\001]} {>

emit {Alpha COFF format core dump (Digital UNIX)}

if {[S string 24 0 {} {} > \0]} {>

emit {\b, from '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq Core\002]} {>

emit {Alpha COFF format core dump (Digital UNIX)}

if {[S string 24 0 {} {} > \0]} {>

emit {\b, from '%s'}
<}

<}
} {
if {[S string 0 0 {} {} eq \377\377\177]} {>

emit ddis/ddif
<}
} {
if {[S string 0 0 {} {} eq \377\377\174]} {>

emit {ddis/dots archive}
<}
} {
if {[S string 0 0 {} {} eq \377\377\176]} {>

emit {ddis/dtif table data}
<}
} {
if {[S string 0 0 {} {} eq \033c\033]} {>

emit {LN03 output}
<}
} {
if {[S string 0 0 {} {} eq !<PDF>!\n]} {>

emit {profiling data file}
<}
}} {
	    set level 0
	    set ext {}
	    set mime {}
	    try $test
	    lassign [resultv] found weight result
	    if {$found}  {
		yield [list $weight $result $mime [split $ext /]]
	    }
	}
	return
    

    }

## -- ** END GENERATED CODE ** --
## -- Do not edit before this line !
##

# ### ### ### ######### ######### #########
## Ready for use.
# EOF
