# cmdline.tcl --
#
#	This package provides a utility for parsing command line
#	arguments that are processed by our various applications.
#	It also includes a utility routine to determine the app
#	name for use in command line errors.
#
# Copyright (c) 1998-2000 by Ajuba Solutions.
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: cmdline.tcl,v 1.11 2001/10/17 17:27:25 andreas_kupries Exp $

package require Tcl 8.2
package provide cmdline 1.1.1
namespace eval cmdline {
    namespace export getArgv0 getopt getfiles getoptions usage
}

# Load the typed versions of these functions
source [file join [file dirname [info script]] typedCmdline.tcl]

# cmdline::getopt --
#
#	The cmdline::getopt works in a fashion like the standard
#	C based getopt function.  Given an option string and a 
#	pointer to an array or args this command will process the
#	first argument and return info on how to procede.
#
# Arguments:
#	argvVar		Name of the argv list that you
#			want to process.  If options are found the
#			arg list is modified and the processed arguments
#			are removed from the start of the list.
#	optstring	A list of command options that the application
#			will accept.  If the option ends in ".arg" the
#			getopt routine will use the next argument as 
#			an argument to the option.  Otherwise the option	
#			is a boolean that is set to 1 if present.
#	optVar		The variable pointed to by optVar
#			contains the option that was found (without the
#			leading '-' and without the .arg extension).
#	valVar		Upon success, the variable pointed to by valVar
#			contains the value for the specified option.
#			This value comes from the command line for .arg
#			options, otherwise the value is 1.
#			If getopt fails, the valVar is filled with an
#			error message.
#
# Results:
# 	The getopt function returns 1 if an option was found, 0 if no more
# 	options were found, and -1 if an error occurred.

proc cmdline::getopt {argvVar optstring optVar valVar} {
    upvar 1 $argvVar argsList

    upvar 1 $optVar option
    upvar 1 $valVar value

    # default settings for a normal return
    set value ""
    set option ""
    set result 0

    # check if we're past the end of the args list
    if {[llength $argsList] != 0} {

	# if we got -- or an option that doesn't begin with -, return (skipping
	# the --).  otherwise process the option arg.
	switch -glob -- [set arg [lindex $argsList 0]] {
	    "--" {
		set argsList [lrange $argsList 1 end]
	    }

	    "-*" {
		set option [string range $arg 1 end]

		if {[lsearch -exact $optstring $option] != -1} {
		    # Booleans are set to 1 when present
		    set value 1
		    set result 1
		    set argsList [lrange $argsList 1 end]
		} elseif {[lsearch -exact $optstring "$option.arg"] != -1} {
		    set result 1
		    set argsList [lrange $argsList 1 end]
		    if {[llength $argsList] != 0} {
			set value [lindex $argsList 0]
			set argsList [lrange $argsList 1 end]
		    } else {
			set value "Option \"$option\" requires an argument"
			set result -1
		    }
		} else {
		    set value "Illegal option \"$option\""
		    set result -1
		}
	    }
	    default {
		# Skip ahead
	    }
	}
    }

    return $result
}

# cmdline::getoptions --
#
#	Process a set of command line options, filling in defaults
#	for those not specified.  This also generates an error message
#	that lists the allowed flags if an incorrect flag is specified.
#
# Arguments:
#	arglistVar	The name of the argument list, typically argv
#	optlist		A list-of-lists where each element specifies an option
#			in the form:
#				(where flag takes no argument) 
#					flag comment 
#
#				(or where flag takes an argument) 
#					flag default comment
#
#			If flag ends in ".arg" then the value is taken from the
#			command line. Otherwise it is a boolean and appears in
#			the result if present on the command line. If flag ends
#			in ".secret", it will not be displayed in the usage.
#	usage		Text to include in the usage display. Defaults to
#			"options:"
#
# Results
#	Name value pairs suitable for using with array set.

proc cmdline::getoptions {arglistVar optlist {usage options:}} {
    upvar 1 $arglistVar argv
    set opts {? help}
    foreach opt $optlist {
	set name [lindex $opt 0]
	if {[regsub -- .secret$ $name {} name] == 1} {
	    # Need to hide this from the usage display and getopt
	}   
	lappend opts $name
	if {[regsub -- .arg$ $name {} name] == 1} {

	    # Set defaults for those that take values.

	    set default [lindex $opt 1]
	    set result($name) $default
	} else {
	    # The default for booleans is false
	    set result($name) 0
	}
    }
    set argc [llength $argv]
    while {[set err [cmdline::getopt argv $opts opt arg]]} {
	if {$err < 0} {
	    error [cmdline::usage $optlist $usage]
	}
	set result($opt) $arg
    }
    if {[info exist result(?)] || [info exists result(help)]} {
	error [cmdline::usage $optlist $usage]
    }
    return [array get result]
}

# cmdline::usage --
#
#	Generate an error message that lists the allowed flags.
#
# Arguments:
#	optlist		As for cmdline::getoptions
#	usage		Text to include in the usage display. Defaults to
#			"options:"
#
# Results
#	A formatted usage message

proc cmdline::usage {optlist {usage {options:}}} {
    set str "[cmdline::getArgv0] $usage\n"
    foreach opt [concat $optlist \
	    {{help "Print this message"} {? "Print this message"}}] {
	set name [lindex $opt 0]
	if {[regsub -- .secret$ $name {} name] == 1} {
	    # Hidden option
	    continue
	}
	if {[regsub -- .arg$ $name {} name] == 1} {
	    set default [lindex $opt 1]
	    set comment [lindex $opt 2]
	    append str [format " %-20s %s <%s>\n" "-$name value" \
		    $comment $default]
	} else {
	    set comment [lindex $opt 1]
	    append str [format " %-20s %s\n" "-$name" $comment]
	}
    }
    return $str
}

# cmdline::getfiles --
#
#	Given a list of file arguments from the command line, compute
#	the set of valid files.  On windows, file globbing is performed
#	on each argument.  On Unix, only file existence is tested.  If
#	a file argument produces no valid files, a warning is optionally
#	generated.
#
#	This code also uses the full path for each file.  If not
#	given it prepends [pwd] to the filename.  This ensures that
#	these files will never comflict with files in our zip file.
#
# Arguments:
#	patterns	The file patterns specified by the user.
#	quiet		If this flag is set, no warnings will be generated.
#
# Results:
#	Returns the list of files that match the input patterns.

proc cmdline::getfiles {patterns quiet} {
    set result {}
    if {$::tcl_platform(platform) == "windows"} {
	foreach pattern $patterns {
	    regsub -all -- {\\} $pattern {\\\\} pat
	    set files [glob -nocomplain -- $pat]
	    if {$files == {}} {
		if {! $quiet} {
		    puts stdout "warning: no files match \"$pattern\""
		}
	    } else {
		foreach file $files {
		    lappend result $file
		}
	    }
	}
    } else {
	set result $patterns
    }
    set files {}
    foreach file $result {
	# Make file an absolute path so that we will never conflict
	# with files that might be contained in our zip file.
	set fullPath [file join [pwd] $file]
	
	if {[file isfile $fullPath]} {
	    lappend files $fullPath
	} elseif {! $quiet} {
	    puts stdout "warning: no files match \"$file\""
	}
    }
    return $files
}

# cmdline::getArgv0 --
#
#	This command returns the "sanitized" version of argv0.  It will strip
#	off the leading path and remove the ".bin" extensions that our apps
#	use because they must be wrapped by a shell script.
#
# Arguments:
#	None.
#
# Results:
#	The application name that can be used in error messages.

proc cmdline::getArgv0 {} {
    global argv0

    set name [file tail $argv0]
    return [file rootname $name]
}


