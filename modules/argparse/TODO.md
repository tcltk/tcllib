- Remove `-boolean` 
  - Instead, act as if `-boolean` were always being passed to [argparse]
  - Remove `-keep` as well
  - Add an `-unset` switch to selectively change the behavior to unsetting a
    variable or omitting a dict key when the switch is not present
- Documentation
  - Instead of having a big comment, use doctools
- Help text generation
  - Parameter and switch descriptions given by per-element `-help` switch
  - Need overall `-help` switch to provide narrative description
  - May need special grouping elements to organize switches and parameters
  - Text formatting and word wrapping
- Automatic command usage error message
  - Takes the place of Tcl\_WrongNumArgs()
- Single-character switch clustering
  - Requires use of `-long` for switches with multi-character names
- Reimplement in C for performance reasons
  - No bytecoding needed
  - Continue to maintain Tcl version for reference and portability
  - Provide stubs-enabled C API
  - One function for parsing definition list
  - One function for parsing argument list against preparsed definition list
  - Custom Tcl\_Obj type for preparsed definition list
- Test suite
  - Possibly the most daunting part of the project

<!-- vim: set sts=4 sw=4 tw=80 et ft=markdown: -->
