################################################################################
#     Logger Utilities - XOTcl wrapper for logger
#     
#     A XOTcl class to wrap logger
#     
#     (c) 2005 Michael Schlenker <mic42@users.sourceforge.net>
#     
#     $Id: xotcl-logger.tcl,v 1.2 2005/04/27 02:40:41 andreas_kupries Exp $
#
#################################################################################

package require XOTcl
package require logger

namespace eval ::logger::xotcl {
    
::xotcl::Class Logger -parameter { {servicename -setter _servicenamesetter
                                               -getter _servicenamegetter}
                                   {loglevel debug -setter _loglevelsetter
                                                -getter _loglevelgetter}} 

Logger instproc init {args} {
    ::xotcl::next
}
    
Logger instproc destroy {args} {
    [::xotcl::my  set loggertoken]::delete
    ::xotcl::next
}

Logger instproc log {level args} {
    eval [linsert $args 0 [::xotcl::my set loggertoken]::${level}]   
}     
        
Logger instproc _servicenamesetter {opt val} {
    puts "Servicesetter: $opt / $val"
    if {[llength [::xotcl::my info vars loggertoken]]} {
        if {[::xotcl::my set loggertoken] != ""} {
            [::xotcl::my set loggertoken]::delete
        }
    } else {
        ::xotcl::my set loggertoken ""
    }
    
    if {$val != ""} {
        if {[lsearch -exact [logger::services] $val] == -1} {
            ::xotcl::my set loggertoken [logger::init $val]
            ::xotcl::my set servicename $val
        } else {
            ::xotcl::my set loggertoken [logger::servicecmd $val]
            ::xotcl::my set servicename $val
        }
        
        if {[llength [::xotcl::my info vars loglevel]]} {
            [::xotcl::my set loggertoken]::setlevel [::xotcl::my set loglevel]
        }
    }
    puts "Token set to [::xotcl::my set loggertoken]"
    return $val
}

Logger instproc _servicenamegetter {opt} {
    return [::xotcl::my set servicename]
}

Logger instproc _loglevelsetter {opt val} {
    puts "Loglevel: $opt / $val"
    if {[::xotcl::my set loggertoken] ne ""} {
        puts "Setting loglevel for loggertoken [::xotcl::my set loggertoken] to $val"
        [::xotcl::my set loggertoken]::setlevel $val
    }
    ::xotcl::my set loglevel $val
}

Logger instproc _loglevelgetter {opt} {
    if {[::xotcl::my set loggertoken] ne ""} {
        return [[::xotcl::my set loggertoken]::currentloglevel]
    } else {
        return
    }
}

Logger instproc logproc {args} {
    eval [linsert $args 0 [::xotcl::my set loggertoken]::logproc]       
}

Logger instproc services {} {
    return [[::xotcl::my set loggertoken]::services]
}

Logger instproc delproc {args} {
    eval [linsert $args 0 [::xotcl::my set loggertoken]::delproc]
}

}

package provide ::logger::xotcl 0.1
