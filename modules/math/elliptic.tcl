# elliptic.tcl --
#    Compute elliptic integrals
#

# namespace ::math::special
#
namespace eval ::math::special {
    ::math::constants::constants pi
    variable halfpi [expr {$pi/2.0}]
}

# elliptic_K --
#    Compute the complete elliptic integral of the first kind
#
# Arguments:
#    k            Parameter of the integral
# Result:
#    Value of K(k)
# Note:
#    This relies on the arithmetic-geometric mean
#
proc ::math::special::elliptic_K {k} {
    variable halfpi
    if { $k < 0.0 || $k >= 1.0 } {
        error "Domain error: must be between 0 (inclusive) and 1 (not inclusive)"
    }

    if { $k == 0.0 } {
        return $halfpi
    }

    set a 1.0
    set b [expr {sqrt(1.0-$k*$k)}]

    for {set i 0} {$i < 10} {incr i} {
        set anew [expr {($a+$b)/2.0}]
        set bnew [expr {sqrt($a*$b)}]

        set a $anew
        set b $bnew
        #puts "$a $b"
    }

    return [expr {$halfpi/$a}]
}

# elliptic_E --
#    Compute the complete elliptic integral of the second kind
#
# Arguments:
#    k            Parameter of the integral
# Result:
#    Value of E(k)
# Note:
#    This relies on the arithmetic-geometric mean
#
proc ::math::special::elliptic_E {k} {
   variable halfpi
   if { $k < 0.0 || $k >= 1.0 } {
       error "Domain error: must be between 0 (inclusive) and 1 (not inclusive)"
   }

   if { $k == 0.0 } {
       return $halfpi
   }
   if { $k == 1.0 } {
       return 1.0
   }

   set a      1.0
   set b      [expr {sqrt(1.0-$k*$k)}]
   set sumc   [expr {$k*$k/2.0}]
   set factor 0.25

   for {set i 0} {$i < 10} {incr i} {
       set anew   [expr {($a+$b)/2.0}]
       set bnew   [expr {sqrt($a*$b)}]
       set sumc   [expr {$sumc+$factor*($a-$b)*($a-$b)}]
       set factor [expr {$factor*2.0}]

       set a $anew
       set b $bnew
       #puts "$a $b"
   }

   set Kk [expr {$halfpi/$a}]
   return [expr {(1.0-$sumc)*$Kk}]
}

# some tests --
#
if { 0 } {
set tcl_precision 17
#foreach k {0.0 0.1 0.2 0.4 0.6 0.8 0.9} {
#    puts "$k: [::math::special::elliptic_K $k]"
#}
foreach k2 {0.0 0.1 0.2 0.4 0.6 0.8 0.9} {
    set k [expr {sqrt($k2)}]
    puts "$k2: [::math::special::elliptic_K $k] \
[::math::special::elliptic_E $k]"
}
}

