# -*- tcl -*-
# --------------------------------------------------------------
# List of modules to install and definitions guiding the process of
# doing so.
#
# This file is shared between 'installer.tcl' and 'sak.tcl', like
# 'tcllib_version.tcl'. The swiss army knife requires access to the
# data in this file to be able to check if there are modules in the
# directory hierarchy, but missing in the list of installed modules.
# --------------------------------------------------------------

# Excluded:
set excluded [list \
	calendar \
	]

set     modules [list]
array set guide {}
foreach {m pkg doc exa} {
    aes         _tcl  _man  _null
    asn		_tcl  _man  _null
    base64	_tcl  _man  _null
    base32	_tcl  _man  _null
    bee		_tcl  _man  _null
    bench	_tcl  _null _null
    bibtex	_tcl  _man  _null
    blowfish	_tcl  _man  _null
    calendar	 _tci _man  _null
    cmdline	_tcl  _man  _null
    comm	_tcl  _man  _null
    control	 _tci _man  _null
    counter	_tcl  _man  _null
    crc		_tcl  _man  _null
    csv		_tcl  _man _exa
    des		_tcl  _man  _null
    dns		 _msg _man _exa
    docstrip	_tcl  _man  _null
    doctools	 _doc _man _exa
    exif	_tcl  _man  _null
    fileutil	_tcl  _man  _null
    ftp		_tcl  _man _exa
    ftpd	_tcl  _man _exa
    fumagic	_tcl  _man  _null
    grammar_fa  _tcl  _man  _null
    grammar_me  _tcl  _man  _null
    grammar_peg _tcl  _man  _null
    html	_tcl  _man  _null
    htmlparse	_tcl  _man  _null
    http	_tcl  _man  _null
    ident       _tcl  _man  _null
    inifile     _tcl  _man  _null
    irc		_tcl  _man _exa
    javascript	_tcl  _man  _null
    jpeg        _tcl  _man  _null
    ldap        _tcl  _man _exa
    log		 _msg _man  _null
    math	 _tci _man _exa
    md4		_tcl  _man  _null
    md5		_tcl  _man  _null
    md5crypt	_tcl  _man _null
    mime	_tcl  _man _exa
    multiplexer _tcl  _man  _null
    ncgi	_tcl  _man  _null
    nntp	_tcl  _man _exa
    ntp		_tcl  _man _exa
    page         _tcr _man  _null
    pluginmgr	_tcl  _man  _null
    png	        _tcl  _man  _null
    pop3	_tcl  _man  _null
    pop3d	_tcl  _man  _null
    profiler	_tcl  _man  _null
    rc4         _tcl  _man  _null
    rcs         _tcl  _man  _null
    report	_tcl  _man  _null
    ripemd      _tcl  _man  _null
    sasl        _tcl  _man  _null
    sha1	_tcl  _man  _null
    smtpd	_tcl  _man _exa
    snit        _tcl  _man  _null
    soundex	_tcl  _man  _null
    stooop	_tcl  _man  _null
    struct	_tcl  _man _exa
    tar         _tcl  _man  _null
    textutil	 _tex _man  _null
    tie		_tcl  _man  _null
    transfer    _tcl  _man  _null
    treeql	_tcl  _man  _null
    units      	_tcl  _man  _null
    uri		_tcl  _man  _null
    uuid	_tcl  _man  _null
} {
    lappend modules $m
    set guide($m,pkg) $pkg
    set guide($m,doc) $doc
    set guide($m,exa) $exa
}

# And a list of applications.
set     apps [list  \
	dtplite     \
	tcldocstrip \
	page        \
]

# --------------------------------------------------------------
