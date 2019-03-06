[subsection {Critcl & Accelerators}]

[para] A number of packages come with [term accelerators], i.e.
[syscmd critcl]-based C code whose use will boost the performance of
the packages using them. As these accelerators are optional they are
not installed by default.

[para] To build the accelerators the normally optional dependency on
[syscmd critcl] becomes required.

[para] To install Tcllib with the accelerators run

[example {
    ./configure
    make critcl # This builds the shared library holding the accelerators
    make install
}]

[para] The underlying tool is [file sak.tcl] in the toplevel directory
of Tcllib and the command [cmd {make critcl}] is just a wrapper around

[example {
    ./sak.tcl critcl
}]
