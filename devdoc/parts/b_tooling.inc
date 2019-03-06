
The Tcllib distribution, whether a checkout directly from the source
repository, or an official release, offers a single method for
installing it, based on Tcl itself.

[para] This is based on the assumption that for Tcllib to be of use
Tcl has to be present, and therefore can be used in the implementation
of the install code.

[para] The relevant tool is the [file installer.tcl] script found in
the toplevel directory of a checkout or release.

[para] It can be used in a variety of ways:

[list_begin enumerated]

[enum] It is always possible to invoke the tool directly, either as

[example {
    ./installer.tcl
}]

or

[example {
    /path/to/tclsh ./installer.tcl
}]

The second form is required on Windows (without a Unix emulation),
except if the Tcl installation is configured to handle [file .tcl]
files on a double-click.

[enum]

In a unix-type environment, i.e. Linux, BSD and related, including OS
X, and Windows using some kind of unix-emulation like [syscmd MSYS],
[syscmd Cygwin], etc.) it is also possible to use

[example {
    ./configure
    make install
}]

in the toplevel directory of Tcllib itself.

[para] To build in a directory [file D] outside of Tcllib's toplevel
directory simply make [file D] the current working directory and
invoke [syscmd configure] with either its absolute path or a proper
relative path.

[para] This will non-interactively install all packages, applications
found in Tcllib, and their manpages, in directories derived from what
[syscmd configure] found out about the system.

[list_end]

[para] The installer selects automatically either a gui based mode, or
a command line based mode. If the package [package Tk] is present and
can be loaded, then the GUI mode is entered, else the system falls
back to the command line.

[para] Note that it is possible to specify options on the command line
even if the installer ultimatively selects GUI mode. In that case the
hardwired defaults and the options determine the data presented to the
user for editing.

[para] Command line help can be asked for by using the option [option -help] when
invoking the installer, i.e.

[example {
    ./installer.tcl -help
}]

This will print a short list of the available options to the standard
output channel. For more examples see the various [term install]
targets found in [file Makefile.in].

[para] The installer will select a number of defaults for the
locations of packages, examples, and documentation, and also the
format of the documentation. The user can overide these defaults in
the GUI, or by specifying additional options.

[para] The defaults depend on the platform detected (unix/windows) and
on the [syscmd tclsh] executable used to run the installer.

[para][strong Attention] The installer will overwrite an existing
installation of a Tcllib with the same version without asking back
after the initial confirmation is given.

Further if the user chooses the same directory as chosen for/by
previous installations then these will be overwritten as well.
