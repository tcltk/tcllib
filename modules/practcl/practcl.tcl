###
# Amalgamated package for practcl
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package require Tcl 8.5
package provide practcl 0.11
namespace eval ::practcl {}

###
# START: httpwget/wget.tcl
###
###
# Tool to download file from the web
# Enhacements to http
###
package provide http::wget 0.1
package require http

::namespace eval ::http {}

###
# topic: 1ed971e03ae89415e2f25d20e59b765c
# description: this proc contributed by Donal Fellows
###
proc ::http::_followRedirects {url args} {
    while 1 {
        set token [geturl $url -validate 1]
        set ncode [ncode $token]
        if { $ncode eq "404" } {
          error "URL Not found"
        }
        switch -glob $ncode {
            30[1237] {### redirect - see below ###}
            default  {cleanup $token ; return $url}
        }
        upvar #0 $token state
        array set meta [set ${token}(meta)]
        cleanup $token
        if {![info exists meta(Location)]} {
           return $url
        }
        set url $meta(Location)
        unset meta
    }
    return $url
}

###
# topic: fced7bc395596569ac225a719c686dcc
###
proc ::http::wget {url destfile {verbose 1}} {
    set tmpchan [open $destfile w]
    fconfigure $tmpchan -translation binary
    if { $verbose } {
        puts [list  GETTING [file tail $destfile] from $url]
    }
    set real_url [_followRedirects $url]
    set token [geturl $real_url -channel $tmpchan -binary yes]
    if {[ncode $token] != "200"} {
      error "DOWNLOAD FAILED"
    }
    cleanup $token
    close $tmpchan
}


###
# END: httpwget/wget.tcl
###
###
# START: setup.tcl
###
###
# Practcl
# An object oriented templating system for stamping out Tcl API calls to C
###

package require TclOO
###
# Seek out Tcllib if it's available
###
set tcllib_path {}
foreach path {.. ../.. ../../..} {
  foreach path [glob -nocomplain [file join [file normalize $path] tcllib* modules]] {
    set tclib_path $path
    lappend ::auto_path $path
    break
  }
  if {$tcllib_path ne {}} break
}
namespace eval ::practcl {}
namespace eval ::practcl::OBJECT {}

###
# END: setup.tcl
###
###
# START: buildutil.tcl
###
###
# Build utility functions
###

###
# A command to do nothing. A handy way of
# negating an instruction without
# having to comment it completely out.
# It's also a handy attachment point for
# an object to be named later
###
if {[info command ::noop] eq {}} {
  proc ::noop args {}
}

proc ::practcl::debug args {
  #puts $args
  ::practcl::cputs ::DEBUG_INFO $args
}

###
# Drop in a static copy of Tcl
###
proc ::practcl::doexec args {
  puts [list {*}$args]
  exec {*}$args >&@ stdout
}

proc ::practcl::doexec_in {path args} {
  set PWD [pwd]
  cd $path
  puts [list {*}$args]
  exec {*}$args >&@ stdout
  cd $PWD
}

proc ::practcl::dotclexec args {
  puts [list [info nameofexecutable] {*}$args]
  exec [info nameofexecutable] {*}$args >&@ stdout
}

proc ::practcl::domake {path args} {
  set PWD [pwd]
  cd $path
  puts [list *** $path ***]
  puts [list make {*}$args]
  exec make {*}$args >&@ stdout
  cd $PWD
}

proc ::practcl::domake.tcl {path args} {
  set PWD [pwd]
  cd $path
  puts [list *** $path ***]
  puts [list make.tcl {*}$args]
  exec [info nameofexecutable] make.tcl {*}$args >&@ stdout
  cd $PWD
}

proc ::practcl::fossil {path args} {
  set PWD [pwd]
  cd $path
  puts [list {*}$args]
  exec fossil {*}$args >&@ stdout
  cd $PWD
}


proc ::practcl::fossil_status {dir} {
  if {[info exists ::fosdat($dir)]} {
    return $::fosdat($dir)
  }
  set result {
tags experimental
version {}
  }
  set pwd [pwd]
  cd $dir
  set info [exec fossil status]
  cd $pwd
  foreach line [split $info \n] {
    if {[lindex $line 0] eq "checkout:"} {
      set hash [lindex $line end-3]
      set maxdate [lrange $line end-2 end-1]
      dict set result hash $hash
      dict set result maxdate $maxdate
      regsub -all {[^0-9]} $maxdate {} isodate
      dict set result isodate $isodate
    }
    if {[lindex $line 0] eq "tags:"} {
      set tags [lrange $line 1 end]
      dict set result tags $tags
      break
    }
  }
  set ::fosdat($dir) $result
  return $result
}

proc ::practcl::os {} {
  return [${::practcl::MAIN} define get TEACUP_OS]
}

if {[::package vcompare $::tcl_version 8.6] < 0} {
  # Approximate ::zipfile::mkzip with exec calls
  proc ::practcl::mkzip {exename barekit vfspath} {
    set path [file dirname [file normalize $exename]]
    set zipfile [file join $path [file rootname $exename].zip]
    file copy -force $barekit $exename
    set pwd [pwd]
    cd $vfspath
    exec zip -r $zipfile .
    cd $pwd
    set fout [open $exename a]
    set fin [open $zipfile r]
    chan configure $fout -translation binary
    chan configure $fin -translation binary
    chan copy $fin $fout
    chan close $fin
    chan close $fout
    exec zip -A $exename
  }
  proc ::practcl::sort_dict list {
    set result {}
    foreach key [lsort -dictionary [dict keys $list]] {
      dict set result $key [dict get $list $key]
    }
    return $result
  }
} else {
  proc ::practcl::mkzip {exename barekit vfspath} {
    ::practcl::tcllib_require zipfile::mkzip
    ::zipfile::mkzip::mkzip $exename -runtime $barekit -directory $vfspath
  }
  proc ::practcl::sort_dict list {
    return [::lsort -stride 2 -dictionary $list]
  }
}

proc ::practcl::local_os {} {
  # If we have already run this command, return
  # a cached copy of the data
  if {[info exists ::practcl::LOCAL_INFO]} {
    return $::practcl::LOCAL_INFO
  }
  set result [array get ::practcl::CONFIG]
  dict set result TEACUP_PROFILE unknown
  dict set result TEACUP_OS unknown
  dict set result EXEEXT {}
  set windows 0
  if {$::tcl_platform(platform) eq "windows"} {
    set windows 1
  }
  if {$windows} {
    set system "windows"
    set arch ix86
    dict set result TEACUP_PROFILE win32-ix86
    dict set result TEACUP_OS windows
    dict set result EXEEXT .exe
  } else {
    set system [exec uname -s]-[exec uname -r]
    set arch unknown
    dict set result TEACUP_OS generic
  }
  dict set result TEA_PLATFORM $system
  dict set result TEA_SYSTEM $system
  if {[info exists ::SANDBOX]} {
    dict set result sandbox $::SANDBOX
  }
  switch -glob $system {
    Linux* {
      dict set result TEACUP_OS linux
      set arch [exec uname -m]
      dict set result TEACUP_PROFILE "linux-glibc2.3-$arch"
    }
    GNU* {
      set arch [exec uname -m]
      dict set result TEACUP_OS "gnu"
    }
    NetBSD-Debian {
      set arch [exec uname -m]
      dict set result TEACUP_OS "netbsd-debian"
    }
    OpenBSD-* {
      set arch [exec arch -s]
      dict set result TEACUP_OS "openbsd"
    }
    Darwin* {
      set arch [exec uname -m]
      dict set result TEACUP_OS "macosx"
      if {$arch eq "x86_64"} {
        dict set result TEACUP_PROFILE "macosx10.5-i386-x86_84"
      } else {
        dict set result TEACUP_PROFILE "macosx-universal"
      }
    }
    OpenBSD* {
      set arch [exec arch -s]
      dict set result TEACUP_OS "openbsd"
    }
  }
  if {$arch eq "unknown"} {
    catch {set arch [exec uname -m]}
  }
  switch -glob $arch {
    i*86 {
      set arch "ix86"
    }
    amd64 {
      set arch "x86_64"
    }
  }
  dict set result TEACUP_ARCH $arch
  if {[dict get $result TEACUP_PROFILE] eq "unknown"} {
    dict set result TEACUP_PROFILE [dict get $result TEACUP_OS]-$arch
  }
  set OS [dict get $result TEACUP_OS]
  dict set result os $OS

  # Look for a local preference file
  set pathlist {}
  set userhome [file normalize ~/tcl]
  set local_install [file join $userhome lib]
  switch $OS {
    windows {
      set userhome [file join [file normalize $::env(LOCALAPPDATA)] Tcl]
      if {[file exists c:/Tcl/Teapot]} {
        dict set result teapot c:/Tcl/Teapot
      }
    }
    macosx {
      set userhome [file join [file normalize {~/Library/Application Support/}] Tcl]
      if {[file exists {~/Library/Application Support/ActiveState/Teapot/repository/}]} {
        dict set result teapot [file normalize {~/Library/Application Support/ActiveState/Teapot/repository/}]
      }
      dict set result local_install [file normalize ~/Library/Tcl]
      if {![dict exists $result sandbox]} {
        dict set result sandbox       [file normalize ~/Library/Tcl/sandbox]
      }
    }
    default {
    }
  }
  dict set result userhome $userhome
  # Load user preferences
  if {[file exists [file join $userhome practcl.rc]]} {
    set dat [::practcl::read_rc_file [file join $userhome practcl.rc]]
    foreach {f v} $dat {
      dict set result $f $v
    }
  }
  if {![dict exists $result prefix]} {
    dict set result prefix   $userhome
  }

  # Create a default path for the teapot
  if {![dict exists $result teapot]} {
    dict set result teapot [file join $userhome teapot]
  }
  # Create a default path for the local sandbox
  if {![dict exists $result sandbox]} {
    dict set result sandbox [file join $userhome sandbox]
  }
  # Create a default path for download folder
  if {![dict exists $result download]} {
    dict set result download [file join $userhome download]
  }
  # Path to install local packages
  if {![dict exists $result local_install]} {
    dict set result local_install [file join $userhome lib]
  }
  if {![dict exists result fossil_mirror] && [::info exists ::env(FOSSIL_MIRROR)]} {
    dict set result fossil_mirror $::env(FOSSIL_MIRROR)
  }

  set ::practcl::LOCAL_INFO $result
  return $result
}


###
# Detect local platform
###
proc ::practcl::config.tcl {path} {
   return [read_configuration $path]
}

proc ::practcl::read_configuration {path} {
  dict set result buildpath $path
  set result [local_os]
  set OS [dict get $result TEACUP_OS]
  set windows 0
  dict set result USEMSVC 0
  if {[file exists [file join $path config.tcl]]} {
    # We have a definitive configuration file. Read its content
    # and take it as gospel
    set cresult [read_rc_file [file join $path config.tcl]]
    set cresult [::practcl::de_shell $cresult]
    if {[dict exists $cresult srcdir] && ![dict exists $cresult sandbox]} {
      dict set cresult sandbox  [file dirname [dict get $cresult srcdir]]
    }
    set result [dict merge $result [::practcl::de_shell $cresult]]
  }
  if {[file exists [file join $path config.site]]} {
    # No config.tcl file is present but we do seed
    dict set result USEMSVC 0
    foreach {f v} [::practcl::de_shell [::practcl::read_sh_file [file join $path config.site]]] {
      dict set result $f $v
      dict set result XCOMPILE_${f} $v
    }
    dict set result CONFIG_SITE [file join $path config.site]
    if {[dict exist $result XCOMPILE_CC] && [regexp mingw [dict get $result XCOMPILE_CC]]} {
      set windows 1
    }
  } elseif {[info exists ::env(VisualStudioVersion)]} {
    set windows 1
    dict set result USEMSVC 1
  }
  if {$windows && [dict get $result TEACUP_OS] ne "windows"} {
    if {![dict exists exists $result TEACUP_ARCH]} {
      dict set result TEACUP_ARCH ix86
    }
    dict set result TEACUP_PROFILE win32-[dict get $result TEACUP_ARCH]
    dict set result TEACUP_OS windows
    dict set result EXEEXT .exe
  }
  return $result
}


###
# Convert an MSYS path to a windows native path
###
if {$::tcl_platform(platform) eq "windows"} {
proc ::practcl::msys_to_tclpath msyspath {
  return [exec sh -c "cd $msyspath ; pwd -W"]
}
proc ::practcl::tcl_to_myspath tclpath {
  set path [file normalize $tclpath]
  return "/[string index $path 0][string range $path 2 end]"
  #return [exec sh -c "cd $tclpath ; pwd"]
}
} else {
proc ::practcl::msys_to_tclpath msyspath {
  return [file normalize $msyspath]
}
proc ::practcl::tcl_to_myspath msyspath {
  return [file normalize $msyspath]
}
}


# Try to load  a package, and failing that
# retrieve tcllib
proc ::practcl::tcllib_require {pkg args} {
  # Try to load the package from the local environment
  if {[catch [list ::package require $pkg {*}$args] err]==0} {
    return $err
  }
  ::practcl::LOCAL tool tcllib env-load
  uplevel #0 [list ::package require $pkg {*}$args]
}

namespace eval ::practcl::platform {}

proc ::practcl::platform::tcl_core_options {os} {
  ###
  # Download our required packages
  ###
  set tcl_config_opts {}
  # Auto-guess options for the local operating system
  switch $os {
    windows {
      #lappend tcl_config_opts --disable-stubs
    }
    linux {
    }
    macosx {
      lappend tcl_config_opts --enable-corefoundation=yes  --enable-framework=no
    }
  }
  lappend tcl_config_opts --with-tzdata
  return $tcl_config_opts
}

proc ::practcl::platform::tk_core_options {os} {
  ###
  # Download our required packages
  ###
  set tk_config_opts {}

  # Auto-guess options for the local operating system
  switch $os {
    windows {
    }
    linux {
      lappend tk_config_opts --enable-xft=no --enable-xss=no
    }
    macosx {
      lappend tk_config_opts --enable-aqua=yes
    }
  }
  return $tk_config_opts
}

###
# Read a stylized key/value list stored in a file
###
proc ::practcl::read_rc_file {filename {localdat {}}} {
  set result $localdat
  set fin [open $filename r]
  set bufline {}
  set rawcount 0
  set linecount 0
  while {[gets $fin thisline]>=0} {
    incr rawcount
    append bufline \n $thisline
    if {![info complete $bufline]} continue
    set line [string trimleft $bufline]
    set bufline {}
    if {[string index [string trimleft $line] 0] eq "#"} continue
    append result \n $line
    #incr linecount
    #set key [lindex $line 0]
    #set value [lindex $line 1]
    #dict set result $key $value
  }
  close $fin
  return $result
}

###
# topic: e71f3f61c348d56292011eec83e95f0aacc1c618
# description: Converts a XXX.sh file into a series of Tcl variables
###
proc ::practcl::read_sh_subst {line info} {
  regsub -all {\x28} $line \x7B line
  regsub -all {\x29} $line \x7D line

  #set line [string map $key [string trim $line]]
  foreach {field value} $info {
    catch {set $field $value}
  }
  if [catch {subst $line} result] {
    return {}
  }
  set result [string trim $result]
  return [string trim $result ']
}

###
# topic: 03567140cca33c814664c7439570f669b9ab88e6
###
proc ::practcl::read_sh_file {filename {localdat {}}} {
  set fin [open $filename r]
  set result {}
  if {$localdat eq {}} {
    set top 1
    set local [array get ::env]
    dict set local EXE {}
  } else {
    set top 0
    set local $localdat
  }
  while {[gets $fin line] >= 0} {
    set line [string trim $line]
    if {[string index $line 0] eq "#"} continue
    if {$line eq {}} continue
    catch {
    if {[string range $line 0 6] eq "export "} {
      set eq [string first "=" $line]
      set field [string trim [string range $line 6 [expr {$eq - 1}]]]
      set value [read_sh_subst [string range $line [expr {$eq+1}] end] $local]
      dict set result $field [read_sh_subst $value $local]
      dict set local $field $value
    } elseif {[string range $line 0 7] eq "include "} {
      set subfile [read_sh_subst [string range $line 7 end] $local]
      foreach {field value} [read_sh_file $subfile $local] {
        dict set result $field $value
      }
    } else {
      set eq [string first "=" $line]
      if {$eq > 0} {
        set field [read_sh_subst [string range $line 0 [expr {$eq - 1}]] $local]
        set value [string trim [string range $line [expr {$eq+1}] end] ']
        #set value [read_sh_subst [string range $line [expr {$eq+1}] end] $local]
        dict set local $field $value
        dict set result $field $value
      }
    }
    } err opts
    if {[dict get $opts -code] != 0} {
      #puts $opts
      puts "Error reading line:\n$line\nerr: $err\n***"
      return $err {*}$opts
    }
  }
  return $result
}

###
# A simpler form of read_sh_file tailored
# to pulling data from (tcl|tk)Config.sh
###
proc ::practcl::read_Config.sh filename {
  set fin [open $filename r]
  set result {}
  set linecount 0
  while {[gets $fin line] >= 0} {
    set line [string trim $line]
    if {[string index $line 0] eq "#"} continue
    if {$line eq {}} continue
    catch {
      set eq [string first "=" $line]
      if {$eq > 0} {
        set field [string range $line 0 [expr {$eq - 1}]]
        set value [string trim [string range $line [expr {$eq+1}] end] ']
        #set value [read_sh_subst [string range $line [expr {$eq+1}] end] $local]
        dict set result $field $value
        incr $linecount
      }
    } err opts
    if {[dict get $opts -code] != 0} {
      #puts $opts
      puts "Error reading line:\n$line\nerr: $err\n***"
      return $err {*}$opts
    }
  }
  return $result
}

###
# A simpler form of read_sh_file tailored
# to pulling data from a Makefile
###
proc ::practcl::read_Makefile filename {
  set fin [open $filename r]
  set result {}
  while {[gets $fin line] >= 0} {
    set line [string trim $line]
    if {[string index $line 0] eq "#"} continue
    if {$line eq {}} continue
    catch {
      set eq [string first "=" $line]
      if {$eq > 0} {
        set field [string trim [string range $line 0 [expr {$eq - 1}]]]
        set value [string trim [string trim [string range $line [expr {$eq+1}] end] ']]
        switch $field {
          PKG_LIB_FILE {
            dict set result libfile $value
          }
          srcdir {
            if {$value eq "."} {
              dict set result srcdir [file dirname $filename]
            } else {
              dict set result srcdir $value
            }
          }
          PACKAGE_NAME {
            dict set result name $value
          }
          PACKAGE_VERSION {
            dict set result version $value
          }
          LIBS {
            dict set result PRACTCL_LIBS $value
          }
          PKG_LIB_FILE {
            dict set result libfile $value
          }
        }
      }
    } err opts
    if {[dict get $opts -code] != 0} {
      #puts $opts
      puts "Error reading line:\n$line\nerr: $err\n***"
      return $err {*}$opts
    }
    # the Compile field is about where most TEA files start getting silly
    if {$field eq "compile"} {
      break
    }
  }
  return $result
}

## Append arguments to a buffer
# The command works like puts in that each call will also insert
# a line feed. Unlike puts, blank links in the interstitial are
# suppressed
proc ::practcl::cputs {varname args} {
  upvar 1 $varname buffer
  if {[llength $args]==1 && [string length [string trim [lindex $args 0]]] == 0} {

  }
  if {[info exist buffer]} {
    if {[string index $buffer end] ne "\n"} {
      append buffer \n
    }
  } else {
    set buffer \n
  }
  # Trim leading \n's
  append buffer [string trimleft [lindex $args 0] \n] {*}[lrange $args 1 end]
}

proc ::practcl::tcl_to_c {body} {
  set result {}
  foreach rawline [split $body \n] {
    set line [string map [list \" \\\" \\ \\\\] $rawline]
    cputs result "\n        \"$line\\n\" \\"
  }
  return [string trimright $result \\]
}


proc ::practcl::_tagblock {text {style tcl} {note {}}} {
  if {[string length [string trim $text]]==0} {
    return {}
  }
  set output {}
  switch $style {
    tcl {
      ::practcl::cputs output "# BEGIN $note"
    }
    c {
      ::practcl::cputs output "/* BEGIN $note */"
    }
    default {
      ::practcl::cputs output "# BEGIN $note"
    }
  }
  ::practcl::cputs output $text
  switch $style {
    tcl {
      ::practcl::cputs output "# END $note"
    }
    c {
      ::practcl::cputs output "/* END $note */"
    }
    default {
      ::practcl::cputs output "# END $note"
    }
  }
  return $output
}

proc ::practcl::de_shell {data} {
  set values {}
  foreach flag {DEFS TCL_DEFS TK_DEFS} {
    if {[dict exists $data $flag]} {
      #set value {}
      #foreach item [dict get $data $flag] {
      #  append value " " [string map {{ } {\ }} $item]
      #}
      dict set values $flag [dict get $data $flag]
    }
  }
  set map {}
  lappend map {${PKG_OBJECTS}} %LIBRARY_OBJECTS%
  lappend map {$(PKG_OBJECTS)} %LIBRARY_OBJECTS%
  lappend map {${PKG_STUB_OBJECTS}} %LIBRARY_STUB_OBJECTS%
  lappend map {$(PKG_STUB_OBJECTS)} %LIBRARY_STUB_OBJECTS%

  if {[dict exists $data name]} {
    lappend map %LIBRARY_NAME% [dict get $data name]
    lappend map %LIBRARY_VERSION% [dict get $data version]
    lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} [dict get $data version]]
    if {[dict exists $data libprefix]} {
      lappend map %LIBRARY_PREFIX% [dict get $data libprefix]
    } else {
      lappend map %LIBRARY_PREFIX% [dict get $data prefix]
    }
  }
  foreach flag [dict keys $data] {
    if {$flag in {TCL_DEFS TK_DEFS DEFS}} continue
    set value [string trim [dict get $data $flag] \"]
    dict set map "\$\{${flag}\}" $value
    dict set map "\$\(${flag}\)" $value
    #dict set map "\$${flag}" $value
    dict set map "%${flag}%" $value
    dict set values $flag [dict get $data $flag]
    #dict set map "\$\{${flag}\}" $proj($flag)
  }
  set changed 1
  while {$changed} {
    set changed 0
    foreach {field value} $values {
      if {$field in {TCL_DEFS TK_DEFS DEFS}} continue
      dict with values {}
      set newval [string map $map $value]
      if {$newval eq $value} continue
      set changed 1
      dict set values $field $newval
    }
  }
  return $values
}

###
# END: buildutil.tcl
###
###
# START: fileutil.tcl
###
###
# Bits stolen from fileutil
###
proc ::practcl::cat fname {
    if {![file exists $fname]} {
       return
    }
    set fin [open $fname r]
    set data [read $fin]
    close $fin
    return $data
}

proc ::practcl::grep {pattern {files {}}} {
    set result [list]
    if {[llength $files] == 0} {
	      # read from stdin
    	  set lnum 0
	      while {[gets stdin line] >= 0} {
	          incr lnum
    	      if {[regexp -- $pattern $line]} {
		            lappend result "${lnum}:${line}"
	          }
    	  }
    } else {
	      foreach filename $files {
            set file [open $filename r]
            set lnum 0
            while {[gets $file line] >= 0} {
                incr lnum
                if {[regexp -- $pattern $line]} {
                    lappend result "${filename}:${lnum}:${line}"
                }
            }
            close $file
    	  }
    }
    return $result
}

proc ::practcl::file_lexnormalize {sp} {
    set spx [file split $sp]

    # Resolution of embedded relative modifiers (., and ..).

    if {
	([lsearch -exact $spx . ] < 0) &&
	([lsearch -exact $spx ..] < 0)
    } {
	# Quick path out if there are no relative modifiers
	return $sp
    }

    set absolute [expr {![string equal [file pathtype $sp] relative]}]
    # A volumerelative path counts as absolute for our purposes.

    set sp $spx
    set np {}
    set noskip 1

    while {[llength $sp]} {
	set ele    [lindex $sp 0]
	set sp     [lrange $sp 1 end]
	set islast [expr {[llength $sp] == 0}]

	if {[string equal $ele ".."]} {
	    if {
		($absolute  && ([llength $np] >  1)) ||
		(!$absolute && ([llength $np] >= 1))
	    } {
		# .. : Remove the previous element added to the
		# new path, if there actually is enough to remove.
		set np [lrange $np 0 end-1]
	    }
	} elseif {[string equal $ele "."]} {
	    # Ignore .'s, they stay at the current location
	    continue
	} else {
	    # A regular element.
	    lappend np $ele
	}
    }
    if {[llength $np] > 0} {
	return [eval [linsert $np 0 file join]]
	# 8.5: return [file join {*}$np]
    }
    return {}
}

proc ::practcl::file_relative {base dst} {
    # Ensure that the link to directory 'dst' is properly done relative to
    # the directory 'base'.

    if {![string equal [file pathtype $base] [file pathtype $dst]]} {
	return -code error "Unable to compute relation for paths of different pathtypes: [file pathtype $base] vs. [file pathtype $dst], ($base vs. $dst)"
    }

    set base [file_lexnormalize [file join [pwd] $base]]
    set dst  [file_lexnormalize [file join [pwd] $dst]]

    set save $dst
    set base [file split $base]
    set dst  [file split $dst]

    while {[string equal [lindex $dst 0] [lindex $base 0]]} {
	set dst  [lrange $dst  1 end]
	set base [lrange $base 1 end]
	if {![llength $dst]} {break}
    }

    set dstlen  [llength $dst]
    set baselen [llength $base]

    if {($dstlen == 0) && ($baselen == 0)} {
	# Cases:
	# (a) base == dst

	set dst .
    } else {
	# Cases:
	# (b) base is: base/sub = sub
	#     dst  is: base     = {}

	# (c) base is: base     = {}
	#     dst  is: base/sub = sub

	while {$baselen > 0} {
	    set dst [linsert $dst 0 ..]
	    incr baselen -1
	}
	# 8.5: set dst [file join {*}$dst]
	set dst [eval [linsert $dst 0 file join]]
    }

    return $dst
}

proc ::practcl::log {fname comment} {
  set fname [file normalize $fname]
  if {[info exists ::practcl::logchan($fname)]} {
    set fout $::practcl::logchan($fname)
    after cancel $::practcl::logevent($fname)
  } else {
    set fout [open $fname a]
  }
  puts $fout $comment
  # Defer close until idle
  set ::practcl::logevent($fname) [after idle "close $fout ; unset ::practcl::logchan($fname)"]
}

###
# END: fileutil.tcl
###
###
# START: installutil.tcl
###
###
# Installer tools
###
proc ::practcl::_isdirectory name {
  return [file isdirectory $name]
}
###
# Return true if the pkgindex file contains
# any statement other than "package ifneeded"
# and/or if any package ifneeded loads a DLL
###
proc ::practcl::_pkgindex_directory {path} {
  set buffer {}
  set pkgidxfile [file join $path pkgIndex.tcl]
  if {![file exists $pkgidxfile]} {
    # No pkgIndex file, read the source
    foreach file [glob -nocomplain $path/*.tm] {
      set file [file normalize $file]
      set fname [file rootname [file tail $file]]
      ###
      # We used to be able to ... Assume the package is correct in the filename
      # No hunt for a "package provides"
      ###
      set package [lindex [split $fname -] 0]
      set version [lindex [split $fname -] 1]
      ###
      # Read the file, and override assumptions as needed
      ###
      set fin [open $file r]
      set dat [read $fin]
      close $fin
      # Look for a teapot style Package statement
      foreach line [split $dat \n] {
        set line [string trim $line]
        if { [string range $line 0 9] != "# Package " } continue
        set package [lindex $line 2]
        set version [lindex $line 3]
        break
      }
      # Look for a package provide statement
      foreach line [split $dat \n] {
        set line [string trim $line]
        if { [string range $line 0 14] != "package provide" } continue
        set package [lindex $line 2]
        set version [lindex $line 3]
        break
      }
      if {[string trim $version] ne {}} {
        append buffer "package ifneeded $package $version \[list source \[file join \$dir [file tail $file]\]\]" \n
      }
    }
    foreach file [glob -nocomplain $path/*.tcl] {
      if { [file tail $file] == "version_info.tcl" } continue
      set fin [open $file r]
      set dat [read $fin]
      close $fin
      if {![regexp "package provide" $dat]} continue
      set fname [file rootname [file tail $file]]
      # Look for a package provide statement
      foreach line [split $dat \n] {
        set line [string trim $line]
        if { [string range $line 0 14] != "package provide" } continue
        set package [lindex $line 2]
        set version [lindex $line 3]
        if {[string index $package 0] in "\$ \[ @"} continue
        if {[string index $version 0] in "\$ \[ @"} continue
        append buffer "package ifneeded $package $version \[list source \[file join \$dir [file tail $file]\]\]" \n
        break
      }
    }
    return $buffer
  }
  set fin [open $pkgidxfile r]
  set dat [read $fin]
  close $fin
  set trace 0
  #if {[file tail $path] eq "tool"} {
  #  set trace 1
  #}
  set thisline {}
  foreach line [split $dat \n] {
    append thisline $line \n
    if {![info complete $thisline]} continue
    set line [string trim $line]
    if {[string length $line]==0} {
      set thisline {} ; continue
    }
    if {[string index $line 0] eq "#"} {
      set thisline {} ; continue
    }
    if {[regexp "if.*catch.*package.*Tcl.*return" $thisline]} {
      if {$trace} {puts "[file dirname $pkgidxfile] Ignoring $thisline"}
      set thisline {} ; continue
    }
    if {[regexp "if.*package.*vsatisfies.*package.*provide.*return" $thisline]} {
      if {$trace} { puts "[file dirname $pkgidxfile] Ignoring $thisline" }
      set thisline {} ; continue
    }
    if {![regexp "package.*ifneeded" $thisline]} {
      # This package index contains arbitrary code
      # source instead of trying to add it to the master
      # package index
      if {$trace} { puts "[file dirname $pkgidxfile] Arbitrary code $thisline" }
      return {source [file join $dir pkgIndex.tcl]}
    }
    append buffer $thisline \n
    set thisline {}
  }
  if {$trace} {puts [list [file dirname $pkgidxfile] $buffer]}
  return $buffer
}


proc ::practcl::_pkgindex_path_subdir {path} {
  set result {}
  foreach subpath [glob -nocomplain [file join $path *]] {
    if {[file isdirectory $subpath]} {
      lappend result $subpath {*}[_pkgindex_path_subdir $subpath]
    }
  }
  return $result
}
###
# Index all paths given as though they will end up in the same
# virtual file system
###
proc ::practcl::pkgindex_path {args} {
  set stack {}
  set buffer {
lappend ::PATHSTACK $dir
  }
  foreach base $args {
    set base [file normalize $base]
    set paths {}
    foreach dir [glob -nocomplain [file join $base *]] {
      if {[file tail $dir] eq "teapot"} continue
      lappend paths $dir {*}[::practcl::_pkgindex_path_subdir $dir]
    }
    set i    [string length  $base]
    # Build a list of all of the paths
    if {[llength $paths]} {
      foreach path $paths {
        if {$path eq $base} continue
        set path_indexed($path) 0
      }
    } else {
      puts [list WARNING: NO PATHS FOUND IN $base]
    }
    set path_indexed($base) 1
    set path_indexed([file join $base boot tcl]) 1
    foreach path $paths {
      if {$path_indexed($path)} continue
      set thisdir [file_relative $base $path]
      set idxbuf [::practcl::_pkgindex_directory $path]
      if {[string length $idxbuf]} {
        incr path_indexed($path)
        append buffer "set dir \[set PKGDIR \[file join \[lindex \$::PATHSTACK end\] $thisdir\]\]" \n
        append buffer [string map {$dir $PKGDIR} [string trimright $idxbuf]] \n
      }
    }
  }
  append buffer {
set dir [lindex $::PATHSTACK end]
set ::PATHSTACK [lrange $::PATHSTACK 0 end-1]
}
  return $buffer
}

proc ::practcl::installDir {d1 d2} {
  puts [format {%*sCreating %s} [expr {4 * [info level]}] {} [file tail $d2]]
  file delete -force -- $d2
  file mkdir $d2

  foreach ftail [glob -directory $d1 -nocomplain -tails *] {
    set f [file join $d1 $ftail]
    if {[file isdirectory $f] && [string compare CVS $ftail]} {
      installDir $f [file join $d2 $ftail]
    } elseif {[file isfile $f]} {
	    file copy -force $f [file join $d2 $ftail]
	    if {$::tcl_platform(platform) eq {unix}} {
        file attributes [file join $d2 $ftail] -permissions 0644
	    } else {
        file attributes [file join $d2 $ftail] -readonly 1
	    }
    }
  }

  if {$::tcl_platform(platform) eq {unix}} {
    file attributes $d2 -permissions 0755
  } else {
    file attributes $d2 -readonly 1
  }
}

proc ::practcl::copyDir {d1 d2 {toplevel 1}} {
  #if {$toplevel} {
  #  puts [list ::practcl::copyDir $d1 -> $d2]
  #}
  #file delete -force -- $d2
  file mkdir $d2
  if {[file isfile $d1]} {
    file copy -force $d1 $d2
    set ftail [file tail $d1]
    if {$::tcl_platform(platform) eq {unix}} {
      file attributes [file join $d2 $ftail] -permissions 0644
    } else {
      file attributes [file join $d2 $ftail] -readonly 1
    }
  } else {
    foreach ftail [glob -directory $d1 -nocomplain -tails *] {
      set f [file join $d1 $ftail]
      if {[file isdirectory $f] && [string compare CVS $ftail]} {
        copyDir $f [file join $d2 $ftail] 0
      } elseif {[file isfile $f]} {
        file copy -force $f [file join $d2 $ftail]
        if {$::tcl_platform(platform) eq {unix}} {
          file attributes [file join $d2 $ftail] -permissions 0644
        } else {
          file attributes [file join $d2 $ftail] -readonly 1
        }
      }
    }
  }
}

###
# END: installutil.tcl
###
###
# START: makeutil.tcl
###
###
# Backward compatible Make facilities
# These were used early in development and are consdiered deprecated
###

proc ::practcl::trigger {args} {
  ::practcl::LOCAL make trigger {*}$args
  foreach {name obj} [::practcl::LOCAL make objects] {
    set ::make($name) [$obj do]
  }
}

proc ::practcl::depends {args} {
  ::practcl::LOCAL make depends {*}$args
}

proc ::practcl::target {name info {action {}}} {
  set obj [::practcl::LOCAL make task $name $info $action]
  set ::make($name) 0
  set filename [$obj define get filename]
  if {$filename ne {}} {
    set ::target($name) $filename
  }
}
###
# END: makeutil.tcl
###
###
# START: class metaclass.tcl
###
::oo::class create ::practcl::metaclass {
  superclass ::oo::object

  method _MorphPatterns {} {
    return {{@name@} {::practcl::@name@} {::practcl::*@name@} {::practcl::*@name@*}}
  }

  method define {submethod args} {
    my variable define
    switch $submethod {
      dump {
        return [array get define]
      }
      add {
        set field [lindex $args 0]
        if {![info exists define($field)]} {
          set define($field) {}
        }
        foreach arg [lrange $args 1 end] {
          if {$arg ni $define($field)} {
            lappend define($field) $arg
          }
        }
        return $define($field)
      }
      remove {
        set field [lindex $args 0]
        if {![info exists define($field)]} {
          return
        }
        set rlist [lrange $args 1 end]
        set olist $define($field)
        set nlist {}
        foreach arg $olist {
          if {$arg in $rlist} continue
          lappend nlist $arg
        }
        set define($field) $nlist
        return $nlist
      }
      exists {
        set field [lindex $args 0]
        return [info exists define($field)]
      }
      getnull -
      get -
      cget {
        set field [lindex $args 0]
        if {[info exists define($field)]} {
          return $define($field)
        }
        return [lindex $args 1]
      }
      set {
        if {[llength $args]==1} {
          set arglist [lindex $args 0]
        } else {
          set arglist $args
        }
        array set define $arglist
        if {[dict exists $arglist class]} {
          my select
        }
      }
      default {
        array $submethod define {*}$args
      }
    }
  }


  method meta {submethod args} {
    my variable meta
    if {![info exists meta]} {
      set meta {}
    }
    switch $submethod {
      dump {
        return $meta
      }
      add {
        set field [lindex $args 0]
        if {![dict exists $meta $field]} {
          dict set meta $field {}
        }
        foreach arg [lrange $args 1 end] {
          if {$arg ni [dict get $meta $field]} {
            dict lappend meta $field $arg
          }
        }
        return [dict get $meta $field]
      }
      remove {
        set field [lindex $args 0]
        if {![dict exists meta $field]} {
          return
        }
        set rlist [lrange $args 1 end]
        set olist [dict get $meta $field]
        set nlist {}
        foreach arg $olist {
          if {$arg in $rlist} continue
          lappend nlist $arg
        }
        dict set meta $field $nlist
        return $nlist
      }
      exists {
        return [dict exists $meta {*}$args]
      }
      getnull -
      get {
        if {[dict exists $meta {*}$args]} {
          return [dict get $meta {*}$args]
        }
        return {}
      }
      cget {
        set field [lindex $args 0]
        if {[dict exists $meta $field]} {
          return [dict get $meta $field]
        }
        return [lindex $args 1]
      }
      set {
        if {[llength $args]==1} {
          foreach {field value} $args {
            dict set meta [string trimright $field :]: $value
          }
        } else {
          set field [lindex $args end-1]
          set value [lindex $args end]
          dict set meta {*}[lrange $args 0 end-2] [string trimright $field :]: $value
        }
      }
      default {
        error "Valid: add cget dump exists get getnull remove set"
      }
    }
  }
  
  method graft args {
    my variable organs
    if {[llength $args] == 1} {
      error "Need two arguments"
    }
    set object {}
    foreach {stub object} $args {
      dict set organs $stub $object
      oo::objdefine [self] forward <${stub}> $object
      oo::objdefine [self] export <${stub}>
    }
    return $object
  }

  method initialize {} {}


  method link {command args} {
    my variable links
    switch $command {
      object {
        foreach obj $args {
          foreach linktype [$obj linktype] {
            my link add $linktype $obj
          }
        }
      }
      add {
        ###
        # Add a link to an object that was externally created
        ###
        if {[llength $args] ne 2} { error "Usage: link add LINKTYPE OBJECT"}
        lassign $args linktype object
        if {[info exists links($linktype)] && $object in $links($linktype)} {
          return
        }
        lappend links($linktype) $object
      }
      remove {
        set object [lindex $args 0]
        if {[llength $args]==1} {
          set ltype *
        } else {
          set ltype [lindex $args 1]
        }
        foreach {linktype elements} [array get links $ltype] {
          if {$object in $elements} {
            set nlist {}
            foreach e $elements {
              if { $object ne $e } { lappend nlist $e }
            }
            set links($linktype) $nlist
          }
        }
      }
      list {
        if {[llength $args]==0} {
          return [array get links]
        }
        if {[llength $args] != 1} { error "Usage: link list LINKTYPE"}
        set linktype [lindex $args 0]
        if {![info exists links($linktype)]} {
          return {}
        }
        return $links($linktype)
      }
      dump {
        return [array get links]
      }
    }
  }

  method morph classname {
    my variable define
    if {$classname ne {}} {
      set map [list @name@ $classname]
      foreach pattern [string map $map [my _MorphPatterns]] {
        set pattern [string trim $pattern]
        set matches [info commands $pattern]
        if {![llength $matches]} continue
        set class [lindex $matches 0]
        break
      }
      set mixinslot {}
      foreach {slot pattern} {
        distribution ::practcl::distribution*
        product      ::practcl::product*
        toolset      ::practcl::toolset*
      } {
        if {[string match $pattern $class]} {
           set mixinslot $slot
           break
        }
      }
      if {$mixinslot ne {}} {
        my mixin $mixinslot $class
      } elseif {[info command $class] ne {}} {
        if {[info object class [self]] ne $class} {
          ::oo::objdefine [self] class $class
          ::practcl::debug [self] morph $class
           my define set class $class
        }
      } else {
        error "[self] Could not detect class for $classname"
      }
    }
    if {[::info exists define(oodefine)]} {
      ::oo::objdefine [self] $define(oodefine)
      #unset define(oodefine)
    }
  }

  method mixin {slot classname} {
    my variable mixinslot
    set class {}
    set map [list @slot@ $slot @name@ $classname]
    foreach pattern [split [string map $map {
      @name@
      @slot@.@name@
      ::practcl::@name@
      ::practcl::@slot@.@name@
      ::practcl::@slot@*@name@
      ::practcl::*@name@*
    }] \n] {
      set pattern [string trim $pattern]
      set matches [info commands $pattern]
      if {![llength $matches]} continue
      set class [lindex $matches 0]
      break
    }
    ::practcl::debug [self] mixin $slot $class
    dict set mixinslot $slot $class
    set mixins {}
    foreach {s c} $mixinslot {
      if {$c eq {}} continue
      lappend mixins $c
    }
    oo::objdefine [self] mixin {*}$mixins
  }

  method organ {{stub all}} {
    my variable organs
    if {![info exists organs]} {
      return {}
    }
    if { $stub eq "all" } {
      return $organs
    }
    if {[dict exists $organs $stub]} {
      return [dict get $organs $stub]
    }
  }

  method script script {
    eval $script
  }

  method select {} {
    my variable define
    if {[info exists define(class)]} {
      my morph $define(class)
    } else {
      if {[::info exists define(oodefine)]} {
        ::oo::objdefine [self] $define(oodefine)
        #unset define(oodefine)
      }
    }
  }

  method source filename {
    source $filename
  }
}

###
# END: class metaclass.tcl
###
###
# START: class toolset baseclass.tcl
###
###
# Ancestor-less class intended to be a mixin
# which defines a family of build related behaviors
# that are modified when targetting either gcc or msvc
###
oo::class create ::practcl::toolset {
  ###
  # find or fake a key/value list describing this project
  ###
  method config.sh {} {
    return [my read_configuration]
  }
  
  method BuildDir {PWD} {
    set name [my define get name]
    set debug [my define get debug 0]
    if {[my <project> define get LOCAL 0]} {
      return [my define get builddir [file join $PWD local $name]]
    }
    if {$debug} {
      return [my define get builddir [file join $PWD debug $name]]
    } else {
      return [my define get builddir [file join $PWD pkg $name]]
    }
  }
  
  method MakeDir {srcdir} {
    return $srcdir
  }
  
  method read_configuration {} {
    my variable conf_result
    if {[info exists conf_result]} {
      return $conf_result
    }
    set result {}
    set name [my define get name]
    set PWD $::CWD
    set builddir [my define get builddir]
    my unpack
    set srcdir [my define get srcdir]
    if {![file exists $builddir]} {
      my Configure
    }
    set filename [file join $builddir config.tcl]
    # Project uses the practcl template. Use the leavings from autoconf
    if {[file exists $filename]} {
      set dat [::practcl::read_configuration $builddir]
      foreach {item value} [::practcl::sort_dict $dat] {
        dict set result $item $value
      }
      set conf_result $result
      return $result
    }
    set filename [file join $builddir ${name}Config.sh]
    if {[file exists $filename]} {
      set l [expr {[string length $name]+1}]
      foreach {field dat} [::practcl::read_Config.sh $filename] {
        set field [string tolower $field]
        if {[string match ${name}_* $field]} {
          set field [string range $field $l end]
        }
        switch $field {
          version {
            dict set result pkg_vers $dat
          }
          lib_file {
            set field libfile
          }
        }
        dict set result $field $dat
      }
      set conf_result $result
      return $result
    }
    ###
    # Oh man... we have to guess
    ###
    set filename [file join $builddir Makefile]
    if {![file exists $filename]} {
      error "Could not locate any configuration data in $srcdir"
    }
    foreach {field dat} [::practcl::read_Makefile $filename] {
      dict set result $field $dat
    }
    if {![dict exists $result PRACTCL_PKG_LIBS] && [dict exists $result LIBS]} {
      dict set result PRACTCL_PKG_LIBS [dict get $result LIBS]
    }
    set conf_result $result
    cd $PWD
    return $result
  }

  ## method DEFS
  # This method populates 4 variables:
  # name - The name of the package
  # version - The version of the package
  # defs - C flags passed to the compiler
  # includedir - A list of paths to feed to the compiler for finding headers
  #
  method build-cflags {PROJECT DEFS namevar versionvar defsvar} {
    upvar 1 $namevar name $versionvar version NAME NAME $defsvar defs
    set name [string tolower [${PROJECT} define get name [${PROJECT} define get pkg_name]]]
    set NAME [string toupper $name]
    set version [${PROJECT} define get version [${PROJECT} define get pkg_vers]]
    if {$version eq {}} {
      set version 0.1a
    }
    set defs $DEFS
    foreach flag {
      -DPACKAGE_NAME
      -DPACKAGE_VERSION
      -DPACKAGE_TARNAME
      -DPACKAGE_STRING
    } {
      if {[set i [string first $flag $defs]] >= 0} {
        set j [string first -D $flag [expr {$i+[string length $flag]}]]
        set predef [string range $defs 0 [expr {$i-1}]]
        set postdef [string range $defs $j end]
        set defs "$predef $postdef"
      }
    }
    append defs " -DPACKAGE_NAME=\"${name}\" -DPACKAGE_VERSION=\"${version}\""
    append defs " -DPACKAGE_TARNAME=\"${name}\" -DPACKAGE_STRING=\"${name}\x5c\x20${version}\""
    return $defs
  }

  method critcl args {
    if {![info exists critcl]} {
      ::practcl::LOCAL tool critcl env-load
      set critcl [file join [::practcl::LOCAL tool critcl define get srcdir] main.tcl
    }
    set srcdir [my SourceRoot]
    set PWD [pwd]
    cd $srcdir
    ::practcl::dotclexec $critcl {*}$args
    cd $PWD
  }
  
  method make-autodetect {} {}
}


oo::objdefine ::practcl::toolset {


  method select object {
    ###
    # Select the toolset to use for this project
    ###
    if {[$object define exists toolset]} {
      return [$object define get toolset]
    }
    set class [$object define get toolset]
    if {$class ne {}} {
      $object mixin toolset $class
    } else {
      if {[info exists ::env(VisualStudioVersion)]} {
        $object mixin toolset ::practcl::toolset.msvc
      } else {
        $object mixin toolset ::practcl::toolset.gcc
      }
    }
  }
}

###
# END: class toolset baseclass.tcl
###
###
# START: class toolset gcc.tcl
###

::oo::class create ::practcl::toolset.gcc {
  superclass ::practcl::toolset

  method Autoconf {} {
    ###
    # Re-run autoconf for this project
    # Not a good idea in practice... but in the right hands it can be useful
    ###
    set pwd [pwd]
    set srcdir [file normalize [my define get srcdir]]
    cd $srcdir
    foreach template {configure.ac configure.in} {
      set input [file join $srcdir $template]
      if {[file exists $input]} {
        puts "autoconf -f $input > [file join $srcdir configure]"
        exec autoconf -f $input > [file join $srcdir configure]
      }
    }
    cd $pwd
  }
  
  method BuildDir {PWD} {
    set name [my define get name]
    set debug [my define get debug 0]
    if {[my <project> define get LOCAL 0]} {
      return [my define get builddir [file join $PWD local $name]]
    }
    if {$debug} {
      return [my define get builddir [file join $PWD debug $name]]
    } else {
      return [my define get builddir [file join $PWD pkg $name]]
    }
  }
  
  method ConfigureOpts {} {
    set opts {}
    set builddir [my define get builddir]
 
    if {[my define get broken_destroot 0]} {
      set PREFIX [my <project> define get prefix_broken_destdir]
    } else {
      set PREFIX [my <project> define get prefix]
    }
    switch [my define get name] {
      tcl {
        set opts [::practcl::platform::tcl_core_options [my <project> define get TEACUP_OS]]
      }
      tk {
        set opts [::practcl::platform::tk_core_options  [my <project> define get TEACUP_OS]]
      }
    }
    if {[my <project> define get CONFIG_SITE] != {}} {
      lappend opts --host=[my <project> define get HOST]
    }
    set inside_msys [string is true -strict [my <project> define get MSYS_ENV 0]]
    lappend opts --with-tclsh=[info nameofexecutable]
    if {![my <project> define get LOCAL 0]} {
      set obj [my <project> tclcore]
      if {$obj ne {}} {
        if {$inside_msys} {
          lappend opts --with-tcl=[::practcl::file_relative [file normalize $builddir] [$obj define get builddir]]
        } else {
          lappend opts --with-tcl=[file normalize [$obj define get builddir]]
        }
      }
      if {[my define get tk 0]} {
        set obj [my <project> tkcore]
        if {$obj ne {}} {
          if {$inside_msys} {
            lappend opts --with-tk=[::practcl::file_relative [file normalize $builddir] [$obj define get builddir]]
          } else {
            lappend opts --with-tk=[file normalize [$obj define get builddir]]
          }
        }
      }
    } else {
      lappend opts --with-tcl=[file join $PREFIX lib]
      if {[my define get tk 0]} {
        lappend opts --with-tk=[file join $PREFIX lib]
      }
    }

    lappend opts {*}[my define get config_opts]
    if {![regexp -- "--prefix" $opts]} {
      lappend opts --prefix=$PREFIX --exec-prefix=$PREFIX
    }
    if {[my define get debug 0]} {
      lappend opts --enable-symbols=true
    }
    #--exec_prefix=$PREFIX
    #if {$::tcl_platform(platform) eq "windows"} {
    #  lappend opts --disable-64bit
    #}
    if {[my define get static 1]} {
      lappend opts --disable-shared
      #--disable-stubs
      #
    } else {
      lappend opts --enable-shared
    }
    return $opts
  }
  
  # Detect what directory contains the Makefile template
  method MakeDir {srcdir} {
    set localsrcdir $srcdir
    if {[file exists [file join $srcdir generic]]} {
      my define add include_dir [file join $srcdir generic]
    }
    set os [my <project> define get TEACUP_OS]
    switch $os {
      windows {
        if {[file exists [file join $srcdir win]]} {
          my define add include_dir [file join $srcdir win]
        }
        if {[file exists [file join $srcdir win Makefile.in]]} {
          set localsrcdir [file join $srcdir win]
        }
      }
      default {
        if {[file exists [file join $srcdir $os]]} {
          my define add include_dir [file join $srcdir $os]
        }
        if {[file exists [file join $srcdir unix]]} {
          my define add include_dir [file join $srcdir unix]
        }
        if {[file exists [file join $srcdir $os Makefile.in]]} {
          set localsrcdir [file join $srcdir $os]
        } elseif {[file exists [file join $srcdir unix Makefile.in]]} {
          set localsrcdir [file join $srcdir unix]
        }
      }
    }
    return $localsrcdir
  }
  
  method make-autodetect {} {
    set srcdir [my define get srcdir]
    set localsrcdir [my define get localsrcdir]
    if {$srcdir eq $localsrcdir} {
      if {![file exists [file join $srcdir tclconfig install-sh]]} {
        # ensure we have tclconfig with all of the trimmings
        set teapath {}
        if {[file exists [file join $srcdir .. tclconfig install-sh]]} {
          set teapath [file join $srcdir .. tclconfig]
        } else {
          set tclConfigObj [::practcl::LOCAL tool tclconfig]
          $tclConfigObj load
          set teapath [$tclConfigObj define get srcdir]
        }
        set teapath [file normalize $teapath]
        #file mkdir [file join $srcdir tclconfig]
        if {[catch {file link -symbolic [file join $srcdir tclconfig] $teapath}]} {
          ::practcl::copyDir [file join $teapath] [file join $srcdir tclconfig]
        }
      }
    }
    set builddir [my define get builddir]
    file mkdir $builddir
    if {![file exists [file join $localsrcdir configure]]} {
      if {[file exists [file join $localsrcdir autogen.sh]]} {
        cd $localsrcdir
        catch {exec sh autogen.sh >>& [file join $builddir autoconf.log]}
        cd $::CWD
      }
    }
    set opts [my ConfigureOpts]
    if {[file exists [file join $builddir autoconf.log]]} {
      file delete [file join $builddir autoconf.log]
    }
    ::practcl::debug [list PKG [my define get name] CONFIGURE {*}$opts]
    ::practcl::log   [file join $builddir autoconf.log] [list  CONFIGURE {*}$opts]
    cd $builddir
    if {[my <project> define get CONFIG_SITE] ne {}} {
      set ::env(CONFIG_SITE) [my <project> define get CONFIG_SITE]
    }
    catch {exec sh [file join $localsrcdir configure] {*}$opts >>& [file join $builddir autoconf.log]}
    cd $::CWD
  }
  
  method make-clean {} {
    set builddir [file normalize [my define get builddir]]
    catch {::practcl::domake $builddir clean}
  }
  
  method make-compile {} {
    set name [my define get name]
    set srcdir [my define get srcdir]
    if {[my define get static 1]} {
      puts "BUILDING Static $name $srcdir"
    } else {
      puts "BUILDING Dynamic $name $srcdir"
    }
    cd $::CWD
    set builddir [file normalize [my define get builddir]]
    file mkdir $builddir
    if {![file exists [file join $builddir Makefile]]} {
      my Configure
    }
    if {[file exists [file join $builddir make.tcl]]} {
      if {[my define get debug 0]} {
        ::practcl::domake.tcl $builddir debug all
      } else {
        ::practcl::domake.tcl $builddir all
      }
    } else {
      ::practcl::domake $builddir all
    }
  }
  
  method make-install DEST {
    set PWD [pwd]
    set builddir [my define get builddir]
    if {[my <project> define get LOCAL 0] || $DEST eq {}} {
      if {[file exists [file join $builddir make.tcl]]} {
        puts "[self] Local INSTALL (Practcl)"
        ::practcl::domake.tcl $builddir install
      } else {[my define get broken_destroot 0] == 0} {
        puts "[self] Local INSTALL (TEA)"
        ::practcl::domake $builddir install
      }
    } else {
      if {[file exists [file join $builddir make.tcl]]} {
        # Practcl builds can inject right to where we need them
        puts "[self] VFS INSTALL $DEST (Practcl)"
        ::practcl::domake.tcl $builddir install-package $DEST
      } elseif {[my define get broken_destroot 0] == 0} {
        # Most modern TEA projects understand DESTROOT in the makefile
        puts "[self] VFS INSTALL $DEST (TEA)"
        ::practcl::domake $builddir install DESTDIR=[::practcl::file_relative $builddir $DEST]
      } else {
        # But some require us to do an install into a fictitious filesystem
        # and then extract the gooey parts within.
        # (*cough*) TkImg
        set PREFIX [my <project> define get prefix]
        set BROKENROOT [::practcl::msys_to_tclpath [my <project> define get prefix_broken_destdir]]
        file delete -force $BROKENROOT
        file mkdir $BROKENROOT
        ::practcl::domake $builddir $install
        ::practcl::copyDir $BROKENROOT  [file join $DEST [string trimleft $PREFIX /]]
        file delete -force $BROKENROOT
      }
    }
    cd $PWD
  }
  
  method build-compile-sources {PROJECT COMPILE CPPCOMPILE INCLUDES} {
    set objext [my define get OBJEXT o]
    set EXTERN_OBJS {}
    set OBJECTS {}
    set result {}
    set builddir [$PROJECT define get builddir]
    file mkdir [file join $builddir objs]
    set debug [$PROJECT define get debug 0]

    set task {}
    ###
    # Compile the C sources
    ###
    ::practcl::debug ### COMPILE PRODUCTS
    foreach {ofile info} [${PROJECT} project-compile-products] {
      ::practcl::debug $ofile $info
      if {[dict exists $info library]} {
        #dict set task $ofile done 1
        continue
      }
      # Products with no cfile aren't compiled
      if {![dict exists $info cfile] || [set cfile [dict get $info cfile]] eq {}} {
        #dict set task $ofile done 1
        continue
      }
      set ofile [file rootname $ofile]
      dict set task $ofile done 0
      if {[dict exists $info external] && [dict get $info external]==1} {
        dict set task $ofile external 1
      } else {
        dict set task $ofile external 0
      }
      set cfile [dict get $info cfile]
      if {$debug} {
        set ofilename [file join $builddir objs [file rootname [file tail $ofile]].debug.${objext}]
      } else {
        set ofilename [file join $builddir objs [file tail $ofile]].${objext}
      }
      dict set task $ofile source $cfile
      dict set task $ofile objfile $ofilename
      if {![dict exist $info command]} {
        if {[file extension $cfile] in {.c++ .cpp}} {
          set cmd $CPPCOMPILE
        } else {
          set cmd $COMPILE
        }
        if {[dict exists $info extra]} {
          append cmd " [dict get $info extra]"
        }
        append cmd " $INCLUDES"
        append cmd " -c $cfile"
        append cmd " -o $ofilename"
        dict set task $ofile command $cmd
      }
    }
    set completed 0
    while {$completed==0} {
      set completed 1
      foreach {ofile info} $task {
        set waiting {}
        if {[dict exists $info done] && [dict get $info done]} continue
        ::practcl::debug COMPILING $ofile $info
        set filename [dict get $info objfile]
        if {[file exists $filename] && [file mtime $filename]>[file mtime [dict get $info source]]} {
          lappend result $filename
          dict set task $ofile done 1
          continue
        }
        if {[dict exists $info depend]} {
          foreach file [dict get $info depend] {
            if {[dict exists $task $file command] && [dict exists $task $file done] && [dict get $task $file done] != 1} {
              set waiting $file
              break
            }
          }
        }
        if {$waiting ne {}} {
          set completed 0
          puts "$ofile waiting for $waiting"
          continue
        }
        if {[dict exists $info command]} {
          set cmd [dict get $info command]
          puts "$cmd"
          exec {*}$cmd >&@ stdout
        }
        if {[file exists $filename]} {
          lappend result $filename
          dict set task $ofile done 1
          continue
        }
        error "Failed to produce $filename"
      }
    }
    return $result
  }

method build-Makefile {path PROJECT} {
  array set proj [$PROJECT define dump]
  set path $proj(builddir)
  cd $path
  set includedir .
  set objext [my define get OBJEXT o]

  #lappend includedir [::practcl::file_relative $path $proj(TCL_INCLUDES)]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TCL_SRC_DIR) generic]]]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(srcdir) generic]]]
  foreach include [$PROJECT toolset-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  set INCLUDES  "-I[join $includedir " -I"]"
  set NAME [string toupper $proj(name)]
  set result {}
  set products {}
  set libraries {}
  set thisline {}
  ::practcl::cputs result "${NAME}_DEFS = $proj(DEFS)\n"
  ::practcl::cputs result "${NAME}_INCLUDES = -I\"[join $includedir "\" -I\""]\"\n"
  ::practcl::cputs result "${NAME}_COMPILE = \$(CC) \$(CFLAGS) \$(PKG_CFLAGS) \$(${NAME}_DEFS) \$(${NAME}_INCLUDES) \$(INCLUDES) \$(AM_CPPFLAGS) \$(CPPFLAGS) \$(AM_CFLAGS)"
  ::practcl::cputs result "${NAME}_CPPCOMPILE = \$(CXX) \$(CFLAGS) \$(PKG_CFLAGS) \$(${NAME}_DEFS) \$(${NAME}_INCLUDES) \$(INCLUDES) \$(AM_CPPFLAGS) \$(CPPFLAGS) \$(AM_CFLAGS)"

  foreach {ofile info} [$PROJECT project-compile-products] {
    dict set products $ofile $info
    set fname [file rootname ${ofile}].${objext}
    if {[dict exists $info library]} {
lappend libraries $ofile
continue
    }
    if {[dict exists $info depend]} {
      ::practcl::cputs result "\n${fname}: [dict get $info depend]"
    } else {
      ::practcl::cputs result "\n${fname}:"
    }
    set cfile [dict get $info cfile]
    if {[file extension $cfile] in {.c++ .cpp}} {
      set cmd "\t\$\(${NAME}_CPPCOMPILE\)"
    } else {
      set cmd "\t\$\(${NAME}_COMPILE\)"
    }
    if {[dict exists $info extra]} {
      append cmd " [dict get $info extra]"
    }
    append cmd " -c [dict get $info cfile] -o \$@\n\t"
    ::practcl::cputs result  $cmd
  }

  set map {}
  lappend map %LIBRARY_NAME% $proj(name)
  lappend map %LIBRARY_VERSION% $proj(version)
  lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $proj(version)]
  lappend map %LIBRARY_PREFIX% [$PROJECT define getnull libprefix]

  if {[string is true [$PROJECT define get SHARED_BUILD]]} {
    set outfile [$PROJECT define get libfile]
  } else {
    set outfile [$PROJECT shared_library]
  }
  $PROJECT define set shared_library $outfile
  ::practcl::cputs result "
${NAME}_SHLIB = $outfile
${NAME}_OBJS = [dict keys $products]
"

  #lappend map %OUTFILE% {\[$]@}
  lappend map %OUTFILE% $outfile
  lappend map %LIBRARY_OBJECTS% "\$(${NAME}_OBJS)"
  ::practcl::cputs result "$outfile: \$(${NAME}_OBJS)"
  ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_SHARED_LIB]]"
  if {[$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL] ni {: {}}} {
    ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL]]"
  }
  ::practcl::cputs result {}
  if {[string is true [$PROJECT define get SHARED_BUILD]]} {
    #set outfile [$PROJECT static_library]
    set outfile $proj(name).a
  } else {
    set outfile [$PROJECT define get libfile]
  }
  $PROJECT define set static_library $outfile
  dict set map %OUTFILE% $outfile
  ::practcl::cputs result "$outfile: \$(${NAME}_OBJS)"
  ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_STATIC_LIB]]"
  ::practcl::cputs result {}
  return $result
}

###
# Produce a static or dynamic library
###
method build-library {outfile PROJECT} {
  array set proj [$PROJECT define dump]
  set path $proj(builddir)
  cd $path
  set includedir .
  #lappend includedir [::practcl::file_relative $path $proj(TCL_INCLUDES)]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TCL_SRC_DIR) generic]]]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(srcdir) generic]]]
  if {[$PROJECT define get tk 0]} {
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) generic]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) ttk]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) xlib]]]
    lappend includedir [::practcl::file_relative $path [file normalize $proj(TK_BIN_DIR)]]
  }
  foreach include [$PROJECT toolset-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  my build-cflags $PROJECT $proj(DEFS) name version defs
  set NAME [string toupper $name]
  set debug [$PROJECT define get debug 0]
  set os [$PROJECT define get TEACUP_OS]

  set INCLUDES  "-I[join $includedir " -I"]"
  if {$debug} {
    set COMPILE "$proj(CC) $proj(CFLAGS_DEBUG) -ggdb \
$proj(CFLAGS_WARNING) $INCLUDES $defs"

    if {[info exists proc(CXX)]} {
      set COMPILECPP "$proj(CXX) $defs $INCLUDES $proj(CFLAGS_DEBUG) -ggdb \
  $defs $proj(CFLAGS_WARNING)"
    } else {
      set COMPILECPP $COMPILE
    }
  } else {
    set COMPILE "$proj(CC) $proj(CFLAGS) $defs"

    if {[info exists proc(CXX)]} {
      set COMPILECPP "$proj(CXX) $defs $proj(CFLAGS)"
    } else {
      set COMPILECPP $COMPILE
    }
  }

  set products [my build-compile-sources $PROJECT $COMPILE $COMPILECPP $INCLUDES]

  set map {}
  lappend map %LIBRARY_NAME% $proj(name)
  lappend map %LIBRARY_VERSION% $proj(version)
  lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $proj(version)]
  lappend map %OUTFILE% $outfile
  lappend map %LIBRARY_OBJECTS% $products
  lappend map {${CFLAGS}} "$proj(CFLAGS_DEFAULT) $proj(CFLAGS_WARNING)"

  if {[string is true [$PROJECT define get SHARED_BUILD 1]]} {
    set cmd [$PROJECT define get PRACTCL_SHARED_LIB]
    append cmd " [$PROJECT define get PRACTCL_LIBS]"
    set cmd [string map $map $cmd]
    puts $cmd
    exec {*}$cmd >&@ stdout
    if {[$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL] ni {: {}}} {
      set cmd [string map $map [$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL]]
      puts $cmd
      exec {*}$cmd >&@ stdout
    }
  } else {
    set cmd [string map $map [$PROJECT define get PRACTCL_STATIC_LIB]]
    puts $cmd
    exec {*}$cmd >&@ stdout
  }
  set ranlib [$PROJECT define get RANLIB]
  if {$ranlib ni {{} :}} {
    catch {exec $ranlib $outfile}
  }
}

###
# Produce a static executable
###
method build-tclsh {outfile PROJECT} {
  puts " BUILDING STATIC TCLSH "
  set TCLOBJ [$PROJECT tclcore]
  ::practcl::toolset select $TCLOBJ
  set PKG_OBJS {}
  foreach item [$PROJECT link list core.library] {
    if {[string is true [$item define get static]]} {
      lappend PKG_OBJS $item
    }
  }
  foreach item [$PROJECT link list package] {
    if {[string is true [$item define get static]]} {
      lappend PKG_OBJS $item
    }
  }
  array set TCL [$TCLOBJ read_configuration]

  set TKOBJ  [$PROJECT tkcore]
  if {[info command $TKOBJ] eq {}} {
    set TKOBJ ::noop
    $PROJECT define set static_tk 0
  } else {
    ::practcl::toolset select $TKOBJ
    array set TK  [$TKOBJ read_configuration]
    set do_tk [$TKOBJ define get static]
    $PROJECT define set static_tk $do_tk
    $PROJECT define set tk $do_tk
    set TKSRCDIR [$TKOBJ define get srcdir]
  }
  set path [file dirname $outfile]
  cd $path
  ###
  # For a static Tcl shell, we need to build all local sources
  # with the same DEFS flags as the tcl core was compiled with.
  # The DEFS produced by a TEA extension aren't intended to operate
  # with the internals of a staticly linked Tcl
  ###
  my build-cflags $PROJECT $TCL(defs) name version defs
  set debug [$PROJECT define get debug 0]
  set NAME [string toupper $name]
  set result {}
  set libraries {}
  set thisline {}
  set OBJECTS {}
  set EXTERN_OBJS {}
  foreach obj $PKG_OBJS {
    $obj compile
    set config($obj) [$obj read_configuration]
  }
  set os [$PROJECT define get TEACUP_OS]
  set TCLSRCDIR [$TCLOBJ define get srcdir]

  set includedir .
  foreach include [$TCLOBJ toolset-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  lappend includedir [::practcl::file_relative $path [file normalize ../tcl/compat/zlib]]
  if {[$PROJECT define get static_tk]} {
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR generic]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR ttk]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR xlib]]]
    lappend includedir [::practcl::file_relative $path [file normalize $TKSRCDIR]]
  }

  foreach include [$PROJECT toolset-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }

  set INCLUDES  "-I[join $includedir " -I"]"
  if {$debug} {
      set COMPILE "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_debug) -ggdb \
$TCL(cflags_warning) $TCL(extra_cflags)"
  } else {
      set COMPILE "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_optimize) \
$TCL(cflags_warning) $TCL(extra_cflags)"
  }
  append COMPILE " " $defs
  lappend OBJECTS {*}[my build-compile-sources $PROJECT $COMPILE $COMPILE $INCLUDES]

  set TCLSRC [file normalize $TCLSRCDIR]

  if {[${PROJECT} define get TEACUP_OS] eq "windows"} {
    set windres [$PROJECT define get RC windres]
    set RSOBJ [file join $path build tclkit.res.o]
    set RCSRC [${PROJECT} define get kit_resource_file]
    set RCMAN [${PROJECT} define get kit_manifest_file]

    set cmd [list $windres -o $RSOBJ -DSTATIC_BUILD --include [::practcl::file_relative $path [file join $TCLSRC generic]]]
    if {[$PROJECT define get static_tk]} {
      if {$RCSRC eq {} || ![file exists $RCSRC]} {
        set RCSRC [file join $TKSRCDIR win rc wish.rc]
      }
      if {$RCMAN eq {} || ![file exists $RCMAN]} {
        set RCMAN [file join [$TKOBJ define get builddir] wish.exe.manifest]
      }
      set TKSRC [file normalize $TKSRCDIR]
      lappend cmd --include [::practcl::file_relative $path [file join $TKSRC generic]] \
        --include [::practcl::file_relative $path [file join $TKSRC win]] \
        --include [::practcl::file_relative $path [file join $TKSRC win rc]]
    } else {
      if {$RCSRC eq {} || ![file exists $RCSRC]} {
        set RCSRC [file join $TCLSRCDIR tclsh.rc]
      }
      if {$RCMAN eq {} || ![file exists $RCMAN]} {
        set RCMAN [file join [$TCLOBJ define get builddir] tclsh.exe.manifest]
      }
    }
    foreach item [${PROJECT} define get resource_include] {
      lappend cmd --include [::practcl::file_relative $path [file normalize $item]]
    }
    lappend cmd [file tail $RCSRC]
    if {![file exists [file join $path [file tail $RCSRC]]]} {
      file copy -force $RCSRC [file join $path [file tail $RCSRC]]
    }
    if {![file exists [file join $path [file tail $RCMAN]]]} {
      file copy -force $RCMAN [file join $path [file tail $RCMAN]]
    }
    ::practcl::doexec {*}$cmd
    lappend OBJECTS $RSOBJ
  }
  puts "***"
  set cmd "$TCL(cc)"
  if {$debug} {
   append cmd " $TCL(cflags_debug)"
  } else {
   append cmd " $TCL(cflags_optimize)"
  }
  append cmd " $TCL(ld_flags)"
  if {$debug} {
   append cmd " $TCL(ldflags_debug)"
  } else {
   append cmd " $TCL(ldflags_optimize)"
  }

  append cmd " $OBJECTS"
  append cmd " $EXTERN_OBJS"
  if {$debug && $os eq "windows"} {
    append cmd " -static"
    append cmd " -L${TCL(src_dir)}/win -ltcl86g"
    if {[$PROJECT define get static_tk]} {
      append cmd " -L${TK(src_dir)}/win -ltk86g"
    }
  } else {
    append cmd " $TCL(build_lib_spec)"
    if {[$PROJECT define get static_tk]} {
      append cmd  " $TK(build_lib_spec)"
    }
  }
  foreach obj $PKG_OBJS {
    append cmd " [$obj linker-products $config($obj)]"
  }
  set LIBS {}
  foreach item $TCL(libs) {
    if {[string range $item 0 1] eq "-l" && $item in $LIBS } continue
    lappend LIBS $item
  }
  if {[$PROJECT define get static_tk]} {
    foreach item $TK(libs) {
      if {[string range $item 0 1] eq "-l" && $item in $LIBS } continue
      lappend LIBS $item
    }
  }
  if {[info exists TCL(extra_libs)]} {
    foreach item $TCL(extra_libs) {
      if {[string range $item 0 1] eq "-l" && $item in $LIBS } continue
      lappend LIBS $item
    }
  }
  foreach obj $PKG_OBJS {
    puts [list Checking $obj for external dependencies]
    foreach item [$obj linker-external $config($obj)] {
      puts [list $obj adds $item]
      if {[string range $item 0 1] eq "-l" && $item in $LIBS } continue
      lappend LIBS $item
    }
  }
  append cmd " ${LIBS}"
  foreach obj $PKG_OBJS {
    puts [list Checking $obj for additional link items]
    foreach item [$obj linker-extra $config($obj)] {
      append cmd $item
    }
  }
  if {$debug && $os eq "windows"} {
    append cmd " -L${TCL(src_dir)}/win ${TCL(stub_lib_flag)}"
    if {[$PROJECT define get static_tk]} {
      append cmd " -L${TK(src_dir)}/win ${TK(stub_lib_flag)}"
    }
  } else {
    append cmd " $TCL(build_stub_lib_spec)"
    if {[$PROJECT define get static_tk]} {
      append cmd " $TK(build_stub_lib_spec)"
    }
  }
  if {[info exists TCL(cc_search_flags)]} {
    append cmd " $TCL(cc_search_flags)"
  }
  append cmd " -o $outfile "
  if {$os eq "windows"} {
    set LDFLAGS_CONSOLE {-mconsole -pipe -static-libgcc}
    set LDFLAGS_WINDOW  {-mwindows -pipe -static-libgcc}
    append cmd " $LDFLAGS_CONSOLE"
  }
  puts "LINK: $cmd"
  exec {*}[string map [list "\n" " " "  " " "] $cmd] >&@ stdout
}

}

###
# END: class toolset gcc.tcl
###
###
# START: class toolset msvc.tcl
###
::oo::class create ::practcl::toolset.msvc {
  superclass ::practcl::toolset

  # MSVC always builds in the source directory
  method BuildDir {PWD} {
    set srcdir [my define get srcdir]
    return $srcdir
  }

  
  # Do nothing
  method make-autodetect {} {
  }
  
  method make-clean {} {
    set PWD [pwd]
    set srcdir [my define get srcdir]
    cd $srcdir
    catch {::practcl::doexec nmake -f makefile.vc clean}
    cd $PWD
  }
  
  method make-compile {} {
    set srcdir [my define get srcdir]
    if {[my define get static 1]} {
      puts "BUILDING Static $name $srcdir"
    } else {
      puts "BUILDING Dynamic $name $srcdir"
    }
    cd $srcdir
    if {[file exists [file join $srcdir make.tcl]]} {
      if {[my define get debug 0]} {
        ::practcl::domake.tcl $srcdir debug all
      } else {
        ::practcl::domake.tcl $srcdir all
      }
    } else {
      if {[file exists [file join $srcdir makefile.vc]]} {
        ::practcl::doexec nmake -f makefile.vc INSTALLDIR=[my <project> define get installdir]  {*}[my NmakeOpts] release
      } elseif {[file exists [file join $srcdir win makefile.vc]]} {
        cd [file join $srcdir win]
        ::practcl::doexec nmake -f makefile.vc INSTALLDIR=[my <project> define get installdir]  {*}[my NmakeOpts] release
      } else {
        error "No make.tcl or makefile.vc found for project $name"
      }
    }
  }
  
  method make-install DEST {
    set PWD [pwd]
    set srcdir [my define get srcdir]
    cd $srcdir
    if {$DEST eq {}} {
      error "No destination given"
    }
    if {[my <project> define get LOCAL 0] || $DEST eq {}} {
      if {[file exists [file join $srcdir make.tcl]]} {
        # Practcl builds can inject right to where we need them
        puts "[self] Local Install (Practcl)"
        ::practcl::domake.tcl $srcdir install
      } else {
        puts "[self] Local Install (Nmake)"
        ::practcl::doexec nmake -f makefile.vc {*}[my NmakeOpts] install
      }
    } else {
      if {[file exists [file join $srcdir make.tcl]]} {
        # Practcl builds can inject right to where we need them
        puts "[self] VFS INSTALL $DEST (Practcl)"
        ::practcl::domake.tcl $srcdir install-package $DEST
      } else {
        puts "[self] VFS INSTALL $DEST"
        ::practcl::doexec nmake -f makefile.vc INSTALLDIR=$DEST {*}[my NmakeOpts] install
      }
    }
    cd $PWD
  }
  
  # Detect what directory contains the Makefile template
  method MakeDir {srcdir} {
    set localsrcdir $srcdir
    if {[file exists [file join $srcdir generic]]} {
      my define add include_dir [file join $srcdir generic]
    }
    if {[file exists [file join $srcdir win]]} {
       my define add include_dir [file join $srcdir win]
    }
    if {[file exists [file join $srcdir makefile.vc]]} {
      set localsrcdir [file join $srcdir win]
    }
    return $localsrcdir
  }
  
  method NmakeOpts {} {
    set opts {}
    set builddir [file normalize [my define get builddir]]

    if {[my <project> define exists tclsrcdir]} {
      ###
      # On Windows we are probably running under MSYS, which doesn't deal with
      # spaces in filename well
      ###
      set TCLSRCDIR  [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tclsrcdir] ..]]]
      set TCLGENERIC [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tclsrcdir] .. generic]]]
      lappend opts TCLDIR=[file normalize $TCLSRCDIR]
      #--with-tclinclude=$TCLGENERIC
    }
    if {[my <project> define exists tksrcdir]} {
      set TKSRCDIR  [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tksrcdir] ..]]]
      set TKGENERIC [::practcl::file_relative [file normalize $builddir] [file normalize [file join $::CWD [my <project> define get tksrcdir] .. generic]]]
      #lappend opts --with-tk=$TKSRCDIR --with-tkinclude=$TKGENERIC
      lappend opts TKDIR=[file normalize $TKSRCDIR]
    }
    return $opts
  }
}

###
# END: class toolset msvc.tcl
###
###
# START: class target.tcl
###

::oo::class create ::practcl::make_obj {
  superclass ::practcl::metaclass

  constructor {module_object name info {action_body {}}} {
    my variable define triggered domake
    set triggered 0
    set domake 0
    set define(name) $name
    set define(action) {}
    array set define $info
    my select
    my initialize
    foreach {stub obj} [$module_object child organs] {
      my graft $stub $obj
    }
    if {$action_body ne {}} {
      set define(action) $action_body
    }
  }

  method do {} {
    my variable domake
    return $domake
  }

  method check {} {
    my variable needs_make domake
    if {$domake} {
      return 1
    }
    if {[info exists needs_make]} {
      return $needs_make
    }
    set make_objects [my <module> make objects]
    set needs_make 0
    foreach item [my define get depends] {
      if {![dict exists $make_objects $item]} continue
      set depobj [dict get $make_objects $item]
      if {$depobj eq [self]} {
        puts "WARNING [self] depends on itself"
        continue
      }
      if {[$depobj check]} {
        set needs_make 1
      }
    }
    if {!$needs_make} {
      foreach filename [my output] {
        if {$filename ne {} && ![file exists $filename]} {
          set needs_make 1
        }
      }
    }
    return $needs_make
  }
  
  method output {} {
    set result {}
    set filename [my define get filename]
    if {$filename ne {}} {
      lappend result $filename
    }
    foreach filename [my define get files] {
      if {$filename ne {}} {
        lappend result $filename
      }
    }
    return $result
  }

  method reset {} {
    my variable triggered domake needs_make
    set triggerd 0
    set domake 0
    set needs_make 0
  }
  
  method triggers {} {
    my variable triggered domake define
    if {$triggered} {
      return $domake
    }
    set triggered 1
    set make_objects [my <module> make objects]

    foreach item [my define get depends] {
      if {![dict exists $make_objects $item]} continue
      set depobj [dict get $make_objects $item]
      if {$depobj eq [self]} {
        puts "WARNING [self] triggers itself"
        continue
      } else {
        set r [$depobj check]
        if {$r} {
          $depobj triggers
        }
      }
    }
    set domake 1
    my <module> make trigger {*}[my define get triggers]
  }
}

###
# END: class target.tcl
###
###
# START: class object.tcl
###
::oo::class create ::practcl::object {
  superclass ::practcl::metaclass

  constructor {parent args} {
    my variable links define
    set organs [$parent child organs]
    my graft {*}$organs
    array set define $organs
    array set define [$parent child define]
    array set links {}
    if {[llength $args]==1 && [file exists [lindex $args 0]]} {
      my define set filename [lindex $args 0]
      ::practcl::product select [self]
    } elseif {[llength $args] == 1} {
      set data  [uplevel 1 [list subst [lindex $args 0]]]
      array set define $data
      my select
    } else {
      array set define [uplevel 1 [list subst $args]]
      my select
    }
    my initialize

  }

  method child {method} {
    return {}
  }

  method go {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable links
    foreach {linktype objs} [array get links] {
      foreach obj $objs {
        $obj go
      }
    }
    ::practcl::debug [list /[self] [self method] [self class]]
  }
}

###
# END: class object.tcl
###
###
# START: class dynamic.tcl
###

###
# Dynamic blocks do not generate their own .c files,
# instead the contribute to the amalgamation
# of the main library file
###
::oo::class create ::practcl::dynamic {

  ###
  # Parser functions
  ###

  method cstructure {name definition {argdat {}}} {
    my variable cstruct
    dict set cstruct $name body $definition
    foreach {f v} $argdat {
      dict set cstruct $name $f $v
    }
    if {![dict exists $cstruct $name public]} {
      dict set cstruct $name public 1
    }
  }
  
  method include header {
    my define add include $header
  }

  method include_dir args {
    my define add include_dir {*}$args
  }

  method include_directory args {
    my define add include_dir {*}$args
  }

  method c_header body {
    my variable code
    ::practcl::cputs code(header) $body
  }

  method c_code body {
    my variable code
    ::practcl::cputs code(funct) $body
  }

  method c_function {header body {info {}}} {
    set header [string map "\t \  \n \ \ \  \ " $header]
    my variable code cfunct
    foreach regexp {
         {(.*) ([a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}
         {(.*) (\x2a[a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}
    } {
      if {[regexp $regexp $header all keywords funcname arglist]} {
        set dat [dict merge {export 0 extern 0 public 1 inline 0} $info]
        dict set dat header $header
        dict set dat body $body
        dict set dat keywords $keywords
        dict set dat arglist $arglist
        if {"IRM_INLINE" in $keywords || "CTHULHU_INLINE" in $keywords} {
          dict set dat public 1
          dict set dat extern 0
          dict set dat inline 1
        } else {
          if {"inline" in $keywords} {
            dict set dat inline 1
          }
          if {"STUB_EXPORT" in $keywords} {
            dict set dat extern 1
            dict set dat public 1
            dict set dat export 1
            dict set dat inline 0
          } elseif {"extern" in $keywords} {
            dict set dat extern 1
            dict set dat public 1
          } elseif {"static" in $keywords} {
            dict set dat public 0
          }
        }
        if {[dict get $dat inline] && [dict get $dat public]} {
          set header [string map {IRM_INLINE {} CTHULHU_INLINE {} static {} inline {} extern {}} [dict get $dat header]]
          dict set dat header "extern $header"
        }
        dict set cfunct $funcname $dat
        return
      }
    }
    puts "WARNING: NON CONFORMING FUNCTION DEFINITION: $headers $body"
    ::practcl::cputs code(header) "$header\;"
    # Could not parse that block as a function
    # append it verbatim to our c_implementation
    ::practcl::cputs code(funct) "$header [list $body]"
  }

  method c_tcloomethod {name body {arginfo {}}} {
    my variable methods code
    foreach {f v} $arginfo {
      dict set methods $name $f $v
    }
    dict set methods $name body "Tcl_Object thisObject = Tcl_ObjectContextObject(objectContext); /* The current connection object */
$body"
  }

  # Alias to classic name
  method cmethod {name body {arginfo {}}} {
    my variable methods code
    foreach {f v} $arginfo {
      dict set methods $name $f $v
    }
    dict set methods $name body "Tcl_Object thisObject = Tcl_ObjectContextObject(objectContext); /* The current connection object */
$body"
  }

  method c_tclproc_nspace nspace {
    my variable code
    if {![info exists code(nspace)]} {
      set code(nspace) {}
    }
    if {$nspace ni $code(nspace)} {
      lappend code(nspace) $nspace
    }
  }

  method c_tclcmd {name body {arginfo {}}} {
    my variable tclprocs code

    foreach {f v} $arginfo {
      dict set tclprocs $name $f $v
    }
    dict set tclprocs $name body $body
  }

  # Alias to classic name
  method c_tclproc_raw {name body {arginfo {}}} {
    my variable tclprocs code

    foreach {f v} $arginfo {
      dict set tclprocs $name $f $v
    }
    dict set tclprocs $name body $body
  }

  method tcltype {name argdat} {
    my variable tcltype
    foreach {f v} $argdat {
      dict set tcltype $name $f $v
    }
    if {![dict exists tcltype $name cname]} {
      dict set tcltype $name cname [string tolower $name]_tclobjtype
    }
    lappend map @NAME@ $name
    set info [dict get $tcltype $name]
    foreach {f v} $info {
      lappend map @[string toupper $f]@ $v
    }
    foreach {func fpat template} {
      freeproc         {@Name@Obj_freeIntRepProc}       {void @FNAME@(Tcl_Obj *objPtr)}
      dupproc          {@Name@Obj_dupIntRepProc}        {void @FNAME@(Tcl_Obj *srcPtr,Tcl_Obj *dupPtr)}
      updatestringproc {@Name@Obj_updateStringRepProc} {void @FNAME@(Tcl_Obj *objPtr)}
      setfromanyproc   {@Name@Obj_setFromAnyProc}       {int @FNAME@(Tcl_Interp *interp,Tcl_Obj *objPtr)}
    } {
      if {![dict exists $info $func]} {
        error "$name does not define $func"
      }
      set body [dict get $info $func]
      # We were given a function name to call
      if {[llength $body] eq 1} continue
      set fname [string map [list @Name@ [string totitle $name]] $fpat]
      my c_function [string map [list @FNAME@ $fname] $template] [string map $map $body]
      dict set tcltype $name $func $fname
    }
  }

  ###
  # Module interactions
  ###


  method project-compile-products {} {
    set filename [my define get output_c]
    set result {}
    if {$filename ne {}} {
      ::practcl::debug [self] [self class] [self method] project-compile-products $filename

      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my Ofile $filename]
        my define set ofile $ofile
      }
      lappend result $ofile [list cfile $filename extra [my define get extra] external [string is true -strict [my define get external]]]
    } else {
      set filename [my define get cfile]
      if {$filename ne {}} {
        ::practcl::debug [self] [self class] [self method] project-compile-products $filename
        if {[my define exists ofile]} {
          set ofile [my define get ofile]
        } else {
          set ofile [my Ofile $filename]
          my define set ofile $ofile
        }
        lappend result $ofile [list cfile $filename extra [my define get extra] external [string is true -strict [my define get external]]]
      }
    }
    foreach item [my link list subordinate] {
      lappend result {*}[$item project-compile-products]
    }
    return $result
  }


  method implement path {
    my go
    my Collate_Source $path
    if {[my define get output_c] eq {}} return
    set filename [file join $path [my define get output_c]]
    ::practcl::debug [self] [my define get filename] WANTS TO GENERATE $filename
    my define set cfile $filename
    set fout [open $filename w]
    puts $fout [my generate-c]
    if {[my define get initfunc] ne {}} {
      puts $fout "extern int DLLEXPORT [my define get initfunc]( Tcl_Interp *interp ) \x7B"
      puts $fout [my generate-loader-module]
      if {[my define get pkg_name] ne {}} {
        puts $fout "   Tcl_PkgProvide(interp, \"[my define get pkg_name]\", \"[my define get pkg_vers]\");"
      }
      puts $fout "  return TCL_OK\;"
      puts $fout "\x7D"
    }
    close $fout
  }



  ###
  # Practcl internals
  ###

  method initialize {} {
    set filename [my define get filename]
    if {$filename eq {}} {
      return
    }
    if {[my define get name] eq {}} {
      my define set name [file tail [file rootname $filename]]
    }
    if {[my define get localpath] eq {}} {
      my define set localpath [my <module> define get localpath]_[my define get name]
    }
    ::source $filename
  }

  method linktype {} {
    return {subordinate product dynamic}
  }

  method generate-cfile-constant {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code cstruct methods tcltype
    if {[info exists code(constant)]} {
      ::practcl::cputs result "/* [my define get filename] CONSTANT */"
      ::practcl::cputs result $code(constant)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        set map {}
        lappend map @NAME@ $name
        lappend map @MACRO@ GET[string toupper $name]

        if {[dict exists $info deleteproc]} {
          lappend map @DELETEPROC@ [dict get $info deleteproc]
        } else {
          lappend map @DELETEPROC@ NULL
        }
        if {[dict exists $info cloneproc]} {
          lappend map @CLONEPROC@ [dict get $info cloneproc]
        } else {
          lappend map @CLONEPROC@ NULL
        }
        ::practcl::cputs result [string map $map {
const static Tcl_ObjectMetadataType @NAME@DataType = {
  TCL_OO_METADATA_VERSION_CURRENT,
  "@NAME@",
  @DELETEPROC@,
  @CLONEPROC@
};
#define @MACRO@(OBJCONTEXT) (@NAME@ *) Tcl_ObjectGetMetadata(OBJCONTEXT,&@NAME@DataType)
}]
      }
    }
    if {[info exists tcltype]} {
      foreach {type info} $tcltype {
        dict with info {}
        ::practcl::cputs result "const Tcl_ObjType $cname = \{\n .name=\"$type\",\n .freeIntRepProc = &${freeproc},\n  .dupIntRepProc = &${dupproc},\n  .updateStringProc = &${updatestringproc},\n  .setFromAnyProc = &${setfromanyproc}\n\}\;"
      }
    }

    if {[info exists methods]} {
      set mtypes {}
      foreach {name info} $methods {
        set callproc   [dict get $info callproc]
        set methodtype [dict get $info methodtype]
        if {$methodtype in $mtypes} continue
        lappend mtypes $methodtype
        ###
        # Build the data struct for this method
        ###
        ::practcl::cputs result "const static Tcl_MethodType $methodtype = \{"
        ::practcl::cputs result "  .version = TCL_OO_METADATA_VERSION_CURRENT,\n  .name = \"$name\",\n  .callProc = $callproc,"
        if {[dict exists $info deleteproc]} {
          set deleteproc [dict get $info deleteproc]
        } else {
          set deleteproc NULL
        }
        if {$deleteproc ni { {} NULL }} {
          ::practcl::cputs result "  .deleteProc = $deleteproc,"
        } else {
          ::practcl::cputs result "  .deleteProc = NULL,"
        }
        if {[dict exists $info cloneproc]} {
          set cloneproc [dict get $info cloneproc]
        } else {
          set cloneproc NULL
        }
        if {$cloneproc ni { {} NULL }} {
          ::practcl::cputs result "  .cloneProc = $cloneproc\n\}\;"
        } else {
          ::practcl::cputs result "  .cloneProc = NULL\n\}\;"
        }
        dict set methods $name methodtype $methodtype
      }
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      ::practcl::cputs result [$obj generate-cfile-constant]
    }
    return $result
  }

  method generate-cfile-header {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct cstruct methods tcltype tclprocs
    set result {}
    if {[info exists code(header)]} {
      ::practcl::cputs result $code(header)
    }
    ::practcl::debug [list cfunct [info exists cfunct]]
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {[dict get $info public]} continue
        ::practcl::cputs result "[dict get $info header]\;"
      }
    }
    ::practcl::debug [list tclprocs [info exists tclprocs]]
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {[dict exists $info header]} {
          ::practcl::cputs result "[dict get $info header]\;"
        }
      }
    }
    ::practcl::debug [list methods [info exists methods] [my define get cclass]]
    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        if {[dict exists $info header]} {
          ::practcl::cputs result "[dict get $info header]\;"
        }
      }
      # Add the initializer wrapper for the class
      ::practcl::cputs result "static int ${thisclass}_OO_Init(Tcl_Interp *interp)\;"
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      set dat [$obj generate-cfile-header]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN [$obj define get filename] generate-cfile-header */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END [$obj define get filename] generate-cfile-header */"
      }
    }
    return $result
  }

  ###
  # Generate code that provides implements Tcl API
  # calls
  ###
  method generate-cfile-tclapi {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code methods tclprocs
    set result {}
    if {[info exists code(method)]} {
      ::practcl::cputs result $code(method)
    }

    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        if {![dict exists $info body]} continue
        set callproc [dict get $info callproc]
        set header [dict get $info header]
        set body [dict get $info body]
        ::practcl::cputs result "/* Tcl Proc $name */"
        ::practcl::cputs result "${header} \{${body}\}"
      }
    }


    if {[info exists methods]} {
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        if {![dict exists $info body]} continue
        set callproc [dict get $info callproc]
        set header [dict get $info header]
        set body [dict get $info body]
        ::practcl::cputs result "/* OO Method $thisclass $name */"
        ::practcl::cputs result "${header} \{${body}\}"
      }
      # Build the OO_Init function
      ::practcl::cputs result "/* Loader for $thisclass */"
      ::practcl::cputs result "static int ${thisclass}_OO_Init(Tcl_Interp *interp) \{"
      ::practcl::cputs result [string map [list @CCLASS@ $thisclass @TCLCLASS@ [my define get class]] {
  /*
  ** Build the "@TCLCLASS@" class
  */
  Tcl_Obj* nameObj;		/* Name of a class or method being looked up */
  Tcl_Object curClassObject;  /* Tcl_Object representing the current class */
  Tcl_Class curClass;		/* Tcl_Class representing the current class */

  /*
   * Find the "@TCLCLASS@" class, and attach an 'init' method to it.
   */

  nameObj = Tcl_NewStringObj("@TCLCLASS@", -1);
  Tcl_IncrRefCount(nameObj);
  if ((curClassObject = Tcl_GetObjectFromObj(interp, nameObj)) == NULL) {
      Tcl_DecrRefCount(nameObj);
      return TCL_ERROR;
  }
  Tcl_DecrRefCount(nameObj);
  curClass = Tcl_GetObjectAsClass(curClassObject);
}]
      if {[dict exists $methods constructor]} {
        set mtype [dict get $methods constructor methodtype]
        ::practcl::cputs result [string map [list @MTYPE@ $mtype] {
  /* Attach the constructor to the class */
  Tcl_ClassSetConstructor(interp, curClass, Tcl_NewMethod(interp, curClass, NULL, 1, &@MTYPE@, NULL));
    }]
      }
      foreach {name info} $methods {
        dict with info {}
        if {$name in {constructor destructor}} continue
        ::practcl::cputs result [string map [list @NAME@ $name @MTYPE@ $methodtype] {
  nameObj=Tcl_NewStringObj("@NAME@",-1);
  Tcl_NewMethod(interp, curClass, nameObj, 1, &@MTYPE@, (ClientData) NULL);
  Tcl_DecrRefCount(nameObj);
}]
        if {[dict exists $info aliases]} {
          foreach alias [dict get $info aliases] {
            if {[dict exists $methods $alias]} continue
            ::practcl::cputs result [string map [list @NAME@ $alias @MTYPE@ $methodtype] {
  nameObj=Tcl_NewStringObj("@NAME@",-1);
  Tcl_NewMethod(interp, curClass, nameObj, 1, &@MTYPE@, (ClientData) NULL);
  Tcl_DecrRefCount(nameObj);
}]
          }
        }
      }
      ::practcl::cputs result "  return TCL_OK\;\n\}\n"
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      ::practcl::cputs result [$obj generate-cfile-tclapi]
    }
    return $result
  }

  ###
  # Generate code that runs when the package/module is
  # initialized into the interpreter
  ###
  method generate-loader-module {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code methods tclprocs
    if {[info exists code(nspace)]} {
      ::practcl::cputs result "  \{\n    Tcl_Namespace *modPtr;"
      foreach nspace $code(nspace) {
        ::practcl::cputs result [string map [list @NSPACE@ $nspace] {
    modPtr=Tcl_FindNamespace(interp,"@NSPACE@",NULL,TCL_NAMESPACE_ONLY);
    if(!modPtr) {
      modPtr = Tcl_CreateNamespace(interp, "@NSPACE@", NULL, NULL);
    }
}]
      }
      ::practcl::cputs result "  \}"
    }
    if {[info exists code(tclinit)]} {
      ::practcl::cputs result $code(tclinit)
    }
    if {[info exists code(cinit)]} {
      ::practcl::cputs result $code(cinit)
    }
    if {[info exists code(initfuncts)]} {
      foreach func $code(initfuncts) {
        ::practcl::cputs result "  if (${func}(interp) != TCL_OK) return TCL_ERROR\;"
      }
    }
    if {[info exists tclprocs]} {
      foreach {name info} $tclprocs {
        set map [list @NAME@ $name @CALLPROC@ [dict get $info callproc]]
        ::practcl::cputs result [string map $map {  Tcl_CreateObjCommand(interp,"@NAME@",(Tcl_ObjCmdProc *)@CALLPROC@,NULL,NULL);}]
        if {[dict exists $info aliases]} {
          foreach alias [dict get $info aliases] {
            set map [list @NAME@ $alias @CALLPROC@ [dict get $info callproc]]
            ::practcl::cputs result [string map $map {  Tcl_CreateObjCommand(interp,"@NAME@",(Tcl_ObjCmdProc *)@CALLPROC@,NULL,NULL);}]
          }
        }
      }
    }

    if {[info exists code(nspace)]} {
      ::practcl::cputs result "  \{\n    Tcl_Namespace *modPtr;"
      foreach nspace $code(nspace) {
        ::practcl::cputs result [string map [list @NSPACE@ $nspace] {
    modPtr=Tcl_FindNamespace(interp,"@NSPACE@",NULL,TCL_NAMESPACE_ONLY);
    Tcl_CreateEnsemble(interp, modPtr->fullName, modPtr, TCL_ENSEMBLE_PREFIX);
    Tcl_Export(interp, modPtr, "[a-z]*", 1);
}]
      }
      ::practcl::cputs result "  \}"
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} {
        ::practcl::cputs result [$obj generate-loader-external]
      } else {
        ::practcl::cputs result [$obj generate-loader-module]
      }
    }
    return $result
  }

  method Collate_Source CWD {
    my variable methods code cstruct tclprocs
    if {[info exists methods]} {
      ::practcl::debug [self] methods [my define get cclass]
      set thisclass [my define get cclass]
      foreach {name info} $methods {
        # Provide a callproc
        if {![dict exists $info callproc]} {
          set callproc [string map {____ _ ___ _ __ _} [string map {{ } _ : _} OOMethod_${thisclass}_${name}]]
          dict set methods $name callproc $callproc
        } else {
          set callproc [dict get $info callproc]
        }
        if {[dict exists $info body] && ![dict exists $info header]} {
          dict set methods $name header "static int ${callproc}(ClientData clientData, Tcl_Interp *interp, Tcl_ObjectContext objectContext ,int objc ,Tcl_Obj *const *objv)"
        }
        if {![dict exists $info methodtype]} {
          set methodtype [string map {{ } _ : _} OOMethodType_${thisclass}_${name}]
          dict set methods $name methodtype $methodtype
        }
      }
      if {![info exists code(initfuncts)] || "${thisclass}_OO_Init" ni $code(initfuncts)} {
        lappend code(initfuncts) "${thisclass}_OO_Init"
      }
    }
    set thisnspace [my define get nspace]

    if {[info exists tclprocs]} {
      ::practcl::debug [self] tclprocs [dict keys $tclprocs]
      foreach {name info} $tclprocs {
        if {![dict exists $info callproc]} {
          set callproc [string map {____ _ ___ _ __ _} [string map {{ } _ : _} TclCmd_${thisnspace}_${name}]]
          dict set tclprocs $name callproc $callproc
        } else {
          set callproc [dict get $info callproc]
        }
        if {[dict exists $info body] && ![dict exists $info header]} {
          dict set tclprocs $name header "static int ${callproc}(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv\[\])"
        }
      }
    }
  }

  # Once an object marks itself as some
  # flavor of dynamic, stop trying to morph
  # it into something else
  method select {} {}

}



###
# END: class dynamic.tcl
###
###
# START: class product.tcl
###

::oo::class create ::practcl::product {


  method code {section body} {
    my variable code
    ::practcl::cputs code($section) $body
  }

  method Collate_Source CWD {}

  method project-compile-products {} {
    set result {}
    noop {
    set filename [my define get filename]
    if {$filename ne {}} {
      ::practcl::debug [self] [self class] [self method] project-compile-products $filename
      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my Ofile $filename]
        my define set ofile $ofile
      }
      lappend result $ofile [list cfile $filename include [my define get include]  extra [my define get extra] external [string is true -strict [my define get external]] object [self]]
    }
    }
    foreach item [my link list subordinate] {
      lappend result {*}[$item project-compile-products]
    }
    return $result
  }

  method generate-debug {{spaces {}}} {
    set result {}
    ::practcl::cputs result "$spaces[list [self] [list class [info object class [self]] filename [my define get filename]] links [my link list]]"
    foreach item [my link list subordinate] {
      practcl::cputs result [$item generate-debug "$spaces  "]
    }
    return $result
  }

  method generate-cfile-constant {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code cstruct methods tcltype
    if {[info exists code(constant)]} {
      ::practcl::cputs result "/* [my define get filename] CONSTANT */"
      ::practcl::cputs result $code(constant)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      ::practcl::cputs result [$obj generate-cfile-constant]
    }
    return $result
  }

  ###
  # Populate const static data structures
  ###
  method generate-cfile-public-structure {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct methods tcltype
    set result {}
    if {[info exists code(struct)]} {
      ::practcl::cputs result $code(struct)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      ::practcl::cputs result [$obj generate-cfile-public-structure]
    }
    return $result
  }

  method generate-cfile-header {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct cstruct methods tcltype tclprocs
    set result {}
    if {[info exists code(header)]} {
      ::practcl::cputs result $code(header)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      set dat [$obj generate-cfile-header]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN [$obj define get filename] generate-cfile-header */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END [$obj define get filename] generate-cfile-header */"
      }
    }
    return $result
  }

  method generate-cfile-global {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct cstruct methods tcltype tclprocs
    set result {}
    if {[info exists code(global)]} {
      ::practcl::cputs result $code(global)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      set dat [$obj generate-cfile-global]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN [$obj define get filename] generate-cfile-global */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END [$obj define get filename] generate-cfile-global */"
      }
    }
    return $result
  }

  method generate-cfile-private-typedef {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(private-typedef)]} {
      ::practcl::cputs result $code(private-typedef)
    }
    if {[info exists cstruct]} {
      # Add defintion for native c data structures
      foreach {name info} $cstruct {
        if {[dict get $info public]==1} continue
        ::practcl::cputs result "typedef struct $name ${name}\;"
        if {[dict exists $info aliases]} {
          foreach n [dict get $info aliases] {
            ::practcl::cputs result "typedef struct $name ${n}\;"
          }
        }
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-cfile-private-typedef]
    }
    return $result
  }

  method generate-cfile-private-structure {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(private-structure)]} {
      ::practcl::cputs result $code(private-structure)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        if {[dict get $info public]==1} continue
        if {[dict exists $info comment]} {
          ::practcl::cputs result [dict get $info comment]
        }
        ::practcl::cputs result "struct $name \{[dict get $info body]\}\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-cfile-private-structure]
    }
    return $result
  }


  ###
  # Generate code that provides subroutines called by
  # Tcl API methods
  ###
  method generate-cfile-functions {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct
    set result {}
    if {[info exists code(funct)]} {
      ::practcl::cputs result $code(funct)
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        ::practcl::cputs result "/* $funcname */"
        if {[dict get $info inline] && [dict get $info public]} {
          ::practcl::cputs result "\ninline [dict get $info header]\{[dict get $info body]\}"
        } else {
          ::practcl::cputs result "\n[dict get $info header]\{[dict get $info body]\}"
        }
      }
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} {
        continue
      }
      ::practcl::cputs result [$obj generate-cfile-functions]
    }
    return $result
  }

  ###
  # Generate code that provides implements Tcl API
  # calls
  ###
  method generate-cfile-tclapi {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code methods tclprocs
    set result {}
    if {[info exists code(method)]} {
      ::practcl::cputs result $code(method)
    }
    foreach obj [my link list product] {
      # Exclude products that will generate their own C files
      if {[$obj define get output_c] ne {}} continue
      ::practcl::cputs result [$obj generate-cfile-tclapi]
    }
    return $result
  }


  method generate-hfile-public-define {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(public-define)]} {
      ::practcl::cputs result $code(public-define)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-define]
    }
    return $result
  }

  method generate-hfile-public-macro {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(public-macro)]} {
      ::practcl::cputs result $code(public-macro)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-macro]
    }
    return $result
  }

  method generate-hfile-public-typedef {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(public-typedef)]} {
      ::practcl::cputs result $code(public-typedef)
    }
    if {[info exists cstruct]} {
      # Add defintion for native c data structures
      foreach {name info} $cstruct {
        if {[dict get $info public]==0} continue
        ::practcl::cputs result "typedef struct $name ${name}\;"
        if {[dict exists $info aliases]} {
          foreach n [dict get $info aliases] {
            ::practcl::cputs result "typedef struct $name ${n}\;"
          }
        }
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-typedef]
    }
    return $result
  }

  method generate-hfile-public-structure {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cstruct
    set result {}
    if {[info exists code(public-structure)]} {
      ::practcl::cputs result $code(public-structure)
    }
    if {[info exists cstruct]} {
      foreach {name info} $cstruct {
        if {[dict get $info public]==0} continue
        if {[dict exists $info comment]} {
          ::practcl::cputs result [dict get $info comment]
        }
        ::practcl::cputs result "struct $name \{[dict get $info body]\}\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-structure]
    }
    return $result
  }

  method generate-hfile-public-headers {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code tcltype
    set result {}
    if {[info exists code(public-header)]} {
      ::practcl::cputs result $code(public-header)
    }
    if {[info exists tcltype]} {
      foreach {type info} $tcltype {
        if {![dict exists $info cname]} {
          set cname [string tolower ${type}]_tclobjtype
          dict set tcltype $type cname $cname
        } else {
          set cname [dict get $info cname]
        }
        ::practcl::cputs result "extern const Tcl_ObjType $cname\;"
      }
    }
    if {[info exists code(public)]} {
      ::practcl::cputs result $code(public)
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-headers]
    }
    return $result
  }

  method generate-hfile-public-function {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct tcltype
    set result {}

    if {[my define get initfunc] ne {}} {
      ::practcl::cputs result "int [my define get initfunc](Tcl_Interp *interp);"
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {![dict get $info public]} continue
        ::practcl::cputs result "[dict get $info header]\;"
      }
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-hfile-public-function]
    }
    return $result
  }

  method generate-hfile-public-includes {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set includes {}
    foreach item [my define get public-include] {
      if {$item ni $includes} {
        lappend includes $item
      }
    }
    foreach mod [my link list product] {
      foreach item [$mod generate-hfile-public-includes] {
        if {$item ni $includes} {
          lappend includes $item
        }
      }
    }
    return $includes
  }

  method generate-hfile-public-verbatim {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set includes {}
    foreach item [my define get public-verbatim] {
      if {$item ni $includes} {
        lappend includes $item
      }
    }
    foreach mod [my link list subordinate] {
      foreach item [$mod generate-hfile-public-verbatim] {
        if {$item ni $includes} {
          lappend includes $item
        }
      }
    }
    return $includes
  }

  method generate-loader-external {} {
    if {[my define get initfunc] eq {}} {
      return "/*  [my define get filename] declared not initfunc */"
    }
    return "  if([my define get initfunc](interp)) return TCL_ERROR\;"
  }

  method generate-loader-module {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code
    set result {}
    if {[info exists code(cinit)]} {
      ::practcl::cputs result $code(cinit)
    }
    if {[my define get initfunc] ne {}} {
      ::practcl::cputs result "  if([my define get initfunc](interp)!=TCL_OK) return TCL_ERROR\;"
    }
    set result [::practcl::_tagblock $result c [my define get filename]]
    foreach item [my link list product] {
      if {[$item define get output_c] ne {}} {
        ::practcl::cputs result [$item generate-loader-external]
      } else {
        ::practcl::cputs result [$item generate-loader-module]
      }
    }
    return $result
  }

  method generate-stub-function {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    my variable code cfunct tcltype
    set result {}
    foreach mod [my link list product] {
      foreach {funct def} [$mod generate-stub-function] {
        dict set result $funct $def
      }
    }
    if {[info exists cfunct]} {
      foreach {funcname info} $cfunct {
        if {![dict get $info export]} continue
        dict set result $funcname [dict get $info header]
      }
    }
    return $result
  }


  method IncludeAdd {headervar args} {
    upvar 1 $headervar headers
    foreach inc $args {
      if {[string index $inc 0] ni {< \"}} {
        set inc "\"$inc\""
      }
      if {$inc ni $headers} {
        lappend headers $inc
      }
    }
  }

  method generate-tcl-loader {} {
    set result {}
    set PKGINIT [my define get pkginit]
    set PKG_NAME [my define get name [my define get pkg_name]]
    set PKG_VERSION [my define get pkg_vers [my define get version]]
    if {[string is true [my define get SHARED_BUILD 0]]} {
      set LIBFILE [my define get libfile]
      ::practcl::cputs result [string map \
        [list @LIBFILE@ $LIBFILE @PKGINIT@ $PKGINIT @PKG_NAME@ $PKG_NAME @PKG_VERSION@ $PKG_VERSION] {
# Shared Library Style
load [file join [file dirname [file join [pwd] [info script]]] @LIBFILE@] @PKGINIT@
package provide @PKG_NAME@ @PKG_VERSION@
}]
    } else {
      ::practcl::cputs result [string map \
      [list @PKGINIT@ $PKGINIT @PKG_NAME@ $PKG_NAME @PKG_VERSION@ $PKG_VERSION] {
# Tclkit Style
load {} @PKGINIT@
package provide @PKG_NAME@ @PKG_VERSION@
}]
    }
    return $result
  }

  ###
  # This methods generates any Tcl script file
  # which is required to pre-initialize the C library
  ###
  method generate-tcl-pre {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code
    if {[info exists code(tcl)]} {
      set result [::practcl::_tagblock $code(tcl) tcl [my define get filename]]
    }
    if {[info exists code(tcl-pre)]} {
      set result [::practcl::_tagblock $code(tcl) tcl [my define get filename]]
    }
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-tcl-pre]
    }
    return $result
  }

  method generate-tcl-post {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    my variable code
    if {[info exists code(tcl-post)]} {
      set result [::practcl::_tagblock $code(tcl-post) tcl [my define get filename]]
    }
    foreach mod [my link list product] {
      ::practcl::cputs result [$mod generate-tcl-post]
    }
    return $result
  }


  method linktype {} {
    return {subordinate product}
  }

  method Ofile filename {
    set lpath [my <module> define get localpath]
    if {$lpath eq {}} {
      set lpath [my <module> define get name]
    }
    return ${lpath}_[file rootname [file tail $filename]]
  }

  ###
  # Methods called by the master project
  ###

  method project-static-packages {} {
    set result [my define get static_packages]
    set initfunc [my define get initfunc]
    if {$initfunc ne {}} {
      set pkg_name [my define get pkg_name]
      if {$pkg_name ne {}} {
        dict set result $pkg_name initfunc $initfunc
        dict set result $pkg_name version [my define get version [my define get pkg_vers]]
        dict set result $pkg_name autoload [my define get autoload 0]
      }
    }
    foreach item [my link list subordinate] {
      foreach {pkg info} [$item project-static-packages] {
        dict set result $pkg $info
      }
    }
    return $result
  }

  ###
  # Methods called by the toolset
  ###

  method toolset-include-directory {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result [my define get include_dir]
    foreach obj [my link list product] {
      foreach path [$obj toolset-include-directory] {
        lappend result $path
      }
    }
    return $result
  }

  method target {method args} {
    switch $method {
      is_unix { return [expr {$::tcl_platform(platform) eq "unix"}] }
    }
  }

}

oo::objdefine ::practcl::product {
  method select {object} {
    set class [$object define get class]
    set mixin [$object define get product]
    if {$class eq {} && $mixin eq {}} {
      set filename [$object define get filename]
      if {$filename ne {} && [file exists $filename]} {
        switch [file extension $filename] {
          .tcl {
            set mixin ::practcl::product.dynamic
          }
          .h {
            set mixin ::practcl::product.cheader
          }
          .c {
            set mixin ::practcl::product.csource
          }
          .ini {
            switch [file tail $filename] {
              module.ini {
                set class ::practcl::module
              }
              library.ini {
                set class ::practcl::subproject
              }
            }
          }
          .so -
          .dll -
          .dylib -
          .a {
            set mixin ::practcl::product.clibrary
          }
        }
      }
    }
    if {$class ne {}} {
      $object morph $class
    }
    if {$mixin ne {}} {
      $object mixin product $mixin
    }
  }
}

###
# Flesh out several trivial varieties of product
###
::oo::class create ::practcl::product.cheader {
  superclass ::practcl::product

  method project-compile-products {} {}
  method generate-loader-module {} {}
}

::oo::class create ::practcl::product.csource {
  superclass ::practcl::product

  method project-compile-products {} {
    set result {}
    set filename [my define get filename]
    if {$filename ne {}} {
      ::practcl::debug [self] [self class] [self method] project-compile-products $filename
      if {[my define exists ofile]} {
        set ofile [my define get ofile]
      } else {
        set ofile [my Ofile $filename]
        my define set ofile $ofile
      }
      lappend result $ofile [list cfile $filename extra [my define get extra] external [string is true -strict [my define get external]] object [self]]
    }
    foreach item [my link list subordinate] {
      lappend result {*}[$item project-compile-products]
    }
    return $result
  }
}

::oo::class create ::practcl::product.clibrary {
  superclass ::practcl::product

  method linker-products {configdict} {
    return [my define get filename]
  }

}

::oo::class create ::practcl::product.dynamic {
  superclass ::practcl::dynamic ::practcl::product

  method initialize {} {
    set filename [my define get filename]
    if {$filename eq {}} {
      return
    }
    if {[my define get name] eq {}} {
      my define set name [file tail [file rootname $filename]]
    }
    if {[my define get localpath] eq {}} {
      my define set localpath [my <module> define get localpath]_[my define get name]
    }
    # Future Development:
    # Scan source file to see if it is encoded in criticl or practcl notation
    #set thisline {}
    #foreach line [split [::practcl::cat $filename] \n] {
    #
    #}
    ::source $filename
    if {[my define get output_c] ne {}} {
      # Turn into a module if we have an output_c file
      my morph ::practcl::module
    }
  }
}

::oo::class create ::practcl::product.critcl {
  superclass ::practcl::dynamic ::practcl::product
}


###
# END: class product.tcl
###
###
# START: class module.tcl
###

###
# In the end, all C code must be loaded into a module
# This will either be a dynamically loaded library implementing
# a tcl extension, or a compiled in segment of a custom shell/app
###
::oo::class create ::practcl::module {
  superclass ::practcl::object ::practcl::product.dynamic

  method _MorphPatterns {} {
    return {{@name@} {::practcl::module.@name@} ::practcl::module}
  }
  
  method add args {
    my variable links
    set object [::practcl::object new [self] {*}$args]
    foreach linktype [$object linktype] {
      lappend links($linktype) $object
    }
    return $object
  }
  
  
  method install-headers args {}
  
  ###
  # Target handling
  ###
  method make {command args} {
    my variable make_object
    if {![info exists make_object]} {
      set make_object {}
    }
    switch $command {
      pkginfo {
        ###
        # Build local variables needed for install
        ###
        package require platform
        set result {}
        set dat [my define dump]
        set PKG_DIR [dict get $dat name][dict get $dat version]
        dict set result PKG_DIR $PKG_DIR
        dict with dat {}
        if {![info exists DESTDIR]} {
          set DESTDIR {}
        }
        dict set result profile [::platform::identify]
        dict set result os $::tcl_platform(os)
        dict set result platform $::tcl_platform(platform)
        foreach {field value} $dat {
          switch $field {
            includedir -
            mandir -
            datadir -
            libdir -
            libfile -
            name -
            output_tcl -
            version -
            authors -
            license -
            requires {
              dict set result $field $value
            }
            TEA_PLATFORM {
              dict set result platform $value
            }
            TEACUP_OS {
              dict set result os $value
            }
            TEACUP_PROFILE {
              dict set result profile $value
            }
            TEACUP_ZIPFILE {
              dict set result zipfile $value
            }
          }
        }
        if {![dict exists $result zipfile]} {
          dict set result zipfile "[dict get $result name]-[dict get $result version]-[dict get $result profile].zip"
        }
        return $result
      }
      objects {
        return $make_object
      }
      object {
        set name [lindex $args 0]
        if {[dict exists $make_object $name]} {
          return [dict get $make_object $name]
        }
        return {}
      }
      reset {
        foreach {name obj} $make_object {
          $obj reset
        }
      }
      trigger {
        foreach {name obj} $make_object {
          if {$name in $args} {
            $obj triggers
          }
        }
      }
      depends {
        foreach {name obj} $make_object {
          if {$name in $args} {
            $obj check
          }
        }
      }
      filename {
        set name [lindex $args 0]
        if {[dict exists $make_object $name]} {
          return [[dict get $make_object $name] define get filename]
        }
      }
      task -
      target -
      add {
        set name [lindex $args 0]
        set info [uplevel #0 [list subst [lindex $args 1]]]
        set body [lindex $args 2]
        
        set nspace [namespace current]
        if {[dict exist $make_object $name]} {
          set obj [dict get $$make_object $name]
        } else {
          set obj [::practcl::make_obj new [self] $name $info $body]
          dict set make_object $name $obj
          dict set target_make $name 0
          dict set target_trigger $name 0
        }
        if {[dict exists $info aliases]} {
          foreach item [dict get $info aliases] {
            if {![dict exists $make_object $item]} {
              dict set make_object $item $obj
            }
          }
        }
        return $obj
      }
      todo {
         foreach {name obj} $make_object {
          if {[$obj do]} {
            lappend result $name
          }
        }       
      }
      do {
        global CWD SRCDIR project SANDBOX
        foreach {name obj} $make_object {
          if {[$obj do]} {
            eval [$obj define get action]
          }
        }
      }
    }
  }
  
  method child which {
    switch $which {
      organs {
        return [list project [my define get project] module [self]]
      }
    }
  }

 ###
  # This methods generates the contents of an amalgamated .c file
  # which implements the loader for a batch of tools
  ###
  method generate-c {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {
/* This file was generated by practcl */
    }
    set includes {}

    foreach mod [my link list product] {
      # Signal modules to formulate final implementation
      $mod go
    }
    set headers {}

    my IncludeAdd headers <tcl.h> <tclOO.h>
    if {[my define get tk 0]} {
      my IncludeAdd headers <tk.h>
    }
    if {[my define get output_h] ne {}} {
      my IncludeAdd headers [my define get output_h]
    }
    my IncludeAdd headers {*}[my define get include]

    foreach mod [my link list dynamic] {
      my IncludeAdd headers {*}[$mod define get include]
    }
    foreach inc $headers {
      ::practcl::cputs result "#include $inc"
    }
    foreach {method} {
      generate-cfile-header
      generate-cfile-private-typedef
      generate-cfile-private-structure
      generate-cfile-public-structure
      generate-cfile-constant
      generate-cfile-global
      generate-cfile-functions
      generate-cfile-tclapi
    } {
      set dat [my $method]
      if {[string length [string trim $dat]]} {
        ::practcl::cputs result "/* BEGIN $method [my define get filename] */"
        ::practcl::cputs result $dat
        ::practcl::cputs result "/* END $method [my define get filename] */"
      }
    }
    ::practcl::debug [list /[self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    return $result
  }


  ###
  # This methods generates the contents of an amalgamated .h file
  # which describes the public API of this module
  ###
  method generate-h {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    set includes [my generate-hfile-public-includes]
    foreach inc $includes {
      if {[string index $inc 0] ni {< \"}} {
        ::practcl::cputs result "#include \"$inc\""
      } else {
        ::practcl::cputs result "#include $inc"
      }
    }

    foreach method {
      generate-hfile-public-define
      generate-hfile-public-macro
      generate-hfile-public-typedef
      generate-hfile-public-structure
    } {
      ::practcl::cputs result "/* BEGIN SECTION $method */"
      ::practcl::cputs result [my $method]
      ::practcl::cputs result "/* END SECTION $method */"
    }

    foreach file [my generate-hfile-public-verbatim] {
      ::practcl::cputs result "/* BEGIN $file */"
      ::practcl::cputs result [::practcl::cat $file]
      ::practcl::cputs result "/* END $file */"
    }

    foreach method {
      generate-hfile-public-headers
      generate-hfile-public-function
    } {
      ::practcl::cputs result "/* BEGIN SECTION $method */"
      ::practcl::cputs result [my $method]
      ::practcl::cputs result "/* END SECTION $method */"
    }
    return $result
  }

  method generate-loader {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set result {}
    if {[my define get initfunc] eq {}} return
    ::practcl::cputs result  "
extern int DLLEXPORT [my define get initfunc]( Tcl_Interp *interp ) \{"
    ::practcl::cputs result  {
  /* Initialise the stubs tables. */
  #ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, "8.6", 0)==NULL) return TCL_ERROR;
    if (TclOOInitializeStubs(interp, "1.0") == NULL) return TCL_ERROR;
}
    if {[my define get tk 0]} {
      ::practcl::cputs result  {    if (Tk_InitStubs(interp, "8.6", 0)==NULL) return TCL_ERROR;}
    }
    ::practcl::cputs result {  #endif}
    set TCLINIT [my generate-tcl-pre]
    if {[string length [string trim $TCLINIT]]} {
      ::practcl::cputs result "  if(interp) {\nif(Tcl_Eval(interp,[::practcl::tcl_to_c $TCLINIT])) return TCL_ERROR;\n  }"
    }
    ::practcl::cputs result [my generate-loader-module]

    set TCLINIT [my generate-tcl-post]
    if {[string length [string trim $TCLINIT]]} {
      ::practcl::cputs result "  if(interp) {\nif(Tcl_Eval(interp,[::practcl::tcl_to_c $TCLINIT])) return TCL_ERROR;\n }"
    }
    if {[my define exists pkg_name]} {
      ::practcl::cputs result  "    if (Tcl_PkgProvide(interp, \"[my define get pkg_name [my define get name]]\" , \"[my define get pkg_vers [my define get version]]\" )) return TCL_ERROR\;"
    }
    ::practcl::cputs result  "  return TCL_OK\;\n\}\n"
    return $result
  }
  method initialize {} {
    set filename [my define get filename]
    if {$filename eq {}} {
      return
    }
    if {[my define get name] eq {}} {
      my define set name [file tail [file dirname $filename]]
    }
    if {[my define get localpath] eq {}} {
      my define set localpath [my <project> define get name]_[my define get name]
    }
    my graft module [self]
    ::practcl::debug [self] SOURCE $filename
    my source $filename
  }

  method implement path {
    my go
    my Collate_Source $path
    set errs {}
    foreach item [my link list dynamic] {
      if {[catch {$item implement $path} err errdat]} {
        lappend errs "Skipped $item: [$item define get filename] $err"
        if {[dict exists $errdat -errorinfo]} {
          lappend errs [dict get $errdat -errorinfo]
        } else {
          lappend errs $errdat
        }
      }
    }
    foreach item [my link list module] {
      if {[catch {$item implement $path} err errdat]} {
        lappend errs "Skipped $item: [$item define get filename] $err"
        if {[dict exists $errdat -errorinfo]} {
          lappend errs [dict get $errdat -errorinfo]
        } else {
          lappend errs $errdat
        }
      }
    }
    if {[llength $errs]} {
      set logfile [file join $::CWD practcl.log]      
      ::practcl::log $logfile "*** ERRORS ***"
      foreach {item trace} $errs {
        ::practcl::log $logfile "###\n# ERROR\n###\n$item"
       ::practcl::log $logfile "###\n# TRACE\n###\n$trace"
      }
      ::practcl::log $logfile "*** DEBUG INFO ***"
      ::practcl::log $logfile $::DEBUG_INFO
      puts stderr "Errors saved to $logfile"
      exit 1
    }
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set filename [my define get output_c]
    if {$filename eq {}} {
      ::practcl::debug [list /[self] [self method] [self class]]
      return
    }
    set cout [open [file join $path [file rootname $filename].c] w]
    puts $cout [subst {/*
** This file is generated by the [info script] script
** any changes will be overwritten the next time it is run
*/}]
    puts $cout [my generate-c]
    puts $cout [my generate-loader]
    close $cout
    ::practcl::debug [list /[self] [self method] [self class]]
  }

  method linktype {} {
    return {subordinate product dynamic module}
  }
}

###
# END: class module.tcl
###
###
# START: class project baseclass.tcl
###

::oo::class create ::practcl::project {
  superclass ::practcl::module

  method _MorphPatterns {} {
    return {{@name@} {::practcl::@name@} {::practcl::project.@name@} {::practcl::project}}
  }

  constructor args {
    my variable define
    if {[llength $args] == 1} {
      set rawcontents [lindex $args 0]
    } else {
      set rawcontents $args
    }
    if {[catch {uplevel 1 [list subst $rawcontents]} contents]} {
      set contents $rawcontents
    }
    ###
    # The first instance of ::practcl::project (or its descendents)
    # registers itself as the ::practcl::MAIN. If a project other
    # than ::practcl::LOCAL is created, odds are that was the one
    # the developer intended to be the main project
    ###
    if {$::practcl::MAIN eq "::practcl::LOCAL"} {
      set ::practcl::MAIN [self]
    }
    # DEFS fields need to be passed unchanged and unsubstituted
    # as we need to preserve their escape characters
    foreach field {TCL_DEFS DEFS TK_DEFS} {
      if {[dict exists $rawcontents $field]} {
        dict set contents $field [dict get $rawcontents $field]
      }
    }
    my graft module [self]
    array set define $contents
    ::practcl::toolset select [self]
    my initialize
  }

  method add_object object {
    my link object $object
  }

  method add_project {pkg info {oodefine {}}} {
    ::practcl::debug [self] add_project $pkg $info
    set os [my define get TEACUP_OS]
    if {$os eq {}} {
      set os [::practcl::os]
      my define set os $os
    }
    set fossilinfo [list download [my define get download] tag trunk sandbox [my define get sandbox]]
    if {[dict exists $info os] && ($os ni [dict get $info os])} return
    # Select which tag to use here.
    # For production builds: tag-release
    set profile [my define get profile release]:
    if {[dict exists $info profile $profile]} {
      dict set info tag [dict get $info profile $profile]
    }
    dict set info USEMSVC [my define get USEMSVC 0]
    dict set info debug [my define get debug 0]
    set obj [namespace current]::PROJECT.$pkg
    if {[info command $obj] eq {}} {
      set obj [::practcl::subproject create $obj [self] [dict merge $fossilinfo [list name $pkg pkg_name $pkg static 0 class subproject.binary] $info]]
    }
    my link object $obj
    oo::objdefine $obj $oodefine
    $obj define set masterpath $::CWD
    $obj go
    return $obj
  }

  method add_tool {pkg info {oodefine {}}} {
    ::practcl::debug [self] add_tool $pkg $info
    set info [dict merge [::practcl::local_os] $info]

    set os [dict get $info TEACUP_OS]
    set fossilinfo [list download [my define get download] tag trunk sandbox [my define get sandbox]]
    if {[dict exists $info os] && ($os ni [dict get $info os])} return
    # Select which tag to use here.
    # For production builds: tag-release
    set profile [my define get profile release]:
    if {[dict exists $info profile $profile]} {
      dict set info tag [dict get $info profile $profile]
    }
    set obj ::practcl::OBJECT::TOOL.$pkg
    if {[info command $obj] eq {}} {
      set obj [::practcl::subproject create $obj [self] [dict merge $fossilinfo [list name $pkg pkg_name $pkg static 0] $info]]
    }
    my link add tool $obj
    oo::objdefine $obj $oodefine
    $obj define set masterpath $::CWD
    $obj go
    return $obj
  }

  method build-tclcore {} {
    set os [my define get TEACUP_OS]
    set tcl_config_opts [::practcl::platform::tcl_core_options $os]
    set tk_config_opts  [::practcl::platform::tk_core_options $os]

    lappend tcl_config_opts --prefix [my define get prefix] --exec-prefix [my define get prefix]
    set tclobj [my tclcore]
    if {[my define get debug 0]} {
      $tclobj define set debug 1
      lappend tcl_config_opts --enable-symbols=true
    }
    $tclobj define set config_opts $tcl_config_opts
    $tclobj go
    $tclobj compile

    set _TclSrcDir [$tclobj define get localsrcdir]
    my define set tclsrcdir $_TclSrcDir

    set tkobj [my tkcore]
    lappend tk_config_opts --with-tcl=[::practcl::file_relative [$tkobj define get builddir]  [$tclobj define get builddir]]
    if {[my define get debug 0]} {
      $tkobj define set debug 1
      lappend tk_config_opts --enable-symbols=true
    }
    $tkobj define set config_opts $tk_config_opts
    $tkobj compile
  }

  method child which {
    switch $which {
      organs {
	# A library can be a project, it can be a module. Any
	# subordinate modules will indicate their existance
        return [list project [self] module [self]]
      }
    }
  }

  method linktype {} {
    return project
  }


  # Exercise the methods of a sub-object
  method project {pkg args} {
    set obj [namespace current]::PROJECT.$pkg
    if {[llength $args]==0} {
      return $obj
    }
    ${obj} {*}$args
  }


  method tclcore {} {
    if {[info commands [set obj [my organ tclcore]]] ne {}} {
      return $obj
    }
    if {[info commands [set obj [my project TCLCORE]]] ne {}} {
      my graft tclcore $obj
      return $obj
    }
    if {[info commands [set obj [my project tcl]]] ne {}} {
      my graft tclcore $obj
      return $obj
    }
    if {[info commands [set obj [my tool tcl]]] ne {}} {
      my graft tclcore $obj
      return $obj
    }
    # Provide a fallback
    set obj [my add_tool tcl {
      tag release class subproject.core
      fossil_url http://core.tcl.tk/tcl
    }]
    my graft tclcore $obj
    return $obj
  }

  method tkcore {} {
    if {[set obj [my organ tkcore]] ne {}} {
      return $obj
    }
    if {[set obj [my project tk]] ne {}} {
      my graft tkcore $obj
      return $obj
    }
    if {[set obj [my tool tk]] ne {}} {
      my graft tkcore $obj
      return $obj
    }
    # Provide a fallback
    set obj [my add_tool tk {
      tag release class tool.core
      fossil_url http://core.tcl.tk/tk
    }]
    my graft tkcore $obj
    return $obj
  }

  method tool {pkg args} {
    set obj ::practcl::OBJECT::TOOL.$pkg
    if {[llength $args]==0} {
      return $obj
    }
    ${obj} {*}$args
  }
}

###
# END: class project baseclass.tcl
###
###
# START: class project library.tcl
###

::oo::class create ::practcl::library {
  superclass ::practcl::project


  method clean {PATH} {
    set objext [my define get OBJEXT o]
    foreach {ofile info} [my project-compile-products] {
      if {[file exists [file join $PATH objs $ofile].${objext}]} {
        file delete [file join $PATH objs $ofile].${objext}
      }
    }
    foreach ofile [glob -nocomplain [file join $PATH *.${objext}]] {
      file delete $ofile
    }
    foreach ofile [glob -nocomplain [file join $PATH objs *]] {
      file delete $ofile
    }
    set libfile [my define get libfile]
    if {[file exists [file join $PATH $libfile]]} {
      file delete [file join $PATH $libfile]
    }
    my implement $PATH
  }

  method project-compile-products {} {
    set result {}
    foreach item [my link list subordinate] {
      lappend result {*}[$item project-compile-products]
    }
    set filename [my define get output_c]
    if {$filename ne {}} {
      ::practcl::debug [self] [self class] [self method] project-compile-products $filename
      set ofile [file rootname [file tail $filename]]_main
      lappend result $ofile [list cfile $filename extra [my define get extra] external [string is true -strict [my define get external]]]
    }
    return $result
  }


  method go {} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set name [my define getnull name]
    if {$name eq {}} {
      set name generic
      my define name generic
    }
    if {[my define get tk] eq {@TEA_TK_EXTENSION@}} {
      my define set tk 0
    }
    set output_c [my define getnull output_c]
    if {$output_c eq {}} {
      set output_c [file rootname $name].c
      my define set output_c $output_c
    }
    set output_h [my define getnull output_h]
    if {$output_h eq {}} {
      set output_h [file rootname $output_c].h
      my define set output_h $output_h
    }
    set output_tcl [my define getnull output_tcl]
    #if {$output_tcl eq {}} {
    #  set output_tcl [file rootname $output_c].tcl
    #  my define set output_tcl $output_tcl
    #}
    #set output_mk [my define getnull output_mk]
    #if {$output_mk eq {}} {
    #  set output_mk [file rootname $output_c].mk
    #  my define set output_mk $output_mk
    #}
    set initfunc [my define getnull initfunc]
    if {$initfunc eq {}} {
      set initfunc [string totitle $name]_Init
      my define set initfunc $initfunc
    }
    set output_decls [my define getnull output_decls]
    if {$output_decls eq {}} {
      set output_decls [file rootname $output_c].decls
      my define set output_decls $output_decls
    }
    my variable links
    foreach {linktype objs} [array get links] {
      foreach obj $objs {
        $obj go
      }
    }
    ::practcl::debug [list /[self] [self method] [self class] -- [my define get filename] [info object class [self]]]
  }


  method generate-decls {pkgname path} {
    ::practcl::debug [list [self] [self method] [self class] -- [my define get filename] [info object class [self]]]
    set outfile [file join $path/$pkgname.decls]

    ###
    # Build the decls file
    ## #
    set fout [open $outfile w]
    puts $fout [subst {###
  # $outfile
  #
  # This file was generated by [info script]
  ###

library $pkgname
interface $pkgname
}]

    ###
    # Generate list of functions
    ###
    set stubfuncts [my generate-stub-function]
    set thisline {}
    set functcount 0
    foreach {func header} $stubfuncts {
      puts $fout [list declare [incr functcount] $header]
    }
    puts $fout [list export "int [my define get initfunc](Tcl_Inter *interp)"]
    puts $fout [list export "char *[string totitle [my define get name]]_InitStubs(Tcl_Inter *interp, char *version, int exact)"]

    close $fout

    ###
    # Build [package]Decls.h
    ###
    set hout [open [file join $path ${pkgname}Decls.h] w]
    close $hout

    set cout [open [file join $path ${pkgname}StubInit.c] w]
    puts $cout [string map [list %pkgname% $pkgname %PkgName% [string totitle $pkgname]] {
#ifndef USE_TCL_STUBS
#define USE_TCL_STUBS
#endif
#undef USE_TCL_STUB_PROCS

#include "tcl.h"
#include "%pkgname%.h"

/*
** Ensure that Tdom_InitStubs is built as an exported symbol.  The other stub
** functions should be built as non-exported symbols.
*/

#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT

%PkgName%Stubs *%pkgname%StubsPtr;

 /*
 **----------------------------------------------------------------------
 **
 **  %PkgName%_InitStubs --
 **
 **        Checks that the correct version of %PkgName% is loaded and that it
 **        supports stubs. It then initialises the stub table pointers.
 **
 **  Results:
 **        The actual version of %PkgName% that satisfies the request, or
 **        NULL to indicate that an error occurred.
 **
 **  Side effects:
 **        Sets the stub table pointers.
 **
 **----------------------------------------------------------------------
 */

char *
%PkgName%_InitStubs (Tcl_Interp *interp, char *version, int exact)
{
  char *actualVersion;
  actualVersion = Tcl_PkgRequireEx(interp, "%pkgname%", version, exact,(ClientData *) &%pkgname%StubsPtr);
  if (!actualVersion) {
    return NULL;
  }
  if (!%pkgname%StubsPtr) {
    Tcl_SetResult(interp,"This implementation of %PkgName% does not support stubs",TCL_STATIC);
    return NULL;
  }
  return actualVersion;
}
}]
    close $cout
  }

  method implement path {
    my go
    my Collate_Source $path
    set errs {}
    foreach item [my link list dynamic] {
      if {[catch {$item implement $path} err errdat]} {
        lappend errs "Skipped $item: [$item define get filename] $err"
        if {[dict exists $errdat -errorinfo]} {
          lappend errs [dict get $errdat -errorinfo]
        } else {
          lappend errs $errdat
        }
      }
    }
    foreach item [my link list module] {
      if {[catch {$item implement $path} err errdat]} {
        lappend errs "Skipped $item: [$item define get filename] $err"
        if {[dict exists $errdat -errorinfo]} {
          lappend errs [dict get $errdat -errorinfo]
        } else {
          lappend errs $errdat
        }
      }
    }
    if {[llength $errs]} {
      set logfile [file join $::CWD practcl.log]
      ::practcl::log $logfile "*** ERRORS ***"
      foreach {item trace} $errs {
        ::practcl::log $logfile "###\n# ERROR\n###$item"
        ::practcl::log $logfile "###\n# TRACE\n###$trace"
      }
      ::practcl::log $logfile "*** DEBUG INFO ***"
      ::practcl::log $logfile $::DEBUG_INFO
      puts stderr "Errors saved to $logfile"
      exit 1
    }
    set cout [open [file join $path [my define get output_c]] w]
    puts $cout [subst {/*
** This file is generated by the [info script] script
** any changes will be overwritten the next time it is run
*/}]
    puts $cout [my generate-c]
    puts $cout [my generate-loader]
    close $cout

    set macro HAVE_[string toupper [file rootname [my define get output_h]]]_H
    set hout [open [file join $path [my define get output_h]] w]
    puts $hout [subst {/*
** This file is generated by the [info script] script
** any changes will be overwritten the next time it is run
*/}]
    puts $hout "#ifndef ${macro}"
    puts $hout "#define ${macro} 1"
    puts $hout [my generate-h]
    puts $hout "#endif"
    close $hout

    set output_tcl [my define get output_tcl]
    if {$output_tcl ne {}} {
      set tclout [open [file join $path [my define get output_tcl]] w]
      puts $tclout "###
# This file is generated by the [info script] script
# any changes will be overwritten the next time it is run
###"
      puts $tclout [my generate-tcl-pre]
      puts $tclout [my generate-tcl-loader]
      puts $tclout [my generate-tcl-post]
      close $tclout
    }
  }

  # Backward compadible call
  method generate-make path {
    my build-Makefile $path [self]
  }

  method linktype {} {
    return library
  }

  # Create a "package ifneeded"
  # Args are a list of aliases for which this package will answer to
  method package-ifneeded {args} {
    set result {}
    set name [my define get pkg_name [my define get name]]
    set version [my define get pkg_vers [my define get version]]
    if {$version eq {}} {
      set version 0.1a
    }
    set output_tcl [my define get output_tcl]
    if {$output_tcl ne {}} {
      set script "\[list source \[file join \$dir $output_tcl\]\]"
    } elseif {[string is true -strict [my define get SHARED_BUILD]]} {
      set script "\[list load \[file join \$dir [my define get libfile]\] $name\]"
    } else {
      # Provide a null passthrough
      set script "\[list package provide $name $version\]"
    }
    set result "package ifneeded [list $name] [list $version] $script"
    foreach alias $args {
      set script "package require $name $version \; package provide $alias $version"
      append result \n\n [list package ifneeded $alias $version $script]
    }
    return $result
  }


  method shared_library {{filename {}}} {
    set name [string tolower [my define get name [my define get pkg_name]]]
    set NAME [string toupper $name]
    set version [my define get version [my define get pkg_vers]]
    set map {}
    lappend map %LIBRARY_NAME% $name
    lappend map %LIBRARY_VERSION% $version
    lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $version]
    lappend map %LIBRARY_PREFIX% [my define getnull libprefix]
    set outfile [string map $map [my define get PRACTCL_NAME_LIBRARY]][my define get SHLIB_SUFFIX]
    return $outfile
  }

  method static_library {{filename {}}} {
    set name [string tolower [my define get name [my define get pkg_name]]]
    set NAME [string toupper $name]
    set version [my define get version [my define get pkg_vers]]
    set map {}
    lappend map %LIBRARY_NAME% $name
    lappend map %LIBRARY_VERSION% $version
    lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $version]
    lappend map %LIBRARY_PREFIX% [my define getnull libprefix]
    set outfile [string map $map [my define get PRACTCL_NAME_LIBRARY]].a
    return $outfile
  }
}

###
# END: class project library.tcl
###
###
# START: class project tclkit.tcl
###


::oo::class create ::practcl::tclkit {
  superclass ::practcl::library

  method build-tclkit_main {PROJECT PKG_OBJS} {
    ###
    # Build static package list
    ###
    set statpkglist {}
    foreach cobj [list {*}${PKG_OBJS} $PROJECT] {
      foreach {pkg info} [$cobj project-static-packages] {
        dict set statpkglist $pkg $info
      }
    }
    foreach {ofile info} [${PROJECT} project-compile-products] {
      if {![dict exists $info object]} continue
      set cobj [dict get $info object]
      foreach {pkg info} [$cobj project-static-packages] {
        dict set statpkglist $pkg $info
      }
    }

    set result {}
    $PROJECT include {<tcl.h>}
    $PROJECT include {"tclInt.h"}
    $PROJECT include {"tclFileSystem.h"}
    $PROJECT include {<assert.h>}
    $PROJECT include {<stdio.h>}
    $PROJECT include {<stdlib.h>}
    $PROJECT include {<string.h>}
    $PROJECT include {<math.h>}

    $PROJECT code header {
#ifndef MODULE_SCOPE
#   define MODULE_SCOPE extern
#endif

/*
** Provide a dummy Tcl_InitStubs if we are using this as a static
** library.
*/
#ifndef USE_TCL_STUBS
# undef  Tcl_InitStubs
# define Tcl_InitStubs(a,b,c) TCL_VERSION
#endif
#define STATIC_BUILD 1
#undef USE_TCL_STUBS

/* Make sure the stubbed variants of those are never used. */
#undef Tcl_ObjSetVar2
#undef Tcl_NewStringObj
#undef Tk_Init
#undef Tk_MainEx
#undef Tk_SafeInit
}

    # Build an area of the file for #define directives and
    # function declarations
    set define {}
    set mainhook   [$PROJECT define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook]
    set mainfunc   [$PROJECT define get TCL_LOCAL_APPINIT Tclkit_AppInit]
    set mainscript [$PROJECT define get main.tcl main.tcl]
    set vfsroot    [$PROJECT define get vfsroot "[$PROJECT define get ZIPFS_VOLUME]app"]
    set vfs_main "${vfsroot}/${mainscript}"

    set map {}
    foreach var {
      vfsroot mainhook mainfunc vfs_main
    } {
      dict set map %${var}% [set $var]
    }
    set preinitscript {
set ::odie(boot_vfs) %vfsroot%
set ::SRCDIR $::odie(boot_vfs)
if {[file exists [file join %vfsroot% tcl_library init.tcl]]} {
  set ::tcl_library [file join %vfsroot% tcl_library]
  set ::auto_path {}
}
if {[file exists [file join %vfsroot% tk_library tk.tcl]]} {
  set ::tk_library [file join %vfsroot% tk_library]
}
} ; # Preinitscript

    set zvfsboot {
/*
 * %mainhook% --
 * Performs the argument munging for the shell
 */
  }
    ::practcl::cputs zvfsboot {
  CONST char *archive;
  Tcl_FindExecutable(*argv[0]);
  archive=Tcl_GetNameOfExecutable();
}
    # We have to initialize the virtual filesystem before calling
    # Tcl_Init().  Otherwise, Tcl_Init() will not be able to find
    # its startup script files.
    if {![$PROJECT define get tip_430 0]} {
      # Add declarations of functions that tip430 puts in the stub files
      $PROJECT code public-header {
int TclZipfs_Init(Tcl_Interp *interp);
int TclZipfs_Mount(
    Tcl_Interp *interp,
    const char *mntpt,
    const char *zipname,
    const char *passwd
);
int TclZipfs_Mount_Buffer(
    Tcl_Interp *interp,
    const char *mntpt,
    unsigned char *data,
    size_t datalen,
    int copy
);
}
      ::practcl::cputs zvfsboot {  TclZipfs_Init(NULL);}
    }
    ::practcl::cputs zvfsboot "  if(!TclZipfs_Mount(NULL, \"app\", archive, NULL)) \x7B "
    ::practcl::cputs zvfsboot {
      Tcl_Obj *vfsinitscript;
      vfsinitscript=Tcl_NewStringObj("%vfs_main%",-1);
      Tcl_IncrRefCount(vfsinitscript);
      if(Tcl_FSAccess(vfsinitscript,F_OK)==0) {
        /* Startup script should be set before calling Tcl_AppInit */
        Tcl_SetStartupScript(vfsinitscript,NULL);
      }
    }
    ::practcl::cputs zvfsboot "    TclSetPreInitScript([::practcl::tcl_to_c $preinitscript])\;"
    ::practcl::cputs zvfsboot "  \x7D else \x7B"
    ::practcl::cputs zvfsboot "    TclSetPreInitScript([::practcl::tcl_to_c {
foreach path {../tcl} {
  set p  [file join $path library init.tcl]
  if {[file exists [file join $path library init.tcl]]} {
    set ::tcl_library [file normalize [file join $path library]]
    break
  }
}
foreach path {
  ../tk
} {
  if {[file exists [file join $path library tk.tcl]]} {
    set ::tk_library [file normalize [file join $path library]]
    break
  }
}
}])\;"
    ::practcl::cputs zvfsboot "  \x7D"
    ::practcl::cputs zvfsboot "  return TCL_OK;"

    if {[$PROJECT define get TEACUP_OS] eq "windows"} {
      set header {int %mainhook%(int *argc, TCHAR ***argv)}
    } else {
      set header {int %mainhook%(int *argc, char ***argv)}
    }
    $PROJECT c_function  [string map $map $header] [string map $map $zvfsboot]

    practcl::cputs appinit "int %mainfunc%(Tcl_Interp *interp) \x7B"

  # Build AppInit()
  set appinit {}
  practcl::cputs appinit {
  if ((Tcl_Init)(interp) == TCL_ERROR) {
      return TCL_ERROR;
  }

}
    if {![$PROJECT define get tip_430 0]} {
      ::practcl::cputs appinit {  TclZipfs_Init(interp);}
    }
    set main_init_script {}

    foreach {statpkg info} $statpkglist {
      set initfunc {}
      if {[dict exists $info initfunc]} {
        set initfunc [dict get $info initfunc]
      }
      if {$initfunc eq {}} {
        set initfunc [string totitle ${statpkg}]_Init
      }
      if {![dict exists $info version]} {
        error "$statpkg HAS NO VERSION"
      }
      # We employ a NULL to prevent the package system from thinking the
      # package is actually loaded into the interpreter
      $PROJECT code header "extern Tcl_PackageInitProc $initfunc\;\n"
      set script [list package ifneeded $statpkg [dict get $info version] [list ::load {} $statpkg]]
      append main_init_script \n [list set ::kitpkg(${statpkg}) $script]
      if {[dict get $info autoload]} {
        ::practcl::cputs appinit "  if(${initfunc}(interp)) return TCL_ERROR\;"
        ::practcl::cputs appinit "  Tcl_StaticPackage(interp,\"$statpkg\",$initfunc,NULL)\;"
      } else {
        ::practcl::cputs appinit "\n  Tcl_StaticPackage(NULL,\"$statpkg\",$initfunc,NULL)\;"
        append main_init_script \n $script
      }
    }
    append main_init_script \n {
if {[file exists [file join $::SRCDIR packages.tcl]]} {
  #In a wrapped exe, we don't go out to the environment
  set dir $::SRCDIR
  source [file join $::SRCDIR packages.tcl]
}
# Specify a user-specific startup file to invoke if the application
# is run interactively.  Typically the startup file is "~/.apprc"
# where "app" is the name of the application.  If this line is deleted
# then no user-specific startup file will be run under any conditions.
}
    append main_init_script \n [list set tcl_rcFileName [$PROJECT define get tcl_rcFileName ~/.tclshrc]]
    practcl::cputs appinit "  Tcl_Eval(interp,[::practcl::tcl_to_c  $main_init_script]);"
    practcl::cputs appinit {  return TCL_OK;}
    $PROJECT c_function [string map $map "int %mainfunc%(Tcl_Interp *interp)"] [string map $map $appinit]
  }

  method Collate_Source CWD {
    next $CWD
    set name [my define get name]
    # Assume a static shell
    if {[my define exists SHARED_BUILD]} {
      my define set SHARED_BUILD 0
    }
    if {![my define exists TCL_LOCAL_APPINIT]} {
      my define set TCL_LOCAL_APPINIT Tclkit_AppInit
    }
    if {![my define exists TCL_LOCAL_MAIN_HOOK]} {
      my define set TCL_LOCAL_MAIN_HOOK Tclkit_MainHook
    }
    set PROJECT [self]
    set os [$PROJECT define get TEACUP_OS]
    if {[my define get SHARED_BUILD]} {
      puts [list BUILDING TCLSH FOR OS $os]
    } else {
      puts [list BUILDING KIT FOR OS $os]
    }
    set TCLOBJ [$PROJECT tclcore]
    ::practcl::toolset select $TCLOBJ

    set TCLSRCDIR [$TCLOBJ define get srcdir]
    set PKG_OBJS {}
    foreach item [$PROJECT link list core.library] {
      if {[string is true [$item define get static]]} {
        lappend PKG_OBJS $item
      }
    }
    foreach item [$PROJECT link list package] {
      if {[string is true [$item define get static]]} {
        lappend PKG_OBJS $item
      }
    }
    # Arrange to build an main.c that utilizes TCL_LOCAL_APPINIT and TCL_LOCAL_MAIN_HOOK
    if {$os eq "windows"} {
      set PLATFORM_SRC_DIR win
      if {[my define get SHARED_BUILD]} {
        my add class csource filename [file join $TCLSRCDIR win tclWinReg.c] initfunc Registry_Init pkg_name registry pkg_vers 1.3.1 autoload 1
        my add class csource filename [file join $TCLSRCDIR win tclWinDde.c] initfunc Dde_Init pkg_name dde pkg_vers 1.4.0 autoload 1
      }
      my add class csource ofile [my define get name]_appinit.o filename [file join $TCLSRCDIR win tclAppInit.c] extra [list -DTCL_LOCAL_MAIN_HOOK=[my define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook] -DTCL_LOCAL_APPINIT=[my define get TCL_LOCAL_APPINIT Tclkit_AppInit]]
    } else {
      set PLATFORM_SRC_DIR unix
      my add class csource ofile [my define get name]_appinit.o filename [file join $TCLSRCDIR unix tclAppInit.c] extra [list -DTCL_LOCAL_MAIN_HOOK=[my define get TCL_LOCAL_MAIN_HOOK Tclkit_MainHook] -DTCL_LOCAL_APPINIT=[my define get TCL_LOCAL_APPINIT Tclkit_AppInit]]
    }

    if {[my define get SHARED_BUILD]} {
      ###
      # Add local static Zlib implementation
      ###
      set cdir [file join $TCLSRCDIR compat zlib]
      foreach file {
        adler32.c compress.c crc32.c
        deflate.c infback.c inffast.c
        inflate.c inftrees.c trees.c
        uncompr.c zutil.c
      } {
        my add [file join $cdir $file]
      }
    }
    ###
    # Pre 8.7, Tcl doesn't include a Zipfs implementation
    # in the core. Grab the one from odielib
    ###
    set zipfs [file join $TCLSRCDIR generic tclZipfs.c]
    if {![$PROJECT define exists ZIPFS_VOLUME]} {
      $PROJECT define set ZIPFS_VOLUME "zipfs:/"
    }
    $PROJECT code header "#define ZIPFS_VOLUME \"[$PROJECT define get ZIPFS_VOLUME]\""
    if {[file exists $zipfs]} {
      $TCLOBJ define set tip_430 1
      my define set tip_430 1
    } else {
      # The Tclconfig project maintains a mirror of the version
      # released with the Tcl core
      my define set tip_430 0
      ::practcl::LOCAL tool tclconfig unpack
      set COMPATSRCROOT [::practcl::LOCAL tool tclconfig define get srcdir]
      my add class csource ofile tclZipfs.o filename [file join $COMPATSRCROOT compat tclZipfs.c] extra -I[::practcl::file_relative $CWD [file join $TCLSRCDIR compat zlib contrib minizip]]
    }

    my define add include_dir [file join $TCLSRCDIR generic]
    my define add include_dir [file join $TCLSRCDIR $PLATFORM_SRC_DIR]
    # This file will implement TCL_LOCAL_APPINIT and TCL_LOCAL_MAIN_HOOK
    my build-tclkit_main $PROJECT $PKG_OBJS
  }

  ## Wrap an executable
  #
  method wrap {PWD exename vfspath args} {
    cd $PWD
    if {![file exists $vfspath]} {
      file mkdir $vfspath
    }
    foreach item [my link list core.library] {
      set name  [$item define get name]
      set libsrcdir [$item define get srcdir]
      if {[file exists [file join $libsrcdir library]]} {
        ::practcl::copyDir [file join $libsrcdir library] [file join $vfspath ${name}_library]
      }
    }
    # Assume the user will populate the VFS path
    #if {[my define get installdir] ne {}} {
    #  ::practcl::copyDir [file join [my define get installdir] [string trimleft [my define get prefix] /] lib] [file join $vfspath lib]
    #}
    foreach arg $args {
       ::practcl::copyDir $arg $vfspath
    }

    set fout [open [file join $vfspath packages.tcl] w]
    puts $fout [string map [list %platform% [my define get TEACUP_PROFILE]] {set ::tcl_teapot_profile {%platform%}}]
    puts $fout {
set ::PKGIDXFILE [info script]
set dir [file dirname $::PKGIDXFILE]
if {$::tcl_platform(platform) eq "windows"} {
  set ::g(HOME) [file join [file normalize $::env(LOCALAPPDATA)] tcl]
} else {
  set ::g(HOME) [file normalize ~/tcl]
}
set ::tcl_teapot [file join $::g(HOME) teapot $::tcl_teapot_profile]
lappend ::auto_path $::tcl_teapot
}
    puts $fout [list proc installDir [info args ::practcl::installDir] [info body ::practcl::installDir]]
    set buffer [::practcl::pkgindex_path $vfspath]
    puts $fout $buffer
    puts $fout {
# Advertise statically linked packages
foreach {pkg script} [array get ::kitpkg] {
  eval $script
}
}
    puts $fout {
###
# Cache binary packages distributed as dynamic libraries in a known location
###
foreach teapath [glob -nocomplain [file join $dir teapot $::tcl_teapot_profile *]] {
  set pkg [file tail $teapath]
  set pkginstall [file join $::tcl_teapot $pkg]
  if {![file exists $pkginstall]} {
    installDir $teapath $pkginstall
  }
}
}
    close $fout

    set EXEEXT [my define get EXEEXT]
    set tclkit_bare [my define get tclkit_bare]
    ::practcl::mkzip ${exename}${EXEEXT} $tclkit_bare $vfspath
    if { [my define get TEACUP_OS] ne "windows" } {
      file attributes ${exename}${EXEEXT} -permissions a+x
    }
  }
}

###
# END: class project tclkit.tcl
###
###
# START: class distro baseclass.tcl
###

###
# Standalone class to manage code distribution
# This class is intended to be mixed into another class
# (Thus the lack of ancestors)
###
oo::class create ::practcl::distribution {

  method scm_info {} {
    return {
      scm  None
      hash {}
      maxdate {}
      tags {}
      isodate {}
    }
  }
  
  method DistroMixIn {} {
    my define set scm none
  }

  method Sandbox {} {
    if {[my define exists sandbox]} {
      return [my define get sandbox]
    }
    if {[my organ project] ni {::noop {}}} {
      set sandbox [my <project> define get sandbox]
      if {$sandbox ne {}} {
        my define set sandbox $sandbox
        return $sandbox
      }
    }
    set sandbox [file normalize [file join $::CWD ..]]
    my define set sandbox $sandbox
    return $sandbox
  }

  method SrcDir {} {
    set pkg [my define get name]
    if {[my define exists srcdir]} {
      return [my define get srcdir]
    }
    set sandbox [my Sandbox]
    set srcdir [file join [my Sandbox] $pkg]
    my define set srcdir $srcdir
    return $srcdir
  }

  method ScmTag    {} {}
  method ScmClone  {} {}
  method ScmUnpack {} {}
  method ScmUpdate {} {}

  method Unpack {} {
    set srcdir [my SrcDir]
    if {[file exists $srcdir]} {
      return
    }
    set pkg [my define get name]
    if {[my define exists download]} {
      # Utilize a staged download
      set download [my define get download]
      if {[file exists [file join $download $pkg.zip]]} {
        ::practcl::tcllib_require zipfile::decode
        ::zipfile::decode::unzipfile [file join $download $pkg.zip] $srcdir
        return
      }
    }
    my ScmUnpack
  }
}

oo::objdefine ::practcl::distribution {

  method Sandbox {object} {
    if {[$object define exists sandbox]} {
      return [$object define get sandbox]
    }
    if {[$object organ project] ni {::noop {}}} {
      set sandbox [$object <project> define get sandbox]
      if {$sandbox ne {}} {
        $object define set sandbox $sandbox
        return $sandbox
      }
    }
    set pkg [$object define get name]
    set sandbox [file normalize [file join $::CWD ..]]
    $object define set sandbox $sandbox
    return $sandbox
  }

  method select object {
    if {[$object define exists scm]} {
      return [$object define get scm]
    }

    set pkg [$object define get name]
    if {[$object define get srcdir] ne {}} {
      set srcdir [$object define get srcdir]
    } else {
      set srcdir [file join [my Sandbox $object] $pkg]
      $object define set srcdir $srcdir
    }

    set classprefix ::practcl::distribution.
    if {[file exists $srcdir]} {
      foreach class [::info commands ${classprefix}*] {
        if {[$class claim_path $srcdir]} {
          $object mixin distribution $class
          $object define set scm [string range $class [string length ::practcl::distribution.] end]
          return [$object define get scm]
        }
      }
    }
    foreach class [::info commands ${classprefix}*] {
      if {[$class claim_object $object]} {
        $object mixin distribution $class
        $object define set scm [string range $class [string length ::practcl::distribution.] end]
        return [$object define get scm]
      }
    }
    if {[$object define get scm] eq {} && [$object define exists file_url]} {
      set class ::practcl::distribution.snapshot
      $object define set scm snapshot
      $object mixin distribution $class
      return [$object define get scm]
    }
    error "Cannot determine source distribution method"
  }

  method claim_path path {
    return false
  }
  method claim_object object {
    return false
  }
}

###
# END: class distro baseclass.tcl
###
###
# START: class distro snapshot.tcl
###

oo::class create ::practcl::distribution.snapshot {
  superclass ::practcl::distribution

  method ScmUnpack {} {
    set srcdir [my SrcDir]
    if {[file exists [file join $srcdir .download]]} {
      return 0
    }
    set dpath [::practcl::LOCAL define get download]
    set url [my define get file_url]
    set fname [file tail $url]
    set archive [file join $dpath $fname]
    if {![file exists $archive]} {
      ::http::wget $url $archive
    }
    set CWD [pwd]
    switch [file extension $fname] {
      .zip {
        # Zipfile

      }
      .tar {
        ::practcl::tcllib_require tar
      }
      .tgz -
      .gz {
        # Tarball
        ::practcl::tcllib_require tcl::transform::zlib
        ::practcl::tcllib_require tar
        set fh [::open $archive]
        fconfigure $fh -encoding binary -translation lf -eofchar {}
        ::tcl::transform::zlib $fh
      }
    }
    set fosdb [my ScmClone]
    set tag [my ScmTag]
    file mkdir $srcdir
    ::practcl::fossil $srcdir open $fosdb $tag
    return 1
  }
}

oo::objdefine ::practcl::distribution.snapshot {
  method claim_path path {
    if {[file exists [file join $path .download]]} {
      return true
    }
    return false
  }
  method claim_object object {
    return false
  }
}

###
# END: class distro snapshot.tcl
###
###
# START: class distro fossil.tcl
###

oo::class create ::practcl::distribution.fossil {
  superclass ::practcl::distribution

  method scm_info {} {
    set info [next]
    dict set info scm fossil
    foreach {field value} [::practcl::fossil_status [my define get srcdir]] {
      dict set info $field $value
    }
    return $info
  }
  
  # Clone the source
  method ScmClone  {} {
    set srcdir [my SrcDir]
    if {[file exists [file join $srcdir .fslckout]]} {
      return
    }
    if {[file exists [file join $srcdir _FOSSIL_]]} {
      return
    }
    if {![::info exists ::practcl::fossil_dbs]} {
      # Get a list of local fossil databases
      set ::practcl::fossil_dbs [exec fossil all list]
    }
    set pkg [my define get name]
    # Return an already downloaded fossil repo
    foreach line [split $::practcl::fossil_dbs \n] {
      set line [string trim $line]
      if {[file rootname [file tail $line]] eq $pkg} {
        return $line
      }
    }
    set download [::practcl::LOCAL define get download]
    set fosdb [file join $download $pkg.fos]
    if {[file exists $fosdb]} {
      return $fosdb
    }

    file mkdir [file join $download fossil]
    set fosdb [file join $download fossil $pkg.fos]
    if {[file exists $fosdb]} {
      return $fosdb
    }

    set cloned 0
    # Attempt to clone from a local network mirror
    if {[::practcl::LOCAL define exists fossil_mirror]} {
      set localmirror [::practcl::LOCAL define get fossil_mirror]
      catch {
        ::practcl::doexec fossil clone $localmirror/$pkg $fosdb
        set cloned 1
      }
      if {$cloned} {
        return $fosdb
      }
    }
    # Attempt to clone from the canonical source
    if {[my define get fossil_url] ne {}} {
      catch {
        ::practcl::doexec fossil clone [my define get fossil_url] $fosdb
        set cloned 1
      }
      if {$cloned} {
        return $fosdb
      }
    }
    # Fall back to the fossil mirror on the island of misfit toys
    ::practcl::doexec fossil clone http://fossil.etoyoc.com/fossil/$pkg $fosdb
    return $fosdb
  }

  method ScmTag {} {
    if {[my define exists scm_tag]} {
      return [my define get scm_tag]
    }
    if {[my define exists tag]} {
      set tag [my define get tag]
    } else {
      set tag trunk
    }
    my define set scm_tag $tag
    return $tag
  }

  method ScmUnpack {} {
    set srcdir [my SrcDir]
    if {[file exists [file join $srcdir .fslckout]]} {
      return 0
    }
    if {[file exists [file join $srcdir _FOSSIL_]]} {
      return 0
    }
    set CWD [pwd]
    set fosdb [my ScmClone]
    set tag [my ScmTag]
    file mkdir $srcdir
    ::practcl::fossil $srcdir open $fosdb $tag
    return 1
  }

  method ScmUpdate {} {
    if {[my ScmUnpack]} {
      return
    }
    set srcdir [my SrcDir]
    set tag [my ScmTag]
    ::practcl::fossil $srcdir update $tag
  }
}

oo::objdefine ::practcl::distribution.fossil {

  # Check for markers in the source root
  method claim_path path {
    if {[file exists [file join $path .fslckout]]} {
      return true
    }
    if {[file exists [file join $path _FOSSIL_]]} {
      return true
    }
    return false
  }

  # Check for markers in the metadata
  method claim_object obj {
    set path [$obj define get srcdir]
    if {[my claim_path $path]} {
      return true
    }
    if {[$obj define get fossil_url] ne {}} {
      return true
    }
    return false
  }
}

###
# END: class distro fossil.tcl
###
###
# START: class distro git.tcl
###


oo::class create ::practcl::distribution.git {
  superclass ::practcl::distribution

  method ScmTag {} {
    if {[my define exists scm_tag]} {
      return [my define get scm_tag]
    }
    if {[my define exists tag]} {
      set tag [my define get tag]
    } else {
      set tag master
    }
    my define set scm_tag $tag
    return $tag
  }

  method ScmUnpack {} {
    set srcdir [my SrcDir]
    if {[file exists [file join $srcdir .git]]} {
      return 0
    }
    set CWD [pwd]
    set tag [my ScmTag]
    set pkg [my define get name]
    if {[my define exists git_url]} {
      ::practcl::doexec git clone --branch $tag [my define get git_url] $srcdir
    } else {
      ::practcl::doexec git clone --branch $tag https://github.com/eviltwinskippy/$pkg $srcdir
    }
    return 1
  }

  method ScmUpdate {} {
    if {[my ScmUnpack]} {
      return
    }
    set CWD [pwd]
    set srcdir [my SrcDir]
    set tag [my ScmTag]
    ::practcl::doexec_in $srcdir git pull
    cd $CWD
  }

}
oo::objdefine ::practcl::distribution.git {
  method claim_path path {
   if {[file exists [file join $path .git]]} {
      return true
    }
    return false
  }
  method claim_object obj {
    set path [$obj define get srcdir]
    if {[my claim_path $path]} {
      return true
    }
    if {[$obj define get git_url] ne {}} {
      return true
    }
    return false
  }
}

###
# END: class distro git.tcl
###
###
# START: class subproject baseclass.tcl
###
oo::class create ::practcl::subproject {
  superclass ::practcl::module

  method _MorphPatterns {} {
    return {{::practcl::subproject.@name@} {::practcl::@name@} {@name@} {::practcl::subproject}}
  }
  
  
  method BuildDir {PWD} {
    return [my define get srcdir]
  }
  
  method child which {
    switch $which {
      organs {
	# A library can be a project, it can be a module. Any
	# subordinate modules will indicate their existance
        return [list project [self] module [self]]
      }
    }
  }

  method compile {} {}


  method go {} {
    ::practcl::distribution select [self]
    set name [my define get name]
    my define set builddir [my BuildDir [my define get masterpath]]
    my define set builddir [my BuildDir [my define get masterpath]]
    my sources
  }

  # Install project into the local build system
  method install args {}

  method linktype {} {
    return {subordinate package}
  }

  method linker-products {configdict} {}

  method linker-external {configdict} {
    if {[dict exists $configdict PRACTCL_PKG_LIBS]} {
      return [dict get $configdict PRACTCL_PKG_LIBS]
    }
    if {[dict exists $configdict LIBS]} {
      return [dict get $configdict LIBS]
    }
  }

  method linker-extra {configdict} {
    if {[dict exists $configdict PRACTCL_LINKER_EXTRA]} {
      return [dict get $configdict PRACTCL_LINKER_EXTRA]
    }
    return {}
  }

  ###
  # Methods for packages/tools that can be downloaded
  # possibly built and used internally by this Practcl
  # process
  ###

  ###
  # Load the facility into the interpreter
  ###
  method env-bootstrap {} {
    set pkg [my define get pkg_name [my define get name]]
    package require $pkg
  }

  ###
  # Return a file path that exec can call
  ###
  method env-exec {} {}

  ###
  # Install the tool into the local environment
  ###
  method env-install {} {
    my unpack
  }

  ###
  # Do whatever is necessary to get the tool
  # into the local environment
  ###
  method env-load {} {
    my variable loaded
    if {[info exists loaded]} {
      return 0
    }
    if {![my env-present]} {
      my env-install
    }
    my env-bootstrap
    set loaded 1
  }

  ###
  # Check if tool is available for load/already loaded
  ###
  method env-present {} {
    set pkg [my define get pkg_name [my define get name]]
    if {[catch [list package require $pkg]]} {
      return 0
    }
    return 1
  }

  method sources {} {}

  method update {} {
    my ScmUpdate
  }

  method unpack {} {
    ::practcl::distribution select [self]
    my Unpack
    ::practcl::toolset select [self]
  }
}

###
# Trivial implementations
###


###
# A project which the kit compiles and integrates
# the source for itself
###
oo::class create ::practcl::subproject.source {
  superclass ::practcl::subproject ::practcl::library

  method env-bootstrap {} {
    set LibraryRoot [file join [my define get srcdir] [my define get module_root modules]]
    if {[file exists $LibraryRoot] && $LibraryRoot ni $::auto_path} {
      set ::auto_path [linsert $::auto_path 0 $LibraryRoot]
    }
  }

  method env-present {} {
    set path [my define get srcdir]
    return [file exists $path]
  }

  method linktype {} {
    return {subordinate package source}
  }

}

# a copy from the teapot
oo::class create ::practcl::subproject.teapot {
  superclass ::practcl::subproject

  method env-bootstrap {} {
    set pkg [my define get pkg_name [my define get name]]
    package require $pkg
  }

  method env-install {} {
    set pkg [my define get pkg_name [my define get name]]
    set download [my <project> define get download]
    my unpack
    set prefix [string trimleft [my <project> define get prefix] /]
    ::practcl::tcllib_require zipfile::decode
    ::zipfile::decode::unzipfile [file join $download $pkg.zip] [file join $prefix lib $pkg]
  }

  method env-present {} {
    set pkg [my define get pkg_name [my define get name]]
    if {[catch [list package require $pkg]]} {
      return 0
    }
    return 1
  }

  method install DEST {
    set pkg [my define get pkg_name [my define get name]]
    set download [my <project> define get download]
    my unpack
    set prefix [string trimleft [my <project> define get prefix] /]
    ::practcl::tcllib_require zipfile::decode
    ::zipfile::decode::unzipfile [file join $download $pkg.zip] [file join $DEST $prefix lib $pkg]
  }
}

oo::class create ::practcl::subproject.kettle {
  superclass ::practcl::subproject

  method kettle {path args} {
    my variable kettle
    if {![info exists kettle]} {
      ::practcl::LOCAL tool kettle env-load
      set kettle [file join [::practcl::LOCAL tool kettle define get srcdir] kettle]
    }
    set srcdir [my SourceRoot]
    ::practcl::dotclexec $kettle -f [file join $srcdir build.tcl] {*}$args
  }

  method install DEST {
    my kettle reinstall --prefix $DEST
  }
}

oo::class create ::practcl::subproject.critcl {
  superclass ::practcl::subproject

  method install DEST {
    my critcl -pkg [my define get name]
    set srcdir [my SourceRoot]
    ::practcl::copyDir [file join $srcdir [my define get name]] [file join $DEST lib [my define get name]]
  }
}


oo::class create ::practcl::subproject.sak {
  superclass ::practcl::subproject

  method env-bootstrap {} {
    set LibraryRoot [file join [my define get srcdir] [my define get module_root modules]]
    if {[file exists $LibraryRoot] && $LibraryRoot ni $::auto_path} {
      set ::auto_path [linsert $::auto_path 0 $LibraryRoot]
    }
  }

  method env-install {} {
    ###
    # Handle teapot installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    my unpack
    set prefix [my <project> define get prefix [file normalize [file join ~ tcl]]]
    set srcdir [my define get srcdir]
    ::practcl::dotclexec [file join $srcdir installer.tcl] \
      -apps -app-path [file join $prefix apps] \
      -html -html-path [file join $prefix doc html $pkg] \
      -pkg-path [file join $prefix lib $pkg]  \
      -no-nroff -no-wait -no-gui
  }

  method env-present {} {
    set path [my define get srcdir]
    return [file exists $path]
  }

  method install DEST {
    ###
    # Handle teapot installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    my unpack
    set prefix [string trimleft [my <project> define get prefix] /]
    set srcdir [my define get srcdir]
    ::practcl::dotclexec [file join $srcdir installer.tcl] \
      -pkg-path [file join $DEST $prefix lib $pkg]  \
      -no-examples -no-html -no-nroff \
      -no-wait -no-gui -no-apps
  }
}

###
# END: class subproject baseclass.tcl
###
###
# START: class subproject binary.tcl
###

###
# A binary package
###
oo::class create ::practcl::subproject.binary {
  superclass ::practcl::subproject

  method clean {} {
    set builddir [file normalize [my define get builddir]]
    if {![file exists $builddir]} return
    if {[file exists [file join $builddir make.tcl]]} {
      ::practcl::domake.tcl $builddir clean
    } else {
      catch {::practcl::domake $builddir clean}
    }
  }

 method env-install {} {
    ###
    # Handle tea installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    set os [::practcl::local_os]
    my define set os $os
    my unpack
    set prefix [my <project> define get prefix [file normalize [file join ~ tcl]]]
    set srcdir [my define get srcdir]
    lappend options --prefix $prefix --exec-prefix $prefix
    my define set config_opts $options
    my go
    my clean
    my compile
    my make-install {}
  }

  method project-compile-products {} {}

  method ComputeInstall {} {
    if {[my define exists install]} {
      switch [my define get install] {
        static {
          my define set static 1
          my define set autoload 0
        }
        static-autoload {
          my define set static 1
          my define set autoload 1
        }
        vfs {
          my define set static 0
          my define set autoload 0
          my define set vfsinstall 1
        }
        null {
          my define set static 0
          my define set autoload 0
          my define set vfsinstall 0
        }
        default {

        }
      }
    }
  }

  method go {} {
    next
    ::practcl::distribution select [self]
    my ComputeInstall
    my define set builddir [my BuildDir [my define get masterpath]]
  }

  method linker-products {configdict} {
    if {![my define get static 0]} {
      return {}
    }
    set srcdir [my define get builddir]
    if {[dict exists $configdict libfile]} {
      return " [file join $srcdir [dict get $configdict libfile]]"
    }
  }

  method project-static-packages {} {
    if {![my define get static 0]} {
      return {}
    }
    set result [my define get static_packages]
    set statpkg  [my define get static_pkg]
    set initfunc [my define get initfunc]
    if {$initfunc ne {}} {
      set pkg_name [my define get pkg_name]
      if {$pkg_name ne {}} {
        dict set result $pkg_name initfunc $initfunc
        set version [my define get version]
        if {$version eq {}} {
          my unpack
          set info [my read_configuration]
          set version [dict get $info version]
          set pl {}
          if {[dict exists $info patch_level]} {
            set pl [dict get $info patch_level]
            append version $pl
          }
          my define set version $version
        }
        dict set result $pkg_name version $version
        dict set result $pkg_name autoload [my define get autoload 0]
      }
    }
    foreach item [my link list subordinate] {
      foreach {pkg info} [$item project-static-packages] {
        dict set result $pkg $info
      }
    }
    return $result
  }

  method BuildDir {PWD} {
    set name [my define get name]
    set debug [my define get debug 0]
    if {[my <project> define get LOCAL 0]} {
      return [my define get builddir [file join $PWD local $name]]
    }
    if {$debug} {
      return [my define get builddir [file join $PWD debug $name]]
    } else {
      return [my define get builddir [file join $PWD pkg $name]]
    }
  }

  method compile {} {
    set name [my define get name]
    set PWD $::CWD
    cd $PWD
    my unpack
    set srcdir [file normalize [my SrcDir]]
    set localsrcdir [my MakeDir $srcdir]
    my define set localsrcdir $localsrcdir
    my Collate_Source $PWD
    ###
    # Build a starter VFS for both Tcl and wish
    ###
    set srcdir [my define get srcdir]
    if {[my define get static 1]} {
      puts "BUILDING Static $name $srcdir"
    } else {
      puts "BUILDING Dynamic $name $srcdir"
    }
    my make-compile
    cd $PWD
  }

  method Configure {} {
    cd $::CWD
    my unpack
    ::practcl::toolset select [self]
    set srcdir [file normalize [my define get srcdir]]
    set builddir [file normalize [my define get builddir]]
    file mkdir $builddir
    my make-autodetect
  }

  method install DEST {
    set PWD [pwd]
    set PREFIX  [my <project> define get prefix]
    ###
    # Handle teapot installs
    ###
    set pkg [my define get pkg_name [my define get name]]
    if {[my <project> define get teapot] ne {}} {
      set TEAPOT [my <project> define get teapot]
      set found 0
      foreach ver [my define get pkg_vers [my define get version]] {
        set teapath [file join $TEAPOT $pkg$ver]
        if {[file exists $teapath]} {
          set dest  [file join $DEST [string trimleft $PREFIX /] lib [file tail $teapath]]
          ::practcl::copyDir $teapath $dest
          return
        }
      }
    }
    my compile
    my make-install $DEST
    cd $PWD
  }
}

oo::class create ::practcl::subproject.tea {
  superclass ::practcl::subproject.binary

}

oo::class create ::practcl::subproject.library {
  superclass ::practcl::subproject.binary ::practcl::library
  method install DEST {
    my compile
  }
}

# An external library
oo::class create ::practcl::subproject.external {
  superclass ::practcl::subproject.binary
  method install DEST {
    my compile
  }
}

###
# END: class subproject binary.tcl
###
###
# START: class subproject core.tcl
###

oo::class create ::practcl::subproject.core {
  superclass ::practcl::subproject.binary

  method env-bootstrap {} {}

  method env-present {} {
    set PREFIX [my <project> define get prefix]
    set name [my define get name]
    set fname [file join $PREFIX lib ${name}Config.sh]
    return [file exists $fname]
  }

  method env-install {} {
    my unpack
    set os [::practcl::local_os]

    set prefix [my <project> define get prefix [file normalize [file join ~ tcl]]]
    lappend options --prefix $prefix --exec-prefix $prefix
    my define set config_opts $options
    puts [list [self] OS [dict get $os TEACUP_OS] options $options]
    my go
    my compile
    my make-install {}
  }

  method go {} {
    my define set core_binary 1
    next
  }

  method linktype {} {
    return {subordinate core.library}
  }
}

###
# END: class subproject core.tcl
###
###
# START: class tool.tcl
###
###
# Create an object to represent the local environment
###
set ::practcl::MAIN ::practcl::LOCAL
# Defer the creation of the ::practcl::LOCAL object until it is called
# in order to allow packages to
set ::auto_index(::practcl::LOCAL) {
  ::practcl::project create ::practcl::LOCAL
  ::practcl::LOCAL define set [::practcl::local_os]
  ::practcl::LOCAL define set LOCAL 1

  # Until something better comes along, use ::practcl::LOCAL
  # as our main project
  # Add tclconfig as a project of record
  ::practcl::LOCAL add_tool tclconfig {
    name tclconfig tag practcl class subproject.source fossil_url http://core.tcl.tk/tclconfig
  }
  # Add tcllib as a project of record
  ::practcl::LOCAL add_tool tcllib {
    tag trunk class sak fossil_url http://core.tcl.tk/tcllib
  }
  ::practcl::LOCAL add_tool kettle {
    tag trunk class sak fossil_url http://fossil.etoyoc.com/fossil/kettle
  }
  ::practcl::LOCAL add_tool tclvfs {
    tag trunk class tea
    fossil_url http://fossil.etoyoc.com/fossil/tclvfs
  }
  ::practcl::LOCAL add_tool critcl {
    tag master class subproject.binary
    git_url http://github.com/andreas-kupries/critcl
    modules lib
  } {
    method env-bootstrap {} {
      package require critcl::app
    }
    method env-install {} {
      my unpack
      set prefix [my <project> define get prefix [file join [file normalize ~] tcl]]
      set srcdir [my define get srcdir]
      ::practcl::dotclexec [file join $srcdir build.tcl] install [file join $prefix lib]
    }
  }
  ::practcl::LOCAL add_tool odie {
    tag trunk class subproject.source
    fossil_url http://fossil.etoyoc.com/fossil/odie
  }
  ::practcl::LOCAL add_tool tcl {
    tag release class subproject.core
    fossil_url http://core.tcl.tk/tcl
  }
  ::practcl::LOCAL add_tool tk {
    tag release class subproject.core
    fossil_url http://core.tcl.tk/tcl
  }
  ::practcl::LOCAL add_tool sqlite {
    tag practcl
    class subproject.tea
    pkg_name sqlite3
    fossil_url http://fossil.etoyoc.com/fossil/sqlite
  }
}

###
# END: class tool.tcl
###

namespace eval ::practcl {
  namespace export *
}

