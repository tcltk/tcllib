/*
 * = = == === ===== ======== ============= =====================
 * == pt::rde (critcl) - Data Structures - ObjType for interned strings.
 */

#ifndef _RDE_DS_OT_H
#define _RDE_DS_OT_H 1

#include "tcl.h"
#include <p.h>   /* State declarations */

long int rde_ot_intern (Tcl_Obj* obj, RDE_STATE p,
			const char* pfx, const char* sfx);

#endif /* _RDE_DS_OT_H */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
