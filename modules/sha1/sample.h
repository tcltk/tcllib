/*
 * sample.h --
 *
 *	This header file contains the function declarations needed for
 *	all of the source files in this package.
 *
 * Copyright (c) 1998-1999 Scriptics Corporation.
 * Copyright (c) 2003 ActiveState Corporation.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _SAMPLE
#define _SAMPLE

#include <tcl.h>

/*
 * Windows needs to know which symbols to export.  Unix does not.
 * BUILD_sample should be undefined for Unix.
 */

#ifdef BUILD_sample
#undef TCL_STORAGE_CLASS
#define TCL_STORAGE_CLASS DLLEXPORT
#endif /* BUILD_sample */

#ifdef HAVE_INTTYPES_H
#   include <inttypes.h>
typedef uint32_t sha_uint32_t;
#else
#   if ((1<<31)<0)
typedef unsigned long sha_uint32_t;
#   else
typedef unsigned int sha_uint32_t;
#   endif
#endif

typedef struct {
    sha_uint32_t state[5];
    sha_uint32_t count[2];
    unsigned char buffer[64];
} SHA1_CTX;

void SHA1Init	(SHA1_CTX* context);
void SHA1Update	(SHA1_CTX* context, unsigned char* data, unsigned int len);
void SHA1Final	(SHA1_CTX* context, unsigned char digest[20]);

/*
 * Only the _Init function is exported.
 */

EXTERN int	Sample_Init(Tcl_Interp * interp);

#endif /* _SAMPLE */
