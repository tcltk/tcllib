/*	$NetBSD: sha1.h,v 1.1 2005/02/21 13:24:18 patthoyts Exp $	*/

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 */

#ifndef _SYS_SHA1_H_
#define	_SYS_SHA1_H_

/* Need the following types...
 *  typedef unsigned long uint32_t; 32 bit unsigned
 *  typedef unsigned char uint8_t;   8 bit unsigned.
 * maybe MSVC will need
 */

#ifdef _MSC_VER
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
typedef UINT32 uint32_t;
typedef UINT8  uint8_t;
#else
#include <stdint.h>
#endif

typedef struct {
	uint32_t state[5];
	uint32_t count[2];  
	uint8_t  buffer[64];
} SHA1_CTX;
  
void	SHA1Transform(uint32_t state[5], const uint8_t buffer[64]);
void	SHA1Init(SHA1_CTX *context);
void	SHA1Update(SHA1_CTX *context, const uint8_t *data, uint32_t len);
void	SHA1Final(uint8_t digest[20], SHA1_CTX *context);

#endif /* _SYS_SHA1_H_ */
