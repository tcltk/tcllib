###
# title: Vector
###
::tool::ui::datatype register vector {
  superclass ::tool::ui::form
  property vector_fields {
    x {type real format {%g} width 10}
    y {type real format {%g} width 10}
    z {type real format {%g} width 10}
  }
  
  method datatype_inferences options {
    set result {}
    if {[dict isnull $options widget]} {
      dict set result widget vector
    }
    return $result
  }
  
  method Value_Export newvalue {
    set result {}
    array set content $newvalue
    foreach {vfield info} [my Vector_Fields]  {
      set format [if_null [dict getnull $info format] %s]
      set newvalue [format $format $content($vfield)]
      lappend result $newvalue
    }
    return $result
  }
  
  method Vector_Fields {} {
    return [my meta cget vector_fields]
  }

  method Value_Get {} {
    my variable local_array
    return [array get local_array]
  }
  
  method Value_Store value {
    my variable local_array internalvalue displayvalue
    if {[::tool::is_null $value] || $value eq "0"} {
      set internalvalue {}
      set displayvalue {}
      return
    }
    array set local_array $value
    foreach {field val} [array get local_array] {
      dict set internalvalue $field $val
      set obj [my formelement object $field]
      if {$obj ne {}} {
        $obj put $val
      }
    }
    set displayvalue [my Value_Display $internalvalue]
  }
  
  method Value_Import  inputvalue {
    set idx -1
    foreach {vfield info} [my Vector_Fields] {
      incr idx
      set format [if_null [dict getnull $info format] %s]
      set value [lindex $inputvalue $idx]
      if {[dict exists $info default]} {
        if {$value eq {}} {
          set value [dict get $info default]
        }
      }
      if {$value eq {}} {
        set local_array($vfield) $value
      } elseif { $format in {"%d" int integer} } {
        if [catch {expr {int($value)}} nvalue] {
          puts "Err: $format $vfield. Raw: $value. Err: $nvalue"
          dict set result $vfield $value
        } else {
          dict set result $vfield $nvalue
        }
      } else {
        if [catch {format $format $value} nvalue] {
          puts "Err: $vfield. Raw: $value. Err: $nvalue"
          dict set result $vfield $value
        } else {
          dict set result $vfield $nvalue
        }
      }
    }
    return $result
  }
}