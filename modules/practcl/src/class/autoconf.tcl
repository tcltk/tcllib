
::oo::class create ::practcl::autoconf {

  ###
  # find or fake a key/value list describing this project
  ###
  method config.sh {} {
    my variable conf_result
    if {[info exists conf_result]} {
      return $conf_result
    }
    set result {}
    set name [my define get name]
    set PWD $::CWD
    set builddir [my define get builddir]
    my unpack
    set srcdir [my define get srcdir]
    if {![file exists $builddir]} {
      my Configure
    }
    set filename [file join $builddir config.tcl]
    # Project uses the practcl template. Use the leavings from autoconf
    if {[file exists $filename]} {
      set dat [::practcl::config.tcl $builddir]
      foreach {item value} [::practcl::sort_dict $dat] {
        dict set result $item $value
      }
      set conf_result $result
      return $result
    }
    set filename [file join $builddir ${name}Config.sh]
    if {[file exists $filename]} {
      set l [expr {[string length $name]+1}]
      foreach {field dat} [::practcl::read_Config.sh $filename] {
        set field [string tolower $field]
        if {[string match ${name}_* $field]} {
          set field [string range $field $l end]
        }
        dict set result $field $dat
      }
      set conf_result $result
      return $result
    }
    ###
    # Oh man... we have to guess
    ###
    set filename [file join $builddir Makefile]
    if {![file exists $filename]} {
      error "Could not locate any configuration data in $srcdir"
    }
    foreach {field dat} [::practcl::read_Makefile $filename] {
      dict set result $field $dat
    }
    set conf_result $result
    cd $PWD
    return $result
  }
}
