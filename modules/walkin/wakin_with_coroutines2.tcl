package require fileutil

variable BREADTH_FIRST 0
variable DEPTH_FIRST 1


proc eval_iterator {list_of_varnames producer code_to_eval} {
    
    foreach varname $list_of_varnames {
        upvar $varname _$varname
    }
    
    while {[info command  $producer] ne ""} {
        set item_to_consume [$producer]
        
        if {[llength $item_to_consume] != 0} {
            foreach varname $list_of_varnames varvalue $item_to_consume {
                set _$varname $varvalue
            }
            uplevel $code_to_eval
        }
    }
}

proc Walk_coroutine {path strategy follow_links} {
    
    variable BREADTH_FIRST 
    variable DEPTH_FIRST
    
    set parent_path [::fileutil::fullnormalize $path]
    
    set search_list [list]
    
    while 1 {
        set dirs [list]
        set files [list]
        
        set children [concat \
                    [glob -nocomplain -directory $parent_path -types hidden *] \
                    [glob -nocomplain -directory $parent_path *]]
    
    
        foreach child $children[set children {}] {
            set file_name [file tail $child]
            if {!($file_name eq "." || $file_name eq "..")} {
                if {[file isdirectory $child]} {
                    set new_path [fileutil::fullnormalize $child]
                    # we try to avoid a cyclic search
                    if {$follow_links || !([file type $new_path] eq "link" && [string first $parent_path[file separator] $new_path] == 0)} {
                        lappend search_list $new_path
                    }
                    
                    lappend dirs $file_name
                } else {
                    lappend files $file_name
                }
            }
        }
        
        yield [list $parent_path $dirs $files]
        
        if {[llength $search_list] ==0} break
        
        if {$strategy == $BREADTH_FIRST} {
            set parent_path [lindex $search_list 0]
            set search_list [lreplace $search_list [set $search_list 0] 0]
            
        } else {
            set parent_path [lindex $search_list end]
            set search_list [lreplace $search_list [set $search_list end] end]
        }
        

    }
}



proc walkin {parent_var dirs_var files_var path body {strategy 0} {follow_links 0}} {
    coroutine filepaths_producer apply {{path strategy follow_links} {
            yield
            Walk_coroutine $path $strategy $follow_links
        }
    } $path $strategy $follow_links

    
    tailcall eval_iterator [list $parent_var $dirs_var $files_var] filepaths_producer $body
}

# Example
walkin root dirs files . {
    puts "directories: $dirs"
    puts "files: $files"
    puts "root: $root\n"
} $BREADTH_FIRST

# Measuring performance
proc a {} {
    walkin root dirs files . {} 0
}

puts "\nPERFORMANCE\n==========="
puts [time a 1000]
