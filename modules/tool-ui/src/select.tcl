
::tool::ui::datatype register select {
  meta set is claim: {[dict getnull $info values-format] eq "list"}
  option values {}
  option cache-values {type: boolean default: 1}
  
  option state {
    widget select
    values {normal readonly disabled}
    default readonly
  }

  method datatype_inferences {options} {
    set result {}
    if {[dict isnull $options widget]} {
      dict set result widget select
    }
    if {[dict isnull $options state]} {
      dict set result state readonly
    }
    return $result
  }

  method CalculateValues {} {
    set values [my GetConfigValueList]
    return $values
  }

  method CalculateValueWidth values {
    set w 0
    set n 0
    foreach v $values {
      incr n
      set l [string length $v]
      incr bins($l)
      if {$l > $w} {
        set w $l
      }
    }
    if { $w > 30} {
      set w 30
    }
    return $w
  }
  
  method Description {} {
    set text [my cget description]
    set thisline {}
    set values [my CalculateValues]
    set format [my cget values-format]
    append text \n "Possible Values:"
    foreach value [my CalculateValues] {
      if {[string length $thisline]>40} {
        append text \n [string trim $thisline]
        set thisline {}
      }
      append thisline " $value"
    }
    append text \n [string trim $thisline]
    return $text
  }

  method GetConfigValueList {} {
    my variable config values
    if {[info exists values]} {
      return $values
    }
    foreach opt {values-command options_command} {
      if {[dict exists $config $opt]} {
        set script [string map [list %field% [dict getnull $config field] %config% $config] [dict get $config $opt]]
        if {[catch $script cvalues]} {
          puts "Warning: Error computing values for $field: $values"
          set cvalues {}
        } else {
          if {[llength $cvalues]} {
            return $cvalues
          }
        }
      }
    }
    if {[dict exists $config options]} {
      set values [dict get $config options]
      if {[llength $values]} {
        return $values
      }
    }
    if {[dict exists $config values]} {
      set values [dict get $config values]
    }
    if {![info exists values]} {
      set values {}
    }
    return $values
  }
}

::tool::ui::datatype register select_keyvalue {
  superclass select

  option accept_number {
    datatype boolean
    default 1
  }
  
  method CalculateValues {} {
    set values [my GetConfigValueList]
    set result {}
    foreach {key value} $values {
      lappend result $key
    }
    return $result
  }

  method Description {} {
    set text [my cget description]
    append text \n "Possible Values:"
    foreach {key value} [my GetConfigValueList] {
      append text \n " * $key - $value"
    }
    return $text
  }
  
  method Value_Export rawvalue {
    set values [my GetConfigValueList]
    foreach {var val} $values {
      if {$rawvalue eq $val} {
        return $val
      }
      if {$rawvalue eq $var} {
        return $val
      }
    }
    return $rawvalue
  }

  method Value_Interpret  rawvalue {
    set values [my GetConfigValueList]
    foreach {var val} $values {
      if {$rawvalue eq $val} {
        return $var
      }
      if {$rawvalue eq $var} {
        return $var
      }
    }
    if {[my cget accept_number]} {
      if {[string is double $rawvalue]} {
        return $rawvalue
      }
    }
    error "Invalid Value \"$rawvalue\". Valid: [join [dict keys $values] ,]"
  }
}

::tool::ui::datatype register enumerated {
  aliases enum
  superclass select
  meta branchset is {
    number:  1
    integer: 1
    real:    0
  }

  option enum {
    default {}
  }

  method CalculateValues {} {
    set values {}
    foreach {id code comment} [my GetConfigValueList] {
      lappend values "$id - $code $comment"
    }
    return $values
  }
  
  method Description {} {
    set text [my cget description]
    append text \n "Possible Values:"
    foreach {id code comment} [my GetConfigValueList] {
      append text \n " * $id - ($code) $comment"
    }
    return $text
  }

  method Value_Interpret value {
    set value [lindex $value 0]
    foreach {id code comment} [my GetConfigValueList] {
      if {$value == $id } {
        return $id
      }
    }
    return {}
  }

  method Value_Display value {
    if {[::tool::is_null $value]} {
      return {}
    }
    foreach {id code comment} [my GetConfigValueList] {
      if { [lindex $value 0] == $id } {
        return "$id - $code"
      }
    }
    return $value
  }
}
