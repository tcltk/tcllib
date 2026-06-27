
[//000000001]: # (string::token \- Text and string utilities)
[//000000002]: # (Generated from file 'token\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (string::token\(n\) 1\.1 tcllib "Text and string utilities")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

string::token \- Regex based iterative lexing

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [API](#section2)

  - [Examples](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5 9  
package require string::token ?1\.1?  
package require fileutil  

[__::string token text__ *lex* *string*](#1)  
[__::string token file__ *lex* *path*](#2)  
[__::string token chomp__ *lex* *startVar* *string* *resultVar*](#3)  

# <a name='description'></a>DESCRIPTION

This package provides commands for regular expression based lexing \(tokenizing\)
of strings\.

# <a name='section2'></a>API

  - <a name='1'></a>__::string token text__ *lex* *string*

    This command takes a dictionary, *lex*, which must map regular expressions
    \(“regexps”\) to labels, and tokenizes the *string* according to the
    dictionary\.

    The command tests each regexp in the *lex* dictionary in order\. Since Tcl
    __dict__s are insertion\-ordered, it is recommended that the regexps are
    specified from most specific to most general\.

    The command returns a list of tokens\. Each token is a 3\-element list
    containing the label \(from the *lex* __dict__\), and the start and end
    indexes of the match in the *string*\.

    The command will throw an error if it is not able to tokenize the entire
    string\.

    For line\-oriented lexers, finer\-grained error handling and handling huge
    files can be achieved by lexing line\-by\-line\.

  - <a name='2'></a>__::string token file__ *lex* *path*

    This command is a convenience wrapper around __::string token text__
    that makes it easy to tokenize entire files\.

    *Note* that this command loads the whole file into memory before starting
    to process it\.

  - <a name='3'></a>__::string token chomp__ *lex* *startVar* *string* *resultVar*

    This command is exposed to enable users to write their own lexers\. For
    example, to apply different lexing dictionaries depending on internal state
    as the lex progresses\.

    \(The __::string token text__ and __::string token file__ commands
    make use of this command behind the scenes\.\)

    This command takes a dictionary, *lex*, which must map regexps to labels,
    a variable *startVar* which contains the index position where the lexing
    should begin in the input *string*, and a result variable *resultVar* to
    which each successfuly lexed token will be appended\.

    The command returns a status code indicating the state of the lex These are

      * __0__

        No token found\.

      * __1__

        Token found\.

      * __2__

        End of string reached\.

    If a token was recognized \(status __1__\) the command will update the
    index in *startVar* to the character immediately *following* the lexed
    token\. It will also append to the *resultVar* the lexed token which itself
    is a 3\-element list containing the label \(from the *lex* __dict__\),
    and the start and end indexes of the match in the *string*\.

    If a token was not recognized \(status __0__ or __2__\), neither
    *startVar* nor *resultVar* will be updated\.

    As noted earlier, the command tests each regexp in the *lex* dictionary in
    order\. Since Tcl __dict__s are insertion\-ordered, it is recommended that
    the regexps are specified from most specific to most general\.

    Further note that all regex patterns are implicitly prefixed with the
    constraint escape __\\A__ to ensure that a match starts exactly at the
    character index found in *startVar*\.

# <a name='section3'></a>Examples

This example shows how to use the __string token text__ command to lex a
simple line\-oriented *\.ini* file format\. \(For full\-featured *\.ini* file
handling, see
[inifile](https://core\.tcl\-lang\.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/inifile/ini\.md)\.\)

    const INI_EG "; example.ini
    Filename = test.db

    invalid
    \[Database\]
    # remote data
    Port: 143
    IP: 192.0.2.62

    junk
    "

    proc main {} {
        set groups [lex_ini $::INI_EG]
        puts General:
        dict for {key value} [dict get $groups General] { puts "\t$key: $value" }
        puts Database:
        dict for {key value} [dict get $groups Database] { puts "\t$key: $value" }
    }

    proc lex_ini ini_text {
        const INI_LEX [dict create {[#;].*$} COMMENT {\[[^]]+\]} GROUP {\w+\s*[:=].+$} ENTRY]
        set group General
        set linenum 0
        foreach line [split $ini_text \n] {
            incr linenum
            if {[string trim $line] eq ""} { continue }
            try {
                set token [string token text $INI_LEX $line]
                if {[llength $token]} { set token [lindex $token 0] }
                lassign $token label i j
                switch $label {
                    COMMENT { continue }
                    GROUP {
                        set group [string range $line $i+1 $j-1]
                        dict set groups $group {}
                    }
                    ENTRY {
                        set entry [string range $line $i $j]
                        set k [lindex [regexp -inline -indices {[=:]} $entry] 0 0]
                        set key [string trim [string range $entry 0 $k-1]]
                        set value [string trim [string range $entry $k+1 end]]
                        dict set groups $group $key $value
                    }
                }
            } on error err {
                puts "Error: line $linenum: $err"
            }
        }
        return $groups
    }

    main
    =>
    Error: line 4: Unexpected character 'i' at offset 0
    Error: line 10: Unexpected character 'j' at offset 0
    General:
    	Filename: test.db
    Database:
    	Port: 143
    	IP: 192.0.2.62

# <a name='section4'></a>Bugs, Ideas, Feedback

If you find errors in this document or bugs or problems with the package it
describes, or if you want to suggest improvements for the documentation or the
package, please use the [Tcllib
Trackers](http://core\.tcl\.tk/tcllib/reportlist) and specify *textutil* as
the category\.

When proposing code changes, please provide *unified diffs*, i\.e the output of
__diff \-u__\.

Note further that *attachments* are strongly preferred over inlined patches\.
Attachments can be made by going to the __Edit__ form of the ticket
immediately after its creation, and then using the left\-most button in the
secondary navigation bar\.

# <a name='keywords'></a>KEYWORDS

[lexing](\.\./\.\./\.\./\.\./index\.md\#lexing),
[regex](\.\./\.\./\.\./\.\./index\.md\#regex),
[string](\.\./\.\./\.\./\.\./index\.md\#string),
[tokenization](\.\./\.\./\.\./\.\./index\.md\#tokenization)

# <a name='category'></a>CATEGORY

Text processing
