/*	$NetBSD: sha1.h,v 1.2 2005/02/21 14:26:26 patthoyts Exp $	*/

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 */

#ifndef _SYS_SHA1_H_
#define	_SYS_SHA1_H_

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
