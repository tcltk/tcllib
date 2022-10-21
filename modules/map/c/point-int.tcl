## -*- tcl -*-
# ### ### ### ######### ######### #########
## Support declarations

# ### ### ### ######### ######### #########
## Type definitions

critcl::resulttype tripoint-int {
    Tcl_SetObjResult(interp, tripoint_int_box (interp, &rv));
    return TCL_OK;
} tripoint_int

critcl::argtype tripoint-int {
    if (tripoint_int_unbox (interp, @@, &@A) != TCL_OK) return TCL_ERROR;
} tripoint_int tripoint_int

# ### ### ### ######### ######### #########
## Support implementation

critcl::ccode {
    typedef struct tripoint_int {
	int z;
	int y;
	int x;
    } tripoint_int;

    static int tripoint_int_unbox (Tcl_Interp* interp, Tcl_Obj* obj, tripoint_int* p) {
	int       lc;
	Tcl_Obj** lv;

	if (Tcl_ListObjGetElements (interp, obj, &lc, &lv) != TCL_OK) return TCL_ERROR;
	if (lc != 3) {
	    Tcl_SetErrorCode (interp, "MAP", "SLIPPY", "INVALID", "POINT/INT", NULL);
	    Tcl_AppendResult (interp, "Bad point-int, expected list of 3", NULL);
	    return TCL_ERROR;
	}

	int z;
	int y;
	int x;

	if (Tcl_GetIntFromObj (interp, lv[0], &z) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetIntFromObj (interp, lv[1], &y) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetIntFromObj (interp, lv[2], &x) != TCL_OK) return TCL_ERROR;

	p->z = z;
	p->y = y;
	p->x = x;

	return TCL_OK;
    }

    static Tcl_Obj* tripoint_int_box (Tcl_Interp* interp, tripoint_int* p) {
	Tcl_Obj* cl[3];
	cl [0] = Tcl_NewIntObj (p->z);
	cl [1] = Tcl_NewIntObj (p->y);
	cl [2] = Tcl_NewIntObj (p->x);
	return Tcl_NewListObj(3, cl);
    }
}

# ### ### ### ######### ######### #########
return
