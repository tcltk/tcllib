package require fileutil

set TOP_DOWN 0
set BOTTOM_UP 1

set RETURN_IMMEDIATELY_EXCEPTION 6

proc Walkin_eval {parent_var parent_path dirs_var dirs files_var files body level} {
    variable RETURN_IMMEDIATELY_EXCEPTION
    
    upvar $level $parent_var _parent $dirs_var _dirs $files_var _files
        
    set _parent $parent_path
    set _dirs $dirs
    set _files $files

    set code_exception [catch {uplevel $level $body} msg]
    
    if {$code_exception == 2} {
        return -code $RETURN_IMMEDIATELY_EXCEPTION $msg
    }
    
    return -code $code_exception $msg
}

proc Walk_without_exception_catching {parent_var dirs_var files_var path body strategy follow_links level} {
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
         Walkin_eval $parent_var $parent_path $dirs_var $dirs $files_var $files $body [expr {$level+1}]
         
    } 

    foreach dir_name $dirs {
        
        set new_path [file join $parent_path $dir_name]
        set normalized_dir [fileutil::fullnormalize $new_path]
        
        # we try to avoid a cyclic search
        if {$follow_links || !([file type $new_path] eq "link" && [string first $parent_path[file separator] $normalized_dir] == 0)} {
            Walk_without_exception_catching $parent_var $dirs_var $files_var $new_path $body $strategy $follow_links [expr {$level +1}]
        }
    }
    
    if {$strategy eq $BOTTOM_UP} {
        Walkin_eval $parent_var $parent_path $dirs_var $dirs $files_var $files $body [expr {$level+1}]
    }
}

proc walkin {parent_var dirs_var files_var path body {strategy 0} {follow_links 0}} {
    variable RETURN_IMMEDIATELY_EXCEPTION
    
    # We catch here all the exceptions in the top level
    set code_exception [catch {Walk_without_exception_catching $parent_var $dirs_var $files_var $path $body $strategy $follow_links 2} msg]
    if {$code_exception}  { 
        if {$code_exception == 1} {
            return -code 1 $msg
        }
            
        # If the exception is "return immediately", we return the message passed    
        if {$code_exception == $RETURN_IMMEDIATELY_EXCEPTION} {
            return $msg
        }
        
        # If the exception is continue or break, we do nothing
        if {($code_exception == 3) || ($code_exception == 4)} {
            return ""
        }
        
        # Otherwise we rerise the exception
        return -code $code_exception $msg
    }

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

puts "\nPERFORMANCE\n==========="
puts [time a 1000]

