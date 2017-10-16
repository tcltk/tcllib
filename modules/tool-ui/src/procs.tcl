::namespace eval ::tool::ui {}

proc ::tool::ui::widget_select {nspace info} {
  set nspace ::[string trimleft $nspace :]
  ###
  # Look for storage specific codes
  ###
  set widget {}
  if {[dict exists $info widget]} {
    set widget [dict get $info widget]
  } else {
    set widget {}
    if {[dict exists $info storage]} {
      set widget [dict get $info storage]
    } else {
      if {[dict exists $info type]} {
        set widget [dict get $info type]
      }
    }
  }
  if {[info command ${nspace}::$widget] ne {} } {
    return ${nspace}::$widget
  }
  if { $widget ne {} } {
    switch $widget {
      bool - boolean - u1 {
        return ${nspace}::boolean
      }
      generic - string - text {
        return ${nspace}::string
      }
      vector {
        return ${nspace}::vector
      }
      longtext -
      blob -
      script {
        return ${nspace}::script
      }
    }
  }
  if {[dict exists $info field]} {
    # Guess based on field name
    set field [dict get $info field]
    
    if {[info command ${nspace}::$field] ne {} } {
      return ${nspace}::$field
    }
  }
  if {[dict exists $info values-format]} {
    switch [dict get $info values-format] {
      enum -
      enumerated -
      select_keyvalue -
      list {
        return ${nspace}::select
      }
    }
  }

  if {[dict exists $info values]} {
    return ${nspace}::select
  }
  if {[dict exists $info range]} {
    return ${nspace}::scale
  }

  if {[dict exists $info history]} {
    if {[string is true [dict get $info history]]} {
      return ${nspace}::history
    }
  }
  return ${nspace}::string
}

