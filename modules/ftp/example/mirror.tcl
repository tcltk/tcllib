#!/usr/local/bin/tclsh8.0

package require FTP 1.2

# user configuration
set server noname
set username anonymous
set passwd xxxxxx 

# simple progress display
proc ProgressBar {bytes} {
    puts -nonewline stdout "."; flush stdout
}

# recursive file transfer 
proc GetTree {{dir ""}} {
    catch {file mkdir $dir}
    foreach line [FTP::List $dir] {
    	set rc [scan $line "%s %s %s %s %s %s %s %s %s %s %s" \
            perm l u g size d1 d2 d3 name link linksource]
	if { ($name == ".") || ($name == "..") } {continue}
        set type [string range $perm 0 0]
        set name [file join $dir $name]
        switch -- $type {
            d {GetTree $name}
            l {catch {exec ln -s $linksource $name} msg}
            - {FTP::Get $name}
        }
    }
}

# main	
if [FTP::Open $server $username $passwd -progress ProgressBar] {
    GetTree
    FTP::Close 
    puts "OK!"
}

