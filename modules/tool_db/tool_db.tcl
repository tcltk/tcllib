###
# Amalgamated package for tool::db
# Do not edit directly, tweak the source in src/ and rerun
# build.tcl
###
package require Tcl 8.6
package provide tool::db 0.1
namespace eval ::tool::db {}
set ::tool::db::version 0.1

###
# START: core.tcl
###
package require sqlite3
package require tool

namespace eval ::tool::db {}


###
# END: core.tcl
###
###
# START: schema.tcl
###
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

###
# END: schema.tcl
###
###
# START: onion.tcl
###
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

###
# END: onion.tcl
###
###
# START: table.tcl
###
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


###
# END: table.tcl
###
###
# START: connection.tcl
###
###
# Keep:
# * all backups in the last day
# * one backup per hour for the past week
# * one per day for the past 2 months
# * one per week for the past 6 months
# * one per month for the path 12 months
# * one every 6 months for years beyond
###
proc ::tool::db::backup_retain {path pattern} {
  set hour 3600
  set day [expr {$hour*24}]
  set week [expr {$day*7}]
  set month [expr {$week*4}]
  set year [expr {$month*12}]
  set halfyear [expr {$month*6}]
  set now [clock seconds]

  foreach file [glob -nocomplain [file join $path $pattern]] {
    set age [expr {$now - [file mtime $file]}]
    if { $age < $day } continue
    if { $age < $week } {
      lappend hourly([expr {$age/$hour}]) $age $file
      continue
    }
    if { $age < ($month*2) } {
      lappend daily([expr {$age/$day}]) $age $file
    }
    if { $age < ($month*6) } {
      lappend weekly([expr {$age/$week}]) $age $file
      continue
    }
    if { $age < $year } {
      lappend monthly([expr {$age/$month}]) $age $file
      continue
    }
    lappend halfyearly([expr {$age/$halfyear}]) $age $file
  }


  foreach {bin backups} [array get hourly] {
    foreach {mtime file} [lrange [lsort -stride 2 -integer $backups] 2 end] {
      file delete $file
    }
  }
  foreach {bin backups} [array get daily] {
    foreach {mtime file} [lrange [lsort -stride 2 -integer $backups] 2 end] {
      file delete $file
    }
  }
  foreach {bin backups} [array get weekly] {
    foreach {mtime file} [lrange [lsort -stride 2 -integer $backups] 2 end] {
      file delete $file
    }
  }
  foreach {bin backups} [array get monthly] {
    foreach {mtime file} [lrange [lsort -stride 2 -integer $backups] 2 end] {
      file delete $file
    }
  }
  foreach {bin backups} [array get halfyearly] {
    foreach {mtime file} [lrange [lsort -stride 2 -integer $backups] 2 end] {
      file delete $file
    }
  }
}

###
# topic: 1f4bc558d601dd0621d4f441fcf94b07
# title: High level database container
# description:
#    A tool::db::connection
#    <p>
#    This object is assumed to be a nexus of an sqlite connector
#    and several subject objects to manage the individual tables
#    accessed by this application.
###
tool::define tool::db::connection {
  superclass ::tao::onion  tool::db::meta.schema
  property docentry {}

  ###
  # topic: 124b0e5697a3e0a179a5bc044c735a54
  ###
  method active_layers {} {
    # Return a mapping of tables to their handler classes
    return {}
  }

  ###
  # topic: ad8b51dd1884240d87d7a99ee2a8b862
  ###
  method Database_Create {} {
  }

  ###
  # topic: 7cb96867401c18478a3dfb74b4cd37d8
  ###
  method Database_Functions {} {
  }

  ###
  # topic: 62f531b6d83adc8a10d15b27ec17b675
  ###
  method schema::create_sql {} {
    set result [my meta cget schema create_sql]
    foreach {layer obj} [my layers] {
      set table [$obj schema table]
      append result "-- BEGIN $table" \n
      append result [$obj schema create_sql] \n
      append result "-- END $table" \n
    }
    return $result
  }

  ###
  # topic: fb34f12af081276e36172acfbbea52cf
  ###
  method schema::tables {} {
    set result {}
    foreach {layer obj} [my layers] {
      set table [$obj schema table]
      lappend result $table
    }
    return $result
  }
}

###
# topic: eaf5daa1dd0baa5e8501e97af3224656
# title: High level database container
# description: A tool::db::connection implemented for sqlite
###
tool::define tool::db::connection.sqlite {
  superclass tool::db::connection tao::onion
  aliases moac.sqliteDb
  variable online_mode 0
  variable memory_db 0
  variable local_mode 0
  variable filemap {}
  variable ensemblemap {}

  option filename {
    widget filename
    extensions {.sqlite {Sqlite Database}}
  }

  option read-only {
    default 0
    datatype boolean
  }

  option timeout {
    default 30000
    type integer
  }

  option online {
    default 0
    datatype boolean
    comment {When true, an in-memory database is backed up to disk}
  }

  ###
  # topic: f71dcb5b2e2312180e379356f3263ff9
  ###
  method attach_sqlite_methods sqlchan {
    my graft db $sqlchan
foreach func {
authorizer
backup
busy
cache
changes
close
collate
collation_needed
commit_hook
complete
copy
enable_load_extension
errorcode
eval
exists
function
incrblob
last_insert
last_insert_rowid
nullvalue
onecolumn
profile
progress
restore
rollback_hook
status
timeout
total_changes
trace
transaction
unlock_notify
update_hook
version
    } {
        my forward $func $sqlchan $func
    }
    my forward one $sqlchan onecolumn
  }

  destructor {
    my Database_Sync
  }


  method attach {handle filename {class {}}} {
    set reply 0
    my mixinmap $handle $class
    my variable filemap mixinmap
    dict set filemap $handle $filename
    if {$class ne {}} {
      set reply [my ${handle} attach $filename]
    } else {
      catch {my eval "detach $handle"}
      if {[file exists $filename]} {
        set filename [file normalize $filename]
      }
      my <db> eval "attach :filename as $handle"
    }
    foreach {slot classes} $mixinmap {
      foreach class $classes {
        if {[$class meta exists mixin view-script:]} {
          if {[catch [$class meta get mixin view-script:] err errdat]} {
            puts stderr "[self] MIXIN ERROR REACTING $class:\n[dict get $errdat -errorinfo]"
          }
        }
      }
    }
    return $reply
  }

  method autobackup {} {
    set filename [my cget filename]
    set DIRNAME [file dirname $filename]
    set BASENAME [file join $DIRNAME [file rootname $filename]]
    set TIMESTAMP [clock format [clock seconds] -format "%Y%m%d%H%M%S"]
    set backupname "$BASENAME-bu$TIMESTAMP[file extension $filename]"
    my <db> backup $backupname
  }

  method database {submethod args} {
    return [my Database_$submethod {*}$args]
  }

  ###
  # topic: 8a8ecce021e1fcbf8fc25be3ce4cd1d5
  ###
  method Database {submethod args} {
    return [my Database_$submethod {*}$args]
  }

  ###
  # topic: ba1114cdc19c7835f848f9c6ce2f21c7
  ###
  method Database_Attach filename {
    my variable online_mode
    set alias db
    set online_mode [string is true -strict [my cget online]]
    if { $filename in {:memory: {}}} {
      set exists 0
    } else {
      set exists [file exists $filename]
    }
    my Config_merge [list filename $filename]
    set objname [my SubObject $alias]
    if {$online_mode} {
      sqlite3 $objname :memory:
      my Config_merge [list memdb 1]
    } else {
      sqlite3 $objname $filename
      my Config_merge [list memdb 0]
      ###
      # Wait up to 2 seconds for
      # a busy database
      ###
      $objname timeout [my cget timeout]
    }
    my graft $alias $objname
    my Database_Functions
    my attach_sqlite_methods $objname
    if {!$exists} {
      my Database_Create
    } else {
      if {$online_mode} {
        $objname restore [file normalize $filename]
      }
    }
  }

  ###
  # Perform a daily backup of the database
  ###
  method Database_Backup {} {
    set filename [my cget filename]
    set now [clock seconds]
    set today [clock format $now -format "%Y-%m-%d-%H"]
    set path [file join [file dirname $filename] backups]
    if {![file exists $path]} {
      file mkdir $path
    }
    set bkuplink [file join $path [file rootname $filename].latest.sqlite]
    file delete $bkuplink
    set bkupfile [file join $path [file tail [file rootname $filename]].$today.sqlite]
    my <db> backup $bkupfile
    file link $bkuplink $bkupfile
    ::tool::db::backup_retain $path *.sqlite
  }

  method Database_Sync {} {
    my variable online_mode
    if {$online_mode && [my cget read-only]==0} {
      # Online databases keep just the latest
      my <db> backup [my cget filename]
    }
  }

  method detach {handle} {
    my variable filemap
    if {[dict exists $filemap $handle]} {
      catch {my <db> eval "detach $handle\;"}
      dict unset filemap $handle
    }
    my mixinmap $handle {}
  }

  method filename {handle} {
    my variable filemap
    return [dict getnull $filemap $handle]
  }

  ###
  # topic: 4251a1e7abd66d20c66f9dcd25bb1e54
  # description:
  #    Deep wizardry
  #    Disable journaling and disk syncronization
  #    If the app crashes, we really don't give a
  #    rat's ass about the output, anyway
  ###
  method journal_mode onoff {
    # Store temporary tables in memory
    if {[string is false $onoff]} {
      my <db> eval {
PRAGMA synchronous=0;
PRAGMA journal_mode=MEMORY;
PRAGMA temp_store=2;
      }
    } else {
      my <db> eval {
PRAGMA synchronous=2;
PRAGMA journal_mode=DELETE;
PRAGMA temp_store=0;
      }
    }
  }

  ###
  # topic: 9363820d1352dc0b02d8b433be02a5b7
  ###
  method message::readonly {} {
    error "Database is read-only"
  }

  ###
  # topic: 29d3a99d20a7f3aaa7911b2666bdf17e
  ###
  method native::table_info table {
    set info {}
    my onecolumn {select type,sql from sqlite_master where tbl_name=$table} {
      foreach {type field value} [::schema::createsql_to_dict $sql] {
        dict set info $type $field $value
      }
    }
    return $info
  }

  ###
  # topic: df7ff05563eae14512f945ac80b18ea6
  ###
  method native::tables {} {
      return [my eval {SELECT name FROM sqlite_master WHERE type ='table'}]
  }

  ###
  # topic: d5591c09b59c6a8d50001af79d108e13
  ###
  method SubObject::db {} {
    return [namespace current]::Sqlite_db
  }
}

###
# END: connection.tcl
###

namespace eval ::tool::db {
    namespace export *
}

