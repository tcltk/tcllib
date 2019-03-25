
[//000000001]: # (tcllib\_install\_guide \- )
[//000000002]: # (Generated from file 'tcllib\_installer\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcllib\_install\_guide\(n\) 1 tcllib "")

<hr> [ <a href="../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../toc.md">Table Of Contents</a> &#124; <a
href="../../../index.md">Keyword Index</a> &#124; <a
href="../../../toc0.md">Categories</a> &#124; <a
href="../../../toc1.md">Modules</a> &#124; <a
href="../../../toc2.md">Applications</a> ] <hr>

# NAME

tcllib\_install\_guide \- Tcllib \- The Installer's Guide

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Description](#section1)

  - [Requisites](#section2)

      - [Tcl](#subsection1)

      - [Critcl](#subsection2)

  - [Build & Installation Instructions](#section3)

      - [Critcl & Accelerators](#subsection3)

# <a name='description'></a>DESCRIPTION

Welcome to Tcllib, the Tcl Standard Library\. Note that Tcllib is not a package
itself\. It is a collection of \(semi\-independent\)
*[Tcl](\.\./\.\./\.\./index\.md\#tcl)* packages that provide utility functions
useful to a large collection of Tcl programmers\.

The audience of this document is anyone wishing to build the packages, for
either themselves, or others\.

For a developer intending to extend or modify the packages we additionally
provide

  1. *[Tcllib \- The Developer's Guide](tcllib\_devguide\.md)*\.

Please read *[Tcllib \- How To Get The Sources](tcllib\_sources\.md)* first,
if that was not done already\. Here we assume that the sources are already
available in a directory of your choice\.

# <a name='section2'></a>Requisites

Before Tcllib can be build and used a number of requisites must be installed\.
These are:

  1. The scripting language Tcl\. For details see [Tcl](#subsection1)\.

  1. Optionally, the __critcl__ package \(C embedding\) for
     __[Tcl](\.\./\.\./\.\./index\.md\#tcl)__\. For details see __CriTcl__\.

This list assumes that the machine where Tcllib is to be installed is
essentially clean\. Of course, if parts of the dependencies listed below are
already installed the associated steps can be skipped\. It is still recommended
to read their sections though, to validate that the dependencies they talk about
are indeed installed\.

## <a name='subsection1'></a>Tcl

As we are installing a number of Tcl packages and applications it should be
pretty much obvious that a working installation of Tcl itself is needed, and I
will not belabor the point\.

Out of the many possibilities use whatever you are comfortable with, as long as
it provides at the very least Tcl 8\.2, or higher\. This may be a Tcl installation
provided by your operating system distribution, from a distribution\-independent
vendor, or built by yourself\.

*Note* that the packages in Tcllib have begun to require 8\.4, 8\.5, and even
8\.6\. Older versions of Tcl will not be able to use such packages\. Trying to use
them will result in *package not found* errors, as their package index files
will not register them in versions of the core unable to use them\.

Myself, I used \(and still use\) [ActiveState's](http://www\.activestate\.com)
ActiveTcl 8\.5 distribution during development, as I am most familiar with it\.

*\(Disclosure: I, Andreas Kupries, worked for ActiveState until 2016,
maintaining ActiveTcl and TclDevKit for them\)\.*\. I am currently working for
SUSE Software Canada ULC, although not in Tcl\-related areas\.

This distribution can be found at
[http://www\.activestate\.com/activetcl](http://www\.activestate\.com/activetcl)\.
Retrieve the archive of ActiveTcl 8\.5 \(or higher\) for your platform and install
it as directed by ActiveState\.

For those wishing to build and install Tcl on their own, the relevant sources
can be found at

  - Tcl

    [http://core\.tcl\-lang\.org/tcl/](http://core\.tcl\-lang\.org/tcl/)

together with the necessary instructions on how to build it\.

If there are problems with building, installing, or using Tcl, please file a
ticket against *[Tcl](\.\./\.\./\.\./index\.md\#tcl)*, or the vendor of your
distribution, and *not* *[Tcllib](\.\./\.\./\.\./index\.md\#tcllib)*\.

## <a name='subsection2'></a>Critcl

The __critcl__ tool is an *optional* dependency\.

It is only required when trying to build the C\-based *accelerators* for a
number of packages, as explained in [Critcl & Accelerators](#subsection3)

Tcllib's build system looks for it in the , using the name __critcl__\. This
is for Unix\. On Windows on the other hand the search is more complex\. First we
look for a proper application __critcl\.exe__\. When that is not found we look
for a combination of interpreter \(__tclkitsh\.exe__, __tclsh\.exe__\) and
starkit \(__critcl\.kit__, __critcl__\) instead\. *Note* that the choice
of starkit can be overriden via the environment variable \.

Tcllib requires Critcl version 2 or higher\.

The github repository providing releases of version 2 and higher, and the
associated sources, can be found at
[http://andreas\-kupries\.github\.com/critcl](http://andreas\-kupries\.github\.com/critcl)\.

Any branch of the repository can be used \(if not using the prebuild starkit or
starpack\), although the use of the stable branch *master* is recommended\.

At the above url is also an explanation on how to build and install Critcl,
including a list of its dependencies\.

Its instructions will not be repeated here\. If there are problems with these
directions please file a ticket against the *Critcl* project, and not Tcllib\.

# <a name='section3'></a>Build & Installation Instructions

The Tcllib distribution, whether a checkout directly from the source repository,
or an official release, offers a single method for installing it, based on Tcl
itself\.

This is based on the assumption that for Tcllib to be of use Tcl has to be
present, and therefore can be used in the implementation of the install code\.

The relevant tool is the "installer\.tcl" script found in the toplevel directory
of a checkout or release\.

It can be used in a variety of ways:

  1. It is always possible to invoke the tool directly, either as

         \./installer\.tcl

     or

         /path/to/tclsh \./installer\.tcl

     The second form is required on Windows \(without a Unix emulation\), except
     if the Tcl installation is configured to handle "\.tcl" files on a
     double\-click\.

  1. In a Unix\-type environment, i\.e\. Linux, BSD and related, including OS X,
     and Windows using some kind of unix\-emulation like __MSYS__,
     __Cygwin__, etc\.\) it is also possible to use

         \./configure
         make install

     in the toplevel directory of Tcllib itself\.

     To build in a directory "D" outside of Tcllib's toplevel directory simply
     make "D" the current working directory and invoke __configure__ with
     either its absolute path or a proper relative path\.

     This will non\-interactively install all packages, applications found in
     Tcllib, and their manpages, in directories derived from what
     __configure__ found out about the system\.

The installer selects automatically either a GUI based mode, or a command line
based mode\. If the package __[Tk](\.\./\.\./\.\./index\.md\#tk)__ is present and
can be loaded, then the GUI mode is entered, else the system falls back to the
command line\.

Note that it is possible to specify options on the command line even if the
installer ultimatively selects GUI mode\. In that case the hardwired defaults and
the options determine the data presented to the user for editing\.

Command line help can be asked for by using the option __\-help__ when
invoking the installer, i\.e\.

    \./installer\.tcl \-help

This will print a short list of the available options to the standard output
channel\. For more examples see the various *install* targets found in
"Makefile\.in"\.

The installer will select a number of defaults for the locations of packages,
examples, and documentation, and also the format of the documentation\. The user
can overide these defaults in the GUI, or by specifying additional options\.

The defaults depend on the platform detected \(Unix/Windows\) and on the
__tclsh__ executable used to run the installer\.

*Attention* The installer will overwrite an existing installation of a Tcllib
with the same version without asking back after the initial confirmation is
given\. Further if the user chooses the same directory as chosen for/by previous
installations then these will be overwritten as well\.

## <a name='subsection3'></a>Critcl & Accelerators

A number of packages come with *accelerators*, i\.e\. __critcl__\-based C
code whose use will boost the performance of the packages using them\. As these
accelerators are optional they are not installed by default\.

To build the accelerators the normally optional dependency on __critcl__
becomes required\.

To install Tcllib with the accelerators in a Unix\-type environment invoke:

    \./configure
    make critcl \# This builds the shared library holding
                \# the accelerators
    make install

The underlying tool is "sak\.tcl" in the toplevel directory of Tcllib and the
command __make critcl__ is just a wrapper around

    \./sak\.tcl critcl

Therefore in a Windows environment instead invoke

    /path/to/tclsh \./sak\.tcl critcl
    /path/to/tclsh \./installer\.tcl
