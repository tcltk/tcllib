###
# Test script build functions
###

set result {}
putb result {# clay.test - Copyright (c) 2018 Sean Woods
# -------------------------------------------------------------------------

#source [file join \
#	[file dirname [file dirname [file dirname [file join [pwd] [info script]]]]] \
#	compat devtools testutilities.tcl]

source [file join  [file dirname [file dirname [file join [pwd] [info script]]]]  devtools testutilities.tcl]


testsNeedTcl     8.6
testsNeedTcltest 2
testsNeed        TclOO 1

support {
    use uuid/uuid.tcl uuid
    use oodialect/oodialect.tcl oo::dialect

}
testing {
    useLocal clay.tcl clay
}
}

putb result {
set ::clay::trace 0
}

putb result {
# -------------------------------------------------------------------------
# dictmerge Testing
unset -nocomplain foo
test dictmerge-0001 {Invoking dictmerge with empty args on a non existent variable create an empty variable} {
  ::clay::dictmerge foo
  set foo
} {}

unset -nocomplain foo
::clay::dictmerge foo bar/ baz/ bell/ bang
test dictmerge-0002 {For new entries dictmerge is essentially a set} {
  dict get $foo bar/ baz/ bell/
} {bang}

::clay::dictmerge foo bar/ baz/ boom/ bang
test dictmerge-0003 {For entries that do exist a zipper merge is performed} {
  dict get $foo bar/ baz/ bell/
} {bang}
test dictmerge-0004 {For entries that do exist a zipper merge is performed} {
  dict get $foo bar/ baz/ boom/
} {bang}

::clay::dictmerge foo bar/ baz/ bop {color green flavor strawberry}
test dictmerge-0005 {Leaves are replaced even if they look like a dict} {
  dict get $foo bar/ baz/ bop
} {color green flavor strawberry}

::clay::dictmerge foo bar/ baz/ bop {color yellow}
test dictmerge-0006 {Leaves are replaced even if they look like a dict} {
  dict get $foo bar/ baz/ bop
} {color yellow}

::clay::dictmerge foo bar/ baz/ bang/ {color green flavor strawberry}
test dictmerge-0005 {Branches are merged} {
  dict get $foo bar/ baz/ bang/
} {color green flavor strawberry}

::clay::dictmerge foo bar/ baz/ bang/ color yellow
test dictmerge-0006 {Branches are merged}  {
  dict get $foo bar/ baz/ bang/
} {color yellow flavor strawberry}

::clay::dictmerge foo bar/ baz/ bang/ {color blue}
test dictmerge-0007 {Branches are merged}  {
  dict get $foo bar/ baz/ bang/
} {color blue flavor strawberry}

::clay::dictmerge foo {public/ {option/ {color {type color} flavor {sense taste}}}}
::clay::dictmerge foo {public/ {option/ {format {default ascii}}}}

test dictmerge-0008 {Whole dicts are merged}  {
  dict get $foo public/ option/ color
} {type color}
test dictmerge-0009 {Whole dicts are merged}  {
  dict get $foo public/ option/ flavor
} {sense taste}
test dictmerge-0010 {Whole dicts are merged}  {
  dict get $foo public/ option/ format
} {default ascii}
}

putb result {
# -------------------------------------------------------------------------

::oo::dialect::create ::alpha

proc ::alpha::define::is_alpha {} {
  dict set ::testinfo([current_class]) is_alpha 1
}

::alpha::define ::alpha::object {
  is_alpha
}

::oo::dialect::create ::bravo ::alpha

proc ::bravo::define::is_bravo {} {
  dict set ::testinfo([current_class]) is_bravo 1
}

::bravo::define ::bravo::object {
  is_bravo
}

::oo::dialect::create ::charlie ::bravo

proc ::charlie::define::is_charlie {} {
  dict set ::testinfo([current_class]) is_charlie 1
}

::charlie::define ::charlie::object {
  is_charlie
}

::oo::dialect::create ::delta ::charlie

proc ::delta::define::is_delta {} {
  dict set ::testinfo([current_class]) is_delta 1
}

::delta::define ::delta::object {
  is_delta
}

::delta::class create adam {
  is_alpha
  is_bravo
  is_charlie
  is_delta
}

test oodialect-keyword-001 {Testing keyword application} {
  set ::testinfo(::adam)
} {is_alpha 1 is_bravo 1 is_charlie 1 is_delta 1}

test oodialect-keyword-002 {Testing keyword application} {
  set ::testinfo(::alpha::object)
} {is_alpha 1}

test oodialect-keyword-003 {Testing keyword application} {
  set ::testinfo(::bravo::object)
} {is_bravo 1}

test oodialect-keyword-004 {Testing keyword application} {
  set ::testinfo(::charlie::object)
} {is_charlie 1}

test oodialect-keyword-005 {Testing keyword application} {
  set ::testinfo(::delta::object)
} {is_delta 1}

###
# Declare an object from a namespace
###
namespace eval ::test1 {
  ::alpha::class create a {
    aliases A
    is_alpha
  }
  ::alpha::define b {
    aliases B BEE
    is_alpha
  }
  ::alpha::class create ::c {
    aliases C
    is_alpha
  }
  ::alpha::define ::d {
    aliases D
    is_alpha
  }
}

test oodialect-naming-001 {Testing keyword application} {
  set ::testinfo(::test1::a)
} {is_alpha 1}

test oodialect-naming-002 {Testing keyword application} {
  set ::testinfo(::test1::b)
} {is_alpha 1}

test oodialect-naming-003 {Testing keyword application} {
  set ::testinfo(::c)
} {is_alpha 1}

test oodialect-naming-004 {Testing keyword application} {
  set ::testinfo(::d)
} {is_alpha 1}

test oodialect-aliasing-001 {Testing keyword application} {
namespace eval ::test1 {
    ::alpha::define e {
       superclass A
    }
}
} ::test1::e

test oodialect-aliasing-002 {Testing keyword application} {
namespace eval ::test1 {
    ::bravo::define f {
       superclass A
    }
}
} ::test1::f


test oodialect-aliasing-003 {Testing aliase method on class} {
  ::test1::a aliases
} {::test1::A}


test oodialect-ancestry-003 {Testing heritage} {
  ::clay::ancestors ::test1::f
} {::test1::f ::test1::a ::bravo::object ::alpha::object ::oo::object}

test oodialect-ancestry-004 {Testing heritage} {
  ::clay::ancestors ::alpha::object
} {::alpha::object ::oo::object}

test oodialect-ancestry-005 {Testing heritage} {
  ::clay::ancestors ::delta::object
} {::delta::object ::charlie::object ::bravo::object ::alpha::object ::oo::object}

# -------------------------------------------------------------------------
# clay submodule testing
# -------------------------------------------------------------------------
# Test canonical path building
set path {const/ foo/ bar/ baz/}
}
set testnum 0
foreach {pattern} {
  {const foo bar baz}
  {const/ foo/ bar/ baz}
  {const/foo/bar/baz}
  {const/foo bar/baz}
  {const/foo/bar baz}
  {const foo/bar/baz}
  {const foo bar/baz}
  {const/foo bar baz}
} {
  putb result [list %pattern% $pattern %testnum% [format %04d [incr testnum]]] {
test oo-clay-path-%testnum% "Test path: %pattern%" {
  ::clay::path %pattern%
} $path
}
}
putb result {set path {const/ foo/ bar/ baz/ bing}}
set testnum 0
foreach {pattern} {
  {const foo bar baz bing}
  {const/ foo/ bar/ baz/ bing}
  {const/foo/bar/baz/bing}
  {const/foo bar/baz/bing:}
  {const/foo/bar baz bing}
  {const/foo/bar baz bing:}
  {const foo/bar/baz/bing}
  {const foo bar/baz/bing}
  {const/foo bar baz bing}
} {
  putb result [list %pattern% $pattern %testnum% [format %04d [incr testnum]]] {
test oo-clay-leaf-%testnum% "Test leaf: %pattern%" {
  ::clay::leaf %pattern%
} $path
}
}

putb result {namespace eval ::foo {}}

set class-a ::foo::classa
set commands-a {
  clay set const color  blue
  clay set const/flavor strawberry
  clay set {const/ sound} zoink
  clay set info/ {
    animal no
    building no
    subelement {pedantic yes}
  }
}
set claydict-a {
  const/ {color blue flavor strawberry sound zoink}
  info/  {
    animal no
    building no
    subelement {pedantic yes}
  }
}

putb result [list %class% ${class-a} %commands% ${commands-a}] {
clay::define %class% {
%commands%
}
}

set testnum 0
foreach {top children} ${claydict-a} {
  foreach {child value} $children {
    set map {}
    dict set map %class% ${class-a}
    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-class-clay-method-%testnum% "Test %class% %top% %child% exists" {
  %class% clay exists %top% %child%
} 1
}
    dict set map %test% [format %04d [incr testnum]]
    putb result $map {
test oo-class-clay-method-%testnum% "Test %class% %top% %child% value" {
  %class% clay get %top% %child%
} {%value%}
}
  }
}


set class-b ::foo::classb
set claydict-b {
  const/ {color black flavor vanilla feeling dread}
  info/  {subelement {spoon yes}}
}
set commands-b {}
foreach {top children} ${claydict-b} {
  foreach {child value} $children {
    putb commands-b "  [list clay set $top $child $value]"
  }
}
putb result [list %class% ${class-b} %commands% ${commands-b}] {
clay::define %class% {
%commands%
}
}

foreach {top children} ${claydict-b} {
  foreach {child value} $children {
    set map {}
    dict set map %class% ${class-b}
    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-class-clay-method-%testnum% "Test %class% %top% %child% exists" {
  %class% clay exists %top% %child%
} 1
}
    dict set map %test% [format %04d [incr testnum]]
    putb result $map {
test oo-class-clay-method-%testnum% "Test %class% %top% %child% value" {
  %class% clay get %top% %child%
} {%value%}
}
  }
}

set commands-c {superclass ::foo::classb ::foo::classa}
set class-c ::foo::class.ab
putb result [list %class% ${class-c} %commands% ${commands-c}] {
clay::define %class% {
%commands%
}
}
set commands-d {superclass ::foo::classa ::foo::classb}
set class-d ::foo::class.ba
putb result [list %class% ${class-d} %commands% ${commands-d}] {
clay::define %class% {
%commands%
}
}

###
# Tests for objects
###

putb result {# -------------------------------------------------------------------------
# OBJECT of ::foo::classa
set OBJECTA [::foo::classa new]

###
# Test object degation
###
proc ::foo::fakeobject {a b} {
  return [expr {$a + $b}]
}

::clay::object create TEST
TEST delegate funct ::foo::fakeobject
test oo-object-delegate-001 {Test object delegation} {
  ::TEST delegate
} {<class> ::clay::object <funct> ::foo::fakeobject}

test oo-object-delegate-002 {Test object delegation} {
  ::TEST delegate funct
} {::foo::fakeobject}

test oo-object-delegate-002a {Test object delegation} {
  ::TEST delegate <funct>
} {::foo::fakeobject}

test oo-object-delegate-003 {Test object delegation} {
  ::TEST <funct> 1 1
} {2}
test oo-object-delegate-004 {Test object delegation} {
  ::TEST <funct> 10 -7
} {3}

# Replace the function out from under
proc ::foo::fakeobject {a b} {
  return [expr {$a * $b}]
}
test oo-object-delegate-005 {Test object delegation} {
  ::TEST <funct> 10 -7
} {-70}

# Object with ::foo::classa mixed in
set MIXINA  [::oo::object new]
oo::objdefine $MIXINA mixin ::foo::classa
}
set matrix ${claydict-a}
set testnum 0
foreach {top children} $matrix {
  foreach {child value} $children {
    set map {}
    dict set map %object1% OBJECTA
    dict set map %object2% MIXINA

    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-object-clay-method-native-%testnum% {Test native object gets the property} {
  $%object1% clay get %top% %child%
} {%value%}
test oo-object-clay-method-mixin-%testnum% {Test mixin object gets the property} {
  $%object2% clay get %top% %child%
} {%value%}
}
  }
}

putb result {# -------------------------------------------------------------------------
# OBJECT of ::foo::classb
set OBJECTB [::foo::classb new]
# Object with ::foo::classb mixed in
set MIXINB  [::oo::object new]
oo::objdefine $MIXINB mixin ::foo::classb
}
set matrix ${claydict-b}
#set testnum 0
foreach {top children} $matrix {
  foreach {child value} $children {
    set map {}
    dict set map %object1% OBJECTB
    dict set map %object2% MIXINB

    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-object-clay-method-native-%testnum% {Test native object gets the property} {
  $%object1% clay get %top% %child%
} {%value%}
test oo-object-clay-method-mixin-%testnum% {Test mixin object gets the property} {
  $%object2% clay get %top% %child%
} {%value%}
}
  }
}

putb result {# -------------------------------------------------------------------------
# OBJECT descended from ::foo::classa ::foo::classb
set OBJECTAB [::foo::class.ab new]
# Object where classes were mixed in ::foo::classa ::foo::classb
set MIXINAB  [::oo::object new]
oo::objdefine $MIXINAB mixin ::foo::classa ::foo::classb
}
set matrix ${claydict-b}
foreach {top children} ${claydict-a} {
  foreach {child value} $children {
    if {![dict exists $matrix $top $child]} {
      dict set matrix $top $child $value
    }
  }
}
#set testnum 0
foreach {top children} $matrix {
  foreach {child value} $children {
    set map {}
    dict set map %object1% OBJECTAB
    dict set map %object2% MIXINAB

    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-object-clay-method-native-%testnum% {Test native object gets the property} {
  $%object1% clay get %top% %child%
} {%value%}
test oo-object-clay-method-mixin-%testnum% {Test mixin object gets the property} {
  $%object2% clay get %top% %child%
} {%value%}
}
  }
}

putb result {# -------------------------------------------------------------------------
# OBJECT descended from ::foo::classb ::foo::classa
set OBJECTBA [::foo::class.ba new]
# Object where classes were mixed in ::foo::classb ::foo::classa
set MIXINBA  [::oo::object new]
oo::objdefine $MIXINBA mixin ::foo::classb ::foo::classa
}
set matrix ${claydict-a}
foreach {top children} ${claydict-b} {
  foreach {child value} $children {
    if {![dict exists $matrix $top $child]} {
      dict set matrix $top $child $value
    }
  }
}
#set testnum 0
foreach {top children} $matrix {
  foreach {child value} $children {
    set map {}
    dict set map %object1% OBJECTBA
    dict set map %object2% MIXINBA

    dict set map %top% $top
    dict set map %child% $child
    dict set map %value% $value
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {
test oo-object-clay-method-native-%testnum% {Test native object gets the property} {
  $%object1% clay get %top% %child%
} {%value%}
test oo-object-clay-method-mixin-%testnum% {Test mixin object gets the property} {
  $%object2% clay get %top% %child%
} {%value%}
}
  }
}

putb resut {
###
# Test local setting if clay data in an object
###
set OBJECT [::foo::classa new]
test oo-object-clay-method-local-0001 {Test native object gets the property} {
  $OBJECT clay get const/ color
} {blue}
test oo-object-clay-method-local-0002 {Test that local settings override the inherited properties} {
  $OBJECT clay set const/ color black
  $OBJECT clay set const/
} {black}

test oo-object-clay-method-local-0003 {Test native object gets an empty property} {
  $OBJECT clay get color
} {}
test oo-object-clay-method-local-0004 {Test that local settings override the empty property} {
  $OBJECT clay set color orange
  $OBJECT clay get color
} {orange}

}

putb result {
###
# put a do-nothing constructor on the books
###
::clay::define ::clay::object {
  constructor args {}
}

oo::objdefine ::clay::object method foo args { return bar }

test clay-core-method-0001 {Test that adding methods to the core ::clay::object class works} {
  ::clay::object foo
} {bar}

namespace eval ::TEST {}
::clay::define ::TEST::myclass {
  clay color red
  clay flavor strawberry

}

###
# Test adding a clay property
###
test clay-class-clay-0001 {Test that a clay statement is recorded in the object of the class} {
  ::TEST::myclass clay get color
} red
test clay-class-clay-0002 {Test that a clay statement is recorded in the object of the class} {
  ::TEST::myclass clay get flavor
} strawberry

###
# Test that objects of the class get the same properties
###
set OBJ [::clay::object new {}]
set OBJ2 [::TEST::myclass new {}]

test clay-object-clay-a-0001 {Test that objects not thee class do not get properties} {
  $OBJ clay get color
} {}
test clay-object-clay-a-0002 {Test that objects not thee class do not get properties} {
  $OBJ clay get flavor
} {}
test clay-object-clay-a-0003 {Test that objects of the class get properties} {
  $OBJ2 clay get color
} red
test clay-object-clay-a-0004 {Test that objects of the class get properties} {
  $OBJ2 clay get flavor
} strawberry

test clay-object-clay-a-0005 {Test the clay ancestors function} {
  $OBJ clay ancestors
} {::clay::object ::oo::object}
test clay-object-clay-a-0006 {Test the clay ancestors function} {
  $OBJ2 clay ancestors
} {::TEST::myclass ::clay::object ::oo::object}
test clay-object-clay-a-0007 {Test the clay source function} {
  $OBJ2 clay source flavor
} ::TEST::myclass

###
# Test that object local setting override the class
###
test clay-object-clay-a-0008 {Test that object local setting override the class} {
  $OBJ2 clay set color purple
  $OBJ2 clay get color
} purple
test clay-object-clay-a-0009 {Test that object local setting override the class} {
  $OBJ2 clay source color
} self

::clay::define ::TEST::myclasse {
  superclass ::TEST::myclass

  clay color blue

  method do args {
    return "I did $args"
  }

  Ensemble which::color {} {
    return [my clay get color]
  }
}

###
# Test clay information is passed town to subclasses
###
test clay-class-clay-0003 {Test that a clay statement is recorded in the object of the class} {
  ::TEST::myclasse clay get color
} blue
test clay-class-clay-0004 {Test that clay statements from the ancestors of this class are not present (we handle them seperately in objects)} {
  ::TEST::myclasse clay get flavor
} {}


###
# Test that properties reach objects
###
set OBJ3 [::TEST::myclasse new {}]
test clay-object-clay-b-0001 {Test that objects of the class get properties} {
  $OBJ3 clay get color
} blue
test clay-object-clay-b-0002 {Test the clay source function} {
  $OBJ3 clay source color
} ::TEST::myclasse
test clay-object-clay-b-0003 {Test that objects of the class get properties} {
  $OBJ3 clay get flavor
} strawberry
test clay-object-clay-b-0004 {Test the clay source function} {
  $OBJ3 clay source flavor
} ::TEST::myclass
test clay-object-clay-b-0005 {Test the clay source function} {
  $OBJ3 clay ancestors
} {::TEST::myclasse ::TEST::myclass ::clay::object ::oo::object}

###
# Test defining a standard method
###
test clay-object-method-0001 {Test and standard method} {
  $OBJ3 do this really cool thing
} {I did this really cool thing}

test clay-object-method-0003 {Test an ensemble} {
  $OBJ3 which color
} blue
# Test setting properties
test clay-object-method-0004 {Test an ensemble} {
  $OBJ3 clay set color black
  $OBJ3 which color
} black

###
# Test that if you try to replace a global command you get an error
###
test clay-nspace-0001 {Test that if you try to replace a global command you get an error} -body {
::clay::define open {
  method bar {} { return foo }

}
}  -returnCodes {error} -result "::open does not refer to an object"

::clay::define fubar {
  method bar {} { return foo }
}
test clay-nspace-0002 {Test a non qualified class ends up in the current namespace} {
  info commands ::fubar
} {::fubar}

namespace eval ::cluster {
::clay::define fubar {
  method bar {} { return foo }
}

::clay::define ::clay::pot {
  method bar {} { return foo }
}

}
test clay-nspace-0003 {Test a non qualified class ends up in the current namespace} {
  info commands ::cluster::fubar
} {::cluster::fubar}
test clay-nspace-0003 {Test a fully qualified class ends up in the proper namespace} {
  info commands ::clay::pot
} {::clay::pot}

#set ::clay::trace 3

###
# Mixin tests
###

###
# Define a core class
###
::clay::define ::TEST::thing {

  method do args {
    return "I did $args"
  }
}


::clay::define ::TEST::vegetable {

  clay color unknown
  clay flavor unknown

  Ensemble which::flavor {} {
    return [my clay get flavor]
  }
  Ensemble which::color {} {
    return [my clay get color]
  }
}

::clay::define ::TEST::animal {

  clay color unknown
  clay sound unknown

  Ensemble which::sound {} {
    return [my clay get sound]
  }
  Ensemble which::color {} {
    return [my clay get color]
  }
}

::clay::define ::TEST::species.cat {
  superclass ::TEST::animal
  clay sound meow

}

::clay::define ::TEST::coloring.calico {
  clay color calico

}

::clay::define ::TEST::condition.dark {
  Ensemble which::color {} {
    return grey
  }
}

::clay::define ::TEST::mood.happy {
  Ensemble which::sound {} {
    return purr
  }
}

set OBJ [::TEST::thing new]
test clay-mixin-a-0001 {Test that prior to a mixin an ensemble doesn't exist} -body {
  $OBJ which color
} -returnCodes error -result {unknown method "which": must be clay, delegate, destroy, do, forward, mixin or source}

test clay-mixin-a-0002 {Test and standard method from an ancestor} {
  $OBJ do this really cool thing
} {I did this really cool thing}

$OBJ mixin species ::TEST::animal
test clay-mixin-b-0001 {Test that an ensemble is created during a mixin} {
  $OBJ which color
} {unknown}

test clay-mixin-b-0002 {Test that an ensemble is created during a mixin} {
  $OBJ which sound
} {unknown}
test clay-mixin-b-0003 {Test that an ensemble is created during a mixin} \
  -body {$OBJ which flavor} -returnCodes {error} \
  -result {unknown method which flavor. Valid: color sound}
test clay-mixin-b-0004 {Test that mixins resolve in the correct order} {
  $OBJ clay ancestors
} {::TEST::animal ::TEST::thing ::clay::object ::oo::object}

###
# Replacing a mixin replaces the behaviors
###
$OBJ mixin species ::TEST::vegetable
test clay-mixin-c-0001 {Test that an ensemble is created during a mixin} {
  $OBJ which color
} {unknown}
test clay-mixin-c-0002 {Test that an ensemble is created during a mixin} \
  -body {$OBJ which sound} \
  -returnCodes {error} \
  -result {unknown method which sound. Valid: color flavor}
test clay-mixin-c-0003 {Test that an ensemble is created during a mixin} {
  $OBJ which flavor
} {unknown}
test clay-mixin-c-0004 {Test that mixins resolve in the correct order} {
  $OBJ clay ancestors
} {::TEST::vegetable ::TEST::thing ::clay::object ::oo::object}

###
# Replacing a mixin
$OBJ mixin species ::TEST::species.cat
test clay-mixin-e-0001 {Test that an ensemble is created during a mixin} {
  $OBJ which color
} {unknown}
test clay-mixin-e-0002 {Test that an ensemble is created during a mixin} {
  $OBJ which sound
} {meow}
test clay-mixin-e-0003 {Test that an ensemble is created during a mixin} \
  -body {$OBJ which flavor} -returnCodes {error} \
  -result {unknown method which flavor. Valid: color sound}
test clay-mixin-e-0004 {Test that clay data follows the rules of inheritence and order of mixin} {
  $OBJ clay ancestors
} {::TEST::species.cat ::TEST::thing ::TEST::animal ::clay::object ::oo::object}

$OBJ mixin coloring ::TEST::coloring.calico
test clay-mixin-f-0001 {Test that an ensemble is created during a mixin} {
  $OBJ which color
} {calico}
test clay-mixin-f-0002 {Test that an ensemble is created during a mixin} {
  $OBJ which sound
} {meow}
test clay-mixin-f-0003 {Test that an ensemble is created during a mixin} \
  -body {$OBJ which flavor} -returnCodes {error} \
  -result {unknown method which flavor. Valid: color sound}
test clay-mixin-f-0004 {Test that clay data follows the rules of inheritence and order of mixin} {
  $OBJ clay ancestors
} {::TEST::coloring.calico ::TEST::species.cat ::TEST::thing ::clay::object ::TEST::animal ::oo::object}

test clay-mixin-f-0005 {Test that clay data from a mixin works} {
  $OBJ clay source color
} {::TEST::coloring.calico}

###
# Test variable initialization
###
::clay::define ::TEST::has_var {
  Variable my_variable 10

  method get_my_variable {} {
    my variable my_variable
    return $my_variable
  }
}

set OBJ [::TEST::has_var new]
test clay-class-variable-0001 {Test that the parser injected the right value in the right place for clay to catch it} {
  $OBJ clay get public/ variable/ my_variable
} {10}

test clay-class-variable-0002 {Test that variables declared in the class definition are initialized} {
  $OBJ get_my_variable
} 10

###
# Test array initialization
###
::clay::define ::TEST::has_array {
  Array my_array {timeout 10}

  method get_my_array {field} {
    my variable my_array
    return $my_array($field)
  }
}

set OBJ [::TEST::has_array new]
test clay-class-array-0001 {Test that the parser injected the right value in the right place for clay to catch it} {
  $OBJ clay get public/ array/
} {my_array/ {timeout 10}}

test clay-class-arrau-0002 {Test that variables declared in the class definition are initialized} {
  $OBJ get_my_array timeout
} 10

###
# Test dict initialization
###
::clay::define ::TEST::has_dict {
  Dict my_dict {timeout 10}

  method get_my_dict {args} {
    my variable my_dict
    return [dict get $my_dict {*}$args]
  }
}

set OBJ [::TEST::has_dict new]
test clay-class-dict-0001 {Test that the parser injected the right value in the right place for clay to catch it} {
  $OBJ clay get public/ dict/
} {my_dict/ {timeout 10}}

test clay-class-dict-0002 {Test that variables declared in the class definition are initialized} {
  $OBJ get_my_dict timeout
} 10

###
# Test object delegation
###
::clay::define ::TEST::organelle {
  method add args {
    set total 0
    foreach item $args {
      set total [expr {$total+$item}]
    }
    return $total
  }
}
::clay::define ::TEST::master {
  constructor {} {
    set mysub [namespace current]::sub
    ::TEST::organelle create $mysub
    my delegate sub $mysub
  }
}

set OBJ [::TEST::master new]
###
# Test that delegation is working
###
test clay-delegation-0001 {Test an array driven ensemble} {
  $OBJ <sub> add 5 5
} 10


###
# Test the Ensemble keyword
###
::clay::define ::TEST::with_ensemble {

  Ensemble myensemble {pattern args} {
    set ensemble [self method]
    set emap [my Ensemble_Map $ensemble]
    set mlist [dict keys $emap [string tolower $pattern]]
    if {[llength $mlist] != 1} {
      error "Couldn't figure out what to do with $pattern"
    }
    set method [lindex $mlist 0]
    set arglist [dict get $emap $method arglist]
    set body    [dict get $emap $method body]
    if {$arglist ni {args {}}} {
      ::clay::dynamic_arguments $ensemble $method [list $arglist] {*}$args
    }
    eval $body
  }

  Ensemble myensemble::go args {
    return 1
  }
}

::clay::define ::TEST::with_ensemble.dance {
  Ensemble myensemble::dance args {
    return 1
  }
}
::clay::define ::TEST::with_ensemble.cannot_dance {
  Ensemble myensemble::dance args {
    return 0
  }
}

set OBJA [::clay::object new]
set OBJB [::clay::object new]

$OBJA mixin \
  core ::TEST::with_ensemble \
  friends ::TEST::with_ensemble.dance

$OBJB mixin \
  core ::TEST::with_ensemble \
  friends ::TEST::with_ensemble.cannot_dance
}

set testnum 0

set matrix {
  go {
    OBJA 1
    OBJB 1
  }
  dance {
    OBJA 1
    OBJB 0
  }
}
foreach {action output} $matrix {
  putb result "# Test $action"
  foreach {object value} $output {
    set map [dict create %object% $object %action% $action %value% $value]
    dict set map %testnum% [format %04d [incr testnum]]
    putb result $map {test clay-dynamic-ensemble-%testnum% {Test ensemble with static method} {
  $%object% myensemble %action%
} {%value%}}
  }
}

###
# TESTS NEEDED:
# destructor
###

putb result {
testsuiteCleanup

# Local variables:
# mode: tcl
# indent-tabs-mode: nil
# End:
}
return $result
