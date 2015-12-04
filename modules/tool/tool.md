Module: TOOL
============

TOOL is the Tcl Object Oriented Library, a standard object framework. TOOL
implements common design patterns in a standardized, tested, and documented
manner. 

# Major Concepts

* Metadata Interitance
* Variable and Array Initialization
* Option handling
* Delegation
* Method Ensembles

## Metadata Interitance

TOOL builds on the oo::meta package to allow data and configuration to be
passed along to descendents in the same way methods are.

<pre><code>
tool::class create fruit {
  property taste sweet
}
tool::class create fruit.apple {
  property color red
}
tool::class create fruit.orange {
  property color orange
}
fruit.orange create cutie
cutie property color
> orange
cutie property taste
> sweet
</code></pre>

## Variable and Array Initialization

TOOL modifies the *variable* keyword and adds and *array* keyword. Using
either will cause a variable of the given name to be initialized with the
given value for this class AND any descendents.

<pre><code>
tool::class create car {
  option color {
    default: white
  }
  variable location home
  
  method location {} {
    my variable location
    return $location
  }
  method move newloc {
    my variable location
    set location $newloc
  }
}

car create car1 color green
car1 cget color
> green
car create car2
car2 cget color
> white
</code></pre>

car1 location
> home
car1 move work
car1 location
> work
</code></pre>

## Delegation

TOOL is built around objects delegating functions to other objects. To
keep track of who is who, 
