
[subsection CriTcl]

The [syscmd critcl] tool is an [emph optional] dependency.

[para] It is only required when trying to build the C-based
[term accelerators] for a number of packages, as explained in
[sectref {Critcl & Accelerators}]

[para] Tcllib's build system accepts it as an application found in the
PATH (be it starkit or starpack).

[para] Tcllib requires version 2 or higher.

[para] The github repository providing releases of version 2 and
higher, and the associated sources, can be found at
[uri http://andreas-kupries.github.com/critcl].

[para] Any branch of the repository can be used (if not using the
prebuild starkit or starpack), although the use of the stable branch
[emph master] is recommended.

[para] At the above url is also an explanation on how to build and
install CriTcl, including a list of its dependencies.

[para] Its instructions will not be repeated here. If there are
problems with their directions please file a ticket against the
[term Critcl] project, and not Tcllib.
