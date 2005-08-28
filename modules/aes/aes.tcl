#!/usr/bin/tclsh
#
# 
# Tcl-script for AES en-/description
#
# Feb/Mar 2005 by Thorsten Schloermann
#
# 
#
#
# usage: 
# 
# ::aes::start <mode> <key> <(plain|cipher)text>
#
# <mode>: "d" for decryption, "e" for encryption, followed by 
#                  the keylength of 128, 196 or 256, eg. "e128"
#
# <key>: hexadecimal representation of the key according to the keylength
#
# <(plain/cipher)text>: the plain- or ciphertext (in hexadecimal representation)
#

package require Tcl 8.4

package provide aes 0.3

namespace eval ::aes {}



#-------------------------------#
# ::aes::init                   #
#                               #
# setting up the needed data    #
#                               #
#-------------------------------#

proc ::aes::init {m key text} {

	variable state
	variable keyArray
	variable Nk
	variable Nb
	variable Nr
	variable sbox
	upvar $m mode 

	# the first char is the mode (e or d), the other 3 chars define the keylength 
	set bit [string range $mode 1 3]
	set mode [string index $mode 0]
	
	
	# put plain-/chiphertext bytewise into a list
	set i 0
	while {$i<[string length $text]} {
    	set cc [string range $text $i [expr $i+1]]
    	set hex [format "0x$cc"]
    	lappend textlist $hex
    	incr i 2
	}

	
	# put the textlist into an array
	for {set j 0} {$j < 4} {incr j} {
    	for {set i 0} {$i < 4} {incr i} {
		set state($i,$j) [lindex $textlist [expr $i + ($j * 4)]]
    	}
	}
	unset textlist



	# Nk: columns of the key-array
	# Nr: number of rounds (depends on key-length)

	switch -- $bit {
    	"128" {set Nk 4; set Nr 10}
    	"192" {set Nk 6; set Nr 12}
    	"256" {set Nk 8; set Nr 14}
    	default {puts "error"}
    
	}
	
	# Nb: columns of the text-block, is always 4 in AES
	set Nb 4 

	
	# now put the key bytewise into an array
	# if the keylength is smaller than desired, it will be padded with 0s
	set i 0
	set m 0
	set hexDigits [expr $bit / 4]
	while {$i < $hexDigits} {
    	set l 0
    	while {$l < 4} {
		set value [string range $key $i [expr $i+1]]
		if {[string length $value] == 0} {
	    	append value 00
		} elseif {[string length $value] == 1} {
	    	append value 0
		} 
		set keyArray($l,$m) [format "0x$value"]
	
		incr i 2
		incr l
    	}
    	incr m
	}

	# the S-box
	set sbox {0x63 0x7c 0x77 0x7b 0xf2 0x6b 0x6f 0xc5 0x30 0x01 0x67 0x2b 0xfe 0xd7 0xab 0x76
			  0xca 0x82 0xc9 0x7d 0xfa 0x59 0x47 0xf0 0xad 0xd4 0xa2 0xaf 0x9c 0xa4 0x72 0xc0
          	  0xb7 0xfd 0x93 0x26 0x36 0x3f 0xf7 0xcc 0x34 0xa5 0xe5 0xf1 0x71 0xd8 0x31 0x15
          	  0x04 0xc7 0x23 0xc3 0x18 0x96 0x05 0x9a 0x07 0x12 0x80 0xe2 0xeb 0x27 0xb2 0x75
          	  0x09 0x83 0x2c 0x1a 0x1b 0x6e 0x5a 0xa0 0x52 0x3b 0xd6 0xb3 0x29 0xe3 0x2f 0x84
          	  0x53 0xd1 0x00 0xed 0x20 0xfC 0xb1 0x5b 0x6a 0xcb 0xbe 0x39 0x4a 0x4c 0x58 0xcf
          	  0xd0 0xef 0xaa 0xfb 0x43 0x4d 0x33 0x85 0x45 0xf9 0x02 0x7f 0x50 0x3c 0x9f 0xa8
          	  0x51 0xa3 0x40 0x8f 0x92 0x9d 0x38 0xf5 0xbc 0xb6 0xda 0x21 0x10 0xff 0xf3 0xd2
          	  0xcd 0x0c 0x13 0xec 0x5f 0x97 0x44 0x17 0xc4 0xa7 0x7e 0x3d 0x64 0x5d 0x19 0x73
          	  0x60 0x81 0x4f 0xdc 0x22 0x2a 0x90 0x88 0x46 0xee 0xb8 0x14 0xde 0x5e 0x0b 0xdb
          	  0xe0 0x32 0x3a 0x0a 0x49 0x06 0x24 0x5c 0xc2 0xd3 0xac 0x62 0x91 0x95 0xe4 0x79
          	  0xe7 0xc8 0x37 0x6d 0x8d 0xd5 0x4e 0xa9 0x6c 0x56 0xf4 0xea 0x65 0x7a 0xae 0x08
          	  0xba 0x78 0x25 0x2e 0x1c 0xa6 0xb4 0xc6 0xe8 0xdd 0x74 0x1f 0x4b 0xbd 0x8b 0x8a
          	  0x70 0x3e 0xb5 0x66 0x48 0x03 0xf6 0x0e 0x61 0x35 0x57 0xb9 0x86 0xc1 0x1d 0x9e
          	  0xe1 0xf8 0x98 0x11 0x69 0xd9 0x8e 0x94 0x9b 0x1e 0x87 0xe9 0xce 0x55 0x28 0xdf
          	  0x8c 0xa1 0x89 0x0d 0xbf 0xe6 0x42 0x68 0x41 0x99 0x2d 0x0f 0xb0 0x54 0xbb 0x16}
		  
}

#-----------------------------------------------#
# ::aes::SubFunc                                #
#                                               #
# operates on the sbox, gets one byte           #
# and returns the byte substituted by the sbox  #
#-----------------------------------------------#

proc ::aes::SubFunc byte {
    
    variable sbox    
    return [lindex $sbox $byte]
}

#---------------------------------#
# ::aes::InvSubFunc               #
#                                 #
# the inverse of SubFunc          #
#---------------------------------#

proc ::aes::InvSubFunc byte {
    
    # one could use an inverse representation of the sbox here
    # but this is a different approach: it searches the list for
    # the desired byte an returns the list index

    variable sbox
    set i 0
    foreach value $sbox {
	
	if {$byte == $value} {break}
	incr i
    }

    set result [format "%#x" $i]
    return $result
}
	    


#-----------------------------------#
# ::aes::GFMult*                    #
#                                   #
# some needed functions for         #
# multiplication in a Galois-field  #
#-----------------------------------#


proc ::aes::GFMult2 {number} {

	# this is a tabular representation of xtime (multiplication by 2)
	# it is used instead of calculation to prevent timing attacks
	set xtime {0x00 0x02 0x04 0x06 0x08 0x0a 0x0c 0x0e 0x10 0x12 0x14 0x16 0x18 0x1a 0x1c 0x1e
			   0x20 0x22 0x24 0x26 0x28 0x2a 0x2c 0x2e 0x30 0x32 0x34 0x36 0x38 0x3a 0x3c 0x3e 
			   0x40 0x42 0x44 0x46 0x48 0x4a 0x4c 0x4e 0x50 0x52 0x54 0x56 0x58 0x5a 0x5c 0x5e
			   0x60 0x62 0x64 0x66 0x68 0x6a 0x6c 0x6e 0x70 0x72 0x74 0x76 0x78 0x7a 0x7c 0x7e 
			   0x80 0x82 0x84 0x86 0x88 0x8a 0x8c 0x8e 0x90 0x92 0x94 0x96 0x98 0x9a 0x9c 0x9e 
			   0xa0 0xa2 0xa4 0xa6 0xa8 0xaa 0xac 0xae 0xb0 0xb2 0xb4 0xb6 0xb8 0xba 0xbc 0xbe 
			   0xc0 0xc2 0xc4 0xc6 0xc8 0xca 0xcc 0xce 0xd0 0xd2 0xd4 0xd6 0xd8 0xda 0xdc 0xde 
			   0xe0 0xe2 0xe4 0xe6 0xe8 0xea 0xec 0xee 0xf0 0xf2 0xf4 0xf6 0xf8 0xfa 0xfc 0xfe 
			   0x1b 0x19 0x1f 0x1d 0x13 0x11 0x17 0x15 0x0b 0x09 0x0f 0x0d 0x03 0x01 0x07 0x05 
			   0x3b 0x39 0x3f 0x3d 0x33 0x31 0x37 0x35 0x2b 0x29 0x2f 0x2d 0x23 0x21 0x27 0x25 
			   0x5b 0x59 0x5f 0x5d 0x53 0x51 0x57 0x55 0x4b 0x49 0x4f 0x4d 0x43 0x41 0x47 0x45 
			   0x7b 0x79 0x7f 0x7d 0x73 0x71 0x77 0x75 0x6b 0x69 0x6f 0x6d 0x63 0x61 0x67 0x65 
			   0x9b 0x99 0x9f 0x9d 0x93 0x91 0x97 0x95 0x8b 0x89 0x8f 0x8d 0x83 0x81 0x87 0x85 
			   0xbb 0xb9 0xbf 0xbd 0xb3 0xb1 0xb7 0xb5 0xab 0xa9 0xaf 0xad 0xa3 0xa1 0xa7 0xa5 
			   0xdb 0xd9 0xdf 0xdd 0xd3 0xd1 0xd7 0xd5 0xcb 0xc9 0xcf 0xcd 0xc3 0xc1 0xc7 0xc5 
			   0xfb 0xf9 0xff 0xfd 0xf3 0xf1 0xf7 0xf5 0xeb 0xe9 0xef 0xed 0xe3 0xe1 0xe7 0xe5}


	return [lindex $xtime $number]

    
}

proc ::aes::GFMult3 {number} {

    # multliply by 2 (via GFMult2) and add the number again on the result (via XOR)
    return [expr $number ^ [GFMult2 $number]]
}

proc ::aes::GFMult09 {number} {

    # 09 is: (02*02*02) + 01
    
    return [expr [GFMult2 [GFMult2 [GFMult2 $number]]] ^ $number]


}

proc ::aes::GFMult0b {number} {

    # 0b is: (02*02*02) + 02 + 01

    return [expr [GFMult2 [GFMult2 [GFMult2 $number]]] ^ [GFMult2 $number] ^ $number]
}

proc ::aes::GFMult0d {number} {

    # 0d is: (02*02*02) + (02*02) + 01
    
    set temp [GFMult2 [GFMult2 $number]]
    return [expr [GFMult2 $temp] ^ ($temp ^ $number)]
}

proc ::aes::GFMult0e {number} {

    # 0e is: (02*02*02) + (02*02) + 02
    
    set temp [GFMult2 [GFMult2 $number]]
    return [expr [GFMult2 $temp] ^ ($temp ^ [GFMult2 $number])]

}



#------------------------------------------#
# ::aes::KeyExpansion                      #
#                                          #
# takes the initial key and expands it     #
# to get a round key for each round of aes #
#------------------------------------------#


proc ::aes::KeyExpansion keyList {

	variable expKey
	variable Nk
	variable Nr 
	variable Nb 
	
	# setting up the round constants
	set RC [list 0x00 0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80 0x1b 0x36 0x6c 0xd8 0xab 0x4d]

    array set key $keyList  ;# put the passed keyList back to an array
    
    set Ne [expr $Nb * ($Nr + 1)];# number of columns the expKey will have totally

    # the following cascaded for-construct copies the initial key
    # to the first columns of the expanded key

    for {set j 0} {$j < $Nk} {incr j} {
		for {set i 0} {$i < 4} {incr i} {
	    	set expKey($i,$j) $key($i,$j)
		}
    }
    
    # next follows the expansion of the initial key
    #
    for {set j $Nk} {$j < $Ne} {incr j} {
	if {[expr $j % $Nk] == 0} {

	    set temp [expr $expKey(0,[expr $j - $Nk]) ^ [SubFunc $expKey(1,[expr $j - 1])]]
	    set expKey(0,$j) [expr $temp ^ [lindex $RC [expr $j / $Nk]]]
	    for {set i 1} {$i < 4} {incr i} {
		set expKey($i,$j) [expr $expKey($i,[expr $j - $Nk]) ^ \
				     [SubFunc $expKey([expr ($i + 1) % 4],[expr $j - 1])]]
	    }		  

	} elseif {$Nk == 8 && [expr $j % $Nk] == 4} {
	    for {set i 0} {$i < 4} {incr i} {
		set expKey($i,$j) [expr $expKey($i,[expr $j - $Nk]) ^ \
				       [SubFunc $expKey($i,[expr $j - 1])]]
	    }

	} else {
	    for {set i 0} {$i < 4} {incr i} {
		set expKey($i,$j) [expr $expKey($i,[expr $j - $Nk]) ^ \
					    $expKey($i,[expr $j - 1])]
	    }
	    
	}
    }
    

}

#----------------------------------------------#
# ::aes::AddRoundKey                           #
#                                              #
# calculates a new state by XOR-ing the actual #
# state with the corresponding round key       #
#----------------------------------------------#

proc ::aes::AddRoundKey {round} {

    variable state
    variable expKey
    

    for {set j 0} {$j < 4} {incr j} {
		for {set i 0} {$i < 4} {incr i} {

	    	set roundKeyIndex [expr ($round * 4) + $j] ;# where to find roundKey in expKey
	    	set result [expr $state($i,$j) ^ $expKey($i,$roundKeyIndex)]
	    
	    	# make the result hexadecimal
	    	set state($i,$j) [format "%#x" $result]
		}
    }


}


#-----------------------------------------#
# ::aes::SubBytes                         #
#                                         #
# substitutes each byte of the state      #
# with bytes form the s-box (via SubFunc) #
#-----------------------------------------#

proc ::aes::SubBytes {} {

    variable state

	for {set j 0} {$j < 4} {incr j} {
		for {set i 0} {$i < 4} {incr i} {

	    	set state($i,$j) [SubFunc $state($i,$j)]

		}
    }

}

#-----------------------------------------#
# ::aes::InvSubBytes                      #
#                                         #
# the inverse of SubBytes                 #
#-----------------------------------------#

proc ::aes::InvSubBytes {} {
        
    variable state

    for {set j 0} {$j < 4} {incr j} {
	for {set i 0} {$i < 4} {incr i} {

	    set state($i,$j) [InvSubFunc $state($i,$j)]

	}
    }

}

#-------------------------------------------#
# ::aes::ShiftRows                          #
#                                           #
# shifts the rows of the state to the left, #
# row 0 by 0 bytes, row 1 by 1 byte, etc.   #
#-------------------------------------------#

proc ::aes::ShiftRows {} {

    variable state
    
    for {set i 1} {$i < 4} {incr i} {
		for {set k 0} {$k < $i} {incr k} {
	    	set temp $state($i,0)
	    	for {set j 0} {$j < 3} {incr j} {
				set state($i,$j) $state($i,[expr $j + 1])
	    	}	
	    	set state($i,3) $temp
		}
    }
}

#-------------------------------------------#
# ::aes::InvShiftRows                       #
#                                           #
# the inverse of ShiftRows                  #
#-------------------------------------------#


proc ::aes::InvShiftRows {} {

    variable state

    for {set i 1} {$i < 4} {incr i} {
		for {set k 0} {$k < $i} {incr k} {
	    	set temp $state($i,3)
	    	for {set j 3} {$j > 0} {incr j -1} {
				set state($i,$j) $state($i,[expr $j - 1])
	    	}
	    	set state($i,0) $temp
		}
    }
}

#-------------------------------------------#
# ::aes::MixColumns                         #
#                                           #
# the actual state is multiplicated with a  #
# fixed matrix, given by the standard       #
#-------------------------------------------#

proc ::aes::MixColumns {} {

    variable state

    #copy state into a temp array
    for {set i 0} {$i < 4} {incr i} {
	for {set j 0} {$j < 4} {incr j} {
	    set tempState($i,$j) $state($i,$j)
	}
    }

    #calculate the new state (with matrix multiplication)
    for {set j 0} {$j < 4} {incr j} {
	
	set state(0,$j) [expr [GFMult2 $tempState(0,$j)] ^ \
			     [GFMult3 $tempState(1,$j)] ^ \
			     $tempState(2,$j) ^ \
			     $tempState(3,$j)]

	set state(1,$j) [expr $tempState(0,$j) ^ \
			     [GFMult2 $tempState(1,$j)] ^ \
			     [GFMult3 $tempState(2,$j)] ^ \
			     $tempState(3,$j)]

	set state(2,$j) [expr $tempState(0,$j) ^ \
			     $tempState(1,$j) ^ \
			     [GFMult2 $tempState(2,$j)] ^ \
			     [GFMult3 $tempState(3,$j)]]

	set state(3,$j) [expr [GFMult3 $tempState(0,$j)] ^ \
			     $tempState(1,$j) ^ \
			     $tempState(2,$j) ^ \
			     [GFMult2 $tempState(3,$j)]]
    }

}

#-------------------------------------------#
# ::aes::InvMixColumns                      #
#                                           #
# the inverse of MixColumns                 #
#-------------------------------------------#

proc ::aes::InvMixColumns {} {

    variable state

    #copy state into a temp array
    for {set i 0} {$i < 4} {incr i} {
	for {set j 0} {$j < 4} {incr j} {
	    set tempState($i,$j) $state($i,$j)
	}
    }

    #calculate the new state (with matrix multiplication)
    for {set j 0} {$j < 4} {incr j} {
	
	set state(0,$j) [expr [GFMult0e $tempState(0,$j)] ^ \
			     [GFMult0b $tempState(1,$j)] ^ \
			     [GFMult0d $tempState(2,$j)] ^ \
			     [GFMult09 $tempState(3,$j)]]

	set state(1,$j) [expr [GFMult09 $tempState(0,$j)] ^ \
			     [GFMult0e $tempState(1,$j)] ^ \
			     [GFMult0b $tempState(2,$j)] ^ \
			     [GFMult0d $tempState(3,$j)]]

	set state(2,$j) [expr [GFMult0d $tempState(0,$j)] ^ \
			     [GFMult09 $tempState(1,$j)] ^ \
			     [GFMult0e $tempState(2,$j)] ^ \
			     [GFMult0b $tempState(3,$j)]]

	set state(3,$j) [expr [GFMult0b $tempState(0,$j)] ^ \
			     [GFMult0d $tempState(1,$j)] ^ \
			     [GFMult09 $tempState(2,$j)] ^ \
			     [GFMult0e $tempState(3,$j)]]
    }
    
} 
    


#----------------------------------------#
# ::aes::start                           #
#                                        #
# this is the start-procedure containing #
# the main algorithm for en-/decryption. #
#----------------------------------------#

proc ::aes::start {mode key text} {
	
	variable keyArray
	variable Nr
	variable state
	
	init mode $key $text

	KeyExpansion [array get keyArray];# needs to convert the array to a list for passing


	switch -- $mode {

   		e {

			#
			# encryption
			#	

	
			AddRoundKey 0 ;# initial round 


			for {set i 1} {$i < $Nr} {incr i} {
    			SubBytes
    			ShiftRows
    			MixColumns
    			AddRoundKey $i
			}
	
			#final round
	
	
			SubBytes
			ShiftRows
			AddRoundKey $Nr
	
			
			# put final state into string and return it
			for {set j 0} {$j < 4} {incr j} {
	    		for {set i 0} {$i < 4} {incr i} {
					lappend cipherlist  [format "%#04x" $state($i,$j)]
    			}
			}
	
			foreach value $cipherlist {
    			append ciphertext [format "%02x" $value]
			}
			return $ciphertext
		}

    	d {

			#
			# decryption
			#
		
			#final round first

			AddRoundKey $Nr
			InvShiftRows
			InvSubBytes

			# now backwards through the rounds
			for {set i [expr $Nr - 1]} {$i > 0} {incr i -1} {
    
	    		AddRoundKey $i
	    		InvMixColumns
	    		InvShiftRows
	    		InvSubBytes

			}

			AddRoundKey 0 

			# put final state into string and return it 
			for {set j 0} {$j < 4} {incr j} {
	    		for {set i 0} {$i < 4} {incr i} {
					append plaintext  [format "%02x" $state($i,$j)]
	    		}
			}
			return $plaintext
	
		}
	}
    
}


