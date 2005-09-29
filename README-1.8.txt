New in Tcllib 1.8
=================
                        		Tcllib 1.8
Module          Package 		New Version     Comments
------          ------- 		-----------     -------------------------------
aes		aes                           1.0.0	AES Encryption
bibtex		bibtex                          0.5	Processing of BibTeX bibliographies
blowfish	blowfish                      1.0.0	Blowfish Encryption
------          ------- 		-----------     -------------------------------
des		tclDES                        1.0.0	DES encryption
		tclDESjr                      1.0.0
------          ------- 		-----------     -------------------------------
docstrip	docstrip                        1.2	Literate programming tools
		docstrip::util                  1.2
------          ------- 		-----------     -------------------------------
fumagic		fileutil::magic::filetype       1.0	File types basic on magic numbers.
		fileutil::magic::mimetype       1.0
------          ------- 		-----------     -------------------------------
grammar_me	grammar::me::cpu                0.1	Match Engine. Foundation for
		grammar::me::cpu::core          0.1	parsers.
		grammar::me::tcl                0.1
		grammar::me::util               0.1
------          ------- 		-----------     -------------------------------
grammar_peg	grammar::peg                    0.1	Container for Parsing Expression
		grammar::peg::interp            0.1	Grammars, PEG interpreter.
------          ------- 		-----------     -------------------------------
log		logger::appender                1.2	Utilities for logger.
		logger::utils                   1.2
------          ------- 		-----------     -------------------------------
math		math::bigfloat                  1.2	Arbitrary-precision floating point.
		math::linearalgebra             1.0	Matrix & vector processing.
------          ------- 		-----------     -------------------------------
page		page::analysis::*               0.1	Parser generator packages. Plugin
		page::config::peg               0.1	based. Can be used for arbitrary
		page::gen::*                    0.1	text processing as well because
		page::parse::*                  0.1	of that.
		page::pluginmgr                 0.1
		page::reader::*                 0.1
		page::transform::*              0.1
		page::util::*                   0.1
		page::writer::*                 0.1
------          ------- 		-----------     -------------------------------
pluginmgr	pluginmgr                       0.1	Generic plugin management.
rcs		rcs                             0.1	Processing of RCS patches.
sha		sha256                        1.0.1	Extended SHA hash
------          ------- 		-----------     -------------------------------
sasl		SASL                          1.0.0	Simple Authentication & Security Layer
		SASL::NTLM                    1.0.0
------          ------- 		-----------     -------------------------------
units		units                           2.1	Unit conversions.
------          ------- 		-----------     -------------------------------


Changes from Tcllib 1.7 to 1.8
==============================

Legend
        API:    ** incompatible ** API changes. > Implies change of major version.
        EF :    Extended functionality, API.    > Implies change of minor verson.
        B  :    Bug fixes.                     \
        D  :    Documentation updates.          > Implies change of patchlevel.
        EX :    New examples.                   >
        P  :    Performance enhancement.       /
	TS :	Test suite fix		       /

                                Tcllib 1.7      Tcllib 1.8
Module          Package         Old version     New Version     Comments
------          -------         -----------     -----------     -------------------------------
asn		asn             0.1             0.4     	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
base64		uuencode        1.1.2           1.1.2   	<<< MISMATCH. Version ==, ChangeLog ++
		base64          2.3.1           2.3.1   	<<< MISMATCH. Version ==, ChangeLog ++
		yencode         1.1.1           1.1.1   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
cmdline		cmdline         1.2.3           1.2.3   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
comm		comm            4.2.1           4.2.1   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
control		control         0.1.2           0.1.2   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
counter		counter         2.0.3           2.0.3   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
crc		sum             1.1.0           1.1.0   	<<< MISMATCH. Version ==, ChangeLog ++
		crc32           1.2             1.3     	=== Classify changes.
		crc16           1.1             1.1     	<<< MISMATCH. Version ==, ChangeLog ++
		cksum           1.0.1           1.1.0   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
csv		csv             0.5.1           0.5.1   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
des		des             0.8.2           --      	=== Classify changes.
		des             --              1.0.0   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
dns		spf             1.1.0           1.1.0   	<<< MISMATCH. Version ==, ChangeLog ++
		ip              1.0.0           1.0.0   	<<< MISMATCH. Version ==, ChangeLog ++
		dns             1.2.0           1.2.1   	=== Classify changes.
		resolv          1.0.3           1.0.3   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
doctools	doctools        1.1             1.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- idx           0.2             0.2     	<<< MISMATCH. Version ==, ChangeLog ++
		- toc           0.2             0.2     	<<< MISMATCH. Version ==, ChangeLog ++
		- cvs           0.1.1           0.1.1   	<<< MISMATCH. Version ==, ChangeLog ++
		- changelog     0.1.1           0.1.1   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
fileutil	fileutil        1.7             1.7     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
ftp		ftp             2.4.1           2.4.1   	<<< MISMATCH. Version ==, ChangeLog ++
		ftp::geturl     0.2             0.2     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
grammar_fa	grammar::fa     0.1		0.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- op            0.1		0.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- dexec         0.1		0.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- dacceptor     0.1		0.1     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
html		html            1.2.3           1.2.3   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
htmlparse	htmlparse       1.1             1.1     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
http		autoproxy       1.2.0           1.2.1   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
inifile		inifile         0.1             0.1     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
javascript	javascript      1.0.1           1.0.1   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
jpeg		jpeg            0.1             0.2     	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
ldap		ldap            1.2             1.2.1   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
log		logger          0.5             0.6.1   	=== Classify changes.
		log             1.2             1.2     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
math		math                1.2.2       1.2.2   	<<< MISMATCH. Version ==, ChangeLog ++
		- statistics        0.1.2       0.1.3   	=== Classify changes.
		- rationalfunctions 1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- complexnumbers    1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- fourier           1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- interpolate       1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- fuzzy             0.2         0.2     	<<< MISMATCH. Version ==, ChangeLog ++
		- special           0.1         0.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- optimize          0.2         --      	=== Classify changes.
		- optimize          --          1.0     	=== Classify changes.
		- bignum            3.0         3.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- calculus          0.6         0.6     	<<< MISMATCH. Version ==, ChangeLog ++
		- geometry          1.0.2       1.0.2   	<<< MISMATCH. Version ==, ChangeLog ++
		- constants         1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- polynomials       1.0         1.0     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
md4		md4             1.0.2           1.0.3   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
md5		md5             --              1.4.3   	=== Classify changes.
		md5             2.0.1           2.0.4   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
mime		smtp            1.4             1.4     	<<< MISMATCH. Version ==, ChangeLog ++
		mime            1.4             1.4     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
ntp		time            1.1             1.2     	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
png		png             0.1             0.1     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
pop3		pop3            1.6.2           1.6.2   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
pop3d		pop3d::udb      1.1             1.1     	<<< MISMATCH. Version ==, ChangeLog ++
		pop3d           1.0.3           1.1.0   	=== Classify changes.
		pop3d::dbox     1.0.2           1.0.2   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
profiler	profiler        0.2.2           0.2.3   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
rc4		rc4             1.0.0           1.0.1   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
ripemd		ripemd160       1.0.0           1.0.3   	=== Classify changes.
		ripemd128       1.0.0           1.0.3   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
sha		sha1            1.0.3           1.1.0   	=== Classify changes.
		sha1            --              2.0.1   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
smtpd		smtpd           1.3.0		1.4.0   	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
snit		snit            0.97            --      	=== Classify changes.
		snit            --              1.1     	=== Classify changes.
		snit            --              2.0     	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
struct		struct          --              1.4     	=== Classify changes.
		struct          2.1             2.1     	=== Classify changes.
		- record        1.2.1           1.2.1   	<<< MISMATCH. Version ==, ChangeLog ++
		- tree          --              1.2.1   	=== Classify changes.
		- tree          2.0             2.0     	=== Classify changes.
		- graph         --              1.2.1   	=== Classify changes.
		- graph         2.0             2.0     	=== Classify changes.
		- skiplist      1.3             1.3     	<<< MISMATCH. Version ==, ChangeLog ++
		- set           2.1             2.1     	<<< MISMATCH. Version ==, ChangeLog ++
		- queue         1.3             1.3     	<<< MISMATCH. Version ==, ChangeLog ++
		- prioqueue     1.3             1.3.1   	=== Classify changes.
		- pool          1.2.1           1.2.1   	<<< MISMATCH. Version ==, ChangeLog ++
		- list          1.4             1.4     	<<< MISMATCH. Version ==, ChangeLog ++
		- matrix        --              1.2.1   	=== Classify changes.
		- matrix        2.0             2.0     	=== Classify changes.
		- stack         1.3             1.3     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
textutil	textutil        0.6.2		0.6.2   	<<< MISMATCH. Version ==, ChangeLog ++
------          - expander      1.3		1.3     	<<< MISMATCH. Version ==, ChangeLog ++
		-------         -----------     -----------     -------------------------------
tie		tie             1.0		1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- std::array    1.0             1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- std::file     1.0             1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- std::rarray   1.0             1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- std::dsource  1.0             1.0     	<<< MISMATCH. Version ==, ChangeLog ++
		- std::log      1.0             1.0     	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
treeql		treeql          1.2             1.3     	=== Classify changes.
------          -------         -----------     -----------     -------------------------------
uri		uri             1.1.4           1.1.4   	<<< MISMATCH. Version ==, ChangeLog ++
		uri::urn        1.0.2           1.0.2   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------
uuid		uuid            1.0.0		1.0.0   	<<< MISMATCH. Version ==, ChangeLog ++
------          -------         -----------     -----------     -------------------------------

Unchanged Modules/Packages
==========================
   bee         bee                             0.1      0.1     
   calendar    calendar                        0.2      0.2     
   exif        exif                            1.1.2    1.1.2   
   ftpd        ftpd                            1.2.2    1.2.2   
   ident       ident                           0.42     0.42    
   irc         irc                             0.5      0.5     
   md5crypt    md5crypt                        1.0.0    1.0.0   
   multiplexer multiplexer                     0.2      0.2     
   ncgi        ncgi                            1.2.3    1.2.3   
   nntp        nntp                            0.2.1    0.2.1   
   report      report                          0.3.1    0.3.1   
   soundex     soundex                         1.0      1.0     
   stooop      stooop                          4.4.1    4.4.1   
               switched                        2.2      2.2     
   tar         tar                             0.1      0.1     
