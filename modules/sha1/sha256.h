/*-
 * Copyright (c) 2001, 2002 Allan Saddi <allan@saddi.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	$Id: sha256.h,v 1.4 2011/04/21 17:51:55 andreas_kupries Exp $
 */

#ifndef _SHA256_H
#define _SHA256_H

/*
#if HAVE_INTTYPES_H
# include <inttypes.h>
#else
# if HAVE_STDINT_H
#  include <stdint.h>
# endif
#endif
*/
# include <stdint.h>
# include <tcl.h>

/*
 * These macros are used to control whether functions are being declared for
 * import or export. If a function is being declared while it is being built
 * to be included in a shared library, then it should have the DLLEXPORT
 * storage class. If is being declared for use by a module that is going to
 * link against the shared library, then it should have the DLLIMPORT storage
 * class. If the symbol is beind declared for a static build or for use from a
 * stub library, then the storage class should be empty.
 *
 * The convention is that a macro called BUILD_xxxx, where xxxx is the name of
 * a library we are building, is set on the compile line for sources that are
 * to be placed in the library. When this macro is set, the storage class will
 * be set to DLLEXPORT. At the end of the header file, the storage class will
 * be reset to DLLIMPORT.
 */

#undef TCL_STORAGE_CLASS
#ifdef BUILD_sha256c
#   define TCL_STORAGE_CLASS DLLEXPORT
#else
#   ifdef USE_SHA256C_STUBS
#      define TCL_STORAGE_CLASS
#   else
#      define TCL_STORAGE_CLASS DLLIMPORT
#   endif
#endif


#define SHA256_HASH_SIZE 32

/* Hash size in 32-bit words */
#define SHA256_HASH_WORDS 8

/*
#ifdef _MSC_VER
typedef unsigned __int64    uint64_t;
#elif !(defined(__hpux) || defined(_AIX))
typedef unsigned long long  uint64_t;
#endif
*/

#if !(defined(__hpux))
typedef unsigned int        uint32_t;
typedef unsigned char       uint8_t;
#endif

struct _SHA256Context {
  uint64_t totalLength;
  uint32_t hash[SHA256_HASH_WORDS];
  uint32_t bufferLength;
  union {
    uint32_t words[16];
    uint8_t bytes[64];
  } buffer;
};

typedef struct _SHA256Context SHA256Context;
typedef struct _SHA256Context SHA256_CTX;

#ifdef __cplusplus
extern "C" {
#endif

EXTERN void SHA256Init (SHA256Context *sc);
EXTERN void SHA256Update (SHA256Context *sc, const void *data, uint32_t len);
EXTERN void SHA256Final (SHA256Context *sc, uint8_t hash[SHA256_HASH_SIZE]);

void SHA224Init (SHA256Context *sc);

#ifdef __cplusplus
}
#endif

#endif /* !_SHA256_H */
