#!/usr/local/bin/tclsh8.0

package require FTP 1.2

if [FTP::Open ftp.scriptics.com  anonymous xxxx] {
    	if {[FTP::Newer /pub/tcl/httpd/tclhttpd.tar.gz /usr/local/src/tclhttpd.tgz]} {
		exec echo "New httpd arrived!" | mailx -s ANNOUNCE root
	}
	FTP::Close 
}

