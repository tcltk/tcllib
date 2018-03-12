###
# topic: 0f30d28a31ce88dfb36ca1c12b454087
# description:
#    This class is a template for objects that will be managed
#    by an onion class
###
tool::define tao::layer {
  aliases tao.layer
  option prefix {}
  option layer_name {}
  property layer_index_order 0

  constructor {sharedobjects args} {
    foreach {organ object} $sharedobjects {
      my graft $organ $object
    }
    my graft layer [self]
    set dictargs [::oo::meta::args_to_options {*}$args]
    set dat [my Config_merge $dictargs]
    my Config_triggers $dat
  }

  ###
  # topic: ce2844831edfd3d32b7e1044690e978a
  # description: Action to perform when layer is mapped visible
  ###
  method initialize {} {
  }

  ###
  # topic: 88c79c0e9188a477f535b66b01631961
  ###
  method node_is_managed unit {
    return 0
  }

  ###
  # topic: 8cc75f590cfad54a22ff0c454c90561c
  ###
  method type_is_managed unit {
    return [expr {$unit eq [my cget prefix]}]
  }
}

###
# topic: 2dba98b257eea6b843505bd2d4887b8a
# description:
#    A form of megawidget which farms out major functions
#    to layers
###
tool::define tao::onion {
  aliases tao.onion
  variable layers {}

  ###
  # Organs that are grafted into our layers
  ###
  property shared_organs {}

  ###
  # topic: 351937a37f294d3ac235e45b9c2f312e
  ###
  method action::activate_layers {} {}

  ###
  # topic: 81232b0943dce1f2586e0ac6159b1e2e
  ###
  method activate_layers {{force 0}} {
    set self [self]
    my variable layers
    set result {}
    set active [my active_layers]

    ###
    # Destroy any layers we are not using
    ###
    set lbefore [get layers]
    foreach {lname obj} $lbefore {
      if {![dict exists $active $lname] || $force} {
        $obj destroy
        dict unset layers $lname
      }
    }

    ###
    # Create or Morph the objects to represent
    # the layers, and then stitch them into
    # the application, and the application to
    # the layers
    ###
    foreach {lname info} $active {
      set class  [dict get $info class]
      set ordercode [$class meta cget layer_index_order]
      if { $ordercode ni {0 {}} } {
        lappend order($ordercode) $lname $info
      } else {
        lappend order(99) $lname $info
      }
    }
    set shared [my Shared_Organs]

    foreach {ordercode} [lsort -integer [array names order]] {
      set objlist $order($ordercode)
      foreach {lname info} $objlist {
        set created 0
        set prefix [dict get $info prefix]
        set class  [dict get $info class]
        set layer_obj [my SubObject layer $lname]
        dict set layers $lname $layer_obj
        if {[info command $layer_obj] == {} } {
          $class create $layer_obj $shared [dict merge $info [list prefix $prefix layer_name $lname]]
          set created 1
          foreach {organ object} $shared {
            $layer_obj graft $organ $object
          }
        } else {
          foreach {organ object} $shared {
            $layer_obj graft $organ $object
          }
          $layer_obj morph $class
        }
        ::ladd result $layer_obj
        $layer_obj event subscribe [self] *
        $layer_obj initialize
      }
    }

    my action activate_layers
    return $result
  }

  ###
  # topic: 7d8c8694fc10c9e8c5017dfaff4b1b8c
  # description: Returns a list of layers with properties needed to create them
  ###
  method active_layers {} {
    ### Example
    #set result {
    #  xtype     {prefix y class sde.layer.xtype}
    #  eqpt      {prefix e class sde.layer.eqpt}
    #  portal    {prefix p class sde.layer.portal}
    #}
    # return $result
    return {}
  }

  method do args {
    set now [clock seconds]
    foreach {layer obj} [my layers] {
      if [catch {$obj {*}$args} err opts] {
        puts stderr "[self] do lname: $layer object: $obj error: $err"
        puts stderr [dict get $opts -errorinfo]
        return -options $opts $err
      }
    }
  }

  # Onions will pass on all configuration items to its layers
  method Config_triggers dictargs {
    set dat [::tool::args_to_options  [my meta getnull option]]
    ###
    # Apply normal behaviors
    ###
    foreach {field val} $dictargs {
      set script [dict getnull $dat $field post-command]
      if {$script ne {}} {
        {*}[string map [list %field% [list $field] %value% [list $val] %self% [namespace which my]] $script]
      }
    }
    foreach {field val} $dictargs {
      if [catch {
        if {[dict exists $dat $field signal]} {
          my signal {*}[dict get $dat $field signal]
          foreach sig [dict get $dat $field signal] {
            my event generate $signal [list value $val]
          }
        }
        my Option_set $field $val
      } err errdat] {
        # Output trace information to stderr in case of
        # cascading errors
        puts stderr [list [self] bg configure error: field $field val $val]
        puts stderr [dict get $errdat -errorinfo]
        return $err {*}$errdat
      }
    }
    # Generate an event
    my event generate configure $dictargs
    # Pass configure items directly to layers
    foreach {name layerobj} [my layers] {
      $layerobj config set $dictargs
    }
    my Prefs_Store $dictargs
    my lock remove configure
  }

  ###
  # topic: d800511c8a288ee9b935135e56c91a65
  ###
  method layer {item args} {
    set scan [scan $item "%1s%d" class objid]
    switch $scan {
      2 {
        # Search by class/objid
        if { $class eq "y"} {
          foreach {layer obj} [my layers] {
            if { [$obj type_is_managed $item] } {
              if {[llength $args]} {
                return [$obj {*}$args]
              }
              return $obj
            }
          }
        } else {
          # Search my node if we have a prefix/number
          foreach {layer obj} [my layers] {
            if { [$obj node_is_managed $item] } {
              if {[llength $args]} {
                return [$obj {*}$args]
              }
              return $obj
            }
          }
        }
      }
      default {
        # Search my name/prefix
        foreach {layer obj} [my layers] {
          if { [string match $item $layer] } {
            if {[llength $args]} {
              return [$obj {*}$args]
            }
            return $obj
          }
          set data [my active_layers]
          if { [string match $item [dict get $data $layer prefix]] } {
            if {[llength $args]} {
              return [$obj {*}$args]
            }
            return $obj
          }
        }
        # Search by string
        ###
        # Search by type
        ###
        foreach {layer obj} [my layers] {
          if { [$obj type_is_managed $item] } {
            if {[llength $args]} {
              return [$obj {*}$args]
            }
            return $obj
          }
        }
        ###
        # Search fall back to search by node
        ###
        foreach {layer obj} [my layers] {
          if { [$obj node_is_managed $item] } {
            if {[llength $args]} {
              return [$obj {*}$args]
            }
            return $obj
          }
        }
      }
    }
    return ::noop
  }

  ###
  # topic: 75d06860b688273777a17cafb45710de
  # description: Return a list of layers for this application
  ###
  method layers {} {
    set result {}
    my variable layers
    if {![info exists layers]} {
      my activate_layers
    }
    return $layers
  }

  ###
  # topic: 96201b2abf6901f5750499e903be1351
  ###
  method Shared_Organs {} {
    dict set shared master [self]
    foreach organ [my meta cget shared_organs] {
      set obj [my organ $organ]
      if { $obj ne {} } {
        dict set shared $organ $obj
      }
    }
    return $shared
  }

  ###
  # topic: b1fe13c9c2f33fb26b71b03c7cb1d0a5
  ###
  method SubObject::layer name {
    return [namespace current]::SubObject_Layer_$name
  }
}
