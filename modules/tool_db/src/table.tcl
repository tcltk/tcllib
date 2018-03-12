###
# topic: 4f78c3dbc3f04099f8388b0aaf87df97
# description:
#    This class abstracts the normal operations undertaken
#    my containers and nodes that write to a single data table
###
tool::define tool::db::table {
  superclass  tool::db::meta.schema

  # Properties that need to be set:
  # table - SQL Table
  # primary_key - Primary key for the sql table
  # default_record - Key/value list of defaults

  method reload script {
    namespace unknown []
    # Reset configuration
    my variable config
    set config {}
    set buffer {}
    set thisline {}
    foreach line [split $script \n] {
      append thisline $line
      if {![info complete $thisline]} {
        append thisline \n
        continue
      }
      set thisline [string trim $thisline]
      if {[string index $thisline 0] eq "#"} continue
      if {[string length $thisline]==0} continue
      switch [lindex $thisline 0] {
        schema -
        field {
          my meta set {*}$thisline
        }
        my {
          putb buffer $thisline
        }
        default {
          putb buffer "my $thisline"
        }
      }
      set thisline {}
    }
    eval $buffer
    my Sql_Dynamic_Methods
  }


  method Sql_Dynamic_Methods {} {
    ###
    # Burn in the record_put method
    ###
    set schema [my meta branchget schema]
    dict with schema {}
    set body {}
    putb body "    set stmtl {}"
    putb body "    my <db> eval \{select * from $table where $primary_key=:key\} oldrec break"
    putb body "    foreach {field value} \$info \{"
    putb body {      if {[get oldrec($field)] eq $value} continue}
    putb body "      switch \$field \{"
    foreach {field info} [my meta branchget field] {
      if {[dict getnull $info type] eq "real"} {
        putb body "      [list $field] \{set record($field) \$value \; lappend stmtl $field=round(:record($field),4)\}"
      } else {
        putb body "      [list $field] \{set record($field) \$value \; lappend stmtl $field=:record($field)\}"
      }
    }
    putb body "      \}
    \}
    if \{\[llength \$stmtl\]==0\} return
    if \{!\[my <db> exists \{select $primary_key from $table where $primary_key=:key\}\]\} \{
       my <db> eval \{insert into $table ($primary_key) VALUES (:key)\}
    \}
    my <db> eval \"update $table set \[join \$stmtl ,\] where $primary_key=:key\"
"

    oo::objdefine [self] method record_put {key info} $body
    oo::objdefine [self] method db_record_save {key info} $body

    set body {}
    putb body "my <db> eval \{select * from $table where $primary_key=:key\} result break\;"
    putb body {
  unset result(*)
  return [array get result]
    }
    oo::objdefine [self] method record_get {key} $body

    oo::objdefine [self] method exists key "return \[my <db> exists \{select $primary_key from $table where $primary_key=:key\}\]"
  }

  method integer_key name {
    my meta set schema primary_key $name
    my meta set field $name sql {INTEGER PRIMARY KEY AUTOINCREMENT}
  }
  method string_key name {
    my meta set schema primary_key $name
    my meta set field $name sql {STRING PRIMARY KEY}
  }


  method create_sql {} {
    set result {}
    set tabname [my schema table]
    putb result "drop table if exists $tabname;"
    if {![my meta exists schema create_sql]} {
      set sql {}
      putb sql "create table $tabname \("
      set fieldlist {}
      foreach {field info} [my meta get field] {
        set line "$field"
        if {[dict exists $info sql]} {
          append line " [dict get $info sql]"
        } else {
          if {[dict exists $info storage]} {
            append line "  [string toupper [dict get $info storage]]"
          } elseif {[dict exists $info type]} {
            append line "  [string toupper [dict get $info type]]"
          }
          if {[dict exists $info key]} {
            append line "  [dict get info $key]"
          }
          if {[dict exists $info references]} {
            append line " REFERENCES [dict get $info references]"
          }
          if {[dict exists $info default]} {
            set dflt [dict get $info default]
            if {$dflt eq "NULL"} {
              append line " DEFAULT NULL"
            } elseif {[string is double -strict $dflt]} {
              append line " DEFAULT $dflt"
            } else {
              append line " DEFAULT '$dflt'"
            }
          }
        }
        lappend fieldlist $line
      }
      putb sql [join $fieldlist ",\n"]
      if {[my meta exists schema sql table_extra:]} {
        putb sql [my meta get schema sql table_extra]
      }
      putb sql "\)\;"
      if {[my meta exists schema sql index:]} {
        putb sql [my meta get schema sql index:]
      }
      my meta set schema create_sql $sql
    }
    putb result [my schema create_sql]
    return $result
  }

  ###
  # topic: 6283f1ecde341c8b7dc0199226cfad86
  # title: Delete a record from the database backend
  ###
  method db_record_delete nodeid {
    set table [my schema table]
    set primary_key [my schema primary_key]
    my <db> change "delete from $table where $primary_key=:nodeid"
  }

  ###
  # topic: d4c5e9cfea2fa029e80ac21e3173a702
  ###
  method db_record_exists nodeid {
    set table [my schema table]
    set primary_key [my schema primary_key]
    return [my <db> exists "select $primary_key from $table where $primary_key=:nodeid"]
  }

  ###
  # topic: e1e4bb66d9cfc158ec9dfb8e13cfe0ce
  # title: Detect record key
  # description: The nodeid of this table from a key/value list of table contents
  ###
  method db_record_key record {
    set primary_key [my schema primary_key]
    if {[dict exists $record $primary_key]} {
      return [dict get $record $primary_key]
    }
    if {[dict exists $record rowid]} {
      return [dict get $record rowid]
    }
    error "Could not locate the primary key"
  }

  ###
  # topic: 505661a4862772908e986e255ffe1f79
  # description: Read a record from the database
  ###
  method db_record_load {nodeid {arrayvar {}}} {
    if { $arrayvar ne {} } {
      upvar 1 $arrayvar R
    }
    set table [my schema table]
    if {$nodeid eq {}} {
      return {}
    }
    my <db> eval "select * from $table where rowid=:nodeid" R {}
    unset -nocomplain R(*)
    return [array get R]
  }

  ###
  # topic: 37e78a4cf9ab491f9894c28a128922e4
  # title: Return a record number for a new entry
  ###
  method db_record_nextid {} {
    set primary_key [my schema primary_key]
    set maxid [my <db> one "select max($primary_key) from [my schema table]"]
    if { ![string is integer -strict $maxid]} {
      return 1
    } else {
      return [expr {$maxid + 1}]
    }
  }

  ###
  # topic: 0960b530335749a9315d8d05af8c02c2
  # description:
  #    Write a record to the database. If nodeid is negative,
  #    create a new record and return its ID.
  #    This action will also perform any container specific prepwork
  #    to stitch the node into the model, as well as re-read the node
  #    from the database and into memory for use by the gui
  ###
  method db_record_save {nodeid record} {
    appmain signal  dbchange

    set table [my schema table]
    set primary_key [my schema primary_key]

    set now [clock seconds]
    if { $nodeid < 1 || $nodeid eq {} } {
      set nodeid [my db_record_nextid]
    }
    if {![my <db> exists "select $primary_key from $table where rowid=:nodeid"]} {
      my <db> change "INSERT INTO $table ($primary_key) VALUES (:nodeid)"
      foreach {var val} [my meta cget default_record] {
        if {![dict exists $record $var]} {
          dict set record $var $val
        }
      }
    }
    set oldrec [my db_record_load $nodeid]
    set fields {}
    set values {}
    set stmt "UPDATE $table SET "
    set stmtl {}
    set columns [dict keys $oldrec]

    foreach {field value} $record {
        if { $field in [list $primary_key mtime uuid] } continue
        if { $field ni $columns } continue
        if {[dict exists $oldrec $field]} {
            # Screen out values that have not changed
            if {[dict get $oldrec $field] eq $value } continue
        }
        lappend stmtl "$field=\$rec_${field}"
        set rec_${field} $value
    }
    if { $stmtl == {} } {
        return 0
    }
    if { "mtime" in $columns } {
      lappend stmtl "mtime=now()"
    }
    append stmt [join $stmtl ,]
    append stmt " WHERE $primary_key=:nodeid"
    my <db> change $stmt
    return $nodeid
  }
}

###
# topic: 9032e81e051b67fa089f1326da6081f1
# description:
#    Managing records for tables that consist of a primary
#    key and a blob field that contains a key/value list
#    that represents the record
###
tool::define tool::db::table.blob {
  aliases moac.sqliteTable.blob
  superclass tool::db::meta.schema

  ###
  # topic: 24d95fd922c7d9d188b60b35b382b8dd
  ###
  method db_record_delete nodeid {
    set table        [my schema table]
    set primary_key  [my schema primary_key]
    my <db> one "delete from $table where $primary_key=:nodeid"
  }

  ###
  # topic: c4c57639b09ab0f1bd81700cabd6ab88
  ###
  method db_record_load {nodeid {arrayvar {}}} {
    set table  [my schema table]
    set vfield [my meta cget field_value]
    set primary_key [my schema primary_key]

    if { $arrayvar ne {} } {
      upvar 1 $arrayvar R
      array set R [my <db> one "select $vfield from $table where $primary_key=:nodeid"]
      return [array get R]
    } else {
      return  [my <db> one "select $vfield from $table where $primary_key=:nodeid"]
    }
  }

  ###
  # topic: 268efa2a6aac3451f3e5e525013ec091
  ###
  method db_record_save {nodeid record} {
    set table  [my schema table]
    set vfield [my meta cget field_value]
    set primary_key [my schema primary_key]

    set result [my meta cget default_record]
    foreach {var val} [my <db> one "select $vfield from $table where $primary_key=:nodeid"] {
      dict set result $var $val
    }
    foreach {var val} $record {
      dict set result $var $val
    }
    my <db> eval "update $table set $vfield=:result where $primary_key=:nodeid"
  }
}

###
# topic: df933b39a39e106c1c0b3f8651d4b5b7
# description:
#    Managing records for tables that consist of a primary
#    key a column representing a "field" and another
#    column representing a "value"
###
tool::define tool::db::table.keyvalue {
  aliases moac.sqliteTable.keyvalue
  superclass

  ###
  # topic: c32d751f91d518b47ad400ef04e4f719
  ###
  method db_record_delete nodeid {
    set table        [my schema table]
    set primary_key  [my schema primary_key]
    my <db> one "delete from $table where $primary_key=:nodeid"
  }

  ###
  # topic: 34b5a0fefa9a9655a3f8184c3eb640a9
  ###
  method db_record_load nodeid {
    set table  [my schema table]
    set ffield [my meta cget field_name]
    set vfield [my meta cget field_value]
    set primary_key [my schema primary_key]

    set result [my meta cget default_record]
    my <db> eval "select $ffield as field,$vfield as value from $table where $primary_key=:nodeid" {
      dict set result $field $value
    }
    return $result
  }

  ###
  # topic: 176679ea4e972f4eac12d4325979369e
  ###
  method db_record_save {nodeid record} {
    set table  [my schema table]
    set ffield [my meta cget field_name]
    set vfield [my meta cget field_value]
    set primary_key [my schema primary_key]

    set oldrecord [my db_record_load $nodeid]
    foreach {var val} $record {
      if {[dict exists $oldrecord $var]} {
        if {[dict get $oldrecord $var] eq $val } continue
      }
      dict set outrecord $var $val
    }
    if {![llength $outrecord]} return

    my <db> transaction {
      foreach {var val} $outrecord {
        my <db> change "insert or replace into $table ($primary_key,$ffield,$vfield) VALUES (:nodeid,$var,$val)"
      }
    }
  }


}

