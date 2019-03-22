
[//000000001]: # (tepam \- Tcl's Enhanced Procedure and Argument Manager)
[//000000002]: # (Generated from file 'tepam\_introduction\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2009\-2013, Andreas Drollinger)
[//000000004]: # (tepam\(n\) 0\.5\.0 tcllib "Tcl's Enhanced Procedure and Argument Manager")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

tepam \- An introduction into TEPAM, Tcl's Enhanced Procedure and Argument
Manager

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Description](#section1)

  - [OVERVIEW](#section2)

  - [PROCEDURE DECLARATION](#section3)

  - [PROCEDURE HELP](#section4)

  - [PROCEDURE CALL](#section5)

  - [INTERACTIVE PROCEDURE CALLS](#section6)

  - [FLEXIBLE ARGUMENT DIALOG BOX](#section7)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='description'></a>DESCRIPTION

This document is an informal introduction into TEPAM, the Tcl's Enhanced
Procedure and Argument Manager\. Detailed information to the TEPAM package is
provided in the *tepam::procedure* and *tepam::argument\_dialogbox* reference
manuals\.

# <a name='section2'></a>OVERVIEW

This package provides a new Tcl procedure declaration syntax that simplifies the
implementation of procedure subcommands and the handling of the different types
of procedure arguments like flags or switches, options, unnamed arguments,
optional and mandatory options and arguments, default values, etc\. Procedure
declarations can be enriched with detailed information about the procedure and
its arguments\. This information is used for the following purposes:

First of all, a preamble is added in front of the body of a procedure that is
declared with TEPAM\. This preamble calls an argument manager that that uses the
provided information to check the validity of the argument types and values
before the procedure body is executed\. Then, the information is used to generate
help and usage texts if requested, or to generate clear error message in case an
argument validation fails\. The information also allows generating automatically
graphical forms that allows an interactive definition of all arguments, in case
a procedure is called interactively\. And finally, the additional information
helps self\-commenting in a clean way the declaration of a procedure and of all
its arguments\.

The graphical form generator that creates the necessary argument specification
forms for the interactive procedure calls is also available for other purposes
than for procedure argument specifications\. It allows creating code efficiently
complex parameter entry forms that are usable independently from TEPAM's new
procedure definition method\.

Here is a short overview about all major TEPAM features:

  - New self\-documenting procedure declaration syntax: The additional
    information to declare properly a procedure has not to be provided with
    additional statements, but can be added in a natural syntax directly into
    the procedure header\.

  - Easy way to specify subcommands: A subcommand is declared like a procedure,
    simply with a procedure name composed by a base name followed by a
    subcommand name\. Sub\-subcommands are created identically using simply
    procedure names composed by 3 words\.

  - Flexible usage of flags \(switches\), options \(named arguments\) and unnamed
    arguments\. Option names are optionally automatically completed\.

  - Support for default values, mandatory/optional options and arguments, choice
    lists, value ranges, multiple usable options/arguments\.

  - Choice of a *named arguments first, unnamed arguments later* procedure
    calling style \(typical for Tcl commands\) or of an *unnamed arguments first,
    named arguments later* procedure calling style \(typical for Tk commands\)\.

  - In case the *named arguments first, unnamed arguments later* style \(Tcl\)
    is selected: Clear separation between options and arguments via the "\-\-"
    flag\. The unnamed arguments can optionally be accessed as options \(named
    arguments\)\.

  - Automatic type and value check before the procedure body is executed, taking
    into account validation ranges, choice lists and custom validation commands\.
    Generation of clear error message if necessary\.

  - Many predefined types exist \(integer, boolean, double, color, file, font,
    \.\.\.\)\. Other application specific types can easily be added\.

  - Automatic help and usage text generation if a procedure is called with the
    *\-help* flag\.

  - Automatic generation of an interactive argument definition form, in case a
    procedure is called with the *\-interactive* flag\.

  - Procedure calls can be logged which is useful to get for interactively
    called procedures the command call lines\.

  - Powerful and code efficient generation of complex parameter definition
    forms\.

# <a name='section3'></a>PROCEDURE DECLARATION

TEPAM's procedure declaration syntax is simple and self\-explaining\. Instead of
declaring a procedure with the Tcl key word
__[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__, a procedure is declared with the
TEPAM command __[procedure](\.\./\.\./\.\./\.\./index\.md\#procedure)__ which
takes as __[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ also 3 arguments: The
procedure name, the procedure header and the procedure body\.

The following example declares the subcommand
__[message](\.\./\.\./\.\./\.\./index\.md\#message)__ of the procedure
__display__\. This command has several named and unnamed arguments:

    __[tepam::procedure](tepam\_procedure\.md)__ \{display message\} \{
       \-return            \-
       \-short\_description "Displays a simple message box"
       \-description       "This procedure allows displaying a configurable message box\."
       \-args \{
          \{\-mtype \-default Warning \-choices \{Info Warning Error\} \-description "Message type"\}
          \{\-font \-type font \-default \{Arial 10 italic\} \-description "Message text font"\}
          \{\-level \-type integer \-optional \-range \{1 10\} \-description "Message level"\}
          \{\-fg \-type color \-default black \-description "Message color"\}
          \{\-bg \-type color \-optional \-description "Background color"\}
          \{\-no\_border \-type none \-description "Use a splash window style \(no border\)"\}
          \{\-log\_file \-type file \-optional \-description "Optional message log file"\}
          \{text \-type string \-multiple \-description "Multiple text lines to display"\}
       \}
    \} \{
    *   puts "display message:"
       foreach var \{mtype font level fg bg no\_border log\_file text\} \{
          if \{\[info exists $var\]\} \{
             puts  "  $var=\[set $var\]"
          \}
       \}
    *\}

A call of procedure that has been declared in this way will first invoke the
TEPAM argument manager, before the procedure body is executed\. The argument
manager parses the provided arguments, validates them, completes them eventually
with some default values, and makes them finally available to the procedure body
as local variables\. In case an argument is missing or has a wrong type, the
argument manager generates an error message that explains the reason for the
error\.

As the example above shows, the TEPAM command
__[procedure](\.\./\.\./\.\./\.\./index\.md\#procedure)__ accepts subcommand
definitions as procedure name and allows defining much more information than
just the argument list inside the procedure header\. The procedure body on the
other hand is identical between a command declared with
__[proc](\.\./\.\./\.\./\.\./index\.md\#proc)__ and a command declared with
__[procedure](\.\./\.\./\.\./\.\./index\.md\#procedure)__\.

The procedure header allows defining in addition to the arguments some procedure
attributes, like a description, information concerning the return value, etc\.
This information is basically used for the automatic generation of comprehensive
help and usage texts\.

A list of argument definition statements assigned to the *\-args* argument is
defining the procedure arguments\. Each argument definition statement starts with
the argument name, optionally followed by some argument attributes\.

Three types of arguments can be defined: Unnamed arguments, named arguments and
flags\. The distinction between the named and unnamed arguments is made by the
first argument name character which is simply "\-" for named arguments\. A flag is
defined as named argument that has the type *none*\.

Named and unnamed arguments are mandatory, unless they are declared with the
*\-optional* flag and unless they have a default value specified with the
*\-default* option\. Named arguments and the last unnamed argument can have the
attribute *\-multiple*, which means that they can be defined multiple times\.
The expected argument data type is specified with the *\-type* option\. TEPAM
defines a large set of standard data types which can easily be completed with
application specific data types\.

The argument declaration order has only an importance for unnamed arguments that
are by default parsed after the named arguments \(Tcl style\)\. A variable allows
changing this behavior in a way that unnamed arguments are parsed first, before
the named arguments \(Tk style\)\.

# <a name='section4'></a>PROCEDURE HELP

The declared procedure can simply be called with the *\-help* option to get the
information about the usage of the procedure and its arguments:

    __display message__ \-help

* \-> NAME display message \- Displays a simple message box SYNOPSYS display
message \[\-mtype <mtype>\] : Message type, default: "Warning", choices: \{Info
Warning Error\} \[\-font <font>\] : Message text font, type: font, default: Arial 10
italic \[\-level <level>\] : Message level, type: integer, range: 1\.\.10 \[\-fg <fg>\]
: Message color, type: color, default: black \[\-bg <bg>\] : Background color,
type: color \[\-no\_border \] : Use a splash window style \(no border\) \[\-log\_file
<log\_file>\] : Optional message log file, type: file <text> : Multiple text lines
to display, type: string DESCRIPTION This procedure allows displaying a
configurable message box\.*

# <a name='section5'></a>PROCEDURE CALL

The specified procedure can be called in many ways\. The following listing shows
some valid procedure calls:

    __display message__ "The document hasn't yet been saved\!"
    *\-> display message:
         mtype=Warning
         font=Arial 10 italic
         fg=black
         no\_border=0
         text=\{The document hasn't yet been saved\!\}*

    __display message__ \-fg red \-bg black "Please save first the document"
    *\-> display message:
         mtype=Warning
         font=Arial 10 italic
         fg=red
         bg=black
         no\_border=0
         text=\{Please save first the document\}*

    __display message__ \-mtype Error \-no\_border "Why is here no border?"
    *\-> display message:
         mtype=Error
         font=Arial 10 italic
         fg=black
         no\_border=1
         text=\{Why is here no border?\}*

    __display message__ \-font \{Courier 12\} \-level 10 \\
       "Is there enough space?" "Reduce otherwise the font size\!"

*\-> display message: mtype=Warning font=Courier 12 level=10 fg=black
no\_border=0 text=\{Is there enough space?\} \{Reduce otherwise the font size\!\}*
The next lines show how wrong arguments are recognized\. The *text* argument
that is mandatory is missing in the first procedure call:

    __display message__ \-font \{Courier 12\}

* \-> display message: Required argument is missing: text* Only known arguments
are accepted:

    __display message__ \-category warning Hello

* \-> display message: Argument '\-category' not known* Argument types are
automatically checked and an error message is generated in case the argument
value has not the expected type:

    __display message__ \-fg MyColor "Hello"

* \-> display message: Argument 'fg' requires type 'color'\. Provided value:
'MyColor'* Selection choices have to be respected \.\.\.

    __display message__ \-mtype Fatal Hello

* \-> display message: Argument \(mtype\) has to be one of the following elements:
Info, Warning, Error* \.\.\. as well as valid value ranges:

    __display message__ \-level 12 Hello

* \-> display message: Argument \(level\) has to be between 1 and 10*

# <a name='section6'></a>INTERACTIVE PROCEDURE CALLS

The most intuitive way to call the procedure is using an form that allows
specifying all arguments interactively\. This form will automatically be
generated if the declared procedure is called with the *\-interactive* flag\. To
use this feature the Tk library has to be loaded\.

    __display message__ \-interactive

The generated form contains for each argument a data entry widget that is
adapted to the argument type\. Check buttons are used to specify flags, radio
boxes for tiny choice lists, disjoint list boxes for larger choice lists and
files, directories, fonts and colors can be selected with dedicated browsers\.

After acknowledging the specified argument data via an OK button, the entered
data are first validated, before the provided arguments are transformed into
local variables and the procedure body is executed\. In case the entered data are
invalid, a message appears and the user can correct them until they are valid\.

The procedure calls can optionally be logged in a variable\. This is for example
useful to get the command call lines of interactively called procedures\.

# <a name='section7'></a>FLEXIBLE ARGUMENT DIALOG BOX

The form generator that creates in the previous example the argument dialog box
for the interactive procedure call is also available for other purposes than for
the definition of procedure arguments\. If Tk has been loaded TEPAM provides and
argument dialog box that allows creating complex parameter definition forms in a
very efficient way\.

The following example tries to illustrate the simplicity to create complex data
entry forms\. It creates an input mask that allows specifying a file to copy, a
destination folder as well as a checkbox that allows specifying if an eventual
existing file can be overwritten\. Comfortable browsers can be used to select
files and directories\. And finally, the form offers also the possibility to
accept and decline the selection\. Here is the code snippet that is doing all
this:

    __[tepam::argument\_dialogbox](tepam\_argument\_dialogbox\.md)__ \\
       __\-existingfile__ \{\-label "Source file" \-variable SourceFile\} \\
       __\-existingdirectory__ \{\-label "Destination folder" \-variable DestDir\} \\
       __\-checkbutton__ \{\-label "Overwrite existing file" \-variable Overwrite\}

The __argument\_dialogbox__ returns __ok__ if the entered data are
validated\. It will return __cancel__ if the data entry has been canceled\.
After the validation of the entered data, the __argument\_dialogbox__ defines
all the specified variables with the entered data inside the calling context\.

An __argument\_dialogbox__ requires a pair of arguments for each variable
that it has to handle\. The first argument defines the entry widget type used to
select the variable's value and the second one is a lists of attributes related
to the variable and the entry widget\.

Many entry widget types are available: Beside the simple generic entries, there
are different kinds of list and combo boxes available, browsers for existing and
new files and directories, check and radio boxes and buttons, as well as color
and font pickers\. If necessary, additional entry widgets can be defined\.

The attribute list contains pairs of attribute names and attribute data\. The
primary attribute is *\-variable* used to specify the variable in the calling
context into which the entered data has to be stored\. Another often used
attribute is *\-label* that allows adding a label to the data entry widget\.
Other attributes are available that allow specifying default values, the
expected data types, valid data ranges, etc\.

The next example of a more complex argument dialog box provides a good overview
about the different available entry widget types and parameter attributes\. The
example contains also some formatting instructions like *\-frame* and *\-sep*
which allows organizing the different entry widgets in frames and sections:

    set ChoiceList \{"Choice 1" "Choice 2" "Choice 3" "Choice 4" "Choice 5" "Choice 6"\}

    set Result \[__[tepam::argument\_dialogbox](tepam\_argument\_dialogbox\.md)__ \\
       __\-title__ "System configuration" \\
       __\-context__ test\_1 \\
       __\-frame__ \{\-label "Entries"\} \\
          __\-entry__ \{\-label Entry1 \-variable Entry1\} \\
          __\-entry__ \{\-label Entry2 \-variable Entry2 \-default "my default"\} \\
       __\-frame__ \{\-label "Listbox & combobox"\} \\
          __\-listbox__ \{\-label "Listbox, single selection" \-variable Listbox1 \\
                    \-choices \{1 2 3 4 5 6 7 8\} \-default 1 \-height 3\} \\
          __\-listbox__ \{\-label "Listbox, multiple selection" \-variable Listbox2
                    \-choicevariable ChoiceList \-default \{"Choice 2" "Choice 3"\}
                    \-multiple\_selection 1 \-height 3\} \\
          __\-disjointlistbox__ \{\-label "Disjoined listbox" \-variable DisJntListbox
                            \-choicevariable ChoiceList \\
                            \-default \{"Choice 3" "Choice 5"\} \-height 3\} \\
          __\-combobox__ \{\-label "Combobox" \-variable Combobox \\
                     \-choices \{1 2 3 4 5 6 7 8\} \-default 3\} \\
       __\-frame__ \{\-label "Checkbox, radiobox and checkbutton"\} \\
          __\-checkbox__ \{\-label Checkbox \-variable Checkbox
                     \-choices \{bold italic underline\} \-choicelabels \{Bold Italic Underline\} \\
                     \-default italic\} \\
          __\-radiobox__ \{\-label Radiobox \-variable Radiobox
                     \-choices \{bold italic underline\} \-choicelabels \{Bold Italic Underline\} \\
                     \-default underline\} \\
          __\-checkbutton__ \{\-label CheckButton \-variable Checkbutton \-default 1\} \\
       __\-frame__ \{\-label "Files & directories"\} \\
          __\-existingfile__ \{\-label "Input file" \-variable InputFile\} \\
          __\-file__ \{\-label "Output file" \-variable OutputFile\} \\
          __\-sep__ \{\} \\
          __\-existingdirectory__ \{\-label "Input directory" \-variable InputDirectory\} \\
          __\-directory__ \{\-label "Output irectory" \-variable OutputDirectory\} \\
       __\-frame__ \{\-label "Colors and fonts"\} \\
          __\-color__ \{\-label "Background color" \-variable Color \-default red\} \\
          __\-sep__ \{\} \\
          __\-font__ \{\-label "Font" \-variable Font \-default \{Courier 12 italic\}\}

\] The __argument\_dialogbox__ defines all the specified variables with the
entered data and returns __ok__ if the data have been validated via the Ok
button\. If the data entry is cancelled by activating the Cancel button, the
__argument\_dialogbox__ returns __cancel__\.

    if \{$Result=="cancel"\} \{
       puts "Canceled"
    \} else \{ \# $Result=="ok"
       puts "Arguments: "
       foreach Var \{
          Entry1 Entry2
          Listbox1 Listbox2 DisJntListbox
          Combobox Checkbox Radiobox Checkbutton
          InputFile OutputFile InputDirectory OutputDirectory
          Color Font
       \} \{
          puts "  $Var: '\[set $Var\]'"
       \}
    \}

*\-> Arguments: Entry1: 'Hello, this is a trial' Entry2: 'my default' Listbox1:
'1' Listbox2: '\{Choice 2\} \{Choice 3\}' DisJntListbox: '\{Choice 3\} \{Choice 5\}'
Combobox: '3' Checkbox: 'italic' Radiobox: 'underline' Checkbutton: '1'
InputFile: 'c:\\tepam\\in\.txt' OutputFile: 'c:\\tepam\\out\.txt' InputDirectory:
'c:\\tepam\\input' OutputDirectory: 'c:\\tepam\\output' Color: 'red' Font: 'Courier
12 italic'*

# <a name='seealso'></a>SEE ALSO

[tepam::argument\_dialogbox\(n\)](tepam\_argument\_dialogbox\.md),
[tepam::procedure\(n\)](tepam\_procedure\.md)

# <a name='keywords'></a>KEYWORDS

[argument integrity](\.\./\.\./\.\./\.\./index\.md\#argument\_integrity), [argument
validation](\.\./\.\./\.\./\.\./index\.md\#argument\_validation),
[arguments](\.\./\.\./\.\./\.\./index\.md\#arguments), [entry
mask](\.\./\.\./\.\./\.\./index\.md\#entry\_mask), [parameter entry
form](\.\./\.\./\.\./\.\./index\.md\#parameter\_entry\_form),
[procedure](\.\./\.\./\.\./\.\./index\.md\#procedure),
[subcommand](\.\./\.\./\.\./\.\./index\.md\#subcommand)

# <a name='category'></a>CATEGORY

Procedures, arguments, parameters, options

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009\-2013, Andreas Drollinger
