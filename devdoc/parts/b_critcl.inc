
While the majority of Tcllib consists of packages written in pure Tcl
a number of packages also have [term accelerators] associated with them.

These are [syscmd critcl]-based C packages whose use will boost the
performance of the packages using them.

These accelerators are optional, and they are not installed by
default.

[para] To build the accelerators the normally optional dependency on
       [syscmd critcl] becomes required.

[para] To build and install Tcllib with the accelerators in a
       Unix-like environment invoke:

[example {
  ./configure
  make critcl # This builds the shared library holding
              # the accelerators
  make install
}]

[para] The underlying tool is [file sak.tcl] in the toplevel directory
of Tcllib and the command [cmd {make critcl}] is just a wrapper around

[example {
  ./sak.tcl critcl
}]

[para] Therefore in a Windows environment instead invoke

[example {
  ./sak.tcl critcl
  ./installer.tcl
}]

from within a DOS window, i.e. [syscmd cmd.exe].
