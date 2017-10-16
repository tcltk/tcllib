###
# Handlers for basic string widgets
###

###
# title: Arbitrary Date/Time
###
::tool::ui::datatype register datetime {

  option display_format {default {}}  
  option output_format  {default {}}
  option gmt {datatype boolean default 0}

  meta branchset is {
    date: 1
  }
  
  method Value_Interpret value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget display_format]
    if { $format ni { {} "unixtime" } } {
      return [clock scan $value -format $format -gmt [my cget gmt]]
    }
    return [clock scan $value]
  }

  method Value_Export value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget output_format]
    if { $format ni { {} "unixtime" } } {
      return [clock format $value -format $format -gmt [my cget gmt]]
    }
    return $value
  }

  method Value_Import  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget output_format]
    if { $format ni { {} "unixtime" } } {
      return [clock scan $value -format $format -gmt [my cget gmt]]
    }
    return [clock scan $value]
  }
  
  method Value_Display  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget display_format]
    if { $format ne {} } {
      return [clock format $value -format $format -gmt [my cget gmt]]
    }
    return [clock format $value -gmt [my cget gmt]]
  }
}

###
# title: unixtime
###
::tool::ui::datatype register unixtime {

  option gmt {datatype boolean default 0}
  option display_format {default {%Y-%m-%d %H:%M:%S}}  

  method Value_Interpret value {
    if {[::tool::is_null $value]} {
      return {}
    }
    return [clock scan $value]
  }

  method Value_Export value {
    if {[::tool::is_null $value]} {
      return {}
    }
    return $value
  }

  method Value_Import  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    if {![string is integer -strict $value]} {
      return [clock scan $value]
    }
    return $value
  }
  
  method Value_Display  value {
    if {[::tool::is_null $value]} {
      return {}
    }
    set format [my cget display_format]
    if { $format ne {} } {
      return [clock format $value -format $format -gmt [my cget gmt]]
    } else {
      return [clock format $value -gmt [my cget gmt]]
    }
  }
}
