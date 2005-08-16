/* struct::tree - critcl - layer 2 definitions
 *
 * -> Support for the tree methods in layer 3.
 */

#include <ms.h>
#include <m.h>
#include <t.h>
#include <tn.h>
#include <util.h>

/* .................................................. */

/*
 *---------------------------------------------------------------------------
 *
 * ms_getchildren --
 *
 *	Retrieval of the children for a node, either only direct children or
 *	all, possibly filtering.
 *
 * Results:
 *	A standard Tcl result code.
 *
 * Side effects:
 *	Only internal, memory allocation changes ...
 *
 *---------------------------------------------------------------------------
 */

int
ms_getchildren (TN* n, int all,
		int cmdc, Tcl_Obj** cmdv,
		Tcl_Obj* tree, Tcl_Interp* interp)
{
    int	      res;
    int	      listc = 0;
    Tcl_Obj** listv = NULL;

    if (all) {
	listv = tn_getdescendants (n, &listc);
    } else {
	listv = tn_getchildren	  (n, &listc);
    }

    if (!listc) {
	/* => (listv == NULL) */
	Tcl_SetObjResult (interp, Tcl_NewListObj (0, NULL));
	return TCL_OK;
    }

    res = tn_filternodes (&listc, listv, cmdc, cmdv, tree, interp);

    if (res != TCL_OK) {
	ckfree ((char*) listv);
	return TCL_ERROR;
    }

    if (!listc) {
	Tcl_SetObjResult (interp, Tcl_NewListObj (0, NULL));
    } else {
	Tcl_SetObjResult (interp, Tcl_NewListObj (listc, listv));
    }

    ckfree ((char*) listv);
    return TCL_OK;
}

/*
 *---------------------------------------------------------------------------
 *
 * ms_assign --
 *
 *	Copies the argument tree over into this one. Uses direct
 *	access to internal data structures for matching tree objects, and
 *	goes through a serialize/deserialize combination otherwise.
 *
 * Results:
 *	A standard Tcl result code.
 *
 * Side effects:
 *	Only internal, memory allocation changes ...
 *
 *---------------------------------------------------------------------------
 */

int
ms_assign (Tcl_Interp* interp, T* t, Tcl_Obj* srccmd)
{
    Tcl_CmdInfo srcCmd;

    if (!Tcl_GetCommandInfo(interp,
			    Tcl_GetString (srccmd),
			    &srcCmd)) {
	Tcl_AppendResult (interp, "invalid command name \"",
			  Tcl_GetString (srccmd), "\"", NULL);
	return TCL_ERROR;
    }

    if (srcCmd.objProc == ms_objcmd) {
	/* The source tree object is managed by this code also. We can
	 * retrieve and copy the data directly.
	 */

	T* src = (T*) srcCmd.objClientData;

	return t_assign (t, src);

    } else {
	/* The source tree is not managed by this package Use
	 * (de)serialization to transfer the information We do not invoke the
	 * command proc directly
	 */

	int	 res;
	Tcl_Obj* ser;
	Tcl_Obj* cmd [2];

	/* Phase 1: Obtain serialization object by invoking the object method
	 */

	cmd [0] = srccmd;
	cmd [1] = Tcl_NewStringObj ("serialize", -1);

	Tcl_IncrRefCount (cmd [0]);
	Tcl_IncrRefCount (cmd [1]);

	res = Tcl_EvalObjv (interp, 2, cmd, 0);

	Tcl_DecrRefCount (cmd [0]);
	Tcl_DecrRefCount (cmd [1]);

	if (res != TCL_OK) {
	    return TCL_ERROR;
	}

	ser = Tcl_GetObjResult (interp);
	Tcl_IncrRefCount (ser);
	Tcl_ResetResult (interp);

	/* Phase 2: Copy into ourselves using regular deserialization
	 */

	res = t_deserialize (t, interp, ser);
	Tcl_DecrRefCount (ser);
	return res;
    }
}

/*
 *---------------------------------------------------------------------------
 *
 * ms_set --
 *
 *	Copies this tree over into the argument tree. Uses direct access to
 *	internal data structures for matching tree objects, and goes through a
 *	serialize/deserialize combination otherwise.
 *
 * Results:
 *	A standard Tcl result code.
 *
 * Side effects:
 *	Only internal, memory allocation changes ...
 *
 *---------------------------------------------------------------------------
 */

int
ms_set (Tcl_Interp* interp, T* t, Tcl_Obj* dstcmd)
{
    Tcl_CmdInfo dstCmd;

    if (!Tcl_GetCommandInfo(interp,
			    Tcl_GetString (dstcmd),
			    &dstCmd)) {
	Tcl_AppendResult (interp, "invalid command name \"",
			  Tcl_GetString (dstcmd), "\"", NULL);
	return TCL_ERROR;
    }

    if (dstCmd.objProc == ms_objcmd) {
	/* The destination tree object is managed by this code also We can
	 * retrieve and copy the data directly.
	 */

	T* dest = (T*) dstCmd.objClientData;

	return t_assign (dest, t);

    } else {
	/* The destination tree is not managed by this package Use
	 * (de)serialization to transfer the information We do not invoke the
	 * command proc directly.
	 */

	int	 res;
	Tcl_Obj* ser;
	Tcl_Obj* cmd [3];

	/* Phase 1: Obtain our serialization */

	ser = ms_serialize (t->root);

	/* Phase 2: Copy into destination by invoking its deserialization
	 * method
	 */

	cmd [0] = dstcmd;
	cmd [1] = Tcl_NewStringObj ("deserialize", -1);
	cmd [2] = ser;

	Tcl_IncrRefCount (cmd [0]);
	Tcl_IncrRefCount (cmd [1]);
	Tcl_IncrRefCount (cmd [2]);

	res = Tcl_EvalObjv (interp, 3, cmd, 0);

	Tcl_DecrRefCount (cmd [0]);
	Tcl_DecrRefCount (cmd [1]);
	Tcl_DecrRefCount (cmd [2]); /* == ser, is gone now */

	if (res != TCL_OK) {
	    return TCL_ERROR;
	}

	Tcl_ResetResult (interp);
	return TCL_OK;
    }
}

/*
 *---------------------------------------------------------------------------
 *
 * ms_serialize --
 *
 *	Generates Tcl value from tree, serialized tree data.
 *
 * Results:
 *	A standard Tcl result code.
 *
 * Side effects:
 *	Only internal, memory allocation changes ...
 *
 *---------------------------------------------------------------------------
 */

Tcl_Obj*
ms_serialize (TN* n)
{
    Tcl_Obj*  ser;
    int	      end;
    int	      listc;
    Tcl_Obj** listv;
    Tcl_Obj*  empty;

    listc = 3 * (tn_ndescendants (n) + 1);
    listv = NALLOC (listc, Tcl_Obj*);
    empty = Tcl_NewObj ();
    Tcl_IncrRefCount (empty);

    end = tn_serialize (n, listc, listv, 0, -1, empty);

    ASSERT (listc == end, "Bad serialization");

    ser = Tcl_NewListObj (listc, listv);

    Tcl_DecrRefCount (empty);
    ckfree((char*) listv);

    return ser;
}

/*
 *---------------------------------------------------------------------------
 *
 * ms_objcmd --
 *
 *	Implementation of tree objects, the main dispatcher function.
 *
 * Results:
 *	A standard Tcl result code.
 *
 * Side effects:
 *	Per the called methods.
 *
 *---------------------------------------------------------------------------
 */

int
ms_objcmd (ClientData cd, Tcl_Interp* interp, int objc, Tcl_Obj* CONST* objv)
{
    T*  t = (T*) cd;
    int m;

    static CONST char* methods [] = {
	"-->",         "=",           "ancestors", "append",   "attr",
	"children",    "cut",         "delete",    "depth",    "descendants",
	"deserialize", "destroy",     "exists",    "get",      "getall",
	"height",      "index",       "insert",    "isleaf",   "keyexists",
	"keys",        "lappend",     "leaves",    "move",     "next",
	"nodes",       "numchildren", "parent",    "previous", "rename",
	"rootname",    "serialize",   "set",       "size",     "splice",
	"swap",        "unset",       "walk",      "walkproc",
	NULL
    };
    enum methods {
	M_TSET,        M_TASSIGN,     M_ANCESTORS, M_APPEND,   M_ATTR,
	M_CHILDREN,    M_CUT,         M_DELETE,    M_DEPTH,    M_DESCENDANTS,
	M_DESERIALIZE, M_DESTROY,     M_EXISTS,    M_GET,      M_GETALL,
	M_HEIGHT,      M_INDEX,       M_INSERT,    M_ISLEAF,   M_KEYEXISTS,
	M_KEYS,        M_LAPPEND,     M_LEAVES,    M_MOVE,     M_NEXT,
	M_NODES,       M_NUMCHILDREN, M_PARENT,    M_PREVIOUS, M_RENAME,
	M_ROOTNAME,    M_SERIALIZE,   M_SET,       M_SIZE,     M_SPLICE,
	M_SWAP,        M_UNSET,       M_WALK,      M_WALKPROC
    };

    if (objc < 2) {
	Tcl_WrongNumArgs (interp, objc, objv, "option ?arg arg ...?");
	return TCL_ERROR;
    } else if (Tcl_GetIndexFromObj (interp, objv [1], methods, "option",
				    0, &m) != TCL_OK) {
	return TCL_ERROR;
    }

    /* Dispatch to methods. They check the #args in detail before performing
     * the requested functionality
     */

    switch (m) {
    case M_TASSIGN:	return m_TASSIGN     (t, interp, objc, objv);
    case M_TSET:	return m_TSET	     (t, interp, objc, objv);
    case M_ANCESTORS:	return m_ANCESTORS   (t, interp, objc, objv);
    case M_APPEND:	return m_APPEND	     (t, interp, objc, objv);
    case M_ATTR:	return m_ATTR	     (t, interp, objc, objv);
    case M_CHILDREN:	return m_CHILDREN    (t, interp, objc, objv);
    case M_CUT:		return m_CUT	     (t, interp, objc, objv);
    case M_DELETE:	return m_DELETE	     (t, interp, objc, objv);
    case M_DEPTH:	return m_DEPTH	     (t, interp, objc, objv);
    case M_DESCENDANTS: return m_DESCENDANTS (t, interp, objc, objv);
    case M_DESERIALIZE: return m_DESERIALIZE (t, interp, objc, objv);
    case M_DESTROY:	return m_DESTROY     (t, interp, objc, objv);
    case M_EXISTS:	return m_EXISTS	     (t, interp, objc, objv);
    case M_GET:		return m_GET	     (t, interp, objc, objv);
    case M_GETALL:	return m_GETALL	     (t, interp, objc, objv);
    case M_HEIGHT:	return m_HEIGHT	     (t, interp, objc, objv);
    case M_INDEX:	return m_INDEX	     (t, interp, objc, objv);
    case M_INSERT:	return m_INSERT	     (t, interp, objc, objv);
    case M_ISLEAF:	return m_ISLEAF	     (t, interp, objc, objv);
    case M_KEYEXISTS:	return m_KEYEXISTS   (t, interp, objc, objv);
    case M_KEYS:	return m_KEYS	     (t, interp, objc, objv);
    case M_LAPPEND:	return m_LAPPEND     (t, interp, objc, objv);
    case M_LEAVES:	return m_LEAVES	     (t, interp, objc, objv);
    case M_MOVE:	return m_MOVE	     (t, interp, objc, objv);
    case M_NEXT:	return m_NEXT	     (t, interp, objc, objv);
    case M_NODES:	return m_NODES	     (t, interp, objc, objv);
    case M_NUMCHILDREN: return m_NUMCHILDREN (t, interp, objc, objv);
    case M_PARENT:	return m_PARENT	     (t, interp, objc, objv);
    case M_PREVIOUS:	return m_PREVIOUS    (t, interp, objc, objv);
    case M_RENAME:	return m_RENAME	     (t, interp, objc, objv);
    case M_ROOTNAME:	return m_ROOTNAME    (t, interp, objc, objv);
    case M_SERIALIZE:	return m_SERIALIZE   (t, interp, objc, objv);
    case M_SET:		return m_SET	     (t, interp, objc, objv);
    case M_SIZE:	return m_SIZE	     (t, interp, objc, objv);
    case M_SPLICE:	return m_SPLICE	     (t, interp, objc, objv);
    case M_SWAP:	return m_SWAP	     (t, interp, objc, objv);
    case M_UNSET:	return m_UNSET	     (t, interp, objc, objv);
    case M_WALK:	return m_WALK	     (t, interp, objc, objv);
    case M_WALKPROC:	return m_WALKPROC    (t, interp, objc, objv);
    }
    /* Not coming to this place */
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
