::namespace eval ::codebale {}

::namespace eval ::codebale::parse {}

###
# topic: 547fa005713946cd8f2c395a28f9353c
###
proc ::codebale::complete_ccomment string {
  set result {}
  set opened 0
  set closed 0
  set idx 0
  while {1} {
    set idx [string first "/*" $string $idx]
    if {$idx < 0} break
    incr idx 2
    incr opened
  }
  if {!$opened} {
    return 1
  }
  set idx 0
  while {1} {
    set idx [string first "*/" $string $idx]
    if {$idx < 0} break
    incr idx 2
    incr closed
  }
  if { $opened > $closed } {
    return 0
  }
  return 1
}

###
# topic: b1e5e6caf0bf9e78695f995a35af7c2f
# description: Provide a keyword handler to the autodoc parser
###
proc ::codebale::define {name info} {
  global cmdref
  foreach {var val} $info {
      dict set cmdref($name) $var $val
  }
}

###
# topic: 9cca11ca444743a321d3ad5ac85538b1
# description:
#    A simpler implementation of digest_comment, this proc
#    takes in the raw buffer and returns a dict of the annotations
#    it found
###
proc ::codebale::digest_comment {buffer {properties {}}} {
  set result(description) {}
  set appendto description
  
  foreach line [split $buffer \n] {
    set line [string trimleft [string range $line [string first # $line] end] #]
    set line [string trimright [string trim $line] -]
    set rawline $line
    if [catch {lindex $line 0} token] {
      append result($appendto) $rawline \n
      #set result($appendto) [buffer_merge $result($appendto) $line]
      continue
    }
    if {[string index $token end] ne ":"} {
      append result($appendto) $rawline \n
      #buffer_puts result($appendto) $line
    } else {
      set field [string tolower [string trimright $token :]]
      set vstart [string first : $rawline]
      set value [string trim [string range $rawline $vstart+1 end]]
      switch $field {
        topic {
          set result(topic) [lrange $line 1 end]
          append result(description) \n
          set appendto description
        }
        comment -
        desc -
        description {
          #append result(description) [lrange $line 1 end] \n
          set result(description) [buffer_merge $result(description) $value]
          append result(description) \n
          set appendto description
        }
        title -
        headline {
          set result(title) $value
          append result(description) \n
          set appendto description          
        }
        ensemble_method {
          set result(type) proc
          append result(description) \n
          set appendto description
        }
        ensemble -
        nspace -
        namespace -
        class -
        agent_class -
        task -
        subtask -
        method -
        class_function -
        class_method -
        phase -
        function -
        action {
          set result(type) $field
          set result(arglist) [lrange $field 1 end]
          append result(description) \n
          set appendto description
        }
        darglist {
          set result($field) $value
        }
        default {
          set result($field) $value
          append result($field) \n
          set appendto $field
        }
      }
    }
  }
  foreach {field} [array names result] {
    set result($field) [string trim $result($field)]
  }
  return [array get result]
}

###
# topic: 4971b1be85962744bfb3869375d60357
###
proc ::codebale::digest_csource {dat {trace 0}} {
  set ::readinglinenumber 0
  set ::readingline {}
  
  set result {}
  set funcregexp {(.*) ([a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}
  set funcregexp2 {(.*) (\x2a[a-zA-Z_][a-zA-Z0-9_]*) *\((.*)\)}

  set priorline {}
  set thisline {}
  set rawblock {}
  set continueline 0
  set inknrdef 0
  set infunct 0
  set isfunct 0
  set inparen 0
  set intypedef 0
  set instruct 0
  set psplit 0
  set incomment 0
  set instatement 0
  set parseline {}
  set thisfunct {}
  set priorcomment {}

  ###
  # Place to store code that surrounds the functions
  ###
  dict set result code {}

  foreach rawline [split $dat \n] {
    incr ::readinglinenumber
    set ::readingline $rawline
    append rawblock $rawline \n
    set wasincomment $incomment
    
    if {[regexp {^ *case *([A-Z]+)_([A-Z0-9_]+):} $rawline all prefix label]} {
      lappend cases($prefix) $label
    }
    
    regsub -all \x7b $rawline \x20\x7b line
    if { $trace } {puts "$continueline $instatement $infunct $inparen $incomment [string length $priorcomment] | $line"}
    if {$incomment} {
      append thisline \n [string trim $line]
      if {[string first "*/" $thisline] <0} continue
      append priorcomment \n $rawblock
      set incomment 0
      set isfunct -1
    } elseif {$inparen} {
      set funcname {} 
      append thisline \n "  [string trim $line]"
      set parenidx [string first ")" $thisline]
      set lastchar [string index [string trim $thisline] end] 
      if {$trace} { puts [list $parenidx $lastchar] }
      ###
      # Wait for the trailing parenthesis and starting curly
      ###
      if {$parenidx < 0} continue
      if {$lastchar ne "\;" } {
        if {[string first "\{" $thisline $idx] < 0} continue
      }        
      set psplit 1
      set inparen 0
    } elseif {$instatement} {
      append thisline \n [string trim $line]
      if {[info complete $thisline]} {
        if { $trace } { puts "ENDOFSTATEMENT ***\n$thisline\n***" }
        set rawblock {}
        set infunct 0
        set isfunct 0
        set instatement 0
        if { [string match "*const*Tcl_ObjType*=*" $thisline] } {
          set pline [string range $thisline 0 [string first "=" $thisline]-1]
          if { $trace } {puts "TCL OBJ TYPE DECLARED $pline "}
          dict lappend result objtypes_defined [lindex $pline end]
        }
        if { [string match "*const*Tk_PhotoImageFormat*=*" $thisline] } {
          set pline [string range $thisline 0 [string first "=" $thisline]-1]
          if { $trace } {puts "TCL PHOTO TYPE DECLARED $pline "}
          dict lappend result phototypes_defined [lindex $pline end]
        }
        set thisline {}
        continue
      } else {
        continue
      }    
    } elseif {$infunct} {
      append thisline \n [string trim $line]
      if {[info complete $thisline]} {
        if { $trace } { puts "ENDOFFUNCTION" }
        if { $thisfunct ne {} } {
          dict set result function $thisfunct body $rawblock
        }
        set rawblock {}
        set thisline {}
        set infunct 0
        set isfunct 0
        continue
      } else {
        continue
      }
    } elseif {$continueline} {
      append thisline " " [string trim $line]
    } else {
      append thisline \n [string trim $line]
    }
    if {[string range [string trim $line] 0 1] eq "//"} {
      set isfunct -1
    } elseif {[string range [string trim $line] 0 1] eq "/*"} {
      # Handle comments
      set isfunct -1
      if {[string first "*/" $thisline] <0} {
        set incomment 1
        set comment 1
        continue
      }
    } elseif {[set idx [string first "(" $thisline]] > 0} {
      if {[string first ")" $thisline] < 0} {
        set inparen 1
        continue
      }
    }

    set parseline [string trim $thisline]
    if {[string range $parseline 0 1] eq "//"} {
      set isfunct -1
    }
    if {[string index $parseline 0] eq "#"} {
      set isfunct -1
    }
    if {![::codebale::complete_ccomment $parseline]} {
      continue
    }
    set parseline [::codebale::strip_ccoments $parseline]
    if {[string index $parseline end] eq "\;" } {
      set isfunct -1
      set priorcomment {}
      if { $trace } { puts "CSTATEMENT" }
    }
    if {$isfunct == 0} {
      set isfunct [regexp $funcregexp $parseline all keywords funcname arglist]
      if { $isfunct == 0 } {
        set isfunct [regexp $funcregexp2 $parseline all keywords funcname arglist]
      }
    }
    if {$isfunct > 0} {
      if {[string first "\{" $parseline] < 0} {
        incr continueline
        continue
      }
      set all [string trim $all]
      set declargs {}
      foreach item [split $arglist ,] {
        lappend declargs [string trim $item]
      }
      if { $trace } { puts "$keywords $funcname\([join $declargs ", "]\) | $arglist" }
      set thisfunct $funcname
      dict set result function $thisfunct comment $priorcomment
      dict set result function $thisfunct keywords $keywords
      dict set result function $thisfunct arglist $declargs
      set priorcomment {}
      
      set infunct 1
      set isfunct 0
      set continueline 0
    } elseif { $isfunct == 0 } {
      if {![info complete $thisline]} {
        set instatement 1
        continue
      }
      if {![regexp (void|unsigned|static|int|char|inline|extern) $thisline]} {
        if { $trace } { puts "!KEYWORDS" }
        dict append result code "$rawblock"
        set priorcomment {}
        set thisline {}
        set rawblock {}
        set infunct 0
        set isfunct 0
        set continueline 0
      } else {
        incr continueline
        continue
      }
    } else {
      if { $trace } { puts "KILLTERM" }
      dict append result code "$rawblock"
      set thisline {}
      set rawblock {}
      set infunct 0
      set isfunct 0
      set continueline 0
    }    
  }
  if { $infunct } {
    error "Stopped waiting for end of function $thisfunct"
  }
  if {[info exists cases]} {
    dict set result cases [array get cases]
  }
  return $result
}

###
# topic: 44c147047b298a349863145642f3c0b2
###
proc ::codebale::first_autoconf_token line {
  set line [string trim $line]
  set idx [string first "(" $line]
  if { $idx < 0 } {
    return {}
  }
  return [string range $line 0 $idx-1]
}

###
# topic: a6ee7ffd7430c9ccd6669addf08fd039
# description:
#    Parses a script, namespace body, or class
#    definition.
###
proc ::codebale::parse_body {meta body modvar} {
  
  upvar 1 $modvar match
  set match 0
  set patterns [parser_patterns [dict getnull $meta scope]]
  foreach {pat info} $patterns {
    if {[regexp $pat $body]} {
      set match 1
      break
    }      
  }

  ###
  # Pass through if we don't see any patterns to match
  ###
  if {!$match} {
    return [list body $body]
  }
  
  set thisline {}
  set thiscomment {}
  set incomment 0
  set linecount 0
  set inheader 1

  array set result {
    namespace {}
    header    {}
    body      {}
    command   {}
    comment   {}
  }
  dict set meta comment {}

  foreach line [split $body \n] {
    append thisline \n $line
    if {![info complete $thisline]} continue
    
    set parseline [string range $thisline 1 end]
    set thisline {}

    if { $incomment } {
      if {[string index [string trimleft $parseline] 0] ne "#"} {
        set incomment 0
        set thiscomment [string trimright $thiscomment \n]
      } else {
        append thiscomment $parseline \n
        continue
      }
    } elseif {[string index [string trimleft $parseline] 0] eq "#"} {
      set incomment 1
      if {$inheader} {
        if {[string length $thiscomment]} {
          append result(header) $thiscomment \n
        }
      } else {
        if {[string length $thiscomment]} {
          append result(body) $thiscomment \n
        }
      }
      set thiscomment {}
      append thiscomment $parseline \n
      continue     
    }
    
    set cmd [pattern_match $patterns $parseline]
    if {$cmd eq {}} {
      set var body
      if {$inheader} {
        set var header
      } else {
        set var body
      }    
      if {[string length $thiscomment]} {
        append result($var) [string trimright $thiscomment \n] \n
        set thiscomment {}
      }
      append result($var) $parseline \n
    } else {
      set inheader 0
      set info $meta
      dict set info comment [string trim $thiscomment]
      if {[catch {{*}$cmd $info $parseline} lresult]} {
        puts "Error: [list {*}$cmd $info $parseline]"
        puts "$lresult"
        puts $::errorInfo
        exit
        error DIE
      }
      foreach {type info} $lresult {
        switch $type {
          header - body {
            #append result($type) $info \n
            buffer_append result($type) $info
          }
          command {
            foreach {pname pinfo} $info {
              dict set result($type) $pname $pinfo           
            }
          }
          namespace {
            logicset add result(namespace) {*}$info
          }
          default {
            append result($type) $info \n
          }
        }
      }
    }
    set thiscomment {}
  }
  return [array get result]
}

###
# topic: a18c537125594150a50c0a21013ba712
# description:
#    Parses a namespace and redeclares any procs as
#    glob procs pointing to the current namespace
###
proc ::codebale::parse_namespace {meta def} {
  global cmdref base block fileinfo
  set nspace [lindex $def end-1]
  set body [lindex $def end]

  set nspace [string trim $nspace :]
  if { $nspace eq {} } {
    set Nspace Global
  } else {
    set Nspace $nspace
  }
  set thisline {}
  array set result {
    command {}
    body    {}
    header  {}
  }
  
  dict set aliases {} [list topic subtopic proc namespace nspace class arglist method]
  set info [digest_comment [dict get $meta comment] $meta]
  set info [meta_scrub $aliases $info]
  dict set aliases darglist darglist
  dict set aliases usage usage
  dict set aliases example example
  dict set info type namespace
  
  helpdoc node_define namespace $Nspace $info nodeid
  set result(meta) [helpdoc node_properties $nodeid]

  set comment         [rewrite_comment 0 $nodeid $result(meta)]

  array set result [parse_body [list {*}$meta namespace $nspace parent $nodeid] $body mod]
  buffer_append newbody [get result(header)] [get result(body)]
  set result(header) {}

  if {[string length [string trim $newbody]]} {
    set result(body) [buffer_merge $comment "[list namespace eval ::$nspace] \{\n$newbody\}"]
  } else {
    logicset add result(namespace) $nspace
    set result(body) {}
    #[dict get $meta comment]
  }
  set result(comment) $comment
  return [array get result]
}

###
# topic: bab541dc7ab25960b7b375553ef388aa
###
proc ::codebale::parse_ooclass {meta def} {
  set nspace [lindex $def end-1]
  set body   [lindex $def end]

  set nspace [string trim $nspace :]
  
  set thisline {}

  array set result {
    command {}
    body    {}
    header  {}
  }
  set info [digest_comment [dict get $meta comment] $meta]
  dict set aliases {} [list topic subtopic proc namespace nspace class arglist method]
  dict set aliases darglist darglist
  dict set aliases usage usage
  dict set aliases example example

  set info [meta_scrub $aliases $info]
  dict set info type class
  if {[dict exists $meta filename]} {
    dict set info filename [dict get $meta filename]
  }
  helpdoc node_define class $nspace $info nodeid
  set result(meta)    [helpdoc node_properties $nodeid]
  set comment         [rewrite_comment 0 $nodeid $result(meta)]
  
  ###
  # Write in the results
  ###
  array set result [parse_body [list {*}$meta class $nspace parent $nodeid scope ooclass] $body mod]
  buffer_append newbody [get result(header)] [get result(body)]
  set result(header) {}
  foreach {mname} [lsort -dictionary [dict keys $result(command)]] {
    buffer_append newbody [dict get $result(command) $mname]
  }
  unset result(command)

  set result(body) [buffer_merge $comment "[list {*}[lrange $def 0 end-1]] \{\n$newbody\}"]
  set result(comment) $comment
  return [array get result]
}

###
# topic: 16fbb45b8e9aa13b0b892270fd7537ff
# description:
#    This procedure reads in the definition of a method,
#    marks it up in the help documentation, and seeds the
#    re-writer so that this method is creates in sorted order
###
proc ::codebale::parse_oomethod {meta def} {
  set token    [lindex $def 0]
  if {[string range $token 0 5]=="class_"} {
    set cmd "class_method"
    set class class_method
  } else {
    set cmd "method"
    set class method
  }
  set def "  [list $cmd {*}[lrange $def 1 end-1]] \{[lindex $def end]\}"
  set def [normalize_tabbing $def 2]

  set token    [lindex $def 0]
  set procname [string trim [lindex $def 1] :]
  set fullname [string trimleft $class :]::$procname
  if {[llength $def] < 4} {
    set arglist dictargs
    set darglist dictargs
    set body [lindex $def 3]
  } else {
    set arglist [lindex $def 2]
    set body [lindex $def 4]
    ###
    # Clean up args
    ###
    set darglist {}
    foreach n $arglist {
      if [catch {
      if {[llength $n] > 1} {
        lappend darglist "?[lindex $n 0]?"
      } else {
        lappend darglist [lindex $n 0]
      }
      } err] {
        lappend darglist $n
      }
    }
  }
  
  ###
  # Document
  ###
  set info [digest_comment [dict get $meta comment] $meta]
  set type [dict getnull $info type]

  if {$type eq {}} {
    set type [string trim $token :]
    if { $type ne "method" } {
      dict set info type $type
    }
  }
  
  dict set aliases returns {return yields}
  dict set aliases darglist darglist
  dict set aliases usage usage
  dict set aliases example example
  dict set aliases {} [list topic subtopic proc namespace nspace class arglist method $type]
  set info [meta_scrub $aliases $info]
  dict set info type $type
  dict set info arglist $darglist
  if {[dict exists $meta filename]} {
    dict set info filename [dict get $meta filename]
  }
  helpdoc node_define_child [dict getnull $meta parent] $class $procname $info nodeid
  set result(meta)    [helpdoc node_properties $nodeid]
  set result(comment) [rewrite_comment 2 $nodeid $result(meta)]

  set result(command) $def
  return [list command [list ${class}::${procname} [buffer_merge $result(comment) $result(command)]]]
}

###
# topic: 2e9b9100a28c1d6dd42195779706ad24
# description:
#    This procedure reads in the definition of a method,
#    marks it up the ancestors for this object
###
proc ::codebale::parse_oosuperclass {meta def} {
  set parentid [dict getnull $meta parent]
  foreach class [lrange $def 1 end] {
    set ancestor [helpdoc node_id [list class $class] 1]
    helpdoc link_create $parentid $ancestor class_ancestor
  }
  return [list header $def]
}

###
# topic: 0360b37868575d302ab6f15e88365266
###
proc ::codebale::parse_path {info base args} {
  set rewrite 0
  set repo    source
  dict with info {}

  set pathlist $args
  if {[llength $pathlist]==0} {
    set pathlist $base
  }
  
  set stack {}
  foreach path $pathlist {
    stack push stack $path
  }
  set filelist {}
  while {[stack pop stack stackpath]} {
    lappend filelist {*}[sniffPath $stackpath stack]
  }
  set meta [list repo $repo rewrite $rewrite base $base]
  if {![helpdoc exists {select localpath from repository where handle=:repo}]} {
    helpdoc eval {insert into repository (handle,localpath) VALUES (:repo,:base);}
  } else {
    helpdoc eval {update repository set localpath=:base where handle=:repo;}
  }
  foreach {type file} $filelist {
    switch $type {
      parent_name -
      source {
        if { [file tail $file] in {version_info.tcl packages.tcl lutils.tcl}} continue
        if {[catch {
          parse_tclsourcefile $meta $file $rewrite
        } err]} {
          puts [list $file $err]
          puts $::errorInfo
          if {[file exists $file.new]} {
            puts "X $file.new"
            file delete $file.new
          }
        }
      }
      csource {
        if {[catch {
          read_csourcefile $file
          
        } err]} {
          puts [list $file $err]
        }
      }
      index {
        continue
      }
    }
  }
}

###
# topic: 70a6c102860ad99677f3c4f2021a5308
# description:
#    This procedure reads in the definition of a procedures,
#    marks it up in the help documentation, and seeds the
#    re-writer so that this procedure is defined from the
#    global namespace
###
proc ::codebale::parse_procedure {meta def} {
  set def [normalize_tabbing $def]

  foreach {token procname arglist body} $def break;
  set rawproc $procname
  set proc [namespace tail $procname]
  set nspace [string trimleft [proc_nspace $rawproc] :]
  if { $nspace eq {} } {
    set nspace [dict getnull $meta namespace]
  }
  if {$nspace in {{} ::}} {
    set fullname [string trim $proc :]
  } else {
    set fullname ${nspace}::${proc}
  }
  set result(namespace) $nspace
  set result(command) [list $token ::$fullname $arglist]
  append result(command) " \{$body\}"

  ###
  # Document
  ###
  set type [string trim $token :]
  dict set aliases yields return
  dict set aliases darglist darglist
  dict set aliases usage usage
  dict set aliases example example

  dict set aliases {} [list topic subtopic proc namespace nspace class arglist $type]

  set info [digest_comment [dict get $meta comment] $meta]
  set info [meta_scrub $aliases $info]
  
  dict set info type $type
  ###
  # Clean up args
  ###
  set darglist {}
  foreach n $arglist {
    if {[llength $n] > 1} {
      lappend darglist "?[lindex $n 0]?"
    } else {
      lappend darglist [lindex $n 0]
    }
  }
  dict set info arglist $darglist
  if {[dict exists $meta filename]} {
    dict set info filename [dict get $meta filename]
  }
  helpdoc node_define proc $fullname $info nodeid
  set result(meta) [helpdoc node_properties $nodeid]
  set result(comment) [rewrite_comment 0 $nodeid $result(meta)]

  return [list command [list $fullname [buffer_merge $result(comment) $result(command)]] namespace $result(namespace)]
}

###
# topic: 7c9f9cea78297eef903b3f711033a993
###
proc ::codebale::parse_tclsourcefile {meta file {rewrite 0}} {
  global classes block filename fileinfo
  variable parser_patterns
  array unset filestore
  
  dict with meta {}

  set i [string length $base]

  set fname [file rootname [file tail $file]]
  set dir [string trimleft [string range [file dirname $file] $i end] /]
  set fpath $dir/[file tail $file]
  set filename $fpath

  set md5 [::md5::md5 -hex -file $file]
  set fileid [::helpdoc file_id [list $repo $fpath] 1]
  set repomd5 [helpdoc one {select hash from file where fileid=:fileid}]
  if {!$::force_check} {
    if { $md5 eq $repomd5} { return 0 }
  }
  
  set info {}
  dict set info mtime [file mtime $file]
  dict set info hash  $md5
  dict set info path  $fpath
  dict set info filename $fpath
  dict set info repo  $repo
  dict set info localpath $fpath
  ::helpdoc file_restore $fileid $info
  dict with info {}

  #set ::filemd5($fpath) $md5
  
  set fin [open $file r]
  set dat [read $fin]
  close $fin
  
  puts "<< $fpath r:$repomd5 l:$md5"
  set fileinfo {}
  set result [parse_body [list namespace {} file $file filename $filename] $dat patmatch]
  if {!$rewrite || !$patmatch} {
    return $patmatch
  }
  ###
  # Rewrite the tcl sourcefile
  ###
  set buffer {}

  set ndefined {}
  set header {}
  set body {}
  set command {}
  set namespace {}
  set buffer {}
  dict with result {}
  buffer_append buffer $header
  foreach ns [lsort -dictionary $namespace] {
    if { $ns ne {} } {
      append buffer \n [list ::namespace eval ::$ns {}] \n
    }
  }  
  if {[llength $command]} {
    foreach {nsproc} [lsort -dictionary [dict keys $command]] {
      buffer_append buffer [dict get $command $nsproc]
    }
  }
  buffer_append buffer $body

  set oldlines [split $dat \n]
  set newlines [split $buffer \n]
  set idx -1
  set identical 1
  foreach oldline $oldlines {
    set newline [lindex $newlines [incr idx]]
    if {[string trim $oldline] ne [string trim $newline]} {
      set identical 0
      break
    }
  }
  if {$identical} {
    if {[file exists $file.new]} {
      puts "~ $file.new"
      file delete $file.new
    }
    return $patmatch
  }
  puts ">> $fpath.new"
  set fout [open $file.new w]
  fconfigure $fout -translation crlf
  puts $fout $buffer
  close $fout
  return $patmatch
}

###
# topic: 233756d1a3b76fa93023ccae156e0ec5
###
proc ::codebale::parser_addpattern args {
  variable parser_patterns
  dict set parser_patterns {*}$args
}

###
# topic: d086f77979bde4d7f60d41af050c529d
###
proc ::codebale::parser_patterns scope {
  variable parser_patterns
  set result {}
  foreach {pat info} [dict getnull $parser_patterns $scope] {
    dict set result $pat $info
  }
  return $result
}

###
# topic: 6fd968f42730f701c0fa3ca32b8f7785
###
proc ::codebale::pattern_match {patterns parseline} {
  set parseline [string trimleft $parseline :]
  foreach {pat patinfo} $patterns {
    set idx -1
    set match 1
    foreach a $pat {
      incr idx
      if [catch {lindex $parseline $idx} token] {
        set match 0
        break
      }
      if {![string match $token $a] } {
        set match 0
        break
      }
    }
    if { $match } {
      return $patinfo
    }
  }
  return {}
}

###
# topic: f9b3ce3aafc972b55e330ac9b62c31db
###
proc ::codebale::proc_nspace procname {
  set rawproc $procname
  set proc [namespace tail $procname]
  set n [string last $proc $rawproc]
  if { $n == 0 } {
    set nspace {}
  } else {
    set nspace [string range $rawproc 0 [expr {$n - 1}]]
    set nspace [string trimleft $nspace :]
    set nspace [string trimright $nspace :]
  }
  return $nspace
}

###
# topic: 27a7f1698a00fb294f2c700a8d8acb7e
###
proc ::codebale::read_csourcefile file {
  global classes base filename
  ###
  # Skip huge files
  ###
  if {[file size $file] > 500000} {return 0}
  set i [string length $base]

  set fname [file rootname [file tail $file]]
  set dir [string trimleft [string range [file dirname $file] $i end] /]
  set fpath $dir/[file tail $file]
  set filename $dir/[file tail $file]
  set fin [open $file r]
  set dat [read $fin]
  close $fin
  set found 0

  set thisline {}
  set thiscomment {}
  set incomment 0
  set parentid tclcmd
  foreach line [split $dat \n] {
    set line [string trim $line]
    if {[string range $line 0 1] == "/*" } {
        set incomment 1
    }
    if { $incomment } {
      set pline [string trimleft $line "/"]
      set pline [string trimleft $pline "*"]
      set pline [string trimright $pline "/"]
      set pline [string trimright $pline "*"]
      append thiscomment $pline \n


      if {[string range $line end-1 end] eq "*/" } {
        set incomment 0

        set info [digest_comment $thiscomment [list file $fpath]]
        set thiscomment {}
        set nodeid {}
        set found 0
        foreach {var val} $info {
          switch $var {
            topic {
              set nodeid $val
              dict unset info $var
            }
            tclcmd -
            tclmod {
              if { $nodeid eq {} } {
                set nodeid   [helpdoc node_id [list tclcmd [lindex $val 0]] 1]
              }
              set parentid $nodeid
              helpdoc node_property_set $nodeid usage $val
              dict unset info $var
            }
            tclmethod -
            tclsubcmd {
              if { $nodeid eq {} } {
                set nodeid [helpdoc node_id [list tclcmd [lindex $val 0] method [lindex $val 1]] 1]
              }
              dict unset info $var
              helpdoc node_property_set $nodeid usage   $val              
              helpdoc node_property_set $nodeid arglist [lrange $val 2 end]
            }
          }
        }
        if { $nodeid ne {} } {
          #puts [list $nodeid $info]
          helpdoc node_property_set $nodeid file $fpath

          dict set info file $fpath
          foreach {var val} $info {
            switch $var {
              topic -
              tclcmd -
              tclmod -
              tclmethod -
              tclsubcmd {}
              default {
                helpdoc node_property_set $nodeid $var $val
              }
            }
          }
        }
      }
    }
  }
  return 1
}

###
# topic: 2e99acd975c8dcb5b24e617d1a4697db
###
proc ::codebale::rewrite_autoconf {} {
  ###
  # Update the AC_INIT line in configure.in
  ###
  set fout [open [file join $::project(path) configure.in.new] w]
  set fin  [open [file join $::project(path) configure.in] r]
  set wrote_sources 0
  
  while {[gets $fin line]>=0} {
    switch [first_autoconf_token $line] {
      "AC_INIT" {
        puts $fout "AC_INIT(\[$::project(pkgname)\], \[$::project(pkgvers)\])"        
      }
      "m4_include" -
      "TEA_ADD_HEADERS" -
      "TEA_ADD_SOURCES" {
        if { !$wrote_sources } {
puts $fout "TEA_ADD_HEADERS(\[generic/${::project(h_file)}\])"
#puts $fout "TEA_ADD_SOURCES(\[generic/${project(c_file)}\])"
set wrote_sources 1
        foreach file $::project(tcl_sources) {
          puts $fout "TEA_ADD_TCL_SOURCES(\[$file\])"
        }
        }
      }
      default {
        puts $fout $line
      }
    }
  }

  close $fin
  close $fout
  file rename -force [file join $::project(path) configure.in.new] [file join $::project(path) configure.in]
}

###
# topic: c790d2a5043a5f76a476143db91bd729
###
namespace eval ::codebale {
  alias nspace namespace

  parser_addpattern {}  {namespace eval}   ::codebale::parse_namespace
  parser_addpattern {}  proc               ::codebale::parse_procedure
  parser_addpattern {}  ensemble_method    ::codebale::parse_procedure
  parser_addpattern {}  odie::class        ::codebale::parse_ooclass  
  parser_addpattern {}  tao::class        ::codebale::parse_ooclass  
  parser_addpattern {}  {oo::class create} ::codebale::parse_ooclass
  parser_addpattern ooclass method         ::codebale::parse_oomethod
  parser_addpattern ooclass proc           ::codebale::parse_oomethod
  parser_addpattern ooclass class_method   ::codebale::parse_oomethod
  parser_addpattern ooclass superclasses   ::codebale::parse_oosuperclass
}

