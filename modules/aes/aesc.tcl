# aesc.tcl -

# A critcl C implementation of AES
#
# Copyright (C) 2022-2024 Nathan Coulter <org.tcl-lang.core.tcllib@pooryorick.com> 
#	ethereum 0x0b5049C148b00a216B29641ab16953b6060Ef8A6

# See the file "license_fsul.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package require Tcl 9
package require critcl
# @sak notprovided aesc
package provide aesc 0.2.0

namespace eval ::aes {
	critcl::tcl 9 
	critcl::ccode {
		#include <stdint.h>
		#include <string.h>

		#define AES_IVSIZE 16


		static Tcl_FreeInternalRepProc	AesFreeInternalRep;
		static Tcl_UpdateStringProc		AesUpdateStringRep;

		typedef enum aes_mode {CBC, ECB} aes_mode;
		char *aes_mode_strings[] = {"cbc" ,"ecb"};

		static Tcl_ObjType aesObjType =  {
			"aes",
			AesFreeInternalRep,
			NULL,
			AesUpdateStringRep,
			NULL,
			0, NULL
		};

		static Tcl_ObjType *aesObjTypePtr = &aesObjType;

		typedef struct aes_ctxt {
			aes_mode mode;
			int Nk;	/* number of 32-bit segments in the key */
			int Nr;	/* number of rounds (depends on key length) */
			int Nb; /* columns of the text-block, is always 4 in AES */
			uint_fast32_t I[4];
			uint_fast32_t *WPtr;
		} aes_ctxt;

		int aes_addRoundKey(Tcl_Interp *interp ,int round 
			,int Nb ,uint_fast32_t data[4] ,uint_fast32_t WPtr[]);
		int aes_expandkey(aes_ctxt* ctxt ,char *keystring); 
		int aes_decrypt(Tcl_Interp *interp ,int n ,unsigned char *bytes
			,int len ,uint_fast32_t* iv ,uint_fast32_t WPtr[] ,aes_mode);
		int aes_decryptBlock(Tcl_Interp *interp ,int n
			,unsigned char *bytes ,uint_fast32_t iv[4] ,Tcl_Size i, uint_fast32_t WPtr[]
			,aes_mode mode);
		aes_ctxt* aes_fetchCtxt(Tcl_Interp *interp ,Tcl_Obj *ctxtObjPtr);
		int aes_prepare(Tcl_Interp *interp ,aes_ctxt *ctxtPtr ,Tcl_Obj *data
			,unsigned char **bytes , Tcl_Size *len , Tcl_Obj **resObjPtr);
		void aes_clamp32(uint_fast32_t data[4]);
		int aes_encryptBlock(Tcl_Interp *interp
			,unsigned char *bytes ,aes_ctxt *ctxtPtr, Tcl_Size i
			,uint_fast32_t WPtr[] ,int n ,aes_mode moden);
		uint_fast32_t aes_GFMult2(uint_fast32_t number);
		uint_fast32_t aes_GFMult3(uint_fast32_t number);
		uint_fast32_t aes_GFMult09(uint_fast32_t number);
		uint_fast32_t aes_GFMult0b(uint_fast32_t number);
		uint_fast32_t aes_GFMult0d(uint_fast32_t number);
		uint_fast32_t aes_GFMult0e(uint_fast32_t number);

		void aes_invMixColumns(uint_fast32_t data[4]);
		void aes_invShiftRows(uint_fast32_t data[4]);
		void aes_invSubBytes(uint_fast32_t data[4]);
		uint_fast32_t aes_invSubWord(uint_fast32_t word);
		void aes_mixColumns(uint_fast32_t data[4]);
		uint_fast32_t aes_RotWord (uint_fast32_t w);
		void aes_shiftRows(uint_fast32_t data[4]);
		void aes_subBytes(uint_fast32_t data[4]);
		uint_fast32_t aes_SubWord(uint_fast32_t word);

		uint_fast8_t sbox[] = {
			 0x63 ,0x7c ,0x77 ,0x7b ,0xf2 ,0x6b ,0x6f ,0xc5 ,0x30 ,0x01 ,0x67 ,0x2b ,0xfe ,0xd7 ,0xab ,0x76
			,0xca ,0x82 ,0xc9 ,0x7d ,0xfa ,0x59 ,0x47 ,0xf0 ,0xad ,0xd4 ,0xa2 ,0xaf ,0x9c ,0xa4 ,0x72 ,0xc0
			,0xb7 ,0xfd ,0x93 ,0x26 ,0x36 ,0x3f ,0xf7 ,0xcc ,0x34 ,0xa5 ,0xe5 ,0xf1 ,0x71 ,0xd8 ,0x31 ,0x15
			,0x04 ,0xc7 ,0x23 ,0xc3 ,0x18 ,0x96 ,0x05 ,0x9a ,0x07 ,0x12 ,0x80 ,0xe2 ,0xeb ,0x27 ,0xb2 ,0x75
			,0x09 ,0x83 ,0x2c ,0x1a ,0x1b ,0x6e ,0x5a ,0xa0 ,0x52 ,0x3b ,0xd6 ,0xb3 ,0x29 ,0xe3 ,0x2f ,0x84
			,0x53 ,0xd1 ,0x00 ,0xed ,0x20 ,0xfc ,0xb1 ,0x5b ,0x6a ,0xcb ,0xbe ,0x39 ,0x4a ,0x4c ,0x58 ,0xcf
			,0xd0 ,0xef ,0xaa ,0xfb ,0x43 ,0x4d ,0x33 ,0x85 ,0x45 ,0xf9 ,0x02 ,0x7f ,0x50 ,0x3c ,0x9f ,0xa8
			,0x51 ,0xa3 ,0x40 ,0x8f ,0x92 ,0x9d ,0x38 ,0xf5 ,0xbc ,0xb6 ,0xda ,0x21 ,0x10 ,0xff ,0xf3 ,0xd2
			,0xcd ,0x0c ,0x13 ,0xec ,0x5f ,0x97 ,0x44 ,0x17 ,0xc4 ,0xa7 ,0x7e ,0x3d ,0x64 ,0x5d ,0x19 ,0x73
			,0x60 ,0x81 ,0x4f ,0xdc ,0x22 ,0x2a ,0x90 ,0x88 ,0x46 ,0xee ,0xb8 ,0x14 ,0xde ,0x5e ,0x0b ,0xdb
			,0xe0 ,0x32 ,0x3a ,0x0a ,0x49 ,0x06 ,0x24 ,0x5c ,0xc2 ,0xd3 ,0xac ,0x62 ,0x91 ,0x95 ,0xe4 ,0x79
			,0xe7 ,0xc8 ,0x37 ,0x6d ,0x8d ,0xd5 ,0x4e ,0xa9 ,0x6c ,0x56 ,0xf4 ,0xea ,0x65 ,0x7a ,0xae ,0x08
			,0xba ,0x78 ,0x25 ,0x2e ,0x1c ,0xa6 ,0xb4 ,0xc6 ,0xe8 ,0xdd ,0x74 ,0x1f ,0x4b ,0xbd ,0x8b ,0x8a
			,0x70 ,0x3e ,0xb5 ,0x66 ,0x48 ,0x03 ,0xf6 ,0x0e ,0x61 ,0x35 ,0x57 ,0xb9 ,0x86 ,0xc1 ,0x1d ,0x9e
			,0xe1 ,0xf8 ,0x98 ,0x11 ,0x69 ,0xd9 ,0x8e ,0x94 ,0x9b ,0x1e ,0x87 ,0xe9 ,0xce ,0x55 ,0x28 ,0xdf
			,0x8c ,0xa1 ,0x89 ,0x0d ,0xbf ,0xe6 ,0x42 ,0x68 ,0x41 ,0x99 ,0x2d ,0x0f ,0xb0 ,0x54 ,0xbb ,0x16
		};

		uint_fast8_t xobs[]  = {
			 0x52 ,0x09 ,0x6a ,0xd5 ,0x30 ,0x36 ,0xa5 ,0x38 ,0xbf ,0x40 ,0xa3 ,0x9e ,0x81 ,0xf3 ,0xd7 ,0xfb
			,0x7c ,0xe3 ,0x39 ,0x82 ,0x9b ,0x2f ,0xff ,0x87 ,0x34 ,0x8e ,0x43 ,0x44 ,0xc4 ,0xde ,0xe9 ,0xcb
			,0x54 ,0x7b ,0x94 ,0x32 ,0xa6 ,0xc2 ,0x23 ,0x3d ,0xee ,0x4c ,0x95 ,0x0b ,0x42 ,0xfa ,0xc3 ,0x4e
			,0x08 ,0x2e ,0xa1 ,0x66 ,0x28 ,0xd9 ,0x24 ,0xb2 ,0x76 ,0x5b ,0xa2 ,0x49 ,0x6d ,0x8b ,0xd1 ,0x25
			,0x72 ,0xf8 ,0xf6 ,0x64 ,0x86 ,0x68 ,0x98 ,0x16 ,0xd4 ,0xa4 ,0x5c ,0xcc ,0x5d ,0x65 ,0xb6 ,0x92
			,0x6c ,0x70 ,0x48 ,0x50 ,0xfd ,0xed ,0xb9 ,0xda ,0x5e ,0x15 ,0x46 ,0x57 ,0xa7 ,0x8d ,0x9d ,0x84
			,0x90 ,0xd8 ,0xab ,0x00 ,0x8c ,0xbc ,0xd3 ,0x0a ,0xf7 ,0xe4 ,0x58 ,0x05 ,0xb8 ,0xb3 ,0x45 ,0x06
			,0xd0 ,0x2c ,0x1e ,0x8f ,0xca ,0x3f ,0x0f ,0x02 ,0xc1 ,0xaf ,0xbd ,0x03 ,0x01 ,0x13 ,0x8a ,0x6b
			,0x3a ,0x91 ,0x11 ,0x41 ,0x4f ,0x67 ,0xdc ,0xea ,0x97 ,0xf2 ,0xcf ,0xce ,0xf0 ,0xb4 ,0xe6 ,0x73
			,0x96 ,0xac ,0x74 ,0x22 ,0xe7 ,0xad ,0x35 ,0x85 ,0xe2 ,0xf9 ,0x37 ,0xe8 ,0x1c ,0x75 ,0xdf ,0x6e
			,0x47 ,0xf1 ,0x1a ,0x71 ,0x1d ,0x29 ,0xc5 ,0x89 ,0x6f ,0xb7 ,0x62 ,0x0e ,0xaa ,0x18 ,0xbe ,0x1b
			,0xfc ,0x56 ,0x3e ,0x4b ,0xc6 ,0xd2 ,0x79 ,0x20 ,0x9a ,0xdb ,0xc0 ,0xfe ,0x78 ,0xcd ,0x5a ,0xf4
			,0x1f ,0xdd ,0xa8 ,0x33 ,0x88 ,0x07 ,0xc7 ,0x31 ,0xb1 ,0x12 ,0x10 ,0x59 ,0x27 ,0x80 ,0xec ,0x5f
			,0x60 ,0x51 ,0x7f ,0xa9 ,0x19 ,0xb5 ,0x4a ,0x0d ,0x2d ,0xe5 ,0x7a ,0x9f ,0x93 ,0xc9 ,0x9c ,0xef
			,0xa0 ,0xe0 ,0x3b ,0x4d ,0xae ,0x2a ,0xf5 ,0xb0 ,0xc8 ,0xeb ,0xbb ,0x3c ,0x83 ,0x53 ,0x99 ,0x61
			,0x17 ,0x2b ,0x04 ,0x7e ,0xba ,0x77 ,0xd6 ,0x26 ,0xe1 ,0x69 ,0x14 ,0x63 ,0x55 ,0x21 ,0x0c ,0x7d
		};


		/* this is a tabular representation of xtime (multiplication by 2)
		 * it is used instead of calculation to prevent timing attacks */

		uint8_t xtime[] = {
			0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
			0x20, 0x22, 0x24, 0x26, 0x28, 0x2a, 0x2c, 0x2e, 0x30, 0x32, 0x34, 0x36, 0x38, 0x3a, 0x3c, 0x3e, 
			0x40, 0x42, 0x44, 0x46, 0x48, 0x4a, 0x4c, 0x4e, 0x50, 0x52, 0x54, 0x56, 0x58, 0x5a, 0x5c, 0x5e,
			0x60, 0x62, 0x64, 0x66, 0x68, 0x6a, 0x6c, 0x6e, 0x70, 0x72, 0x74, 0x76, 0x78, 0x7a, 0x7c, 0x7e, 
			0x80, 0x82, 0x84, 0x86, 0x88, 0x8a, 0x8c, 0x8e, 0x90, 0x92, 0x94, 0x96, 0x98, 0x9a, 0x9c, 0x9e, 
			0xa0, 0xa2, 0xa4, 0xa6, 0xa8, 0xaa, 0xac, 0xae, 0xb0, 0xb2, 0xb4, 0xb6, 0xb8, 0xba, 0xbc, 0xbe, 
			0xc0, 0xc2, 0xc4, 0xc6, 0xc8, 0xca, 0xcc, 0xce, 0xd0, 0xd2, 0xd4, 0xd6, 0xd8, 0xda, 0xdc, 0xde, 
			0xe0, 0xe2, 0xe4, 0xe6, 0xe8, 0xea, 0xec, 0xee, 0xf0, 0xf2, 0xf4, 0xf6, 0xf8, 0xfa, 0xfc, 0xfe, 
			0x1b, 0x19, 0x1f, 0x1d, 0x13, 0x11, 0x17, 0x15, 0x0b, 0x09, 0x0f, 0x0d, 0x03, 0x01, 0x07, 0x05, 
			0x3b, 0x39, 0x3f, 0x3d, 0x33, 0x31, 0x37, 0x35, 0x2b, 0x29, 0x2f, 0x2d, 0x23, 0x21, 0x27, 0x25, 
			0x5b, 0x59, 0x5f, 0x5d, 0x53, 0x51, 0x57, 0x55, 0x4b, 0x49, 0x4f, 0x4d, 0x43, 0x41, 0x47, 0x45, 
			0x7b, 0x79, 0x7f, 0x7d, 0x73, 0x71, 0x77, 0x75, 0x6b, 0x69, 0x6f, 0x6d, 0x63, 0x61, 0x67, 0x65, 
			0x9b, 0x99, 0x9f, 0x9d, 0x93, 0x91, 0x97, 0x95, 0x8b, 0x89, 0x8f, 0x8d, 0x83, 0x81, 0x87, 0x85, 
			0xbb, 0xb9, 0xbf, 0xbd, 0xb3, 0xb1, 0xb7, 0xb5, 0xab, 0xa9, 0xaf, 0xad, 0xa3, 0xa1, 0xa7, 0xa5, 
			0xdb, 0xd9, 0xdf, 0xdd, 0xd3, 0xd1, 0xd7, 0xd5, 0xcb, 0xc9, 0xcf, 0xcd, 0xc3, 0xc1, 0xc7, 0xc5, 
			0xfb, 0xf9, 0xff, 0xfd, 0xf3, 0xf1, 0xf7, 0xf5, 0xeb, 0xe9, 0xef, 0xed, 0xe3, 0xe1, 0xe7, 0xe5
		};

		uint32_t Rcon[] = {
			0x00000000 ,0x01000000 ,0x02000000 ,0x04000000 ,0x08000000
			,0x10000000 ,0x20000000 ,0x40000000 ,0x80000000 ,0x1b000000
			,0x36000000 ,0x6c000000 ,0xd8000000 ,0xab000000 ,0x4d000000
		};


		static void
		AesFreeInternalRep(
			Tcl_Obj *objPtr
		) {
			aes_ctxt *ctxtPtr = aes_fetchCtxt(NULL ,objPtr);
			if (ctxtPtr->WPtr) {
				Tcl_Free(ctxtPtr->WPtr);
			}
			Tcl_Free(ctxtPtr);
			return;
		}


		static void
		AesUpdateStringRep(
			Tcl_Obj *objPtr
		) {
			aes_ctxt *ctxtPtr = aes_fetchCtxt(NULL ,objPtr);
			char *tmpbytes = objPtr->bytes;
			Tcl_Size tmplength = objPtr->length;
			Tcl_Obj *tmpPtr = Tcl_ObjPrintf("aes context %p" ,ctxtPtr);
			objPtr->bytes = tmpPtr->bytes;
			objPtr->length = tmpPtr->length;
			tmpPtr->bytes = tmpbytes; 
			tmpPtr->length = tmplength;
			Tcl_DecrRefCount(tmpPtr);
			return;
		}


		int aes_addRoundKey(Tcl_Interp * interp ,int round
			,int Nb, uint_fast32_t data[4] ,uint_fast32_t WPtr[]) {
			Tcl_Obj *item;
			int i ,n ,status ,w;
			uint_fast32_t uword;
			n = round * Nb;

			for (i = 0 ;i < Nb ;i++) {
				uword = WPtr[n];
				data[i] = data[i] ^ uword;
				n++;
			}
			return TCL_OK;
		}


		void aes_clamp32(uint_fast32_t data[4]) {
			/* Force all elements into 32bit range. */
			data[0] = data[0] & 0xffffffff;
			data[1] = data[1] & 0xffffffff;
			data[2] = data[2] & 0xffffffff;
			data[3] = data[3] & 0xffffffff;
			return;
		}


		int aes_decrypt(Tcl_Interp *interp ,int n ,unsigned char *bytes
			,int len ,uint_fast32_t* iv ,uint_fast32_t WPtr[] ,aes_mode moden) {
			int i ,status;
			for (i = 0 ;i < len ;i+= 16) {
				status = aes_decryptBlock(interp ,n ,bytes ,iv ,i ,WPtr ,moden);
				if (status != TCL_OK) {
					return TCL_ERROR;
				}
			}
			return TCL_OK;
		}


		int aes_decryptBlock(Tcl_Interp *interp, int n
			, unsigned char *bytes ,uint_fast32_t iv[4] ,Tcl_Size i
			,uint_fast32_t WPtr[] ,aes_mode mode) {

			Tcl_Obj *formattedPtr;
			int status;
			Tcl_Size k = i;
			uint_fast8_t j;
			uint_fast32_t data[4] ,newdata[4], newiv[4];

			for (j = 0 ;j < 4 ;j++) {
				newiv[j] = data[j] =  bytes[k++] << 24 | bytes[k++] << 16
					| bytes[k++] << 8 | bytes[k++];
			}
			status = aes_addRoundKey(interp ,n ,4 ,data ,WPtr);
			if (status != TCL_OK) {
				return status;
			};
			for (n-- ;n > 0 ;n--) {
				aes_invShiftRows(data);
				aes_invSubBytes(data);
				status = aes_addRoundKey(interp ,n ,4 ,data ,WPtr);
				if (status != TCL_OK) {
					return status;
				}
				aes_invMixColumns(data);
			}
			aes_invShiftRows(data);
			aes_invSubBytes(data);
			status = aes_addRoundKey(interp ,n ,4 ,data ,WPtr);
			if (status != TCL_OK) {
				return status;
			}

			switch (mode) {
				case CBC:
					data[0] =(data[0] ^ iv[0]) & 0xffffffff;
					data[1] =(data[1] ^ iv[1]) & 0xffffffff;
					data[2] =(data[2] ^ iv[2]) & 0xffffffff;
					data[3] =(data[3] ^ iv[3]) & 0xffffffff;
					break;
				default:
					aes_clamp32(data);
					break;
			}

			k = i;
			for (j = 0 ;j < 4 ;j++) {
				bytes[k++] = data[j] >> 24 & 255;
				bytes[k++] = data[j] >> 16 & 255;
				bytes[k++] = data[j] >> 8 & 255;
				bytes[k++] = data[j] & 255;
			}
			memcpy(iv ,newiv ,sizeof(newiv));
			return TCL_OK;
		}


		int aes_encryptBlock(Tcl_Interp *interp ,unsigned char *bytes
			,aes_ctxt *ctxtPtr, Tcl_Size i ,uint_fast32_t WPtr[] ,int n
			,aes_mode moden) {

			int status;
			Tcl_Size k = i;
			uint8_t j;
			uint_fast32_t data[4] ,newiv[4];
			uint_fast32_t *IPtr = ctxtPtr->I;

			for (j = 0 ;j < 4 ;j++) {
				newiv[j] = data[j] =  bytes[k++] << 24 | bytes[k++] << 16
					| bytes[k++] << 8 | bytes[k++];
			}

			switch (moden) {
				case CBC:
					data[0] = data[0] ^ IPtr[0];
					data[1] = data[1] ^ IPtr[1];
					data[2] = data[2] ^ IPtr[2];
					data[3] = data[3] ^ IPtr[3];
					break;
			}

			status = aes_addRoundKey(interp ,0 ,4 ,data ,WPtr);

			if (status != TCL_OK) {
				return status;
			};
			for (j = 1 ;j < n ;j++) {
				aes_subBytes(data);
				aes_shiftRows(data);
				aes_mixColumns(data);
				aes_addRoundKey(interp ,j ,4 ,data ,WPtr);
			}
			aes_subBytes(data);
			aes_shiftRows(data);
			aes_addRoundKey(interp ,j ,4 ,data ,WPtr);

			/* Bug 2993029:
			* Force all elements of data into the 32bit range.
			* Loop unrolled
			*/
			aes_clamp32(data);
			k = i;
			for (j = 0 ;j < 4 ;j++) {
				bytes[k++] = data[j] >> 24 & 255;
				bytes[k++] = data[j] >> 16 & 255;
				bytes[k++] = data[j] >> 8 & 255;
				bytes[k++] = data[j] & 255;
			}
			memcpy(IPtr ,data ,sizeof(data));
			return TCL_OK;
		}


		uint_fast32_t aes_GFMult2(uint_fast32_t number) {
			return xtime[number];
		}


		uint_fast32_t aes_GFMult3(uint_fast32_t number) {
			/* multliply by 2 (via aes_GFMult2) and add the number again on
			 * the result (via XOR) */
			return number ^ aes_GFMult2(number);
		}


		uint_fast32_t aes_GFMult09(uint_fast32_t number) {
			/* 09 is: (02*02*02) + 01 */
			return aes_GFMult2(aes_GFMult2(aes_GFMult2(number))) ^ number;
		}


		uint_fast32_t aes_GFMult0b(uint_fast32_t number) {
			/*
			0b is: (02*02*02) + 02 + 01
			*/
			return aes_GFMult09(number) ^ aes_GFMult2(number);
		}


		uint_fast32_t aes_GFMult0d(uint_fast32_t number) {
			/* 0d is: (02*02*02) + (02*02) + 01 */
			uint_fast32_t temp;
			temp = aes_GFMult2(aes_GFMult2(number));
			return aes_GFMult2(temp) ^ (temp ^ number);
		}


		uint_fast32_t aes_GFMult0e(uint_fast32_t number) {
			/* 0e is: (02*02*02) + (02*02) + 02 */
			uint_fast32_t temp;
			temp = aes_GFMult2(aes_GFMult2(number));
			return aes_GFMult2(temp) ^ (temp ^ aes_GFMult2(number));
		}


		int aes_expandkey(aes_ctxt* ctxtPtr ,char *keystring) {
			uint_fast32_t mask = 0xffffffff;
			uint_fast32_t rc ,sub ,temp;
			uint_fast32_t h ,i ,j ,max;
			max = ctxtPtr->Nb * (ctxtPtr->Nr + 1);
			uint_fast32_t *W = Tcl_Alloc(sizeof(uint_fast32_t) * (ctxtPtr->Nk + max));
			ctxtPtr->WPtr = W;

			for (i = 0 ,j = 0; i < ctxtPtr->Nk; i++, j+=4) {
				int chanmode;
				temp = (uint8_t)keystring[j] << 24;
				temp += (uint8_t)keystring[j+1] << 16;
				temp += (uint8_t)keystring[j+2] << 8;
				temp += (uint8_t)keystring[j+3];
				W[i] = temp;
			}

			h= i - 1;
			j = 0;
			for (;i < max; i+= 1 ,h += 1 ,j += 1) {
				temp = W[h];
				if ((i % ctxtPtr->Nk) == 0) {
					sub = aes_SubWord(aes_RotWord(temp));
					rc = Rcon[i/ctxtPtr->Nk];
					temp = sub ^ rc;
				} else if (ctxtPtr->Nk > 6 && (i % ctxtPtr->Nk) == 4) {
					temp = aes_SubWord(temp);
				}
				W[i] = W[j] ^ temp;
			}
			return TCL_OK;
		}


		aes_ctxt* aes_fetchCtxt(Tcl_Interp *interp ,Tcl_Obj *ctxtObjPtr) {
			aes_ctxt *ctxtPtr;
			Tcl_ObjInternalRep *ir = Tcl_FetchInternalRep(ctxtObjPtr ,aesObjTypePtr);
			if (!ir) {
				if (interp) {
					Tcl_SetObjResult(interp, Tcl_NewStringObj(
						"value does not provide an aes context", -1));
				}
				return NULL;
			}
			ctxtPtr = ir->twoPtrValue.ptr1;
			return ctxtPtr;
		}



		void aes_invMixColumns(uint_fast32_t data[4]) {
			uint_fast8_t i ,r0 ,r1 ,r2 ,r3 ,s0 ,s1 ,s2 ,s3;
			for (i=0 ;i < 4 ;i++) {
				r0 = (data[i] >> 24) & 255;
				r1 = (data[i] >> 16) & 255;
				r2 = (data[i] >> 8 ) & 255;
				r3 = data[i]         & 255;

				s0 = aes_GFMult0e(r0) ^ aes_GFMult0b(r1) ^ aes_GFMult0d(r2)
					^ aes_GFMult09(r3);
				s1 = aes_GFMult09(r0) ^ aes_GFMult0e(r1) ^ aes_GFMult0b(r2)
					^ aes_GFMult0d(r3);
				s2 = aes_GFMult0d(r0) ^ aes_GFMult09(r1) ^ aes_GFMult0e(r2)
					^ aes_GFMult0b(r3);
				s3 = aes_GFMult0b(r0) ^ aes_GFMult0d(r1) ^ aes_GFMult09(r2)
					^ aes_GFMult0e(r3);
				data[i] = (s0 << 24) | (s1 << 16) | (s2 << 8) | s3;
			}
			return;
		}


		void aes_invShiftRows(uint_fast32_t data[4]) {
			uint_fast8_t n0 ,n1 ,n2 ,n3;
			uint_fast32_t newdata[4];
			for (n0 = 0 ;n0 < 4 ;n0++) {
				n1 = (n0 + 1) % 4;
				n2 = (n0 + 2) % 4;
				n3 = (n0 + 3) % 4;
				newdata[n0] = 
					  (data[n0] & 0xff000000)
					| (data[n3] & 0x00ff0000)
					| (data[n2] & 0x0000ff00)
					| (data[n1] & 0x000000ff)
				;
			}
			memcpy(data ,newdata ,sizeof(newdata));
			return;
		}


		void aes_invSubBytes(uint_fast32_t data[4]) {
			data[0] = aes_invSubWord(data[0]);
			data[1] = aes_invSubWord(data[1]);
			data[2] = aes_invSubWord(data[2]);
			data[3] = aes_invSubWord(data[3]);
			return;
		}


		uint_fast32_t aes_invSubWord(uint_fast32_t word) {
			uint8_t s3, s2 ,s1 ,s0;
			s3 = xobs[(word >> 24) & 255];
			s2 = xobs[(word >> 16) & 255];
			s1 = xobs[(word >> 8) & 255];
			s0 = xobs[word  & 255];
			return (s3 << 24) | (s2 << 16) | (s1 << 8) | s0;
		}


		void aes_mixColumns(uint_fast32_t data[4]) {
			uint_fast8_t i ,r0 ,r1 ,r2 ,r3 ,s0 ,s1 ,s2 ,s3;
			for (i = 0 ;i < 4; i++) {
				r0 = (data[i] >> 24) & 255;
				r1 = (data[i] >> 16) & 255;
				r2 = (data[i] >> 8 ) & 255;
				r3 = data[i]        & 255;

				s0 = aes_GFMult2(r0) ^ aes_GFMult3(r1) ^ r2 ^ r3;
				s1 = r0 ^ aes_GFMult2(r1) ^ aes_GFMult3(r2) ^ r3;
				s2 = r0 ^ r1 ^ aes_GFMult2(r2) ^ aes_GFMult3(r3);
				s3 = aes_GFMult3(r0) ^ r1 ^ r2 ^ aes_GFMult2(r3);
				data[i] = (s0 << 24) | (s1 << 16) | (s2 << 8) | s3;
			}
			return;
		}


		int aes_prepare(Tcl_Interp *interp ,aes_ctxt *ctxtPtr, Tcl_Obj *dataPtr
			,unsigned char **bytes ,Tcl_Size *lenPtr ,Tcl_Obj **resObjPtr) {

			int i ,owned = 0, status = TCL_OK;

			if (Tcl_IsShared(dataPtr)) {
				*resObjPtr = Tcl_DuplicateObj(dataPtr);
				owned = 1;
			} else {
				*resObjPtr = dataPtr;
			}

			*bytes = Tcl_GetBytesFromObj(interp ,*resObjPtr, lenPtr);
			if (bytes == NULL) {
				Tcl_SetObjResult(interp ,Tcl_NewStringObj(
					"data must not include characters with\
						a code point greater than 255", -1));
				status = TCL_ERROR;
				goto failure;
			}
			if (*lenPtr % 16 != 0) {
				Tcl_SetObjResult(interp ,Tcl_NewStringObj(
					"invalid block size: AES requires 16 byte blocks", -1));
				status =  TCL_ERROR;
				goto failure;
			}

			goto success;
			failure:
				if (owned) {
					Tcl_DecrRefCount(*resObjPtr);
				}
				*resObjPtr = NULL;
			success:
				return status;
		}


		uint_fast32_t aes_RotWord (uint_fast32_t w) {
			return ((w << 8) | ((w >> 24) & 0xff)) & 0xffffffff;
		}


		void aes_shiftRows(uint_fast32_t data[4]) {
			uint_fast8_t n0 ,n1 ,n2 ,n3;
			uint_fast32_t newdata[4];
			for (n0 = 0 ;n0 < 4 ;n0++) {
				n1 = (n0 + 1) % 4;
				n2 = (n0 + 2) % 4;
				n3 = (n0 + 3) % 4;
				newdata[n0] = 
					  (data[n0] & 0xff000000)
					| (data[n1] & 0x00ff0000)
					| (data[n2] & 0x0000ff00)
					| (data[n3] & 0x000000ff);
			}
			memcpy(data ,newdata ,sizeof(newdata));
			return;
		}


		void aes_subBytes(uint_fast32_t data[4]) {
			data[0] = aes_SubWord(data[0]);
			data[1] = aes_SubWord(data[1]);
			data[2] = aes_SubWord(data[2]);
			data[3] = aes_SubWord(data[3]);
			return;
		}


		uint_fast32_t aes_SubWord(uint_fast32_t word) {
			uint_fast32_t s0 ,s1 ,s2 ,s3;
			s3 = sbox[(word >> 24) & 255];
			s2 = sbox[(word >> 16) & 255];
			s1 = sbox[(word >> 8) & 255];
			s0 = sbox[word & 255];
			return (s3 << 24) | (s2 << 16) | (s1 << 8) | s0;
		}

	}


    critcl::cproc EncryptAccelerated {
		Tcl_Interp* interp Tcl_Obj* handle Tcl_Obj* data
	} ok {
		unsigned char *bytes;
		int status = TCL_OK;
		Tcl_Size i, len;
		Tcl_Obj *resObjPtr;
		aes_ctxt *ctxtPtr = aes_fetchCtxt(interp , handle);
		if (!ctxtPtr) {
			return TCL_ERROR;
		}
		status = aes_prepare(interp ,ctxtPtr ,data ,&bytes ,&len ,&resObjPtr);
		if (status != TCL_OK) {
			return status;
		}
		for (i = 0 ;i < len ;i+= 16) {
			status = aes_encryptBlock(
				interp ,bytes ,ctxtPtr ,i ,ctxtPtr->WPtr ,ctxtPtr->Nr ,ctxtPtr->mode);
			if (status != TCL_OK) {
				goto failure;
			}
		}
		goto success;
		failure:
			Tcl_BounceRefCount(resObjPtr);
			return status;
		success:
			Tcl_SetByteArrayObj(resObjPtr ,bytes ,len);
			Tcl_SetObjResult(interp ,resObjPtr);
			return TCL_OK;
	}


    critcl::cproc DecryptAccelerated {
		Tcl_Interp* interp Tcl_Obj* handle Tcl_Obj* data
	} ok {
		char *modePtr;
		unsigned char *bytes;
		int j, n,status = TCL_OK;
		Tcl_Size i, len;
		uint_fast32_t uword ,*iv;
		Tcl_Obj *resObjPtr ,*itemPtr ,*listPtr ,*MPtr;
		aes_ctxt *ctxtPtr;
		static Tcl_Obj *IName;
		ctxtPtr = aes_fetchCtxt(interp , handle);
		if (!ctxtPtr) {
			return TCL_ERROR;
		}
		iv = ctxtPtr->I;

		status = aes_prepare(interp ,ctxtPtr ,data ,&bytes ,&len ,&resObjPtr);
		if (status != TCL_OK) {
			goto failure2;
		}

		aes_decrypt(interp ,ctxtPtr->Nr ,bytes ,len ,ctxtPtr->I ,ctxtPtr->WPtr
			,ctxtPtr->mode);

		Tcl_SetObjResult(interp ,resObjPtr);
		goto success;
		failure:
			Tcl_DecrRefCount(resObjPtr);
		failure2:
			return status;
		success:
			Tcl_SetByteArrayObj(resObjPtr ,bytes ,len);
			Tcl_SetObjResult(interp ,resObjPtr);
			return TCL_OK;
	}


	critcl::cproc FinalAccelerated {
		Tcl_Interp* interp Tcl_Obj* objPtr
	} ok {
		Tcl_FreeInternalRep(objPtr);
		return TCL_OK;
	}

	critcl::cproc InitAccelerated {
		Tcl_Interp* interp Tcl_Obj* mode Tcl_Obj* keyPtr Tcl_Obj* IPtr
	} object0 {
		int i ,j ,modeidx ,Nk ,Nr ,Nb = 4;
		uint_fast32_t ivval ,ivval2;
		Tcl_Obj *resultPtr;
		Tcl_Size ivlength, keylength;
		Tcl_ObjInternalRep ir;
		aes_ctxt *ctxtPtr;

		if (Tcl_IsShared(keyPtr)) {
			keyPtr = Tcl_DuplicateObj(keyPtr);
		}

		char *keystring = Tcl_GetBytesFromObj(interp ,keyPtr ,&keylength);
		if (!keystring) {
			return NULL;
		}
		switch (keylength << 3) {
			case 128:
				Nk=4; Nr=10;
				break;
			case 192:
				Nk=6; Nr=12;
				break;
			case 256:
				Nk=8; Nr=14;
				break;
			default:
				Tcl_SetObjResult(interp, Tcl_NewStringObj(
					"{the length of the key in bytes must be one of} {128 192 256}", -1));
				return NULL;
		}

		ctxtPtr = Tcl_Alloc(sizeof(aes_ctxt));
		char *ivstring = Tcl_GetBytesFromObj(interp ,IPtr ,&ivlength);
		Tcl_GetIndexFromObj(interp, mode, aes_mode_strings, "option", TCL_EXACT, &modeidx);
		switch (modeidx) {
			case CBC:
				if (ivlength == 0) {
					for (j = 0; j < 4; j++) {
						ctxtPtr->I[j] = 0;
					}
				} else {
					if (ivlength != 16) {
						Tcl_SetObjResult(interp, Tcl_NewStringObj(
							"the length of iv must be 16 bytes", -1));
						goto failure;
					}

					for (i = 0, j = 0; i < 4; i++ , j+=4) {
						ivval = ((uint8_t)ivstring[j+0]) << 24;
						ivval += ((uint8_t)ivstring[j+1]) << 16;
						ivval += ((uint8_t)ivstring[j+2]) << 8;
						ivval += ((uint8_t)ivstring[j+3]) << 0;
						ctxtPtr->I[i] = ivval;
					}
				}
				break;
			case ECB:
				if (ivlength != 0) {
					Tcl_SetObjResult(interp, Tcl_NewStringObj(
						"In ECB mod an initialization vector is not used", -1));
					goto failure;
				}
				for (j = 0; j < 4; j++) {
					ctxtPtr->I[j] = 0;
				}
				break;
			default:
				if (interp != NULL) {
					Tcl_SetObjResult(interp, Tcl_NewStringObj(
						"mode must be either \"cbc\" or \"ecb\"", -1));
					goto failure;
				}
				break;
		}

		ctxtPtr->mode = modeidx;
		ctxtPtr->Nk = Nk;
		ctxtPtr->Nr = Nr;
		ctxtPtr->Nb = Nb;

		aes_expandkey(ctxtPtr ,keystring);

		ir.twoPtrValue.ptr1 = ctxtPtr;
		resultPtr = Tcl_NewObj();
		Tcl_InvalidateStringRep(resultPtr);
		Tcl_StoreInternalRep(resultPtr, aesObjTypePtr, &ir);
		Tcl_GetStringFromObj(resultPtr ,NULL);
		return resultPtr;

		failure:
			Tcl_Free(ctxtPtr);
			return NULL;
	}

	critcl::debug symbols
	critcl::load

}
