#-----------------------------------------------------------------------
# TITLE:
#    validate.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Temporary file; validation function for future option
#    validation.
#
# TYPE SPECIFICATION SYNTAX
#
#    <typename> ?<option>...?
#
# STANDARD OPTIONS
#
#    -list {?minlen? ?maxlen?}
#        A list of items of the specified type.  minlen defaults to 0,
#        maxlen defaults to INF
#
# TYPE SPECIFICATIONS
#
#    boolean ?-list ...?
#        Values are any booleans understood by Tcl, e.g., 1, 0, yes, no,
#        true, false, on, off.
#
#        Example:   boolean
#
#    command ?-list ...? -prefix {<command> ?<arg>...?}
#        <command> and its args are used as a command prefix, to which the
#        value is appended.  The command is expected to throw an error
#        if the value is invalid, and return nothing or anything otherwise.
#
#    double ?-list...? ?-range {<min> ?<max>?}
#        The value must be a floating-point number; optionally it 
#        must be greater than or equal to min, and less than or equal to max.
#
#        Example:  double                       Any number
#                  double -range 0.5            0.5 <= value
#                  double -range {0.0 1.0}      0.0 <= value <= 1.0
#    
#    enum ?-list ...? -values {<value> ...}
#        The value must belong to the list of <value>s.
#
#        Example:   enum -values {red white blue}
#
#    fpixels ?-list...? ?-range {<min> ?<max>?}
#        The value must be a Tk pixel value with an optional unit suffix.
#        Optionally it must be greater than or equal to min, and less than 
#        or equal to max; comparisons are doing using floating-point
#        pixel values.
#
#        Example:  fpixels                   Any pixel, e.g., 5.5, or 2.5i
#                  fpixels -range 0.5        0.5 <= value
#                  fpixels -range {0 5.5i}   0 <= value <= 5.5i
#
#    int ?-list...? ?-range {<min> ?<max>?}
#        The value must be an integer; optionally it must be greater than
#        or equal to min, and less than or equal to max.
#
#        Example:  int                       Any integer
#                  int -range 0              0 <= value
#                  int -range {0 5}          0 <= value <= 5
#    
#    pixels ?-list...? ?-range {<min> ?<max>?}
#        The value must be a Tk pixel value with an optional unit suffix.
#        Optionally it must be greater than or equal to min, and less than 
#        or equal to max; comparisons are doing using integer pixel values.
#
#        Example:  pixels                    Any pixel, e.g., 5, or 2i
#                  pixels -range 0           0 <= value
#                  pixels -range {0 5i}      0 <= value <= 5i
#
#    string ?-list...? ?-nocase? ?-length {min ?max?}? 
#                      ?-glob <pattern>? ?-regexp <regexp>?
#        String must match the constraints
#
#        Example:  string -glob "*FOO*"          Value contains "FOO"
#                  string -nocase -glob "*FOO*"  Value contains "FOO" or "foo"
#
#    window
#        Value must be a Tk window
#
#        Example:  window
#
#-----------------------------------------------------------------------

namespace eval ::snit:: { 
    namespace export \
        validate     \
        valcompile


    # Name the compiler for each validation type.
    variable valcompilers

    array set ::snit::valcompilers {
        boolean ::snit::CompileTypespecBoolean
        command ::snit::CompileTypespecCommand
        double  ::snit::CompileTypespecDouble
        enum    ::snit::CompileTypespecEnum
        fpixels ::snit::CompileTypespecFpixels
        int     ::snit::CompileTypespecInt
        pixels  ::snit::CompileTypespecPixels
        string  ::snit::CompileTypespecString
        window  ::snit::CompileTypespecWindow
    }
}

# validate typespec value
#
# typespec       A type specification
# value          The value to validate.
#
# Verifies that the value is a valid member of the type defined by the
# typespec.  If the value is invalid, validate throws an appropriate
# error message; otherwise, it does nothing.

proc ::snit::validate {typespec value} {
    # FIRST, compile the typespec into a command prefix
    set cmd [valcompile $typespec]

    # NEXT, append the value to be validated.
    lappend cmd $value

    # NEXT, execute it!
    uplevel \#0 $cmd

    return
}

# valcompile typespec
#
# typespec       A type specification
#
# Given a type specification, returns a command prefix to which values
# to be validated can be appended.  Throws an error if the type
# specification is invalid.

proc ::snit::valcompile {typespec} {
    variable valcompilers

    # FIRST, get the type name from the type spec
    set typeName [lindex $typespec 0]
    set allArgs [lrange $typespec 1 end]

    # NEXT, is it a known type?
    if {![info exists valcompilers($typeName)]} {
        return -code error \
            "unrecognized data type: \"$typeName\""
    }

    # NEXT, extract standard options from the beginning of the type 
    # spec.  Leave the rest of the arguments alone.
    set typeArgs {}

    array set std {
        -list    0
        listMin  0
        listMax  ""
    }

    while {[llength $allArgs] > 0} {
        set opt [NextArg allArgs]

        switch -exact -- $opt {
            -list {
                # -list ?{listMin ?listMax?}?
                set std(-list) 1

                # NEXT, if the next argument is an option, we're
                # done here.
                set arg [lindex $allArgs 0]

                if {[string match {-*} $arg]} {
                    continue
                }

                # NEXT, the next argument is the list bounds.  Validate it.
                set arglen [llength $arg]

                if {$arglen < 1} {
                    continue
                }

                if {$arglen > 2} {
                    error "invalid -list bounds"
                }

                set std(listMin) [lindex $arg 0]

                if {![string is integer -strict $std(listMin)] ||
                    $std(listMin) < 0} {
                    error "invalid -list bounds"
                }

                if {$arglen == 2} {
                    set std(listMax) [lindex $arg 1]

                    if {![string is integer -strict $std(listMax)] ||
                        $std(listMax) < $std(listMin)} {
                        error "invalid -list bounds"
                    }
                }

                NextArg allArgs
            }
            
            default {
                lappend typeArgs $opt
            }
        }
    }

    # NEXT, compile the remainder of the typespec.
    set validator [$valcompilers($typeName) $typeArgs]

    # NEXT, if it's a list compile it as a list.
    if {$std(-list)} {
        set validator [list \
                           ::snit::TypespecList \
                           $std(listMin) \
                           $std(listMax) \
                           $validator]
    }

    # NEXT, return the compiled validator
    return $validator
}

proc ::snit::NextArg {listvar} {
    upvar $listvar theList

    set arg [lindex $theList 0]
    set theList [lrange $theList 1 end]

    return $arg
}

#-----------------------------------------------------------------------
# <type> -list ?{minlen ?maxlen?}?

# TypespecList minlen maxlen validator value
#
# minlen      Minimum list length, or 0.
# maxlen      Maximum list length, or "".
# validator   A command to validate the list elements.
# value       The value to validate.

proc ::snit::TypespecList {minlen maxlen validator value} {
    # FIRST, It's a list; check the bounds
    set valueLen [llength $value]

    if {$valueLen < $minlen} {
        return -code error \
            "value has too few elements; at least $minlen expected"
    } elseif {$maxlen ne ""} {
        if {$valueLen > $maxlen} {
            return -code error \
                "value has too many elements; no more than $maxlen expected"
        }
    }

    # NEXT, check each value
    foreach item $value {
        set cmd $validator
        lappend cmd $item
        uplevel \#0 $cmd
    }
}

#-----------------------------------------------------------------------
# boolean ?-list ...?

# CompileTypespecBoolean typeArgs
#
# typeArgs      Type arguments (should be empty)
#
# Compiles a boolean validator

proc snit::CompileTypespecBoolean {typeArgs} {
    if {[llength $typeArgs] != 0} {
        return -code error \
            "unexpected typespec option: \"[lindex $typeArgs 0]\""
    }

    return [list ::snit::TypespecBoolean]
}

# TypespecBoolean value
#
# value     The value to be validated.
#
# Validates boolean values.  

proc ::snit::TypespecBoolean {value} {
    if {![string is boolean -strict $value]} {
        return -code error \
            "invalid boolean \"$value\", should be one of: 1, 0, true, false, yes, no, on, off"
    }

    return
}

#-----------------------------------------------------------------------
#    command ?-list ...? -prefix {<command> ?<arg>...?}

# CompileTypespecCommand typeArgs
#
# typeArgs  Type arguments
#
# Compiles a command typespec

proc ::snit::CompileTypespecCommand {typeArgs} {
    set prefix ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -prefix {
                set prefix [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }

    if {[llength $prefix] == 0} {
        return -code error \
            "invalid -prefix: \"\""
    }

    return [list ::snit::TypespecCommand $prefix]
}

# TypespecCommand prefix value
#
# prefix   The command prefix
# value    The value to be validated.
#
# Validates values using a passed in command prefix

proc ::snit::TypespecCommand {prefix value} {
    lappend prefix $value

    if {[catch {uplevel \#0 $prefix} result]} {
        return -code error $result
    }

    return
}

#-----------------------------------------------------------------------
# double ?-list...? -range ?{min ?max?}?

# CompileTypespecDouble typeArgs
#
# typeArgs  Type arguments
#
# Compiles a double typespec

proc ::snit::CompileTypespecDouble {typeArgs} {
    set range ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -range {
                set range [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }


    set min [lindex $range 0]
    set max [lindex $range 1]

    if {[llength $range] > 2 ||
        ($min ne "" && ![string is double -strict $min]) ||
        ($max ne "" && ![string is double -strict $max]) ||
        ($min ne "" && $max ne "" && $max < $min)} {
        return -code error \
            "invalid -range: \"$range\""
    }

    

    return [list ::snit::TypespecDouble $min $max]
    
}

# TypespecDouble min max value
#
# min        The minimum value, or ""
# max        The maximum value, or ""
# value      The value to validate
#
# Validates a double value, and optionally checks its range.

proc ::snit::TypespecDouble {min max value} {
    if {![string is double -strict $value] ||
        ($min ne "" && $value < $min)       ||
        ($max ne "" && $value > $max)} {

        set msg "invalid value \"$value\", expected double"

        if {$min ne "" && $max ne ""} {
            append msg " in range $min, $max"
        } elseif {$min ne ""} {
            append msg " no less than $min"
        }
        
        return -code error $msg
    }

    return
}

#-----------------------------------------------------------------------
# enum ?-list ...? -values {<value>....}

# CompileTypespecEnum typeArgs
#
# typeArgs  Type arguments
#
# Compiles an enum typespec

proc ::snit::CompileTypespecEnum {typeArgs} {
    set values ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -values {
                set values [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }

    if {[llength $values] == 0} {
        return -code error \
            "invalid -values: \"\""
    }

    return [list ::snit::TypespecEnum $values]
}

# TypespecEnum values value
#
# typeArgs  Type arguments (unused)
# value     The value to be validated.
#
# Validates values using an enumerated list

proc ::snit::TypespecEnum {values value} {
    if {[lsearch -exact $values $value] == -1} {
        return -code error \
            "invalid value \"$value\", should be one of: [join $values {, }]"
    }

    return
}

#-----------------------------------------------------------------------
# fpixels ?-list...? ?-range {<min> ?<max>?}

# CompileTypespecFpixels typeArgs
#
# typeArgs  Type arguments
#
# Compiles a pixel typespec

proc ::snit::CompileTypespecFpixels {typeArgs} {
    set range ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -range {
                set range [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }

    set min [lindex $range 0]
    set max [lindex $range 1]

    if {[llength $range] > 2 ||
        ($min ne "" && [catch {winfo fpixels . $min} min]) ||
        ($max ne "" && [catch {winfo fpixels . $max} max]) ||
        ($min ne "" && $max ne "" && $max < $min)} {
        return -code error \
            "invalid -range: \"$range\""
    }

    return [list ::snit::TypespecFpixels $min $max]
}

# TypespecFpixels min max value
#
# min        The minimum value, or ""
# max        The maximum value, or ""
# value      The value to validate
#
# Validates a pixel value, and optionally checks its range.

proc ::snit::TypespecFpixels {min max value} {
    if {[catch {winfo fpixels . $value} dummy] ||
        ($min ne "" && $value < $min)       ||
        ($max ne "" && $value > $max)} {

        set msg "invalid value \"$value\", expected fpixels"

        if {$min ne "" && $max ne ""} {
            append msg " in range $min, $max"
        } elseif {$min ne ""} {
            append msg " no less than $min"
        }
        
        return -code error $msg
    }

    return
}

#-----------------------------------------------------------------------
# int ?-list...? ?-range {<min> ?<max>?}

# CompileTypespecInt typeArgs
#
# typeArgs  Type arguments
#
# Compiles an int typespec

proc ::snit::CompileTypespecInt {typeArgs} {
    set range ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -range {
                set range [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }


    set min [lindex $range 0]
    set max [lindex $range 1]

    if {[llength $range] > 2 ||
        ($min ne "" && ![string is integer -strict $min]) ||
        ($max ne "" && ![string is integer -strict $max]) ||
        ($min ne "" && $max ne "" && $max < $min)} {
        return -code error \
            "invalid -range: \"$range\""
    }

    return [list ::snit::TypespecInt $min $max]
}

# TypespecInt min max value
#
# min        The minimum value, or ""
# max        The maximum value, or ""
# value      The value to validate
#
# Validates an integer value, and optionally checks its range.

proc ::snit::TypespecInt {min max value} {
    if {![string is integer -strict $value] ||
        ($min ne "" && $value < $min)       ||
        ($max ne "" && $value > $max)} {

        set msg "invalid value \"$value\", expected integer"

        if {$min ne "" && $max ne ""} {
            append msg " in range $min, $max"
        } elseif {$min ne ""} {
            append msg " no less than $min"
        }
        
        return -code error $msg
    }

    return
}

#-----------------------------------------------------------------------
# pixels ?-list...? ?-range {<min> ?<max>?}

# CompileTypespecPixels typeArgs
#
# typeArgs  Type arguments
#
# Compiles a pixel typespec

proc ::snit::CompileTypespecPixels {typeArgs} {
    set range ""

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -range {
                set range [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }

    set min [lindex $range 0]
    set max [lindex $range 1]

    if {[llength $range] > 2 ||
        ($min ne "" && [catch {winfo pixels . $min} min]) ||
        ($max ne "" && [catch {winfo pixels . $max} max]) ||
        ($min ne "" && $max ne "" && $max < $min)} {
        return -code error \
            "invalid -range: \"$range\""
    }

    return [list ::snit::TypespecPixels $min $max]
}

# TypespecPixels min max value
#
# min        The minimum value, or ""
# max        The maximum value, or ""
# value      The value to validate
#
# Validates a pixel value, and optionally checks its range.

proc ::snit::TypespecPixels {min max value} {
    if {[catch {winfo pixels . $value} dummy] ||
        ($min ne "" && $value < $min)       ||
        ($max ne "" && $value > $max)} {

        set msg "invalid value \"$value\", expected pixels"

        if {$min ne "" && $max ne ""} {
            append msg " in range $min, $max"
        } elseif {$min ne ""} {
            append msg " no less than $min"
        }
        
        return -code error $msg
    }

    return
}

#-----------------------------------------------------------------------
# string ?-list...? ?-nocase? ?-length {minlen ?maxlen?}? 
#        ?-glob <pattern>? ?-regexp <regexp>?
#       
# CompileTypespecString typeArgs
#
# typeArgs  Type arguments
#
# Compiles a string typespec

proc ::snit::CompileTypespecString {typeArgs} {
    set nocase 0
    set length {}
    set glob {}
    set regexp {}

    while {[llength $typeArgs] > 0} {
        set opt [NextArg typeArgs]

        switch -exact -- $opt {
            -nocase {
                set nocase 1
            }

            -length {
                set length [NextArg typeArgs]
            }

            -glob {
                set glob [NextArg typeArgs]
            }

            -regexp {
                set regexp [NextArg typeArgs]
            }

            default {
                return -code error \
                    "unexpected typespec option: \"[list $opt]\""
                
            }
        }
    }

    # Validate the length bounds
    set minlen [lindex $length 0]
    set maxlen [lindex $length 1]

    if {[llength $length] > 2 ||
        ($minlen ne "" && ![string is integer -strict $minlen]) ||
        ($maxlen ne "" && ![string is integer -strict $maxlen]) ||
        ($minlen ne "" && $maxlen ne "" && $maxlen < $minlen)} {
        return -code error \
            "invalid -length: \"$length\""
    }

    if {$minlen eq ""} {
        set minlen 0
    }

    # Validate the glob
    if {$glob ne "" && [catch {string match $glob ""} dummy]} {
        return -code error \
            "invalid -glob: \"$glob\""
    }

    # Validate the regexp
    if {$regexp ne "" && [catch {regexp $regexp ""} dummy]} {
        return -code error \
            "invalid -regexp: \"$regexp\""
    }

    
    return [list ::snit::TypespecString $minlen $maxlen $nocase $glob $regexp]
}

# TypespecString minlen maxlen nocase glob regexp value
#
# minlen    Minimum string length, or 0
# maxlen    Maximum string length, or ""
# nocase    1 if case-insensitive, 0 otherwise
# glob      The glob pattern, or ""
# regexp    The regular expression, or ""
# value     The value to be validated
#
# Validates a string, checking that it matches the constraints

proc ::snit::TypespecString {minlen maxlen nocase glob regexp value} {
    # FIRST, Check the length
    set len [string length $value]

    if {$len < $minlen} {
        return -code error \
            "too short: at least $minlen characters expected"
    } elseif {$maxlen ne ""} {
        if {$len > $maxlen} {
            return -code error \
                "too long: no more than $maxlen characters expected"
        }
    }

    # NEXT, check glob match with or without case
    if {$glob ne ""} {
        if {$nocase} {
            set result [string match -nocase $glob $value]
        } else {
            set result [string match $glob $value]
        }

        if {!$result} {
            return -code error \
                "invalid value \"$value\""
        }
    }

    # NEXT, check regexp match with or without case
    if {$regexp ne ""} {
        if {$nocase} {
            set result [regexp -nocase -- $regexp $value]
        } else {
            set result [regexp -- $regexp $value]
        }

        if {!$result} {
            return -code error \
                "invalid value \"$value\""
        }
    }
}

#-----------------------------------------------------------------------
# window ?-list ...?

# CompileTypespecWindow typeArgs
#
# typeArgs      Type arguments (should be empty)
#
# Compiles a window validator

proc snit::CompileTypespecWindow {typeArgs} {
    if {[llength $typeArgs] != 0} {
        return -code error \
            "unexpected typespec option: \"[lindex $typeArgs 0]\""
    }

    return [list ::snit::TypespecWindow]
}

# TypespecWindow value
#
# value     The value to be validated.
#
# Validates Tk window names as belonging to existing windows.

proc ::snit::TypespecWindow {value} {
    if {![winfo exists $value]} {
        return -code error \
            "invalid value \"$value\", value is not a window"
    }
}


