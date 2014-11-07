oo::class create CFB {
	variable fd
	variable attr
    
	variable hdrFields dirFields

	constructor {} {

	set hdrFields {
	    magic a8	 clsid a16	 minor s	 major s	 order s
		sshift s	 msshift s	 resvd a6	 ndirs i	 nfats i
		fds i		 tsn i		 mscs i		 fmf i		 nmf i
		fdf i		 ndf i		 dfs i109
	}

	set dirFields {
	    name2 a64	nlen s	 otype c	 color c	
		lsid  i		rsid i	 cid  i
		clsid a16 	state i  
		ctime w  	mtime w 
		ss i		sz w
	}

	    dict set attr ssize 512
	}

	method ReadStruct {fields data {ofs 0}} {
	    binary scan $data "x$ofs [dict values $fields]" {*}[dict keys $fields]
		set struct [dict create]
		foreach key [dict keys $fields] {
		    dict set struct $key [set $key]
		}
		return $struct
	}


    method open {file} {
	    set fd [::open $file]
		chan configure $fd -translation binary
		my ReadHdr
		my ReadFat
		my ReadDir
		my ReadMiniFat
		# puts 0x[string toupper [binary encode hex [dict get $attr magic]]]
	}

	method ReadSect {sn {count 1}} {
	    seek $fd [expr {[dict get $attr ssize] * (1 + $sn)}]
		read $fd [expr {$count * [dict get $attr ssize]}]
	}

	method ReadMiniSect {sn {count 1}} {
		set stream [my ReadStream [dict get $attr ministart]]
		set ofs [expr {[dict get $attr mssize] * $sn}]
		binary scan $stream "x$ofs a[expr {$count * [dict get $attr mssize]}]" data
		return $data
	}

	method ReadHdr {} {
	    set hdr [my ReadSect -1]
		set attr [dict merge $attr [my ReadStruct $hdrFields $hdr]]
		dict set attr ssize [expr {1 << [dict get $attr sshift]}]
		dict set attr mssize [expr {1 << [dict get $attr msshift]}]
	}

	method ReadFatSect {sn} {
	    set rsn [lindex [dict get $attr dfs] $sn]
		my ReadSect $rsn
	}

	method ReadFat {} {
	    for {set c 0} {$c < [dict get $attr nfats]} {incr c} {
		    binary scan [my ReadFatSect $c] i[expr {[dict get $attr ssize]/4}] _fat
			dict lappend attr fat {*}$_fat
		}
	}

	method ReadMiniFat {} {
		dict set attr minifat {}
		if {[dict get $attr fmf] != -1} {
			set ministream [my ReadStream [dict get $attr fmf]]
			binary scan $ministream "i[expr {[dict get $attr nmf]*[dict get $attr ssize] / 4}]" minifat
			dict set attr minifat $minifat
		}
	}

	method GetStream {ss fat} {
		set ns $ss
	    set sectors [list]
		while {$ns != -2} {
		    lappend sectors $ns
			set ns [lindex $fat $ns]
		}
		return $sectors
	}

	method ReadStream {ss} {
	    set data ""
		foreach sector [my GetStream $ss [dict get $attr fat]] {
			append data [my ReadSect $sector]
		}
		return $data
	}

	method ReadMiniStream {ss} {
	    set data ""
		foreach sector [my GetStream $ss [dict get $attr minifat]] {
			append data [my ReadMiniSect $sector]
		}
		return $data
	}

	method ReadDir {} {
	    set dir [my ReadStream [dict get $attr fds]]
		set dirlen [string length $dir]
		set dirattrs {name2 nlen otype color lsid rsid cid clsid state ctime mtime ss sz}
		set ofs 0
		dict set attr dir {}
		while {$ofs < $dirlen} {
		    set ent [my ReadStruct $dirFields $dir $ofs]
			incr ofs 128
			# if {[dict get $ent otype] == 0} continue
			set name [encoding convertfrom unicode [string range [dict get $ent name2] 0 [dict get $ent nlen]-2]]
			dict set ent clsid [binary encode hex [dict get $ent clsid]]
			dict set ent name $name
			dict unset ent name2
			dict lappend attr dir $ent
			# root storage object
			if {[dict get $ent otype] == 5} {
			    # puts "Root Storage Object: $ent"
				dict set attr ministart [dict get $ent ss]
				# puts "ministaart: [dict get $ent ss]"
				dict set attr minisize [dict get $ent sz]
				# puts "minisize: [dict get $ent sz]"
			}
		}
	}

	method dir {} {
	    return [dict get $attr dir]
	}

	method dirEnt {n {key ""}} {
		if {$key == ""} {
			return [lindex [dict get $attr dir] $n]
		} else {
			return [dict get [lindex [dict get $attr dir] $n] $key]
		}
	}

	method Children {n} {
		set ent [my dirEnt $n]
		return [my Dir [dict get $ent cid]]
	}

	method Dir {n} {
		if {$n == -1} {return {}}
		set ent [my dirEnt $n]
		return [list {*}[my Dir [dict get $ent lsid]] $n {*}[my Dir [dict get $ent rsid]]]
	}

	# returns the tree rooted at stream n
	# {id {children}}
	method dirTree {n {in ""}} {
		foreach ch [my Children $n] {
		    set ent [my dirEnt $ch]
			puts "${in}sid $ch: [dict get $ent name] ([dict get $ent sz])"
			my dirTree $ch "$in  "
		}
	}

	method attr {} {
	    return $attr
	}

	method getStream {n} {
		if {[my dirEnt $n  sz] < [dict get $attr mscs]} {
		    return [my ReadMiniStream [my dirEnt $n ss]]
		} else {
		    return [my ReadStream [my dirEnt $n ss]]
		}
	}

}

set cfb [CFB new]
$cfb open [lindex $argv 0]

set ent [$cfb dirEnt 0]
puts "sid 0: [dict get $ent name] ([dict get $ent sz])"

if {[lindex $argv 1] != ""} {
    puts [$cfb getStream [lindex $argv 1]]
} else {
	$cfb dirTree 0
}
