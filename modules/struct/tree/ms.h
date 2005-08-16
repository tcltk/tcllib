/* struct::tree - critcl - layer 2 declarations
 * Support for tree methods.
 */

#ifndef _MS_H
#define _MS_H 1

#include "tcl.h"
#include <ds.h>

int	 ms_objcmd (ClientData cd, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv);

int	 ms_assign    (Tcl_Interp* interp, TPtr t, Tcl_Obj* srccmd);
int	 ms_set	      (Tcl_Interp* interp, TPtr t, Tcl_Obj* dstcmd);
Tcl_Obj* ms_serialize (TNPtr n);

int ms_getchildren (TNPtr n, int all,
		    int cmdc, Tcl_Obj** cmdv,
		    Tcl_Obj* tree, Tcl_Interp* interp);

#endif /* _MS_H */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
