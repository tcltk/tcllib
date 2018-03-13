###
# topic: e10dc9220800b9649c51f42b176d2d1afa8dc93d
# description:
#    Facilities expected of any object
#    that is marked as a master to a dynamic object
###
tool::define ::tool::ui::stylesheet {
  superclass
  
  property style_prefix {Tool}

  option initial-filepath [list tab General type pathname default [pwd] description {Path where file dialogs open by default}]
  
  option stylelist { default {} }
  
  option color-background [subst {
    signal stylesheet
    usage gui
    tab colors
    type color
    default white
    description {Default background color for windows}
  }]

  option color-row-even {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #BBF
    description {Color of even numbered rows in the display}
  }

  option color-row-odd {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #FFF
    description {Color of even numbered rows in the display}
  }
  option color-red-even {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #F44
    description {Color of even numbered red rows in the display (with error)}
  }
  option color-red-odd {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #F00
    description {Color of even numbered red rows in the display (with error)}
  }

  option color-blue-even {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #44F
    description {Color of even numbered red rows in the display (with error)}
  }
  option color-blue-odd {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #00F
    description {Color of even numbered red rows in the display (with error)}
  }

  option color-green-even {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #4F4
    description {Color of even numbered red rows in the display (with error)}
  }
  option color-green-odd {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #0F0
    description {Color of even numbered red rows in the display (with error)}
  }

  option color-grey-even {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #a0a0a0
    description {Color of even numbered grey rows in the display (with disabled/greyed)}
  }
  option color-grey-odd {
    signal stylesheet
    usage gui
    tab colors
    type color
    default #888
    description {Color of even numbered grey rows in the display (with disabled/greyed)}
  }
  
  option font-button {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default TkDefaultFont
    description {Font used on standard buttons}
  }
  option font-button-bold {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Font used on bold buttons}
  }
  option font-button-small {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Font used on small buttons}
  }
  option font-button-fixed {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Font used on fixed font buttons}
  }
  option font-canvas {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Font used on canvas elements}
  }
  option font-console {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default {fixed 10}
    description {Font used on console widgets}
  }
  option font-editor {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default {fixed 10}
    description {Font used on editable text widgets}
  }
  option font-entry {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default TkDefaultFont
    description {Font used on standard entry boxes}
  }
  option font-fixed {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Standard fixed space font}
  }
  option font-label {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default TkDefaultFont
    description {Font used on standard labels}
  }
  option font-normal {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default {helvetica 10}
    description {Standard proportional font}
  }
  option font-popups {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default-command {my Option_font_default %field%}
    description {Font used on popups}
  }
  option font-text {
    signal stylesheet
    type font
    tab fonts
    usage gui
    default {fixed 10}
    description {Font used on normal text widgets}
  }
  
  option style_background {
    type color
    tab general
    signal stylesheet
    default grey
  }
  
  ###
  # topic: 576dca7d430159ab89fb1130fb72039aba74a5b5
  ###
  method Option_font_default field {
    # Font defaults for generic unix
    switch $field {
      font-fixed        {return {fixed 10}}
      font-button-fixed {return {fixed 12}}
      font-button-small {return {fixed 6}}
      font-button-bold  {return {fixed 12 bold}}
      font-canvas       {return {fixed 10}}
      font-popups       {return {fixed 8}}      
    }
  }

  method TkFontToCSS font {
    set family [lindex $font 0]
    if {$family eq "TkDefaultFont"} {
      set family Helvetica
    } else {
      dict set info -family $family
    }
    if {[lindex $font 1] ne {}} {
      dict set info -size [lindex $font 1]
    } else {
      dict set info -size medium
    }
    switch [lindex $font 2] {
      italic {
        dict set info -style italic
        dict set info -wieght normal
      }
      bold {
        dict set info -style normal
        dict set info -wieght bold
      }
      default {
        dict set info -style normal
        dict set info -wieght normal
      }
    }
    
    set size [dict get $info -size]
    if {[string is integer $size]} {
      append result "font-size:${size}pt\;"
    } else {
      append result "font-size:${size}\;"
    }
    append result "font-family:\"[dict get $info -family]\"\;"
    append result "font-weight:[dict get $info -weight]\;"
    append result "font-style:[dict get $info -slant]\;"
    return $result
  }

  ###
  # title: Return this sheet as a Cascading style sheet
  ###
  method css args {
    my variable css
    if {("reset" ni $args) && [info exists css]} {
      return $css
    }
    set result {}
    
    # Set the background
    append result "body \{"
    append result "background-color:[my cget color-background]\;"
    append result "\}"
    
    # Tweak text
    foreach {taglist option} {
      {p div html} font-normal
      .tkentry font-entry
      .tklabel font-label
      {typewriter verbatim} font-fixed
    } {
      set cssf [my TkFontToCSS [my cget $option]]
      foreach tag $taglist {
        append result "\n$tag \{${cssf}\}"
      }
    }
    foreach {style} {
      row red blue green grey
    } {
      append result "\nroweven$style \{background-color:[my cget color-${style}-even]\;\}"
    }
    set css $result
    return $result
  }
  ###
  # title: Return a row color in the given style
  ###
  method row_color {{row {}} {substyle {}}} {
    if { $row eq {} } {
      my variable Rowcount
      set row $Rowcount
    }
    switch $substyle {
      green {
        if {[expr {$row % 2}]} {
          return [my cget color-green-odd]
        } else {
          return [my cget color-green-even]
        }        
      }
      blue {
        if {[expr {$row % 2}]} {
          return [my cget color-blue-odd]
        } else {
          return [my cget color-blue-even]
        }        
      }
      grey -
      missing {
        if {[expr {$row % 2}]} {
          return [my cget color-grey-odd]
        } else {
          return [my cget color-grey-even]
        }
      }
      red -
      error {
        if {[expr {$row % 2}]} {
          return [my cget color-red-odd]
        } else {
          return [my cget color-red-even]
        }
      }
      default {
        if {[expr {$row % 2}]} {
          return [my cget color-row-odd]
        } else {
          return [my cget color-row-even]
        }
      }
    }
  }
}

