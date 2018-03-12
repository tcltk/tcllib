tool::define tool::db::meta.schema {

  class_method schema args {
    if {[lindex $args 0] eq "<list>"} {
      return [my meta list schema]
    }
    return [my meta getnull schema {*}$args]
  }

  method schema::<list> {} {
    set result $methodlist
    foreach item [my meta keys schema] {
      lappend result [string trimright $item :]
    }
    return [lsort -dictionary -unique $result]
  }

  method schema::default {} {
    return [my meta cget schema $method]
  }
}
