[subsection Windows]

This section describes the actions required to install Tcllib on Windows(tm)
systems.

If you have to install Tcllib on a Unix machine (Linux, BSD, and
related, including OS X) instead then see section [sectref Unix].

[para] If the build environment is based on [term MSYS],
[term cygwin], or a similar emulation of a unix environment, then
[sectref Unix] still applies and should be used.

[para] Alternatively, as mentioned in the previous section, the tool
underneath of the unix buildsystem is the [term Tcl]-based
[file installer.tcl] script.

[para] Invoking this tool from a DOS shell via

[example {
    /path/to/tclsh ./installer.tcl -help
}]

will provide a short list of the available options. For more examples
see the various [term install] targets found in [file Makefile.in].

Invoking this tool without any arguments, i.e. like

[example {
    /path/to/tclsh ./installer.tcl
}]

will start a non-interactive installation showing its progress in a
Tk-based graphical interface. The directories to install the packages,
applications, etc. into are derived from the location of the
[syscmd tclsh] used to invoke the script, and where it expects
packages.
