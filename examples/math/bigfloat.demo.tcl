########################################################################
# BigFloat for Tcl
# Copyright (C) 2003-2004  ARNOLD Stephane
#
# BIGFLOAT LICENSE TERMS
#
# This software is copyrighted by Stephane ARNOLD, (stephanearnold <at> yahoo.fr).
# The following terms apply to all files associated
# with the software unless explicitly disclaimed in individual files.
#
# The authors hereby grant permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
#
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
#
# GOVERNMENT USE: If you are acquiring this software on behalf of the
# U.S. government, the Government shall have only "Restricted Rights"
# in the software and related documentation as defined in the Federal
# Acquisition Regulations (FARs) in Clause 52.227.19 (c) (2).  If you
# are acquiring the software on behalf of the Department of Defense, the
# software shall be classified as "Commercial Computer Software" and the
# Government shall have only "Restricted Rights" as defined in Clause
# 252.227-7013 (c) (1) of DFARs.  Notwithstanding the foregoing, the
# authors grant the U.S. Government and others acting in its behalf
# permission to use and distribute the software in accordance with the
# terms specified in this license.
#
# Web site : http://sarnold.free.fr/
########################################################################

set nbButtons 0
proc addButton {command} {
    global nbButtons
    set ::buttons($nbButtons,command) $command
    set ::buttons($nbButtons,texte) $command
    incr nbButtons
}

proc addButtonF {commande} {
    addButton $commande
    proc $commande {} "pop a
    isFloat \$a
    fpush \[::math::bigfloat::$commande \[lindex \$a 1\]\]"
}


proc addButtonI {commande} {
    addButton $commande
    proc $commande {} "pop a
    isFloat \$a
    ipush \[::math::bigfloat::$commande \[lindex \$a 1\]\]"
}


proc drawButtons {} {
    global nbButtons
    set nbLines [expr {int(sqrt($nbButtons))}]
    for {set i 0} {$i<$nbButtons} {incr i} {
        set col [expr {$i%$nbLines}]
        set line [expr {$i/$nbLines}]
        set commande $::buttons($i,command)
        set texte $::buttons($i,texte)
        button .functions.$commande -text $texte -command $commande
        grid .functions.$commande -column $col -row $line -in .functions
        
    }
}

proc initStack {} {
    set ::stack {}
    foreach i {1 2 3 4} {
        frame .stack.f$i
        pack .stack.f$i -in .stack -side top
        label .stack.f$i.i -text "$i :"
        pack .stack.f$i.i -in .stack.f$i -anchor w -side left
        label .stack.f$i.l -text "Empty"
        pack .stack.f$i.l -in .stack.f$i -anchor e -side right
        
    }
    drawStack
}

proc FloatPush {} {
    set x [split $::bigfloat e]
    set mantissa [lindex $x 0][math::bigfloat::zero $::zeros]
    if {[llength $x]>1} {
        append mantissa e[lindex $x 1]
    }
    lappend ::stack [list Float\
           [math::bigfloat::fromstr $mantissa]]
    set ::bigfloat 0.0
    set ::zeros 1
}

proc IntPush {} {
    lappend ::stack [list Int $::integer]
    set ::integer 0
    drawStack
}

proc toStrInt {n} {
    set resultat ""
    while {[string length $n]>80} {
        append resultat "[string range $n 0 79]...\n"
        set n [string range $n 80 end]
    }
    append resultat $n
}
proc toStrFloat {x} {
    set resultat ""
    set n [math::bigfloat::tostr $x]
    while {[string length $n]>80} {
        append resultat "[string range $n 0 79]...\n"
        set n [string range $n 80 end]
    }
    append resultat $n
}

proc drawStack {args} {
    set l [lrange $::stack end-3 end]
    for {set i 4} {$i>[llength $l]} {incr i -1} {
        .stack.f[expr {5-$i}].l configure -text "Empty"
    }
    for {set i 0} {$i<[llength $l]} {incr i} {
        foreach {type valeur} [lindex $l end-$i] {break}
        .stack.f[expr {4-$i}].l configure -text [toStr$type $valeur]
    }
}

proc init {} {
    wm title . "BigFloatDemo 1.0"
    source bigfloat.tcl
    # the stack (for RPN)
    frame .stack
    pack .stack
    initStack
    # the commands for input
    set c [frame .commands]
    pack $c
    set ::bigfloat 0.0
    entry $c.bigfloat -textvariable ::bigfloat
    pack $c.bigfloat -in $c -side left
    label $c.labelZero -text "add precision"
    pack $c.labelZero -in $c -side left
    set ::zeros 1
    entry $c.zeros -textvariable ::zeros -width 5
    pack $c.zeros -in $c -side left
    button $c.fenter -text "Push float" -command FloatPush
    pack $c.fenter -in $c -side left
    set ::integer 0
    set d [frame .icommands]
    pack $d
    entry $d.integer -textvariable ::integer
    pack $d.integer -in $d -side left
    button $d.ienter -text "Push integer" -command IntPush
    pack $d.ienter -in $d -side left
    # the functions for numbers
    frame .functions
    pack .functions
    set f .functions
    # chaque fonction est associée, d'une part,
    # à un bouton portant un libellé, et d'autre part
    # à une commande Tcl
    # ici nous associons le bouton "add" à la commande "add"
    addButton add
    # toutes ces commandes se trouvent à la fin de ce fichier
    addButton sub
    addButton mul
    addButton div
    addButton mod
    addButtonF opp
    addButtonF abs
    addButtonI round
    addButtonI ceil
    addButtonI floor
    addButton pow
    addButtonF sqrt
    addButtonF log
    addButtonF exp
    addButtonF cos
    addButtonF sin
    addButtonF tan
    addButtonF acos
    addButtonF asin
    addButtonF atan
    addButtonF cotan
    addButtonF cosh
    addButtonF sinh
    addButtonF tanh
    addButton pi
    addButton del
    addButton swap
    addButton help
    addButton save
    addButton exit
    drawButtons
}

################################################################################
# procedures that corresponds to functions (add,mul,etc.)
################################################################################

proc save {} {
    set fichier [tk_getSaveFile -filetypes {{{Text Files} {.txt}}} -title "Save the stack as ..."]
    if {$fichier == ""} {
        error "You should give a name to the file. Aborting saving operation. Sorry."
    }
    if {[catch {set file [open $fichier w]}]} {
        error "Write impossible on file : '$fichier'"
    }
    foreach i $::stack {
        foreach {type valeur} $i {
            switch -- $type {
                Int {puts $file $valeur}
                Float -
                default {puts $file [::math::bigfloat::tostr $valeur]}
            }
        }
    }
    close $file
}

proc help {} {
    toplevel .help
    text .help.texte -width 80 -height 25
    pack .help.texte -in .help
    set fd [open license_terms.txt]
    .help.texte insert 0.0 [read $fd]
    close $fd
    .help.texte configure -state disabled
    button .help.bouton -text "I Agree" -command {destroy .help}
    pack .help.bouton -in .help
}

proc del {} {
    if {[llength $::stack]==1} {
        set ::stack {}
    } else  {
        set ::stack [lrange $::stack 0 end-1]
    }
}

proc swap {} {
    set last [lindex $::stack end]
    lset ::stack end [lindex $::stack end-1]
    lset ::stack end-1 $last
}

proc isFloat {data} {
    if {![string equal [lindex $data 0] Float]} {
        error "The argument : [lindex $data 1] has to be a float"
    }
}

proc isInt {data} {
    if {![string equal [lindex $data 0] Int]} {
        error "The argument has to be an integer"
    }
}



proc pop {varname} {
    if {[llength $::stack]==0} {
        error "too few arguments in the stack"
    }
    upvar $varname out
    set out [lindex $::stack end]
    set ::stack [lrange $::stack 0 end-1]
    return
}

proc fpush {x} {
    lappend ::stack [list Float $x]
}

proc ipush {x} {
    lappend ::stack [list Int $x]
}

proc push {x} {
    if {[::math::bigfloat::isInt $x]} {ipush $x} else {fpush $x}
}
proc add {} {
    pop a
    pop b
    set resultat [math::bigfloat::add [lindex $a 1] [lindex $b 1]]
    push $resultat
}

proc sub {} {
    pop a
    pop b
    set resultat [math::bigfloat::sub [lindex $a 1] [lindex $b 1]]
    push $resultat
}

proc mul {} {
    pop a
    pop b
    set resultat [math::bigfloat::mul [lindex $a 1] [lindex $b 1]]
    push $resultat
}

proc div {} {
    pop a
    pop b
    set resultat [math::bigfloat::div [lindex $a 1] [lindex $b 1]]
    push $resultat
}

proc mod {} {
    pop a
    pop b
    set resultat [math::bigfloat::mod [lindex $a 1] [lindex $b 1]]
    push $resultat
}

proc pow {} {
    pop a
    pop b
    isInt $b
    push [math::bigfloat::pow [lindex $a 1] [lindex $b 1]]
}


proc pi {} {
    pop a
    isInt $a
    push [math::bigfloat::pi [lindex $a 1]]
}

# initialise la calculatrice en créant l'interface GUI
init
# chaque fois qu'une commande modifie la pile de nombres,
# la commande drawStack sera appelée pour la réactualiser
trace add variable stack write drawStack
