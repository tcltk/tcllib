
::tool::ui::datatype register boolean {
  aliases bool u1

  meta branchset is {
    number:  1
    integer: 1
    boolean: 1
    real: 1
  }

  method datatype_inferences info {
    set result {}
    if {[dict isnull $info storage]} {
      dict set result storage boolean
    }
    if {[dict isnull $info widget]} {
      dict set result widget boolean
    }
    return $result
  }

  method Value_Export value {
    return [string is true -strict $value]
  }

  method Value_Import  value {
    return [string is true -strict $value]
  }

}

::tool::ui::datatype register number {
  meta branchset is {
    number:  1
    integer: 1
    real:    1
    ranged:  0
  }
  option range {default {}}
  option divisions {default 0}

  method Range {} {
    return [my cget range]
  }

  method Value_Import value {
    if { $value in {NULL {}} } {
      return [my cget default]
    }
    return $value
  }


  method Value_Interpret value {
    if { $value in {NULL {}} } {
      return [my cget default]
    }
    set range [my Range]
    if {[llength $range]==0} {
      return $value
    }
    set from [lindex $range 0]
    set to   [lindex $range 1]
    if { $to eq {} } {
      set to 1.0
    }
    if { $from eq {} } {
      set from 0.0
    }
    set divisions [my cget divisions]
    if {$value > $to} {
      return $to
    } elseif {$value < $from} {
      return $from
    } elseif {[set divisions [my cget divisions]]>0} {
      return [expr {round((($value-$from)/($to-$from)*$divisions))/$divisions*($to-$from)+$from}]
    }
    return $value
  }
}

# title: Integer UI
::tool::ui::datatype register integer {
  aliases u2 u3 u4 u5 u6 u7 u8 u16 u32 u64 long time timer {long long}
  superclass number
  meta branchset is {
    number:  1
    integer: 1
    real:    0
    claim:   {$datatype in {int integer unsigned uint long {long long} time timer} || ([string index $datatype 0] eq "u" && [string is integer -strict [string range $datatype 1 end]])}
  }
  option format {default %d}

  method datatype_inferences info {
    set result {}
    if {[dict isnull $info storage]} {
      foreach field {datatype type} {
        set v [dict getnull $info $field]
        if {$v ne {}} {
          dict set result storage $v
          break
        }
      }
      dict set result storage int
    }
    return $result
  }

  method Value_Import value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget format]
    set c [scan $value $format newvalue]
    if {![info exists newvalue]} {
      error "Bad value $value"
    }
    return $newvalue
  }

  method Value_Display  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget format]
    set c [scan $value $format newvalue]
    if {![info exists newvalue]} {
      error "Bad value $value"
    }
    return $newvalue
  }
}

# title: real
::tool::ui::datatype register real {
  aliases float double widedouble
  superclass number
  meta branchset is {
    number:  1
    integer: 0
    real:    1
  }
  option format {default %g}

  method datatype_inferences info {
    set result {}
    if {[dict isnull $info storage]} {
      foreach field {datatype type} {
        set v [dict getnull $info $field]
        if {$v ne {}} {
          dict set result storage $v
          break
        }
      }
      dict set result storage double
    }
    return $result
  }

  method Value_Display  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget format]
    set c [scan $value $format newvalue]
    if {![info exists newvalue]} {
      error "Bad value $value"
    }
    return $newvalue
  }
}

::tool::ui::datatype register percentage {
  superclass real
  option divisions {default 1000.0}
  meta branchset is {
    ranged:  1
    match: {$datatype in {percent percentage %}}
  }

  method Value_Interpret value {
    if {[::tool::is_null $value]} {
      return [my cget default]
    }
    if {$value > 100.0} {
      return 100.0
    } elseif {$value < 0.0} {
      return 0.0
    } elseif {[set divisions [my cget divisions]]>0} {
      return [expr {round($value*$divisions)/$divisions}]
    }
    return $value
  }

  method Range {} {
    return {0.0 100.0}
  }
}


# title: A real number between zero ane one
::tool::ui::datatype register kronecker {
  superclass real
  meta branchset is {
    ranged:  1
    match: {$datatype in {kronecker unit kronecker_delta}}
  }
  # When displaying on a scale, get
  # to the nearest 0.05
  option divisions {default 0}

  method Value_Interpret value {
    if {[::tool::is_null $value]} {
      return [my cget default]
    }
    if {$value > 1.0} {
      return 1.0
    } elseif {$value < 0.0} {
      return 0.0
    } elseif {[set divisions [my cget divisions]]>0} {
      return [expr {round($value*$divisions)/$divisions}]
    }
    return $value
  }

  method Range {} {
    return {0.0 1.0}
  }
}

# title: A value which stores a physical quantity that can be expressed in multiple units
::tool::ui::datatype register physics {
  superclass real

  option delimeter {default "*"}
  option units {}

  method unit_info {specinfo} {
    my variable system_units system_options
    set result {}
    set system_units [dict getnull $specinfo units]
    if {[::tool::is_null $system_units]} {
      set system_units [my meta get physics units:]
      dict set result units $system_units
    }
    set system_options [dict getnull $specinfo options]
    if {[::tool::is_null $system_options]} {
      set system_options [my meta getnull physics options:]
      dict set result options $system_options
    }
    if {$system_units ni $system_options} {
      lappend system_option $system_units
      dict set result options $system_options
    }
    return $result
  }

  method datatype_inferences specinfo {
    set result {}
    set widget [dict getnull $specinfo widget]
    if {[::tool::is_null $widget]} {
      dict set result widget physics
    }
    set format [dict getnull $specinfo format]
    if {[::tool::is_null $format]} {
      dict set result format %s
    }
    foreach {f v} [my unit_info $specinfo] {
      dict set result $f $v
    }
    return $result
  }

  method Value_Store value {
    my variable irm_value user_value user_units system_units displayvalue internalvalue
    if {![info exists system_units]} {
      set system_units [my cget units]
    }
    if {[::tool::is_null $value]} {
      set irm_value   {}
      set user_value  {}
      set displayvalue {}
      set internalvalue {}
      set user_units {}
      return {}
    }
    set value [string map {+ { } , { } * { } x { }} $value]
    set irm_value   [lindex $value 0]
    set user_value  [lindex $value 1]
    if {[llength $value]==1} {
      set user_units $system_units
      set user_value $irm_value
      set internalvalue $irm_value
      set displayvalue [my Value_Display $irm_value]
    } elseif {[llength $value]==0 || [::tool::is_null $user_value]} {
      set user_units $system_units
      set user_value $irm_value
      set internalvalue {}
      set displayvalue  {}
    } else {
      set user_units   [lindex $value 2]
      set internalvalue [list $irm_value $user_value $user_units]
      set displayvalue [my Value_Display $internalvalue]
    }
  }

  method Value_Get {} {
    my variable irm_value user_value user_units
    if {[::tool::is_null $irm_value]} {
      return {}
    }
    return [list $irm_value $user_value $user_units]
  }

  method Value_Display value {
    if {[::tool::is_null $value]} {
      return {}
    }
    my variable system_units
    set value [string map {+ { } , { } * { } x { }} $value]
    if {![info exists system_units]} {
      return $value
    }
    if {[llength $value]<2 || [lindex $value 1] eq {}} {
      return $value
    }
    if {[lindex $value 2] eq "$system_units" || [lindex $value 0]==[lindex $value 1]} {
      return "[lindex $value 0] $system_units"
    }
    return "[lindex $value 1] [lindex $value 2] ([lindex $value 0] ${system_units})"
  }

  method Value_Interpret newvalue {
    if { $newvalue in {NULL {}} } {
      return [my cget default]
    }
    my variable system_units
    if {[llength $newvalue]==2} {
      set irm_value [::siground::signif [::units::convert $newvalue $system_units] 6]
      return [list $irm_value {*}$newvalue]
    }
    set irm_value [lindex $newvalue 0]
    set human_value [lrange $newvalue 1 end]
    if {[llength $human_value]==0} {
      return $irm_value
    }
    if {[llength $human_value]==1} {
      return [lindex $human_value 0]
    }
    if {[string index $human_value 0] eq "."} {
      set human_value 0$human_value
    }
    set irm_value [::siground::signif [::units::convert $human_value $system_units] 6]
    set user_quantity [::siground::signif [lindex $human_value 0] 6]
    if {$irm_value == $user_quantity} {
      return [lindex $human_value 0]
    }
    return [list $irm_value {*}$human_value]
  }
}

::tool::ui::datatype register volume {
  superclass physics

  meta set physics units: m^3
  meta set physics options:  {liters gallons m^3}
}

::tool::ui::datatype register length {
  superclass physics

  meta set physics units: meter
  meta set physics options:  {meter feet inch mile km mm cm}
}

::tool::ui::datatype register flow {
  superclass physics

  meta set physics units: liters/second
  meta set physics options:  {liters/second gallons/minute}

}

::tool::ui::datatype register power {
  superclass physics

  meta set physics units: watt
  meta set physics options:  {watt kw hp}
}

::tool::ui::datatype register temperature {
  superclass physics

  meta set physics units: celsius
  meta set physics options:  {kelvin celsius farhenheit}
}

::tool::ui::datatype register kelvin {
  superclass physics

  meta set physics units: kelvin
  meta set physics options:  {kelvin celsius farhenheit}
  method Value_Display value {
    if {[::tool::is_null $value]} {
      return {}
    }
    my variable system_units
    set degsym "\xB0"
    if {[llength $value]<2 || [lindex $value 1] eq {}} {
      return "$value ( [::siground::signif [::units::convert [list $value $system_units] celsius] 4]${degsym}C)"
    }
    if {[lindex $value 2] eq "$system_units" || [lindex $value 0] == [lindex $value 1]} {
      set value [lindex $value 1]
      return "$value ( [::siground::signif [::units::convert [list $value $system_units] celsius] 4]${degsym}C)"
    }
    return "[lindex $value 1] ${degsym}[lindex $value 2] ([lindex $value 0] ${degsym}${system_units})"
  }
}
