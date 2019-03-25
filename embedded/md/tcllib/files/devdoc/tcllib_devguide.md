
[//000000001]: # (tcllib\_devguide \- )
[//000000002]: # (Generated from file 'tcllib\_devguide\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (tcllib\_devguide\(n\) 1 tcllib "")

<hr> [ <a href="../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../toc.md">Table Of Contents</a> &#124; <a
href="../../../index.md">Keyword Index</a> &#124; <a
href="../../../toc0.md">Categories</a> &#124; <a
href="../../../toc1.md">Modules</a> &#124; <a
href="../../../toc2.md">Applications</a> ] <hr>

# NAME

tcllib\_devguide \- Tcllib \- The Developer's Guide

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Commitments](#section2)

      - [Contributor](#subsection1)

      - [Maintainer](#subsection2)

  - [Branching and Workflow](#section3)

      - [Branches](#subsection3)

      - [Version numbers](#subsection4)

  - [Structural Overview](#section4)

      - [Main Directories](#subsection5)

      - [More Directories](#subsection6)

      - [Top Files](#subsection7)

      - [File Types](#subsection8)

  - [Testsuite Tooling](#section5)

      - [Invoke the testsuites of a specific module](#subsection9)

      - [Invoke the testsuites of all modules](#subsection10)

      - [Detailed Test Logs](#subsection11)

      - [Shell Selection](#subsection12)

      - [Help](#subsection13)

  - [Documentation Tooling](#section6)

      - [Generate documentation for a specific module](#subsection14)

      - [Generate documentation for all modules](#subsection15)

      - [Available output formats, help](#subsection16)

      - [Validation without output](#subsection17)

  - [Notes On Writing A Testsuite](#section7)

  - [Installation Tooling](#section8)

# <a name='synopsis'></a>SYNOPSIS

[__[Module](\.\./\.\./\.\./index\.md\#module)__ *name* *code\-action* *doc\-action* *example\-action*](#1)  
[__[Application](\.\./\.\./\.\./index\.md\#application)__ *name*](#2)  
[__Exclude__ *name*](#3)  

# <a name='description'></a>DESCRIPTION

Welcome to Tcllib, the Tcl Standard Library\. Note that Tcllib is not a package
itself\. It is a collection of \(semi\-independent\)
*[Tcl](\.\./\.\./\.\./index\.md\#tcl)* packages that provide utility functions
useful to a large collection of Tcl programmers\.

This document is a guide for developers working on Tcllib, i\.e\. maintainers
fixing bugs, extending the collection's functionality, etc\.

Please read

  1. *[Tcllib \- How To Get The Sources](tcllib\_sources\.md)* and

  1. *[Tcllib \- The Installer's Guide](tcllib\_installer\.md)*

first, if that was not done already\.

Here we assume that the sources are already available in a directory of your
choice, and that you not only know how to build and install them, but also have
all the necessary requisites to actually do so\. The guide to the sources in
particular also explains which source code management system is used, where to
find it, how to set it up, etc\.

# <a name='section2'></a>Commitments

## <a name='subsection1'></a>Contributor

As a contributor to Tcllib you are committing yourself to:

  1. Follow the guidelines laid down in *[Tcl Community \- Kind
     Communication](tcl\_community\_communication\.md)*

  1. Your contributions getting distributed under a BSD/MIT license\. For the
     details see *[Tcllib \- License](tcllib\_license\.md)*

Contributions are made by entering tickets into our tracker, providing patches,
bundles or branches of code for inclusion, or posting to the Tcllib related
mailing lists\.

## <a name='subsection2'></a>Maintainer

When contributing one or more packages for full inclusion into Tcllib you are
committing yourself to

  1. Follow the guidelines laid down in *[Tcl Community \- Kind
     Communication](tcl\_community\_communication\.md)* \(as any contributor\)

  1. Your packages getting distributed under a BSD/MIT license\. For the details
     see *[Tcllib \- License](tcllib\_license\.md)*

  1. Maintenance of the new packages for a period of two years under the
     following rules, and responsibilities:

       1) A maintainer may step down after the mandatory period as they see fit\.

       1) A maintainer may step down before the end of the mandatory period,
          under the condition that a replacement maintainer is immediately
          available and has agreed to serve the remainder of the period, plus
          their own mandatory period \(see below\)\.

       1) When stepping down without a replacement maintainer taking over the
          relevant packages have to be flagged as __unmaintained__\.

       1) When a replacement mantainer is brought in for a package it is \(kept\)
          marked as __maintained__ \(again\)\.

          A replacement maintainer is bound by the same rules as the original
          maintainer, except that the mandatory period of maintenance is
          shortened to one year\.

       1) For any __unmaintained__ package a contributor interested in
          becoming its maintainer can become so by flagging them as
          __maintained__ with their name and contact information, committing
          themselves to the rules of a replacement maintainer \(see previous
          point\)\.

       1) For any already __maintained__ package a contributor interested in
          becoming a co\-maintainer can become so with the agreement of the
          existing maintainer\(s\), committing themselves to the rules of a
          replacement maintainer \(see two points previous\)\.

     The responsibilities as a maintainer include:

       1) Watching Tcllib's ticket tracker for bugs, bug fixes, and feature
          requests related to the new packages\.

       1) Reviewing the aforementioned tickets, rejecting or applying them

       1) Coordination and discussion with ticket submitter during the
          development and/or application of bug fixes\.

  1. Follow the [Branching and Workflow](#section3) of this guide\.

# <a name='section3'></a>Branching and Workflow

## <a name='subsection3'></a>Branches

An important part of working with a *Distributed Version Control System*
\(*DVCS*\) like [fossil](https://www\.fossil\-scm\.org/) is the management and
use of branches\.

For Tcllib the main branch of the collection is *trunk*\. In *git* this
branch would be called *master*, and this exactly the case in the [github
mirror](https://github\.com/tcltk/tcllib/) of Tcllib\.

In support of debugging, like searching for when an issue appeared via
bisection, each commit on this branch must pass the entire testsuite of the
collection\.

As fossil has no mechanism to enforce this this is handled on the honor system
for developers and maintainers\.

To make the task easier Tcllib comes with a tool \("sak\.tcl"\) providing a number
of commands in support\. These commands are explained in the following sections
of this guide\.

While it is possible and allowed to commit directly to trunk remember the above
regarding the testsuite, and the coming notes about other possible issues with a
commit\.

Because of this it is \(strongly\) recommended to perform any development on a
nicely named \(nick of dev, ticket reference if any, keywords applicable to the
work, \.\.\.\) non\-trunk branch\. Outside of the trunk developers are allowed to
commit intermediate broken states of their work\. Only at the end, when the
branch is considered ready for merging will it be necessary to perform full
validation\.

## <a name='subsection4'></a>Version numbers

In Tcllib all changes to a package have to come with an increment of its version
number\. What part is incremented \(patchlevel, minor, major version\) depends on
the kind of change made\. With multiple changes in a commit the highest "wins"\.

When working in a development branch the version change can be deferred until it
is time to merge, and then has to cover all the changes in the branch\.

Below a list of the kinds of changes and their association version increments:

  - *D \- documentation*

    No increment

  - *T \- testsuite*

    No increment

  - *B \- bugfix*

    Patchlevel

  - *I \- implementation tweak*

    Patchlevel

  - *P \- performance tweak*

    Patchlevel

  - *E \- backward\-compatible extension*

    Minor

  - *API \- incompatible change*

    Major

Note, a commit containing a version increment has to mention the kind of change
which caused it in the commit message, as well as the new version number\.

Note further that the version number of a package currently exists in 3 places\.
An increment has to update all of them:

  1. The package implementation\.

  1. The package index \("pkgIndex\.tcl"\)

  1. The package documentation\.

The "sak\.tcl" command __validate version__ helps finding discrepancies
between the first two\. All the other __validate__ methods are also of
interest to any developer\. Invoke it with

    sak\.tcl help validate

to see their documentation\.

# <a name='section4'></a>Structural Overview

## <a name='subsection5'></a>Main Directories

The main directories in the Tcllib toplevel directory and of interest to a
developer are:

  - "modules"

    Each child directory represents one or more packages\. In the case of the
    latter the packages are usually related in some way\. Examples are "base64",
    "math", and "struct", with loose \(base64\) to strong \(math\) relations between
    the packages in the directory\.

  - "apps"

    This directory contains all the installable applications, with their
    documentation\. Note that this directory is currently *not* split into
    sub\-directories\.

  - "examples"

    Each child directory "foo" contains one or more example application for the
    packages in "modules/foo"\. These examples are generally not polished enough
    to be considered for installation\.

## <a name='subsection6'></a>More Directories

  - "config"

    This directory contains files supporting the Unix build system, i\.e\.
    "configure" and "Makefile\.in"\.

  - "devdoc"

    This directories contains the doctools sources for the global documentation,
    like this document and its sibling guides\.

  - "embedded"

    This directory contains the entire documentation formatted for
    *[HTML](\.\./\.\./\.\./index\.md\#html)* and styled to properly mix into the
    web site generated by fossil for the repository\.

    This is the documentation accessible from the Tcllib home directory,
    represented in the repository as "embedded/index\.md"\.

  - "idoc"

    This directory contains the entire documentation formatted for
    *[nroff](\.\./\.\./\.\./index\.md\#nroff)* and
    *[HTML](\.\./\.\./\.\./index\.md\#html)*, the latter without any styling\. This
    is the documentation which will be installed\.

  - "support"

    This directory contains the sources of internal packages and utilities used
    in the implementation of the "installer\.tcl" and "sak\.tcl" scripts/tools\.

## <a name='subsection7'></a>Top Files

  - "aclocal\.m4"

  - "configure"

  - "configure\.in"

  - "Makefile\.in"

    These four files comprise the Unix build system layered on top of the
    "installer\.tcl" script\.

  - "installer\.tcl"

    The Tcl\-based installation script/tool\.

  - "project\.shed"

    Configuration file for *Sean Wood*'s
    __[PracTcl](\.\./modules/practcl/practcl\.md)__ buildsystem\.

  - "sak\.tcl"

    This is the main tool for developers and release managers, the *Swiss Army
    Knife* of management operations on the collection\.

  - "ChangeLog"

    The log of changes to the global support, when the sources were held in
    *[CVS](\.\./\.\./\.\./index\.md\#cvs)*\. Not relevant any longer with the
    switch to the *fossil* SCM\.

  - "license\.terms"

    The license in plain ASCII\. See also *[Tcllib \-
    License](tcllib\_license\.md)* for the nicely formatted form\. The text is
    identical\.

  - "README\.md"

  - "\.github/CONTRIBUTING\.md"

  - "\.github/ISSUE\_TEMPLATE\.md"

  - "\.github/PULL\_REQUEST\_TEMPLATE\.md"

    These markdown\-formatted documents are used and shown by the github mirror
    of these sources, pointing people back to the official location and issue
    trackers\.

  - "DESCRIPTION\.txt"

  - "STATUS"

  - "tcllib\.spec"

  - "tcllib\.tap"

  - "tcllib\.yml"

    ????

## <a name='subsection8'></a>File Types

The most common file types, by file extension, are:

  - "\.tcl"

    Tcl code for a package, application, or example\.

  - "\.man"

    Doctools\-formatted documentation, usually for a package\.

  - "\.test"

    Test suite for a package, or part of\. Based on __tcltest__\.

  - "\.bench"

    Performance benchmarks for a package, or part of\. Based on "modules/bench"\.

  - "\.pcx"

    Syntax rules for *TclDevKit*'s __tclchecker__\. Using these rules
    allows the checker to validate the use of commands of a Tcllib package
    __foo__ without having to scan the "\.tcl" files implementing it\.

# <a name='section5'></a>Testsuite Tooling

Testsuites in Tcllib are based on Tcl's standard test package __tcltest__,
plus utilities found in the directory "modules/devtools"

Tcllib developers invoke the suites through the __test run__ method of the
"sak\.tcl" tool, with other methods of __[test](\.\./\.\./\.\./index\.md\#test)__
providing management operations, for example setting a list of standard Tcl
shells to use\.

## <a name='subsection9'></a>Invoke the testsuites of a specific module

Invoke either

    \./sak\.tcl test run foo

or

    \./sak\.tcl test run modules/foo

to invoke the testsuites found in a specific module "foo"\.

## <a name='subsection10'></a>Invoke the testsuites of all modules

Invoke the tool without a module name, i\.e\.

    \./sak\.tcl test run

to invoke the testsuites of all modules\.

## <a name='subsection11'></a>Detailed Test Logs

In all the previous examples the test runner will write a combination of
progress display and testsuite log to the standard output, showing for each
module only the tests that passed or failed and how many of each in a summary at
the end\.

To get a detailed log, it is necessary to invoke the test runner with additional
options\.

For one:

    \./sak\.tcl test run \-\-log LOG foo

While this shows the same short log on the terminal as before, it also writes a
detailed log to the file "LOG\.log", and excerpts to other files \("LOG\.summary",
"LOG\.failures", etc\.\)\.

For two:

    \./sak\.tcl test run \-v foo

This writes the detailed log to the standard output, instead of the short log\.

Regardless of form, the detailed log contains a list of all test cases executed,
which failed, and how they failed \(expected versus actual results\)\.

## <a name='subsection12'></a>Shell Selection

By default the test runner will use all the Tcl shells specified via __test
add__ to invoke the specified testsuites, if any\. If no such are specified it
will fall back to the Tcl shell used to run the tool itself\.

Use option __\-\-shell__ to explicitly specify the Tcl shell to use, like

    \./sak\.tcl test run \-\-shell /path/to/tclsh \.\.\.

## <a name='subsection13'></a>Help

Invoke the tool as

    \./sak\.tcl help test

to see the detailed help for all methods of
__[test](\.\./\.\./\.\./index\.md\#test)__, and the associated options\.

# <a name='section6'></a>Documentation Tooling

The standard format used for documentation of packages and other things in
Tcllib is *[doctools](\.\./\.\./\.\./index\.md\#doctools)*\. Its supporting
packages are a part of Tcllib, see the directories "modules/doctools" and
"modules/dtplite"\. The latter is an application package, with the actual
application "apps/dtplite" a light wrapper around it\.

Tcllib developers gain access to these through the __doc__ method of the
"sak\.tcl" tool, another \(internal\) wrapper around the "modules/dtplite"
application package\.

## <a name='subsection14'></a>Generate documentation for a specific module

Invoke either

    \./sak\.tcl doc html foo

or

    \./sak\.tcl doc html modules/foo

to generate HTML for the documentation found in the module "foo"\. Instead of
__html__ any other supported format can be used here, of course\.

The generated formatted documentation will be placed into a directory "doc" in
the current working directory\.

## <a name='subsection15'></a>Generate documentation for all modules

Invoke the tool without a module name, i\.e\.

    \./sak\.tcl doc html

to generate HTML for the documentation found in all modules\. Instead of
__html__ any other supported format can be used here, of course\.

The generated formatted documentation will be placed into a directory "doc" in
the current working directory\.

## <a name='subsection16'></a>Available output formats, help

Invoke the tool as

    \./sak\.tcl help doc

to see the entire set of supported output formats which can be generated\.

## <a name='subsection17'></a>Validation without output

Note the special format __validate__\.

Using this value as the name of the format to generate forces the tool to simply
check that the documentation is syntactically correct, without generating actual
output\.

Invoke it as either

    \./sak\.tcl doc validate \(modules/\)foo

or

    \./sak\.tcl doc validate

to either check the packages of a specific module or check all of them\.

# <a name='section7'></a>Notes On Writing A Testsuite

While previous sections talked about running the testsuites for a module and the
packages therein, this has no meaning if the module in question has no
testsuites at all\.

This section gives a very basic overview on possible methodologies for writing
tests and testsuites\.

First there are "drudgery" tests\. Written to check absolutely basic assumptions
which should never fail\.

For example for a command FOO taking two arguments, three tests calling it with
zero, one, and three arguments\. The basic checks that the command fails if it
has not enough arguments, or too many\.

After that come the tests checking things based on our knowledge of the command,
about its properties and assumptions\. Some examples based on the graph
operations added during Google's Summer of Code 2009 are:

  - The BellmanFord command in struct::graph::ops takes a *startnode* as
    argument, and this node should be a node of the graph\. This equals one test
    case checking the behavior when the specified node is not a node of the
    graph\.

    This often gives rise to code in the implementation which explicitly checks
    the assumption and throws an understandable error\. Instead of letting the
    algorithm fail later in some weird non\-deterministic way\.

    It is not always possible to do such checks\. The graph argument for example
    is just a command in itself, and while we expect it to exhibit a certain
    interface, i\.e\. a set of sub\-commands aka methods, we cannot check that it
    has them, except by actually trying to use them\. That is done by the
    algorithm anyway, so an explicit check is just overhead we can get by
    without\.

  - IIRC one of the distinguishing characteristic of either BellmanFord and/or
    Johnson is that they are able to handle negative weights\. Whereas Dijkstra
    requires positive weights\.

    This induces \(at least\) three testcases \.\.\. Graph with all positive weights,
    all negative, and a mix of positive and negative weights\. Thinking further
    does the algorithm handle the weight __0__ as well ? Another test case,
    or several, if we mix zero with positive and negative weights\.

  - The two algorithms we are currently thinking about are about distances
    between nodes, and distance can be 'Inf'inity, i\.e\. nodes may not be
    connected\. This means that good test cases are

      1. Strongly connected graph

      1. Connected graph

      1. Disconnected graph\.

    At the extremes of strongly connected and disconnected we have the fully
    connected graphs and graphs without edges, only nodes, i\.e\. completely
    disconnected\.

  - IIRC both of the algorithms take weighted arcs, and fill in a default if
    arcs are left unweighted in the input graph\.

    This also induces three test cases:

      1. Graph will all arcs with explicit weights\.

      1. Graph without weights at all\.

      1. Graph with mixture of weighted and unweighted graphs\.

What was described above via examples is called *black\-box* testing\. Test
cases are designed and written based on the developer's knowledge of the
properties of the algorithm and its inputs, without referencing a particular
implementation\.

Going further, a complement to *black\-box* testing is *white\-box*\. For this
we know the implementation of the algorithm, we look at it and design our tests
cases so that they force the code through all possible paths in the
implementation\. Wherever a decision is made we have a test case forcing a
specific direction of the decision, for all possible combinations and
directions\. It is easy to get a combinatorial explosion in the number of needed
test\-cases\.

In practice I often hope that the black\-box tests I have made are enough to
cover all the paths, obviating the need for white\-box tests\.

The above should be enough to make it clear that writing tests for an algorithm
takes at least as much time as coding the algorithm, and often more time\. Much
more time\. See for example also
[http://sqlite\.org/testing\.html](http://sqlite\.org/testing\.html), a writeup
on how the Sqlite database engine is tested\.

An interesting connection is to documentation\. In one direction, the properties
checked with black\-box testing are exactly the properties which should be
documented in the algorithm's man page\. And conversely, the documentation of the
properties of an algorithm makes a good reference to base the black\-box tests
on\.

In practice test cases and documentation often get written together,
cross\-influencing each other\. And the actual writing of test cases is a mix of
black and white box, possibly influencing the implementation while writing the
tests\. Like writing a test for a condition like *startnode not in input graph*
serving as reminder to put a check for this condition into the code\.

# <a name='section8'></a>Installation Tooling

A last thing to consider when adding a new package to the collection is
installation\.

How to *use* the "installer\.tcl" script is documented in *[Tcllib \- The
Installer's Guide](tcllib\_installer\.md)*\.

Here we document how to extend said installer so that it may install new
package\(s\) and/or application\(s\)\.

In most cases only a single file has to be modified, the
"support/installation/modules\.tcl" holding one command per module and
application to install\.

The relevant commands are:

  - <a name='1'></a>__[Module](\.\./\.\./\.\./index\.md\#module)__ *name* *code\-action* *doc\-action* *example\-action*

    Install the packages of module *name*, found in "modules/*name*"\.

    The *code\-action* is responsible for installing the packages and their
    index\. The system currently provides

      * __\_tcl__

        Copy all "\.tcl" files found in "modules/*name*" into the installation\.

      * __\_tcr__

        As __\_tcl__, copy the "\.tcl" files found in the subdirectories of
        "modules/*name*" as well\.

      * __\_tci__

        As __\_tcl__, and copy the "tclIndex\.tcl" file as well\.

      * __\_msg__

        As __\_tcl__, and copy the subdirectory "msgs" as well\.

      * __\_doc__

        As __\_tcl__, and copy the subdirectory "mpformats" as well\.

      * __\_tex__

        As __\_tcl__, and copy "\.tex" files as well\.

    The *doc\-action* is responsible for installing the package documentation\.
    The system currently provides

      * __\_null__

        No documentation available, do nothing\.

      * __\_man__

        Process the "\.man" files found in "modules/*name*" and install the
        results \(nroff and/or HTML\) in the proper location, as given to the
        installer\.

        This is actually a fallback, normally the installer uses the pre\-made
        formatted documentation found under "idoc"\.

    The *example\-action* is responsible for installing the examples\. The
    system currently provides

      * __\_null__

        No examples available, do nothing\.

      * __\_exa__

        Copy the the directory "examples/*name*" recursively to the install
        location for examples\.

  - <a name='2'></a>__[Application](\.\./\.\./\.\./index\.md\#application)__ *name*

    Install the application with *name*, found in "apps"\.

  - <a name='3'></a>__Exclude__ *name*

    This command signals to the installer which of the listed modules to *not*
    install\. I\.e\. they name the deprecated modules of Tcllib\.

If, and only if the above actions are not suitable for the new module then a
second file has to be modified, "support/installation/actions\.tcl"\.

This file contains the implementations of the available actions, and is the
place where any custom action needed to handle the special circumstances of
module has to be added\.
