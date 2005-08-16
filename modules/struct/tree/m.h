/* struct::tree - critcl - layer 3 declarations
 * Method functions.
 */

#ifndef _M_H
#define _M_H 1

#include "tcl.h"
#include <t.h>

int m_TASSIGN	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_TSET	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_ANCESTORS	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_APPEND	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_ATTR	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_CHILDREN	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_CUT	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_DELETE	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_DEPTH	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_DESCENDANTS (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_DESERIALIZE (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_DESTROY	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_EXISTS	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_GET	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_GETALL	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_HEIGHT	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_INDEX	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_INSERT	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_ISLEAF	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_KEYEXISTS	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_KEYS	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_LAPPEND	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_LEAVES	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_MOVE	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_NEXT	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_NODES	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_NUMCHILDREN (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_PARENT	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_PREVIOUS	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_RENAME	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_ROOTNAME	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_SERIALIZE	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_SET	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_SIZE	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_SPLICE	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_SWAP	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_UNSET	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_WALK	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);
int m_WALKPROC	  (T* td, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);

#endif /* _M_H */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
