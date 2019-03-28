
When developing we have to keep ourselves aware of the context of our
work. On what branch are we ? What files have we changed ? What new
files are not yet known to the repository ?

This becomes especially important when using a long-lived checkout and
coming back to it after some time away.

[para] Commands to answer questions like the above are:

[list_begin definitions]
[def [cmd {fossil info | grep tags}]]
[def [cmd {fossil branch list | grep '\*'}]]

       Two different ways of determining the branch our checkout is
       on.

[def [cmd {fossil timeline}]]

       What have we (and others) done recently ?

[para] [emph Attention], this information is very likely outdated, the
       more the longer we did not use this checkout.

       Run [cmd {fossil pull}] first to get latest information from
       the remote repository of the project.

[def [cmd {fossil timeline current}]]

       Place the commit our checkout is based on at the top of the
       timeline.

[def [cmd {fossil changes}]]

       Lists the files we have changed compared to the commit the
       checkout is based on.

[def [cmd {fossil extra}]]

       Lists the files we have in the checkout the repository does not
       know about. This may be leftover chaff from our work, or
       something we have forgotten to [cmd {fossil add}] to the
       repository yet.

[list_end]
