package require fileutil

variable TOP_DOWN 0
variable BOTTOM_UP 1


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
    
    variable TOP_DOWN 
    variable BOTTOM_UP
    
    set parent_path [::fileutil::fullnormalize $path]
    set dirs [list]
    set files [list]
    
    set children [concat \
                    [glob -nocomplain -directory $parent_path -types hidden *] \
                    [glob -nocomplain -directory $parent_path *]]
    
    foreach child $children[set children {}] {
        set file_name [file tail $child]
        if {!($file_name eq "." || $file_name eq "..")} {
            if {[file isdirectory $child]} {
                lappend dirs $file_name
            } else {
                lappend files $file_name
            }
        }
    }

    if {$strategy == $TOP_DOWN} {
         yield [list $parent_path $dirs $files]
    } 

    foreach dir_name $dirs {
        
        set new_path [file join $parent_path $dir_name]
        set normalized_dir [fileutil::fullnormalize $new_path]
        
        # we try to avoid a cyclic search
        if {$follow_links || !([file type $new_path] eq "link" && [string first $parent_path[file separator] $normalized_dir] == 0)} {
            Walk_coroutine $new_path $strategy $follow_links
        }
    }
    
    if {$strategy eq $BOTTOM_UP} {
        yield [list $parent_path $dirs $files]
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
} $TOP_DOWN


# Measuring performance
proc a {} {
    walkin root dirs files . {} 0
}

foreach a {1 2 3 4 5 6 7 8 9} {
puts "\nPERFORMANCE\n==========="
puts [time a 1000]
}
