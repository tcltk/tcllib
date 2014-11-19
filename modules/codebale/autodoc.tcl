package provide codebale::autodoc 0.1

::namespace eval ::codebale {}

::namespace eval ::codebale::doctools {}

###
# topic: 07388c9cf3874e1c0ce049e07be8a5b7
###
proc ::codebale::autodoc {info args} {
  ###
  # This script parses through TCL files
  # and systematically adds template entries
  # for the auto-documenter, and captures
  # any information filled out for the
  # auto-documenter to ../lib/classes.rc
  ###
  package require md5
  package require sqlite3
  package require tao-sqlite
  if {[dict exists $info local-root:]} {
    set base [dict get $info local-root:]
  } elseif {[dict exists $info base]} {
    set base [dict get $info base]
  } else {
    #set base [file normalize [file join [file dirname [info script]] ..]]
    set base [pwd]
  }
  if {![dict exists $info rewrite]} {
    dict set info rewrite 0
  }
  if {![dict exists $info repo]} {
    dict set info repo [file tail $base]
  }
  
  ###
  # Build a database file
  ###
  set docfile [file join $base helpdoc.sqlite]
  set exists [file exists $docfile]
  tao.yggdrasil create ::helpdoc $docfile

  if {!$exists} {
    set rcfile [file join $base helpdoc.rc]
    if {[file exists $rcfile]} {
      source $rcfile
      #helpdoc eval {update file set hash=NULL}
    }
  }

  set pathlist {}
  if {[llength $args]} {
    #helpdoc eval {update file set hash=NULL}
    foreach path $args {
      lappend pathlist [file join $base $path]
    }
  } else {
    foreach path {src lib modules} {
      lappend pathlist [file join $base $path]
    }
  }
  ::codebale::parse_path $info $base {*}$pathlist
  ::codebale::meta_output $base/helpdoc.rc
}

###
# topic: 8dec84ee6bf00a39a72d93510d94354d
###
proc ::codebale::doctools::cmdout {cmdname info} {
  set buffer "\[call \[method $cmdname\]"
  if {[dict exists $info darglist]} {
    puts [list darglist [dict get $info darglist]]
    append buffer " [dict get $info darglist]" \n
  } elseif {[dict exists $info arglist]} {
    foreach arg [dict get $info arglist] {
      if {[string index $arg 0] eq "-"} {
        append buffer " \[opt \[option \"$arg\"\]\]"
      } elseif {[string index $arg 0] eq "?"} {
        append buffer " \[opt \[arg \"[string trim $arg ?]\"\]\]"
      } else {
        append buffer " \[arg \"$arg\"\]"
      }
    }
  }
  append buffer "\]\n"
  return $buffer
}

###
# topic: 537b338abcd70051ec54a930ad13e599
###
proc ::codebale::doctools::maketoc base {
  set lastmodule {}
  set idx [string length $::odielib(srcroot)]
  helpdoc eval {
drop table if exists contents;
CREATE TABLE contents (
  filename primary key,
  module string,
  category string,
  label string unique,
  title text
);
}
  cd $base
  foreach file [lsort -dictionary [::fileutil::find [file join $::odielib(srcroot) doc doctool]]] {
    if {[file extension $file] != ".man"} continue
    set module [file tail [file dirname $file]]
    set fname [string range $file $idx+1 end]
    set label [file rootname [file tail $file]]
    set info [lindex [manpage_meta $module $fname] 1]
    set category {}
    puts $fname
    puts $info
    puts {}
    dict with info {}
    puts [list $fname $module $category $fid $desc]
    helpdoc eval {      
insert into contents(filename,module,category,label,title)
VALUES (:fname,:module,:category,:fid,:desc);}
  }

  set fout   [open [file join $base toc.txt] w]
  puts $fout {[toc_begin {Table Of Contents} {}]}
  puts $fout {[division_start Modules]}
  puts $fout {[division_start null]}
  set priormodule {}
  set priorcat    {}
  ::helpdoc eval {select * from contents order by module,title} {
    if { $priormodule != $module } {
      puts $fout {[division_end]}
      puts $fout "\[division_start $module\]"

    }
    puts $fout "\[[list item $filename $label $title]\]"
    set priormodule $module
  }
  puts $fout {[division_end]}
  puts $fout {[division_end]}
  puts $fout {[toc_end]}
  close $fout
  

  set fout   [open [file join $base toc_class.txt] w]
  puts $fout {[toc_begin {Table Of Contents} {}]}
  puts $fout {[division_start Modules]}
  puts $fout {[division_start null]}
  set priormodule {}
  set priorcat    {}
  ::helpdoc eval {select * from contents where category='Class' order by title} {
    if { $priormodule != $module } {
      puts $fout {[division_end]}
      puts $fout "\[division_start $module\]"

    }
    puts $fout "\[[list item $filename $label $title]\]"
    set priormodule $module
  }
  puts $fout {[division_end]}
  puts $fout {[division_end]}
  puts $fout {[toc_end]}
  close $fout
  
  set fout   [open [file join $base toc_category.txt] w]
  puts $fout {[toc_begin {Table Of Contents} {}]}
  puts $fout {[division_start Categories]}
  puts $fout {[division_start null]}
  set priormodule {}
  set pcategory    {}
  ::helpdoc eval {select * from contents order by category,title} {
    if { $pcategory != $category } {
      puts $fout {[division_end]}
      puts $fout "\[division_start $category\]"

    }
    puts $fout "\[[list item $filename $label $title]\]"
    set pcategory $module
  }
  puts $fout {[division_end]}
  puts $fout {[division_end]}
  puts $fout {[toc_end]}
  close $fout
}

###
# topic: 881574a52dee232f2f04231808d4c152
###
proc ::codebale::doctools::manpage_meta {module file} {
  ::doctools::new dtmeta \
        -format list \
        -module $module \
        -file $file
  set data [dtmeta format [read_in $file]]
  dtmeta destroy

  return $data
}

###
# topic: 47db648e32d9bdbaec90e6d3f597b61b
###
proc ::codebale::doctools::mkclassfiles {module mpath docpath} {
  set found 0
  ::helpdoc eval {select entryid,class,name from entry where class='class' and entryid in (select entryid from module_index where module=:module)
  and parent is null or parent='' order by name} {
    set fname $docpath/$entryid.man
    set fout [open $fname w]
    
    puts $fout [string map [list %module% $module %class% $name %uuid% $entryid] {
[comment {-*- Class %class% uuid %uuid% -*-}]
[manpage_begin %class% n 9.1]
[keywords %module%]
[keywords %class%]
[keywords odielib]
[category Class]
[copyright {2000-2014 Sean Woods <yoda@etoyoc.com>}]
[titledesc {Class %class%}]
[description]
  }]
    set classsname ::$name
    set alist {}
    ::tao::db eval {select ancestor from class_ancestor where class=:classsname order by seq} {
      lappend alist "[string trimleft $ancestor :]"
    }
    puts $fout "Ancestors: [join $alist ", "]"
        
    set info [::helpdoc eval {select field,value from property where entryid=:entryid}]

    foreach field {title description} {
      if {[dict exists $info $field]} {
        puts $fout [string map {<p> [para]} [dict get $info $field]]
        puts $fout "\[para\]"
      }
    }
    #puts "  $class $name - $entryid"
    if {[helpdoc exists {select entryid as childid,class as childclass,name as childname from entry where parent=:entryid and class='class_method'}]} {
      puts $fout {[subsection {Class Methods}]
Methods available to the class object, as well as objects of the class.
[list_begin definitions]
}
      ::helpdoc eval {select entryid as childid,class as childclass,name as childname from entry where parent=:entryid and class='class_method'} {
        set info [::helpdoc eval {select field,value from property where entryid=:childid}]
        puts $fout [cmdout $childname $info]        
        foreach field {title description} {
          if {[dict exists $info $field]} {
            puts $fout [string map {<p> [para]} [dict get $info $field]]
            puts $fout "\[para\]"
          }
        }
      }
      puts $fout {[list_end]}
    }
    puts $fout {[subsection Methods]
[list_begin definitions]}
    #puts "  $class $name - $entryid"
    ::helpdoc eval {select entryid as childid,class as childclass,name as childname from entry where parent=:entryid} {
      set info [::helpdoc eval {select field,value from property where entryid=:childid}]
      puts $fout [cmdout $childname $info]
      foreach field {title description} {
        if {[dict exists $info $field]} {
          puts $fout [string map {<p> [para]} [dict get $info $field]]
          puts $fout "\[para\]"
        }
      }
    }
    puts $fout {[list_end]}
  
  set buffer  {
[section "REFERENCES"]


[section AUTHORS]
Sean Woods

[vset CATEGORY %module%]
  }
  append buffer [::codebale::doctools::read_in $::odielib(srcroot)/scripts/feedback.inc]
  append buffer {
[manpage_end]
}
    puts $fout [string map [list %module% $module] $buffer]
    close $fout
    incr found
  }  
}

###
# topic: 85303670f7293fadcd8da5e9545ed119
# description: Generate automated help documentation from comment scraping
###
proc ::codebale::doctools::mkprocfiles {module mpath docpath} {
  set procfile $docpath/${module}_procs.man
  set fout [open $procfile w]
  puts $fout [string map [list %module% $module] {
[comment {-*- %module%_procs -*-}]
[manpage_begin %module%_procs n 9.1]
[keywords %module%]
[keywords odielib]
[copyright {2000-2014 Sean Woods <yoda@etoyoc.com>}]
[moddesc {Module %module% procs}]
[titledesc {Module %module% procs}]
[category Procs]
[description]
[section COMMANDS]
[list_begin definitions]
  }]
  
  set found 0
  ::helpdoc eval {select entryid,class,name from entry where class='proc' and entryid in (select entryid from module_index where module=:module)
  and parent is null or parent='' order by name} {
    set info [::helpdoc eval {select field,value from property where entryid=:entryid}]
    puts $fout [cmdout $name $info]
    foreach field {title description} {
      if {[dict exists $info $field]} {
        puts $fout [string map {<p> [para]} [dict get $info $field]]
        puts $fout "\[para\]"
      }
    }
    incr found
  }
  puts $fout {[list_end]}
  set buffer {
[section "REFERENCES"]


[section AUTHORS]
Sean Woods

[vset CATEGORY %module%]
  }
  append buffer [::codebale::doctools::read_in $::odielib(srcroot)/scripts/feedback.inc]
  append buffer {
[manpage_end]
}
    puts $fout [string map [list %module% $module] $buffer]
  
  close $fout
  if {!$found} {
    file delete $procfile 
  }
}

###
# topic: f6b4ff0b701cde0d8f5c14e80c9016b1
# description: Generate human-edited documentation
###
proc ::codebale::doctools::path {fmt ext module mpath} {
  set fl [glob -nocomplain [file join $mpath *.man]]

  if {[llength $fl] == 0} {
    return
  }
  ::doctools::new dt \
        -format $fmt \
        -module $module
  foreach f $fl {
    set target [file join $::odielib(srcroot) doc $fmt $module \
                    [file rootname [file tail $f]].$ext]
    if {[file exists $target] 
        && [file mtime $target] > [file mtime $f]} {
        continue
    }
    dt configure -file $f

    #dt configure -file $f
    set fail [catch {
        set data [dt format [::codebale::doctools::read_in $f]]
    } msg]

    set warnings [dt warnings]
    if {[llength $warnings] > 0} {
        puts stderr [join $warnings \n]
    }

    if {$fail} {
        puts stderr $msg
        continue
    }

    write_out $target $data
  }
  dt destroy
}

###
# topic: 6c3e4328a95c435c46e41a462ee10525
###
proc ::codebale::doctools::read_in f {return [read [set if [open $f r]]][close $if]}

###
# topic: beae9f668725187788972d2dd0915ccd
###
proc ::codebale::doctools::write_out {f text} {
  catch {file delete -force $f}
  puts -nonewline [set of [open $f w]] $text
  close $of
}

###
# topic: a019728317a414badf7b1ec955d4014e
###
proc ::codebale::doctools::write_toc {fmt ext tocfile docroot} {
  
  ::doctools::toc::new dtoc \
        -format $fmt \
        -module $module
  foreach f $fl {
    set target [file join $::odielib(srcroot) doc $fmt $module \
                    [file rootname [file tail $f]].$ext]
    if {[file exists $target] 
        && [file mtime $target] > [file mtime $f]} {
        continue
    }
    dt configure -file $f

    #dt configure -file $f
    set fail [catch {
        set data [dt format [read_in $f]]
    } msg]

    set warnings [dt warnings]
    if {[llength $warnings] > 0} {
        puts stderr [join $warnings \n]
    }

    if {$fail} {
        puts stderr $msg
        continue
    }

    write_out $target $data
  }
  dt destroy
}

###
# topic: bc003494fd515f8eba72b49e58ada5e0
# title: Create an html manpage filesystem for a repository
###
proc ::codebale::mkdoc_embedded_html {base modules docpath args} {
  package require cmdline
  package require fileutil
  package require textutil::repeat
  package require doctools
  package require dtplite
  package require doctools
  package require doctools::toc

  set repo [file tail $base]

  set info [list \
    base $base \
    rewrite 0 \
    repo $repo
  ]
  ::codebale::autodoc $info modules

  
  ###
  # Index entries by module
  ###
  ::helpdoc eval {
  drop table if exists module_index;
    create temporary table module_index (
    module text,
    entryid text,
    unique (module,entryid) on conflict ignore
  );
  }
  
  foreach module $modules {
    set mpat modules/$module/%
    ::helpdoc eval {
  insert into module_index (module,entryid)
  select :module,entryid from property where field='filename' and value like :mpat
    }
    set mpath [file join $::odielib(srcroot) modules $module]
    file mkdir $docpath
    ::codebale::doctools::mkprocfiles $module $mpath $docpath
    ::codebale::doctools::mkclassfiles $module $mpath $docpath
  }
  cd $base
  
  set map  {
      .man     .html
      modules/ tcllib/files/modules/
      apps/    tcllib/files/apps/
  }
  puts "Generating HTML... Pass 1, draft..."
  set baseconfig {}
  set     config $baseconfig
  lappend config -exclude  {*.vfs} 
  lappend config -exclude  {*/doctools/tests/*} 
  lappend config -exclude  {*/support/*} 
  #lappend config -toc      $toc 
  #lappend config -post+toc Categories    $toc_cats
  #lappend config -post+toc Classes       $toc_class 
  #lappend config -post+toc Modules       $mods 
  #lappend config -post+toc Applications  $apps 
  lappend config -merge 
  lappend config {*}$args

  lappend config html .
  puts $config
  dtplite::do $config
  
  puts "Generating HTML... Pass 2, resolving cross-references..."
  dtplite::do $config 
}

