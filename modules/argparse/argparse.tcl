# argparse.tcl --
#
# Feature-heavy argument parsing package
#
# Copyright (C) 2019 Andy Goth <andrew.m.goth@gmail.com>
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package require Tcl 8.6
package provide argparse 0.5

# argparse --
# Parses an argument list according to a definition list.  The result may be
# stored into caller variables or returned as a dict.
#
# The [argparse] command accepts the following switches:
#
# -inline        Return the result dict rather than setting caller variables
# -exact         Require exact switch name matches, and do not accept prefixes
# -mixed         Allow switches to appear after parameters
# -long          Recognize "--switch" long option alternative syntax
# -equalarg      Recognize "-switch=arg" inline argument alternative syntax
# -normalize     Normalize switch syntax in pass-through result keys
# -reciprocal    Every element's -require constraints are reciprocal
# -level LEVEL   Every -upvar element's [upvar] level; defaults to 1
# -template TMP  Transform default element names using a substitution template
# -pass KEY      Pass unrecognized elements through to a result key
# -keep          Do not unset omitted element variables; conflicts with -inline
# -boolean       Treat switches as having -boolean wherever possible
# -validate DEF  Define named validation expressions to be used by elements
# -enum DEF      Define named enumeration lists to be used by elements
# --             Force next argument to be interpreted as the definition list
#
# After the above switches comes the definition list argument, then finally the
# optional argument list argument.  If the argument list is omitted, it is taken
# from the caller's args variable.
#
# A special syntax is provided allowing the above switches to appear within the
# definition list argument.  If an element of the definition list is a list
# whose first element is empty string, its subsequent elements are treated as
# additional overall switches to [argparse].
#
# Each element of the definition list is itself a list containing a unique,
# non-empty name element consisting of alphanumerics, underscores, and minus
# (not as the first character), then zero or more of the following switches:
#
# -switch        Element is a switch; conflicts with -parameter
# -parameter     Element is a parameter; conflicts with -switch
# -alias ALIAS   Alias name; requires -switch
# -ignore        Element is omitted from result; conflicts with -key and -pass
# -key KEY       Override key name; not affected by -template
# -pass KEY      Pass through to result key; not affected by -template
# -default VAL   Value if omitted; conflicts with -required and -keep
# -keep          Do not unset if omitted; requires -optional; conflicts -inline
# -value VAL     Value if present; requires -switch; conflicts with -argument
# -boolean       Equivalent to "-default 0 -value 1"
# -argument      Value is next argument following switch; requires -switch
# -optional      Switch value is optional, or parameter is optional
# -required      Switch is required, or stop -catchall from implying -optional
# -catchall      Value is list of all otherwise unassigned arguments
# -upvar         Links caller variable; conflicts with -inline and -catchall
# -level LEVEL   This element's [upvar] level; requires -upvar
# -standalone    If element is present, ignore -required, -require, and -forbid
# -require LIST  If element is present, other elements that must be present
# -forbid LIST   If element is present, other elements that must not be present
# -imply LIST    If element is present, extra switch arguments; requires -switch
# -reciprocal    This element's -require is reciprocal; requires -require
# -validate DEF  Name of validation expression, or inline validation definition
# -enum DEF      Name of enumeration list, or inline enumeration definition
#
# If the first (possibly only) word of a definition list element is the single
# character "#", the element is ignored.  If the definition list element is only
# one word long, the following element is ignored as well.  This may be used to
# place comments directly within the definition list.
#
# If neither -switch nor -parameter are used, a shorthand form is permitted.  If
# the name is preceded by "-", it is a switch; otherwise, it is a parameter.  An
# alias may be written after "-", then followed by "|" and the switch name.  The
# element name may be followed by any number of flag characters:
#
# "="            Same as -argument; only valid for switches
# "?"            Same as -optional
# "!"            Same as -required
# "*"            Same as -catchall
# "^"            Same as -upvar
#
# -default specifies the value to assign to element keys when the element is
# omitted.  If -default is not used, keys for omitted switches and parameters
# are omitted from the result, unless -catchall is used, in which case the
# default value for -default is empty string.
#
# At most one parameter may use -catchall.
#
# Multiple elements may share the same -key value if they are switches, do not
# use -argument or -catchall, and do not use -default for more than one element.
# Such elements are automatically are given -forbid constraints to prevent them
# from being used simultaneously.  If such an element does not use -boolean or
# -value, the element name is used as its default -value.
#
# -value specifies the value to assign to switch keys when the switch is
# present.  -value may not be used with -argument, -optional, -required, or
# -catchall.  -value normally defaults to empty string, except when -boolean is
# used (1 is the default -value) or multiple switches share the same -key (the
# element name is the default -value).
#
# -optional, -required, -catchall, and -upvar imply -argument when used with
# -switch.  Consequently, switches require an argument when any of the shorthand
# flag characters defined above are used, and it is not necessary to explicitly
# specify "=" if any of the other flag characters are used.
#
# If -argument is used, the value assigned to the switch's key is normally the
# next argument following the switch.  With -catchall, the value assigned to the
# switch's key is instead the list of all remaining arguments.  With -optional,
# the following processing is applied:
#
# - If the switch is not present, the switch's key is omitted from the result.
# - If the switch is not the final argument, its value is a two-element list
#   consisting of empty string and the argument following the switch.
# - If the switch is the final argument, its value is empty string.
#
# By default, switches are optional and parameters are required.  Switches can
# be made required with -required, and parameters can be made optional with
# -optional.  -catchall also makes parameters optional, unless -required is
# used, in which case at least one argument must be assigned to the parameter.
# Otherwise, using -required with -parameter has no effect.  -switch -optional
# -required means the switch must be present but may be the final argument.
#
# When -switch and -optional are both used, -catchall, -default, and -upvar are
# disallowed.  -parameter -optional -required is also a disallowed combination.
#
# -validate and -enum provide element value validation.  The overall -validate
# and -enum switches declare named validation expressions and enumeration lists,
# and the per-element -validate and -enum switches select which validation
# expressions and enumeration lists are used on which elements.  The argument to
# the overall -validate and -enum switches is a dict mapping from validation or
# enumeration name to validation expressions or enumeration lists.  The argument
# to a per-element -validate switch is a validation name or expression, and the
# argument to a per-element -enum switch is an enumeration name or list.  An
# element may not use both -validate and -enum.
#
# A validation expression is an [expr] expression parameterized on a variable
# named arg which is replaced with the argument.  If the expression evaluates to
# true, the argument is accepted.
#
# An enumeration list is a list of possible argument values.  If the argument
# appears in the enumeration list, the argument is accepted.  Unless -exact is
# used, if the argument is a prefix of exactly one element of the enumeration
# list, the argument is replaced with the enumeration list element.
#
# Unambiguous prefixes of switch names are acceptable, unless the -exact switch
# is used.  Switches in the argument list normally begin with a single "-" but
# can also begin with "--" if the -long switch is used.  Arguments to switches
# normally appear as the list element following the switch, but if -equalarg is
# used, they may be supplied within the switch element itself, delimited with an
# "=" character, e.g. "-switch=arg".
#
# The per-element -pass switch causes the element argument or arguments to be
# appended to the value of the indicated pass-through result key.  Many elements
# may use the same pass-through key.  If -normalize is used, switch arguments
# are normalized to not use aliases, abbreviations, the "--" prefix, or the "="
# argument delimiter; otherwise, switches will be expressed the same way they
# appear in the original input.  Furthermore, -normalize causes omitted switches
# that accept arguments and have default values, as well as omitted parameters
# that have default values, to be explicitly included in the pass-through key.
# If -mixed is used, pass-through keys will list all switches first before
# listing any parameters.  If the first parameter value for a pass-through key
# starts with "-", its value will be preceded by "--" so that it will not appear
# to be a switch.  If no arguments are assigned to a pass-through key, its value
# will be empty string.  The intention is that the value of a pass-through key
# can be parsed again to get the original data, and if -normalize is used, it
# will not be necessary to use -mixed, -long, -equalarg, -alias, or -default to
# get the correct result.  However, pathological use of -default can conflict
# with this goal.  For example, if the first optional parameter has no -default
# but the second one does, then parsing the result of -normalize can assign the
# default value to the first parameter rather than the second.
#
# The [argparse] -pass switch may be used to collect unrecognized arguments into
# a pass-through key, rather than failing with an error.  Normalization and
# unmixing will not be applied to these arguments because it is not possible to
# reliably determine if they are switches or parameters.  In particular, it is
# not known if an undefined switch expects an argument.
#
# [argparse] produces a set of keys and values.  The keys are the names of
# caller variables into which the values are stored, unless -inline is used, in
# which case the key-value pairs are returned as a dict.  The element names
# default to the key names, unless overridden by -key, -pass, or -template.  If
# both -key and -pass are used, two keys are defined: one having the element
# value, the other having the pass-through elements.  Unless -keep or -inline
# are used, the caller variables for omitted switches and parameters are unset.
#
# -template applies to elements using neither -key nor -pass.  Its value is a
# substitution template applied to element names to determine key names.  "%" in
# the template is replaced with the element name.  To protect "%" or "\" from
# replacement, precede it with "\".  One use for -template is to put the result
# in an array, e.g. with "-template arrayName(%)".
#
# Elements with -upvar are special.  Rather than having normal values, they are
# bound to caller variables using the [upvar] command.  -upvar conflicts with
# -inline because it is not possible to map a dict value to a variable.  Due to
# limitations of arrays and [upvar], -upvar cannot be used with keys whose names
# resemble array elements.  -upvar conflicts with -catchall because the value
# must be a variable name, not a list.  The combination -switch -optional -upvar
# is disallowed for the same reason.  If -upvar is used with switches or with
# optional parameters, [info exists KEY] returns 1 both when the element is not
# present and when its value is the name of a nonexistent variable.  To tell the
# difference, check if [info vars KEY] returns an empty list; if so, the element
# is not present.  Note that the argument to [info vars] is a [string match]
# pattern, so it may be necessary to precede *?[]\ characters with backslashes.
#
# Argument processing is performed in three stages: switch processing, parameter
# allocation, and parameter assignment.  Each argument processing stage and pass
# is performed left-to-right.
#
# All switches must normally appear in the argument list before any parameters.
# Switch processing terminates with the first argument (besides arguments to
# switches) that does not start with "-" (or "--", if -long is used).  The
# special switch "--" can be used to force switch termination if the first
# parameter happens to start with "-".  If no switches are defined, the first
# argument is known to be a parameter even if it starts with "-".
#
# When the -mixed switch is used, switch processing continues after encountering
# arguments that do not start with "-" or "--".  This is convenient but may be
# ambiguous in cases where parameters look like switches.  To resolve ambiguity,
# the special "--" switch terminates switch processing and forces all remaining
# arguments to be parameters.
#
# When -mixed is not used, the required parameters are counted, then that number
# of arguments at the end of the argument list are treated as parameters even if
# they begin with "-".  This avoids the need for "--" in many cases.
#
# After switch processing, parameter allocation determines how many arguments to
# assign to each parameter.  Arguments assigned to switches are not used in
# parameter processing.  First, arguments are allocated to required parameters;
# second, to optional, non-catchall parameters; and last to catchall parameters.
# Finally, each parameter is assigned the allocated number of arguments.
proc ::argparse {args} {
    # Common validation helper routine.
    set validateHelper {apply {{name opt args} {
        if {[dict exists $opt enum]} {
            set command [list tcl::prefix match -message "$name value"\
                    {*}[if {[uplevel 1 {info exists exact}]} {list -exact}]\
                    [dict get $opt enum]]
            set args [lmap arg $args {{*}$command $arg}]
        } elseif {[dict exists $opt validate]} {
            foreach arg $args [list if [dict get $opt validate] {} else {
                return -code error -level 2\
                        "$name value \"$arg\" fails [dict get $opt validateMsg]"
            }]
        }
        return $args
    }}}

    # Process arguments.
    set level 1
    set enum {}
    set validate {}
    for {set i 0} {$i < [llength $args]} {incr i} {
        if {[catch {
            regsub {^-} [tcl::prefix match -message switch {
                -boolean -enum -equalarg -exact -inline -keep -level -long
                -mixed -normalize -pass -reciprocal -template -validate
            } [lindex $args $i]] {} switch
        } msg]} {
            # Do not allow "--" or definition lists nested within the special
            # empty-string element containing extra overall switches.
            if {[info exists reparse]} {
                return -code error $msg
            }

            # Stop after "--" or at the first non-switch argument.
            if {[lindex $args $i] eq "--"} {
                incr i
            }

            # Extract definition and args from the argument list, pulling from
            # the caller's args variable if the args parameter is omitted.
            switch [expr {[llength $args] - $i}] {
            0 {
                break
            } 1 {
                set definition [lindex $args end]
                set argv [uplevel 1 {::set args}]
            } 2 {
                set definition [lindex $args end-1]
                set argv [lindex $args end]
            } default {
                return -code error "too many arguments"
            }}

            # Convert any definition list elements named empty string to instead
            # be overall switches, and arrange to reparse those switches.  Also,
            # remove inline comments from the definition list.
            set args {}
            set reparse {}
            set i -1
            foreach elem $definition[set definition {}] {
                if {[lindex $elem 0] eq "#"} {
                    if {[llength $elem] == 1} {
                        set comment {}
                    }
                } elseif {[info exists comment]} {
                    unset comment
                } elseif {[lindex $elem 0] eq {}} {
                    lappend args {*}[lrange $elem 1 end]
                } else {
                    lappend definition $elem
                }
            }
        } elseif {$switch ni {enum level pass template validate}} {
            # Process switches with no arguments.
            set $switch {}
        } elseif {$i == [llength $args] - 1} {
            return -code error "-$switch requires an argument"
        } else {
            # Process switches with arguments.
            set $switch [lindex $args [incr i]]
        }
    }

    # Fail if no definition argument was supplied.
    if {![info exists definition]} {
        return -code error "missing required parameter: definition"
    }

    # Forbid using -inline and -keep at the same time.
    if {[info exists inline] && [info exists keep]} {
        return -code error "-inline and -keep conflict"
    }

    # Parse element definition list.
    set def {}
    set aliases {}
    set order {}
    set switches {}
    set upvars {}
    set omitted {}
    foreach elem $definition {
        # Read element definition switches.
        set opt {}
        for {set i 1} {$i < [llength $elem]} {incr i} {
            if {[set switch [regsub {^-} [tcl::prefix match {
                -alias -argument -boolean -catchall -default -enum -forbid
                -ignore -imply -keep -key -level -optional -parameter -pass
                -reciprocal -require -required -standalone -switch -upvar
                -validate -value
            } [lindex $elem $i]] {}]] ni {
                alias default enum forbid imply key pass require validate value
            }} {
                # Process switches without arguments.
                dict set opt $switch {}
            } elseif {$i == [llength $elem] - 1} {
                return -code error "-$switch requires an argument"
            } else {
                # Process switches with arguments.
                incr i
                dict set opt $switch [lindex $elem $i]
            }
        }

        # Process the first element of the element definition.
        if {![llength $elem]} {
            return -code error "element definition cannot be empty"
        } elseif {[dict exists $opt switch] && [dict exists $opt parameter]} {
            return -code error "-switch and -parameter conflict"
        } elseif {[info exists inline] && [dict exists $opt keep]} {
            return -code error "-inline and -keep conflict"
        } elseif {![dict exists $opt switch] && ![dict exists $opt parameter]} {
            # If -switch and -parameter are not used, parse shorthand syntax.
            if {![regexp -expanded {
                ^(?:(-)             # Leading switch "-"
                (?:(\w[\w-]*)\|)?)? # Optional switch alias
                (\w[\w-]*)          # Switch or parameter name
                ([=?!*^]*)$         # Optional flags
            } [lindex $elem 0] _ minus alias name flags]} {
                return -code error "bad element shorthand: [lindex $elem 0]"
            }
            if {$minus ne {}} {
                dict set opt switch {}
            } else {
                dict set opt parameter {}
            }
            if {$alias ne {}} {
                dict set opt alias $alias
            }
            foreach flag [split $flags {}] {
                dict set opt [dict get {
                    = argument ? optional ! required * catchall ^ upvar
                } $flag] {}
            }
        } elseif {![regexp {^\w[\w-]*$} [lindex $elem 0]]} {
            return -code error "bad element name: [lindex $elem 0]"
        } else {
            # If exactly one of -switch or -parameter is used, the first element
            # of the definition is the element name, with no processing applied.
            set name [lindex $elem 0]
        }

        # Check for collisions.
        if {[dict exists $def $name]} {
            return -code error "element name collision: $name"
        }

        if {[dict exists $opt switch]} {
            # -optional, -required, -catchall, and -upvar imply -argument when
            # used with switches.
            foreach switch {optional required catchall upvar} {
                if {[dict exists $opt $switch]} {
                    dict set opt argument {}
                }
            }
        } else {
            # Parameters are required unless -catchall or -optional are used.
            if {([dict exists $opt catchall] || [dict exists $opt optional])
             && ![dict exists $opt required]} {
                dict set opt optional {}
            } else {
                dict set opt required {}
            }
        }

        # Check requirements and conflicts.
        foreach {switch other} {reciprocal require   level upvar} {
            if {[dict exists $opt $switch] && ![dict exists $opt $other]} {
                return -code error "-$switch requires -$other"
            }
        }
        foreach {switch others} {
            parameter {alias boolean value argument imply}
            ignore    {key pass}
            required  {boolean default}
            argument  {boolean value}
            upvar     {boolean inline catchall}
            boolean   {default value}
            enum      validate
        } {
            if {[dict exists $opt $switch]} {
                foreach other $others {
                    if {[dict exists $opt $other]} {
                        return -code error "-$switch and -$other conflict"
                    }
                }
            }
        }
        if {[dict exists $opt upvar] && [info exists inline]} {
            return -code error "-upvar and -inline conflict"
        }

        # Check for disallowed combinations.
        foreach combination {
            {switch optional catchall}
            {switch optional upvar}
            {switch optional default}
            {switch optional boolean}
            {parameter optional required}
        } {
            foreach switch [list {*}$combination {}] {
                if {$switch eq {}} {
                    return -code error "[join [lmap switch $combination {
                        string cat - $switch
                    }]] is a disallowed combination"
                } elseif {![dict exists $opt $switch]} {
                    break
                }
            }
        }

        # Replace -boolean with "-default 0 -value 1".
        if {([info exists boolean] && [dict exists $opt switch]
          && ![dict exists $opt argument] && ![dict exists $opt upvar]
          && ![dict exists $opt default] && ![dict exists $opt value]
          && ![dict exists $opt required]) || [dict exists $opt boolean]} {
            dict set opt default 0
            dict set opt value 1
        }

        # Insert default -level if -upvar is used.
        if {[dict exists $opt upvar] && ![dict exists $opt level]} {
            dict set opt level $level
        }

        # Compute default output key if -ignore, -key, and -pass aren't used.
        if {![dict exists $opt ignore] && ![dict exists $opt key]
         && ![dict exists $opt pass]} {
            if {[info exists template]} {
                dict set opt key [string map\
                        [list \\\\ \\ \\% % % $name] $template]
            } else {
                dict set opt key $name
            }
        }

        if {[dict exists $opt parameter]} {
            # Keep track of parameter order.
            lappend order $name

            # Forbid more than one catchall parameter.
            if {[dict exists $opt catchall]} {
                if {[info exists catchall]} {
                    return -code error "multiple catchall parameters:\
                            $catchall and $name"
                } else {
                    set catchall $name
                }
            }
        } elseif {![dict exists $opt alias]} {
            # Build list of switches.
            lappend switches -$name
        } elseif {![regexp {^\w[\w-]*$} [dict get $opt alias]]} {
            return -code error "bad alias: [dict get $opt alias]"
        } elseif {[dict exists $aliases [dict get $opt alias]]} {
            return -code error "element alias collision: [dict get $opt alias]"
        } else {
            # Build list of switches (with aliases), and link switch aliases.
            dict set aliases [dict get $opt alias] $name
            lappend switches -[dict get $opt alias]|$name
        }

        # Map from upvar keys back to element names, and forbid collisions.
        if {[dict exists $opt upvar] && [dict exists $opt key]} {
            if {[dict exists $upvars [dict get $opt key]]} {
                return -code error "multiple upvars to the same variable:\
                        [dict get $upvars [dict get $opt key]] $name"
            }
            dict set upvars [dict get $opt key] $name
        }

        # Look up named enumeration lists and validation expressions.
        if {[dict exists $opt enum]
         && [dict exists $enum [dict get $opt enum]]} {
            dict set opt enum [dict get $enum [dict get $opt enum]]
        } elseif {[dict exists $opt validate]} {
            if {[dict exists $validate [dict get $opt validate]]} {
                dict set opt validateMsg "[dict get $opt validate] validation"
                dict set opt validate [dict get $validate\
                        [dict get $opt validate]]
            } else {
                dict set opt validateMsg "validation: [dict get $opt validate]"
            }
        }

        # Save element definition.
        dict set def $name $opt

        # Prepare to identify omitted elements.
        dict set omitted $name {}
    }

    # Process constraints and shared key logic.
    dict for {name opt} $def {
        # Verify constraint references.
        foreach constraint {require forbid} {
            if {[dict exists $opt $constraint]} {
                foreach otherName [dict get $opt $constraint] {
                    if {![dict exists $def $otherName]} {
                        return -code error "$name -$constraint references\
                                undefined element: $otherName"
                    }
                }
            }
        }

        # Create reciprocal requirements.
        if {([info exists reciprocal] || [dict exists $opt reciprocal])
          && [dict exists $opt require]} {
            foreach other [dict get $opt require] {
                dict update def $other otherOpt {
                    dict lappend otherOpt require $name
                }
            }
        }

        # Perform shared key logic.
        if {[dict exists $opt key]} {
            dict for {otherName otherOpt} $def {
                if {$name ne $otherName && [dict exists $otherOpt key]
                 && [dict get $otherOpt key] eq [dict get $opt key]} {
                    # Limit when shared keys may be used.
                    if {[dict exists $opt parameter]} {
                        return -code error "$name cannot be a parameter because\
                                it shares a key with $otherName"
                    } elseif {[dict exists $opt argument]} {
                        return -code error "$name cannot use -argument because\
                                it shares a key with $otherName"
                    } elseif {[dict exists $opt catchall]} {
                        return -code error "$name cannot use -catchall because\
                                it shares a key with $otherName"
                    } elseif {[dict exists $opt default]
                           && [dict exists $otherOpt default]} {
                        return -code error "$name and $otherName cannot both\
                                use -default because they share a key"
                    }

                    # Create forbid constraints on shared keys.
                    if {![dict exists $otherOpt forbid]
                     || $name ni [dict get $otherOpt forbid]} {
                        dict update def $otherName otherOpt {
                            dict lappend otherOpt forbid $name
                        }
                    }

                    # Set default -value for shared keys.
                    if {![dict exists $opt value]} {
                        dict set def $name value $name
                    }
                }
            }
        }
    }

    # Handle default pass-through switch by creating a dummy element.
    if {[info exists pass]} {
        dict set def {} pass $pass
    }

    # Force required parameters to bypass switch logic.
    set end [expr {[llength $argv] - 1}]
    if {![info exists mixed]} {
        foreach name $order {
            if {[dict exists $def $name required]} {
                incr end -1
            }
        }
    }
    set force [lreplace $argv 0 $end]
    set argv [lrange $argv 0 $end]

    # Perform switch logic.
    set result {}
    set missing {}
    if {$switches ne {}} {
        # Build regular expression to match switches.
        set re ^-
        if {[info exists long]} {
            append re -?
        }
        append re {(\w[\w-]*)}
        if {[info exists equalarg]} {
            append re (?:(=)(.*))?
        } else {
            append re ()()
        }
        append re $

        # Process switches, and build the list of parameter arguments.
        set params {}
        while {$argv ne {}} {
            # Check if this argument appears to be a switch.
            set argv [lassign $argv arg]
            if {[regexp $re $arg _ name equal val]} {
                # This appears to be a switch.  Fall through to the handler.
            } elseif {$arg eq "--"} {
                # If this is the special "--" switch to end all switches, all
                # remaining arguments are parameters.
                set params $argv
                break
            } elseif {[info exists mixed]} {
                # If -mixed is used and this is not a switch, it is a parameter.
                # Add it to the parameter list, then go to the next argument.
                lappend params $arg
                continue
            } else {
                # If this is not a switch, terminate switch processing, and
                # process this and all remaining arguments as parameters.
                set params [linsert $argv 0 $arg]
                break
            }

            # Process switch aliases.
            if {[dict exists $aliases $name]} {
                set name [dict get $aliases $name]
            }

            # Preliminary guess for the normalized switch name.
            set normal -$name

            # Perform switch name lookup.
            if {[dict exists $def $name switch]} {
                # Exact match.  No additional lookup needed.
            } elseif {![info exists exact] && ![catch {
                tcl::prefix match -message switch [lmap {key data} $def {
                    if {[dict exists $data switch]} {
                        set key
                    } else {
                        continue
                    }
                }] $name
            } name]} {
                # Use the switch whose prefix unambiguously matches.
                set normal -$name
            } elseif {[dict exists $def {}]} {
                # Use default pass-through if defined.
                set name {}
            } else {
                # Fail if this is an invalid switch.
                set switches [lsort $switches]
                if {[llength $switches] > 1} {
                    lset switches end "or [lindex $switches end]"
                }
                set switches [join $switches\
                        {*}[if {[llength $switches] > 2} {list ", "}]]
                return -code error "bad switch \"$arg\": must be $switches"
            }

            # If the switch is standalone, ignore all constraints.
            if {[dict exists $def $name standalone]} {
                foreach other [dict keys $def] {
                    dict unset def $other required
                    dict unset def $other require
                    dict unset def $other forbid
                    if {[dict exists $def $other parameter]} {
                        dict set def $other optional {}
                    }
                }
            }

            # Keep track of which elements are present.
            dict set def $name present {}

            # If the switch value was set using -switch=value notation, insert
            # the value into the argument list to be handled below.
            if {$equal eq "="} {
                set argv [linsert $argv 0 $val]
            }

            # Load key and pass into local variables for easy access.
            unset -nocomplain key pass
            foreach var {key pass} {
                if {[dict exists $def $name $var]} {
                    set $var [dict get $def $name $var]
                }
            }

            # Keep track of which switches have been seen.
            dict unset omitted $name

            # Validate switch arguments and store values into the result dict.
            if {[dict exists $def $name catchall]} {
                # The switch is catchall, so store all remaining arguments.
                set argv [{*}$validateHelper $normal\
                        [dict get $def $name] {*}$argv]
                if {[info exists key]} {
                    dict set result $key $argv
                }
                if {[info exists pass]} {
                    if {[info exists normalize]} {
                        dict lappend result $pass $normal {*}$argv
                    } else {
                        dict lappend result $pass $arg {*}$argv
                    }
                }
                break
            } elseif {![dict exists $def $name argument]} {
                # The switch expects no arguments.
                if {$equal eq "="} {
                    return -code error "$normal doesn't allow an argument"
                }
                if {[info exists key]} {
                    if {[dict exists $def $name value]} {
                        dict set result $key [dict get $def $name value]
                    } else {
                        dict set result $key {}
                    }
                }
                if {[info exists pass]} {
                    if {[info exists normalize]} {
                        dict lappend result $pass $normal
                    } else {
                        dict lappend result $pass $arg
                    }
                }
            } elseif {$argv ne {}} {
                # The switch was given the expected argument.
                set argv0 [lindex [{*}$validateHelper $normal\
                        [dict get $def $name] [lindex $argv 0]] 0]
                if {[info exists key]} {
                    if {[dict exists $def $name optional]} {
                        dict set result $key [list {} $argv0]
                    } else {
                        dict set result $key $argv0
                    }
                }
                if {[info exists pass]} {
                    if {[info exists normalize]} {
                        dict lappend result $pass $normal $argv0
                    } elseif {$equal eq "="} {
                        dict lappend result $pass $arg
                    } else {
                        dict lappend result $pass $arg [lindex $argv 0]
                    }
                }
                set argv [lrange $argv 1 end]
            } else {
                # The switch was not given the expected argument.
                if {![dict exists $def $name optional]} {
                    return -code error "$normal requires an argument"
                }
                if {[info exists key]} {
                    dict set result $key {}
                }
                if {[info exists pass]} {
                    if {[info exists normalize]} {
                        dict lappend result $pass $normal
                    } else {
                        dict lappend result $pass $arg
                    }
                }
            }

            # Insert this switch's implied arguments into the argument list.
            if {[dict exists $def $name imply]} {
                set argv [concat [dict get $def $name imply] $argv]
                dict unset def $name imply
            }
        }

        # Build list of missing required switches.
        dict for {name opt} $def {
            if {[dict exists $opt switch] && ![dict exists $opt present]
             && [dict exists $opt required]} {
                if {[dict exists $opt alias]} {
                    lappend missing -[dict get $opt alias]|$name
                } else {
                    lappend missing -$name
                }
            }
        }

        # Fail if at least one required switch is missing.
        if {$missing ne {}} {
            set missing [lsort $missing]
            if {[llength $missing] > 1} {
                lset missing end "and [lindex $missing end]"
            }
            set missing [join $missing\
                    {*}[if {[llength $missing] > 2} {list ", "}]]
            return -code error [string cat "missing required switch"\
                    {*}[if {[llength $missing] > 1} {list es}] ": " $missing]
        }
    } else {
        # If no switches are defined, bypass the switch logic and process all
        # arguments using the parameter logic.
        set params $argv
    }

    # Allocate one argument to each required parameter, including catchalls.
    set alloc {}
    lappend params {*}$force
    set count [llength $params]
    set i 0
    foreach name $order {
        if {[dict exists $def $name required]} {
            if {$count} {
                dict set alloc $name 1
                dict unset omitted $name
                incr count -1
            } else {
                lappend missing $name
            }
        }
        incr i
    }

    # Fail if at least one required parameter is missing.
    if {$missing ne {}} {
        if {[llength $missing] > 1} {
            lset missing end "and [lindex $missing end]"
        }
        return -code error [string cat "missing required parameter"\
                {*}[if {[llength $missing] > 1} {list s}] ": "\
                [join $missing {*}[if {[llength $missing] > 2} {list ", "}]]]
    }

    # Try to allocate one argument to each optional, non-catchall parameter,
    # until there are no arguments left.
    if {$count} {
        foreach name $order {
            if {![dict exists $def $name required]
             && ![dict exists $def $name catchall]} {
                dict set alloc $name 1
                dict unset omitted $name
                if {![incr count -1]} {
                    break
                }
            }
        }
    }

    # Process excess arguments.
    if {$count} {
        if {[info exists catchall]} {
            # Allocate remaining arguments to the catchall parameter.
            dict incr alloc $catchall $count
            dict unset omitted $catchall
        } elseif {[dict exists $def {}]} {
            # If there is no catchall parameter, instead allocate to the default
            # pass-through result key.
            lappend order {}
            dict set alloc {} $count
        } else {
            return -code error "too many arguments"
        }
    }

    # Check constraints.
    dict for {name opt} $def {
        if {[dict exists $opt present]} {
            foreach {match condition description} {
                1 require requires 0 forbid "conflicts with"
            } {
                if {[dict exists $opt $condition]} {
                    foreach otherName [dict get $opt $condition] {
                        if {[dict exists $def $otherName present] != $match} {
                            foreach var {name otherName} {
                                if {[dict exists $def [set $var] switch]} {
                                    set $var -[set $var]
                                }
                            }
                            return -code error "$name $description $otherName"
                        }
                    }
                }
            }
        }
    }

    # If normalization is enabled, explicitly store into the pass-through keys
    # all omitted switches that have a pass-through key, accept an argument, and
    # have a default value.
    if {[info exists normalize]} {
        dict for {name opt} $def {
            if {[dict exists $opt switch] && [dict exists $opt pass]
             && [dict exists $opt argument] && [dict exists $opt default]
             && [dict exists $omitted $name]} {
                dict lappend result [dict get $opt pass]\
                        -$name [dict get $opt default]
            }
        }
    }

    # Validate parameters and store in result dict.
    set i 0
    foreach name $order {
        set opt [dict get $def $name]
        if {[dict exists $alloc $name]} {
            if {![dict exists $opt catchall] && $name ne {}} {
                set val [lindex [{*}$validateHelper $name\
                        $opt [lindex $params $i]] 0]
                if {[dict exists $opt pass]} {
                    if {[string index $val 0] eq "-"
                     && ![dict exists $result [dict get $opt pass]]} {
                        dict lappend result [dict get $opt pass] --
                    }
                    dict lappend result [dict get $opt pass] $val
                }
                incr i
            } else {
                set step [dict get $alloc $name]
                set val [lrange $params $i [expr {$i + $step - 1}]]
                if {$name ne {}} {
                    set val [{*}$validateHelper $name $opt {*}$val]
                }
                if {[dict exists $opt pass]} {
                    if {[string index [lindex $val 0] 0] eq "-"
                     && ![dict exists $result [dict get $opt pass]]} {
                        dict lappend result [dict get $opt pass] --
                    }
                    dict lappend result [dict get $opt pass] {*}$val
                }
                incr i $step
            }
            if {[dict exists $opt key]} {
                dict set result [dict get $opt key] $val
            }
        } elseif {[info exists normalize] && [dict exists $opt default]
               && [dict exists $opt pass]} {
            # If normalization is enabled and this omitted parameter has both a
            # default value and a pass-through key, explicitly store the default
            # value in the pass-through key, located in the correct position so
            # that it can be recognized again later.
            if {[string index [dict get $opt default] 0] eq "-"
             && ![dict exists $result [dict get $opt pass]]} {
                dict lappend result [dict get $opt pass] --
            }
            dict lappend result [dict get $opt pass] [dict get $opt default]
        }
    }

    # Create default values for missing elements.
    dict for {name opt} $def {
        if {[dict exists $opt key]
         && ![dict exists $result [dict get $opt key]]} {
            if {[dict exists $opt default]} {
                dict set result [dict get $opt key] [dict get $opt default]
            } elseif {[dict exists $opt catchall]} {
                dict set result [dict get $opt key] {}
            }
        }
        if {[dict exists $opt pass]
         && ![dict exists $result [dict get $opt pass]]} {
            dict set result [dict get $opt pass] {}
        }
    }

    if {[info exists inline]} {
        # Return result dict.
        return $result
    } else {
        # Unless -keep was used, unset caller variables for omitted elements.
        if {![info exists keep]} {
            dict for {name val} $omitted {
                set opt [dict get $def $name]
                if {![dict exists $opt keep] && [dict exists $opt key]
                 && ![dict exists $result [dict get $opt key]]} {
                    uplevel 1 [list ::unset -nocomplain [dict get $opt key]]
                }
            }
        }

        # Process results.
        dict for {key val} $result {
            if {[dict exists $upvars $key]} {
                # If this element uses -upvar, link to the named variable.
                uplevel 1 [list ::upvar\
                        [dict get $def [dict get $upvars $key] level] $val $key]
            } else {
                # Store result into caller variables.
                uplevel 1 [list ::set $key $val]
            }
        }
    }
}

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
