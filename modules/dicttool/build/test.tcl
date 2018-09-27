set result {}
putb result {
# dicttool.test - Copyright (c) 2018 Sean Woods
# -------------------------------------------------------------------------

source [file join  [file dirname [file dirname [file join [pwd] [info script]]]]  devtools testutilities.tcl]


testsNeedTcl     8.5
testsNeedTcltest 2

support {
}
testing {
    useLocal dicttool.tcl dicttool
}}



putb result {
###
# Test canonical mapping
###
}
set test 0
  foreach {pattern canonical storage} {
    {foo bar baz}       {foo/ bar/ baz}         {foo bar baz}
    {foo bar baz/}      {foo/ bar/ baz/}        {foo bar baz}
    {foo bar .}         {foo/ bar}              {foo bar .}
    {foo/ bar/ .}       {foo/ bar}              {foo bar .}
    {foo . bar . baz .} {foo/ bar/ baz}         {foo . bar . baz .}
    {foo bar baz bat:}  {foo/ bar/ baz/ bat:}   {foo bar baz bat:}
    {foo:}              {foo:}                  {foo:}
    {foo/bar/baz/bat:}  {foo/ bar/ baz/ bat:}   {foo bar baz bat:}
} {
    dict set map %pattern% $pattern
    dict set map %canonical% $canonical
    dict set map %storage% $storage
    incr test
    noop {
    dict set map %test% [format "test-canonical-%04d" $test]
    putb result $map {
test {%test%} {Test ::dicttool::canonical with %pattern%} {
  dicttool::canonical {%pattern%}
} {%canonical%}
}
    }
    dict set map %test% [format "test-storage-%04d" $test]
    putb result $map {
test {%test%} {Test ::dicttool::storage with %pattern%} {
  dicttool::storage {%pattern%}
} {%storage%}
}
}

putb result {
dict set r foo/ bar/ baz 1
dict set s foo/ bar/ baz 0
set t [dicttool::merge $r $s]

test rmerge-0001 {Test that the root is marked as a branch} {
  dict get $t foo bar baz
} 0

set r [dict create]
dicttool::dictmerge r {
  foo/ {
    bar/ {
      baz 1
      bing: 2
      bang { bim 3 boom 4 }
      womp: {a 1 b 2}
    }
  }
}

test dictmerge-0001 {Test that the root is marked as a branch} {
  dict exists $r .
} 1
test dictmerge-0002 {Test that branch foo is marked correctly} {
  dict exists $r foo .
} 1
test dictmerge-0003 {Test that branch bar is marked correctly} {
  dict exists $r foo bar .
} 1
test dictmerge-0004 {Test that leaf foo/bar/bang is not marked as branch despite being a dict} {
  dict exists $r foo bar bang .
} 0
test dictmerge-0004 {Test that leaf foo/bar/bang/bim exists} {
  dict exists $r foo bar bang bim
} 1
test dictmerge-0005 {Test that leaf foo/bar/bang/boom exists} {
  dict exists $r foo bar bang boom
} 1

###
# Replace bang with bang/
###
dicttool::dictmerge r {
  foo/ {
    bar/ {
      bang/ {
        whoop 1
      }
    }
  }
}

test dictmerge-0006 {Test that leaf foo/bar/bang/bim ceases to exist} {
  dict exists $r foo bar bang bim
} 0
test dictmerge-0007 {Test that leaf foo/bar/bang/boom exists} {
  dict exists $r foo bar bang boom
} 0

test dictmerge-0008 {Test that leaf foo/bar/bang is now a branch} {
  dict exists $r foo bar bang .
} 1

test branch-0001 {Test that foo/ is a branch} {
  dicttool::is_branch $r foo/
} 1
test branch-0002 {Test that foo is a branch} {
  dicttool::is_branch $r foo
} 1
test branch-0003 {Test that foo/bar/ is a branch} {
  dicttool::is_branch $r {foo/ bar/}
} 1
test branch-0004 {Test that foo bar is not branch} {
  dicttool::is_branch $r {foo bar}
} 1
test branch-0004 {Test that foo/ bar is not branch} {
  dicttool::is_branch $r {foo/ bar}
} 0
}

set test 0
foreach {path isbranch} {
  foo 1
  {foo bar} 1
  {foo bar baz} 0
  {foo bar bing} 0
  {foo bar bang} 1
  {foo bar bang whoop} 0
} {
  set mpath [lrange $path 0 end-1]
  set item  [lindex $path end]
  set tests [list {} {} $isbranch {} : 0 {} / 1 . {} 0]
  dict set map %mpath% $mpath
  dict set map %item% $item
  foreach {head tail isbranch} $tests {
    dict set map %head% $head
    dict set map %tail% $tail
    dict set map %isbranch% $isbranch
    dict set map %test% [format "test-branch-%04d" [incr test]]
    putb result $map {
test {%test%} {Test that %mpath% %head%%item%%tail% is_branch = %isbranch%} {
  dicttool::is_branch $r {%mpath% %head%%item%%tail%}
} %isbranch%
}
  }
}

putb result {
# -------------------------------------------------------------------------
# dictmerge Testing - oometa
unset -nocomplain foo
dicttool::dictmerge foo {
  option/ {
    color/ {
      label Color
      default green
    }
  }
}
dicttool::dictmerge foo {
  option/ {
    color/ {
      default purple
    }
  }
}

test oometa-0001 {Invoking dictmerge with empty args on a non existent variable create an empty variable} {
  dict get $foo option color default
} purple
test oometa-0002 {Invoking dictmerge with empty args on a non existent variable create an empty variable} {
  dict get $foo option color label
} Color

unset -nocomplain foo
set foo {. {}}
::dicttool::dictmerge foo {. {} color {. {} default green label Color}}
::dicttool::dictmerge foo {. {} color {. {} default purple}}
test oometa-0003 {Recursive merge problem from oometa/clay find} {
  dict get $foo color default
} purple
test oometa-0004 {Recursive merge problem from oometa/clay find} {
  dict get $foo color label
} Color

unset -nocomplain foo
set foo {. {}}
::dicttool::dictmerge foo {. {} color {. {} default purple}}
::dicttool::dictmerge foo {. {} color {. {} default green label Color}}
test oometa-0005 {Recursive merge problem from oometa/clay find} {
  dict get $foo color default
} green
test oometa-0006 {Recursive merge problem from oometa/clay find} {
  dict get $foo color label
} Color

test oometa-0008 {Un-Sanitized output} {
  set foo
} {. {} color {. {} default green label Color}}

test oometa-0009 {Sanitize} {
  dicttool::sanitize $foo
} {color {default green label Color}}
}


putb result {
# -------------------------------------------------------------------------
# dictmerge Testing - clay
unset -nocomplain foo
test clay-0001 {Invoking dictmerge with empty args on a non existent variable create an empty variable} {
  ::dicttool::dictmerge foo
  set foo
} {. {}}

unset -nocomplain foo
::dicttool::dictset foo bar/ baz/ bell bang

test clay-0002 {For new entries dictmerge is essentially a set} {
  dict get $foo bar baz bell
} {bang}
::dicttool::dictset foo bar/ baz/ boom/ bang
test clay-0003 {For entries that do exist a zipper merge is performed} {
  dict get $foo bar baz bell
} {bang}
test clay-0004 {For entries that do exist a zipper merge is performed} {
  dict get $foo bar baz boom
} {bang}

::dicttool::dictset foo bar/ baz/ bop {color green flavor strawberry}

test clay-0005 {Leaves are replaced even if they look like a dict} {
  dict get $foo bar baz bop
} {color green flavor strawberry}

::dicttool::dictset foo bar/ baz/ bop {color yellow}
test clay-0006 {Leaves are replaced even if they look like a dict} {
  dict get $foo bar baz bop
} {color yellow}

::dicttool::dictset foo bar/ baz/ bang/ {color green flavor strawberry}
test clay-0007a {Branches are merged} {
  dict get $foo bar baz bang
} {. {} color green flavor strawberry}

::dicttool::dictset foo bar/ baz/ bang/ color yellow
test clay-0007b {Branches are merged}  {
  dict get $foo bar baz bang
} {. {} color yellow flavor strawberry}

::dicttool::dictset foo bar/ baz/ bang/ {color blue}
test clay-0007c {Branches are merged}  {
  dict get $foo bar baz bang
} {. {} color blue flavor strawberry}

::dicttool::dictset foo bar/ baz/ bang/ shape: {Sort of round}
test clay-0007d {Branches are merged} {
  dict get $foo bar baz bang
} {. {} color blue flavor strawberry shape: {Sort of round}}

::dicttool::dictset foo bar/ baz/ bang/ color yellow
test clay-0007e {Branches are merged}  {
  dict get $foo bar baz bang
} {. {} color yellow flavor strawberry shape: {Sort of round}}

::dicttool::dictset foo bar/ baz/ bang/ {color blue}
test clay-0007f {Branches are merged}  {
  dict get $foo bar baz bang
} {. {} color blue flavor strawberry shape: {Sort of round}}

::dicttool::dictset foo dict my_var 10
::dicttool::dictset foo dict my_other_var 9

test clay-0007g {Branches are merged}  {
  dict get $foo dict
} {. {} my_var 10 my_other_var 9}

::dicttool::dictset foo dict/ my_other_other_var 8
test clay-0007h {Branches are merged}  {
  dict get $foo dict
} {. {} my_var 10 my_other_var 9 my_other_other_var 8}


::dicttool::dictmerge foo {option/ {color {type color} flavor {sense taste}}}
::dicttool::dictmerge foo {option/ {format {default ascii}}}

test clay-0008 {Whole dicts are merged}  {
  dict get $foo option color
} {type color}
test clay-0009 {Whole dicts are merged}  {
  dict get $foo option flavor
} {sense taste}
test clay-0010 {Whole dicts are merged}  {
  dict get $foo option format
} {default ascii}

###
# Tests for the httpd module
###
test clay-0010 {Test that leaves are merged properly}
set bar {}
::dicttool::dictmerge bar {
   proxy/ {port 10101 host myhost.localhost}
}
::dicttool::dictmerge bar {
   mimetxt {Host: localhost
Content_Type: text/plain
Content-Length: 15
}
   http {HTTP_HOST {} CONTENT_LENGTH 15 HOST localhost CONTENT_TYPE text/plain UUID 3a7b4cdc-28d7-49b7-b18d-9d7d18382b9e REMOTE_ADDR 127.0.0.1 REMOTE_HOST 127.0.0.1 REQUEST_METHOD POST REQUEST_URI /echo REQUEST_PATH echo REQUEST_VERSION 1.0 DOCUMENT_ROOT {} QUERY_STRING {} REQUEST_RAW {POST /echo HTTP/1.0} SERVER_PORT 10001 SERVER_NAME 127.0.0.1 SERVER_PROTOCOL HTTP/1.1 SERVER_SOFTWARE {TclHttpd 4.2.0} LOCALHOST 0} UUID 3a7b4cdc-28d7-49b7-b18d-9d7d18382b9e uriinfo {fragment {} port {} path echo scheme http host {} query {} pbare 0 pwd {} user {}}
   mixin {reply ::test::content.echo}
   prefix /echo
   proxy_port 10010
   proxy/ {host localhost}
}

test clay-0011 {Whole dicts are merged}  {
  dict get $bar proxy_port
} {10010}

test clay-0012 {Whole dicts are merged}  {
  dict get $bar http CONTENT_LENGTH
} 15
test clay-0013 {Whole dicts are merged}  {
  dict get $bar proxy host
} localhost
test clay-0014 {Whole dicts are merged}  {
  dict get $bar proxy port
} 10101
}

putb result {

testsuiteCleanup

# Local variables:
# mode: tcl
# indent-tabs-mode: nil
# End:
}

return $result
