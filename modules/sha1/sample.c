/*
 * sample.c --
 *
 *	This file implements a secure hashing algorithm
 *
 * Copyright (c) 1999 Scriptics Corporation.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 * 
 * Test Vectors (from FIPS PUB 180-1)
 * "abc"
 *   A9993E36 4706816A BA3E2571 7850C26C 9CD0D89D
 * "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
 *   84983E44 1C3BD26E BAAE4AA1 F95129E5 E54670F1
 * A million repetitions of "a"
 *   34AA973C D4C4DAA4 F61EEB2B DBAD2731 6534016F
 */

/*
 * If byte order known, #define LITTLE_ENDIAN or BIG_ENDIAN to be faster
 */

/*
 * Copy data before messing with it.
 * #define SHA1HANDSOFF
 */

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "sample.h"

#define Rol(value, bits) (((value) << (bits)) | ((value) >> (32 - (bits))))

/*
 * Blk0() and Blk() perform the initial expand.
 * I got the idea of expanding during the round function from SSLeay
 */

#ifdef LITTLE_ENDIAN
#define Blk0(i) (block->l[i] = (Rol(block->l[i],24)&0xFF00FF00) \
    |(Rol(block->l[i],8)&0x00FF00FF))
#else
#ifdef BIG_ENDIAN
#define Blk0(i) block->l[i]
#else

/*
 * for unknown byte order, to work with either
 * results in no change on big endian machines
 * added by Dave Dykstra, 4/16/97
 */

#define Blk0(i) (block->l[i] = (*(p = (unsigned char *) (&block->l[i])) << 24) \
		+ (*(p+1) << 16) + (*(p+2) << 8) + *(p+3))
#endif
#endif
#define Blk(i) (block->l[i&15] = Rol(block->l[(i+13)&15]^block->l[(i+8)&15] \
    ^block->l[(i+2)&15]^block->l[i&15],1))

/*
 * (R0+R1), R2, R3, R4 are the different operations used in SHA1
 */

#define R0(v,w,x,y,z,i) z+=((w&(x^y))^y)+Blk0(i)+0x5A827999+Rol(v,5);w=Rol(w,30);
#define R1(v,w,x,y,z,i) z+=((w&(x^y))^y)+Blk(i)+0x5A827999+Rol(v,5);w=Rol(w,30);
#define R2(v,w,x,y,z,i) z+=(w^x^y)+Blk(i)+0x6ED9EBA1+Rol(v,5);w=Rol(w,30);
#define R3(v,w,x,y,z,i) z+=(((w|x)&y)|(w&x))+Blk(i)+0x8F1BBCDC+Rol(v,5);w=Rol(w,30);
#define R4(v,w,x,y,z,i) z+=(w^x^y)+Blk(i)+0xCA62C1D6+Rol(v,5);w=Rol(w,30);

/*
 *----------------------------------------------------------------------
 *
 * SHA1Transform
 *
 *	Hash a single 512-bit block. This is the core of the algorithm.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Contents of state pointer are changed.
 *
 *----------------------------------------------------------------------
 */

void
SHA1Transform(state, buffer)
    sha_uint32_t state[5];	/* State variable */
    unsigned char buffer[64];	/* Modified buffer */
{
#if (!defined(BIG_ENDIAN) && !defined(LITTLE_ENDIAN))
    unsigned char *p;
#endif
    sha_uint32_t a, b, c, d, e;
    typedef union {
	unsigned char c[64];
	sha_uint32_t l[16];
    } CHAR64LONG16;
    CHAR64LONG16* block;

#ifdef SHA1HANDSOFF
    static unsigned char workspace[64];
    block = (CHAR64LONG16*)workspace;
    memcpy(block, buffer, 64);
#else
    block = (CHAR64LONG16*)buffer;
#endif

    assert(sizeof(block->c) == sizeof(block->l));

    /*
     * Copy context->state[] to working vars
     */

    a = state[0];
    b = state[1];
    c = state[2];
    d = state[3];
    e = state[4];

    /*
     * 4 rounds of 20 operations each. Loop unrolled.
     */

    R0(a,b,c,d,e, 0); R0(e,a,b,c,d, 1); R0(d,e,a,b,c, 2); R0(c,d,e,a,b, 3);
    R0(b,c,d,e,a, 4); R0(a,b,c,d,e, 5); R0(e,a,b,c,d, 6); R0(d,e,a,b,c, 7);
    R0(c,d,e,a,b, 8); R0(b,c,d,e,a, 9); R0(a,b,c,d,e,10); R0(e,a,b,c,d,11);
    R0(d,e,a,b,c,12); R0(c,d,e,a,b,13); R0(b,c,d,e,a,14); R0(a,b,c,d,e,15);
    R1(e,a,b,c,d,16); R1(d,e,a,b,c,17); R1(c,d,e,a,b,18); R1(b,c,d,e,a,19);
    R2(a,b,c,d,e,20); R2(e,a,b,c,d,21); R2(d,e,a,b,c,22); R2(c,d,e,a,b,23);
    R2(b,c,d,e,a,24); R2(a,b,c,d,e,25); R2(e,a,b,c,d,26); R2(d,e,a,b,c,27);
    R2(c,d,e,a,b,28); R2(b,c,d,e,a,29); R2(a,b,c,d,e,30); R2(e,a,b,c,d,31);
    R2(d,e,a,b,c,32); R2(c,d,e,a,b,33); R2(b,c,d,e,a,34); R2(a,b,c,d,e,35);
    R2(e,a,b,c,d,36); R2(d,e,a,b,c,37); R2(c,d,e,a,b,38); R2(b,c,d,e,a,39);
    R3(a,b,c,d,e,40); R3(e,a,b,c,d,41); R3(d,e,a,b,c,42); R3(c,d,e,a,b,43);
    R3(b,c,d,e,a,44); R3(a,b,c,d,e,45); R3(e,a,b,c,d,46); R3(d,e,a,b,c,47);
    R3(c,d,e,a,b,48); R3(b,c,d,e,a,49); R3(a,b,c,d,e,50); R3(e,a,b,c,d,51);
    R3(d,e,a,b,c,52); R3(c,d,e,a,b,53); R3(b,c,d,e,a,54); R3(a,b,c,d,e,55);
    R3(e,a,b,c,d,56); R3(d,e,a,b,c,57); R3(c,d,e,a,b,58); R3(b,c,d,e,a,59);
    R4(a,b,c,d,e,60); R4(e,a,b,c,d,61); R4(d,e,a,b,c,62); R4(c,d,e,a,b,63);
    R4(b,c,d,e,a,64); R4(a,b,c,d,e,65); R4(e,a,b,c,d,66); R4(d,e,a,b,c,67);
    R4(c,d,e,a,b,68); R4(b,c,d,e,a,69); R4(a,b,c,d,e,70); R4(e,a,b,c,d,71);
    R4(d,e,a,b,c,72); R4(c,d,e,a,b,73); R4(b,c,d,e,a,74); R4(a,b,c,d,e,75);
    R4(e,a,b,c,d,76); R4(d,e,a,b,c,77); R4(c,d,e,a,b,78); R4(b,c,d,e,a,79);

    /*
     * Add the working vars back into context.state[]
     */

    state[0] += a;
    state[1] += b;
    state[2] += c;
    state[3] += d;
    state[4] += e;

    /*
     * Wipe variables
     */

    a = b = c = d = e = 0;

    return;
}

/*
 *----------------------------------------------------------------------
 *
 * SHA1Init --
 *
 *	 Initialize new context
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Contents of context pointer are changed.
 *
 *----------------------------------------------------------------------
 */

void SHA1Init(context)
    SHA1_CTX* context;		/* Context to initialize */
{
    /*
     * SHA1 initialization constants
     */

    context->state[0] = 0x67452301;
    context->state[1] = 0xEFCDAB89;
    context->state[2] = 0x98BADCFE;
    context->state[3] = 0x10325476;
    context->state[4] = 0xC3D2E1F0;
    context->count[0] = context->count[1] = 0;

    return;
}

/*
 *----------------------------------------------------------------------
 *
 * SHA1Update
 *
 *	 Updates a context.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Contents of context pointer are changed.
 *
 *----------------------------------------------------------------------
 */

void
SHA1Update(context, data, len)
    SHA1_CTX* context;		/* Context to update */
    unsigned char* data;	/* Data used for update */
    unsigned int len;		/* Length of data */
{
    unsigned int i, j;

    j = (context->count[0] >> 3) & 63;
    if ((context->count[0] += len << 3) < (len << 3)) {
	context->count[1]++;
    }
    context->count[1] += (len >> 29);
    if ((j + len) > 63) {
        memcpy(&context->buffer[j], data, (i = 64-j));
        SHA1Transform(context->state, context->buffer);
        for ( ; i + 63 < len; i += 64) {
#ifdef CANWRITEDATA
            SHA1Transform(context->state, &data[i]);
#else

	    /*
	     * else case added by Dave Dykstra 4/22/97
	     */

	    memcpy(&context->buffer[0], &data[i], 64);
            SHA1Transform(context->state, context->buffer);
#endif
        }
        j = 0;
    } else {
	i = 0;
    }

    memcpy(&context->buffer[j], &data[i], len - i);

    return;
}

/*
 *----------------------------------------------------------------------
 *
 * SHA1Final
 *
 *	Add padding and return the message digest.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Contents of context pointer are changed.
 *
 *----------------------------------------------------------------------
 */

void SHA1Final(context, digest)
    SHA1_CTX* context;		/* Context to pad */
    unsigned char digest[20];	/* Returned message digest */
{
    sha_uint32_t i, j;
    unsigned char finalcount[8];

    for (i = 0; i < 8; i++) {
	/*
	 * This statement is independent of the endianness
	 */

        finalcount[i] = (unsigned char)((context->count[(i >= 4 ? 0 : 1)]
		>> ((3-(i & 3)) * 8) ) & 255);
    }
    SHA1Update(context, (unsigned char *)"\200", 1);
    while ((context->count[0] & 504) != 448) {
        SHA1Update(context, (unsigned char *)"\0", 1);
    }

    /*
     * Should cause a SHA1Transform()
     */

    SHA1Update(context, finalcount, 8);
    for (i = 0; i < 20; i++) {
        digest[i] = (unsigned char)
		((context->state[i>>2] >> ((3-(i & 3)) * 8) ) & 255);
    }

    /*
     * Wipe variables
     */

    i = j = 0;
    memset(context, 0, sizeof(SHA1_CTX));
    memset(&finalcount, 0, 8);

    /*
     * Make SHA1Transform overwrite it's own static vars.
     */

#ifdef SHA1HANDSOFF
    SHA1Transform(context->state, context->buffer);
#endif

    return;
}
