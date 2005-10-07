/*	$NetBSD: sha1.h,v 1.3 2005/10/07 12:54:16 patthoyts Exp $	*/

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 */

#ifndef _SYS_SHA1_H_
#define	_SYS_SHA1_H_

/* ---------------------------------------------------------------------- */

#ifndef BYTE_ORDER
#if (BSD >= 199103)
# include <machine/endian.h>
#else
#ifdef linux
# include <endian.h>
#else
#define LITTLE_ENDIAN 1234 /* least-significant byte first (vax, pc) */
#define BIG_ENDIAN    4321 /* most-significant byte first (IBM, net) */
#define PDP_ENDIAN    3412 /* LSB first in word, MSW first in long (pdp)*/

#if defined(vax) || defined(ns32000) || defined(sun386) || defined(i386) || \
    defined(MIPSEL) || defined(_MIPSEL) || defined(BIT_ZERO_ON_RIGHT) || \
    defined(__alpha__) || defined(__alpha) || defined(_M_IX86)
#define BYTE_ORDER LITTLE_ENDIAN
#endif

#if defined(sel) || defined(pyr) || defined(mc68000) || defined(sparc) || \
    defined(is68k) || defined(tahoe) || defined(ibm032) || defined(ibm370) || \
    defined(MIPSEB) || defined(_MIPSEB) || defined(_IBMR2) || defined(DGUX) ||\
    defined(apollo) || defined(__convex__) || defined(_CRAY) || \
    defined(__hppa) || defined(__hp9000) || \
    defined(__hp9000s300) || defined(__hp9000s700) || \
    defined (BIT_ZERO_ON_LEFT) || defined(m68k)
#define BYTE_ORDER BIG_ENDIAN
#endif
#endif /* linux */
#endif /* BSD */
#endif /* BYTE_ORDER */

#if !defined(BYTE_ORDER) || \
    (BYTE_ORDER != BIG_ENDIAN && BYTE_ORDER != LITTLE_ENDIAN && \
    BYTE_ORDER != PDP_ENDIAN)
/* you must determine what the correct bit order is for
 * your compiler - the next line is an intentional error
 * which will force your compiles to bomb until you fix
 * the above macros.
 */
error "Undefined or invalid BYTE_ORDER";
#endif

/* ---------------------------------------------------------------------- */

#ifdef __alpha
typedef unsigned int  u_int32_t;
#else
typedef unsigned long u_int32_t;
#endif

typedef unsigned char u_char;

typedef struct {
	u_int32_t state[5];
	u_int32_t count[2];  
	u_char    buffer[64];
} SHA1_CTX;
  
void	SHA1Transform(u_int32_t state[5], const u_char buffer[64]);
void	SHA1Init(SHA1_CTX *context);
void	SHA1Update(SHA1_CTX *context, const u_char *data, u_int32_t len);
void	SHA1Final(u_char digest[20], SHA1_CTX *context);

#endif /* _SYS_SHA1_H_ */
