
::oo::class create ::practcl::build.gcc {
  superclass ::practcl::build

  method build-compile-sources {PROJECT COMPILE {CPPCOMPILE {}}} {
  set EXTERN_OBJS {}
  set OBJECTS {}
  set result {}
  set builddir [$PROJECT define get builddir]
  file mkdir [file join $builddir objs]
  set debug [$PROJECT define get debug 0]
  if {$CPPCOMPILE eq {}} {
    set CPPCOMPILE $COMPILE
  }
  set task [${PROJECT} compile-products]
  ###
  # Compile the C sources
  ###
  foreach {ofile info} $task {
    dict set task $ofile done 0
    if {[dict exists $info external] && [dict get $info external]==1} {
      dict set task $ofile external 1
    } else {
      dict set task $ofile external 0
    }
    if {[dict exists $info library]} {
      dict set task $ofile done 1
      continue
    }
    # Products with no cfile aren't compiled
    if {![dict exists $info cfile] || [set cfile [dict get $info cfile]] eq {}} {
      dict set task $ofile done 1
      continue
    }
    set cfile [dict get $info cfile]
    set ofilename [file join $builddir objs [file tail $ofile]]
    if {$debug} {
      set ofilename [file join $builddir objs [file rootname [file tail $ofile]].debug.o]
    }
    dict set task $ofile filename $ofilename
    if {[file exists $ofilename] && [file mtime $ofilename]>[file mtime $cfile]} {
      lappend result $ofilename
      dict set task $ofile done 1
      continue
    }
    if {![dict exist $info command]} {
      if {[file extension $cfile] in {.c++ .cpp}} {
        set cmd $CPPCOMPILE
      } else {
        set cmd $COMPILE
      }
      if {[dict exists $info extra]} {
        append cmd " [dict get $info extra]"
      }
      append cmd " -c $cfile"
      append cmd " -o $ofilename"
      dict set task $ofile command $cmd
    }
  }
  set completed 0
  while {$completed==0} {
    set completed 1
    foreach {ofile info} $task {
      set waiting {}
      if {[dict exists $info done] && [dict get $info done]} continue
      if {[dict exists $info depend]} {
        foreach file [dict get $info depend] {
          if {[dict exists $task $file command] && [dict exists $task $file done] && [dict get $task $file done] != 1} {
            set waiting $file
            break
          }
        }
      }
      if {$waiting ne {}} {
        set completed 0
        puts "$ofile waiting for $waiting"
        continue
      }
      if {[dict exists $info command]} {
        set cmd [dict get $info command]
        puts "$cmd"
        exec {*}$cmd >&@ stdout
      }
      lappend result [dict get $info filename]
      dict set task $ofile done 1
    }
  }
  return $result
}

method build-Makefile {path PROJECT} {
  array set proj [$PROJECT define dump]
  set path $proj(builddir)
  cd $path
  set includedir .
  #lappend includedir [::practcl::file_relative $path $proj(TCL_INCLUDES)]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TCL_SRC_DIR) generic]]]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(srcdir) generic]]]
  foreach include [$PROJECT generate-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  set INCLUDES  "-I[join $includedir " -I"]"
  set NAME [string toupper $proj(name)]
  set result {}
  set products {}
  set libraries {}
  set thisline {}
  ::practcl::cputs result "${NAME}_DEFS = $proj(DEFS)\n"
  ::practcl::cputs result "${NAME}_INCLUDES = -I\"[join $includedir "\" -I\""]\"\n"
  ::practcl::cputs result "${NAME}_COMPILE = \$(CC) \$(CFLAGS) \$(PKG_CFLAGS) \$(${NAME}_DEFS) \$(${NAME}_INCLUDES) \$(INCLUDES) \$(AM_CPPFLAGS) \$(CPPFLAGS) \$(AM_CFLAGS)"
  ::practcl::cputs result "${NAME}_CPPCOMPILE = \$(CXX) \$(CFLAGS) \$(PKG_CFLAGS) \$(${NAME}_DEFS) \$(${NAME}_INCLUDES) \$(INCLUDES) \$(AM_CPPFLAGS) \$(CPPFLAGS) \$(AM_CFLAGS)"

  foreach {ofile info} [$PROJECT compile-products] {
    dict set products $ofile $info
    if {[dict exists $info library]} {
lappend libraries $ofile
continue
    }
    if {[dict exists $info depend]} {
      ::practcl::cputs result "\n${ofile}: [dict get $info depend]"
    } else {
      ::practcl::cputs result "\n${ofile}:"
    }
    set cfile [dict get $info cfile]
    if {[file extension $cfile] in {.c++ .cpp}} {
      set cmd "\t\$\(${NAME}_CPPCOMPILE\)"
    } else {
      set cmd "\t\$\(${NAME}_COMPILE\)"
    }
    if {[dict exists $info extra]} {
      append cmd " [dict get $info extra]"
    }
    append cmd " -c [dict get $info cfile] -o \$@\n\t"
    ::practcl::cputs result  $cmd
  }

  set map {}
  lappend map %LIBRARY_NAME% $proj(name)
  lappend map %LIBRARY_VERSION% $proj(version)
  lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $proj(version)]
  lappend map %LIBRARY_PREFIX% [$PROJECT define getnull libprefix]

  if {[string is true [$PROJECT define get SHARED_BUILD]]} {
    set outfile [$PROJECT define get libfile]
  } else {
    set outfile [$PROJECT shared_library]
  }
  $PROJECT define set shared_library $outfile
  ::practcl::cputs result "
${NAME}_SHLIB = $outfile
${NAME}_OBJS = [dict keys $products]
"

  #lappend map %OUTFILE% {\[$]@}
  lappend map %OUTFILE% $outfile
  lappend map %LIBRARY_OBJECTS% "\$(${NAME}_OBJS)"
  ::practcl::cputs result "$outfile: \$(${NAME}_OBJS)"
  ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_SHARED_LIB]]"
  if {[$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL] ni {: {}}} {
    ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL]]"
  }
  ::practcl::cputs result {}
  if {[string is true [$PROJECT define get SHARED_BUILD]]} {
    #set outfile [$PROJECT static_library]
    set outfile $proj(name).a
  } else {
    set outfile [$PROJECT define get libfile]
  }
  $PROJECT define set static_library $outfile
  dict set map %OUTFILE% $outfile
  ::practcl::cputs result "$outfile: \$(${NAME}_OBJS)"
  ::practcl::cputs result "\t[string map $map [$PROJECT define get PRACTCL_STATIC_LIB]]"
  ::practcl::cputs result {}
  return $result
}

###
# Produce a static or dynamic library
###
method build-library {outfile PROJECT} {
  array set proj [$PROJECT define dump]
  set path $proj(builddir)
  cd $path
  set includedir .
  #lappend includedir [::practcl::file_relative $path $proj(TCL_INCLUDES)]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TCL_SRC_DIR) generic]]]
  lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(srcdir) generic]]]
  if {[$PROJECT define get tk 0]} {
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) generic]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) ttk]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $proj(TK_SRC_DIR) xlib]]]
    lappend includedir [::practcl::file_relative $path [file normalize $proj(TK_BIN_DIR)]]
  }
  foreach include [$PROJECT generate-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  my build-cflags $PROJECT $proj(DEFS) name version defs
  set NAME [string toupper $name]
  set debug [$PROJECT define get debug 0]
  set os [$PROJECT define get TEACUP_OS]

  set INCLUDES  "-I[join $includedir " -I"]"
  if {$debug} {
    set COMPILE "$proj(CC) $proj(CFLAGS_DEBUG) -ggdb \
$proj(CFLAGS_WARNING) $INCLUDES $defs"

    if {[info exists proc(CXX)]} {
      set COMPILECPP "$proj(CXX) $defs $INCLUDES $proj(CFLAGS_DEBUG) -ggdb \
  $defs $proj(CFLAGS_WARNING)"
    } else {
      set COMPILECPP $COMPILE
    }
  } else {
    set COMPILE "$proj(CC) $proj(CFLAGS) $defs $INCLUDES "

    if {[info exists proc(CXX)]} {
      set COMPILECPP "$proj(CXX) $defs $INCLUDES $proj(CFLAGS) $defs"
    } else {
      set COMPILECPP $COMPILE
    }
  }

  set products [my build-compile-sources $PROJECT $COMPILE $COMPILECPP]

  set map {}
  lappend map %LIBRARY_NAME% $proj(name)
  lappend map %LIBRARY_VERSION% $proj(version)
  lappend map %LIBRARY_VERSION_NODOTS% [string map {. {}} $proj(version)]
  lappend map %OUTFILE% $outfile
  lappend map %LIBRARY_OBJECTS% $products
  lappend map {${CFLAGS}} "$proj(CFLAGS_DEFAULT) $proj(CFLAGS_WARNING)"

  if {[string is true [$PROJECT define get SHARED_BUILD 1]]} {
    set cmd [$PROJECT define get PRACTCL_SHARED_LIB]
    append cmd " [$PROJECT define get PRACTCL_LIBS]"
    set cmd [string map $map $cmd]
    puts $cmd
    exec {*}$cmd >&@ stdout
    if {[$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL] ni {: {}}} {
      set cmd [string map $map [$PROJECT define get PRACTCL_VC_MANIFEST_EMBED_DLL]]
      puts $cmd
      exec {*}$cmd >&@ stdout
    }
  } else {
    set cmd [string map $map [$PROJECT define get PRACTCL_STATIC_LIB]]
    puts $cmd
    exec {*}$cmd >&@ stdout
  }
  set ranlib [$PROJECT define get RANLIB]
  if {$ranlib ni {{} :}} {
    catch {exec $ranlib $outfile}
  }
}

###
# Produce a static executable
###
method build-tclsh {outfile PROJECT} {
  puts " BUILDING STATIC TCLSH "
  set TCLOBJ [$PROJECT project TCLCORE]
  set PKG_OBJS {}
  foreach item [$PROJECT link list core.library] {
    if {[string is true [$item define get static]]} {
      lappend PKG_OBJS $item
    }
  }
  foreach item [$PROJECT link list package] {
    if {[string is true [$item define get static]]} {
      lappend PKG_OBJS $item
    }
  }
  array set TCL [$TCLOBJ config.sh]

  set TKOBJ  [$PROJECT project tk]
  if {[info command $TKOBJ] eq {}} {
    set TKOBJ ::noop
    $PROJECT define set static_tk 0
  } else {
    array set TK  [$TKOBJ config.sh]
    set do_tk [$TKOBJ define get static]
    $PROJECT define set static_tk $do_tk
    $PROJECT define set tk $do_tk
    set TKSRCDIR [$TKOBJ define get srcdir]
  }
  set path [file dirname $outfile]
  cd $path
  ###
  # For a static Tcl shell, we need to build all local sources
  # with the same DEFS flags as the tcl core was compiled with.
  # The DEFS produced by a TEA extension aren't intended to operate
  # with the internals of a staticly linked Tcl
  ###
  my build-cflags $PROJECT $TCL(defs) name version defs
  set debug [$PROJECT define get debug 0]
  set NAME [string toupper $name]
  set result {}
  set libraries {}
  set thisline {}
  set OBJECTS {}
  set EXTERN_OBJS {}
  foreach obj $PKG_OBJS {
    $obj compile
    set config($obj) [$obj config.sh]
  }
  set os [$PROJECT define get TEACUP_OS]
  set TCLSRCDIR [$TCLOBJ define get srcdir]

  set includedir .
  foreach include [$TCLOBJ generate-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }
  lappend includedir [::practcl::file_relative $path [file normalize ../tcl/compat/zlib]]
  if {[$PROJECT define get static_tk]} {
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR generic]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR ttk]]]
    lappend includedir [::practcl::file_relative $path [file normalize [file join $TKSRCDIR xlib]]]
    lappend includedir [::practcl::file_relative $path [file normalize $TKSRCDIR]]
  }

  foreach include [$PROJECT generate-include-directory] {
    set cpath [::practcl::file_relative $path [file normalize $include]]
    if {$cpath ni $includedir} {
      lappend includedir $cpath
    }
  }

  set INCLUDES  "-I[join $includedir " -I"]"
  if {$debug} {
      set COMPILE "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_debug) -ggdb \
$TCL(cflags_warning) $TCL(extra_cflags) $INCLUDES"
  } else {
      set COMPILE "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_optimize) \
$TCL(cflags_warning) $TCL(extra_cflags) $INCLUDES"
  }
  append COMPILE " " $defs
  lappend OBJECTS {*}[my build-compile-sources $PROJECT $COMPILE $COMPILE]

  set TCLSRC [file normalize $TCLSRCDIR]

  if {[${PROJECT} define get TEACUP_OS] eq "windows"} {
    set windres [$PROJECT define get RC windres]
    set RSOBJ [file join $path build tclkit.res.o]
    set RCSRC [${PROJECT} define get kit_resource_file]
    set cmd [list $windres -o $RSOBJ -DSTATIC_BUILD --include [::practcl::file_relative $path [file join $TCLSRC generic]]]
    if {[$PROJECT define get static_tk]} {
      if {$RCSRC eq {} || ![file exists $RCSRC]} {
        set RCSRC [file join $TKSRCDIR win rc wish.rc]
      }
      set TKSRC [file normalize $TKSRCDIR]
      lappend cmd --include [::practcl::file_relative $path [file join $TKSRC generic]] \
        --include [::practcl::file_relative $path [file join $TKSRC win]] \
        --include [::practcl::file_relative $path [file join $TKSRC win rc]]
    } else {
      if {$RCSRC eq {} || ![file exists $RCSRC]} {
        set RCSRC [file join $TCLSRCDIR tclsh.rc]
      }
    }
    foreach item [${PROJECT} define get resource_include] {
      lappend cmd --include [::practcl::file_relative $path [file normalize $item]]
    }
    lappend cmd $RCSRC
    ::practcl::doexec {*}$cmd
    lappend OBJECTS $RSOBJ
    set LDFLAGS_CONSOLE {-mconsole -pipe -static-libgcc}
    set LDFLAGS_WINDOW  {-mwindows -pipe -static-libgcc}
  } else {
    set LDFLAGS_CONSOLE {}
    set LDFLAGS_WINDOW  {}
  }
  puts "***"
  if {$debug} {
    set cmd "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_debug) \
$TCL(cflags_warning) $TCL(extra_cflags) $INCLUDES"
  } else {
    set cmd "$TCL(cc) $TCL(shlib_cflags) $TCL(cflags_optimize) \
$TCL(cflags_warning) $TCL(extra_cflags) $INCLUDES"
  }
  append cmd " $OBJECTS"
  append cmd " $EXTERN_OBJS "
  # On OSX it is impossibly to generate a completely static
  # executable
  if {[$PROJECT define get TEACUP_OS] ne "macosx"} {
    append cmd " -static "
  }
  if {$debug} {
    if {$os eq "windows"} {
      append cmd " -L${TCL(src_dir)}/win -ltcl86g"
      if {[$PROJECT define get static_tk]} {
        append cmd " -L${TK(src_dir)}/win -ltk86g"
      }
    } else {
      append cmd " -L${TCL(src_dir)}/unix -ltcl86g"
      if {[$PROJECT define get static_tk]} {
        append cmd " -L${TK(src_dir)}/unix -ltk86g"
      }
    }
  } else {
    append cmd " $TCL(build_lib_spec)"
    if {[$PROJECT define get static_tk]} {
      append cmd " $TK(build_lib_spec)"
    }
  }
  foreach obj $PKG_OBJS {
    append cmd " [$obj linker-products $config($obj)]"
  }
  append cmd " $TCL(libs) "
  if {[$PROJECT define get static_tk]} {
    append cmd " $TK(libs)"
  }
  foreach obj $PKG_OBJS {
    append cmd " [$obj linker-external $config($obj)]"
  }
  if {$debug} {
    if {$os eq "windows"} {
      append cmd " -L${TCL(src_dir)}/win ${TCL(stub_lib_flag)}"
      if {[$PROJECT define get static_tk]} {
        append cmd " -L${TK(src_dir)}/win ${TK(stub_lib_flag)}"
      }
    } else {
      append cmd " -L${TCL(src_dir)}/unix ${TCL(stub_lib_flag)}"
      if {[$PROJECT define get static_tk]} {
        append cmd " -L${TK(src_dir)}/unix ${TK(stub_lib_flag)}"
      }
    }
  } else {
    append cmd " $TCL(build_stub_lib_spec)"
    if {[$PROJECT define get static_tk]} {
      append cmd " $TK(build_stub_lib_spec)"
    }
  }
  append cmd " -o $outfile $LDFLAGS_CONSOLE"
  puts "LINK: $cmd"
  exec {*}$cmd >&@ stdout
}
}
