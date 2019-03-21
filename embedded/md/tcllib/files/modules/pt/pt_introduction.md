
[//000000001]: # (pt_introduction - Parser Tools)
[//000000002]: # (Generated from file 'pt_introduction.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (pt_introduction(n) 1 tcllib "Parser Tools")

# NAME

pt_introduction - Introduction to Parser Tools

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [Parser Tools Architecture](#section2)

      -  [User Packages](#subsection1)

      -  [Core Packages](#subsection2)

      -  [Support Packages](#subsection3)

  -  [Bugs, Ideas, Feedback](#section3)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8.5  

# <a name='description'></a>DESCRIPTION

Welcome to the Parser Tools, a system for the creation and manipulation of
parsers and the grammars driving them.

What are your goals which drove you here ?

  1. Do you simply wish to create a parser for some language ?

     In that case have a look at our parser generator application,
     __[pt](../../apps/pt.md)__, or, for a slightly deeper access, the package
     underneath it, __[pt::pgen](pt_pgen.md)__.

  1. Do you wish to know more about the architecture of the system ?

     This is described in the section [Parser Tools Architecture](#section2),
     below

  1. Is your interest in the theoretical background upon which the packages and
     tools are build ?

     See the *[Introduction to Parsing Expression
     Grammars](pt_peg_introduction.md)*.

# <a name='section2'></a>Parser Tools Architecture

The system can be split into roughly three layers, as seen in the figure below

![](/home/aku/Play/Tcllib/w-scratch/embedded/md/image/architecture.png) These
layers are, from high to low:

  1. At the top we have the application and the packages using the packages of
     the layer below to implement common usecases. One example is the
     aforementioned __[pt::pgen](pt_pgen.md)__ which provides a parser
     generator.

     The list of packages belonging to this layer can be found in section [User
     Packages](#subsection1)

  1. In this layer we have the packages which provide the core of the
     functionality for the whole system. They are, in essence, a set of blocks
     which can be combined in myriad ways, like Lego (tm). The packages in the
     previous level are 'just' pre-fabricated combinations to cover the most
     important use cases.

     The list of packages belonging to this layer can be found in section [Core
     Packages](#subsection2)

  1. Last, but not least is the layer containing support packages providing
     generic functionality which not necessarily belong into the module.

     The list of packages belonging to this layer can be found in section
     [Support Packages](#subsection3)

## <a name='subsection1'></a>User Packages

  - __[pt::pgen](pt_pgen.md)__

## <a name='subsection2'></a>Core Packages

This layer is further split into six sections handling the storage, import,
export, transformation, and execution of grammars, plus grammar specific support
packages.

  - Storage

      * __[pt::peg::container](pt_peg_container.md)__

  - Export

      * __[pt::peg::export](pt_peg_export.md)__

      * __[pt::peg::export::container](pt_peg_export_container.md)__

      * __[pt::peg::export::json](pt_peg_export_json.md)__

      * __[pt::peg::export::peg](pt_peg_export_peg.md)__

      * __[pt::peg::to::container](pt_peg_to_container.md)__

      * __[pt::peg::to::json](pt_peg_to_json.md)__

      * __[pt::peg::to::peg](pt_peg_to_peg.md)__

      * __[pt::peg::to::param](pt_peg_to_param.md)__

      * __[pt::peg::to::tclparam](pt_peg_to_tclparam.md)__

      * __[pt::peg::to::cparam](pt_peg_to_cparam.md)__

  - Import

      * __[pt::peg::import](pt_peg_import.md)__

      * __[pt::peg::import::container](pt_peg_import_container.md)__

      * __[pt::peg::import::json](pt_peg_import_json.md)__

      * __[pt::peg::import::peg](pt_peg_import_peg.md)__

      * __[pt::peg::from::container](pt_peg_from_container.md)__

      * __[pt::peg::from::json](pt_peg_from_json.md)__

      * __[pt::peg::from::peg](pt_peg_from_peg.md)__

  - Transformation

  - Execution

      * __[pt::peg::interp](pt_peg_interp.md)__

      * __[pt::rde](pt_rdengine.md)__

  - Support

      * __[pt::tclparam::configuration::snit](pt_tclparam_config_snit.md)__

      * __[pt::tclparam::configuration::tcloo](pt_tclparam_config_tcloo.md)__

      * __[pt::cparam::configuration::critcl](pt_cparam_config_critcl.md)__

      * __[pt::ast](pt_astree.md)__

      * __[pt::pe](pt_pexpression.md)__

      * __[pt::peg](pt_pegrammar.md)__

## <a name='subsection3'></a>Support Packages

  - __[pt::peg::container::peg](pt_peg_container_peg.md)__

  - __text::write__

  - __configuration__

  - __paths__

  - __char__

# <a name='section3'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems. Please report such in the category *pt* of the [Tcllib
Trackers](http://core.tcl.tk/tcllib/reportlist). Please also report any ideas
for enhancements you may have for either package and/or documentation.

When proposing code changes, please provide *unified diffs*, i.e the output of
__diff -u__.

Note further that *attachments* are strongly preferred over inlined patches.
Attachments can be made by going to the __Edit__ form of the ticket immediately
after its creation, and then using the left-most button in the secondary
navigation bar.

# <a name='keywords'></a>KEYWORDS

[EBNF](../../../../index.md#ebnf), [LL(k)](../../../../index.md#ll_k_),
[PEG](../../../../index.md#peg), [TDPL](../../../../index.md#tdpl),
[context-free languages](../../../../index.md#context_free_languages),
[expression](../../../../index.md#expression),
[grammar](../../../../index.md#grammar),
[matching](../../../../index.md#matching),
[parser](../../../../index.md#parser), [parsing
expression](../../../../index.md#parsing_expression), [parsing expression
grammar](../../../../index.md#parsing_expression_grammar), [push down
automaton](../../../../index.md#push_down_automaton), [recursive
descent](../../../../index.md#recursive_descent),
[state](../../../../index.md#state), [top-down parsing
languages](../../../../index.md#top_down_parsing_languages),
[transducer](../../../../index.md#transducer)

# <a name='category'></a>CATEGORY

Parsing and Grammars

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2009 Andreas Kupries <andreas_kupries@users.sourceforge.net>
