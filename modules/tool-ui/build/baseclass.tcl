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


