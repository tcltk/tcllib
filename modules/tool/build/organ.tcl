###
# A special class of objects that
# stores no clay data of its own
# Instead it vampires off of the master object
###
tool::class create ::tool::organelle {
  
  constructor {master} {
    my entangle $master
    set final_class [my select]
    if {[info commands $final_class] ne {}} {
      # Safe to switch class here, we haven't initialized anything
      oo::objdefine [self] class $final_class
    }
    my initialize
  }

  method entangle {master} {
    my graft master $master
    my forward clay $master meta
    foreach {stub organ} [$master organ] {
      my graft $stub $organ
    }
    foreach {methodname variable} [my clay branchget array_ensemble] {
      my forward $methodname $master $methodname
    }
  }
  
  method select {} {
    return {}
  }
}
