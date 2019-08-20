Overview
========

||||||
|---|---|---|---|---|
|8|new packages|in|7|modules|
|40|changed packages|in|25|modules|
|389|unchanged packages|in|115|modules|
|446|packages, total|in|131|modules, total|

Legend
======

|Change|Details|Comments|
|---|---|---|
|Major|API|__incompatible__ API changes|
|Minor|EF|Extended functionality, API|
||I|Major rewrite, but no API change|
|Patch|B|Bug fixes|
||EX|New examples|
||P|Performance enhancement|
|None|T|Testsuite changes|
||D|Documentation updates|

New in Tcllib 1.20
==================

|Module|Package|New Version|Comments|
|---|---|---|---|
|clay|clay|0.8||
|fileutil|fileutil::paths|1||
|lazyset|lazyset|1||
|||||
|math|math::quasirandom|1.0||
||math::trig|1.0||
|||||
|practcl|clay|0.8||
|struct|struct::map|1||
|textutil|textutil::patch|0.1||
||textutil::wcswidth|35.1||
|||||

Deprecations in Tcllib 1.20
===========================

Four packages are stage 1 deprecated in favor of two replacements.

|Module|Package|Replacement|Deprecation stage|
|---|---|---|---|
|doctools|doctools::paths|fileutil::paths|(D1) Redirected to replacements|
|doctools|doctools::config|struct::map|(D1) Redirected to replacements|
|pt|paths|fileutil::paths|(D1) Redirected to replacements|
|pt|configuration|struct::map|(D1) Redirected to replacements|

Stage 1 (__D1__) means that:

  - The deprecated packages still exist.
  - Their implementations have changed and become wrappers around their replacements.

Future progress:

  - In the release after 1.20 the stage 1 deprecated packages will be
    moved to stage 2 (__D2__). In that stage the implementations of the
    deprecated packages will stop redirecting to their replacements,
    and throw errors instead. IOW starting with stage 2 use of the
    deprecated packages will be more strictly blocked.

  - In the release after that all stage 2 deprecated package will be
    moved to stage 3 (__D3__). In that stage the packages will be
    removed from Tcllib, causing `package require` to fail.


Changes from Tcllib 1.19 to 1.20
================================

|Module|Package|From 1.19|To 1.20|Comments|
|---|---|---|---|---|
|cache|cache::async|0.3|0.3.1|B|
||||||
|doctools|doctools|1.4.21|1.5.6|B|
||doctools::idx|1.0.7|1.1|B|
||doctools::idx|2|2|B|
||doctools::toc|1.1.6|1.2|B|
||doctools::toc|2|2|B|
||||||
|doctools2idx|doctools::idx|1.0.7|1.1|---|
||doctools::idx|2|2|---|
||doctools::idx::export|0.2|0.2.1|B|
||doctools::idx::import|0.2|0.2.1|B|
||||||
|doctools2toc|doctools::toc|1.1.6|1.2|---|
||doctools::toc|2|2|---|
||doctools::toc::export|0.2|0.2.1|B|
||doctools::toc::import|0.2|0.2.1|B|
||||||
|dtplite|dtplite|1.3|1.3.1|B|
|html|html|1.4.4|1.4.5|B|
|http|autoproxy|1.6|1.7|B|
|httpd|httpd|4.1.0|4.3.3|B|
||||||
|log|log|1.3|1.4|B|
||logger::utils|1.3|1.3.1|B|
||||||
|math|math::calculus|0.8.2|0.8.1|B|
||math::geometry|1.2.3|1.3.0|B|
||math::numtheory|1.1|1.1.1|B|
||math::statistics|1.1.1|1.3.1|B|
||||||
|mime|mime|1.6|1.6.2|B|
||smtp|1.4.5|1.5|B|
||||||
|namespacex|namespacex|0.1|0.2|B|
|ncgi|ncgi|1.4.3|1.4.4|B|
|oauth|oauth|1.0.1|1.0.3|B|
|png|png|0.2|0.3|B|
|practcl|practcl|0.11|0.16.3|B|
|profiler|profiler|0.3|0.4|B|
||||||
|pt|pt::peg::export|1|1.0.1|B|
||pt::peg::import|1|1.0.1|B|
||pt::peg::op|1.0.1|1.1.0|B|
||||||
|sha1|sha1|1.1.1|1.1.1|---|
||sha1|2.0.3|2.0.4|---|
||sha256|1.0.3|1.0.4|B|
||||||
|simulation|simulation::random|0.3.1|0.4.0|B|
||||||
|struct|struct::disjointset|1.0|1.1|B|
||struct::graph|1.2.1|1.2.1|B|
||struct::graph|2.4.1|2.4.3|B|
||struct::list|1.8.3|1.8.4|B|
||struct::record|1.2.1|1.2.2|B|
|textutil|textutil|0.8|0.9|B|
|uuid|uuid|1.0.5|1.0.7|B|
|virtchannel_base|tcl::chan::cat|1.0.2|1.0.3|B|
|zip|zipfile::mkzip|1.2|1.2.1|B|
||||||

Unchanged
=========

    aes, ascii85, asn, base32, base32::core, base32::hex, base64,
    bee, bench, bench::in, bench::out::csv, bench::out::text,
    bibtex, blowfish, calendar, char, cksum, clock::iso8601,
    clock::rfc2822, cmdline, comm, configuration, control,
    coroutine, coroutine::auto, counter, crc16, crc32, cron, csv,
    debug, debug::caller, debug::heartbeat, debug::timestamp, defer,
    des, dicttool, dns, docstrip, docstrip::util,
    doctools::changelog, doctools::config, doctools::cvs,
    doctools::html, doctools::html::cssdefaults,
    doctools::idx::export::docidx, doctools::idx::export::html,
    doctools::idx::export::json, doctools::idx::export::nroff,
    doctools::idx::export::text, doctools::idx::export::wiki,
    doctools::idx::import::docidx, doctools::idx::import::json,
    doctools::idx::parse, doctools::idx::structure,
    doctools::msgcat, doctools::msgcat::idx::c,
    doctools::msgcat::idx::de, doctools::msgcat::idx::en,
    doctools::msgcat::idx::fr, doctools::msgcat::toc::c,
    doctools::msgcat::toc::de, doctools::msgcat::toc::en,
    doctools::msgcat::toc::fr, doctools::nroff::man_macros,
    doctools::paths, doctools::tcl::parse, doctools::text,
    doctools::toc::export::doctoc, doctools::toc::export::html,
    doctools::toc::export::json, doctools::toc::export::nroff,
    doctools::toc::export::text, doctools::toc::export::wiki,
    doctools::toc::import::doctoc, doctools::toc::import::json,
    doctools::toc::parse, doctools::toc::structure, exif, fileutil,
    fileutil::decode, fileutil::magic::cfront,
    fileutil::magic::cgen, fileutil::magic::filetype,
    fileutil::magic::rt, fileutil::multi, fileutil::multi::op,
    fileutil::traverse, ftp, ftp::geturl, ftpd, generator, gpx,
    grammar::aycock, grammar::aycock::debug,
    grammar::aycock::runtime, grammar::fa, grammar::fa::dacceptor,
    grammar::fa::dexec, grammar::fa::op, grammar::me::cpu,
    grammar::me::cpu::core, grammar::me::cpu::gasm,
    grammar::me::tcl, grammar::me::util, grammar::peg,
    grammar::peg::interp, hook, htmlparse, http::wget, huddle,
    huddle::json, ident, imap4, inifile, interp,
    interp::delegate::method, interp::delegate::proc, ip, irc,
    javascript, jpeg, json, json::write, lambda, ldap, ldapx,
    logger, logger::appender, map::geocode::nominatim, map::slippy,
    map::slippy::cache, map::slippy::fetcher, mapproj, Markdown,
    math, math::bigfloat, math::bignum, math::calculus::symdiff,
    math::complexnumbers, math::constants, math::decimal,
    math::exact, math::fourier, math::fuzzy, math::interpolate,
    math::linearalgebra, math::machineparameters, math::optimize,
    math::PCA, math::polynomials, math::rationalfunctions,
    math::roman, math::special, md4, md5, md5crypt, multiplexer,
    nameserv, nameserv::auto, nameserv::common, nameserv::server,
    nettool, nmea, nntp, odie::processman, oo::dialect, oo::meta,
    oo::option, oo::util, otp, page::analysis::peg::emodes,
    page::analysis::peg::minimize, page::analysis::peg::reachable,
    page::analysis::peg::realizable, page::compiler::peg::mecpu,
    page::config::peg, page::gen::peg::canon, page::gen::peg::cpkg,
    page::gen::peg::hb, page::gen::peg::me, page::gen::peg::mecpu,
    page::gen::peg::ser, page::gen::tree::text, page::parse::lemon,
    page::parse::peg, page::parse::peghb, page::parse::pegser,
    page::pluginmgr, page::reader::hb, page::reader::lemon,
    page::reader::peg, page::reader::ser, page::reader::treeser,
    page::transform::mecpu, page::transform::reachable,
    page::transform::realizable, page::util::flow,
    page::util::norm::lemon, page::util::norm::peg, page::util::peg,
    page::util::quote, page::writer::hb, page::writer::identity,
    page::writer::me, page::writer::mecpu, page::writer::null,
    page::writer::peg, page::writer::ser, page::writer::tpc,
    page::writer::tree, paths, picoirc, pki, pluginmgr, pop3, pop3d,
    pop3d::dbox, pop3d::udb, processman, pt::ast,
    pt::cparam::configuration::critcl,
    pt::cparam::configuration::tea, pt::parse::peg, pt::pe,
    pt::pe::op, pt::peg, pt::peg::container,
    pt::peg::container::peg, pt::peg::export::container,
    pt::peg::export::json, pt::peg::export::peg,
    pt::peg::from::json, pt::peg::from::peg, pt::peg::import::json,
    pt::peg::import::peg, pt::peg::interp, pt::peg::to::container,
    pt::peg::to::cparam, pt::peg::to::json, pt::peg::to::param,
    pt::peg::to::peg, pt::peg::to::tclparam, pt::pgen, pt::rde,
    pt::rde::nx, pt::rde::oo, pt::tclparam::configuration::nx,
    pt::tclparam::configuration::snit,
    pt::tclparam::configuration::tcloo, pt::util, rc4, rcs, report,
    resolv, rest, ripemd128, ripemd160, S3, SASL, SASL::NTLM,
    SASL::SCRAM, SASL::XGoogleToken, simulation::annealing,
    simulation::montecarlo, smtpd, snit, soundex, spf, stooop,
    string::token, string::token::shell, stringprep,
    stringprep::data, struct, struct::graph::op, struct::matrix,
    struct::pool, struct::prioqueue, struct::queue, struct::set,
    struct::skiplist, struct::stack, struct::tree, sum, switched,
    tar, tcl::chan::core, tcl::chan::events, tcl::chan::facade,
    tcl::chan::fifo, tcl::chan::fifo2, tcl::chan::halfpipe,
    tcl::chan::memchan, tcl::chan::null, tcl::chan::nullzero,
    tcl::chan::random, tcl::chan::std, tcl::chan::string,
    tcl::chan::textwindow, tcl::chan::variable, tcl::chan::zero,
    tcl::randomseed, tcl::transform::adler32,
    tcl::transform::base64, tcl::transform::core,
    tcl::transform::counter, tcl::transform::crc32,
    tcl::transform::hex, tcl::transform::identity,
    tcl::transform::limitsize, tcl::transform::observe,
    tcl::transform::otp, tcl::transform::rot,
    tcl::transform::spacer, tcl::transform::zlib, tclDES, tclDESjr,
    tepam, tepam::doc_gen, term, term::ansi::code,
    term::ansi::code::attr, term::ansi::code::ctrl,
    term::ansi::code::macros, term::ansi::ctrl::unix,
    term::ansi::send, term::interact::menu, term::interact::pager,
    term::receive, term::receive::bind, term::send, text::write,
    textutil::adjust, textutil::expander, textutil::repeat,
    textutil::split, textutil::string, textutil::tabify,
    textutil::trim, throw, tie, tie::std::array, tie::std::dsource,
    tie::std::file, tie::std::growfile, tie::std::log,
    tie::std::rarray, tiff, time, tool, transfer::connect,
    transfer::copy, transfer::copy::queue,
    transfer::data::destination, transfer::data::source,
    transfer::receiver, transfer::transmitter, treeql, try,
    udpcluster, uevent, uevent::onidle, unicode, unicode::data,
    units, uri, uri::urn, uuencode, valtype::common,
    valtype::creditcard::amex, valtype::creditcard::discover,
    valtype::creditcard::mastercard, valtype::creditcard::visa,
    valtype::gs1::ean13, valtype::iban, valtype::imei,
    valtype::isbn, valtype::luhn, valtype::luhn5, valtype::usnpi,
    valtype::verhoeff, websocket, wip, xsxp, yaml, yencode,
    zipfile::decode, zipfile::encode
