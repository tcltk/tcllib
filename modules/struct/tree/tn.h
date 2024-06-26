/* struct::tree - critcl - layer 1 declarations
 * (b) Node operations.
 */

#ifndef _TN_H
#define _TN_H 1

#include "tclpre9compat.h"
#include <ds.h>

void  tn_shimmer  (Tcl_Obj* o, TNPtr n);
TNPtr tn_get_node (TPtr t, Tcl_Obj* node, Tcl_Interp* interp, Tcl_Obj* tree);

TNPtr  tn_new	 (TPtr td, CONST char* name);
TNPtr  tn_dup	 (TPtr dst, TNPtr src);
void   tn_delete (TNPtr n);

void tn_node	  (TNPtr n);
void tn_notnode	  (TNPtr n);
void tn_leaf	  (TNPtr n);
void tn_notleaf	  (TNPtr n);
void tn_structure (TNPtr n, Tcl_Size depth);

void   tn_detach	 (TNPtr n);
TNPtr* tn_detachmany	 (TNPtr n, Tcl_Size len);
TNPtr* tn_detachchildren (TNPtr n, Tcl_Size* nc);

void tn_append	   (TNPtr p,	          TNPtr n);
void tn_insert	   (TNPtr p, Tcl_Size at, TNPtr n);

void tn_appendmany (TNPtr p,	          Tcl_Size nc, TNPtr* nv);
void tn_insertmany (TNPtr p, Tcl_Size at, Tcl_Size nc, TNPtr* nv);

void tn_cut	   (TNPtr n);

Tcl_Size  tn_depth	    (TNPtr n);
Tcl_Size  tn_height	    (TNPtr n);
Tcl_Size  tn_ndescendants   (TNPtr n);
Tcl_Obj** tn_getdescendants (TNPtr n, Tcl_Size* nc);
Tcl_Obj** tn_getchildren    (TNPtr n, Tcl_Size* nc);

int tn_filternodes (Tcl_Size* nc,   Tcl_Obj** nv,
		    Tcl_Size  cmdc, Tcl_Obj** cmdv,
		    Tcl_Obj*  tree, Tcl_Interp* interp);

int tn_isancestorof (TNPtr a, TNPtr b);

void	 tn_extend_attr (TNPtr n);
void	 tn_set_attr	(TNPtr n, Tcl_Interp* interp, Tcl_Obj* dict);
Tcl_Obj* tn_get_attr	(TNPtr n, Tcl_Obj* empty);

int tn_serialize (TNPtr n, Tcl_Size listc, Tcl_Obj** listv,
		  Tcl_Size at, Tcl_Size parent, Tcl_Obj* empty);

#endif /* _TN_H */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
