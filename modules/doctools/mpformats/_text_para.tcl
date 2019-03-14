# -*- tcl -*-
#
# Copyright (c) 2019 Andreas Kupries <andreas_kupries@sourceforge.net>
# Freely redistributable.
#
# _text_para.tcl -- Paragraph variables and accessors - Text accumulator

# # ## ### ##### ########
## State: Text buffer for paragraphs.

global __currentp

# # ## ### ##### ########
## API

proc Text      {text} { global __currentp ; append __currentp $text ; return }
proc Text?     {}     { global __currentp ; return $__currentp }
proc TextClear {}     { global __currentp ; set __currentp "" }

proc TextTrimLeadingSpace {} {
    global __currentp
    regsub {^([ \t\v\f]*\n)*} $__currentp {} __currentp
    return
}

proc TextPlain {text} {
    #puts_stderr "<<text_plain_text>>"

    if  {[IsOff]} {return}

    # Note: Whenever we get plain text it is possible that a macro for
    # visual markup actually generated output before the expander got
    # to the current text. This output was captured by the expander in
    # its current context. Given the current organization of the
    # engine we have to retrieve this formatted text from the expander
    # or it will be lost. This is the purpose of the 'ctopandclear',
    # which retrieves the data and also clears the capture buffer. The
    # latter to prevent us from retrieving it again later, after the
    # next macro added more data.

    set text [ex_ctopandclear]$text

    # ... TODO ... Handling of example => verbatim

    if {[string length [string trim $text]] == 0} return

    Text $text
    return
}

#return
# # ## ### ##### ########
## Debugging

proc Text {text} {
    #puts_stderr "T++ (($text))"
    global __currentp
    append __currentp $text
    return
}
