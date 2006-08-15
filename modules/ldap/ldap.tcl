#-----------------------------------------------------------------------------
#   Copyright (C) 1999-2004 Jochen C. Loewer (loewerj@web.de)
#-----------------------------------------------------------------------------
#
#   A (partial) LDAPv3 protocol implementation in plain Tcl.
#
#   See RFC 2251 and ASN.1 (X.680) and BER (X.690).
#
#
#   This software is copyrighted by Jochen C. Loewer (loewerj@web.de). The
#   following terms apply to all files associated with the software unless
#   explicitly disclaimed in individual files.
#
#   The authors hereby grant permission to use, copy, modify, distribute,
#   and license this software and its documentation for any purpose, provided
#   that existing copyright notices are retained in all copies and that this
#   notice is included verbatim in any distributions. No written agreement,
#   license, or royalty fee is required for any of the authorized uses.
#   Modifications to this software may be copyrighted by their authors
#   and need not follow the licensing terms described here, provided that
#   the new terms are clearly indicated on the first page of each file where
#   they apply.
#
#   IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#   FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#   ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
#   DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.
#
#   THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#   INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#   IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#   NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#   MODIFICATIONS.
#
#   $Id: ldap.tcl,v 1.11 2006/08/15 14:11:34 mic42 Exp $
#
#   written by Jochen Loewer
#   3 June, 1999
#
#-----------------------------------------------------------------------------

package require Tcl 8.4
package require asn 0.6
package provide ldap 1.5


namespace eval ldap {

    namespace export  connect secure_connect \
                      disconnect             \
                      bind unbind            \
                      search                 \
                      modify                 \
                      add                    \
		      addMulti		     \
                      delete                 \
                      modifyDN		     \
		      info

    namespace import ::asn::*
    
    variable SSLCertifiedAuthoritiesFile
    variable doDebug

    set doDebug 0

    array set resultCode2String {
         0  success
         1  operationsError
         2  protocolError
         3  timeLimitExceeded
         4  sizeLimitExceeded
         5  compareFalse
         6  compareTrue
         7  authMethodNotSupported
         8  strongAuthRequired
        10  referral
        11  adminLimitExceeded
        12  unavailableCriticalExtension
        13  confidentialityRequired
        14  saslBindInProgress
        16  noSuchAttribute
        17  undefinedAttributeType
        18  inappropriateMatching
        19  constraintViolation
        20  attributeOrValueExists
        21  invalidAttributeSyntax
        32  noSuchObject
        33  aliasProblem
        34  invalidDNSyntax
        35  isLeaf
        36  aliasDereferencingProblem
        48  inappropriateAuthentication
        49  invalidCredentials
        50  insufficientAccessRights
        51  busy
        52  unavailable
        53  unwillingToPerform
        54  loopDetect
        64  namingViolation
        65  objectClassViolation
        66  notAllowedOnNonLeaf
        67  notAllowedOnRDN
        68  entryAlreadyExists
        69  objectClassModsProhibited
        80  other
    }
}


#-----------------------------------------------------------------------------
#    info
#
#-----------------------------------------------------------------------------

proc ldap::info {args} {
   set cmd [lindex $args 0]
   set cmds {connections ip bound tls}
   if {[llength $args] == 0} {
   	return -code error \
		"Usage info connections|ip handle|bound handle|tls handle"    
   }
   if {[lsearch -exact $cmds $cmd] == -1} {
   	return -code error \
		"Invalid subcommand \"$cmd\", valid commands are\
		[join [lrange $cmds 0 end-1] ,] and [lindex $cmds end]" 
   }
   eval [linsert [lrange $args 1 end] 0 ldap::info_$cmd]    
}

#-----------------------------------------------------------------------------
#    get the ip address of the server we connected to
# 
#-----------------------------------------------------------------------------
proc ldap::info_ip {args} {
   if {[llength $args] != 1} {
   	return -code error \
	       "Wrong # of arguments. Usage: ldap::info ip handle"
   }
   upvar #0 [lindex $args 0] conn
   if {![::info exists conn(sock)]} {
   	return -code error \
		"\"[lindex $args 0]\" is not a ldap connection handle"
   }
   return [lindex [fconfigure $conn(sock) -peername] 0]
}

#-----------------------------------------------------------------------------
#   get the list of open ldap connections
#
#-----------------------------------------------------------------------------
proc ldap::info_connections {args} {
   if {[llength $args] != 0} {
   	return -code error \
	       "Wrong # of arguments. Usage: ldap::info connections"   
   }
   return [::info vars ::ldap::ldap*]
}

#-----------------------------------------------------------------------------
#   check if the connection is bound
#
#-----------------------------------------------------------------------------
proc ldap::info_bound {args} {
   if {[llength $args] != 1} {
   	return -code error \
	       "Wrong # of arguments. Usage: ldap::info bound handle"
   }
   upvar #0 [lindex $args 0] conn
   if {![::info exists conn(bound)]} {
   	return -code error \
		"\"[lindex $args 0]\" is not a ldap connection handle"
   }
   return $conn(bound)
}

#-----------------------------------------------------------------------------
#   check if the connection uses tls
#
#-----------------------------------------------------------------------------

proc ldap::info_tls {args} {
   if {[llength $args] != 1} {
   	return -code error \
	       "Wrong # of arguments. Usage: ldap::info tls handle"
   }
   upvar #0 [lindex $args 0] conn
   if {![::info exists conn(tls)]} {
   	return -code error \
		"\"[lindex $args 0]\" is not a ldap connection handle"
   }
   return $conn(tls)
}


#-----------------------------------------------------------------------------
#    connect
#
#-----------------------------------------------------------------------------
proc ldap::connect { host {port 389} } {

    #--------------------------------------
    #   connect via TCP/IP
    #--------------------------------------
    set sock [socket $host $port]
    fconfigure $sock -blocking yes -translation binary

    #--------------------------------------
    #   initialize connection array
    #--------------------------------------
    upvar ::ldap::ldap$sock conn
    catch { unset conn }

    set conn(sock)      $sock
    set conn(messageId) 0
    set conn(tls)       0
    set conn(bound)     ''

    return ::ldap::ldap$sock
}

#-----------------------------------------------------------------------------
#    secure_connect
#
#-----------------------------------------------------------------------------
proc ldap::secure_connect { host {port 636} } {

    variable SSLCertifiedAuthoritiesFile

    package require tls

    #------------------------------------------------------------------
    #   connect via TCP/IP
    #------------------------------------------------------------------
    set sock [socket $host $port]
    fconfigure $sock -blocking yes -translation binary

    #------------------------------------------------------------------
    #   make it a SSL connection
    #
    #------------------------------------------------------------------
    #tls::import $sock -cafile $SSLCertifiedAuthoritiesFile -ssl2 no -ssl3 yes -tls1 yes
    tls::import $sock -cafile "" -certfile "" -keyfile "" \
                      -request 1 -server 0 -require 0 -ssl2 no -ssl3 yes -tls1 yes
    set retry 0
    while {1} {
        if {$retry > 20} {
            close $sock
            return -code error "too long retry to setup SSL connection"
        }
        if {[catch { tls::handshake $sock } err]} {
            if {[string match "*resource temporarily unavailable*" $err]} {
                after 50
                incr retry
            } else {
                close $sock
                return -code error $err
            }
        } else {
            break
        }
    }
    #puts stderr [tls::status $sock]

    #--------------------------------------
    #   initialize connection array
    #--------------------------------------
    upvar ::ldap::ldap$sock conn
    catch { unset conn }

    set conn(sock)      $sock
    set conn(messageId) 0
    set conn(tls)       1
    set conn(bound)     ''

    return ::ldap::ldap$sock
}


#-----------------------------------------------------------------------------
#    bind  -  does a bind with simple authentication
#
#-----------------------------------------------------------------------------
proc ldap::bind { handle {name ""} {password ""} } {

    upvar $handle conn

    incr conn(messageId)

    #-----------------------------------------------------------------
    #   marshal bind request packet and send it
    #
    #-----------------------------------------------------------------
    set request [asnSequence                           \
                    [asnInteger $conn(messageId)]      \
                    [asnApplicationConstr 0            \
                        [asnInteger 3]                 \
                        [asnOctetString $name]         \
                        [asnChoice 0 $password]        \
                    ]                                  \
                ]
    debugData bindRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #-----------------------------------------------------------------
    #   receive (blocking) bind response packet(s) and unmarshal it
    #
    #-----------------------------------------------------------------
    asnGetResponse $conn(sock) response
    debugData bindResponse $response

    asnGetSequence response response
    asnGetInteger  response MessageID
    if { $MessageID != $conn(messageId) } {
        error "umatching response packet ($MessageID != $conn(messageId))"
    }
    asnGetApplication response appNum
    if { $appNum != 1 } {
        error "unexpected application number ($appNum != 1)"
    }
    asnGetEnumeration response resultCode
    asnGetOctetString response matchedDN
    asnGetOctetString response errorMessage
    if {$resultCode != 0} {
        return -code error "LDAP error $ldap::resultCode2String($resultCode) '$matchedDN': $errorMessage"
    }
    set conn(bound) 1
}


#-----------------------------------------------------------------------------
#    unbind
#
#-----------------------------------------------------------------------------
proc ldap::unbind { handle } {

    upvar $handle conn

    incr conn(messageId)

    #------------------------------------------------
    #   marshal unbind request packet and send it
    #------------------------------------------------
    set request [asnSequence                      \
                    [asnInteger $conn(messageId)] \
                    [asnApplication 2 ""]         ]

    debugData unbindRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)
    set conn(bound) 0
}


#-----------------------------------------------------------------------------
#    buildUpFilter  -   parses the text representation of LDAP search
#                       filters and transforms it into the correct
#                       marshalled representation for the search request
#                       packet
#
#-----------------------------------------------------------------------------
proc ldap::buildUpFilter { filter } {

    set first [lindex $filter 0]
    set data ""
    switch -regexp -- $first {
        ^\\&$ {  #--- and -------------------------------------------
            foreach term [lrange $filter 1 end] {
                append data [buildUpFilter $term]
            }
            return [asnChoiceConstr 0 $data]
        }
        ^\\|$ {  #--- or --------------------------------------------
            foreach term [lrange $filter 1 end] {
                append data [buildUpFilter $term]
            }
            return [asnChoiceConstr 1 $data]
        }
        ^\\!$ {  #--- not -------------------------------------------
            return [asnChoiceConstr 2 [buildUpFilter [lindex $filter 1]]]
        }
        =\\*$ {  #--- present ---------------------------------------
            set endpos [expr {[string length $first] -3}]
            set attributetype [string range $first 0 $endpos]
            return [asnChoice 7 $attributetype]
        }
        ^[0-9A-z.]*~= {  #--- approxMatch --------------------------
            regexp {^([0-9A-z.]*)~=(.*)$} $first all attributetype value
            return [asnChoiceConstr 8 [asnOctetString $attributetype] \
                                      [asnOctetString $value]         ]
        }
        ^[0-9A-z.]*<= {  #--- lessOrEqual --------------------------
            regexp {^([0-9A-z.]*)<=(.*)$} $first all attributetype value
            return [asnChoiceConstr 6 [asnOctetString $attributetype] \
                                      [asnOctetString $value]         ]
        }
        ^[0-9A-z.]*>= {  #--- greaterOrEqual -----------------------
            regexp {^([0-9A-z.]*)>=(.*)$} $first all attributetype value
            return [asnChoiceConstr 5 [asnOctetString $attributetype] \
                                      [asnOctetString $value]         ]
        }
        ^[0-9A-z.]*=.*\\*.* {  #--- substrings -----------------
            regexp {^([0-9A-z.]*)=(.*)$} $first all attributetype value
            regsub -all {\*+} $value {*} value
            set value [split $value "*"]
            
            set firstsubstrtype 0       ;# initial
            set lastsubstrtype  2       ;# final
            if {[string equal [lindex $value 0] ""]} {
                set firstsubstrtype 1       ;# any
                set value [lreplace $value 0 0]
            }
            if {[string equal [lindex $value end] ""]} {
                set lastsubstrtype 1        ;# any
                set value [lreplace $value end end]
            }
        
            set n [llength $value]
        
            set i 1
            set l {}
            set substrtype 0            ;# initial
            foreach str $value {
            if {$i == 1 && $i == $n} {
                if {$firstsubstrtype == 0} {
                set substrtype 0    ;# initial
                } elseif {$lastsubstrtype == 2} {
                set substrtype 2    ;# final
                } else {
                set substrtype 1    ;# any
                }
            } elseif {$i == 1} {
                set substrtype $firstsubstrtype
            } elseif {$i == $n} {
                set substrtype $lastsubstrtype
            } else {
                set substrtype 1        ;# any
            }
            lappend l [asnChoice $substrtype $str]
            incr i
            }
            return [asnChoiceConstr 4 [asnOctetString $attributetype]     \
                      [asnSequenceFromList $l] ]
        }
        ^[0-9A-z.]*= {  #--- equal ---------------------------------
            regexp {^([0-9A-z.]*)=(.*)$} $first all attributetype value
            trace "equal: attributetype='$attributetype' value='$value'"
            return [asnChoiceConstr 3 [asnOctetString $attributetype] \
                                      [asnOctetString $value]         ]
        }
        default {
            return [buildUpFilter $first]
            #error "cant handle $first for filter part"
        }
    }
}

#-----------------------------------------------------------------------------
#    search  -  performs a LDAP search below the baseObject tree using a
#               complex LDAP search expression (like "|(cn=Linus*)(sn=Torvalds*)"
#               and returns all matching objects (DNs) with given attributes
#               (or all attributes if empty list is given) as list:
#
#               dn1 { attr1 val1 attr2 val2 ... } dn2 { a1 v1 } ....
#
#-----------------------------------------------------------------------------
proc ldap::search { handle baseObject filterString attributes args} {

    upvar $handle conn

    set scope        2
    set derefAliases 0
    set sizeLimit    0
    set timeLimit    0
    set attrsOnly    0

    foreach {key value} $args {
        switch -- $key {
            -scope {
                switch -- $value {
                   base { set scope 0 }
                   one - onelevel { set scope 1 }
                   sub - subtree { set scope 2 }
                   default { set scope $value }
                }
            }
        }
    }

    #----------------------------------------------------------
    #   marshal filter and attributes parameter
    #----------------------------------------------------------
    regsub -all {\(} $filterString " \{" filterString
    regsub -all {\)} $filterString "\} " filterString

    set berFilter [buildUpFilter $filterString]

    set berAttributes ""
    foreach attribute $attributes {
        append berAttributes [asnOctetString $attribute]
    }

    #----------------------------------------------------------
    #   marshal search request packet and send it
    #----------------------------------------------------------
    incr conn(messageId)
    set request [asnSequence                            \
                    [asnInteger $conn(messageId)]       \
                    [asnApplicationConstr 3             \
                        [asnOctetString $baseObject]    \
                        [asnEnumeration $scope]         \
                        [asnEnumeration $derefAliases]  \
                        [asnInteger     $sizeLimit]     \
                        [asnInteger     $timeLimit]     \
                        [asnBoolean     $attrsOnly]     \
                        $berFilter                      \
                        [asnSequence    $berAttributes] \
                    ]                                   \
                ]
    debugData searchRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #----------------------------------------------------------
    #   receive (blocking) search response packet(s)
    #----------------------------------------------------------
    set results    {}
    set lastPacket 0
    while { !$lastPacket } {

        asnGetResponse $conn(sock) response
        debugData searchResponse $response

        asnGetSequence response response
        asnGetInteger  response MessageID
        if { $MessageID != $conn(messageId) } {
            error "umatching response packet ($MessageID != $conn(messageId))"
        }
        asnGetApplication response appNum
        if { ($appNum != 4) && ($appNum != 5) } {
             error "unexpected application number ($appNum != 4 or 5)"
        }
        if {$appNum == 4} {
            #----------------------------------------------------------
            #   unmarshal search data packet
            #----------------------------------------------------------
            asnGetOctetString response objectName
            asnGetSequence    response attributes
            set result_attributes {}
            while { [string length $attributes] != 0 } {
                asnGetSequence attributes attribute
                asnGetOctetString attribute attrType
                asnGetSet  attribute attrValues
                set result_attrValues {}
                while { [string length $attrValues] != 0 } {
                    asnGetOctetString attrValues attrValue
                    lappend result_attrValues $attrValue
                }
                lappend result_attributes $attrType $result_attrValues
            }
            lappend results [list $objectName $result_attributes]
        }
        if {$appNum == 5} {
            #----------------------------------------------------------
            #   unmarshal search final response packet
            #----------------------------------------------------------
            asnGetEnumeration response resultCode
            asnGetOctetString response matchedDN
            asnGetOctetString response errorMessage
            if {$resultCode != 0} {
                return -code error "LDAP error $ldap::resultCode2String($resultCode): $errorMessage"
            }
            set lastPacket 1
        }
    }
    return $results
}


#-----------------------------------------------------------------------------
#    modify  -  provides attribute modifications on one single object (DN):
#                 o replace attributes with new values
#                 o delete attributes (having certain values)
#                 o add attributes with new values
#
#-----------------------------------------------------------------------------
proc ldap::modify { handle dn
                    attrValToReplace { attrToDelete {} } { attrValToAdd {} } } {

    upvar $handle conn

    set operationAdd     0
    set operationDelete  1
    set operationReplace 2

    #------------------------------------------------------------------
    #   marshal attribute modify operations
    #    - always mode 'replace' ! see rfc2251:
    #
    #        replace: replace all existing values of the given attribute
    #        with the new values listed, creating the attribute if it
    #        did not already exist.  A replace with no value will delete
    #        the entire attribute if it exists, and is ignored if the
    #        attribute does not exist.
    #
    #------------------------------------------------------------------
    set modifications {}
    foreach { attrName attrValue } $attrValToReplace {
        append modifications [asnSequence                            \
                                 [asnEnumeration $operationReplace ] \
                                 [asnSequence                        \
                                    [asnOctetString $attrName  ]     \
                                    [asnSet                          \
                                        [asnOctetString $attrValue ] \
                                    ]                                \
                                 ]                                   \
                             ]
    }

    #------------------------------------------------------------------
    #   marshal attribute add operations
    #
    #------------------------------------------------------------------
    foreach { attrName attrValue } $attrValToAdd {
        append modifications [asnSequence                            \
                                 [asnEnumeration $operationAdd ]     \
                                 [asnSequence                        \
                                    [asnOctetString $attrName  ]     \
                                    [asnSet                          \
                                        [asnOctetString $attrValue ] \
                                    ]                                \
                                 ]                                   \
                             ]
    }

    #------------------------------------------------------------------
    #   marshal attribute delete operations
    #
    #     - a non-empty value will trigger to delete only those
    #       attributes which have the same value as the given one
    #
    #     - an empty value will trigger to delete the attribute
    #       in all cases
    #
    #------------------------------------------------------------------
    foreach { attrName attrValue } $attrToDelete {
        if {$attrValue == ""} {
            set val [asnSet ""]
        } else {
            set val [asnSet [asnOctetString $attrValue]]
        }
        append modifications [asnSequence                            \
                                 [asnEnumeration $operationDelete ]  \
                                 [asnSequence                        \
                                    [asnOctetString $attrName  ]     \
                                    $val                             \
                                 ]                                   \
                             ]
    }

    #----------------------------------------------------------
    #   marshal 'modify' request packet and send it
    #----------------------------------------------------------
    incr conn(messageId)
    set request [asnSequence                             \
                    [asnInteger $conn(messageId)]        \
                    [asnApplicationConstr 6              \
                        [asnOctetString $dn ]            \
                        [asnSequence    $modifications ] \
                    ]                                    \
                ]
    debugData modifyRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #-----------------------------------------------------------------------
    #   receive (blocking) 'modify' response packet(s) and unmarshal it
    #-----------------------------------------------------------------------
    asnGetResponse $conn(sock) response
    debugData bindResponse $response

    asnGetSequence response response
    asnGetInteger  response MessageID

    if { $MessageID != $conn(messageId) } {
        error "umatching response packet ($MessageID != $conn(messageId))"
    }
    asnGetApplication response appNum
    if { $appNum != 7 } {
         error "unexpected application number ($appNum != 7)"
    }
    asnGetEnumeration response resultCode
    asnGetOctetString response matchedDN
    asnGetOctetString response errorMessage
    if {$resultCode != 0} {
        return -code error "LDAP error $ldap::resultCode2String($resultCode) $matchedDN: $errorMessage"
    }
}


#-----------------------------------------------------------------------------
#    add  -  will create a new object using given DN and sets the given
#            attributes
#
#-----------------------------------------------------------------------------
proc ldap::add { handle dn attrValueTuples } {

  #
  # In order to handle multi-valuated attributes (see bug 1191326 on
  # sourceforge), we walk through tuples to collect all values for
  # an attribute.
  # http://sourceforge.net/tracker/index.php?func=detail&atid=112883&group_id=12883&aid=1191326
  #

  foreach { attrName attrValue } $attrValueTuples {
     lappend avpairs($attrName) $attrValue
  }

  return [addMulti $handle $dn [array get avpairs]]
}

#-----------------------------------------------------------------------------
#    addMulti -  will create a new object using given DN and sets the given
#		 attributes. Argument is a list of attr-listOfVals pair.
#
#-----------------------------------------------------------------------------
proc ldap::addMulti { handle dn attrValueTuples } {

    upvar $handle conn

    #------------------------------------------------------------------
    #   marshal attribute list
    #
    #------------------------------------------------------------------
    set attrList ""

    foreach { attrName attrValues } $attrValueTuples {
       set valList {}
       foreach val $attrValues {
	   lappend valList [asnOctetString $val]
       }
       append attrList [asnSequence			    \
			   [asnOctetString $attrName ]      \
			   [asnSetFromList $valList]	    \
		       ]
    }    

    #----------------------------------------------------------
    #   marshal search 'add' request packet and send it
    #----------------------------------------------------------
    incr conn(messageId)
    set request [asnSequence                        \
                    [asnInteger $conn(messageId)]   \
                    [asnApplicationConstr 8         \
                        [asnOctetString $dn       ] \
                        [asnSequence    $attrList ] \
                    ]                               \
                ]

    debugData addRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #-----------------------------------------------------------------------
    #   receive (blocking) 'add' response packet(s) and unmarshal it
    #
    #-----------------------------------------------------------------------
    asnGetResponse $conn(sock) response
    debugData bindResponse $response

    asnGetSequence response response
    asnGetInteger  response MessageID

    if { $MessageID != $conn(messageId) } {
        error "umatching response packet ($MessageID != $conn(messageId))"
    }
    asnGetApplication response appNum
    if { $appNum != 9 } {
         error "unexpected application number ($appNum != 9)"
    }
    asnGetEnumeration response resultCode
    asnGetOctetString response matchedDN
    asnGetOctetString response errorMessage
    if {$resultCode != 0} {
        return -code error "LDAP error $ldap::resultCode2String($resultCode) $matchedDN: $errorMessage"
    }
}

#-----------------------------------------------------------------------------
#    delete  -  removes the whole object (DN) inclusive all attributes
#
#-----------------------------------------------------------------------------
proc ldap::delete { handle dn } {

    upvar $handle conn

    #----------------------------------------------------------
    #   marshal 'delete' request packet and send it
    #----------------------------------------------------------
    incr conn(messageId)
    set request [asnSequence                      \
                    [asnInteger $conn(messageId)] \
                    [asnApplication 10 $dn      ] \
                ]

    debugData deleteRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #-----------------------------------------------------------------------
    #   receive (blocking) 'delete' response packet(s) and unmarshal it
    #
    #-----------------------------------------------------------------------
    asnGetResponse $conn(sock) response
    debugData bindResponse $response

    asnGetSequence response response
    asnGetInteger  response MessageID

    if { $MessageID != $conn(messageId) } {
        error "umatching response packet ($MessageID != $conn(messageId))"
    }
    asnGetApplication response appNum
    if { $appNum != 11 } {
         error "unexpected application number ($appNum != 11)"
    }
    asnGetEnumeration response resultCode
    asnGetOctetString response matchedDN
    asnGetOctetString response errorMessage
    if {$resultCode != 0} {
        return -code error "LDAP error $ldap::resultCode2String($resultCode) $matchedDN: $errorMessage"
    }
}


#-----------------------------------------------------------------------------
#    modifyDN  -  moves an object (DN) to another (relative) place
#
#-----------------------------------------------------------------------------
proc ldap::modifyDN { handle dn newrdn { deleteOld 1 } } {

    upvar $handle conn

    #----------------------------------------------------------
    #   marshal 'modifyDN' request packet and send it
    #----------------------------------------------------------
    incr conn(messageId)
    set request [asnSequence                             \
                    [asnInteger $conn(messageId)]        \
                    [asnApplicationConstr 12             \
                        [asnOctetString $dn ]            \
                        [asnOctetString $newrdn ]        \
                        [asnBoolean     $deleteOld ]     \
                    ]                                    \
                ]
    debugData modifyRequest $request
    puts -nonewline $conn(sock) $request
    flush $conn(sock)

    #-----------------------------------------------------------------------
    #   receive (blocking) 'modifyDN' response packet(s) and unmarshal it
    #-----------------------------------------------------------------------
    asnGetResponse $conn(sock) response
    debugData bindResponse $response

    asnGetSequence response response
    asnGetInteger  response MessageID

    if { $MessageID != $conn(messageId) } {
        error "umatching response packet ($MessageID != $conn(messageId))"
    }
    asnGetApplication response appNum
    if { $appNum != 13 } {
         error "unexpected application number ($appNum != 13)"
    }
    asnGetEnumeration response resultCode
    asnGetOctetString response matchedDN
    asnGetOctetString response errorMessage
    if {$resultCode != 0} {
        return -code error "LDAP error $ldap::resultCode2String($resultCode) $matchedDN: $errorMessage"
    }
}


#-----------------------------------------------------------------------------
#    disconnect
#
#-----------------------------------------------------------------------------
proc ldap::disconnect { handle } {

    upvar $handle conn

    # should we sent an 'unbind' ?
    close $conn(sock)
    unset conn

    return
}


#-----------------------------------------------------------------------------
#    trace
#
#-----------------------------------------------------------------------------
proc ldap::trace { message } {

    variable doDebug

    if {!$doDebug} return

    puts stderr $message
}


#-----------------------------------------------------------------------------
#    debugData
#
#-----------------------------------------------------------------------------
proc ldap::debugData { info data } {

    variable doDebug

    if {!$doDebug} return

    set len [string length $data]
    trace "$info ($len bytes):"
    set address ""
    set hexnums ""
    set ascii   ""
    for {set i 0} {$i < $len} {incr i} {
        set v [string index $data $i]
        binary scan $v H2 hex
        binary scan $v c  num
        set num [expr {( $num + 0x100 ) % 0x100}]
        set text .
        if {$num > 31} {
            set text $v
        }
        if { ($i % 16) == 0 } {
            if {$address != ""} {
                trace [format "%4s  %-48s  |%s|" $address $hexnums $ascii ]
                set address ""
                set hexnums ""
                set ascii   ""
            }
            append address [format "%04d" $i]
        }
        append hexnums "$hex "
        append ascii   $text
        #trace [format "%3d %2s %s" $i $hex $text]
    }
    if {$address != ""} {
        trace [format "%4s  %-48s  |%s|" $address $hexnums $ascii ]
    }
    trace ""
}
