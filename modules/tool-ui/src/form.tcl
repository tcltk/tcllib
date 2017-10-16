
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