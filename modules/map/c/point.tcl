## -*- tcl -*-
# ### ### ### ######### ######### #########
## Support declarations

# ### ### ### ######### ######### #########
## Type definitions

critcl::resulttype tripoint {
    Tcl_SetObjResult(interp, tripoint_box (interp, &rv));
    return TCL_OK;
} tripoint

critcl::argtype tripoint {
    if (tripoint_unbox (interp, @@, &@A) != TCL_OK) return TCL_ERROR;
} tripoint tripoint

# ### ### ### ######### ######### #########
## Support implementation

critcl::ccode {
    #include <stdio.h>

    typedef struct tripoint {
	int    z;
	double y;
	double x;
    } tripoint;

    static int tripoint_unbox (Tcl_Interp* interp, Tcl_Obj* obj, tripoint* p) {
	int       lc;
	Tcl_Obj** lv;

	if (Tcl_ListObjGetElements (interp, obj, &lc, &lv) != TCL_OK) return TCL_ERROR;
	if (lc != 3) {
	    Tcl_SetErrorCode (interp, "MAP", "SLIPPY", "INVALID", "POINT");
	    Tcl_AppendResult (interp, "Bad point, expected list of 3");
	    return TCL_ERROR;
	}

	int    z;
	double y;
	double x;

	if (Tcl_GetIntFromObj    (interp, lv[0], &z) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetDoubleFromObj (interp, lv[1], &y) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetDoubleFromObj (interp, lv[2], &x) != TCL_OK) return TCL_ERROR;

	p->z = z;
	p->y = y;
	p->x = x;

	return TCL_OK;
    }

    static Tcl_Obj* tripoint_box (Tcl_Interp* interp, tripoint* p) {
	Tcl_Obj* cl[3];
	cl [0] = Tcl_NewIntObj    (p->z);
	cl [1] = Tcl_NewDoubleObj (p->y);
	cl [2] = Tcl_NewDoubleObj (p->x);
	return Tcl_NewListObj(3, cl);
    }
}

# ### ### ### ######### ######### #########
return
