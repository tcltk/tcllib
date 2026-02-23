
[//000000001]: # (lambda \- Utility commands for anonymous procedures)
[//000000002]: # (Generated from file 'lambda\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2011 Andreas Kupries, BSD licensed)
[//000000004]: # (lambda\(n\) 1\.1 tcllib "Utility commands for anonymous procedures")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

lambda \- Utility commands for anonymous procedures

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Commands](#section2)

  - [Examples](#section3)

      - [Partial Function Application](#subsection1)

      - [Using regusb with lambda](#subsection2)

      - [Using lsort with lambda](#subsection3)

  - [Authors](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require lambda ?1\.1?  

[__::lambda__ *arguments* *body* ?*arg \.\.\.*?](#1)  
[__::lambda@__ *namespace* *arguments* *body* ?*arg \.\.\.*?](#2)  

# <a name='description'></a>DESCRIPTION

This package provides two convenience commands to make the creation of anonymous
commands, i\.e\., lambdas, more
__[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__\-like\. Instead of writing, for
example

    set f {::apply {{x} {
       ....
    }}}

with its deep nesting of braces, or

    set f [list ::apply {{x y} {
       ....
    }} $value_for_x]

with a __list__ command to insert some of the arguments of a partial
application, simply write

    set f [lambda {x} {
       ....
    }]

or

    set f [lambda {x y} {
       ....
    } $value_for_x]

Lambdas are particularly useful for commands that accept a __\-command__
option\.

# <a name='section2'></a>Commands

  - <a name='1'></a>__::lambda__ *arguments* *body* ?*arg \.\.\.*?

    Returns an anonymous command based on the *arguments* list, the *body*
    script, and any \(optional\) predefined argument values, *arg \.\.\.*\.

    When invoked, the *body* is run in a new procedure scope just below the
    global scope, with the arguments set to the values supplied at both
    construction \(any *arg \.\.\.* arguments\), and invocation time\.

  - <a name='2'></a>__::lambda@__ *namespace* *arguments* *body* ?*arg \.\.\.*?

    Returns an anonymous command in namespace *namespace*, and based on the
    *arguments* list, the *body* script, and any \(optional\) predefined
    argument values, *arg \.\.\.*\.

    When invoked, the *body* is run in a new procedure scope in the
    *namespace* namespace, with the arguments set to the values supplied at
    both construction \(any *arg \.\.\.* arguments\), and invocation time\.

# <a name='section3'></a>Examples

## <a name='subsection1'></a>Partial Function Application

Lambdas can be used for partial function application \(PFA\), although Tcl’s
__expr__ contexts mean that this isn’t often needed\. Nonetheless, here is a
classic PFA example:

    proc make_adder addend { lambda {x y} { expr { $x + $y } } $addend }
    set add5 [make_adder 5]
    puts "[{*}$add5 92] [{*}$add5 17]"
    =>
    97 22

The __make\_adder__ command has been used to create an anonymous command,
i\.e\., a lambda, which has then been assigned to the __add5__ variable\. To
call a variable as a command, it is necessary to prefix it with the __\{\*\}__
expansion \(“splat”\) operator\. Notice that these calls need only *one*
argument; the first argument was set when the lambda was created\.

## <a name='subsection2'></a>Using regusb with lambda

This example shows how to use a lambda with the built\-in
[regsub](https://www\.tcl\-lang\.org/man/tcl/TclCmd/regsub\.html) command’s
__\-command__ option\.

    # Simple URL-decoding: + → space; %XX → char
    set encoded_url "www.tcl-lang.org%2FSet%20or%20%24%20usage%3F"
    set url [regsub -all -command {(\+)|%([0-9A-Fa-f]{2})}  $encoded_url [lambda {_ plus hex} {
                    if {$plus eq "+"} { return " " }
                    scan $hex %x charCode
                    format %c $charCode
                }]]
    puts $url
    =>
    www.tcl-lang.org/Set or $ usage?

Notice that when using the built\-in
[regsub](https://www\.tcl\-lang\.org/man/tcl/TclCmd/regsub\.html) command’s
__\-command__ option, the command itself *follows* the string to match \(in
the *subSpec* argument’s position\)\.

## <a name='subsection3'></a>Using lsort with lambda

This example shows how to use lambdas to sort objects using the built\-in
[lsort](https://www\.tcl\-lang\.org/man/tcl/TclCmd/lsort\.html) command’s
__\-command__ option\.

First, a minimal definition of an __Id__ class whose objects are to be
sorted\.

    oo::class create Id {
        variable Id
        variable Name
        constructor {id name} { set Id $id ; set Name $name }
        method id {} { return $Id }
        method name {} { return $Name }
        method to_string {} { return "$Id'$Name'" }
    }

Next, a list of __Id__s is created and then sorted in two different ways
using lambdas to get the required sort orders\.

    set ids [list [Id new 3 Jane] [Id new 1 Bill] [Id new 4 Sam] [Id new 5 Nell]]
    #
    puts -nonewline "Original order:     "
    foreach id $ids { puts -nonewline "[$id to_string] " }
    #
    puts -nonewline "\nName,Id order:      "
    foreach id [lsort -command [lambda {a b} {
    		if {[set i [string compare [$a name] [$b name]]]} { return $i }
    		if {[$a id] < [$b id]} { return -1 }
    		if {[$a id] > [$b id]} { return 1 }
    		return 0}
                ] $ids] {
        puts -nonewline "[$id to_string] "
    }
    #
    puts -nonewline "\nId desc,Name order: "
    foreach id [lsort -command [lambda {a b} {
    		if {[$a id] < [$b id]} { return 1 }
    		if {[$a id] > [$b id]} { return -1 }
    		return [string compare [$a name] [$b name]]}
                ] $ids] {
        puts -nonewline "[$id to_string] "
    }
    puts ""
    =>
    Original order:     3'Jane' 1'Bill' 4'Sam' 5'Nell'
    Name,Id order:      1'Bill' 3'Jane' 5'Nell' 4'Sam'
    Id desc,Name order: 5'Nell' 4'Sam' 3'Jane' 1'Bill'

Notice that when using the built\-in
[lsort](https://www\.tcl\-lang\.org/man/tcl/TclCmd/lsort\.html) command’s
__\-command__ option, the command itself *precedes* the list to sort\.

# <a name='section4'></a>Authors

Andreas Kupries

# <a name='section5'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *lambda* as the
category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='seealso'></a>SEE ALSO

apply\(n\), proc\(n\)

# <a name='keywords'></a>KEYWORDS

[anonymous procedure](\.\./\.\./\.\./\.\./index\.md\#anonymous\_procedure),
[callback](\.\./\.\./\.\./\.\./index\.md\#callback), [command
prefix](\.\./\.\./\.\./\.\./index\.md\#command\_prefix),
[currying](\.\./\.\./\.\./\.\./index\.md\#currying),
[lambda](\.\./\.\./\.\./\.\./index\.md\#lambda), [partial
application](\.\./\.\./\.\./\.\./index\.md\#partial\_application),
[proc](\.\./\.\./\.\./\.\./index\.md\#proc)

# <a name='category'></a>CATEGORY

Utility

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2011 Andreas Kupries, BSD licensed
