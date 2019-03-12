[subsection Branches]

An important part of working with a
[term {Distributed Version Control System}] ([term DVCS]) like
[uri https://www.fossil-scm.org/ fossil]
is the management and use of branches.

[para] For Tcllib the main branch of the collection is
[term trunk]. In [term git] this branch would be called [term master],
and this exactly the case in the
[uri https://github.com/tcltk/tcllib/ {github mirror}] of Tcllib.

[para] In support of debugging, like searching for when an issue
appeared via bisection, each commit on this branch must pass the
entire testsuite of the collection.

[para] As fossil has no mechanism to enfore this this is handled on
the honor system for developers and maintainers.

[para] To make the task easier Tcllib comes with a tool
([file sak.tcl]) providing a number of commands in support. These
commands are explained in the following sections of this guide.

[para] While it is possible and allowed to commit directly to trunk
remember the above regarding the testsuite, and the coming notes about
other possible issues with a commit.

[para] Because of this it is (strongly) recommended to perform any
development on a nicely named (nick of dev, ticket reference if any,
keywords applicable to the work, ...) non-trunk branch. Outside of the
trunk developers are allowed to commit intermediate broken states of
their work. Only at the end, when the branch is considered ready for
merging will it be necessary to perform full validation.

[subsection {Version numbers}]

In Tcllib all changes to a package have to come with an increment of
its version number. With what part is incremented (patchlevel, minor,
major version) dependent on the kind of change made. With multiple
changes in a commit the highest "wins".

[para] When working in a development branch the version change can be
defered until it is time to merge, and then has to cover all the
changes in the branch.

[para] Below a list of the kinds of changes and their association
version increments:

[list_begin definitions]
[def [term {D - documentation}]] No increment
[def [term {T - testsuite}]] No increment
[def [term {B - bugfix}]] Patchlevel
[def [term {I - implementation tweak}]] Patchlevel
[def [term {P - performance tweak}]] Patchlevel
[def [term {E - backward-compatible extension}]] Minor
[def [term {API - incompatible change}]] Major
[list_end]

[para] Note, a commit containing a version increment has to mention
the kind of change which caused it in the commit message, as well as
the new version number.

[para] Note further that the version number of a package currently
exists in 3 places. An increment has to update all of them:

[list_begin enumerated]
[enum] The package implementation.
[enum] The package index ([file pkgIndex.tcl])
[enum] The package documentation.
[list_end]

[para] The [file sak.tcl] command [cmd {validate version}] helps
finding discrepancies between the first two.

All the other [cmd validate] methods are also of interest to any
developer. Invoke it with

[example {
    sak.tcl help validate
}]

to see their documentation.
