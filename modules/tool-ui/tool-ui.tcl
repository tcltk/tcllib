###
# Amalgamated package for tool-ui
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package require Tcl 8.6
package provide tool-ui 0.2.1
namespace eval ::tool-ui {}

::tool::module push tool-ui
###
# START: baseclass.tcl
###
::namespace eval ::tool::ui {}
::namespace eval ::tool::ui::element  {}
::namespace eval ::tool::ui::datatype {}
set ::tool::ui::datatype::regen 1

tool::define ::tool::ui::datatype {
  property classinfo type core
  variable internalvalue {}
  variable displayvalue {}
  
  meta set is {
    integer: 0
    string:  0
    real:    0
    number:  0
    date:    0
    complex: 0
    boolean: 0
  }
  
  class_method register {name body} {
    ::tool::define ::tool::ui::datatype::$name $body
    set ::tool::ui::datatype::regen 1
  }
  
  method datatype_inferences {options} {}
  
  method is::default {} {
    if {[my meta exists is ${method}]} {
      return [string is true [my meta get is ${method}:]]
    }
    return 0
  }
  
  method Generate_Select_Datatype {} {
    set ::tool::ui::datatype::regen 0
    set nspace [my meta get namespace datatype:]
    set default [my meta get namespace default:]
    set buffer [string map [list %NSPACE% $nspace] {
  set info [my config dump]
  set datatype {}
  foreach param {datatype type field widget storage} {
    if {[set v [dict getnull $info $param]] ne {}} {
      if {[info exists ::oo::dialect::cname(%NSPACE%::${v})]} {
        return $::oo::dialect::cname(%NSPACE%::${v})
      }
      set datatype $v
      break
    }
  }
  if {$%NSPACE%::regen} {
    set body [my Generate_Select_Datatype]
    oo::define [info object class [self]] method Select_Datatype {} $body
    return [my Select_Datatype]
  }
  set storage [dict getnull $info storage]
}]
    append buffer \n {# Adhoc rules}
    foreach {alias class} [lsort -dictionary -stride 2 [array get ::oo::dialect::cname ${nspace}::*]] {
      if {$alias ne $class} continue      
      set cexpr [::oo::meta::localdata $class is claim:]
      if {[string length $cexpr]} {
        append buffer \n [list if $cexpr [list return $class]]
      }
    }
    append buffer \n "  " [list return [info commands ${nspace}::${default}]]
    return $buffer
  }
  
  method Select_Datatype {} {
    set body [my Generate_Select_Datatype]
    oo::define ::tool::ui::datatype method Select_Datatype {} $body
    return [my Select_Datatype]
  }

  method value_display {} {
    my variable displayvalue
    if {![info exists displayvalue]} {
      set displayvalue [my Value_Display [my Value_Get]] 
    }
    return $displayvalue
  }
  
  # title: Format and internally coded value into human readable format
  method Value_Display value {
    if {[::tool::is_null $value]} {
      return {}
    }
    return $value
  }
  
  # title: Convert an internally encoded value to its externally encoded value
  method Value_Export value {
    return $value
  }
  
  # title: Retrieve the internally encoded value stored with Value_Store
  method Value_Get {} {
    my variable internalvalue
    return $internalvalue
  }
  
  # title: Convert an externally encoded value to its internally encoded value
  method Value_Import  value {
    return $value
  }

  # title: Interpret a human editable value into an internally encoded value
  method Value_Interpret  value {
    return $value
  }
 
  # title: Store a value in the internally coded format for later recall
  method Value_Store value {
    my variable internalvalue displayvalue
    set internalvalue $value
    set displayvalue [my Value_Display $value]
  }
  
  method Value_Url {} {
    return {}
  }
}

tool::define ::tool::ui::element {
  superclass ::tool::ui::datatype
  
  property classinfo type core

  option unknown      {default 0}
  option showlabels   {default 1}
  option units        {default {}}
  option data_source  {default {}}
  option label        {default {}}
  option description  {default {}}
  option field        {default {}}
  option textvariable {default {}}
  option readonly     {default 0}
  option command      {default {}}
  option post_command {default {}}
  option colorstate   {default normal}
  option row          {default {}}
  
  variable entryvalue {}

  meta set namespace {
    datatype:     ::tool::ui::datatype
  }
  
  variable displayvalue {}
  
  ###
  # Place to store an internal representation
  # of the value:
  # variable local_value
  ###
  option form {
    class organ
    description {The form we are representing}
  }
  
  constructor {} {}
  
  ###
  # description:
  #    Called during the destructor of taotk widgets prior
  #    to the destruction of tk objects and the unlinking and
  #    destruction of the object and it's subobjects. It gives
  #    complex UIs an easy to maintain shim with which to respond
  #    to the object's destruction, without having to modify the
  #    the (admitedly) complex taotk object destructor.
  ###
  method action::destroy {} {}

  method action::revert_to_default {} {
    set field [my cget field]
    set default [my cget default]
    if {$default in {{} default}} {
      set default [my <form> private Option_Default $field]
    }
    my Value_Store $default
  }

  method ApplySelectedValue newvalue {
    if {[set command [my cget post_command]] ne {}} {
      set field [my cget field]
      eval [string map [list %field% [list $field] %self% [namespace which my] %value% [list $newvalue]] $command]
    }
    if {[set command [my cget command]] ne {}} {
      set field [my cget field]
      eval [string map [list %field% [list $field] %self% [namespace which my] %value% [list $newvalue]] $command]
    }
    set varname [my GlobalVariableName]
    if { $varname ne {} } {
      set $varname $newvalue
    }
  }


  method attach {organs args} {
    my variable field
    my graft {*}$organs

    set dictargs {}
    foreach {dfield dval} [::tool::args_to_options {*}$args] {
      dict set dictargs [string trim $dfield :] $dval
    }
    set options [my inferences [dict merge $dictargs $organs]]
    set form [dict get $options form]
    my config merge $options
    my graft form $form parent $form object $form
    my config merge [list form $form parent $form object $form]
    my <form> formelement register [self] $options
    
    set datatype   [my Select_Datatype]
    my mixinmap datatype $datatype
    if {$datatype ne {}} {
      dict set options datatype [namespace tail $datatype]
    }
    set dopts [my datatype_inferences $options]
    my config merge $dopts
  }
  
  ###
  # description:
  #    This command is run after the arguments are inputted
  #    internally, and should throw an error if a needed argument
  #    was not given a value.
  ###
  method check_required_args {} {
    return {}
  }
  
  method ClearError {} {}

  method DefaultValue {} {
    my variable config
    set getcmd [dict getnull $config default-command]
    if {$getcmd ne {}} {
      return [{*}[string map [list %field% [my cget field] %widget% [namespace which my] %self% [my cget object] %object% [my cget object]] $getcmd]]
    } else {
      return [dict getnull $config default]
    }
  }
  
  # Return descriptive text about this field
  method Description {} {
    return [my cget description]
  }
  
  method display {} {}

  method drawn {} {
    return 1
  }
  method edit {} {}
  
  method inferences {info} {
    set result [dict merge $info [my organ all]]
    set form ::noop
    if {[dict exists $info form]} {
      set form [dict get $info form]    
    } elseif {[dict exists $info object]} {
      set form [dict get $info object]
    } elseif {[dict exists $info parent]} {
      set form [dict get $info parent]
    }
    dict set result form $form
    set field [string tolower [dict get $info field]]
    if {![dict exists $info labels]} {
      dict set result labels 1
    }
    set label {}
    set description {}
  
    if {![dict exists $info units]} {
      dict set result units {}
    }
    foreach mf {desc description comment} {
      if {[dict exists $info $mf]} {
        append description [string trim [dict get $info $mf]]
      }
    }
    if {[dict exists $info label]} {
      set label [dict get $info label]
    }
    if { $label == {} } {
      set label $field
    } else {
      set description "Full Name: $field\n$description"
    }
    
    switch {[dict getnull $info mode]} {
      dynamic -
      spec -
      specs {
        dict set result mode  dynamic
      }
      default {
        dict set result mode  static
      }
    }
    dict set result label $label
    dict set result description $description
    return $result
  }

  method ErrorInvalid {newvalue {error {}} {errdat {}}} {
    puts stderr "Failed to interpret $newvalue : $error"
    puts stderr [dict getnull $errdat -errorinfo]
  }

  # title: Pull the contents from the widget and decode the human-readable input into machine values
  method get {} {
    return [my Value_Export [my Value_Get]]
  }

  method GlobalVariableName {} {
    return [my cget textvariable]
  }

  # title: Pull new contents to the widget and encode the machine value to the human-readable output
  method put value {
    set ivalue [my Value_Import $value]
    my Value_Store $ivalue
    my config merge [list value $value]
  }

  method readonly {} {
    return [string is true -strict [my cget readonly]]
  }
  
  method Validate newvalue {
    if {[catch {
      set ivalue [my Value_Interpret $newvalue]
      my Value_Store $ivalue
      set result [my Value_Export $ivalue]
      my ClearError
      my ApplySelectedValue $result
    } error errdat]} {
      my ErrorInvalid $newvalue $error $errdat
      return 0
    }
    return 1
  }
}



###
# END: baseclass.tcl
###
###
# START: procs.tcl
###
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


###
# END: procs.tcl
###
###
# START: stylesheet.tcl
###
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


###
# END: stylesheet.tcl
###
###
# START: string.tcl
###
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

###
# END: string.tcl
###
###
# START: select.tcl
###

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

###
# END: select.tcl
###
###
# START: form.tcl
###

###
# Basic functions for maintaining a relationship between
# forms and their fields
###
tool::define ::tool::ui::form {

  variable formelement_object {}
  variable formelement_fields {}

  method formelement::register {object info} {
    my variable formelement_object formelement_fields subobjects
    dict set info dobject $object
    if {[dict exists $info field]} {
      set field [dict get $info field]
      if {[dict exists $info subform]} {
        dict set formelement_object {*}[dict get $info subform] $field $object
        dict set formelement_fields $object [list {*}[dict get $info subform] $field]
      } else {
        dict set formelement_object $field $object
        dict set formelement_fields $object $field
      }
    }
    dict set info event 0
    dict set subobjects $object $info
  }
  
  method formelement::field {object} {
    my variable formelement_fields
    return [dict getnull $formelement_fields $object]
  }
  
  method formelement::object {args} {
    my variable formelement_object subobjects formelement_fields
    set dobject {}
    if {[info exists subobjects] && [dict exists $subobjects {*}$args dobject]} {
      set dobject [dict get $subobjects {*}$args dobject]
    } elseif {[info exists formelement_object] && [dict exists $formelement_object [lindex $args 0]]} {
      set dobject [lindex $args 0]
    }
    if {$dobject eq {}} {
      return {}
    }
    if {[info command $dobject] eq {}} {
      my formelement unregister $dobject
      return {}
    }
    return $dobject
  }
  
  method formelement::info {object} {
    my variable subobjects
    return [dict getnull $subobjects $object]
  }
  
  method formelement::unregister object {
    my variable formelement_object formelement_fields subobjects
    catch {dict unset formelement_object {*}$formelement_fields $object}
    catch {dict unset formelement_fields $object}
    catch {dict unset subobjects $object}
  }
  
  method FormRead {args} {
    my variable formelement_object
    if {![info exists formelement_object]} {
      return {}
    }
    set result {}
    foreach dobject [dict getnull $formelement_object {*}$args] {
      if {[info command $dobject] eq {}} continue
      dict set result [$dobject cget field] [$dobject get]
    }
    return $result
  }
  
  method FormReset subform {
    my variable subformrow display_map
    set display_map {}
    unset -nocomplain subformrow
  }
  
  method FormObject {api args} {
    set fconfig [dict merge {*}$args]
    set field   [dict get $fconfig field]
    set subform [dict get $fconfig subform]
    set objname [my SubObject $subform $field]
    if {[info command $objname] eq {}} {
      $api create $objname
    } else {
      if {[info object class $objname] ne $api} {
        $objname destroy
        $api create $objname
      }      
    }
    $objname attach [list form [self]] $fconfig
    return $objname
  }
}
###
# END: form.tcl
###
###
# START: vector.tcl
###
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
###
# END: vector.tcl
###
###
# START: number.tcl
###

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
    if {[lindex $value 2] eq "$system_units" || [lindex $value 0] eq [lindex $value 1]} {
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
    if {$irm_value eq $user_quantity} {
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

  meta set physics units: liter/second
  meta set physics options:  {liter/second gallon/minute}

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
    if {[lindex $value 2] eq "$system_units" || [lindex $value 0] eq [lindex $value 1]} {
      set value [lindex $value 1]
      return "$value ( [::siground::signif [::units::convert [list $value $system_units] celsius] 4]${degsym}C)"
    }
    return "[lindex $value 1] ${degsym}[lindex $value 2] ([lindex $value 0] ${degsym}${system_units})"
  }
}

###
# END: number.tcl
###
###
# START: round.tcl
###
#
# round number to significant digits
# according to 
# http://perfdynamics.blogspot.de/2010/04/significant-figures-in-r-and-rounding.html
# round number num to n significant digits
# works only in the range of double
# it is published under the same licence as Tcl
# (c) J. Heidemeier 2014
#
namespace eval ::siground {}
proc ::siground::signif {num n {decimalPoint .}} {
set orig $num
# arguments:
# num: number to be rounded (integer, real or exponential format)
# n: number of significant digits (positive integer)
# decimalPoint: decimal separator character for the output (default .)
# 
# reasonable figure for significant digits ?
    if {!([string is integer $n] && $n > 0)} \
        {error  "number of significant digits $n is not a positive integer"}
#
# ensure that num is numeric
# and split into sign, integer, decimal and exponent part
#
if {[regexp {^([+,-]?)([0-9]+)(\.?[0-9]*)?([eE][+-]?[0-9]+)?$} $num -> s i d e]} {
# i must contain alt least one digit
if {![string length i]} "error wrong format $num, no digit in Integerpart "
#
# type of number
# 
    set typ ""    
    if {[string length $e]} {set typ e}
    if {[string length $d]} {
        if {$typ ne {e}} {set typ d}
    } else {
        if {$typ ne {e}} {
                set typ i
#
#
#
        } else {
# reformat iexx to i.0exx bringen
            set d {.0}
       }
    }
# remove leading 0, if digits 1-9 in i-part
# or collapse several 0 to 0
#
    if {[string length $i] > 1} {
        regexp  {^(0*)([1-9][0-9]*)$} $i -> NULL DIG
        if {[string length $DIG]} {
            set i $DIG
        } else {
            set i 0 ;# collapse to one 0
        }
    }
#        
# build teststring for rounding process
#
set tstring $i
            
set decpos [expr {[string length $i] -1}]
# skip decimalpoint and append decimalpart
if {[string length $d]} {
       append tstring [string range $d 1 end]
} 
# enough digits for the rounding process       
    set ndigs [string length $tstring]
    if {$ndigs < $n} {
        return $orig
    #    error "more significant digits $n requested than available $ndigs"
    }

# x is the last significant digit
# y and z are the following 2 digits, if y or z are blank
# zeros are appended     
    set x [string index $tstring $n-1]
        if  {$ndigs == $n} {
            set y 0
        } else {
        set y [string index $tstring $n]
    }
    if {$ndigs > $n} {
        set z [string index $tstring $n+1]
    } else {
        set z 0
    }
# the actual test; pad0 pads zeros for the integerpart
    if {$y < 5} {        
        set rstring "[string range $tstring 0 $n-1][pad0 $decpos $n]"
    } elseif {$y > 5} {
         incr x
            set rstring "[string range $tstring 0 $n-2]$x[pad0 $decpos $n]"
    } else {
# y == 5; test for parity jitter
        if {$z >= 1} {
                set rstring "[string range $tstring 0 $n-1][pad0 $decpos $n]"
        } else {
            if {[isOdd $x]} {
                incr x
            }
                set rstring "[string range $tstring 0 $n-2]$x[pad0 $decpos $n]"
        }
    }
} else {
 error "number to round \"$num\" is not numeric"
}
# reformatting the output    
    switch -exact -- $typ {
        i {set result "$s$rstring"}
        d {
            set decfrac [string range $rstring $decpos+1 end]
            if {![string length $decfrac]} {
                set result "$s$rstring"
            } else {
                set result "$s[string range $rstring 0 $decpos]$decimalPoint$decfrac"
            }
        }
        e {
            set result "$s[string range $rstring 0 $decpos]$decimalPoint[string range $rstring $decpos+1 end]$e"
        }
    }
return  $result
}
#
# pad integer part with 0 if necessary
# arguments
# decpos:  index of the last digit before the decimal point
# n:  number of significant digits
#
proc ::siground::pad0 {decpos n} {

    set v {}
    incr decpos
    set x [expr {$decpos - $n}]
    
    if {$x} {
        set v [string repeat 0 $x] 
    }
    return $v
 }

proc ::siground::isOdd n {
    try {
        expr {$n & 1}
    } trap {ARITH DOMAIN} {message options} {
        return -options $options -errorinfo "$n is not an integer"
    }
}

###
# END: round.tcl
###

namespace eval ::tool-ui {
  namespace export *
}

