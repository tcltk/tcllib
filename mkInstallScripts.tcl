# Simple Tcl script that produces install scripts for tcllib for Windows
# (INSTALL.BAT) and Unix (install.sh).
# Arguments list:
#	outdir
#	package
#	version
#	module module module module

set outdir  [lindex $argv 0]
set package [lindex $argv 1]
set version [lindex $argv 2]
set modules [lrange $argv 3 end]
	
# Make an INSTALL.BAT for Windows
#

set f [open [file join $outdir INSTALL.BAT] w]
puts  $f "@echo off"
puts  $f "set TCLINSTALL=C:\\Progra~1\\Tcl"
puts  $f "mkdir %TCLINSTALL%\\lib\\$package$version"
puts  $f "copy pkgIndex.tcl %TCLINSTALL%\\lib\\$package$version"
puts  $f "xcopy .\\doc\\html\\*.* %TCLINSTALL%\\lib\\$package$version\\doc /E /S /I /Q /C"
puts  $f "cd modules"
puts  $f "for %%f in ($modules) do xcopy .\\%%f\\*.* %TCLINSTALL%\\lib\\$package$version\\%%f /E /S /I /Q /C"
close $f

# Make an install.sh for Unix
#

set installFile [file join $outdir install.sh]
set f [open $installFile w]
puts $f "#!/bin/sh"
puts $f "TCLINSTALL=\$1"
puts $f "if \[ \"\${TCLINSTALL\}x\" = \"x\" \] ; then \\"
puts $f "   TCLINSTALL=/usr/local"
puts $f "fi"
puts $f "here=`pwd`"
puts $f "cd \$TCLINSTALL"
puts $f "TCLINSTALL=`pwd`"
puts $f "cd \$here"
puts $f "echo Installing $package $version to \$TCLINSTALL"
puts $f "if \[ ! -d \$TCLINSTALL/lib/$package$version \] ; then \\"
puts $f "    mkdir -p \$TCLINSTALL/lib/$package$version ; \\"
puts $f "fi"
puts $f "if \[ ! -d \$TCLINSTALL/man/mann \] ; then \\"
puts $f "    mkdir -p \$TCLINSTALL/man/mann ; \\"
puts $f "fi"
puts $f "if \[ ! -d \$TCLINSTALL/lib/$package$version/htmldoc \] ; then \\"
puts $f "    mkdir -p \$TCLINSTALL/lib/$package$version/htmldoc ; \\"
puts $f "fi"
puts $f "cp -f pkgIndex.tcl    \$TCLINSTALL/lib/$package$version"
puts $f "cp -f doc/nroff/*.n   \$TCLINSTALL/man/mann                     2> /dev/null ; \\"
puts $f "cp -f doc/html/*.html \$TCLINSTALL/lib/$package$version/htmldoc 2> /dev/null ; \\"
puts $f "cd modules"
puts $f "for j in $modules ; do \\"
puts $f "    if \[ ! -d \$TCLINSTALL/lib/$package$version/\$j \] ; then \\"
puts $f "        mkdir \$TCLINSTALL/lib/$package$version/\$j ; \\"
puts $f "    fi; \\"
puts $f "    cp -f \$j/*.tcl    \$TCLINSTALL/lib/$package$version/\$j 2>/dev/null; \\"
puts $f "    if \[ -f \$j/tclIndex \] ; then \\"
puts $f "        cp -f \$j/tclIndex \$TCLINSTALL/lib/$package$version/\$j ; \\"
puts $f "    fi ; \\"
puts $f "done"
puts $f "## Module specific installation code"
puts $f "#  1. doctools: message catalogs and predefined formatting engines."
puts $f "mkdir \$TCLINSTALL/lib/$package$version/doctools/mpformats"
puts $f "cp -f doctools/mpformats/* \$TCLINSTALL/lib/$package$version/doctools/mpformats 2>/dev/null; \\"
puts $f "#  2. textutil: hyphenation files"
puts $f "cp -f textutil/*.tex    \$TCLINSTALL/lib/$package$version/textutil 2>/dev/null; \\"


close $f

switch -exact $::tcl_platform(platform) {
    unix {
	file attributes $installFile -permissions 0755
    }
    windows {
	file attributes $installFile -readonly 1
    }
}
