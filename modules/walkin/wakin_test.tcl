package require fileutil


variable BREADTH_FIRST 0
variable DEPTH_FIRST 1

proc eval_iterator {args} {
    array set opts $args
    
    set list_of_varnames $opts(-list_of_varnames)
    set producer $opts(-producer)
    set code_to_eval $opts(-code_to_eval)
    
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

proc Walk_coroutine {root_path strategy follow_links} {
    
    variable BREADTH_FIRST 
    variable DEPTH_FIRST
    
    set root_path [::fileutil::fullnormalize $root_path]
    
    set base_path $root_path
    set parent_subpath {}
    
    set search_list [list]
    
    while 1 {
        set dirs [list]
        set files [list]
                  
        set children [concat \
                    [glob -nocomplain -directory $base_path -types hidden *] \
                    [glob -nocomplain -directory $base_path *]]
    
    
        foreach child $children[set children {}] {
            set file_name [file tail $child]
            
            if {!($file_name eq "." || $file_name eq "..")} {
                if {[file isdirectory $child]} {
                    set new_subpath [file join $parent_subpath $file_name]
                    if {$follow_links || !([file type $child] eq "link")} {
                        lappend search_list $new_subpath
                    }
                    
                    lappend dirs $file_name
                } else {
                    lappend files $file_name
                }
            }
        }
        
        yield [list $parent_subpath $dirs $files]
        
        if {[llength $search_list] ==0} break
        
        if {$strategy == $BREADTH_FIRST} {
            set parent_subpath [lindex $search_list 0]
            set search_list [lreplace $search_list [set $search_list 0] 0]
            
        } else {
            set parent_subpath [lindex $search_list end]
            set search_list [lreplace $search_list [set $search_list end] end]
        }
        
        set base_path [file join $root_path $parent_subpath]

    }
}


proc walkin {list_of_varnames path body {strategy 0} {follow_links 0}} {
    # list_of_varnames = base_path, dirs, files
    
    coroutine filepaths_producer apply {{path strategy follow_links} {
            yield
            Walk_coroutine $path $strategy $follow_links
        }
    } $path $strategy $follow_links


    tailcall eval_iterator -list_of_varnames $list_of_varnames -producer filepaths_producer -code_to_eval $body
}



# Example
walkin [list subpath dirs files] . {
    puts "directories: $dirs"
    puts "files: $files"
    puts "subpath: $subpath\n"
} $BREADTH_FIRST

# Measuring performance
proc a {} {
    walkin [list subpath dirs files] . {} 0
}

puts "\nPERFORMANCE\n==========="
puts [time a 1000]
