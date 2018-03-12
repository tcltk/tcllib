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
