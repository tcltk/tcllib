source [file dirname [info script]]/smtp.tcl
package require smtp ;#1.6
package require mime
package require tls
tls::init -tls1.2 1

proc send_tls_smtp {recipient email_server subject body} {
     set token [mime::initialize -canonical text/plain -string $body]
     mime::setheader $token Subject $subject
     smtp::sendmessage $token\
 	-usetls 1 -tlsimport 0 -originator test@tcl.tk -recipients $recipient -servers $email_server -ports 25\
	-debug 1
     mime::finalize $token 
}  
proc send_ssl_smtp {recipient email_server subject body} {
     set token [mime::initialize -canonical text/plain -string $body]
     mime::setheader $token Subject $subject
     smtp::sendmessage $token\
 	-usetls 0 -tlsimport 1 -originator test@tcl.tk -recipients $recipient -servers $email_server -ports 465\
	-debug 1
     mime::finalize $token 
}


send_tls_smtp test@tcl.tk alt1.gmail-smtp-in.l.google.com \
     "This is the subject." "This is the message."
send_ssl_smtp test@tcl.tk smtp.gmail.com \
     "This is the subject." "This is the message."
